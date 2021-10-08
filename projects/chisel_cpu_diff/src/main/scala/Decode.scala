import chisel3._
import chisel3.util._
import Instructions._
class ID_TO_IF_BUS extends Bundle{
  val next_pc=Output(UInt(32.W))
  val jump = Output(Bool)
}
class ID_TO_EX_BUS extends Bundle{
  val opcode = Output(UInt(8.W))
  val imm = Output(UInt(64.W))
  val load = Output(Bool)
  val save = Output(Bool)
}
class Decode extends Module {
  val io = IO(new Bundle {
    val if_to_id=Flipped(new IF_TO_ID_BUS)
    val id_to_ex=new ID_TO_EX_BUS

    val rs1_addr = Output(UInt(5.W))
    val rs1_en = Output(Bool())
    val rs2_addr = Output(UInt(5.W))
    val rs2_en = Output(Bool())
    val rd_addr = Output(UInt(5.W))
    val rd_en = Output(Bool())

  })

  val inst = io.if_to_id.inst
  val opcode = WireInit(UInt(8.W), 0.U)
  val imm_i = Cat(Fill(53, inst(31)), inst(30, 20))
  

  // Only example here, use your own control flow!
  when (inst === ADDI) {
    opcode := 1.U
  }

  io.rs1_addr := inst(19, 15)
  io.rs2_addr := inst(24, 20)
  io.rd_addr := inst(11, 7)
  
  io.rs1_en := false.B
  io.rs2_en := false.B
  io.rd_en := false.B

  when (inst === ADDI) {
    io.rs1_en := true.B
    io.rs2_en := false.B
    io.rd_en := true.B
  }
  
  io.id_to_ex.opcode := opcode
  io.id_to_ex.imm := imm_i
}
