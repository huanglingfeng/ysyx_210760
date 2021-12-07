import chisel3._
import chisel3.util._
import Instructions._
import Consts._

class InstFetch extends Module {
  val io = IO(new Bundle {
    val ds_allowin = Input(Bool())
    val fs_to_ds_valid = Output(Bool())

    // val imem = new RomIO
    val isram = new SRAM_BUS

    val if_to_id = new IF_TO_ID_BUS
    val id_to_if = Flipped(new ID_TO_IF_BUS)

    val br_stall = Output(Bool())
  })
  val jump = io.id_to_if.jump

  //------------流水线控制逻辑------------------------------//
  val addr_valid = RegInit(false.B)
  val to_fs_valid = ~(Module.reset).asBool() && !addr_valid

  val fs_ready_go = io.isram.data_ok

  val fs_allowin = Wire(Bool())
  val fs_valid = RegEnable(to_fs_valid ,false.B,fs_allowin)
  val fs_to_ds_valid = Wire(Bool())

  fs_allowin := !fs_valid || (fs_ready_go && io.ds_allowin)
  fs_to_ds_valid := fs_valid && fs_ready_go
  io.fs_to_ds_valid := fs_to_ds_valid

  val addr_can_send = RegInit(false.B)
  io.isram.addr_can_send := addr_can_send
  
  val pc_can_change = to_fs_valid && fs_allowin
  val addr_hs = io.isram.addr_ok && addr_can_send
  io.isram.using := fs_to_ds_valid && io.ds_allowin
  //-------------------------------------------------------//
  io.br_stall := jump && ~fs_ready_go

  val pc_en = RegInit(false.B)
  pc_en := true.B

  val pc = RegInit("h0000_0000_7FFF_FFFC".U(64.W))

  val nextpc = Mux(jump, io.id_to_if.pc_target , pc + 4.U)
  when(addr_hs){
    addr_valid := true.B
    addr_can_send := false.B
  }
  when(addr_valid && io.isram.using){
    addr_valid := false.B
  }
  when (pc_can_change){
    pc := nextpc
    addr_can_send := true.B
  }
  io.isram.wr := false.B
  io.isram.size := SIZE_D
  io.isram.addr := pc
  io.isram.wstrb := 0.U
  io.isram.wdata := 0.U
  
  io.isram.addr_valid := addr_valid

  io.if_to_id.pc := Mux(pc_en, pc, 0.U)
  // io.if_to_id.inst := Mux(pc_en, io.imem.rdata(31, 0), 0.U)
  val pc_is_wrong = (pc =/= io.id_to_if.pc_target) && jump

  // val imem_data = io.imem.rdata(31, 0)
  val isram_data = Mux(io.isram.data_ok,io.isram.rdata(31,0),0.U)

  io.if_to_id.is_nop := (pc_en && pc_is_wrong) || !fs_to_ds_valid

  io.if_to_id.inst := Mux(!fs_to_ds_valid,NOP,
  Mux1H(
    Seq(
      !pc_en -> 0.U,
      (pc_en && pc_is_wrong) -> NOP,
      (pc_en && !pc_is_wrong) -> isram_data
    )
  ))

}
