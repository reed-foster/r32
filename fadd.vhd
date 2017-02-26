----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:03:42 02/20/2017 
-- Design Name: 
-- Module Name:    fadd - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx primitives in this code.
--library unisim;
--use unisim.vcomponents.all;

entity fadd is
   port
   (
      c_in  : in  std_logic;
      a     : in  std_logic;
      b     : in  std_logic;
      sum   : out std_logic;
      c_out : out std_logic
   );
end fadd;

architecture behavioral of fadd is
   signal sum_partial : std_logic;
begin
   
   sum_partial <= a xor b;
   c_out <= (a and b) or (c_in and sum_partial);
   sum <= sum_partial xor c_in;

end behavioral;

