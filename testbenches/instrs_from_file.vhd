library IEEE;
use IEEE.STD_LOGIC_1164.all;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.NUMERIC_STD.all;

entity instrs_from_file is
	generic(pc_width : integer := 32; file_path : string);
	port(PC: in STD_LOGIC_VECTOR(pc_width - 1 downto 0);
	Instr: out STD_LOGIC_VECTOR(7 downto 0));
end;

architecture synth of instrs_from_file is
	subtype word_t is STD_LOGIC_VECTOR(7 downto 0);
	type ramtype is array(2**pc_width downto 0) of word_t;
	-- initialize memory from file
	
	impure function read_from_file return ramtype is
		file text_file : text open read_mode is file_path;
		variable text_line : line;
		variable line_content : character;
		variable temp_instr: integer;
		variable ram_content : ramtype;
		variable i : integer := 0;
	begin
		for i in 0 to 2**pc_width - 1 loop -- set all contents low
			ram_content(i) := (others => '0');
		end loop;
		while not endfile(text_file) loop -- set contents from file
			readline(text_file, text_line);
			read(text_line, line_content);
			temp_instr := character'pos(line_content);
			ram_content(i) := std_logic_vector(to_unsigned(temp_instr, 8));
			i := i + 1;
		end loop;
		
		return ram_content;
	end function;	
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
	
	signal mem : ramtype := read_from_file;
	begin
	-- read memory
	process(PC) begin
		Instr <= mem(to_integer(PC));
	end process;
end;