import chisel3._
import chisel3.util._

class WB extends Module {
  val io = IO(new Bundle {
    val lsu_to_wb = Flipped(new LSU_TO_WB_BUS)

    val rd_addr = Output(UInt(5.W))
    val rd_data = Output(UInt(64.W))
    val rd_en = Output(Bool())
  })

  io.rd_addr := io.lsu_to_wb.dest
  io.rd_data := io.lsu_to_wb.lsu_res
  io.rd_en := io.lsu_to_wb.rf_w
}
