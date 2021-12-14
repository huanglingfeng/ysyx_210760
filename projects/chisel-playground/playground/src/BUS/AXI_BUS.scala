import chisel3._
import chisel3.util._
import Consts._

class AXI_BUS_TOP extends Bundle{
        val awready = Input(Bool())
        val awvalid = Output(Bool())
        val awaddr = Output(UInt(32.W))
        val awid = Output(UInt(AXI_ID_WIDTH.W))
        val awlen = Output(UInt(8.W))
        val awsize = Output(UInt(3.W))
        val awburst = Output(UInt(2.W))

        val wready = Input(Bool())
        val wvalid = Output(Bool())
        val wdata = Output(UInt(64.W))
        val wstrb = Output(UInt(8.W))
        val wlast = Output(Bool())

        val bready = Output(Bool())
        val bvalid = Input(Bool())
        val bresp = Input(UInt(2.W))
        val bid = Input(UInt(AXI_ID_WIDTH.W))
    
        val arready = Input(Bool())
        val arvalid = Output(Bool())
        val araddr = Output(UInt(32.W))
        val arid = Output(UInt(AXI_ID_WIDTH.W))
        val arlen = Output(UInt(8.W))
        val arsize = Output(UInt(3.W))
        val arburst = Output(UInt(2.W))

        val rready = Output(Bool())
        val rvalid = Input(Bool())
        val rresp = Input(UInt(2.W))
        val rdata = Input(UInt(64.W))
        val rlast = Input(Bool())
        val rid = Input(UInt(AXI_ID_WIDTH.W))
}
class AXI_BUS extends Bundle{
    val aw = new Bundle{
        val ready_i = Input(Bool())
        val valid_o = Output(Bool())
        val addr_o = Output(UInt(32.W))
        val prot_o = Output(UInt(3.W))
        val id_o = Output(UInt(AXI_ID_WIDTH.W))
        val user_o = Output(UInt(AXI_USER_WIDTH.W))
        val len_o = Output(UInt(8.W))
        val size_o = Output(UInt(3.W))
        val burst_o = Output(UInt(2.W))
        val lock_o = Output(Bool())
        val cache_o = Output(UInt(4.W))
        val qos_o = Output(UInt(4.W))
    }
    val w = new Bundle{
        val ready_i = Input(Bool())
        val valid_o = Output(Bool())
        val data_o = Output(UInt(64.W))
        val strb_o = Output(UInt(8.W))
    }
    val b = new Bundle{
        val ready_o = Output(Bool())
        val valid_i = Input(Bool())
        val resp_i = Input(UInt(2.W))
        val id_i = Input(UInt(AXI_ID_WIDTH.W))
        val user_i = Input(UInt(AXI_USER_WIDTH.W))
    }
    val ar = new Bundle{
        val ready_i = Input(Bool())
        val valid_o = Output(Bool())
        val addr_o = Output(UInt(32.W))
        val prot_o = Output(UInt(3.W))
        val id_o = Output(UInt(AXI_ID_WIDTH.W))
        val user_o = Output(UInt(AXI_USER_WIDTH.W))
        val len_o = Output(UInt(8.W))
        val size_o = Output(UInt(3.W))
        val burst_o = Output(UInt(2.W))
        val lock_o = Output(Bool())
        val cache_o = Output(UInt(4.W))
        val qos_o = Output(UInt(4.W))
    }
    val r = new Bundle{
        val ready_o = Output(Bool())
        val valid_i = Input(Bool())
        val resp_i = Input(UInt(2.W))
        val data_i = Input(UInt(64.W))
        val last_i = Input(Bool())
        val id_i = Input(UInt(AXI_ID_WIDTH.W))
        val user_i = Input(UInt(AXI_USER_WIDTH.W))
    }
}