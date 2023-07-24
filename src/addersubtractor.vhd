library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity addersubtractor is
	generic(width : integer := 2);
	port(a, b: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Selection: in STD_LOGIC; -- 0-> addition, 1 -> subtraction
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
end;
architecture synth of addersubtractor is
	signal Carries: STD_LOGIC_VECTOR(width downto 0);
begin
	Carries(0) <= Selection;
	abc: for i in 0 to width - 1 generate
		Carries(i + 1) <= (a(i) and (b(i) xor Selection)) 
								or ((b(i) xor Selection) and Carries(i)) 
								or (a(i) and Carries(i));
		Output(i) <= (a(i) xor (b(i) xor Selection)) xor Carries(i);
	end generate;
end;