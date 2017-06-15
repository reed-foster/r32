----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    13:24:20 06/14/2017 
-- Design Name: 
-- Module Name:    core - structural 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- CPU core
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

entity core is
    port
    (
        clock           : in  std_logic;
        i_cache_disable : in  std_logic;
        d_cache_disable : in  std_logic;
        programcounter  : out std_logic_vector (31 downto 0);
        instruction     : in  std_logic_vector (31 downto 0);
        address         : out std_logic_vector (31 downto 0);
        data_to_ram     : out std_logic_vector (31 downto 0);
        data_from_ram   : in  std_logic_vector (31 downto 0);
        ram_read        : out std_logic;
        ram_write       : out std_logic
    );
end core;

architecture structural of core is

begin

end structural;