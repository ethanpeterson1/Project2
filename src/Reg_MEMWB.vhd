library IEEE;
use IEEE.std_logic_1164.all;


entity Reg_MEMWB is
generic(N : integer := 170);
  port(	i_CLKn        	: in std_logic;     -- Clock input
       	i_RSTn        	: in std_logic;     -- Reset input
       	i_WEn         	: in std_logic;     -- Write enable input


	i_ALUOut	: in std_logic_vector(31 downto 0);
	i_Forward_ALUOut: in std_logic_vector(31 downto 0);
	i_OutMux	: in std_logic_vector(31 downto 0);
	i_RSOut		: in std_logic_vector(31 downto 0);
	i_IFID_Out	: in std_logic_vector(31 downto 0);
	i_WriteRegAdd	: in std_logic_vector(4 downto 0);
	i_jrControl	: in std_logic;
	i_MemWrite	: in std_logic;
	i_Branch	: in std_logic;
	i_MemToReg	: in std_logic;
	i_RegWrite	: in std_logic;

	o_ALUOut	: out std_logic_vector(31 downto 0);
	o_Forward_ALUOut: out std_logic_vector(31 downto 0);
	o_OutMux	: out std_logic_vector(31 downto 0);
	o_RSOut		: out std_logic_vector(31 downto 0);
	o_IFID_Out	: out std_logic_vector(31 downto 0);
	o_WriteRegAdd	: out std_logic_vector(4 downto 0);
	o_jrControl	: out std_logic;
   	o_MemWrite    	: out std_logic;
    	o_Branch    	: out std_logic;
    	o_MemToReg    	: out std_logic;
    	o_RegWrite    	: out std_logic);

end Reg_MEMWB;

architecture structural of Reg_MEMWB is
component register_170 is
port(i_CLKn        : in std_logic;     -- Clock input
       i_RSTn        : in std_logic;     -- Reset input
       i_WEn         : in std_logic;     -- Write enable input
       i_Dn          : in std_logic_vector(169 downto 0);     -- Data value input
       o_Qn          : out std_logic_vector(169 downto 0));   -- Data value output
end component;

signal S_Reg_Inputs: std_logic_vector(169 downto 0);
signal S_Reg_Outputs: std_logic_vector(169 downto 0);

begin
S_Reg_Inputs <= i_RegWrite & 
		i_MemToReg & 
		i_Branch &
		i_MemWrite &
		i_jrControl &
		i_WriteRegAdd &
		i_IFID_Out &
		i_RSOut &
		i_OutMux &
		i_Forward_ALUOut &
		i_ALUOut;
		
REG: register_170 port map(
	i_CLKn => i_CLKn, 
       	i_RSTn => i_RSTn,
       	i_WEn  => i_WEn,
       	i_Dn   => S_Reg_Inputs,
       	o_Qn   => S_Reg_Outputs);

o_ALUOut <= S_Reg_Outputs(31 downto 0);
o_Forward_ALUOut <= S_Reg_Outputs(63 downto 32);
o_OutMux <= S_Reg_Outputs(95 downto 64);
o_RSOut <= S_Reg_Outputs(127 downto 96);
o_IFID_Out <= S_Reg_Outputs(159 downto 128);
o_WriteRegAdd <= S_Reg_Outputs(164 downto 160);
o_jrControl <= S_Reg_Outputs(165);
o_MemWrite <= S_Reg_Outputs(166);
o_Branch <= S_Reg_Outputs(167);
o_MemToReg <= S_Reg_Outputs(168);
o_RegWrite <= S_Reg_Outputs(169);


end structural;