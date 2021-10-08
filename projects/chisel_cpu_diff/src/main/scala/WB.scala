import chisel3._
import chisel3.util._

class WB extends Module {
    val io = IO(new Bundle{
        val in = Input(UInt(64.W))
        val out = Output(UInt(64.W))
    })
    
}