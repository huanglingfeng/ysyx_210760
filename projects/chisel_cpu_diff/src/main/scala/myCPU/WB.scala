import chisel3._
import chisel3.util._

class WB extends Module {
  val io = IO(new Bundle {
    val wb_valid = Input(Bool())
    val wb_allowin = Output(Bool())

    val lsu_to_wb = Flipped(new LSU_TO_WB_BUS)

    val rd_addr = Output(UInt(5.W))
    val rd_data = Output(UInt(64.W))
    val rd_en = Output(Bool())
  })
  //------------流水线控制逻辑------------------------------//
  val wb_valid = io.wb_valid
  val wb_ready_go = true.B
  val wb_allowin = Wire(Bool())

  wb_allowin := !wb_valid || wb_ready_go
  
  io.wb_allowin := wb_allowin

  //-------------------------------------------------------//

  io.rd_addr := Mux(wb_valid,io.lsu_to_wb.dest,0.U)
  io.rd_data := io.lsu_to_wb.lsu_res
  io.rd_en := Mux(wb_valid,io.lsu_to_wb.rf_w,false.B)
}
