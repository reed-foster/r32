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
        cs          : in  std_logic;
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
    signal next_state : fsm_states;
    
    signal statetimer : std_logic_vector (9 downto 0) := "0000000000";
    
    --BurstMode, TestMode, CAS# Latency, Burst Type, Burst Length
    constant mode_reg_cas2 : std_logic_vector (12 downto 0) := "000" & '0' & "00" & "010" & '0' & "111";
    constant mode_reg_cas3 : std_logic_vector (12 downto 0) := "000" & '0' & "00" & "011" & '0' & "111";
    
    --commands in the form cs#, ras#, cas#, we#
    constant cmd_deselect : std_logic_vector (3 downto 0) := "1111";
    constant cmd_read     : std_logic_vector (3 downto 0) := "0101"; --A10 must be low
    constant cmd_write    : std_logic_vector (3 downto 0) := "0100"; --A10 must be low
    constant cmd_bnkact   : std_logic_vector (3 downto 0) := "0011";
    constant cmd_prechrg  : std_logic_vector (3 downto 0) := "0010"; --A10 must be high
    constant cmd_refresh  : std_logic_vector (3 downto 0) := "0001";
    constant cmd_setmode  : std_logic_vector (3 downto 0) := "0000";
    constant cmd_hltbrst  : std_logic_vector (3 downto 0) := "0110";


    --timing constants
    constant init_prechrg  : std_logic_vector (9 downto 0) := "0000000001";
    constant init_setmode  : std_logic_vector (9 downto 0) := "0000000100";
    constant init_ref0     : std_logic_vector (9 downto 0) := "0000000110";
    constant init_ref1     : std_logic_vector (9 downto 0) := "0000001101";
    constant init_exit     : std_logic_vector (9 downto 0) := "0000010001";

    constant ref_refresh   : std_logic_vector (9 downto 0) := "0000000000";
    constant ref_exit      : std_logic_vector (9 downto 0) := "0000001001";

    constant wrt_ba        : std_logic_vector (9 downto 0) := "0000000000";
    constant wrt_write_1   : std_logic_vector (9 downto 0) := "0000000010";
    constant wrt_write     : std_logic_vector (9 downto 0) := "0000000011";
    constant wrt_hltbrst   : std_logic_vector (9 downto 0) := "1000000011";
    constant wrt_prechrg   : std_logic_vector (9 downto 0) := "1000000100";

    constant rd_ba              : std_logic_vector (9 downto 0) := "0000000000";
    constant rd_read            : std_logic_vector (9 downto 0) := "0000000000";
    constant rd_data_ready_cas2 : std_logic_vector (9 downto 0) := "0000000100";
    constant rd_hltbrst_cas2    : std_logic_vector (9 downto 0) := "1000000011";
    constant rd_prechrg_cas2    : std_logic_vector (9 downto 0) := "1000000100";
    constant rd_data_ready_cas3 : std_logic_vector (9 downto 0) := "0000000101";
    constant rd_hltbrst_cas3    : std_logic_vector (9 downto 0) := "1000000100";
    constant rd_prechrg_cas3    : std_logic_vector (9 downto 0) := "1000000101";
    
    signal cmd : std_logic_vector (3 downto 0);
    
    signal get_next : std_logic := '0';
    signal next_req_addr : std_logic_vector (23 downto 0);
    signal next_req_type : std_logic;
    signal req_queue_empty : std_logic;

    signal ram_addr_tmp : std_logic_vector (12 downto 0);

    signal precharge, setmode, autorefresh, exit_init, exit_refresh, bank_activate,
           store, burst_stop, load, read_ready_en, write_ready_en : std_logic;
    signal write_ready_tmp, read_ready_tmp : std_logic;

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
    
    precharge <= '1' when ((statetimer = init_prechrg and currentstate = init) or
                           (statetimer = wrt_prechrg and currentstate = wrt) or
                           (statetimer = rd_prechrg_cas2 and currentstate = rd and CAS_latency = 2) or
                           (statetimer = rd_prechrg_cas3 and currentstate = rd and CAS_latency = 3)) else '0';
    setmode <= '1' when (statetimer = init_setmode and currentstate = init) else '0';
    autorefresh <= '1' when ((statetimer = init_ref0 and currentstate = init) or
                             (statetimer = init_ref1 and currentstate = init) or
                             (statetimer = ref_refresh and currentstate = ref)) else '0';
    exit_init <= '1' when (statetimer = init_exit and currentstate = init) else '0';
    exit_refresh <= '1' when (statetimer = ref_exit and currentstate = ref) else '0';
    bank_activate <= '1' when ((statetimer = wrt_ba and currentstate = rd) or
                               (statetimer = rd_ba and currentstate = wrt)) else '0';
    store <= '1' when (statetimer = wrt_write and currentstate = wrt) else '0';
    burst_stop <= '1' when ((statetimer = wrt_hltbrst and currentstate = wrt) or
                            (statetimer = rd_hltbrst_cas2 and currentstate = rd and CAS_latency = 2) or
                            (statetimer = rd_hltbrst_cas3 and currentstate = rd and CAS_latency = 3)) else '0';
    load <= '1' when (statetimer = rd_read and currentstate = rd) else '0';
    write_ready <= '1' when (statetimer = wrt_write_1 and currentstate = wrt) else '0';
    read_ready <= '1' when ((statetimer = rd_data_ready_cas2 and currentstate = rd and CAS_latency = 2) or
                            (statetimer = rd_data_ready_cas3 and currentstate = rd and CAS_latency = 3)) else '0';
    cmd <= cmd_prechrg when (precharge = '1') else
           cmd_setmode when (setmode = '1') else
           cmd_refresh when (autorefresh = '1') else
           cmd_bnkact when (bank_activate = '1') else
           cmd_write when (store = '1') else
           cmd_read when (load = '1') else
           cmd_hltbrst when (burst_stop = '1') else
           cmd_deselect;

    udqm <= '1' when currentstate = init else '0';
    ldqm <= '1' when currentstate = init else '0';

    sdram_cs <= cmd(3);
    ras <= cmd(2);
    cas <= cmd(1);
    we <= cmd(0);

    ba <= next_req_addr(23 downto 22);
    ram_addr_tmp <= next_req_addr(21 downto 9) when bank_activate = '0' else "0000" & next_req_addr(8 downto 0);

    ram_addr <= ram_addr_tmp when (precharge = '0' and setmode = '0') else 
                ram_addr_tmp(12 downto 11) & '1' & ram_addr_tmp(9 downto 0) when (precharge = '1' and setmode = '0') else
                "000000" & "010" & '0' & "111" when (setmode = '1' and CAS_latency = 2) else
                "000000" & "011" & '0' & "111" when (setmode = '1' and CAS_latency = 3) else
                (12 downto 0 => '0');
    
    get_next <= '1' when (req_queue_empty = '0' and currentstate = idle) else '0';

    d_out <= ram_data_in;
    ram_data_out <= d_in;

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

    --FSM code
    fsm : process(clock, currentstate, next_state) is
        variable statetimer_next : std_logic_vector (9 downto 0);
    begin
        if rising_edge(clock) then
            statetimer_next := std_logic_vector(unsigned(statetimer) + 1);
            if (next_state /= currentstate) then
                statetimer_next := "0000000000";
            end if;
            currentstate <= next_state;
            statetimer <= statetimer_next;
        end if;
    end process fsm;

    next_state <= idle when (exit_init = '1' or exit_refresh = '1' or (precharge = '1' and currentstate /= init)) else
                  ref when (req_queue_empty = '1' and currentstate = idle) else
                  rd when (get_next = '1' and next_req_type = '0' and currentstate = idle) else
                  wrt when (get_next = '1' and next_req_type = '1' and currentstate = idle) else
                  currentstate;

end behavioral;

