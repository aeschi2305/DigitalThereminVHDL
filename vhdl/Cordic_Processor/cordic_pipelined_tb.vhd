-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : cordic_pipelined_tb.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Testbench for cordic_pipelined.vhd
-----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_pipelined_tb is
end entity cordic_pipelined_tb;

architecture struct of cordic_pipelined_tb is
	
	constant N       : natural := 16; 

	constant stages  : natural := 3;	-- N-1 / stages has to be a natural number
	-- Internal signal declarations:
	signal clk       : std_ulogic;
	signal reset_n     : std_ulogic;
	signal phi 		 : signed (N-1 downto 0);
	signal sine 	 : signed (N-1 downto 0);


	
	-- Component Declarations
	component cordic_pipelined is
		generic (
    	  N : natural := 16 --Number of Bits of the sine wave (precision)
  		);
  		port(
  		  reset_n : in std_ulogic;
  		  clk : in std_ulogic;
  		  phi : in signed(N-1 downto 0);
  		  sine : out signed(N downto 0)
  		);
	end component cordic_pipelined;
	
	component cordic_pipelined_verify is
		generic (
		 N : natural := 16;	--Number of Bits of the sine wave (precision)
		 nn : natural := 100	-- Cordic Latency (in Clock Cycles)
		);
  		port(
    	 
    	 reset_n : out std_ulogic;
    	 clk : out std_ulogic;
    	 phi : out signed(N-1 downto 0);
    	 sine : in signed(N-1 downto 0)
  		);
	end component cordic_pipelined_verify;
	
begin
	
	-- Instance port mappings.
	verify_pm : entity work.cordic_pipelined_verify
		generic map (
			N => N,
			nn => 100
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			phi     => phi,
			sine    => sine
		); 

	cordic_pm : entity work.cordic_pipelined
		generic map (
			N => N,
			stages => stages
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			phi => phi,
			sine => sine
		); 
	
end architecture struct;