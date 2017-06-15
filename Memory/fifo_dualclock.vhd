----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    14:09:00 05/30/2017 
-- Design Name: 
-- Module Name:    fifo_dualclock - behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- FIFO with separate read and write clocks
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

library unisim;
use unisim.vcomponents.all;

entity fifo_dualclock is
    port
    (
        enqueue_clk   : in  std_logic;
        dequeue_clk   : in  std_logic;
        enqueue_en    : in  std_logic;
        dequeue_en    : in  std_logic;
        d_in          : in  std_logic_vector (15 downto 0);
        d_out         : out std_logic_vector (15 downto 0);
        status        : out std_logic_vector (1 downto 0) --full & empty
    );
end entity;

architecture behavioral of fifo_dualclock is

    --type queue is array (0 to 511) of std_logic_vector (15 downto 0);
    --signal data : queue := (0 to 511 => (15 downto 0 => '0'));

    signal read_ptr, write_ptr : std_logic_vector (8 downto 0);
    signal read_gray, write_gray : std_logic_vector (8 downto 0);
    signal read_gray_synch, write_gray_synch : std_logic_vector (8 downto 0) := (others => '0');
    signal en_ct_ovr, de_ct_ovr : std_logic := '0';
    signal en_ct_ovr_synch, de_ct_ovr_synch : std_logic := '0';

    signal enqueue, dequeue : std_logic := '0';
    signal full, empty : std_logic;

    signal d_out_buff, d_in_buff : std_logic_vector (31 downto 0);
    signal addra_buff, addrb_buff : std_logic_vector (13 downto 0);

    component gray
        port
        (
            clock    : in  std_logic;
            enable   : in  std_logic;
            binary   : out std_logic_vector (8 downto 0);
            gray_out : out std_logic_vector (8 downto 0);
            overflow : out std_logic
        );
    end component;

begin

    enqueue_counter : gray
    port map
    (
        clock => enqueue_clk,
        enable => enqueue,
        binary => write_ptr,
        gray_out => write_gray,
        overflow => en_ct_ovr
    );

    dequeue_counter : gray
    port map
    (
        clock => dequeue_clk,
        enable => dequeue,
        binary => read_ptr,
        gray_out => read_gray,
        overflow => de_ct_ovr
    );

    read_synch : process (enqueue_clk, en_ct_ovr, read_gray)
    begin
        if rising_edge(enqueue_clk) then
            read_gray_synch <= read_gray;
            en_ct_ovr_synch <= en_ct_ovr;
        end if;
    end process;

    write_synch : process (dequeue_clk, de_ct_ovr, write_gray)
    begin
        if rising_edge(dequeue_clk) then
            write_gray_synch <= write_gray;
            de_ct_ovr_synch <= de_ct_ovr;
        end if;
    end process;

    empty <= '1' when (write_gray_synch = read_gray and en_ct_ovr = de_ct_ovr_synch) else '0';
    full <= '1' when (read_gray_synch = write_gray and de_ct_ovr /= en_ct_ovr_synch) else '0';

    status <= full & empty;

    enqueue <= enqueue_en and (not full);
    dequeue <= dequeue_en and (not empty);

    --block ram
    RAMB16BWER_inst: RAMB16BWER    
    generic map (
        DATA_WIDTH_A => 18,
        DOA_REG => 0,
        DATA_WIDTH_B => 18,
        DOB_REG => 0
    )
    port map
    (
        --Port A (write port)
        dia => d_in_buff, --data in
        dipa => x"0", --data in parity (additional storage space, no actual parity logic in bram)
        addra => addra_buff, --address
        wea => x"f", --write enable
        ena => enqueue, --enable (enables/disables read, write, and reset of bram)
        regcea => '0', --enables latching of data to output register
        rsta => '0',
        clka => enqueue_clk,
        doa => open,
        dopa => open,
        --Port B (read port)
        dib => x"00000000",
        dipb => x"0",
        addrb => addrb_buff,
        web => x"0",
        enb => dequeue,
        regceb => '0',
        rstb => '0',
        clkb => dequeue_clk,
        dob => d_out_buff,
        dopb => open
    );

    addra_buff <= write_ptr & "00000";
    addrb_buff <= read_ptr & "00000";

    d_in_buff <= x"0000" & d_in;
    d_out <= d_out_buff(15 downto 0);

end behavioral;