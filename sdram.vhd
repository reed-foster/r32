----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    15:30:18 02/26/2017 
-- Design Name: 
-- Module Name:    sdram - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- SRAM interface for AS4C16M16S-6TCN SDRAM
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


entity sdram is
    generic
    (
        CAS_latency : integer range 2 to 3
    );
    port
    (
        --Processor Interface
        clock       : in  std_logic;
        read_req    : in  std_logic;
        write_req   : in  std_logic;
        d_in        : in  std_logic_vector (15 downto 0);
        d_out       : out std_logic_vector (15 downto 0);
        addr        : in  std_logic_vector (23 downto 0);
        read_ready  : out std_logic;
        write_ready : out std_logic;


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
        ram_data_in  : in  std_logic_vector (15 downto 0); --data input
        ram_data_out : out std_logic_vector (15 downto 0)  --data output
   );
end sdram;

architecture behavioral of sdram is
   
   type fsm_states is (init, idle, rd, wrt, ref);

   signal currentstate : fsm_states := init;

   --commands in the form cs#, ras#, cas#, we#
    constant cmd_nop     : std_logic_vector(3 downto 0) := "0111";
    constant cmd_read    : std_logic_vector(3 downto 0) := "0101"; --A10 must be low
    constant cmd_write   : std_logic_vector(3 downto 0) := "0100";
    constant cmd_bnkact  : std_logic_vector(3 downto 0) := "0011";
    constant cmd_prechrg : std_logic_vector(3 downto 0) := "0010"; --A10 must be high
    constant cmd_refresh : std_logic_vector(3 downto 0) := "0001";
    constant cmd_setmode : std_logic_vector(3 downto 0) := "0000";
    constant cmd_hltbrst : std_logic_vector(3 downto 0) := "0110";

    constant mode_reg : std_logic_vector(12 downto 0) := 
    --BurstMode, TestMode, CAS# Latency, Burst Type, Burst Length
    "0" & "00" & ("010" when CAS_latency = 2 else "011") & "0" & "111";

    signal statetimer : std_logic_vector(9 downto 0) := x"00000";

    signal cmd : std_logic_vector(3 downto 0);

begin

    fsm : process(clock, currentstate) is
    begin
        if rising_edge(clock)
            case currentstate is
                when init =>
                    if initctr = "10001"
                        currentstate <= idle;
                        initctr <= "00000"
                    else
                        initctr <= std_logic_vector(unsigned(initctr) + 1);
                    end if;
                when ref =>
                    if refctr = "1001"
                        currentstate <= idle;
                        refctr <= "0000";
                    else
                        refctr <= std_logic_vector(unsigned(refctr) + 1);
                    end if;
                when wrt =>
                    if wrtctr = "1000000001"
                        currentstate <= idle;
                        wrtctr <= "0000000000";
                    else
                        wrtctr <= std_logic_vector(unsigned(wrtctr) + 1);
                    end if;
                when rd =>
                    if rdctr = "1000000001"
                        currentstate <= idle;
                        rdctr <= "0000000000";
                    else
                        rdctr <= std_logic_vector(unsigned(rdctr) + 1);
                    end if;
            end case;
        end if;
    end process fsm;

    with currentstate select
    cmd <=  (cmd_prechrg when initctr = "00001" else
             cmd_setmode when initctr = "00100" else
             cmd_autorefresh when (initctr = "00110" or initctr = "01101")) when init,
            () when idle,
            () when rd,
            () when wrt,
            () when ref,
            cmd_nop when others;

    sdram_cs <= cmd(3);
    ras <= cmd(2);
    cas <= cmd(1);
    we <= cmd(0);

end behavioral;

