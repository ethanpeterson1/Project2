library IEEE; 
use IEEE.std_logic_1164.all;

entity ControlHazardDetection is

 port(
	PrevInstrRegWr		: in std_logic;
	PrevInstrMemToReg	: in std_logic;
	BranchEqual		: in std_logic;
	iBranchCtrl 		: in std_logic;
	iALUOp			: in std_logic_vector(3 downto 0);
	iJumpCtrl		: in std_logic;
--	iJALCtrl	: in std_logic;
--	iJRCtrl	 	: in std_logic;
	IF_Flush 		: out std_logic; 
	OneStall 		: out std_logic;
	TwoStalls		: out std_logic
 
      );
end ControlHazardDetection;

architecture behavior of ControlHazardDetection is

begin
	process(iJumpCtrl, BranchEqual, iBranchCtrl, PrevInstrRegWr, PrevInstrMemToReg)
	begin
	-- if BranchEqual = "0x00000000" then
	-- 	

	if iJumpCtrl = '1' then
		IF_Flush 	<= '1';
		OneStall 	<= '0';
		TwoStalls	<= '0';
	elsif iBranchCtrl = '1' AND iALUOp = "1100" then --BEQ
		if BranchEqual = '1' then
			
		else
		
		end if;
		

	elsif iBranchCtrl = '1' AND iALUOp = "1101" then --BNE
		if then
		
		else

		end if;

	else
		IF_FLush 	<= '0';
		OneStall 	<= '0';
		TwoStalls	<= '0';
	end if;
	end process;
	

end behavior;