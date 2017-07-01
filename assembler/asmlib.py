import re

opcodes = ["add", "addi", "addiu", "addu", "and", "andi", "bc1f", "bc1t", "beq",
           "bgez", "bgtz", "blez", "bltz", "bne", "ceq", "cfc1", "cge", "cgt",
           "cle", "clt", "cne", "ctc1", "fabs", "fadd", "fdiv", "fma", "fmul",
           "fneg", "fsqrt", "fsub", "j", "jr", "lb", "lbu", "lh", "lhu", "lui",
           "lw", "lwc0", "lwc1", "mfc0", "mfc1", "mov", "mtc0", "mtc1", "nor",
           "or", "ori", "pre", "sh", "sll", "sllv", "slt", "slti", "sltiu", "sltu",
           "sra", "srav", "srl", "srlv", "sub", "sub", "subu", "sw", "swc0", "swc1",
           "syscall", "teq", "teqi", "tge", "tgei", "tgeiu", "tgeu", "tlt", "tlti",
           "tltiu", "tltu", "tne", "tnei", "xor", "xor"]

directives = [".text", ".data", ".word", ".half", ".byte", ".space", ".fill", ".ascii", ".asciiz", ".float", ".globl"]

def statementtype(asm):
    asm.lstrip()

def asmtohex(asm):
    if (";" in asm):
        asm = asm[:asm.find(";")]
    asm_split = re.split(" |, ", asm)
    toks = [i for i in asm_split if i != ""]
