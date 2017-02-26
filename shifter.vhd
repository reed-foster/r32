----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:02:44 02/26/2017 
-- Design Name: 
-- Module Name:    shifter - dataflow 
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
use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx primitives in this code.
--library unisim;
--use unisim.vcomponents.all;

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
   signal lleft   : std_logic_vector (31 downto 0);
   signal lright  : std_logic_vector (31 downto 0);
   signal aright  : std_logic_vector (31 downto 0);
   
   signal int_sa  : integer;
   
begin
   
   int_sa <= to_integer(unsigned(shamt));
   
   lleft <= a((31 - int_sa) downto 0) & (int_sa - 1 downto 0 => '0') when int_sa > 0 else a;
   lright <= (int_sa - 1 downto 0 => '0') & a(31 downto int_sa) when int_sa > 0 else a;
   aright <= (int_sa - 1 downto 0 => a(31)) & a(31 downto int_sa) when int_sa > 0 else a;
   
   with func select
      res <=   lleft when "00",
               lright when "01",
               aright when "10",
               a when others;

end dataflow;

