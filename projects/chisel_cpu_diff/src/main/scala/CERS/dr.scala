import chisel3._
import chisel3.util._
import Instructions._
import Consts._

class DR extends Module {
  val io = IO(new Bundle {
    val fs_to_ds_valid = Input(Bool())
    val ds_valid = Output(Bool())
    val ds_allowin = Input(Bool())

    val if_to_dr = Flipped(new IF_TO_ID_BUS)
    val dr_to_id = (new IF_TO_ID_BUS)
  })
  
  val judg = io.fs_to_ds_valid && io.ds_allowin
  io.ds_valid := RegEnable(io.fs_to_ds_valid,true.B, io.ds_allowin)
  // RegEnable(io.if_to_dr,0.U, judg) <> io.dr_to_id
  io.dr_to_id.is_nop := RegEnable(io.if_to_dr.is_nop,true.B,io.ds_allowin)

  io.dr_to_id.pc := RegEnable(io.if_to_dr.pc,"h8000_0000".U(64.W),judg)
  io.dr_to_id.inst := RegEnable(io.if_to_dr.inst,NOP,io.ds_allowin)
  

}
