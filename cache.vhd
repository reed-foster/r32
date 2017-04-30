----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    09:24:25 02/28/2017 
-- Design Name: 
-- Module Name:    cache - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity cache is
    generic
    (
        lines     : integer := 8;
        line_size : integer := 1024
    );
    port
    (
        data_in  : in  std_logic_vector (31 downto 0);
        data_out : out std_logic_vector (31 downto 0);
        address  : in  std_logic_vector (31 downto 0);
        hit      : out std_logic;

        clk      : in  std_logic;
        proc_wrt : in  std_logic;
        proc_en  : in  std_logic
    );
end cache;

architecture behavioral of cache is
    type line_data_type is array (0 to line_size - 1) of 
        std_logic_vector(7 downto 0);
    type line_type is record
        dirty : std_logic;
        tag   : std_logic_vector(21 downto 0);
        data  : line_data_type;
    end record;
begin
   
   

end behavioral;

