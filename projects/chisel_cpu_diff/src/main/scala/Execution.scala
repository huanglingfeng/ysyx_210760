import chisel3._
import chisel3.util._
import Consts._

class EX_TO_ISU_BUS extends Bundle {
  val is_csr = Output(Bool())
  val csr_res = Output(UInt(64.W))

  val alu_res = Output(UInt(64.W))

  val src1 = Output(UInt(64.W))
  val src2 = Output(UInt(64.W))
  val imm = Output(UInt(64.W))

  val lsuop = Output(UInt(8.W))
  val rv64op = Output(UInt(12.W))
  val dest = Output(UInt(5.W))
  val rf_w = Output(Bool())
  val load = Output(Bool())
  val save = Output(Bool())
}

class Execution extends Module {
  val io = IO(new Bundle {

    val id_to_ex = Flipped(new ID_TO_EX_BUS)
    val ex_to_isu = new EX_TO_ISU_BUS

  })
  val aluop = io.id_to_ex.aluop
  val rv64op = io.id_to_ex.rv64op
  val src1_64 = io.id_to_ex.out1
  val src2_64 = io.id_to_ex.out2
  val imm = io.id_to_ex.imm

  io.ex_to_isu.lsuop := io.id_to_ex.lsuop
  io.ex_to_isu.rv64op := io.id_to_ex.rv64op
  io.ex_to_isu.dest := io.id_to_ex.dest
  io.ex_to_isu.rf_w := io.id_to_ex.rf_w
  io.ex_to_isu.load := io.id_to_ex.load
  io.ex_to_isu.save := io.id_to_ex.save

  io.ex_to_isu.is_csr := io.id_to_ex.is_csr
  io.ex_to_isu.csr_res := io.id_to_ex.csr_res
  
  io.ex_to_isu.src1 := src1_64
  io.ex_to_isu.src2 := src2_64
  io.ex_to_isu.imm := imm

  val is_w = Mux1H(
    Seq(
      (rv64op === 0.U) -> N,
      rv64op(0) -> Y,
      rv64op(1) -> Y,
      rv64op(2) -> Y,
      rv64op(3) -> Y,
      rv64op(4) -> Y,
      rv64op(5) -> Y,
      rv64op(6) -> Y,
      rv64op(7) -> Y,
      rv64op(8) -> Y,
      rv64op(9) -> N,
      rv64op(10) -> N,
      rv64op(11) -> N
    )
  )

  val src1_32 = src1_64(31, 0)
  val src2_32 = src2_64(31, 0)

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

  val add_res_64 = src1_64 + src2_64
  
  val slt_res_64 =
    (Mux(src1_64.asSInt() < src2_64.asSInt(), 1.U(64.W), 0.U(64.W))).asUInt()

  val sltu_res_64 = Mux(src1_64.asUInt() < src2_64.asUInt(), 1.U(64.W), 0.U(64.W))

  val and_res_64 = src1_64 & src2_64

  val or_res_64 = src1_64 | src2_64

  val xor_res_64 = src1_64 ^ src2_64

  val lui_res_64 = src2_64

  val sub_res_64 = src1_64 - src2_64


  val sll_res_64 = src1_64.asUInt() << src2_64(5, 0)
  val sll_res_32 = src1_32.asUInt() << src2_32(4, 0)
 

  val srl_res_64 = src1_64.asUInt() >> src2_64(5, 0)
  val srl_res_32 = src1_32.asUInt() >> src2_32(4, 0)


  val sra_res_64 = (src1_64.asSInt() >> src2_64(5, 0)).asUInt()
  val sra_res_32 = (src1_32.asSInt() >> src2_32(4, 0)).asUInt()
  
  
  val alu_res_64 = Mux1H(
    Seq(
      (aluop === 0.U) -> 0.U,
      i_add -> add_res_64,
      i_slt -> slt_res_64,
      i_sltu -> sltu_res_64,
      i_and -> and_res_64,
      i_or -> or_res_64,
      i_xor -> xor_res_64,
      i_sll -> sll_res_64,
      i_srl -> srl_res_64,
      i_sra -> sra_res_64,
      i_lui -> lui_res_64,
      i_sub -> sub_res_64
    )
  )

  val add_res_32 = src1_32 + src2_32

  val slt_res_32 =
    (Mux(src1_32.asSInt() < src2_32.asSInt(), 1.U(32.W), 0.U(32.W))).asUInt()

  val sltu_res_32 = Mux(src1_32.asUInt() < src2_32.asUInt(), 1.U(32.W), 0.U(32.W))

  val and_res_32 = src1_32 & src2_32

  val or_res_32 = src1_32 | src2_32

  val xor_res_32 = src1_32 ^ src2_32

  val lui_res_32 = src2_32

  val sub_res_32 = src1_32 - src2_32

  val alu_res_32 = Mux1H(
    Seq(
      (aluop === 0.U) -> 0.U,
      i_add -> add_res_32,
      i_slt -> slt_res_32,
      i_sltu -> sltu_res_32,
      i_and -> and_res_32,
      i_or -> or_res_32,
      i_xor -> xor_res_32,
      i_sll -> sll_res_32,
      i_srl -> srl_res_32,
      i_sra -> sra_res_32,
      i_lui -> lui_res_32,
      i_sub -> sub_res_32
    )
  )

  val alu_res =
    Mux(is_w, Cat(Fill(32, alu_res_32(31)), alu_res_32(31,0)), alu_res_64)

  io.ex_to_isu.alu_res := alu_res

}


