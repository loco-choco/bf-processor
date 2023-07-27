library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity foward_jumping_datapath is
	generic(pc_width: integer := 32);
	port(Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			Operation: in STD_LOGIC; -- '0' start jump, '1' stop jump
			JumpEnable: in STD_LOGIC; -- if the instr is of type '[' or ']'
			JumpCondition: in STD_LOGIC; -- in bf, the condition is data = 0
			SearchingJump: out STD_LOGIC); -- when it is searching where to jump to, which means we should increase the PC but not do anything unless it is a '[' or ']'
end;

architecture synth of foward_jumping_datapath is
	component registry generic(width : integer);
	port(Input: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			WriteEnable: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	component regbank generic(width : natural; addr_width : natural);
	port(Addr: in STD_LOGIC_VECTOR(addr_width - 1 downto 0);
			WriteIn: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			WriteEnable: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	component addersubtractor generic(width : integer);
	port(a, b: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Selection: in STD_LOGIC; -- 0-> addition, 1 -> subtraction
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	component is_zero generic(width : integer);
	port(Input: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Output: out STD_LOGIC);
	end component;
	
	signal JumpDepth, NextJD : STD_LOGIC_VECTOR(pc_width - 1 downto 0);
	signal ToggleSJ, AtZeroDepth : STD_LOGIC;
	signal MeasureDepth : STD_LOGIC;
	signal NextSJ, CurrentSJ : STD_LOGIC_VECTOR(0 downto 0);
begin
	-- Logic to start and stop jump search
	ToggleSJ <=  JumpCondition and AtZeroDepth;
	NextSJ(0) <= ToggleSJ and not(Operation);
	SearchingJump <= CurrentSJ(0);
	sj: registry generic map(1) port map(NextSJ, Clk, Reset, JumpEnable, CurrentSJ);
	-- Logic to find current jump depth
	MeasureDepth <= JumpEnable and CurrentSJ(0);
	is_zero_depth: is_zero generic map(pc_width) port map(JumpDepth, AtZeroDepth);
	jd: registry generic map(pc_width) port map(NextJD, Clk, Reset, MeasureDepth, JumpDepth);	
	depthmeasr: addersubtractor generic map(pc_width) port map(JumpDepth, (0 => '1', others => '0'), Operation, NextJD);
end;