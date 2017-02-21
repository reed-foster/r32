#Processor Instructions
---
<table>
<tr><td><b>Operation</b></td><td><b>Semantics</b></td><td><b>Notes</b></td></tr>
<tr><td>add</td><td>rd ← rs + rt</td><td></td></tr>
<tr><td>addi</td><td>rt ← rs + imm</td><td>imm is sign-extended</td></tr>
<tr><td>addiu</td><td>rt ← rs + imm</td><td>no overflow exception</td></tr>
<tr><td>addu</td><td>rd ← rs + rt</td><td>no overflow exception</td></tr>
<tr><td>and</td><td>rd ← rs &amp; rt</td><td></td></tr>
<tr><td>andi</td><td>rt ← rs &amp; imm</td><td>imm is zero-extended</td></tr>
<tr><td>beq</td><td>rs == rt ? PC += offset : PC++</td><td></td></tr>
<tr><td>bgez</td><td>rs >= 0 ? PC += offset : PC++</td><td></td></tr>
<tr><td>bgtz</td><td>rs > 0 ? PC += offset : PC++</td><td></td></tr>
<tr><td>blez</td><td>rs &lt;= 0 ? PC += offset : PC++</td><td></td></tr>
<tr><td>bltz</td><td>rs &lt; 0 ? PC += offset : PC++</td><td></td></tr>
<tr><td>bne</td><td>rs != 0 ? PC += offset : PC++</td><td></td></tr>
<tr><td>j</td><td>PC ← PC(31:28) || jtarg</td><td></td></tr>
<tr><td>jal</td><td>PC ← PC(31:28) || jtarg; $ra ? PC + 8</td><td></td></tr>
<tr><td>jalr</td><td>PC ← rs; $ra ? PC + 8</td><td></td></tr>
<tr><td>jr</td><td>PC ← rs</td><td></td></tr>
<tr><td>lb</td><td>rt ← MEM[rs + imm]</td><td>imm is sign-extended; byte at MEM[rs + imm] is sign-extended</td></tr>
<tr><td>lbu</td><td>rt ← MEM[rs + imm]</td><td>imm is sign-extended; byte at MEM[rs + imm] is zero-extended</td></tr>
<tr><td>lh</td><td>rt ← MEM[rs + imm] || MEM[rs + imm + 1]</td><td>imm is sign-extended; word at MEM[rs + imm] is sign-extended</td></tr>
<tr><td>lhu</td><td>rt ← MEM[rs + imm] || MEM[rs + imm + 1]</td><td>imm is sign-extended; word at MEM[rs + imm] is zero-extended</td></tr>
<tr><td>lui</td><td>rt ← imm &lt;&lt; 16</td><td>imm is sign-exteded after shifting</td></tr>
<tr><td>lw</td><td>rt ← MEM[rs + imm] || MEM[rs + imm + 1] || MEM[rs + imm + 2] || MEM[rs + imm + 3]</td><td>imm is sign-extended</td></tr>
<tr><td>nor</td><td>rd ← ~(rs | rt)</td><td></td></tr>
<tr><td>or</td><td>rd ← rs | rt</td><td></td></tr>
<tr><td>ori</td><td>rt ← rs | imm</td><td>imm is zero-extended</td></tr>
<tr><td>sb</td><td>MEM[rs + imm] ← rt(7:0)</td><td>imm is sign-extended</td></tr>
<tr><td>sh</td><td>MEM[rs + imm + 1] ← rt(7:0); MEM[rs + imm] ← rt(15:8)</td><td></td></tr>
<tr><td>sll</td><td>rd ← rt &lt;&lt; sa</td><td></td></tr>
<tr><td>sllv</td><td>rd ← rt &lt;&lt; rs</td><td></td></tr>
<tr><td>slt</td><td>rd ← rs &lt; rt ? 1 : 0</td><td></td></tr>
<tr><td>slti</td><td>rd ← rs &lt; imm ? 1 : 0</td><td>imm is sign-extended</td></tr>
<tr><td>sltiu</td><td>rd ← rs &lt; imm ? 1 : 0</td><td>imm is sign-extended; compared as unsigned</td></tr>
<tr><td>sltu</td><td>rd ← rs &lt; rt ? 1 : 0</td><td>compared as unsigned</td></tr>
<tr><td>sra</td><td>rd ← rt &lt;&lt; sa</td><td></td></tr>
<tr><td>srav</td><td>rd ← rt &lt;&lt; rs</td><td></td></tr>
<tr><td>srl</td><td>rd ← rt &lt;&lt;&lt; sa</td><td></td></tr>
<tr><td>srlv</td><td>rd ← rt &lt;&lt;&lt; rs</td><td></td></tr>
<tr><td>sub</td><td>rd ← rs - rt</td><td></td></tr>
<tr><td>subu</td><td>rd ← rs - rt</td><td>no overflow exception</td></tr>
<tr><td>sw</td><td>MEM[rs + imm + 3] ← rt(7:0); MEM[rs + imm + 2] ← rt(15:8); MEM[rs + imm + 1] ← rt(23:16); MEM[rs + imm] ← rt(31:24)</td><td></td></tr>
<tr><td>syscall</td><td>transfer control to exception handler unconditionally</td><td></td></tr>
<tr><td>teq</td><td>if (rs == rt) trap</td><td></td></tr>
<tr><td>teqi</td><td>if (rs == imm) trap</td><td>imm is sign-extended</td></tr>
<tr><td>tge</td><td>if (rs >= rt) trap</td><td></td></tr>
<tr><td>tgei</td><td>if (rs >= imm) trap</td><td>imm is sign-extended</td></tr>
<tr><td>tgeiu</td><td>if (rs >= imm) trap</td><td>imm is sign-extended; compared as unsigned</td></tr>
<tr><td>tgeu</td><td>if (rs >= rt) trap</td><td>compared as unsigned</td></tr>
<tr><td>tlt</td><td>if (rs &lt; rt) trap</td><td></td></tr>
<tr><td>tlti</td><td>if (rs &lt; imm) trap</td><td>imm is sign-extended</td></tr>
<tr><td>tltiu</td><td>if (rs &lt; imm) trap</td><td>imm is sign-extended; compared as unsigned</td></tr>
<tr><td>tltu</td><td>if (rs &lt; rt) trap</td><td>compared as unsigned</td></tr>
<tr><td>tne</td><td>if (rs != rt) trap</td><td></td></tr>
<tr><td>tnei</td><td>if (rs != imm) trap</td><td>imm is sign-extended</td></tr>
<tr><td>xor</td><td>rd ← rs ⊕ rt</td><td></td></tr>
<tr><td>xori</td><td>rd ← rs ⊕ imm</td><td>imm is zero-extended</td></tr>
</table>

