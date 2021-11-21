import chisel3._
import chisel3.util._
import Consts._

class WB extends Module {
  val io = IO(new Bundle {
    val ws_valid = Input(Bool())
    val ws_allowin = Output(Bool())

    val lsu_to_wb = Flipped(new LSU_TO_WB_BUS)
    val wb_to_csr = new WB_TO_CSR_BUS

    val wb_fwd = new WB_TO_ID_BUS

    val rd_addr = Output(UInt(5.W))
    val rd_data = Output(UInt(64.W))
    val rd_en = Output(Bool())

    val pc = Output(UInt(64.W))
    val inst = Output(UInt(32.W))
    val is_nop = Output(Bool())

    val flush = Input(Bool())
  })
  val pc = io.lsu_to_wb.pc
  val inst = Mux(io.flush,NOP,io.lsu_to_wb.inst)
  val is_csr = io.lsu_to_wb.is_csr

  //------------流水线控制逻辑------------------------------//
  val ws_valid = io.ws_valid
  val wb_ready_go = true.B
  val ws_allowin = Wire(Bool())

  ws_allowin := !ws_valid || wb_ready_go
  
  io.ws_allowin := ws_allowin

  //-------------------------------------------------------//
  val csr_res = io.wb_to_csr.csr_res

  val rd_addr = Mux(ws_valid &&(inst =/= NOP),io.lsu_to_wb.dest,0.U)
  io.rd_addr := rd_addr
  val rd_data = Mux(is_csr,csr_res,io.lsu_to_wb.lsu_res)
  io.rd_data := rd_data
  val rd_en = Mux(ws_valid && (inst =/= NOP),io.lsu_to_wb.rf_w,false.B)
  io.rd_en := rd_en

  io.wb_fwd.rf_w := Mux(!ws_valid,false.B,rd_en)
  io.wb_fwd.dst := rd_addr
  io.wb_fwd.wb_res := rd_data

  io.pc := pc
  io.inst := inst
  io.is_nop := Mux(io.flush,NOP,io.lsu_to_wb.is_nop)

  io.wb_to_csr.is_nop := io.lsu_to_wb.is_nop
  
  io.wb_to_csr.csrop := io.lsu_to_wb.csrop
  io.wb_to_csr.csr_addr := io.lsu_to_wb.csr_addr
  io.wb_to_csr.csr_src := io.lsu_to_wb.csr_src
  io.wb_to_csr.is_zero := io.lsu_to_wb.is_zero
  io.wb_to_csr.pc := pc
}
