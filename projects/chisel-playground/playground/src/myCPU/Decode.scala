import chisel3._
import chisel3.util._
import Instructions._
import Consts._

class Decode extends Module {
  val io = IO(new Bundle {
    val es_allowin = Input(Bool())
    val ds_valid = Input(Bool())
    val ds_allowin = Output(Bool())
    val ds_to_es_valid = Output(Bool())

    val if_to_id=Flipped(new IF_TO_ID_BUS)
    val id_to_ex=new ID_TO_EX_BUS
    val id_to_if= new ID_TO_IF_BUS

    val csr_to_id = Flipped(new CSR_TO_ID_BUS)

    val rs1_addr = Output(UInt(5.W))
    val rs1_data = Input(UInt(64.W))
    val rs2_addr = Output(UInt(5.W))
    val rs2_data = Input(UInt(64.W))

    val fwd_ex = Flipped(new EX_TO_ID_BUS)
    val fwd_lsu = Flipped(new LSU_TO_ID_BUS)
    val fwd_wb = Flipped(new WB_TO_ID_BUS)

    val intr_flush = Output(Bool()) //向后传递的流水线冲刷信号

    val ds_stall = Input(Bool())

    val csr_stall = Output(Bool())

  })

  //------------流水线控制逻辑------------------------------//
  val ds_valid = io.ds_valid
  val ds_ready_go = Wire(Bool())
  val ds_allowin = Wire(Bool())
  val ds_to_es_valid = Wire(Bool())

  ds_allowin := !ds_valid || (ds_ready_go && io.es_allowin)
  ds_to_es_valid := ds_valid && ds_ready_go

  io.ds_allowin := ds_allowin
  io.ds_to_es_valid := ds_to_es_valid

  //-------------------------------------------------------//

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
    List(N,OUT1_X,OUT2_X,IMM_X,OPTYPE_X,ALU_X,BRU_X,LSU_X,RV64_X,  CSR_X   ),Array(
      /*inst_valid    | id_out1   | id_out2 | id_imm |   optype     |  aluop   |  bruop    |  lsuop    |  rv64op     | csrop    |  */
      //-------------------RV32I_ALUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_X   ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),  */
      ADDI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SLLI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SLTI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SLT ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SLTIU   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SLTU,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      XORI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_XOR ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SRLI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      ORI     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_OR  ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      ANDI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_AND ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SRAI    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),

