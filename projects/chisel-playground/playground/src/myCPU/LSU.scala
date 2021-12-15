import chisel3._
import chisel3.util._
import Consts._

class LSU extends Module {
  val io = IO(new Bundle {
    val ws_allowin = Input(Bool())
    val ls_valid = Input(Bool())
    val ls_allowin = Output(Bool())
    val ls_to_ws_valid = Output(Bool())

    val ex_to_lsu = Flipped(new EX_TO_LSU_BUS)
    val lsu_to_wb = new LSU_TO_WB_BUS
    
    val lsu_to_csr = new LSU_TO_CSR_BUS

    val lsu_fwd = new LSU_TO_ID_BUS

    val dsram = new SRAM_BUS

    val flush = Input(Bool())

    val addr_valid = Output(Bool())
    
  })
  val load = Wire(Bool())
  val save = Wire(Bool())
  val is_clint = Wire(Bool())
  
  //------------流水线控制逻辑------------------------------//
  val addr_valid = RegInit(false.B)
  val addr_can_send = RegInit(false.B)
  io.dsram.addr_can_send := addr_can_send
  val addr_hs = io.dsram.addr_ok && addr_can_send

  val ls_valid = io.ls_valid
  val memory_fetch = (load || save) && !is_clint
  io.dsram.addr_valid := addr_valid
  io.dsram.addr_can_send := true.B

  val ls_ready_go = io.dsram.data_ok || !memory_fetch
  val ls_allowin = Wire(Bool())
  val ls_to_ws_valid = Wire(Bool())

  ls_allowin := !ls_valid || (ls_ready_go && io.ws_allowin)
  ls_to_ws_valid := ls_valid && ls_ready_go

  io.ls_allowin := ls_allowin
  io.ls_to_ws_valid := ls_to_ws_valid

  io.dsram.using := ls_to_ws_valid && io.ws_allowin
  
  io.addr_valid := addr_valid
  //-------------------------------------------------------//

  when(addr_hs){
    addr_can_send := false.B
  }
  when(addr_valid && io.dsram.using){
    addr_valid := false.B
  }
  when(memory_fetch && !addr_valid){
    addr_can_send := true.B
    addr_valid := true.B
  }

  val pc = io.ex_to_lsu.pc
  val inst = Mux(io.flush,NOP,io.ex_to_lsu.inst)

  val alu_res = io.ex_to_lsu.alu_res
  val src1 = io.ex_to_lsu.src1
  val src2 = io.ex_to_lsu.src2
  val imm = io.ex_to_lsu.imm
  val lsuop = io.ex_to_lsu.lsuop
  val rv64op = io.ex_to_lsu.rv64op
  load := Mux(ls_valid && (inst =/= NOP),io.ex_to_lsu.load,false.B)
  save := Mux(ls_valid && (inst =/= NOP),io.ex_to_lsu.save,false.B)

  val i_lb = lsuop(0)
  val i_lh = lsuop(1)
  val i_lw = lsuop(2)
  val i_lbu = lsuop(3)
  val i_lhu = lsuop(4)
  val i_sb = lsuop(5)
  val i_sh = lsuop(6)
  val i_sw = lsuop(7)

  val i_lwu = (rv64op === RV64_LWU)
  val i_ld  = (rv64op === RV64_LD)
  val i_sd  = (rv64op === RV64_SD)

  val addr_real = Mux(
    (load || save),
    (src1 + imm)(31,0),
    "h0000_0000_8000_0000".U(32.W)
  ) //这个加法器应该能转移到exu

  val sel_b=addr_real(0)
  val sel_h=addr_real(1)
  val sel_w=addr_real(2)

  // val wstrb = Mux1H(
  //   Seq(
  //     (save === false.B) -> 0.U(8.W),
  //     i_sd -> "b11111111".U(8.W),
  //     i_sw -> "b00001111".U(8.W),
  //     i_sh -> "b00000011".U(8.W),
  //     i_sb -> "b00000001".U(8.W)
  // ))
  val dram_size = Mux1H(
    Seq(
      !(memory_fetch) -> 0.U,
      (i_lb || i_sb || i_lbu) -> SIZE_B,
      (i_lh || i_sh || i_lhu) -> SIZE_H,
      (i_lw || i_sw || i_lwu) -> SIZE_W,
      (i_ld || i_sd)          -> SIZE_D
    )
  )

