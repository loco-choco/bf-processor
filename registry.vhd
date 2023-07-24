library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity registry is
	generic(width : integer := 32);
	port(Input: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			WriteEnable: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
end;

architecture synth of registry is
begin
	process(Clk, Reset, Input, WriteEnable)
	begin
		if (Reset = '0') then
			Output <= (others => '0');
		elsif rising_edge(Clk)then
			if (WriteEnable = '1') then
				Output <= Input;
			end if;
		end if;
	end process;
end architecture;