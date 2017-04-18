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
-- SRAM-like interface for AS4C16M16S-6TCN SDRAM
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
        CAS_latency : integer range 2 to 3 := 3
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
        addr_ready  : out std_logic_vector (23 downto 0);


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
    
    signal statetimer : std_logic_vector (9 downto 0) := "0000000000";
    
    --BurstMode, TestMode, CAS# Latency, Burst Type, Burst Length
    constant mode_reg_cas2 : std_logic_vector (12 downto 0) := "000" & '0' & "00" & "010" & '0' & "111";
    constant mode_reg_cas3 : std_logic_vector (12 downto 0) := "000" & '0' & "00" & "011" & '0' & "111";
    
    --commands in the form cs#, ras#, cas#, we#
    constant cmd_nop     : std_logic_vector (3 downto 0) := "0111";
    constant cmd_read    : std_logic_vector (3 downto 0) := "0101"; --A10 must be low
    constant cmd_write   : std_logic_vector (3 downto 0) := "0100";
    constant cmd_bnkact  : std_logic_vector (3 downto 0) := "0011";
    constant cmd_prechrg : std_logic_vector (3 downto 0) := "0010"; --A10 must be high
    constant cmd_refresh : std_logic_vector (3 downto 0) := "0001";
    constant cmd_setmode : std_logic_vector (3 downto 0) := "0000";
    constant cmd_hltbrst : std_logic_vector (3 downto 0) := "0110";

    --timing constants
    constant init_prechrg  : std_logic_vector (9 downto 0) := "0000000001";
    constant init_setmode  : std_logic_vector (9 downto 0) := "0000000100";
    constant init_ref0     : std_logic_vector (9 downto 0) := "0000000110";
    constant init_ref1     : std_logic_vector (9 downto 0) := "0000001101";
    constant init_exit     : std_logic_vector (9 downto 0) := "0000010001";

    constant ref_refresh   : std_logic_vector (9 downto 0) := "0000000000";
    constant ref_exit      : std_logic_vector (9 downto 0) := "0000001001";

    constant wrt_write     : std_logic_vector (9 downto 0) := "0000000000";
    constant wrt_hltbrst   : std_logic_vector (9 downto 0) := "1000000000";
    constant wrt_prechrg   : std_logic_vector (9 downto 0) := "1000000001";

    constant rd_read            : std_logic_vector (9 downto 0) := "0000000000";
    constant rd_data_ready_cas2 : std_logic_vector (9 downto 0) := "0000000010";
    constant rd_hltbrst_cas2    : std_logic_vector (9 downto 0) := "1000000000";
    constant rd_prechrg_cas2    : std_logic_vector (9 downto 0) := "1000000001";
    constant rd_data_ready_cas3 : std_logic_vector (9 downto 0) := "0000000011";
    constant rd_hltbrst_cas3    : std_logic_vector (9 downto 0) := "1000000001";
    constant rd_prechrg_cas3    : std_logic_vector (9 downto 0) := "1000000010";
    
    signal init_cmd, rd_cmd, wrt_cmd, ref_cmd : std_logic_vector (3 downto 0);
    signal cmd : std_logic_vector (3 downto 0);
    
    signal get_next : std_logic;
    signal next_req_addr : std_logic_vector (23 downto 0);
    signal next_req_type : std_logic;
    signal req_queue_empty : std_logic;

    component sdram_request_queue is
        generic
        (
            depth : integer range 1 to 16 := 8
        );
        port
        (
            read_req      : in  std_logic;
            write_req     : in  std_logic;
            clock         : in  std_logic;
            address       : in  std_logic_vector (23 downto 0);
            get_next      : in  std_logic;
            next_req_addr : out std_logic_vector (23 downto 0);
            next_req_type : out std_logic; --1 for write, 0 for read
            empty         : out std_logic
        );
    end component;

begin
    
    request_queue : sdram_request_queue
        generic map (depth => 8)
        port map
        (
            read_req => read_req,
            write_req => write_req,
            clock => clock,
            address => addr,
            get_next => get_next,
            next_req_addr => next_req_addr,
            next_req_type => next_req_type,
            empty => req_queue_empty
        );

    fsm : process(clock, currentstate) is
        variable statetimer_next : std_logic_vector (9 downto 0);
    begin
        if rising_edge(clock) then
            statetimer_next := std_logic_vector(unsigned(statetimer) + 1);
            case currentstate is
                when init =>
                    if statetimer = init_exit then
                        currentstate <= idle;
                        statetimer_next := (9 downto 0 => '0');
                    end if;
                when ref =>
                    if statetimer = ref_exit then
                        currentstate <= idle;
                        statetimer_next := (9 downto 0 => '0');
                    end if;
                when wrt =>
                    get_next <= '0';
                    if statetimer = wrt_prechrg then
                        currentstate <= idle;
                        statetimer_next := (9 downto 0 => '0');
                    end if;
                when rd =>
                    get_next <= '0';
                    if CAS_latency = 2 then
                        if statetimer = rd_prechrg_cas2 then
                            read_ready <= '0';
                            currentstate <= idle;
                            statetimer_next := (9 downto 0 => '0');
                        elsif statetimer = rd_data_ready_cas2 then
                            read_ready <= '1';
                        end if;
                    elsif CAS_latency = 3 then
                        if statetimer = rd_prechrg_cas3 then
                            read_ready <= '0';
                            currentstate <= idle;
                            statetimer_next := (9 downto 0 => '0');
                        elsif statetimer = rd_data_ready_cas3 then
                            read_ready <= '1';
                        end if;
                    end if;
                when idle =>
                    statetimer_next := (9 downto 0 => '0');
                    if req_queue_empty = '1' then
                        currentstate <= ref;
                    else
                        get_next <= '1';
                        if next_req_type = '1' then
                            currentstate <= rd;
                        else
                            currentstate <= wrt;
                        end if;
                    end if;
            end case;
        end if;
    end process fsm;
    
    init_cmd <= cmd_prechrg when statetimer = init_prechrg else
                cmd_setmode when statetimer = init_setmode else
                cmd_refresh when (statetimer = init_ref0 or statetimer = init_ref1) else
                cmd_nop;
    rd_cmd <=   cmd_read when statetimer = rd_read else
                cmd_hltbrst when statetimer = rd_hltbrst_cas2 and CAS_latency = 2 else
                cmd_hltbrst when statetimer = rd_hltbrst_cas3 and CAS_latency = 3 else
                cmd_prechrg when statetimer = rd_prechrg_cas2 and CAS_latency = 2 else
                cmd_prechrg when statetimer = rd_prechrg_cas3 and CAS_latency = 3 else
                cmd_nop;
    wrt_cmd <=  cmd_write when statetimer = wrt_write else
                cmd_hltbrst when statetimer = wrt_hltbrst else
                cmd_prechrg when statetimer = wrt_prechrg else
                cmd_nop;
    ref_cmd <=  cmd_refresh when statetimer = ref_refresh else cmd_nop;
    
    with currentstate select
    cmd <=  init_cmd when init,
            cmd_nop when idle,
            rd_cmd when rd,
            wrt_cmd when wrt,
            ref_cmd when ref,
            cmd_nop when others;

    sdram_cs <= cmd(3);
    ras <= cmd(2);
    cas <= cmd(1);
    we <= cmd(0);

end behavioral;

