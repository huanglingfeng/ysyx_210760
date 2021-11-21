import chisel3._
import chisel3.util._
import Instructions._
import Consts._
//IFU
class IF_TO_ID_BUS extends Bundle {
  val is_nop = Output(Bool())

  val pc = Output(UInt(64.W))
  val inst = Output(UInt(32.W))
}

//IDU
class ID_TO_IF_BUS extends Bundle{
  val pc_target=Output(UInt(64.W))
  val jump = Output(Bool())
  val csr_jump = Output(Bool())
}

class ID_TO_EX_BUS extends Bundle{
  val is_nop = Output(Bool())
  
  val aluop = Output(UInt(11.W))
  val lsuop = Output(UInt(8.W))
  val rv64op = Output(UInt(12.W))
  
  val out1  = Output(UInt(64.W))
  val out2  = Output(UInt(64.W))

  val imm = Output(UInt(64.W))
  
  val dest  = Output(UInt(5.W))
  val rf_w  = Output(Bool())
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

class CSR_TO_ID_BUS extends Bundle{
  val csr_jump = Output(Bool())
  val csr_target = Output(UInt(64.W))
}


