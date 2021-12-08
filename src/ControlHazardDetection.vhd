library IEEE; 
use IEEE.std_logic_1164.all;

entity ControlHazardDetection is

 port(
	iIDEXRegWr		: in std_logic;
	iIDEXMemToReg		: in std_logic;
	iBranchNotEqual		: in std_logic;
	iBranchCtrl 		: in std_logic;
	iALUOp			: in std_logic_vector(3 downto 0);
	iRS			: in std_logic_vector(4 downto 0);
	iRT			: in std_logic_vector(4 downto 0);
	iIDEXWriteReg		: in std_logic_vector(4 downto 0);
	iIDEXRS			: in std_logic_vector(4 downto 0);
	iJumpCtrl		: in std_logic;
	IF_Flush 		: out std_logic; 
	oStallsNeeded		: out std_logic_vector(1 downto 0)
      );
end ControlHazardDetection;

architecture behavior of ControlHazardDetection is

begin
	process(iJumpCtrl, iBranchNotEqual, iBranchCtrl, iIDEXRegWr, iIDEXMemToReg, iRS, iRT, iIDEXWriteReg, iIDEXRS)
	begin

	if iJumpCtrl = '1' then	--Jump instruction
		IF_Flush 	<= '1';
		oStallsNeeded	<= "00";

	elsif iBranchCtrl = '1' AND iALUOp = "1100" then --BEQ
		if iBranchNotEqual = '0' then	--If true, Branch Equal, then check for data hazard

			IF_Flush 	<= '1';	--Needs to flush with or without data hazards

			if iIDEXMemToReg = '0' AND iIDEXRegWr = '1' AND (iRS = iIDEXWriteReg OR iRT = iIDEXWriteReg) then	--If there is a ALU operation right before branch instruction. Need one stall
				
				oStallsNeeded	<= "01";	--One stall needed

			elsif iIDEXMemToReg = '1' AND iIDEXRegWr = '1' AND (iRS = iIDEXRS OR iRT = iIDEXRS) then	--If there is a LW instruction right before branch instruction. Need two stalls
				
				oStallsNeeded	<= "10";	--Two stalls needed

			else		--If there are no data hazards. Need one flush only
				
				oStallsNeeded	<= "00";	--No stalls needed
				
			end if;
		else	--If branch instruction doesn't branch, false
			IF_FLush 	<= '0';
			oStallsNeeded	<= "00";

		end if;
		

	elsif iBranchCtrl = '1' AND iALUOp = "1101" then --BNE
		if iBranchNotEqual = '1' then	--If true, Branch Not Equal, then check for data hazard
			IF_Flush 	<= '1';
			if iIDEXMemToReg = '0' AND iIDEXRegWr = '1' AND (iRS = iIDEXWriteReg OR iRT = iIDEXWriteReg) then	--If there is a ALU operation right before branch instruction. Need one stall
				
				oStallsNeeded	<= "01";	--One stall needed

			elsif iIDEXMemToReg = '1' AND iIDEXRegWr = '1' AND (iRS = iIDEXRS OR iRT = iIDEXRS) then	--If there is a LW instruction right before branch instruction. Need two stalls
				
				oStallsNeeded	<= "10";	--Two stalls needed

			else		--If there are no data hazards. Need one flush only
				
				oStallsNeeded	<= "00";	--No stalls needed

			end if;
		else	-- If branch instruction doesn't need to branch, false
			IF_FLush 	<= '0';
			oStallsNeeded	<= "00";
		end if;

	else	-- If not a branch or jump, no control hazard detection needed
		IF_FLush 	<= '0';
		oStallsNeeded	<= "00";
	end if;
	end process;
	

end behavior;