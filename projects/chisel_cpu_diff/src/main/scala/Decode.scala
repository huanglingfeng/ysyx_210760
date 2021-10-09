import chisel3._
import chisel3.util._
import Instructions._
import Consts._

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

  val inst   = io.if_to_id.inst
  val rd     = inst(11,7)
  val funct3 = inst(14,12)
  val rs1    = inst(19,15)
  val rs2    = inst(24,20)
  val funct7 = inst(31,25)

  val opcode = WireInit(UInt(8.W), 0.U)
  val imm_i = Cat(Fill(53, inst(31)), inst(30, 20))
  val imm_s = Cat(Fill(53,inst(31))inst(30,25),inst(11,7))
  val imm_b = Cat(Fill(52,inst(31)),inst(7),inst(30,25),inst(11,8),0.U)
  val imm_u = Cat(Fill(33,inst(31)),inst(30,12),0.U(12.W))
  val imm_j = Cat(Fill(44,inst(31)),inst(19,12),inst(20),inst(30,25),inst(24,21),0.U)

  val signals = ListLookup(inst,
    List(N,OUT1_X,OUT2_X,IMM_X,NEXTPC_ADD4,ALU_OPCODE_X,ISU_OUT_X),Array(
      /*inst_valid    | id_out1   | id_out2 | id_imm | if_nextpc  | ex_alu_opcode | isu_out  */
      //-------------------RV32I_ALUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_X   , OUT2_X  , IMM_X  , NEXTPC_ADD4 ,  ALU_X        , ISU_OUT_X),    */
      ADDI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  ALU_ADD      , ISU_OUT_ALU),
      SLLI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  ALU_SLL      , ISU_OUT_ALU),
      SLTI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  ALU_SLT      , ISU_OUT_ALU),
      SLTIU   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_X  , NEXTPC_ADD4 ,  ALU_SLTU     , ISU_OUT_ALU),
      XORI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  ALU_XOR      , ISU_OUT_ALU),
      SRLI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  ALU_SRL      , ISU_OUT_ALU),
      ORI     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  ALU_OR       , ISU_OUT_ALU),
      ANDI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  ALU_AND      , ISU_OUT_ALU),
      SRAI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  ALU_SRA      , ISU_OUT_ALU),

      ADD     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  ALU_ADD      , ISU_OUT_ALU),
      SLL     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  ALU_SLL      , ISU_OUT_ALU),
      SLTU    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  ALU_SLTU     , ISU_OUT_ALU),
      XOR     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  ALU_XOR      , ISU_OUT_ALU),
      SRL     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  ALU_SRL      , ISU_OUT_ALU),
      OR      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  ALU_OR       , ISU_OUT_ALU),
      AND     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  ALU_AND      , ISU_OUT_ALU),
      SUB     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  ALU_X        , ISU_OUT_ALU),
      SRA     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  ALU_X        , ISU_OUT_ALU),

      AUIPC   -> List(Y, OUT1_X   , OUT2_X  , IMM_X  , NEXTPC_ADD4 ,  ALU_X        , ISU_OUT_ALU),
      LUI     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  , NEXTPC_ADD4 ,  ALU_X        , ISU_OUT_ALU),


    ))

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
