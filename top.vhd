----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    16:15:44 06/05/2017 
-- Design Name: 
-- Module Name:    top - structural 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Top level component of CPU hierarchy
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

entity top is
    port
    (
        --clock in
        clock50 : std_logic;

        --sdram interface
        sdram_clk : out std_logic; --synchronous clock input to SDRAM
        cke       : out std_logic; --clock enable (HIGH) disable (LOW)
        udqm : out std_logic;
        ldqm : out std_logic;
        ba       : out std_logic_vector (1 downto 0); --bank activate "00" => A, "01" => B, etc.
        sdram_cs : out std_logic; --enables/disables command decoder
        ras      : out std_logic; --row address strobe
        cas      : out std_logic; --column address strobe
        we       : out std_logic; --write enable
        ram_addr     : out std_logic_vector (12 downto 0); --address inputs
        ram_data     : inout std_logic_vector (15 downto 0) --data input
    );
end top;

architecture structural of top is

begin

end structural;
