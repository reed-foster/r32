-- Reed Foster Aug 2017
-- fifoasync.vhd - A fifo with separate read and write clocks

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifoasync is
    generic
    (
        bitwidth : integer range 1 to 32 := 32;
        delay : integer range 2 to 5 := 2
    );
    port
    (
        wrt_clock   : in  std_logic;
        rd_clock    : in  std_logic;
        enqueue     : in  std_logic;
        dequeue     : in  std_logic;
        d_in        : in  std_logic_vector(bitwidth - 1 downto 0);
        d_out       : out std_logic_vector(bitwidth - 1 downto 0)
    );
end entity;

architecture behavioral of fifoasync is

    type ramtype is array(0 to depth - 1) of std_logic_vector (bitwidth - 1 downto 0);
    signal mem : ramtype;

    signal wrt_en, rd_en : std_logic;
    signal wrt_addr, rd_addr, wrt_addr_sync, rd_addr_sync : integer range 0 to 511;
    signal wrt_addr_gray, rd_addr_gray, wrt_addr_gray_sync, rd_addr_gray_sync : std_logic_vector (8 downto 0);
    signal almost_full, almost_empty : std_logic;

begin

    process (wrt_clock, rd_clock)
    begin
        if rising_edge(wrt_clock) and wrt_en = '1' then
            mem(wrt_addr) <= d_in;
            if wrt_addr >= 511 then
                wrt_addr <= 0;
            else
                wrt_addr <= rd_addr + 1;
            end if;
        end if;

        if rising_edge(rd_clock) and rd_en = '1' then
            d_out <= mem(rd_addr);
            if rd_addr >= 511 then
                rd_addr <= 0;
            else
                rd_addr <= rd_addr + 1;
            end if;
        end if;

        if rising_edge(wrt_clock) then
            rd_addr_gray_sync <= rd_addr_gray;
        end if;

        if rising_edge(rd_clock) then
            wrt_addr_gray_sync <= wrt_addr_gray;
        end if;
    end process;

    wrt_en <= enqueue and (not almost_full);
    rd_en <= dequeue and (not almost_empty);

    almost_empty <= '1' when unsigned(wrt_addr_sync - rd_addr) < delay else '0';
    almost_full <= '1' when unsigned(rd_addr_sync - wrt_addr) < delay else '0';

    --binary to gray conversion

    --gray to binary conversion

end architecture;
