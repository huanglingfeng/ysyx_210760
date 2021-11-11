import chisel3._
import chisel3.util._
class IF_TO_ID_BUS extends Bundle {
  val pc = Output(UInt(64.W))
  val inst = Output(UInt(32.W))
}
class InstFetch extends Module {
  val io = IO(new Bundle {
    val imem = new RomIO
    val if_to_id = new IF_TO_ID_BUS
    val id_to_if = Flipped(new ID_TO_IF_BUS)
  })

  val pc_en = RegInit(false.B)
  pc_en := true.B

  val pc = RegInit("h0000_0000_7FFF_FFFC".U(64.W))
  pc := Mux(io.id_to_if.jump, io.id_to_if.pc_target, pc + 4.U)

  io.imem.en := true.B
  io.imem.addr := pc.asUInt()

  io.if_to_id.pc := Mux(pc_en, pc, 0.U)
  io.if_to_id.inst := Mux(pc_en, io.imem.rdata(31, 0), 0.U)
}