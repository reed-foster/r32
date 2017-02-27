----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    10:02:44 02/26/2017 
-- Design Name: 
-- Module Name:    shifter - dataflow 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- 32bit barrel shifter, supports sll, srl, sra
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- 
-- func mappings
-- sll => "00"
-- srl => "01"
-- sra => "10"
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;


entity shifter32 is
   port
   (
      a     : in  std_logic_vector (31 downto 0);
      shamt : in  std_logic_vector (4 downto 0);
      func  : in  std_logic_vector (1 downto 0);
      res   : out std_logic_vector (31 downto 0)
   );
end shifter32;

architecture dataflow of shifter32 is
   signal shift16 : std_logic_vector (31 downto 0);
   signal shift8  : std_logic_vector (31 downto 0);
   signal shift4  : std_logic_vector (31 downto 0);
   signal shift2  : std_logic_vector (31 downto 0);
   signal shift1  : std_logic_vector (31 downto 0);
   
begin
   
   shift16 <=  a when (shamt(4) = '0') else
               a(15 downto 0) & (15 downto 0 => '0') when func = "00" else
               (15 downto 0 => '0') & a(31 downto 16) when func = "01" else
               (15 downto 0 => a(31)) & a(31 downto 16) when func = "10" else a;
   shift8  <=  shift16 when shamt(3) = '0' else
               shift16(23 downto 0) & (7 downto 0 => '0') when func = "00" else
               (7 downto 0 => '0') & shift16(31 downto 8) when func = "01" else
               (7 downto 0 => shift16(31)) & shift16(31 downto 8) when func = "10" else a;
   shift4  <=  shift8 when shamt(2) = '0' else
               shift8(27 downto 0) & (3 downto 0 => '0') when func = "00" else
               (3 downto 0 => '0') & shift8(31 downto 4) when func = "01" else
               (3 downto 0 => shift8(31)) & shift16(31 downto 4) when func = "10" else a;
   shift2  <=  shift4 when shamt(1) = '0' else
               shift4(29 downto 0) & (1 downto 0 => '0') when func = "00" else
               (1 downto 0 => '0') & shift4(31 downto 2) when func = "01" else
               (1 downto 0 => shift4(31)) & shift4(31 downto 2) when func = "10" else a;
   shift1  <=  shift2 when shamt(0) = '0' else
               shift2(30 downto 0) & '0' when func = "00" else
               '0' & shift2(31 downto 1) when func = "01" else
               shift2(31) & shift2(31 downto 1) when func = "10" else a;
   
   res <= shift1;

end dataflow;

