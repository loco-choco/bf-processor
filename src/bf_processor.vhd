library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity bf_processor is
	generic(bf_width: integer := 8; pc_width: integer := 32; jd_width: integer := 32);
	port(Clk: in STD_LOGIC;
			Reset : in STD_LOGIC;
			DataRequest: out STD_LOGIC;
			IOData: inout STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			DataOut: out STD_LOGIC;
			--external instruction eeprom
			PC: out STD_LOGIC_VECTOR(pc_width - 1 downto 0);
			Instruction: in STD_LOGIC_VECTOR(7 downto 0));
end;

architecture synth of bf_processor is
component memory_datapath generic(bf_width: integer);
	port(Clk: in STD_LOGIC;
			StackEnable: in STD_LOGIC;
			Reset: in STD_LOGIC;
			Memory: in STD_LOGIC;
			Operation: in STD_LOGIC;
			OverrideData: in STD_LOGIC;
			Override: in STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			Data: out STD_LOGIC_VECTOR(bf_width - 1 downto 0));
	end component;
	component instruction_datapath generic(pc_width: integer);
	port(Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			Direction: in STD_LOGIC;
			-- instr regbank here
			InstrPC: out STD_LOGIC_VECTOR(pc_width - 1 downto 0);
			Instr: in STD_LOGIC_VECTOR(7 downto 0);
			-- made like this so we can easily swap the instr memory element on testbenches
			-- "control signals" or "decoded instr"
			Action: out STD_LOGIC;
			Memory: out STD_LOGIC;
			Operation: out STD_LOGIC);
	end component;
	component jumping_datapath generic(jd_width: integer; bf_width: integer);
	port(Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			JumpEnable: in STD_LOGIC;
			Operation: in STD_LOGIC;
			Data: in STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			Jumping: out STD_LOGIC;
			Direction: out STD_LOGIC);
	end component;
	component io_datapath generic(bf_width: integer);
	port(IOEnable: in STD_LOGIC;
			Operation: in STD_LOGIC;
			CurrentData: in STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			-- outer pins
			Data: inout STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			DataRequest: out STD_LOGIC;
			DataOut: out STD_LOGIC;
			-- inner pins
			OverrideData: out STD_LOGIC;
			Override: out STD_LOGIC_VECTOR(bf_width - 1 downto 0));
	end component;
	-- instruction dp signals
	signal Action, Memory, Operation : STD_LOGIC;
	signal Direction : STD_LOGIC;
	-- memory db signals
	signal StackEnable : STD_LOGIC;
	signal Data : STD_LOGIC_VECTOR(bf_width - 1 downto 0);
	signal OverrideData : STD_LOGIC;
	signal Override : STD_LOGIC_VECTOR(bf_width - 1 downto 0);
	-- jumping dp signals
	signal JumpEnable : STD_LOGIC;
	signal Jumping : STD_LOGIC;
	-- io dp signals
	signal IOEnable : STD_LOGIC;
begin
	mem_dp: memory_datapath generic map(bf_width) port map(Clk, StackEnable, Reset, Memory, Operation, 
								OverrideData, Override, Data);
	instr_dp: instruction_datapath generic map(pc_width) port map(Clk, Reset, Direction, 
									PC, Instruction,
									Action, Memory, Operation);
	jump_dp: jumping_datapath generic map(jd_width, bf_width) port map(Clk, Reset, JumpEnable, Operation, Data,
									Jumping, Direction);
	io_dp: io_datapath generic map(bf_width) port map(IOEnable, Operation, Data, IOData,
									DataRequest, DataOut,
									OverrideData, Override);
									
	StackEnable <= not(Action) and not(Jumping);
	JumpEnable <= Action and not(Memory);
	IOEnable <= Action and Memory and not(Jumping);
end;
