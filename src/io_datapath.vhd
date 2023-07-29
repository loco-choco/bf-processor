library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity io_datapath is
	generic(bf_width: integer := 8);
	port(IOEnable: in STD_LOGIC;
			Operation: in STD_LOGIC;
			CurrentData: in STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			-- outer pins
			Data: inout STD_LOGIC_VECTOR(bf_width - 1 downto 0);
			DataRequest: out STD_LOGIC;
			DataOut: out STD_LOGIC;
			-- inner pins
			OverrideData: out STD_LOGIC;
			Override: out STD_LOGIC_VECTOR(bf_width - 1 downto 0));
end;

architecture synth of io_datapath is
	signal Request, Output : STD_LOGIC;
begin
	-- Data IN
	Override <= Data;
	Request <= IOEnable and Operation;
	OverrideData <= Request;
	DataRequest <= Request;
	-- Data OUT
	Output <= IOEnable and not(Operation);
	DataOut <= Output;	
	Data <= CurrentData when Output = '1' else (others=>'Z');
end;
