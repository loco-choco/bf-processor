library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity regbank is
	generic(width : natural := 32; addr_width : natural := 2);
	port(Addr: in STD_LOGIC_VECTOR(addr_width - 1 downto 0);
			WriteIn: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			WriteEnable: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
end;

architecture synth of regbank is
	subtype word_t is STD_LOGIC_VECTOR(width - 1 downto 0);
	type memory_t is array(addr_width - 1 downto 0) of word_t;
	signal bank : memory_t;
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
process(Clk, Reset, Addr, WriteIn, WriteEnable)
begin
	if (Reset = '0') then
		reset: for i in 0 to addr_width - 1 loop
			bank(i) <= (others => '0');
		end loop reset;
	elsif rising_edge(Clk)then
		if (WriteEnable = '1') then
			bank(to_integer(Addr)) <= WriteIn;
		end if;
	end if;
end process;
Output <= bank(to_integer(Addr));
end;