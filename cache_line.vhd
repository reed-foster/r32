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
use ieee.numeric_std.all;

entity cache_line is
   port
   (
      mode     : in  std_logic_vector (2 downto 0); --0 => u_byte, 1 => byte, 2 => u_hword, 3 => hword, 4 => word
      data_in  : in  std_logic_vector (31 downto 0);
      data_out : out std_logic_vector (31 downto 0);
      address  : in  std_logic_vector (31 downto 0);
      hit      : out std_logic;
      clk      : in  std_logic;
      wrt      : in  std_logic;
      set_tag  : in  std_logic
   );
end cache_line;

architecture behavioral of cache is
   signal tag  : std_logic_vector(21 downto 0);
   signal data : array (0 to 1024) of std_logic_vector(7 downto 0);
   signal empty : std_logic;
   signal wordout : std_logic_vector(31 downto 0);
begin
   
   updatetag : process(clk)
   begin
      if (rising_edge(clk)) then
         if (set_tag = '1') then
            tag <= address(31 downto 10)
         end if;
      end if;
   end updatetag;

   --little endian encoding for words/halfwords (lsb stored first)
   wrt_data : process(clk)
   begin
      if (rising_edge(clk)) then
         if ((wrt or set_tag) = '1') then
            data(to_integer(unsigned(address(9 downto 0)))) <= data_in(7 downto 0);
            if (not (mode = "000" or mode = "001")) then
               data(to_integer(unsigned(address(9 downto 0))) + 1) <= data_in(15 downto 8);
            end if;
            if (mode = "100") then
               data(to_integer(unsigned(address(9 downto 0))) + 2) <= data_in(23 downto 16);
               data(to_integer(unsigned(address(9 downto 0))) + 3) <= data_in(31 downto 24);
            end if;
         end if;
      end if;
   end wrt_data;

   hit <= ('1' when (address(31 downto 10) = tag) else '0') and (not empty);

   --little endian encoding for words/halfwords (lsb stored first)
   word_out <= (31 downto 8 => mode(0)) & data(to_integer(unsigned(address(9 downto 0)))) when (mode = "000" or mode = "001")
         else  (31 downto 16 => mode(0)) & data(to_integer(unsigned(address(9 downto 0))) + 1) & data(to_integer(unsigned(address(9 downto 0)))) when (mode = "010" or mode = "011")
         else  data(to_integer(unsigned(address(9 downto 0))) + 3) & data(to_integer(unsigned(address(9 downto 0))) + 2) & data(to_integer(unsigned(address(9 downto 0))) + 1) & data(to_integer(unsigned(address(9 downto 0)))) when (mode = "100")
         else  (31 downto 0 => '0');

   data_out <= (31 downto 0 => '0') when (not hit) else wordout;

end behavioral;

