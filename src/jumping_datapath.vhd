library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity jumping_datapath is
	generic(pc_width: integer := 32; bf_width: integer := 8);
	port(Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			Operation: in STD_LOGIC;
			JumpEnable: in STD_LOGIC;
			Data: in STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			-- foward jumping output
			SearchingJump: out STD_LOGIC;
			-- backward jumping output
			Override: out STD_LOGIC;
			PCOverride: out STD_LOGIC_VECTOR(pc_width - 1 downto 0));
end;

architecture synth of jumping_datapath is
	component foward_jumping_datapath generic(pc_width: integer);
	port(Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			Operation: in STD_LOGIC; -- '0' start jump, '1' stop jump
			JumpEnable: in STD_LOGIC; -- if the instr is of type '[' or ']'
			JumpCondition: in STD_LOGIC; -- in bf, the condition is data = 0
			SearchingJump: out STD_LOGIC); -- when it is searching where to jump to, which means we should increase the PC but not do anything unless it is a '[' or ']'
	end component;
	component is_zero generic(width : integer);
	port(Input: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Output: out STD_LOGIC);
	end component;
	
	signal JumpCondition : STD_LOGIC;
begin
	-- Jump condition
	is_data_zero: is_zero generic map(bf_width) port map(Data, JumpCondition);
	-- foward jumping datapath
	fj_dp: foward_jumping_datapath generic map(pc_width) port map(Clk, Reset, Operation, JumpEnable, JumpCondition, SearchingJump);	
	-- backward jumping datapath
	Override <= '0';
	PCOverride <= (others => '0');
end;