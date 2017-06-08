----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    14:09:00 05/30/2017 
-- Design Name: 
-- Module Name:    fifo_dualclock - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- FIFO with separate read and write clocks
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

entity fifo_dualclock is
    generic
    (
        depth : integer range 1 to 512 := 8; --must be power of 2
        bitwidth : integer range 1 to 32 := 32
    );
    port
    (
        enqueue_clk   : in  std_logic;
        dequeue_clk   : in  std_logic;
        enqueue_en    : in  std_logic;
        dequeue_en    : in  std_logic;
        d_in          : in  std_logic_vector (bitwidth - 1 downto 0);
        d_out         : out std_logic_vector (bitwidth - 1 downto 0);
        empty         : out std_logic
    );
end entity;

architecture behavioral of fifo_dualclock is

    type queue is array (0 to depth - 1) of std_logic_vector (bitwidth - 1 downto 0);
    signal data : queue := (0 to depth - 1 => (bitwidth - 1 downto 0 => '0'));

    constant counter_width : unsigned := integer(ceil(log2(real(depth))));
    signal read_ptr, write_ptr : unsigned (counter_width - 1 downto 0) := 0;

    signal almostempty, almostfull : std_logic;

begin

    ------------------
    -- Enqueue
    ------------------

    enqueue_proc : process(enqueue_en, enqueue_clk)
    begin
        if rising_edge(enqueue_clk) then
            if enqueue_en = '1' then
                
            end if;
        end if;
    end process;

    ------------------
    -- Dequeue
    ------------------

    dequeue_proc : process(dequeue_en, dequeue_clk)
    begin
        if rising_edge(dequeue_clk) then
            if dequeue_en = '1' then

            end if;
        end if;
    end process;

end behavioral;