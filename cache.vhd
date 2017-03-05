----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:24:25 02/28/2017 
-- Design Name: 
-- Module Name:    cache - behavioral 
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

entity cache is
   port
   (
      data_in  : in  std_logic_vector (31 downto 0);
      data_out : out std_logic_vector (31 downto 0);
      address  : in  std_logic_vector (31 downto 0);
      hit      : out std_logic;
      
      clk      : in  std_logic;
      proc_wrt : in  std_logic;
      proc_en  : in  std_logic
   );
end cache;

architecture behavioral of cache is
   type line_type is array (0 to 255) of 
      std_logic_vector(31 downto 0);
   type cache_type is array (0 to 31) of
      line_type;
begin


end behavioral;

