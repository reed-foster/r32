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
        clockperiodns : integer range 0 to 31 := 6; --default of 166MHz
        burst_length : std_logic_vector (2 downto 0) := "111" --000, 001, 010, 011, or 111: 1-, 2-, 4-, 8-, 512-word burst (respectively)
    );
    port
    (
        --Processor Interface
        clock        : in  std_logic;
        read_req     : in  std_logic; --issue a new request to read from ram on each rising clock edge
        write_req    : in  std_logic; --issue a new request to write to ram on each rising clock edge
        cs           : in  std_logic; --1 enables command queues, 0 disable
        d_in         : in  std_logic_vector (15 downto 0);
        d_out        : out std_logic_vector (15 downto 0);
        addr         : in  std_logic_vector (23 downto 0);
        read_ready   : out std_logic; --1 if data is available to read from rx buffer
        write_ready  : out std_logic; --1 if tx buffer is empty
        rd_from_buff : in  std_logic; --dequeue from rx buffer
        wrt_to_buff  : in  std_logic; --enqueue onto tx buffer


        --SDRAM Interface
        --clock
        sdram_clk : out std_logic; --synchronous clock input to SDRAM
        cke       : out std_logic; --clock enable (HIGH) disable (LOW)

        --data I/O mask: controls output buffers in read mode and masks input data in write mode
        udqm : out std_logic; --byte mask
        ldqm : out std_logic;

        --enable/disable signals
        --control signals: ba, cs#, ras#, cas#, and we#
        ba       : out std_logic_vector (1 downto 0); --bank activate "00" => A, "01" => B, etc.
        sdram_cs : out std_logic; --enables/disables command decoder
        ras      : out std_logic; --row address strobe
        cas      : out std_logic; --column address strobe
        we       : out std_logic; --write enable

        --address/data
        ram_addr     : out std_logic_vector (12 downto 0); --address inputs
        ram_data_in  : out std_logic_vector (15 downto 0); --data input
        ram_data_out : in  std_logic_vector (15 downto 0); --data output

        --tristate control signal
        ram_data_sel : out std_logic --1 if ram_data_in should be written to inout, 0 if ram_data_out should be read
   );
end sdram;

