module InstFetch(
  input         clock,
  input         reset,
  output [63:0] io_imem_addr,
  input  [63:0] io_imem_rdata,
  output [63:0] io_if_to_id_pc,
  output [31:0] io_if_to_id_inst,
  input  [63:0] io_id_to_if_pc_target,
  input         io_id_to_if_jump
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [63:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg  pc_en; // @[InstFetch.scala 14:22]
  reg [63:0] pc; // @[InstFetch.scala 17:19]
  wire [63:0] _pc_T_1 = pc + 64'h4; // @[InstFetch.scala 18:57]
  assign io_imem_addr = pc; // @[InstFetch.scala 21:16]
  assign io_if_to_id_pc = pc_en ? pc : 64'h0; // @[InstFetch.scala 23:24]
  assign io_if_to_id_inst = pc_en ? io_imem_rdata[31:0] : 32'h0; // @[InstFetch.scala 24:26]
  always @(posedge clock) begin
    if (reset) begin // @[InstFetch.scala 14:22]
      pc_en <= 1'h0; // @[InstFetch.scala 14:22]
    end else begin
      pc_en <= 1'h1; // @[InstFetch.scala 15:9]
    end
    if (reset) begin // @[InstFetch.scala 17:19]
      pc <= 64'h7ffffffc; // @[InstFetch.scala 17:19]
    end else if (io_id_to_if_jump) begin // @[InstFetch.scala 18:12]
      pc <= io_id_to_if_pc_target;
    end else begin
      pc <= _pc_T_1;
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
  pc_en = _RAND_0[0:0];
  _RAND_1 = {2{`RANDOM}};
  pc = _RAND_1[63:0];
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
  input  [63:0] io_if_to_id_pc,
  input  [31:0] io_if_to_id_inst,
  output [10:0] io_id_to_ex_aluop,
  output [7:0]  io_id_to_ex_lsuop,
  output [11:0] io_id_to_ex_rv64op,
  output        io_id_to_ex_is_csr,
  output [63:0] io_id_to_ex_csr_res,
  output [63:0] io_id_to_ex_out1,
  output [63:0] io_id_to_ex_out2,
  output [63:0] io_id_to_ex_imm,
  output [4:0]  io_id_to_ex_dest,
  output        io_id_to_ex_rf_w,
  output        io_id_to_ex_load,
  output        io_id_to_ex_save,
  output [63:0] io_id_to_if_pc_target,
  output        io_id_to_if_jump,
  output [7:0]  io_id_to_csr_csrop,
  output [11:0] io_id_to_csr_csr_addr,
  output [63:0] io_id_to_csr_src1,
  output        io_id_to_csr_is_zero,
  output [63:0] io_id_to_csr_id_pc,
  input  [63:0] io_id_to_csr_csr_res,
  input         io_id_to_csr_csr_jump,
  input  [63:0] io_id_to_csr_csr_target,
  output [4:0]  io_rs1_addr,
  input  [63:0] io_rs1_data,
  output [4:0]  io_rs2_addr,
  input  [63:0] io_rs2_data
);
  wire [4:0] rd = io_if_to_id_inst[11:7]; // @[Decode.scala 61:20]
  wire [4:0] rs1 = io_if_to_id_inst[19:15]; // @[Decode.scala 63:20]
  wire [52:0] imm_i_hi = io_if_to_id_inst[31] ? 53'h1fffffffffffff : 53'h0; // @[Bitwise.scala 72:12]
  wire [10:0] imm_i_lo = io_if_to_id_inst[30:20]; // @[Decode.scala 68:43]
  wire [63:0] imm_i = {imm_i_hi,imm_i_lo}; // @[Cat.scala 30:58]
  wire [5:0] imm_s_hi_lo = io_if_to_id_inst[30:25]; // @[Decode.scala 69:41]
  wire [63:0] imm_s = {imm_i_hi,imm_s_hi_lo,rd}; // @[Cat.scala 30:58]
  wire [51:0] imm_b_hi_hi_hi = io_if_to_id_inst[31] ? 52'hfffffffffffff : 52'h0; // @[Bitwise.scala 72:12]
  wire  imm_b_hi_hi_lo = io_if_to_id_inst[7]; // @[Decode.scala 70:41]
  wire [3:0] imm_b_lo_hi = io_if_to_id_inst[11:8]; // @[Decode.scala 70:61]
  wire [63:0] imm_b = {imm_b_hi_hi_hi,imm_b_hi_hi_lo,imm_s_hi_lo,imm_b_lo_hi,1'h0}; // @[Cat.scala 30:58]
  wire [32:0] imm_u_hi_hi = io_if_to_id_inst[31] ? 33'h1ffffffff : 33'h0; // @[Bitwise.scala 72:12]
  wire [18:0] imm_u_hi_lo = io_if_to_id_inst[30:12]; // @[Decode.scala 71:41]
  wire [63:0] imm_u = {imm_u_hi_hi,imm_u_hi_lo,12'h0}; // @[Cat.scala 30:58]
  wire [43:0] imm_j_hi_hi_hi = io_if_to_id_inst[31] ? 44'hfffffffffff : 44'h0; // @[Bitwise.scala 72:12]
  wire [7:0] imm_j_hi_hi_lo = io_if_to_id_inst[19:12]; // @[Decode.scala 72:41]
  wire  imm_j_hi_lo = io_if_to_id_inst[20]; // @[Decode.scala 72:53]
  wire [3:0] imm_j_lo_hi_lo = io_if_to_id_inst[24:21]; // @[Decode.scala 72:74]
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
  wire  _ctr_signals_T_115 = 32'h7b == io_if_to_id_inst; // @[Lookup.scala 31:38]
  wire [1:0] _ctr_signals_T_173 = _ctr_signals_T_115 ? 2'h1 : 2'h0; // @[Lookup.scala 33:37]
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
  wire [1:0] _ctr_signals_T_230 = _ctr_signals_T_115 ? 2'h2 : 2'h0; // @[Lookup.scala 33:37]
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
  wire [5:0] _ctr_signals_T_287 = _ctr_signals_T_115 ? 6'h1 : 6'h0; // @[Lookup.scala 33:37]
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
  wire [4:0] _ctr_signals_T_344 = _ctr_signals_T_115 ? 5'h1 : 5'h0; // @[Lookup.scala 33:37]
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
  wire [10:0] _ctr_signals_T_401 = _ctr_signals_T_115 ? 11'h1 : 11'h0; // @[Lookup.scala 33:37]
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
  wire [63:0] _io_id_to_ex_out1_T_4 = ctr_signals_1[0] ? io_rs1_data : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _io_id_to_ex_out1_T_5 = ctr_signals_1[1] ? io_if_to_id_pc : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _io_id_to_ex_out2_T_4 = ctr_signals_2[0] ? io_rs2_data : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _io_id_to_ex_out2_T_5 = ctr_signals_2[1] ? imm : 64'h0; // @[Mux.scala 27:72]
  wire  load = ctr_signals_7[0] | ctr_signals_7[1] | ctr_signals_7[2] | ctr_signals_7[3] | ctr_signals_7[4] |
    ctr_signals_8[9] | ctr_signals_8[10]; // @[Mux.scala 27:72]
  wire  save = ctr_signals_7[5] | ctr_signals_7[6] | ctr_signals_7[7] | ctr_signals_8[11]; // @[Mux.scala 27:72]
  wire  is_br = bruop[2] | bruop[3] | bruop[4] | bruop[5] | bruop[6] | bruop[7]; // @[Mux.scala 27:72]
  wire [63:0] jal_target = io_if_to_id_pc + imm_j; // @[Decode.scala 244:25]
  wire [63:0] jalr_target = io_rs1_data + imm_i; // @[Decode.scala 245:32]
  wire [63:0] br_target = io_if_to_id_pc + imm_b; // @[Decode.scala 246:24]
  wire  _jump_T_5 = bruop[3] & io_rs1_data == io_rs2_data; // @[Decode.scala 257:14]
  wire  _jump_T_6 = bruop[2] & io_rs1_data != io_rs2_data | _jump_T_5; // @[Decode.scala 256:43]
  wire  _jump_T_10 = bruop[4] & $signed(io_rs1_data) < $signed(io_rs2_data); // @[Decode.scala 258:14]
  wire  _jump_T_11 = _jump_T_6 | _jump_T_10; // @[Decode.scala 257:43]
  wire  _jump_T_13 = bruop[6] & io_rs1_data < io_rs2_data; // @[Decode.scala 259:15]
  wire  _jump_T_14 = _jump_T_11 | _jump_T_13; // @[Decode.scala 258:59]
  wire  _jump_T_18 = bruop[5] & $signed(io_rs1_data) >= $signed(io_rs2_data); // @[Decode.scala 260:14]
  wire  _jump_T_19 = _jump_T_14 | _jump_T_18; // @[Decode.scala 259:59]
  wire  _jump_T_21 = bruop[7] & io_rs1_data >= io_rs2_data; // @[Decode.scala 261:15]
  wire  _jump_T_22 = _jump_T_19 | _jump_T_21; // @[Decode.scala 260:60]
  wire  jump = bruop[0] | bruop[1] | io_id_to_csr_csr_jump | _jump_T_22; // @[Decode.scala 255:48]
  wire  _pc_target_T_1 = is_br & ~jump; // @[Decode.scala 268:14]
  wire [63:0] _pc_target_T_2 = bruop[0] ? jal_target : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_3 = bruop[1] ? jalr_target : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_4 = is_br ? br_target : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_5 = _pc_target_T_1 ? 64'h80000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_6 = _pc_target_T_2 | _pc_target_T_3; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_7 = _pc_target_T_6 | _pc_target_T_4; // @[Mux.scala 27:72]
  wire [63:0] _pc_target_T_8 = _pc_target_T_7 | _pc_target_T_5; // @[Mux.scala 27:72]
  wire  _io_id_to_ex_rf_w_T_3 = ~io_id_to_csr_csr_jump; // @[Decode.scala 272:44]
  wire  is_csr = ctr_signals_4 == 5'h10; // @[Decode.scala 289:26]
  wire  _is_zimm_T = ~is_csr; // @[Decode.scala 291:7]
  wire  _is_zimm_T_4 = csrop == 8'h4; // @[Decode.scala 295:14]
  wire  _is_zimm_T_5 = csrop == 8'h5; // @[Decode.scala 296:14]
  wire  _is_zimm_T_6 = csrop == 8'h6; // @[Decode.scala 297:14]
  wire  is_zimm = _is_zimm_T_4 | _is_zimm_T_5 | _is_zimm_T_6; // @[Mux.scala 27:72]
  wire [63:0] _io_id_to_csr_src1_T = {59'h0,rs1}; // @[Cat.scala 30:58]
  assign io_id_to_ex_aluop = _ctr_signals_T_1 ? 11'h1 : _ctr_signals_T_457; // @[Lookup.scala 33:37]
  assign io_id_to_ex_lsuop = _ctr_signals_T_1 ? 8'h0 : _ctr_signals_T_571; // @[Lookup.scala 33:37]
  assign io_id_to_ex_rv64op = _ctr_signals_T_1 ? 12'h0 : _ctr_signals_T_628; // @[Lookup.scala 33:37]
  assign io_id_to_ex_is_csr = ctr_signals_4 == 5'h10; // @[Decode.scala 304:35]
  assign io_id_to_ex_csr_res = io_id_to_csr_csr_res; // @[Decode.scala 305:25]
  assign io_id_to_ex_out1 = _io_id_to_ex_out1_T_4 | _io_id_to_ex_out1_T_5; // @[Mux.scala 27:72]
  assign io_id_to_ex_out2 = _io_id_to_ex_out2_T_4 | _io_id_to_ex_out2_T_5; // @[Mux.scala 27:72]
  assign io_id_to_ex_imm = _imm_T_18 | _imm_T_13; // @[Mux.scala 27:72]
  assign io_id_to_ex_dest = _ctr_signals_T_115 ? 5'h0 : rd; // @[Decode.scala 196:28]
  assign io_id_to_ex_rf_w = ~save & ~is_br & ~io_id_to_csr_csr_jump; // @[Decode.scala 272:41]
  assign io_id_to_ex_load = load & _io_id_to_ex_rf_w_T_3; // @[Decode.scala 273:30]
  assign io_id_to_ex_save = save & _io_id_to_ex_rf_w_T_3; // @[Decode.scala 274:30]
  assign io_id_to_if_pc_target = io_id_to_csr_csr_jump ? io_id_to_csr_csr_target : _pc_target_T_8; // @[Decode.scala 263:24]
  assign io_id_to_if_jump = bruop[0] | bruop[1] | io_id_to_csr_csr_jump | _jump_T_22; // @[Decode.scala 255:48]
  assign io_id_to_csr_csrop = _ctr_signals_T_1 ? 8'h0 : _ctr_signals_T_685; // @[Lookup.scala 33:37]
  assign io_id_to_csr_csr_addr = is_csr ? io_if_to_id_inst[31:20] : 12'h0; // @[Decode.scala 301:33]
  assign io_id_to_csr_src1 = is_zimm ? _io_id_to_csr_src1_T : io_rs1_data; // @[Decode.scala 300:29]
  assign io_id_to_csr_is_zero = rs1 == 5'h0 | _is_zimm_T; // @[Decode.scala 302:44]
  assign io_id_to_csr_id_pc = io_if_to_id_pc; // @[Decode.scala 59:22]
  assign io_rs1_addr = _ctr_signals_T_115 ? 5'ha : rs1; // @[Decode.scala 162:23]
  assign io_rs2_addr = io_if_to_id_inst[24:20]; // @[Decode.scala 64:20]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_ctr_signals_T_115 & ~reset) begin
          $fwrite(32'h80000002,"%c",io_rs1_data); // @[Decode.scala 285:13]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module Execution(
  input  [10:0] io_id_to_ex_aluop,
  input  [7:0]  io_id_to_ex_lsuop,
  input  [11:0] io_id_to_ex_rv64op,
  input         io_id_to_ex_is_csr,
  input  [63:0] io_id_to_ex_csr_res,
  input  [63:0] io_id_to_ex_out1,
  input  [63:0] io_id_to_ex_out2,
  input  [63:0] io_id_to_ex_imm,
  input  [4:0]  io_id_to_ex_dest,
  input         io_id_to_ex_rf_w,
  input         io_id_to_ex_load,
  input         io_id_to_ex_save,
  output        io_ex_to_lsu_is_csr,
  output [63:0] io_ex_to_lsu_csr_res,
  output [63:0] io_ex_to_lsu_alu_res,
  output [63:0] io_ex_to_lsu_src1,
  output [63:0] io_ex_to_lsu_src2,
  output [63:0] io_ex_to_lsu_imm,
  output [7:0]  io_ex_to_lsu_lsuop,
  output [11:0] io_ex_to_lsu_rv64op,
  output [4:0]  io_ex_to_lsu_dest,
  output        io_ex_to_lsu_rf_w,
  output        io_ex_to_lsu_load,
  output        io_ex_to_lsu_save
);
  wire  is_w = io_id_to_ex_rv64op[0] | io_id_to_ex_rv64op[1] | io_id_to_ex_rv64op[2] | io_id_to_ex_rv64op[3] |
    io_id_to_ex_rv64op[4] | io_id_to_ex_rv64op[5] | io_id_to_ex_rv64op[6] | io_id_to_ex_rv64op[7] | io_id_to_ex_rv64op[8
    ]; // @[Mux.scala 27:72]
  wire [31:0] src1_32 = io_id_to_ex_out1[31:0]; // @[Execution.scala 68:24]
  wire [31:0] lui_res_32 = io_id_to_ex_out2[31:0]; // @[Execution.scala 69:24]
  wire  i_add = io_id_to_ex_aluop[0]; // @[Execution.scala 71:20]
  wire  i_slt = io_id_to_ex_aluop[1]; // @[Execution.scala 72:20]
  wire  i_sltu = io_id_to_ex_aluop[2]; // @[Execution.scala 73:21]
  wire  i_and = io_id_to_ex_aluop[3]; // @[Execution.scala 74:20]
  wire  i_or = io_id_to_ex_aluop[4]; // @[Execution.scala 75:19]
  wire  i_xor = io_id_to_ex_aluop[5]; // @[Execution.scala 76:20]
  wire  i_sll = io_id_to_ex_aluop[6]; // @[Execution.scala 77:20]
  wire  i_srl = io_id_to_ex_aluop[7]; // @[Execution.scala 78:20]
  wire  i_sra = io_id_to_ex_aluop[8]; // @[Execution.scala 79:20]
  wire  i_lui = io_id_to_ex_aluop[9]; // @[Execution.scala 80:20]
  wire  i_sub = io_id_to_ex_aluop[10]; // @[Execution.scala 81:20]
  wire [63:0] add_res_64 = io_id_to_ex_out1 + io_id_to_ex_out2; // @[Execution.scala 83:28]
  wire [63:0] slt_res_64 = $signed(io_id_to_ex_out1) < $signed(io_id_to_ex_out2) ? 64'h1 : 64'h0; // @[Execution.scala 86:9]
  wire [63:0] sltu_res_64 = io_id_to_ex_out1 < io_id_to_ex_out2 ? 64'h1 : 64'h0; // @[Execution.scala 88:24]
  wire [63:0] and_res_64 = io_id_to_ex_out1 & io_id_to_ex_out2; // @[Execution.scala 90:28]
  wire [63:0] or_res_64 = io_id_to_ex_out1 | io_id_to_ex_out2; // @[Execution.scala 92:27]
  wire [63:0] xor_res_64 = io_id_to_ex_out1 ^ io_id_to_ex_out2; // @[Execution.scala 94:28]
  wire [63:0] sub_res_64 = io_id_to_ex_out1 - io_id_to_ex_out2; // @[Execution.scala 98:28]
  wire [126:0] _GEN_0 = {{63'd0}, io_id_to_ex_out1}; // @[Execution.scala 101:37]
  wire [126:0] sll_res_64 = _GEN_0 << io_id_to_ex_out2[5:0]; // @[Execution.scala 101:37]
  wire [62:0] _GEN_1 = {{31'd0}, src1_32}; // @[Execution.scala 102:37]
  wire [62:0] sll_res_32 = _GEN_1 << lui_res_32[4:0]; // @[Execution.scala 102:37]
  wire [63:0] srl_res_64 = io_id_to_ex_out1 >> io_id_to_ex_out2[5:0]; // @[Execution.scala 105:37]
  wire [31:0] srl_res_32 = src1_32 >> lui_res_32[4:0]; // @[Execution.scala 106:37]
  wire [63:0] sra_res_64 = $signed(io_id_to_ex_out1) >>> io_id_to_ex_out2[5:0]; // @[Execution.scala 109:62]
  wire [31:0] _sra_res_32_T = io_id_to_ex_out1[31:0]; // @[Execution.scala 110:35]
  wire [31:0] sra_res_32 = $signed(_sra_res_32_T) >>> lui_res_32[4:0]; // @[Execution.scala 110:62]
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
  wire [31:0] add_res_32 = src1_32 + lui_res_32; // @[Execution.scala 130:28]
  wire [31:0] _slt_res_32_T_1 = io_id_to_ex_out2[31:0]; // @[Execution.scala 133:43]
  wire [31:0] slt_res_32 = $signed(_sra_res_32_T) < $signed(_slt_res_32_T_1) ? 32'h1 : 32'h0; // @[Execution.scala 133:9]
  wire [31:0] sltu_res_32 = src1_32 < lui_res_32 ? 32'h1 : 32'h0; // @[Execution.scala 135:24]
  wire [31:0] and_res_32 = src1_32 & lui_res_32; // @[Execution.scala 137:28]
  wire [31:0] or_res_32 = src1_32 | lui_res_32; // @[Execution.scala 139:27]
  wire [31:0] xor_res_32 = src1_32 ^ lui_res_32; // @[Execution.scala 141:28]
  wire [31:0] sub_res_32 = src1_32 - lui_res_32; // @[Execution.scala 145:28]
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
  wire [31:0] alu_res_lo = alu_res_32[31:0]; // @[Execution.scala 165:55]
  wire [63:0] _alu_res_T_2 = {alu_res_hi,alu_res_lo}; // @[Cat.scala 30:58]
  wire [126:0] alu_res = is_w ? {{63'd0}, _alu_res_T_2} : alu_res_64; // @[Execution.scala 165:8]
  assign io_ex_to_lsu_is_csr = io_id_to_ex_is_csr; // @[Execution.scala 43:23]
  assign io_ex_to_lsu_csr_res = io_id_to_ex_csr_res; // @[Execution.scala 44:24]
  assign io_ex_to_lsu_alu_res = alu_res[63:0]; // @[Execution.scala 167:24]
  assign io_ex_to_lsu_src1 = io_id_to_ex_out1; // @[Execution.scala 46:21]
  assign io_ex_to_lsu_src2 = io_id_to_ex_out2; // @[Execution.scala 47:21]
  assign io_ex_to_lsu_imm = io_id_to_ex_imm; // @[Execution.scala 48:20]
  assign io_ex_to_lsu_lsuop = io_id_to_ex_lsuop; // @[Execution.scala 36:22]
  assign io_ex_to_lsu_rv64op = io_id_to_ex_rv64op; // @[Execution.scala 37:23]
  assign io_ex_to_lsu_dest = io_id_to_ex_dest; // @[Execution.scala 38:21]
  assign io_ex_to_lsu_rf_w = io_id_to_ex_rf_w; // @[Execution.scala 39:21]
  assign io_ex_to_lsu_load = io_id_to_ex_load; // @[Execution.scala 40:21]
  assign io_ex_to_lsu_save = io_id_to_ex_save; // @[Execution.scala 41:21]
endmodule
module LSU(
  input         io_ex_to_lsu_is_csr,
  input  [63:0] io_ex_to_lsu_csr_res,
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
  output [63:0] io_lsu_to_wb_lsu_res,
  output [4:0]  io_lsu_to_wb_dest,
  output        io_lsu_to_wb_rf_w,
  output        io_lsu_to_csr_is_clint,
  output        io_lsu_to_csr_is_mtime,
  output        io_lsu_to_csr_is_mtimecmp,
  output        io_lsu_to_csr_load,
  output        io_lsu_to_csr_save,
  output [63:0] io_lsu_to_csr_wdata,
  input  [63:0] io_lsu_to_csr_rdata,
  output        io_dmem_en,
  output [63:0] io_dmem_addr,
  input  [63:0] io_dmem_rdata,
  output [63:0] io_dmem_wdata,
  output [63:0] io_dmem_wmask,
  output        io_dmem_wen
);
  wire  i_lb = io_ex_to_lsu_lsuop[0]; // @[LSU.scala 45:19]
  wire  i_lh = io_ex_to_lsu_lsuop[1]; // @[LSU.scala 46:19]
  wire  i_lw = io_ex_to_lsu_lsuop[2]; // @[LSU.scala 47:19]
  wire  i_lbu = io_ex_to_lsu_lsuop[3]; // @[LSU.scala 48:20]
  wire  i_lhu = io_ex_to_lsu_lsuop[4]; // @[LSU.scala 49:20]
  wire  i_sb = io_ex_to_lsu_lsuop[5]; // @[LSU.scala 50:19]
  wire  i_sh = io_ex_to_lsu_lsuop[6]; // @[LSU.scala 51:19]
  wire  i_sw = io_ex_to_lsu_lsuop[7]; // @[LSU.scala 52:19]
  wire  i_lwu = io_ex_to_lsu_rv64op[9]; // @[LSU.scala 54:21]
  wire  i_ld = io_ex_to_lsu_rv64op[10]; // @[LSU.scala 55:20]
  wire  i_sd = io_ex_to_lsu_rv64op[11]; // @[LSU.scala 56:20]
  wire  _addr_real_T = io_ex_to_lsu_load | io_ex_to_lsu_save; // @[LSU.scala 59:11]
  wire [63:0] _addr_real_T_2 = io_ex_to_lsu_src1 + io_ex_to_lsu_imm; // @[LSU.scala 60:10]
  wire [63:0] addr_real = _addr_real_T ? _addr_real_T_2 : 64'h80000000; // @[LSU.scala 58:22]
  wire  sel_b = addr_real[0]; // @[LSU.scala 64:22]
  wire  sel_h = addr_real[1]; // @[LSU.scala 65:22]
  wire  sel_w = addr_real[2]; // @[LSU.scala 66:22]
  wire  _wmask_T_1 = ~sel_w; // @[LSU.scala 73:16]
  wire  _wmask_T_2 = i_sw & ~sel_w; // @[LSU.scala 73:13]
  wire  _wmask_T_3 = i_sw & sel_w; // @[LSU.scala 74:13]
  wire  _wmask_T_5 = ~sel_h; // @[LSU.scala 76:27]
  wire  _wmask_T_6 = _wmask_T_1 & ~sel_h; // @[LSU.scala 76:24]
  wire  _wmask_T_7 = i_sh & (_wmask_T_1 & ~sel_h); // @[LSU.scala 76:13]
  wire  _wmask_T_9 = _wmask_T_1 & sel_h; // @[LSU.scala 77:24]
  wire  _wmask_T_10 = i_sh & (_wmask_T_1 & sel_h); // @[LSU.scala 77:13]
  wire  _wmask_T_12 = sel_w & _wmask_T_5; // @[LSU.scala 78:24]
  wire  _wmask_T_13 = i_sh & (sel_w & _wmask_T_5); // @[LSU.scala 78:13]
  wire  _wmask_T_14 = sel_w & sel_h; // @[LSU.scala 79:24]
  wire  _wmask_T_15 = i_sh & (sel_w & sel_h); // @[LSU.scala 79:13]
  wire  _wmask_T_19 = ~sel_b; // @[LSU.scala 81:37]
  wire  _wmask_T_20 = _wmask_T_6 & ~sel_b; // @[LSU.scala 81:34]
  wire  _wmask_T_21 = i_sb & (_wmask_T_6 & ~sel_b); // @[LSU.scala 81:13]
  wire  _wmask_T_25 = _wmask_T_6 & sel_b; // @[LSU.scala 82:34]
  wire  _wmask_T_26 = i_sb & (_wmask_T_6 & sel_b); // @[LSU.scala 82:13]
  wire  _wmask_T_30 = _wmask_T_9 & _wmask_T_19; // @[LSU.scala 83:34]
  wire  _wmask_T_31 = i_sb & (_wmask_T_9 & _wmask_T_19); // @[LSU.scala 83:13]
  wire  _wmask_T_34 = _wmask_T_9 & sel_b; // @[LSU.scala 84:34]
  wire  _wmask_T_35 = i_sb & (_wmask_T_9 & sel_b); // @[LSU.scala 84:13]
  wire  _wmask_T_39 = _wmask_T_12 & _wmask_T_19; // @[LSU.scala 85:34]
  wire  _wmask_T_40 = i_sb & (_wmask_T_12 & _wmask_T_19); // @[LSU.scala 85:13]
  wire  _wmask_T_43 = _wmask_T_12 & sel_b; // @[LSU.scala 86:34]
  wire  _wmask_T_44 = i_sb & (_wmask_T_12 & sel_b); // @[LSU.scala 86:13]
  wire  _wmask_T_47 = _wmask_T_14 & _wmask_T_19; // @[LSU.scala 87:34]
  wire  _wmask_T_48 = i_sb & (_wmask_T_14 & _wmask_T_19); // @[LSU.scala 87:13]
  wire  _wmask_T_50 = _wmask_T_14 & sel_b; // @[LSU.scala 88:34]
  wire  _wmask_T_51 = i_sb & (_wmask_T_14 & sel_b); // @[LSU.scala 88:13]
  wire [63:0] _wmask_T_53 = i_sd ? 64'hffffffffffffffff : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_54 = _wmask_T_2 ? 64'hffffffff : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_55 = _wmask_T_3 ? 64'hffffffff00000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_56 = _wmask_T_7 ? 64'hffff : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_57 = _wmask_T_10 ? 64'hffff0000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_58 = _wmask_T_13 ? 64'hffff00000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_59 = _wmask_T_15 ? 64'hffff000000000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_60 = _wmask_T_21 ? 64'hff : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_61 = _wmask_T_26 ? 64'hff00 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_62 = _wmask_T_31 ? 64'hff0000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_63 = _wmask_T_35 ? 64'hff000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_64 = _wmask_T_40 ? 64'hff00000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_65 = _wmask_T_44 ? 64'hff0000000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_66 = _wmask_T_48 ? 64'hff000000000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_67 = _wmask_T_51 ? 64'hff00000000000000 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_69 = _wmask_T_53 | _wmask_T_54; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_70 = _wmask_T_69 | _wmask_T_55; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_71 = _wmask_T_70 | _wmask_T_56; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_72 = _wmask_T_71 | _wmask_T_57; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_73 = _wmask_T_72 | _wmask_T_58; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_74 = _wmask_T_73 | _wmask_T_59; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_75 = _wmask_T_74 | _wmask_T_60; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_76 = _wmask_T_75 | _wmask_T_61; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_77 = _wmask_T_76 | _wmask_T_62; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_78 = _wmask_T_77 | _wmask_T_63; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_79 = _wmask_T_78 | _wmask_T_64; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_80 = _wmask_T_79 | _wmask_T_65; // @[Mux.scala 27:72]
  wire [63:0] _wmask_T_81 = _wmask_T_80 | _wmask_T_66; // @[Mux.scala 27:72]
  wire [31:0] sdata_hi = io_ex_to_lsu_src2[31:0]; // @[LSU.scala 96:30]
  wire [63:0] _sdata_T_1 = {sdata_hi,sdata_hi}; // @[Cat.scala 30:58]
  wire [15:0] sdata_hi_1 = io_ex_to_lsu_src2[15:0]; // @[LSU.scala 97:30]
  wire [63:0] _sdata_T_2 = {sdata_hi_1,sdata_hi_1,sdata_hi_1,sdata_hi_1}; // @[Cat.scala 30:58]
  wire [7:0] sdata_hi_3 = io_ex_to_lsu_src2[7:0]; // @[LSU.scala 98:30]
  wire [63:0] _sdata_T_3 = {sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3,sdata_hi_3}; // @[Cat.scala 30:58]
  wire [63:0] _sdata_T_5 = i_sd ? io_ex_to_lsu_src2 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_6 = i_sw ? _sdata_T_1 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_7 = i_sh ? _sdata_T_2 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_8 = i_sb ? _sdata_T_3 : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_10 = _sdata_T_5 | _sdata_T_6; // @[Mux.scala 27:72]
  wire [63:0] _sdata_T_11 = _sdata_T_10 | _sdata_T_7; // @[Mux.scala 27:72]
  wire  is_mtime = addr_real == 64'h200bff8; // @[LSU.scala 102:29]
  wire  is_mtimecmp = addr_real == 64'h2004000; // @[LSU.scala 103:32]
  wire  is_clint = is_mtime | is_mtimecmp; // @[LSU.scala 104:27]
  wire [60:0] io_dmem_addr_hi = addr_real[63:3]; // @[LSU.scala 109:32]
  wire  _rdata_T_1 = i_lw | i_lwu; // @[LSU.scala 119:14]
  wire  _rdata_T_3 = (i_lw | i_lwu) & _wmask_T_1; // @[LSU.scala 119:24]
  wire [31:0] rdata_lo = io_dmem_rdata[31:0]; // @[LSU.scala 119:57]
  wire [63:0] _rdata_T_4 = {32'h0,rdata_lo}; // @[Cat.scala 30:58]
  wire  _rdata_T_6 = _rdata_T_1 & sel_w; // @[LSU.scala 120:24]
  wire [31:0] rdata_lo_1 = io_dmem_rdata[63:32]; // @[LSU.scala 120:57]
  wire [63:0] _rdata_T_7 = {32'h0,rdata_lo_1}; // @[Cat.scala 30:58]
  wire  _rdata_T_8 = i_lh | i_lhu; // @[LSU.scala 122:14]
  wire  _rdata_T_12 = (i_lh | i_lhu) & _wmask_T_6; // @[LSU.scala 122:24]
  wire [15:0] rdata_lo_2 = io_dmem_rdata[15:0]; // @[LSU.scala 122:69]
  wire [63:0] _rdata_T_13 = {48'h0,rdata_lo_2}; // @[Cat.scala 30:58]
  wire  _rdata_T_17 = _rdata_T_8 & _wmask_T_9; // @[LSU.scala 123:24]
  wire [15:0] rdata_lo_3 = io_dmem_rdata[31:16]; // @[LSU.scala 123:69]
  wire [63:0] _rdata_T_18 = {48'h0,rdata_lo_3}; // @[Cat.scala 30:58]
  wire  _rdata_T_22 = _rdata_T_8 & _wmask_T_12; // @[LSU.scala 124:24]
  wire [15:0] rdata_lo_4 = io_dmem_rdata[47:32]; // @[LSU.scala 124:69]
  wire [63:0] _rdata_T_23 = {48'h0,rdata_lo_4}; // @[Cat.scala 30:58]
  wire  _rdata_T_26 = _rdata_T_8 & _wmask_T_14; // @[LSU.scala 125:24]
  wire [15:0] rdata_lo_5 = io_dmem_rdata[63:48]; // @[LSU.scala 125:69]
  wire [63:0] _rdata_T_27 = {48'h0,rdata_lo_5}; // @[Cat.scala 30:58]
  wire  _rdata_T_28 = i_lb | i_lbu; // @[LSU.scala 127:13]
  wire  _rdata_T_34 = (i_lb | i_lbu) & _wmask_T_20; // @[LSU.scala 127:23]
  wire [7:0] rdata_lo_6 = io_dmem_rdata[7:0]; // @[LSU.scala 127:78]
  wire [63:0] _rdata_T_35 = {56'h0,rdata_lo_6}; // @[Cat.scala 30:58]
  wire  _rdata_T_41 = _rdata_T_28 & _wmask_T_25; // @[LSU.scala 128:23]
  wire [7:0] rdata_lo_7 = io_dmem_rdata[15:8]; // @[LSU.scala 128:78]
  wire [63:0] _rdata_T_42 = {56'h0,rdata_lo_7}; // @[Cat.scala 30:58]
  wire  _rdata_T_48 = _rdata_T_28 & _wmask_T_30; // @[LSU.scala 129:23]
  wire [7:0] rdata_lo_8 = io_dmem_rdata[23:16]; // @[LSU.scala 129:78]
  wire [63:0] _rdata_T_49 = {56'h0,rdata_lo_8}; // @[Cat.scala 30:58]
  wire  _rdata_T_54 = _rdata_T_28 & _wmask_T_34; // @[LSU.scala 130:23]
  wire [7:0] rdata_lo_9 = io_dmem_rdata[31:24]; // @[LSU.scala 130:78]
  wire [63:0] _rdata_T_55 = {56'h0,rdata_lo_9}; // @[Cat.scala 30:58]
  wire  _rdata_T_61 = _rdata_T_28 & _wmask_T_39; // @[LSU.scala 131:23]
  wire [7:0] rdata_lo_10 = io_dmem_rdata[39:32]; // @[LSU.scala 131:78]
  wire [63:0] _rdata_T_62 = {56'h0,rdata_lo_10}; // @[Cat.scala 30:58]
  wire  _rdata_T_67 = _rdata_T_28 & _wmask_T_43; // @[LSU.scala 132:23]
  wire [7:0] rdata_lo_11 = io_dmem_rdata[47:40]; // @[LSU.scala 132:78]
  wire [63:0] _rdata_T_68 = {56'h0,rdata_lo_11}; // @[Cat.scala 30:58]
  wire  _rdata_T_73 = _rdata_T_28 & _wmask_T_47; // @[LSU.scala 133:23]
  wire [7:0] rdata_lo_12 = io_dmem_rdata[55:48]; // @[LSU.scala 133:78]
  wire [63:0] _rdata_T_74 = {56'h0,rdata_lo_12}; // @[Cat.scala 30:58]
  wire  _rdata_T_78 = _rdata_T_28 & _wmask_T_50; // @[LSU.scala 134:23]
  wire [7:0] rdata_lo_13 = io_dmem_rdata[63:56]; // @[LSU.scala 134:78]
  wire [63:0] _rdata_T_79 = {56'h0,rdata_lo_13}; // @[Cat.scala 30:58]
  wire [63:0] _rdata_T_81 = i_ld ? io_dmem_rdata : 64'h0; // @[Mux.scala 27:72]
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
  wire [31:0] lw_res_lo = ld_res[31:0]; // @[LSU.scala 139:46]
  wire [63:0] lw_res = {lw_res_hi,lw_res_lo}; // @[Cat.scala 30:58]
  wire [63:0] lwu_res = {32'h0,lw_res_lo}; // @[Cat.scala 30:58]
  wire [47:0] lh_res_hi = ld_res[15] ? 48'hffffffffffff : 48'h0; // @[Bitwise.scala 72:12]
  wire [15:0] lh_res_lo = ld_res[15:0]; // @[LSU.scala 141:46]
  wire [63:0] lh_res = {lh_res_hi,lh_res_lo}; // @[Cat.scala 30:58]
  wire [16:0] lhu_res = {1'h0,lh_res_lo}; // @[Cat.scala 30:58]
  wire [55:0] lb_res_hi = ld_res[7] ? 56'hffffffffffffff : 56'h0; // @[Bitwise.scala 72:12]
  wire [7:0] lb_res_lo = ld_res[7:0]; // @[LSU.scala 143:45]
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
  wire [63:0] _GEN_0 = {{47'd0}, _load_res_T_6}; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_13 = _load_res_T_12 | _GEN_0; // @[Mux.scala 27:72]
  wire [63:0] _load_res_T_14 = _load_res_T_13 | _load_res_T_7; // @[Mux.scala 27:72]
  wire [63:0] load_res = _load_res_T_14 | _load_res_T_8; // @[Mux.scala 27:72]
  wire  _lsu_res_T_1 = ~(io_ex_to_lsu_save | io_ex_to_lsu_load); // @[LSU.scala 161:7]
  wire [63:0] _lsu_res_T_2 = _lsu_res_T_1 ? io_ex_to_lsu_alu_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] _lsu_res_T_4 = io_ex_to_lsu_load ? load_res : 64'h0; // @[Mux.scala 27:72]
  wire [63:0] lsu_res = _lsu_res_T_2 | _lsu_res_T_4; // @[Mux.scala 27:72]
  wire [63:0] _io_lsu_to_wb_lsu_res_T = is_clint ? io_lsu_to_csr_rdata : lsu_res; // @[LSU.scala 167:49]
  assign io_lsu_to_wb_lsu_res = io_ex_to_lsu_is_csr ? io_ex_to_lsu_csr_res : _io_lsu_to_wb_lsu_res_T; // @[LSU.scala 167:30]
  assign io_lsu_to_wb_dest = io_ex_to_lsu_save ? 5'h0 : io_ex_to_lsu_dest; // @[LSU.scala 168:27]
  assign io_lsu_to_wb_rf_w = io_ex_to_lsu_save ? 1'h0 : io_ex_to_lsu_rf_w; // @[LSU.scala 169:27]
  assign io_lsu_to_csr_is_clint = is_mtime | is_mtimecmp; // @[LSU.scala 104:27]
  assign io_lsu_to_csr_is_mtime = addr_real == 64'h200bff8; // @[LSU.scala 102:29]
  assign io_lsu_to_csr_is_mtimecmp = addr_real == 64'h2004000; // @[LSU.scala 103:32]
  assign io_lsu_to_csr_load = io_ex_to_lsu_load; // @[LSU.scala 175:22]
  assign io_lsu_to_csr_save = io_ex_to_lsu_save; // @[LSU.scala 176:22]
  assign io_lsu_to_csr_wdata = io_ex_to_lsu_src2; // @[LSU.scala 177:23]
  assign io_dmem_en = _addr_real_T & ~is_clint; // @[LSU.scala 108:32]
  assign io_dmem_addr = {io_dmem_addr_hi,3'h0}; // @[Cat.scala 30:58]
  assign io_dmem_wdata = _sdata_T_11 | _sdata_T_8; // @[Mux.scala 27:72]
  assign io_dmem_wmask = _wmask_T_81 | _wmask_T_67; // @[Mux.scala 27:72]
  assign io_dmem_wen = io_ex_to_lsu_save; // @[LSU.scala 110:15]
endmodule
module WB(
  input  [63:0] io_lsu_to_wb_lsu_res,
  input  [4:0]  io_lsu_to_wb_dest,
  input         io_lsu_to_wb_rf_w,
  output [4:0]  io_rd_addr,
  output [63:0] io_rd_data,
  output        io_rd_en
);
  assign io_rd_addr = io_lsu_to_wb_dest; // @[WB.scala 13:14]
  assign io_rd_data = io_lsu_to_wb_lsu_res; // @[WB.scala 14:14]
  assign io_rd_en = io_lsu_to_wb_rf_w; // @[WB.scala 15:12]
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
  input  [7:0]  io_csr_to_id_csrop,
  input  [11:0] io_csr_to_id_csr_addr,
  input  [63:0] io_csr_to_id_src1,
  input         io_csr_to_id_is_zero,
  input  [63:0] io_csr_to_id_id_pc,
  output [63:0] io_csr_to_id_csr_res,
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
  output [31:0] io_cause
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
  reg [63:0] mcycle; // @[CSR.scala 33:23]
  wire [63:0] _mcycle_T_1 = mcycle + 64'h1; // @[CSR.scala 35:22]
  reg [63:0] mepc; // @[CSR.scala 37:17]
  reg [63:0] mcause; // @[CSR.scala 38:23]
  reg [63:0] mtvec; // @[CSR.scala 39:22]
  reg [62:0] mstatus_i; // @[CSR.scala 40:26]
  wire  mSD = mstatus_i[16:15] == 2'h3 | mstatus_i[14:13] == 2'h3; // @[CSR.scala 42:40]
  wire [63:0] mstatus = {mSD,mstatus_i}; // @[Cat.scala 30:58]
  reg [63:0] mscratch; // @[CSR.scala 45:25]
  reg [63:0] mie; // @[CSR.scala 47:20]
  reg [63:0] mip; // @[CSR.scala 48:20]
  reg [63:0] mtime; // @[CSR.scala 73:22]
  wire [63:0] _mtime_T_1 = mtime + 64'h1; // @[CSR.scala 75:20]
  reg [63:0] mtimecmp; // @[CSR.scala 77:25]
  wire [55:0] mip_hi_hi = mip[63:8]; // @[CSR.scala 79:19]
  wire [6:0] mip_lo = mip[6:0]; // @[CSR.scala 79:33]
  wire [63:0] _mip_T = {mip_hi_hi,1'h1,mip_lo}; // @[Cat.scala 30:58]
  wire [63:0] _GEN_2 = mtime >= mtimecmp ? _mip_T : mip; // @[CSR.scala 78:26 CSR.scala 79:9 CSR.scala 48:20]
  wire [63:0] _GEN_3 = mtime >= mtimecmp ? 64'h0 : _mtime_T_1; // @[CSR.scala 78:26 CSR.scala 80:11]
  wire [63:0] _clint_out_T = io_csr_to_lsu_is_mtimecmp ? mtimecmp : 64'h0; // @[CSR.scala 90:42]
  wire [63:0] _clint_out_T_1 = io_csr_to_lsu_is_mtime ? mtime : _clint_out_T; // @[CSR.scala 90:23]
  wire [63:0] _GEN_4 = io_csr_to_lsu_is_mtimecmp ? io_csr_to_lsu_wdata : mtimecmp; // @[CSR.scala 94:30 CSR.scala 95:18 CSR.scala 77:25]
  wire [63:0] _GEN_5 = io_csr_to_lsu_is_mtime ? io_csr_to_lsu_wdata : _GEN_3; // @[CSR.scala 92:21 CSR.scala 93:15]
  wire [63:0] _GEN_6 = io_csr_to_lsu_is_mtime ? mtimecmp : _GEN_4; // @[CSR.scala 92:21 CSR.scala 77:25]
  wire [63:0] _GEN_9 = io_csr_to_lsu_load ? _clint_out_T_1 : 64'h0; // @[CSR.scala 89:15 CSR.scala 90:17]
  wire  clk_int = mip[7]; // @[CSR.scala 100:21]
  wire  _csr_data_o_T_1 = io_csr_to_id_csr_addr == 12'hb00; // @[CSR.scala 106:17]
  wire  _csr_data_o_T_2 = io_csr_to_id_csr_addr == 12'h341; // @[CSR.scala 107:17]
  wire  _csr_data_o_T_3 = io_csr_to_id_csr_addr == 12'h342; // @[CSR.scala 108:17]
  wire  _csr_data_o_T_4 = io_csr_to_id_csr_addr == 12'h305; // @[CSR.scala 109:17]
  wire  _csr_data_o_T_5 = io_csr_to_id_csr_addr == 12'h300; // @[CSR.scala 110:17]
  wire  _csr_data_o_T_6 = io_csr_to_id_csr_addr == 12'h344; // @[CSR.scala 111:17]
  wire  _csr_data_o_T_7 = io_csr_to_id_csr_addr == 12'h304; // @[CSR.scala 112:17]
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
  wire  is_rw = io_csr_to_id_csrop == 8'h1 | io_csr_to_id_csrop == 8'h4; // @[CSR.scala 118:33]
  wire  is_rs = io_csr_to_id_csrop == 8'h2 | io_csr_to_id_csrop == 8'h5; // @[CSR.scala 119:33]
  wire  is_rc = io_csr_to_id_csrop == 8'h3 | io_csr_to_id_csrop == 8'h6; // @[CSR.scala 120:33]
  wire  _is_trap_begin_T = io_csr_to_id_csrop == 8'h7; // @[CSR.scala 123:30]
  wire  is_trap_begin = io_csr_to_id_csrop == 8'h7 | clk_int; // @[CSR.scala 123:45]
  wire  is_trap_end = io_csr_to_id_csrop == 8'h8; // @[CSR.scala 124:28]
  wire  is_csrop = is_rw | is_rs | is_rc; // @[CSR.scala 143:33]
  wire [63:0] _csr_mask_T = io_csr_to_id_is_zero ? 64'h0 : 64'hffffffffffffffff; // @[CSR.scala 148:22]
  wire [63:0] _csr_mask_T_1 = io_csr_to_id_is_zero ? 64'h0 : io_csr_to_id_src1; // @[CSR.scala 152:22]
  wire [63:0] _csr_data_i_T = ~io_csr_to_id_src1; // @[CSR.scala 155:21]
  wire [63:0] _GEN_15 = is_rc ? csr_data_o : 64'h0; // @[CSR.scala 153:23 CSR.scala 154:15]
  wire [63:0] _GEN_16 = is_rc ? _csr_data_i_T : 64'h0; // @[CSR.scala 153:23 CSR.scala 155:18]
  wire [63:0] _GEN_17 = is_rc ? _csr_mask_T_1 : 64'h0; // @[CSR.scala 153:23 CSR.scala 156:16]
  wire [63:0] _GEN_18 = is_rs ? csr_data_o : _GEN_15; // @[CSR.scala 149:23 CSR.scala 150:15]
  wire [63:0] _GEN_19 = is_rs ? io_csr_to_id_src1 : _GEN_16; // @[CSR.scala 149:23 CSR.scala 151:18]
  wire [63:0] _GEN_20 = is_rs ? _csr_mask_T_1 : _GEN_17; // @[CSR.scala 149:23 CSR.scala 152:16]
  wire [63:0] _GEN_21 = is_rw ? csr_data_o : _GEN_18; // @[CSR.scala 145:17 CSR.scala 146:15]
  wire [63:0] _GEN_22 = is_rw ? io_csr_to_id_src1 : _GEN_19; // @[CSR.scala 145:17 CSR.scala 147:18]
  wire [63:0] _GEN_23 = is_rw ? _csr_mask_T : _GEN_20; // @[CSR.scala 145:17 CSR.scala 148:16]
  wire [63:0] csr_mask = is_csrop ? _GEN_23 : 64'h0; // @[CSR.scala 144:17]
  wire [63:0] _mcycle_T_2 = ~csr_mask; // @[CSR.scala 160:27]
  wire [63:0] _mcycle_T_3 = mcycle & _mcycle_T_2; // @[CSR.scala 160:25]
  wire [63:0] csr_data_i = is_csrop ? _GEN_22 : 64'h0; // @[CSR.scala 144:17]
  wire [63:0] _mcycle_T_4 = csr_data_i & csr_mask; // @[CSR.scala 160:52]
  wire [63:0] _mcycle_T_5 = _mcycle_T_3 | _mcycle_T_4; // @[CSR.scala 160:38]
  wire [63:0] _mepc_T_1 = mepc & _mcycle_T_2; // @[CSR.scala 163:21]
  wire [63:0] _mepc_T_3 = _mepc_T_1 | _mcycle_T_4; // @[CSR.scala 163:34]
  wire [63:0] _mcause_T_1 = mcause & _mcycle_T_2; // @[CSR.scala 166:25]
  wire [63:0] _mcause_T_3 = _mcause_T_1 | _mcycle_T_4; // @[CSR.scala 166:38]
  wire [63:0] _mtvec_T_1 = mtvec & _mcycle_T_2; // @[CSR.scala 169:23]
  wire [63:0] _mtvec_T_3 = _mtvec_T_1 | _mcycle_T_4; // @[CSR.scala 169:36]
  wire [62:0] _lo_T_2 = ~csr_mask[62:0]; // @[CSR.scala 172:37]
  wire [62:0] _lo_T_3 = mstatus[62:0] & _lo_T_2; // @[CSR.scala 172:35]
  wire [62:0] _lo_T_6 = csr_data_i[62:0] & csr_mask[62:0]; // @[CSR.scala 172:74]
  wire [62:0] _lo_T_7 = _lo_T_3 | _lo_T_6; // @[CSR.scala 172:54]
  wire [49:0] lo_hi_hi_hi_3 = mstatus[62:13]; // @[CSR.scala 215:36]
  wire [2:0] lo_hi_lo_hi_3 = mstatus[10:8]; // @[CSR.scala 215:64]
  wire  lo_hi_lo_lo_3 = mstatus[3]; // @[CSR.scala 215:78]
  wire [2:0] lo_lo_hi_hi_3 = mstatus[6:4]; // @[CSR.scala 215:89]
  wire [2:0] lo_lo_lo_3 = mstatus[2:0]; // @[CSR.scala 215:106]
  wire [62:0] _lo_T_11 = {lo_hi_hi_hi_3,2'h3,lo_hi_lo_hi_3,lo_hi_lo_lo_3,lo_lo_hi_hi_3,1'h0,lo_lo_lo_3}; // @[Cat.scala 30:58]
  wire [62:0] _GEN_37 = _csr_data_o_T_5 ? _lo_T_7 : 63'h0; // @[CSR.scala 171:40 CSR.scala 174:19]
  wire [62:0] _GEN_50 = _csr_data_o_T_4 ? 63'h0 : _GEN_37; // @[CSR.scala 168:38]
  wire [62:0] _GEN_65 = _csr_data_o_T_3 ? 63'h0 : _GEN_50; // @[CSR.scala 165:39]
  wire [62:0] _GEN_82 = _csr_data_o_T_2 ? 63'h0 : _GEN_65; // @[CSR.scala 162:37]
  wire [62:0] _GEN_101 = _csr_data_o_T_1 ? 63'h0 : _GEN_82; // @[CSR.scala 159:33]
  wire [62:0] _GEN_123 = is_csrop ? _GEN_101 : 63'h0; // @[CSR.scala 144:17]
  wire [62:0] _GEN_137 = _is_trap_begin_T ? _lo_T_11 : _GEN_123; // @[CSR.scala 191:30 CSR.scala 198:19]
  wire [62:0] _GEN_147 = clk_int ? _lo_T_11 : _GEN_137; // @[CSR.scala 205:18 CSR.scala 215:19]
  wire  lo_lo_hi_lo_1 = mstatus[7]; // @[CSR.scala 235:95]
  wire [62:0] _lo_T_13 = {lo_hi_hi_hi_3,2'h0,lo_hi_lo_hi_3,1'h1,lo_lo_hi_hi_3,lo_lo_hi_lo_1,lo_lo_lo_3}; // @[Cat.scala 30:58]
  wire [62:0] _GEN_155 = is_trap_end ? _lo_T_13 : _GEN_123; // @[CSR.scala 232:29 CSR.scala 235:19]
  wire [62:0] _GEN_160 = is_trap_end ? _GEN_155 : _GEN_123; // @[CSR.scala 231:27]
  wire [62:0] mstatus_o_i = is_trap_begin ? _GEN_147 : _GEN_160; // @[CSR.scala 190:23]
  wire  _mSD_o_T_4 = mstatus_o_i[16:15] == 2'h3 | mstatus_o_i[14:13] == 2'h3; // @[CSR.scala 175:48]
  wire  _GEN_38 = _csr_data_o_T_5 & (mstatus_o_i[16:15] == 2'h3 | mstatus_o_i[14:13] == 2'h3); // @[CSR.scala 171:40 CSR.scala 175:13]
  wire  _GEN_51 = _csr_data_o_T_4 ? 1'h0 : _GEN_38; // @[CSR.scala 168:38]
  wire  _GEN_66 = _csr_data_o_T_3 ? 1'h0 : _GEN_51; // @[CSR.scala 165:39]
  wire  _GEN_83 = _csr_data_o_T_2 ? 1'h0 : _GEN_66; // @[CSR.scala 162:37]
  wire  _GEN_102 = _csr_data_o_T_1 ? 1'h0 : _GEN_83; // @[CSR.scala 159:33]
  wire  _GEN_124 = is_csrop & _GEN_102; // @[CSR.scala 144:17]
  wire  _GEN_138 = _is_trap_begin_T ? _mSD_o_T_4 : _GEN_124; // @[CSR.scala 191:30 CSR.scala 199:13]
  wire  _GEN_148 = clk_int ? _mSD_o_T_4 : _GEN_138; // @[CSR.scala 205:18 CSR.scala 216:13]
  wire  _GEN_156 = is_trap_end ? _mSD_o_T_4 : _GEN_124; // @[CSR.scala 232:29 CSR.scala 236:13]
  wire  _GEN_161 = is_trap_end ? _GEN_156 : _GEN_124; // @[CSR.scala 231:27]
  wire  mSD_o = is_trap_begin ? _GEN_148 : _GEN_161; // @[CSR.scala 190:23]
  wire [63:0] _mstatus_o_T = {mSD_o,mstatus_o_i}; // @[Cat.scala 30:58]
  wire [63:0] _GEN_39 = _csr_data_o_T_5 ? _mstatus_o_T : 64'h0; // @[CSR.scala 171:40 CSR.scala 176:17]
  wire [63:0] _GEN_52 = _csr_data_o_T_4 ? 64'h0 : _GEN_39; // @[CSR.scala 168:38]
  wire [63:0] _GEN_67 = _csr_data_o_T_3 ? 64'h0 : _GEN_52; // @[CSR.scala 165:39]
  wire [63:0] _GEN_84 = _csr_data_o_T_2 ? 64'h0 : _GEN_67; // @[CSR.scala 162:37]
  wire [63:0] _GEN_103 = _csr_data_o_T_1 ? 64'h0 : _GEN_84; // @[CSR.scala 159:33]
  wire [63:0] _GEN_125 = is_csrop ? _GEN_103 : 64'h0; // @[CSR.scala 144:17]
  wire [63:0] _GEN_139 = _is_trap_begin_T ? _mstatus_o_T : _GEN_125; // @[CSR.scala 191:30 CSR.scala 200:17]
  wire [63:0] _GEN_149 = clk_int ? _mstatus_o_T : _GEN_139; // @[CSR.scala 205:18 CSR.scala 217:17]
  wire [63:0] _GEN_157 = is_trap_end ? _mstatus_o_T : _GEN_125; // @[CSR.scala 232:29 CSR.scala 237:17]
  wire [63:0] _GEN_162 = is_trap_end ? _GEN_157 : _GEN_125; // @[CSR.scala 231:27]
  wire [63:0] mstatus_o = is_trap_begin ? _GEN_149 : _GEN_162; // @[CSR.scala 190:23]
  wire [1:0] sstatus_o_hi_lo = mstatus_o[16:15]; // @[CSR.scala 177:49]
  wire [1:0] sstatus_o_lo_hi = mstatus_o[14:13]; // @[CSR.scala 177:66]
  wire [63:0] _sstatus_o_T = {mSD_o,46'h0,sstatus_o_hi_lo,sstatus_o_lo_hi,13'h0}; // @[Cat.scala 30:58]
  wire [63:0] _mip_T_2 = mip & _mcycle_T_2; // @[CSR.scala 179:19]
  wire [63:0] _mip_T_4 = _mip_T_2 | _mcycle_T_4; // @[CSR.scala 179:32]
  wire [63:0] _mie_T_1 = mie & _mcycle_T_2; // @[CSR.scala 182:19]
  wire [63:0] _mie_T_3 = _mie_T_1 | _mcycle_T_4; // @[CSR.scala 182:32]
  wire  _T_8 = io_csr_to_id_csr_addr == 12'h340; // @[CSR.scala 184:25]
  wire [63:0] _mscratch_T_1 = mscratch & _mcycle_T_2; // @[CSR.scala 185:29]
  wire [63:0] _mscratch_T_3 = _mscratch_T_1 | _mcycle_T_4; // @[CSR.scala 185:42]
  wire [63:0] _GEN_24 = io_csr_to_id_csr_addr == 12'h340 ? _mscratch_T_3 : mscratch; // @[CSR.scala 184:40 CSR.scala 185:16 CSR.scala 45:25]
  wire [63:0] _GEN_25 = io_csr_to_id_csr_addr == 12'h340 ? _mscratch_T_3 : 64'h0; // @[CSR.scala 184:40 CSR.scala 186:18]
  wire [63:0] _GEN_26 = _csr_data_o_T_7 ? _mie_T_3 : mie; // @[CSR.scala 181:36 CSR.scala 182:11 CSR.scala 47:20]
  wire [63:0] _GEN_27 = _csr_data_o_T_7 ? _mie_T_3 : 64'h0; // @[CSR.scala 181:36 CSR.scala 183:13]
  wire [63:0] _GEN_28 = _csr_data_o_T_7 ? mscratch : _GEN_24; // @[CSR.scala 181:36 CSR.scala 45:25]
  wire [63:0] _GEN_29 = _csr_data_o_T_7 ? 64'h0 : _GEN_25; // @[CSR.scala 181:36]
  wire [63:0] _GEN_30 = _csr_data_o_T_6 ? _mip_T_4 : _GEN_2; // @[CSR.scala 178:36 CSR.scala 179:11]
  wire [63:0] _GEN_32 = _csr_data_o_T_6 ? mie : _GEN_26; // @[CSR.scala 178:36 CSR.scala 47:20]
  wire [63:0] _GEN_33 = _csr_data_o_T_6 ? 64'h0 : _GEN_27; // @[CSR.scala 178:36]
  wire [63:0] _GEN_34 = _csr_data_o_T_6 ? mscratch : _GEN_28; // @[CSR.scala 178:36 CSR.scala 45:25]
  wire [63:0] _GEN_35 = _csr_data_o_T_6 ? 64'h0 : _GEN_29; // @[CSR.scala 178:36]
  wire [62:0] _GEN_36 = _csr_data_o_T_5 ? _lo_T_7 : mstatus_i; // @[CSR.scala 171:40 CSR.scala 172:17 CSR.scala 40:26]
  wire [63:0] _GEN_40 = _csr_data_o_T_5 ? _sstatus_o_T : 64'h0; // @[CSR.scala 171:40 CSR.scala 177:17]
  wire [63:0] _GEN_41 = _csr_data_o_T_5 ? _GEN_2 : _GEN_30; // @[CSR.scala 171:40]
  wire [63:0] _GEN_43 = _csr_data_o_T_5 ? mie : _GEN_32; // @[CSR.scala 171:40 CSR.scala 47:20]
  wire [63:0] _GEN_44 = _csr_data_o_T_5 ? 64'h0 : _GEN_33; // @[CSR.scala 171:40]
  wire [63:0] _GEN_45 = _csr_data_o_T_5 ? mscratch : _GEN_34; // @[CSR.scala 171:40 CSR.scala 45:25]
  wire [63:0] _GEN_46 = _csr_data_o_T_5 ? 64'h0 : _GEN_35; // @[CSR.scala 171:40]
  wire [63:0] _GEN_47 = _csr_data_o_T_4 ? _mtvec_T_3 : mtvec; // @[CSR.scala 168:38 CSR.scala 169:13 CSR.scala 39:22]
  wire [63:0] _GEN_48 = _csr_data_o_T_4 ? _mtvec_T_3 : 64'h0; // @[CSR.scala 168:38 CSR.scala 170:15]
  wire [62:0] _GEN_49 = _csr_data_o_T_4 ? mstatus_i : _GEN_36; // @[CSR.scala 168:38 CSR.scala 40:26]
  wire [63:0] _GEN_53 = _csr_data_o_T_4 ? 64'h0 : _GEN_40; // @[CSR.scala 168:38]
  wire [63:0] _GEN_54 = _csr_data_o_T_4 ? _GEN_2 : _GEN_41; // @[CSR.scala 168:38]
  wire [63:0] _GEN_56 = _csr_data_o_T_4 ? mie : _GEN_43; // @[CSR.scala 168:38 CSR.scala 47:20]
  wire [63:0] _GEN_57 = _csr_data_o_T_4 ? 64'h0 : _GEN_44; // @[CSR.scala 168:38]
  wire [63:0] _GEN_58 = _csr_data_o_T_4 ? mscratch : _GEN_45; // @[CSR.scala 168:38 CSR.scala 45:25]
  wire [63:0] _GEN_59 = _csr_data_o_T_4 ? 64'h0 : _GEN_46; // @[CSR.scala 168:38]
  wire [63:0] _GEN_60 = _csr_data_o_T_3 ? _mcause_T_3 : mcause; // @[CSR.scala 165:39 CSR.scala 166:14 CSR.scala 38:23]
  wire [63:0] _GEN_61 = _csr_data_o_T_3 ? _mcause_T_3 : 64'h0; // @[CSR.scala 165:39 CSR.scala 167:16]
  wire [63:0] _GEN_62 = _csr_data_o_T_3 ? mtvec : _GEN_47; // @[CSR.scala 165:39 CSR.scala 39:22]
  wire [63:0] _GEN_63 = _csr_data_o_T_3 ? 64'h0 : _GEN_48; // @[CSR.scala 165:39]
  wire [62:0] _GEN_64 = _csr_data_o_T_3 ? mstatus_i : _GEN_49; // @[CSR.scala 165:39 CSR.scala 40:26]
  wire [63:0] _GEN_68 = _csr_data_o_T_3 ? 64'h0 : _GEN_53; // @[CSR.scala 165:39]
  wire [63:0] _GEN_69 = _csr_data_o_T_3 ? _GEN_2 : _GEN_54; // @[CSR.scala 165:39]
  wire [63:0] _GEN_71 = _csr_data_o_T_3 ? mie : _GEN_56; // @[CSR.scala 165:39 CSR.scala 47:20]
  wire [63:0] _GEN_72 = _csr_data_o_T_3 ? 64'h0 : _GEN_57; // @[CSR.scala 165:39]
  wire [63:0] _GEN_73 = _csr_data_o_T_3 ? mscratch : _GEN_58; // @[CSR.scala 165:39 CSR.scala 45:25]
  wire [63:0] _GEN_74 = _csr_data_o_T_3 ? 64'h0 : _GEN_59; // @[CSR.scala 165:39]
  wire [63:0] _GEN_75 = _csr_data_o_T_2 ? _mepc_T_3 : mepc; // @[CSR.scala 162:37 CSR.scala 163:12 CSR.scala 37:17]
  wire [63:0] _GEN_76 = _csr_data_o_T_2 ? _mepc_T_3 : 64'h0; // @[CSR.scala 162:37 CSR.scala 164:14]
  wire [63:0] _GEN_77 = _csr_data_o_T_2 ? mcause : _GEN_60; // @[CSR.scala 162:37 CSR.scala 38:23]
  wire [63:0] _GEN_78 = _csr_data_o_T_2 ? 64'h0 : _GEN_61; // @[CSR.scala 162:37]
  wire [63:0] _GEN_80 = _csr_data_o_T_2 ? 64'h0 : _GEN_63; // @[CSR.scala 162:37]
  wire [62:0] _GEN_81 = _csr_data_o_T_2 ? mstatus_i : _GEN_64; // @[CSR.scala 162:37 CSR.scala 40:26]
  wire [63:0] _GEN_85 = _csr_data_o_T_2 ? 64'h0 : _GEN_68; // @[CSR.scala 162:37]
  wire [63:0] _GEN_86 = _csr_data_o_T_2 ? _GEN_2 : _GEN_69; // @[CSR.scala 162:37]
  wire [63:0] _GEN_89 = _csr_data_o_T_2 ? 64'h0 : _GEN_72; // @[CSR.scala 162:37]
  wire [63:0] _GEN_91 = _csr_data_o_T_2 ? 64'h0 : _GEN_74; // @[CSR.scala 162:37]
  wire [63:0] _GEN_94 = _csr_data_o_T_1 ? mepc : _GEN_75; // @[CSR.scala 159:33 CSR.scala 37:17]
  wire [63:0] _GEN_95 = _csr_data_o_T_1 ? 64'h0 : _GEN_76; // @[CSR.scala 159:33]
  wire [63:0] _GEN_96 = _csr_data_o_T_1 ? mcause : _GEN_77; // @[CSR.scala 159:33 CSR.scala 38:23]
  wire [63:0] _GEN_97 = _csr_data_o_T_1 ? 64'h0 : _GEN_78; // @[CSR.scala 159:33]
  wire [63:0] _GEN_99 = _csr_data_o_T_1 ? 64'h0 : _GEN_80; // @[CSR.scala 159:33]
  wire [62:0] _GEN_100 = _csr_data_o_T_1 ? mstatus_i : _GEN_81; // @[CSR.scala 159:33 CSR.scala 40:26]
  wire [63:0] _GEN_104 = _csr_data_o_T_1 ? 64'h0 : _GEN_85; // @[CSR.scala 159:33]
  wire [63:0] _GEN_105 = _csr_data_o_T_1 ? _GEN_2 : _GEN_86; // @[CSR.scala 159:33]
  wire [63:0] _GEN_108 = _csr_data_o_T_1 ? 64'h0 : _GEN_89; // @[CSR.scala 159:33]
  wire [63:0] _GEN_110 = _csr_data_o_T_1 ? 64'h0 : _GEN_91; // @[CSR.scala 159:33]
  wire [63:0] _GEN_116 = is_csrop ? _GEN_94 : mepc; // @[CSR.scala 144:17 CSR.scala 37:17]
  wire [63:0] _GEN_117 = is_csrop ? _GEN_95 : 64'h0; // @[CSR.scala 144:17]
  wire [63:0] _GEN_118 = is_csrop ? _GEN_96 : mcause; // @[CSR.scala 144:17 CSR.scala 38:23]
  wire [63:0] _GEN_119 = is_csrop ? _GEN_97 : 64'h0; // @[CSR.scala 144:17]
  wire [63:0] mtvec_o = is_csrop ? _GEN_99 : 64'h0; // @[CSR.scala 144:17]
  wire [62:0] _GEN_122 = is_csrop ? _GEN_100 : mstatus_i; // @[CSR.scala 144:17 CSR.scala 40:26]
  wire [63:0] _GEN_126 = is_csrop ? _GEN_104 : 64'h0; // @[CSR.scala 144:17]
  wire [63:0] _GEN_127 = is_csrop ? _GEN_105 : _GEN_2; // @[CSR.scala 144:17]
  wire [63:0] mie_o = is_csrop ? _GEN_108 : 64'h0; // @[CSR.scala 144:17]
  wire [63:0] mscratch_o = is_csrop ? _GEN_110 : 64'h0; // @[CSR.scala 144:17]
  wire [63:0] _GEN_136 = _is_trap_begin_T ? 64'hb : _GEN_119; // @[CSR.scala 191:30 CSR.scala 196:16]
  wire [63:0] _GEN_140 = _is_trap_begin_T ? _sstatus_o_T : _GEN_126; // @[CSR.scala 191:30 CSR.scala 201:17]
  wire [63:0] _GEN_141 = _is_trap_begin_T ? io_csr_to_id_id_pc : _GEN_117; // @[CSR.scala 191:30 CSR.scala 203:14]
  wire [63:0] _GEN_146 = clk_int ? 64'h8000000000000007 : _GEN_136; // @[CSR.scala 205:18 CSR.scala 213:16]
  wire [63:0] _GEN_150 = clk_int ? _sstatus_o_T : _GEN_140; // @[CSR.scala 205:18 CSR.scala 218:17]
  wire [63:0] _GEN_151 = clk_int ? io_csr_to_id_id_pc : _GEN_141; // @[CSR.scala 205:18 CSR.scala 220:14]
  wire [61:0] csr_target_hi = mtvec[63:2]; // @[CSR.scala 225:31]
  wire [63:0] _csr_target_T = {csr_target_hi,2'h0}; // @[Cat.scala 30:58]
  wire [62:0] csr_target_lo = mcause[62:0]; // @[CSR.scala 225:67]
  wire [63:0] _csr_target_T_1 = {1'h0,csr_target_lo}; // @[Cat.scala 30:58]
  wire [63:0] _csr_target_T_3 = _csr_target_T + _csr_target_T_1; // @[CSR.scala 225:50]
  wire [65:0] _csr_target_T_4 = {_csr_target_T_3, 2'h0}; // @[CSR.scala 225:76]
  wire [65:0] _GEN_152 = mtvec[1:0] == 2'h1 ? _csr_target_T_4 : 66'h0; // @[CSR.scala 224:37 CSR.scala 225:18]
  wire [65:0] _GEN_153 = mtvec[1:0] == 2'h0 ? {{2'd0}, mtvec} : _GEN_152; // @[CSR.scala 222:31 CSR.scala 223:18]
  wire [63:0] _GEN_158 = is_trap_end ? _sstatus_o_T : _GEN_126; // @[CSR.scala 232:29 CSR.scala 238:17]
  wire [63:0] _GEN_163 = is_trap_end ? _GEN_158 : _GEN_126; // @[CSR.scala 231:27]
  wire [63:0] _GEN_164 = is_trap_end ? mepc : 64'h0; // @[CSR.scala 231:27 CSR.scala 242:16]
  wire [63:0] mcause_o = is_trap_begin ? _GEN_146 : _GEN_119; // @[CSR.scala 190:23]
  wire [63:0] sstatus_o = is_trap_begin ? _GEN_150 : _GEN_163; // @[CSR.scala 190:23]
  wire [63:0] mepc_o = is_trap_begin ? _GEN_151 : _GEN_117; // @[CSR.scala 190:23]
  wire [65:0] _GEN_175 = is_trap_begin ? _GEN_153 : {{2'd0}, _GEN_164}; // @[CSR.scala 190:23]
  wire  _io_mstatus_T_3 = is_csrop & _csr_data_o_T_5 | is_trap_begin | is_trap_end; // @[CSR.scala 253:75]
  wire [1:0] sstatus_hi_lo = mstatus[16:15]; // @[CSR.scala 257:42]
  wire [1:0] sstatus_lo_hi = mstatus[14:13]; // @[CSR.scala 257:57]
  wire [63:0] sstatus = {mSD,46'h0,sstatus_hi_lo,sstatus_lo_hi,13'h0}; // @[Cat.scala 30:58]
  assign io_csr_to_id_csr_res = is_csrop ? _GEN_21 : 64'h0; // @[CSR.scala 144:17]
  assign io_csr_to_id_csr_jump = is_trap_begin | is_trap_end; // @[CSR.scala 125:42]
  assign io_csr_to_id_csr_target = _GEN_175[63:0]; // @[CSR.scala 246:27]
  assign io_csr_to_lsu_rdata = io_csr_to_lsu_is_clint ? _GEN_9 : 64'h0; // @[CSR.scala 88:17]
  assign io_mepc = is_csrop & _csr_data_o_T_2 | is_trap_begin ? mepc_o : mepc; // @[CSR.scala 249:17]
  assign io_mcause = is_csrop & _csr_data_o_T_3 | is_trap_begin ? mcause_o : mcause; // @[CSR.scala 250:19]
  assign io_mtvec = is_csrop & _csr_data_o_T_4 ? mtvec_o : mtvec; // @[CSR.scala 251:18]
  assign io_mstatus = is_csrop & _csr_data_o_T_5 | is_trap_begin | is_trap_end ? mstatus_o : mstatus; // @[CSR.scala 253:20]
  assign io_mie = is_csrop & _csr_data_o_T_7 ? mie_o : mie; // @[CSR.scala 255:16]
  assign io_mscratch = is_csrop & _T_8 ? mscratch_o : mscratch; // @[CSR.scala 256:21]
  assign io_sstatus = _io_mstatus_T_3 ? sstatus_o : sstatus; // @[CSR.scala 258:20]
  assign io_intrNO = clk_int ? 32'h7 : 32'h0; // @[Mux.scala 27:72]
  assign io_cause = _is_trap_begin_T ? 32'hb : 32'h0; // @[Mux.scala 27:72]
  always @(posedge clock) begin
    if (reset) begin // @[CSR.scala 33:23]
      mcycle <= 64'h0; // @[CSR.scala 33:23]
    end else if (is_csrop) begin // @[CSR.scala 144:17]
      if (_csr_data_o_T_1) begin // @[CSR.scala 159:33]
        mcycle <= _mcycle_T_5; // @[CSR.scala 160:14]
      end else begin
        mcycle <= _mcycle_T_1;
      end
    end else begin
      mcycle <= _mcycle_T_1;
    end
    if (is_trap_begin) begin // @[CSR.scala 190:23]
      if (clk_int) begin // @[CSR.scala 205:18]
        mepc <= io_csr_to_id_id_pc; // @[CSR.scala 211:12]
      end else if (_is_trap_begin_T) begin // @[CSR.scala 191:30]
        mepc <= io_csr_to_id_id_pc; // @[CSR.scala 194:12]
      end else begin
        mepc <= _GEN_116;
      end
    end else begin
      mepc <= _GEN_116;
    end
    if (reset) begin // @[CSR.scala 38:23]
      mcause <= 64'h0; // @[CSR.scala 38:23]
    end else if (is_trap_begin) begin // @[CSR.scala 190:23]
      if (clk_int) begin // @[CSR.scala 205:18]
        mcause <= 64'h8000000000000007; // @[CSR.scala 206:14]
      end else if (_is_trap_begin_T) begin // @[CSR.scala 191:30]
        mcause <= 64'hb; // @[CSR.scala 192:14]
      end else begin
        mcause <= _GEN_118;
      end
    end else begin
      mcause <= _GEN_118;
    end
    if (reset) begin // @[CSR.scala 39:22]
      mtvec <= 64'h0; // @[CSR.scala 39:22]
    end else if (is_csrop) begin // @[CSR.scala 144:17]
      if (!(_csr_data_o_T_1)) begin // @[CSR.scala 159:33]
        if (!(_csr_data_o_T_2)) begin // @[CSR.scala 162:37]
          mtvec <= _GEN_62;
        end
      end
    end
    if (reset) begin // @[CSR.scala 40:26]
      mstatus_i <= 63'h1800; // @[CSR.scala 40:26]
    end else if (is_trap_begin) begin // @[CSR.scala 190:23]
      if (clk_int) begin // @[CSR.scala 205:18]
        mstatus_i <= _lo_T_11; // @[CSR.scala 207:17]
      end else if (_is_trap_begin_T) begin // @[CSR.scala 191:30]
        mstatus_i <= _lo_T_11; // @[CSR.scala 193:17]
      end else begin
        mstatus_i <= _GEN_122;
      end
    end else if (is_trap_end) begin // @[CSR.scala 231:27]
      if (is_trap_end) begin // @[CSR.scala 232:29]
        mstatus_i <= _lo_T_13; // @[CSR.scala 233:17]
      end else begin
        mstatus_i <= _GEN_122;
      end
    end else begin
      mstatus_i <= _GEN_122;
    end
    if (reset) begin // @[CSR.scala 45:25]
      mscratch <= 64'h0; // @[CSR.scala 45:25]
    end else if (is_csrop) begin // @[CSR.scala 144:17]
      if (!(_csr_data_o_T_1)) begin // @[CSR.scala 159:33]
        if (!(_csr_data_o_T_2)) begin // @[CSR.scala 162:37]
          mscratch <= _GEN_73;
        end
      end
    end
    if (reset) begin // @[CSR.scala 47:20]
      mie <= 64'h0; // @[CSR.scala 47:20]
    end else if (is_csrop) begin // @[CSR.scala 144:17]
      if (!(_csr_data_o_T_1)) begin // @[CSR.scala 159:33]
        if (!(_csr_data_o_T_2)) begin // @[CSR.scala 162:37]
          mie <= _GEN_71;
        end
      end
    end
    if (reset) begin // @[CSR.scala 48:20]
      mip <= 64'h0; // @[CSR.scala 48:20]
    end else if (is_trap_begin) begin // @[CSR.scala 190:23]
      if (clk_int) begin // @[CSR.scala 205:18]
        mip <= 64'h0; // @[CSR.scala 209:11]
      end else begin
        mip <= _GEN_127;
      end
    end else begin
      mip <= _GEN_127;
    end
    if (reset) begin // @[CSR.scala 73:22]
      mtime <= 64'h0; // @[CSR.scala 73:22]
    end else if (io_csr_to_lsu_is_clint) begin // @[CSR.scala 88:17]
      if (io_csr_to_lsu_load) begin // @[CSR.scala 89:15]
        mtime <= _GEN_3;
      end else if (io_csr_to_lsu_save) begin // @[CSR.scala 91:21]
        mtime <= _GEN_5;
      end else begin
        mtime <= _GEN_3;
      end
    end else begin
      mtime <= _GEN_3;
    end
    if (reset) begin // @[CSR.scala 77:25]
      mtimecmp <= 64'hf8ff; // @[CSR.scala 77:25]
    end else if (io_csr_to_lsu_is_clint) begin // @[CSR.scala 88:17]
      if (!(io_csr_to_lsu_load)) begin // @[CSR.scala 89:15]
        if (io_csr_to_lsu_save) begin // @[CSR.scala 91:21]
          mtimecmp <= _GEN_6;
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
  output [63:0] io_imem_addr,
  input  [63:0] io_imem_rdata,
  output        io_dmem_en,
  output [63:0] io_dmem_addr,
  input  [63:0] io_dmem_rdata,
  output [63:0] io_dmem_wdata,
  output [63:0] io_dmem_wmask,
  output        io_dmem_wen
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
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
`endif // RANDOMIZE_REG_INIT
  wire  fetch_clock; // @[Core.scala 13:21]
  wire  fetch_reset; // @[Core.scala 13:21]
  wire [63:0] fetch_io_imem_addr; // @[Core.scala 13:21]
  wire [63:0] fetch_io_imem_rdata; // @[Core.scala 13:21]
  wire [63:0] fetch_io_if_to_id_pc; // @[Core.scala 13:21]
  wire [31:0] fetch_io_if_to_id_inst; // @[Core.scala 13:21]
  wire [63:0] fetch_io_id_to_if_pc_target; // @[Core.scala 13:21]
  wire  fetch_io_id_to_if_jump; // @[Core.scala 13:21]
  wire  decode_clock; // @[Core.scala 15:22]
  wire  decode_reset; // @[Core.scala 15:22]
  wire [63:0] decode_io_if_to_id_pc; // @[Core.scala 15:22]
  wire [31:0] decode_io_if_to_id_inst; // @[Core.scala 15:22]
  wire [10:0] decode_io_id_to_ex_aluop; // @[Core.scala 15:22]
  wire [7:0] decode_io_id_to_ex_lsuop; // @[Core.scala 15:22]
  wire [11:0] decode_io_id_to_ex_rv64op; // @[Core.scala 15:22]
  wire  decode_io_id_to_ex_is_csr; // @[Core.scala 15:22]
  wire [63:0] decode_io_id_to_ex_csr_res; // @[Core.scala 15:22]
  wire [63:0] decode_io_id_to_ex_out1; // @[Core.scala 15:22]
  wire [63:0] decode_io_id_to_ex_out2; // @[Core.scala 15:22]
  wire [63:0] decode_io_id_to_ex_imm; // @[Core.scala 15:22]
  wire [4:0] decode_io_id_to_ex_dest; // @[Core.scala 15:22]
  wire  decode_io_id_to_ex_rf_w; // @[Core.scala 15:22]
  wire  decode_io_id_to_ex_load; // @[Core.scala 15:22]
  wire  decode_io_id_to_ex_save; // @[Core.scala 15:22]
  wire [63:0] decode_io_id_to_if_pc_target; // @[Core.scala 15:22]
  wire  decode_io_id_to_if_jump; // @[Core.scala 15:22]
  wire [7:0] decode_io_id_to_csr_csrop; // @[Core.scala 15:22]
  wire [11:0] decode_io_id_to_csr_csr_addr; // @[Core.scala 15:22]
  wire [63:0] decode_io_id_to_csr_src1; // @[Core.scala 15:22]
  wire  decode_io_id_to_csr_is_zero; // @[Core.scala 15:22]
  wire [63:0] decode_io_id_to_csr_id_pc; // @[Core.scala 15:22]
  wire [63:0] decode_io_id_to_csr_csr_res; // @[Core.scala 15:22]
  wire  decode_io_id_to_csr_csr_jump; // @[Core.scala 15:22]
  wire [63:0] decode_io_id_to_csr_csr_target; // @[Core.scala 15:22]
  wire [4:0] decode_io_rs1_addr; // @[Core.scala 15:22]
  wire [63:0] decode_io_rs1_data; // @[Core.scala 15:22]
  wire [4:0] decode_io_rs2_addr; // @[Core.scala 15:22]
  wire [63:0] decode_io_rs2_data; // @[Core.scala 15:22]
  wire [10:0] exu_io_id_to_ex_aluop; // @[Core.scala 20:19]
  wire [7:0] exu_io_id_to_ex_lsuop; // @[Core.scala 20:19]
  wire [11:0] exu_io_id_to_ex_rv64op; // @[Core.scala 20:19]
  wire  exu_io_id_to_ex_is_csr; // @[Core.scala 20:19]
  wire [63:0] exu_io_id_to_ex_csr_res; // @[Core.scala 20:19]
  wire [63:0] exu_io_id_to_ex_out1; // @[Core.scala 20:19]
  wire [63:0] exu_io_id_to_ex_out2; // @[Core.scala 20:19]
  wire [63:0] exu_io_id_to_ex_imm; // @[Core.scala 20:19]
  wire [4:0] exu_io_id_to_ex_dest; // @[Core.scala 20:19]
  wire  exu_io_id_to_ex_rf_w; // @[Core.scala 20:19]
  wire  exu_io_id_to_ex_load; // @[Core.scala 20:19]
  wire  exu_io_id_to_ex_save; // @[Core.scala 20:19]
  wire  exu_io_ex_to_lsu_is_csr; // @[Core.scala 20:19]
  wire [63:0] exu_io_ex_to_lsu_csr_res; // @[Core.scala 20:19]
  wire [63:0] exu_io_ex_to_lsu_alu_res; // @[Core.scala 20:19]
  wire [63:0] exu_io_ex_to_lsu_src1; // @[Core.scala 20:19]
  wire [63:0] exu_io_ex_to_lsu_src2; // @[Core.scala 20:19]
  wire [63:0] exu_io_ex_to_lsu_imm; // @[Core.scala 20:19]
  wire [7:0] exu_io_ex_to_lsu_lsuop; // @[Core.scala 20:19]
  wire [11:0] exu_io_ex_to_lsu_rv64op; // @[Core.scala 20:19]
  wire [4:0] exu_io_ex_to_lsu_dest; // @[Core.scala 20:19]
  wire  exu_io_ex_to_lsu_rf_w; // @[Core.scala 20:19]
  wire  exu_io_ex_to_lsu_load; // @[Core.scala 20:19]
  wire  exu_io_ex_to_lsu_save; // @[Core.scala 20:19]
  wire  lsu_io_ex_to_lsu_is_csr; // @[Core.scala 23:19]
  wire [63:0] lsu_io_ex_to_lsu_csr_res; // @[Core.scala 23:19]
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
  wire [63:0] lsu_io_lsu_to_wb_lsu_res; // @[Core.scala 23:19]
  wire [4:0] lsu_io_lsu_to_wb_dest; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_wb_rf_w; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_is_clint; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_is_mtime; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_is_mtimecmp; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_load; // @[Core.scala 23:19]
  wire  lsu_io_lsu_to_csr_save; // @[Core.scala 23:19]
  wire [63:0] lsu_io_lsu_to_csr_wdata; // @[Core.scala 23:19]
  wire [63:0] lsu_io_lsu_to_csr_rdata; // @[Core.scala 23:19]
  wire  lsu_io_dmem_en; // @[Core.scala 23:19]
  wire [63:0] lsu_io_dmem_addr; // @[Core.scala 23:19]
  wire [63:0] lsu_io_dmem_rdata; // @[Core.scala 23:19]
  wire [63:0] lsu_io_dmem_wdata; // @[Core.scala 23:19]
  wire [63:0] lsu_io_dmem_wmask; // @[Core.scala 23:19]
  wire  lsu_io_dmem_wen; // @[Core.scala 23:19]
  wire [63:0] wb_io_lsu_to_wb_lsu_res; // @[Core.scala 27:18]
  wire [4:0] wb_io_lsu_to_wb_dest; // @[Core.scala 27:18]
  wire  wb_io_lsu_to_wb_rf_w; // @[Core.scala 27:18]
  wire [4:0] wb_io_rd_addr; // @[Core.scala 27:18]
  wire [63:0] wb_io_rd_data; // @[Core.scala 27:18]
  wire  wb_io_rd_en; // @[Core.scala 27:18]
  wire  rf_clock; // @[Core.scala 30:18]
  wire  rf_reset; // @[Core.scala 30:18]
  wire [4:0] rf_io_rs1_addr; // @[Core.scala 30:18]
  wire [4:0] rf_io_rs2_addr; // @[Core.scala 30:18]
  wire [63:0] rf_io_rs1_data; // @[Core.scala 30:18]
  wire [63:0] rf_io_rs2_data; // @[Core.scala 30:18]
  wire [4:0] rf_io_rd_addr; // @[Core.scala 30:18]
  wire [63:0] rf_io_rd_data; // @[Core.scala 30:18]
  wire  rf_io_rd_en; // @[Core.scala 30:18]
  wire [63:0] rf_rf_10; // @[Core.scala 30:18]
  wire  csr_clock; // @[Core.scala 42:19]
  wire  csr_reset; // @[Core.scala 42:19]
  wire [7:0] csr_io_csr_to_id_csrop; // @[Core.scala 42:19]
  wire [11:0] csr_io_csr_to_id_csr_addr; // @[Core.scala 42:19]
  wire [63:0] csr_io_csr_to_id_src1; // @[Core.scala 42:19]
  wire  csr_io_csr_to_id_is_zero; // @[Core.scala 42:19]
  wire [63:0] csr_io_csr_to_id_id_pc; // @[Core.scala 42:19]
  wire [63:0] csr_io_csr_to_id_csr_res; // @[Core.scala 42:19]
  wire  csr_io_csr_to_id_csr_jump; // @[Core.scala 42:19]
  wire [63:0] csr_io_csr_to_id_csr_target; // @[Core.scala 42:19]
  wire  csr_io_csr_to_lsu_is_clint; // @[Core.scala 42:19]
  wire  csr_io_csr_to_lsu_is_mtime; // @[Core.scala 42:19]
  wire  csr_io_csr_to_lsu_is_mtimecmp; // @[Core.scala 42:19]
  wire  csr_io_csr_to_lsu_load; // @[Core.scala 42:19]
  wire  csr_io_csr_to_lsu_save; // @[Core.scala 42:19]
  wire [63:0] csr_io_csr_to_lsu_wdata; // @[Core.scala 42:19]
  wire [63:0] csr_io_csr_to_lsu_rdata; // @[Core.scala 42:19]
  wire [63:0] csr_io_mepc; // @[Core.scala 42:19]
  wire [63:0] csr_io_mcause; // @[Core.scala 42:19]
  wire [63:0] csr_io_mtvec; // @[Core.scala 42:19]
  wire [63:0] csr_io_mstatus; // @[Core.scala 42:19]
  wire [63:0] csr_io_mie; // @[Core.scala 42:19]
  wire [63:0] csr_io_mscratch; // @[Core.scala 42:19]
  wire [63:0] csr_io_sstatus; // @[Core.scala 42:19]
  wire [31:0] csr_io_intrNO; // @[Core.scala 42:19]
  wire [31:0] csr_io_cause; // @[Core.scala 42:19]
  wire  dt_ic_clock; // @[Core.scala 48:21]
  wire [7:0] dt_ic_coreid; // @[Core.scala 48:21]
  wire [7:0] dt_ic_index; // @[Core.scala 48:21]
  wire  dt_ic_valid; // @[Core.scala 48:21]
  wire [63:0] dt_ic_pc; // @[Core.scala 48:21]
  wire [31:0] dt_ic_instr; // @[Core.scala 48:21]
  wire [7:0] dt_ic_special; // @[Core.scala 48:21]
  wire  dt_ic_skip; // @[Core.scala 48:21]
  wire  dt_ic_isRVC; // @[Core.scala 48:21]
  wire  dt_ic_scFailed; // @[Core.scala 48:21]
  wire  dt_ic_wen; // @[Core.scala 48:21]
  wire [63:0] dt_ic_wdata; // @[Core.scala 48:21]
  wire [7:0] dt_ic_wdest; // @[Core.scala 48:21]
  wire  dt_ae_clock; // @[Core.scala 66:21]
  wire [7:0] dt_ae_coreid; // @[Core.scala 66:21]
  wire [31:0] dt_ae_intrNO; // @[Core.scala 66:21]
  wire [31:0] dt_ae_cause; // @[Core.scala 66:21]
  wire [63:0] dt_ae_exceptionPC; // @[Core.scala 66:21]
  wire [31:0] dt_ae_exceptionInst; // @[Core.scala 66:21]
  wire  dt_te_clock; // @[Core.scala 82:21]
  wire [7:0] dt_te_coreid; // @[Core.scala 82:21]
  wire  dt_te_valid; // @[Core.scala 82:21]
  wire [2:0] dt_te_code; // @[Core.scala 82:21]
  wire [63:0] dt_te_pc; // @[Core.scala 82:21]
  wire [63:0] dt_te_cycleCnt; // @[Core.scala 82:21]
  wire [63:0] dt_te_instrCnt; // @[Core.scala 82:21]
  wire  dt_cs_clock; // @[Core.scala 91:21]
  wire [7:0] dt_cs_coreid; // @[Core.scala 91:21]
  wire [1:0] dt_cs_priviledgeMode; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mstatus; // @[Core.scala 91:21]
  wire [63:0] dt_cs_sstatus; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mepc; // @[Core.scala 91:21]
  wire [63:0] dt_cs_sepc; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mtval; // @[Core.scala 91:21]
  wire [63:0] dt_cs_stval; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mtvec; // @[Core.scala 91:21]
  wire [63:0] dt_cs_stvec; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mcause; // @[Core.scala 91:21]
  wire [63:0] dt_cs_scause; // @[Core.scala 91:21]
  wire [63:0] dt_cs_satp; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mip; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mie; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mscratch; // @[Core.scala 91:21]
  wire [63:0] dt_cs_sscratch; // @[Core.scala 91:21]
  wire [63:0] dt_cs_mideleg; // @[Core.scala 91:21]
  wire [63:0] dt_cs_medeleg; // @[Core.scala 91:21]
  reg [63:0] dt_ic_io_pc_REG; // @[Core.scala 53:25]
  reg [31:0] dt_ic_io_instr_REG; // @[Core.scala 54:28]
  wire [31:0] _dt_ic_io_skip_T_2 = fetch_io_if_to_id_inst; // @[Core.scala 55:125]
  wire  _dt_ic_io_skip_T_4 = fetch_io_if_to_id_inst == 32'h7b | lsu_io_lsu_to_csr_is_clint | 32'h73 ==
    _dt_ic_io_skip_T_2; // @[Core.scala 55:99]
  reg  dt_ic_io_skip_REG; // @[Core.scala 55:27]
  reg  dt_ic_io_wen_REG; // @[Core.scala 62:26]
  reg [63:0] dt_ic_io_wdata_REG; // @[Core.scala 63:28]
  reg [4:0] dt_ic_io_wdest_REG; // @[Core.scala 64:28]
  reg [31:0] dt_ae_io_intrNO_REG; // @[Core.scala 69:29]
  reg [31:0] dt_ae_io_cause_REG; // @[Core.scala 70:28]
  reg [63:0] dt_ae_io_exceptionPC_REG; // @[Core.scala 71:34]
  reg [63:0] cycle_cnt; // @[Core.scala 73:26]
  reg [63:0] instr_cnt; // @[Core.scala 74:26]
  wire [63:0] _cycle_cnt_T_1 = cycle_cnt + 64'h1; // @[Core.scala 76:26]
  wire [63:0] _instr_cnt_T_1 = instr_cnt + 64'h1; // @[Core.scala 77:26]
  wire [63:0] rf_a0_0 = rf_rf_10;
  reg [63:0] dt_cs_io_mstatus_REG; // @[Core.scala 95:30]
  reg [63:0] dt_cs_io_sstatus_REG; // @[Core.scala 96:30]
  reg [63:0] dt_cs_io_mepc_REG; // @[Core.scala 97:27]
  reg [63:0] dt_cs_io_mtvec_REG; // @[Core.scala 101:28]
  reg [63:0] dt_cs_io_mcause_REG; // @[Core.scala 103:29]
  reg [63:0] dt_cs_io_mie_REG; // @[Core.scala 107:26]
  reg [63:0] dt_cs_io_mscratch_REG; // @[Core.scala 108:31]
  InstFetch fetch ( // @[Core.scala 13:21]
    .clock(fetch_clock),
    .reset(fetch_reset),
    .io_imem_addr(fetch_io_imem_addr),
    .io_imem_rdata(fetch_io_imem_rdata),
    .io_if_to_id_pc(fetch_io_if_to_id_pc),
    .io_if_to_id_inst(fetch_io_if_to_id_inst),
    .io_id_to_if_pc_target(fetch_io_id_to_if_pc_target),
    .io_id_to_if_jump(fetch_io_id_to_if_jump)
  );
  Decode decode ( // @[Core.scala 15:22]
    .clock(decode_clock),
    .reset(decode_reset),
    .io_if_to_id_pc(decode_io_if_to_id_pc),
    .io_if_to_id_inst(decode_io_if_to_id_inst),
    .io_id_to_ex_aluop(decode_io_id_to_ex_aluop),
    .io_id_to_ex_lsuop(decode_io_id_to_ex_lsuop),
    .io_id_to_ex_rv64op(decode_io_id_to_ex_rv64op),
    .io_id_to_ex_is_csr(decode_io_id_to_ex_is_csr),
    .io_id_to_ex_csr_res(decode_io_id_to_ex_csr_res),
    .io_id_to_ex_out1(decode_io_id_to_ex_out1),
    .io_id_to_ex_out2(decode_io_id_to_ex_out2),
    .io_id_to_ex_imm(decode_io_id_to_ex_imm),
    .io_id_to_ex_dest(decode_io_id_to_ex_dest),
    .io_id_to_ex_rf_w(decode_io_id_to_ex_rf_w),
    .io_id_to_ex_load(decode_io_id_to_ex_load),
    .io_id_to_ex_save(decode_io_id_to_ex_save),
    .io_id_to_if_pc_target(decode_io_id_to_if_pc_target),
    .io_id_to_if_jump(decode_io_id_to_if_jump),
    .io_id_to_csr_csrop(decode_io_id_to_csr_csrop),
    .io_id_to_csr_csr_addr(decode_io_id_to_csr_csr_addr),
    .io_id_to_csr_src1(decode_io_id_to_csr_src1),
    .io_id_to_csr_is_zero(decode_io_id_to_csr_is_zero),
    .io_id_to_csr_id_pc(decode_io_id_to_csr_id_pc),
    .io_id_to_csr_csr_res(decode_io_id_to_csr_csr_res),
    .io_id_to_csr_csr_jump(decode_io_id_to_csr_csr_jump),
    .io_id_to_csr_csr_target(decode_io_id_to_csr_csr_target),
    .io_rs1_addr(decode_io_rs1_addr),
    .io_rs1_data(decode_io_rs1_data),
    .io_rs2_addr(decode_io_rs2_addr),
    .io_rs2_data(decode_io_rs2_data)
  );
  Execution exu ( // @[Core.scala 20:19]
    .io_id_to_ex_aluop(exu_io_id_to_ex_aluop),
    .io_id_to_ex_lsuop(exu_io_id_to_ex_lsuop),
    .io_id_to_ex_rv64op(exu_io_id_to_ex_rv64op),
    .io_id_to_ex_is_csr(exu_io_id_to_ex_is_csr),
    .io_id_to_ex_csr_res(exu_io_id_to_ex_csr_res),
    .io_id_to_ex_out1(exu_io_id_to_ex_out1),
    .io_id_to_ex_out2(exu_io_id_to_ex_out2),
    .io_id_to_ex_imm(exu_io_id_to_ex_imm),
    .io_id_to_ex_dest(exu_io_id_to_ex_dest),
    .io_id_to_ex_rf_w(exu_io_id_to_ex_rf_w),
    .io_id_to_ex_load(exu_io_id_to_ex_load),
    .io_id_to_ex_save(exu_io_id_to_ex_save),
    .io_ex_to_lsu_is_csr(exu_io_ex_to_lsu_is_csr),
    .io_ex_to_lsu_csr_res(exu_io_ex_to_lsu_csr_res),
    .io_ex_to_lsu_alu_res(exu_io_ex_to_lsu_alu_res),
    .io_ex_to_lsu_src1(exu_io_ex_to_lsu_src1),
    .io_ex_to_lsu_src2(exu_io_ex_to_lsu_src2),
    .io_ex_to_lsu_imm(exu_io_ex_to_lsu_imm),
    .io_ex_to_lsu_lsuop(exu_io_ex_to_lsu_lsuop),
    .io_ex_to_lsu_rv64op(exu_io_ex_to_lsu_rv64op),
    .io_ex_to_lsu_dest(exu_io_ex_to_lsu_dest),
    .io_ex_to_lsu_rf_w(exu_io_ex_to_lsu_rf_w),
    .io_ex_to_lsu_load(exu_io_ex_to_lsu_load),
    .io_ex_to_lsu_save(exu_io_ex_to_lsu_save)
  );
  LSU lsu ( // @[Core.scala 23:19]
    .io_ex_to_lsu_is_csr(lsu_io_ex_to_lsu_is_csr),
    .io_ex_to_lsu_csr_res(lsu_io_ex_to_lsu_csr_res),
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
    .io_lsu_to_wb_lsu_res(lsu_io_lsu_to_wb_lsu_res),
    .io_lsu_to_wb_dest(lsu_io_lsu_to_wb_dest),
    .io_lsu_to_wb_rf_w(lsu_io_lsu_to_wb_rf_w),
    .io_lsu_to_csr_is_clint(lsu_io_lsu_to_csr_is_clint),
    .io_lsu_to_csr_is_mtime(lsu_io_lsu_to_csr_is_mtime),
    .io_lsu_to_csr_is_mtimecmp(lsu_io_lsu_to_csr_is_mtimecmp),
    .io_lsu_to_csr_load(lsu_io_lsu_to_csr_load),
    .io_lsu_to_csr_save(lsu_io_lsu_to_csr_save),
    .io_lsu_to_csr_wdata(lsu_io_lsu_to_csr_wdata),
    .io_lsu_to_csr_rdata(lsu_io_lsu_to_csr_rdata),
    .io_dmem_en(lsu_io_dmem_en),
    .io_dmem_addr(lsu_io_dmem_addr),
    .io_dmem_rdata(lsu_io_dmem_rdata),
    .io_dmem_wdata(lsu_io_dmem_wdata),
    .io_dmem_wmask(lsu_io_dmem_wmask),
    .io_dmem_wen(lsu_io_dmem_wen)
  );
  WB wb ( // @[Core.scala 27:18]
    .io_lsu_to_wb_lsu_res(wb_io_lsu_to_wb_lsu_res),
    .io_lsu_to_wb_dest(wb_io_lsu_to_wb_dest),
    .io_lsu_to_wb_rf_w(wb_io_lsu_to_wb_rf_w),
    .io_rd_addr(wb_io_rd_addr),
    .io_rd_data(wb_io_rd_data),
    .io_rd_en(wb_io_rd_en)
  );
  RegFile rf ( // @[Core.scala 30:18]
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
  CSR csr ( // @[Core.scala 42:19]
    .clock(csr_clock),
    .reset(csr_reset),
    .io_csr_to_id_csrop(csr_io_csr_to_id_csrop),
    .io_csr_to_id_csr_addr(csr_io_csr_to_id_csr_addr),
    .io_csr_to_id_src1(csr_io_csr_to_id_src1),
    .io_csr_to_id_is_zero(csr_io_csr_to_id_is_zero),
    .io_csr_to_id_id_pc(csr_io_csr_to_id_id_pc),
    .io_csr_to_id_csr_res(csr_io_csr_to_id_csr_res),
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
    .io_cause(csr_io_cause)
  );
  DifftestInstrCommit dt_ic ( // @[Core.scala 48:21]
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
  DifftestArchEvent dt_ae ( // @[Core.scala 66:21]
    .clock(dt_ae_clock),
    .coreid(dt_ae_coreid),
    .intrNO(dt_ae_intrNO),
    .cause(dt_ae_cause),
    .exceptionPC(dt_ae_exceptionPC),
    .exceptionInst(dt_ae_exceptionInst)
  );
  DifftestTrapEvent dt_te ( // @[Core.scala 82:21]
    .clock(dt_te_clock),
    .coreid(dt_te_coreid),
    .valid(dt_te_valid),
    .code(dt_te_code),
    .pc(dt_te_pc),
    .cycleCnt(dt_te_cycleCnt),
    .instrCnt(dt_te_instrCnt)
  );
  DifftestCSRState dt_cs ( // @[Core.scala 91:21]
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
  assign io_imem_addr = fetch_io_imem_addr; // @[Core.scala 14:17]
  assign io_dmem_en = lsu_io_dmem_en; // @[Core.scala 25:15]
  assign io_dmem_addr = lsu_io_dmem_addr; // @[Core.scala 25:15]
  assign io_dmem_wdata = lsu_io_dmem_wdata; // @[Core.scala 25:15]
  assign io_dmem_wmask = lsu_io_dmem_wmask; // @[Core.scala 25:15]
  assign io_dmem_wen = lsu_io_dmem_wen; // @[Core.scala 25:15]
  assign fetch_clock = clock;
  assign fetch_reset = reset;
  assign fetch_io_imem_rdata = io_imem_rdata; // @[Core.scala 14:17]
  assign fetch_io_id_to_if_pc_target = decode_io_id_to_if_pc_target; // @[Core.scala 18:22]
  assign fetch_io_id_to_if_jump = decode_io_id_to_if_jump; // @[Core.scala 18:22]
  assign decode_clock = clock;
  assign decode_reset = reset;
  assign decode_io_if_to_id_pc = fetch_io_if_to_id_pc; // @[Core.scala 17:21]
  assign decode_io_if_to_id_inst = fetch_io_if_to_id_inst; // @[Core.scala 17:21]
  assign decode_io_id_to_csr_csr_res = csr_io_csr_to_id_csr_res; // @[Core.scala 43:23]
  assign decode_io_id_to_csr_csr_jump = csr_io_csr_to_id_csr_jump; // @[Core.scala 43:23]
  assign decode_io_id_to_csr_csr_target = csr_io_csr_to_id_csr_target; // @[Core.scala 43:23]
  assign decode_io_rs1_data = rf_io_rs1_data; // @[Core.scala 35:22]
  assign decode_io_rs2_data = rf_io_rs2_data; // @[Core.scala 36:22]
  assign exu_io_id_to_ex_aluop = decode_io_id_to_ex_aluop; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_lsuop = decode_io_id_to_ex_lsuop; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_rv64op = decode_io_id_to_ex_rv64op; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_is_csr = decode_io_id_to_ex_is_csr; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_csr_res = decode_io_id_to_ex_csr_res; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_out1 = decode_io_id_to_ex_out1; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_out2 = decode_io_id_to_ex_out2; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_imm = decode_io_id_to_ex_imm; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_dest = decode_io_id_to_ex_dest; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_rf_w = decode_io_id_to_ex_rf_w; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_load = decode_io_id_to_ex_load; // @[Core.scala 21:22]
  assign exu_io_id_to_ex_save = decode_io_id_to_ex_save; // @[Core.scala 21:22]
  assign lsu_io_ex_to_lsu_is_csr = exu_io_ex_to_lsu_is_csr; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_csr_res = exu_io_ex_to_lsu_csr_res; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_alu_res = exu_io_ex_to_lsu_alu_res; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_src1 = exu_io_ex_to_lsu_src1; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_src2 = exu_io_ex_to_lsu_src2; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_imm = exu_io_ex_to_lsu_imm; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_lsuop = exu_io_ex_to_lsu_lsuop; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_rv64op = exu_io_ex_to_lsu_rv64op; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_dest = exu_io_ex_to_lsu_dest; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_rf_w = exu_io_ex_to_lsu_rf_w; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_load = exu_io_ex_to_lsu_load; // @[Core.scala 24:20]
  assign lsu_io_ex_to_lsu_save = exu_io_ex_to_lsu_save; // @[Core.scala 24:20]
  assign lsu_io_lsu_to_csr_rdata = csr_io_csr_to_lsu_rdata; // @[Core.scala 44:21]
  assign lsu_io_dmem_rdata = io_dmem_rdata; // @[Core.scala 25:15]
  assign wb_io_lsu_to_wb_lsu_res = lsu_io_lsu_to_wb_lsu_res; // @[Core.scala 28:20]
  assign wb_io_lsu_to_wb_dest = lsu_io_lsu_to_wb_dest; // @[Core.scala 28:20]
  assign wb_io_lsu_to_wb_rf_w = lsu_io_lsu_to_wb_rf_w; // @[Core.scala 28:20]
  assign rf_clock = clock;
  assign rf_reset = reset;
  assign rf_io_rs1_addr = decode_io_rs1_addr; // @[Core.scala 32:18]
  assign rf_io_rs2_addr = decode_io_rs2_addr; // @[Core.scala 33:18]
  assign rf_io_rd_addr = wb_io_rd_addr; // @[Core.scala 38:17]
  assign rf_io_rd_data = wb_io_rd_data; // @[Core.scala 39:17]
  assign rf_io_rd_en = wb_io_rd_en; // @[Core.scala 40:15]
  assign csr_clock = clock;
  assign csr_reset = reset;
  assign csr_io_csr_to_id_csrop = decode_io_id_to_csr_csrop; // @[Core.scala 43:23]
  assign csr_io_csr_to_id_csr_addr = decode_io_id_to_csr_csr_addr; // @[Core.scala 43:23]
  assign csr_io_csr_to_id_src1 = decode_io_id_to_csr_src1; // @[Core.scala 43:23]
  assign csr_io_csr_to_id_is_zero = decode_io_id_to_csr_is_zero; // @[Core.scala 43:23]
  assign csr_io_csr_to_id_id_pc = decode_io_id_to_csr_id_pc; // @[Core.scala 43:23]
  assign csr_io_csr_to_lsu_is_clint = lsu_io_lsu_to_csr_is_clint; // @[Core.scala 44:21]
  assign csr_io_csr_to_lsu_is_mtime = lsu_io_lsu_to_csr_is_mtime; // @[Core.scala 44:21]
  assign csr_io_csr_to_lsu_is_mtimecmp = lsu_io_lsu_to_csr_is_mtimecmp; // @[Core.scala 44:21]
  assign csr_io_csr_to_lsu_load = lsu_io_lsu_to_csr_load; // @[Core.scala 44:21]
  assign csr_io_csr_to_lsu_save = lsu_io_lsu_to_csr_save; // @[Core.scala 44:21]
  assign csr_io_csr_to_lsu_wdata = lsu_io_lsu_to_csr_wdata; // @[Core.scala 44:21]
  assign dt_ic_clock = clock; // @[Core.scala 49:18]
  assign dt_ic_coreid = 8'h0; // @[Core.scala 50:19]
  assign dt_ic_index = 8'h0; // @[Core.scala 51:18]
  assign dt_ic_valid = 1'h1; // @[Core.scala 52:18]
  assign dt_ic_pc = dt_ic_io_pc_REG; // @[Core.scala 53:15]
  assign dt_ic_instr = dt_ic_io_instr_REG; // @[Core.scala 54:18]
  assign dt_ic_special = 8'h0;
  assign dt_ic_skip = dt_ic_io_skip_REG; // @[Core.scala 55:17]
  assign dt_ic_isRVC = 1'h0; // @[Core.scala 60:18]
  assign dt_ic_scFailed = 1'h0; // @[Core.scala 61:21]
  assign dt_ic_wen = dt_ic_io_wen_REG; // @[Core.scala 62:16]
  assign dt_ic_wdata = dt_ic_io_wdata_REG; // @[Core.scala 63:18]
  assign dt_ic_wdest = {{3'd0}, dt_ic_io_wdest_REG}; // @[Core.scala 64:18]
  assign dt_ae_clock = clock; // @[Core.scala 67:18]
  assign dt_ae_coreid = 8'h0; // @[Core.scala 68:19]
  assign dt_ae_intrNO = dt_ae_io_intrNO_REG; // @[Core.scala 69:19]
  assign dt_ae_cause = dt_ae_io_cause_REG; // @[Core.scala 70:18]
  assign dt_ae_exceptionPC = dt_ae_io_exceptionPC_REG; // @[Core.scala 71:24]
  assign dt_ae_exceptionInst = 32'h0;
  assign dt_te_clock = clock; // @[Core.scala 83:18]
  assign dt_te_coreid = 8'h0; // @[Core.scala 84:19]
  assign dt_te_valid = fetch_io_if_to_id_inst == 32'h6b; // @[Core.scala 85:45]
  assign dt_te_code = rf_a0_0[2:0]; // @[Core.scala 86:25]
  assign dt_te_pc = fetch_io_if_to_id_pc; // @[Core.scala 87:15]
  assign dt_te_cycleCnt = cycle_cnt; // @[Core.scala 88:21]
  assign dt_te_instrCnt = instr_cnt; // @[Core.scala 89:21]
  assign dt_cs_clock = clock; // @[Core.scala 92:18]
  assign dt_cs_coreid = 8'h0; // @[Core.scala 93:19]
  assign dt_cs_priviledgeMode = 2'h3; // @[Core.scala 94:27]
  assign dt_cs_mstatus = dt_cs_io_mstatus_REG; // @[Core.scala 95:20]
  assign dt_cs_sstatus = dt_cs_io_sstatus_REG; // @[Core.scala 96:20]
  assign dt_cs_mepc = dt_cs_io_mepc_REG; // @[Core.scala 97:17]
  assign dt_cs_sepc = 64'h0; // @[Core.scala 98:17]
  assign dt_cs_mtval = 64'h0; // @[Core.scala 99:18]
  assign dt_cs_stval = 64'h0; // @[Core.scala 100:18]
  assign dt_cs_mtvec = dt_cs_io_mtvec_REG; // @[Core.scala 101:18]
  assign dt_cs_stvec = 64'h0; // @[Core.scala 102:18]
  assign dt_cs_mcause = dt_cs_io_mcause_REG; // @[Core.scala 103:19]
  assign dt_cs_scause = 64'h0; // @[Core.scala 104:19]
  assign dt_cs_satp = 64'h0; // @[Core.scala 105:17]
  assign dt_cs_mip = 64'h0; // @[Core.scala 106:16]
  assign dt_cs_mie = dt_cs_io_mie_REG; // @[Core.scala 107:16]
  assign dt_cs_mscratch = dt_cs_io_mscratch_REG; // @[Core.scala 108:21]
  assign dt_cs_sscratch = 64'h0; // @[Core.scala 109:21]
  assign dt_cs_mideleg = 64'h0; // @[Core.scala 110:20]
  assign dt_cs_medeleg = 64'h0; // @[Core.scala 111:20]
  always @(posedge clock) begin
    dt_ic_io_pc_REG <= fetch_io_if_to_id_pc; // @[Core.scala 53:25]
    dt_ic_io_instr_REG <= fetch_io_if_to_id_inst; // @[Core.scala 54:28]
    dt_ic_io_skip_REG <= _dt_ic_io_skip_T_4 | csr_io_csr_to_id_csr_addr == 12'hb00; // @[Core.scala 56:3]
    dt_ic_io_wen_REG <= wb_io_rd_en; // @[Core.scala 62:26]
    dt_ic_io_wdata_REG <= wb_io_rd_data; // @[Core.scala 63:28]
    dt_ic_io_wdest_REG <= wb_io_rd_addr; // @[Core.scala 64:28]
    dt_ae_io_intrNO_REG <= csr_io_intrNO; // @[Core.scala 69:29]
    dt_ae_io_cause_REG <= csr_io_cause; // @[Core.scala 70:28]
    dt_ae_io_exceptionPC_REG <= decode_io_id_to_csr_id_pc; // @[Core.scala 71:34]
    if (reset) begin // @[Core.scala 73:26]
      cycle_cnt <= 64'h0; // @[Core.scala 73:26]
    end else begin
      cycle_cnt <= _cycle_cnt_T_1; // @[Core.scala 76:13]
    end
    if (reset) begin // @[Core.scala 74:26]
      instr_cnt <= 64'h0; // @[Core.scala 74:26]
    end else begin
      instr_cnt <= _instr_cnt_T_1; // @[Core.scala 77:13]
    end
    dt_cs_io_mstatus_REG <= csr_io_mstatus; // @[Core.scala 95:30]
    dt_cs_io_sstatus_REG <= csr_io_sstatus; // @[Core.scala 96:30]
    dt_cs_io_mepc_REG <= csr_io_mepc; // @[Core.scala 97:27]
    dt_cs_io_mtvec_REG <= csr_io_mtvec; // @[Core.scala 101:28]
    dt_cs_io_mcause_REG <= csr_io_mcause; // @[Core.scala 103:29]
    dt_cs_io_mie_REG <= csr_io_mie; // @[Core.scala 107:26]
    dt_cs_io_mscratch_REG <= csr_io_mscratch; // @[Core.scala 108:31]
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
  dt_ic_io_pc_REG = _RAND_0[63:0];
  _RAND_1 = {1{`RANDOM}};
  dt_ic_io_instr_REG = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  dt_ic_io_skip_REG = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dt_ic_io_wen_REG = _RAND_3[0:0];
  _RAND_4 = {2{`RANDOM}};
  dt_ic_io_wdata_REG = _RAND_4[63:0];
  _RAND_5 = {1{`RANDOM}};
  dt_ic_io_wdest_REG = _RAND_5[4:0];
  _RAND_6 = {1{`RANDOM}};
  dt_ae_io_intrNO_REG = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  dt_ae_io_cause_REG = _RAND_7[31:0];
  _RAND_8 = {2{`RANDOM}};
  dt_ae_io_exceptionPC_REG = _RAND_8[63:0];
  _RAND_9 = {2{`RANDOM}};
  cycle_cnt = _RAND_9[63:0];
  _RAND_10 = {2{`RANDOM}};
  instr_cnt = _RAND_10[63:0];
  _RAND_11 = {2{`RANDOM}};
  dt_cs_io_mstatus_REG = _RAND_11[63:0];
  _RAND_12 = {2{`RANDOM}};
  dt_cs_io_sstatus_REG = _RAND_12[63:0];
  _RAND_13 = {2{`RANDOM}};
  dt_cs_io_mepc_REG = _RAND_13[63:0];
  _RAND_14 = {2{`RANDOM}};
  dt_cs_io_mtvec_REG = _RAND_14[63:0];
  _RAND_15 = {2{`RANDOM}};
  dt_cs_io_mcause_REG = _RAND_15[63:0];
  _RAND_16 = {2{`RANDOM}};
  dt_cs_io_mie_REG = _RAND_16[63:0];
  _RAND_17 = {2{`RANDOM}};
  dt_cs_io_mscratch_REG = _RAND_17[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Ram2r1w(
  input         clock,
  input  [63:0] io_imem_addr,
  output [63:0] io_imem_rdata,
  input         io_dmem_en,
  input  [63:0] io_dmem_addr,
  output [63:0] io_dmem_rdata,
  input  [63:0] io_dmem_wdata,
  input  [63:0] io_dmem_wmask,
  input         io_dmem_wen
);
  wire  mem_clk; // @[Ram.scala 37:19]
  wire  mem_imem_en; // @[Ram.scala 37:19]
  wire [63:0] mem_imem_addr; // @[Ram.scala 37:19]
  wire [31:0] mem_imem_data; // @[Ram.scala 37:19]
  wire  mem_dmem_en; // @[Ram.scala 37:19]
  wire [63:0] mem_dmem_addr; // @[Ram.scala 37:19]
  wire [63:0] mem_dmem_rdata; // @[Ram.scala 37:19]
  wire [63:0] mem_dmem_wdata; // @[Ram.scala 37:19]
  wire [63:0] mem_dmem_wmask; // @[Ram.scala 37:19]
  wire  mem_dmem_wen; // @[Ram.scala 37:19]
  ram_2r1w mem ( // @[Ram.scala 37:19]
    .clk(mem_clk),
    .imem_en(mem_imem_en),
    .imem_addr(mem_imem_addr),
    .imem_data(mem_imem_data),
    .dmem_en(mem_dmem_en),
    .dmem_addr(mem_dmem_addr),
    .dmem_rdata(mem_dmem_rdata),
    .dmem_wdata(mem_dmem_wdata),
    .dmem_wmask(mem_dmem_wmask),
    .dmem_wen(mem_dmem_wen)
  );
  assign io_imem_rdata = {{32'd0}, mem_imem_data}; // @[Ram.scala 41:21]
  assign io_dmem_rdata = mem_dmem_rdata; // @[Ram.scala 44:21]
  assign mem_clk = clock; // @[Ram.scala 38:21]
  assign mem_imem_en = 1'h1; // @[Ram.scala 39:21]
  assign mem_imem_addr = io_imem_addr; // @[Ram.scala 40:21]
  assign mem_dmem_en = io_dmem_en; // @[Ram.scala 42:21]
  assign mem_dmem_addr = io_dmem_addr; // @[Ram.scala 43:21]
  assign mem_dmem_wdata = io_dmem_wdata; // @[Ram.scala 45:21]
  assign mem_dmem_wmask = io_dmem_wmask; // @[Ram.scala 46:21]
  assign mem_dmem_wen = io_dmem_wen; // @[Ram.scala 47:21]
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
  input  [7:0]  io_uart_in_ch
);
  wire  core_clock; // @[SimTop.scala 12:20]
  wire  core_reset; // @[SimTop.scala 12:20]
  wire [63:0] core_io_imem_addr; // @[SimTop.scala 12:20]
  wire [63:0] core_io_imem_rdata; // @[SimTop.scala 12:20]
  wire  core_io_dmem_en; // @[SimTop.scala 12:20]
  wire [63:0] core_io_dmem_addr; // @[SimTop.scala 12:20]
  wire [63:0] core_io_dmem_rdata; // @[SimTop.scala 12:20]
  wire [63:0] core_io_dmem_wdata; // @[SimTop.scala 12:20]
  wire [63:0] core_io_dmem_wmask; // @[SimTop.scala 12:20]
  wire  core_io_dmem_wen; // @[SimTop.scala 12:20]
  wire  mem_clock; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_imem_addr; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_imem_rdata; // @[SimTop.scala 14:19]
  wire  mem_io_dmem_en; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_dmem_addr; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_dmem_rdata; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_dmem_wdata; // @[SimTop.scala 14:19]
  wire [63:0] mem_io_dmem_wmask; // @[SimTop.scala 14:19]
  wire  mem_io_dmem_wen; // @[SimTop.scala 14:19]
  Core core ( // @[SimTop.scala 12:20]
    .clock(core_clock),
    .reset(core_reset),
    .io_imem_addr(core_io_imem_addr),
    .io_imem_rdata(core_io_imem_rdata),
    .io_dmem_en(core_io_dmem_en),
    .io_dmem_addr(core_io_dmem_addr),
    .io_dmem_rdata(core_io_dmem_rdata),
    .io_dmem_wdata(core_io_dmem_wdata),
    .io_dmem_wmask(core_io_dmem_wmask),
    .io_dmem_wen(core_io_dmem_wen)
  );
  Ram2r1w mem ( // @[SimTop.scala 14:19]
    .clock(mem_clock),
    .io_imem_addr(mem_io_imem_addr),
    .io_imem_rdata(mem_io_imem_rdata),
    .io_dmem_en(mem_io_dmem_en),
    .io_dmem_addr(mem_io_dmem_addr),
    .io_dmem_rdata(mem_io_dmem_rdata),
    .io_dmem_wdata(mem_io_dmem_wdata),
    .io_dmem_wmask(mem_io_dmem_wmask),
    .io_dmem_wen(mem_io_dmem_wen)
  );
  assign io_uart_out_valid = 1'h0; // @[SimTop.scala 18:21]
  assign io_uart_out_ch = 8'h0; // @[SimTop.scala 19:18]
  assign io_uart_in_valid = 1'h0; // @[SimTop.scala 20:20]
  assign core_clock = clock;
  assign core_reset = reset;
  assign core_io_imem_rdata = mem_io_imem_rdata; // @[SimTop.scala 15:15]
  assign core_io_dmem_rdata = mem_io_dmem_rdata; // @[SimTop.scala 16:15]
  assign mem_clock = clock;
  assign mem_io_imem_addr = core_io_imem_addr; // @[SimTop.scala 15:15]
  assign mem_io_dmem_en = core_io_dmem_en; // @[SimTop.scala 16:15]
  assign mem_io_dmem_addr = core_io_dmem_addr; // @[SimTop.scala 16:15]
  assign mem_io_dmem_wdata = core_io_dmem_wdata; // @[SimTop.scala 16:15]
  assign mem_io_dmem_wmask = core_io_dmem_wmask; // @[SimTop.scala 16:15]
  assign mem_io_dmem_wen = core_io_dmem_wen; // @[SimTop.scala 16:15]
endmodule
