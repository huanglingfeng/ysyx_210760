import chisel3._
import chisel3.util._
import difftest._
import Consts._

class SimTop extends Module {
  val io = IO(new Bundle {
    val logCtrl = new LogCtrlIO
    val perfInfo = new PerfInfoIO
    val uart = new UARTIO

    val memAXI_0 = new AXI_BUS_TOP
  })

  val core = Module(new Core)

  val u_axi_rw = new AXI_RW

  val s_a_brid = new S_A_BRIDGE

  core.io.iram <> s_a_brid.io.iram
  core.io.dram <> s_a_brid.io.dram
  //--------cpu <> u_axi_rw-------------------------//
  u_axi_rw.io.rw_valid_i := s_a_brid.io.rw_valid
  s_a_brid.io.rw_ready := u_axi_rw.io.rw_ready
  u_axi_rw.io.rw_req_i := s_a_brid.io.rw_req
  s_a_brid.io.data_read := u_axi_rw.io.data_read_o
  u_axi_rw.io.data_write_i := s_a_brid.io.data_write
  u_axi_rw.io.rw_addr_i := s_a_brid.io.rw_addr
  u_axi_rw.io.rw_size_i := s_a_brid.io.rw_size
  s_a_brid.io.rw_resp := u_axi_rw.io.rw_resp_o
  u_axi_rw.io.w_strb := s_a_brid.io.w_strb
  u_axi_rw.io.axi_id := s_a_brid.io.id
  
  //--------write address--------------------------//
  u_axi_rw.io.axi.ready_i := io.memAXI_0.aw.ready
  io.memAXI_0.aw.valid := u_axi_rw.io.axi.valid_o
  io.memAXI_0.aw.bits_addr := u_axi_rw.io.axi.aw.addr_o
  io.memAXI_0.aw.bits_prot := u_axi_rw.io.axi.aw.prot_o
  io.memAXI_0.aw.bits_id := u_axi_rw.io.axi.aw.id_o
  io.memAXI_0.aw.bits_user := u_axi_rw.io.axi.aw.user_o
  io.memAXI_0.aw.bits_len := u_axi_rw.io.axi.aw.len_o  
  io.memAXI_0.aw.bits_size := u_axi_rw.io.axi.aw.size_o
  io.memAXI_0.aw.bits_burst := u_axi_rw.io.axi.aw.burst_o
  io.memAXI_0.aw.bits_lock := u_axi_rw.io.axi.aw.lock_o
  io.memAXI_0.aw.bits_cache := u_axi_rw.io.axi.aw.cache_o
  io.memAXI_0.aw.bits_qos := u_axi_rw.io.axi.aw.qos_o

  //-------------write data-----------------------//
  u_axi_rw.io.axi.w.ready_i := io.memAXI_0.w.ready
  io.memAXI_0.w.valid := u_axi_rw.io.axi.w.valid_o
  io.memAXI_0.w.bits_data := u_axi_rw.io.axi.w.data_o
  io.memAXI_0.w.bits_strb := u_axi_rw.io.axi.w.strb_o
  io.memAXI_0.w.bits_last := u_axi_rw.io.axi.w.last_o

  //-------------write response--------------------//
  io.memAXI_0.b.ready := u_axi_rw.io.axi.b.ready_o
  u_axi_rw.io.axi.b.valid_i := io.memAXI_0.b.valid
  u_axi_rw.io.axi.b.resp_i := io.memAXI_0.b.bits_resp
  u_axi_rw.io.axi.b.id_i := io.memAXI_0.b.bits_id
  u_axi_rw.io.axi.b.user_i := io.memAXI_0.b.bits_user

  //-------------read address-----------------------//
  u_axi_rw.io.axi.ar.ready_i := io.memAXI_0.ar.ready
  io.memAXI_0.ar.valid := u_axi_rw.io.axi.ar.valid_o
  io.memAXI_0.ar.bits_addr := u_axi_rw.io.axi.ar.addr_o
  io.memAXI_0.ar.bits_prot := u_axi_rw.io.axi.ar.prot_o
  io.memAXI_0.ar.bits_id := u_axi_rw.io.axi.ar.id_o
  io.memAXI_0.ar.bits_user := u_axi_rw.io.axi.ar.user_o
  io.memAXI_0.ar.bits_len := u_axi_rw.io.axi.ar.len_o
  io.memAXI_0.ar.bits_size := u_axi_rw.io.axi.ar.size_o
  io.memAXI_0.ar.bits_burst := u_axi_rw.io.axi.ar.burst_o
  io.memAXI_0.ar.bits_lock := u_axi_rw.io.axi.ar.lock_o
  io.memAXI_0.ar.bits_cache := u_axi_rw.io.axi.ar.cache_o
  io.memAXI_0.ar.bits_qos := u_axi_rw.io.axi.ar.qos_o

  //----------------read data-------------------------//
  io.memAXI_0.r.ready := u_axi_rw.io.axi.r.ready_o
  u_axi_rw.io.axi.r.valid_i := io.memAXI_0.r.bits_valid
  u_axi_rw.io.axi.r.resp_i := io.memAXI_0.r.bits_resp
  u_axi_rw.io.axi.r.data_i := io.memAXI_0.r.bits_data
  u_axi_rw.io.axi.r.last_i := io.memAXI_0.r.bits_last
  u_axi_rw.io.axi.r.id_i := io.memAXI_0.r.bits_id
  u_axi_rw.io.axi.r.user_i := io.memAXI_0.r.bits_user


  io.uart.out.valid := false.B
  io.uart.out.ch := 0.U
  io.uart.in.valid := false.B

}
