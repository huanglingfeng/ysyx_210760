import chisel3._
import chisel3.util._

import Consts._

class SimTop extends Module {
  val io = IO(new Bundle {
    val interrupt = Input(Bool())
    val master = new AXI_BUS_TOP
    val slave  = Flipped(new AXI_BUS_TOP)
  })

  val core = Module(new Core)

  val u_axi_rw = Module(new AXI_RW)

  val s_a_brid = Module(new S_A_BRIDGE)

  core.io.isram <> s_a_brid.io.iram
  core.io.dsram <> s_a_brid.io.dram
  //--------cpu <> u_axi_rw-------------------------//
  u_axi_rw.io.rw_valid_i := s_a_brid.io.rw_valid
  s_a_brid.io.rw_ready := u_axi_rw.io.rw_ready_o
  u_axi_rw.io.rw_req_i := s_a_brid.io.rw_req
  s_a_brid.io.data_read := u_axi_rw.io.data_read_o
  u_axi_rw.io.data_write_i := s_a_brid.io.data_write
  u_axi_rw.io.rw_addr_i := s_a_brid.io.rw_addr
  u_axi_rw.io.rw_size_i := s_a_brid.io.rw_size
  s_a_brid.io.rw_resp := u_axi_rw.io.rw_resp_o
  u_axi_rw.io.w_strb := s_a_brid.io.w_strb
  u_axi_rw.io.axi_id := s_a_brid.io.id
  //--------write address--------------------------//
  u_axi_rw.io.axi.aw.ready_i := io.master.awready
  io.master.awvalid := u_axi_rw.io.axi.aw.valid_o
  io.master.awaddr := u_axi_rw.io.axi.aw.addr_o
  io.master.awid := u_axi_rw.io.axi.aw.id_o
  io.master.awlen := u_axi_rw.io.axi.aw.len_o  
  io.master.awsize := u_axi_rw.io.axi.aw.size_o
  io.master.awburst := u_axi_rw.io.axi.aw.burst_o
  //-------------write data-----------------------//
  u_axi_rw.io.axi.w.ready_i := io.master.wready
  io.master.wvalid := u_axi_rw.io.axi.w.valid_o
  io.master.wdata := u_axi_rw.io.axi.w.data_o
  io.master.wstrb := u_axi_rw.io.axi.w.strb_o
  io.master.wlast := 1.U

  //-------------write response--------------------//
  io.master.bready := u_axi_rw.io.axi.b.ready_o
  u_axi_rw.io.axi.b.valid_i := io.master.bvalid
  u_axi_rw.io.axi.b.resp_i := io.master.bresp
  u_axi_rw.io.axi.b.id_i := io.master.bid
  u_axi_rw.io.axi.b.user_i := 0.U

  //-------------read address-----------------------//
  u_axi_rw.io.axi.ar.ready_i := io.master.arready
  io.master.arvalid := u_axi_rw.io.axi.ar.valid_o
  io.master.araddr := u_axi_rw.io.axi.ar.addr_o
  io.master.arid := u_axi_rw.io.axi.ar.id_o
  io.master.arlen := u_axi_rw.io.axi.ar.len_o
  io.master.arsize := u_axi_rw.io.axi.ar.size_o
  io.master.arburst := u_axi_rw.io.axi.ar.burst_o
  //----------------read data-------------------------//
  io.master.rready := u_axi_rw.io.axi.r.ready_o
  u_axi_rw.io.axi.r.valid_i := io.master.rvalid
  u_axi_rw.io.axi.r.resp_i := io.master.rresp
  u_axi_rw.io.axi.r.data_i := io.master.rdata
  u_axi_rw.io.axi.r.last_i := io.master.rlast
  u_axi_rw.io.axi.r.id_i := io.master.rid
  u_axi_rw.io.axi.r.user_i := 0.U

  //------------axi slave 悬空----------------------//
  io.slave.awready := 0.U
  io.slave.wready  := 0.U
  io.slave.bvalid  := 0.U
  io.slave.bresp   := 0.U
  io.slave.bid     := 0.U
  io.slave.arready := 0.U
  io.slave.rvalid  := 0.U
  io.slave.rresp   := 0.U
  io.slave.rdata   := 0.U
  io.slave.rlast   := 0.U
  io.slave.rid     := 0.U
}
