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
        clockperiondns : integer := 6; --default of 166MHz
        burst_length : std_logic_vector := "111" --000, 001, 010, 011, or 111
    );
    port
    (
        --Processor Interface
        clock       : in  std_logic;
        read_req    : in  std_logic;
        write_req   : in  std_logic;
        cs          : in  std_logic;
        d_in        : in  std_logic_vector (15 downto 0);
        d_out       : out std_logic_vector (15 downto 0);
        addr        : in  std_logic_vector (23 downto 0);
        read_ready  : out std_logic;
        write_ready : out std_logic;
        rd          : in  std_logic;
        wrt         : in  std_logic;


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
        ram_addr     : out std_logic_vector (12 downto 0) --address inputs
        ram_data_in  : out std_logic_vector (15 downto 0); --data input
        ram_data_out : in  std_logic_vector (15 downto 0)  --data output
   );
end sdram;

architecture behavioral of sdram is
    
    constant CAS_latency : integer := 3;

    --timing constants (in ns)
    constant trc  : integer := 60; --row cycle time (same bank)
    constant trfc : integer := 60; --refresh cycle time
    constant trcd : integer := 18; --ras# to cas# delay (same bank)
    constant trp  : integer := 18; --precharge to refresh/row activate (same bank)
    constant trrd : integer := 12; --row activate to row activate (different bank)
    constant tmrd : integer := 12; --mode register set
    constant tras : integer := 42; --row activate to precharge (same bank)
    constant twr  : integer := 12; --write recovery time  

    signal init_startup_timer    : integer := 200000 / clockperiodns - 1; --countdown for 200us
    signal init_pretoset_timer   : integer := trp  / clockperiodns - 1;
    signal init_settoref0_timer  : integer := tmrd / clockperiodns - 1;
    signal init_ref0toref1_timer : integer := trp  / clockperiodns - 1;
    signal init_ref1toexit_timer : integer := trc  / clockperiodns - 1;

    constant bank_activate_delay_default : integer := trcd / clockperiodns;
    signal wrt_bnktowrt_timer : integer := bank_activate_delay_default;
    signal rd_bnktord_timer   : integer := bank_activate_delay_default;

    constant rd_timer_default : integer := 508; --509 cycles
    signal rd_timer : integer := rd_timer_default;

    constant wrt_timer_default : integer := 510; --511 cycles
    signal wrt_timer : integer := wrt_timer_default;

    constant refresh_delay_default : integer := trc / clockperiodns - 1;
    signal refresh_reftoidle_timer : integer := refresh_delay_default;
    
    type fsm_states is (
        --init
        init_wait0, init_wait1, init_precharge, init_wait2, init_setmode, init_wait3, init_refresh0,
        init_wait4, init_refresh1, init_wait5,
        --idle
        idle,
        --read
        rd_bankact, rd_wait0, rd, rd_wait1, rd_wait2, rd_wait3, rd_bursthlt, rd_precharge, rd_wait4, rd_wait5,
        --write
        wrt_bankact, wrt_wait0, wrt, wrt_wait1, wrt_bursthlt, wrt_precharge, wrt_wait2,
        --refresh
        refresh, refresh_wait);

    signal state : fsm_states := init;
    signal nextstate : fsm_states;

    --BurstMode, TestMode, CAS# Latency, Burst Type, Burst Length
    signal mode_reg : std_logic_vector (12 downto 0);
    
    --commands in the form cs#, ras#, cas#, we#
    constant cmd_deselect : std_logic_vector (3 downto 0) := "1111";
    constant cmd_read     : std_logic_vector (3 downto 0) := "0101"; --A10 must be low
    constant cmd_write    : std_logic_vector (3 downto 0) := "0100"; --A10 must be low
    constant cmd_bnkact   : std_logic_vector (3 downto 0) := "0011";
    constant cmd_prechrg  : std_logic_vector (3 downto 0) := "0010"; --A10 must be high
    constant cmd_refresh  : std_logic_vector (3 downto 0) := "0001";
    constant cmd_setmode  : std_logic_vector (3 downto 0) := "0000";
    constant cmd_hltbrst  : std_logic_vector (3 downto 0) := "0110";
    
    signal iob_cmd : std_logic_vector (3 downto 0) := cmd_deselect;

    signal iob_cs : std_logic;
    signal iob_ras : std_logic;
    signal iob_cas : std_logic;
    signal iob_we : std_logic;
    attribute iob : string;
    attribute iob of iob_cs  : signal is "true";
    attribute iob of iob_ras : signal is "true";
    attribute iob of iob_cas : signal is "true";
    attribute iob of iob_we  : signal is "true";

    signal req_queue_enqueue : std_logic := '0';
    signal current_address : std_logic_vector (24 downto 0);

    signal read_active : std_logic := '0';
    signal write_active : std_logic := '0';

    signal get_next_request : std_logic;
    signal req_queue_empty : std_logic;

    component fifo is
    generic
    (
        depth : integer range 1 to 16 := 8,
        bitwidth : integer range 1 to 32 := 32
    );
    port
    (
        clock   : in  std_logic;
        enqueue : in  std_logic;
        dequeue : in  std_logic;
        d_in    : in  std_logic_vector (bitwidth - 1 downto 0);
        d_out   : out std_logic_vector (bitwidth - 1 downto 0);
        empty   : out std_logic
    );
    end component;

