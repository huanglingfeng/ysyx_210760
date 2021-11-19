import chisel3._
import chisel3.util._

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
  io.wr_to_wb.lsu_res := RegEnable(io.lsu_to_wr.lsu_res, 0.U ,judg)

  io.wr_to_wb.dest := RegEnable(io.lsu_to_wr.dest, 0.U ,judg)
  io.wr_to_wb.rf_w := RegEnable(io.lsu_to_wr.rf_w, false.B ,judg)
}
