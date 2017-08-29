-- Reed Foster Aug 2017
-- fifoasync_tb.vhd - Testbench for fifoasync.vhd

library ieee;
use ieee.std_logic_1164.all;

entity fifoasync_tb is
end entity;

architecture test of fifoasync_tb is

    component fifoasync is
        generic
        (
            bitwidth : integer range 1 to 32 := 32;
            depth_addrwidth : integer range 1 to 9 := 3;
            delay : integer range 2 to 5 := 2
        );
        port
        (
            wrt_clock   : in  std_logic;
            rd_clock    : in  std_logic;
            enqueue     : in  std_logic;
            dequeue     : in  std_logic;
            d_in        : in  std_logic_vector(bitwidth - 1 downto 0);
            d_out       : out std_logic_vector(bitwidth - 1 downto 0)
        );
    end component;

    signal wrt_clock, rd_clock : std_logic := '0';
    constant wrt_clock_period : time := 37000 ps;
    constant rd_clock_period : time := 15000 ps;

    signal enqueue, dequeue : std_logic := '0';
    signal d_in : std_logic_vector (3 downto 0) := "0000";
    signal d_out : std_logic_vector (3 downto 0);

    type test_array_type is array (0 to 7) of std_logic_vector (3 downto 0);

    constant test_data : test_array_type := ("0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000");
    signal test_pointer : integer range 0 to 7 := 0;

begin

    uut : fifoasync
        generic map (bitwidth => 4, depth_addrwidth => 3, delay => 2)
        port map (wrt_clock, rd_clock, enqueue, dequeue, d_in, d_out);

    wrt_clock_process : process
    begin
        wrt_clock <= '0';
        wait for wrt_clock_period / 2;
        wrt_clock <= '1';
        wait for wrt_clock_period / 2;
    end process;

    rd_clock_process : process
    begin
        rd_clock <= '0';
        wait for rd_clock_period / 2;
        rd_clock <= '1';
        wait for rd_clock_period / 2;
    end process;

    output_generation : process (wrt_clock)
    begin
        if falling_edge(wrt_clock) then
            if test_pointer = 7 then
                test_pointer <= 0;
            else
                test_pointer <= test_pointer + 1;
            end if;
        end if;
    end process;

    enq_deq_process : process (wrt_clock, rd_clock)
    begin
        if falling_edge(wrt_clock) then
            if test_pointer = 4 then
                enqueue <= not enqueue;
            end if;
        end if;
        if falling_edge(rd_clock) then
            if test_pointer = 4 then
                dequeue <= not dequeue;
            end if;
        end if;
    end process;

    d_in <= test_data(test_pointer);

end architecture;