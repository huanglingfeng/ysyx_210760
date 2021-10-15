import chisel3._
import chisel3.util._
import Consts._

class ISU_TO_WB_BUS extends Bundle{
    val isu_res = Output(UInt(64.W))

    val dest = Output(UInt(5.W))
    val rf_w = Output(Bool())
}

class ISU extends Module {
    val io = IO(new Bundle{
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

    val addr = src1 + imm //这个加法器应该能转移到exu

    val wmask =  Mux1H(Seq(
        (save === false.B) -> 0.U(64.W),
        i_sd -> "hFFFF_FFFF_FFFF_FFFF".U(64.W),
        i_sw -> "h0000_0000_FFFF_FFFF".U(64.W),
        i_sh -> "h0000_0000_0000_FFFF".U(64.W),
        i_sb -> "h0000_0000_0000_00FF".U(64.W)
    ))

    io.dmem.en := load || save
    io.dmem.addr := addr
    io.dmem.wen := save
    io.dmem.wdata := src2
    io.dmem.wmask := wmask
    val rdata = io.dmem.rdata

    val ld_res = rdata
    val lw_res = Cat(Fill(32,rdata(31)),rdata(31,0))
    val lwu_res = Cat(0.U(32.W),rdata(31,0))
    val lh_res = Cat(Fill(48,rdata(19)),rdata(19,0))
    val lhu_res = Cat(0.U(48),rdata(19,0))
    val lb_res = Cat(Fill(56,rdata(7)),rdata(7,0))
    val lbu_res = Cat(0.U(56.W),rdata(7,0))

    val load_res = Mux1H(Seq(
        !load -> 0.U(64.W),
        i_ld -> ld_res,
        i_lw -> lw_res,
        i_lwu -> lwu_res,
        i_lh -> lh_res,
        i_lhu -> lhu_res,
        i_lb -> lb_res,
        i_lbu -> lbu_res
    ))

    val isu_res = Mux1H(Seq(
        !(save || load) -> alu_res,
        save -> 0.U,
        load -> load_res
    ))

    io.isu_to_wb.isu_res := isu_res
    io.isu_to_wb.dest := Mux(save,0.U,io.ex_to_isu.dest)
    io.isu_to_wb.rf_w :=  Mux(save,false.B,io.ex_to_isu.rf_w)
}