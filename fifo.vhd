----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    22:05:00 04/29/2017 
-- Design Name: 
-- Module Name:    fifo - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Generic FIFO
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

entity fifo is
    generic
    (
        depth : integer range 1 to 512 := 8,
        bitwidth : integer range 1 to 32 := 32
    );
    port
    (
        clock   : in  std_logic;
        enqueue : in  std_logic;
        dequeue : in  std_logic;
        d_in    : in  std_logic_vector (bitwidth - 1 downto 0);
        d_out   : out std_logic_vector (bitwidth - 1 downto 0);
        empty   : out std_logic
    );
end entity;

architecture behavioral of fifo is
    type queue is array (0 to depth - 1) of std_logic_vector (bitwidth - 1 downto 0);

    signal data : queue := (0 to depth - 1 => (bitwidth - 1 downto 0 => '0'));

    signal read_addr : integer range 0 to depth - 1:= 0;
    signal write_addr : integer range 0 to depth - 1 := 0;

    signal read_ctr_overflowed : std_logic := '0';
    signal write_ctr_overflowed : std_logic := '0';

    signal full : std_logic := '0';
    signal empty_tmp : std_logic := '1';

    signal d_out_buff : std_logic_vector (bitwidth - 1 downto 0) := (bitwidth - 1 downto 0 => '0');

begin

    process (clock, enqueue, dequeue, d_in, full, empty_tmp)
    begin
        if rising_edge(clock)
            if enqueue = '1' and full /= '1' then
                data(write_addr) <= d_in;
                write_addr <= write_addr + 1;
                if write_addr >= depth then
                    write_addr <= 0;
                    write_ctr_overflowed <= not write_ctr_overflowed;
                end if;
            end if;
            if dequeue = '1' and empty_tmp /= '1' then
                d_out_buff <= data(read_addr);
                read_addr <= read_addr + 1;
                if read_addr >= depth then
                    read_addr <= 0;
                    read_ctr_overflowed <= not read_ctr_overflowed;
                end if;
            end if;
        end if;
    end process;

    full <= '1' when read_addr = write_addr and read_ctr_overflowed /= write_ctr_overflowed else '0';
    empty_tmp <= '1' when read_addr = write_addr and read_ctr_overflowed = write_ctr_overflowed else '0';
    empty <= empty_tmp;

    d_out <= d_out_buff;

end behavioral;