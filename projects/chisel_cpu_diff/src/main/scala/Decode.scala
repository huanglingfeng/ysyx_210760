import chisel3._
import chisel3.util._
import Instructions._
import Consts._

class ID_TO_IF_BUS extends Bundle{
  val jump_pc=Output(UInt(64.W))
  val jump = Output(Bool)
}
class ID_TO_EX_BUS extends Bundle{
  val opcode = Output(UInt(11.W))
  val out1  = Output(UInt(64.W))
  val out2  = Output(UInt(64.W))
  val dest  = Output(UInt(5.W))
  val rf_w  = Output(Bool)
  val load = Output(Bool)
  val save = Output(Bool)

}
class Decode extends Module {
  val io = IO(new Bundle {
    val if_to_id=Flipped(new IF_TO_ID_BUS)
    val id_to_ex=new ID_TO_EX_BUS

    val rs1_addr = Output(UInt(5.W))
    val rs1_en = Output(Bool())
    val rs1_data = Input(UInt(64.W))

    val rs2_addr = Output(UInt(5.W))
    val rs2_en = Output(Bool())
    val rs2_data = Input(UInt(64.W))

  })

  val inst   = io.if_to_id.inst
  val pc     = io.if_to_id.pc

  val rd     = inst(11,7)
  val funct3 = inst(14,12)
  val rs1    = inst(19,15)
  val rs2    = inst(24,20)
  val funct7 = inst(31,25)

  
  val imm_i = Cat(Fill(53, inst(31)), inst(30, 20))
  val imm_s = Cat(Fill(53,inst(31))inst(30,25),inst(11,7))
  val imm_b = Cat(Fill(52,inst(31)),inst(7),inst(30,25),inst(11,8),0.U)
  val imm_u = Cat(Fill(33,inst(31)),inst(30,12),0.U(12.W))
  val imm_j = Cat(Fill(44,inst(31)),inst(19,12),inst(20),inst(30,25),inst(24,21),0.U)
  val imm_4 = 4.U(64.W)

  val ctr_signals = ListLookup(inst,
    List(N,OUT1_X,OUT2_X,IMM_X,NEXTPC_ADD4,OPTYPE,ALU_X,BRU_X,LSU_X,RV64_X),Array(
      /*inst_valid    | id_out1   | id_out2 | id_imm | if_nextpc  |   optype     |  aluop   |  bruop    |  lsuop    |  rv64op     |   */
      //-------------------RV32I_ALUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_X   ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ),  */
      ADDI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLLI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLTI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SLT ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLTIU   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SLT ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      XORI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_XOR ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SRLI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      ORI     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_OR  ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      ANDI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_AND ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SRAI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_X     ),

      ADD     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLL     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLTU    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SLT ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      XOR     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_XOR ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SRL     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      OR      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_OR  ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      AND     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_AND ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SUB     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SUB ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SRA     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_X     ),

      AUIPC   -> List(Y, OUT1_PC  , OUT2_IMM, IMM_U  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      LUI     -> List(Y, OUT1_X   , OUT2_IMM, IMM_U  , NEXTPC_ADD4 ,  OPTYPE_ALU ,  ALU_LUI ,  BRU_X    ,  LSU_X    ,  RV64_X     ),

      //-------------------RV32I_BRUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_PC  , OUT2_IMM, IMM_4  , NEXTPC_JUMP ,  OPTYPE_BRU ,  ALU_X   ,  BRU_JAL  ,  LSU_X    ,  RV64_X     ),  */
      JAL     -> List(Y, OUT1_PC  , OUT2_IMM, IMM_4  , NEXTPC_JUMP ,  OPTYPE_BRU ,  ALU_ADD ,  BRU_JAL  ,  LSU_X    ,  RV64_X     ),
      JALR    -> List(Y, OUT1_PC  , OUT2_IMM, IMM_4  , NEXTPC_JUMP ,  OPTYPE_BRU ,  ALU_ADD ,  BRU_JALR ,  LSU_X    ,  RV64_X     ),

      BNE     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  , NEXTPC_JUMP ,  OPTYPE_BRU ,  ALU_X   ,  BRU_BNE  ,  LSU_X    ,  RV64_X     ),
      BEQ     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  , NEXTPC_JUMP ,  OPTYPE_BRU ,  ALU_X   ,  BRU_BEQ  ,  LSU_X    ,  RV64_X     ),
      BLT     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  , NEXTPC_JUMP ,  OPTYPE_BRU ,  ALU_X   ,  BRU_BLT  ,  LSU_X    ,  RV64_X     ),
      BGE     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  , NEXTPC_JUMP ,  OPTYPE_BRU ,  ALU_X   ,  BRU_BGE  ,  LSU_X    ,  RV64_X     ),
      BLTU    -> List(Y, OUT1_X   , OUT2_X  , IMM_X  , NEXTPC_JUMP ,  OPTYPE_BRU ,  ALU_X   ,  BRU_BLTU ,  LSU_X    ,  RV64_X     ),
      BGEU    -> List(Y, OUT1_X   , OUT2_X  , IMM_X  , NEXTPC_JUMP ,  OPTYPE_BRU ,  ALU_X   ,  BRU_BGEU ,  LSU_X    ,  RV64_X     ),

      //-------------------RV32I_LSUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LB   ,  RV64_X     ),  */
      LB      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LB   ,  RV64_X     ),
      LH      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LH   ,  RV64_X     ),
      LW      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LW   ,  RV64_X     ),
      LBU     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LBU  ,  RV64_X     ),
      LHU     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  , NEXTPC_ADD4 ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LHU  ,  RV64_X     ),
      SB      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_SB   ,  RV64_X     ),
      SH      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_SH   ,  RV64_X     ),
      SW      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  , NEXTPC_ADD4 ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_SW   ,  RV64_X     )

    ))
    val (inst_valid: Bool) :: id_out1 :: id_out2 :: id_imm :: if_nextpc :: optype :: aluop :: bruop :: lsuop :: rv64op :: Nil = ctr_signals

    io.rs1_addr := rs1
    io.rs2_addr := rs2
    rs1_en := id_out1(0)
    rs2_en := id_out2(0)

    val imm = Mux1H(Seq(
      id_imm(0) -> imm_i,
      id_imm(1) -> imm_s,
      id_imm(2) -> imm_b,
      id_imm(3) -> imm_u,
      id_imm(4) -> imm_j
    ))

    
    io.id_to_ex_bus.out1 := Mux1H(Seq(
      id_out1(0) -> io.rs1_data,
      id_out1(1) -> io.if_to_id.pc
    ))
    io.id_to_ex_bus.out2 := Mux1H(Seq(
      id_out2(0) -> io.rs2_data,
      id_out2(1) ->imm
    ))
    io.id_to_ex_bus.dest := rd
    io.id_to_ex_bus.rf_w := !load

    io.id_to_if.jump := (if_nextpc === NEXTPC_JUMP)
    io.id_to_if.jump_pc := "h8000_0000".U(64.W)
    
    io.id_to_ex_bus.opcode := alu_opcode
  

  // // Only example here, use your own control flow!
  // when (inst === ADDI) {
  //   opcode := 1.U
  // }

  // io.rs1_addr := rs1
  // io.rs2_addr := rs2
  // io.rd_addr := rd
  
  // io.rs1_en := false.B
  // io.rs2_en := false.B
  // io.rd_en := false.B

  // when (inst === ADDI) {
  //   io.rs1_en := true.B
  //   io.rs2_en := false.B
  //   io.rd_en := true.B
  // }
  
  io.id_to_ex.opcode := opcode
  io.id_to_ex.imm := imm_i
}
