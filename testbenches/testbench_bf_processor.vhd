library IEEE; use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_TEXTIO.ALL; use STD.TEXTIO.all;
entity testbench_bf_processor is
	generic(clk_period: time := 5 ns; clk_duty: real := 0.5; 
		reset_period: time := 20 ns;
		bf_width: integer := 8; pc_width : integer := 16;
		instr_file: string := "../testbenches/tests/test01.bf";
		input_file: string := "../testbenches/tests/test01-input.txt");
end;
architecture sim of testbench_bf_processor is
	-- components to be tested
	component  bf_processor generic(bf_width: integer; pc_width: integer; jd_width: integer);
	port(Clk: in STD_LOGIC;
			Reset : in STD_LOGIC;
			DataRequest: out STD_LOGIC;
			IOData: inout STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			DataOut: out STD_LOGIC;
			--external instruction eeprom
			PC: out STD_LOGIC_VECTOR(pc_width - 1 downto 0);
			Instruction: in STD_LOGIC_VECTOR(7 downto 0));
 	end component;
	----------------
	component instrs_from_file 
		generic(pc_width : integer; file_path : string);
		port(PC: in STD_LOGIC_VECTOR(pc_width - 1 downto 0);
			Instr: out STD_LOGIC_VECTOR(7 downto 0));
	end component;
	component input_data_from_file
		generic(file_path : string; bf_width : integer; input_max_size : integer);
		port(Clk: in STD_LOGIC;
			DataRequest: in STD_LOGIC;
			Data: out STD_LOGIC_VECTOR(bf_width - 1 downto 0));
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
	

	--related to instruction	
	signal pc: STD_LOGIC_VECTOR(pc_width - 1 downto 0);
	signal instruction: STD_LOGIC_VECTOR(7 downto 0);
	--related to io
	signal data_request, data_out: STD_LOGIC;
	signal io_data: STD_LOGIC_VECTOR(7 downto 0);
	--
	signal clk, reset: STD_LOGIC;
begin
	bf_proc: bf_processor generic map(bf_width, pc_width, pc_width) port map(clk, reset, data_request, io_data, data_out, pc, instruction);
	--
	instr_ff: instrs_from_file generic map(pc_width, instr_file) port map(pc, instruction);		
	input_ff: input_data_from_file generic map(input_file, bf_width, 1000) port map(clk, data_request, io_data);
	--out io
	process is
		variable output_index : integer := 0;
		begin
		
		while true loop
			wait until rising_edge(clk);
			if data_out = '1' then
				report "[" & integer'image(output_index) & "] " &
					integer'image(to_integer(io_data));
				output_index := output_index + 1;
			end if;
		end loop;
	end process;
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
end;