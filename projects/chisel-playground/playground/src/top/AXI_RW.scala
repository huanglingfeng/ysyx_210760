import chisel3._
import chisel3.util._
import Consts._
import scala.math._

class AXI_RW extends Module{
    val io = IO(new Bundle{
        val rw_valid_i = Input(Bool())
        val rw_ready_o = Output(Bool())
        val rw_req_i = Input(Bool())
        val data_read_o = Output(UInt((RW_DATA_WIDTH).W))
        val data_write_i = Input(UInt((RW_DATA_WIDTH).W))
        val rw_addr_i = Input(UInt((AXI_DATA_WIDTH).W))
        val rw_size_i = Input(UInt(2.W))
        val rw_resp_o = Output(UInt(2.W))
        val w_strb = Input(UInt(8.W))
        val axi_id = Input(UInt(AXI_ID_WIDTH.W))

        val axi = new AXI_BUS
    })

    val w_trans = (io.rw_req_i === REQ_WRITE)
    val r_trans = (io.rw_req_i === REQ_READ)
    val w_valid = (io.rw_valid_i & w_trans)
    val r_valid = (io.rw_valid_i & r_trans)

    //handshake
    val aw_hs = (io.axi.aw.ready_i & io.axi.aw.valid_o)
    val w_hs  = (io.axi.w.ready_i & io.axi.w.valid_o)
    val b_hs  = (io.axi.b.ready_o & io.axi.b.valid_i)
    val ar_hs = (io.axi.ar.ready_i & io.axi.ar.valid_o)
    val r_hs  = (io.axi.r.ready_o & io.axi.r.valid_i)

    val w_done =  w_hs
    val r_done = (r_hs & io.axi.r.last_i)
    val trans_done = Mux(w_trans,b_hs,r_done)

    //--------------------State Machine-----------------------------------------------------------------//
    val W_STATE_IDLE  = "b00".U(2.W)
    val W_STATE_ADDR  = "b01".U(2.W)
    val W_STATE_WRITE = "b10".U(2.W)
    val W_STATE_RESP  = "b11".U(2.W)
  
    val R_STATE_IDLE  = "b00".U(2.W)
    val R_STATE_ADDR  = "b01".U(2.W)
    val R_STATE_READ  = "b10".U(2.W)

    val w_state = RegInit(W_STATE_IDLE)
    val r_state = RegInit(R_STATE_IDLE)
    val (w_state_idle,w_state_addr,w_state_write,w_state_resp) = ((w_state === W_STATE_IDLE),(w_state === W_STATE_ADDR),(w_state ===W_STATE_WRITE),(w_state === W_STATE_RESP))
    val (r_state_idle,r_state_addr,r_state_read) = ((r_state === R_STATE_IDLE),(r_state === R_STATE_ADDR),(r_state === R_STATE_READ))

    // Wirte State Machine
    when(w_valid){
        switch(w_state){
            is(W_STATE_IDLE) {w_state := W_STATE_ADDR}
            is(W_STATE_ADDR) {when(aw_hs){w_state := W_STATE_WRITE}}
            is(W_STATE_WRITE){when(w_done){w_state := W_STATE_RESP}}
            is(W_STATE_RESP) {when(b_hs){w_state := W_STATE_IDLE}}
        }
    }
    // Read State Machine
    when(r_valid){
        switch(r_state){
            is(R_STATE_IDLE) {r_state := R_STATE_ADDR}
            is(R_STATE_ADDR) {when(ar_hs){r_state := R_STATE_READ}}
            is(R_STATE_READ) {when(r_done){r_state:= R_STATE_IDLE}}
        }
    }

    //--------------Number of transmission---------------------//
    val axi_len = WireInit(0.U(8.W))
    
    // ------------------Process Data--------------------------//

    axi_len := 0.U
    val axi_size = io.rw_size_i

    val axi_addr = io.rw_addr_i
    val axi_id = io.axi_id
    val axi_user = 0.U(AXI_USER_WIDTH.W)

    val rw_ready = RegInit(false.B)

    val rw_ready_nxt = trans_done
    val rw_ready_en = trans_done | rw_ready
    when(rw_ready_en){
        rw_ready := rw_ready_nxt
    }
    io.rw_ready_o := rw_ready

    val rw_resp = RegInit(0.U(2.W))
    val rw_resp_nxt = Mux(w_trans,io.axi.b.resp_i,io.axi.r.resp_i)
    val resp_en = trans_done
    when(resp_en){
        rw_resp := rw_resp_nxt
    }
    io.rw_resp_o := rw_resp

    // ------------------Write Transaction------------------
    
    //Write address channel signals
    io.axi.aw.valid_o := w_state_addr
    io.axi.aw.addr_o  := axi_addr
    io.axi.aw.prot_o  := 0.U
    io.axi.aw.id_o    := axi_id
    io.axi.aw.user_o  := axi_user
    io.axi.aw.len_o   := axi_len
    io.axi.aw.size_o  := axi_size
    io.axi.aw.burst_o := 1.U
    io.axi.aw.lock_o  := 0.U
    io.axi.aw.cache_o := 0.U
    io.axi.aw.qos_o   := 0.U

    //Write data channel signals
    io.axi.w.valid_o  := w_state_write
    io.axi.w.data_o   := io.data_write_i
    io.axi.w.strb_o   := io.w_strb

    //Write response channel signals
    io.axi.b.ready_o  := w_state_resp

    // ------------------Read Transaction------------------

    // Read address channel signals
    io.axi.ar.valid_o := r_state_addr
    io.axi.ar.addr_o  := axi_addr
    io.axi.ar.prot_o  := 0.U
    io.axi.ar.id_o    := axi_id
    io.axi.ar.user_o  := axi_user
    io.axi.ar.len_o   := axi_len
    io.axi.ar.size_o  := axi_size
    io.axi.ar.burst_o := 1.U
    io.axi.ar.lock_o  := 0.U
    io.axi.ar.cache_o := 0.U
    io.axi.ar.qos_o   := 0.U

    // Read data channel signals
    io.axi.r.ready_o := r_state_read

    val data_read_o = RegInit(0.U(RW_DATA_WIDTH.W))

    when(io.axi.r.ready_o & io.axi.r.valid_i){
        data_read_o := io.axi.r.data_i
    }
    io.data_read_o := data_read_o

}