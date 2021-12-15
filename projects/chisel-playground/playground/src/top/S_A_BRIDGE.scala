//sram-axi转接桥
import chisel3._
import chisel3.util._
import Consts._

class S_A_BRIDGE extends Module {
  val io = IO(new Bundle {
    val iram = Flipped(new SRAM_BUS)
    val dram = Flipped(new SRAM_BUS)

    val rw_valid = Output(Bool())
    val rw_ready = Input(Bool())
    val rw_req = Output(Bool())
    val data_read = Input(UInt(RW_DATA_WIDTH.W))
    val data_write = Output(UInt(RW_DATA_WIDTH.W))
    val rw_addr = Output(UInt(RW_ADDR_WIDTH.W))
    val rw_size = Output(UInt(2.W))
    val rw_resp = Input(UInt(2.W))
    val w_strb = Output(UInt(8.W))

    val id = Output(UInt(AXI_ID_WIDTH.W))
  })
  val rw_resp = WireInit(0.U(2.W))

  val axi_hs = io.rw_valid && io.rw_ready
  val axi_dataok = io.rw_ready
  val iram_avalid = io.iram.addr_can_send
  val dram_avalid = io.dram.addr_can_send
  val iram_hs = io.iram.data_ok && io.iram.using
  val dram_hs = io.dram.data_ok && io.dram.using
  val is_dram = RegInit(false.B)
  val is_dram_w = WireInit(false.B)

  val STATE_ADDR_RECEIVE = "b00".U(2.W)
  val STATE_ADDR_SEND = "b01".U(2.W)
  val STATE_DATA_WAIT = "b10".U(2.W)
  val STATE_DATA_USE = "b11".U(2.W)

  val state = RegInit(0.U(2.W))
  val axi_addr = RegInit("h3000_0000".U(64.W))

  val is_addr_receive = (state === STATE_ADDR_RECEIVE)
  val is_addr_send = (state === STATE_ADDR_SEND)
  val is_data_wait = (state === STATE_DATA_WAIT)
  val is_data_use = (state === STATE_DATA_USE)

  when(true.B) {
    switch(state) {
      is(STATE_ADDR_RECEIVE) {
        when(Mux(is_dram_w, dram_avalid, iram_avalid) && Mux(is_dram_w, io.dram.addr_ok, io.iram.addr_ok)) {state := STATE_ADDR_SEND}
      }
      is(STATE_ADDR_SEND) { when(axi_hs) { state := Mux(is_dram && io.dram.wr,STATE_DATA_USE,STATE_DATA_WAIT) } }
      is(STATE_DATA_WAIT) { when(axi_dataok) { state := STATE_DATA_USE } }
      is(STATE_DATA_USE) {
        when(Mux(is_dram, dram_hs, iram_hs)) { state := STATE_ADDR_RECEIVE }
      }
    }
  }

