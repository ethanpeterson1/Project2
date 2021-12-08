library IEEE;
use IEEE.std_logic_1164.all;
--DO NOT implement until we have software scheduled pipelined fully implemented
entity ForwardingUnit is
	port(IDEXRT	: in std_logic_vector(4 downto 0);
	     IDEXRS	: in std_logic_vector(4 downto 0);
	     EXMEMRD	: in std_logic_vector(4 downto 0);
	     EXMEMRegWrite : in std_logic;
	     MEMWBRD	: in std_logic_vector(4 downto 0);
	     MEMWBRegWrite : in std_logic;
	     ForwardA	: out std_logic_vector(1 downto 0);
	     ForwardB	: out std_logic_vector(1 downto 0)
	);
end ForwardingUnit;

architecture behavior of ForwardingUnit is
begin
	process(IDEXRT,IDEXRS,EXMEMRD,EXMEMRegWrite, MEMWBRD,MEMWBRegWrite,ForwardA,ForwardB)
	begin
	if EXMEMRegWrite = '1' and EXMEMRD /= "00000" and EXMEMRD = IDEXRT then
		ForwardA <= "10";
	elsif EXMEMRegWrite = '1' and EXMEMRD /= "00000" and EXMEMRD = IDEXRS then
		ForwardB <= "10";
	elsif MEMWBRegWrite = '1' and MEMWBRD /= "00000" and MEMWBRD = IDEXRS and not(EXMEMRegWrite = '1' and EXMEMRD /= "00000" and EXMEMRD /= IDEXRS)then 
		ForwardA <= "01";
	elsif MEMWBRegWrite = '1' and MEMWBRD /= "00000" and MEMWBRD = IDEXRT and not(EXMEMRegWrite = '1' and EXMEMRD /= "00000" and EXMEMRD /= IDEXRT)then
		ForwardB <= "01";
	else 
		ForwardA <= "00";
		ForwardB <= "00";
	end if;
	end process;
end behavior;