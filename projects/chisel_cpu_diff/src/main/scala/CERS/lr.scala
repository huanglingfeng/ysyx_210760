import chisel3._
import chisel3.util._
import Instructions._
import Consts._

class LR extends Module {
  val io = IO(new Bundle {
    val es_to_ls_valid = Input(Bool())
    val ls_valid = Output(Bool())
    val ls_allowin = Input(Bool())

    val ex_to_lr = Flipped(new EX_TO_LSU_BUS)
    val lr_to_lsu = (new EX_TO_LSU_BUS)
  })
  
  val judg = io.es_to_ls_valid && io.ls_allowin
  io.ls_valid := RegEnable(io.es_to_ls_valid,true.B, io.ls_allowin)
  // RegEnable(io.ex_to_lr,0.U, judg) <> io.lr_to_lsu
  io.lr_to_lsu.is_nop := RegEnable(io.ex_to_lr.is_nop, false.B ,io.ls_allowin)
  
  io.lr_to_lsu.is_csr := RegEnable(io.ex_to_lr.is_csr, false.B ,judg)

  io.lr_to_lsu.alu_res := RegEnable(io.ex_to_lr.alu_res, 0.U ,judg)

  io.lr_to_lsu.src1 := RegEnable(io.ex_to_lr.src1, 0.U ,judg)
  io.lr_to_lsu.src2 := RegEnable(io.ex_to_lr.src2, 0.U ,judg)
  io.lr_to_lsu.imm := RegEnable(io.ex_to_lr.imm, 0.U ,judg)

  io.lr_to_lsu.lsuop := RegEnable(io.ex_to_lr.lsuop, 0.U ,judg)
  io.lr_to_lsu.rv64op := RegEnable(io.ex_to_lr.rv64op, 0.U ,judg)
  io.lr_to_lsu.dest := RegEnable(io.ex_to_lr.dest, 0.U ,judg)
  io.lr_to_lsu.rf_w := RegEnable(io.ex_to_lr.rf_w, false.B ,judg)
  io.lr_to_lsu.load := RegEnable(io.ex_to_lr.load, false.B ,judg)
  io.lr_to_lsu.save := RegEnable(io.ex_to_lr.save, false.B ,judg)

  io.lr_to_lsu.pc := RegEnable(io.ex_to_lr.pc, 0.U , io.ls_allowin)
  io.lr_to_lsu.inst := RegEnable(io.ex_to_lr.inst, 0.U ,io.ls_allowin)

  io.lr_to_lsu.csrop := RegEnable(io.ex_to_lr.csrop, 0.U ,judg)
  io.lr_to_lsu.csr_addr := RegEnable(io.ex_to_lr.csr_addr, 0.U ,judg)
  io.lr_to_lsu.csr_src := RegEnable(io.ex_to_lr.csr_src, 0.U ,judg)
  io.lr_to_lsu.is_zero := RegEnable(io.ex_to_lr.is_zero, false.B ,judg)
}
