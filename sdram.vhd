----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    15:30:18 02/26/2017 
-- Design Name: 
-- Module Name:    sdram - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- SRAM interface for AS4C16M16S-6TCN SDRAM
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


entity sdram is
   port
   (
      --Processor Interface
      clock : in  std_logic;
      load  : in  std_logic;
      cs    : in  std_logic;
      d_in  : in  std_logic_vector (31 downto 0);
      d_out : out std_logic_vector (31 downto 0);
      addr  : in  std_logic_vector (31 downto 0);
      
      
      --SDRAM Interface
      --clock
      sdram_clk   : out std_logic; --synchronous clock input to SDRAM
      cke         : out std_logic; --clock enable (HIGH) disable (LOW)
      
      --data I/O mask: controls output buffers in read mode and masks input data in write mode
      udqm  : out std_logic; --upper byte mask
      ldqm  : out std_logic; --lower byte mask
      
      --enable/disable signals
      --control signals: ba0, ba1, cs, ras#, cas#, and we#
      ba       : out std_logic_vector (1 downto 0); --bank activate "00" => A, "01" => B, etc.
      sdram_cs : out std_logic; --enables/disables command decoder
      ras      : out std_logic; --row address strobe
      cas      : out std_logic; --column address strobe
      we       : out std_logic; --write enable
      
      --address/data
      ram_addr     : out std_logic_vector (12 downto 0); --address inputs
      ram_data_in  : in  std_logic_vector (15 downto 0); --data input
      ram_data_out : out std_logic_vector (15 downto 0)  --data output
   );
end sdram;

architecture behavioral of sdram is

   type fsm_states is (idle, refresh, rowactivate, read, write);

begin


end behavioral;

