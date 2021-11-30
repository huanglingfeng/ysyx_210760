import chisel3._
import chisel3.util._
import difftest._
import Consts._

class SimTop extends Module {
  val io = IO(new Bundle {
    val logCtrl = new LogCtrlIO
    val perfInfo = new PerfInfoIO
    val uart = new UARTIO

    val memAXI_0 = new AXI_BUS_TOP
  })

  val core = Module(new Core)

  val u_axi_rw = new AXI_RW
  //--------write address--------------------------//
  u_axi_rw.io.axi.ready := io.memAXI_0.aw.ready
  io.memAXI_0.aw.valid := u_axi_rw.io.axi.valid
  io.memAXI_0.aw.bits_addr := u_axi_rw.io.axi.aw.addr
  io.memAXI_0.aw.bits_prot := u_axi_rw.io.axi.aw.prot      
  io.memAXI_0.aw.bits_id := u_axi_rw.io.axi.aw.id
  io.memAXI_0.aw.bits_user := u_axi_rw.io.axi.aw.user      
  io.memAXI_0.aw.bits_len := u_axi_rw.io.axi.aw.len        
  io.memAXI_0.aw.bits_size := u_axi_rw.io.axi.aw.size      
  io.memAXI_0.aw.bits_burst := u_axi_rw.io.axi.aw.burst    
  io.memAXI_0.aw.bits_lock := u_axi_rw.io.axi.aw.lock      
  io.memAXI_0.aw.bits_cache := u_axi_rw.io.axi.aw.cache
  io.memAXI_0.aw.bits_qos := u_axi_rw.io.axi.aw.qos  

  //-------------write data-----------------------//
  u_axi_rw.io.axi.w.ready := io.memAXI_0.w.ready
  io.memAXI_0.w.valid := u_axi_rw.io.axi.w.valid
  io.memAXI_0.w.bits_data := u_axi_rw.io.axi.w.data
  io.memAXI_0.w.bits_strb := u_axi_rw.io.axi.w.strb        
  io.memAXI_0.w.bits_last := u_axi_rw.io.axi.w.last 

  //-------------write response--------------------//
  io.memAXI_0.b.ready := u_axi_rw.io.axi.b.ready
  u_axi_rw.io.axi.b.valid := io.memAXI_0.b.valid
  u_axi_rw.io.axi.b.resp := io.memAXI_0.b.bits_resp
  u_axi_rw.io.axi.b.id := io.memAXI_0.b.bits_id
  u_axi_rw.io.axi.b.user := io.memAXI_0.b.bits_user

  //-------------read address-----------------------//
  u_axi_rw.io.axi.ar.ready := io.memAXI_0.ar.ready
  io.memAXI_0.ar.valid := u_axi_rw.io.axi.ar.valid
  io.memAXI_0.ar.bits_addr := u_axi_rw.io.axi.ar.addr  
  io.memAXI_0.ar.bits_prot := u_axi_rw.io.axi.ar.prot  
  io.memAXI_0.ar.bits_id := u_axi_rw.io.axi.ar.id      
  io.memAXI_0.ar.bits_user := u_axi_rw.io.axi.ar.user  
  io.memAXI_0.ar.bits_len := u_axi_rw.io.axi.ar.len    
  io.memAXI_0.ar.bits_size := u_axi_rw.io.axi.ar.size  
  io.memAXI_0.ar.bits_burst := u_axi_rw.io.axi.ar.burst
  io.memAXI_0.ar.bits_lock := u_axi_rw.io.axi.ar.lock  
  io.memAXI_0.ar.bits_cache := u_axi_rw.io.axi.ar.cache
  io.memAXI_0.ar.bits_qos := u_axi_rw.io.axi.ar.qos    

  //----------------read data-------------------------//
  io.memAXI_0.r.ready := u_axi_rw.io.axi.r.ready
  u_axi_rw.io.axi.r.valid := io.memAXI_0.r.bits_valid
  u_axi_rw.io.axi.r.resp := io.memAXI_0.r.bits_resp
  u_axi_rw.io.axi.r.data := io.memAXI_0.r.bits_data
  u_axi_rw.io.axi.r.last := io.memAXI_0.r.bits_last
  u_axi_rw.io.axi.r.id := io.memAXI_0.r.bits_id
  u_axi_rw.io.axi.r.user := io.memAXI_0.r.bits_user

  // val mem = Module(new Ram2r1w)
  // mem.io.imem <> core.io.imem
  // mem.io.dmem <> core.io.dmem

  io.uart.out.valid := false.B
  io.uart.out.ch := 0.U
  io.uart.in.valid := false.B

}
