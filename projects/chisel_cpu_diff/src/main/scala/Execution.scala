import chisel3._
import chisel3.util._

class EX_TO_ISU_BUS extends Bundle{
    val alu_res = Output(UInt(64.W))

    val lsuop = Output(UInt(8.W))
    val rv64op = Output(UInt(12.W))
    val dest = Output(UInt(5.W))
    val rf_w = Output(Bool)
    val load = Output(Bool)
    val save = Output(Bool)
}

class Execution extends Module {
  val io = IO(new Bundle {
    val id_to_ex = Flipped(new ID_TO_EX_BUS)
    val ex_to_isu = new EX_TO_ISU_BUS

    // val dmem = new RamIO
  })
  val aluop = id_to_ex.aluop
  val rv64op = id_to_ex.rv64op
  val src1 = id_to_ex.out1
  val src2 = id_to_ex.out2

  ex_to_isu.lsuop := id_to_ex.lsuop
  ex_to_isu.rv64op := id_to_ex.rv64op
  ex_to_isu.dest := id_to_ex.dest
  ex_to_isu.rf_w := id_to_ex.rf_w
  ex_to_isu.load := id_to_ex.load
  ex_to_isu.save := id_to_ex.save

  val i_add = aluop(0)
  val i_slt = aluop(1)
  val i_sltu = aluop(2)
  val i_and = aluop(3)
  val i_or = aluop(4)
  val i_xor = aluop(5)
  val i_sll = aluop(6)
  val i_srl = aluop(7)
  val i_sra = aluop(8)
  val i_lui = aluop(9)
  val i_sub = aluop(10)

  val add_res = src1 + src2

  val slt_res = Mux(src1.asSInt()<src2.asSInt(),1.U(64.W),0.U(64.W))

  val sltu_res = Mux(src1.asUInt()<src2.asUInt(),1.U(64.W),0.U(64.W))

  val and_res = src1 & src2
  
  val or_res = src1 | src2
  
  val xor_res = src1 ^ src2
  
  val sll_res = src1 << src2(4,0)

  val srl_res = src1.asUInt() >> src2(4,0)
  
  val sra_res = src1.asSInt() >> src2(4,0)
  
  val lui_res = src2

  val sub_res = src1 - src2

  val alu_res = Mux1H(Seq(
    (aluop === 0) -> 0.U,
    i_add -> add_res,
    i_slt -> slt_res,
    i_sltu -> sltu_res,
    i_and -> and_res,
    i_or -> or_res,
    i_xor -> xor_res,
    i_sll -> sll_res,
    i_srl -> srl_res,
    i_sra -> sra_res,
    i_lui -> lui_res,
    i_sub -> sub_res
  ))

  // io.dmem.en := false.B
  // io.dmem.addr := 0.U
  // io.dmem.wen := false.B
  // io.dmem.wdata := 0.U
  // io.dmem.wmask := 0.U

}
