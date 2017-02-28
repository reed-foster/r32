----------------------------------------------------------------------------------
-- Company:
-- Engineer: Reed Foster
--
-- Create Date:    18:46:02 02/20/2017
-- Design Name:
-- Module Name:    adder - structural
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Generic adder with a "mode" input to select addition or subtraction
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity adder is
   generic
   (
      bits : integer := 32
   );
   port
   (
      mode  : in  std_logic;
      a     : in  std_logic_vector (bits - 1 downto 0);
      b     : in  std_logic_vector (bits - 1 downto 0);
      sum   : out std_logic_vector (bits - 1 downto 0);
      over  : out std_logic
   );
end adder;

architecture structural of adder is

   component fadd is
      port
      (
         c_in  : in  std_logic;
         a     : in  std_logic;
         b     : in  std_logic;
         sum   : out std_logic;
         c_out : out std_logic
      );
   end component fadd;
   
   signal carry_internal : std_logic_vector(bits downto 0);
   
   signal b_tmp : std_logic_vector(bits - 1 downto 0);
   
begin
   
   adders : for n in 0 to bits - 1 generate
      
      fulladder : fadd
         port map
         (
            a     => a(n),
            b     => b_tmp(n),
            c_in  => carry_internal(n),
            sum   => sum(n),
            c_out => carry_internal(n + 1)
         );
   end generate;
   
   
   b_tmp <= (bits - 1 downto 0 => mode) xor b;
   
   carry_internal(0) <= mode;
   
   over <= carry_internal(bits) xor carry_internal(bits - 1);
   
end structural;

