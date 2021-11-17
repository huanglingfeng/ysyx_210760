import chisel3._
import chisel3.util._

class dr extends Module {
  val io = IO(new Bundle {
    val fs_to_ds_valid = Input(Bool())
    val ds_valid = Output(Bool())
    val ds_allowin = Input(Bool())

    val if_to_dr = Flipped(new IF_TO_ID_BUS)
    val dr_to_id = (new IF_TO_ID_BUS)
  })
  
  val judg = io.fs_to_ds_valid && io.ds_allowin
  io.ds_valid := RegEnable(io.fs_to_ds_valid, io.ds_allowin)
  RegEnable(io.if_to_dr, judg) <> io.dr_to_id

}
