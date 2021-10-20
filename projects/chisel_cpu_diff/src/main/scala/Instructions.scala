import chisel3._
import chisel3.util._

object Instructions {
//-------------------RV32I_ALUInstr------------------------------//
  def ADDI = BitPat("b????????????_?????_000_?????_0010011")
  def SLLI = BitPat("b000000??????_?????_001_?????_0010011")
  def SLTI = BitPat("b????????????_?????_010_?????_0010011")
  def SLTIU = BitPat("b????????????_?????_011_?????_0010011")
  def XORI = BitPat("b????????????_?????_100_?????_0010011")
  def SRLI = BitPat("b000000??????_?????_101_?????_0010011")
  def ORI = BitPat("b????????????_?????_110_?????_0010011")
  def ANDI = BitPat("b????????????_?????_111_?????_0010011")
  def SRAI = BitPat("b010000??????_?????_101_?????_0010011")

  def ADD = BitPat("b0000000_?????_?????_000_?????_0110011")
  def SLL = BitPat("b0000000_?????_?????_001_?????_0110011")
  def SLT = BitPat("b0000000_?????_?????_010_?????_0110011")
  def SLTU = BitPat("b0000000_?????_?????_011_?????_0110011")
  def XOR = BitPat("b0000000_?????_?????_100_?????_0110011")
  def SRL = BitPat("b0000000_?????_?????_101_?????_0110011")
  def OR = BitPat("b0000000_?????_?????_110_?????_0110011")
  def AND = BitPat("b0000000_?????_?????_111_?????_0110011")
  def SUB = BitPat("b0100000_?????_?????_000_?????_0110011")
  def SRA = BitPat("b0100000_?????_?????_101_?????_0110011")

  def AUIPC = BitPat("b????????????????????_?????_0010111")
  def LUI = BitPat("b????????????????????_?????_0110111")

//-------------------RV32I_BRUInstr------------------------------//
  def JAL = BitPat("b????????????????????_?????_1101111")
  def JALR = BitPat("b????????????_?????_000_?????_1100111")

  def BNE = BitPat("b???????_?????_?????_001_?????_1100011")
  def BEQ = BitPat("b???????_?????_?????_000_?????_1100011")
  def BLT = BitPat("b???????_?????_?????_100_?????_1100011")
  def BGE = BitPat("b???????_?????_?????_101_?????_1100011")
  def BLTU = BitPat("b???????_?????_?????_110_?????_1100011")
  def BGEU = BitPat("b???????_?????_?????_111_?????_1100011")

//-------------------RV32I_LSUInstr------------------------------//
  def LB = BitPat("b????????????_?????_000_?????_0000011")
  def LH = BitPat("b????????????_?????_001_?????_0000011")
  def LW = BitPat("b????????????_?????_010_?????_0000011")
  def LBU = BitPat("b????????????_?????_100_?????_0000011")
  def LHU = BitPat("b????????????_?????_101_?????_0000011")
  def SB = BitPat("b???????_?????_?????_000_?????_0100011")
  def SH = BitPat("b???????_?????_?????_001_?????_0100011")
  def SW = BitPat("b???????_?????_?????_010_?????_0100011")

//-------------------RV64IInstr----------------------------------//
  def ADDIW = BitPat("b???????_?????_?????_000_?????_0011011")
  def SLLIW = BitPat("b0000000_?????_?????_001_?????_0011011")
  def SRLIW = BitPat("b0000000_?????_?????_101_?????_0011011")
  def SRAIW = BitPat("b0100000_?????_?????_101_?????_0011011")
  def SLLW = BitPat("b0000000_?????_?????_001_?????_0111011")
  def SRLW = BitPat("b0000000_?????_?????_101_?????_0111011")
  def SRAW = BitPat("b0100000_?????_?????_101_?????_0111011")
  def ADDW = BitPat("b0000000_?????_?????_000_?????_0111011")
  def SUBW = BitPat("b0100000_?????_?????_000_?????_0111011")

  def LWU = BitPat("b???????_?????_?????_110_?????_0000011")
  def LD = BitPat("b???????_?????_?????_011_?????_0000011")
  def SD = BitPat("b???????_?????_?????_011_?????_0100011")

//-------------------自定义指令------------------------------------//
  def PUTCH = BitPat("b0000000_00000_00000_000_00000_1111011")
}
