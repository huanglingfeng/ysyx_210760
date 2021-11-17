import chisel3._
import chisel3.util._

class wr extends Module {
  val io = IO(new Bundle {
    val ls_to_ws_valid = Input(Bool())
    val ws_valid = Output(Bool())
    val ws_allowin = Input(Bool())

    val ls_to_wr = Flipped(new LSU_TO_WB_BUS)
    val wr_to_wb = (new LSU_TO_WB_BUS)
  })
  
  val judg = io.ls_to_ws_valid && io.ws_allowin
  io.ws_valid := RegEnable(io.ls_to_ws_valid, io.ws_allowin)
  RegEnable(io.ls_to_wr, judg) <> io.wr_to_wb

}
