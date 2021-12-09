library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ForwardingUnit is
  generic(gCLK_HPER   : time := 50 ns; N : integer := 32);
end tb_ForwardingUnit;

architecture behavior of tb_ForwardingUnit is

constant cCLK_PER  : time := gCLK_HPER * 2;


  component ForwardingUnit
	port(IDEXRT	: in std_logic_vector(4 downto 0);
	     IDEXRS	: in std_logic_vector(4 downto 0);
	     EXMEMRD	: in std_logic_vector(4 downto 0);
	     EXMEMRegWrite : in std_logic;
	     MEMWBRD	: in std_logic_vector(4 downto 0);
	     MEMWBRegWrite : in std_logic;
	     ForwardA	: out std_logic_vector(1 downto 0);
	     ForwardB	: out std_logic_vector(1 downto 0);
	     ForwardC 	: out std_logic;
	     ForwardD	: out std_logic;
	     );
  end component;
	signal s_IDEXRT, s_IDEXRS, s_EXMEMRD, s_MEMWBRD : std_logic_vector(4 downto 0);
	signal s_ForwardA, s_ForwardB : std_logic_vector(1 downto 0);
	signal s_EXMEMRegWrite, s_MEMWBRegWrite, s_ForwardC, s_ForwardD : std_logic;
	
begin
	DUT : controlUnit
	port map(IDEXRT => s_IDEXRT,
		 IDEXRS => s_IDEXRS,
		 EXMEMRD => s_EXMEMRD,
		 MEMWBRD => s_MEMWBRD,
		 ForwardA => s_ForwardA,
		 ForwardB => s_ForwardB,
		 EXMEMRegWrite => s_EXMEMRegWrite,
		 MEMWBRegWrite => s_MEMWBRegWrite,
		 ForwardC => s_ForwardC,
		 ForwardD => s_ForwardD
	);
P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
P_TB : process
	begin

	wait;
	end process;
end behavior;
	