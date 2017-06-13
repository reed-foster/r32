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

entity fifo_dualclock is
    generic
    (
        depth : integer range 1 to 512 := 8; --must be power of 2
        bitwidth : integer range 1 to 32 := 32
    );
    port
    (
        enqueue_clk   : in  std_logic;
        dequeue_clk   : in  std_logic;
        enqueue_en    : in  std_logic;
        dequeue_en    : in  std_logic;
        d_in          : in  std_logic_vector (15 downto 0);
        d_out         : out std_logic_vector (15 downto 0);
        empty         : out std_logic
    );
end entity;

architecture behavioral of fifo_dualclock is

    type queue is array (0 to 511) of std_logic_vector (15 downto 0);
    signal data : queue := (0 to 511 => (15 downto 0 => '0'));

    signal read_ptr, write_ptr : std_logic_vector (8 downto 0);
    signal read_gray, write_gray : std_logic_vector (8 downto 0);
    signal read_gray_synch, write_gray_synch : std_logic_vector (8 downto 0);
    signal en_ct_ovr, de_ct_ovr : std_logic := '0';
    signal en_ct_ovr_synch, de_ct_ovr_synch : std_logic := '0';

    signal enqueue, dequeue : std_logic := '0';
    signal full, empty : std_logic;


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
        if rising_edge(enqueue_clk) then
            write_gray_synch <= write_gray;
            de_ct_ovr_synch <= de_ct_ovr;
        end if;
    end process;

    empty <= '1' when (write_gray_synch = read_gray and en_ct_ovr_synch = de_ct_ovr) else '0';
    full <= '1' when (read_gray_synch = write_gray and de_ct_ovr_synch /= en_ct_ovr) else '0';

    enqueue <= enqueue_en and (not full);
    dequeue <= dequeue_en and (not empty);

    --block ram
    ram : RAMB16BWER --1K x 18: 16 data + 2 parity (unused)
    generic map --configuration of mode of block ram
    (
        DATA_WIDTH_A => 18;
        DOA_REG => 0;
        RSTTYPE => SYNC
    )
    port map
    (
        --Port A (write port)
        dia => d_in, --data in
        dipa => "00", --data in parity (additional storage space, no actual parity logic in bram)
        addra => write_ptr, --address
        wea => '1', --write enable
        ena => enqueue, --enable (enables/disables read, write, and reset of bram)
        regcea => '0', --enables latching of data to output register
        rsta => '0', --
        clka => enqueue_clk,
        doa => open,
        dopa => open,
        --Port B (read port)
        dib => x"0000",
        dipb => "00",
        addrb => read_ptr,
        web => '0',
        enb => dequeue,
        regceb => '0',
        rstb => '0',
        clkb => dequeue_clk,
        dob => d_out,
        dopb => open
    );

end behavioral;