#Coprocessor 0 Instructions
---
<table>
<tr><td><b>Operation</b></td><td><b>Semantics</b></td><td><b>Notes</b></td></tr>
<tr><td>lwc0</td><td>CP0[rt] ← MEM[base + imm]</td><td>imm is sign-extended</td></tr>
<tr><td>swc0</td><td>MEM[base + imm] ← CP0[rt]</td><td>imm is sign-extended</td></tr>
<tr><td>mtc0</td><td>CP0[rt] ← rs</td><td></td></tr>
<tr><td>mfc0</td><td>rt ← CP0[rs]</td><td></td></tr>
</table>

#Coprocessor 1 (FPU) Instructions
---
<table>
<tr><td><b>Operation</b></td><td><b>Semantics</b></td><td><b>Notes</b></td></tr>
<tr><td>lwc1</td><td>FPU[ft] ← MEM[base + imm]</td><td>imm is sign-extended</td></tr>
<tr><td>mtc1</td><td>FPU[ft] ← rs</td><td></td></tr>
<tr><td>mfc1</td><td>rt ← FPU[fs]</td><td></td></tr>
<tr><td>swc1</td><td>MEM[base + imm] ← FPU[ft]</td><td>imm is sign-extended</td></tr>
<tr><td>fadd</td><td>fd ← fs + ft</td><td></td></tr>
<tr><td>fsub</td><td>fd ← fs - ft</td><td></td></tr>
<tr><td>fmul</td><td>fd ← fs * ft</td><td></td></tr>
<tr><td>fdiv</td><td>fd ← fs / ft</td><td></td></tr>
<tr><td>fabs</td><td>fd ← |fs|</td><td></td></tr>
<tr><td>fneg</td><td>fd ← -fs</td><td></td></tr>
<tr><td>fsqrt</td><td>fd ← √fs</td></tr>
<tr><td>bc1f</td><td>(cc == 0) ? PC += offset : PC++</td><td>offset is sign-extended</td></tr>
<tr><td>bc1t</td><td>(cc == 1) ? PC += offset : PC++</td><td>offset is sign-extended</td></tr>
<tr><td>ceq</td><td>cc ← (fs == ft) ? 1 : 0</td><td></td></tr>
<tr><td>cne</td><td>cc ← (fs != ft) ? 1 : 0</td><td></td></tr>
<tr><td>clt</td><td>cc ← (fs &lt; ft) ? 1 : 0</td><td></td></tr>
<tr><td>cle</td><td>cc ← (fs &lt;= ft) ? 1 : 0</td><td></td></tr>
<tr><td>cge</td><td>cc ← (fs &gt;= ft) ? 1 : 0</td><td></td></tr>
<tr><td>cgt</td><td>cc ← (fs &gt; ft) ? 1 : 0</td><td></td></tr>
<tr><td>cfc1</td><td>rt ← FPU_control[fs]</td><td></td></tr>
<tr><td>ctc1</td><td>FPU_control[ft] ← rs</td><td></td></tr>
<tr><td>fma</td><td>fd ← (fs * ft) + fr</td><td></td></tr>
<tr><td>mov</td><td>fd ← fs</td><td></td></tr>
</table>
