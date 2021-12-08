module InstFetch(
  input         clock,
  input         reset,
  input         io_ds_allowin,
  output        io_fs_to_ds_valid,
  output [63:0] io_isram_addr,
  output        io_isram_addr_valid,
  output        io_isram_addr_can_send,
  input         io_isram_addr_ok,
  input         io_isram_data_ok,
  output        io_isram_using,
  input  [63:0] io_isram_rdata,
  output        io_if_to_id_is_nop,
  output [63:0] io_if_to_id_pc,
  output [31:0] io_if_to_id_inst,
  input  [63:0] io_id_to_if_pc_target,
  input         io_id_to_if_jump,
  output        io_br_stall
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [63:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg  addr_valid; // @[InstFetch.scala 22:27]
  wire  to_fs_valid = ~reset; // @[InstFetch.scala 23:21]
  reg  fs_valid; // @[Reg.scala 27:20]
  wire  fs_allowin = ~fs_valid | io_isram_data_ok & io_ds_allowin; // @[InstFetch.scala 34:27]
  wire  fs_to_ds_valid = fs_valid & io_isram_data_ok; // @[InstFetch.scala 35:30]
  reg  addr_can_send; // @[InstFetch.scala 38:30]
  wire  pc_can_change = to_fs_valid & fs_allowin; // @[InstFetch.scala 41:35]
  wire  addr_hs = io_isram_addr_ok & addr_can_send; // @[InstFetch.scala 42:34]
  reg  pc_en; // @[InstFetch.scala 47:22]
  reg [63:0] pc; // @[InstFetch.scala 50:19]
  wire [63:0] _nextpc_T_1 = pc + 64'h4; // @[InstFetch.scala 52:53]
  wire  _GEN_2 = addr_hs ? 1'h0 : addr_can_send; // @[InstFetch.scala 53:16 InstFetch.scala 54:19 InstFetch.scala 38:30]
  wire  _GEN_3 = addr_valid & io_isram_using ? 1'h0 : addr_valid; // @[InstFetch.scala 56:37 InstFetch.scala 57:16 InstFetch.scala 22:27]
  wire  _GEN_5 = pc_can_change | _GEN_2; // @[InstFetch.scala 59:23 InstFetch.scala 61:19]
  wire  _GEN_6 = pc_can_change | _GEN_3; // @[InstFetch.scala 59:23 InstFetch.scala 62:16]
  wire  pc_is_wrong = pc != io_id_to_if_pc_target & io_id_to_if_jump; // @[InstFetch.scala 74:52]
  wire [31:0] isram_data = io_isram_data_ok ? io_isram_rdata[31:0] : 32'h0; // @[InstFetch.scala 77:23]
  wire  _io_if_to_id_is_nop_T = pc_en & pc_is_wrong; // @[InstFetch.scala 79:32]
  wire  _io_if_to_id_is_nop_T_1 = ~fs_to_ds_valid; // @[InstFetch.scala 79:51]
  wire  _io_if_to_id_inst_T_4 = pc_en & ~pc_is_wrong; // @[InstFetch.scala 86:14]
  wire [63:0] _io_if_to_id_inst_T_6 = _io_if_to_id_is_nop_T ? 64'h13 : 64'h0; // @[Mux.scala 27:72]
  wire [31:0] _io_if_to_id_inst_T_7 = _io_if_to_id_inst_T_4 ? isram_data : 32'h0; // @[Mux.scala 27:72]
  wire [63:0] _GEN_7 = {{32'd0}, _io_if_to_id_inst_T_7}; // @[Mux.scala 27:72]
  wire [63:0] _io_if_to_id_inst_T_9 = _io_if_to_id_inst_T_6 | _GEN_7; // @[Mux.scala 27:72]
  wire [63:0] _io_if_to_id_inst_T_10 = _io_if_to_id_is_nop_T_1 ? 64'h13 : _io_if_to_id_inst_T_9; // @[InstFetch.scala 81:26]
  assign io_fs_to_ds_valid = fs_valid & io_isram_data_ok; // @[InstFetch.scala 35:30]
  assign io_isram_addr = pc; // @[InstFetch.scala 66:17]
  assign io_isram_addr_valid = addr_valid; // @[InstFetch.scala 70:23]
  assign io_isram_addr_can_send = addr_can_send; // @[InstFetch.scala 39:26]
  assign io_isram_using = fs_to_ds_valid & io_ds_allowin; // @[InstFetch.scala 43:36]
  assign io_if_to_id_is_nop = pc_en & pc_is_wrong | ~fs_to_ds_valid; // @[InstFetch.scala 79:48]
  assign io_if_to_id_pc = pc_en ? pc : 64'h0; // @[InstFetch.scala 72:24]
  assign io_if_to_id_inst = _io_if_to_id_inst_T_10[31:0]; // @[InstFetch.scala 81:20]
  assign io_br_stall = io_id_to_if_jump & ~io_isram_data_ok; // @[InstFetch.scala 45:23]
  always @(posedge clock) begin
    if (reset) begin // @[InstFetch.scala 22:27]
      addr_valid <= 1'h0; // @[InstFetch.scala 22:27]
    end else begin
      addr_valid <= _GEN_6;
    end
    if (reset) begin // @[Reg.scala 27:20]
      fs_valid <= 1'h0; // @[Reg.scala 27:20]
    end else if (~addr_valid & ~fs_allowin) begin // @[InstFetch.scala 29:35]
      fs_valid <= 1'h0; // @[InstFetch.scala 30:14]
    end else if (fs_allowin) begin // @[Reg.scala 28:19]
      fs_valid <= to_fs_valid; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[InstFetch.scala 38:30]
      addr_can_send <= 1'h0; // @[InstFetch.scala 38:30]
    end else begin
      addr_can_send <= _GEN_5;
    end
    if (reset) begin // @[InstFetch.scala 47:22]
      pc_en <= 1'h0; // @[InstFetch.scala 47:22]
    end else begin
      pc_en <= 1'h1; // @[InstFetch.scala 48:9]
    end
    if (reset) begin // @[InstFetch.scala 50:19]
      pc <= 64'h7ffffffc; // @[InstFetch.scala 50:19]
    end else if (pc_can_change) begin // @[InstFetch.scala 59:23]
      if (io_id_to_if_jump) begin // @[InstFetch.scala 52:19]
        pc <= io_id_to_if_pc_target;
      end else begin
        pc <= _nextpc_T_1;
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  addr_valid = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  fs_valid = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  addr_can_send = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  pc_en = _RAND_3[0:0];
  _RAND_4 = {2{`RANDOM}};
  pc = _RAND_4[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module DR(
  input         clock,
  input         reset,
  input         io_fs_to_ds_valid,
  output        io_ds_valid,
  input         io_ds_allowin,
  input         io_if_to_dr_is_nop,
  input  [63:0] io_if_to_dr_pc,
  input  [31:0] io_if_to_dr_inst,
  output        io_dr_to_id_is_nop,
  output [63:0] io_dr_to_id_pc,
  output [31:0] io_dr_to_id_inst
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [63:0] _RAND_2;
  reg [63:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg  io_ds_valid_r; // @[Reg.scala 27:20]
  wire  _GEN_0 = io_ds_allowin ? io_fs_to_ds_valid : io_ds_valid_r; // @[Reg.scala 28:19 Reg.scala 28:23 Reg.scala 27:20]
  reg  io_dr_to_id_is_nop_r; // @[Reg.scala 27:20]
  wire  _GEN_1 = io_ds_allowin ? io_if_to_dr_is_nop : io_dr_to_id_is_nop_r; // @[Reg.scala 28:19 Reg.scala 28:23 Reg.scala 27:20]
  reg [63:0] io_dr_to_id_pc_r; // @[Reg.scala 27:20]
  reg [63:0] io_dr_to_id_inst_r; // @[Reg.scala 27:20]
  assign io_ds_valid = io_ds_valid_r; // @[dr.scala 17:15]
  assign io_dr_to_id_is_nop = io_dr_to_id_is_nop_r; // @[dr.scala 19:22]
  assign io_dr_to_id_pc = io_dr_to_id_pc_r; // @[dr.scala 21:18]
  assign io_dr_to_id_inst = io_dr_to_id_inst_r[31:0]; // @[dr.scala 22:20]
  always @(posedge clock) begin
    io_ds_valid_r <= reset | _GEN_0; // @[Reg.scala 27:20 Reg.scala 27:20]
    io_dr_to_id_is_nop_r <= reset | _GEN_1; // @[Reg.scala 27:20 Reg.scala 27:20]
    if (reset) begin // @[Reg.scala 27:20]
      io_dr_to_id_pc_r <= 64'h80000000; // @[Reg.scala 27:20]
    end else if (io_ds_allowin) begin // @[Reg.scala 28:19]
      io_dr_to_id_pc_r <= io_if_to_dr_pc; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_dr_to_id_inst_r <= 64'h13; // @[Reg.scala 27:20]
    end else if (io_ds_allowin) begin // @[Reg.scala 28:19]
      io_dr_to_id_inst_r <= {{32'd0}, io_if_to_dr_inst}; // @[Reg.scala 28:23]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  io_ds_valid_r = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  io_dr_to_id_is_nop_r = _RAND_1[0:0];
  _RAND_2 = {2{`RANDOM}};
  io_dr_to_id_pc_r = _RAND_2[63:0];
  _RAND_3 = {2{`RANDOM}};
  io_dr_to_id_inst_r = _RAND_3[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Decode(
  input         clock,
  input         reset,
  input         io_es_allowin,
  input         io_ds_valid,
  output        io_ds_allowin,
  output        io_ds_to_es_valid,
  input         io_if_to_id_is_nop,
  input  [63:0] io_if_to_id_pc,
  input  [31:0] io_if_to_id_inst,
  output        io_id_to_ex_is_nop,
  output [10:0] io_id_to_ex_aluop,
  output [7:0]  io_id_to_ex_lsuop,
  output [11:0] io_id_to_ex_rv64op,
  output [63:0] io_id_to_ex_out1,
  output [63:0] io_id_to_ex_out2,
  output [63:0] io_id_to_ex_imm,
  output [4:0]  io_id_to_ex_dest,
  output        io_id_to_ex_rf_w,
  output        io_id_to_ex_load,
  output        io_id_to_ex_save,
  output [63:0] io_id_to_ex_pc,
  output [31:0] io_id_to_ex_inst,
  output        io_id_to_ex_is_csr,
  output [7:0]  io_id_to_ex_csrop,
  output [11:0] io_id_to_ex_csr_addr,
  output [63:0] io_id_to_ex_csr_src,
  output        io_id_to_ex_is_zero,
  output [63:0] io_id_to_if_pc_target,
  output        io_id_to_if_jump,
  input         io_csr_to_id_csr_jump,
  input  [63:0] io_csr_to_id_csr_target,
  output [4:0]  io_rs1_addr,
  input  [63:0] io_rs1_data,
  output [4:0]  io_rs2_addr,
  input  [63:0] io_rs2_data,
  input         io_fwd_ex_rf_w,
  input  [4:0]  io_fwd_ex_dst,
  input  [63:0] io_fwd_ex_alu_res,
  input         io_fwd_ex_is_csr,
  input         io_fwd_ex_load,
  input         io_fwd_lsu_rf_w,
  input  [4:0]  io_fwd_lsu_dst,
  input  [63:0] io_fwd_lsu_lsu_res,
  input         io_fwd_lsu_is_csr,
  input         io_fwd_lsu_br_stall,
  input         io_fwd_wb_rf_w,
  input  [4:0]  io_fwd_wb_dst,
  input  [63:0] io_fwd_wb_wb_res,
  output        io_intr_flush,
  input         io_br_stall
);
  wire  is_putch = 32'h7b == io_if_to_id_inst; // @[Decode.scala 149:23]
  wire [4:0] rs1 = io_if_to_id_inst[19:15]; // @[Decode.scala 53:20]
  wire [4:0] rs1_addr = is_putch ? 5'ha : rs1; // @[Decode.scala 151:23]
  wire  _eq1_e_T_1 = io_fwd_ex_dst != 5'h0; // @[Decode.scala 173:64]
  wire  eq1_e = io_fwd_ex_dst == rs1_addr & io_fwd_ex_dst != 5'h0 & io_fwd_ex_rf_w; // @[Decode.scala 173:73]
  wire [4:0] rs2 = io_if_to_id_inst[24:20]; // @[Decode.scala 54:20]
  wire  eq2_e = io_fwd_ex_dst == rs2 & _eq1_e_T_1 & io_fwd_ex_rf_w; // @[Decode.scala 177:73]
  wire  _ds_ready_go_T = eq1_e | eq2_e; // @[Decode.scala 183:52]
  wire  _eq1_l_T_1 = io_fwd_lsu_dst != 5'h0; // @[Decode.scala 174:65]
  wire  eq1_l = io_fwd_lsu_dst == rs1_addr & io_fwd_lsu_dst != 5'h0 & io_fwd_lsu_rf_w; // @[Decode.scala 174:74]
  wire  eq2_l = io_fwd_lsu_dst == rs2 & _eq1_l_T_1 & io_fwd_lsu_rf_w; // @[Decode.scala 178:74]
  wire  e_load = io_fwd_ex_load & _ds_ready_go_T; // @[Decode.scala 181:34]
  wire  ds_ready_go = (~(io_fwd_ex_is_csr & (eq1_e | eq2_e) | io_fwd_lsu_is_csr & (eq1_l | eq2_l) | e_load) |
    io_csr_to_id_csr_jump) & ~(io_br_stall | io_fwd_lsu_br_stall & (eq1_l | eq2_l)); // @[Decode.scala 183:131]
  wire  ds_to_es_valid = io_ds_valid & ds_ready_go; // @[Decode.scala 41:30]
  wire [4:0] rd = io_if_to_id_inst[11:7]; // @[Decode.scala 51:20]
  wire [52:0] imm_i_hi = io_if_to_id_inst[31] ? 53'h1fffffffffffff : 53'h0; // @[Bitwise.scala 72:12]
  wire [10:0] imm_i_lo = io_if_to_id_inst[30:20]; // @[Decode.scala 57:43]
  wire [63:0] imm_i = {imm_i_hi,imm_i_lo}; // @[Cat.scala 30:58]
  wire [5:0] imm_s_hi_lo = io_if_to_id_inst[30:25]; // @[Decode.scala 58:41]
  wire [63:0] imm_s = {imm_i_hi,imm_s_hi_lo,rd}; // @[Cat.scala 30:58]
  wire [51:0] imm_b_hi_hi_hi = io_if_to_id_inst[31] ? 52'hfffffffffffff : 52'h0; // @[Bitwise.scala 72:12]
  wire  imm_b_hi_hi_lo = io_if_to_id_inst[7]; // @[Decode.scala 59:41]
  wire [3:0] imm_b_lo_hi = io_if_to_id_inst[11:8]; // @[Decode.scala 59:61]
  wire [63:0] imm_b = {imm_b_hi_hi_hi,imm_b_hi_hi_lo,imm_s_hi_lo,imm_b_lo_hi,1'h0}; // @[Cat.scala 30:58]
  wire [32:0] imm_u_hi_hi = io_if_to_id_inst[31] ? 33'h1ffffffff : 33'h0; // @[Bitwise.scala 72:12]
  wire [18:0] imm_u_hi_lo = io_if_to_id_inst[30:12]; // @[Decode.scala 60:41]
  wire [63:0] imm_u = {imm_u_hi_hi,imm_u_hi_lo,12'h0}; // @[Cat.scala 30:58]
  wire [43:0] imm_j_hi_hi_hi = io_if_to_id_inst[31] ? 44'hfffffffffff : 44'h0; // @[Bitwise.scala 72:12]
  wire [7:0] imm_j_hi_hi_lo = io_if_to_id_inst[19:12]; // @[Decode.scala 61:41]
  wire  imm_j_hi_lo = io_if_to_id_inst[20]; // @[Decode.scala 61:53]
  wire [3:0] imm_j_lo_hi_lo = io_if_to_id_inst[24:21]; // @[Decode.scala 61:74]
  wire [63:0] imm_j = {imm_j_hi_hi_hi,imm_j_hi_hi_lo,imm_j_hi_lo,imm_s_hi_lo,imm_j_lo_hi_lo,1'h0}; // @[Cat.scala 30:58]
  wire [31:0] _ctr_signals_T = io_if_to_id_inst & 32'h707f; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_1 = 32'h13 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire [31:0] _ctr_signals_T_2 = io_if_to_id_inst & 32'hfc00707f; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_3 = 32'h1013 == _ctr_signals_T_2; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_5 = 32'h2013 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_7 = 32'h3013 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_9 = 32'h4013 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_11 = 32'h5013 == _ctr_signals_T_2; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_13 = 32'h6013 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_15 = 32'h7013 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_17 = 32'h40005013 == _ctr_signals_T_2; // @[Lookup.scala 31:38]
  wire [31:0] _ctr_signals_T_18 = io_if_to_id_inst & 32'hfe00707f; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_19 = 32'h33 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_21 = 32'h1033 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_23 = 32'h2033 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_25 = 32'h3033 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_27 = 32'h4033 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_29 = 32'h5033 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_31 = 32'h6033 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_33 = 32'h7033 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_35 = 32'h40000033 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_37 = 32'h40005033 == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire [31:0] _ctr_signals_T_38 = io_if_to_id_inst & 32'h7f; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_39 = 32'h17 == _ctr_signals_T_38; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_41 = 32'h37 == _ctr_signals_T_38; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_43 = 32'h6f == _ctr_signals_T_38; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_45 = 32'h67 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_47 = 32'h1063 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_49 = 32'h63 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_51 = 32'h4063 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_53 = 32'h5063 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_55 = 32'h6063 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_57 = 32'h7063 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_59 = 32'h3 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_61 = 32'h1003 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_63 = 32'h2003 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_65 = 32'h4003 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_67 = 32'h5003 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_69 = 32'h23 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_71 = 32'h1023 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_73 = 32'h2023 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_75 = 32'h1b == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_77 = 32'h101b == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_79 = 32'h501b == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_81 = 32'h4000501b == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_83 = 32'h103b == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_85 = 32'h503b == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_87 = 32'h4000503b == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_89 = 32'h3b == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_91 = 32'h4000003b == _ctr_signals_T_18; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_93 = 32'h6003 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_95 = 32'h3003 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_97 = 32'h3023 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_99 = 32'h1073 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_101 = 32'h2073 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_103 = 32'h3073 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_105 = 32'h5073 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_107 = 32'h6073 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_109 = 32'h7073 == _ctr_signals_T; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_111 = 32'h73 == io_if_to_id_inst; // @[Lookup.scala 31:38]
  wire  _ctr_signals_T_113 = 32'h30200073 == io_if_to_id_inst; // @[Lookup.scala 31:38]
  wire [1:0] _ctr_signals_T_173 = is_putch ? 2'h1 : 2'h0; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_174 = _ctr_signals_T_113 ? 2'h1 : _ctr_signals_T_173; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_175 = _ctr_signals_T_111 ? 2'h1 : _ctr_signals_T_174; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_176 = _ctr_signals_T_109 ? 2'h1 : _ctr_signals_T_175; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_177 = _ctr_signals_T_107 ? 2'h1 : _ctr_signals_T_176; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_178 = _ctr_signals_T_105 ? 2'h1 : _ctr_signals_T_177; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_179 = _ctr_signals_T_103 ? 2'h1 : _ctr_signals_T_178; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_180 = _ctr_signals_T_101 ? 2'h1 : _ctr_signals_T_179; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_181 = _ctr_signals_T_99 ? 2'h1 : _ctr_signals_T_180; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_182 = _ctr_signals_T_97 ? 2'h1 : _ctr_signals_T_181; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_183 = _ctr_signals_T_95 ? 2'h1 : _ctr_signals_T_182; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_184 = _ctr_signals_T_93 ? 2'h1 : _ctr_signals_T_183; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_185 = _ctr_signals_T_91 ? 2'h1 : _ctr_signals_T_184; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_186 = _ctr_signals_T_89 ? 2'h1 : _ctr_signals_T_185; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_187 = _ctr_signals_T_87 ? 2'h1 : _ctr_signals_T_186; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_188 = _ctr_signals_T_85 ? 2'h1 : _ctr_signals_T_187; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_189 = _ctr_signals_T_83 ? 2'h1 : _ctr_signals_T_188; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_190 = _ctr_signals_T_81 ? 2'h1 : _ctr_signals_T_189; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_191 = _ctr_signals_T_79 ? 2'h1 : _ctr_signals_T_190; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_192 = _ctr_signals_T_77 ? 2'h1 : _ctr_signals_T_191; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_193 = _ctr_signals_T_75 ? 2'h1 : _ctr_signals_T_192; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_194 = _ctr_signals_T_73 ? 2'h1 : _ctr_signals_T_193; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_195 = _ctr_signals_T_71 ? 2'h1 : _ctr_signals_T_194; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_196 = _ctr_signals_T_69 ? 2'h1 : _ctr_signals_T_195; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_197 = _ctr_signals_T_67 ? 2'h1 : _ctr_signals_T_196; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_198 = _ctr_signals_T_65 ? 2'h1 : _ctr_signals_T_197; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_199 = _ctr_signals_T_63 ? 2'h1 : _ctr_signals_T_198; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_200 = _ctr_signals_T_61 ? 2'h1 : _ctr_signals_T_199; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_201 = _ctr_signals_T_59 ? 2'h1 : _ctr_signals_T_200; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_202 = _ctr_signals_T_57 ? 2'h0 : _ctr_signals_T_201; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_203 = _ctr_signals_T_55 ? 2'h0 : _ctr_signals_T_202; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_204 = _ctr_signals_T_53 ? 2'h0 : _ctr_signals_T_203; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_205 = _ctr_signals_T_51 ? 2'h0 : _ctr_signals_T_204; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_206 = _ctr_signals_T_49 ? 2'h0 : _ctr_signals_T_205; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_207 = _ctr_signals_T_47 ? 2'h0 : _ctr_signals_T_206; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_208 = _ctr_signals_T_45 ? 2'h2 : _ctr_signals_T_207; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_209 = _ctr_signals_T_43 ? 2'h2 : _ctr_signals_T_208; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_210 = _ctr_signals_T_41 ? 2'h0 : _ctr_signals_T_209; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_211 = _ctr_signals_T_39 ? 2'h2 : _ctr_signals_T_210; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_212 = _ctr_signals_T_37 ? 2'h1 : _ctr_signals_T_211; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_213 = _ctr_signals_T_35 ? 2'h1 : _ctr_signals_T_212; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_214 = _ctr_signals_T_33 ? 2'h1 : _ctr_signals_T_213; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_215 = _ctr_signals_T_31 ? 2'h1 : _ctr_signals_T_214; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_216 = _ctr_signals_T_29 ? 2'h1 : _ctr_signals_T_215; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_217 = _ctr_signals_T_27 ? 2'h1 : _ctr_signals_T_216; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_218 = _ctr_signals_T_25 ? 2'h1 : _ctr_signals_T_217; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_219 = _ctr_signals_T_23 ? 2'h1 : _ctr_signals_T_218; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_220 = _ctr_signals_T_21 ? 2'h1 : _ctr_signals_T_219; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_221 = _ctr_signals_T_19 ? 2'h1 : _ctr_signals_T_220; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_222 = _ctr_signals_T_17 ? 2'h1 : _ctr_signals_T_221; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_223 = _ctr_signals_T_15 ? 2'h1 : _ctr_signals_T_222; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_224 = _ctr_signals_T_13 ? 2'h1 : _ctr_signals_T_223; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_225 = _ctr_signals_T_11 ? 2'h1 : _ctr_signals_T_224; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_226 = _ctr_signals_T_9 ? 2'h1 : _ctr_signals_T_225; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_227 = _ctr_signals_T_7 ? 2'h1 : _ctr_signals_T_226; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_228 = _ctr_signals_T_5 ? 2'h1 : _ctr_signals_T_227; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_229 = _ctr_signals_T_3 ? 2'h1 : _ctr_signals_T_228; // @[Lookup.scala 33:37]
  wire [1:0] ctr_signals_1 = _ctr_signals_T_1 ? 2'h1 : _ctr_signals_T_229; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_230 = is_putch ? 2'h2 : 2'h0; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_231 = _ctr_signals_T_113 ? 2'h2 : _ctr_signals_T_230; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_232 = _ctr_signals_T_111 ? 2'h2 : _ctr_signals_T_231; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_233 = _ctr_signals_T_109 ? 2'h2 : _ctr_signals_T_232; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_234 = _ctr_signals_T_107 ? 2'h2 : _ctr_signals_T_233; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_235 = _ctr_signals_T_105 ? 2'h2 : _ctr_signals_T_234; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_236 = _ctr_signals_T_103 ? 2'h2 : _ctr_signals_T_235; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_237 = _ctr_signals_T_101 ? 2'h2 : _ctr_signals_T_236; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_238 = _ctr_signals_T_99 ? 2'h2 : _ctr_signals_T_237; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_239 = _ctr_signals_T_97 ? 2'h1 : _ctr_signals_T_238; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_240 = _ctr_signals_T_95 ? 2'h2 : _ctr_signals_T_239; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_241 = _ctr_signals_T_93 ? 2'h2 : _ctr_signals_T_240; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_242 = _ctr_signals_T_91 ? 2'h1 : _ctr_signals_T_241; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_243 = _ctr_signals_T_89 ? 2'h1 : _ctr_signals_T_242; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_244 = _ctr_signals_T_87 ? 2'h1 : _ctr_signals_T_243; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_245 = _ctr_signals_T_85 ? 2'h1 : _ctr_signals_T_244; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_246 = _ctr_signals_T_83 ? 2'h1 : _ctr_signals_T_245; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_247 = _ctr_signals_T_81 ? 2'h2 : _ctr_signals_T_246; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_248 = _ctr_signals_T_79 ? 2'h2 : _ctr_signals_T_247; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_249 = _ctr_signals_T_77 ? 2'h2 : _ctr_signals_T_248; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_250 = _ctr_signals_T_75 ? 2'h2 : _ctr_signals_T_249; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_251 = _ctr_signals_T_73 ? 2'h1 : _ctr_signals_T_250; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_252 = _ctr_signals_T_71 ? 2'h1 : _ctr_signals_T_251; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_253 = _ctr_signals_T_69 ? 2'h1 : _ctr_signals_T_252; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_254 = _ctr_signals_T_67 ? 2'h2 : _ctr_signals_T_253; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_255 = _ctr_signals_T_65 ? 2'h2 : _ctr_signals_T_254; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_256 = _ctr_signals_T_63 ? 2'h2 : _ctr_signals_T_255; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_257 = _ctr_signals_T_61 ? 2'h2 : _ctr_signals_T_256; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_258 = _ctr_signals_T_59 ? 2'h2 : _ctr_signals_T_257; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_259 = _ctr_signals_T_57 ? 2'h0 : _ctr_signals_T_258; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_260 = _ctr_signals_T_55 ? 2'h0 : _ctr_signals_T_259; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_261 = _ctr_signals_T_53 ? 2'h0 : _ctr_signals_T_260; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_262 = _ctr_signals_T_51 ? 2'h0 : _ctr_signals_T_261; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_263 = _ctr_signals_T_49 ? 2'h0 : _ctr_signals_T_262; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_264 = _ctr_signals_T_47 ? 2'h0 : _ctr_signals_T_263; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_265 = _ctr_signals_T_45 ? 2'h2 : _ctr_signals_T_264; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_266 = _ctr_signals_T_43 ? 2'h2 : _ctr_signals_T_265; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_267 = _ctr_signals_T_41 ? 2'h2 : _ctr_signals_T_266; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_268 = _ctr_signals_T_39 ? 2'h2 : _ctr_signals_T_267; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_269 = _ctr_signals_T_37 ? 2'h1 : _ctr_signals_T_268; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_270 = _ctr_signals_T_35 ? 2'h1 : _ctr_signals_T_269; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_271 = _ctr_signals_T_33 ? 2'h1 : _ctr_signals_T_270; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_272 = _ctr_signals_T_31 ? 2'h1 : _ctr_signals_T_271; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_273 = _ctr_signals_T_29 ? 2'h1 : _ctr_signals_T_272; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_274 = _ctr_signals_T_27 ? 2'h1 : _ctr_signals_T_273; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_275 = _ctr_signals_T_25 ? 2'h1 : _ctr_signals_T_274; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_276 = _ctr_signals_T_23 ? 2'h1 : _ctr_signals_T_275; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_277 = _ctr_signals_T_21 ? 2'h1 : _ctr_signals_T_276; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_278 = _ctr_signals_T_19 ? 2'h1 : _ctr_signals_T_277; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_279 = _ctr_signals_T_17 ? 2'h2 : _ctr_signals_T_278; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_280 = _ctr_signals_T_15 ? 2'h2 : _ctr_signals_T_279; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_281 = _ctr_signals_T_13 ? 2'h2 : _ctr_signals_T_280; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_282 = _ctr_signals_T_11 ? 2'h2 : _ctr_signals_T_281; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_283 = _ctr_signals_T_9 ? 2'h2 : _ctr_signals_T_282; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_284 = _ctr_signals_T_7 ? 2'h2 : _ctr_signals_T_283; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_285 = _ctr_signals_T_5 ? 2'h2 : _ctr_signals_T_284; // @[Lookup.scala 33:37]
  wire [1:0] _ctr_signals_T_286 = _ctr_signals_T_3 ? 2'h2 : _ctr_signals_T_285; // @[Lookup.scala 33:37]
  wire [1:0] ctr_signals_2 = _ctr_signals_T_1 ? 2'h2 : _ctr_signals_T_286; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_287 = is_putch ? 6'h1 : 6'h0; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_288 = _ctr_signals_T_113 ? 6'h1 : _ctr_signals_T_287; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_289 = _ctr_signals_T_111 ? 6'h1 : _ctr_signals_T_288; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_290 = _ctr_signals_T_109 ? 6'h1 : _ctr_signals_T_289; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_291 = _ctr_signals_T_107 ? 6'h1 : _ctr_signals_T_290; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_292 = _ctr_signals_T_105 ? 6'h1 : _ctr_signals_T_291; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_293 = _ctr_signals_T_103 ? 6'h1 : _ctr_signals_T_292; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_294 = _ctr_signals_T_101 ? 6'h1 : _ctr_signals_T_293; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_295 = _ctr_signals_T_99 ? 6'h1 : _ctr_signals_T_294; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_296 = _ctr_signals_T_97 ? 6'h2 : _ctr_signals_T_295; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_297 = _ctr_signals_T_95 ? 6'h1 : _ctr_signals_T_296; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_298 = _ctr_signals_T_93 ? 6'h1 : _ctr_signals_T_297; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_299 = _ctr_signals_T_91 ? 6'h0 : _ctr_signals_T_298; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_300 = _ctr_signals_T_89 ? 6'h0 : _ctr_signals_T_299; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_301 = _ctr_signals_T_87 ? 6'h0 : _ctr_signals_T_300; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_302 = _ctr_signals_T_85 ? 6'h0 : _ctr_signals_T_301; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_303 = _ctr_signals_T_83 ? 6'h0 : _ctr_signals_T_302; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_304 = _ctr_signals_T_81 ? 6'h1 : _ctr_signals_T_303; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_305 = _ctr_signals_T_79 ? 6'h1 : _ctr_signals_T_304; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_306 = _ctr_signals_T_77 ? 6'h1 : _ctr_signals_T_305; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_307 = _ctr_signals_T_75 ? 6'h1 : _ctr_signals_T_306; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_308 = _ctr_signals_T_73 ? 6'h2 : _ctr_signals_T_307; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_309 = _ctr_signals_T_71 ? 6'h2 : _ctr_signals_T_308; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_310 = _ctr_signals_T_69 ? 6'h2 : _ctr_signals_T_309; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_311 = _ctr_signals_T_67 ? 6'h1 : _ctr_signals_T_310; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_312 = _ctr_signals_T_65 ? 6'h1 : _ctr_signals_T_311; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_313 = _ctr_signals_T_63 ? 6'h1 : _ctr_signals_T_312; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_314 = _ctr_signals_T_61 ? 6'h1 : _ctr_signals_T_313; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_315 = _ctr_signals_T_59 ? 6'h1 : _ctr_signals_T_314; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_316 = _ctr_signals_T_57 ? 6'h0 : _ctr_signals_T_315; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_317 = _ctr_signals_T_55 ? 6'h0 : _ctr_signals_T_316; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_318 = _ctr_signals_T_53 ? 6'h0 : _ctr_signals_T_317; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_319 = _ctr_signals_T_51 ? 6'h0 : _ctr_signals_T_318; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_320 = _ctr_signals_T_49 ? 6'h0 : _ctr_signals_T_319; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_321 = _ctr_signals_T_47 ? 6'h0 : _ctr_signals_T_320; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_322 = _ctr_signals_T_45 ? 6'h20 : _ctr_signals_T_321; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_323 = _ctr_signals_T_43 ? 6'h20 : _ctr_signals_T_322; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_324 = _ctr_signals_T_41 ? 6'h8 : _ctr_signals_T_323; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_325 = _ctr_signals_T_39 ? 6'h8 : _ctr_signals_T_324; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_326 = _ctr_signals_T_37 ? 6'h0 : _ctr_signals_T_325; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_327 = _ctr_signals_T_35 ? 6'h0 : _ctr_signals_T_326; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_328 = _ctr_signals_T_33 ? 6'h0 : _ctr_signals_T_327; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_329 = _ctr_signals_T_31 ? 6'h0 : _ctr_signals_T_328; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_330 = _ctr_signals_T_29 ? 6'h0 : _ctr_signals_T_329; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_331 = _ctr_signals_T_27 ? 6'h0 : _ctr_signals_T_330; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_332 = _ctr_signals_T_25 ? 6'h0 : _ctr_signals_T_331; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_333 = _ctr_signals_T_23 ? 6'h0 : _ctr_signals_T_332; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_334 = _ctr_signals_T_21 ? 6'h0 : _ctr_signals_T_333; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_335 = _ctr_signals_T_19 ? 6'h0 : _ctr_signals_T_334; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_336 = _ctr_signals_T_17 ? 6'h1 : _ctr_signals_T_335; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_337 = _ctr_signals_T_15 ? 6'h1 : _ctr_signals_T_336; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_338 = _ctr_signals_T_13 ? 6'h1 : _ctr_signals_T_337; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_339 = _ctr_signals_T_11 ? 6'h1 : _ctr_signals_T_338; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_340 = _ctr_signals_T_9 ? 6'h1 : _ctr_signals_T_339; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_341 = _ctr_signals_T_7 ? 6'h1 : _ctr_signals_T_340; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_342 = _ctr_signals_T_5 ? 6'h1 : _ctr_signals_T_341; // @[Lookup.scala 33:37]
  wire [5:0] _ctr_signals_T_343 = _ctr_signals_T_3 ? 6'h1 : _ctr_signals_T_342; // @[Lookup.scala 33:37]
  wire [5:0] ctr_signals_3 = _ctr_signals_T_1 ? 6'h1 : _ctr_signals_T_343; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_344 = is_putch ? 5'h1 : 5'h0; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_345 = _ctr_signals_T_113 ? 5'h10 : _ctr_signals_T_344; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_346 = _ctr_signals_T_111 ? 5'h10 : _ctr_signals_T_345; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_347 = _ctr_signals_T_109 ? 5'h10 : _ctr_signals_T_346; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_348 = _ctr_signals_T_107 ? 5'h10 : _ctr_signals_T_347; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_349 = _ctr_signals_T_105 ? 5'h10 : _ctr_signals_T_348; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_350 = _ctr_signals_T_103 ? 5'h10 : _ctr_signals_T_349; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_351 = _ctr_signals_T_101 ? 5'h10 : _ctr_signals_T_350; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_352 = _ctr_signals_T_99 ? 5'h10 : _ctr_signals_T_351; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_353 = _ctr_signals_T_97 ? 5'h8 : _ctr_signals_T_352; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_354 = _ctr_signals_T_95 ? 5'h8 : _ctr_signals_T_353; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_355 = _ctr_signals_T_93 ? 5'h8 : _ctr_signals_T_354; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_356 = _ctr_signals_T_91 ? 5'h8 : _ctr_signals_T_355; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_357 = _ctr_signals_T_89 ? 5'h8 : _ctr_signals_T_356; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_358 = _ctr_signals_T_87 ? 5'h8 : _ctr_signals_T_357; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_359 = _ctr_signals_T_85 ? 5'h8 : _ctr_signals_T_358; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_360 = _ctr_signals_T_83 ? 5'h8 : _ctr_signals_T_359; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_361 = _ctr_signals_T_81 ? 5'h8 : _ctr_signals_T_360; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_362 = _ctr_signals_T_79 ? 5'h8 : _ctr_signals_T_361; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_363 = _ctr_signals_T_77 ? 5'h8 : _ctr_signals_T_362; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_364 = _ctr_signals_T_75 ? 5'h8 : _ctr_signals_T_363; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_365 = _ctr_signals_T_73 ? 5'h4 : _ctr_signals_T_364; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_366 = _ctr_signals_T_71 ? 5'h4 : _ctr_signals_T_365; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_367 = _ctr_signals_T_69 ? 5'h4 : _ctr_signals_T_366; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_368 = _ctr_signals_T_67 ? 5'h4 : _ctr_signals_T_367; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_369 = _ctr_signals_T_65 ? 5'h4 : _ctr_signals_T_368; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_370 = _ctr_signals_T_63 ? 5'h4 : _ctr_signals_T_369; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_371 = _ctr_signals_T_61 ? 5'h4 : _ctr_signals_T_370; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_372 = _ctr_signals_T_59 ? 5'h4 : _ctr_signals_T_371; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_373 = _ctr_signals_T_57 ? 5'h2 : _ctr_signals_T_372; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_374 = _ctr_signals_T_55 ? 5'h2 : _ctr_signals_T_373; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_375 = _ctr_signals_T_53 ? 5'h2 : _ctr_signals_T_374; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_376 = _ctr_signals_T_51 ? 5'h2 : _ctr_signals_T_375; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_377 = _ctr_signals_T_49 ? 5'h2 : _ctr_signals_T_376; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_378 = _ctr_signals_T_47 ? 5'h2 : _ctr_signals_T_377; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_379 = _ctr_signals_T_45 ? 5'h2 : _ctr_signals_T_378; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_380 = _ctr_signals_T_43 ? 5'h2 : _ctr_signals_T_379; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_381 = _ctr_signals_T_41 ? 5'h1 : _ctr_signals_T_380; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_382 = _ctr_signals_T_39 ? 5'h1 : _ctr_signals_T_381; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_383 = _ctr_signals_T_37 ? 5'h1 : _ctr_signals_T_382; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_384 = _ctr_signals_T_35 ? 5'h1 : _ctr_signals_T_383; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_385 = _ctr_signals_T_33 ? 5'h1 : _ctr_signals_T_384; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_386 = _ctr_signals_T_31 ? 5'h1 : _ctr_signals_T_385; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_387 = _ctr_signals_T_29 ? 5'h1 : _ctr_signals_T_386; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_388 = _ctr_signals_T_27 ? 5'h1 : _ctr_signals_T_387; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_389 = _ctr_signals_T_25 ? 5'h1 : _ctr_signals_T_388; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_390 = _ctr_signals_T_23 ? 5'h1 : _ctr_signals_T_389; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_391 = _ctr_signals_T_21 ? 5'h1 : _ctr_signals_T_390; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_392 = _ctr_signals_T_19 ? 5'h1 : _ctr_signals_T_391; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_393 = _ctr_signals_T_17 ? 5'h1 : _ctr_signals_T_392; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_394 = _ctr_signals_T_15 ? 5'h1 : _ctr_signals_T_393; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_395 = _ctr_signals_T_13 ? 5'h1 : _ctr_signals_T_394; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_396 = _ctr_signals_T_11 ? 5'h1 : _ctr_signals_T_395; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_397 = _ctr_signals_T_9 ? 5'h1 : _ctr_signals_T_396; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_398 = _ctr_signals_T_7 ? 5'h1 : _ctr_signals_T_397; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_399 = _ctr_signals_T_5 ? 5'h1 : _ctr_signals_T_398; // @[Lookup.scala 33:37]
  wire [4:0] _ctr_signals_T_400 = _ctr_signals_T_3 ? 5'h1 : _ctr_signals_T_399; // @[Lookup.scala 33:37]
  wire [4:0] ctr_signals_4 = _ctr_signals_T_1 ? 5'h1 : _ctr_signals_T_400; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_401 = is_putch ? 11'h1 : 11'h0; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_402 = _ctr_signals_T_113 ? 11'h1 : _ctr_signals_T_401; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_403 = _ctr_signals_T_111 ? 11'h1 : _ctr_signals_T_402; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_404 = _ctr_signals_T_109 ? 11'h1 : _ctr_signals_T_403; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_405 = _ctr_signals_T_107 ? 11'h1 : _ctr_signals_T_404; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_406 = _ctr_signals_T_105 ? 11'h1 : _ctr_signals_T_405; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_407 = _ctr_signals_T_103 ? 11'h1 : _ctr_signals_T_406; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_408 = _ctr_signals_T_101 ? 11'h1 : _ctr_signals_T_407; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_409 = _ctr_signals_T_99 ? 11'h1 : _ctr_signals_T_408; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_410 = _ctr_signals_T_97 ? 11'h1 : _ctr_signals_T_409; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_411 = _ctr_signals_T_95 ? 11'h1 : _ctr_signals_T_410; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_412 = _ctr_signals_T_93 ? 11'h1 : _ctr_signals_T_411; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_413 = _ctr_signals_T_91 ? 11'h400 : _ctr_signals_T_412; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_414 = _ctr_signals_T_89 ? 11'h1 : _ctr_signals_T_413; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_415 = _ctr_signals_T_87 ? 11'h100 : _ctr_signals_T_414; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_416 = _ctr_signals_T_85 ? 11'h80 : _ctr_signals_T_415; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_417 = _ctr_signals_T_83 ? 11'h40 : _ctr_signals_T_416; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_418 = _ctr_signals_T_81 ? 11'h100 : _ctr_signals_T_417; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_419 = _ctr_signals_T_79 ? 11'h80 : _ctr_signals_T_418; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_420 = _ctr_signals_T_77 ? 11'h40 : _ctr_signals_T_419; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_421 = _ctr_signals_T_75 ? 11'h1 : _ctr_signals_T_420; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_422 = _ctr_signals_T_73 ? 11'h1 : _ctr_signals_T_421; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_423 = _ctr_signals_T_71 ? 11'h1 : _ctr_signals_T_422; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_424 = _ctr_signals_T_69 ? 11'h1 : _ctr_signals_T_423; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_425 = _ctr_signals_T_67 ? 11'h1 : _ctr_signals_T_424; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_426 = _ctr_signals_T_65 ? 11'h1 : _ctr_signals_T_425; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_427 = _ctr_signals_T_63 ? 11'h1 : _ctr_signals_T_426; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_428 = _ctr_signals_T_61 ? 11'h1 : _ctr_signals_T_427; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_429 = _ctr_signals_T_59 ? 11'h1 : _ctr_signals_T_428; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_430 = _ctr_signals_T_57 ? 11'h0 : _ctr_signals_T_429; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_431 = _ctr_signals_T_55 ? 11'h0 : _ctr_signals_T_430; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_432 = _ctr_signals_T_53 ? 11'h0 : _ctr_signals_T_431; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_433 = _ctr_signals_T_51 ? 11'h0 : _ctr_signals_T_432; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_434 = _ctr_signals_T_49 ? 11'h0 : _ctr_signals_T_433; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_435 = _ctr_signals_T_47 ? 11'h0 : _ctr_signals_T_434; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_436 = _ctr_signals_T_45 ? 11'h1 : _ctr_signals_T_435; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_437 = _ctr_signals_T_43 ? 11'h1 : _ctr_signals_T_436; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_438 = _ctr_signals_T_41 ? 11'h200 : _ctr_signals_T_437; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_439 = _ctr_signals_T_39 ? 11'h1 : _ctr_signals_T_438; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_440 = _ctr_signals_T_37 ? 11'h100 : _ctr_signals_T_439; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_441 = _ctr_signals_T_35 ? 11'h400 : _ctr_signals_T_440; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_442 = _ctr_signals_T_33 ? 11'h8 : _ctr_signals_T_441; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_443 = _ctr_signals_T_31 ? 11'h10 : _ctr_signals_T_442; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_444 = _ctr_signals_T_29 ? 11'h80 : _ctr_signals_T_443; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_445 = _ctr_signals_T_27 ? 11'h20 : _ctr_signals_T_444; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_446 = _ctr_signals_T_25 ? 11'h4 : _ctr_signals_T_445; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_447 = _ctr_signals_T_23 ? 11'h2 : _ctr_signals_T_446; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_448 = _ctr_signals_T_21 ? 11'h40 : _ctr_signals_T_447; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_449 = _ctr_signals_T_19 ? 11'h1 : _ctr_signals_T_448; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_450 = _ctr_signals_T_17 ? 11'h100 : _ctr_signals_T_449; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_451 = _ctr_signals_T_15 ? 11'h8 : _ctr_signals_T_450; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_452 = _ctr_signals_T_13 ? 11'h10 : _ctr_signals_T_451; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_453 = _ctr_signals_T_11 ? 11'h80 : _ctr_signals_T_452; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_454 = _ctr_signals_T_9 ? 11'h20 : _ctr_signals_T_453; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_455 = _ctr_signals_T_7 ? 11'h4 : _ctr_signals_T_454; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_456 = _ctr_signals_T_5 ? 11'h2 : _ctr_signals_T_455; // @[Lookup.scala 33:37]
  wire [10:0] _ctr_signals_T_457 = _ctr_signals_T_3 ? 11'h40 : _ctr_signals_T_456; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_487 = _ctr_signals_T_57 ? 8'h80 : 8'h0; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_488 = _ctr_signals_T_55 ? 8'h40 : _ctr_signals_T_487; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_489 = _ctr_signals_T_53 ? 8'h20 : _ctr_signals_T_488; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_490 = _ctr_signals_T_51 ? 8'h10 : _ctr_signals_T_489; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_491 = _ctr_signals_T_49 ? 8'h8 : _ctr_signals_T_490; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_492 = _ctr_signals_T_47 ? 8'h4 : _ctr_signals_T_491; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_493 = _ctr_signals_T_45 ? 8'h2 : _ctr_signals_T_492; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_494 = _ctr_signals_T_43 ? 8'h1 : _ctr_signals_T_493; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_495 = _ctr_signals_T_41 ? 8'h0 : _ctr_signals_T_494; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_496 = _ctr_signals_T_39 ? 8'h0 : _ctr_signals_T_495; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_497 = _ctr_signals_T_37 ? 8'h0 : _ctr_signals_T_496; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_498 = _ctr_signals_T_35 ? 8'h0 : _ctr_signals_T_497; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_499 = _ctr_signals_T_33 ? 8'h0 : _ctr_signals_T_498; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_500 = _ctr_signals_T_31 ? 8'h0 : _ctr_signals_T_499; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_501 = _ctr_signals_T_29 ? 8'h0 : _ctr_signals_T_500; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_502 = _ctr_signals_T_27 ? 8'h0 : _ctr_signals_T_501; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_503 = _ctr_signals_T_25 ? 8'h0 : _ctr_signals_T_502; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_504 = _ctr_signals_T_23 ? 8'h0 : _ctr_signals_T_503; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_505 = _ctr_signals_T_21 ? 8'h0 : _ctr_signals_T_504; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_506 = _ctr_signals_T_19 ? 8'h0 : _ctr_signals_T_505; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_507 = _ctr_signals_T_17 ? 8'h0 : _ctr_signals_T_506; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_508 = _ctr_signals_T_15 ? 8'h0 : _ctr_signals_T_507; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_509 = _ctr_signals_T_13 ? 8'h0 : _ctr_signals_T_508; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_510 = _ctr_signals_T_11 ? 8'h0 : _ctr_signals_T_509; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_511 = _ctr_signals_T_9 ? 8'h0 : _ctr_signals_T_510; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_512 = _ctr_signals_T_7 ? 8'h0 : _ctr_signals_T_511; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_513 = _ctr_signals_T_5 ? 8'h0 : _ctr_signals_T_512; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_514 = _ctr_signals_T_3 ? 8'h0 : _ctr_signals_T_513; // @[Lookup.scala 33:37]
  wire [7:0] bruop = _ctr_signals_T_1 ? 8'h0 : _ctr_signals_T_514; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_536 = _ctr_signals_T_73 ? 8'h80 : 8'h0; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_537 = _ctr_signals_T_71 ? 8'h40 : _ctr_signals_T_536; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_538 = _ctr_signals_T_69 ? 8'h20 : _ctr_signals_T_537; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_539 = _ctr_signals_T_67 ? 8'h10 : _ctr_signals_T_538; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_540 = _ctr_signals_T_65 ? 8'h8 : _ctr_signals_T_539; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_541 = _ctr_signals_T_63 ? 8'h4 : _ctr_signals_T_540; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_542 = _ctr_signals_T_61 ? 8'h2 : _ctr_signals_T_541; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_543 = _ctr_signals_T_59 ? 8'h1 : _ctr_signals_T_542; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_544 = _ctr_signals_T_57 ? 8'h0 : _ctr_signals_T_543; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_545 = _ctr_signals_T_55 ? 8'h0 : _ctr_signals_T_544; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_546 = _ctr_signals_T_53 ? 8'h0 : _ctr_signals_T_545; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_547 = _ctr_signals_T_51 ? 8'h0 : _ctr_signals_T_546; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_548 = _ctr_signals_T_49 ? 8'h0 : _ctr_signals_T_547; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_549 = _ctr_signals_T_47 ? 8'h0 : _ctr_signals_T_548; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_550 = _ctr_signals_T_45 ? 8'h0 : _ctr_signals_T_549; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_551 = _ctr_signals_T_43 ? 8'h0 : _ctr_signals_T_550; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_552 = _ctr_signals_T_41 ? 8'h0 : _ctr_signals_T_551; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_553 = _ctr_signals_T_39 ? 8'h0 : _ctr_signals_T_552; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_554 = _ctr_signals_T_37 ? 8'h0 : _ctr_signals_T_553; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_555 = _ctr_signals_T_35 ? 8'h0 : _ctr_signals_T_554; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_556 = _ctr_signals_T_33 ? 8'h0 : _ctr_signals_T_555; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_557 = _ctr_signals_T_31 ? 8'h0 : _ctr_signals_T_556; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_558 = _ctr_signals_T_29 ? 8'h0 : _ctr_signals_T_557; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_559 = _ctr_signals_T_27 ? 8'h0 : _ctr_signals_T_558; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_560 = _ctr_signals_T_25 ? 8'h0 : _ctr_signals_T_559; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_561 = _ctr_signals_T_23 ? 8'h0 : _ctr_signals_T_560; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_562 = _ctr_signals_T_21 ? 8'h0 : _ctr_signals_T_561; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_563 = _ctr_signals_T_19 ? 8'h0 : _ctr_signals_T_562; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_564 = _ctr_signals_T_17 ? 8'h0 : _ctr_signals_T_563; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_565 = _ctr_signals_T_15 ? 8'h0 : _ctr_signals_T_564; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_566 = _ctr_signals_T_13 ? 8'h0 : _ctr_signals_T_565; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_567 = _ctr_signals_T_11 ? 8'h0 : _ctr_signals_T_566; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_568 = _ctr_signals_T_9 ? 8'h0 : _ctr_signals_T_567; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_569 = _ctr_signals_T_7 ? 8'h0 : _ctr_signals_T_568; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_570 = _ctr_signals_T_5 ? 8'h0 : _ctr_signals_T_569; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_571 = _ctr_signals_T_3 ? 8'h0 : _ctr_signals_T_570; // @[Lookup.scala 33:37]
  wire [7:0] ctr_signals_7 = _ctr_signals_T_1 ? 8'h0 : _ctr_signals_T_571; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_581 = _ctr_signals_T_97 ? 12'h800 : 12'h0; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_582 = _ctr_signals_T_95 ? 12'h400 : _ctr_signals_T_581; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_583 = _ctr_signals_T_93 ? 12'h200 : _ctr_signals_T_582; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_584 = _ctr_signals_T_91 ? 12'h100 : _ctr_signals_T_583; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_585 = _ctr_signals_T_89 ? 12'h80 : _ctr_signals_T_584; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_586 = _ctr_signals_T_87 ? 12'h40 : _ctr_signals_T_585; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_587 = _ctr_signals_T_85 ? 12'h20 : _ctr_signals_T_586; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_588 = _ctr_signals_T_83 ? 12'h10 : _ctr_signals_T_587; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_589 = _ctr_signals_T_81 ? 12'h8 : _ctr_signals_T_588; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_590 = _ctr_signals_T_79 ? 12'h4 : _ctr_signals_T_589; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_591 = _ctr_signals_T_77 ? 12'h2 : _ctr_signals_T_590; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_592 = _ctr_signals_T_75 ? 12'h1 : _ctr_signals_T_591; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_593 = _ctr_signals_T_73 ? 12'h0 : _ctr_signals_T_592; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_594 = _ctr_signals_T_71 ? 12'h0 : _ctr_signals_T_593; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_595 = _ctr_signals_T_69 ? 12'h0 : _ctr_signals_T_594; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_596 = _ctr_signals_T_67 ? 12'h0 : _ctr_signals_T_595; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_597 = _ctr_signals_T_65 ? 12'h0 : _ctr_signals_T_596; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_598 = _ctr_signals_T_63 ? 12'h0 : _ctr_signals_T_597; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_599 = _ctr_signals_T_61 ? 12'h0 : _ctr_signals_T_598; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_600 = _ctr_signals_T_59 ? 12'h0 : _ctr_signals_T_599; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_601 = _ctr_signals_T_57 ? 12'h0 : _ctr_signals_T_600; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_602 = _ctr_signals_T_55 ? 12'h0 : _ctr_signals_T_601; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_603 = _ctr_signals_T_53 ? 12'h0 : _ctr_signals_T_602; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_604 = _ctr_signals_T_51 ? 12'h0 : _ctr_signals_T_603; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_605 = _ctr_signals_T_49 ? 12'h0 : _ctr_signals_T_604; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_606 = _ctr_signals_T_47 ? 12'h0 : _ctr_signals_T_605; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_607 = _ctr_signals_T_45 ? 12'h0 : _ctr_signals_T_606; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_608 = _ctr_signals_T_43 ? 12'h0 : _ctr_signals_T_607; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_609 = _ctr_signals_T_41 ? 12'h0 : _ctr_signals_T_608; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_610 = _ctr_signals_T_39 ? 12'h0 : _ctr_signals_T_609; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_611 = _ctr_signals_T_37 ? 12'h0 : _ctr_signals_T_610; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_612 = _ctr_signals_T_35 ? 12'h0 : _ctr_signals_T_611; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_613 = _ctr_signals_T_33 ? 12'h0 : _ctr_signals_T_612; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_614 = _ctr_signals_T_31 ? 12'h0 : _ctr_signals_T_613; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_615 = _ctr_signals_T_29 ? 12'h0 : _ctr_signals_T_614; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_616 = _ctr_signals_T_27 ? 12'h0 : _ctr_signals_T_615; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_617 = _ctr_signals_T_25 ? 12'h0 : _ctr_signals_T_616; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_618 = _ctr_signals_T_23 ? 12'h0 : _ctr_signals_T_617; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_619 = _ctr_signals_T_21 ? 12'h0 : _ctr_signals_T_618; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_620 = _ctr_signals_T_19 ? 12'h0 : _ctr_signals_T_619; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_621 = _ctr_signals_T_17 ? 12'h0 : _ctr_signals_T_620; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_622 = _ctr_signals_T_15 ? 12'h0 : _ctr_signals_T_621; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_623 = _ctr_signals_T_13 ? 12'h0 : _ctr_signals_T_622; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_624 = _ctr_signals_T_11 ? 12'h0 : _ctr_signals_T_623; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_625 = _ctr_signals_T_9 ? 12'h0 : _ctr_signals_T_624; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_626 = _ctr_signals_T_7 ? 12'h0 : _ctr_signals_T_625; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_627 = _ctr_signals_T_5 ? 12'h0 : _ctr_signals_T_626; // @[Lookup.scala 33:37]
  wire [11:0] _ctr_signals_T_628 = _ctr_signals_T_3 ? 12'h0 : _ctr_signals_T_627; // @[Lookup.scala 33:37]
  wire [11:0] ctr_signals_8 = _ctr_signals_T_1 ? 12'h0 : _ctr_signals_T_628; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_630 = _ctr_signals_T_113 ? 8'h8 : 8'h0; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_631 = _ctr_signals_T_111 ? 8'h7 : _ctr_signals_T_630; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_632 = _ctr_signals_T_109 ? 8'h6 : _ctr_signals_T_631; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_633 = _ctr_signals_T_107 ? 8'h5 : _ctr_signals_T_632; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_634 = _ctr_signals_T_105 ? 8'h4 : _ctr_signals_T_633; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_635 = _ctr_signals_T_103 ? 8'h3 : _ctr_signals_T_634; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_636 = _ctr_signals_T_101 ? 8'h2 : _ctr_signals_T_635; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_637 = _ctr_signals_T_99 ? 8'h1 : _ctr_signals_T_636; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_638 = _ctr_signals_T_97 ? 8'h0 : _ctr_signals_T_637; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_639 = _ctr_signals_T_95 ? 8'h0 : _ctr_signals_T_638; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_640 = _ctr_signals_T_93 ? 8'h0 : _ctr_signals_T_639; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_641 = _ctr_signals_T_91 ? 8'h0 : _ctr_signals_T_640; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_642 = _ctr_signals_T_89 ? 8'h0 : _ctr_signals_T_641; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_643 = _ctr_signals_T_87 ? 8'h0 : _ctr_signals_T_642; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_644 = _ctr_signals_T_85 ? 8'h0 : _ctr_signals_T_643; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_645 = _ctr_signals_T_83 ? 8'h0 : _ctr_signals_T_644; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_646 = _ctr_signals_T_81 ? 8'h0 : _ctr_signals_T_645; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_647 = _ctr_signals_T_79 ? 8'h0 : _ctr_signals_T_646; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_648 = _ctr_signals_T_77 ? 8'h0 : _ctr_signals_T_647; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_649 = _ctr_signals_T_75 ? 8'h0 : _ctr_signals_T_648; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_650 = _ctr_signals_T_73 ? 8'h0 : _ctr_signals_T_649; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_651 = _ctr_signals_T_71 ? 8'h0 : _ctr_signals_T_650; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_652 = _ctr_signals_T_69 ? 8'h0 : _ctr_signals_T_651; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_653 = _ctr_signals_T_67 ? 8'h0 : _ctr_signals_T_652; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_654 = _ctr_signals_T_65 ? 8'h0 : _ctr_signals_T_653; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_655 = _ctr_signals_T_63 ? 8'h0 : _ctr_signals_T_654; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_656 = _ctr_signals_T_61 ? 8'h0 : _ctr_signals_T_655; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_657 = _ctr_signals_T_59 ? 8'h0 : _ctr_signals_T_656; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_658 = _ctr_signals_T_57 ? 8'h0 : _ctr_signals_T_657; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_659 = _ctr_signals_T_55 ? 8'h0 : _ctr_signals_T_658; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_660 = _ctr_signals_T_53 ? 8'h0 : _ctr_signals_T_659; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_661 = _ctr_signals_T_51 ? 8'h0 : _ctr_signals_T_660; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_662 = _ctr_signals_T_49 ? 8'h0 : _ctr_signals_T_661; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_663 = _ctr_signals_T_47 ? 8'h0 : _ctr_signals_T_662; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_664 = _ctr_signals_T_45 ? 8'h0 : _ctr_signals_T_663; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_665 = _ctr_signals_T_43 ? 8'h0 : _ctr_signals_T_664; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_666 = _ctr_signals_T_41 ? 8'h0 : _ctr_signals_T_665; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_667 = _ctr_signals_T_39 ? 8'h0 : _ctr_signals_T_666; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_668 = _ctr_signals_T_37 ? 8'h0 : _ctr_signals_T_667; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_669 = _ctr_signals_T_35 ? 8'h0 : _ctr_signals_T_668; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_670 = _ctr_signals_T_33 ? 8'h0 : _ctr_signals_T_669; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_671 = _ctr_signals_T_31 ? 8'h0 : _ctr_signals_T_670; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_672 = _ctr_signals_T_29 ? 8'h0 : _ctr_signals_T_671; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_673 = _ctr_signals_T_27 ? 8'h0 : _ctr_signals_T_672; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_674 = _ctr_signals_T_25 ? 8'h0 : _ctr_signals_T_673; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_675 = _ctr_signals_T_23 ? 8'h0 : _ctr_signals_T_674; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_676 = _ctr_signals_T_21 ? 8'h0 : _ctr_signals_T_675; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_677 = _ctr_signals_T_19 ? 8'h0 : _ctr_signals_T_676; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_678 = _ctr_signals_T_17 ? 8'h0 : _ctr_signals_T_677; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_679 = _ctr_signals_T_15 ? 8'h0 : _ctr_signals_T_678; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_680 = _ctr_signals_T_13 ? 8'h0 : _ctr_signals_T_679; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_681 = _ctr_signals_T_11 ? 8'h0 : _ctr_signals_T_680; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_682 = _ctr_signals_T_9 ? 8'h0 : _ctr_signals_T_681; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_683 = _ctr_signals_T_7 ? 8'h0 : _ctr_signals_T_682; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_684 = _ctr_signals_T_5 ? 8'h0 : _ctr_signals_T_683; // @[Lookup.scala 33:37]
  wire [7:0] _ctr_signals_T_685 = _ctr_signals_T_3 ? 8'h0 : _ctr_signals_T_684; // @[Lookup.scala 33:37]
  wire [7:0] csrop = _ctr_signals_T_1 ? 8'h0 : _ctr_signals_T_685; // @[Lookup.scala 33:37]
  wire [63:0] _imm_T_8 = ctr_signals_3[0] ? imm_i : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _imm_T_9 = ctr_signals_3[1] ? imm_s : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _imm_T_10 = ctr_signals_3[2] ? imm_b : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _imm_T_11 = ctr_signals_3[3] ? imm_u : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _imm_T_12 = ctr_signals_3[4] ? imm_j : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _imm_T_13 = ctr_signals_3[5] ? 64'h4 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _imm_T_15 = _imm_T_8 | _imm_T_9; // @[Mux.scala 27:72]
  wire [63:0] _imm_T_16 = _imm_T_15 | _imm_T_10; // @[Mux.scala 27:72]
  wire [63:0] _imm_T_17 = _imm_T_16 | _imm_T_11; // @[Mux.scala 27:72]
  wire [63:0] _imm_T_18 = _imm_T_17 | _imm_T_12; // @[Mux.scala 27:72]
  wire [63:0] imm = _imm_T_18 | _imm_T_13; // @[Mux.scala 27:72]
  wire  _eq1_w_T_1 = io_fwd_wb_dst != 5'h0; // @[Decode.scala 175:64]
  wire  eq1_w = io_fwd_wb_dst == rs1_addr & io_fwd_wb_dst != 5'h0 & io_fwd_wb_rf_w; // @[Decode.scala 175:73]
  wire  eq2_w = io_fwd_wb_dst == rs2 & _eq1_w_T_1 & io_fwd_wb_rf_w; // @[Decode.scala 179:73]
  wire  _rs1_data_T_1 = ~eq1_e; // @[Decode.scala 187:22]
  wire  _rs1_data_T_2 = ~eq1_l; // @[Decode.scala 187:32]
  wire  _rs1_data_T_5 = ~eq1_e & ~eq1_l & ~eq1_w; // @[Decode.scala 187:39]
  wire  _rs1_data_T_8 = eq1_l & _rs1_data_T_1; // @[Decode.scala 189:16]
  wire  _rs1_data_T_12 = eq1_w & _rs1_data_T_2 & _rs1_data_T_1; // @[Decode.scala 190:26]
  wire [63:0] _rs1_data_T_20 = eq1_e ? io_fwd_ex_alu_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rs1_data_T_21 = _rs1_data_T_8 ? io_fwd_lsu_lsu_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rs1_data_T_22 = _rs1_data_T_12 ? io_fwd_wb_wb_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rs1_data_T_23 = _rs1_data_T_5 ? io_rs1_data : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rs1_data_T_25 = _rs1_data_T_20 | _rs1_data_T_21; // @[Mux.scala 27:72]
  wire [63:0] _rs1_data_T_26 = _rs1_data_T_25 | _rs1_data_T_22; // @[Mux.scala 27:72]
  wire [63:0] rs1_data = _rs1_data_T_26 | _rs1_data_T_23; // @[Mux.scala 27:72]
  wire  _rs2_data_T_1 = ~eq2_e; // @[Decode.scala 197:22]
  wire  _rs2_data_T_2 = ~eq2_l; // @[Decode.scala 197:32]
  wire  _rs2_data_T_5 = ~eq2_e & ~eq2_l & ~eq2_w; // @[Decode.scala 197:39]
  wire  _rs2_data_T_8 = eq2_l & _rs2_data_T_1; // @[Decode.scala 199:16]
  wire  _rs2_data_T_12 = eq2_w & _rs2_data_T_2 & _rs2_data_T_1; // @[Decode.scala 200:26]
  wire [63:0] _rs2_data_T_20 = eq2_e ? io_fwd_ex_alu_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rs2_data_T_21 = _rs2_data_T_8 ? io_fwd_lsu_lsu_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rs2_data_T_22 = _rs2_data_T_12 ? io_fwd_wb_wb_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rs2_data_T_23 = _rs2_data_T_5 ? io_rs2_data : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rs2_data_T_25 = _rs2_data_T_20 | _rs2_data_T_21; // @[Mux.scala 27:72]
  wire [63:0] _rs2_data_T_26 = _rs2_data_T_25 | _rs2_data_T_22; // @[Mux.scala 27:72]
  wire [63:0] rs2_data = _rs2_data_T_26 | _rs2_data_T_23; // @[Mux.scala 27:72]
  wire [63:0] _io_id_to_ex_out1_T_4 = ctr_signals_1[0] ? rs1_data : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _io_id_to_ex_out1_T_5 = ctr_signals_1[1] ? io_if_to_id_pc : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _io_id_to_ex_out2_T_4 = ctr_signals_2[0] ? rs2_data : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _io_id_to_ex_out2_T_5 = ctr_signals_2[1] ? imm : 64'h0; // @[Mux.scala 27:72]
  wire  load = ctr_signals_7[0] | ctr_signals_7[1] | ctr_signals_7[2] | ctr_signals_7[3] | ctr_signals_7[4] |
    ctr_signals_8[9] | ctr_signals_8[10]; // @[Mux.scala 27:72]
  wire  save = ctr_signals_7[5] | ctr_signals_7[6] | ctr_signals_7[7] | ctr_signals_8[11]; // @[Mux.scala 27:72]
  wire  is_br = bruop[2] | bruop[3] | bruop[4] | bruop[5] | bruop[6] | bruop[7]; // @[Mux.scala 27:72]
  wire [63:0] jal_target = io_if_to_id_pc + imm_j; // @[Decode.scala 265:25]
  wire [63:0] jalr_target = rs1_data + imm_i; // @[Decode.scala 266:32]
  wire [63:0] br_target = io_if_to_id_pc + imm_b; // @[Decode.scala 267:24]
  wire  _jump_T_5 = bruop[3] & rs1_data == rs2_data; // @[Decode.scala 278:14]
  wire  _jump_T_6 = bruop[2] & rs1_data != rs2_data | _jump_T_5; // @[Decode.scala 277:43]
  wire [63:0] _jump_T_7 = _rs1_data_T_26 | _rs1_data_T_23; // @[Decode.scala 279:34]
  wire [63:0] _jump_T_8 = _rs2_data_T_26 | _rs2_data_T_23; // @[Decode.scala 279:54]
  wire  _jump_T_10 = bruop[4] & $signed(_jump_T_7) < $signed(_jump_T_8); // @[Decode.scala 279:14]
  wire  _jump_T_11 = _jump_T_6 | _jump_T_10; // @[Decode.scala 278:43]
  wire  _jump_T_13 = bruop[6] & rs1_data < rs2_data; // @[Decode.scala 280:15]
  wire  _jump_T_14 = _jump_T_11 | _jump_T_13; // @[Decode.scala 279:59]
  wire  _jump_T_18 = bruop[5] & $signed(_jump_T_7) >= $signed(_jump_T_8); // @[Decode.scala 281:14]
  wire  _jump_T_19 = _jump_T_14 | _jump_T_18; // @[Decode.scala 280:59]
  wire  _jump_T_21 = bruop[7] & rs1_data >= rs2_data; // @[Decode.scala 282:15]
  wire  _jump_T_22 = _jump_T_19 | _jump_T_21; // @[Decode.scala 281:60]
  wire  _jump_T_23 = bruop[0] | bruop[1] | io_csr_to_id_csr_jump | _jump_T_22; // @[Decode.scala 276:49]
  wire  jump = _jump_T_23 & io_ds_valid; // @[Decode.scala 283:8]
  wire  _pc_target_T_1 = is_br & ~jump; // @[Decode.scala 289:14]
  wire [63:0] _pc_target_T_2 = bruop[0] ? jal_target : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_3 = bruop[1] ? jalr_target : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_4 = is_br ? br_target : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_5 = _pc_target_T_1 ? 64'h80000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_6 = _pc_target_T_2 | _pc_target_T_3; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_7 = _pc_target_T_6 | _pc_target_T_4; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_8 = _pc_target_T_7 | _pc_target_T_5; // @[Mux.scala 27:72]
  wire  _io_id_to_ex_rf_w_T_3 = ~io_csr_to_id_csr_jump; // @[Decode.scala 293:44]
  wire  is_csr = ctr_signals_4 == 5'h10; // @[Decode.scala 310:26]
  wire  _is_zimm_T = ~is_csr; // @[Decode.scala 312:7]
  wire  _is_zimm_T_4 = csrop == 8'h4; // @[Decode.scala 316:14]
  wire  _is_zimm_T_5 = csrop == 8'h5; // @[Decode.scala 317:14]
  wire  _is_zimm_T_6 = csrop == 8'h6; // @[Decode.scala 318:14]
  wire  is_zimm = _is_zimm_T_4 | _is_zimm_T_5 | _is_zimm_T_6; // @[Mux.scala 27:72]
  wire [63:0] _io_id_to_ex_csr_src_T = {59'h0,rs1}; // @[Cat.scala 30:58]
  wire  _io_id_to_ex_inst_T_1 = io_intr_flush | ~ds_to_es_valid; // @[Decode.scala 328:43]
  wire [63:0] _io_id_to_ex_inst_T_2 = io_intr_flush | ~ds_to_es_valid ? 64'h13 : {{32'd0}, io_if_to_id_inst}; // @[Decode.scala 328:28]
  assign io_ds_allowin = ~io_ds_valid | ds_ready_go & io_es_allowin; // @[Decode.scala 40:27]
  assign io_ds_to_es_valid = io_ds_valid & ds_ready_go; // @[Decode.scala 41:30]
  assign io_id_to_ex_is_nop = _io_id_to_ex_inst_T_1 | io_if_to_id_is_nop; // @[Decode.scala 332:30]
  assign io_id_to_ex_aluop = _ctr_signals_T_1 ? 11'h1 : _ctr_signals_T_457; // @[Lookup.scala 33:37]
  assign io_id_to_ex_lsuop = _ctr_signals_T_1 ? 8'h0 : _ctr_signals_T_571; // @[Lookup.scala 33:37]
  assign io_id_to_ex_rv64op = _ctr_signals_T_1 ? 12'h0 : _ctr_signals_T_628; // @[Lookup.scala 33:37]
  assign io_id_to_ex_out1 = _io_id_to_ex_out1_T_4 | _io_id_to_ex_out1_T_5; // @[Mux.scala 27:72]
  assign io_id_to_ex_out2 = _io_id_to_ex_out2_T_4 | _io_id_to_ex_out2_T_5; // @[Mux.scala 27:72]
  assign io_id_to_ex_imm = _imm_T_18 | _imm_T_13; // @[Mux.scala 27:72]
  assign io_id_to_ex_dest = is_putch ? 5'h0 : rd; // @[Decode.scala 217:28]
  assign io_id_to_ex_rf_w = ~save & ~is_br & ~io_csr_to_id_csr_jump; // @[Decode.scala 293:41]
  assign io_id_to_ex_load = load & _io_id_to_ex_rf_w_T_3; // @[Decode.scala 294:30]
  assign io_id_to_ex_save = save & _io_id_to_ex_rf_w_T_3; // @[Decode.scala 295:30]
  assign io_id_to_ex_pc = io_if_to_id_pc; // @[Decode.scala 327:20]
  assign io_id_to_ex_inst = _io_id_to_ex_inst_T_2[31:0]; // @[Decode.scala 328:22]
  assign io_id_to_ex_is_csr = ctr_signals_4 == 5'h10; // @[Decode.scala 310:26]
  assign io_id_to_ex_csrop = _ctr_signals_T_1 ? 8'h0 : _ctr_signals_T_685; // @[Lookup.scala 33:37]
  assign io_id_to_ex_csr_addr = is_csr & io_ds_valid ? io_if_to_id_inst[31:20] : 12'h0; // @[Decode.scala 324:32]
  assign io_id_to_ex_csr_src = is_zimm ? _io_id_to_ex_csr_src_T : rs1_data; // @[Decode.scala 323:31]
  assign io_id_to_ex_is_zero = rs1 == 5'h0 | _is_zimm_T; // @[Decode.scala 325:43]
  assign io_id_to_if_pc_target = io_csr_to_id_csr_jump ? io_csr_to_id_csr_target : _pc_target_T_8; // @[Decode.scala 284:24]
  assign io_id_to_if_jump = _jump_T_23 & io_ds_valid; // @[Decode.scala 283:8]
  assign io_rs1_addr = is_putch ? 5'ha : rs1; // @[Decode.scala 151:23]
  assign io_rs2_addr = io_if_to_id_inst[24:20]; // @[Decode.scala 54:20]
  assign io_intr_flush = io_csr_to_id_csr_jump; // @[Decode.scala 330:19]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (is_putch & ~reset) begin
          $fwrite(32'h80000002,"%c",rs1_data); // @[Decode.scala 306:13]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module ER(
  input         clock,
  input         reset,
  input         io_ds_to_es_valid,
  output        io_es_valid,
  input         io_es_allowin,
  input         io_id_to_er_is_nop,
  input  [10:0] io_id_to_er_aluop,
  input  [7:0]  io_id_to_er_lsuop,
  input  [11:0] io_id_to_er_rv64op,
  input  [63:0] io_id_to_er_out1,
  input  [63:0] io_id_to_er_out2,
  input  [63:0] io_id_to_er_imm,
  input  [4:0]  io_id_to_er_dest,
  input         io_id_to_er_rf_w,
  input         io_id_to_er_load,
  input         io_id_to_er_save,
  input  [63:0] io_id_to_er_pc,
  input  [31:0] io_id_to_er_inst,
  input         io_id_to_er_is_csr,
  input  [7:0]  io_id_to_er_csrop,
  input  [11:0] io_id_to_er_csr_addr,
  input  [63:0] io_id_to_er_csr_src,
  input         io_id_to_er_is_zero,
  output        io_er_to_ex_is_nop,
  output [10:0] io_er_to_ex_aluop,
  output [7:0]  io_er_to_ex_lsuop,
  output [11:0] io_er_to_ex_rv64op,
  output [63:0] io_er_to_ex_out1,
  output [63:0] io_er_to_ex_out2,
  output [63:0] io_er_to_ex_imm,
  output [4:0]  io_er_to_ex_dest,
  output        io_er_to_ex_rf_w,
  output        io_er_to_ex_load,
  output        io_er_to_ex_save,
  output [63:0] io_er_to_ex_pc,
  output [31:0] io_er_to_ex_inst,
  output        io_er_to_ex_is_csr,
  output [7:0]  io_er_to_ex_csrop,
  output [11:0] io_er_to_ex_csr_addr,
  output [63:0] io_er_to_ex_csr_src,
  output        io_er_to_ex_is_zero
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [63:0] _RAND_7;
  reg [63:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [63:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [63:0] _RAND_17;
  reg [31:0] _RAND_18;
`endif // RANDOMIZE_REG_INIT
  wire  judg = io_ds_to_es_valid & io_es_allowin; // @[er.scala 17:32]
  reg  io_es_valid_r; // @[Reg.scala 27:20]
  wire  _GEN_0 = io_es_allowin ? io_ds_to_es_valid : io_es_valid_r; // @[Reg.scala 28:19 Reg.scala 28:23 Reg.scala 27:20]
  reg  io_er_to_ex_is_nop_r; // @[Reg.scala 27:20]
  reg [10:0] io_er_to_ex_aluop_r; // @[Reg.scala 27:20]
  reg [7:0] io_er_to_ex_lsuop_r; // @[Reg.scala 27:20]
  reg [11:0] io_er_to_ex_rv64op_r; // @[Reg.scala 27:20]
  reg  io_er_to_ex_is_csr_r; // @[Reg.scala 27:20]
  reg [63:0] io_er_to_ex_out1_r; // @[Reg.scala 27:20]
  reg [63:0] io_er_to_ex_out2_r; // @[Reg.scala 27:20]
  reg [63:0] io_er_to_ex_imm_r; // @[Reg.scala 27:20]
  reg [4:0] io_er_to_ex_dest_r; // @[Reg.scala 27:20]
  reg  io_er_to_ex_rf_w_r; // @[Reg.scala 27:20]
  reg  io_er_to_ex_load_r; // @[Reg.scala 27:20]
  reg  io_er_to_ex_save_r; // @[Reg.scala 27:20]
  reg [63:0] io_er_to_ex_pc_r; // @[Reg.scala 27:20]
  reg [31:0] io_er_to_ex_inst_r; // @[Reg.scala 27:20]
  reg [7:0] io_er_to_ex_csrop_r; // @[Reg.scala 27:20]
  reg [11:0] io_er_to_ex_csr_addr_r; // @[Reg.scala 27:20]
  reg [63:0] io_er_to_ex_csr_src_r; // @[Reg.scala 27:20]
  reg  io_er_to_ex_is_zero_r; // @[Reg.scala 27:20]
  assign io_es_valid = io_es_valid_r; // @[er.scala 18:15]
  assign io_er_to_ex_is_nop = io_er_to_ex_is_nop_r; // @[er.scala 20:22]
  assign io_er_to_ex_aluop = io_er_to_ex_aluop_r; // @[er.scala 22:21]
  assign io_er_to_ex_lsuop = io_er_to_ex_lsuop_r; // @[er.scala 23:21]
  assign io_er_to_ex_rv64op = io_er_to_ex_rv64op_r; // @[er.scala 24:22]
  assign io_er_to_ex_out1 = io_er_to_ex_out1_r; // @[er.scala 28:20]
  assign io_er_to_ex_out2 = io_er_to_ex_out2_r; // @[er.scala 29:20]
  assign io_er_to_ex_imm = io_er_to_ex_imm_r; // @[er.scala 31:19]
  assign io_er_to_ex_dest = io_er_to_ex_dest_r; // @[er.scala 33:20]
  assign io_er_to_ex_rf_w = io_er_to_ex_rf_w_r; // @[er.scala 34:20]
  assign io_er_to_ex_load = io_er_to_ex_load_r; // @[er.scala 35:20]
  assign io_er_to_ex_save = io_er_to_ex_save_r; // @[er.scala 36:20]
  assign io_er_to_ex_pc = io_er_to_ex_pc_r; // @[er.scala 38:18]
  assign io_er_to_ex_inst = io_er_to_ex_inst_r; // @[er.scala 39:20]
  assign io_er_to_ex_is_csr = io_er_to_ex_is_csr_r; // @[er.scala 26:22]
  assign io_er_to_ex_csrop = io_er_to_ex_csrop_r; // @[er.scala 41:21]
  assign io_er_to_ex_csr_addr = io_er_to_ex_csr_addr_r; // @[er.scala 42:24]
  assign io_er_to_ex_csr_src = io_er_to_ex_csr_src_r; // @[er.scala 43:23]
  assign io_er_to_ex_is_zero = io_er_to_ex_is_zero_r; // @[er.scala 44:23]
  always @(posedge clock) begin
    io_es_valid_r <= reset | _GEN_0; // @[Reg.scala 27:20 Reg.scala 27:20]
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_is_nop_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (io_es_allowin) begin // @[Reg.scala 28:19]
      io_er_to_ex_is_nop_r <= io_id_to_er_is_nop; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_aluop_r <= 11'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_aluop_r <= io_id_to_er_aluop; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_lsuop_r <= 8'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_lsuop_r <= io_id_to_er_lsuop; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_rv64op_r <= 12'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_rv64op_r <= io_id_to_er_rv64op; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_is_csr_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_is_csr_r <= io_id_to_er_is_csr; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_out1_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_out1_r <= io_id_to_er_out1; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_out2_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_out2_r <= io_id_to_er_out2; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_imm_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_imm_r <= io_id_to_er_imm; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_dest_r <= 5'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_dest_r <= io_id_to_er_dest; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_rf_w_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_rf_w_r <= io_id_to_er_rf_w; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_load_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_load_r <= io_id_to_er_load; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_save_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_save_r <= io_id_to_er_save; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_pc_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (io_es_allowin) begin // @[Reg.scala 28:19]
      io_er_to_ex_pc_r <= io_id_to_er_pc; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_inst_r <= 32'h0; // @[Reg.scala 27:20]
    end else if (io_es_allowin) begin // @[Reg.scala 28:19]
      io_er_to_ex_inst_r <= io_id_to_er_inst; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_csrop_r <= 8'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_csrop_r <= io_id_to_er_csrop; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_csr_addr_r <= 12'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_csr_addr_r <= io_id_to_er_csr_addr; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_csr_src_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_csr_src_r <= io_id_to_er_csr_src; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_er_to_ex_is_zero_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_er_to_ex_is_zero_r <= io_id_to_er_is_zero; // @[Reg.scala 28:23]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  io_es_valid_r = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  io_er_to_ex_is_nop_r = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  io_er_to_ex_aluop_r = _RAND_2[10:0];
  _RAND_3 = {1{`RANDOM}};
  io_er_to_ex_lsuop_r = _RAND_3[7:0];
  _RAND_4 = {1{`RANDOM}};
  io_er_to_ex_rv64op_r = _RAND_4[11:0];
  _RAND_5 = {1{`RANDOM}};
  io_er_to_ex_is_csr_r = _RAND_5[0:0];
  _RAND_6 = {2{`RANDOM}};
  io_er_to_ex_out1_r = _RAND_6[63:0];
  _RAND_7 = {2{`RANDOM}};
  io_er_to_ex_out2_r = _RAND_7[63:0];
  _RAND_8 = {2{`RANDOM}};
  io_er_to_ex_imm_r = _RAND_8[63:0];
  _RAND_9 = {1{`RANDOM}};
  io_er_to_ex_dest_r = _RAND_9[4:0];
  _RAND_10 = {1{`RANDOM}};
  io_er_to_ex_rf_w_r = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  io_er_to_ex_load_r = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  io_er_to_ex_save_r = _RAND_12[0:0];
  _RAND_13 = {2{`RANDOM}};
  io_er_to_ex_pc_r = _RAND_13[63:0];
  _RAND_14 = {1{`RANDOM}};
  io_er_to_ex_inst_r = _RAND_14[31:0];
  _RAND_15 = {1{`RANDOM}};
  io_er_to_ex_csrop_r = _RAND_15[7:0];
  _RAND_16 = {1{`RANDOM}};
  io_er_to_ex_csr_addr_r = _RAND_16[11:0];
  _RAND_17 = {2{`RANDOM}};
  io_er_to_ex_csr_src_r = _RAND_17[63:0];
  _RAND_18 = {1{`RANDOM}};
  io_er_to_ex_is_zero_r = _RAND_18[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Execution(
  input         io_ls_allowin,
  input         io_es_valid,
  output        io_es_allowin,
  output        io_es_to_ls_valid,
  input         io_id_to_ex_is_nop,
  input  [10:0] io_id_to_ex_aluop,
  input  [7:0]  io_id_to_ex_lsuop,
  input  [11:0] io_id_to_ex_rv64op,
  input  [63:0] io_id_to_ex_out1,
  input  [63:0] io_id_to_ex_out2,
  input  [63:0] io_id_to_ex_imm,
  input  [4:0]  io_id_to_ex_dest,
  input         io_id_to_ex_rf_w,
  input         io_id_to_ex_load,
  input         io_id_to_ex_save,
  input  [63:0] io_id_to_ex_pc,
  input  [31:0] io_id_to_ex_inst,
  input         io_id_to_ex_is_csr,
  input  [7:0]  io_id_to_ex_csrop,
  input  [11:0] io_id_to_ex_csr_addr,
  input  [63:0] io_id_to_ex_csr_src,
  input         io_id_to_ex_is_zero,
  output        io_ex_to_lsu_is_nop,
  output [63:0] io_ex_to_lsu_alu_res,
  output [63:0] io_ex_to_lsu_src1,
  output [63:0] io_ex_to_lsu_src2,
  output [63:0] io_ex_to_lsu_imm,
  output [7:0]  io_ex_to_lsu_lsuop,
  output [11:0] io_ex_to_lsu_rv64op,
  output [4:0]  io_ex_to_lsu_dest,
  output        io_ex_to_lsu_rf_w,
  output        io_ex_to_lsu_load,
  output        io_ex_to_lsu_save,
  output [63:0] io_ex_to_lsu_pc,
  output [31:0] io_ex_to_lsu_inst,
  output        io_ex_to_lsu_is_csr,
  output [7:0]  io_ex_to_lsu_csrop,
  output [11:0] io_ex_to_lsu_csr_addr,
  output [63:0] io_ex_to_lsu_csr_src,
  output        io_ex_to_lsu_is_zero,
  output        io_ex_fwd_rf_w,
  output [4:0]  io_ex_fwd_dst,
  output [63:0] io_ex_fwd_alu_res,
  output        io_ex_fwd_is_csr,
  output        io_ex_fwd_load,
  input         io_flush
);
  wire  _es_allowin_T = ~io_es_valid; // @[Execution.scala 27:17]
  wire  is_w = io_id_to_ex_rv64op[0] | io_id_to_ex_rv64op[1] | io_id_to_ex_rv64op[2] | io_id_to_ex_rv64op[3] |
    io_id_to_ex_rv64op[4] | io_id_to_ex_rv64op[5] | io_id_to_ex_rv64op[6] | io_id_to_ex_rv64op[7] | io_id_to_ex_rv64op[8
    ]; // @[Mux.scala 27:72]
  wire [31:0] src1_32 = io_id_to_ex_out1[31:0]; // @[Execution.scala 76:24]
  wire [31:0] lui_res_32 = io_id_to_ex_out2[31:0]; // @[Execution.scala 77:24]
  wire  i_add = io_id_to_ex_aluop[0]; // @[Execution.scala 79:20]
  wire  i_slt = io_id_to_ex_aluop[1]; // @[Execution.scala 80:20]
  wire  i_sltu = io_id_to_ex_aluop[2]; // @[Execution.scala 81:21]
  wire  i_and = io_id_to_ex_aluop[3]; // @[Execution.scala 82:20]
  wire  i_or = io_id_to_ex_aluop[4]; // @[Execution.scala 83:19]
  wire  i_xor = io_id_to_ex_aluop[5]; // @[Execution.scala 84:20]
  wire  i_sll = io_id_to_ex_aluop[6]; // @[Execution.scala 85:20]
  wire  i_srl = io_id_to_ex_aluop[7]; // @[Execution.scala 86:20]
  wire  i_sra = io_id_to_ex_aluop[8]; // @[Execution.scala 87:20]
  wire  i_lui = io_id_to_ex_aluop[9]; // @[Execution.scala 88:20]
  wire  i_sub = io_id_to_ex_aluop[10]; // @[Execution.scala 89:20]
  wire [63:0] add_res_64 = io_id_to_ex_out1 + io_id_to_ex_out2; // @[Execution.scala 91:28]
  wire [63:0] slt_res_64 = $signed(io_id_to_ex_out1) < $signed(io_id_to_ex_out2) ? 64'h1 : 64'h0; // @[Execution.scala 94:9]
  wire [63:0] sltu_res_64 = io_id_to_ex_out1 < io_id_to_ex_out2 ? 64'h1 : 64'h0; // @[Execution.scala 96:24]
  wire [63:0] and_res_64 = io_id_to_ex_out1 & io_id_to_ex_out2; // @[Execution.scala 98:28]
  wire [63:0] or_res_64 = io_id_to_ex_out1 | io_id_to_ex_out2; // @[Execution.scala 100:27]
  wire [63:0] xor_res_64 = io_id_to_ex_out1 ^ io_id_to_ex_out2; // @[Execution.scala 102:28]
  wire [63:0] sub_res_64 = io_id_to_ex_out1 - io_id_to_ex_out2; // @[Execution.scala 106:28]
  wire [126:0] _GEN_0 = {{63'd0}, io_id_to_ex_out1}; // @[Execution.scala 109:37]
  wire [126:0] sll_res_64 = _GEN_0 << io_id_to_ex_out2[5:0]; // @[Execution.scala 109:37]
  wire [62:0] _GEN_1 = {{31'd0}, src1_32}; // @[Execution.scala 110:37]
  wire [62:0] sll_res_32 = _GEN_1 << lui_res_32[4:0]; // @[Execution.scala 110:37]
  wire [63:0] srl_res_64 = io_id_to_ex_out1 >> io_id_to_ex_out2[5:0]; // @[Execution.scala 113:37]
  wire [31:0] srl_res_32 = src1_32 >> lui_res_32[4:0]; // @[Execution.scala 114:37]
  wire [63:0] sra_res_64 = $signed(io_id_to_ex_out1) >>> io_id_to_ex_out2[5:0]; // @[Execution.scala 117:62]
  wire [31:0] _sra_res_32_T = io_id_to_ex_out1[31:0]; // @[Execution.scala 118:35]
  wire [31:0] sra_res_32 = $signed(_sra_res_32_T) >>> lui_res_32[4:0]; // @[Execution.scala 118:62]
  wire [63:0] _alu_res_64_T_2 = i_add ? add_res_64 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_3 = i_slt ? slt_res_64 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_4 = i_sltu ? sltu_res_64 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_5 = i_and ? and_res_64 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_6 = i_or ? or_res_64 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_7 = i_xor ? xor_res_64 : 64'h0; // @[Mux.scala 27:72]
  wire [126:0] _alu_res_64_T_8 = i_sll ? sll_res_64 : 127'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_9 = i_srl ? srl_res_64 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_10 = i_sra ? sra_res_64 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_11 = i_lui ? io_id_to_ex_out2 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_12 = i_sub ? sub_res_64 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_14 = _alu_res_64_T_2 | _alu_res_64_T_3; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_15 = _alu_res_64_T_14 | _alu_res_64_T_4; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_16 = _alu_res_64_T_15 | _alu_res_64_T_5; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_17 = _alu_res_64_T_16 | _alu_res_64_T_6; // @[Mux.scala 27:72]
  wire [63:0] _alu_res_64_T_18 = _alu_res_64_T_17 | _alu_res_64_T_7; // @[Mux.scala 27:72]
  wire [126:0] _GEN_2 = {{63'd0}, _alu_res_64_T_18}; // @[Mux.scala 27:72]
  wire [126:0] _alu_res_64_T_19 = _GEN_2 | _alu_res_64_T_8; // @[Mux.scala 27:72]
  wire [126:0] _GEN_3 = {{63'd0}, _alu_res_64_T_9}; // @[Mux.scala 27:72]
  wire [126:0] _alu_res_64_T_20 = _alu_res_64_T_19 | _GEN_3; // @[Mux.scala 27:72]
  wire [126:0] _GEN_4 = {{63'd0}, _alu_res_64_T_10}; // @[Mux.scala 27:72]
  wire [126:0] _alu_res_64_T_21 = _alu_res_64_T_20 | _GEN_4; // @[Mux.scala 27:72]
  wire [126:0] _GEN_5 = {{63'd0}, _alu_res_64_T_11}; // @[Mux.scala 27:72]
  wire [126:0] _alu_res_64_T_22 = _alu_res_64_T_21 | _GEN_5; // @[Mux.scala 27:72]
  wire [126:0] _GEN_6 = {{63'd0}, _alu_res_64_T_12}; // @[Mux.scala 27:72]
  wire [126:0] alu_res_64 = _alu_res_64_T_22 | _GEN_6; // @[Mux.scala 27:72]
  wire [31:0] add_res_32 = src1_32 + lui_res_32; // @[Execution.scala 138:28]
  wire [31:0] _slt_res_32_T_1 = io_id_to_ex_out2[31:0]; // @[Execution.scala 141:43]
  wire [31:0] slt_res_32 = $signed(_sra_res_32_T) < $signed(_slt_res_32_T_1) ? 32'h1 : 32'h0; // @[Execution.scala 141:9]
  wire [31:0] sltu_res_32 = src1_32 < lui_res_32 ? 32'h1 : 32'h0; // @[Execution.scala 143:24]
  wire [31:0] and_res_32 = src1_32 & lui_res_32; // @[Execution.scala 145:28]
  wire [31:0] or_res_32 = src1_32 | lui_res_32; // @[Execution.scala 147:27]
  wire [31:0] xor_res_32 = src1_32 ^ lui_res_32; // @[Execution.scala 149:28]
  wire [31:0] sub_res_32 = src1_32 - lui_res_32; // @[Execution.scala 153:28]
  wire [31:0] _alu_res_32_T_2 = i_add ? add_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_3 = i_slt ? slt_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_4 = i_sltu ? sltu_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_5 = i_and ? and_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_6 = i_or ? or_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_7 = i_xor ? xor_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [62:0] _alu_res_32_T_8 = i_sll ? sll_res_32 : 63'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_9 = i_srl ? srl_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_10 = i_sra ? sra_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_11 = i_lui ? lui_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_12 = i_sub ? sub_res_32 : 32'h0; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_14 = _alu_res_32_T_2 | _alu_res_32_T_3; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_15 = _alu_res_32_T_14 | _alu_res_32_T_4; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_16 = _alu_res_32_T_15 | _alu_res_32_T_5; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_17 = _alu_res_32_T_16 | _alu_res_32_T_6; // @[Mux.scala 27:72]
  wire [31:0] _alu_res_32_T_18 = _alu_res_32_T_17 | _alu_res_32_T_7; // @[Mux.scala 27:72]
  wire [62:0] _GEN_7 = {{31'd0}, _alu_res_32_T_18}; // @[Mux.scala 27:72]
  wire [62:0] _alu_res_32_T_19 = _GEN_7 | _alu_res_32_T_8; // @[Mux.scala 27:72]
  wire [62:0] _GEN_8 = {{31'd0}, _alu_res_32_T_9}; // @[Mux.scala 27:72]
  wire [62:0] _alu_res_32_T_20 = _alu_res_32_T_19 | _GEN_8; // @[Mux.scala 27:72]
  wire [62:0] _GEN_9 = {{31'd0}, _alu_res_32_T_10}; // @[Mux.scala 27:72]
  wire [62:0] _alu_res_32_T_21 = _alu_res_32_T_20 | _GEN_9; // @[Mux.scala 27:72]
  wire [62:0] _GEN_10 = {{31'd0}, _alu_res_32_T_11}; // @[Mux.scala 27:72]
  wire [62:0] _alu_res_32_T_22 = _alu_res_32_T_21 | _GEN_10; // @[Mux.scala 27:72]
  wire [62:0] _GEN_11 = {{31'd0}, _alu_res_32_T_12}; // @[Mux.scala 27:72]
  wire [62:0] alu_res_32 = _alu_res_32_T_22 | _GEN_11; // @[Mux.scala 27:72]
  wire [31:0] alu_res_hi = alu_res_32[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 72:12]
  wire [31:0] alu_res_lo = alu_res_32[31:0]; // @[Execution.scala 173:55]
  wire [63:0] _alu_res_T_2 = {alu_res_hi,alu_res_lo}; // @[Cat.scala 30:58]
  wire [126:0] alu_res = is_w ? {{63'd0}, _alu_res_T_2} : alu_res_64; // @[Execution.scala 173:8]
  wire  _io_ex_to_lsu_inst_T_1 = io_flush | _es_allowin_T; // @[Execution.scala 186:37]
  wire [63:0] _io_ex_to_lsu_inst_T_2 = io_flush | _es_allowin_T ? 64'h13 : {{32'd0}, io_id_to_ex_inst}; // @[Execution.scala 186:27]
  assign io_es_allowin = ~io_es_valid | io_ls_allowin; // @[Execution.scala 27:27]
  assign io_es_to_ls_valid = io_es_valid; // @[Execution.scala 28:30]
  assign io_ex_to_lsu_is_nop = _io_ex_to_lsu_inst_T_1 | io_id_to_ex_is_nop; // @[Execution.scala 194:29]
  assign io_ex_to_lsu_alu_res = alu_res[63:0]; // @[Execution.scala 175:24]
  assign io_ex_to_lsu_src1 = io_id_to_ex_out1; // @[Execution.scala 54:21]
  assign io_ex_to_lsu_src2 = io_id_to_ex_out2; // @[Execution.scala 55:21]
  assign io_ex_to_lsu_imm = io_id_to_ex_imm; // @[Execution.scala 56:20]
  assign io_ex_to_lsu_lsuop = io_id_to_ex_lsuop; // @[Execution.scala 40:22]
  assign io_ex_to_lsu_rv64op = io_id_to_ex_rv64op; // @[Execution.scala 41:23]
  assign io_ex_to_lsu_dest = io_id_to_ex_dest; // @[Execution.scala 43:21]
  assign io_ex_to_lsu_rf_w = io_id_to_ex_rf_w; // @[Execution.scala 45:21]
  assign io_ex_to_lsu_load = io_id_to_ex_load; // @[Execution.scala 48:21]
  assign io_ex_to_lsu_save = io_id_to_ex_save; // @[Execution.scala 49:21]
  assign io_ex_to_lsu_pc = io_id_to_ex_pc; // @[Execution.scala 185:19]
  assign io_ex_to_lsu_inst = _io_ex_to_lsu_inst_T_2[31:0]; // @[Execution.scala 186:21]
  assign io_ex_to_lsu_is_csr = io_id_to_ex_is_csr; // @[Execution.scala 188:23]
  assign io_ex_to_lsu_csrop = io_id_to_ex_csrop; // @[Execution.scala 189:22]
  assign io_ex_to_lsu_csr_addr = io_id_to_ex_csr_addr; // @[Execution.scala 190:25]
  assign io_ex_to_lsu_csr_src = io_id_to_ex_csr_src; // @[Execution.scala 191:24]
  assign io_ex_to_lsu_is_zero = io_id_to_ex_is_zero; // @[Execution.scala 192:24]
  assign io_ex_fwd_rf_w = _es_allowin_T ? 1'h0 : io_id_to_ex_rf_w; // @[Execution.scala 177:24]
  assign io_ex_fwd_dst = io_id_to_ex_dest; // @[Execution.scala 178:17]
  assign io_ex_fwd_alu_res = alu_res[63:0]; // @[Execution.scala 179:21]
  assign io_ex_fwd_is_csr = _es_allowin_T ? 1'h0 : io_id_to_ex_is_csr; // @[Execution.scala 180:26]
  assign io_ex_fwd_load = _es_allowin_T ? 1'h0 : io_id_to_ex_load; // @[Execution.scala 181:24]
endmodule
module LR(
  input         clock,
  input         reset,
  input         io_es_to_ls_valid,
  output        io_ls_valid,
  input         io_ls_allowin,
  input         io_ex_to_lr_is_nop,
  input  [63:0] io_ex_to_lr_alu_res,
  input  [63:0] io_ex_to_lr_src1,
  input  [63:0] io_ex_to_lr_src2,
  input  [63:0] io_ex_to_lr_imm,
  input  [7:0]  io_ex_to_lr_lsuop,
  input  [11:0] io_ex_to_lr_rv64op,
  input  [4:0]  io_ex_to_lr_dest,
  input         io_ex_to_lr_rf_w,
  input         io_ex_to_lr_load,
  input         io_ex_to_lr_save,
  input  [63:0] io_ex_to_lr_pc,
  input  [31:0] io_ex_to_lr_inst,
  input         io_ex_to_lr_is_csr,
  input  [7:0]  io_ex_to_lr_csrop,
  input  [11:0] io_ex_to_lr_csr_addr,
  input  [63:0] io_ex_to_lr_csr_src,
  input         io_ex_to_lr_is_zero,
  output        io_lr_to_lsu_is_nop,
  output [63:0] io_lr_to_lsu_alu_res,
  output [63:0] io_lr_to_lsu_src1,
  output [63:0] io_lr_to_lsu_src2,
  output [63:0] io_lr_to_lsu_imm,
  output [7:0]  io_lr_to_lsu_lsuop,
  output [11:0] io_lr_to_lsu_rv64op,
  output [4:0]  io_lr_to_lsu_dest,
  output        io_lr_to_lsu_rf_w,
  output        io_lr_to_lsu_load,
  output        io_lr_to_lsu_save,
  output [63:0] io_lr_to_lsu_pc,
  output [31:0] io_lr_to_lsu_inst,
  output        io_lr_to_lsu_is_csr,
  output [7:0]  io_lr_to_lsu_csrop,
  output [11:0] io_lr_to_lsu_csr_addr,
  output [63:0] io_lr_to_lsu_csr_src,
  output        io_lr_to_lsu_is_zero
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [63:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [63:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [63:0] _RAND_17;
  reg [31:0] _RAND_18;
`endif // RANDOMIZE_REG_INIT
  wire  judg = io_es_to_ls_valid & io_ls_allowin; // @[lr.scala 18:32]
  reg  ls_valid; // @[Reg.scala 27:20]
  wire  _GEN_0 = io_ls_allowin ? io_es_to_ls_valid : ls_valid; // @[Reg.scala 28:19 Reg.scala 28:23 Reg.scala 27:20]
  reg  io_lr_to_lsu_is_nop_r; // @[Reg.scala 27:20]
  reg  io_lr_to_lsu_is_csr_r; // @[Reg.scala 27:20]
  reg [63:0] io_lr_to_lsu_alu_res_r; // @[Reg.scala 27:20]
  reg [63:0] io_lr_to_lsu_src1_r; // @[Reg.scala 27:20]
  reg [63:0] io_lr_to_lsu_src2_r; // @[Reg.scala 27:20]
  reg [63:0] io_lr_to_lsu_imm_r; // @[Reg.scala 27:20]
  reg [7:0] io_lr_to_lsu_lsuop_r; // @[Reg.scala 27:20]
  reg [11:0] io_lr_to_lsu_rv64op_r; // @[Reg.scala 27:20]
  reg [4:0] io_lr_to_lsu_dest_r; // @[Reg.scala 27:20]
  reg  io_lr_to_lsu_rf_w_r; // @[Reg.scala 27:20]
  reg  io_lr_to_lsu_load_r; // @[Reg.scala 27:20]
  reg  io_lr_to_lsu_save_r; // @[Reg.scala 27:20]
  reg [63:0] io_lr_to_lsu_pc_r; // @[Reg.scala 27:20]
  reg [31:0] io_lr_to_lsu_inst_r; // @[Reg.scala 27:20]
  reg [7:0] io_lr_to_lsu_csrop_r; // @[Reg.scala 27:20]
  reg [11:0] io_lr_to_lsu_csr_addr_r; // @[Reg.scala 27:20]
  reg [63:0] io_lr_to_lsu_csr_src_r; // @[Reg.scala 27:20]
  reg  io_lr_to_lsu_is_zero_r; // @[Reg.scala 27:20]
  assign io_ls_valid = ls_valid; // @[lr.scala 20:15]
  assign io_lr_to_lsu_is_nop = io_lr_to_lsu_is_nop_r; // @[lr.scala 22:23]
  assign io_lr_to_lsu_alu_res = io_lr_to_lsu_alu_res_r; // @[lr.scala 26:24]
  assign io_lr_to_lsu_src1 = io_lr_to_lsu_src1_r; // @[lr.scala 28:21]
  assign io_lr_to_lsu_src2 = io_lr_to_lsu_src2_r; // @[lr.scala 29:21]
  assign io_lr_to_lsu_imm = io_lr_to_lsu_imm_r; // @[lr.scala 30:20]
  assign io_lr_to_lsu_lsuop = io_lr_to_lsu_lsuop_r; // @[lr.scala 32:22]
  assign io_lr_to_lsu_rv64op = io_lr_to_lsu_rv64op_r; // @[lr.scala 33:23]
  assign io_lr_to_lsu_dest = io_lr_to_lsu_dest_r; // @[lr.scala 34:21]
  assign io_lr_to_lsu_rf_w = io_lr_to_lsu_rf_w_r; // @[lr.scala 35:21]
  assign io_lr_to_lsu_load = io_lr_to_lsu_load_r; // @[lr.scala 36:21]
  assign io_lr_to_lsu_save = io_lr_to_lsu_save_r; // @[lr.scala 37:21]
  assign io_lr_to_lsu_pc = io_lr_to_lsu_pc_r; // @[lr.scala 39:19]
  assign io_lr_to_lsu_inst = io_lr_to_lsu_inst_r; // @[lr.scala 40:21]
  assign io_lr_to_lsu_is_csr = io_lr_to_lsu_is_csr_r; // @[lr.scala 24:23]
  assign io_lr_to_lsu_csrop = io_lr_to_lsu_csrop_r; // @[lr.scala 42:22]
  assign io_lr_to_lsu_csr_addr = io_lr_to_lsu_csr_addr_r; // @[lr.scala 43:25]
  assign io_lr_to_lsu_csr_src = io_lr_to_lsu_csr_src_r; // @[lr.scala 44:24]
  assign io_lr_to_lsu_is_zero = io_lr_to_lsu_is_zero_r; // @[lr.scala 45:24]
  always @(posedge clock) begin
    ls_valid <= reset | _GEN_0; // @[Reg.scala 27:20 Reg.scala 27:20]
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_is_nop_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (io_ls_allowin) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_is_nop_r <= io_ex_to_lr_is_nop; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_is_csr_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_is_csr_r <= io_ex_to_lr_is_csr; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_alu_res_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_alu_res_r <= io_ex_to_lr_alu_res; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_src1_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_src1_r <= io_ex_to_lr_src1; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_src2_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_src2_r <= io_ex_to_lr_src2; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_imm_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_imm_r <= io_ex_to_lr_imm; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_lsuop_r <= 8'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_lsuop_r <= io_ex_to_lr_lsuop; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_rv64op_r <= 12'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_rv64op_r <= io_ex_to_lr_rv64op; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_dest_r <= 5'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_dest_r <= io_ex_to_lr_dest; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_rf_w_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_rf_w_r <= io_ex_to_lr_rf_w; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_load_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_load_r <= io_ex_to_lr_load; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_save_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_save_r <= io_ex_to_lr_save; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_pc_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (io_ls_allowin) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_pc_r <= io_ex_to_lr_pc; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_inst_r <= 32'h0; // @[Reg.scala 27:20]
    end else if (io_ls_allowin) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_inst_r <= io_ex_to_lr_inst; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_csrop_r <= 8'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_csrop_r <= io_ex_to_lr_csrop; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_csr_addr_r <= 12'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_csr_addr_r <= io_ex_to_lr_csr_addr; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_csr_src_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_csr_src_r <= io_ex_to_lr_csr_src; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_lr_to_lsu_is_zero_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (judg) begin // @[Reg.scala 28:19]
      io_lr_to_lsu_is_zero_r <= io_ex_to_lr_is_zero; // @[Reg.scala 28:23]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  ls_valid = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  io_lr_to_lsu_is_nop_r = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  io_lr_to_lsu_is_csr_r = _RAND_2[0:0];
  _RAND_3 = {2{`RANDOM}};
  io_lr_to_lsu_alu_res_r = _RAND_3[63:0];
  _RAND_4 = {2{`RANDOM}};
  io_lr_to_lsu_src1_r = _RAND_4[63:0];
  _RAND_5 = {2{`RANDOM}};
  io_lr_to_lsu_src2_r = _RAND_5[63:0];
  _RAND_6 = {2{`RANDOM}};
  io_lr_to_lsu_imm_r = _RAND_6[63:0];
  _RAND_7 = {1{`RANDOM}};
  io_lr_to_lsu_lsuop_r = _RAND_7[7:0];
  _RAND_8 = {1{`RANDOM}};
  io_lr_to_lsu_rv64op_r = _RAND_8[11:0];
  _RAND_9 = {1{`RANDOM}};
  io_lr_to_lsu_dest_r = _RAND_9[4:0];
  _RAND_10 = {1{`RANDOM}};
  io_lr_to_lsu_rf_w_r = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  io_lr_to_lsu_load_r = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  io_lr_to_lsu_save_r = _RAND_12[0:0];
  _RAND_13 = {2{`RANDOM}};
  io_lr_to_lsu_pc_r = _RAND_13[63:0];
  _RAND_14 = {1{`RANDOM}};
  io_lr_to_lsu_inst_r = _RAND_14[31:0];
  _RAND_15 = {1{`RANDOM}};
  io_lr_to_lsu_csrop_r = _RAND_15[7:0];
  _RAND_16 = {1{`RANDOM}};
  io_lr_to_lsu_csr_addr_r = _RAND_16[11:0];
  _RAND_17 = {2{`RANDOM}};
  io_lr_to_lsu_csr_src_r = _RAND_17[63:0];
  _RAND_18 = {1{`RANDOM}};
  io_lr_to_lsu_is_zero_r = _RAND_18[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module LSU(
  input         clock,
  input         reset,
  input         io_ls_valid,
  output        io_ls_allowin,
  output        io_ls_to_ws_valid,
  input         io_ex_to_lsu_is_nop,
  input  [63:0] io_ex_to_lsu_alu_res,
  input  [63:0] io_ex_to_lsu_src1,
  input  [63:0] io_ex_to_lsu_src2,
  input  [63:0] io_ex_to_lsu_imm,
  input  [7:0]  io_ex_to_lsu_lsuop,
  input  [11:0] io_ex_to_lsu_rv64op,
  input  [4:0]  io_ex_to_lsu_dest,
  input         io_ex_to_lsu_rf_w,
  input         io_ex_to_lsu_load,
  input         io_ex_to_lsu_save,
  input  [63:0] io_ex_to_lsu_pc,
  input  [31:0] io_ex_to_lsu_inst,
  input         io_ex_to_lsu_is_csr,
  input  [7:0]  io_ex_to_lsu_csrop,
  input  [11:0] io_ex_to_lsu_csr_addr,
  input  [63:0] io_ex_to_lsu_csr_src,
  input         io_ex_to_lsu_is_zero,
  output        io_lsu_to_wb_is_nop,
  output [63:0] io_lsu_to_wb_lsu_res,
  output [4:0]  io_lsu_to_wb_dest,
  output        io_lsu_to_wb_rf_w,
  output [63:0] io_lsu_to_wb_pc,
  output [31:0] io_lsu_to_wb_inst,
  output        io_lsu_to_wb_is_csr,
  output [7:0]  io_lsu_to_wb_csrop,
  output [11:0] io_lsu_to_wb_csr_addr,
  output [63:0] io_lsu_to_wb_csr_src,
  output        io_lsu_to_wb_is_zero,
  output        io_lsu_to_csr_is_clint,
  output        io_lsu_to_csr_is_mtime,
  output        io_lsu_to_csr_is_mtimecmp,
  output        io_lsu_to_csr_load,
  output        io_lsu_to_csr_save,
  output [63:0] io_lsu_to_csr_wdata,
  input  [63:0] io_lsu_to_csr_rdata,
  output        io_lsu_fwd_rf_w,
  output [4:0]  io_lsu_fwd_dst,
  output [63:0] io_lsu_fwd_lsu_res,
  output        io_lsu_fwd_is_csr,
  output        io_lsu_fwd_br_stall,
  output        io_dsram_wr,
  output [1:0]  io_dsram_size,
  output [63:0] io_dsram_addr,
  output [7:0]  io_dsram_wstrb,
  output [63:0] io_dsram_wdata,
  output        io_dsram_addr_valid,
  input         io_dsram_data_ok,
  output        io_dsram_using,
  input  [63:0] io_dsram_rdata,
  input         io_flush
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg  addr_valid; // @[LSU.scala 32:27]
  wire [63:0] inst = io_flush ? 64'h13 : {{32'd0}, io_ex_to_lsu_inst}; // @[LSU.scala 69:17]
  wire  _load_T_1 = io_ls_valid & inst != 64'h13; // @[LSU.scala 77:24]
  wire  load = io_ls_valid & inst != 64'h13 & io_ex_to_lsu_load; // @[LSU.scala 77:14]
  wire  save = _load_T_1 & io_ex_to_lsu_save; // @[LSU.scala 78:14]
  wire  _memory_fetch_T = load | save; // @[LSU.scala 38:28]
  wire [63:0] _addr_real_T_2 = io_ex_to_lsu_src1 + io_ex_to_lsu_imm; // @[LSU.scala 95:10]
  wire [63:0] addr_real = _memory_fetch_T ? _addr_real_T_2 : 64'h80000000; // @[LSU.scala 93:22]
  wire  is_mtime = addr_real == 64'h200bff8; // @[LSU.scala 162:29]
  wire  is_mtimecmp = addr_real == 64'h2004000; // @[LSU.scala 163:32]
  wire  is_clint = is_mtime | is_mtimecmp; // @[LSU.scala 164:24]
  wire  memory_fetch = (load | save) & ~is_clint; // @[LSU.scala 38:37]
  wire  ls_ready_go = io_dsram_data_ok | ~memory_fetch; // @[LSU.scala 42:38]
  wire  _ls_allowin_T = ~io_ls_valid; // @[LSU.scala 46:17]
  wire  ls_to_ws_valid = io_ls_valid & ls_ready_go; // @[LSU.scala 47:30]
  wire  _GEN_1 = addr_valid & io_dsram_using ? 1'h0 : addr_valid; // @[LSU.scala 60:37 LSU.scala 61:16 LSU.scala 32:27]
  wire  _GEN_3 = memory_fetch & ~addr_valid | _GEN_1; // @[LSU.scala 63:36 LSU.scala 65:16]
  wire  i_lb = io_ex_to_lsu_lsuop[0]; // @[LSU.scala 80:19]
  wire  i_lh = io_ex_to_lsu_lsuop[1]; // @[LSU.scala 81:19]
  wire  i_lw = io_ex_to_lsu_lsuop[2]; // @[LSU.scala 82:19]
  wire  i_lbu = io_ex_to_lsu_lsuop[3]; // @[LSU.scala 83:20]
  wire  i_lhu = io_ex_to_lsu_lsuop[4]; // @[LSU.scala 84:20]
  wire  i_sb = io_ex_to_lsu_lsuop[5]; // @[LSU.scala 85:19]
  wire  i_sh = io_ex_to_lsu_lsuop[6]; // @[LSU.scala 86:19]
  wire  i_sw = io_ex_to_lsu_lsuop[7]; // @[LSU.scala 87:19]
  wire  i_lwu = io_ex_to_lsu_rv64op[9]; // @[LSU.scala 89:21]
  wire  i_ld = io_ex_to_lsu_rv64op[10]; // @[LSU.scala 90:20]
  wire  i_sd = io_ex_to_lsu_rv64op[11]; // @[LSU.scala 91:20]
  wire  sel_b = addr_real[0]; // @[LSU.scala 99:22]
  wire  sel_h = addr_real[1]; // @[LSU.scala 100:22]
  wire  sel_w = addr_real[2]; // @[LSU.scala 101:22]
  wire  _wstrb_T_1 = ~sel_w; // @[LSU.scala 133:16]
  wire  _wstrb_T_2 = i_sw & ~sel_w; // @[LSU.scala 133:13]
  wire  _wstrb_T_3 = i_sw & sel_w; // @[LSU.scala 134:13]
  wire  _wstrb_T_5 = ~sel_h; // @[LSU.scala 136:27]
  wire  _wstrb_T_6 = _wstrb_T_1 & ~sel_h; // @[LSU.scala 136:24]
  wire  _wstrb_T_7 = i_sh & (_wstrb_T_1 & ~sel_h); // @[LSU.scala 136:13]
  wire  _wstrb_T_9 = _wstrb_T_1 & sel_h; // @[LSU.scala 137:24]
  wire  _wstrb_T_10 = i_sh & (_wstrb_T_1 & sel_h); // @[LSU.scala 137:13]
  wire  _wstrb_T_12 = sel_w & _wstrb_T_5; // @[LSU.scala 138:24]
  wire  _wstrb_T_13 = i_sh & (sel_w & _wstrb_T_5); // @[LSU.scala 138:13]
  wire  _wstrb_T_14 = sel_w & sel_h; // @[LSU.scala 139:24]
  wire  _wstrb_T_15 = i_sh & (sel_w & sel_h); // @[LSU.scala 139:13]
  wire  _wstrb_T_19 = ~sel_b; // @[LSU.scala 141:37]
  wire  _wstrb_T_20 = _wstrb_T_6 & ~sel_b; // @[LSU.scala 141:34]
  wire  _wstrb_T_21 = i_sb & (_wstrb_T_6 & ~sel_b); // @[LSU.scala 141:13]
  wire  _wstrb_T_25 = _wstrb_T_6 & sel_b; // @[LSU.scala 142:34]
  wire  _wstrb_T_26 = i_sb & (_wstrb_T_6 & sel_b); // @[LSU.scala 142:13]
  wire  _wstrb_T_30 = _wstrb_T_9 & _wstrb_T_19; // @[LSU.scala 143:34]
  wire  _wstrb_T_31 = i_sb & (_wstrb_T_9 & _wstrb_T_19); // @[LSU.scala 143:13]
  wire  _wstrb_T_34 = _wstrb_T_9 & sel_b; // @[LSU.scala 144:34]
  wire  _wstrb_T_35 = i_sb & (_wstrb_T_9 & sel_b); // @[LSU.scala 144:13]
  wire  _wstrb_T_39 = _wstrb_T_12 & _wstrb_T_19; // @[LSU.scala 145:34]
  wire  _wstrb_T_40 = i_sb & (_wstrb_T_12 & _wstrb_T_19); // @[LSU.scala 145:13]
  wire  _wstrb_T_43 = _wstrb_T_12 & sel_b; // @[LSU.scala 146:34]
  wire  _wstrb_T_44 = i_sb & (_wstrb_T_12 & sel_b); // @[LSU.scala 146:13]
  wire  _wstrb_T_47 = _wstrb_T_14 & _wstrb_T_19; // @[LSU.scala 147:34]
  wire  _wstrb_T_48 = i_sb & (_wstrb_T_14 & _wstrb_T_19); // @[LSU.scala 147:13]
  wire  _wstrb_T_50 = _wstrb_T_14 & sel_b; // @[LSU.scala 148:34]
  wire  _wstrb_T_51 = i_sb & (_wstrb_T_14 & sel_b); // @[LSU.scala 148:13]
  wire [7:0] _wstrb_T_53 = i_sd ? 8'hff : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_54 = _wstrb_T_2 ? 8'hf : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_55 = _wstrb_T_3 ? 8'hf0 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_56 = _wstrb_T_7 ? 8'h3 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_57 = _wstrb_T_10 ? 8'hc : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_58 = _wstrb_T_13 ? 8'h30 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_59 = _wstrb_T_15 ? 8'hc0 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_60 = _wstrb_T_21 ? 8'h1 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_61 = _wstrb_T_26 ? 8'h2 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_62 = _wstrb_T_31 ? 8'h4 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_63 = _wstrb_T_35 ? 8'h8 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_64 = _wstrb_T_40 ? 8'h10 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_65 = _wstrb_T_44 ? 8'h20 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_66 = _wstrb_T_48 ? 8'h40 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_67 = _wstrb_T_51 ? 8'h80 : 8'h0; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_69 = _wstrb_T_53 | _wstrb_T_54; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_70 = _wstrb_T_69 | _wstrb_T_55; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_71 = _wstrb_T_70 | _wstrb_T_56; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_72 = _wstrb_T_71 | _wstrb_T_57; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_73 = _wstrb_T_72 | _wstrb_T_58; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_74 = _wstrb_T_73 | _wstrb_T_59; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_75 = _wstrb_T_74 | _wstrb_T_60; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_76 = _wstrb_T_75 | _wstrb_T_61; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_77 = _wstrb_T_76 | _wstrb_T_62; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_78 = _wstrb_T_77 | _wstrb_T_63; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_79 = _wstrb_T_78 | _wstrb_T_64; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_80 = _wstrb_T_79 | _wstrb_T_65; // @[Mux.scala 27:72]
  wire [7:0] _wstrb_T_81 = _wstrb_T_80 | _wstrb_T_66; // @[Mux.scala 27:72]
  wire [31:0] sdata_hi = io_ex_to_lsu_src2[31:0]; // @[LSU.scala 156:30]
  wire [63:0] _sdata_T_1 = {sdata_hi,sdata_hi}; // @[Cat.scala 30:58]
  wire [15:0] sdata_hi_1 = io_ex_to_lsu_src2[15:0]; // @[LSU.scala 157:30]
  wire [63:0] _sdata_T_2 = {sdata_hi_1,sdata_hi_1,sdata_hi_1,sdata_hi_1}; // @[Cat.scala 30:58]
  wire [7:0] sdata_hi_3 = io_ex_to_lsu_src2[7:0]; // @[LSU.scala 158:30]
  wire [63:0] _sdata_T_3 = {sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3}; // @[Cat.scala 30:58]
  wire [63:0] _sdata_T_5 = i_sd ? io_ex_to_lsu_src2 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_6 = i_sw ? _sdata_T_1 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_7 = i_sh ? _sdata_T_2 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_8 = i_sb ? _sdata_T_3 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_10 = _sdata_T_5 | _sdata_T_6; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_11 = _sdata_T_10 | _sdata_T_7; // @[Mux.scala 27:72]
  wire  _io_dsram_size_T_2 = i_lb | i_lbu; // @[LSU.scala 178:11]
  wire  _io_dsram_size_T_4 = i_lh | i_lhu; // @[LSU.scala 179:11]
  wire  _io_dsram_size_T_5 = i_lh | i_lhu | i_sh; // @[LSU.scala 179:20]
  wire  _io_dsram_size_T_6 = i_lw | i_lwu; // @[LSU.scala 180:11]
  wire  _io_dsram_size_T_7 = i_lw | i_lwu | i_sw; // @[LSU.scala 180:20]
  wire  _io_dsram_size_T_8 = i_ld | i_sd; // @[LSU.scala 181:11]
  wire [1:0] _io_dsram_size_T_12 = _io_dsram_size_T_7 ? 2'h2 : 2'h0; // @[Mux.scala 27:72]
  wire [1:0] _io_dsram_size_T_13 = _io_dsram_size_T_8 ? 2'h3 : 2'h0; // @[Mux.scala 27:72]
  wire [1:0] _GEN_4 = {{1'd0}, _io_dsram_size_T_5}; // @[Mux.scala 27:72]
  wire [1:0] _io_dsram_size_T_16 = _GEN_4 | _io_dsram_size_T_12; // @[Mux.scala 27:72]
  wire [60:0] io_dsram_addr_hi = addr_real[63:3]; // @[LSU.scala 183:33]
  wire  _rdata_T_3 = _io_dsram_size_T_6 & _wstrb_T_1; // @[LSU.scala 194:24]
  wire [31:0] rdata_lo = io_dsram_rdata[31:0]; // @[LSU.scala 194:57]
  wire [63:0] _rdata_T_4 = {32'h0,rdata_lo}; // @[Cat.scala 30:58]
  wire  _rdata_T_6 = _io_dsram_size_T_6 & sel_w; // @[LSU.scala 195:24]
  wire [31:0] rdata_lo_1 = io_dsram_rdata[63:32]; // @[LSU.scala 195:57]
  wire [63:0] _rdata_T_7 = {32'h0,rdata_lo_1}; // @[Cat.scala 30:58]
  wire  _rdata_T_12 = _io_dsram_size_T_4 & _wstrb_T_6; // @[LSU.scala 197:24]
  wire [15:0] rdata_lo_2 = io_dsram_rdata[15:0]; // @[LSU.scala 197:69]
  wire [63:0] _rdata_T_13 = {48'h0,rdata_lo_2}; // @[Cat.scala 30:58]
  wire  _rdata_T_17 = _io_dsram_size_T_4 & _wstrb_T_9; // @[LSU.scala 198:24]
  wire [15:0] rdata_lo_3 = io_dsram_rdata[31:16]; // @[LSU.scala 198:69]
  wire [63:0] _rdata_T_18 = {48'h0,rdata_lo_3}; // @[Cat.scala 30:58]
  wire  _rdata_T_22 = _io_dsram_size_T_4 & _wstrb_T_12; // @[LSU.scala 199:24]
  wire [15:0] rdata_lo_4 = io_dsram_rdata[47:32]; // @[LSU.scala 199:69]
  wire [63:0] _rdata_T_23 = {48'h0,rdata_lo_4}; // @[Cat.scala 30:58]
  wire  _rdata_T_26 = _io_dsram_size_T_4 & _wstrb_T_14; // @[LSU.scala 200:24]
  wire [15:0] rdata_lo_5 = io_dsram_rdata[63:48]; // @[LSU.scala 200:69]
  wire [63:0] _rdata_T_27 = {48'h0,rdata_lo_5}; // @[Cat.scala 30:58]
  wire  _rdata_T_34 = _io_dsram_size_T_2 & _wstrb_T_20; // @[LSU.scala 202:23]
  wire [7:0] rdata_lo_6 = io_dsram_rdata[7:0]; // @[LSU.scala 202:78]
  wire [63:0] _rdata_T_35 = {56'h0,rdata_lo_6}; // @[Cat.scala 30:58]
  wire  _rdata_T_41 = _io_dsram_size_T_2 & _wstrb_T_25; // @[LSU.scala 203:23]
  wire [7:0] rdata_lo_7 = io_dsram_rdata[15:8]; // @[LSU.scala 203:78]
  wire [63:0] _rdata_T_42 = {56'h0,rdata_lo_7}; // @[Cat.scala 30:58]
  wire  _rdata_T_48 = _io_dsram_size_T_2 & _wstrb_T_30; // @[LSU.scala 204:23]
  wire [7:0] rdata_lo_8 = io_dsram_rdata[23:16]; // @[LSU.scala 204:78]
  wire [63:0] _rdata_T_49 = {56'h0,rdata_lo_8}; // @[Cat.scala 30:58]
  wire  _rdata_T_54 = _io_dsram_size_T_2 & _wstrb_T_34; // @[LSU.scala 205:23]
  wire [7:0] rdata_lo_9 = io_dsram_rdata[31:24]; // @[LSU.scala 205:78]
  wire [63:0] _rdata_T_55 = {56'h0,rdata_lo_9}; // @[Cat.scala 30:58]
  wire  _rdata_T_61 = _io_dsram_size_T_2 & _wstrb_T_39; // @[LSU.scala 206:23]
  wire [7:0] rdata_lo_10 = io_dsram_rdata[39:32]; // @[LSU.scala 206:78]
  wire [63:0] _rdata_T_62 = {56'h0,rdata_lo_10}; // @[Cat.scala 30:58]
  wire  _rdata_T_67 = _io_dsram_size_T_2 & _wstrb_T_43; // @[LSU.scala 207:23]
  wire [7:0] rdata_lo_11 = io_dsram_rdata[47:40]; // @[LSU.scala 207:78]
  wire [63:0] _rdata_T_68 = {56'h0,rdata_lo_11}; // @[Cat.scala 30:58]
  wire  _rdata_T_73 = _io_dsram_size_T_2 & _wstrb_T_47; // @[LSU.scala 208:23]
  wire [7:0] rdata_lo_12 = io_dsram_rdata[55:48]; // @[LSU.scala 208:78]
  wire [63:0] _rdata_T_74 = {56'h0,rdata_lo_12}; // @[Cat.scala 30:58]
  wire  _rdata_T_78 = _io_dsram_size_T_2 & _wstrb_T_50; // @[LSU.scala 209:23]
  wire [7:0] rdata_lo_13 = io_dsram_rdata[63:56]; // @[LSU.scala 209:78]
  wire [63:0] _rdata_T_79 = {56'h0,rdata_lo_13}; // @[Cat.scala 30:58]
  wire [63:0] _rdata_T_81 = i_ld ? io_dsram_rdata : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_82 = _rdata_T_3 ? _rdata_T_4 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_83 = _rdata_T_6 ? _rdata_T_7 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_84 = _rdata_T_12 ? _rdata_T_13 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_85 = _rdata_T_17 ? _rdata_T_18 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_86 = _rdata_T_22 ? _rdata_T_23 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_87 = _rdata_T_26 ? _rdata_T_27 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_88 = _rdata_T_34 ? _rdata_T_35 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_89 = _rdata_T_41 ? _rdata_T_42 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_90 = _rdata_T_48 ? _rdata_T_49 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_91 = _rdata_T_54 ? _rdata_T_55 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_92 = _rdata_T_61 ? _rdata_T_62 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_93 = _rdata_T_67 ? _rdata_T_68 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_94 = _rdata_T_73 ? _rdata_T_74 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_95 = _rdata_T_78 ? _rdata_T_79 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_97 = _rdata_T_81 | _rdata_T_82; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_98 = _rdata_T_97 | _rdata_T_83; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_99 = _rdata_T_98 | _rdata_T_84; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_100 = _rdata_T_99 | _rdata_T_85; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_101 = _rdata_T_100 | _rdata_T_86; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_102 = _rdata_T_101 | _rdata_T_87; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_103 = _rdata_T_102 | _rdata_T_88; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_104 = _rdata_T_103 | _rdata_T_89; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_105 = _rdata_T_104 | _rdata_T_90; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_106 = _rdata_T_105 | _rdata_T_91; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_107 = _rdata_T_106 | _rdata_T_92; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_108 = _rdata_T_107 | _rdata_T_93; // @[Mux.scala 27:72]
  wire [63:0] _rdata_T_109 = _rdata_T_108 | _rdata_T_94; // @[Mux.scala 27:72]
  wire [63:0] ld_res = _rdata_T_109 | _rdata_T_95; // @[Mux.scala 27:72]
  wire [31:0] lw_res_hi = ld_res[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 72:12]
  wire [31:0] lw_res_lo = ld_res[31:0]; // @[LSU.scala 214:46]
  wire [63:0] lw_res = {lw_res_hi,lw_res_lo}; // @[Cat.scala 30:58]
  wire [63:0] lwu_res = {32'h0,lw_res_lo}; // @[Cat.scala 30:58]
  wire [47:0] lh_res_hi = ld_res[15] ? 48'hffffffffffff : 48'h0; // @[Bitwise.scala 72:12]
  wire [15:0] lh_res_lo = ld_res[15:0]; // @[LSU.scala 216:46]
  wire [63:0] lh_res = {lh_res_hi,lh_res_lo}; // @[Cat.scala 30:58]
  wire [16:0] lhu_res = {1'h0,lh_res_lo}; // @[Cat.scala 30:58]
  wire [55:0] lb_res_hi = ld_res[7] ? 56'hffffffffffffff : 56'h0; // @[Bitwise.scala 72:12]
  wire [7:0] lb_res_lo = ld_res[7:0]; // @[LSU.scala 218:45]
  wire [63:0] lb_res = {lb_res_hi,lb_res_lo}; // @[Cat.scala 30:58]
  wire [63:0] lbu_res = {56'h0,lb_res_lo}; // @[Cat.scala 30:58]
  wire [63:0] _load_res_T_2 = i_ld ? ld_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_3 = i_lw ? lw_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_4 = i_lwu ? lwu_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_5 = i_lh ? lh_res : 64'h0; // @[Mux.scala 27:72]
  wire [16:0] _load_res_T_6 = i_lhu ? lhu_res : 17'h0; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_7 = i_lb ? lb_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_8 = i_lbu ? lbu_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_10 = _load_res_T_2 | _load_res_T_3; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_11 = _load_res_T_10 | _load_res_T_4; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_12 = _load_res_T_11 | _load_res_T_5; // @[Mux.scala 27:72]
  wire [63:0] _GEN_5 = {{47'd0}, _load_res_T_6}; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_13 = _load_res_T_12 | _GEN_5; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_14 = _load_res_T_13 | _load_res_T_7; // @[Mux.scala 27:72]
  wire [63:0] load_res = _load_res_T_14 | _load_res_T_8; // @[Mux.scala 27:72]
  wire  _lsu_res_T_1 = ~(save | load); // @[LSU.scala 236:7]
  wire [63:0] _lsu_res_T_2 = _lsu_res_T_1 ? io_ex_to_lsu_alu_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _lsu_res_T_4 = load ? load_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] lsu_res = _lsu_res_T_2 | _lsu_res_T_4; // @[Mux.scala 27:72]
  wire  rf_w = save ? 1'h0 : io_ex_to_lsu_rf_w; // @[LSU.scala 247:17]
  wire  _io_lsu_to_wb_inst_T_1 = io_flush | ~ls_to_ws_valid; // @[LSU.scala 266:37]
  wire [63:0] _io_lsu_to_wb_inst_T_2 = io_flush | ~ls_to_ws_valid ? 64'h13 : inst; // @[LSU.scala 266:27]
  assign io_ls_allowin = ~io_ls_valid | ls_ready_go; // @[LSU.scala 46:27]
  assign io_ls_to_ws_valid = io_ls_valid & ls_ready_go; // @[LSU.scala 47:30]
  assign io_lsu_to_wb_is_nop = _io_lsu_to_wb_inst_T_1 | io_ex_to_lsu_is_nop; // @[LSU.scala 274:29]
  assign io_lsu_to_wb_lsu_res = is_clint ? io_lsu_to_csr_rdata : lsu_res; // @[LSU.scala 242:26]
  assign io_lsu_to_wb_dest = save ? 5'h0 : io_ex_to_lsu_dest; // @[LSU.scala 245:17]
  assign io_lsu_to_wb_rf_w = save ? 1'h0 : io_ex_to_lsu_rf_w; // @[LSU.scala 247:17]
  assign io_lsu_to_wb_pc = io_ex_to_lsu_pc; // @[LSU.scala 265:19]
  assign io_lsu_to_wb_inst = _io_lsu_to_wb_inst_T_2[31:0]; // @[LSU.scala 266:21]
  assign io_lsu_to_wb_is_csr = io_ex_to_lsu_is_csr; // @[LSU.scala 268:23]
  assign io_lsu_to_wb_csrop = io_ex_to_lsu_csrop; // @[LSU.scala 269:22]
  assign io_lsu_to_wb_csr_addr = io_ex_to_lsu_csr_addr; // @[LSU.scala 270:25]
  assign io_lsu_to_wb_csr_src = io_ex_to_lsu_csr_src; // @[LSU.scala 271:24]
  assign io_lsu_to_wb_is_zero = io_ex_to_lsu_is_zero; // @[LSU.scala 272:24]
  assign io_lsu_to_csr_is_clint = is_mtime | is_mtimecmp; // @[LSU.scala 164:24]
  assign io_lsu_to_csr_is_mtime = addr_real == 64'h200bff8; // @[LSU.scala 162:29]
  assign io_lsu_to_csr_is_mtimecmp = addr_real == 64'h2004000; // @[LSU.scala 163:32]
  assign io_lsu_to_csr_load = io_ls_valid & inst != 64'h13 & io_ex_to_lsu_load; // @[LSU.scala 77:14]
  assign io_lsu_to_csr_save = _load_T_1 & io_ex_to_lsu_save; // @[LSU.scala 78:14]
  assign io_lsu_to_csr_wdata = io_ex_to_lsu_src2; // @[LSU.scala 263:23]
  assign io_lsu_fwd_rf_w = _ls_allowin_T ? 1'h0 : rf_w; // @[LSU.scala 251:25]
  assign io_lsu_fwd_dst = save ? 5'h0 : io_ex_to_lsu_dest; // @[LSU.scala 245:17]
  assign io_lsu_fwd_lsu_res = is_clint ? io_lsu_to_csr_rdata : lsu_res; // @[LSU.scala 242:26]
  assign io_lsu_fwd_is_csr = _ls_allowin_T ? 1'h0 : io_ex_to_lsu_is_csr; // @[LSU.scala 254:27]
  assign io_lsu_fwd_br_stall = ~ls_ready_go; // @[LSU.scala 255:26]
  assign io_dsram_wr = _load_T_1 & io_ex_to_lsu_save; // @[LSU.scala 78:14]
  assign io_dsram_size = _io_dsram_size_T_16 | _io_dsram_size_T_13; // @[Mux.scala 27:72]
  assign io_dsram_addr = {io_dsram_addr_hi,3'h0}; // @[Cat.scala 30:58]
  assign io_dsram_wstrb = _wstrb_T_81 | _wstrb_T_67; // @[Mux.scala 27:72]
  assign io_dsram_wdata = _sdata_T_11 | _sdata_T_8; // @[Mux.scala 27:72]
  assign io_dsram_addr_valid = addr_valid; // @[LSU.scala 39:23]
  assign io_dsram_using = io_ls_valid & ls_ready_go; // @[LSU.scala 47:30]
  always @(posedge clock) begin
    if (reset) begin // @[LSU.scala 32:27]
      addr_valid <= 1'h0; // @[LSU.scala 32:27]
    end else begin
      addr_valid <= _GEN_3;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  addr_valid = _RAND_0[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module WR(
  input         clock,
  input         reset,
  input         io_ls_to_ws_valid,
  output        io_ws_valid,
  input         io_lsu_to_wr_is_nop,
  input  [63:0] io_lsu_to_wr_lsu_res,
  input  [4:0]  io_lsu_to_wr_dest,
  input         io_lsu_to_wr_rf_w,
  input  [63:0] io_lsu_to_wr_pc,
  input  [31:0] io_lsu_to_wr_inst,
  input         io_lsu_to_wr_is_csr,
  input  [7:0]  io_lsu_to_wr_csrop,
  input  [11:0] io_lsu_to_wr_csr_addr,
  input  [63:0] io_lsu_to_wr_csr_src,
  input         io_lsu_to_wr_is_zero,
  output        io_wr_to_wb_is_nop,
  output [63:0] io_wr_to_wb_lsu_res,
  output [4:0]  io_wr_to_wb_dest,
  output        io_wr_to_wb_rf_w,
  output [63:0] io_wr_to_wb_pc,
  output [31:0] io_wr_to_wb_inst,
  output        io_wr_to_wb_is_csr,
  output [7:0]  io_wr_to_wb_csrop,
  output [11:0] io_wr_to_wb_csr_addr,
  output [63:0] io_wr_to_wb_csr_src,
  output        io_wr_to_wb_is_zero
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [63:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [63:0] _RAND_10;
  reg [31:0] _RAND_11;
`endif // RANDOMIZE_REG_INIT
  reg  io_ws_valid_r; // @[Reg.scala 27:20]
  reg  io_wr_to_wb_is_nop_r; // @[Reg.scala 27:20]
  reg [63:0] io_wr_to_wb_lsu_res_r; // @[Reg.scala 27:20]
  reg [4:0] io_wr_to_wb_dest_r; // @[Reg.scala 27:20]
  reg  io_wr_to_wb_rf_w_r; // @[Reg.scala 27:20]
  reg [63:0] io_wr_to_wb_pc_r; // @[Reg.scala 27:20]
  reg [31:0] io_wr_to_wb_inst_r; // @[Reg.scala 27:20]
  reg  io_wr_to_wb_is_csr_r; // @[Reg.scala 27:20]
  reg [7:0] io_wr_to_wb_csrop_r; // @[Reg.scala 27:20]
  reg [11:0] io_wr_to_wb_csr_addr_r; // @[Reg.scala 27:20]
  reg [63:0] io_wr_to_wb_csr_src_r; // @[Reg.scala 27:20]
  reg  io_wr_to_wb_is_zero_r; // @[Reg.scala 27:20]
  assign io_ws_valid = io_ws_valid_r; // @[wr.scala 17:15]
  assign io_wr_to_wb_is_nop = io_wr_to_wb_is_nop_r; // @[wr.scala 19:22]
  assign io_wr_to_wb_lsu_res = io_wr_to_wb_lsu_res_r; // @[wr.scala 21:23]
  assign io_wr_to_wb_dest = io_wr_to_wb_dest_r; // @[wr.scala 23:20]
  assign io_wr_to_wb_rf_w = io_wr_to_wb_rf_w_r; // @[wr.scala 24:20]
  assign io_wr_to_wb_pc = io_wr_to_wb_pc_r; // @[wr.scala 26:18]
  assign io_wr_to_wb_inst = io_wr_to_wb_inst_r; // @[wr.scala 27:20]
  assign io_wr_to_wb_is_csr = io_wr_to_wb_is_csr_r; // @[wr.scala 29:22]
  assign io_wr_to_wb_csrop = io_wr_to_wb_csrop_r; // @[wr.scala 30:21]
  assign io_wr_to_wb_csr_addr = io_wr_to_wb_csr_addr_r; // @[wr.scala 31:24]
  assign io_wr_to_wb_csr_src = io_wr_to_wb_csr_src_r; // @[wr.scala 32:23]
  assign io_wr_to_wb_is_zero = io_wr_to_wb_is_zero_r; // @[wr.scala 33:23]
  always @(posedge clock) begin
    io_ws_valid_r <= reset | io_ls_to_ws_valid; // @[Reg.scala 27:20 Reg.scala 27:20]
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_is_nop_r <= 1'h0; // @[Reg.scala 27:20]
    end else begin
      io_wr_to_wb_is_nop_r <= io_lsu_to_wr_is_nop;
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_lsu_res_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (io_ls_to_ws_valid) begin // @[Reg.scala 28:19]
      io_wr_to_wb_lsu_res_r <= io_lsu_to_wr_lsu_res; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_dest_r <= 5'h0; // @[Reg.scala 27:20]
    end else if (io_ls_to_ws_valid) begin // @[Reg.scala 28:19]
      io_wr_to_wb_dest_r <= io_lsu_to_wr_dest; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_rf_w_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (io_ls_to_ws_valid) begin // @[Reg.scala 28:19]
      io_wr_to_wb_rf_w_r <= io_lsu_to_wr_rf_w; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_pc_r <= 64'h0; // @[Reg.scala 27:20]
    end else begin
      io_wr_to_wb_pc_r <= io_lsu_to_wr_pc;
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_inst_r <= 32'h0; // @[Reg.scala 27:20]
    end else begin
      io_wr_to_wb_inst_r <= io_lsu_to_wr_inst;
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_is_csr_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (io_ls_to_ws_valid) begin // @[Reg.scala 28:19]
      io_wr_to_wb_is_csr_r <= io_lsu_to_wr_is_csr; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_csrop_r <= 8'h0; // @[Reg.scala 27:20]
    end else if (io_ls_to_ws_valid) begin // @[Reg.scala 28:19]
      io_wr_to_wb_csrop_r <= io_lsu_to_wr_csrop; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_csr_addr_r <= 12'h0; // @[Reg.scala 27:20]
    end else if (io_ls_to_ws_valid) begin // @[Reg.scala 28:19]
      io_wr_to_wb_csr_addr_r <= io_lsu_to_wr_csr_addr; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_csr_src_r <= 64'h0; // @[Reg.scala 27:20]
    end else if (io_ls_to_ws_valid) begin // @[Reg.scala 28:19]
      io_wr_to_wb_csr_src_r <= io_lsu_to_wr_csr_src; // @[Reg.scala 28:23]
    end
    if (reset) begin // @[Reg.scala 27:20]
      io_wr_to_wb_is_zero_r <= 1'h0; // @[Reg.scala 27:20]
    end else if (io_ls_to_ws_valid) begin // @[Reg.scala 28:19]
      io_wr_to_wb_is_zero_r <= io_lsu_to_wr_is_zero; // @[Reg.scala 28:23]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  io_ws_valid_r = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  io_wr_to_wb_is_nop_r = _RAND_1[0:0];
  _RAND_2 = {2{`RANDOM}};
  io_wr_to_wb_lsu_res_r = _RAND_2[63:0];
  _RAND_3 = {1{`RANDOM}};
  io_wr_to_wb_dest_r = _RAND_3[4:0];
  _RAND_4 = {1{`RANDOM}};
  io_wr_to_wb_rf_w_r = _RAND_4[0:0];
  _RAND_5 = {2{`RANDOM}};
  io_wr_to_wb_pc_r = _RAND_5[63:0];
  _RAND_6 = {1{`RANDOM}};
  io_wr_to_wb_inst_r = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  io_wr_to_wb_is_csr_r = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  io_wr_to_wb_csrop_r = _RAND_8[7:0];
  _RAND_9 = {1{`RANDOM}};
  io_wr_to_wb_csr_addr_r = _RAND_9[11:0];
  _RAND_10 = {2{`RANDOM}};
  io_wr_to_wb_csr_src_r = _RAND_10[63:0];
  _RAND_11 = {1{`RANDOM}};
  io_wr_to_wb_is_zero_r = _RAND_11[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module WB(
  input         io_ws_valid,
  input         io_lsu_to_wb_is_nop,
  input  [63:0] io_lsu_to_wb_lsu_res,
  input  [4:0]  io_lsu_to_wb_dest,
  input         io_lsu_to_wb_rf_w,
  input  [63:0] io_lsu_to_wb_pc,
  input  [31:0] io_lsu_to_wb_inst,
  input         io_lsu_to_wb_is_csr,
  input  [7:0]  io_lsu_to_wb_csrop,
  input  [11:0] io_lsu_to_wb_csr_addr,
  input  [63:0] io_lsu_to_wb_csr_src,
  input         io_lsu_to_wb_is_zero,
  output        io_wb_to_csr_is_nop,
  output [7:0]  io_wb_to_csr_csrop,
  output [11:0] io_wb_to_csr_csr_addr,
  output [63:0] io_wb_to_csr_csr_src,
  output        io_wb_to_csr_is_zero,
  output [63:0] io_wb_to_csr_pc,
  input  [63:0] io_wb_to_csr_csr_res,
  output        io_wb_fwd_rf_w,
  output [4:0]  io_wb_fwd_dst,
  output [63:0] io_wb_fwd_wb_res,
  output [4:0]  io_rd_addr,
  output [63:0] io_rd_data,
  output        io_rd_en,
  output [63:0] io_pc,
  output [31:0] io_inst,
  output        io_is_nop,
  input         io_flush
);
  wire [63:0] inst = io_flush ? 64'h13 : {{32'd0}, io_lsu_to_wb_inst}; // @[WB.scala 26:17]
  wire  _ws_allowin_T = ~io_ws_valid; // @[WB.scala 34:17]
  wire  _rd_addr_T_1 = io_ws_valid & inst != 64'h13; // @[WB.scala 41:30]
  wire  rd_en = _rd_addr_T_1 & io_lsu_to_wb_rf_w; // @[WB.scala 45:18]
  wire [63:0] _io_is_nop_T = io_flush ? 64'h13 : {{63'd0}, io_lsu_to_wb_is_nop}; // @[WB.scala 54:19]
  assign io_wb_to_csr_is_nop = io_lsu_to_wb_is_nop; // @[WB.scala 56:23]
  assign io_wb_to_csr_csrop = inst == 64'h13 ? 8'h0 : io_lsu_to_wb_csrop; // @[WB.scala 58:28]
  assign io_wb_to_csr_csr_addr = io_lsu_to_wb_csr_addr; // @[WB.scala 59:25]
  assign io_wb_to_csr_csr_src = io_lsu_to_wb_csr_src; // @[WB.scala 60:24]
  assign io_wb_to_csr_is_zero = io_lsu_to_wb_is_zero; // @[WB.scala 61:24]
  assign io_wb_to_csr_pc = io_lsu_to_wb_pc; // @[WB.scala 62:19]
  assign io_wb_fwd_rf_w = _ws_allowin_T ? 1'h0 : rd_en; // @[WB.scala 48:24]
  assign io_wb_fwd_dst = io_ws_valid & inst != 64'h13 ? io_lsu_to_wb_dest : 5'h0; // @[WB.scala 41:20]
  assign io_wb_fwd_wb_res = io_lsu_to_wb_is_csr ? io_wb_to_csr_csr_res : io_lsu_to_wb_lsu_res; // @[WB.scala 43:20]
  assign io_rd_addr = io_ws_valid & inst != 64'h13 ? io_lsu_to_wb_dest : 5'h0; // @[WB.scala 41:20]
  assign io_rd_data = io_lsu_to_wb_is_csr ? io_wb_to_csr_csr_res : io_lsu_to_wb_lsu_res; // @[WB.scala 43:20]
  assign io_rd_en = _rd_addr_T_1 & io_lsu_to_wb_rf_w; // @[WB.scala 45:18]
  assign io_pc = io_lsu_to_wb_pc; // @[WB.scala 52:9]
  assign io_inst = inst[31:0]; // @[WB.scala 53:11]
  assign io_is_nop = _io_is_nop_T[0]; // @[WB.scala 54:13]
endmodule
module RegFile(
  input         clock,
  input         reset,
  input  [4:0]  io_rs1_addr,
  input  [4:0]  io_rs2_addr,
  output [63:0] io_rs1_data,
  output [63:0] io_rs2_data,
  input  [4:0]  io_rd_addr,
  input  [63:0] io_rd_data,
  input         io_rd_en,
  output [63:0] rf_10
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [63:0] _RAND_2;
  reg [63:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [63:0] _RAND_7;
  reg [63:0] _RAND_8;
  reg [63:0] _RAND_9;
  reg [63:0] _RAND_10;
  reg [63:0] _RAND_11;
  reg [63:0] _RAND_12;
  reg [63:0] _RAND_13;
  reg [63:0] _RAND_14;
  reg [63:0] _RAND_15;
  reg [63:0] _RAND_16;
  reg [63:0] _RAND_17;
  reg [63:0] _RAND_18;
  reg [63:0] _RAND_19;
  reg [63:0] _RAND_20;
  reg [63:0] _RAND_21;
  reg [63:0] _RAND_22;
  reg [63:0] _RAND_23;
  reg [63:0] _RAND_24;
  reg [63:0] _RAND_25;
  reg [63:0] _RAND_26;
  reg [63:0] _RAND_27;
  reg [63:0] _RAND_28;
  reg [63:0] _RAND_29;
  reg [63:0] _RAND_30;
  reg [63:0] _RAND_31;
`endif // RANDOMIZE_REG_INIT
  wire  dt_ar_clock; // @[RegFile.scala 26:21]
  wire [7:0] dt_ar_coreid; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_0; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_1; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_2; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_3; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_4; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_5; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_6; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_7; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_8; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_9; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_10; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_11; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_12; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_13; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_14; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_15; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_16; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_17; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_18; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_19; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_20; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_21; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_22; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_23; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_24; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_25; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_26; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_27; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_28; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_29; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_30; // @[RegFile.scala 26:21]
  wire [63:0] dt_ar_gpr_31; // @[RegFile.scala 26:21]
  reg [63:0] rf__0; // @[RegFile.scala 17:19]
  reg [63:0] rf__1; // @[RegFile.scala 17:19]
  reg [63:0] rf__2; // @[RegFile.scala 17:19]
  reg [63:0] rf__3; // @[RegFile.scala 17:19]
  reg [63:0] rf__4; // @[RegFile.scala 17:19]
  reg [63:0] rf__5; // @[RegFile.scala 17:19]
  reg [63:0] rf__6; // @[RegFile.scala 17:19]
  reg [63:0] rf__7; // @[RegFile.scala 17:19]
  reg [63:0] rf__8; // @[RegFile.scala 17:19]
  reg [63:0] rf__9; // @[RegFile.scala 17:19]
  reg [63:0] rf__10; // @[RegFile.scala 17:19]
  reg [63:0] rf__11; // @[RegFile.scala 17:19]
  reg [63:0] rf__12; // @[RegFile.scala 17:19]
  reg [63:0] rf__13; // @[RegFile.scala 17:19]
  reg [63:0] rf__14; // @[RegFile.scala 17:19]
  reg [63:0] rf__15; // @[RegFile.scala 17:19]
  reg [63:0] rf__16; // @[RegFile.scala 17:19]
  reg [63:0] rf__17; // @[RegFile.scala 17:19]
  reg [63:0] rf__18; // @[RegFile.scala 17:19]
  reg [63:0] rf__19; // @[RegFile.scala 17:19]
  reg [63:0] rf__20; // @[RegFile.scala 17:19]
  reg [63:0] rf__21; // @[RegFile.scala 17:19]
  reg [63:0] rf__22; // @[RegFile.scala 17:19]
  reg [63:0] rf__23; // @[RegFile.scala 17:19]
  reg [63:0] rf__24; // @[RegFile.scala 17:19]
  reg [63:0] rf__25; // @[RegFile.scala 17:19]
  reg [63:0] rf__26; // @[RegFile.scala 17:19]
  reg [63:0] rf__27; // @[RegFile.scala 17:19]
  reg [63:0] rf__28; // @[RegFile.scala 17:19]
  reg [63:0] rf__29; // @[RegFile.scala 17:19]
  reg [63:0] rf__30; // @[RegFile.scala 17:19]
  reg [63:0] rf__31; // @[RegFile.scala 17:19]
  wire [63:0] _GEN_65 = 5'h1 == io_rs1_addr ? rf__1 : rf__0; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_66 = 5'h2 == io_rs1_addr ? rf__2 : _GEN_65; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_67 = 5'h3 == io_rs1_addr ? rf__3 : _GEN_66; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_68 = 5'h4 == io_rs1_addr ? rf__4 : _GEN_67; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_69 = 5'h5 == io_rs1_addr ? rf__5 : _GEN_68; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_70 = 5'h6 == io_rs1_addr ? rf__6 : _GEN_69; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_71 = 5'h7 == io_rs1_addr ? rf__7 : _GEN_70; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_72 = 5'h8 == io_rs1_addr ? rf__8 : _GEN_71; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_73 = 5'h9 == io_rs1_addr ? rf__9 : _GEN_72; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_74 = 5'ha == io_rs1_addr ? rf__10 : _GEN_73; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_75 = 5'hb == io_rs1_addr ? rf__11 : _GEN_74; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_76 = 5'hc == io_rs1_addr ? rf__12 : _GEN_75; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_77 = 5'hd == io_rs1_addr ? rf__13 : _GEN_76; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_78 = 5'he == io_rs1_addr ? rf__14 : _GEN_77; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_79 = 5'hf == io_rs1_addr ? rf__15 : _GEN_78; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_80 = 5'h10 == io_rs1_addr ? rf__16 : _GEN_79; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_81 = 5'h11 == io_rs1_addr ? rf__17 : _GEN_80; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_82 = 5'h12 == io_rs1_addr ? rf__18 : _GEN_81; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_83 = 5'h13 == io_rs1_addr ? rf__19 : _GEN_82; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_84 = 5'h14 == io_rs1_addr ? rf__20 : _GEN_83; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_85 = 5'h15 == io_rs1_addr ? rf__21 : _GEN_84; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_86 = 5'h16 == io_rs1_addr ? rf__22 : _GEN_85; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_87 = 5'h17 == io_rs1_addr ? rf__23 : _GEN_86; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_88 = 5'h18 == io_rs1_addr ? rf__24 : _GEN_87; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_89 = 5'h19 == io_rs1_addr ? rf__25 : _GEN_88; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_90 = 5'h1a == io_rs1_addr ? rf__26 : _GEN_89; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_91 = 5'h1b == io_rs1_addr ? rf__27 : _GEN_90; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_92 = 5'h1c == io_rs1_addr ? rf__28 : _GEN_91; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_93 = 5'h1d == io_rs1_addr ? rf__29 : _GEN_92; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_94 = 5'h1e == io_rs1_addr ? rf__30 : _GEN_93; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_95 = 5'h1f == io_rs1_addr ? rf__31 : _GEN_94; // @[RegFile.scala 23:21 RegFile.scala 23:21]
  wire [63:0] _GEN_97 = 5'h1 == io_rs2_addr ? rf__1 : rf__0; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_98 = 5'h2 == io_rs2_addr ? rf__2 : _GEN_97; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_99 = 5'h3 == io_rs2_addr ? rf__3 : _GEN_98; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_100 = 5'h4 == io_rs2_addr ? rf__4 : _GEN_99; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_101 = 5'h5 == io_rs2_addr ? rf__5 : _GEN_100; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_102 = 5'h6 == io_rs2_addr ? rf__6 : _GEN_101; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_103 = 5'h7 == io_rs2_addr ? rf__7 : _GEN_102; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_104 = 5'h8 == io_rs2_addr ? rf__8 : _GEN_103; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_105 = 5'h9 == io_rs2_addr ? rf__9 : _GEN_104; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_106 = 5'ha == io_rs2_addr ? rf__10 : _GEN_105; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_107 = 5'hb == io_rs2_addr ? rf__11 : _GEN_106; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_108 = 5'hc == io_rs2_addr ? rf__12 : _GEN_107; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_109 = 5'hd == io_rs2_addr ? rf__13 : _GEN_108; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_110 = 5'he == io_rs2_addr ? rf__14 : _GEN_109; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_111 = 5'hf == io_rs2_addr ? rf__15 : _GEN_110; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_112 = 5'h10 == io_rs2_addr ? rf__16 : _GEN_111; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_113 = 5'h11 == io_rs2_addr ? rf__17 : _GEN_112; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_114 = 5'h12 == io_rs2_addr ? rf__18 : _GEN_113; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_115 = 5'h13 == io_rs2_addr ? rf__19 : _GEN_114; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_116 = 5'h14 == io_rs2_addr ? rf__20 : _GEN_115; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_117 = 5'h15 == io_rs2_addr ? rf__21 : _GEN_116; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_118 = 5'h16 == io_rs2_addr ? rf__22 : _GEN_117; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_119 = 5'h17 == io_rs2_addr ? rf__23 : _GEN_118; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_120 = 5'h18 == io_rs2_addr ? rf__24 : _GEN_119; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_121 = 5'h19 == io_rs2_addr ? rf__25 : _GEN_120; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_122 = 5'h1a == io_rs2_addr ? rf__26 : _GEN_121; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_123 = 5'h1b == io_rs2_addr ? rf__27 : _GEN_122; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_124 = 5'h1c == io_rs2_addr ? rf__28 : _GEN_123; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_125 = 5'h1d == io_rs2_addr ? rf__29 : _GEN_124; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_126 = 5'h1e == io_rs2_addr ? rf__30 : _GEN_125; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  wire [63:0] _GEN_127 = 5'h1f == io_rs2_addr ? rf__31 : _GEN_126; // @[RegFile.scala 24:21 RegFile.scala 24:21]
  DifftestArchIntRegState dt_ar ( // @[RegFile.scala 26:21]
    .clock(dt_ar_clock),
    .coreid(dt_ar_coreid),
    .gpr_0(dt_ar_gpr_0),
    .gpr_1(dt_ar_gpr_1),
    .gpr_2(dt_ar_gpr_2),
    .gpr_3(dt_ar_gpr_3),
    .gpr_4(dt_ar_gpr_4),
    .gpr_5(dt_ar_gpr_5),
    .gpr_6(dt_ar_gpr_6),
    .gpr_7(dt_ar_gpr_7),
    .gpr_8(dt_ar_gpr_8),
    .gpr_9(dt_ar_gpr_9),
    .gpr_10(dt_ar_gpr_10),
    .gpr_11(dt_ar_gpr_11),
    .gpr_12(dt_ar_gpr_12),
    .gpr_13(dt_ar_gpr_13),
    .gpr_14(dt_ar_gpr_14),
    .gpr_15(dt_ar_gpr_15),
    .gpr_16(dt_ar_gpr_16),
    .gpr_17(dt_ar_gpr_17),
    .gpr_18(dt_ar_gpr_18),
    .gpr_19(dt_ar_gpr_19),
    .gpr_20(dt_ar_gpr_20),
    .gpr_21(dt_ar_gpr_21),
    .gpr_22(dt_ar_gpr_22),
    .gpr_23(dt_ar_gpr_23),
    .gpr_24(dt_ar_gpr_24),
    .gpr_25(dt_ar_gpr_25),
    .gpr_26(dt_ar_gpr_26),
    .gpr_27(dt_ar_gpr_27),
    .gpr_28(dt_ar_gpr_28),
    .gpr_29(dt_ar_gpr_29),
    .gpr_30(dt_ar_gpr_30),
    .gpr_31(dt_ar_gpr_31)
  );
  assign io_rs1_data = io_rs1_addr != 5'h0 ? _GEN_95 : 64'h0; // @[RegFile.scala 23:21]
  assign io_rs2_data = io_rs2_addr != 5'h0 ? _GEN_127 : 64'h0; // @[RegFile.scala 24:21]
  assign rf_10 = rf__10;
  assign dt_ar_clock = clock; // @[RegFile.scala 27:19]
  assign dt_ar_coreid = 8'h0; // @[RegFile.scala 28:19]
  assign dt_ar_gpr_0 = rf__0; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_1 = rf__1; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_2 = rf__2; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_3 = rf__3; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_4 = rf__4; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_5 = rf__5; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_6 = rf__6; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_7 = rf__7; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_8 = rf__8; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_9 = rf__9; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_10 = rf__10; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_11 = rf__11; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_12 = rf__12; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_13 = rf__13; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_14 = rf__14; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_15 = rf__15; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_16 = rf__16; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_17 = rf__17; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_18 = rf__18; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_19 = rf__19; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_20 = rf__20; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_21 = rf__21; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_22 = rf__22; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_23 = rf__23; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_24 = rf__24; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_25 = rf__25; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_26 = rf__26; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_27 = rf__27; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_28 = rf__28; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_29 = rf__29; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_30 = rf__30; // @[RegFile.scala 29:19]
  assign dt_ar_gpr_31 = rf__31; // @[RegFile.scala 29:19]
  always @(posedge clock) begin
    if (reset) begin // @[RegFile.scala 17:19]
      rf__0 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h0 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__0 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__1 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h1 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__1 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__2 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h2 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__2 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__3 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h3 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__3 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__4 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h4 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__4 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__5 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h5 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__5 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__6 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h6 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__6 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__7 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h7 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__7 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__8 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h8 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__8 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__9 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h9 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__9 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__10 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'ha == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__10 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__11 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'hb == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__11 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__12 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'hc == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__12 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__13 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'hd == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__13 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__14 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'he == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__14 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__15 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'hf == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__15 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__16 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h10 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__16 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__17 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h11 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__17 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__18 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h12 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__18 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__19 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h13 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__19 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__20 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h14 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__20 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__21 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h15 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__21 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__22 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h16 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__22 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__23 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h17 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__23 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__24 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h18 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__24 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__25 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h19 == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__25 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__26 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h1a == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__26 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__27 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h1b == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__27 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__28 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h1c == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__28 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__29 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h1d == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__29 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__30 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h1e == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__30 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
    if (reset) begin // @[RegFile.scala 17:19]
      rf__31 <= 64'h0; // @[RegFile.scala 17:19]
    end else if (io_rd_en & io_rd_addr != 5'h0) begin // @[RegFile.scala 19:43]
      if (5'h1f == io_rd_addr) begin // @[RegFile.scala 20:20]
        rf__31 <= io_rd_data; // @[RegFile.scala 20:20]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {2{`RANDOM}};
  rf__0 = _RAND_0[63:0];
  _RAND_1 = {2{`RANDOM}};
  rf__1 = _RAND_1[63:0];
  _RAND_2 = {2{`RANDOM}};
  rf__2 = _RAND_2[63:0];
  _RAND_3 = {2{`RANDOM}};
  rf__3 = _RAND_3[63:0];
  _RAND_4 = {2{`RANDOM}};
  rf__4 = _RAND_4[63:0];
  _RAND_5 = {2{`RANDOM}};
  rf__5 = _RAND_5[63:0];
  _RAND_6 = {2{`RANDOM}};
  rf__6 = _RAND_6[63:0];
  _RAND_7 = {2{`RANDOM}};
  rf__7 = _RAND_7[63:0];
  _RAND_8 = {2{`RANDOM}};
  rf__8 = _RAND_8[63:0];
  _RAND_9 = {2{`RANDOM}};
  rf__9 = _RAND_9[63:0];
  _RAND_10 = {2{`RANDOM}};
  rf__10 = _RAND_10[63:0];
  _RAND_11 = {2{`RANDOM}};
  rf__11 = _RAND_11[63:0];
  _RAND_12 = {2{`RANDOM}};
  rf__12 = _RAND_12[63:0];
  _RAND_13 = {2{`RANDOM}};
  rf__13 = _RAND_13[63:0];
  _RAND_14 = {2{`RANDOM}};
  rf__14 = _RAND_14[63:0];
  _RAND_15 = {2{`RANDOM}};
  rf__15 = _RAND_15[63:0];
  _RAND_16 = {2{`RANDOM}};
  rf__16 = _RAND_16[63:0];
  _RAND_17 = {2{`RANDOM}};
  rf__17 = _RAND_17[63:0];
  _RAND_18 = {2{`RANDOM}};
  rf__18 = _RAND_18[63:0];
  _RAND_19 = {2{`RANDOM}};
  rf__19 = _RAND_19[63:0];
  _RAND_20 = {2{`RANDOM}};
  rf__20 = _RAND_20[63:0];
  _RAND_21 = {2{`RANDOM}};
  rf__21 = _RAND_21[63:0];
  _RAND_22 = {2{`RANDOM}};
  rf__22 = _RAND_22[63:0];
  _RAND_23 = {2{`RANDOM}};
  rf__23 = _RAND_23[63:0];
  _RAND_24 = {2{`RANDOM}};
  rf__24 = _RAND_24[63:0];
  _RAND_25 = {2{`RANDOM}};
  rf__25 = _RAND_25[63:0];
  _RAND_26 = {2{`RANDOM}};
  rf__26 = _RAND_26[63:0];
  _RAND_27 = {2{`RANDOM}};
  rf__27 = _RAND_27[63:0];
  _RAND_28 = {2{`RANDOM}};
  rf__28 = _RAND_28[63:0];
  _RAND_29 = {2{`RANDOM}};
  rf__29 = _RAND_29[63:0];
  _RAND_30 = {2{`RANDOM}};
  rf__30 = _RAND_30[63:0];
  _RAND_31 = {2{`RANDOM}};
  rf__31 = _RAND_31[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module CSR(
  input         clock,
  input         reset,
  input         io_wb_to_csr_is_nop,
  input  [7:0]  io_wb_to_csr_csrop,
  input  [11:0] io_wb_to_csr_csr_addr,
  input  [63:0] io_wb_to_csr_csr_src,
  input         io_wb_to_csr_is_zero,
  input  [63:0] io_wb_to_csr_pc,
  output [63:0] io_wb_to_csr_csr_res,
  output        io_csr_to_id_csr_jump,
  output [63:0] io_csr_to_id_csr_target,
  input         io_csr_to_lsu_is_clint,
  input         io_csr_to_lsu_is_mtime,
  input         io_csr_to_lsu_is_mtimecmp,
  input         io_csr_to_lsu_load,
  input         io_csr_to_lsu_save,
  input  [63:0] io_csr_to_lsu_wdata,
  output [63:0] io_csr_to_lsu_rdata,
  output [63:0] io_mepc,
  output [63:0] io_mcause,
  output [63:0] io_mtvec,
  output [63:0] io_mstatus,
  output [63:0] io_mie,
  output [63:0] io_mscratch,
  output [63:0] io_sstatus,
  output [31:0] io_intrNO,
  output [31:0] io_cause,
  output        io_clkintr_flush
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [63:0] _RAND_2;
  reg [63:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [63:0] _RAND_7;
  reg [63:0] _RAND_8;
  reg [63:0] _RAND_9;
`endif // RANDOMIZE_REG_INIT
  reg [63:0] mcycle; // @[CSR.scala 38:23]
  wire [63:0] _mcycle_T_1 = mcycle + 64'h1; // @[CSR.scala 40:22]
  reg [63:0] mepc; // @[CSR.scala 42:17]
  reg [63:0] mcause; // @[CSR.scala 43:23]
  reg [63:0] mtvec; // @[CSR.scala 44:22]
  reg [62:0] mstatus_i; // @[CSR.scala 45:26]
  wire  mSD = mstatus_i[16:15] == 2'h3 | mstatus_i[14:13] == 2'h3; // @[CSR.scala 47:40]
  wire [63:0] mstatus = {mSD,mstatus_i}; // @[Cat.scala 30:58]
  reg [63:0] mscratch; // @[CSR.scala 50:25]
  reg [63:0] mie; // @[CSR.scala 52:20]
  reg [63:0] mip; // @[CSR.scala 53:20]
  reg [63:0] mtime; // @[CSR.scala 78:22]
  wire [63:0] _mtime_T_1 = mtime + 64'h1; // @[CSR.scala 80:20]
  reg [63:0] mtimecmp; // @[CSR.scala 82:25]
  wire [63:0] _clint_out_T = io_csr_to_lsu_is_mtimecmp ? mtimecmp : 64'h0; // @[CSR.scala 92:42]
  wire [63:0] _clint_out_T_1 = io_csr_to_lsu_is_mtime ? mtime : _clint_out_T; // @[CSR.scala 92:23]
  wire [63:0] _GEN_2 = io_csr_to_lsu_is_mtimecmp ? io_csr_to_lsu_wdata : mtimecmp; // @[CSR.scala 96:30 CSR.scala 97:18 CSR.scala 82:25]
  wire [63:0] _GEN_3 = io_csr_to_lsu_is_mtime ? io_csr_to_lsu_wdata : _mtime_T_1; // @[CSR.scala 94:21 CSR.scala 95:15]
  wire [63:0] _GEN_4 = io_csr_to_lsu_is_mtime ? mtimecmp : _GEN_2; // @[CSR.scala 94:21 CSR.scala 82:25]
  wire [63:0] _GEN_7 = io_csr_to_lsu_load ? _clint_out_T_1 : 64'h0; // @[CSR.scala 91:15 CSR.scala 92:17]
  wire  clk_int = io_wb_to_csr_is_nop ? 1'h0 : mip[7]; // @[CSR.scala 102:20]
  wire  _csr_data_o_T_1 = io_wb_to_csr_csr_addr == 12'hb00; // @[CSR.scala 109:17]
  wire  _csr_data_o_T_2 = io_wb_to_csr_csr_addr == 12'h341; // @[CSR.scala 110:17]
  wire  _csr_data_o_T_3 = io_wb_to_csr_csr_addr == 12'h342; // @[CSR.scala 111:17]
  wire  _csr_data_o_T_4 = io_wb_to_csr_csr_addr == 12'h305; // @[CSR.scala 112:17]
  wire  _csr_data_o_T_5 = io_wb_to_csr_csr_addr == 12'h300; // @[CSR.scala 113:17]
  wire  _csr_data_o_T_6 = io_wb_to_csr_csr_addr == 12'h344; // @[CSR.scala 114:17]
  wire  _csr_data_o_T_7 = io_wb_to_csr_csr_addr == 12'h304; // @[CSR.scala 115:17]
  wire [63:0] _csr_data_o_T_9 = _csr_data_o_T_1 ? mcycle : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_10 = _csr_data_o_T_2 ? mepc : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_11 = _csr_data_o_T_3 ? mcause : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_12 = _csr_data_o_T_4 ? mtvec : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_13 = _csr_data_o_T_5 ? mstatus : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_14 = _csr_data_o_T_6 ? mip : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_15 = _csr_data_o_T_7 ? mie : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_17 = _csr_data_o_T_9 | _csr_data_o_T_10; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_18 = _csr_data_o_T_17 | _csr_data_o_T_11; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_19 = _csr_data_o_T_18 | _csr_data_o_T_12; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_20 = _csr_data_o_T_19 | _csr_data_o_T_13; // @[Mux.scala 27:72]
  wire [63:0] _csr_data_o_T_21 = _csr_data_o_T_20 | _csr_data_o_T_14; // @[Mux.scala 27:72]
  wire [63:0] csr_data_o = _csr_data_o_T_21 | _csr_data_o_T_15; // @[Mux.scala 27:72]
  wire  is_rw = io_wb_to_csr_csrop == 8'h1 | io_wb_to_csr_csrop == 8'h4; // @[CSR.scala 121:33]
  wire  is_rs = io_wb_to_csr_csrop == 8'h2 | io_wb_to_csr_csrop == 8'h5; // @[CSR.scala 122:33]
  wire  is_rc = io_wb_to_csr_csrop == 8'h3 | io_wb_to_csr_csrop == 8'h6; // @[CSR.scala 123:33]
  wire  _is_trap_begin_T = io_wb_to_csr_csrop == 8'h7; // @[CSR.scala 125:30]
  wire  is_trap_begin = io_wb_to_csr_csrop == 8'h7 | clk_int; // @[CSR.scala 125:45]
  wire  is_trap_end = io_wb_to_csr_csrop == 8'h8; // @[CSR.scala 126:28]
  wire  is_csrop = is_rw | is_rs | is_rc; // @[CSR.scala 145:33]
  wire [63:0] _csr_mask_T = io_wb_to_csr_is_zero ? 64'h0 : 64'hffffffffffffffff; // @[CSR.scala 150:22]
  wire [63:0] _csr_mask_T_1 = io_wb_to_csr_is_zero ? 64'h0 : io_wb_to_csr_csr_src; // @[CSR.scala 154:22]
  wire [63:0] _csr_data_i_T = ~io_wb_to_csr_csr_src; // @[CSR.scala 157:21]
  wire [63:0] _GEN_13 = is_rc ? csr_data_o : 64'h0; // @[CSR.scala 155:23 CSR.scala 156:15]
  wire [63:0] _GEN_14 = is_rc ? _csr_data_i_T : 64'h0; // @[CSR.scala 155:23 CSR.scala 157:18]
  wire [63:0] _GEN_15 = is_rc ? _csr_mask_T_1 : 64'h0; // @[CSR.scala 155:23 CSR.scala 158:16]
  wire [63:0] _GEN_16 = is_rs ? csr_data_o : _GEN_13; // @[CSR.scala 151:23 CSR.scala 152:15]
  wire [63:0] _GEN_17 = is_rs ? io_wb_to_csr_csr_src : _GEN_14; // @[CSR.scala 151:23 CSR.scala 153:18]
  wire [63:0] _GEN_18 = is_rs ? _csr_mask_T_1 : _GEN_15; // @[CSR.scala 151:23 CSR.scala 154:16]
  wire [63:0] _GEN_19 = is_rw ? csr_data_o : _GEN_16; // @[CSR.scala 147:17 CSR.scala 148:15]
  wire [63:0] _GEN_20 = is_rw ? io_wb_to_csr_csr_src : _GEN_17; // @[CSR.scala 147:17 CSR.scala 149:18]
  wire [63:0] _GEN_21 = is_rw ? _csr_mask_T : _GEN_18; // @[CSR.scala 147:17 CSR.scala 150:16]
  wire [63:0] csr_mask = is_csrop ? _GEN_21 : 64'h0; // @[CSR.scala 146:17]
  wire [63:0] _mcycle_T_2 = ~csr_mask; // @[CSR.scala 162:27]
  wire [63:0] _mcycle_T_3 = mcycle & _mcycle_T_2; // @[CSR.scala 162:25]
  wire [63:0] csr_data_i = is_csrop ? _GEN_20 : 64'h0; // @[CSR.scala 146:17]
  wire [63:0] _mcycle_T_4 = csr_data_i & csr_mask; // @[CSR.scala 162:52]
  wire [63:0] _mcycle_T_5 = _mcycle_T_3 | _mcycle_T_4; // @[CSR.scala 162:38]
  wire [63:0] _mepc_T_1 = mepc & _mcycle_T_2; // @[CSR.scala 165:21]
  wire [63:0] _mepc_T_3 = _mepc_T_1 | _mcycle_T_4; // @[CSR.scala 165:34]
  wire [63:0] _mcause_T_1 = mcause & _mcycle_T_2; // @[CSR.scala 168:25]
  wire [63:0] _mcause_T_3 = _mcause_T_1 | _mcycle_T_4; // @[CSR.scala 168:38]
  wire [63:0] _mtvec_T_1 = mtvec & _mcycle_T_2; // @[CSR.scala 171:23]
  wire [63:0] _mtvec_T_3 = _mtvec_T_1 | _mcycle_T_4; // @[CSR.scala 171:36]
  wire [62:0] _lo_T_2 = ~csr_mask[62:0]; // @[CSR.scala 174:37]
  wire [62:0] _lo_T_3 = mstatus[62:0] & _lo_T_2; // @[CSR.scala 174:35]
  wire [62:0] _lo_T_6 = csr_data_i[62:0] & csr_mask[62:0]; // @[CSR.scala 174:74]
  wire [62:0] _lo_T_7 = _lo_T_3 | _lo_T_6; // @[CSR.scala 174:54]
  wire [49:0] lo_hi_hi_hi_3 = mstatus[62:13]; // @[CSR.scala 217:36]
  wire [2:0] lo_hi_lo_hi_3 = mstatus[10:8]; // @[CSR.scala 217:64]
  wire  lo_hi_lo_lo_3 = mstatus[3]; // @[CSR.scala 217:78]
  wire [2:0] lo_lo_hi_hi_3 = mstatus[6:4]; // @[CSR.scala 217:89]
  wire [2:0] lo_lo_lo_3 = mstatus[2:0]; // @[CSR.scala 217:106]
  wire [62:0] _lo_T_11 = {lo_hi_hi_hi_3,2'h3,lo_hi_lo_hi_3,lo_hi_lo_lo_3,lo_lo_hi_hi_3,1'h0,lo_lo_lo_3}; // @[Cat.scala 30:58]
  wire [62:0] _GEN_35 = _csr_data_o_T_5 ? _lo_T_7 : 63'h0; // @[CSR.scala 173:40 CSR.scala 176:19]
  wire [62:0] _GEN_48 = _csr_data_o_T_4 ? 63'h0 : _GEN_35; // @[CSR.scala 170:38]
  wire [62:0] _GEN_63 = _csr_data_o_T_3 ? 63'h0 : _GEN_48; // @[CSR.scala 167:39]
  wire [62:0] _GEN_80 = _csr_data_o_T_2 ? 63'h0 : _GEN_63; // @[CSR.scala 164:37]
  wire [62:0] _GEN_99 = _csr_data_o_T_1 ? 63'h0 : _GEN_80; // @[CSR.scala 161:33]
  wire [62:0] _GEN_121 = is_csrop ? _GEN_99 : 63'h0; // @[CSR.scala 146:17]
  wire [62:0] _GEN_135 = _is_trap_begin_T ? _lo_T_11 : _GEN_121; // @[CSR.scala 193:30 CSR.scala 200:19]
  wire [62:0] _GEN_145 = clk_int ? _lo_T_11 : _GEN_135; // @[CSR.scala 207:18 CSR.scala 217:19]
  wire  lo_lo_hi_lo_1 = mstatus[7]; // @[CSR.scala 234:95]
  wire [62:0] _lo_T_13 = {lo_hi_hi_hi_3,2'h0,lo_hi_lo_hi_3,1'h1,lo_lo_hi_hi_3,lo_lo_hi_lo_1,lo_lo_lo_3}; // @[Cat.scala 30:58]
  wire [62:0] _GEN_153 = is_trap_end ? _lo_T_13 : _GEN_121; // @[CSR.scala 231:29 CSR.scala 234:19]
  wire [62:0] _GEN_158 = is_trap_end ? _GEN_153 : _GEN_121; // @[CSR.scala 230:27]
  wire [62:0] mstatus_o_i = is_trap_begin ? _GEN_145 : _GEN_158; // @[CSR.scala 192:23]
  wire  _mSD_o_T_4 = mstatus_o_i[16:15] == 2'h3 | mstatus_o_i[14:13] == 2'h3; // @[CSR.scala 177:48]
  wire  _GEN_36 = _csr_data_o_T_5 & (mstatus_o_i[16:15] == 2'h3 | mstatus_o_i[14:13] == 2'h3); // @[CSR.scala 173:40 CSR.scala 177:13]
  wire  _GEN_49 = _csr_data_o_T_4 ? 1'h0 : _GEN_36; // @[CSR.scala 170:38]
  wire  _GEN_64 = _csr_data_o_T_3 ? 1'h0 : _GEN_49; // @[CSR.scala 167:39]
  wire  _GEN_81 = _csr_data_o_T_2 ? 1'h0 : _GEN_64; // @[CSR.scala 164:37]
  wire  _GEN_100 = _csr_data_o_T_1 ? 1'h0 : _GEN_81; // @[CSR.scala 161:33]
  wire  _GEN_122 = is_csrop & _GEN_100; // @[CSR.scala 146:17]
  wire  _GEN_136 = _is_trap_begin_T ? _mSD_o_T_4 : _GEN_122; // @[CSR.scala 193:30 CSR.scala 201:13]
  wire  _GEN_146 = clk_int ? _mSD_o_T_4 : _GEN_136; // @[CSR.scala 207:18 CSR.scala 218:13]
  wire  _GEN_154 = is_trap_end ? _mSD_o_T_4 : _GEN_122; // @[CSR.scala 231:29 CSR.scala 235:13]
  wire  _GEN_159 = is_trap_end ? _GEN_154 : _GEN_122; // @[CSR.scala 230:27]
  wire  mSD_o = is_trap_begin ? _GEN_146 : _GEN_159; // @[CSR.scala 192:23]
  wire [63:0] _mstatus_o_T = {mSD_o,mstatus_o_i}; // @[Cat.scala 30:58]
  wire [63:0] _GEN_37 = _csr_data_o_T_5 ? _mstatus_o_T : 64'h0; // @[CSR.scala 173:40 CSR.scala 178:17]
  wire [63:0] _GEN_50 = _csr_data_o_T_4 ? 64'h0 : _GEN_37; // @[CSR.scala 170:38]
  wire [63:0] _GEN_65 = _csr_data_o_T_3 ? 64'h0 : _GEN_50; // @[CSR.scala 167:39]
  wire [63:0] _GEN_82 = _csr_data_o_T_2 ? 64'h0 : _GEN_65; // @[CSR.scala 164:37]
  wire [63:0] _GEN_101 = _csr_data_o_T_1 ? 64'h0 : _GEN_82; // @[CSR.scala 161:33]
  wire [63:0] _GEN_123 = is_csrop ? _GEN_101 : 64'h0; // @[CSR.scala 146:17]
  wire [63:0] _GEN_137 = _is_trap_begin_T ? _mstatus_o_T : _GEN_123; // @[CSR.scala 193:30 CSR.scala 202:17]
  wire [63:0] _GEN_147 = clk_int ? _mstatus_o_T : _GEN_137; // @[CSR.scala 207:18 CSR.scala 219:17]
  wire [63:0] _GEN_155 = is_trap_end ? _mstatus_o_T : _GEN_123; // @[CSR.scala 231:29 CSR.scala 236:17]
  wire [63:0] _GEN_160 = is_trap_end ? _GEN_155 : _GEN_123; // @[CSR.scala 230:27]
  wire [63:0] mstatus_o = is_trap_begin ? _GEN_147 : _GEN_160; // @[CSR.scala 192:23]
  wire [1:0] sstatus_o_hi_lo = mstatus_o[16:15]; // @[CSR.scala 179:49]
  wire [1:0] sstatus_o_lo_hi = mstatus_o[14:13]; // @[CSR.scala 179:66]
  wire [63:0] _sstatus_o_T = {mSD_o,46'h0,sstatus_o_hi_lo,sstatus_o_lo_hi,13'h0}; // @[Cat.scala 30:58]
  wire [63:0] _mip_T_1 = mip & _mcycle_T_2; // @[CSR.scala 181:19]
  wire [63:0] _mip_T_3 = _mip_T_1 | _mcycle_T_4; // @[CSR.scala 181:32]
  wire [63:0] _mie_T_1 = mie & _mcycle_T_2; // @[CSR.scala 184:19]
  wire [63:0] _mie_T_3 = _mie_T_1 | _mcycle_T_4; // @[CSR.scala 184:32]
  wire  _T_7 = io_wb_to_csr_csr_addr == 12'h340; // @[CSR.scala 186:25]
  wire [63:0] _mscratch_T_1 = mscratch & _mcycle_T_2; // @[CSR.scala 187:29]
  wire [63:0] _mscratch_T_3 = _mscratch_T_1 | _mcycle_T_4; // @[CSR.scala 187:42]
  wire [63:0] _GEN_22 = io_wb_to_csr_csr_addr == 12'h340 ? _mscratch_T_3 : mscratch; // @[CSR.scala 186:40 CSR.scala 187:16 CSR.scala 50:25]
  wire [63:0] _GEN_23 = io_wb_to_csr_csr_addr == 12'h340 ? _mscratch_T_3 : 64'h0; // @[CSR.scala 186:40 CSR.scala 188:18]
  wire [63:0] _GEN_24 = _csr_data_o_T_7 ? _mie_T_3 : mie; // @[CSR.scala 183:36 CSR.scala 184:11 CSR.scala 52:20]
  wire [63:0] _GEN_25 = _csr_data_o_T_7 ? _mie_T_3 : 64'h0; // @[CSR.scala 183:36 CSR.scala 185:13]
  wire [63:0] _GEN_26 = _csr_data_o_T_7 ? mscratch : _GEN_22; // @[CSR.scala 183:36 CSR.scala 50:25]
  wire [63:0] _GEN_27 = _csr_data_o_T_7 ? 64'h0 : _GEN_23; // @[CSR.scala 183:36]
  wire [63:0] _GEN_28 = _csr_data_o_T_6 ? _mip_T_3 : mip; // @[CSR.scala 180:36 CSR.scala 181:11 CSR.scala 53:20]
  wire [63:0] _GEN_30 = _csr_data_o_T_6 ? mie : _GEN_24; // @[CSR.scala 180:36 CSR.scala 52:20]
  wire [63:0] _GEN_31 = _csr_data_o_T_6 ? 64'h0 : _GEN_25; // @[CSR.scala 180:36]
  wire [63:0] _GEN_32 = _csr_data_o_T_6 ? mscratch : _GEN_26; // @[CSR.scala 180:36 CSR.scala 50:25]
  wire [63:0] _GEN_33 = _csr_data_o_T_6 ? 64'h0 : _GEN_27; // @[CSR.scala 180:36]
  wire [62:0] _GEN_34 = _csr_data_o_T_5 ? _lo_T_7 : mstatus_i; // @[CSR.scala 173:40 CSR.scala 174:17 CSR.scala 45:26]
  wire [63:0] _GEN_38 = _csr_data_o_T_5 ? _sstatus_o_T : 64'h0; // @[CSR.scala 173:40 CSR.scala 179:17]
  wire [63:0] _GEN_39 = _csr_data_o_T_5 ? mip : _GEN_28; // @[CSR.scala 173:40 CSR.scala 53:20]
  wire [63:0] _GEN_41 = _csr_data_o_T_5 ? mie : _GEN_30; // @[CSR.scala 173:40 CSR.scala 52:20]
  wire [63:0] _GEN_42 = _csr_data_o_T_5 ? 64'h0 : _GEN_31; // @[CSR.scala 173:40]
  wire [63:0] _GEN_43 = _csr_data_o_T_5 ? mscratch : _GEN_32; // @[CSR.scala 173:40 CSR.scala 50:25]
  wire [63:0] _GEN_44 = _csr_data_o_T_5 ? 64'h0 : _GEN_33; // @[CSR.scala 173:40]
  wire [63:0] _GEN_45 = _csr_data_o_T_4 ? _mtvec_T_3 : mtvec; // @[CSR.scala 170:38 CSR.scala 171:13 CSR.scala 44:22]
  wire [63:0] _GEN_46 = _csr_data_o_T_4 ? _mtvec_T_3 : 64'h0; // @[CSR.scala 170:38 CSR.scala 172:15]
  wire [62:0] _GEN_47 = _csr_data_o_T_4 ? mstatus_i : _GEN_34; // @[CSR.scala 170:38 CSR.scala 45:26]
  wire [63:0] _GEN_51 = _csr_data_o_T_4 ? 64'h0 : _GEN_38; // @[CSR.scala 170:38]
  wire [63:0] _GEN_52 = _csr_data_o_T_4 ? mip : _GEN_39; // @[CSR.scala 170:38 CSR.scala 53:20]
  wire [63:0] _GEN_54 = _csr_data_o_T_4 ? mie : _GEN_41; // @[CSR.scala 170:38 CSR.scala 52:20]
  wire [63:0] _GEN_55 = _csr_data_o_T_4 ? 64'h0 : _GEN_42; // @[CSR.scala 170:38]
  wire [63:0] _GEN_56 = _csr_data_o_T_4 ? mscratch : _GEN_43; // @[CSR.scala 170:38 CSR.scala 50:25]
  wire [63:0] _GEN_57 = _csr_data_o_T_4 ? 64'h0 : _GEN_44; // @[CSR.scala 170:38]
  wire [63:0] _GEN_58 = _csr_data_o_T_3 ? _mcause_T_3 : mcause; // @[CSR.scala 167:39 CSR.scala 168:14 CSR.scala 43:23]
  wire [63:0] _GEN_59 = _csr_data_o_T_3 ? _mcause_T_3 : 64'h0; // @[CSR.scala 167:39 CSR.scala 169:16]
  wire [63:0] _GEN_60 = _csr_data_o_T_3 ? mtvec : _GEN_45; // @[CSR.scala 167:39 CSR.scala 44:22]
  wire [63:0] _GEN_61 = _csr_data_o_T_3 ? 64'h0 : _GEN_46; // @[CSR.scala 167:39]
  wire [62:0] _GEN_62 = _csr_data_o_T_3 ? mstatus_i : _GEN_47; // @[CSR.scala 167:39 CSR.scala 45:26]
  wire [63:0] _GEN_66 = _csr_data_o_T_3 ? 64'h0 : _GEN_51; // @[CSR.scala 167:39]
  wire [63:0] _GEN_67 = _csr_data_o_T_3 ? mip : _GEN_52; // @[CSR.scala 167:39 CSR.scala 53:20]
  wire [63:0] _GEN_69 = _csr_data_o_T_3 ? mie : _GEN_54; // @[CSR.scala 167:39 CSR.scala 52:20]
  wire [63:0] _GEN_70 = _csr_data_o_T_3 ? 64'h0 : _GEN_55; // @[CSR.scala 167:39]
  wire [63:0] _GEN_71 = _csr_data_o_T_3 ? mscratch : _GEN_56; // @[CSR.scala 167:39 CSR.scala 50:25]
  wire [63:0] _GEN_72 = _csr_data_o_T_3 ? 64'h0 : _GEN_57; // @[CSR.scala 167:39]
  wire [63:0] _GEN_73 = _csr_data_o_T_2 ? _mepc_T_3 : mepc; // @[CSR.scala 164:37 CSR.scala 165:12 CSR.scala 42:17]
  wire [63:0] _GEN_74 = _csr_data_o_T_2 ? _mepc_T_3 : 64'h0; // @[CSR.scala 164:37 CSR.scala 166:14]
  wire [63:0] _GEN_75 = _csr_data_o_T_2 ? mcause : _GEN_58; // @[CSR.scala 164:37 CSR.scala 43:23]
  wire [63:0] _GEN_76 = _csr_data_o_T_2 ? 64'h0 : _GEN_59; // @[CSR.scala 164:37]
  wire [63:0] _GEN_78 = _csr_data_o_T_2 ? 64'h0 : _GEN_61; // @[CSR.scala 164:37]
  wire [62:0] _GEN_79 = _csr_data_o_T_2 ? mstatus_i : _GEN_62; // @[CSR.scala 164:37 CSR.scala 45:26]
  wire [63:0] _GEN_83 = _csr_data_o_T_2 ? 64'h0 : _GEN_66; // @[CSR.scala 164:37]
  wire [63:0] _GEN_84 = _csr_data_o_T_2 ? mip : _GEN_67; // @[CSR.scala 164:37 CSR.scala 53:20]
  wire [63:0] _GEN_87 = _csr_data_o_T_2 ? 64'h0 : _GEN_70; // @[CSR.scala 164:37]
  wire [63:0] _GEN_89 = _csr_data_o_T_2 ? 64'h0 : _GEN_72; // @[CSR.scala 164:37]
  wire [63:0] _GEN_92 = _csr_data_o_T_1 ? mepc : _GEN_73; // @[CSR.scala 161:33 CSR.scala 42:17]
  wire [63:0] _GEN_93 = _csr_data_o_T_1 ? 64'h0 : _GEN_74; // @[CSR.scala 161:33]
  wire [63:0] _GEN_94 = _csr_data_o_T_1 ? mcause : _GEN_75; // @[CSR.scala 161:33 CSR.scala 43:23]
  wire [63:0] _GEN_95 = _csr_data_o_T_1 ? 64'h0 : _GEN_76; // @[CSR.scala 161:33]
  wire [63:0] _GEN_97 = _csr_data_o_T_1 ? 64'h0 : _GEN_78; // @[CSR.scala 161:33]
  wire [62:0] _GEN_98 = _csr_data_o_T_1 ? mstatus_i : _GEN_79; // @[CSR.scala 161:33 CSR.scala 45:26]
  wire [63:0] _GEN_102 = _csr_data_o_T_1 ? 64'h0 : _GEN_83; // @[CSR.scala 161:33]
  wire [63:0] _GEN_103 = _csr_data_o_T_1 ? mip : _GEN_84; // @[CSR.scala 161:33 CSR.scala 53:20]
  wire [63:0] _GEN_106 = _csr_data_o_T_1 ? 64'h0 : _GEN_87; // @[CSR.scala 161:33]
  wire [63:0] _GEN_108 = _csr_data_o_T_1 ? 64'h0 : _GEN_89; // @[CSR.scala 161:33]
  wire [63:0] _GEN_114 = is_csrop ? _GEN_92 : mepc; // @[CSR.scala 146:17 CSR.scala 42:17]
  wire [63:0] _GEN_115 = is_csrop ? _GEN_93 : 64'h0; // @[CSR.scala 146:17]
  wire [63:0] _GEN_116 = is_csrop ? _GEN_94 : mcause; // @[CSR.scala 146:17 CSR.scala 43:23]
  wire [63:0] _GEN_117 = is_csrop ? _GEN_95 : 64'h0; // @[CSR.scala 146:17]
  wire [63:0] mtvec_o = is_csrop ? _GEN_97 : 64'h0; // @[CSR.scala 146:17]
  wire [62:0] _GEN_120 = is_csrop ? _GEN_98 : mstatus_i; // @[CSR.scala 146:17 CSR.scala 45:26]
  wire [63:0] _GEN_124 = is_csrop ? _GEN_102 : 64'h0; // @[CSR.scala 146:17]
  wire [63:0] _GEN_125 = is_csrop ? _GEN_103 : mip; // @[CSR.scala 146:17 CSR.scala 53:20]
  wire [63:0] mie_o = is_csrop ? _GEN_106 : 64'h0; // @[CSR.scala 146:17]
  wire [63:0] mscratch_o = is_csrop ? _GEN_108 : 64'h0; // @[CSR.scala 146:17]
  wire [63:0] _GEN_134 = _is_trap_begin_T ? 64'hb : _GEN_117; // @[CSR.scala 193:30 CSR.scala 198:16]
  wire [63:0] _GEN_138 = _is_trap_begin_T ? _sstatus_o_T : _GEN_124; // @[CSR.scala 193:30 CSR.scala 203:17]
  wire [63:0] _GEN_139 = _is_trap_begin_T ? io_wb_to_csr_pc : _GEN_115; // @[CSR.scala 193:30 CSR.scala 205:14]
  wire [63:0] _GEN_144 = clk_int ? 64'h8000000000000007 : _GEN_134; // @[CSR.scala 207:18 CSR.scala 215:16]
  wire [63:0] _GEN_148 = clk_int ? _sstatus_o_T : _GEN_138; // @[CSR.scala 207:18 CSR.scala 220:17]
  wire [63:0] _GEN_149 = clk_int ? io_wb_to_csr_pc : _GEN_139; // @[CSR.scala 207:18 CSR.scala 222:14]
  wire [61:0] csr_target_hi = mtvec[63:2]; // @[CSR.scala 227:31]
  wire [63:0] _csr_target_T = {csr_target_hi,2'h0}; // @[Cat.scala 30:58]
  wire [62:0] csr_target_lo = mcause[62:0]; // @[CSR.scala 227:67]
  wire [63:0] _csr_target_T_1 = {1'h0,csr_target_lo}; // @[Cat.scala 30:58]
  wire [63:0] _csr_target_T_3 = _csr_target_T + _csr_target_T_1; // @[CSR.scala 227:50]
  wire [65:0] _csr_target_T_4 = {_csr_target_T_3, 2'h0}; // @[CSR.scala 227:76]
  wire [65:0] _GEN_150 = mtvec[1:0] == 2'h1 ? _csr_target_T_4 : 66'h0; // @[CSR.scala 226:37 CSR.scala 227:18]
  wire [65:0] _GEN_151 = mtvec[1:0] == 2'h0 ? {{2'd0}, mtvec} : _GEN_150; // @[CSR.scala 224:31 CSR.scala 225:18]
  wire [63:0] _GEN_156 = is_trap_end ? _sstatus_o_T : _GEN_124; // @[CSR.scala 231:29 CSR.scala 237:17]
  wire [63:0] _GEN_161 = is_trap_end ? _GEN_156 : _GEN_124; // @[CSR.scala 230:27]
  wire [63:0] _GEN_162 = is_trap_end ? mepc : 64'h0; // @[CSR.scala 230:27 CSR.scala 241:16]
  wire [63:0] mcause_o = is_trap_begin ? _GEN_144 : _GEN_117; // @[CSR.scala 192:23]
  wire [63:0] sstatus_o = is_trap_begin ? _GEN_148 : _GEN_161; // @[CSR.scala 192:23]
  wire [63:0] mepc_o = is_trap_begin ? _GEN_149 : _GEN_115; // @[CSR.scala 192:23]
  wire [65:0] _GEN_173 = is_trap_begin ? _GEN_151 : {{2'd0}, _GEN_162}; // @[CSR.scala 192:23]
  wire  _io_mstatus_T_3 = is_csrop & _csr_data_o_T_5 | is_trap_begin | is_trap_end; // @[CSR.scala 252:75]
  wire [1:0] sstatus_hi_lo = mstatus[16:15]; // @[CSR.scala 256:42]
  wire [1:0] sstatus_lo_hi = mstatus[14:13]; // @[CSR.scala 256:57]
  wire [63:0] sstatus = {mSD,46'h0,sstatus_hi_lo,sstatus_lo_hi,13'h0}; // @[Cat.scala 30:58]
  assign io_wb_to_csr_csr_res = is_csrop ? _GEN_19 : 64'h0; // @[CSR.scala 146:17]
  assign io_csr_to_id_csr_jump = is_trap_begin | is_trap_end; // @[CSR.scala 127:42]
  assign io_csr_to_id_csr_target = _GEN_173[63:0]; // @[CSR.scala 245:27]
  assign io_csr_to_lsu_rdata = io_csr_to_lsu_is_clint ? _GEN_7 : 64'h0; // @[CSR.scala 90:17]
  assign io_mepc = is_csrop & _csr_data_o_T_2 | is_trap_begin ? mepc_o : mepc; // @[CSR.scala 248:17]
  assign io_mcause = is_csrop & _csr_data_o_T_3 | is_trap_begin ? mcause_o : mcause; // @[CSR.scala 249:19]
  assign io_mtvec = is_csrop & _csr_data_o_T_4 ? mtvec_o : mtvec; // @[CSR.scala 250:18]
  assign io_mstatus = is_csrop & _csr_data_o_T_5 | is_trap_begin | is_trap_end ? mstatus_o : mstatus; // @[CSR.scala 252:20]
  assign io_mie = is_csrop & _csr_data_o_T_7 ? mie_o : mie; // @[CSR.scala 254:16]
  assign io_mscratch = is_csrop & _T_7 ? mscratch_o : mscratch; // @[CSR.scala 255:21]
  assign io_sstatus = _io_mstatus_T_3 ? sstatus_o : sstatus; // @[CSR.scala 257:20]
  assign io_intrNO = clk_int ? 32'h7 : 32'h0; // @[Mux.scala 27:72]
  assign io_cause = _is_trap_begin_T ? 32'hb : 32'h0; // @[Mux.scala 27:72]
  assign io_clkintr_flush = io_wb_to_csr_is_nop ? 1'h0 : mip[7]; // @[CSR.scala 102:20]
  always @(posedge clock) begin
    if (reset) begin // @[CSR.scala 38:23]
      mcycle <= 64'h0; // @[CSR.scala 38:23]
    end else if (is_csrop) begin // @[CSR.scala 146:17]
      if (_csr_data_o_T_1) begin // @[CSR.scala 161:33]
        mcycle <= _mcycle_T_5; // @[CSR.scala 162:14]
      end else begin
        mcycle <= _mcycle_T_1;
      end
    end else begin
      mcycle <= _mcycle_T_1;
    end
    if (is_trap_begin) begin // @[CSR.scala 192:23]
      if (clk_int) begin // @[CSR.scala 207:18]
        mepc <= io_wb_to_csr_pc; // @[CSR.scala 213:12]
      end else if (_is_trap_begin_T) begin // @[CSR.scala 193:30]
        mepc <= io_wb_to_csr_pc; // @[CSR.scala 196:12]
      end else begin
        mepc <= _GEN_114;
      end
    end else begin
      mepc <= _GEN_114;
    end
    if (reset) begin // @[CSR.scala 43:23]
      mcause <= 64'h0; // @[CSR.scala 43:23]
    end else if (is_trap_begin) begin // @[CSR.scala 192:23]
      if (clk_int) begin // @[CSR.scala 207:18]
        mcause <= 64'h8000000000000007; // @[CSR.scala 208:14]
      end else if (_is_trap_begin_T) begin // @[CSR.scala 193:30]
        mcause <= 64'hb; // @[CSR.scala 194:14]
      end else begin
        mcause <= _GEN_116;
      end
    end else begin
      mcause <= _GEN_116;
    end
    if (reset) begin // @[CSR.scala 44:22]
      mtvec <= 64'h0; // @[CSR.scala 44:22]
    end else if (is_csrop) begin // @[CSR.scala 146:17]
      if (!(_csr_data_o_T_1)) begin // @[CSR.scala 161:33]
        if (!(_csr_data_o_T_2)) begin // @[CSR.scala 164:37]
          mtvec <= _GEN_60;
        end
      end
    end
    if (reset) begin // @[CSR.scala 45:26]
      mstatus_i <= 63'h1800; // @[CSR.scala 45:26]
    end else if (is_trap_begin) begin // @[CSR.scala 192:23]
      if (clk_int) begin // @[CSR.scala 207:18]
        mstatus_i <= _lo_T_11; // @[CSR.scala 209:17]
      end else if (_is_trap_begin_T) begin // @[CSR.scala 193:30]
        mstatus_i <= _lo_T_11; // @[CSR.scala 195:17]
      end else begin
        mstatus_i <= _GEN_120;
      end
    end else if (is_trap_end) begin // @[CSR.scala 230:27]
      if (is_trap_end) begin // @[CSR.scala 231:29]
        mstatus_i <= _lo_T_13; // @[CSR.scala 232:17]
      end else begin
        mstatus_i <= _GEN_120;
      end
    end else begin
      mstatus_i <= _GEN_120;
    end
    if (reset) begin // @[CSR.scala 50:25]
      mscratch <= 64'h0; // @[CSR.scala 50:25]
    end else if (is_csrop) begin // @[CSR.scala 146:17]
      if (!(_csr_data_o_T_1)) begin // @[CSR.scala 161:33]
        if (!(_csr_data_o_T_2)) begin // @[CSR.scala 164:37]
          mscratch <= _GEN_71;
        end
      end
    end
    if (reset) begin // @[CSR.scala 52:20]
      mie <= 64'h0; // @[CSR.scala 52:20]
    end else if (is_csrop) begin // @[CSR.scala 146:17]
      if (!(_csr_data_o_T_1)) begin // @[CSR.scala 161:33]
        if (!(_csr_data_o_T_2)) begin // @[CSR.scala 164:37]
          mie <= _GEN_69;
        end
      end
    end
    if (reset) begin // @[CSR.scala 53:20]
      mip <= 64'h0; // @[CSR.scala 53:20]
    end else if (is_trap_begin) begin // @[CSR.scala 192:23]
      if (clk_int) begin // @[CSR.scala 207:18]
        mip <= 64'h0; // @[CSR.scala 211:11]
      end else begin
        mip <= _GEN_125;
      end
    end else begin
      mip <= _GEN_125;
    end
    if (reset) begin // @[CSR.scala 78:22]
      mtime <= 64'h0; // @[CSR.scala 78:22]
    end else if (io_csr_to_lsu_is_clint) begin // @[CSR.scala 90:17]
      if (io_csr_to_lsu_load) begin // @[CSR.scala 91:15]
        mtime <= _mtime_T_1;
      end else if (io_csr_to_lsu_save) begin // @[CSR.scala 93:21]
        mtime <= _GEN_3;
      end else begin
        mtime <= _mtime_T_1;
      end
    end else begin
      mtime <= _mtime_T_1;
    end
    if (reset) begin // @[CSR.scala 82:25]
      mtimecmp <= 64'hf8ff; // @[CSR.scala 82:25]
    end else if (io_csr_to_lsu_is_clint) begin // @[CSR.scala 90:17]
      if (!(io_csr_to_lsu_load)) begin // @[CSR.scala 91:15]
        if (io_csr_to_lsu_save) begin // @[CSR.scala 93:21]
          mtimecmp <= _GEN_4;
        end
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {2{`RANDOM}};
  mcycle = _RAND_0[63:0];
  _RAND_1 = {2{`RANDOM}};
  mepc = _RAND_1[63:0];
  _RAND_2 = {2{`RANDOM}};
  mcause = _RAND_2[63:0];
  _RAND_3 = {2{`RANDOM}};
  mtvec = _RAND_3[63:0];
  _RAND_4 = {2{`RANDOM}};
  mstatus_i = _RAND_4[62:0];
  _RAND_5 = {2{`RANDOM}};
  mscratch = _RAND_5[63:0];
  _RAND_6 = {2{`RANDOM}};
  mie = _RAND_6[63:0];
  _RAND_7 = {2{`RANDOM}};
  mip = _RAND_7[63:0];
  _RAND_8 = {2{`RANDOM}};
  mtime = _RAND_8[63:0];
  _RAND_9 = {2{`RANDOM}};
  mtimecmp = _RAND_9[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Core(
  input         clock,
  input         reset,
  output [63:0] io_isram_addr,
  output        io_isram_addr_valid,
  output        io_isram_addr_can_send,
  input         io_isram_addr_ok,
  input         io_isram_data_ok,
  output        io_isram_using,
  input  [63:0] io_isram_rdata,
  output        io_dsram_wr,
  output [1:0]  io_dsram_size,
  output [63:0] io_dsram_addr,
  output [7:0]  io_dsram_wstrb,
  output [63:0] io_dsram_wdata,
  output        io_dsram_addr_valid,
  input         io_dsram_data_ok,
  output        io_dsram_using,
  input  [63:0] io_dsram_rdata
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [63:0] _RAND_10;
  reg [63:0] _RAND_11;
  reg [63:0] _RAND_12;
  reg [63:0] _RAND_13;
  reg [63:0] _RAND_14;
  reg [63:0] _RAND_15;
  reg [63:0] _RAND_16;
  reg [63:0] _RAND_17;
  reg [63:0] _RAND_18;
  reg [63:0] _RAND_19;
`endif // RANDOMIZE_REG_INIT
  wire  fetch_clock; // @[Core.scala 13:21]
  wire  fetch_reset; // @[Core.scala 13:21]
  wire  fetch_io_ds_allowin; // @[Core.scala 13:21]
  wire  fetch_io_fs_to_ds_valid; // @[Core.scala 13:21]
  wire [63:0] fetch_io_isram_addr; // @[Core.scala 13:21]
  wire  fetch_io_isram_addr_valid; // @[Core.scala 13:21]
  wire  fetch_io_isram_addr_can_send; // @[Core.scala 13:21]
  wire  fetch_io_isram_addr_ok; // @[Core.scala 13:21]
  wire  fetch_io_isram_data_ok; // @[Core.scala 13:21]
  wire  fetch_io_isram_using; // @[Core.scala 13:21]
  wire [63:0] fetch_io_isram_rdata; // @[Core.scala 13:21]
  wire  fetch_io_if_to_id_is_nop; // @[Core.scala 13:21]
  wire [63:0] fetch_io_if_to_id_pc; // @[Core.scala 13:21]
  wire [31:0] fetch_io_if_to_id_inst; // @[Core.scala 13:21]
  wire [63:0] fetch_io_id_to_if_pc_target; // @[Core.scala 13:21]
  wire  fetch_io_id_to_if_jump; // @[Core.scala 13:21]
  wire  fetch_io_br_stall; // @[Core.scala 13:21]
  wire  dr_clock; // @[Core.scala 16:18]
  wire  dr_reset; // @[Core.scala 16:18]
  wire  dr_io_fs_to_ds_valid; // @[Core.scala 16:18]
  wire  dr_io_ds_valid; // @[Core.scala 16:18]
  wire  dr_io_ds_allowin; // @[Core.scala 16:18]
  wire  dr_io_if_to_dr_is_nop; // @[Core.scala 16:18]
  wire [63:0] dr_io_if_to_dr_pc; // @[Core.scala 16:18]
  wire [31:0] dr_io_if_to_dr_inst; // @[Core.scala 16:18]
  wire  dr_io_dr_to_id_is_nop; // @[Core.scala 16:18]
  wire [63:0] dr_io_dr_to_id_pc; // @[Core.scala 16:18]
  wire [31:0] dr_io_dr_to_id_inst; // @[Core.scala 16:18]
  wire  decode_clock; // @[Core.scala 17:22]
  wire  decode_reset; // @[Core.scala 17:22]
  wire  decode_io_es_allowin; // @[Core.scala 17:22]
  wire  decode_io_ds_valid; // @[Core.scala 17:22]
  wire  decode_io_ds_allowin; // @[Core.scala 17:22]
  wire  decode_io_ds_to_es_valid; // @[Core.scala 17:22]
  wire  decode_io_if_to_id_is_nop; // @[Core.scala 17:22]
  wire [63:0] decode_io_if_to_id_pc; // @[Core.scala 17:22]
  wire [31:0] decode_io_if_to_id_inst; // @[Core.scala 17:22]
  wire  decode_io_id_to_ex_is_nop; // @[Core.scala 17:22]
  wire [10:0] decode_io_id_to_ex_aluop; // @[Core.scala 17:22]
  wire [7:0] decode_io_id_to_ex_lsuop; // @[Core.scala 17:22]
  wire [11:0] decode_io_id_to_ex_rv64op; // @[Core.scala 17:22]
  wire [63:0] decode_io_id_to_ex_out1; // @[Core.scala 17:22]
  wire [63:0] decode_io_id_to_ex_out2; // @[Core.scala 17:22]
  wire [63:0] decode_io_id_to_ex_imm; // @[Core.scala 17:22]
  wire [4:0] decode_io_id_to_ex_dest; // @[Core.scala 17:22]
  wire  decode_io_id_to_ex_rf_w; // @[Core.scala 17:22]
  wire  decode_io_id_to_ex_load; // @[Core.scala 17:22]
  wire  decode_io_id_to_ex_save; // @[Core.scala 17:22]
  wire [63:0] decode_io_id_to_ex_pc; // @[Core.scala 17:22]
  wire [31:0] decode_io_id_to_ex_inst; // @[Core.scala 17:22]
  wire  decode_io_id_to_ex_is_csr; // @[Core.scala 17:22]
  wire [7:0] decode_io_id_to_ex_csrop; // @[Core.scala 17:22]
  wire [11:0] decode_io_id_to_ex_csr_addr; // @[Core.scala 17:22]
  wire [63:0] decode_io_id_to_ex_csr_src; // @[Core.scala 17:22]
  wire  decode_io_id_to_ex_is_zero; // @[Core.scala 17:22]
  wire [63:0] decode_io_id_to_if_pc_target; // @[Core.scala 17:22]
  wire  decode_io_id_to_if_jump; // @[Core.scala 17:22]
  wire  decode_io_csr_to_id_csr_jump; // @[Core.scala 17:22]
  wire [63:0] decode_io_csr_to_id_csr_target; // @[Core.scala 17:22]
  wire [4:0] decode_io_rs1_addr; // @[Core.scala 17:22]
  wire [63:0] decode_io_rs1_data; // @[Core.scala 17:22]
  wire [4:0] decode_io_rs2_addr; // @[Core.scala 17:22]
  wire [63:0] decode_io_rs2_data; // @[Core.scala 17:22]
  wire  decode_io_fwd_ex_rf_w; // @[Core.scala 17:22]
  wire [4:0] decode_io_fwd_ex_dst; // @[Core.scala 17:22]
  wire [63:0] decode_io_fwd_ex_alu_res; // @[Core.scala 17:22]
  wire  decode_io_fwd_ex_is_csr; // @[Core.scala 17:22]
  wire  decode_io_fwd_ex_load; // @[Core.scala 17:22]
  wire  decode_io_fwd_lsu_rf_w; // @[Core.scala 17:22]
  wire [4:0] decode_io_fwd_lsu_dst; // @[Core.scala 17:22]
  wire [63:0] decode_io_fwd_lsu_lsu_res; // @[Core.scala 17:22]
  wire  decode_io_fwd_lsu_is_csr; // @[Core.scala 17:22]
  wire  decode_io_fwd_lsu_br_stall; // @[Core.scala 17:22]
  wire  decode_io_fwd_wb_rf_w; // @[Core.scala 17:22]
  wire [4:0] decode_io_fwd_wb_dst; // @[Core.scala 17:22]
  wire [63:0] decode_io_fwd_wb_wb_res; // @[Core.scala 17:22]
  wire  decode_io_intr_flush; // @[Core.scala 17:22]
  wire  decode_io_br_stall; // @[Core.scala 17:22]
  wire  er_clock; // @[Core.scala 20:18]
  wire  er_reset; // @[Core.scala 20:18]
  wire  er_io_ds_to_es_valid; // @[Core.scala 20:18]
  wire  er_io_es_valid; // @[Core.scala 20:18]
  wire  er_io_es_allowin; // @[Core.scala 20:18]
  wire  er_io_id_to_er_is_nop; // @[Core.scala 20:18]
  wire [10:0] er_io_id_to_er_aluop; // @[Core.scala 20:18]
  wire [7:0] er_io_id_to_er_lsuop; // @[Core.scala 20:18]
  wire [11:0] er_io_id_to_er_rv64op; // @[Core.scala 20:18]
  wire [63:0] er_io_id_to_er_out1; // @[Core.scala 20:18]
  wire [63:0] er_io_id_to_er_out2; // @[Core.scala 20:18]
  wire [63:0] er_io_id_to_er_imm; // @[Core.scala 20:18]
  wire [4:0] er_io_id_to_er_dest; // @[Core.scala 20:18]
  wire  er_io_id_to_er_rf_w; // @[Core.scala 20:18]
  wire  er_io_id_to_er_load; // @[Core.scala 20:18]
  wire  er_io_id_to_er_save; // @[Core.scala 20:18]
  wire [63:0] er_io_id_to_er_pc; // @[Core.scala 20:18]
  wire [31:0] er_io_id_to_er_inst; // @[Core.scala 20:18]
  wire  er_io_id_to_er_is_csr; // @[Core.scala 20:18]
  wire [7:0] er_io_id_to_er_csrop; // @[Core.scala 20:18]
  wire [11:0] er_io_id_to_er_csr_addr; // @[Core.scala 20:18]
  wire [63:0] er_io_id_to_er_csr_src; // @[Core.scala 20:18]
  wire  er_io_id_to_er_is_zero; // @[Core.scala 20:18]
  wire  er_io_er_to_ex_is_nop; // @[Core.scala 20:18]
  wire [10:0] er_io_er_to_ex_aluop; // @[Core.scala 20:18]
  wire [7:0] er_io_er_to_ex_lsuop; // @[Core.scala 20:18]
  wire [11:0] er_io_er_to_ex_rv64op; // @[Core.scala 20:18]
  wire [63:0] er_io_er_to_ex_out1; // @[Core.scala 20:18]
  wire [63:0] er_io_er_to_ex_out2; // @[Core.scala 20:18]
  wire [63:0] er_io_er_to_ex_imm; // @[Core.scala 20:18]
  wire [4:0] er_io_er_to_ex_dest; // @[Core.scala 20:18]
  wire  er_io_er_to_ex_rf_w; // @[Core.scala 20:18]
  wire  er_io_er_to_ex_load; // @[Core.scala 20:18]
  wire  er_io_er_to_ex_save; // @[Core.scala 20:18]
  wire [63:0] er_io_er_to_ex_pc; // @[Core.scala 20:18]
  wire [31:0] er_io_er_to_ex_inst; // @[Core.scala 20:18]
  wire  er_io_er_to_ex_is_csr; // @[Core.scala 20:18]
  wire [7:0] er_io_er_to_ex_csrop; // @[Core.scala 20:18]
  wire [11:0] er_io_er_to_ex_csr_addr; // @[Core.scala 20:18]
  wire [63:0] er_io_er_to_ex_csr_src; // @[Core.scala 20:18]
  wire  er_io_er_to_ex_is_zero; // @[Core.scala 20:18]
  wire  ex_io_ls_allowin; // @[Core.scala 21:18]
  wire  ex_io_es_valid; // @[Core.scala 21:18]
  wire  ex_io_es_allowin; // @[Core.scala 21:18]
  wire  ex_io_es_to_ls_valid; // @[Core.scala 21:18]
  wire  ex_io_id_to_ex_is_nop; // @[Core.scala 21:18]
  wire [10:0] ex_io_id_to_ex_aluop; // @[Core.scala 21:18]
  wire [7:0] ex_io_id_to_ex_lsuop; // @[Core.scala 21:18]
  wire [11:0] ex_io_id_to_ex_rv64op; // @[Core.scala 21:18]
  wire [63:0] ex_io_id_to_ex_out1; // @[Core.scala 21:18]
  wire [63:0] ex_io_id_to_ex_out2; // @[Core.scala 21:18]
  wire [63:0] ex_io_id_to_ex_imm; // @[Core.scala 21:18]
  wire [4:0] ex_io_id_to_ex_dest; // @[Core.scala 21:18]
  wire  ex_io_id_to_ex_rf_w; // @[Core.scala 21:18]
  wire  ex_io_id_to_ex_load; // @[Core.scala 21:18]
  wire  ex_io_id_to_ex_save; // @[Core.scala 21:18]
  wire [63:0] ex_io_id_to_ex_pc; // @[Core.scala 21:18]
  wire [31:0] ex_io_id_to_ex_inst; // @[Core.scala 21:18]
  wire  ex_io_id_to_ex_is_csr; // @[Core.scala 21:18]
  wire [7:0] ex_io_id_to_ex_csrop; // @[Core.scala 21:18]
  wire [11:0] ex_io_id_to_ex_csr_addr; // @[Core.scala 21:18]
  wire [63:0] ex_io_id_to_ex_csr_src; // @[Core.scala 21:18]
  wire  ex_io_id_to_ex_is_zero; // @[Core.scala 21:18]
  wire  ex_io_ex_to_lsu_is_nop; // @[Core.scala 21:18]
  wire [63:0] ex_io_ex_to_lsu_alu_res; // @[Core.scala 21:18]
  wire [63:0] ex_io_ex_to_lsu_src1; // @[Core.scala 21:18]
  wire [63:0] ex_io_ex_to_lsu_src2; // @[Core.scala 21:18]
  wire [63:0] ex_io_ex_to_lsu_imm; // @[Core.scala 21:18]
  wire [7:0] ex_io_ex_to_lsu_lsuop; // @[Core.scala 21:18]
  wire [11:0] ex_io_ex_to_lsu_rv64op; // @[Core.scala 21:18]
  wire [4:0] ex_io_ex_to_lsu_dest; // @[Core.scala 21:18]
  wire  ex_io_ex_to_lsu_rf_w; // @[Core.scala 21:18]
  wire  ex_io_ex_to_lsu_load; // @[Core.scala 21:18]
  wire  ex_io_ex_to_lsu_save; // @[Core.scala 21:18]
  wire [63:0] ex_io_ex_to_lsu_pc; // @[Core.scala 21:18]
  wire [31:0] ex_io_ex_to_lsu_inst; // @[Core.scala 21:18]
  wire  ex_io_ex_to_lsu_is_csr; // @[Core.scala 21:18]
  wire [7:0] ex_io_ex_to_lsu_csrop; // @[Core.scala 21:18]
  wire [11:0] ex_io_ex_to_lsu_csr_addr; // @[Core.scala 21:18]
  wire [63:0] ex_io_ex_to_lsu_csr_src; // @[Core.scala 21:18]
  wire  ex_io_ex_to_lsu_is_zero; // @[Core.scala 21:18]
  wire  ex_io_ex_fwd_rf_w; // @[Core.scala 21:18]
  wire [4:0] ex_io_ex_fwd_dst; // @[Core.scala 21:18]
  wire [63:0] ex_io_ex_fwd_alu_res; // @[Core.scala 21:18]
  wire  ex_io_ex_fwd_is_csr; // @[Core.scala 21:18]
  wire  ex_io_ex_fwd_load; // @[Core.scala 21:18]
  wire  ex_io_flush; // @[Core.scala 21:18]
  wire  lr_clock; // @[Core.scala 22:18]
  wire  lr_reset; // @[Core.scala 22:18]
  wire  lr_io_es_to_ls_valid; // @[Core.scala 22:18]
  wire  lr_io_ls_valid; // @[Core.scala 22:18]
  wire  lr_io_ls_allowin; // @[Core.scala 22:18]
  wire  lr_io_ex_to_lr_is_nop; // @[Core.scala 22:18]
  wire [63:0] lr_io_ex_to_lr_alu_res; // @[Core.scala 22:18]
  wire [63:0] lr_io_ex_to_lr_src1; // @[Core.scala 22:18]
  wire [63:0] lr_io_ex_to_lr_src2; // @[Core.scala 22:18]
  wire [63:0] lr_io_ex_to_lr_imm; // @[Core.scala 22:18]
  wire [7:0] lr_io_ex_to_lr_lsuop; // @[Core.scala 22:18]
  wire [11:0] lr_io_ex_to_lr_rv64op; // @[Core.scala 22:18]
  wire [4:0] lr_io_ex_to_lr_dest; // @[Core.scala 22:18]
  wire  lr_io_ex_to_lr_rf_w; // @[Core.scala 22:18]
  wire  lr_io_ex_to_lr_load; // @[Core.scala 22:18]
  wire  lr_io_ex_to_lr_save; // @[Core.scala 22:18]
  wire [63:0] lr_io_ex_to_lr_pc; // @[Core.scala 22:18]
  wire [31:0] lr_io_ex_to_lr_inst; // @[Core.scala 22:18]
  wire  lr_io_ex_to_lr_is_csr; // @[Core.scala 22:18]
  wire [7:0] lr_io_ex_to_lr_csrop; // @[Core.scala 22:18]
  wire [11:0] lr_io_ex_to_lr_csr_addr; // @[Core.scala 22:18]
  wire [63:0] lr_io_ex_to_lr_csr_src; // @[Core.scala 22:18]
  wire  lr_io_ex_to_lr_is_zero; // @[Core.scala 22:18]
  wire  lr_io_lr_to_lsu_is_nop; // @[Core.scala 22:18]
  wire [63:0] lr_io_lr_to_lsu_alu_res; // @[Core.scala 22:18]
  wire [63:0] lr_io_lr_to_lsu_src1; // @[Core.scala 22:18]
  wire [63:0] lr_io_lr_to_lsu_src2; // @[Core.scala 22:18]
  wire [63:0] lr_io_lr_to_lsu_imm; // @[Core.scala 22:18]
  wire [7:0] lr_io_lr_to_lsu_lsuop; // @[Core.scala 22:18]
  wire [11:0] lr_io_lr_to_lsu_rv64op; // @[Core.scala 22:18]
  wire [4:0] lr_io_lr_to_lsu_dest; // @[Core.scala 22:18]
  wire  lr_io_lr_to_lsu_rf_w; // @[Core.scala 22:18]
  wire  lr_io_lr_to_lsu_load; // @[Core.scala 22:18]
  wire  lr_io_lr_to_lsu_save; // @[Core.scala 22:18]
  wire [63:0] lr_io_lr_to_lsu_pc; // @[Core.scala 22:18]
  wire [31:0] lr_io_lr_to_lsu_inst; // @[Core.scala 22:18]
  wire  lr_io_lr_to_lsu_is_csr; // @[Core.scala 22:18]
  wire [7:0] lr_io_lr_to_lsu_csrop; // @[Core.scala 22:18]
  wire [11:0] lr_io_lr_to_lsu_csr_addr; // @[Core.scala 22:18]
  wire [63:0] lr_io_lr_to_lsu_csr_src; // @[Core.scala 22:18]
  wire  lr_io_lr_to_lsu_is_zero; // @[Core.scala 22:18]
  wire  lsu_clock; // @[Core.scala 23:19]
  wire  lsu_reset; // @[Core.scala 23:19]
  wire  lsu_io_ls_valid; // @[Core.scala 23:19]
  wire  lsu_io_ls_allowin; // @[Core.scala 23:19]
  wire  lsu_io_ls_to_ws_valid; // @[Core.scala 23:19]
  wire  lsu_io_ex_to_lsu_is_nop; // @[Core.scala 23:19]
  wire [63:0] lsu_io_ex_to_lsu_alu_res; // @[Core.scala 23:19]
  wire [63:0] lsu_io_ex_to_lsu_src1; // @[Core.scala 23:19]
  wire [63:0] lsu_io_ex_to_lsu_src2; // @[Core.scala 23:19]
  wire [63:0] lsu_io_ex_to_lsu_imm; // @[Core.scala 23:19]
  wire [7:0] lsu_io_ex_to_lsu_lsuop; // @[Core.scala 23:19]
  wire [11:0] lsu_io_ex_to_lsu_rv64op; // @[Core.scala 23:19]
  wire [4:0] lsu_io_ex_to_lsu_dest; // @[Core.scala 23:19]
  wire  lsu_io_ex_to_lsu_rf_w; // @[Core.scala 23:19]
  wire  lsu_io_ex_to_lsu_load; // @[Core.scala 23:19]
  wire  lsu_io_ex_to_lsu_save; // @[Core.scala 23:19]
  wire [63:0] lsu_io_ex_to_lsu_pc; // @[Core.scala 23:19]
  wire [31:0] lsu_io_ex_to_lsu_inst; // @[Core.scala 23:19]
  wire  lsu_io_ex_to_lsu_is_csr; // @[Core.scala 23:19]
  wire [7:0] lsu_io_ex_to_lsu_csrop; // @[Core.scala 23:19]
  wire [11:0] lsu_io_ex_to_lsu_csr_addr; // @[Core.scala 23:19]
  wire [63:0] lsu_io_ex_to_lsu_csr_src; // @[Core.scala 23:19]
  wire  lsu_io_ex_to_lsu_is_zero; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_wb_is_nop; // @[Core.scala 23:19]
  wire [63:0] lsu_io_lsu_to_wb_lsu_res; // @[Core.scala 23:19]
  wire [4:0] lsu_io_lsu_to_wb_dest; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_wb_rf_w; // @[Core.scala 23:19]
  wire [63:0] lsu_io_lsu_to_wb_pc; // @[Core.scala 23:19]
  wire [31:0] lsu_io_lsu_to_wb_inst; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_wb_is_csr; // @[Core.scala 23:19]
  wire [7:0] lsu_io_lsu_to_wb_csrop; // @[Core.scala 23:19]
  wire [11:0] lsu_io_lsu_to_wb_csr_addr; // @[Core.scala 23:19]
  wire [63:0] lsu_io_lsu_to_wb_csr_src; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_wb_is_zero; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_is_clint; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_is_mtime; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_is_mtimecmp; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_load; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_save; // @[Core.scala 23:19]
  wire [63:0] lsu_io_lsu_to_csr_wdata; // @[Core.scala 23:19]
  wire [63:0] lsu_io_lsu_to_csr_rdata; // @[Core.scala 23:19]
  wire  lsu_io_lsu_fwd_rf_w; // @[Core.scala 23:19]
  wire [4:0] lsu_io_lsu_fwd_dst; // @[Core.scala 23:19]
  wire [63:0] lsu_io_lsu_fwd_lsu_res; // @[Core.scala 23:19]
  wire  lsu_io_lsu_fwd_is_csr; // @[Core.scala 23:19]
  wire  lsu_io_lsu_fwd_br_stall; // @[Core.scala 23:19]
  wire  lsu_io_dsram_wr; // @[Core.scala 23:19]
  wire [1:0] lsu_io_dsram_size; // @[Core.scala 23:19]
  wire [63:0] lsu_io_dsram_addr; // @[Core.scala 23:19]
  wire [7:0] lsu_io_dsram_wstrb; // @[Core.scala 23:19]
  wire [63:0] lsu_io_dsram_wdata; // @[Core.scala 23:19]
  wire  lsu_io_dsram_addr_valid; // @[Core.scala 23:19]
  wire  lsu_io_dsram_data_ok; // @[Core.scala 23:19]
  wire  lsu_io_dsram_using; // @[Core.scala 23:19]
  wire [63:0] lsu_io_dsram_rdata; // @[Core.scala 23:19]
  wire  lsu_io_flush; // @[Core.scala 23:19]
  wire  wr_clock; // @[Core.scala 28:18]
  wire  wr_reset; // @[Core.scala 28:18]
  wire  wr_io_ls_to_ws_valid; // @[Core.scala 28:18]
  wire  wr_io_ws_valid; // @[Core.scala 28:18]
  wire  wr_io_lsu_to_wr_is_nop; // @[Core.scala 28:18]
  wire [63:0] wr_io_lsu_to_wr_lsu_res; // @[Core.scala 28:18]
  wire [4:0] wr_io_lsu_to_wr_dest; // @[Core.scala 28:18]
  wire  wr_io_lsu_to_wr_rf_w; // @[Core.scala 28:18]
  wire [63:0] wr_io_lsu_to_wr_pc; // @[Core.scala 28:18]
  wire [31:0] wr_io_lsu_to_wr_inst; // @[Core.scala 28:18]
  wire  wr_io_lsu_to_wr_is_csr; // @[Core.scala 28:18]
  wire [7:0] wr_io_lsu_to_wr_csrop; // @[Core.scala 28:18]
  wire [11:0] wr_io_lsu_to_wr_csr_addr; // @[Core.scala 28:18]
  wire [63:0] wr_io_lsu_to_wr_csr_src; // @[Core.scala 28:18]
  wire  wr_io_lsu_to_wr_is_zero; // @[Core.scala 28:18]
  wire  wr_io_wr_to_wb_is_nop; // @[Core.scala 28:18]
  wire [63:0] wr_io_wr_to_wb_lsu_res; // @[Core.scala 28:18]
  wire [4:0] wr_io_wr_to_wb_dest; // @[Core.scala 28:18]
  wire  wr_io_wr_to_wb_rf_w; // @[Core.scala 28:18]
  wire [63:0] wr_io_wr_to_wb_pc; // @[Core.scala 28:18]
  wire [31:0] wr_io_wr_to_wb_inst; // @[Core.scala 28:18]
  wire  wr_io_wr_to_wb_is_csr; // @[Core.scala 28:18]
  wire [7:0] wr_io_wr_to_wb_csrop; // @[Core.scala 28:18]
  wire [11:0] wr_io_wr_to_wb_csr_addr; // @[Core.scala 28:18]
  wire [63:0] wr_io_wr_to_wb_csr_src; // @[Core.scala 28:18]
  wire  wr_io_wr_to_wb_is_zero; // @[Core.scala 28:18]
  wire  wb_io_ws_valid; // @[Core.scala 29:18]
  wire  wb_io_lsu_to_wb_is_nop; // @[Core.scala 29:18]
  wire [63:0] wb_io_lsu_to_wb_lsu_res; // @[Core.scala 29:18]
  wire [4:0] wb_io_lsu_to_wb_dest; // @[Core.scala 29:18]
  wire  wb_io_lsu_to_wb_rf_w; // @[Core.scala 29:18]
  wire [63:0] wb_io_lsu_to_wb_pc; // @[Core.scala 29:18]
  wire [31:0] wb_io_lsu_to_wb_inst; // @[Core.scala 29:18]
  wire  wb_io_lsu_to_wb_is_csr; // @[Core.scala 29:18]
  wire [7:0] wb_io_lsu_to_wb_csrop; // @[Core.scala 29:18]
  wire [11:0] wb_io_lsu_to_wb_csr_addr; // @[Core.scala 29:18]
  wire [63:0] wb_io_lsu_to_wb_csr_src; // @[Core.scala 29:18]
  wire  wb_io_lsu_to_wb_is_zero; // @[Core.scala 29:18]
  wire  wb_io_wb_to_csr_is_nop; // @[Core.scala 29:18]
  wire [7:0] wb_io_wb_to_csr_csrop; // @[Core.scala 29:18]
  wire [11:0] wb_io_wb_to_csr_csr_addr; // @[Core.scala 29:18]
  wire [63:0] wb_io_wb_to_csr_csr_src; // @[Core.scala 29:18]
  wire  wb_io_wb_to_csr_is_zero; // @[Core.scala 29:18]
  wire [63:0] wb_io_wb_to_csr_pc; // @[Core.scala 29:18]
  wire [63:0] wb_io_wb_to_csr_csr_res; // @[Core.scala 29:18]
  wire  wb_io_wb_fwd_rf_w; // @[Core.scala 29:18]
  wire [4:0] wb_io_wb_fwd_dst; // @[Core.scala 29:18]
  wire [63:0] wb_io_wb_fwd_wb_res; // @[Core.scala 29:18]
  wire [4:0] wb_io_rd_addr; // @[Core.scala 29:18]
  wire [63:0] wb_io_rd_data; // @[Core.scala 29:18]
  wire  wb_io_rd_en; // @[Core.scala 29:18]
  wire [63:0] wb_io_pc; // @[Core.scala 29:18]
  wire [31:0] wb_io_inst; // @[Core.scala 29:18]
  wire  wb_io_is_nop; // @[Core.scala 29:18]
  wire  wb_io_flush; // @[Core.scala 29:18]
  wire  rf_clock; // @[Core.scala 31:18]
  wire  rf_reset; // @[Core.scala 31:18]
  wire [4:0] rf_io_rs1_addr; // @[Core.scala 31:18]
  wire [4:0] rf_io_rs2_addr; // @[Core.scala 31:18]
  wire [63:0] rf_io_rs1_data; // @[Core.scala 31:18]
  wire [63:0] rf_io_rs2_data; // @[Core.scala 31:18]
  wire [4:0] rf_io_rd_addr; // @[Core.scala 31:18]
  wire [63:0] rf_io_rd_data; // @[Core.scala 31:18]
  wire  rf_io_rd_en; // @[Core.scala 31:18]
  wire [63:0] rf_rf_10; // @[Core.scala 31:18]
  wire  csr_clock; // @[Core.scala 43:19]
  wire  csr_reset; // @[Core.scala 43:19]
  wire  csr_io_wb_to_csr_is_nop; // @[Core.scala 43:19]
  wire [7:0] csr_io_wb_to_csr_csrop; // @[Core.scala 43:19]
  wire [11:0] csr_io_wb_to_csr_csr_addr; // @[Core.scala 43:19]
  wire [63:0] csr_io_wb_to_csr_csr_src; // @[Core.scala 43:19]
  wire  csr_io_wb_to_csr_is_zero; // @[Core.scala 43:19]
  wire [63:0] csr_io_wb_to_csr_pc; // @[Core.scala 43:19]
  wire [63:0] csr_io_wb_to_csr_csr_res; // @[Core.scala 43:19]
  wire  csr_io_csr_to_id_csr_jump; // @[Core.scala 43:19]
  wire [63:0] csr_io_csr_to_id_csr_target; // @[Core.scala 43:19]
  wire  csr_io_csr_to_lsu_is_clint; // @[Core.scala 43:19]
  wire  csr_io_csr_to_lsu_is_mtime; // @[Core.scala 43:19]
  wire  csr_io_csr_to_lsu_is_mtimecmp; // @[Core.scala 43:19]
  wire  csr_io_csr_to_lsu_load; // @[Core.scala 43:19]
  wire  csr_io_csr_to_lsu_save; // @[Core.scala 43:19]
  wire [63:0] csr_io_csr_to_lsu_wdata; // @[Core.scala 43:19]
  wire [63:0] csr_io_csr_to_lsu_rdata; // @[Core.scala 43:19]
  wire [63:0] csr_io_mepc; // @[Core.scala 43:19]
  wire [63:0] csr_io_mcause; // @[Core.scala 43:19]
  wire [63:0] csr_io_mtvec; // @[Core.scala 43:19]
  wire [63:0] csr_io_mstatus; // @[Core.scala 43:19]
  wire [63:0] csr_io_mie; // @[Core.scala 43:19]
  wire [63:0] csr_io_mscratch; // @[Core.scala 43:19]
  wire [63:0] csr_io_sstatus; // @[Core.scala 43:19]
  wire [31:0] csr_io_intrNO; // @[Core.scala 43:19]
  wire [31:0] csr_io_cause; // @[Core.scala 43:19]
  wire  csr_io_clkintr_flush; // @[Core.scala 43:19]
  wire  dt_ic_clock; // @[Core.scala 92:21]
  wire [7:0] dt_ic_coreid; // @[Core.scala 92:21]
  wire [7:0] dt_ic_index; // @[Core.scala 92:21]
  wire  dt_ic_valid; // @[Core.scala 92:21]
  wire [63:0] dt_ic_pc; // @[Core.scala 92:21]
  wire [31:0] dt_ic_instr; // @[Core.scala 92:21]
  wire [7:0] dt_ic_special; // @[Core.scala 92:21]
  wire  dt_ic_skip; // @[Core.scala 92:21]
  wire  dt_ic_isRVC; // @[Core.scala 92:21]
  wire  dt_ic_scFailed; // @[Core.scala 92:21]
  wire  dt_ic_wen; // @[Core.scala 92:21]
  wire [63:0] dt_ic_wdata; // @[Core.scala 92:21]
  wire [7:0] dt_ic_wdest; // @[Core.scala 92:21]
  wire  dt_ae_clock; // @[Core.scala 108:21]
  wire [7:0] dt_ae_coreid; // @[Core.scala 108:21]
  wire [31:0] dt_ae_intrNO; // @[Core.scala 108:21]
  wire [31:0] dt_ae_cause; // @[Core.scala 108:21]
  wire [63:0] dt_ae_exceptionPC; // @[Core.scala 108:21]
  wire [31:0] dt_ae_exceptionInst; // @[Core.scala 108:21]
  wire  dt_te_clock; // @[Core.scala 124:21]
  wire [7:0] dt_te_coreid; // @[Core.scala 124:21]
  wire  dt_te_valid; // @[Core.scala 124:21]
  wire [2:0] dt_te_code; // @[Core.scala 124:21]
  wire [63:0] dt_te_pc; // @[Core.scala 124:21]
  wire [63:0] dt_te_cycleCnt; // @[Core.scala 124:21]
  wire [63:0] dt_te_instrCnt; // @[Core.scala 124:21]
  wire  dt_cs_clock; // @[Core.scala 133:21]
  wire [7:0] dt_cs_coreid; // @[Core.scala 133:21]
  wire [1:0] dt_cs_priviledgeMode; // @[Core.scala 133:21]
  wire [63:0] dt_cs_mstatus; // @[Core.scala 133:21]
  wire [63:0] dt_cs_sstatus; // @[Core.scala 133:21]
  wire [63:0] dt_cs_mepc; // @[Core.scala 133:21]
  wire [63:0] dt_cs_sepc; // @[Core.scala 133:21]
  wire [63:0] dt_cs_mtval; // @[Core.scala 133:21]
  wire [63:0] dt_cs_stval; // @[Core.scala 133:21]
  wire [63:0] dt_cs_mtvec; // @[Core.scala 133:21]
  wire [63:0] dt_cs_stvec; // @[Core.scala 133:21]
  wire [63:0] dt_cs_mcause; // @[Core.scala 133:21]
  wire [63:0] dt_cs_scause; // @[Core.scala 133:21]
  wire [63:0] dt_cs_satp; // @[Core.scala 133:21]
  wire [63:0] dt_cs_mip; // @[Core.scala 133:21]
  wire [63:0] dt_cs_mie; // @[Core.scala 133:21]
  wire [63:0] dt_cs_mscratch; // @[Core.scala 133:21]
  wire [63:0] dt_cs_sscratch; // @[Core.scala 133:21]
  wire [63:0] dt_cs_mideleg; // @[Core.scala 133:21]
  wire [63:0] dt_cs_medeleg; // @[Core.scala 133:21]
  wire [31:0] _dt_ic_io_valid_T = wb_io_inst; // @[Core.scala 96:57]
  reg  dt_ic_io_valid_REG; // @[Core.scala 96:29]
  reg [63:0] dt_ic_io_pc_REG; // @[Core.scala 97:25]
  reg [31:0] dt_ic_io_instr_REG; // @[Core.scala 98:28]
  reg  dt_ic_io_skip_REG; // @[Core.scala 99:67]
  wire  _dt_ic_io_skip_T_1 = wb_io_inst == 32'h7b | dt_ic_io_skip_REG; // @[Core.scala 99:57]
  reg  dt_ic_io_skip_REG_1; // @[Core.scala 99:27]
  reg  dt_ic_io_wen_REG; // @[Core.scala 104:26]
  reg [63:0] dt_ic_io_wdata_REG; // @[Core.scala 105:28]
  reg [4:0] dt_ic_io_wdest_REG; // @[Core.scala 106:28]
  reg [31:0] dt_ae_io_intrNO_REG; // @[Core.scala 111:29]
  reg [31:0] dt_ae_io_cause_REG; // @[Core.scala 112:28]
  reg [63:0] dt_ae_io_exceptionPC_REG; // @[Core.scala 113:34]
  reg [63:0] cycle_cnt; // @[Core.scala 115:26]
  reg [63:0] instr_cnt; // @[Core.scala 116:26]
  wire [63:0] _cycle_cnt_T_1 = cycle_cnt + 64'h1; // @[Core.scala 118:26]
  wire [63:0] _instr_cnt_T_1 = instr_cnt + 64'h1; // @[Core.scala 119:26]
  wire [63:0] rf_a0_0 = rf_rf_10;
  reg [63:0] dt_cs_io_mstatus_REG; // @[Core.scala 137:30]
  reg [63:0] dt_cs_io_sstatus_REG; // @[Core.scala 138:30]
  reg [63:0] dt_cs_io_mepc_REG; // @[Core.scala 139:27]
  reg [63:0] dt_cs_io_mtvec_REG; // @[Core.scala 143:28]
  reg [63:0] dt_cs_io_mcause_REG; // @[Core.scala 145:29]
  reg [63:0] dt_cs_io_mie_REG; // @[Core.scala 149:26]
  reg [63:0] dt_cs_io_mscratch_REG; // @[Core.scala 150:31]
  InstFetch fetch ( // @[Core.scala 13:21]
    .clock(fetch_clock),
    .reset(fetch_reset),
    .io_ds_allowin(fetch_io_ds_allowin),
    .io_fs_to_ds_valid(fetch_io_fs_to_ds_valid),
    .io_isram_addr(fetch_io_isram_addr),
    .io_isram_addr_valid(fetch_io_isram_addr_valid),
    .io_isram_addr_can_send(fetch_io_isram_addr_can_send),
    .io_isram_addr_ok(fetch_io_isram_addr_ok),
    .io_isram_data_ok(fetch_io_isram_data_ok),
    .io_isram_using(fetch_io_isram_using),
    .io_isram_rdata(fetch_io_isram_rdata),
    .io_if_to_id_is_nop(fetch_io_if_to_id_is_nop),
    .io_if_to_id_pc(fetch_io_if_to_id_pc),
    .io_if_to_id_inst(fetch_io_if_to_id_inst),
    .io_id_to_if_pc_target(fetch_io_id_to_if_pc_target),
    .io_id_to_if_jump(fetch_io_id_to_if_jump),
    .io_br_stall(fetch_io_br_stall)
  );
  DR dr ( // @[Core.scala 16:18]
    .clock(dr_clock),
    .reset(dr_reset),
    .io_fs_to_ds_valid(dr_io_fs_to_ds_valid),
    .io_ds_valid(dr_io_ds_valid),
    .io_ds_allowin(dr_io_ds_allowin),
    .io_if_to_dr_is_nop(dr_io_if_to_dr_is_nop),
    .io_if_to_dr_pc(dr_io_if_to_dr_pc),
    .io_if_to_dr_inst(dr_io_if_to_dr_inst),
    .io_dr_to_id_is_nop(dr_io_dr_to_id_is_nop),
    .io_dr_to_id_pc(dr_io_dr_to_id_pc),
    .io_dr_to_id_inst(dr_io_dr_to_id_inst)
  );
  Decode decode ( // @[Core.scala 17:22]
    .clock(decode_clock),
    .reset(decode_reset),
    .io_es_allowin(decode_io_es_allowin),
    .io_ds_valid(decode_io_ds_valid),
    .io_ds_allowin(decode_io_ds_allowin),
    .io_ds_to_es_valid(decode_io_ds_to_es_valid),
    .io_if_to_id_is_nop(decode_io_if_to_id_is_nop),
    .io_if_to_id_pc(decode_io_if_to_id_pc),
    .io_if_to_id_inst(decode_io_if_to_id_inst),
    .io_id_to_ex_is_nop(decode_io_id_to_ex_is_nop),
    .io_id_to_ex_aluop(decode_io_id_to_ex_aluop),
    .io_id_to_ex_lsuop(decode_io_id_to_ex_lsuop),
    .io_id_to_ex_rv64op(decode_io_id_to_ex_rv64op),
    .io_id_to_ex_out1(decode_io_id_to_ex_out1),
    .io_id_to_ex_out2(decode_io_id_to_ex_out2),
    .io_id_to_ex_imm(decode_io_id_to_ex_imm),
    .io_id_to_ex_dest(decode_io_id_to_ex_dest),
    .io_id_to_ex_rf_w(decode_io_id_to_ex_rf_w),
    .io_id_to_ex_load(decode_io_id_to_ex_load),
    .io_id_to_ex_save(decode_io_id_to_ex_save),
    .io_id_to_ex_pc(decode_io_id_to_ex_pc),
    .io_id_to_ex_inst(decode_io_id_to_ex_inst),
    .io_id_to_ex_is_csr(decode_io_id_to_ex_is_csr),
    .io_id_to_ex_csrop(decode_io_id_to_ex_csrop),
    .io_id_to_ex_csr_addr(decode_io_id_to_ex_csr_addr),
    .io_id_to_ex_csr_src(decode_io_id_to_ex_csr_src),
    .io_id_to_ex_is_zero(decode_io_id_to_ex_is_zero),
    .io_id_to_if_pc_target(decode_io_id_to_if_pc_target),
    .io_id_to_if_jump(decode_io_id_to_if_jump),
    .io_csr_to_id_csr_jump(decode_io_csr_to_id_csr_jump),
    .io_csr_to_id_csr_target(decode_io_csr_to_id_csr_target),
    .io_rs1_addr(decode_io_rs1_addr),
    .io_rs1_data(decode_io_rs1_data),
    .io_rs2_addr(decode_io_rs2_addr),
    .io_rs2_data(decode_io_rs2_data),
    .io_fwd_ex_rf_w(decode_io_fwd_ex_rf_w),
    .io_fwd_ex_dst(decode_io_fwd_ex_dst),
    .io_fwd_ex_alu_res(decode_io_fwd_ex_alu_res),
    .io_fwd_ex_is_csr(decode_io_fwd_ex_is_csr),
    .io_fwd_ex_load(decode_io_fwd_ex_load),
    .io_fwd_lsu_rf_w(decode_io_fwd_lsu_rf_w),
    .io_fwd_lsu_dst(decode_io_fwd_lsu_dst),
    .io_fwd_lsu_lsu_res(decode_io_fwd_lsu_lsu_res),
    .io_fwd_lsu_is_csr(decode_io_fwd_lsu_is_csr),
    .io_fwd_lsu_br_stall(decode_io_fwd_lsu_br_stall),
    .io_fwd_wb_rf_w(decode_io_fwd_wb_rf_w),
    .io_fwd_wb_dst(decode_io_fwd_wb_dst),
    .io_fwd_wb_wb_res(decode_io_fwd_wb_wb_res),
    .io_intr_flush(decode_io_intr_flush),
    .io_br_stall(decode_io_br_stall)
  );
  ER er ( // @[Core.scala 20:18]
    .clock(er_clock),
    .reset(er_reset),
    .io_ds_to_es_valid(er_io_ds_to_es_valid),
    .io_es_valid(er_io_es_valid),
    .io_es_allowin(er_io_es_allowin),
    .io_id_to_er_is_nop(er_io_id_to_er_is_nop),
    .io_id_to_er_aluop(er_io_id_to_er_aluop),
    .io_id_to_er_lsuop(er_io_id_to_er_lsuop),
    .io_id_to_er_rv64op(er_io_id_to_er_rv64op),
    .io_id_to_er_out1(er_io_id_to_er_out1),
    .io_id_to_er_out2(er_io_id_to_er_out2),
    .io_id_to_er_imm(er_io_id_to_er_imm),
    .io_id_to_er_dest(er_io_id_to_er_dest),
    .io_id_to_er_rf_w(er_io_id_to_er_rf_w),
    .io_id_to_er_load(er_io_id_to_er_load),
    .io_id_to_er_save(er_io_id_to_er_save),
    .io_id_to_er_pc(er_io_id_to_er_pc),
    .io_id_to_er_inst(er_io_id_to_er_inst),
    .io_id_to_er_is_csr(er_io_id_to_er_is_csr),
    .io_id_to_er_csrop(er_io_id_to_er_csrop),
    .io_id_to_er_csr_addr(er_io_id_to_er_csr_addr),
    .io_id_to_er_csr_src(er_io_id_to_er_csr_src),
    .io_id_to_er_is_zero(er_io_id_to_er_is_zero),
    .io_er_to_ex_is_nop(er_io_er_to_ex_is_nop),
    .io_er_to_ex_aluop(er_io_er_to_ex_aluop),
    .io_er_to_ex_lsuop(er_io_er_to_ex_lsuop),
    .io_er_to_ex_rv64op(er_io_er_to_ex_rv64op),
    .io_er_to_ex_out1(er_io_er_to_ex_out1),
    .io_er_to_ex_out2(er_io_er_to_ex_out2),
    .io_er_to_ex_imm(er_io_er_to_ex_imm),
    .io_er_to_ex_dest(er_io_er_to_ex_dest),
    .io_er_to_ex_rf_w(er_io_er_to_ex_rf_w),
    .io_er_to_ex_load(er_io_er_to_ex_load),
    .io_er_to_ex_save(er_io_er_to_ex_save),
    .io_er_to_ex_pc(er_io_er_to_ex_pc),
    .io_er_to_ex_inst(er_io_er_to_ex_inst),
    .io_er_to_ex_is_csr(er_io_er_to_ex_is_csr),
    .io_er_to_ex_csrop(er_io_er_to_ex_csrop),
    .io_er_to_ex_csr_addr(er_io_er_to_ex_csr_addr),
    .io_er_to_ex_csr_src(er_io_er_to_ex_csr_src),
    .io_er_to_ex_is_zero(er_io_er_to_ex_is_zero)
  );
  Execution ex ( // @[Core.scala 21:18]
    .io_ls_allowin(ex_io_ls_allowin),
    .io_es_valid(ex_io_es_valid),
    .io_es_allowin(ex_io_es_allowin),
    .io_es_to_ls_valid(ex_io_es_to_ls_valid),
    .io_id_to_ex_is_nop(ex_io_id_to_ex_is_nop),
    .io_id_to_ex_aluop(ex_io_id_to_ex_aluop),
    .io_id_to_ex_lsuop(ex_io_id_to_ex_lsuop),
    .io_id_to_ex_rv64op(ex_io_id_to_ex_rv64op),
    .io_id_to_ex_out1(ex_io_id_to_ex_out1),
    .io_id_to_ex_out2(ex_io_id_to_ex_out2),
    .io_id_to_ex_imm(ex_io_id_to_ex_imm),
    .io_id_to_ex_dest(ex_io_id_to_ex_dest),
    .io_id_to_ex_rf_w(ex_io_id_to_ex_rf_w),
    .io_id_to_ex_load(ex_io_id_to_ex_load),
    .io_id_to_ex_save(ex_io_id_to_ex_save),
    .io_id_to_ex_pc(ex_io_id_to_ex_pc),
    .io_id_to_ex_inst(ex_io_id_to_ex_inst),
    .io_id_to_ex_is_csr(ex_io_id_to_ex_is_csr),
    .io_id_to_ex_csrop(ex_io_id_to_ex_csrop),
    .io_id_to_ex_csr_addr(ex_io_id_to_ex_csr_addr),
    .io_id_to_ex_csr_src(ex_io_id_to_ex_csr_src),
    .io_id_to_ex_is_zero(ex_io_id_to_ex_is_zero),
    .io_ex_to_lsu_is_nop(ex_io_ex_to_lsu_is_nop),
    .io_ex_to_lsu_alu_res(ex_io_ex_to_lsu_alu_res),
    .io_ex_to_lsu_src1(ex_io_ex_to_lsu_src1),
    .io_ex_to_lsu_src2(ex_io_ex_to_lsu_src2),
    .io_ex_to_lsu_imm(ex_io_ex_to_lsu_imm),
    .io_ex_to_lsu_lsuop(ex_io_ex_to_lsu_lsuop),
    .io_ex_to_lsu_rv64op(ex_io_ex_to_lsu_rv64op),
    .io_ex_to_lsu_dest(ex_io_ex_to_lsu_dest),
    .io_ex_to_lsu_rf_w(ex_io_ex_to_lsu_rf_w),
    .io_ex_to_lsu_load(ex_io_ex_to_lsu_load),
    .io_ex_to_lsu_save(ex_io_ex_to_lsu_save),
    .io_ex_to_lsu_pc(ex_io_ex_to_lsu_pc),
    .io_ex_to_lsu_inst(ex_io_ex_to_lsu_inst),
    .io_ex_to_lsu_is_csr(ex_io_ex_to_lsu_is_csr),
    .io_ex_to_lsu_csrop(ex_io_ex_to_lsu_csrop),
    .io_ex_to_lsu_csr_addr(ex_io_ex_to_lsu_csr_addr),
    .io_ex_to_lsu_csr_src(ex_io_ex_to_lsu_csr_src),
    .io_ex_to_lsu_is_zero(ex_io_ex_to_lsu_is_zero),
    .io_ex_fwd_rf_w(ex_io_ex_fwd_rf_w),
    .io_ex_fwd_dst(ex_io_ex_fwd_dst),
    .io_ex_fwd_alu_res(ex_io_ex_fwd_alu_res),
    .io_ex_fwd_is_csr(ex_io_ex_fwd_is_csr),
    .io_ex_fwd_load(ex_io_ex_fwd_load),
    .io_flush(ex_io_flush)
  );
  LR lr ( // @[Core.scala 22:18]
    .clock(lr_clock),
    .reset(lr_reset),
    .io_es_to_ls_valid(lr_io_es_to_ls_valid),
    .io_ls_valid(lr_io_ls_valid),
    .io_ls_allowin(lr_io_ls_allowin),
    .io_ex_to_lr_is_nop(lr_io_ex_to_lr_is_nop),
    .io_ex_to_lr_alu_res(lr_io_ex_to_lr_alu_res),
    .io_ex_to_lr_src1(lr_io_ex_to_lr_src1),
    .io_ex_to_lr_src2(lr_io_ex_to_lr_src2),
    .io_ex_to_lr_imm(lr_io_ex_to_lr_imm),
    .io_ex_to_lr_lsuop(lr_io_ex_to_lr_lsuop),
    .io_ex_to_lr_rv64op(lr_io_ex_to_lr_rv64op),
    .io_ex_to_lr_dest(lr_io_ex_to_lr_dest),
    .io_ex_to_lr_rf_w(lr_io_ex_to_lr_rf_w),
    .io_ex_to_lr_load(lr_io_ex_to_lr_load),
    .io_ex_to_lr_save(lr_io_ex_to_lr_save),
    .io_ex_to_lr_pc(lr_io_ex_to_lr_pc),
    .io_ex_to_lr_inst(lr_io_ex_to_lr_inst),
    .io_ex_to_lr_is_csr(lr_io_ex_to_lr_is_csr),
    .io_ex_to_lr_csrop(lr_io_ex_to_lr_csrop),
    .io_ex_to_lr_csr_addr(lr_io_ex_to_lr_csr_addr),
    .io_ex_to_lr_csr_src(lr_io_ex_to_lr_csr_src),
    .io_ex_to_lr_is_zero(lr_io_ex_to_lr_is_zero),
    .io_lr_to_lsu_is_nop(lr_io_lr_to_lsu_is_nop),
    .io_lr_to_lsu_alu_res(lr_io_lr_to_lsu_alu_res),
    .io_lr_to_lsu_src1(lr_io_lr_to_lsu_src1),
    .io_lr_to_lsu_src2(lr_io_lr_to_lsu_src2),
    .io_lr_to_lsu_imm(lr_io_lr_to_lsu_imm),
    .io_lr_to_lsu_lsuop(lr_io_lr_to_lsu_lsuop),
    .io_lr_to_lsu_rv64op(lr_io_lr_to_lsu_rv64op),
    .io_lr_to_lsu_dest(lr_io_lr_to_lsu_dest),
    .io_lr_to_lsu_rf_w(lr_io_lr_to_lsu_rf_w),
    .io_lr_to_lsu_load(lr_io_lr_to_lsu_load),
    .io_lr_to_lsu_save(lr_io_lr_to_lsu_save),
    .io_lr_to_lsu_pc(lr_io_lr_to_lsu_pc),
    .io_lr_to_lsu_inst(lr_io_lr_to_lsu_inst),
    .io_lr_to_lsu_is_csr(lr_io_lr_to_lsu_is_csr),
    .io_lr_to_lsu_csrop(lr_io_lr_to_lsu_csrop),
    .io_lr_to_lsu_csr_addr(lr_io_lr_to_lsu_csr_addr),
    .io_lr_to_lsu_csr_src(lr_io_lr_to_lsu_csr_src),
    .io_lr_to_lsu_is_zero(lr_io_lr_to_lsu_is_zero)
  );
  LSU lsu ( // @[Core.scala 23:19]
    .clock(lsu_clock),
    .reset(lsu_reset),
    .io_ls_valid(lsu_io_ls_valid),
    .io_ls_allowin(lsu_io_ls_allowin),
    .io_ls_to_ws_valid(lsu_io_ls_to_ws_valid),
    .io_ex_to_lsu_is_nop(lsu_io_ex_to_lsu_is_nop),
    .io_ex_to_lsu_alu_res(lsu_io_ex_to_lsu_alu_res),
    .io_ex_to_lsu_src1(lsu_io_ex_to_lsu_src1),
    .io_ex_to_lsu_src2(lsu_io_ex_to_lsu_src2),
    .io_ex_to_lsu_imm(lsu_io_ex_to_lsu_imm),
    .io_ex_to_lsu_lsuop(lsu_io_ex_to_lsu_lsuop),
    .io_ex_to_lsu_rv64op(lsu_io_ex_to_lsu_rv64op),
    .io_ex_to_lsu_dest(lsu_io_ex_to_lsu_dest),
    .io_ex_to_lsu_rf_w(lsu_io_ex_to_lsu_rf_w),
    .io_ex_to_lsu_load(lsu_io_ex_to_lsu_load),
    .io_ex_to_lsu_save(lsu_io_ex_to_lsu_save),
    .io_ex_to_lsu_pc(lsu_io_ex_to_lsu_pc),
    .io_ex_to_lsu_inst(lsu_io_ex_to_lsu_inst),
    .io_ex_to_lsu_is_csr(lsu_io_ex_to_lsu_is_csr),
    .io_ex_to_lsu_csrop(lsu_io_ex_to_lsu_csrop),
    .io_ex_to_lsu_csr_addr(lsu_io_ex_to_lsu_csr_addr),
    .io_ex_to_lsu_csr_src(lsu_io_ex_to_lsu_csr_src),
    .io_ex_to_lsu_is_zero(lsu_io_ex_to_lsu_is_zero),
    .io_lsu_to_wb_is_nop(lsu_io_lsu_to_wb_is_nop),
    .io_lsu_to_wb_lsu_res(lsu_io_lsu_to_wb_lsu_res),
    .io_lsu_to_wb_dest(lsu_io_lsu_to_wb_dest),
    .io_lsu_to_wb_rf_w(lsu_io_lsu_to_wb_rf_w),
    .io_lsu_to_wb_pc(lsu_io_lsu_to_wb_pc),
    .io_lsu_to_wb_inst(lsu_io_lsu_to_wb_inst),
    .io_lsu_to_wb_is_csr(lsu_io_lsu_to_wb_is_csr),
    .io_lsu_to_wb_csrop(lsu_io_lsu_to_wb_csrop),
    .io_lsu_to_wb_csr_addr(lsu_io_lsu_to_wb_csr_addr),
    .io_lsu_to_wb_csr_src(lsu_io_lsu_to_wb_csr_src),
    .io_lsu_to_wb_is_zero(lsu_io_lsu_to_wb_is_zero),
    .io_lsu_to_csr_is_clint(lsu_io_lsu_to_csr_is_clint),
    .io_lsu_to_csr_is_mtime(lsu_io_lsu_to_csr_is_mtime),
    .io_lsu_to_csr_is_mtimecmp(lsu_io_lsu_to_csr_is_mtimecmp),
    .io_lsu_to_csr_load(lsu_io_lsu_to_csr_load),
    .io_lsu_to_csr_save(lsu_io_lsu_to_csr_save),
    .io_lsu_to_csr_wdata(lsu_io_lsu_to_csr_wdata),
    .io_lsu_to_csr_rdata(lsu_io_lsu_to_csr_rdata),
    .io_lsu_fwd_rf_w(lsu_io_lsu_fwd_rf_w),
    .io_lsu_fwd_dst(lsu_io_lsu_fwd_dst),
    .io_lsu_fwd_lsu_res(lsu_io_lsu_fwd_lsu_res),
    .io_lsu_fwd_is_csr(lsu_io_lsu_fwd_is_csr),
    .io_lsu_fwd_br_stall(lsu_io_lsu_fwd_br_stall),
    .io_dsram_wr(lsu_io_dsram_wr),
    .io_dsram_size(lsu_io_dsram_size),
    .io_dsram_addr(lsu_io_dsram_addr),
    .io_dsram_wstrb(lsu_io_dsram_wstrb),
    .io_dsram_wdata(lsu_io_dsram_wdata),
    .io_dsram_addr_valid(lsu_io_dsram_addr_valid),
    .io_dsram_data_ok(lsu_io_dsram_data_ok),
    .io_dsram_using(lsu_io_dsram_using),
    .io_dsram_rdata(lsu_io_dsram_rdata),
    .io_flush(lsu_io_flush)
  );
  WR wr ( // @[Core.scala 28:18]
    .clock(wr_clock),
    .reset(wr_reset),
    .io_ls_to_ws_valid(wr_io_ls_to_ws_valid),
    .io_ws_valid(wr_io_ws_valid),
    .io_lsu_to_wr_is_nop(wr_io_lsu_to_wr_is_nop),
    .io_lsu_to_wr_lsu_res(wr_io_lsu_to_wr_lsu_res),
    .io_lsu_to_wr_dest(wr_io_lsu_to_wr_dest),
    .io_lsu_to_wr_rf_w(wr_io_lsu_to_wr_rf_w),
    .io_lsu_to_wr_pc(wr_io_lsu_to_wr_pc),
    .io_lsu_to_wr_inst(wr_io_lsu_to_wr_inst),
    .io_lsu_to_wr_is_csr(wr_io_lsu_to_wr_is_csr),
    .io_lsu_to_wr_csrop(wr_io_lsu_to_wr_csrop),
    .io_lsu_to_wr_csr_addr(wr_io_lsu_to_wr_csr_addr),
    .io_lsu_to_wr_csr_src(wr_io_lsu_to_wr_csr_src),
    .io_lsu_to_wr_is_zero(wr_io_lsu_to_wr_is_zero),
    .io_wr_to_wb_is_nop(wr_io_wr_to_wb_is_nop),
    .io_wr_to_wb_lsu_res(wr_io_wr_to_wb_lsu_res),
    .io_wr_to_wb_dest(wr_io_wr_to_wb_dest),
    .io_wr_to_wb_rf_w(wr_io_wr_to_wb_rf_w),
    .io_wr_to_wb_pc(wr_io_wr_to_wb_pc),
    .io_wr_to_wb_inst(wr_io_wr_to_wb_inst),
    .io_wr_to_wb_is_csr(wr_io_wr_to_wb_is_csr),
    .io_wr_to_wb_csrop(wr_io_wr_to_wb_csrop),
    .io_wr_to_wb_csr_addr(wr_io_wr_to_wb_csr_addr),
    .io_wr_to_wb_csr_src(wr_io_wr_to_wb_csr_src),
    .io_wr_to_wb_is_zero(wr_io_wr_to_wb_is_zero)
  );
  WB wb ( // @[Core.scala 29:18]
    .io_ws_valid(wb_io_ws_valid),
    .io_lsu_to_wb_is_nop(wb_io_lsu_to_wb_is_nop),
    .io_lsu_to_wb_lsu_res(wb_io_lsu_to_wb_lsu_res),
    .io_lsu_to_wb_dest(wb_io_lsu_to_wb_dest),
    .io_lsu_to_wb_rf_w(wb_io_lsu_to_wb_rf_w),
    .io_lsu_to_wb_pc(wb_io_lsu_to_wb_pc),
    .io_lsu_to_wb_inst(wb_io_lsu_to_wb_inst),
    .io_lsu_to_wb_is_csr(wb_io_lsu_to_wb_is_csr),
    .io_lsu_to_wb_csrop(wb_io_lsu_to_wb_csrop),
    .io_lsu_to_wb_csr_addr(wb_io_lsu_to_wb_csr_addr),
    .io_lsu_to_wb_csr_src(wb_io_lsu_to_wb_csr_src),
    .io_lsu_to_wb_is_zero(wb_io_lsu_to_wb_is_zero),
    .io_wb_to_csr_is_nop(wb_io_wb_to_csr_is_nop),
    .io_wb_to_csr_csrop(wb_io_wb_to_csr_csrop),
    .io_wb_to_csr_csr_addr(wb_io_wb_to_csr_csr_addr),
    .io_wb_to_csr_csr_src(wb_io_wb_to_csr_csr_src),
    .io_wb_to_csr_is_zero(wb_io_wb_to_csr_is_zero),
    .io_wb_to_csr_pc(wb_io_wb_to_csr_pc),
    .io_wb_to_csr_csr_res(wb_io_wb_to_csr_csr_res),
    .io_wb_fwd_rf_w(wb_io_wb_fwd_rf_w),
    .io_wb_fwd_dst(wb_io_wb_fwd_dst),
    .io_wb_fwd_wb_res(wb_io_wb_fwd_wb_res),
    .io_rd_addr(wb_io_rd_addr),
    .io_rd_data(wb_io_rd_data),
    .io_rd_en(wb_io_rd_en),
    .io_pc(wb_io_pc),
    .io_inst(wb_io_inst),
    .io_is_nop(wb_io_is_nop),
    .io_flush(wb_io_flush)
  );
  RegFile rf ( // @[Core.scala 31:18]
    .clock(rf_clock),
    .reset(rf_reset),
    .io_rs1_addr(rf_io_rs1_addr),
    .io_rs2_addr(rf_io_rs2_addr),
    .io_rs1_data(rf_io_rs1_data),
    .io_rs2_data(rf_io_rs2_data),
    .io_rd_addr(rf_io_rd_addr),
    .io_rd_data(rf_io_rd_data),
    .io_rd_en(rf_io_rd_en),
    .rf_10(rf_rf_10)
  );
  CSR csr ( // @[Core.scala 43:19]
    .clock(csr_clock),
    .reset(csr_reset),
    .io_wb_to_csr_is_nop(csr_io_wb_to_csr_is_nop),
    .io_wb_to_csr_csrop(csr_io_wb_to_csr_csrop),
    .io_wb_to_csr_csr_addr(csr_io_wb_to_csr_csr_addr),
    .io_wb_to_csr_csr_src(csr_io_wb_to_csr_csr_src),
    .io_wb_to_csr_is_zero(csr_io_wb_to_csr_is_zero),
    .io_wb_to_csr_pc(csr_io_wb_to_csr_pc),
    .io_wb_to_csr_csr_res(csr_io_wb_to_csr_csr_res),
    .io_csr_to_id_csr_jump(csr_io_csr_to_id_csr_jump),
    .io_csr_to_id_csr_target(csr_io_csr_to_id_csr_target),
    .io_csr_to_lsu_is_clint(csr_io_csr_to_lsu_is_clint),
    .io_csr_to_lsu_is_mtime(csr_io_csr_to_lsu_is_mtime),
    .io_csr_to_lsu_is_mtimecmp(csr_io_csr_to_lsu_is_mtimecmp),
    .io_csr_to_lsu_load(csr_io_csr_to_lsu_load),
    .io_csr_to_lsu_save(csr_io_csr_to_lsu_save),
    .io_csr_to_lsu_wdata(csr_io_csr_to_lsu_wdata),
    .io_csr_to_lsu_rdata(csr_io_csr_to_lsu_rdata),
    .io_mepc(csr_io_mepc),
    .io_mcause(csr_io_mcause),
    .io_mtvec(csr_io_mtvec),
    .io_mstatus(csr_io_mstatus),
    .io_mie(csr_io_mie),
    .io_mscratch(csr_io_mscratch),
    .io_sstatus(csr_io_sstatus),
    .io_intrNO(csr_io_intrNO),
    .io_cause(csr_io_cause),
    .io_clkintr_flush(csr_io_clkintr_flush)
  );
  DifftestInstrCommit dt_ic ( // @[Core.scala 92:21]
    .clock(dt_ic_clock),
    .coreid(dt_ic_coreid),
    .index(dt_ic_index),
    .valid(dt_ic_valid),
    .pc(dt_ic_pc),
    .instr(dt_ic_instr),
    .special(dt_ic_special),
    .skip(dt_ic_skip),
    .isRVC(dt_ic_isRVC),
    .scFailed(dt_ic_scFailed),
    .wen(dt_ic_wen),
    .wdata(dt_ic_wdata),
    .wdest(dt_ic_wdest)
  );
  DifftestArchEvent dt_ae ( // @[Core.scala 108:21]
    .clock(dt_ae_clock),
    .coreid(dt_ae_coreid),
    .intrNO(dt_ae_intrNO),
    .cause(dt_ae_cause),
    .exceptionPC(dt_ae_exceptionPC),
    .exceptionInst(dt_ae_exceptionInst)
  );
  DifftestTrapEvent dt_te ( // @[Core.scala 124:21]
    .clock(dt_te_clock),
    .coreid(dt_te_coreid),
    .valid(dt_te_valid),
    .code(dt_te_code),
    .pc(dt_te_pc),
    .cycleCnt(dt_te_cycleCnt),
    .instrCnt(dt_te_instrCnt)
  );
  DifftestCSRState dt_cs ( // @[Core.scala 133:21]
    .clock(dt_cs_clock),
    .coreid(dt_cs_coreid),
    .priviledgeMode(dt_cs_priviledgeMode),
    .mstatus(dt_cs_mstatus),
    .sstatus(dt_cs_sstatus),
    .mepc(dt_cs_mepc),
    .sepc(dt_cs_sepc),
    .mtval(dt_cs_mtval),
    .stval(dt_cs_stval),
    .mtvec(dt_cs_mtvec),
    .stvec(dt_cs_stvec),
    .mcause(dt_cs_mcause),
    .scause(dt_cs_scause),
    .satp(dt_cs_satp),
    .mip(dt_cs_mip),
    .mie(dt_cs_mie),
    .mscratch(dt_cs_mscratch),
    .sscratch(dt_cs_sscratch),
    .mideleg(dt_cs_mideleg),
    .medeleg(dt_cs_medeleg)
  );
  assign io_isram_addr = fetch_io_isram_addr; // @[Core.scala 14:18]
  assign io_isram_addr_valid = fetch_io_isram_addr_valid; // @[Core.scala 14:18]
  assign io_isram_addr_can_send = fetch_io_isram_addr_can_send; // @[Core.scala 14:18]
  assign io_isram_using = fetch_io_isram_using; // @[Core.scala 14:18]
  assign io_dsram_wr = lsu_io_dsram_wr; // @[Core.scala 24:16]
  assign io_dsram_size = lsu_io_dsram_size; // @[Core.scala 24:16]
  assign io_dsram_addr = lsu_io_dsram_addr; // @[Core.scala 24:16]
  assign io_dsram_wstrb = lsu_io_dsram_wstrb; // @[Core.scala 24:16]
  assign io_dsram_wdata = lsu_io_dsram_wdata; // @[Core.scala 24:16]
  assign io_dsram_addr_valid = lsu_io_dsram_addr_valid; // @[Core.scala 24:16]
  assign io_dsram_using = lsu_io_dsram_using; // @[Core.scala 24:16]
  assign fetch_clock = clock;
  assign fetch_reset = reset;
  assign fetch_io_ds_allowin = decode_io_ds_allowin; // @[Core.scala 62:23]
  assign fetch_io_isram_addr_ok = io_isram_addr_ok; // @[Core.scala 14:18]
  assign fetch_io_isram_data_ok = io_isram_data_ok; // @[Core.scala 14:18]
  assign fetch_io_isram_rdata = io_isram_rdata; // @[Core.scala 14:18]
  assign fetch_io_id_to_if_pc_target = decode_io_id_to_if_pc_target; // @[Core.scala 18:22]
  assign fetch_io_id_to_if_jump = decode_io_id_to_if_jump; // @[Core.scala 18:22]
  assign dr_clock = clock;
  assign dr_reset = reset;
  assign dr_io_fs_to_ds_valid = fetch_io_fs_to_ds_valid; // @[Core.scala 63:24]
  assign dr_io_ds_allowin = decode_io_ds_allowin; // @[Core.scala 64:20]
  assign dr_io_if_to_dr_is_nop = fetch_io_if_to_id_is_nop; // @[Core.scala 49:21]
  assign dr_io_if_to_dr_pc = fetch_io_if_to_id_pc; // @[Core.scala 49:21]
  assign dr_io_if_to_dr_inst = fetch_io_if_to_id_inst; // @[Core.scala 49:21]
  assign decode_clock = clock;
  assign decode_reset = reset;
  assign decode_io_es_allowin = ex_io_es_allowin; // @[Core.scala 67:24]
  assign decode_io_ds_valid = dr_io_ds_valid; // @[Core.scala 65:22]
  assign decode_io_if_to_id_is_nop = dr_io_dr_to_id_is_nop; // @[Core.scala 50:18]
  assign decode_io_if_to_id_pc = dr_io_dr_to_id_pc; // @[Core.scala 50:18]
  assign decode_io_if_to_id_inst = dr_io_dr_to_id_inst; // @[Core.scala 50:18]
  assign decode_io_csr_to_id_csr_jump = csr_io_csr_to_id_csr_jump; // @[Core.scala 44:20]
  assign decode_io_csr_to_id_csr_target = csr_io_csr_to_id_csr_target; // @[Core.scala 44:20]
  assign decode_io_rs1_data = rf_io_rs1_data; // @[Core.scala 36:22]
  assign decode_io_rs2_data = rf_io_rs2_data; // @[Core.scala 37:22]
  assign decode_io_fwd_ex_rf_w = ex_io_ex_fwd_rf_w; // @[Core.scala 83:21]
  assign decode_io_fwd_ex_dst = ex_io_ex_fwd_dst; // @[Core.scala 83:21]
  assign decode_io_fwd_ex_alu_res = ex_io_ex_fwd_alu_res; // @[Core.scala 83:21]
  assign decode_io_fwd_ex_is_csr = ex_io_ex_fwd_is_csr; // @[Core.scala 83:21]
  assign decode_io_fwd_ex_load = ex_io_ex_fwd_load; // @[Core.scala 83:21]
  assign decode_io_fwd_lsu_rf_w = lsu_io_lsu_fwd_rf_w; // @[Core.scala 84:21]
  assign decode_io_fwd_lsu_dst = lsu_io_lsu_fwd_dst; // @[Core.scala 84:21]
  assign decode_io_fwd_lsu_lsu_res = lsu_io_lsu_fwd_lsu_res; // @[Core.scala 84:21]
  assign decode_io_fwd_lsu_is_csr = lsu_io_lsu_fwd_is_csr; // @[Core.scala 84:21]
  assign decode_io_fwd_lsu_br_stall = lsu_io_lsu_fwd_br_stall; // @[Core.scala 84:21]
  assign decode_io_fwd_wb_rf_w = wb_io_wb_fwd_rf_w; // @[Core.scala 85:21]
  assign decode_io_fwd_wb_dst = wb_io_wb_fwd_dst; // @[Core.scala 85:21]
  assign decode_io_fwd_wb_wb_res = wb_io_wb_fwd_wb_res; // @[Core.scala 85:21]
  assign decode_io_br_stall = fetch_io_br_stall; // @[Core.scala 19:22]
  assign er_clock = clock;
  assign er_reset = reset;
  assign er_io_ds_to_es_valid = decode_io_ds_to_es_valid; // @[Core.scala 68:24]
  assign er_io_es_allowin = ex_io_es_allowin; // @[Core.scala 69:20]
  assign er_io_id_to_er_is_nop = decode_io_id_to_ex_is_nop; // @[Core.scala 52:22]
  assign er_io_id_to_er_aluop = decode_io_id_to_ex_aluop; // @[Core.scala 52:22]
  assign er_io_id_to_er_lsuop = decode_io_id_to_ex_lsuop; // @[Core.scala 52:22]
  assign er_io_id_to_er_rv64op = decode_io_id_to_ex_rv64op; // @[Core.scala 52:22]
  assign er_io_id_to_er_out1 = decode_io_id_to_ex_out1; // @[Core.scala 52:22]
  assign er_io_id_to_er_out2 = decode_io_id_to_ex_out2; // @[Core.scala 52:22]
  assign er_io_id_to_er_imm = decode_io_id_to_ex_imm; // @[Core.scala 52:22]
  assign er_io_id_to_er_dest = decode_io_id_to_ex_dest; // @[Core.scala 52:22]
  assign er_io_id_to_er_rf_w = decode_io_id_to_ex_rf_w; // @[Core.scala 52:22]
  assign er_io_id_to_er_load = decode_io_id_to_ex_load; // @[Core.scala 52:22]
  assign er_io_id_to_er_save = decode_io_id_to_ex_save; // @[Core.scala 52:22]
  assign er_io_id_to_er_pc = decode_io_id_to_ex_pc; // @[Core.scala 52:22]
  assign er_io_id_to_er_inst = decode_io_id_to_ex_inst; // @[Core.scala 52:22]
  assign er_io_id_to_er_is_csr = decode_io_id_to_ex_is_csr; // @[Core.scala 52:22]
  assign er_io_id_to_er_csrop = decode_io_id_to_ex_csrop; // @[Core.scala 52:22]
  assign er_io_id_to_er_csr_addr = decode_io_id_to_ex_csr_addr; // @[Core.scala 52:22]
  assign er_io_id_to_er_csr_src = decode_io_id_to_ex_csr_src; // @[Core.scala 52:22]
  assign er_io_id_to_er_is_zero = decode_io_id_to_ex_is_zero; // @[Core.scala 52:22]
  assign ex_io_ls_allowin = lsu_io_ls_allowin; // @[Core.scala 72:20]
  assign ex_io_es_valid = er_io_es_valid; // @[Core.scala 70:18]
  assign ex_io_id_to_ex_is_nop = er_io_er_to_ex_is_nop; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_aluop = er_io_er_to_ex_aluop; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_lsuop = er_io_er_to_ex_lsuop; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_rv64op = er_io_er_to_ex_rv64op; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_out1 = er_io_er_to_ex_out1; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_out2 = er_io_er_to_ex_out2; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_imm = er_io_er_to_ex_imm; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_dest = er_io_er_to_ex_dest; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_rf_w = er_io_er_to_ex_rf_w; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_load = er_io_er_to_ex_load; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_save = er_io_er_to_ex_save; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_pc = er_io_er_to_ex_pc; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_inst = er_io_er_to_ex_inst; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_is_csr = er_io_er_to_ex_is_csr; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_csrop = er_io_er_to_ex_csrop; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_csr_addr = er_io_er_to_ex_csr_addr; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_csr_src = er_io_er_to_ex_csr_src; // @[Core.scala 53:18]
  assign ex_io_id_to_ex_is_zero = er_io_er_to_ex_is_zero; // @[Core.scala 53:18]
  assign ex_io_flush = decode_io_intr_flush; // @[Core.scala 87:15]
  assign lr_clock = clock;
  assign lr_reset = reset;
  assign lr_io_es_to_ls_valid = ex_io_es_to_ls_valid; // @[Core.scala 73:24]
  assign lr_io_ls_allowin = lsu_io_ls_allowin; // @[Core.scala 74:20]
  assign lr_io_ex_to_lr_is_nop = ex_io_ex_to_lsu_is_nop; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_alu_res = ex_io_ex_to_lsu_alu_res; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_src1 = ex_io_ex_to_lsu_src1; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_src2 = ex_io_ex_to_lsu_src2; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_imm = ex_io_ex_to_lsu_imm; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_lsuop = ex_io_ex_to_lsu_lsuop; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_rv64op = ex_io_ex_to_lsu_rv64op; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_dest = ex_io_ex_to_lsu_dest; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_rf_w = ex_io_ex_to_lsu_rf_w; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_load = ex_io_ex_to_lsu_load; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_save = ex_io_ex_to_lsu_save; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_pc = ex_io_ex_to_lsu_pc; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_inst = ex_io_ex_to_lsu_inst; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_is_csr = ex_io_ex_to_lsu_is_csr; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_csrop = ex_io_ex_to_lsu_csrop; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_csr_addr = ex_io_ex_to_lsu_csr_addr; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_csr_src = ex_io_ex_to_lsu_csr_src; // @[Core.scala 55:19]
  assign lr_io_ex_to_lr_is_zero = ex_io_ex_to_lsu_is_zero; // @[Core.scala 55:19]
  assign lsu_clock = clock;
  assign lsu_reset = reset;
  assign lsu_io_ls_valid = lr_io_ls_valid; // @[Core.scala 75:19]
  assign lsu_io_ex_to_lsu_is_nop = lr_io_lr_to_lsu_is_nop; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_alu_res = lr_io_lr_to_lsu_alu_res; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_src1 = lr_io_lr_to_lsu_src1; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_src2 = lr_io_lr_to_lsu_src2; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_imm = lr_io_lr_to_lsu_imm; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_lsuop = lr_io_lr_to_lsu_lsuop; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_rv64op = lr_io_lr_to_lsu_rv64op; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_dest = lr_io_lr_to_lsu_dest; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_rf_w = lr_io_lr_to_lsu_rf_w; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_load = lr_io_lr_to_lsu_load; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_save = lr_io_lr_to_lsu_save; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_pc = lr_io_lr_to_lsu_pc; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_inst = lr_io_lr_to_lsu_inst; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_is_csr = lr_io_lr_to_lsu_is_csr; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_csrop = lr_io_lr_to_lsu_csrop; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_csr_addr = lr_io_lr_to_lsu_csr_addr; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_csr_src = lr_io_lr_to_lsu_csr_src; // @[Core.scala 56:19]
  assign lsu_io_ex_to_lsu_is_zero = lr_io_lr_to_lsu_is_zero; // @[Core.scala 56:19]
  assign lsu_io_lsu_to_csr_rdata = csr_io_csr_to_lsu_rdata; // @[Core.scala 45:21]
  assign lsu_io_dsram_data_ok = io_dsram_data_ok; // @[Core.scala 24:16]
  assign lsu_io_dsram_rdata = io_dsram_rdata; // @[Core.scala 24:16]
  assign lsu_io_flush = decode_io_intr_flush; // @[Core.scala 88:16]
  assign wr_clock = clock;
  assign wr_reset = reset;
  assign wr_io_ls_to_ws_valid = lsu_io_ls_to_ws_valid; // @[Core.scala 78:24]
  assign wr_io_lsu_to_wr_is_nop = lsu_io_lsu_to_wb_is_nop; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_lsu_res = lsu_io_lsu_to_wb_lsu_res; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_dest = lsu_io_lsu_to_wb_dest; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_rf_w = lsu_io_lsu_to_wb_rf_w; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_pc = lsu_io_lsu_to_wb_pc; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_inst = lsu_io_lsu_to_wb_inst; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_is_csr = lsu_io_lsu_to_wb_is_csr; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_csrop = lsu_io_lsu_to_wb_csrop; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_csr_addr = lsu_io_lsu_to_wb_csr_addr; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_csr_src = lsu_io_lsu_to_wb_csr_src; // @[Core.scala 58:20]
  assign wr_io_lsu_to_wr_is_zero = lsu_io_lsu_to_wb_is_zero; // @[Core.scala 58:20]
  assign wb_io_ws_valid = wr_io_ws_valid; // @[Core.scala 80:18]
  assign wb_io_lsu_to_wb_is_nop = wr_io_wr_to_wb_is_nop; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_lsu_res = wr_io_wr_to_wb_lsu_res; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_dest = wr_io_wr_to_wb_dest; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_rf_w = wr_io_wr_to_wb_rf_w; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_pc = wr_io_wr_to_wb_pc; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_inst = wr_io_wr_to_wb_inst; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_is_csr = wr_io_wr_to_wb_is_csr; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_csrop = wr_io_wr_to_wb_csrop; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_csr_addr = wr_io_wr_to_wb_csr_addr; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_csr_src = wr_io_wr_to_wb_csr_src; // @[Core.scala 59:18]
  assign wb_io_lsu_to_wb_is_zero = wr_io_wr_to_wb_is_zero; // @[Core.scala 59:18]
  assign wb_io_wb_to_csr_csr_res = csr_io_wb_to_csr_csr_res; // @[Core.scala 46:19]
  assign wb_io_flush = csr_io_clkintr_flush; // @[Core.scala 89:15]
  assign rf_clock = clock;
  assign rf_reset = reset;
  assign rf_io_rs1_addr = decode_io_rs1_addr; // @[Core.scala 33:18]
  assign rf_io_rs2_addr = decode_io_rs2_addr; // @[Core.scala 34:18]
  assign rf_io_rd_addr = wb_io_rd_addr; // @[Core.scala 39:17]
  assign rf_io_rd_data = wb_io_rd_data; // @[Core.scala 40:17]
  assign rf_io_rd_en = wb_io_rd_en; // @[Core.scala 41:15]
  assign csr_clock = clock;
  assign csr_reset = reset;
  assign csr_io_wb_to_csr_is_nop = wb_io_wb_to_csr_is_nop; // @[Core.scala 46:19]
  assign csr_io_wb_to_csr_csrop = wb_io_wb_to_csr_csrop; // @[Core.scala 46:19]
  assign csr_io_wb_to_csr_csr_addr = wb_io_wb_to_csr_csr_addr; // @[Core.scala 46:19]
  assign csr_io_wb_to_csr_csr_src = wb_io_wb_to_csr_csr_src; // @[Core.scala 46:19]
  assign csr_io_wb_to_csr_is_zero = wb_io_wb_to_csr_is_zero; // @[Core.scala 46:19]
  assign csr_io_wb_to_csr_pc = wb_io_wb_to_csr_pc; // @[Core.scala 46:19]
  assign csr_io_csr_to_lsu_is_clint = lsu_io_lsu_to_csr_is_clint; // @[Core.scala 45:21]
  assign csr_io_csr_to_lsu_is_mtime = lsu_io_lsu_to_csr_is_mtime; // @[Core.scala 45:21]
  assign csr_io_csr_to_lsu_is_mtimecmp = lsu_io_lsu_to_csr_is_mtimecmp; // @[Core.scala 45:21]
  assign csr_io_csr_to_lsu_load = lsu_io_lsu_to_csr_load; // @[Core.scala 45:21]
  assign csr_io_csr_to_lsu_save = lsu_io_lsu_to_csr_save; // @[Core.scala 45:21]
  assign csr_io_csr_to_lsu_wdata = lsu_io_lsu_to_csr_wdata; // @[Core.scala 45:21]
  assign dt_ic_clock = clock; // @[Core.scala 93:18]
  assign dt_ic_coreid = 8'h0; // @[Core.scala 94:19]
  assign dt_ic_index = 8'h0; // @[Core.scala 95:18]
  assign dt_ic_valid = ~dt_ic_io_valid_REG; // @[Core.scala 96:21]
  assign dt_ic_pc = dt_ic_io_pc_REG; // @[Core.scala 97:15]
  assign dt_ic_instr = dt_ic_io_instr_REG; // @[Core.scala 98:18]
  assign dt_ic_special = 8'h0;
  assign dt_ic_skip = dt_ic_io_skip_REG_1; // @[Core.scala 99:17]
  assign dt_ic_isRVC = 1'h0; // @[Core.scala 102:18]
  assign dt_ic_scFailed = 1'h0; // @[Core.scala 103:21]
  assign dt_ic_wen = dt_ic_io_wen_REG; // @[Core.scala 104:16]
  assign dt_ic_wdata = dt_ic_io_wdata_REG; // @[Core.scala 105:18]
  assign dt_ic_wdest = {{3'd0}, dt_ic_io_wdest_REG}; // @[Core.scala 106:18]
  assign dt_ae_clock = clock; // @[Core.scala 109:18]
  assign dt_ae_coreid = 8'h0; // @[Core.scala 110:19]
  assign dt_ae_intrNO = dt_ae_io_intrNO_REG; // @[Core.scala 111:19]
  assign dt_ae_cause = dt_ae_io_cause_REG; // @[Core.scala 112:18]
  assign dt_ae_exceptionPC = dt_ae_io_exceptionPC_REG; // @[Core.scala 113:24]
  assign dt_ae_exceptionInst = 32'h0;
  assign dt_te_clock = clock; // @[Core.scala 125:18]
  assign dt_te_coreid = 8'h0; // @[Core.scala 126:19]
  assign dt_te_valid = wb_io_inst == 32'h6b; // @[Core.scala 127:33]
  assign dt_te_code = rf_a0_0[2:0]; // @[Core.scala 128:25]
  assign dt_te_pc = wb_io_pc; // @[Core.scala 129:15]
  assign dt_te_cycleCnt = cycle_cnt; // @[Core.scala 130:21]
  assign dt_te_instrCnt = instr_cnt; // @[Core.scala 131:21]
  assign dt_cs_clock = clock; // @[Core.scala 134:18]
  assign dt_cs_coreid = 8'h0; // @[Core.scala 135:19]
  assign dt_cs_priviledgeMode = 2'h3; // @[Core.scala 136:27]
  assign dt_cs_mstatus = dt_cs_io_mstatus_REG; // @[Core.scala 137:20]
  assign dt_cs_sstatus = dt_cs_io_sstatus_REG; // @[Core.scala 138:20]
  assign dt_cs_mepc = dt_cs_io_mepc_REG; // @[Core.scala 139:17]
  assign dt_cs_sepc = 64'h0; // @[Core.scala 140:17]
  assign dt_cs_mtval = 64'h0; // @[Core.scala 141:18]
  assign dt_cs_stval = 64'h0; // @[Core.scala 142:18]
  assign dt_cs_mtvec = dt_cs_io_mtvec_REG; // @[Core.scala 143:18]
  assign dt_cs_stvec = 64'h0; // @[Core.scala 144:18]
  assign dt_cs_mcause = dt_cs_io_mcause_REG; // @[Core.scala 145:19]
  assign dt_cs_scause = 64'h0; // @[Core.scala 146:19]
  assign dt_cs_satp = 64'h0; // @[Core.scala 147:17]
  assign dt_cs_mip = 64'h0; // @[Core.scala 148:16]
  assign dt_cs_mie = dt_cs_io_mie_REG; // @[Core.scala 149:16]
  assign dt_cs_mscratch = dt_cs_io_mscratch_REG; // @[Core.scala 150:21]
  assign dt_cs_sscratch = 64'h0; // @[Core.scala 151:21]
  assign dt_cs_mideleg = 64'h0; // @[Core.scala 152:20]
  assign dt_cs_medeleg = 64'h0; // @[Core.scala 153:20]
  always @(posedge clock) begin
    dt_ic_io_valid_REG <= wb_io_is_nop | 32'h73 == _dt_ic_io_valid_T; // @[Core.scala 96:43]
    dt_ic_io_pc_REG <= wb_io_pc; // @[Core.scala 97:25]
    dt_ic_io_instr_REG <= wb_io_inst; // @[Core.scala 98:28]
    dt_ic_io_skip_REG <= lsu_io_lsu_to_csr_is_clint; // @[Core.scala 99:67]
    dt_ic_io_skip_REG_1 <= _dt_ic_io_skip_T_1 | wb_io_wb_to_csr_csr_addr == 12'hb00; // @[Core.scala 100:5]
    dt_ic_io_wen_REG <= wb_io_rd_en; // @[Core.scala 104:26]
    dt_ic_io_wdata_REG <= wb_io_rd_data; // @[Core.scala 105:28]
    dt_ic_io_wdest_REG <= wb_io_rd_addr; // @[Core.scala 106:28]
    dt_ae_io_intrNO_REG <= csr_io_intrNO; // @[Core.scala 111:29]
    dt_ae_io_cause_REG <= csr_io_cause; // @[Core.scala 112:28]
    dt_ae_io_exceptionPC_REG <= wb_io_pc; // @[Core.scala 113:34]
    if (reset) begin // @[Core.scala 115:26]
      cycle_cnt <= 64'h0; // @[Core.scala 115:26]
    end else begin
      cycle_cnt <= _cycle_cnt_T_1; // @[Core.scala 118:13]
    end
    if (reset) begin // @[Core.scala 116:26]
      instr_cnt <= 64'h0; // @[Core.scala 116:26]
    end else begin
      instr_cnt <= _instr_cnt_T_1; // @[Core.scala 119:13]
    end
    dt_cs_io_mstatus_REG <= csr_io_mstatus; // @[Core.scala 137:30]
    dt_cs_io_sstatus_REG <= csr_io_sstatus; // @[Core.scala 138:30]
    dt_cs_io_mepc_REG <= csr_io_mepc; // @[Core.scala 139:27]
    dt_cs_io_mtvec_REG <= csr_io_mtvec; // @[Core.scala 143:28]
    dt_cs_io_mcause_REG <= csr_io_mcause; // @[Core.scala 145:29]
    dt_cs_io_mie_REG <= csr_io_mie; // @[Core.scala 149:26]
    dt_cs_io_mscratch_REG <= csr_io_mscratch; // @[Core.scala 150:31]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  dt_ic_io_valid_REG = _RAND_0[0:0];
  _RAND_1 = {2{`RANDOM}};
  dt_ic_io_pc_REG = _RAND_1[63:0];
  _RAND_2 = {1{`RANDOM}};
  dt_ic_io_instr_REG = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  dt_ic_io_skip_REG = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  dt_ic_io_skip_REG_1 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  dt_ic_io_wen_REG = _RAND_5[0:0];
  _RAND_6 = {2{`RANDOM}};
  dt_ic_io_wdata_REG = _RAND_6[63:0];
  _RAND_7 = {1{`RANDOM}};
  dt_ic_io_wdest_REG = _RAND_7[4:0];
  _RAND_8 = {1{`RANDOM}};
  dt_ae_io_intrNO_REG = _RAND_8[31:0];
  _RAND_9 = {1{`RANDOM}};
  dt_ae_io_cause_REG = _RAND_9[31:0];
  _RAND_10 = {2{`RANDOM}};
  dt_ae_io_exceptionPC_REG = _RAND_10[63:0];
  _RAND_11 = {2{`RANDOM}};
  cycle_cnt = _RAND_11[63:0];
  _RAND_12 = {2{`RANDOM}};
  instr_cnt = _RAND_12[63:0];
  _RAND_13 = {2{`RANDOM}};
  dt_cs_io_mstatus_REG = _RAND_13[63:0];
  _RAND_14 = {2{`RANDOM}};
  dt_cs_io_sstatus_REG = _RAND_14[63:0];
  _RAND_15 = {2{`RANDOM}};
  dt_cs_io_mepc_REG = _RAND_15[63:0];
  _RAND_16 = {2{`RANDOM}};
  dt_cs_io_mtvec_REG = _RAND_16[63:0];
  _RAND_17 = {2{`RANDOM}};
  dt_cs_io_mcause_REG = _RAND_17[63:0];
  _RAND_18 = {2{`RANDOM}};
  dt_cs_io_mie_REG = _RAND_18[63:0];
  _RAND_19 = {2{`RANDOM}};
  dt_cs_io_mscratch_REG = _RAND_19[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI_RW(
  input         clock,
  input         reset,
  input         io_rw_valid_i,
  output        io_rw_ready_o,
  input         io_rw_req_i,
  output [63:0] io_data_read_o,
  input  [63:0] io_data_write_i,
  input  [63:0] io_rw_addr_i,
  input  [1:0]  io_rw_size_i,
  input  [7:0]  io_w_strb,
  input  [3:0]  io_axi_id,
  input         io_axi_aw_ready_i,
  output        io_axi_aw_valid_o,
  output [63:0] io_axi_aw_addr_o,
  output [3:0]  io_axi_aw_id_o,
  output [7:0]  io_axi_aw_len_o,
  input         io_axi_w_ready_i,
  output        io_axi_w_valid_o,
  output [63:0] io_axi_w_data_o,
  output [7:0]  io_axi_w_strb_o,
  output        io_axi_w_last_o,
  output        io_axi_b_ready_o,
  input         io_axi_b_valid_i,
  input         io_axi_ar_ready_i,
  output        io_axi_ar_valid_o,
  output [63:0] io_axi_ar_addr_o,
  output [3:0]  io_axi_ar_id_o,
  output [7:0]  io_axi_ar_len_o,
  output        io_axi_r_ready_o,
  input         io_axi_r_valid_i,
  input  [63:0] io_axi_r_data_i,
  input         io_axi_r_last_i
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [63:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  wire  r_trans = ~io_rw_req_i; // @[AXI_RW.scala 23:32]
  wire  w_valid = io_rw_valid_i & io_rw_req_i; // @[AXI_RW.scala 24:34]
  wire  r_valid = io_rw_valid_i & r_trans; // @[AXI_RW.scala 25:34]
  wire  aw_hs = io_axi_aw_ready_i & io_axi_aw_valid_o; // @[AXI_RW.scala 28:36]
  wire  w_hs = io_axi_w_ready_i & io_axi_w_valid_o; // @[AXI_RW.scala 29:35]
  wire  b_hs = io_axi_b_ready_o & io_axi_b_valid_i; // @[AXI_RW.scala 30:35]
  wire  ar_hs = io_axi_ar_ready_i & io_axi_ar_valid_o; // @[AXI_RW.scala 31:36]
  wire  r_hs = io_axi_r_ready_o & io_axi_r_valid_i; // @[AXI_RW.scala 32:35]
  wire  w_done = w_hs & io_axi_w_last_o; // @[AXI_RW.scala 34:24]
  wire  r_done = r_hs & io_axi_r_last_i; // @[AXI_RW.scala 35:24]
  wire  resp_en = io_rw_req_i ? b_hs : r_done; // @[AXI_RW.scala 36:25]
  reg [1:0] w_state; // @[AXI_RW.scala 48:26]
  reg [1:0] r_state; // @[AXI_RW.scala 49:26]
  wire  w_state_idle = w_state == 2'h0; // @[AXI_RW.scala 50:76]
  wire  r_state_idle = r_state == 2'h0; // @[AXI_RW.scala 51:62]
  wire  _T = 2'h0 == w_state; // @[Conditional.scala 37:30]
  wire  _T_1 = 2'h1 == w_state; // @[Conditional.scala 37:30]
  wire [1:0] _GEN_0 = aw_hs ? 2'h2 : w_state; // @[AXI_RW.scala 57:42 AXI_RW.scala 57:51 AXI_RW.scala 48:26]
  wire  _T_2 = 2'h2 == w_state; // @[Conditional.scala 37:30]
  wire [1:0] _GEN_1 = w_done ? 2'h3 : w_state; // @[AXI_RW.scala 58:43 AXI_RW.scala 58:52 AXI_RW.scala 48:26]
  wire  _T_3 = 2'h3 == w_state; // @[Conditional.scala 37:30]
  wire [1:0] _GEN_2 = b_hs ? 2'h0 : w_state; // @[AXI_RW.scala 59:41 AXI_RW.scala 59:50 AXI_RW.scala 48:26]
  wire [1:0] _GEN_3 = _T_3 ? _GEN_2 : w_state; // @[Conditional.scala 39:67 AXI_RW.scala 48:26]
  wire [1:0] _GEN_4 = _T_2 ? _GEN_1 : _GEN_3; // @[Conditional.scala 39:67]
  wire  _T_4 = 2'h0 == r_state; // @[Conditional.scala 37:30]
  wire  _T_5 = 2'h1 == r_state; // @[Conditional.scala 37:30]
  wire [1:0] _GEN_8 = ar_hs ? 2'h2 : r_state; // @[AXI_RW.scala 66:42 AXI_RW.scala 66:51 AXI_RW.scala 49:26]
  wire  _T_6 = 2'h2 == r_state; // @[Conditional.scala 37:30]
  wire [1:0] _GEN_9 = r_done ? 2'h0 : r_state; // @[AXI_RW.scala 67:43 AXI_RW.scala 67:51 AXI_RW.scala 49:26]
  wire [1:0] _GEN_10 = _T_6 ? _GEN_9 : r_state; // @[Conditional.scala 39:67 AXI_RW.scala 49:26]
  wire  len_reset = reset | io_rw_req_i & w_state_idle | r_trans & r_state_idle; // @[AXI_RW.scala 73:73]
  reg [7:0] len; // @[AXI_RW.scala 74:20]
  wire  aligned = io_rw_addr_i[2:0] == 3'h0; // @[AXI_RW.scala 90:74]
  wire [3:0] addr_op1_lo = io_rw_addr_i[3:0]; // @[AXI_RW.scala 96:59]
  wire [4:0] _addr_op1_T = {1'h0,addr_op1_lo}; // @[Cat.scala 30:58]
  wire [3:0] addr_op1 = _addr_op1_T[3:0];
  wire  size_b = io_rw_size_i == 2'h0; // @[AXI_RW.scala 91:39]
  wire  size_h = io_rw_size_i == 2'h1; // @[AXI_RW.scala 92:39]
  wire [3:0] _addr_op2_T_1 = size_h ? 4'h1 : 4'h0; // @[Mux.scala 27:72]
  wire  size_w = io_rw_size_i == 2'h2; // @[AXI_RW.scala 93:39]
  wire [3:0] _addr_op2_T_2 = size_w ? 4'h3 : 4'h0; // @[Mux.scala 27:72]
  wire [3:0] _addr_op2_T_5 = _addr_op2_T_1 | _addr_op2_T_2; // @[Mux.scala 27:72]
  wire  size_d = io_rw_size_i == 2'h3; // @[AXI_RW.scala 94:39]
  wire [3:0] _addr_op2_T_3 = size_d ? 4'h7 : 4'h0; // @[Mux.scala 27:72]
  wire [3:0] addr_op2 = _addr_op2_T_5 | _addr_op2_T_3; // @[Mux.scala 27:72]
  wire [3:0] addr_end = addr_op1 + addr_op2; // @[AXI_RW.scala 104:29]
  wire  overstep = addr_end[3]; // @[AXI_RW.scala 105:29]
  wire [7:0] _axi_len_T = {7'h0,overstep}; // @[Cat.scala 30:58]
  wire [7:0] axi_len = aligned ? 8'h0 : _axi_len_T; // @[AXI_RW.scala 106:19]
  wire  len_incr_en = len != axi_len & (w_hs | r_hs); // @[AXI_RW.scala 75:42]
  wire [7:0] _len_T_1 = len + 8'h1; // @[AXI_RW.scala 79:20]
  wire [60:0] axi_addr_hi = io_rw_addr_i[63:3]; // @[AXI_RW.scala 109:36]
  wire [5:0] _aligned_offset_l_T = {3'h0,io_rw_addr_i[2:0]}; // @[Cat.scala 30:58]
  wire [8:0] aligned_offset_l = {_aligned_offset_l_T, 3'h0}; // @[AXI_RW.scala 110:102]
  wire [8:0] aligned_offset_h = 9'h40 - aligned_offset_l; // @[AXI_RW.scala 111:47]
  wire [127:0] _mask_T = size_b ? 128'hff : 128'h0; // @[Mux.scala 27:72]
  wire [127:0] _mask_T_1 = size_h ? 128'hffff : 128'h0; // @[Mux.scala 27:72]
  wire [127:0] _mask_T_2 = size_w ? 128'hffffffff : 128'h0; // @[Mux.scala 27:72]
  wire [127:0] _mask_T_3 = size_d ? 128'hffffffffffffffff : 128'h0; // @[Mux.scala 27:72]
  wire [127:0] _mask_T_4 = _mask_T | _mask_T_1; // @[Mux.scala 27:72]
  wire [127:0] _mask_T_5 = _mask_T_4 | _mask_T_2; // @[Mux.scala 27:72]
  wire [127:0] _mask_T_6 = _mask_T_5 | _mask_T_3; // @[Mux.scala 27:72]
  wire [638:0] _GEN_22 = {{511'd0}, _mask_T_6}; // @[AXI_RW.scala 117:9]
  wire [638:0] mask = _GEN_22 << aligned_offset_l; // @[AXI_RW.scala 117:9]
  wire [63:0] mask_l = mask[63:0]; // @[AXI_RW.scala 119:22]
  wire [63:0] mask_h = mask[127:64]; // @[AXI_RW.scala 120:22]
  reg  rw_ready; // @[AXI_RW.scala 125:27]
  wire  rw_ready_en = resp_en | rw_ready; // @[AXI_RW.scala 128:34]
  wire [63:0] _axi_r_data_l_T = io_axi_r_data_i & mask_l; // @[AXI_RW.scala 185:38]
  wire [63:0] axi_r_data_l = _axi_r_data_l_T >> aligned_offset_l; // @[AXI_RW.scala 185:48]
  wire [63:0] _axi_r_data_h_T = io_axi_r_data_i & mask_h; // @[AXI_RW.scala 187:38]
  wire [574:0] _GEN_23 = {{511'd0}, _axi_r_data_h_T}; // @[AXI_RW.scala 187:48]
  wire [574:0] _axi_r_data_h_T_1 = _GEN_23 << aligned_offset_h; // @[AXI_RW.scala 187:48]
  reg [63:0] data_read_o; // @[AXI_RW.scala 189:30]
  wire [63:0] axi_r_data_h = _axi_r_data_h_T_1[63:0]; // @[AXI_RW.scala 186:28 AXI_RW.scala 187:18]
  wire [63:0] _data_read_o_T_1 = data_read_o | axi_r_data_h; // @[AXI_RW.scala 199:72]
  assign io_rw_ready_o = rw_ready; // @[AXI_RW.scala 132:19]
  assign io_data_read_o = data_read_o; // @[AXI_RW.scala 219:20]
  assign io_axi_aw_valid_o = w_state == 2'h1; // @[AXI_RW.scala 50:103]
  assign io_axi_aw_addr_o = {axi_addr_hi,3'h0}; // @[Cat.scala 30:58]
  assign io_axi_aw_id_o = io_axi_id; // @[AXI_RW.scala 148:23]
  assign io_axi_aw_len_o = aligned ? 8'h0 : _axi_len_T; // @[AXI_RW.scala 106:19]
  assign io_axi_w_valid_o = w_state == 2'h2; // @[AXI_RW.scala 50:130]
  assign io_axi_w_data_o = io_data_write_i; // @[AXI_RW.scala 159:23]
  assign io_axi_w_strb_o = io_w_strb; // @[AXI_RW.scala 160:23]
  assign io_axi_w_last_o = 1'h1; // @[AXI_RW.scala 161:23]
  assign io_axi_b_ready_o = w_state == 2'h3; // @[AXI_RW.scala 50:157]
  assign io_axi_ar_valid_o = r_state == 2'h1; // @[AXI_RW.scala 51:89]
  assign io_axi_ar_addr_o = {axi_addr_hi,3'h0}; // @[Cat.scala 30:58]
  assign io_axi_ar_id_o = io_axi_id; // @[AXI_RW.scala 172:23]
  assign io_axi_ar_len_o = aligned ? 8'h0 : _axi_len_T; // @[AXI_RW.scala 106:19]
  assign io_axi_r_ready_o = r_state == 2'h2; // @[AXI_RW.scala 51:116]
  always @(posedge clock) begin
    if (reset) begin // @[AXI_RW.scala 48:26]
      w_state <= 2'h0; // @[AXI_RW.scala 48:26]
    end else if (w_valid) begin // @[AXI_RW.scala 54:18]
      if (_T) begin // @[Conditional.scala 40:58]
        w_state <= 2'h1; // @[AXI_RW.scala 56:39]
      end else if (_T_1) begin // @[Conditional.scala 39:67]
        w_state <= _GEN_0;
      end else begin
        w_state <= _GEN_4;
      end
    end
    if (reset) begin // @[AXI_RW.scala 49:26]
      r_state <= 2'h0; // @[AXI_RW.scala 49:26]
    end else if (r_valid) begin // @[AXI_RW.scala 63:18]
      if (_T_4) begin // @[Conditional.scala 40:58]
        r_state <= 2'h1; // @[AXI_RW.scala 65:39]
      end else if (_T_5) begin // @[Conditional.scala 39:67]
        r_state <= _GEN_8;
      end else begin
        r_state <= _GEN_10;
      end
    end
    if (reset) begin // @[AXI_RW.scala 74:20]
      len <= 8'h0; // @[AXI_RW.scala 74:20]
    end else if (len_reset) begin // @[AXI_RW.scala 76:20]
      len <= 8'h0; // @[AXI_RW.scala 77:13]
    end else if (len_incr_en) begin // @[AXI_RW.scala 78:28]
      len <= _len_T_1; // @[AXI_RW.scala 79:13]
    end
    if (reset) begin // @[AXI_RW.scala 125:27]
      rw_ready <= 1'h0; // @[AXI_RW.scala 125:27]
    end else if (rw_ready_en) begin // @[AXI_RW.scala 129:22]
      if (io_rw_req_i) begin // @[AXI_RW.scala 36:25]
        rw_ready <= b_hs;
      end else begin
        rw_ready <= r_done;
      end
    end
    if (reset) begin // @[AXI_RW.scala 189:30]
      data_read_o <= 64'h0; // @[AXI_RW.scala 189:30]
    end else if (r_hs) begin // @[AXI_RW.scala 192:50]
      if (~aligned & overstep) begin // @[AXI_RW.scala 193:38]
        if (len[0]) begin // @[AXI_RW.scala 194:29]
          data_read_o <= _data_read_o_T_1; // @[AXI_RW.scala 199:37]
        end else begin
          data_read_o <= axi_r_data_l; // @[AXI_RW.scala 206:37]
        end
      end else if (len == 8'h0) begin // @[AXI_RW.scala 209:36]
        data_read_o <= axi_r_data_l; // @[AXI_RW.scala 214:33]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  w_state = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  r_state = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  len = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  rw_ready = _RAND_3[0:0];
  _RAND_4 = {2{`RANDOM}};
  data_read_o = _RAND_4[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module S_A_BRIDGE(
  input         clock,
  input         reset,
  input  [63:0] io_iram_addr,
  input         io_iram_addr_valid,
  input         io_iram_addr_can_send,
  output        io_iram_addr_ok,
  output        io_iram_data_ok,
  input         io_iram_using,
  output [63:0] io_iram_rdata,
  input         io_dram_wr,
  input  [1:0]  io_dram_size,
  input  [63:0] io_dram_addr,
  input  [7:0]  io_dram_wstrb,
  input  [63:0] io_dram_wdata,
  input         io_dram_addr_valid,
  output        io_dram_addr_ok,
  output        io_dram_data_ok,
  input         io_dram_using,
  output [63:0] io_dram_rdata,
  output        io_rw_valid,
  input         io_rw_ready,
  output        io_rw_req,
  input  [63:0] io_data_read,
  output [63:0] io_data_write,
  output [63:0] io_rw_addr,
  output [1:0]  io_rw_size,
  output [7:0]  io_w_strb,
  output [3:0]  io_id
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [63:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  wire  axi_hs = io_rw_valid & io_rw_ready; // @[S_A_BRIDGE.scala 25:28]
  wire  iram_hs = io_iram_data_ok & io_iram_using; // @[S_A_BRIDGE.scala 29:33]
  wire  dram_hs = io_dram_data_ok & io_dram_using; // @[S_A_BRIDGE.scala 30:33]
  reg  is_dram; // @[S_A_BRIDGE.scala 31:24]
  reg [1:0] state; // @[S_A_BRIDGE.scala 39:22]
  reg [63:0] axi_addr; // @[S_A_BRIDGE.scala 40:25]
  wire  is_addr_receive = state == 2'h0; // @[S_A_BRIDGE.scala 42:32]
  wire  is_addr_send = state == 2'h1; // @[S_A_BRIDGE.scala 43:29]
  wire  is_data_wait = state == 2'h2; // @[S_A_BRIDGE.scala 44:29]
  wire  is_data_use = state == 2'h3; // @[S_A_BRIDGE.scala 45:28]
  wire  _T = 2'h0 == state; // @[Conditional.scala 37:30]
  wire  is_dram_w = is_addr_receive & io_dram_addr_valid; // @[S_A_BRIDGE.scala 60:24]
  wire  _T_2 = is_dram_w ? io_dram_addr_ok : io_iram_addr_ok; // @[S_A_BRIDGE.scala 50:61]
  wire  _T_4 = 2'h1 == state; // @[Conditional.scala 37:30]
  wire  _T_5 = 2'h2 == state; // @[Conditional.scala 37:30]
  wire [1:0] _GEN_2 = io_rw_ready ? 2'h3 : state; // @[S_A_BRIDGE.scala 53:46 S_A_BRIDGE.scala 53:54 S_A_BRIDGE.scala 39:22]
  wire  _T_6 = 2'h3 == state; // @[Conditional.scala 37:30]
  wire  _T_7 = is_dram ? dram_hs : iram_hs; // @[S_A_BRIDGE.scala 55:17]
  wire [1:0] _GEN_3 = _T_7 ? 2'h0 : state; // @[S_A_BRIDGE.scala 55:46 S_A_BRIDGE.scala 55:54 S_A_BRIDGE.scala 39:22]
  wire [1:0] _GEN_4 = _T_6 ? _GEN_3 : state; // @[Conditional.scala 39:67 S_A_BRIDGE.scala 39:22]
  wire  _GEN_11 = io_dram_addr_valid ? 1'h0 : 1'h1; // @[S_A_BRIDGE.scala 61:30 S_A_BRIDGE.scala 67:23 S_A_BRIDGE.scala 89:23]
  wire  _GEN_15 = is_dram ? io_dram_addr_valid : io_iram_addr_valid; // @[S_A_BRIDGE.scala 107:19 S_A_BRIDGE.scala 109:19 S_A_BRIDGE.scala 127:19]
  wire  _GEN_17 = is_dram & io_dram_wr; // @[S_A_BRIDGE.scala 107:19 S_A_BRIDGE.scala 112:17 S_A_BRIDGE.scala 130:17]
  wire [63:0] _GEN_18 = is_dram ? io_data_read : 64'h0; // @[S_A_BRIDGE.scala 107:19 S_A_BRIDGE.scala 113:21 S_A_BRIDGE.scala 140:21]
  wire [63:0] _GEN_19 = is_dram ? io_dram_wdata : 64'h0; // @[S_A_BRIDGE.scala 107:19 S_A_BRIDGE.scala 114:21 S_A_BRIDGE.scala 132:21]
  wire [1:0] _GEN_21 = is_dram ? io_dram_size : 2'h2; // @[S_A_BRIDGE.scala 107:19 S_A_BRIDGE.scala 116:18 S_A_BRIDGE.scala 134:18]
  wire [7:0] _GEN_23 = is_dram ? io_dram_wstrb : 8'h0; // @[S_A_BRIDGE.scala 107:19 S_A_BRIDGE.scala 118:17 S_A_BRIDGE.scala 136:17]
  wire [63:0] _GEN_24 = is_dram ? 64'h0 : io_data_read; // @[S_A_BRIDGE.scala 107:19 S_A_BRIDGE.scala 122:21 S_A_BRIDGE.scala 131:21]
  wire  _io_rw_valid_T = io_rw_ready ? 1'h0 : io_dram_addr_valid; // @[S_A_BRIDGE.scala 145:25]
  wire  _io_rw_valid_T_1 = io_rw_ready ? 1'h0 : io_iram_addr_valid; // @[S_A_BRIDGE.scala 161:25]
  wire  _GEN_26 = is_dram ? _io_rw_valid_T : _io_rw_valid_T_1; // @[S_A_BRIDGE.scala 143:19 S_A_BRIDGE.scala 145:19 S_A_BRIDGE.scala 161:19]
  wire  _GEN_27 = is_dram ? 1'h0 : 1'h1; // @[S_A_BRIDGE.scala 177:19 S_A_BRIDGE.scala 191:23 S_A_BRIDGE.scala 197:23]
  wire  _GEN_28 = is_data_use & is_dram; // @[S_A_BRIDGE.scala 176:26 S_A_BRIDGE.scala 219:13]
  wire  _GEN_30 = is_data_use & _GEN_17; // @[S_A_BRIDGE.scala 176:26 S_A_BRIDGE.scala 220:17]
  wire [63:0] _GEN_31 = is_data_use ? _GEN_18 : 64'h0; // @[S_A_BRIDGE.scala 176:26 S_A_BRIDGE.scala 217:21]
  wire [63:0] _GEN_32 = is_data_use ? _GEN_19 : 64'h0; // @[S_A_BRIDGE.scala 176:26 S_A_BRIDGE.scala 221:21]
  wire [63:0] _GEN_33 = is_data_use ? axi_addr : 64'h0; // @[S_A_BRIDGE.scala 176:26 S_A_BRIDGE.scala 222:18]
  wire [1:0] _GEN_34 = is_data_use ? _GEN_21 : 2'h0; // @[S_A_BRIDGE.scala 176:26 S_A_BRIDGE.scala 223:18]
  wire [7:0] _GEN_36 = is_data_use ? _GEN_23 : 8'h0; // @[S_A_BRIDGE.scala 176:26 S_A_BRIDGE.scala 225:17]
  wire  _GEN_37 = is_data_use & _GEN_27; // @[S_A_BRIDGE.scala 176:26 S_A_BRIDGE.scala 213:23]
  wire [63:0] _GEN_38 = is_data_use ? _GEN_24 : 64'h0; // @[S_A_BRIDGE.scala 176:26 S_A_BRIDGE.scala 214:21]
  wire  _GEN_39 = is_data_wait ? is_dram : _GEN_28; // @[S_A_BRIDGE.scala 142:27]
  wire  _GEN_40 = is_data_wait & _GEN_26; // @[S_A_BRIDGE.scala 142:27]
  wire  _GEN_42 = is_data_wait ? 1'h0 : _GEN_28; // @[S_A_BRIDGE.scala 142:27]
  wire  _GEN_43 = is_data_wait ? _GEN_17 : _GEN_30; // @[S_A_BRIDGE.scala 142:27]
  wire [63:0] _GEN_44 = is_data_wait ? _GEN_18 : _GEN_31; // @[S_A_BRIDGE.scala 142:27]
  wire [63:0] _GEN_45 = is_data_wait ? _GEN_19 : _GEN_32; // @[S_A_BRIDGE.scala 142:27]
  wire [63:0] _GEN_46 = is_data_wait ? axi_addr : _GEN_33; // @[S_A_BRIDGE.scala 142:27]
  wire [1:0] _GEN_47 = is_data_wait ? _GEN_21 : _GEN_34; // @[S_A_BRIDGE.scala 142:27]
  wire [7:0] _GEN_49 = is_data_wait ? _GEN_23 : _GEN_36; // @[S_A_BRIDGE.scala 142:27]
  wire  _GEN_50 = is_data_wait ? 1'h0 : _GEN_37; // @[S_A_BRIDGE.scala 142:27]
  wire [63:0] _GEN_51 = is_data_wait ? _GEN_24 : _GEN_38; // @[S_A_BRIDGE.scala 142:27]
  wire  _GEN_52 = is_addr_send ? is_dram : _GEN_39; // @[S_A_BRIDGE.scala 106:28]
  wire  _GEN_53 = is_addr_send ? _GEN_15 : _GEN_40; // @[S_A_BRIDGE.scala 106:28]
  wire  _GEN_55 = is_addr_send ? 1'h0 : _GEN_42; // @[S_A_BRIDGE.scala 106:28]
  wire  _GEN_56 = is_addr_send ? _GEN_17 : _GEN_43; // @[S_A_BRIDGE.scala 106:28]
  wire [63:0] _GEN_57 = is_addr_send ? _GEN_18 : _GEN_44; // @[S_A_BRIDGE.scala 106:28]
  wire [63:0] _GEN_58 = is_addr_send ? _GEN_19 : _GEN_45; // @[S_A_BRIDGE.scala 106:28]
  wire [63:0] _GEN_59 = is_addr_send ? axi_addr : _GEN_46; // @[S_A_BRIDGE.scala 106:28]
  wire [1:0] _GEN_60 = is_addr_send ? _GEN_21 : _GEN_47; // @[S_A_BRIDGE.scala 106:28]
  wire [7:0] _GEN_62 = is_addr_send ? _GEN_23 : _GEN_49; // @[S_A_BRIDGE.scala 106:28]
  wire  _GEN_63 = is_addr_send ? 1'h0 : _GEN_50; // @[S_A_BRIDGE.scala 106:28]
  wire [63:0] _GEN_64 = is_addr_send ? _GEN_24 : _GEN_51; // @[S_A_BRIDGE.scala 106:28]
  wire  _GEN_76 = is_addr_receive ? 1'h0 : _GEN_52; // @[S_A_BRIDGE.scala 60:24]
  assign io_iram_addr_ok = is_addr_receive & _GEN_11; // @[S_A_BRIDGE.scala 60:24]
  assign io_iram_data_ok = is_addr_receive ? 1'h0 : _GEN_63; // @[S_A_BRIDGE.scala 60:24]
  assign io_iram_rdata = is_addr_receive ? 64'h0 : _GEN_64; // @[S_A_BRIDGE.scala 60:24]
  assign io_dram_addr_ok = is_addr_receive & io_dram_addr_valid; // @[S_A_BRIDGE.scala 60:24]
  assign io_dram_data_ok = is_addr_receive ? 1'h0 : _GEN_55; // @[S_A_BRIDGE.scala 60:24]
  assign io_dram_rdata = is_addr_receive ? 64'h0 : _GEN_57; // @[S_A_BRIDGE.scala 60:24]
  assign io_rw_valid = is_addr_receive ? 1'h0 : _GEN_53; // @[S_A_BRIDGE.scala 60:24]
  assign io_rw_req = is_addr_receive ? 1'h0 : _GEN_56; // @[S_A_BRIDGE.scala 60:24]
  assign io_data_write = is_addr_receive ? 64'h0 : _GEN_58; // @[S_A_BRIDGE.scala 60:24]
  assign io_rw_addr = is_addr_receive ? 64'h0 : _GEN_59; // @[S_A_BRIDGE.scala 60:24]
  assign io_rw_size = is_addr_receive ? 2'h0 : _GEN_60; // @[S_A_BRIDGE.scala 60:24]
  assign io_w_strb = is_addr_receive ? 8'h0 : _GEN_62; // @[S_A_BRIDGE.scala 60:24]
  assign io_id = {{3'd0}, _GEN_76}; // @[S_A_BRIDGE.scala 60:24]
  always @(posedge clock) begin
    if (reset) begin // @[S_A_BRIDGE.scala 31:24]
      is_dram <= 1'h0; // @[S_A_BRIDGE.scala 31:24]
    end else if (is_addr_receive) begin // @[S_A_BRIDGE.scala 60:24]
      is_dram <= io_dram_addr_valid;
    end
    if (reset) begin // @[S_A_BRIDGE.scala 39:22]
      state <= 2'h0; // @[S_A_BRIDGE.scala 39:22]
    end else if (_T) begin // @[Conditional.scala 40:58]
      if ((is_dram_w | io_iram_addr_can_send) & _T_2) begin // @[S_A_BRIDGE.scala 50:108]
        state <= 2'h1; // @[S_A_BRIDGE.scala 50:115]
      end
    end else if (_T_4) begin // @[Conditional.scala 39:67]
      if (axi_hs) begin // @[S_A_BRIDGE.scala 52:42]
        state <= 2'h2; // @[S_A_BRIDGE.scala 52:50]
      end
    end else if (_T_5) begin // @[Conditional.scala 39:67]
      state <= _GEN_2;
    end else begin
      state <= _GEN_4;
    end
    if (reset) begin // @[S_A_BRIDGE.scala 40:25]
      axi_addr <= 64'h80000000; // @[S_A_BRIDGE.scala 40:25]
    end else if (is_addr_receive) begin // @[S_A_BRIDGE.scala 60:24]
      if (io_dram_addr_valid) begin // @[S_A_BRIDGE.scala 61:30]
        axi_addr <= io_dram_addr; // @[S_A_BRIDGE.scala 65:16]
      end else begin
        axi_addr <= io_iram_addr; // @[S_A_BRIDGE.scala 87:16]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  is_dram = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  state = _RAND_1[1:0];
  _RAND_2 = {2{`RANDOM}};
  axi_addr = _RAND_2[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module SimTop(
  input         clock,
  input         reset,
  input  [63:0] io_logCtrl_log_begin,
  input  [63:0] io_logCtrl_log_end,
  input  [63:0] io_logCtrl_log_level,
  input         io_perfInfo_clean,
  input         io_perfInfo_dump,
  output        io_uart_out_valid,
  output [7:0]  io_uart_out_ch,
  output        io_uart_in_valid,
  input  [7:0]  io_uart_in_ch,
  input         io_memAXI_0_aw_ready,
  output        io_memAXI_0_aw_valid,
  output [63:0] io_memAXI_0_aw_bits_addr,
  output [2:0]  io_memAXI_0_aw_bits_prot,
  output [3:0]  io_memAXI_0_aw_bits_id,
  output        io_memAXI_0_aw_bits_user,
  output [7:0]  io_memAXI_0_aw_bits_len,
  output [2:0]  io_memAXI_0_aw_bits_size,
  output [1:0]  io_memAXI_0_aw_bits_burst,
  output        io_memAXI_0_aw_bits_lock,
  output [3:0]  io_memAXI_0_aw_bits_cache,
  output [3:0]  io_memAXI_0_aw_bits_qos,
  input         io_memAXI_0_w_ready,
  output        io_memAXI_0_w_valid,
  output [63:0] io_memAXI_0_w_bits_data[3:0],
  output [7:0]  io_memAXI_0_w_bits_strb,
  output        io_memAXI_0_w_bits_last,
  output        io_memAXI_0_b_ready,
  input         io_memAXI_0_b_valid,
  input  [1:0]  io_memAXI_0_b_bits_resp,
  input  [3:0]  io_memAXI_0_b_bits_id,
  input         io_memAXI_0_b_bits_user,
  input         io_memAXI_0_ar_ready,
  output        io_memAXI_0_ar_valid,
  output [63:0] io_memAXI_0_ar_bits_addr,
  output [2:0]  io_memAXI_0_ar_bits_prot,
  output [3:0]  io_memAXI_0_ar_bits_id,
  output        io_memAXI_0_ar_bits_user,
  output [7:0]  io_memAXI_0_ar_bits_len,
  output [2:0]  io_memAXI_0_ar_bits_size,
  output [1:0]  io_memAXI_0_ar_bits_burst,
  output        io_memAXI_0_ar_bits_lock,
  output [3:0]  io_memAXI_0_ar_bits_cache,
  output [3:0]  io_memAXI_0_ar_bits_qos,
  output        io_memAXI_0_r_ready,
  input         io_memAXI_0_r_valid,
  input  [1:0]  io_memAXI_0_r_bits_resp,
  input  [63:0] io_memAXI_0_r_bits_data[3:0],
  input         io_memAXI_0_r_bits_last,
  input  [3:0]  io_memAXI_0_r_bits_id,
  input         io_memAXI_0_r_bits_user
);
  wire  core_clock; // @[SimTop.scala 15:20]
  wire  core_reset; // @[SimTop.scala 15:20]
  wire [63:0] core_io_isram_addr; // @[SimTop.scala 15:20]
  wire  core_io_isram_addr_valid; // @[SimTop.scala 15:20]
  wire  core_io_isram_addr_can_send; // @[SimTop.scala 15:20]
  wire  core_io_isram_addr_ok; // @[SimTop.scala 15:20]
  wire  core_io_isram_data_ok; // @[SimTop.scala 15:20]
  wire  core_io_isram_using; // @[SimTop.scala 15:20]
  wire [63:0] core_io_isram_rdata; // @[SimTop.scala 15:20]
  wire  core_io_dsram_wr; // @[SimTop.scala 15:20]
  wire [1:0] core_io_dsram_size; // @[SimTop.scala 15:20]
  wire [63:0] core_io_dsram_addr; // @[SimTop.scala 15:20]
  wire [7:0] core_io_dsram_wstrb; // @[SimTop.scala 15:20]
  wire [63:0] core_io_dsram_wdata; // @[SimTop.scala 15:20]
  wire  core_io_dsram_addr_valid; // @[SimTop.scala 15:20]
  wire  core_io_dsram_data_ok; // @[SimTop.scala 15:20]
  wire  core_io_dsram_using; // @[SimTop.scala 15:20]
  wire [63:0] core_io_dsram_rdata; // @[SimTop.scala 15:20]
  wire  u_axi_rw_clock; // @[SimTop.scala 17:24]
  wire  u_axi_rw_reset; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_rw_valid_i; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_rw_ready_o; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_rw_req_i; // @[SimTop.scala 17:24]
  wire [63:0] u_axi_rw_io_data_read_o; // @[SimTop.scala 17:24]
  wire [63:0] u_axi_rw_io_data_write_i; // @[SimTop.scala 17:24]
  wire [63:0] u_axi_rw_io_rw_addr_i; // @[SimTop.scala 17:24]
  wire [1:0] u_axi_rw_io_rw_size_i; // @[SimTop.scala 17:24]
  wire [7:0] u_axi_rw_io_w_strb; // @[SimTop.scala 17:24]
  wire [3:0] u_axi_rw_io_axi_id; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_aw_ready_i; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_aw_valid_o; // @[SimTop.scala 17:24]
  wire [63:0] u_axi_rw_io_axi_aw_addr_o; // @[SimTop.scala 17:24]
  wire [3:0] u_axi_rw_io_axi_aw_id_o; // @[SimTop.scala 17:24]
  wire [7:0] u_axi_rw_io_axi_aw_len_o; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_w_ready_i; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_w_valid_o; // @[SimTop.scala 17:24]
  wire [63:0] u_axi_rw_io_axi_w_data_o; // @[SimTop.scala 17:24]
  wire [7:0] u_axi_rw_io_axi_w_strb_o; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_w_last_o; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_b_ready_o; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_b_valid_i; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_ar_ready_i; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_ar_valid_o; // @[SimTop.scala 17:24]
  wire [63:0] u_axi_rw_io_axi_ar_addr_o; // @[SimTop.scala 17:24]
  wire [3:0] u_axi_rw_io_axi_ar_id_o; // @[SimTop.scala 17:24]
  wire [7:0] u_axi_rw_io_axi_ar_len_o; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_r_ready_o; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_r_valid_i; // @[SimTop.scala 17:24]
  wire [63:0] u_axi_rw_io_axi_r_data_i; // @[SimTop.scala 17:24]
  wire  u_axi_rw_io_axi_r_last_i; // @[SimTop.scala 17:24]
  wire  s_a_brid_clock; // @[SimTop.scala 19:24]
  wire  s_a_brid_reset; // @[SimTop.scala 19:24]
  wire [63:0] s_a_brid_io_iram_addr; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_iram_addr_valid; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_iram_addr_can_send; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_iram_addr_ok; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_iram_data_ok; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_iram_using; // @[SimTop.scala 19:24]
  wire [63:0] s_a_brid_io_iram_rdata; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_dram_wr; // @[SimTop.scala 19:24]
  wire [1:0] s_a_brid_io_dram_size; // @[SimTop.scala 19:24]
  wire [63:0] s_a_brid_io_dram_addr; // @[SimTop.scala 19:24]
  wire [7:0] s_a_brid_io_dram_wstrb; // @[SimTop.scala 19:24]
  wire [63:0] s_a_brid_io_dram_wdata; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_dram_addr_valid; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_dram_addr_ok; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_dram_data_ok; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_dram_using; // @[SimTop.scala 19:24]
  wire [63:0] s_a_brid_io_dram_rdata; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_rw_valid; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_rw_ready; // @[SimTop.scala 19:24]
  wire  s_a_brid_io_rw_req; // @[SimTop.scala 19:24]
  wire [63:0] s_a_brid_io_data_read; // @[SimTop.scala 19:24]
  wire [63:0] s_a_brid_io_data_write; // @[SimTop.scala 19:24]
  wire [63:0] s_a_brid_io_rw_addr; // @[SimTop.scala 19:24]
  wire [1:0] s_a_brid_io_rw_size; // @[SimTop.scala 19:24]
  wire [7:0] s_a_brid_io_w_strb; // @[SimTop.scala 19:24]
  wire [3:0] s_a_brid_io_id; // @[SimTop.scala 19:24]
  Core core ( // @[SimTop.scala 15:20]
    .clock(core_clock),
    .reset(core_reset),
    .io_isram_addr(core_io_isram_addr),
    .io_isram_addr_valid(core_io_isram_addr_valid),
    .io_isram_addr_can_send(core_io_isram_addr_can_send),
    .io_isram_addr_ok(core_io_isram_addr_ok),
    .io_isram_data_ok(core_io_isram_data_ok),
    .io_isram_using(core_io_isram_using),
    .io_isram_rdata(core_io_isram_rdata),
    .io_dsram_wr(core_io_dsram_wr),
    .io_dsram_size(core_io_dsram_size),
    .io_dsram_addr(core_io_dsram_addr),
    .io_dsram_wstrb(core_io_dsram_wstrb),
    .io_dsram_wdata(core_io_dsram_wdata),
    .io_dsram_addr_valid(core_io_dsram_addr_valid),
    .io_dsram_data_ok(core_io_dsram_data_ok),
    .io_dsram_using(core_io_dsram_using),
    .io_dsram_rdata(core_io_dsram_rdata)
  );
  AXI_RW u_axi_rw ( // @[SimTop.scala 17:24]
    .clock(u_axi_rw_clock),
    .reset(u_axi_rw_reset),
    .io_rw_valid_i(u_axi_rw_io_rw_valid_i),
    .io_rw_ready_o(u_axi_rw_io_rw_ready_o),
    .io_rw_req_i(u_axi_rw_io_rw_req_i),
    .io_data_read_o(u_axi_rw_io_data_read_o),
    .io_data_write_i(u_axi_rw_io_data_write_i),
    .io_rw_addr_i(u_axi_rw_io_rw_addr_i),
    .io_rw_size_i(u_axi_rw_io_rw_size_i),
    .io_w_strb(u_axi_rw_io_w_strb),
    .io_axi_id(u_axi_rw_io_axi_id),
    .io_axi_aw_ready_i(u_axi_rw_io_axi_aw_ready_i),
    .io_axi_aw_valid_o(u_axi_rw_io_axi_aw_valid_o),
    .io_axi_aw_addr_o(u_axi_rw_io_axi_aw_addr_o),
    .io_axi_aw_id_o(u_axi_rw_io_axi_aw_id_o),
    .io_axi_aw_len_o(u_axi_rw_io_axi_aw_len_o),
    .io_axi_w_ready_i(u_axi_rw_io_axi_w_ready_i),
    .io_axi_w_valid_o(u_axi_rw_io_axi_w_valid_o),
    .io_axi_w_data_o(u_axi_rw_io_axi_w_data_o),
    .io_axi_w_strb_o(u_axi_rw_io_axi_w_strb_o),
    .io_axi_w_last_o(u_axi_rw_io_axi_w_last_o),
    .io_axi_b_ready_o(u_axi_rw_io_axi_b_ready_o),
    .io_axi_b_valid_i(u_axi_rw_io_axi_b_valid_i),
    .io_axi_ar_ready_i(u_axi_rw_io_axi_ar_ready_i),
    .io_axi_ar_valid_o(u_axi_rw_io_axi_ar_valid_o),
    .io_axi_ar_addr_o(u_axi_rw_io_axi_ar_addr_o),
    .io_axi_ar_id_o(u_axi_rw_io_axi_ar_id_o),
    .io_axi_ar_len_o(u_axi_rw_io_axi_ar_len_o),
    .io_axi_r_ready_o(u_axi_rw_io_axi_r_ready_o),
    .io_axi_r_valid_i(u_axi_rw_io_axi_r_valid_i),
    .io_axi_r_data_i(u_axi_rw_io_axi_r_data_i),
    .io_axi_r_last_i(u_axi_rw_io_axi_r_last_i)
  );
  S_A_BRIDGE s_a_brid ( // @[SimTop.scala 19:24]
    .clock(s_a_brid_clock),
    .reset(s_a_brid_reset),
    .io_iram_addr(s_a_brid_io_iram_addr),
    .io_iram_addr_valid(s_a_brid_io_iram_addr_valid),
    .io_iram_addr_can_send(s_a_brid_io_iram_addr_can_send),
    .io_iram_addr_ok(s_a_brid_io_iram_addr_ok),
    .io_iram_data_ok(s_a_brid_io_iram_data_ok),
    .io_iram_using(s_a_brid_io_iram_using),
    .io_iram_rdata(s_a_brid_io_iram_rdata),
    .io_dram_wr(s_a_brid_io_dram_wr),
    .io_dram_size(s_a_brid_io_dram_size),
    .io_dram_addr(s_a_brid_io_dram_addr),
    .io_dram_wstrb(s_a_brid_io_dram_wstrb),
    .io_dram_wdata(s_a_brid_io_dram_wdata),
    .io_dram_addr_valid(s_a_brid_io_dram_addr_valid),
    .io_dram_addr_ok(s_a_brid_io_dram_addr_ok),
    .io_dram_data_ok(s_a_brid_io_dram_data_ok),
    .io_dram_using(s_a_brid_io_dram_using),
    .io_dram_rdata(s_a_brid_io_dram_rdata),
    .io_rw_valid(s_a_brid_io_rw_valid),
    .io_rw_ready(s_a_brid_io_rw_ready),
    .io_rw_req(s_a_brid_io_rw_req),
    .io_data_read(s_a_brid_io_data_read),
    .io_data_write(s_a_brid_io_data_write),
    .io_rw_addr(s_a_brid_io_rw_addr),
    .io_rw_size(s_a_brid_io_rw_size),
    .io_w_strb(s_a_brid_io_w_strb),
    .io_id(s_a_brid_io_id)
  );
  assign io_uart_out_valid = 1'h0; // @[SimTop.scala 87:21]
  assign io_uart_out_ch = 8'h0; // @[SimTop.scala 88:18]
  assign io_uart_in_valid = 1'h0; // @[SimTop.scala 89:20]
  assign io_memAXI_0_aw_valid = u_axi_rw_io_axi_aw_valid_o; // @[SimTop.scala 37:24]
  assign io_memAXI_0_aw_bits_addr = u_axi_rw_io_axi_aw_addr_o; // @[SimTop.scala 38:28]
  assign io_memAXI_0_aw_bits_prot = 3'h0; // @[SimTop.scala 39:28]
  assign io_memAXI_0_aw_bits_id = u_axi_rw_io_axi_aw_id_o; // @[SimTop.scala 40:26]
  assign io_memAXI_0_aw_bits_user = 1'h0; // @[SimTop.scala 41:28]
  assign io_memAXI_0_aw_bits_len = u_axi_rw_io_axi_aw_len_o; // @[SimTop.scala 42:27]
  assign io_memAXI_0_aw_bits_size = 3'h3; // @[SimTop.scala 43:28]
  assign io_memAXI_0_aw_bits_burst = 2'h1; // @[SimTop.scala 44:29]
  assign io_memAXI_0_aw_bits_lock = 1'h0; // @[SimTop.scala 45:28]
  assign io_memAXI_0_aw_bits_cache = 4'h0; // @[SimTop.scala 46:29]
  assign io_memAXI_0_aw_bits_qos = 4'h0; // @[SimTop.scala 47:27]
  assign io_memAXI_0_w_valid = u_axi_rw_io_axi_w_valid_o; // @[SimTop.scala 51:23]
  assign io_memAXI_0_w_bits_data[0] = u_axi_rw_io_axi_w_data_o; // @[SimTop.scala 52:27]
  assign io_memAXI_0_w_bits_strb = u_axi_rw_io_axi_w_strb_o; // @[SimTop.scala 53:27]
  assign io_memAXI_0_w_bits_last = 1'h1; // @[SimTop.scala 54:27]
  assign io_memAXI_0_b_ready = u_axi_rw_io_axi_b_ready_o; // @[SimTop.scala 57:23]
  assign io_memAXI_0_ar_valid = u_axi_rw_io_axi_ar_valid_o; // @[SimTop.scala 65:24]
  assign io_memAXI_0_ar_bits_addr = u_axi_rw_io_axi_ar_addr_o; // @[SimTop.scala 66:28]
  assign io_memAXI_0_ar_bits_prot = 3'h0; // @[SimTop.scala 67:28]
  assign io_memAXI_0_ar_bits_id = u_axi_rw_io_axi_ar_id_o; // @[SimTop.scala 68:26]
  assign io_memAXI_0_ar_bits_user = 1'h0; // @[SimTop.scala 69:28]
  assign io_memAXI_0_ar_bits_len = u_axi_rw_io_axi_ar_len_o; // @[SimTop.scala 70:27]
  assign io_memAXI_0_ar_bits_size = 3'h3; // @[SimTop.scala 71:28]
  assign io_memAXI_0_ar_bits_burst = 2'h1; // @[SimTop.scala 72:29]
  assign io_memAXI_0_ar_bits_lock = 1'h0; // @[SimTop.scala 73:28]
  assign io_memAXI_0_ar_bits_cache = 4'h0; // @[SimTop.scala 74:29]
  assign io_memAXI_0_ar_bits_qos = 4'h0; // @[SimTop.scala 75:27]
  assign io_memAXI_0_r_ready = u_axi_rw_io_axi_r_ready_o; // @[SimTop.scala 78:23]
  assign core_clock = clock;
  assign core_reset = reset;
  assign core_io_isram_addr_ok = s_a_brid_io_iram_addr_ok; // @[SimTop.scala 21:17]
  assign core_io_isram_data_ok = s_a_brid_io_iram_data_ok; // @[SimTop.scala 21:17]
  assign core_io_isram_rdata = s_a_brid_io_iram_rdata; // @[SimTop.scala 21:17]
  assign core_io_dsram_data_ok = s_a_brid_io_dram_data_ok; // @[SimTop.scala 22:17]
  assign core_io_dsram_rdata = s_a_brid_io_dram_rdata; // @[SimTop.scala 22:17]
  assign u_axi_rw_clock = clock;
  assign u_axi_rw_reset = reset;
  assign u_axi_rw_io_rw_valid_i = s_a_brid_io_rw_valid; // @[SimTop.scala 24:26]
  assign u_axi_rw_io_rw_req_i = s_a_brid_io_rw_req; // @[SimTop.scala 26:24]
  assign u_axi_rw_io_data_write_i = s_a_brid_io_data_write; // @[SimTop.scala 28:28]
  assign u_axi_rw_io_rw_addr_i = s_a_brid_io_rw_addr; // @[SimTop.scala 29:25]
  assign u_axi_rw_io_rw_size_i = s_a_brid_io_rw_size; // @[SimTop.scala 30:25]
  assign u_axi_rw_io_w_strb = s_a_brid_io_w_strb; // @[SimTop.scala 32:22]
  assign u_axi_rw_io_axi_id = s_a_brid_io_id; // @[SimTop.scala 33:22]
  assign u_axi_rw_io_axi_aw_ready_i = io_memAXI_0_aw_ready; // @[SimTop.scala 36:30]
  assign u_axi_rw_io_axi_w_ready_i = io_memAXI_0_w_ready; // @[SimTop.scala 50:29]
  assign u_axi_rw_io_axi_b_valid_i = io_memAXI_0_b_valid; // @[SimTop.scala 58:29]
  assign u_axi_rw_io_axi_ar_ready_i = io_memAXI_0_ar_ready; // @[SimTop.scala 64:30]
  assign u_axi_rw_io_axi_r_valid_i = io_memAXI_0_r_valid; // @[SimTop.scala 79:29]
  assign u_axi_rw_io_axi_r_data_i = io_memAXI_0_r_bits_data[0]; // @[SimTop.scala 81:28]
  assign u_axi_rw_io_axi_r_last_i = io_memAXI_0_r_bits_last; // @[SimTop.scala 82:28]
  assign s_a_brid_clock = clock;
  assign s_a_brid_reset = reset;
  assign s_a_brid_io_iram_addr = core_io_isram_addr; // @[SimTop.scala 21:17]
  assign s_a_brid_io_iram_addr_valid = core_io_isram_addr_valid; // @[SimTop.scala 21:17]
  assign s_a_brid_io_iram_addr_can_send = core_io_isram_addr_can_send; // @[SimTop.scala 21:17]
  assign s_a_brid_io_iram_using = core_io_isram_using; // @[SimTop.scala 21:17]
  assign s_a_brid_io_dram_wr = core_io_dsram_wr; // @[SimTop.scala 22:17]
  assign s_a_brid_io_dram_size = core_io_dsram_size; // @[SimTop.scala 22:17]
  assign s_a_brid_io_dram_addr = core_io_dsram_addr; // @[SimTop.scala 22:17]
  assign s_a_brid_io_dram_wstrb = core_io_dsram_wstrb; // @[SimTop.scala 22:17]
  assign s_a_brid_io_dram_wdata = core_io_dsram_wdata; // @[SimTop.scala 22:17]
  assign s_a_brid_io_dram_addr_valid = core_io_dsram_addr_valid; // @[SimTop.scala 22:17]
  assign s_a_brid_io_dram_using = core_io_dsram_using; // @[SimTop.scala 22:17]
  assign s_a_brid_io_rw_ready = u_axi_rw_io_rw_ready_o; // @[SimTop.scala 25:24]
  assign s_a_brid_io_data_read = u_axi_rw_io_data_read_o; // @[SimTop.scala 27:25]
endmodule
