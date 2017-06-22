----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    15:52:54 06/21/2017 
-- Design Name: 
-- Module Name:    lru - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- lru counter (keeps track of least recently used tag)
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

entity lru is
    generic
    (
        tagselectwidth : integer range 1 to 6
    );
    port
    (
        clock     : in  std_logic;
        enable    : in  std_logic;
        tagselect : in  std_logic_vector (tagselectwidth - 1 downto 0);
        lrutag    : out std_logic_vector (tagselectwidth - 1 downto 0)
    );
end entity;

architecture behavioral of lru is
    type shiftreg is array (0 to 2 ** tagselectwidth - 1) of std_logic_vector (tagselectwidth - 1 downto 0);
    signal data : shiftreg;
    signal regenables : std_logic_vector (2 ** tagselectwidth - 1 downto 0);

    component lrureg is
        generic
        (
            tagselectwidth : integer range 1 to 6
        );
        port
        (
            clock         : in  std_logic;
            enable        : in  std_logic;
            tagselectin   : in  std_logic_vector (tagselectwidth - 1 downto 0);
            tagselectprev : in  std_logic_vector (tagselectwidth - 1 downto 0);
            tagselectout  : out std_logic_vector (tagselectwidth - 1 downto 0);
            enableout     : out std_logic
        );
    end component;
begin

    gen_regs : for i in 0 to 2 ** tagselectwidth - 1 generate
        first_reg : if i = 0 generate
            reg0 : lrureg
            generic map
            (
                tagselectwidth => tagselectwidth
            )
            port map
            (
                clock => clock,
                enable => enable,
                tagselectin => tagselect,
                tagselectprev => tagselect,
                tagselectout => data(i),
                enableout => regenables(i)
            );
        end generate;
        other_regs : if i /= 0 generate
            regn : lrureg
            generic map
            (
                tagselectwidth => tagselectwidth
            )
            port map
            (
                clock => clock,
                enable => regenables(i - 1),
                tagselectin => tagselect,
                tagselectprev => data(i - 1),
                tagselectout => data(i),
                enableout => regenables(i)
            );
        end generate;
    end generate;

    lrutag <= data(2 ** tagselectwidth - 1);
    
end behavioral;