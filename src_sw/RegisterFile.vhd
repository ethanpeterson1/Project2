library IEEE;
use IEEE.std_logic_1164.all;
package busArray is

type array32 is array(31 downto 0) of std_logic_vector(31 downto 0);

end package busArray;
library IEEE;
use IEEE.std_logic_1164.all;
use work.busArray.all;

entity RegisterFile is
	generic(N : integer := 32);
	port(w_add	: in std_logic_vector(4 downto 0);
	     w_En	: in std_logic;
	     w_Data	: in std_logic_vector(N-1 downto 0);
	     r_add1	: in std_logic_vector(4 downto 0);
	     r_add2	: in std_logic_vector(4 downto 0);
	     i_CLK	: in std_logic;
	     rst	: in std_logic;
	     rs_out	: out std_logic_vector(N-1 downto 0);
	     rt_out	: out std_logic_vector(N-1 downto 0)
	     );
end RegisterFile;

architecture structural of RegisterFile is
	component dffg_NBit
	generic(N: integer := 32);
  	port (i_CLK        : in std_logic;     -- Clock input
             i_RST        : in std_logic;     -- Reset input
             i_WE         : in std_logic;     -- Write enable input
             i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
             o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
	end component;
	component mux32bit32to1
	port(i_S	: in std_logic_vector(4 downto 0);
	     i_D	: in array32;
	     o_O	: out std_logic_vector(N-1 downto 0)
	);
	end component;
	component decoder32bit
	port(i_E	: in std_logic_vector(4 downto 0);
             o_D	: out std_logic_vector(N-1 downto 0);
	     w_E	: in std_logic
	);
	end component;
	signal s_Decode : std_logic_vector(N-1 downto 0);
	signal s_RegOut : array32;
	--signal s_DataofReg0 : std_logic_vector(N-1 downto 0);
begin
	--s_DataofReg0 <= (others => x"00000000");
	write_decoder : decoder32bit
		port map(i_E	=> w_add,
			 o_D	=> s_Decode,
			 w_E	=> w_En);
	Register0 : dffg_Nbit 
		port map(i_CLK => i_CLK,
			 i_RST => '1',
			 i_WE  => '0',
			 i_D   => w_Data,
			 o_Q   => s_RegOut(0));
	G_NBit_dffg: for i in 1 to N-1 generate
    		dffgI: dffg_Nbit port map(i_CLK => i_CLK,
					  i_RST => rst,
					  i_WE => s_Decode(i),
					  i_D  => w_Data,
					  o_Q  => s_RegOut(i));
  	end generate G_NBit_dffg;
	Mux1 : mux32bit32to1
		port map(i_S => r_add1,
			 i_D => s_RegOut,
			 o_O => rs_out
	);
	Mux2 : mux32bit32to1
		port map(i_S => r_add2,
			 i_D => s_RegOut,
			 o_O => rt_out
	);
	
	
end structural;