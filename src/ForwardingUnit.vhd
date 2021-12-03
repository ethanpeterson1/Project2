library IEEE;
use IEEE.std_logic_1164.all;
--DO NOT implement until we have software scheduled pipelined fully implemented
entity ForwardingUnit is
	port(ID/EXRT	: in std_logic_vector(4 downto 0);
	     ID/EXRS	: in std_logic_vector(4 downto 0);
	     EX/MEMRD	: in std_logic_vector(4 downto 0);
	     MEM/WBRD	: in std_logic_vector(4 downto 0);
	     ForwardA	: out std_logic_vector(1 downto 0);
	     ForwardB	: out std_logic_vector(1 downto 0);
	);
end ForwardingUnit;