library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is 
end testbench;

architecture test1 of testbench is 

component calculateur is
	port(
	detecteur : in std_logic_vector(6 downto 0);
	eerreur : out std_logic_vector(3 downto 0);
	nombre_de_1 : out std_logic_vector(2 downto 0)
	);
end component;

signal det 			: std_logic_vector(6 downto 0);
signal nombre_1   : std_logic_vector(2 downto 0):="000";
signal erreur : std_logic_vector(3 downto 0);

begin

	test : calculateur port map(
		detecteur => det,
		nombre_de_1     => nombre_1,
		eerreur   => erreur
	);
	
	det <= "0110000","0001100" after 10 ns,"0000000" after 20 ns, "0000001" after 30 ns;
	
end test1;