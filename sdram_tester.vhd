----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    11:15:26 04/23/2017 
-- Design Name: 
-- Module Name:    sdram_tester - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Tests the sdram.vhd interface by writing a few bytes to the AS4C16M16S-6TCN SDRAM
-- and reading them back
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

entity sdram_tester is
    port
    (
        --testing interface
        clock50    : in  std_logic;
        byte_out   : out std_logic_vector (7 downto 0);
        byte_out_v : out std_logic;

        --SDRAM Interface
        --clock
        sdram_clk : out std_logic; --synchronous clock input to SDRAM
        cke       : out std_logic; --clock enable (HIGH) disable (LOW)

        --data I/O mask: controls output buffers in read mode and masks input data in write mode
        udqm : out std_logic; --byte mask
        ldqm : out std_logic;

        --enable/disable signals
        --control signals: ba0, ba1, cs#, ras#, cas#, and we#
        ba       : out std_logic_vector (1 downto 0); --bank activate "00" => A, "01" => B, etc.
        sdram_cs : out std_logic; --enables/disables command decoder
        ras      : out std_logic; --row address strobe
        cas      : out std_logic; --column address strobe
        we       : out std_logic; --write enable

        --address/data
        ram_addr     : out std_logic_vector (12 downto 0); --address inputs
        ram_data     : inout std_logic_vector (15 downto 0)
    );
end entity;

architecture behavioral of sdram_tester is

    constant value : std_logic_vector (15 downto 0) := x"dead";
    signal buffptr : std_logic_vector (8 downto 0) := "000000000";
    signal state : std_logic_vector (1 downto 0) := "00"; --0 => init, 1 => write, 2 => read, 3 => stop
    signal byte_out_tmp : std_logic_vector (15 downto 0) := x"0000";
    signal byte_out_v_tmp : std_logic := '0';

    signal write_req, read_req : std_logic := '0';

    signal read_ready, write_ready : std_logic := '0';

    signal ram_data_in, ram_data_out : std_logic_vector (15 downto 0) := x"0000";

    --signal d_in_tmp : std_logic_vector (15 downto 0);

    signal clockcounter : integer range 0 to 49999 := 0;
    signal clock_in : std_logic := '0';

    component sdram is
    port
    (
        --Processor Interface
        clock       : in  std_logic;
        read_req    : in  std_logic;
        cs          : in  std_logic;
        write_req   : in  std_logic;
        --d_in        : in  std_logic_vector (15 downto 0);
        --d_out       : out std_logic_vector (15 downto 0);
        addr        : in  std_logic_vector (23 downto 0);
        read_ready  : out std_logic;
        write_ready : out std_logic;
        curr_addr   : out std_logic_vector (23 downto 0);

        --SDRAM Interface
        sdram_clk    : out std_logic; --synchronous clock input to SDRAM
        cke          : out std_logic; --clock enable (HIGH) disable (LOW)
        udqm         : out std_logic; --data I/O mask: controls output buffers
        ldqm         : out std_logic; --in read mode and masks input data in write mode
        ba           : out std_logic_vector (1 downto 0); --bank activate "00" => A, "01" => B, etc.
        sdram_cs     : out std_logic; --enables/disables command decoder
        ras          : out std_logic; --row address strobe
        cas          : out std_logic; --column address strobe
        we           : out std_logic; --write enable
        ram_addr     : out std_logic_vector (12 downto 0) --address inputs
        --ram_data_in  : in  std_logic_vector (15 downto 0); --data input
        --ram_data_out : out std_logic_vector (15 downto 0)  --data output
    );
    end component;

begin

    --clock_div : process(clock50)
    --begin
    --    if rising_edge(clock50) then
    --        if clockcounter = 49999 then
    --            clockcounter <= 0;
    --            clock_in <= not clock_in;
    --        else
    --            clockcounter <= clockcounter + 1;
    --        end if;
    --    end if;
    --end process;
    clock_in <= clock50;

    ram_data_out <= value;
    controller : sdram
    port map
    (
        clock => clock_in,
        read_req => read_req,
        write_req => write_req,
        cs => '1',
        --d_in => d_in_tmp,
        --d_out => byte_out_buff,
        addr => x"000000",
        read_ready => read_ready,
        write_ready => write_ready,
        curr_addr => open,
        sdram_clk => sdram_clk,
        cke => cke,
        udqm => udqm,
        ldqm => ldqm,
        ba => ba,
        sdram_cs => sdram_cs,
        ras => ras,
        cas => cas,
        we => we,
        ram_addr => ram_addr
        --ram_data_in => ram_data_in,
        --ram_data_out => ram_data_out
    );

    updatecounters : process(clock_in, read_ready, write_ready, state)
    begin
        if rising_edge(clock_in) then
            if (state /= "11") then
                state <= std_logic_vector(unsigned(state) + 1);
            end if;
        end if;
    end process;

    setoutput : process(clock_in, byte_out_v_tmp, ram_data_in, read_ready)
    begin
        if rising_edge(clock_in) then
            if (read_ready = '1' and byte_out_v_tmp = '0') then
                byte_out_tmp <= ram_data_in;
            end if;
        end if;
    end process;

    setvalid : process (clock_in, read_ready)
    begin
        if rising_edge(clock_in) then
            if (read_ready = '1') then
                byte_out_v_tmp <= '1';
            end if;
        end if;
    end process;

    write_req <= '1' when state = "01" else '0';
    read_req <= '1' when state = "10" else '0';

    byte_out_v <= byte_out_v_tmp;
    byte_out <= byte_out_tmp (7 downto 0);

    ram_data <= ram_data_out when (write_ready = '1') else (15 downto 0 => 'Z');
    ram_data_in <= ram_data when (read_ready = '1') else x"0000";

end behavioral;