begin
    
    tx_data : fifo
    generic map
    (
        depth => 512,
        bitwidth => 16
    );
    port map
    (
        clock => clock,
        enqueue => wrt,
        dequeue => write_active,
        d_in => d_in,
        d_out => ram_data_in,
        empty =>
    );

    rx_data : fifo
    generic map
    (
        depth => 512,
        bitwidth => 16
    );
    port map
    (
        clock => clock,
        enqueue => read_active,
        dequeue => rd,
        d_in => ram_data_out,
        d_out => d_out,
        empty =>
    );

    req_queue : fifo
    generic map
    (
        depth => 4,
        bitwidth => 25
    );
    port map
    (
        clock => clock,
        enqueue => req_queue_enqueue,
        dequeue => get_next_request,
        d_in => (write_req & addr),
        d_out => current_address,
        empty => req_queue_empty
    );

    req_queue_enqueue <= read_req or write_req;

    mode_reg <= "000" & '0' & "00" & std_logic_vector(to_unsigned(CAS_latency, 3)) & '0' & burst_length;
    
    iob_we <= iob_cmd(0);
    iob_cas <= iob_cmd(1);
    iob_ras <= iob_cmd(2);
    iob_cs <= iob_cmd(3);

    fsm : process(clock, state)
    begin
        if rising_edge(clock) then
            nextstate <= state;
            case state is
                --------------------------------------------------------
                -- Initialization
                --------------------------------------------------------
                when init_wait0 =>
                    if init_startup_timer > 0 then
                        init_startup_timer <= init_startup_timer - 1;
                    else
                        nextstate <= init_wait1;
                    end if;

                when init_wait1 => nextstate <= init_precharge;

                when init_precharge =>
                    nextstate <= init_wait2;

                when init_wait2 =>
                    if init_pretoset_timer > 0 then
                        init_pretoset_timer <= init_pretoset_timer - 1;
                    else
                        nextstate <= init_setmode;
                    end if;

                when init_setmode =>
                    nextstate <= init_wait4;

                when init_wait3 => 
                    if init_settoref0_timer > 0 then
                        init_settoref0_timer <= init_settoref0_timer - 1;
                    else
                        nextstate <= init_refresh0;
                    end if;

                when init_refresh0 =>
                    nextstate <= init_wait4;

                when init_wait4 =>
                    if init_ref0toref1_timer > 0 then
                        init_ref0toref1_timer <= init_ref0toref1_timer - 1;
                    else
                        nextstate <= init_refresh1;
                    end if;

                when init_refresh1 =>
                    nextstate <= init_wait5;

                when init_wait5 =>
                    if init_ref1toexit_timer > 0 then
                        init_ref1toexit_timer <= init_ref1toexit_timer - 1;
                    else
                        nextstate <= idle;
                    end if;

                --------------------------------------------------------
                -- Idle
                --------------------------------------------------------
                when idle =>
                    nextstate <= idle;
                    --need actual implementation

                --------------------------------------------------------
                -- Read
                --------------------------------------------------------
                when rd_bankact =>
                    nextstate <= rd_wait0;

                when rd_wait0 =>
                    if rd_bnktord_timer > 0 then
                        rd_bnktord_timer <= rd_bnktord_timer - 1;
                    else
                        rd_bnktord_timer <= bank_activate_delay_default;
                        nextstate <= rd;
                    end if;

                when rd =>

                when rd_wait1 => nextstate <= rd_wait2;
                when rd_wait2 => nextstate <= rd_wait3;

                when rd_wait3 =>
                    if rd_timer > 0 then
                        rd_timer <= rd_timer - 1;
                    else
                        rd_timer <= rd_timer_default;
                        nextstate <= rd_bursthlt;
                    end if;

                when rd_bursthlt =>
                    nextstate <= rd_precharge;

                when rd_precharge =>
                    nextstate <= rd_wait4;

                when rd_wait4 =>
                    nextstate <= rd_wait5;

                when rd_wait5 =>
                    nextstate <= idle;

                --------------------------------------------------------
                -- Write
                --------------------------------------------------------
                when wrt_bankact =>
                    nextstate <= wrt_wait0;

                when wrt_wait0 =>
                    if wrt_bnktowrt_timer > 0 then
                        wrt_bnktowrt_timer <= wrt_bnktowrt_timer - 1;
                    else
                        wrt_bnktowrt_timer <= bank_activate_delay_default;
                        nextstate <= wrt;
                    end if;

                when wrt =>
                    nextstate <= wrt_wait1;

                when wrt_wait1 =>
                    if wrt_timer > 0 then
                        wrt_timer <= wrt_timer - 1;
                    else
                        wrt_timer <= wrt_timer_default;
                        nextstate <= wrt_bursthlt;
                    end if;

                when wrt_bursthlt =>
                    nextstate <= wrt_precharge;

                when wrt_precharge =>
                    nextstate <= wrt_wait2;

                when wrt_wait2 =>
                    nextstate <= idle;

                --------------------------------------------------------
                -- Refresh
                --------------------------------------------------------
                when refresh =>
                    nextstate <= refresh_wait;

                when refresh_wait =>
                    if refresh_reftoidle_timer > 0 then
                        refresh_reftoidle_timer <= refresh_reftoidle_timer - 1;
                    else
                        refresh_reftoidle_timer <= refresh_delay_default;
                        nextstate <= idle;
                    end if;

            end case;
            state <= nextstate;
        end if;
    end process;

end behavioral;