library IEEE;
use IEEE.std_logic_1164.all;

entity Reg_IFID is
generic(N : integer := 64);
  port(	i_CLKn        	: in std_logic;     -- Clock input
       	i_RSTn        	: in std_logic;     -- Reset input
       	i_WEn         	: in std_logic;     -- Write enable input
       	i_Instruction 	: in std_logic_vector(31 downto 0);    
	i_PC		: in std_logic_vector(31 downto 0);
	--i_Flush		: in std_logic;
	o_Instruction 	: out std_logic_vector(31 downto 0);    
	o_PC		: out std_logic_vector(31 downto 0)
	--o_Flush		: out std_logic WILL BE IMPLEMENT FOR HARDWARD SCHEDULED PIPELINING
	);
end Reg_IFID;

architecture structural of Reg_IFID is
component register_64 is
port(i_CLK           : in std_logic;     -- Clock input
       i_RST         : in std_logic;     -- Reset input
       i_WE          : in std_logic;     -- Write enable input
       i_D           : in std_logic_vector(63 downto 0);     -- Data value input
       o_Q           : out std_logic_vector(63 downto 0));   -- Data value output
end component;

signal S_Reg_Inputs: std_logic_vector(63 downto 0);
signal S_Reg_Outputs: std_logic_vector(63 downto 0);

begin

S_Reg_Inputs <= i_PC & i_Instruction;
--i_Flush & i_PC & i_Instruction;

REG: register_64 port map(
	i_CLK  => i_CLKn, 
       	i_RST  => i_RSTn,
       	i_WE   => i_WEn,
       	i_D    => S_Reg_Inputs,
       	o_Q    => S_Reg_Outputs);
o_Instruction 	<= S_Reg_Outputs(31 downto 0);
o_PC		<= S_Reg_Outputs(63 downto 32);
--o_Flush		<= S_Reg_Outputs(64);

end structural;
