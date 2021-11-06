import chisel3._
import chisel3.util._
import Consts._

class CSR extends Module {
  val io = IO(new Bundle {
    val csr_to_id = Flipped(new ID_TO_CSR_BUS)

    val mcycle = Output(UInt(64.W))
    val mepc = Output(UInt(64.W))
    val mcause = Output(UInt(64.W))
    val mtvec = Output(UInt(64.W))
    val mstatus = Output(UInt(64.W))
    val mie = Output(UInt(64.W))
    val mip = Output(UInt(64.W))

  })
  val csrop = io.csr_to_id.csrop
  val csr_addr = io.csr_to_id.csr_addr
  val src1 = io.csr_to_id.src1
  val is_zero = io.csr_to_id.is_zero
  val id_pc = io.csr_to_id.id_pc

  val csr_res = WireInit(UInt(64.W), 0.U)

  val mcycle = RegInit(UInt(64.W), 0.U)
  when(true.B) {
    mcycle := mcycle + 1.U
  }
  val mepc = Reg(UInt(64.W))
  val mcause = RegInit(UInt(64.W), 0.U)
  val mtvec = RegInit(UInt(64.W), 0.U)
  val mstatus = RegInit(UInt(64.W), "h0000_0000_0000_1800".U)

  val mie = RegInit(0.U(64.W))
  val mip = RegInit(0.U(64.W))

  val csr_data_o = Mux1H(
    Seq(
      (csr_addr === 0.U) -> 0.U,
      (csr_addr === MCYCLE_N) -> mcycle,
      (csr_addr === MEPC_N) -> mepc,
      (csr_addr === MCAUSE_N) -> mcause,
      (csr_addr === MTVEC_N) -> mtvec,
      (csr_addr === MSTATUS_N) -> mstatus,
      (csr_addr === MIP_N) -> mip,
      (csr_addr === MIE_N) -> mie
    )
  )
  val csr_src = src1
  val csr_data_i = WireInit(0.U(64.W))
  val csr_mask = WireInit(0.U(64.W)) //屏蔽信号，0屏蔽
  val is_rw = (csrop === CSR_RW || csrop === CSR_RWI)
  val is_rs = (csrop === CSR_RS || csrop === CSR_RSI)
  val is_rc = (csrop === CSR_RC || csrop === CSR_RCI)

  val is_trap_begin = (csrop === CSR_ECALL)
  val is_trap_end = (csrop === CSR_MRET)

  val csr_target = WireInit(0.U(64.W))
  when(!is_trap_begin && !is_trap_end) {
    when(is_rw) {
      csr_res := csr_data_o
      csr_data_i := csr_src
      csr_mask := Mux(is_zero, 0.U, "hffff_ffff_ffff_ffff".U(64.W))
    }.elsewhen(is_rs) {
      csr_res := csr_data_o
      csr_data_i := csr_src
      csr_mask := Mux(is_zero, 0.U, csr_src)
    }.elsewhen(is_rc) {
      csr_res := csr_data_o
      csr_data_i := ~csr_src
      csr_mask := Mux(is_zero, 0.U, csr_src)
    }

    when(csr_addr === MCYCLE_N) {
      mcycle := (mcycle & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MEPC_N) {
      mepc := (mepc & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MCAUSE_N) {
      mcause := (mcause & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MTVEC_N) {
      mtvec := (mtvec & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MSTATUS_N) {
      mstatus := (mstatus & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MIP_N) {
      mip := (mip & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MIE_N) {
      mie := (mie & ~csr_mask) | (csr_data_i & csr_mask)
    }
  }.elsewhen(is_trap_begin) {
    when(csrop === CSR_ECALL){
      mstatus := Cat(mstatus(63,13),"b11".U(2.W),mstatus(10,8),mstatus(3),mstatus(6,4),0.U,mstatus(2,0))
    }
    when(mtvec(1, 0) === 0.U) {
      csr_target := mtvec
    }.elsewhen(mtvec(1, 0) === 1.U) {
      csr_target := (Cat(mtvec(63, 2), 0.U(2.W)) + Cat(0.U, mcause(62, 0)) << 2)
    }

    when(mstatus(12,11) === "b11".U(2.W) && (csrop === CSR_ECALL)){
      mcause := "h0000_0000_0000_000b".U(64.W)
    }

    mepc := id_pc
  }.elsewhen(is_trap_end) {
    when(csrop === CSR_MRET){
      mstatus := Cat(mstatus(63,13),"b00".U(2.W),mstatus(10,8),1.U,mstatus(6,4),mstatus(7),mstatus(2,0))
    }
    csr_target := mepc
  }

  io.csr_to_id.csr_res := csr_res
  io.csr_to_id.csr_target := csr_target

  io.mcycle := mcycle
  io.mepc := mepc
  io.mcause := mcause
  io.mtvec := mtvec
  io.mstatus := mstatus
  io.mip := mip
  io.mie := mie
}
