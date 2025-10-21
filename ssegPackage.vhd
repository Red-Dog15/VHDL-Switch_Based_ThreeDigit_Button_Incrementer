library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ssegPackage is

	component ssegDecoder
	port
	(
		binaryIn	 : in std_logic_vector(3 downto 0);
		ssegOut	 : out std_logic_vector(7 downto 0)
	);
   end component;	
	
	component doubleDabble
	port
	(
		clk		 : in std_logic;
		binaryIn	 : in unsigned(11 downto 0);
		bcd		 : out std_logic_vector(15 downto 0)
	);
	end component;


end package ssegPackage;


