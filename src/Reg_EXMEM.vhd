library IEEE;
use IEEE.std_logic_1164.all;


entity Reg_EXMEM is
generic(N : integer := 211);
  port(	i_CLKn        	: in std_logic;     -- Clock input
       	i_RSTn        	: in std_logic;     -- Reset input
       	i_WEn         	: in std_logic;     -- Write enable input


	i_ALUOut	: in std_logic_vector(31 downto 0);
	i_Forward_ALUOut: in std_logic_vector(31 downto 0);
	i_OutMux	: in std_logic_vector(31 downto 0);
	i_DMEMOut	: in std_logic_vector(31 downto 0);
	i_JrMuxOut	: in std_logic_vector(31 downto 0);
	i_MemToReg	: in std_logic;
	i_RegWr		: in std_logic;
	i_WriteRegAdd	: in std_logic_vector(4 downto 0);

	
	o_ALUOut	: out std_logic_vector(31 downto 0);
	o_Forward_ALUOut: out std_logic_vector(31 downto 0);
	o_OutMux	: out std_logic_vector(31 downto 0);
	o_DMEMOut	: out std_logic_vector(31 downto 0);
	o_JrMuxOut	: out std_logic_vector(31 downto 0);
	o_MemToReg	: out std_logic;
	o_RegWr		: out std_logic;
	o_WriteRegAdd	: out std_logic_vector(4 downto 0));
	

end Reg_EXMEM;

architecture structural of Reg_EXMEM is
component register_167 is
port(i_CLKn        : in std_logic;     -- Clock input
       i_RSTn        : in std_logic;     -- Reset input
       i_WEn         : in std_logic;     -- Write enable input
       i_Dn          : in std_logic_vector(166 downto 0);     -- Data value input
       o_Qn          : out std_logic_vector(166 downto 0));   -- Data value output
end component;

signal S_Reg_Inputs: std_logic_vector(166 downto 0);
signal S_Reg_Outputs: std_logic_vector(166 downto 0);

begin
S_Reg_Inputs <= i_WriteRegAdd &
		i_RegWr & 
		i_MemToReg & 
		i_JrMuxOut &
		i_DMEMOut &
		i_OutMux &
		i_Forward_ALUOut &
		i_ALUOut;
		
REG: register_167 port map(
	i_CLKn => i_CLKn, 
       	i_RSTn => i_RSTn,
       	i_WEn  => i_WEn,
       	i_Dn   => S_Reg_Inputs,
       	o_Qn   => S_Reg_Outputs);


o_ALUOut <= S_Reg_Outputs(31 downto 0);
o_Forward_ALUOut <= S_Reg_Outputs(63 downto 32);
o_OutMux <= S_Reg_Outputs(95 downto 64);
o_DMEMOut <= S_Reg_Outputs(127 downto 96);
o_JrMuxOut <= S_Reg_Outputs(159 downto 128);
o_MemToReg <= S_Reg_Outputs(160);
o_RegWr <= S_Reg_Outputs(161);
o_WriteRegAdd <= S_Reg_Outputs(166 downto 162);



end structural;