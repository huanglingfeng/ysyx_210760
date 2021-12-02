//sram-axi转接桥
import chisel3._
import chisel3.util._
import Consts._

class S_A_BRIDGE extends Module{
    val io = IO(new Bundle{
        val iram = Flipped(new SRAM_BUS)
        val dram = Flipped(new SRAM_BUS)

        val rw_valid_i = Output(Bool())
        val rw_ready_o = Input(Bool())
        val rw_req_i = Output(Bool())
        val data_read_o = Input(UInt(RW_DATA_WIDTH.W))
        val data_write_i = Output(UInt(RW_DATA_WIDTH.W))
        val rw_addr_i = Output(UInt(AXI_DATA_WIDTH.W))
        val rw_size_i = Output(UInt(2.W))
        val rw_resp_o = Input(UInt(2.W))

        val id = Output(AXI_ID_WIDTH.W)
    })
    

}