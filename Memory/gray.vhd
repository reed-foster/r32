-- Reed Foster Jun 2016
-- gray.vhd - a gray to binary and binary to gray converter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gray is
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
end entity;

architecture behavioral of gray is

    signal binarytemp : unsigned (bitwidth - 1 downto 0);
    signal graytemp : std_logic_vector (bitwidth - 1 downto 0);

begin
    
    gen_conv : for i in 0 to bitwidth - 1 generate
        g2b : if mode = "g2b" generate
            g2b_msb : if i = 0 generate
                binarytemp(bitwidth - 1) <= d_in(bitwidth - 1);
            end generate g2b_msb;
            g2b_lsbs : if i > 0 generate
                binarytemp(bitwidth - 1 - i) <= binarytemp(bitwidth - i) xor d_in(bitwidth - 1 - i);
            end generate g2b_lsbs;
        end generate g2b;

        b2g : if mode = "b2g" generate
            b2g_msb : if i = 0 generate
                graytemp(bitwidth - 1) <= d_in(bitwidth - 1);
            end generate b2g_msb;
            b2g_lsbs : if i > 0 generate
                graytemp(bitwidth - 1 - i) <= d_in(bitwidth - i) xor d_in(bitwidth - 1 - i);
            end generate b2g_lsbs;
        end generate b2g;
    end generate gen_conv;

end behavioral;