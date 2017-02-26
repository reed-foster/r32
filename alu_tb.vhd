--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:40:32 02/26/2017
-- Design Name:   
-- Module Name:   C:/Users/Reed2/Desktop/XilinxPrograms/r32/alu_tb.vhd
-- Project Name:  r32
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
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
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         a : IN  std_logic_vector(31 downto 0);
         b : IN  std_logic_vector(31 downto 0);
         opcode : IN  std_logic_vector(3 downto 0);
         shamt : IN  std_logic_vector(4 downto 0);
         compare : IN  std_logic_vector(3 downto 0);
         output : OUT  std_logic_vector(31 downto 0);
         exception : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal a : std_logic_vector(31 downto 0) := (others => '0');
   signal b : std_logic_vector(31 downto 0) := (others => '0');
   signal opcode : std_logic_vector(3 downto 0) := (others => '0');
   signal shamt : std_logic_vector(4 downto 0) := (others => '0');
   signal compare : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(31 downto 0);
   signal exception : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          a => a,
          b => b,
          opcode => opcode,
          shamt => shamt,
          compare => compare,
          output => output,
          exception => exception
        );

   -- Clock process definitions
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
      a <= x"00000001";
      b <= x"00000000";
      opcode <= "0000";
      shamt <= "00000";
      compare <= "0000";
      
      wait for 100 ns;
      shamt <= "00001";
      wait for 100 ns;
      shamt <= "00010";
      wait for 100 ns;
      shamt <= "00011";
      wait for 100 ns;
      shamt <= "00100";
      
      wait for 500 ns;
      a <= x"00010000";
      opcode <= "0010";
      
      
      wait for 100 ns;
      shamt <= "00001";
      wait for 100 ns;
      shamt <= "00010";
      wait for 100 ns;
      shamt <= "00011";
      wait for 100 ns;
      shamt <= "00100";
      
      wait for 500 ns;
      a <= x"80000000";
      opcode <= "0100";
      shamt <= "00000";
      
      wait for 100 ns;
      shamt <= "00001";
      wait for 100 ns;
      shamt <= "00010";
      wait for 100 ns;
      shamt <= "00011";
      wait for 100 ns;
      shamt <= "00100";

      -- insert stimulus here 

      wait;
   end process;

END;