architecture behavioral of sdram is

    constant CAS_latency : integer range 0 to 3 := 3;

    --timing constants (in ns)
    constant trc  : unsigned (5 downto 0) := 60; --row cycle time (same bank)
    constant trfc : unsigned (5 downto 0) := 60; --refresh cycle time
    constant trcd : unsigned (4 downto 0) := 18; --ras# to cas# delay (same bank)
    constant trp  : unsigned (4 downto 0) := 18; --precharge to refresh/row activate (same bank)
    constant trrd : unsigned (3 downto 0) := 12; --row activate to row activate (different bank)
    constant tmrd : unsigned (3 downto 0) := 12; --mode register set
    constant tras : unsigned (5 downto 0) := 42; --row activate to precharge (same bank)
    constant twr  : unsigned (3 downto 0) := 12; --write recovery time  

    constant init_startup_timer_default    : unsigned (15 downto 0) := 200000 / clockperiodns; --countdown for 200us
    constant init_pretoset_timer_default   : unsigned (1 downto 0)  := trp / clockperiodns; --default = 3
    constant init_settoref0_timer_default  : unsigned (1 downto 0)  := tmrd / clockperiodns; --default = 2
    constant init_ref0toref1_timer_default : unsigned (1 downto 0)  := trp / clockperiodns; --default = 3
    constant init_ref1toexit_timer_default : unsigned (3 downto 0)  := trc / clockperiodns; --default = 10

    signal init_startup_timer    : integer range 0 to 65535 := init_startup_timer_default;
    signal init_pretoset_timer   : integer range 0 to 3     := init_pretoset_timer_default;
    signal init_settoref0_timer  : integer range 0 to 3     := init_settoref0_timer_default;
    signal init_ref0toref1_timer : integer range 0 to 3     := init_ref0toref1_timer_default;
    signal init_ref1toexit_timer : integer range 0 to 15    := init_ref1toexit_timer_default;

    constant bank_activate_delay_default : integer range 0 to 3 := trcd / clockperiodns; --default = 3
    signal wrt_bnktowrt_timer : integer := bank_activate_delay_default;
    signal rd_bnktord_timer   : integer := bank_activate_delay_default;

    constant rd_timer_default : integer range 0 to 511 := 509;
    signal rd_timer : integer := rd_timer_default;

    constant wrt_timer_default : integer range 0 to 511 := 511;
    signal wrt_timer : integer := wrt_timer_default;

    constant refresh_delay_default : integer range 0 to 15 := trc / clockperiodns;
    signal refresh_reftoidle_timer : integer := refresh_delay_default;

    constant idle_timer_default : integer range 0 to 15 := 10;
    signal idle_timer: integer := idle_timer_default;
    
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

    signal state : fsm_states := init_wait0;
    signal nextstate : fsm_states;

    --BurstMode, TestMode, CAS# Latency, Burst Type, Burst Length
    signal mode_reg : std_logic_vector (12 downto 0);
    
    --commands in the form cs#, ras#, cas#, we#
    constant cmd_deselect : std_logic_vector (3 downto 0) := "1111";
    constant cmd_nop      : std_logic_vector (3 downto 0) := "0111";
    constant cmd_read     : std_logic_vector (3 downto 0) := "0101"; --A10 must be low
    constant cmd_write    : std_logic_vector (3 downto 0) := "0100"; --A10 must be low
    constant cmd_bnkact   : std_logic_vector (3 downto 0) := "0011";
    constant cmd_prechrg  : std_logic_vector (3 downto 0) := "0010"; --A10 must be high
    constant cmd_refresh  : std_logic_vector (3 downto 0) := "0001";
    constant cmd_setmode  : std_logic_vector (3 downto 0) := "0000"; --A10 is low
    constant cmd_hltbrst  : std_logic_vector (3 downto 0) := "0110";

    -- A(12 downto 11) & A(9 downto 0), A(10), udqm, ldqm, ba, cs#, ras#, cas#, we#
    signal sdram_control : std_logic_vector (20 downto 0);
    constant sdram_control_init_nop : std_logic_vector (20 downto 0) := x"000" & '0' & "11" & "00" & cmd_nop;
    constant sdram_control_nop : std_logic_vector (20 downto 0) := x"000" & '0' & "00" & "00" & cmd_nop;
    
    signal iob_cmd : std_logic_vector (3 downto 0) := cmd_deselect;
    --attribute iob : string;
    --attribute iob of iob_cmd : signal is "true";

    --Holds the current address
    -- (24) => write_req
    -- (23 downto 21) => bank
    -- (21 downto 9) => row address
    -- (8 downto 0) => column address
    signal req_out, req_in : std_logic_vector (24 downto 0);
    signal req_queue_enqueue : std_logic := '0';
    signal get_next_request : std_logic;
    signal req_queue_empty : std_logic;
    
    --data fifos
    signal tx_ready, rx_ready : std_logic;
    signal tx_empty, rx_empty : std_logic;
    signal read_active : std_logic := '0';
    signal write_active : std_logic := '0';

    component fifo is
    generic
    (
        depth : integer range 1 to 512 := 8;
        bitwidth : integer range 1 to 32 := 32
    );
    port
    (
        clock   : in  std_logic;
        enqueue : in  std_logic;
        dequeue : in  std_logic;
        enable  : in  std_logic;
        d_in    : in  std_logic_vector (bitwidth - 1 downto 0);
        d_out   : out std_logic_vector (bitwidth - 1 downto 0);
        empty   : out std_logic
    );
    end component;

