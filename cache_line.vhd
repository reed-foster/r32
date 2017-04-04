----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    16:54:25 04/02/2017 
-- Design Name: 
-- Module Name:    line_cache - behavioral 
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

entity cache_line is
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
end cache_line;

architecture behavioral of cache is
   type line_type is record
      tag  : std_logic_vector(21 downto 0);
      data : array (0 to 1024) of std_logic_vector(7 downto 0);
   signal ram : line_type;
   signal empty : std_logic;
begin


end behavioral;

