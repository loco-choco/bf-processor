library IEEE; use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_TEXTIO.ALL; use STD.TEXTIO.all;
entity testbench_memory_datapath is
	generic(clk_period: time := 5 ns; clk_duty: real := 0.5;
				reset_period: time := 27 ns);
end;
architecture sim of testbench_memory_datapath is
	component memory_datapath generic(bf_width: integer);
		port(Clk: in STD_LOGIC;
				StackEnable: in STD_LOGIC;
				Reset: in STD_LOGIC;
				Memory: in STD_LOGIC;
				Operation: in STD_LOGIC;
				Data: out STD_LOGIC_VECTOR(bf_width - 1 downto 0));
	end component;
	signal stack_enable, memory, operation: STD_LOGIC;
	signal current_data, current_data_expected: STD_LOGIC_VECTOR(7 downto 0);
	signal clk, reset: STD_LOGIC;
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
begin
	dut: memory_datapath generic map(8) port map(clk, stack_enable, reset, memory, operation, current_data);
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
	stack_enable <= '1'; --always have the component enabled to updating
	--run tests
	process is
		file tv: text;
		variable L: line;
		variable vector_in: STD_LOGIC_VECTOR(1 downto 0);
		variable dummy: character;
		variable vector_out: STD_LOGIC_VECTOR(7 downto 0);
		variable vectornum: integer := 0;
		variable errors: integer := 0;
		begin
			wait for reset_period;
			FILE_OPEN(tv, "../testbenches/memory-dp-test.txt", READ_MODE);
			while not endfile(tv) loop
				--change vectors on rising edge
				wait until rising_edge(clk);
				--read the next line of testvectors and split into pieces
				readline(tv, L);
				read(L, vector_in);
				read(L, dummy); --skip over underscore
				read(L, vector_out);
				(memory, operation) <= vector_in(1 downto 0);
				--wait until rising_edge(clk);
				current_data_expected <= vector_out;
				--check results on falling edge
				wait until falling_edge(clk);
				if current_data /= current_data_expected then
					report "Error: data = " & integer'image(to_integer(current_data)) & " but current state should be at " & integer'image(to_integer(current_data_expected));
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