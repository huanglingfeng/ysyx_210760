import chisel3._
import chisel3.util._

class LSR extends Module {
  val io = IO(new Bundle {
    val es_to_ls_valid = Input(Bool())
    val ls_valid = Output(Bool())
    val ls_allowin = Input(Bool())

    val ex_to_lsr = Flipped(new EX_TO_LSU_BUS)
    val lsr_to_ex = (new EX_TO_LSU_BUS)
  })
  
  val judg = io.es_to_ls_valid && io.ls_allowin
  io.ls_valid := RegEnable(io.es_to_ls_valid, io.ls_allowin)
  RegEnable(io.ex_to_lsr, judg) <> io.lsr_to_ex

}
