library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux2 is
	generic(width : integer := 32);
	port(Input0, Input1: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Selection: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
end;

architecture synth of mux2 is
begin
	Output <= 
	Input0 when Selection = '0' else
	Input1;
end;