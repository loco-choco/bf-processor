library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity instruction_datapath is
	generic(pc_width: integer := 32);
	port(Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			-- pc override
			Override: in STD_LOGIC;
			PCOverride: in STD_LOGIC_VECTOR(pc_width - 1 downto 0);
			--
			-- instr regbank here
			InstrPC: out STD_LOGIC_VECTOR(pc_width - 1 downto 0);
			Instr: in STD_LOGIC_VECTOR(7 downto 0);
			-- made like this so we can easily swap the instr memory element on testbenches
			-- "control signals" or "decoded instr"
			Action: out STD_LOGIC;
			Memory: out STD_LOGIC;
			Operation: out STD_LOGIC);
end;

architecture synth of instruction_datapath is
	component registry generic(width : integer);
	port(Input: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			WriteEnable: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	--component regbank generic(width : natural; addr_width : natural);
	--port(Addr: in STD_LOGIC_VECTOR(addr_width - 1 downto 0);
	--		WriteIn: in STD_LOGIC_VECTOR(width - 1 downto 0);
	--		Clk: in STD_LOGIC;
	--		Reset: in STD_LOGIC;
	--		WriteEnable: in STD_LOGIC;
	--		Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	--end component;
	component addersubtractor generic(width : integer);
	port(a, b: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Selection: in STD_LOGIC; -- 0-> addition, 1 -> subtraction
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	component mux2	generic(width : integer);
	port(Input0, Input1: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Selection: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	component instrdecoder 
	port(Instr: in STD_LOGIC_VECTOR(7 downto 0);
			Action: out STD_LOGIC;
			Memory: out STD_LOGIC;
			Operation: out STD_LOGIC);
	end component;
	
	signal PC, NextPC, ChosenPC : STD_LOGIC_VECTOR(pc_width - 1 downto 0);
begin
	InstrPC <= PC;
	-- PC Logic
	pcreg: registry generic map(pc_width) port map(ChosenPC, Clk, Reset, '1', PC);
	nextpcresult: addersubtractor generic map(pc_width) port map(PC, (0 => '1', others => '0'), '0', NextPC);
	pcoverridemux: mux2 generic map(pc_width) port map(NextPC, PCOverride, Override, ChosenPC);
	-- Decoding Logic
	instrdecod: instrdecoder port map(Instr, Action, Memory, Operation);
end;