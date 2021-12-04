//sram-axi转接桥
import chisel3._
import chisel3.util._
import Consts._

class S_A_BRIDGE extends Module{
    val io = IO(new Bundle{
        val iram = Flipped(new SRAM_BUS)
        val dram = Flipped(new SRAM_BUS)

        val rw_valid = Output(Bool())
        val rw_ready = Input(Bool())
        val rw_req = Output(Bool())
        val data_read = Input(UInt(RW_DATA_WIDTH.W))
        val data_write = Output(UInt(RW_DATA_WIDTH.W))
        val rw_addr = Output(UInt(AXI_DATA_WIDTH.W))
        val rw_size = Output(UInt(2.W))
        val rw_resp = Input(UInt(2.W))
        val w_strb = Output(UInt(8.W))

        val id = Output(AXI_ID_WIDTH.W)
    })
    val rw_resp = WireInit(0.U(2.W))
    when(io.dram.rw_valid){
        io.id := 1.U
        io.rw_valid := io.dram.rw_valid
        io.dram.rw_ready := io.rw_ready
        io.rw_req := io.dram.wr
        io.dram.rdata := io.data_read
        io.data_write := io.dram.wdata 
        io.rw_addr := io.dram.addr
        io.rw_size := io.dram.size
        rw_resp := io.rw_resp
        io.w_strb := io.dram.wstrb

        io.iram.rw_ready := false.B
    }.otherwise{
        io.id := 0.U
        io.rw_valid := io.iram.rw_valid
        io.iram.rw_ready := io.rw_ready
        io.rw_req := 0.U
        io.iram.rdata := io.data_read
        io.data_write := 0.U
        io.rw_addr := io.iram.addr
        io.rw_size := SIZE_W
        rw_resp := io.rw_resp
        io.w_strb := 0.U

        io.dram.rw_ready := false.B
    }

}