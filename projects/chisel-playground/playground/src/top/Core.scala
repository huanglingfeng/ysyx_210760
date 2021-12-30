import chisel3._
import chisel3.util.experimental._
import Instructions._
import Consts._

class Core extends Module {
  val io = IO(new Bundle {
    val isram = new SRAM_BUS
    val dsram = new SRAM_BUS
  })

  val fetch = Module(new InstFetch)
  fetch.io.isram <> io.isram
  
  val dr = Module(new DR)
  val decode = Module(new Decode)
  decode.io.id_to_if <> fetch.io.id_to_if
  decode.io.ds_stall := fetch.io.ds_stall
  val er = Module(new ER)
  val ex = Module(new Execution)
  val lr = Module(new LR)
  val lsu = Module(new LSU)
  lsu.io.dsram <> io.dsram

  lr.io.addr_valid := lsu.io.addr_valid

  val wr = Module(new WR)
  val wb = Module(new WB)

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

  wb.io.csr_stall := decode.io.csr_stall
  csr.io.csr_stall := decode.io.csr_stall

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
  wb.io.flush := csr.io.clkintr_flush
}
