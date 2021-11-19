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
  io.es_valid := RegEnable(io.ds_to_es_valid,true.B, io.es_allowin)
  // RegEnable(io.id_to_er,0.U, judg) <> io.er_to_ex
  io.er_to_ex.aluop := RegEnable(io.id_to_er.aluop, 0.U ,judg)
  io.er_to_ex.lsuop := RegEnable(io.id_to_er.lsuop, 0.U ,judg)
  io.er_to_ex.rv64op := RegEnable(io.id_to_er.rv64op, 0.U ,judg)
  
  io.er_to_ex.is_csr := RegEnable(io.id_to_er.is_csr, false.B ,judg)
  io.er_to_ex.csr_res := RegEnable(io.id_to_er.csr_res, 0.U ,judg)

  io.er_to_ex.out1 := RegEnable(io.id_to_er.out1, 0.U ,judg)
  io.er_to_ex.out2 := RegEnable(io.id_to_er.out2, 0.U ,judg)

  io.er_to_ex.imm := RegEnable(io.id_to_er.imm, 0.U ,judg)

  io.er_to_ex.dest := RegEnable(io.id_to_er.dest, 0.U ,judg)
  io.er_to_ex.rf_w := RegEnable(io.id_to_er.rf_w, false.B ,judg)
  io.er_to_ex.load := RegEnable(io.id_to_er.load, false.B ,judg)
  io.er_to_ex.save := RegEnable(io.id_to_er.save, false.B ,judg)

}