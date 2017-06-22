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
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

entity cache_bram is
    generic
    (
        size : integer range 2 to 8 --number of 2KB BRAMs
    );
    port
    (
        clock_in : in  std_logic;
        store    : in  std_logic;
        enable   : in  std_logic;
        address  : in  std_logic_vector ((integer(ceil(log2(real(size)))) + 8) downto 0);
        data_in  : in  std_logic_vector (15 downto 0);
        data_out : out std_logic_vector (15 downto 0)
    );
end entity;

architecture structural of cache_bram is

    type dout_bus_type is array (0 to size - 1) of std_logic_vector (15 downto 0);

    signal dout_bus : dout_bus_type;

    signal ramselect   : integer;
    signal ramselectoh : std_logic_vector (size - 1 downto 0); --one-hot encoded selector

    signal blockaddr : std_logic_vector (10 downto 0);

begin
    
    gen_ram: for i in 0 to size generate
        ram : RAMB16BWER --1K x 18: 16 data + 2 parity (unused)
        generic map --configuration of mode of block ram
        (
            DATA_WIDTH_A => 18,
            DOA_REG => 0,
            RSTTYPE => SYNC
        )
        port map
        (
            --Port A
            dia => data_in, --data in
            dipa => '0', --data in parity (additional storage space, no actual parity logic in bram)
            addra => blockaddr, --address
            wea => store, --write enable
            ena => ramselectoh(i), --enable (enables/disables read, write, and reset of bram)
            regcea => '0', --enables latching of data to output register
            rsta => '0', --
            clka => clock_in,
            doa => dout_bus(i),
            dopa => open,
            --Port B (not connected)
            dib => open, dipb => open, addrb => open, web => '0', enb => '0',
            regceb => '0', rstb => '0', clkb => '0', dob => open, dopb => open
        );
    end generate gen_ram;

    ramselect <= to_integer(unsigned(address(integer(ceil(log2(real(size)))) + 8 downto 8)));
    ramselectoh <= (size - 1 downto 1 => '0') & '1' sll ramselect;
    data_out <= dout_bus(ramselect);

end structural;