  when(is_addr_receive){
    when(io.dram.addr_valid) {
      is_dram := true.B
      is_dram_w := true.B

      axi_addr := io.dram.addr

      io.iram.addr_ok := false.B
      io.dram.addr_ok := true.B

      io.rw_valid := false.B
      io.iram.data_ok := false.B
      io.iram.rdata := 0.U
      io.dram.data_ok := false.B
      io.dram.rdata := 0.U

      io.id := 0.U
      io.rw_req := 0.U
      io.data_write := 0.U
      io.rw_addr := 0.U
      io.rw_size := 0.U
      rw_resp := io.rw_resp
      io.w_strb := 0.U
    }.otherwise {
      is_dram := false.B
      is_dram_w := false.B

      axi_addr := io.iram.addr

      io.iram.addr_ok := true.B
      io.dram.addr_ok := false.B

      io.rw_valid := false.B
      io.iram.data_ok := false.B
      io.iram.rdata := 0.U
      io.dram.data_ok := false.B
      io.dram.rdata := 0.U

      io.id := 0.U
      io.rw_req := 0.U
      io.data_write := 0.U
      io.rw_addr := 0.U
      io.rw_size := 0.U
      rw_resp := io.rw_resp
      io.w_strb := 0.U
    }
  }.elsewhen(is_addr_send) {
    when(is_dram && io.dram.wr) {
      io.id := 1.U
      io.rw_valid := io.dram.addr_valid && !axi_dataok
      io.dram.addr_ok := false.B
      io.dram.data_ok := false.B
      io.rw_req := 1.U
      io.dram.rdata := io.data_read
      io.data_write := io.dram.wdata
      io.rw_addr := axi_addr
      io.rw_size := io.dram.size
      rw_resp := io.rw_resp
      io.w_strb := io.dram.wstrb

      io.iram.addr_ok := false.B
      io.iram.data_ok := false.B
      io.iram.rdata := 0.U
    }.elsewhen(is_dram){
      io.id := 1.U
      io.rw_valid := io.dram.addr_valid
      io.dram.addr_ok := false.B
      io.dram.data_ok := false.B
      io.rw_req := 0.U
      io.dram.rdata := io.data_read
      io.data_write := io.dram.wdata
      io.rw_addr := axi_addr
      io.rw_size := io.dram.size
      rw_resp := io.rw_resp
      io.w_strb := io.dram.wstrb

      io.iram.addr_ok := false.B
      io.iram.data_ok := false.B
      io.iram.rdata := 0.U
    }.otherwise {
      is_dram := false.B

      io.id := 0.U
      io.rw_valid := io.iram.addr_valid
      io.iram.addr_ok := false.B
      io.iram.data_ok := false.B
      io.rw_req := 0.U
      io.iram.rdata := io.data_read
      io.data_write := 0.U
      io.rw_addr := axi_addr
      io.rw_size := SIZE_W
      rw_resp := io.rw_resp
      io.w_strb := 0.U

      io.dram.addr_ok := false.B
      io.dram.data_ok := false.B
      io.dram.rdata := 0.U
    }
  }.elsewhen(is_data_wait){
    when(is_dram) {
      io.id := 1.U
      io.rw_valid := Mux(axi_dataok,false.B,io.dram.addr_valid)
      io.dram.addr_ok := false.B
      io.dram.data_ok := false.B
      io.rw_req := io.dram.wr
      io.dram.rdata := io.data_read
      io.data_write := io.dram.wdata
      io.rw_addr := axi_addr
      io.rw_size := io.dram.size
      rw_resp := io.rw_resp
      io.w_strb := io.dram.wstrb

      io.iram.addr_ok := false.B
      io.iram.data_ok := false.B
      io.iram.rdata := 0.U
    }.otherwise {
      io.id := 0.U
      io.rw_valid := Mux(axi_dataok,false.B,io.iram.addr_valid)
      io.iram.addr_ok := false.B
      io.iram.data_ok := false.B
      io.rw_req := 0.U
      io.iram.rdata := io.data_read
      io.data_write := 0.U
      io.rw_addr := axi_addr
      io.rw_size := SIZE_W
      rw_resp := io.rw_resp
      io.w_strb := 0.U

      io.dram.addr_ok := false.B
      io.dram.data_ok := false.B
      io.dram.rdata := 0.U
    }
  }.elsewhen(is_data_use){
    when(is_dram) {
      io.id := 1.U
      io.rw_valid := false.B
      io.dram.addr_ok := false.B
      io.dram.data_ok := true.B
      io.rw_req := io.dram.wr
      io.dram.rdata := io.data_read
      io.data_write := io.dram.wdata
      io.rw_addr := axi_addr
      io.rw_size := io.dram.size
      rw_resp := io.rw_resp
      io.w_strb := io.dram.wstrb

      io.iram.addr_ok := false.B
      io.iram.data_ok := false.B
      io.iram.rdata := 0.U
    }.otherwise {
      io.id := 0.U
      io.rw_valid := false.B
      io.iram.addr_ok := false.B
      io.iram.data_ok := true.B
      io.rw_req := 0.U
      io.iram.rdata := io.data_read
      io.data_write := 0.U
      io.rw_addr := axi_addr
      io.rw_size := SIZE_W
      rw_resp := io.rw_resp
      io.w_strb := 0.U

      io.dram.addr_ok := false.B
      io.dram.data_ok := false.B
      io.dram.rdata := 0.U
    }
  }.otherwise{
      io.rw_valid := false.B
      io.iram.addr_ok := false.B
      io.iram.data_ok := false.B
      io.iram.rdata := 0.U
      io.dram.addr_ok := false.B
      io.dram.data_ok := false.B
      io.dram.rdata := 0.U

      io.id := 0.U
      io.rw_req := 0.U
      io.data_write := 0.U
      io.rw_addr := 0.U
      io.rw_size := 0.U
      rw_resp := io.rw_resp
      io.w_strb := 0.U
  }
}
