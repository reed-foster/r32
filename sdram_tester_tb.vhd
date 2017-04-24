--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:11:12 04/23/2017
-- Design Name:   
-- Module Name:   /home/reed/xilinx_projects/r32/sdram_tester_tb.vhd
-- Project Name:  r32
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sdram_tester
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY sdram_tester_tb IS
END sdram_tester_tb;
 
ARCHITECTURE behavior OF sdram_tester_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sdram_tester
    PORT(
         clock_in : IN  std_logic;
         byte_out : OUT  std_logic_vector(7 downto 0);
         byte_out_v : OUT  std_logic;
         sdram_clk : OUT  std_logic;
         cke : OUT  std_logic;
         udqm : OUT  std_logic;
         ldqm : OUT  std_logic;
         ba : OUT  std_logic_vector(1 downto 0);
         sdram_cs : OUT  std_logic;
         ras : OUT  std_logic;
         cas : OUT  std_logic;
         we : OUT  std_logic;
         ram_addr : OUT  std_logic_vector(12 downto 0);
         ram_data : INOUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clock_in : std_logic := '0';
   signal ram_data : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal byte_out : std_logic_vector(7 downto 0);
   signal byte_out_v : std_logic;
   signal sdram_clk : std_logic;
   signal cke : std_logic;
   signal udqm : std_logic;
   signal ldqm : std_logic;
   signal ba : std_logic_vector(1 downto 0);
   signal sdram_cs : std_logic;
   signal ras : std_logic;
   signal cas : std_logic;
   signal we : std_logic;
   signal ram_addr : std_logic_vector(12 downto 0);

   -- Clock period definitions
   constant clock_in_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sdram_tester PORT MAP (
          clock_in => clock_in,
          byte_out => byte_out,
          byte_out_v => byte_out_v,
          sdram_clk => sdram_clk,
          cke => cke,
          udqm => udqm,
          ldqm => ldqm,
          ba => ba,
          sdram_cs => sdram_cs,
          ras => ras,
          cas => cas,
          we => we,
          ram_addr => ram_addr,
          ram_data => ram_data
        );

   -- Clock process definitions
   clock_in_process :process
   begin
		clock_in <= '0';
		wait for clock_in_period/2;
		clock_in <= '1';
		wait for clock_in_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for 100 ns;
   end process;

END;
