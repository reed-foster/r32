----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Reed Foster
-- 
-- Create Date:    14:47:30 04/17/2017 
-- Design Name: 
-- Module Name:    sdram_request_queue - behavioral 
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

use ieee.numeric_std.all;


entity sdram_request_queue is
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
end sdram_request_queue;

architecture behavioral of sdram_request_queue is
    type queue is array (0 to depth - 1) of std_logic_vector (24 downto 0);

    signal buffdata : queue := (0 to depth - 1 => (24 downto 0 => '0'));

    signal enqueue_ptr : integer := 0;
    signal dequeue_ptr : integer := 0;
    signal empty_tmp : std_logic;
    signal full_tmp : std_logic;

    signal enqueue_ptr_ovr : std_logic := '0';
    signal dequeue_ptr_ovr : std_logic := '0';
begin
    
    update_ptrs : process (clock, read_req, write_req, address, empty_tmp, full_tmp) is
    begin
        if rising_edge(clock) then
            if read_req = '1' and full_tmp /= '1' then
                buffdata(enqueue_ptr) <= '0' & address;
                enqueue_ptr <= enqueue_ptr + 1;
                if enqueue_ptr >= depth then
                    enqueue_ptr <= 0;
                    enqueue_ptr_ovr <= not enqueue_ptr_ovr;
                end if;
            end if;
            if write_req = '1' and full_tmp /= '1' then
                buffdata(enqueue_ptr) <= '1' & address;
                enqueue_ptr <= enqueue_ptr + 1;
                if enqueue_ptr >= depth then
                    enqueue_ptr <= 0;
                    enqueue_ptr_ovr <= not enqueue_ptr_ovr;
                end if;
            end if;
            if get_next = '1' and empty_tmp /= '1' then
                dequeue_ptr <= dequeue_ptr + 1;
                if dequeue_ptr >= depth then
                    dequeue_ptr <= 0;
                    dequeue_ptr_ovr <= not dequeue_ptr_ovr;
                end if;
            end if;
        end if;
    end process update_ptrs;

    full_tmp <= '1' when enqueue_ptr = dequeue_ptr and enqueue_ptr_ovr /= dequeue_ptr_ovr else '0';
    empty_tmp <= '1' when enqueue_ptr = dequeue_ptr and enqueue_ptr_ovr = dequeue_ptr_ovr else '0';
    empty <= empty_tmp;

    next_req_addr <= buffdata(dequeue_ptr)(23 downto 0);
    next_req_type <= buffdata(dequeue_ptr)(24);

end behavioral;