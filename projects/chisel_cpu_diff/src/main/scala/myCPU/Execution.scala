import chisel3._
import chisel3.util._
import Consts._

class Execution extends Module {
  val io = IO(new Bundle {
    val ls_allowin = Input(Bool())
    val es_valid = Input(Bool())
    val es_allowin = Output(Bool())
    val es_to_ls_valid = Output(Bool())

    val id_to_ex = Flipped(new ID_TO_EX_BUS)
    val ex_to_lsu = new EX_TO_LSU_BUS
    
    val ex_fwd = new EX_TO_ID_BUS

    val flush = Input(Bool())

  })

  //------------流水线控制逻辑------------------------------//
  val es_valid = Mux(io.flush,true.B,io.es_valid)
  val es_ready_go = true.B
  val es_allowin = Wire(Bool())
  val es_to_ls_valid = Wire(Bool())

  es_allowin := !es_valid || (es_ready_go && io.ls_allowin)
  es_to_ls_valid := es_valid && es_ready_go

  io.es_allowin := es_allowin
  io.es_to_ls_valid := es_to_ls_valid
  
  //-------------------------------------------------------//
  val aluop = io.id_to_ex.aluop
  val rv64op = io.id_to_ex.rv64op
  val src1_64 = io.id_to_ex.out1
  val src2_64 = io.id_to_ex.out2
  val imm = io.id_to_ex.imm

  io.ex_to_lsu.lsuop := io.id_to_ex.lsuop
  io.ex_to_lsu.rv64op := io.id_to_ex.rv64op
  val dest = io.id_to_ex.dest
  io.ex_to_lsu.dest := dest
  val rf_w = io.id_to_ex.rf_w
  io.ex_to_lsu.rf_w := rf_w

  val load = io.id_to_ex.load
  io.ex_to_lsu.load := load
  io.ex_to_lsu.save := io.id_to_ex.save

  val is_csr = io.id_to_ex.is_csr
  io.ex_to_lsu.is_csr := is_csr
  
  io.ex_to_lsu.src1 := src1_64
  io.ex_to_lsu.src2 := src2_64
  io.ex_to_lsu.imm := imm

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

  io.ex_to_lsu.alu_res := alu_res

  io.ex_fwd.rf_w := Mux(!es_valid,false.B,rf_w)
  io.ex_fwd.dst := dest
  io.ex_fwd.alu_res := alu_res
  io.ex_fwd.is_csr := Mux(!es_valid,false.B,is_csr)
  io.ex_fwd.load := Mux(!es_valid,false.B,load)

  val pc = io.id_to_ex.pc
  val inst = io.id_to_ex.inst
  io.ex_to_lsu.pc := pc
  io.ex_to_lsu.inst := Mux(io.flush || !es_to_ls_valid,NOP,inst)

  io.ex_to_lsu.is_csr := io.id_to_ex.is_csr
  io.ex_to_lsu.csrop := io.id_to_ex.csrop
  io.ex_to_lsu.csr_addr := io.id_to_ex.csr_addr
  io.ex_to_lsu.csr_src := io.id_to_ex.csr_src
  io.ex_to_lsu.is_zero := io.id_to_ex.is_zero

  io.ex_to_lsu.is_nop := Mux(io.flush || !es_to_ls_valid,true.B,io.id_to_ex.is_nop)
}


