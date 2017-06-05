----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    11:01:53 04/26/2017 
-- Design Name: 
-- Module Name:    usb_interface - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- FIFO interface for FT2232H
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity usb_interface is
    generic
    (
        depth : integer range 1 to 256 := 256
    );
    port
    (
        --Processor Interface
        data_in  : in  std_logic_vector (7 downto 0);
        data_out : out std_logic_vector (7 downto 0);
        empty    : out std_logic;
        clock    : in  std_logic;
        
        --FT2232H Interface
        d_tx     : out std_logic_vector (7 downto 0);
        d_rx     : in  std_logic_vector (7 downto 0);
        cs_n     : out std_logic;
        a0       : out std_logic;
        rd_n     : out std_logic;
        wr_n     : out std_logic
    );
end usb_interface;
