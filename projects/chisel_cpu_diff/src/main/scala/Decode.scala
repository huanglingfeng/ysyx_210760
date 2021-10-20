import chisel3._
import chisel3.util._
import Instructions._
import Consts._

class ID_TO_IF_BUS extends Bundle{
  val pc_target=Output(UInt(64.W))
  val jump = Output(Bool())
}
class ID_TO_EX_BUS extends Bundle{
  val aluop = Output(UInt(11.W))
  val lsuop = Output(UInt(8.W))
  val rv64op = Output(UInt(12.W))
  
  val out1  = Output(UInt(64.W))
  val out2  = Output(UInt(64.W))

  val imm = Output(UInt(64.W))
  
  val dest  = Output(UInt(5.W))
  val rf_w  = Output(Bool())
  val load = Output(Bool())
  val save = Output(Bool())

}
class Decode extends Module {
  val io = IO(new Bundle {
    val if_to_id=Flipped(new IF_TO_ID_BUS)
    val id_to_ex=new ID_TO_EX_BUS
    val id_to_if= new ID_TO_IF_BUS

    val rs1_addr = Output(UInt(5.W))
    val rs1_data = Input(UInt(64.W))
    val rs2_addr = Output(UInt(5.W))
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
  val imm_s = Cat(Fill(53,inst(31)),inst(30,25),inst(11,7))
  val imm_b = Cat(Fill(52,inst(31)),inst(7),inst(30,25),inst(11,8),0.U)
  val imm_u = Cat(Fill(33,inst(31)),inst(30,12),0.U(12.W))
  val imm_j = Cat(Fill(44,inst(31)),inst(19,12),inst(20),inst(30,25),inst(24,21),0.U)
  val imm_4 = 4.U(64.W)

  val ctr_signals = ListLookup(inst,
    List(N,OUT1_X,OUT2_X,IMM_X,OPTYPE_X,ALU_X,BRU_X,LSU_X,RV64_X),Array(
      /*inst_valid    | id_out1   | id_out2 | id_imm |   optype     |  aluop   |  bruop    |  lsuop    |  rv64op     |   */
      //-------------------RV32I_ALUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_X   ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ),  */
      ADDI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLLI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLTI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SLT ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLTIU   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SLTU ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      XORI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_XOR ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SRLI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      ORI     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_OR  ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      ANDI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_AND ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SRAI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_X     ),

      ADD     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLL     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLT     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SLT ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SLTU    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SLTU ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      XOR     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_XOR ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SRL     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      OR      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_OR  ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      AND     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_AND ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SUB     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SUB ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      SRA     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_X     ),

      AUIPC   -> List(Y, OUT1_PC  , OUT2_IMM, IMM_U  ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ),
      LUI     -> List(Y, OUT1_X   , OUT2_IMM, IMM_U  ,  OPTYPE_ALU ,  ALU_LUI ,  BRU_X    ,  LSU_X    ,  RV64_X     ),

      //-------------------RV32I_BRUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_PC  , OUT2_IMM, IMM_4  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_JAL  ,  LSU_X    ,  RV64_X     ),  */
      JAL     -> List(Y, OUT1_PC  , OUT2_IMM, IMM_4  ,   OPTYPE_BRU ,  ALU_ADD ,  BRU_JAL  ,  LSU_X    ,  RV64_X     ),
      JALR    -> List(Y, OUT1_PC  , OUT2_IMM, IMM_4  ,   OPTYPE_BRU ,  ALU_ADD ,  BRU_JALR ,  LSU_X    ,  RV64_X     ),

      BNE     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BNE  ,  LSU_X    ,  RV64_X     ),
      BEQ     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BEQ  ,  LSU_X    ,  RV64_X     ),
      BLT     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BLT  ,  LSU_X    ,  RV64_X     ),
      BGE     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BGE  ,  LSU_X    ,  RV64_X     ),
      BLTU    -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BLTU ,  LSU_X    ,  RV64_X     ),
      BGEU    -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BGEU ,  LSU_X    ,  RV64_X     ),

      //-------------------RV32I_LSUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LB   ,  RV64_X     ),  */
      LB      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LB   ,  RV64_X     ),
      LH      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LH   ,  RV64_X     ),
      LW      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LW   ,  RV64_X     ),
      LBU     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LBU  ,  RV64_X     ),
      LHU     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LHU  ,  RV64_X     ),
      SB      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_S  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_SB   ,  RV64_X     ),
      SH      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_S  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_SH   ,  RV64_X     ),
      SW      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_S  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_SW   ,  RV64_X     ),
      //-------------------RV64IInstr----------------------------------//
      /*e.x.: -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_X   ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ),  */
      ADDIW   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_ADDIW ),
      SLLIW   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_SLLIW ),
      SRLIW   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_SRLIW ),
      SRAIW   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_SRAIW ),
      SLLW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_SLLW  ),
      SRLW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_SRLW  ),
      SRAW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_SRAW  ),
      ADDW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_ADDW  ),
      SUBW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_SUB ,  BRU_X    ,  LSU_X    ,  RV64_SUBW  ),

      LWU     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_LWU   ),
      LD      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_LD    ),
      SD      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_S  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_SD    ),

      //---------------------自定义-----------------------------//
      PUTCH   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     )

    ))
    val (inst_valid: Bool) :: id_out1 :: id_out2 :: id_imm :: optype :: aluop :: bruop :: lsuop :: rv64op :: Nil = ctr_signals

    val is_putch = (inst === PUTCH)
    
    if(is_putch == true.B)
      printf(p"$rs1_data")

    io.rs1_addr := Mux(is_putch,"d10".U,rs1)
    io.rs2_addr := rs2
    val rs1_en = true.B
    val rs2_en = true.B

    val imm = Mux1H(Seq(
      (id_imm === 0.U) -> 0.U,

      id_imm(0) -> imm_i,
      id_imm(1) -> imm_s,
      id_imm(2) -> imm_b,
      id_imm(3) -> imm_u,
      id_imm(4) -> imm_j,
      id_imm(5) -> imm_4
    ))

    

    val rs1_data = Mux(rs1_en,io.rs1_data,0.U)
    val rs2_data = Mux(rs2_en,io.rs2_data,0.U)
    
    io.id_to_ex.out1 := Mux1H(Seq(
      (id_out1 === 0.U) -> 0.U,

      id_out1(0) -> rs1_data,
      id_out1(1) -> io.if_to_id.pc
    ))
    io.id_to_ex.out2 := Mux1H(Seq(
      (id_out2 === 0.U) -> 0.U,

      id_out2(0) -> rs2_data,
      id_out2(1) ->imm
    ))
    io.id_to_ex.dest := Mux(is_putch,0.U,rd)

    val load = Mux1H(Seq(
      (lsuop === 0.U && rv64op === 0.U) -> N,
      lsuop(0) -> Y,
      lsuop(1) -> Y,
      lsuop(2) -> Y,
      lsuop(3) -> Y,
      lsuop(4) -> Y,
      lsuop(5) -> N,
      lsuop(6) -> N,
      lsuop(7) -> N,

      rv64op(9) -> Y,
      rv64op(10) -> Y,
      (rv64op =/= 0.U && !rv64op(10) && !(rv64op(11))) -> N
    ))
    val save = Mux1H(Seq(
      (lsuop === 0.U && rv64op === 0.U) -> N,
      lsuop(0) -> N,
      lsuop(1) -> N,
      lsuop(2) -> N,
      lsuop(3) -> N,
      lsuop(4) -> N,
      lsuop(5) -> Y,
      lsuop(6) -> Y,
      lsuop(7) -> Y,

      rv64op(11) -> Y,
      (rv64op =/= 0.U && !rv64op(11)) -> N

    ))
  //------------------------跳转部分----------------------------//

    val is_br = Mux1H(Seq(
      (bruop === 0.U) -> N,
      bruop(0) -> N,
      bruop(1) -> N,
      bruop(2) -> Y,
      bruop(3) -> Y,
      bruop(4) -> Y,
      bruop(5) -> Y,
      bruop(6) -> Y,
      bruop(7) -> Y
    ))
    val is_jal = bruop(0)
    val is_jalr = bruop(1)

    val jal_target = pc + imm_j
    val jalr_target = rs1_data + imm_i
    val br_target = pc + imm_b

    val bne = bruop(2)
    val beq = bruop(3)
    val blt = bruop(4)
    val bge = bruop(5)
    val bltu = bruop(6)
    val bgeu = bruop(7)

    val jump = (is_jal || is_jalr) || (
        (bne &&  (rs1_data =/= rs2_data)) ||
        (beq &&  (rs1_data === rs2_data)) ||
        (blt &&  (rs1_data.asSInt() < rs2_data.asSInt())) ||
        (bltu && (rs1_data.asUInt() < rs2_data.asUInt())) ||
        (bge &&  (rs1_data.asSInt() >= rs2_data.asSInt())) ||
        (bgeu && (rs1_data.asUInt() >= rs2_data.asUInt()))
    )
    val pc_target = Mux1H(Seq(
      is_jal -> jal_target,
      is_jalr -> jalr_target,
      is_br -> br_target,
      (is_br && !jump) -> "h8000_0000".U(64.W) 
    ))

    io.id_to_ex.imm := imm
    io.id_to_ex.rf_w := !save && !is_br
    io.id_to_ex.load := load
    io.id_to_ex.save := save
    
    
    io.id_to_if.jump := jump
    io.id_to_if.pc_target := pc_target
    
    io.id_to_ex.aluop := aluop
    io.id_to_ex.lsuop := lsuop
    io.id_to_ex.rv64op := rv64op


}
