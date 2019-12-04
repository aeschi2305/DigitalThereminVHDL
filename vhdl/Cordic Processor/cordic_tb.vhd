-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : cordic_tb.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Testbench for cordic.vhd
-----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_tb is
end entity cordic_tb;

architecture struct of cordic_tb is
	
	constant N       : natural := 16; 
	-- Internal signal declarations:
	signal clk       : std_ulogic;
	signal reset_n     : std_ulogic;
	signal phi 		 : signed (N-1 downto 0);
	signal sine 	 : signed (N downto 0);
	signal done 	 : std_ulogic;

	
	-- Component Declarations
	component cordic is
		generic (
    	  N : natural := 16 --Number of Bits of the sine wave (precision)
  		);
  		port(
  		  reset_n : in std_ulogic;
  		  clk : in std_ulogic;
  		  done : out std_ulogic;
  		  phi : in signed(N-1 downto 0);
  		  sine : out signed(N downto 0)
  		);
	end component cordic;
	
	component cordic_verify is
		generic (
		 N : natural := 16;	--Number of Bits of the sine wave (precision)
		 nn : natural := 100	-- Cordic Latency (in Clock Cycles)
		);
  		port(
    	 
    	 reset_n : out std_ulogic;
    	 clk : out std_ulogic;
    	 done : in std_ulogic;
    	 phi : out signed(N-1 downto 0);
    	 sine : in signed(N downto 0)
  		);
	end component cordic_verify;
	
begin
	
	-- Instance port mappings.
	verify_pm : entity work.cordic_verify
		generic map (
			N => N,
			nn => 100
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			done => done,
			phi     => phi,
			sine    => sine
		); 

	cordic_pm : entity work.cordic
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			done => done,
			phi => phi,
			sine => sine
		); 
	
end architecture struct;