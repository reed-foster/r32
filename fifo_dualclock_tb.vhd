--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:18:25 06/13/2017
-- Design Name:   
-- Module Name:   /home/reed/xilinx_projects/r32/fifo_dualclock_tb.vhd
-- Project Name:  r32
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fifo_dualclock
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
 
entity fifo_dualclock_tb is
end fifo_dualclock_tb;
 
architecture behavior of fifo_dualclock_tb is

    component fifo_dualclock
    port(
        enqueue_clk : in  std_logic;
        dequeue_clk : in  std_logic;
        enqueue_en : in  std_logic;
        dequeue_en : in  std_logic;
        d_in : in  std_logic_vector(15 downto 0);
        d_out : out  std_logic_vector(15 downto 0);
        status : out  std_logic_vector(1 downto 0)
        );
    end component;
    

    --inputs
    signal enqueue_clk : std_logic := '0';
    signal dequeue_clk : std_logic := '0';
    signal enqueue_en : std_logic := '0';
    signal dequeue_en : std_logic := '0';
    signal d_in : std_logic_vector(15 downto 0) := (others => '0');

    --outputs
    signal d_out : std_logic_vector(15 downto 0);
    signal status : std_logic_vector(1 downto 0);

    -- clock period definitions
    constant enqueue_clk_period : time := 50 ns;
    constant dequeue_clk_period : time := 40 ns;
 
begin
 
    -- instantiate the unit under test (uut)
    uut: fifo_dualclock
    port map
    (
        enqueue_clk => enqueue_clk,
        dequeue_clk => dequeue_clk,
        enqueue_en => enqueue_en,
        dequeue_en => dequeue_en,
        d_in => d_in,
        d_out => d_out,
        status => status
    );

    -- clock process definitions
    enqueue_clk_process :process
    begin
        enqueue_clk <= '0';
        wait for enqueue_clk_period/2;
        enqueue_clk <= '1';
        wait for enqueue_clk_period/2;
    end process;
 
    dequeue_clk_process :process
    begin
        dequeue_clk <= '0';
        wait for dequeue_clk_period/2;
        dequeue_clk <= '1';
        wait for dequeue_clk_period/2;
    end process;
 

    -- stimulus process
    stim_proc: process
    begin
        wait for 100 ns;
        enqueue_en <= '1';
        d_in <= x"dead";
        wait for 50 ns;
        d_in <= x"beef";
        wait for 50 ns;
        d_in <= x"abcd";
        wait for 50 ns;
        d_in <= x"0123";
        wait for 50 ns;
        enqueue_en <= '0';
        dequeue_en <= '1';
        wait;
    end process;

end;
