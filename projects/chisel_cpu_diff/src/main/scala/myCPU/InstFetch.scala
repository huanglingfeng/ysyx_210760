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
  })
  val jump = io.id_to_if.jump

  //------------流水线控制逻辑------------------------------//
  val to_fs_valid = ~(Module.reset).asBool()
  val rw_valid = to_fs_valid
  val hs_done = io.isram.rw_ready && rw_valid

  val fs_ready_go = hs_done

  val fs_allowin = Wire(Bool())
  val fs_valid = RegEnable(to_fs_valid,true.B,fs_allowin)
  val fs_to_ds_valid = Wire(Bool())

  fs_allowin := !fs_valid || (fs_ready_go && io.ds_allowin)
  fs_to_ds_valid := fs_valid && fs_ready_go
  io.fs_to_ds_valid := fs_to_ds_valid

  //-------------------------------------------------------//
  val pc_en = RegInit(false.B)
  pc_en := true.B

  val pc = RegInit("h0000_0000_7FFF_FFFC".U(64.W))
  val pc_out = RegInit("h0000_0000_8000_0000".U(64.W))

  val nextpc = Mux(jump, io.id_to_if.pc_target, pc + 4.U)
  
  when(hs_done){
    pc := pc_out
    pc_out := next_pc
  }
  // io.imem.en := true.B
  // io.imem.addr := pc.asUInt()
  io.isram.wr := false.B
  io.isram.size := SIZE_D
  io.isram.addr := pc_out
  io.isram.wstrb := 0.U
  io.isram.wdata := 0.U
  
  io.isram.rw_valid := rw_valid

  io.if_to_id.pc := Mux(pc_en, pc, 0.U)
  // io.if_to_id.inst := Mux(pc_en, io.imem.rdata(31, 0), 0.U)

  // val imem_data = io.imem.rdata(31, 0)
  val isram_data = RegEnable(io.isram.rdata(31,0),hs_done)

  io.if_to_id.is_nop := (pc_en && jump) || !fs_to_ds_valid

  io.if_to_id.inst := Mux(!fs_to_ds_valid,NOP,
  Mux1H(
    Seq(
      !pc_en -> 0.U,
      (pc_en && jump) -> NOP,
      (pc_en && !jump) -> isram_data
    )
  ))

}
