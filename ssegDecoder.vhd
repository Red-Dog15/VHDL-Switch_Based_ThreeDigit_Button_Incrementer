--converts binary coded decimal to seven segment code for DE1-SoC 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ssegDecoder is port
	(
		binaryIn	 : in std_logic_vector(3 downto 0);
		ssegOut	 : out std_logic_vector(7 downto 0)
	);
end ssegDecoder;

architecture rtl of ssegDecoder is

begin

with binaryIn select

    ssegOut <=
				"11000000" when x"0",
            "11111001" when x"1",
            "10100100" when x"2",
            "10110000" when x"3",
            "10011001" when x"4",
            "10010010" when x"5",
            "10000010" when x"6",
            "11111000" when x"7",
            "10000000" when x"8",
            "10011000" when x"9",
            "11111111" when others;
end rtl;