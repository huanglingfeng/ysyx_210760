import chisel3._
import chisel3.util._

class EX_TO_ID_BUS extends Bundle{
    val rf_w = Output(Bool())
    val dst = Output(UInt(5.W))
    val alu_res = Output(UInt(64.W))
}

class LSU_TO_ID_BUS extends Bundle{
    val rf_w = Output(Bool())
    val dst = Output(UInt(5.W))
    val lsu_res = Output(UInt(64.W))
}

class WB_TO_ID_BUS extends Bundle{
    val rd_en = Output(Bool())
    val rd_addr = Output(UInt(5.W))
    val rd_data = Output(UInt(64.W))
}