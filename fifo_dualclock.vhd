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
        d_in          : in  std_logic_vector (15 downto 0);
        d_out         : out std_logic_vector (15 downto 0);
        empty         : out std_logic
    );
end entity;

architecture behavioral of fifo_dualclock is

    type queue is array (0 to 511) of std_logic_vector (15 downto 0);
    signal data : queue := (0 to 511 => (15 downto 0 => '0'));

    signal read_ptr, write_ptr : std_logic_vector (8 downto 0);

    signal enqueue, dequeue : std_logic := '0';
    signal full, empty : std_logic;

    component gray
        port
        (
            clock    : in  std_logic;
            enable   : in  std_logic;
            binary   : out std_logic_vector (8 downto 0);
            gray_out : out std_logic_vector (8 downto 0);
            overflow : out std_logic
        );
    end component;

begin

    enqueue_counter : gray
    port map
    (
        clock => enqueue_clk,
        enable => enqueue,
        binary =>,
        gray_out =>,
        overflow =>
    );

    dequeue_counter : gray
    port map
    (
        clock => dequeue_clk,
        enable => dequeue,
        binary =>,
        gray_out =>,
        overflow =>
    );

    enqueue <= enqueue_en and (not full);
    dequeue <= dequeue_en and (not empty);

end behavioral;