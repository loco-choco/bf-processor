library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity is_zero is
	generic(width : integer := 32);
	port(Input: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Output: out STD_LOGIC);
end;

architecture synth of is_zero is
	constant Zero: STD_LOGIC_VECTOR(width - 1 downto 0) := (others => '0');
begin
	Output <= 
	'1' when Input = Zero else
	'0';
end;