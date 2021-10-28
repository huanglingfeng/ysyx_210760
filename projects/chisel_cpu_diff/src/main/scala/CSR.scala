import chisel3._
import chisel3.util._
import Consts._

class CSR extends Module{
    val io = IO(new Bundle{
        val id_to_csr = Flipped(new ID_TO_CSR_BUS)

        val mcycle = Output(UInt(64.W))
        val mepc = Output(UInt(64.W))
        val mcause = Output(UInt(64.W))
        val mtevc = Output(UInt(64.W))
        val mstatus = Output(UInt(64.W))
        val mie = Output(UInt(64.W))
        val mip = Output(UInt(64.W))
    })
    val csrop = io.id_to_csr.csrop
    val csr_addr = io.id_to_csr.csr_addr
    val src1 = io.id_to_csr.src1
    val is_zero = io.id_to_csr.is_zero

    val csr_res = WireInit(UInt(64.W),0.U)

    val mcycle = RegInit(UInt(64.W),0.U)
    when(true.B){
        mcycle := mcycle + 1.U
    }
    val mepc = Reg(UInt(64.W))
    val mcause = RegInit(UInt(64.W), 0.U)
    val mtevc = RegInit(UInt(64.W), 0.U)
    val mstatus = RegInit(UInt(64.W), "h00001800".U)

    val mie = RegInit(0.U(64.W))
    val mip = RegInit(0.U(64.W))

    val csr_data_o = Mux1H(Seq(
        (csr_addr === 0.U) -> 0.U,
        (csr_addr === MCYCLE_N)  -> mcycle,
        (csr_addr === MEPC_N)    -> mepc,
        (csr_addr === MCAUSE_N)  -> mcause,
        (csr_addr === MTEVC_N)   -> mtevc,
        (csr_addr === MSTATUS_N) -> mstatus,
        (csr_addr === MIP_N)     -> mip,
        (csr_addr === MIE_N)     -> mie
    ))
    val csr_res_i = io.id_to_csr.csr_res
    val csr_data_i = WireInit(0.U(64.W))
    val csr_mask = WireInit(0.U(64.W))  //屏蔽信号，0屏蔽
    val is_rw = (csrop === CSR_RW || csrop === CSR_RWI)
    val is_rs = (csrop === CSR_RS || csrop === CSR_RSI)
    val is_rc = (csrop === CSR_RC || csrop === CSR_RCI)
    
    when(is_rw){
        csr_res := csr_data_o
        csr_data_i := csr_res_i
        csr_mask := Mux(is_zero,0.U,"hffff_ffff_ffff_ffff".U(64.W))
    }.elsewhen(is_rs){
        csr_res := csr_data_o
        csr_data_i := csr_res_i
        csr_mask := Mux(is_zero,0.U,csr_res_i)
    }.elsewhen(is_rc){
        csr_res := csr_data_o
        csr_data_i := ~csr_res_i
        csr_mask := Mux(is_zero,0.U,csr_res_i)
    }

    when(csr_addr === MCYCLE_N){
        mcycle := mcycle | (csr_data_i | csr_mask)
    }.elsewhen(csr_addr === MEPC_N){
        mepc := mepc | (csr_data_i | csr_mask)
    }.elsewhen(csr_addr === MCAUSE_N){
        mcause := mcause | (csr_data_i | csr_mask)
    }.elsewhen(csr_addr === MTEVC_N){
        mtevc := mtevc | (csr_data_i | csr_mask)
    }.elsewhen(csr_addr === MSTATUS_N){
        mstatus := mstatus | (csr_data_i | csr_mask)
    }.elsewhen(csr_addr === MIP_N){
        mip := mip | (csr_data_i | csr_mask)
    }.elsewhen(csr_addr === MIE_N){
        mie := mie | (csr_data_i | csr_mask)
    }

    io.id_to_csr.csr_res := csr_res

    io.mcycle := mcycle
    io.mepc := mepc
    io.mcause := mcause
    io.mtevc := mtevc 
    io.mstatus := mstatus
    io.mip := mip 
    io.mie := mie
}