----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    16:39:56 02/20/2017 
-- Design Name: 
-- Module Name:    alu - dataflow 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- 32 bit ALU that supports several operations including add, su
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
-- opcode mappings
--  add  => 0110
--  and  => 1000
--  comp => 1100
--  sll  => 0000
--  sllv => 0001
--  nor  => 1011
--  or   => 1001
--  sra  => 0100
--  srav => 0101
--  srl  => 0010
--  srlv => 0011
--  xor  => 1010
--  sub  => 0111
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity alu is
    port
    (
        a           : in  std_logic_vector (31 downto 0);
        b           : in  std_logic_vector (31 downto 0);
        opcode      : in  std_logic_vector (3 downto 0);
        shamt       : in  std_logic_vector (4 downto 0);
        compare     : in  std_logic_vector (3 downto 0);
        output      : out std_logic_vector (31 downto 0);
        exception   : out std_logic
    );
end alu;

architecture dataflow of alu is
    signal sum_diff   : std_logic_vector (31 downto 0);
    signal addermode  : std_logic;

    signal shift_func       : std_logic_vector (1 downto 0);
    signal shiftout         : std_logic_vector (31 downto 0);
    signal internal_shamt   : std_logic_vector (4 downto 0);

    signal comp_res   : std_logic;
    signal equal      : std_logic;
    signal greater    : std_logic;
    signal greater_eq : std_logic;

    component adder is
        generic (bits : integer);
        port
        (
            mode  : in  std_logic;
            a     : in  std_logic_vector (bits - 1 downto 0);
            b     : in  std_logic_vector (bits - 1 downto 0);
            sum   : out std_logic_vector (bits - 1 downto 0);
            over  : out std_logic
        );
    end component adder;
    
    component shifter32 is
        port
        (
            a     : in  std_logic_vector (31 downto 0);
            shamt : in  std_logic_vector (4 downto 0);
            func  : in  std_logic_vector (1 downto 0);
            res   : out std_logic_vector (31 downto 0)
        );
    end component shifter32;
   
begin

    shift_unit : shifter32
        port map
        (
            a => a,
            shamt => internal_shamt,
            func => shift_func,
            res => shiftout
        );

    add_sub : adder
        generic map (bits => 32)
        port map
        (
            mode  => addermode,
            a     => a,
            b     => b,
            sum   => sum_diff,
            over  => exception
        );
   
    shift_func <= "00" when opcode(3 downto 1) = "000" else
                  "01" when opcode(3 downto 1) = "001" else
                  "10" when opcode(3 downto 1) = "010" else
                  "11";
   
    internal_shamt <= b(4 downto 0) when opcode(0) = '1' else shamt;
   
    addermode <= '1' when (opcode = "0111") else '0';
   
    equal <= '1' when (a = b) else '0';
    greater <= '1' when ((unsigned(a) > unsigned(b) and compare(3) = '0') or (signed(a) > signed(b) and compare(3) = '1')) else '0';
    greater_eq <= (equal or greater);
   
    with compare(2 downto 0) select
        comp_res <= equal when "000",
                    not equal when "001",
                    greater_eq when "010",
                    greater when "011",
                    not greater_eq when "100", --less than
                    not greater when "101", --less than or equal to
                    '0' when others;
      
    output <= sum_diff when (opcode = "0110" or opcode = "0111") else
              a and b when opcode = "1000" else
              (31 downto 1 => '0') & comp_res when opcode = "1100" else
              shiftout when (opcode = "0000" or opcode = "0001") else --sll
              shiftout when (opcode = "0010" or opcode = "0011") else --srl
              shiftout when (opcode = "0100" or opcode = "0101") else --sra
              a nor b when opcode = "1011" else
              a or b when opcode = "1001" else
              a xor b when opcode = "1010" else
              (31 downto 0 => '0');

end dataflow;

