-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_Processor is
  generic(N : integer := 32);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mux2t1_5 -- instruction 20-16 and instruction 15-11
  generic(N : integer := 5); 
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component RegisterFile is
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
  end component;

  component controlUnit is
	port(opcode : in std_logic_vector(5 downto 0);
	functionF : in std_logic_vector(5 downto 0);
	reg_dst : out std_logic;
	jump : out std_logic;
	branch : out std_logic;
	memToReg : out std_logic;
	memWrite : out std_logic;
	ALUsrc : out std_logic; 
	regWrite : out std_logic;
	signExtend : out std_logic;
	jr : out std_logic;
	jal : out std_logic;
	ALUOP	: out std_logic_vector(3 downto 0);
	i_CLK : in std_logic;
	ImmType : out std_logic;
	luiInst : out std_logic
	);
  end component;

  component SignExtender is
	port(i_S : in std_logic;
	     i_Extend : in std_logic_vector(15 downto 0);
	     o_Extended : out std_logic_vector(31 downto 0)
	);
  end component;

  component ALUcontrol is 
	port(ALUOP : in std_logic_vector(3 downto 0);
	functionF : in std_logic_vector(10 downto 0);
	shAmt : out std_logic_vector(4 downto 0);
	branchSelect : out std_logic;
	ALUcontrolOut : out std_logic_vector(3 downto 0);
	i_CLK : in std_logic;
	ImmType : in std_logic
	);
  end component;

  component adder_n is --adder +4 for PC and shift left2 one
       generic(N : integer := 32);
       port(i_Aa          : in std_logic_vector(N-1 downto 0);
       i_Ba          : in std_logic_vector(N-1 downto 0);
       i_Ca          : in std_logic;
       o_carry	    : out std_logic;
       o_result      : out std_logic_vector(N-1 downto 0);
       o_overflow     : out std_logic
	);
  end component;

  component mux2t1_N is -- ALUsrc, memtoreg,
	generic(N : integer := 32); 
        port(i_S	  : in std_logic;
	     i_D0         : in std_logic_vector(N-1 downto 0);
             i_D1         : in std_logic_vector(N-1 downto 0);
             o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component ALU is
	port(i_A  :in std_logic_vector (31 downto 0);
	     i_B  :in std_logic_vector (31 downto 0);
	     i_shamt :in std_logic_vector(4 downto 0);
	     i_ALUcode :in std_logic_vector(3 downto 0);
	     i_repl	:in std_logic_vector(7 downto 0);
	     o_result :out std_logic_vector (31 downto 0);
	     o_carry, o_oF :out std_logic);
  end component;

  component comparator32 is
	port(iCompVal1		: in std_logic_vector(31 downto 0);
	iCompVal2		: in std_logic_vector(31 downto 0);
	oNotEqual		: out std_logic);
  end component;

  component shiftleft2 is
	port(in32        : in std_logic_vector(31 downto 0);  
             out32shifted         : out std_logic_vector(31 downto 0)
	); 
  end component;

  component andg2 is --branch and zero output from ALU
       port(i_A          : in std_logic;
       	i_B          : in std_logic;
       	o_F          : out std_logic
       );
  end component;

  component dffg_NBit is
	generic(N: integer := 32);
  	port(i_CLK        : in std_logic;     -- Clock input
             i_RST        : in std_logic;     -- Reset input
             i_WE         : in std_logic;     -- Write enable input
             i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
             o_Q          : out std_logic_vector(N-1 downto 0)); 
  end component;

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  component shiftleft226bit is 
	  port(in26        : in std_logic_vector(25 downto 0);  
               out28shifted         : out std_logic_vector(27 downto 0)
	);  
	end component;

  component PCReg is 
	port(i_CLK        : in std_logic;     -- Clock input
       	     i_RST        : in std_logic;     -- Reset input
             i_WE         : in std_logic;     -- Write enable input
             i_D          : in std_logic_vector(31 downto 0);     -- Data value input
             o_Q          : out std_logic_vector(31 downto 0)
	);
  end component;

component ripplecarryadd_n is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(
      i_Ain          : in std_logic_vector(N-1 downto 0);
      i_Bin          : in std_logic_vector(N-1 downto 0);
      i_Cin          : in std_logic;
      o_Cout         : out std_logic;
      o_R            : out std_logic_vector(N-1 downto 0));
end component;

   component Reg_IDEX is
	generic(N : integer := 211);
	port(	i_CLKn        	: in std_logic;     -- Clock input
       	i_RSTn        	: in std_logic;     -- Reset input
       	i_WEn         	: in std_logic;     -- Write enable input

	i_RS_RegOut	: in std_logic_vector(31 downto 0);
	i_RT_RegOut	: in std_logic_vector(31 downto 0);
	i_SignExtendOut	: in std_logic_vector(31 downto 0);
	i_UpdatedPC	: in std_logic_vector(31 downto 0);
	i_Instruction	: in std_logic_vector(31 downto 0);
	i_rsAdd		: in std_logic_vector(4 downto 0);
	i_rtAdd		: in std_logic_vector(4 downto 0);
	i_ALUControlOut	: in std_logic_vector(3 downto 0);
       	i_ALUSrc	: in std_logic;
	i_RegDst	: in std_logic;
	i_MemWrite	: in std_logic;
	i_MemToReg	: in std_logic;
	i_RegWrite	: in std_logic;
	i_JalControl	: in std_logic;
	i_shamt		: in std_logic_vector(4 downto 0);
	i_LuiInst       : in std_logic;
	o_RS_RegOut    	: out std_logic_vector(31 downto 0);
    	o_RT_RegOut    	: out std_logic_vector(31 downto 0);
    	o_SignExtendOut : out std_logic_vector(31 downto 0);
   	o_UpdatedPC    	: out std_logic_vector(31 downto 0);
   	o_Instruction   : out std_logic_vector(31 downto 0);
  	o_rsAdd        	: out std_logic_vector(4 downto 0);
   	o_rtAdd        	: out std_logic_vector(4 downto 0);
   	o_ALUControlOut : out std_logic_vector(3 downto 0);
   	o_ALUSrc    	: out std_logic;
    	o_RegDst    	: out std_logic;
   	o_MemWrite    	: out std_logic;
    	o_MemToReg    	: out std_logic;
    	o_RegWrite    	: out std_logic;
    	o_JalControl    : out std_logic;
	o_shamt		: out std_logic_vector(4 downto 0);
	o_LuiInst	: out std_logic);
end component;
    component Reg_IFID is
	generic(N : integer := 64);
	port(i_CLKn        	: in std_logic;     -- Clock input
       	i_RSTn        	: in std_logic;     -- Reset input
       	i_WEn         	: in std_logic;     -- Write enable input
       	i_Instruction 	: in std_logic_vector(31 downto 0);    
	i_PC		: in std_logic_vector(31 downto 0);
	--i_Flush		: in std_logic;
	o_Instruction 	: out std_logic_vector(31 downto 0);    
	o_PC		: out std_logic_vector(31 downto 0)
	--o_Flush		: out std_logic WILL BE IMPLEMENTED FOR HARDWARE SCHEDULE PIPELINE
	);
end component;
    component Reg_MEMWB is
	generic(N : integer := 137);
	port(	i_CLKn        	: in std_logic;     -- Clock input
       	i_RSTn        	: in std_logic;     -- Reset input
       	i_WEn         	: in std_logic;     -- Write enable input


	i_ALUOut	: in std_logic_vector(31 downto 0);
	i_DMEM		: in std_logic_vector(31 downto 0);
	i_UpdatedPC	: in std_logic_vector(31 downto 0);
	i_Inst		: in std_logic_vector(31 downto 0);
	i_WriteRegAdd	: in std_logic_vector(4 downto 0);
	i_MemToReg	: in std_logic;
	i_RegWrite	: in std_logic;
	i_LuiControl	: in std_logic;
	i_JalControl	: in std_logic;

	o_ALUOut	: out std_logic_vector(31 downto 0);
	o_DMEM		: out std_logic_vector(31 downto 0);
	o_UpdatedPC	: out std_logic_vector(31 downto 0);
	o_Inst		: out std_logic_vector(31 downto 0);
	o_WriteRegAdd	: out std_logic_vector(4 downto 0);
    	o_MemToReg    	: out std_logic;
    	o_RegWrite    	: out std_logic;
	o_LuiControl	: out std_logic;
	o_JalControl	: out std_logic);
end component;

	component Reg_EXMEM is
	generic(N : integer := 138);
  port(	i_CLKn        	: in std_logic;     -- Clock input
       	i_RSTn        	: in std_logic;     -- Reset input
       	i_WEn         	: in std_logic;     -- Write enable input


	i_ALUOut	: in std_logic_vector(31 downto 0);
	i_Inst          : in std_logic_vector(31 downto 0);
	i_RtRegOut	: in std_logic_vector(31 downto 0);
	i_MemToReg	: in std_logic;
	i_RegWr		: in std_logic;
	i_JalControl	: in std_logic;
        i_LuiControl	: in std_logic;
	i_MemWr		: in std_logic;
	i_WriteRegAdd	: in std_logic_vector(4 downto 0);
	i_UpdatedPC	: in std_logic_vector(31 downto 0);

	
	o_ALUOut	: out std_logic_vector(31 downto 0);
	o_Inst          : out std_logic_vector(31 downto 0);
	o_RtRegOut	: out std_logic_vector(31 downto 0);
	o_MemToReg	: out std_logic;
	o_RegWr		: out std_logic;
	o_JalControl	: out std_logic;
        o_LuiControl	: out std_logic;
	o_MemWr		: out std_logic;
	o_WriteRegAdd	: out std_logic_vector(4 downto 0);
	o_UpdatedPC	: out std_logic_vector(31 downto 0));
	

end component;

	component invg is
	  port(i_A          : in std_logic;
       o_F          : out std_logic);
end component;


  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

	signal s_regdst, s_jump,s_branch, s_memToReg, s_ALUsrc, s_signExtendControl, s_jr, s_branchSelect, s_jal : std_logic;
	signal s_InstrMuxOut : std_logic_vector(4 downto 0);
	signal s_ALUOP, s_ALUcontrolOut : std_logic_vector(3 downto 0);
	signal s_shAmt : std_logic_vector(4 downto 0);
	signal s_rsOut, s_rtOut : std_logic_vector(31 downto 0);
	signal s_toNothing : std_logic;
	signal s_ALUmuxOut : std_logic_vector(31 downto 0);
	signal s_replOut : std_logic_vector(7 downto 0);
	signal s_ALUout : std_logic_vector(31 downto 0);	
	signal s_OutAnd : std_logic;
	signal s_signExtended, s_shiftToAdder : std_logic_vector(31 downto 0);
	signal s_shiftAdderOut : std_logic_vector(31 downto 0);
	signal s_memToRegMuxOut : std_logic_vector(31 downto 0);
	signal s_jumpadd : std_logic_vector(27 downto 0);
	signal s_UpdatedPCAdd : std_logic_vector(31 downto 0);
	signal s_IFIDOut : std_logic_vector(31 downto 0);
	signal s_ImmType : std_logic;
	signal s_JALAdd : std_logic_vector(31 downto 0);
	signal s_jrMuxOut : std_logic_vector(4 downto 0);
	signal s_memToRegOut : std_logic_vector(31 downto 0);
	signal s_JRmuxOut32 : std_logic_vector(31 downto 0);
	signal s_InstrMux1Out : std_logic_vector(4 downto 0);
	signal s_luiMuxOut : std_logic_vector(31 downto 0);
	signal s_PCAdderOut : std_logic_vector(31 downto 0);
	signal s_IFIDInst : std_logic_vector(31 downto 0);
	signal s_IFIDPC : std_logic_vector(31 downto 0);
	signal s_BranchPC : std_logic_vector(31 downto 0);
	signal s_shiftedL2Out : std_logic_vector(31 downto 0);
	signal IFIDluiInst : std_logic;
	signal s_memWrite : std_logic;
	signal s_regWrite : std_logic;
	signal IDEX_RS_RegOut,IDEX_RT_RegOut,IDEX_SignExtend,IDEX_UpdatedPC,IDEXInst : std_logic_vector(31 downto 0);
	signal IDEXrsAdd,IDEXrtAdd,IDEXshamt : std_logic_vector(4 downto 0);
	signal IDEXALUControlOut : std_logic_vector(3 downto 0);
	signal IDEXALUSrc,IDEXRegDst,IDEXMemWrite,IDEXMemToReg,IDEXRegWrite,IDEXJalControl,IDEXluiInst : std_logic;
	signal IDEXWriteRegAdd : std_logic_vector(4 downto 0);
	signal EXMEMALUOut,EXMEMInst,EXMEMRtRegOut,EXMEMUpdatedPC : std_logic_vector(31 downto 0);
	signal EXMEMMemToReg,EXMEMRegWr,EXMEMJalControl,EXMEMLuiControl,EXMEMMemWr : std_logic;
	signal EXMEMWriteRegAdd : std_logic_vector(4 downto 0);
	signal WBALUOut,WBDMEM,WBUpdatedPC,WBInst : std_logic_vector(31 downto 0);
	signal WBWriteRegAdd : std_logic_vector(4 downto 0);
	signal WBMemToReg,WBRegWrite,WBLuiControl,WBJalControl : std_logic;
	signal s_BranchControl : std_logic;
	signal s_comparator :std_logic;
	signal s_BranchPCMuxout: std_logic_vector(31 downto 0);
	signal s_test : std_logic;
begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  s_DMemAddr <= EXMEMALUOut;
  s_DMemData <= EXMEMRtRegOut;
  s_RegWr <= WBRegWrite;
  s_RegWrAddr <= WBWriteRegAdd;
  oALUOut <= WBALUout;
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

--IF
---------------------------------------------------------------------------
	s_Halt <= '1' when WBInst(31 downto 26) = "010100" 
	else '0';

  g_PC: PCReg
    port MAP( --PC 0x00400000, special register 
	i_CLK		=> iCLK,
	i_RST      	=> iRST,
	i_WE		=> '1',
	i_D		=> s_JRmuxOut32,
        o_Q            	=> s_NextInstAddr);

  g_PCADDER: ripplecarryadd_N		--fulladder_n
    port MAP(
	i_Ain		=> s_NextInstAddr,
	i_Bin      	=> x"00000004",	--s_AdderBinSrc
	i_Cin		=> '0',
	o_Cout		=> s_toNothing,
        o_R            	=> s_PCAdderOut);
   g_RegIFID: Reg_IFID
	port MAP(i_CLKn => iCLK,
		 i_RSTn => iRST,
		 i_WEn  => '1',
		 i_Instruction => s_Inst,
		 i_PC => s_PCAdderOut,
		 --i_Flush => ,
		 o_Instruction => s_IFIDInst,
		 o_PC => s_IFIDPC
		 --o_Flush => ,
	);



--ID
---------------------------------------------------------------------------

  control : controlUnit
	port map(opcode => s_IFIDInst(31 downto 26),
		 functionF => s_IFIDInst(5 downto 0),
		 reg_dst => s_regdst,
		 jump => s_jump,
		 branch => s_branch,
		 memToReg => s_memToReg,
		 memWrite => s_memWrite,
		 ALUsrc => s_ALUsrc,
		 regWrite => s_regWrite,
		 signExtend => s_signExtendControl,
		 jr => s_jr,
		 jal => s_jal,
		 ALUOP => s_ALUOP,
		 i_CLK => iCLK,
		 luiInst => IFIDluiInst,
		 ImmType => s_ImmType);

  ALUcont : ALUcontrol
	port map(ALUOP 		=> s_ALUOP,
		 functionF 	=> s_IFIDInst(10 downto 0),
		 shAmt 		=> s_shAmt,
		 branchSelect 	=> s_branchSelect,
		 ALUcontrolOut 	=> s_ALUcontrolOut,
		 i_CLK 		=> iCLK,
		 ImmType	=> s_ImmType
	);

  signExtend : SignExtender 
	port map(i_S => s_signExtendControl,
		 i_Extend => s_IFIDInst(15 downto 0),
		 o_Extended => s_signExtended);

  g_SHIFTL2: shiftleft2
    port MAP(
	in32		=> s_signExtended,
	out32shifted	=> s_shiftedL2Out);

  g_BRANCHADDRADDER: ripplecarryadd_N		--fulladder_n
    port MAP(
	i_Ain		=> s_IFIDPC,
	i_Bin      	=> s_shiftedL2Out,	
	i_Cin		=> '0',
	o_Cout		=> s_toNothing,
        o_R            	=> s_BranchPC);

  g_MUX2T1PCSrc: mux2t1_N
    port MAP(
	i_S		=> s_BranchControl,
	i_D0      	=> s_PCAdderOut,
	i_D1		=> s_BranchPC,
        o_O            	=> s_BranchPCMuxout);

   shiftL26bit : shiftleft226bit
	port map(in26 => s_IFIDInst(25 downto 0),
		 out28shifted => s_jumpAdd);

  muxJump : mux2t1_N
	port map(i_S    => s_jump,
		 i_D0   => s_BranchPCMuxout,
		 i_D1   => s_IFIDPC(31 downto 28) & s_jumpAdd,
		 o_O    => s_UpdatedPCAdd
	);

  JrMuxInputReg : mux2t1_5
	port map(i_S => s_jr,
		 i_D0 => s_IFIDInst(25 downto 21),
		 i_D1 => "11111",
		 o_O => s_jrMuxOut
	);

  RegFile : RegisterFile 
	generic map(N => N)
	port map(w_add => s_RegWrAddr,
		 w_En => s_RegWr,
		 w_Data => s_RegWrData,
		 r_add1 => s_jrMuxOut,
		 r_add2 => s_IFIDInst(20 downto 16),
		 i_CLK => iCLK,
		 rst => iRST,
		 rs_out => s_rsOut,
		 rt_out => s_rtOut);


  Comparator : comparator32
	port map(iCompVal1 => s_rsOut,
		 iCompVal2 => s_rtOut,
		 oNotEqual => s_comparator);

  g_RegIDEX : Reg_IDEX
	generic map(N => 186)
	port map(i_CLKn => iCLK,
		 i_RSTn => iRST,
		 i_WEn => '1',
		 i_RS_RegOut => s_rsOut,
		 i_RT_RegOut => s_rtOut,
		 i_SignExtendOut => s_signExtended, 
		 i_UpdatedPC => s_IFIDPC,
		 i_Instruction => s_IFIDInst,
		 i_rsAdd => s_jrMuxOut,
		 i_rtAdd => s_IFIDInst(20 downto 16),
		 i_ALUControlOut => s_ALUcontrolOut,
		 i_ALUSrc => s_ALUsrc,
		 i_RegDst => s_regdst,
		 i_MemWrite => s_memWrite,
		 i_MemToReg => s_memToReg,
		 i_RegWrite => s_regWrite,
		 i_JalControl => s_jal,
		 i_shamt => s_shAmt,	
		 i_LuiInst => IFIDluiInst,
		 o_RS_RegOut => IDEX_RS_RegOut,
		 o_RT_RegOut => IDEX_RT_RegOut,
		 o_SignExtendOut => IDEX_SignExtend,
		 o_UpdatedPC => IDEX_UpdatedPC,
		 o_Instruction => IDEXInst,
		 o_rsAdd => IDEXrsAdd,
		 o_rtAdd => IDEXrtAdd,
		 o_ALUControlOut => IDEXALUControlOut,
		 o_ALUSrc => IDEXALUSrc,
		 o_RegDst => IDEXRegDst,
		 o_MemWrite => IDEXMemWrite,
		 o_MemToReg => IDEXMemToReg,
		 o_RegWrite => IDEXRegWrite,
		 o_JalControl => IDEXJalControl,
		 o_shamt => IDEXshamt,
		 o_LuiInst => IDEXluiInst
	);

    JrMux : mux2t1_N
	generic map(N => N)
	port map(i_S => s_jr,
		 i_D0 => s_UpdatedPCAdd,
		 i_D1 => s_rsOut,
		 o_O => s_JRmuxOut32
	);
   g_invg : invg
	port map(i_A => s_comparator,
		 o_F => s_test
	);
   g_andg2 : andg2
	port map(i_A => s_branch,
		 i_B => s_test,
		 o_F => s_BranchControl
	);

--EX
---------------------------------------------------------------------------

  ALUmux : mux2t1_N
	generic map(N => N)
	port map(i_S 	=> IDEXALUSrc,
		 i_D0 	=> IDEX_RT_RegOut,
		 i_D1 	=> IDEX_SignExtend,
		 o_O 	=> s_ALUmuxOut
	);

  MainALU : ALU
	port map(i_A => IDEX_RS_RegOut,
	     i_B => s_ALUmuxOut,
	     i_shAmt => IDEXshamt,
	     i_ALUcode => IDEXALUControlOut,
	     i_repl => s_replOut, --?
	     o_result => s_ALUout,
	     o_carry => s_toNothing,
	     o_oF => s_Ovfl
	);
   InstrMux : mux2t1_5
	generic map (N => 5)
	port map(i_S => IDEXRegDst,
		 i_D0 => IDEXInst(20 downto 16),
		 i_D1 => IDEXInst(15 downto 11),
		 o_O => s_InstrMux1Out);
   InstrMux2 : mux2t1_5
	generic map (N => 5)
	port map(i_S => IDEXJalControl,
		 i_D0 => s_InstrMux1Out,
		 i_D1 => "11111",
		 o_O => IDEXWriteRegAdd);

   g_Reg_EXMEM : Reg_EXMEM
	generic map(N => 106)
	port map(i_CLKn => iCLK,
		 i_RSTn => iRST,
		 i_WEn => '1',
		 i_ALUOut => s_ALUout,
		 i_Inst => IDEXInst,
		 i_RtRegOut => IDEX_RT_RegOut,
		 i_MemToReg => IDEXMemToReg,
		 i_RegWr => IDEXRegWrite,
		 i_JalControl => IDEXJalControl,
		 i_LuiControl => IDEXluiInst,
		 i_MemWr => IDEXMemWrite,
		 i_WriteRegAdd => IDEXWriteRegAdd,
		 i_UpdatedPC => IDEX_UpdatedPC,
		 o_ALUOut => EXMEMALUOut,
		 o_Inst => EXMEMInst,
		 o_RtRegOut => EXMEMRtRegOut,
		 o_MemToReg => EXMEMMemToReg,
		 o_RegWr => EXMEMRegWr,
		 o_JalControl => EXMEMJalControl,
		 o_LuiControl => EXMEMLuiControl,
		 o_MemWr => s_DMemWr,
		 o_WriteRegAdd => EXMEMWriteRegAdd,
		 o_UpdatedPC => EXMEMUpdatedPC
	);

--MEM
---------------------------------------------------------------------------

  g_RegMEMWB : Reg_MEMWB
	generic map(N => 137)
	port map(i_CLKn => iCLK,
		 i_RSTn => iRST,
		 i_WEn => '1',
		 i_ALUOut => EXMEMALUOut,
		 i_DMEM => s_DMemOut,
		 i_UpdatedPC => EXMEMUpdatedPC,
		 i_Inst => EXMEMInst,
		 i_WriteRegAdd => EXMEMWriteRegAdd,
		 i_MemToReg => EXMEMMemToReg,
		 i_RegWrite => EXMEMRegWr,
		 i_LuiControl => EXMEMLuiControl,
		 i_JalControl => EXMEMJalControl,
		 o_ALUOut => WBALUOut,
		 o_DMEM => WBDMEM,
		 o_UpdatedPC => WBUpdatedPC,
		 o_Inst => WBInst,
		 o_WriteRegAdd => WBWriteRegAdd,
		 o_MemToReg => WBMemToReg,
		 o_RegWrite => WBRegWrite,
		 o_LuiControl => WBLuiControl,
		 o_JalControl => WBJalControl
	);
		 

--WB
---------------------------------------------------------------------------
  memToRegMux : mux2t1_N
	generic map(N => N)
	port map(i_S => WBMemToReg,
		 i_D0 => WBALUOut,
		 i_D1 => WBDMEM,
		 o_O => s_memToRegOut
	);

  luiMux : mux2t1_N
	generic map(N=>N)
	port map(i_S => WBLuiControl,
		 i_D0 => s_memToRegOut,
		 i_D1 => WBInst(15 downto 0) & x"0000",
		 o_O => s_luiMuxOut
	);

  JalWrite : mux2t1_N
	generic map(N => N)
	port map(i_S => WBJalControl,
		 i_D0 => s_luiMuxOut,
		 i_D1 => WBUpdatedPC,
		 o_O => s_RegWrData
	);

end structure;

