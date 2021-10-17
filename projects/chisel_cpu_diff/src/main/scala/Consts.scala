import chisel3._
import chisel3.util._

object Consts {
  val Y = true.B
  val N = false.B

  val SEL_ID_OUT1_WIDTH = 2
  val OUT1_X = "b00".U(SEL_ID_OUT1_WIDTH.W)
  val OUT1_RS1 = "b01".U(SEL_ID_OUT1_WIDTH.W)
  val OUT1_PC = "b10".U(SEL_ID_OUT1_WIDTH.W)

  val SEL_ID_OUT2_WIDTH = 2
  val OUT2_X = "b00".U(SEL_ID_OUT2_WIDTH.W)
  val OUT2_RS2 = "b01".U(SEL_ID_OUT2_WIDTH.W)
  val OUT2_IMM = "b10".U(SEL_ID_OUT2_WIDTH.W)

  val SEL_ID_IMM_WIDTH = 6
  val IMM_X = "b000000".U(SEL_ID_IMM_WIDTH.W)
  val IMM_I = "b000001".U(SEL_ID_IMM_WIDTH.W)
  val IMM_S = "b000010".U(SEL_ID_IMM_WIDTH.W)
  val IMM_B = "b000100".U(SEL_ID_IMM_WIDTH.W)
  val IMM_U = "b001000".U(SEL_ID_IMM_WIDTH.W)
  val IMM_J = "b010000".U(SEL_ID_IMM_WIDTH.W)
  val IMM_4 = "b100000".U(SEL_ID_IMM_WIDTH.W)

  val SEL_OPTYPE_WIDTH = 4
  val OPTYPE_X = "b0000".U(SEL_OPTYPE_WIDTH.W)
  val OPTYPE_ALU = "b0001".U(SEL_OPTYPE_WIDTH.W)
  val OPTYPE_BRU = "b0010".U(SEL_OPTYPE_WIDTH.W)
  val OPTYPE_LSU = "b0100".U(SEL_OPTYPE_WIDTH.W)
  val OPTYPE_RV64 = "b1000".U(SEL_OPTYPE_WIDTH.W)

  val SEL_ALU_OP_WIDTH = 11
  val ALU_X = "b00000000000".U(SEL_ALU_OP_WIDTH.W)
  val ALU_ADD = "b00000000001".U(SEL_ALU_OP_WIDTH.W)
  val ALU_SLT = "b00000000010".U(SEL_ALU_OP_WIDTH.W)
  val ALU_SLTU = "b00000000100".U(SEL_ALU_OP_WIDTH.W)
  val ALU_AND = "b00000001000".U(SEL_ALU_OP_WIDTH.W)
  val ALU_OR = "b00000010000".U(SEL_ALU_OP_WIDTH.W)
  val ALU_XOR = "b00000100000".U(SEL_ALU_OP_WIDTH.W)
  val ALU_SLL = "b00001000000".U(SEL_ALU_OP_WIDTH.W)
  val ALU_SRL = "b00010000000".U(SEL_ALU_OP_WIDTH.W)
  val ALU_SRA = "b00100000000".U(SEL_ALU_OP_WIDTH.W)
  val ALU_LUI = "b01000000000".U(SEL_ALU_OP_WIDTH.W)
  val ALU_SUB = "b10000000000".U(SEL_ALU_OP_WIDTH.W)

  val SEL_BRU_OP_WIDTH = 8
  val BRU_X = "b00000000".U(SEL_BRU_OP_WIDTH.W)
  val BRU_JAL = "b00000001".U(SEL_BRU_OP_WIDTH.W)
  val BRU_JALR = "b00000010".U(SEL_BRU_OP_WIDTH.W)
  val BRU_BNE = "b00000100".U(SEL_BRU_OP_WIDTH.W)
  val BRU_BEQ = "b00001000".U(SEL_BRU_OP_WIDTH.W)
  val BRU_BLT = "b00010000".U(SEL_BRU_OP_WIDTH.W)
  val BRU_BGE = "b00100000".U(SEL_BRU_OP_WIDTH.W)
  val BRU_BLTU = "b01000000".U(SEL_BRU_OP_WIDTH.W)
  val BRU_BGEU = "b10000000".U(SEL_BRU_OP_WIDTH.W)

  val SEL_LSU_OP_WIDTH = 8
  val LSU_X = "b00000000".U(SEL_LSU_OP_WIDTH.W)
  val LSU_LB = "b00000001".U(SEL_LSU_OP_WIDTH.W)
  val LSU_LH = "b00000010".U(SEL_LSU_OP_WIDTH.W)
  val LSU_LW = "b00000100".U(SEL_LSU_OP_WIDTH.W)
  val LSU_LBU = "b00001000".U(SEL_LSU_OP_WIDTH.W)
  val LSU_LHU = "b00010000".U(SEL_LSU_OP_WIDTH.W)
  val LSU_SB = "b00100000".U(SEL_LSU_OP_WIDTH.W)
  val LSU_SH = "b01000000".U(SEL_LSU_OP_WIDTH.W)
  val LSU_SW = "b10000000".U(SEL_LSU_OP_WIDTH.W)

  val SEL_RV64_OP_WIDTH = 12
  val RV64_X = "b000000000000".U(SEL_RV64_OP_WIDTH.W)
  val RV64_ADDIW = "b000000000001".U(SEL_RV64_OP_WIDTH.W)
  val RV64_SLLIW = "b000000000010".U(SEL_RV64_OP_WIDTH.W)
  val RV64_SRLIW = "b000000000100".U(SEL_RV64_OP_WIDTH.W)
  val RV64_SRAIW = "b000000001000".U(SEL_RV64_OP_WIDTH.W)
  val RV64_SLLW = "b000000010000".U(SEL_RV64_OP_WIDTH.W)
  val RV64_SRLW = "b000000100000".U(SEL_RV64_OP_WIDTH.W)
  val RV64_SRAW = "b000001000000".U(SEL_RV64_OP_WIDTH.W)
  val RV64_ADDW = "b000010000000".U(SEL_RV64_OP_WIDTH.W)
  val RV64_SUBW = "b000100000000".U(SEL_RV64_OP_WIDTH.W)
  val RV64_LWU = "b001000000000".U(SEL_RV64_OP_WIDTH.W)
  val RV64_LD = "b010000000000".U(SEL_RV64_OP_WIDTH.W)
  val RV64_SD = "b100000000000".U(SEL_RV64_OP_WIDTH.W)
}
