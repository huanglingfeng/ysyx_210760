import chisel3._
import chisel3.util._
import Consts._

class EX_TO_LSU_BUS extends Bundle {
  val is_nop = Output(Bool())

  val alu_res = Output(UInt(64.W))

  val src1 = Output(UInt(64.W))
  val src2 = Output(UInt(64.W))
  val imm = Output(UInt(64.W))

  val lsuop = Output(UInt(8.W))
  val rv64op = Output(UInt(12.W))
  val dest = Output(UInt(5.W))
  val rf_w = Output(Bool())
  val load = Output(Bool())
  val save = Output(Bool())
  
  val pc = Output(UInt(64.W))
  val inst = Output(UInt(32.W))

  val is_csr = Output(Bool())
  val csrop = Output(UInt(SEL_CSR_WIDTH.W))
  val csr_addr = Output(UInt(12.W))
  val csr_src = Output(UInt(64.W))
  val is_zero = Output(Bool())
}

class LSU_TO_WB_BUS extends Bundle {
  val is_nop = Output(Bool())
  
  val lsu_res = Output(UInt(64.W))

  val dest = Output(UInt(5.W))
  val rf_w = Output(Bool())

  val pc = Output(UInt(64.W))
  val inst = Output(UInt(32.W))

  val is_csr = Output(Bool())
  val csrop = Output(UInt(SEL_CSR_WIDTH.W))
  val csr_addr = Output(UInt(12.W))
  val csr_src = Output(UInt(64.W))
  val is_zero = Output(Bool())
}

class LSU_TO_CSR_BUS extends Bundle{
  val is_clint = Output(Bool())
  val is_mtime = Output(Bool())
  val is_mtimecmp = Output(Bool())
  val load = Output(Bool())
  val save = Output(Bool())
  val wdata = Output(UInt(64.W))

  val rdata = Input(UInt(64.W))
}

class WB_TO_CSR_BUS extends Bundle{
  val is_nop = Output(Bool())

  val csrop = Output(UInt(SEL_CSR_WIDTH.W))
  val csr_addr = Output(UInt(12.W))
  val csr_src = Output(UInt(64.W))
  val is_zero = Output(Bool())
  val pc = Output(UInt(64.W))
  
  val csr_res = Input(UInt(64.W))
}