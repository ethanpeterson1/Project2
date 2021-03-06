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
	     IFIDALUOP	: in std_logic_vector(3 downto 0);
	     IFIDRS	: in std_logic_vector(4 downto 0);
	     IFIDRT	: in std_logic_vector(4 downto 0);
	     ForwardA	: out std_logic_vector(1 downto 0);
	     ForwardB	: out std_logic_vector(1 downto 0);
	     ForwardC 	: out std_logic_vector(1 downto 0);
	     ForwardD	: out std_logic_vector(1 downto 0));
end ForwardingUnit;
-- implement lw in mem stage, ALU out ex stage to comparator in ID stage
architecture behavior of ForwardingUnit is
begin	-- mux with alu operation followed by lw
	process(IFIDALUOP,IFIDALUOP,IFIDRS, IFIDRT, IDEXRT,IDEXRS,EXMEMRD,EXMEMRegWrite, MEMWBRD,MEMWBRegWrite,ForwardA,ForwardB,ForwardC, ForwardD)
	begin
	ForwardA <= "00";
	ForwardB <= "00";
	ForwardC <= "00";
	ForwardD <= "00";
	if (IFIDALUOP = "1100" or IFIDALUOP = "1101") and EXMEMRD = IFIDRS and EXMEMRegWrite = '1' then
		ForwardC <= "10";
	end if;
	if (IFIDALUOP = "1100" or IFIDALUOP = "1101") and EXMEMRD = IFIDRT and EXMEMRegWrite = '1' then	
		ForwardD <= "10";
	end if; 
	if (IFIDALUOP = "1100" or IFIDALUOP = "1101") and MEMWBRD = IFIDRS and MEMWBRegWrite = '1' then
		ForwardC <= "01";
	end if;
	if (IFIDALUOP = "1100" or IFIDALUOP = "1101") and MEMWBRD = IFIDRT and MEMWBRegWrite = '1' then	
		ForwardD <= "01";
	end if;
	if EXMEMRegWrite = '1' and EXMEMRD /= "00000" and EXMEMRD = IDEXRS then
		ForwardA <= "10";
	end if;
	if EXMEMRegWrite = '1' and EXMEMRD /= "00000" and EXMEMRD = IDEXRT then
		ForwardB <= "10";
	end if;
	if MEMWBRegWrite = '1' and MEMWBRD /= "00000" and MEMWBRD = IDEXRS and not(EXMEMRegWrite = '1' and EXMEMRD /= "00000") and EXMEMRD /= IDEXRS then 
		ForwardA <= "01";
	end if;
	if MEMWBRegWrite = '1' and MEMWBRD /= "00000" and MEMWBRD = IDEXRT and not(EXMEMRegWrite = '1' and EXMEMRD /= "00000") and EXMEMRD /= IDEXRT then
		ForwardB <= "01";
	end if;
	
	end process;
end behavior;