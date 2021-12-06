library IEEE;
use IEEE.std_logic_1164.all;
--DO NOT implement until we have software scheduled pipelined fully implemented
entity ForwardingUnit is
	port(ID/EXRT	: in std_logic_vector(4 downto 0);
	     ID/EXRS	: in std_logic_vector(4 downto 0);
	     EX/MEMRD	: in std_logic_vector(4 downto 0);
	     EX/MEMRegWrite : in std_logic;
	     MEM/WBRD	: in std_logic_vector(4 downto 0);
	     MEM/WBRegWrite : in std_logic;
	     ForwardA	: out std_logic_vector(1 downto 0);
	     ForwardB	: out std_logic_vector(1 downto 0);
	);
end ForwardingUnit;

architecture behavior of ForwardingUnit is
begin
	process(ID/EXRT,ID/EXRS,EX/MEMRD,EX/MEMRegWrite, MEM/WBRD,MEM/WBRegWrite,ForwardA,ForwardB)
	begin
	if EX/MEMRegWrite = '1' and EX/MEMRD /= "00000" and EX/MEMRD = ID/EXRT then
		ForwardA = "10";
	elsif EX/MEMRegWrite = '1' and EX/MEMRD /= "00000" and EX/MEMRD = ID/EXRS then
		ForwardB = "10";
	elsif MEM/WBRegWrite = '1' and MEM/WBRD /= "00000" and MEM/WBRD = ID/EXRS and not(EX/MEMRegWrite = '1' and EX/MEMRD /= "00000" and EX/MEMRD /= ID/EXRS)then 
		ForwardA = "01";
	elsif MEM/WBRegWrite = '1' and MEM/WBRD /= "00000" and MEM/WBRD = ID/EXRT and not(EX/MEMRegWrite = '1' and EX/MEMRD /= "00000" and EX/MEMRD /= ID/EXRT)then
		ForwardB = "01";
	else 
		ForwardA = "00";
		ForwardB = "00";
	end if;
	end process;
end behavior;