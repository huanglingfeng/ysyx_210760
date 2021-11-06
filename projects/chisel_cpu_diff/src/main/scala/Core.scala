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
  val decode = Module(new Decode)

  fetch.io.if_to_id <> decode.io.if_to_id
  decode.io.id_to_if <> fetch.io.id_to_if

  val exu = Module(new Execution)
  decode.io.id_to_ex <> exu.io.id_to_ex

  val isu = Module(new ISU)
  exu.io.ex_to_isu <> isu.io.ex_to_isu
  isu.io.dmem <> io.dmem

  val wb = Module(new WB)
  isu.io.isu_to_wb <> wb.io.isu_to_wb

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
  decode.io.id_to_csr <> csr.io.csr_to_id

  /* ----- Difftest ------------------------------ */

  val dt_ic = Module(new DifftestInstrCommit)
  dt_ic.io.clock := clock
  dt_ic.io.coreid := 0.U
  dt_ic.io.index := 0.U
  dt_ic.io.valid := true.B
  dt_ic.io.pc := RegNext(fetch.io.if_to_id.pc)
  dt_ic.io.instr := RegNext(fetch.io.if_to_id.inst)
  dt_ic.io.skip := RegNext(fetch.io.if_to_id.inst === "h0000007b".U) 
  // || fetch.io.if_to_id.inst === CSRRW 
  // || fetch.io.if_to_id.inst === CSRRS || fetch.io.if_to_id.inst === CSRRC || fetch.io.if_to_id.inst === CSRRWI
  // || fetch.io.if_to_id.inst === CSRRSI || fetch.io.if_to_id.inst === CSRRCI)
  dt_ic.io.isRVC := false.B
  dt_ic.io.scFailed := false.B
  dt_ic.io.wen := RegNext(wb.io.rd_en)
  dt_ic.io.wdata := RegNext(wb.io.rd_data)
  dt_ic.io.wdest := RegNext(wb.io.rd_addr)

  val dt_ae = Module(new DifftestArchEvent)
  dt_ae.io.clock := clock
  dt_ae.io.coreid := 0.U
  dt_ae.io.intrNO := 0.U
  dt_ae.io.cause := 0.U
  dt_ae.io.exceptionPC := 0.U

  val cycle_cnt = RegInit(0.U(64.W))
  val instr_cnt = RegInit(0.U(64.W))

  cycle_cnt := cycle_cnt + 1.U
  instr_cnt := instr_cnt + 1.U

  val rf_a0 = WireInit(0.U(64.W))
  BoringUtils.addSink(rf_a0, "rf_a0")

  val dt_te = Module(new DifftestTrapEvent)
  dt_te.io.clock := clock
  dt_te.io.coreid := 0.U
  dt_te.io.valid := (fetch.io.if_to_id.inst === "h0000006b".U)
  dt_te.io.code := rf_a0(2, 0)
  dt_te.io.pc := fetch.io.if_to_id.pc
  dt_te.io.cycleCnt := cycle_cnt
  dt_te.io.instrCnt := instr_cnt

  val dt_cs = Module(new DifftestCSRState)
  dt_cs.io.clock := clock
  dt_cs.io.coreid := 0.U
  dt_cs.io.priviledgeMode := 3.U // Machine mode
  dt_cs.io.mstatus := csr.io.mstatus
  dt_cs.io.sstatus := 0.U
  dt_cs.io.mepc := csr.io.mepc
  dt_cs.io.sepc := 0.U
  dt_cs.io.mtval := 0.U
  dt_cs.io.stval := 0.U
  dt_cs.io.mtvec := csr.io.mtvec
  dt_cs.io.stvec := 0.U
  dt_cs.io.mcause := csr.io.mcause
  dt_cs.io.scause := 0.U
  dt_cs.io.satp := 0.U
  dt_cs.io.mip := csr.io.mip
  dt_cs.io.mie := csr.io.mie
  dt_cs.io.mscratch := 0.U
  dt_cs.io.sscratch := 0.U
  dt_cs.io.mideleg := 0.U
  dt_cs.io.medeleg := 0.U
}
