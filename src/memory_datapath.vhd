library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity memory_datapath is
	generic(bf_width: integer := 8);
	port(Clk: in STD_LOGIC;
			StackEnable: in STD_LOGIC;
			Reset: in STD_LOGIC;
			Memory: in STD_LOGIC;
			Operation: in STD_LOGIC;
			OverrideData: in STD_LOGIC;
			Override: in STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			Data: out STD_LOGIC_VECTOR(bf_width - 1 downto 0));
end;

architecture synth of memory_datapath is
	component registry generic(width : integer);
	port(Input: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			WriteEnable: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	component regbank generic(width : natural; addr_width : natural);
	port(Addr: in STD_LOGIC_VECTOR(addr_width - 1 downto 0);
			WriteIn: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Clk: in STD_LOGIC;
			Reset: in STD_LOGIC;
			WriteEnable: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	component addersubtractor generic(width : integer);
	port(a, b: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Selection: in STD_LOGIC; -- 0-> addition, 1 -> subtraction
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	component mux2	generic(width : integer);
	port(Input0, Input1: in STD_LOGIC_VECTOR(width - 1 downto 0);
			Selection: in STD_LOGIC;
			Output: out STD_LOGIC_VECTOR(width - 1 downto 0));
	end component;
	
	signal AdderSubtrInput, AdderSubtrResult : STD_LOGIC_VECTOR(bf_width - 1 downto 0);
	signal StackPointer, StackData, NextStackData : STD_LOGIC_VECTOR(bf_width - 1 downto 0);
	signal SPWriteEnable, SDWriteEnable : STD_LOGIC;
begin
	SPWriteEnable <= StackEnable and not(Memory);
	SDWriteEnable <= (StackEnable and Memory) or OverrideData;
	Data <= StackData;
	-- Stack Logic
	spreg: registry generic map(bf_width) port map(AdderSubtrResult, Clk, Reset, SPWriteEnable, StackPointer);
	sdregbank: regbank generic map(bf_width, bf_width) port map(StackPointer, NextStackData, Clk, Reset, SDWriteEnable, StackData);
	-- Incrementation and Decrementation logic
	addsubmux: mux2 generic map(bf_width) port map(StackPointer, StackData, Memory, AdderSubtrInput);
	addersubtr: addersubtractor generic map(bf_width) port map(AdderSubtrInput, (0 => '1', others => '0'), Operation, AdderSubtrResult);
	-- Data Override Logic
	overridemux: mux2 generic map(bf_width) port map(AdderSubtrResult, Override, OverrideData, NextStackData);
end;