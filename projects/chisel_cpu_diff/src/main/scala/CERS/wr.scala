import chisel3._
import chisel3.util._
import Instructions._
import Consts._

class WR extends Module {
  val io = IO(new Bundle {
    val ls_to_ws_valid = Input(Bool())
    val ws_valid = Output(Bool())
    val ws_allowin = Input(Bool())

    val lsu_to_wr = Flipped(new LSU_TO_WB_BUS)
    val wr_to_wb = (new LSU_TO_WB_BUS)
  })
  
  val judg = io.ls_to_ws_valid && io.ws_allowin
  io.ws_valid := RegEnable(io.ls_to_ws_valid,true.B, io.ws_allowin)
  // RegEnable(io.lsu_to_wr,0.U, judg) <> io.wr_to_wb
  io.wr_to_wb.is_nop := RegEnable(io.lsu_to_wr.is_nop, false.B ,io.ws_allowin)

  io.wr_to_wb.lsu_res := RegEnable(io.lsu_to_wr.lsu_res, 0.U ,judg)

  io.wr_to_wb.dest := RegEnable(io.lsu_to_wr.dest, 0.U ,judg)
  io.wr_to_wb.rf_w := RegEnable(io.lsu_to_wr.rf_w, false.B ,judg)

  io.wr_to_wb.pc := RegEnable(io.lsu_to_wr.pc, 0.U ,judg)
  io.wr_to_wb.inst := RegEnable(io.lsu_to_wr.inst, 0.U ,io.ws_allowin)

  io.wr_to_wb.is_csr := RegEnable(io.lsu_to_wr.is_csr, false.B ,judg)
  io.wr_to_wb.csrop := RegEnable(io.lsu_to_wr.csrop, 0.U ,judg)
  io.wr_to_wb.csr_addr := RegEnable(io.lsu_to_wr.csr_addr, 0.U ,judg)
  io.wr_to_wb.csr_src := RegEnable(io.lsu_to_wr.csr_src, 0.U ,judg)
  io.wr_to_wb.is_zero := RegEnable(io.lsu_to_wr.is_zero, false.B ,judg)
}
