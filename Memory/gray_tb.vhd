-- Reed Foster Aug 2017
-- gray_tb.vhd - A testbench module for binary to gray converter gray.vhd

library ieee;
use ieee.std_logic_1164.all;

entity gray_tb is
end entity;

architecture test of gray_tb is

    component gray is
        generic
        (
            mode : string; --"g2b" or "b2g"
            bitwidth : integer range 1 to 16
        );
        port
        (
            d_in  : in  std_logic_vector (bitwidth - 1 downto 0);
            d_out : out std_logic_vector (bitwidth - 1 downto 0)
        );
    end component;

    signal b2g_din, b2g_dout, g2b_din, g2b_dout : std_logic_vector (2 downto 0);

begin
    
    b2g : gray
        generic map (mode => "b2g", bitwidth => 3)
        port map (d_in => b2g_din, d_out => b2g_dout);

    g2b : gray
        generic map (mode => "g2b", bitwidth => 3)
        port map (d_in => g2b_din, d_out => g2b_dout);

    process
        type test_array is array(0 to 7) of std_logic_vector(2 downto 0);
        constant b2g_test : test_array := ("000", "001", "010", "011", "100", "101", "110", "111");
        constant b2g_res : test_array := ("000", "001", "011", "010", "110", "111", "101", "100");
        constant g2b_test : test_array := b2g_res;
        constant g2b_res : test_array := b2g_test;
    begin
        for i in 0 to 7 loop
            b2g_din <= b2g_test(i);
            g2b_din <= g2b_test(i);
            wait for 1 ns;
            assert b2g_dout = b2g_res(i)
                report "b2g failed" severity error;
            assert g2b_dout = g2b_res(i)
                report "g2b failed" severity error;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end test;