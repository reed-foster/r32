import re

opcodes = ["add", "addi", "addiu", "addu", "and", "andi", "beq", "bgez", "bgtz", "blez", "bltz", "bne", "j", "jr", "lb", "lbu", "lh", "lhu", "lui", "lw", "nor", "or", "ori", "pre", "sb", "sh",
           "sll", "sllv", "slt", "slti", "sltiu", "sra", "srav", "srl", "srlv", "sub", "subu", "sw", "syscall", "teq", "teqi", "tge", "tgei", "tgeiu", "tgeu", "tlt", "tlti", "tltiu", "tltu",
           "tne", "tnei", "xor", "xori", "lwc0", "swc0", "mtc0", "mfc0", "lwc1", "swc1", "mtc1", "mfc1", "fadd", "fsub", "fmul", "fdiv", "fabs", "fneg", "fsqrt", "bc1f", "bc1t", "ceq",
           "cne", "clt", "cle", "cge", "cgt", "cfc1", "ctc1", "fma", "mov"]

directives = [".text", ".data", ".word", ".half", ".byte", ".space", ".ascii", ".asciiz", ".float", ".globl"]

def statementtype(asm):
    asm.lstrip()

def asmtohex(asm):
    if (";" in asm):
        asm = asm[:asm.find(";")]
    asm_split = re.split(" |, ", asm)
    toks = [i for i in asm_split if i != ""]
