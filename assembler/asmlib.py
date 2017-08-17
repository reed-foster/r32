import re

opcodes = ["add", "addi", "addiu", "addu", "and", "andi", "bc1f", "bc1t", "beq",
           "bgez", "bgtz", "blez", "bltz", "bne", "ceq", "cfc1", "cle", "clt",
           "ctc1", "fabs", "fadd", "fdiv", "fma", "fmul", "fneg", "fsqrt", "fsub",
           "j", "jr", "lb", "lbu", "lh", "lhu", "lui", "lw", "lwc1", "mfc0",
           "mfc1", "mov", "mtc0", "mtc1", "nor", "or", "ori", "pref", "sb", "sh",
           "sll", "sllv", "slt", "slti", "sltiu", "sltu", "sra", "srav", "srl",
           "srlv", "sub", "subu", "sw", "swc1", "syscall", "teq", "teqi", "tge",
           "tgei", "tgeiu", "tgeu", "tlt", "tlti", "tltiu", "tltu", "tne", "tnei",
           "xor", "xori"]

directives = [".text", ".data", ".word", ".half", ".byte", ".space", ".fill", ".ascii", ".asciiz", ".float", ".globl"]

def statementtype(asm):
    asm.lstrip()

def asmtohex(asm):
    if (";" in asm):
        asm = asm[:asm.find(";")]
    asm_split = re.split(" |, ", asm)
    toks = [i for i in asm_split if i != ""]