begin
    
    --Need to add logic to modify cke if the tx_buffer is empty
    tx_data : fifo
    generic map
    (
        depth => 512,
        bitwidth => 16
    )
    port map
    (
        clock => clock,
        enqueue => wrt_to_buff,
        dequeue => write_active,
        enable => '1',
        d_in => d_in,
        d_out => ram_data_in,
        empty => tx_empty
    );

    rx_data : fifo
    generic map
    (
        depth => 512,
        bitwidth => 16
    )
    port map
    (
        clock => clock,
        enqueue => read_active,
        dequeue => rd_from_buff,
        enable => '1',
        d_in => ram_data_out,
        d_out => d_out,
        empty => rx_empty
    );

    req_queue : fifo
    generic map
    (
        depth => 4,
        bitwidth => 25
    )
    port map
    (
        clock => clock,
        enqueue => req_queue_enqueue,
        dequeue => get_next_request,
        enable => cs,
        d_in => req_in,
        d_out => req_out,
        empty => req_queue_empty
    );

    req_in <= write_req & addr;

    read_ready <= not rx_empty;
    write_ready <= tx_empty;

    req_queue_enqueue <= read_req or write_req;

    mode_reg <= "000" & '0' & "00" & std_logic_vector(to_unsigned(CAS_latency, 3)) & '0' & burst_length;
    
    we <= iob_cmd(0);
    cas <= iob_cmd(1);
    ras <= iob_cmd(2);
    sdram_cs <= iob_cmd(3);

    ram_addr <= sdram_control(20 downto 19) & sdram_control(8) & sdram_control(18 downto 9);
    iob_cmd <= sdram_control(3 downto 0);
    ba <= sdram_control(5 downto 4);
    udqm <= sdram_control(7);
    ldqm <= sdram_control(6);

    sdram_clk <= clock;
    ram_data_sel <= not read_active;

    -- Transition Logic
    fsm_transition : process(clock, state)
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
                when init_precharge => nextstate <= init_wait2;

                when init_wait2 =>
                    if init_pretoset_timer > 0 then
                        init_pretoset_timer <= init_pretoset_timer - 1;
                    else
                        nextstate <= init_setmode;
                    end if;

                when init_setmode => nextstate <= init_wait4;

                when init_wait3 =>
                    if init_settoref0_timer > 0 then
                        init_settoref0_timer <= init_settoref0_timer - 1;
                    else
                        nextstate <= init_refresh0;
                    end if;

                when init_refresh0 => nextstate <= init_wait4;

                when init_wait4 =>
                    if init_ref0toref1_timer > 0 then
                        init_ref0toref1_timer <= init_ref0toref1_timer - 1;
                    else
                        nextstate <= init_refresh1;
                    end if;

                when init_refresh1 => nextstate <= init_wait5;

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
                    if req_queue_empty = '0' then
                        if req_out(24) = '1' then
                            nextstate <= wrt_bankact;
                        else
                            nextstate <= rd_bankact;
                        end if;
                        idle_timer <= idle_timer_default;
                    elsif idle_timer > 0 then
                        idle_timer <= idle_timer - 1;
                    end if;

                --------------------------------------------------------
                -- Read
                --------------------------------------------------------
                when rd_bankact => nextstate <= rd_wait0;

                when rd_wait0 =>
                    if rd_bnktord_timer > 0 then
                        rd_bnktord_timer <= rd_bnktord_timer - 1;
                    else
                        rd_bnktord_timer <= bank_activate_delay_default;
                        nextstate <= rd;
                    end if;

                when rd => nextstate <= rd_wait1;
                when rd_wait1 => nextstate <= rd_wait2;
                when rd_wait2 => nextstate <= rd_wait3;

                when rd_wait3 =>
                    if rd_timer > 0 then
                        rd_timer <= rd_timer - 1;
                    else
                        rd_timer <= rd_timer_default;
                        nextstate <= rd_bursthlt;
                    end if;

                when rd_bursthlt => nextstate <= rd_precharge;
                when rd_precharge => nextstate <= rd_wait4;
                when rd_wait4 => nextstate <= rd_wait5;
                when rd_wait5 => nextstate <= idle;

                --------------------------------------------------------
                -- Write
                --------------------------------------------------------
                when wrt_bankact => nextstate <= wrt_wait0;

                when wrt_wait0 =>
                    if wrt_bnktowrt_timer > 0 then
                        wrt_bnktowrt_timer <= wrt_bnktowrt_timer - 1;
                    else
                        wrt_bnktowrt_timer <= bank_activate_delay_default;
                        nextstate <= wrt;
                    end if;

                when wrt =>
                    if tx_empty /= '1' then
                        nextstate <= wrt_wait1;
                    end if;

                when wrt_wait1 =>
                    if wrt_timer > 0 then
                        if tx_empty /= '1' then
                            wrt_timer <= wrt_timer - 1;
                        end if;
                    else
                        wrt_timer <= wrt_timer_default;
                        nextstate <= wrt_bursthlt;
                    end if;

                when wrt_bursthlt => nextstate <= wrt_precharge;
                when wrt_precharge => nextstate <= wrt_wait2;
                when wrt_wait2 => nextstate <= idle;

                --------------------------------------------------------
                -- Refresh
                --------------------------------------------------------
                when refresh => nextstate <= refresh_wait;

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

    sdram_control_output : process(state, mode_reg, req_out)
    begin
        case state is
            --------------------------------------------------------
            -- Initialization
            --------------------------------------------------------
            when init_wait0 => sdram_control <= x"000" & '0' & "11" & "00" & cmd_deselect;
            when init_wait1 => sdram_control <= sdram_control_init_nop;
            when init_precharge => sdram_control <= x"000" & '1' & "11" & "00" & cmd_prechrg;
            when init_wait2 => sdram_control <= sdram_control_init_nop;
            when init_setmode => sdram_control <= mode_reg(12 downto 11) & mode_reg(9 downto 0) & mode_reg(10) & "11" & "00" & cmd_setmode;
            when init_wait3 => sdram_control <= sdram_control_init_nop;
            when init_refresh0 => sdram_control <= x"000" & '0' & "11" & "00" & cmd_refresh;
            when init_wait4 => sdram_control <= sdram_control_init_nop;
            when init_refresh1 => sdram_control <= x"000" & '0' & "11" & "00" & cmd_refresh;
            when init_wait5 => sdram_control <= sdram_control_init_nop;

            --------------------------------------------------------
            -- Read
            --------------------------------------------------------
            when rd_bankact => sdram_control <= req_out(21 downto 20) & req_out(18 downto 9) & req_out(19) & "00" & req_out(23 downto 22) & cmd_bnkact;
            when rd => sdram_control <= "00" & ('0' & req_out(8 downto 0)) & '0' & "00" & req_out(23 downto 22) & cmd_read;
            when rd_bursthlt => sdram_control <= x"000" & '0' & "00" & "00" & cmd_hltbrst;
            when rd_precharge => sdram_control <= x"000" & '1' & "00" & "00" & cmd_prechrg;

            --------------------------------------------------------
            -- Write
            --------------------------------------------------------
            when wrt_bankact => sdram_control <= req_out(21 downto 20) & req_out(18 downto 9) & req_out(19) & "00" & req_out(23 downto 22) & cmd_bnkact;
            when wrt => sdram_control <= "00" & ('0' & req_out(8 downto 0)) & '0' & "00" & req_out(23 downto 22) & cmd_write;
            when wrt_bursthlt => sdram_control <= x"000" & '0' & "00" & "00" & cmd_hltbrst;
            when wrt_precharge => sdram_control <= x"000" & '1' & "00" & "00" & cmd_prechrg;

            --------------------------------------------------------
            -- Refresh
            --------------------------------------------------------
            when refresh => sdram_control <= x"000" & '0' & "00" & "00" & cmd_refresh;
            when others => sdram_control <= sdram_control_nop;

        end case;
    end process;

    rd_active_output : process(state)
    begin
        case state is
            when rd_wait3 => read_active <= '1';
            when rd_bursthlt => read_active <= '1';
            when rd_precharge => read_active <= '1';
            when rd_wait4 => read_active <= '1';
            when others => read_active <= '0';
        end case;
    end process;

    wrt_active_output : process(state)
    begin
        case state is
            when wrt => write_active <= '1';
            when wrt_wait1 => write_active <= '1';
            when others => write_active <= '0';
        end case;
    end process;

    get_next_request <= '1' when (state = idle and req_queue_empty = '0') else '0';

    cke <= '0' when state = init_wait0 else '1';

end behavioral;