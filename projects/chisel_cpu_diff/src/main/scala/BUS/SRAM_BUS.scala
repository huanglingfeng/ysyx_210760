import chisel3._
import chisel3.util._
import Consts._

class SRAM_BUS extends Bundle{
    val req = Output(Bool())
    val wr  = Output(Bool())
    val size = Output(UInt(2.W))
    val addr = Output(UInt(64.W))
    val wstrb = Output(UInt(8.W))
    val wdata = Output(UInt(64.W))

    val data_ok = Input(Bool())
    val rdata = Input(UInt(64.W))
}