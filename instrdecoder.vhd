library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Char | Ascii |Action(0->Normal, 1->IO/Branch)|Memory(0->SP,1->Data)|Operation(0->+, 1->-)
--  >      0x3C                0                        0                        0      
--  <      0x3E                0                        0                        1  
--  +      0x2B                0                        1                        0
--  -      0x2D                0                        1                        1
--  .      0x2E                1                        1                        0  
--  ,      0x2C                1                        1                        1
--  [      0x5B                1                        0                        0
--  ]      0x5D                1                        0                        1
entity instrdecoder is
	port(Instr: in STD_LOGIC_VECTOR(7 downto 0);
			Action: out STD_LOGIC;
			Memory: out STD_LOGIC;
			Operation: out STD_LOGIC);
end;
architecture synth of instrdecoder is
	signal instructions : STD_LOGIC_VECTOR(2 downto 0);
begin
	Action <= instructions(2);
	Memory <= instructions(1);
	Operation <= instructions(0);
	with Instr select
	instructions <= 
				"000" when X"3C",
				"001" when X"3E",
				"010" when X"2B",
				"011" when X"2D",
				"110" when X"2E",
				"111" when X"2C",
				"100" when X"5B",
				"101" when X"5D",
				"---" when others;
end;