import chisel3._
import chisel3.util._
import Consts._

class AXI_BUS_TOP extends Bundle{
    val aw = new Bundle{
        val ready = Input(Bool())
        val valid = Output(Bool())
        val bits_addr = Output(UInt(64.W))
        val bits_prot = Output(3.W)
        val bits_id = Output(UInt(AXI_ID_WIDTH.W))
        val bits_user = Output(UInt(AXI_USER_WIDTH.W))
        val bits_len = Output(UInt(8.W))
        val bits_size = Output(UInt(3.W))
        val bits_burst = Output(UInt(2.W))
        val bits_lock = Output(Bool())
        val bits_cache = Output(UInt(4.W))
        val bits_qos = Output(UInt(4.W))
    }
    val w = new Bundle{
        val ready = Input(Bool())
        val valid = Output(Bool())
        val bits_data = Output(UInt(64.W))
        val bits_strb = Output(UInt(8.W))
        val bits_last = Output(Bool())
    }
    val b = new Bundle{
        val ready = Output(Bool())
        val valid = Input(Bool())
        val bits_resp = Input(UInt(2.W))
        val bits_id = Input(UInt(AXI_ID_WIDTH.W))
        val bits_user = Input(UInt(AXI_USER_WIDTH.W))
    }
    val ar = new Bundle{
        val ready = Input(Bool())
        val valid = Output(Bool())
        val bits_addr = Output(UInt(64.W))
        val bits_prot = Output(3.W)
        val bits_id = Output(UInt(AXI_ID_WIDTH.W))
        val bits_user = Output(UInt(AXI_USER_WIDTH.W))
        val bits_len = Output(UInt(8.W))
        val bits_size = Output(UInt(3.W))
        val bits_burst = Output(UInt(2.W))
        val bits_lock = Output(Bool())
        val bits_cache = Output(UInt(4.W))
        val bits_qos = Output(UInt(4.W))
    }
    val r = new Bundle{
        val ready = Output(Bool())
        val valid = Input(Bool())
        val bits_resp = Input(UInt(2.W))
        val bits_data = Input(UInt(64.W))
        val bits_last = Input(Bool())
        val bits_id = Input(UInt(AXI_ID_WIDTH.W))
        val bits_user = Input(UInt(AXI_USER_WIDTH.W))
    }
}
class AXI_BUS extends Bundle{
    val aw = new Bundle{
        val ready = Input(Bool())
        val valid = Output(Bool())
        val addr = Output(UInt(64.W))
        val prot = Output(3.W)
        val id = Output(UInt(AXI_ID_WIDTH.W))
        val user = Output(UInt(AXI_USER_WIDTH.W))
        val len = Output(UInt(8.W))
        val size = Output(UInt(3.W))
        val burst = Output(UInt(2.W))
        val lock = Output(Bool())
        val cache = Output(UInt(4.W))
        val qos = Output(UInt(4.W))
    }
    val w = new Bundle{
        val ready = Input(Bool())
        val valid = Output(Bool())
        val data = Output(UInt(64.W))
        val strb = Output(UInt(8.W))
        val last = Output(Bool())
    }
    val b = new Bundle{
        val ready = Output(Bool())
        val valid = Input(Bool())
        val resp = Input(UInt(2.W))
        val id = Input(UInt(AXI_ID_WIDTH.W))
        val user = Input(UInt(AXI_USER_WIDTH.W))
    }
    val ar = new Bundle{
        val ready = Input(Bool())
        val valid = Output(Bool())
        val addr = Output(UInt(64.W))
        val prot = Output(3.W)
        val id = Output(UInt(AXI_ID_WIDTH.W))
        val user = Output(UInt(AXI_USER_WIDTH.W))
        val len = Output(UInt(8.W))
        val size = Output(UInt(3.W))
        val burst = Output(UInt(2.W))
        val lock = Output(Bool())
        val cache = Output(UInt(4.W))
        val qos = Output(UInt(4.W))
    }
    val r = new Bundle{
        val ready = Output(Bool())
        val valid = Input(Bool())
        val resp = Input(UInt(2.W))
        val data = Input(UInt(64.W))
        val last = Input(Bool())
        val id = Input(UInt(AXI_ID_WIDTH.W))
        val user = Input(UInt(AXI_USER_WIDTH.W))
    }
}