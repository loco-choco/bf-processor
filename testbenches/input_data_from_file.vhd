library IEEE;
use IEEE.STD_LOGIC_1164.all;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.NUMERIC_STD.all;

entity input_data_from_file is
	generic(file_path : string; bf_width : integer := 8; input_max_size : integer := 100);
	port(Clk: in STD_LOGIC;
		DataRequest: in STD_LOGIC;
		Data: out STD_LOGIC_VECTOR(bf_width - 1 downto 0));
end;

architecture synth of input_data_from_file is
	subtype word_t is STD_LOGIC_VECTOR(bf_width - 1 downto 0);
	type ramtype is array(input_max_size - 1 downto 0) of word_t;
	-- initialize memory from file
	
	impure function read_from_file return ramtype is
		file text_file : text open read_mode is file_path;
		variable text_line : line;
		variable input_data: character;
		variable temp_data: integer;
		variable ram_content : ramtype;
		variable i : integer := 0;
	begin
		for i in 0 to input_max_size - 1 loop -- set all contents low
			ram_content(i) := (others => '0');
		end loop;
		while not endfile(text_file) loop -- set contents from file
			readline(text_file, text_line);
			for j in text_line'range loop
				input_data := text_line(j);
				temp_data := character'pos(input_data);
				ram_content(i) := std_logic_vector(to_unsigned(temp_data, 8));
				i := i + 1;
			end loop;
		end loop;
		
		return ram_content;
	end function;	
	signal mem : ramtype := read_from_file;
	begin
	-- read memory
	process(Clk, DataRequest) is
		variable index: integer := 0;
		begin
		if rising_edge(Clk) then
			if DataRequest = '1' then
				Index := Index + 1;
			end if;
		end if;
		if DataRequest = '1' then
			Data <= mem(Index);
		else
			Data <= (others => 'Z');
		end if;
	end process;
end;