  val wstrb = Mux1H(
    Seq(
      (save === false.B) -> 0.U(8.W),
      i_sd -> "b11111111".U(8.W),
      
      (i_sw && !sel_w) -> "b00001111".U(8.W),
      (i_sw &&  sel_w) -> "b11110000".U(8.W),

      (i_sh && (!sel_w && !sel_h)) -> "b00000011".U(8.W),
      (i_sh && (!sel_w &&  sel_h)) -> "b00001100".U(8.W),
      (i_sh && ( sel_w && !sel_h)) -> "b00110000".U(8.W),
      (i_sh && ( sel_w &&  sel_h)) -> "b11000000".U(8.W),

      (i_sb && (!sel_w && !sel_h && !sel_b)) -> "b00000001".U(8.W),
      (i_sb && (!sel_w && !sel_h &&  sel_b)) -> "b00000010".U(8.W),
      (i_sb && (!sel_w &&  sel_h && !sel_b)) -> "b00000100".U(8.W),
      (i_sb && (!sel_w &&  sel_h &&  sel_b)) -> "b00001000".U(8.W),
      (i_sb && ( sel_w && !sel_h && !sel_b)) -> "b00010000".U(8.W),
      (i_sb && ( sel_w && !sel_h &&  sel_b)) -> "b00100000".U(8.W),
      (i_sb && ( sel_w &&  sel_h && !sel_b)) -> "b01000000".U(8.W),
      (i_sb && ( sel_w &&  sel_h &&  sel_b)) -> "b10000000".U(8.W)
    )
  )

  val sdata = Mux1H(
    Seq(
      (save === false.B) -> 0.U(64.W),
      i_sd -> src2,
      i_sw -> Cat(Fill(2,src2(31,0))),
      i_sh -> Cat(Fill(4,src2(15,0))),
      i_sb -> Cat(Fill(8,src2( 7,0)))
    )
  )

  val is_mtime = (addr_real === "h0200_bff8".U(32.W))
  val is_mtimecmp = (addr_real === "h0200_4000".U(32.W))
  is_clint := is_mtime || is_mtimecmp  //在0x200_0000 ~ 0x200_ffff的其他地址依然会访问ram
  val clint_wdata = src2
  val clint_rdata = io.lsu_to_csr.rdata

  io.dsram.wr := save
  io.dsram.size := dram_size
  io.dsram.addr := addr_real
  io.dsram.wstrb := wstrb
  io.dsram.wdata := sdata

  val mdata = io.dsram.rdata

  // val rdata = Mux1H(
  //   Seq(
  //     (load === false.B) -> 0.U(64.W),
  //     i_ld -> mdata,
  //     (i_lw || i_lwu) -> Cat(0.U(32.W),mdata(31, 0)),
  //     (i_lh || i_lhu) -> Cat(0.U(48.W),mdata(15, 0)),
  //     (i_lb || i_lbu) -> Cat(0.U(56.W),mdata( 7, 0))
  //   )
  // )
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

  val lsu_res = Mux1H(
    Seq(
      !(save || load) -> alu_res,
      save -> 0.U,
      load -> load_res
    )
  )

  val lsu_res_final = Mux(is_clint,clint_rdata,lsu_res)
  io.lsu_to_wb.lsu_res := lsu_res_final

  val dest = Mux(save, 0.U, io.ex_to_lsu.dest)
  io.lsu_to_wb.dest := dest
  val rf_w = Mux(save, false.B, io.ex_to_lsu.rf_w)
  io.lsu_to_wb.rf_w := rf_w

  val is_csr = io.ex_to_lsu.is_csr
  io.lsu_fwd.rf_w := Mux(!ls_valid,false.B,rf_w)
  io.lsu_fwd.dst := dest
  io.lsu_fwd.lsu_res := lsu_res_final
  io.lsu_fwd.is_csr := Mux(!ls_valid,false.B,is_csr)
  io.lsu_fwd.ds_stall := ~ls_ready_go

  //--------------lsu <> clint----------------------------//
  io.lsu_to_csr.is_clint := is_clint
  io.lsu_to_csr.is_mtime := is_mtime
  io.lsu_to_csr.is_mtimecmp := is_mtimecmp
  io.lsu_to_csr.load := load
  io.lsu_to_csr.save := save
  io.lsu_to_csr.wdata := clint_wdata

  io.lsu_to_wb.pc := pc
  io.lsu_to_wb.inst := Mux(io.flush || !ls_to_ws_valid,NOP,inst)

  io.lsu_to_wb.is_csr := is_csr
  io.lsu_to_wb.csrop := io.ex_to_lsu.csrop
  io.lsu_to_wb.csr_addr := io.ex_to_lsu.csr_addr
  io.lsu_to_wb.csr_src := io.ex_to_lsu.csr_src
  io.lsu_to_wb.is_zero := io.ex_to_lsu.is_zero

  io.lsu_to_wb.is_nop := Mux(io.flush || !ls_to_ws_valid ,true.B,io.ex_to_lsu.is_nop)
}