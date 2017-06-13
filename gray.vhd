----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    15:18:18 06/12/2017 
-- Design Name: 
-- Module Name:    gray - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- gray counter with binary and gray-code output (as well as an overflow bit)
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

entity gray is
    port
    (
        clock    : in  std_logic;
        enable   : in  std_logic;
        binary   : out std_logic_vector (8 downto 0);
        gray_out : out std_logic_vector (8 downto 0);
        overflow : out std_logic
    );
end entity;

architecture behavioral of gray is
    
    signal count : unsigned (8 downto 0) := (8 downto 0 => '0'); --stores temporary value of counter
    signal countnext : unsigned (8 downto 0);
    signal binaryinc : unsigned (8 downto 0);
    signal binarytemp : std_logic_vector (8 downto 0);

begin

    update : process (clock, enable, count)
    begin
        if rising_edge(clock) then
            if (enable = '1') then
                count <= countnext;
            end if;
        end if;
    end process;

    -- gray to binary conversion
    binarytemp(8) <= count(8);
    binarytemp(7) <= binarytemp(8) xor count(7);
    binarytemp(6) <= binarytemp(7) xor count(6);
    binarytemp(5) <= binarytemp(6) xor count(5);
    binarytemp(4) <= binarytemp(5) xor count(4);
    binarytemp(3) <= binarytemp(4) xor count(3);
    binarytemp(2) <= binarytemp(3) xor count(2);
    binarytemp(1) <= binarytemp(2) xor count(1);
    binarytemp(0) <= binarytemp(1) xor count(0);

    binaryinc <= binarytemp + 1;
    overflow <= binarytemp(0) and binarytemp(1) and binarytemp(2) and binarytemp(3) and binarytemp(4) and binarytemp(5) and binarytemp(6) and binarytemp(7) and binarytemp(8);

    -- binary to gray conversion
    countnext(8) <= binaryinc(8);
    countnext(7) <= binaryinc(8) xor binaryinc(7);
    countnext(6) <= binaryinc(7) xor binaryinc(6);
    countnext(5) <= binaryinc(6) xor binaryinc(5);
    countnext(4) <= binaryinc(5) xor binaryinc(4);
    countnext(3) <= binaryinc(4) xor binaryinc(3);
    countnext(2) <= binaryinc(3) xor binaryinc(2);
    countnext(1) <= binaryinc(2) xor binaryinc(1);
    countnext(0) <= binaryinc(1) xor binaryinc(0);

    gray_out <= std_logic_vector(count);
    binary <= std_logic_vector(binarytemp);

end behavioral;