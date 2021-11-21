import chisel3._
import chisel3.util.experimental._
import difftest._
import Instructions._
import Consts._

class Core extends Module {
  val io = IO(new Bundle {
    val imem = new RomIO
    val dmem = new RamIO
  })

  val fetch = Module(new InstFetch)
  fetch.io.imem <> io.imem
  
  val dr = Module(new DR)
  val decode = Module(new Decode)

  // fetch.io.if_to_id <> decode.io.if_to_id
  decode.io.id_to_if <> fetch.io.id_to_if
  val er = Module(new ER)
  val ex = Module(new Execution)
  // decode.io.id_to_ex <> ex.io.id_to_ex
  val lr = Module(new LR)
  val lsu = Module(new LSU)
  // ex.io.ex_to_lsu <> lsu.io.ex_to_lsu
  lsu.io.dmem <> io.dmem

  val wr = Module(new WR)
  val wb = Module(new WB)
  // lsu.io.lsu_to_wb <> wb.io.lsu_to_wb

  val rf = Module(new RegFile)
  /*------------idu <> rf---------------------*/
  rf.io.rs1_addr := decode.io.rs1_addr
  rf.io.rs2_addr := decode.io.rs2_addr

  decode.io.rs1_data := rf.io.rs1_data
  decode.io.rs2_data := rf.io.rs2_data
  /*-----------wb <> rf-----------------------*/
  rf.io.rd_addr := wb.io.rd_addr
  rf.io.rd_data := wb.io.rd_data
  rf.io.rd_en := wb.io.rd_en

  val csr = Module(new CSR)
  csr.io.csr_to_id <> decode.io.csr_to_id 
  lsu.io.lsu_to_csr <> csr.io.csr_to_lsu
  wb.io.wb_to_csr <> csr.io.wb_to_csr

  /*-----------流水线总线连接---------------*/
  fetch.io.if_to_id <> dr.io.if_to_dr
  dr.io.dr_to_id <> decode.io.if_to_id

  decode.io.id_to_ex <> er.io.id_to_er
  er.io.er_to_ex <> ex.io.id_to_ex

  ex.io.ex_to_lsu <> lr.io.ex_to_lr
  lr.io.lr_to_lsu <> lsu.io.ex_to_lsu

  lsu.io.lsu_to_wb <> wr.io.lsu_to_wr
  wr.io.wr_to_wb <> wb.io.lsu_to_wb

  /*----------流水线控制逻辑-------------------*/
  fetch.io.ds_allowin := decode.io.ds_allowin
  dr.io.fs_to_ds_valid := fetch.io.fs_to_ds_valid
  dr.io.ds_allowin := decode.io.ds_allowin
  decode.io.ds_valid := dr.io.ds_valid

  decode.io.es_allowin := ex.io.es_allowin
  er.io.ds_to_es_valid := decode.io.ds_to_es_valid
  er.io.es_allowin := ex.io.es_allowin
  ex.io.es_valid := er.io.es_valid

  ex.io.ls_allowin := lsu.io.ls_allowin
  lr.io.es_to_ls_valid := ex.io.es_to_ls_valid
  lr.io.ls_allowin := lsu.io.ls_allowin
  lsu.io.ls_valid := lr.io.ls_valid

  lsu.io.ws_allowin := wb.io.ws_allowin
  wr.io.ls_to_ws_valid := lsu.io.ls_to_ws_valid
  wr.io.ws_allowin := wb.io.ws_allowin
  wb.io.ws_valid := wr.io.ws_valid


  decode.io.fwd_ex  <> ex.io.ex_fwd
  decode.io.fwd_lsu <> lsu.io.lsu_fwd
  decode.io.fwd_wb  <> wb.io.wb_fwd

  ex.io.flush := decode.io.intr_flush
  lsu.io.flush := decode.io.intr_flush
  /* ----- Difftest ------------------------------ */

  val dt_ic = Module(new DifftestInstrCommit)
  dt_ic.io.clock := clock
  dt_ic.io.coreid := 0.U
  dt_ic.io.index := 0.U
  dt_ic.io.valid := !RegNext(wb.io.is_nop)
  dt_ic.io.pc := RegNext(wb.io.pc)
  dt_ic.io.instr := RegNext(wb.io.inst)
  dt_ic.io.skip := RegNext(wb.io.inst === "h0000007b".U || RegNext(lsu.io.lsu_to_csr.is_clint) || wb.io.inst === ECALL
    || (wb.io.wb_to_csr.csr_addr === MCYCLE_N)
    )
  dt_ic.io.isRVC := false.B
  dt_ic.io.scFailed := false.B
  dt_ic.io.wen := RegNext(wb.io.rd_en)
  dt_ic.io.wdata := RegNext(wb.io.rd_data)
  dt_ic.io.wdest := RegNext(wb.io.rd_addr)

  val dt_ae = Module(new DifftestArchEvent)
  dt_ae.io.clock := clock
  dt_ae.io.coreid := 0.U
  dt_ae.io.intrNO := RegNext(csr.io.intrNO)
  dt_ae.io.cause := RegNext(csr.io.cause)
  dt_ae.io.exceptionPC := RegNext(wb.io.pc)

  val cycle_cnt = RegInit(0.U(64.W))
  val instr_cnt = RegInit(0.U(64.W))

  cycle_cnt := cycle_cnt + 1.U
  instr_cnt := instr_cnt + 1.U

  val rf_a0 = WireInit(0.U(64.W))
  BoringUtils.addSink(rf_a0, "rf_a0")

  val dt_te = Module(new DifftestTrapEvent)
  dt_te.io.clock := clock
  dt_te.io.coreid := 0.U
  dt_te.io.valid := (wb.io.inst === "h0000006b".U)
  dt_te.io.code := rf_a0(2, 0)
  dt_te.io.pc := wb.io.pc
  dt_te.io.cycleCnt := cycle_cnt
  dt_te.io.instrCnt := instr_cnt

  val dt_cs = Module(new DifftestCSRState)
  dt_cs.io.clock := clock
  dt_cs.io.coreid := 0.U
  dt_cs.io.priviledgeMode := 3.U // Machine mode
  dt_cs.io.mstatus := RegNext(csr.io.mstatus)
  dt_cs.io.sstatus := RegNext(csr.io.sstatus)
  dt_cs.io.mepc := RegNext(csr.io.mepc)
  dt_cs.io.sepc := 0.U
  dt_cs.io.mtval := 0.U
  dt_cs.io.stval := 0.U
  dt_cs.io.mtvec := RegNext(csr.io.mtvec)
  dt_cs.io.stvec := 0.U
  dt_cs.io.mcause := RegNext(csr.io.mcause)
  dt_cs.io.scause := 0.U
  dt_cs.io.satp := 0.U
  dt_cs.io.mip := 0.U //实现了，但接0
  dt_cs.io.mie := RegNext(csr.io.mie)
  dt_cs.io.mscratch := RegNext(csr.io.mscratch)
  dt_cs.io.sscratch := 0.U
  dt_cs.io.mideleg := 0.U
  dt_cs.io.medeleg := 0.U
}
