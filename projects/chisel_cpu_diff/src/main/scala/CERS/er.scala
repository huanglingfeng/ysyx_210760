import chisel3._
import chisel3.util._

class ER extends Module {
  val io = IO(new Bundle {
    val ds_to_es_valid = Input(Bool())
    val es_valid = Output(Bool())
    val es_allowin = Input(Bool())

    val id_to_er = Flipped(new ID_TO_EX_BUS)
    val er_to_ex = (new ID_TO_EX_BUS)
  })
  
  val judg = io.ds_to_es_valid && io.es_allowin
  io.es_valid := RegEnable(io.ds_to_es_valid, io.es_allowin)
  RegEnable(io.id_to_er, judg) <> io.er_to_ex

}
