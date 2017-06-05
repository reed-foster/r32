----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    10:38:42 06/02/2017 
-- Design Name: 
-- Module Name:    cache_bram - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Block ram interface for cache memory
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

entity cache_bram is
    port
    (
        clock_in : in  std_logic;
        store    : in  std_logic;
        enable   : in  std_logic;
        address  : in  std_logic_vector (10 downto 0);
        data_in  : in  std_logic_vector (7 downto 0);
        data_out : out std_logic_vector (7 downto 0)
    );
end entity;

architecture structural of cache_bram is

begin
    
    ram0 : RAMB16BWER --2K x 9: 8 data + 1 parity (unused)
    generic map --configuration of mode of block ram
    (
        DATA_WIDTH_A => 9;
        DOA_REG => 0;
        RSTTYPE => SYNC
    )
    port map
    (
        --Port A
        dia => data_in, --data in
        dipa => '0', --data in parity (additional storage space, no actual parity logic in bram)
        addra => address, --address
        wea => store, --write enable
        ena => enable, --enable (enables/disables read, write, and reset of bram)
        regcea => '0', --enables latching of data to output register
        rsta => '0', --
        clka => clock_in,
        doa => data_out,
        dopa => open,
        --Port B (not connected)
        dib => open, dipb => open, addrb => open, web => '0', enb => '0',
        regceb => '0', rstb => '0', clkb => '0', dob => open, dopb => open
    );

end structural;