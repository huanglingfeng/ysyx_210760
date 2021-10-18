import chisel3._
import chisel3.util._
import Consts._

class ISU_TO_WB_BUS extends Bundle {
  val isu_res = Output(UInt(64.W))

  val dest = Output(UInt(5.W))
  val rf_w = Output(Bool())
}

class ISU extends Module {
  val io = IO(new Bundle {
    val ex_to_isu = Flipped(new EX_TO_ISU_BUS)
    val isu_to_wb = new ISU_TO_WB_BUS

    val dmem = new RamIO
  })

  val alu_res = io.ex_to_isu.alu_res
  val src1 = io.ex_to_isu.src1
  val src2 = io.ex_to_isu.src2
  val imm = io.ex_to_isu.imm
  val lsuop = io.ex_to_isu.lsuop
  val rv64op = io.ex_to_isu.rv64op
  val load = io.ex_to_isu.load
  val save = io.ex_to_isu.save

  val i_lb = lsuop(0)
  val i_lh = lsuop(1)
  val i_lw = lsuop(2)
  val i_lbu = lsuop(3)
  val i_lhu = lsuop(4)
  val i_sb = lsuop(5)
  val i_sh = lsuop(6)
  val i_sw = lsuop(7)

  val i_lwu = rv64op(9)
  val i_ld = rv64op(10)
  val i_sd = rv64op(11)

  val addr_real = Mux(
    (load || save),
    src1 + imm,
    "h0000_0000_8000_0000".U(64.W)
  ) //这个加法器应该能转移到exu

  val sel_b=addr_real(0)
  val sel_h=addr_real(1)
  val sel_w=addr_real(2)

  val wmask = Mux1H(
    Seq(
      (save === false.B) -> 0.U(64.W),
      i_sd -> "hFFFF_FFFF_FFFF_FFFF".U(64.W),
      
      (i_sw && !sel_w) -> "h0000_0000_FFFF_FFFF".U(64.W),
      (i_sw &&  sel_w) -> "hFFFF_FFFF_0000_0000".U(64.W),

      (i_sh && (!sel_w && !sel_h)) -> "h0000_0000_0000_FFFF".U(64.W),
      (i_sh && (!sel_w &&  sel_h)) -> "h0000_0000_FFFF_0000".U(64.W),
      (i_sh && ( sel_w && !sel_h)) -> "h0000_FFFF_0000_0000".U(64.W),
      (i_sh && ( sel_w &&  sel_h)) -> "hFFFF_0000_0000_0000".U(64.W),

      (i_sb && (!sel_w && !sel_h && !sel_b)) -> "h0000_0000_0000_00FF".U(64.W),
      (i_sb && (!sel_w && !sel_h &&  sel_b)) -> "h0000_0000_0000_FF00".U(64.W),
      (i_sb && (!sel_w &&  sel_h && !sel_b)) -> "h0000_0000_00FF_0000".U(64.W),
      (i_sb && (!sel_w &&  sel_h &&  sel_b)) -> "h0000_0000_FF00_0000".U(64.W),
      (i_sb && ( sel_w && !sel_h && !sel_b)) -> "h0000_00FF_0000_0000".U(64.W),
      (i_sb && ( sel_w && !sel_h &&  sel_b)) -> "h0000_FF00_0000_0000".U(64.W),
      (i_sb && ( sel_w &&  sel_h && !sel_b)) -> "h00FF_0000_0000_0000".U(64.W),
      (i_sb && ( sel_w &&  sel_h &&  sel_b)) -> "hFF00_0000_0000_0000".U(64.W)

    )
  )

  io.dmem.en := load || save
  io.dmem.addr := Cat(addr_real(63,3),0.U(3.W))
  io.dmem.wen := save
  io.dmem.wdata := src2
  io.dmem.wmask := wmask
  val mdata = io.dmem.rdata
  val rdata = Mux1H(
    Seq(
      (load === false.B) -> 0.U(64.W),
      i_ld -> mdata,
      
      ((i_lw || i_lwu) && !sel_w) -> Cat(0.U(32.W),mdata(31, 0)),
      ((i_lw || i_lwu) &&  sel_w) -> Cat(0.U(32.W),mdata(63,32)),

      ((i_lh || i_lhu) && (!sel_w && !sel_h)) -> Cat(0.U(48.W),mdata(15, 0)),
      ((i_lh || i_lhu) && (!sel_w &&  sel_h)) -> Cat(0.U(48.W),mdata(31,16)),
      ((i_lh || i_lhu) && ( sel_w && !sel_h)) -> Cat(0.U(48.W),mdata(47,32)),
      ((i_lh || i_lhu) && ( sel_w &&  sel_h)) -> Cat(0.U(48.W),mdata(63,48)),

      ((i_lb|| i_lbu) && (!sel_w && !sel_h && !sel_b)) -> Cat(0.U(56.W),mdata( 7, 0)),
      ((i_lb|| i_lbu) && (!sel_w && !sel_h &&  sel_b)) -> Cat(0.U(56.W),mdata(15, 8)),
      ((i_lb|| i_lbu) && (!sel_w &&  sel_h && !sel_b)) -> Cat(0.U(56.W),mdata(23,16)),
      ((i_lb|| i_lbu) && (!sel_w &&  sel_h &&  sel_b)) -> Cat(0.U(56.W),mdata(31,24)),
      ((i_lb|| i_lbu) && ( sel_w && !sel_h && !sel_b)) -> Cat(0.U(56.W),mdata(39,32)),
      ((i_lb|| i_lbu) && ( sel_w && !sel_h &&  sel_b)) -> Cat(0.U(56.W),mdata(47,40)),
      ((i_lb|| i_lbu) && ( sel_w &&  sel_h && !sel_b)) -> Cat(0.U(56.W),mdata(55,48)),
      ((i_lb|| i_lbu) && ( sel_w &&  sel_h &&  sel_b)) -> Cat(0.U(56.W),mdata(63,56))
    )
  )

  val ld_res = rdata
  val lw_res = Cat(Fill(32, rdata(31)), rdata(31, 0))
  val lwu_res = Cat(0.U(32.W), rdata(31, 0))
  val lh_res = Cat(Fill(48, rdata(15)), rdata(15, 0))
  val lhu_res = Cat(0.U(48), rdata(15, 0))
  val lb_res = Cat(Fill(56, rdata(7)), rdata(7, 0))
  val lbu_res = Cat(0.U(56.W), rdata(7, 0))

  val load_res = Mux1H(
    Seq(
      !load -> 0.U(64.W),
      i_ld -> ld_res,
      i_lw -> lw_res,
      i_lwu -> lwu_res,
      i_lh -> lh_res,
      i_lhu -> lhu_res,
      i_lb -> lb_res,
      i_lbu -> lbu_res
    )
  )

  val isu_res = Mux1H(
    Seq(
      !(save || load) -> alu_res,
      save -> 0.U,
      load -> load_res
    )
  )

  io.isu_to_wb.isu_res := isu_res
  io.isu_to_wb.dest := Mux(save, 0.U, io.ex_to_isu.dest)
  io.isu_to_wb.rf_w := Mux(save, false.B, io.ex_to_isu.rf_w)
}
