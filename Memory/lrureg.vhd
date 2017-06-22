----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    11:24:38 06/22/2017 
-- Design Name: 
-- Module Name:    lrureg - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- single register used to implement lru.vhd
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

entity lrureg is
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
end entity;

architecture behavioral of lrureg is

    signal data : std_logic_vector (tagselectwidth - 1 downto 0);
    signal en_tmp : std_logic;

begin

    update : process(clock, enable, tagselectin, data)
    begin
        if rising_edge(clock) then
            if en_tmp = '1' then
                data <= tagselectprev;
            end if;
        end if;
    end process;

    tagselectout <= data;
    en_tmp <= '1' when tagselectin /= data and enable = '1' else '0';
    enableout <= en_tmp;

end behavioral;