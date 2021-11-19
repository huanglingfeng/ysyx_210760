import chisel3._
import chisel3.util._

class WB extends Module {
  val io = IO(new Bundle {
    val ws_valid = Input(Bool())
    val ws_allowin = Output(Bool())

    val lsu_to_wb = Flipped(new LSU_TO_WB_BUS)

    val wb_fwd = new WB_TO_ID_BUS

    val rd_addr = Output(UInt(5.W))
    val rd_data = Output(UInt(64.W))
    val rd_en = Output(Bool())
  })
  //------------流水线控制逻辑------------------------------//
  val ws_valid = io.ws_valid
  val wb_ready_go = true.B
  val ws_allowin = Wire(Bool())

  ws_allowin := !ws_valid || wb_ready_go
  
  io.ws_allowin := ws_allowin

  //-------------------------------------------------------//

  val rd_addr = Mux(ws_valid,io.lsu_to_wb.dest,0.U)
  io.rd_addr := rd_addr
  val rd_data = io.lsu_to_wb.lsu_res
  io.rd_data := rd_data
  val rd_en = Mux(ws_valid,io.lsu_to_wb.rf_w,false.B)
  io.rd_en := rd_en

  io.wb_fwd.rf_w := rd_en
  io.wb_fwd.dst := rd_addr
  io.wb_fwd.wb_res := rd_data
}
