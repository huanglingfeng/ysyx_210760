import chisel3._
import chisel3.util._
import Consts._

class CSR extends Module {
  val io = IO(new Bundle {
    val csr_to_id = Flipped(new ID_TO_CSR_BUS)
    val csr_to_lsu = Flipped(new LSU_TO_CSR_BUS)

    val mcycle = Output(UInt(64.W))
    val mepc = Output(UInt(64.W))
    val mcause = Output(UInt(64.W))
    val mtvec = Output(UInt(64.W))
    val mstatus = Output(UInt(64.W))
    val mie = Output(UInt(64.W))
    val mip = Output(UInt(64.W))
    val mscratch = Output(UInt(64.W))

    val sstatus = Output(UInt(64.W))

    val intrNO = Output(UInt(32.W))
    val cause = Output(UInt(32.W))

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
  val mstatus_i = RegInit(UInt(63.W), "h0000_0000_0000_1800".U)
  val mSD = Wire(Bool())
  mSD := (mstatus_i(16,15) === "b11".U || mstatus_i(14,13) === "b11".U)
  val mstatus = Cat(mSD,mstatus_i)

  val mscratch = RegInit(UInt(64.W), 0.U)

  val mie = RegInit(0.U(64.W))
  val mip = RegInit(0.U(64.W))

  //----------------为了配合nemu的csr相关指令行为加上的wire型csr输出----------//
  val mepc_o = WireInit(UInt(64.W), 0.U)
  val mcause_o = WireInit(UInt(64.W), 0.U)
  val mtvec_o = WireInit(UInt(64.W), 0.U)

  val mstatus_o_i = WireInit(UInt(63.W), 0.U)
  val mstatus_o = WireInit(UInt(64.W), 0.U)
  val mSD_o = WireInit(Bool(),false.B)

  val mscratch_o = WireInit(UInt(64.W), 0.U)
  val mie_o = WireInit(0.U(64.W))
  val mip_o = WireInit(0.U(64.W))
  val mcycle_o = WireInit(0.U(64.W))

  val sstatus_o = WireInit(0.U(64.W))
  //-----------------Clint------------------------------------------------//
  val is_clint = io.csr_to_lsu.is_clint
  val is_mtime = io.csr_to_lsu.is_mtime
  val is_mtimecmp = io.csr_to_lsu.is_mtimecmp
  val load = io.csr_to_lsu.load
  val save = io.csr_to_lsu.save
  val wdata = io.csr_to_lsu.wdata

  val mtime = RegInit(0.U(64.W))
  when(true.B) {
    mtime := mtime + 1.U
  }
  val mtimecmp = RegInit(UInt(64.W),"h8ff".U)
  when(mtime >= mtimecmp){
    mip := Cat(mip(63,8),1.U,mip(6,0)) 
  }
  // when(true.B){
  //   mie := Cat(mie(63,8),mip(7),mie(6,0))
  // }
  
  val clint_out = WireInit(0.U(64.W))

  when(is_clint){
    when(load){
      clint_out := Mux(is_mtime,mtime,Mux(is_mtimecmp,mtimecmp,"h0".U(64.W))) 
    }.elsewhen(save){
      when(is_mtime){
        mtime := wdata
      }.elsewhen(is_mtimecmp){
        mtimecmp := wdata
      }
    }
  }
  io.csr_to_lsu.rdata := clint_out
  val clk_int = (mip(7) === true.B)
  //------------------------------------------------------------//

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


  val is_trap_begin = (csrop === CSR_ECALL) || clk_int
  val is_trap_end = (csrop === CSR_MRET)
  io.csr_to_id.csr_jump := is_trap_begin || is_trap_end

  val intrNO = Mux1H(
    Seq(
      !clk_int -> 0.U,
      clk_int ->"h7".U(32.W)
    )
  )
  val cause = Mux1H(
    Seq(
      !(csrop === CSR_ECALL) -> 0.U,
      (csrop === CSR_ECALL) -> "hb".U(32.W)
    )
  )
  io.intrNO := intrNO
  io.cause := cause

  val csr_target = WireInit(0.U(64.W))
  val is_csrop = is_rw || is_rs || is_rc
  when(is_csrop){
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
      mcycle_o := (mcycle & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MEPC_N) {
      mepc := (mepc & ~csr_mask) | (csr_data_i & csr_mask)
      mepc_o := (mepc & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MCAUSE_N) {
      mcause := (mcause & ~csr_mask) | (csr_data_i & csr_mask)
      mcause_o := (mcause & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MTVEC_N) {
      mtvec := (mtvec & ~csr_mask) | (csr_data_i & csr_mask)
      mtvec_o := (mtvec & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MSTATUS_N) {
      mstatus_i := (mstatus(62,0) & ~csr_mask(62,0)) | (csr_data_i(62,0) & csr_mask(62,0))

      mstatus_o_i := (mstatus(62,0) & ~csr_mask(62,0)) | (csr_data_i(62,0) & csr_mask(62,0))
      mSD_o := (mstatus_o_i(16,15) === "b11".U || mstatus_o_i(14,13) === "b11".U)
      mstatus_o := Cat(mSD_o,mstatus_o_i)
      sstatus_o := Cat(mSD_o,0.U(46.W),mstatus_o(16,15),mstatus_o(14,13),0.U(13.W))
    }.elsewhen(csr_addr === MIP_N) {
      mip := (mip & ~csr_mask) | (csr_data_i & csr_mask)
      mip_o := (mip & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MIE_N) {
      mie := (mie & ~csr_mask) | (csr_data_i & csr_mask)
      mie_o := (mie & ~csr_mask) | (csr_data_i & csr_mask)
    }.elsewhen(csr_addr === MSCRATCH_N){
      mscratch := (mscratch & ~csr_mask) | (csr_data_i & csr_mask)
      mscratch_o := (mscratch & ~csr_mask) | (csr_data_i & csr_mask)
    }
  }

  when(is_trap_begin) {
    when(csrop === CSR_ECALL){
      mcause := Cat(false.B,"d11".U(63.W))
      mstatus_i := Cat(   mstatus(62,13),"b11".U(2.W),mstatus(10,8),mstatus(3),mstatus(6,4),0.U,mstatus(2,0))
      mepc := id_pc

      mcause_o := Cat(false.B,"d11".U(63.W))

      mstatus_o_i := Cat(   mstatus(62,13),"b11".U(2.W),mstatus(10,8),mstatus(3),mstatus(6,4),0.U,mstatus(2,0))
      mSD_o := (mstatus_o_i(16,15) === "b11".U || mstatus_o_i(14,13) === "b11".U)
      mstatus_o := Cat(mSD_o,mstatus_o_i)
      sstatus_o := Cat(mSD_o,0.U(46.W),mstatus_o(16,15),mstatus_o(14,13),0.U(13.W))

      mepc_o := id_pc
    }
    when(clk_int){
      mcause := Cat(true.B,"d7".U(63.W))
      mstatus_i := Cat(   mstatus(62,13),"b11".U(2.W),mstatus(10,8),mstatus(3),mstatus(6,4),0.U,mstatus(2,0))
      //mie := Cat(mie(63,8),1.U,mie(6,0))
      mip := 0.U
      mtime := "h0".U
      mepc := id_pc

      mcause_o := Cat(true.B,"d7".U(63.W))

      mstatus_o_i := Cat(   mstatus(62,13),"b11".U(2.W),mstatus(10,8),mstatus(3),mstatus(6,4),0.U,mstatus(2,0))
      mSD_o := (mstatus_o_i(16,15) === "b11".U || mstatus_o_i(14,13) === "b11".U)
      mstatus_o := Cat(mSD_o,mstatus_o_i)
      sstatus_o := Cat(mSD_o,0.U(46.W),mstatus_o(16,15),mstatus_o(14,13),0.U(13.W))

      mepc_o := id_pc
    }
    when(mtvec(1, 0) === 0.U) {
      csr_target := mtvec
    }.elsewhen(mtvec(1, 0) === 1.U) {
      csr_target := (Cat(mtvec(63, 2), 0.U(2.W)) + Cat(0.U, mcause(62, 0)) << 2)
    }

    // when(mstatus(12,11) === "b11".U(2.W) && (csrop === CSR_ECALL)){
    //   mcause := "h0000_0000_0000_000b".U(64.W)                             //重复设计?
    // }                                               
  }.elsewhen(is_trap_end) {
    when(csrop === CSR_MRET){
      mstatus_i := Cat(   mstatus(62,13),"b00".U(2.W),mstatus(10,8),1.U,mstatus(6,4),mstatus(7),mstatus(2,0))

      mstatus_o_i := Cat(   mstatus(62,13),"b00".U(2.W),mstatus(10,8),1.U,mstatus(6,4),mstatus(7),mstatus(2,0))
      mSD_o := (mstatus_o_i(16,15) === "b11".U || mstatus_o_i(14,13) === "b11".U)
      mstatus_o := Cat(mSD_o,mstatus_o_i)
      sstatus_o := Cat(mSD_o,0.U(46.W),mstatus_o(16,15),mstatus_o(14,13),0.U(13.W))

      //mtime := 0.U
    }
    csr_target := mepc
  }

  io.csr_to_id.csr_res := csr_res
  io.csr_to_id.csr_target := csr_target

  io.mcycle := Mux(is_csrop && csr_addr === MCYCLE_N,mcycle_o,mcycle)
  io.mepc := Mux((is_csrop && csr_addr === MEPC_N) || is_trap_begin,mepc_o,mepc)
  io.mcause := Mux((is_csrop && csr_addr === MCAUSE_N) || is_trap_begin,mcause_o,mcause)
  io.mtvec := Mux(is_csrop && csr_addr === MTVEC_N,mtvec_o,mtvec)
  
  io.mstatus := Mux((is_csrop && csr_addr === MSTATUS_N) || is_trap_begin || is_trap_end,mstatus_o,mstatus)
  io.mip := Mux(is_csrop && csr_addr === MIP_N,mip_o,mip)
  io.mie := Mux(is_csrop && csr_addr === MIE_N,mie_o,mie)
  io.mscratch := Mux(is_csrop && csr_addr === MSCRATCH_N,mscratch_o,mscratch)
  val sstatus = Cat(mSD,0.U(46.W),mstatus(16,15),mstatus(14,13),0.U(13.W))
  io.sstatus := Mux((is_csrop && csr_addr === MSTATUS_N) || is_trap_begin || is_trap_end,sstatus_o,sstatus)
}
