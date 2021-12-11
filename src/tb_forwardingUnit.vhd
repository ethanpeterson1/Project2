library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ForwardingUnit is
  generic(gCLK_HPER   : time := 50 ns; N : integer := 32);
end tb_ForwardingUnit;

architecture behavior of tb_ForwardingUnit is

constant cCLK_PER  : time := gCLK_HPER * 2;


  component ForwardingUnit is
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
	     ForwardD	: out std_logic_vector(1 downto 0)
	     );
  end component;
	signal s_IDEXRT, s_IDEXRS, s_EXMEMRD, s_MEMWBRD,s_IFIDRT,s_IFIDRS : std_logic_vector(4 downto 0);
	signal s_ForwardA, s_ForwardB, s_ForwardC, s_ForwardD  : std_logic_vector(1 downto 0);
	signal s_EXMEMRegWrite, s_MEMWBRegWrite : std_logic;
	signal s_IFIDALUOP : std_logic_vector(3 downto 0);
	
begin
	DUT0: ForwardingUnit
	port map(IDEXRT => s_IDEXRT,
		 IDEXRS => s_IDEXRS,
		 EXMEMRD => s_EXMEMRD,
		 EXMEMRegWrite => s_EXMEMRegWrite,
		 MEMWBRD => s_MEMWBRD,
		 MEMWBRegWrite => s_MEMWBRegWrite,
		 IFIDALUOP => s_IFIDALUOP,
		 IFIDRS => s_IFIDRS,
		 IFIDRT => s_IFIDRT,
		 ForwardA => s_ForwardA,
		 ForwardB => s_ForwardB,
		 ForwardC => s_ForwardC,
		 ForwardD => s_ForwardD
	);

P_TB : process
	begin
	wait for gCLK_HPER;
	s_EXMEMRegWrite <= '1'; --forwardA <= "10"
	s_EXMEMRD <= "01111";
	s_IDEXRT <= "01111";
	wait for gCLK_HPER;
	s_IDEXRS <= "01111"; --forwardB <= "10"
	wait for gCLK_HPER;
	s_MEMWBRegWrite <= '1'; --forwardA <= "01"
	s_MEMWBRD <= "10101";
	s_IDEXRS <= "10101";
	s_EXMEMRegWrite <= '0';
	s_EXMEMRD <= "00001";
	wait for gCLK_HPER;
	s_IDEXRT <= "10101"; --forwardB <= "01"
	wait for gCLK_HPER;
	s_IFIDALUOP <= "1100"; --forwardC <= "10";
	s_IFIDRS <= "00001";
	s_EXMEMRegWrite <= '1';
	wait for gCLK_HPER;
	s_IFIDRT <= "00001";
	wait for gCLK_HPER;
	s_EXMEMRegWrite <= '0';--forwardC <= "01"
	s_MEMWBRegWrite <= '1';
	s_IFIDRT <= "00001";
	s_EXMEMRD <= "11111";
	s_MEMWBRD <= "00001";
	wait for gCLK_HPER;
	s_IFIDRT <= "00001";
	wait;
	end process;
end behavior;
	