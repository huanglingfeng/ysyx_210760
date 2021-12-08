import chisel3._
import chisel3.util._
import Consts._

class EX_TO_ID_BUS extends Bundle{
    val rf_w = Output(Bool())
    val dst = Output(UInt(5.W))
    val alu_res = Output(UInt(64.W))
    val is_csr = Output(Bool())
    val load = Output(Bool())
}

class LSU_TO_ID_BUS extends Bundle{
    val rf_w = Output(Bool())
    val dst = Output(UInt(5.W))
    val lsu_res = Output(UInt(64.W))
    val is_csr = Output(Bool())
    val br_stall = Output(Bool())
}

class WB_TO_ID_BUS extends Bundle{
    val rf_w = Output(Bool())
    val dst = Output(UInt(5.W))
    val wb_res = Output(UInt(64.W))
}