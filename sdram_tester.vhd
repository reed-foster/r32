--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:35:16 05/31/2017
-- Design Name:   
-- Module Name:   /home/reed/xilinx_projects/r32/sdram_tester.vhd
-- Project Name:  r32
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sdram
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
 
entity sdram_tester is
port
(
    clock50 : in  std_logic;
    leds    : out std_logic_vector (7 downto 0);

    udqm : out std_logic;
    sdram_clk : out std_logic;
    cke : out std_logic;
    ba : out std_logic_vector (1 downto 0);
    sdram_cs : out std_logic;
    ras : out std_logic;
    cas : out std_logic;
    we : out std_logic;
    ldqm : out std_logic;
    ram_addr : out std_logic_vector (12 downto 0);
    ram_data : inout std_logic_vector (15 downto 0)
);
end sdram_tester;

architecture behavior of sdram_tester is 
 
    -- component declaration for the unit under test (uut)

    type tester_states is (wrt, rd, idle);

    signal tester : tester_states := wrt;
 
    component sdram
    port(
        clock : in  std_logic;
        read_req : in  std_logic;
        write_req : in  std_logic;
        cs : in  std_logic;
        d_in : in  std_logic_vector (15 downto 0);
        d_out : out  std_logic_vector (15 downto 0);
        addr : in  std_logic_vector (23 downto 0);
        read_ready : out  std_logic;
        write_ready : out  std_logic;
        rd_from_buff : in  std_logic;
        wrt_to_buff : in  std_logic;
        sdram_clk : out  std_logic;
        cke : out  std_logic;
        udqm : out  std_logic;
        ldqm : out  std_logic;
        ba : out  std_logic_vector(1 downto 0);
        sdram_cs : out  std_logic;
        ras : out  std_logic;
        cas : out  std_logic;
        we : out  std_logic;
        ram_addr : out  std_logic_vector (12 downto 0);
        ram_data_in : out  std_logic_vector (15 downto 0);
        ram_data_out : in  std_logic_vector (15 downto 0)
        );
    end component;


    --inputs
    signal read_req : std_logic := '0';
    signal write_req : std_logic := '0';
    signal rd_from_buff : std_logic := '0';
    signal wrt_to_buff : std_logic := '0';
    signal ram_data_out : std_logic_vector (15 downto 0) := (others => '0');

    --outputs
    signal d_out : std_logic_vector (15 downto 0);
    signal read_ready : std_logic;
    signal write_ready : std_logic;
    signal ram_data_in : std_logic_vector (15 downto 0);

    signal wrt_timer : integer := 512;
 
begin

    uut: sdram
    port map (
        clock => clock50,
        read_req => read_req,
        write_req => write_req,
        cs => '1',
        d_in => x"abcd",
        d_out => d_out,
        addr => x"000000",
        read_ready => read_ready,
        write_ready => write_ready,
        rd_from_buff => rd_from_buff,
        wrt_to_buff => wrt_to_buff,
        sdram_clk => sdram_clk,
        cke => cke,
        udqm => udqm,
        ldqm => ldqm,
        ba => ba,
        sdram_cs => sdram_cs,
        ras => ras,
        cas => cas,
        we => we,
        ram_addr => ram_addr,
        ram_data_in => ram_data_in,
        ram_data_out => ram_data_out
    );

    testfsm : process (clock50, tester)
    begin
        if rising_edge(clock50) then
            case tester is
                when wrt =>
                    if (wrt_timer > 0) then
                        wrt_timer <= wrt_timer - 1;
                    else
                        tester <= rd;
                    end if;
                when rd => tester <= idle;
                when idle => tester <= idle;
            end case;
        end if;
    end process;

    fsmcomb : process (tester)
    begin
        case tester is
            when wrt =>
                if wrt_timer = 512 then
                    write_req <= '1';
                else
                    write_req <= '0';
                end if;
                wrt_to_buff <= '1';
            when rd =>
                read_req <= '1';
            when idle =>
                read_req <= '0';
                rd_from_buff <= '1';
        end case;
    end process;

    latchdata : process (clock50, read_ready)
    begin
        if rising_edge(clock50) and read_ready = '1' then
            leds <= d_out (7 downto 0);
        end if;
    end process;

    ram_data <= ram_data_in when write_ready = '1' else (others => 'Z');
    ram_data_out <= ram_data;
end;
