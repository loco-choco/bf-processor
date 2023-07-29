library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity jumping_datapath is
	generic(jd_width: integer := 32; bf_width: integer := 8);
	port(Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			JumpEnable: in STD_LOGIC;
			Operation: in STD_LOGIC;
			Data: in STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			Jumping: out STD_LOGIC;
			Direction: out STD_LOGIC);
end;

architecture synth of jumping_datapath is
	component registry generic(width : integer);
	port(Input: in STD_LOGIC_VECTOR(width - 1 downto 0);
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
	
	signal JumpCondition, IsDataZero, JDEnable : STD_LOGIC;
	signal JumpDepth, NextJumpDepth: STD_LOGIC_VECTOR(jd_width - 1 downto 0);
	signal AtZeroJD, IsJumping: STD_LOGIC;
begin
	-- Jump condition
	is_data_zero: is_zero generic map(bf_width) port map(Data, IsDataZero);
	-- Depth Calculation
	depth_calc: addersubtractor generic map(jd_width) port map(JumpDepth, (0=>'1', others => '0'), Operation, NextJumpDepth);
	jd_reg: registry generic map(jd_width) port map(NextJumpDepth, Clk, Reset, JDEnable, JumpDepth);
	JumpCondition <= IsDataZero xor Operation;
	JDEnable <= JumpEnable and (IsJumping or JumpCondition);
	-- Is Jumping
	is_jumping: is_zero generic map(jd_width) port map(JumpDepth, AtZeroJD);
	IsJumping <= not(AtZeroJD);
	Jumping <= IsJumping;
	Direction <= Operation when JDEnable = '1' else
		     JumpDepth(jd_width - 1);
end;