      ADD     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SLL     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SLT     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SLT ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SLTU    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SLTU ,  BRU_X   ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      XOR     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_XOR ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SRL     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      OR      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_OR  ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      AND     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_AND ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SUB     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SUB ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      SRA     -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_ALU ,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),

      AUIPC   -> List(Y, OUT1_PC  , OUT2_IMM, IMM_U  ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      LUI     -> List(Y, OUT1_X   , OUT2_IMM, IMM_U  ,  OPTYPE_ALU ,  ALU_LUI ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),

      //-------------------RV32I_BRUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_PC  , OUT2_IMM, IMM_4  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_JAL  ,  LSU_X    ,  RV64_X     ,  CSR_X   ),  */
      JAL     -> List(Y, OUT1_PC  , OUT2_IMM, IMM_4  ,   OPTYPE_BRU ,  ALU_ADD ,  BRU_JAL  ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      JALR    -> List(Y, OUT1_PC  , OUT2_IMM, IMM_4  ,   OPTYPE_BRU ,  ALU_ADD ,  BRU_JALR ,  LSU_X    ,  RV64_X     ,  CSR_X   ),

      BNE     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BNE  ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      BEQ     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BEQ  ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      BLT     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BLT  ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      BGE     -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BGE  ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      BLTU    -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BLTU ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      BGEU    -> List(Y, OUT1_X   , OUT2_X  , IMM_X  ,   OPTYPE_BRU ,  ALU_X   ,  BRU_BGEU ,  LSU_X    ,  RV64_X     ,  CSR_X   ),

      //-------------------RV32I_LSUInstr------------------------------//
      /*e.x.: -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LB   ,  RV64_X     ,  CSR_X   ),  */
      LB      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LB   ,  RV64_X     ,  CSR_X   ),
      LH      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LH   ,  RV64_X     ,  CSR_X   ),
      LW      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LW   ,  RV64_X     ,  CSR_X   ),
      LBU     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LBU  ,  RV64_X     ,  CSR_X   ),
      LHU     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_LHU  ,  RV64_X     ,  CSR_X   ),
      SB      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_S  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_SB   ,  RV64_X     ,  CSR_X   ),
      SH      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_S  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_SH   ,  RV64_X     ,  CSR_X   ),
      SW      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_S  ,  OPTYPE_LSU ,  ALU_ADD ,  BRU_X    ,  LSU_SW   ,  RV64_X     ,  CSR_X   ),
      //-------------------RV64IInstr----------------------------------//
      /*e.x.: -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_X   ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),  */
      ADDIW   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_ADDIW ,  CSR_X   ),
      SLLIW   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_SLLIW ,  CSR_X   ),
      SRLIW   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_SRLIW ,  CSR_X   ),
      SRAIW   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_SRAIW ,  CSR_X   ),
      SLLW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_SLL ,  BRU_X    ,  LSU_X    ,  RV64_SLLW  ,  CSR_X   ),
      SRLW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_SRL ,  BRU_X    ,  LSU_X    ,  RV64_SRLW  ,  CSR_X   ),
      SRAW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_SRA ,  BRU_X    ,  LSU_X    ,  RV64_SRAW  ,  CSR_X   ),
      ADDW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_ADDW  ,  CSR_X   ),
      SUBW    -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_X  ,  OPTYPE_RV64,  ALU_SUB ,  BRU_X    ,  LSU_X    ,  RV64_SUBW  ,  CSR_X   ),

      LWU     -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_LWU   ,  CSR_X   ),
      LD      -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_LD    ,  CSR_X   ),
      SD      -> List(Y, OUT1_RS1 , OUT2_RS2, IMM_S  ,  OPTYPE_RV64,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_SD    ,  CSR_X   ),

      //------------------CSR Instr-----------------------------//
      /*e.x.: -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_CSR ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_RW    ),  */
      CSRRW   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_CSR ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_RW    ),
      CSRRS   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_CSR ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_RS    ),
      CSRRC   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_CSR ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_RC    ),
      CSRRWI  -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_CSR ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_RWI   ),
      CSRRSI  -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_CSR ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_RSI   ),
      CSRRCI  -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_CSR ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_RCI   ),

      ECALL   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_CSR ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_ECALL ),
      MRET    -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_CSR ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_MRET  ),
      //---------------------其他指令-----------------------------//
      PUTCH   -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   ),
      FENCE_I -> List(Y, OUT1_RS1 , OUT2_IMM, IMM_I  ,  OPTYPE_ALU ,  ALU_ADD ,  BRU_X    ,  LSU_X    ,  RV64_X     ,  CSR_X   )
    ))
    val (inst_valid: Bool) :: id_out1 :: id_out2 :: id_imm :: optype :: aluop :: bruop :: lsuop :: rv64op :: csrop :: Nil = ctr_signals

    val inst_like_nop = Wire(Bool())
    inst_like_nop := (inst === PUTCH) || (inst === FENCE_I)

    val rs1_addr = Mux(inst_like_nop, "d10".U ,rs1)
    io.rs1_addr := rs1_addr
    val rs2_addr = rs2
    io.rs2_addr := rs2_addr

    val rs1_en = true.B
    val rs2_en = true.B

    val csr_jump = io.csr_to_id.csr_jump
    val csr_target = io.csr_to_id.csr_target
    io.csr_stall := io.ds_stall && csr_jump

    val imm = Mux1H(Seq(
      (id_imm === 0.U) -> 0.U,

      id_imm(0) -> imm_i,
      id_imm(1) -> imm_s,
      id_imm(2) -> imm_b,
      id_imm(3) -> imm_u,
      id_imm(4) -> imm_j,
      id_imm(5) -> imm_4
    ))

    val eq1_e = (io.fwd_ex.dst  === rs1_addr && (io.fwd_ex.dst =/= 0.U) && io.fwd_ex.rf_w)
    val eq1_l = (io.fwd_lsu.dst === rs1_addr && (io.fwd_lsu.dst =/= 0.U) && io.fwd_lsu.rf_w)
    val eq1_w = (io.fwd_wb.dst  === rs1_addr && (io.fwd_wb.dst =/= 0.U) && io.fwd_wb.rf_w)

    val eq2_e = (io.fwd_ex.dst  === rs2_addr && (io.fwd_ex.dst =/= 0.U) && io.fwd_ex.rf_w)
    val eq2_l = (io.fwd_lsu.dst === rs2_addr && (io.fwd_lsu.dst =/= 0.U) && io.fwd_lsu.rf_w)
    val eq2_w = (io.fwd_wb.dst  === rs2_addr && (io.fwd_wb.dst =/= 0.U) && io.fwd_wb.rf_w)

    val e_load = (io.fwd_ex.load && (eq1_e || eq2_e))

    ds_ready_go := ((!((io.fwd_ex.is_csr && (eq1_e || eq2_e)) || (io.fwd_lsu.is_csr && (eq1_l || eq2_l)) || e_load)) || csr_jump) && ~(io.ds_stall || (io.fwd_lsu.ds_stall && (eq1_l || eq2_l)))

    val rs1_data = Mux1H(
      Seq(
        (!rs1_en && (!eq1_e && !eq1_l && !eq1_w)) -> 0.U(64.W),
         eq1_e  -> io.fwd_ex.alu_res,
        (eq1_l && !eq1_e) -> io.fwd_lsu.lsu_res,
        (eq1_w && !eq1_l && !eq1_e) -> io.fwd_wb.wb_res,
        (rs1_en && (!eq1_e && !eq1_l && !eq1_w)) -> io.rs1_data
      )
    )

    val rs2_data = Mux1H(
      Seq(
        (!rs2_en && (!eq2_e && !eq2_l && !eq2_w)) -> 0.U(64.W),
        eq2_e   -> io.fwd_ex.alu_res,
        (eq2_l && !eq2_e) -> io.fwd_lsu.lsu_res,
        (eq2_w && !eq2_l && !eq2_e) -> io.fwd_wb.wb_res,
        (rs2_en && (!eq2_e && !eq2_l && !eq2_w)) -> io.rs2_data
      )
    )
    
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
    io.id_to_ex.dest := Mux(inst_like_nop,0.U,rd)

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

    val jump = csr_jump || (((is_jal || is_jalr) || (
        (bne &&  (rs1_data =/= rs2_data)) ||
        (beq &&  (rs1_data === rs2_data)) ||
        (blt &&  (rs1_data.asSInt() < rs2_data.asSInt())) ||
        (bltu && (rs1_data.asUInt() < rs2_data.asUInt())) ||
        (bge &&  (rs1_data.asSInt() >= rs2_data.asSInt())) ||
        (bgeu && (rs1_data.asUInt() >= rs2_data.asUInt()))
    )) && ds_valid)
    val pc_target = Mux(csr_jump,csr_target,
      Mux1H(Seq(
      is_jal -> jal_target,
      is_jalr -> jalr_target,
      is_br -> br_target,
      (is_br && !jump) -> "h3000_0000".U(64.W) 
    )))

    io.id_to_ex.imm := imm
    io.id_to_ex.rf_w := !save && !is_br && !csr_jump
    io.id_to_ex.load := load && !csr_jump
    io.id_to_ex.save := save && !csr_jump
    
    io.id_to_if.jump := jump
    io.id_to_if.pc_target := pc_target
    
    io.id_to_ex.aluop := aluop
    io.id_to_ex.lsuop := lsuop
    io.id_to_ex.rv64op := rv64op

    //-----------------csr op----------------------//
    val is_csr = (optype === OPTYPE_CSR)
    val is_zimm = Mux1H(Seq(
      !is_csr -> false.B,
      (csrop === CSR_RW)  -> false.B,
      (csrop === CSR_RS)  -> false.B,
      (csrop === CSR_RC)  -> false.B,
      (csrop === CSR_RWI) -> true.B,
      (csrop === CSR_RSI) -> true.B,
      (csrop === CSR_RCI) -> true.B
    ))
    
    io.id_to_ex.is_csr := is_csr
    io.id_to_ex.csrop := csrop
    io.id_to_ex.csr_src := Mux(is_zimm,Cat(Fill(59,0.U),rs1(4,0)),rs1_data)
    io.id_to_ex.csr_addr := Mux(is_csr && ds_valid,inst(31,20),0.U)
    io.id_to_ex.is_zero := ((rs1 === 0.U) || !is_csr)

    io.id_to_ex.pc := pc
    io.id_to_ex.inst := Mux(io.intr_flush || !ds_to_es_valid,NOP,inst)

    io.intr_flush := csr_jump

    io.id_to_ex.is_nop := Mux(io.intr_flush || !ds_to_es_valid ,true.B,io.if_to_id.is_nop)
}
