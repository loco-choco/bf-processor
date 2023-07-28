library IEEE; use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_TEXTIO.ALL; use STD.TEXTIO.all;
entity testbench_bf_processor is
	generic(clk_period: time := 5 ns; clk_duty: real := 0.5; 
		reset_period: time := 20 ns;
		bf_width: integer := 8; pc_width : integer := 16;
		instr_file: string := "../testbenches/tests/test01.bf";
		expected_result_file: string := "../testbenches/tests/test01-expected.txt");
end;
architecture sim of testbench_bf_processor is
	-- components to be tested
	component memory_datapath generic(bf_width: integer);
		port(Clk: in STD_LOGIC;
			StackEnable: in STD_LOGIC;
			Reset: in STD_LOGIC;
			Memory: in STD_LOGIC;
			Operation: in STD_LOGIC;
			Data: out STD_LOGIC_VECTOR(bf_width - 1 downto 0));
	end component;
	component instruction_datapath generic(pc_width: integer);
	port(Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			Direction: in STD_LOGIC;
			PCEnable: in STD_LOGIC;
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
	----------------
	component instrs_from_file 
		generic(pc_width : integer; file_path : string);
		port(PC: in STD_LOGIC_VECTOR(pc_width - 1 downto 0);
			Instr: out STD_LOGIC_VECTOR(7 downto 0));
	end component;

	function to_integer(constant vec: STD_LOGIC_VECTOR) return integer is
		alias xvec: STD_LOGIC_VECTOR(vec'LENGTH - 1 downto 0) is vec;
		variable result: integer := 0;
	begin
   	for i in xvec'RANGE loop
		result := result + result;
      	if xvec(i) = '1' then
		result := result + 1;
    	end if;
  	end loop;
   		return result;
	end to_integer;	
	
	--related to memory datapath
	signal stack_enable: STD_LOGIC;
	signal data: STD_LOGIC_VECTOR(bf_width - 1 downto 0);
	--related to instruction datapath	
	signal direction, pc_enable: STD_LOGIC;	
	signal instr_pc: STD_LOGIC_VECTOR(pc_width - 1 downto 0);
	signal instr: STD_LOGIC_VECTOR(7 downto 0);
	signal action, memory, operation: STD_LOGIC;	
	--related to jumping datapath
	signal jump_enable: STD_LOGIC;
	signal jumping: STD_LOGIC;
	--
	signal clk, reset: STD_LOGIC;
begin
	mem_dp: memory_datapath generic map(bf_width) port map(clk, stack_enable, reset, memory, operation, data);
	instr_dp: instruction_datapath generic map(pc_width) port map(clk, reset, direction, pc_enable, 
									instr_pc, instr,
									action, memory, operation);
	jump_dp: jumping_datapath generic map(pc_width, bf_width) port map(clk, reset, jump_enable, operation, data,
									 jumping, direction);
	instr_ff: instrs_from_file generic map(pc_width, instr_file) port map(instr_pc, instr);	
	--internal wiring
	pc_enable <= '1'; --untill we add IO, this will always be on
	stack_enable <= not(action) and not(jumping);
	jump_enable <= action and not (memory); --means that the instr is of type "[" or "]" (10X)
	--clock
	process begin
		wait for reset_period;
		while true loop
			clk <= '1'; wait for clk_period * clk_duty;
			clk <= '0'; wait for clk_period * (1.0 - clk_duty);
		end loop;
	end process;
	--reset the component
	process begin
		reset <= '0'; wait for reset_period; reset <= '1'; --resets on '0'
		wait;
	end process;
	--run tests
	process is
		file tv: text;
		variable L: line;
		variable pc_of_expected_data: integer;
		variable dummy: character;
		variable expected_data: STD_LOGIC_VECTOR(bf_width - 1 downto 0);
		variable vectornum: integer := 0;
		variable errors: integer := 0;
		begin
			wait for reset_period;
			FILE_OPEN(tv, expected_result_file, READ_MODE);
			wait until to_integer(instr_pc) = 1000;
			while not endfile(tv) loop
				--change vectors on rising edge
				wait until rising_edge(clk);
				--read the next line of testvectors and split into pieces
				readline(tv, L);
				read(L, pc_of_expected_data);
				read(L, dummy); --skip over underscore
				read(L, expected_data);
				--check results when on right pc
				wait until to_integer(instr_pc) = pc_of_expected_data;
				if data /= expected_data then
					report "Error: data = " & integer'image(to_integer(data)) & " but at current pc [" & integer'image(pc_of_expected_data) &
					 "] should be at " & integer'image(to_integer(expected_data));
					errors := errors + 1;
				end if;
				vectornum := vectornum + 1;
			end loop;
			--results sum
			if (errors = 0) then
				report "NO ERRORS -- " &
				integer'image(vectornum) &
				" tests completed successfully."
				severity failure;
			else
				report integer'image(vectornum) &
				" tests completed, errors = " &
				integer'image(errors)
				severity failure;
			end if;
		end process;
end;