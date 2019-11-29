-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : mixer_tb.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Testbench for cordic.vhd
-----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mixer_tb is
end entity mixer_tb;

architecture struct of mixer_tb is
	
	constant N       	: natural := 16; 
	-- Internal signal declarations:
	signal clk       	: std_ulogic;
	signal reset_n   	: std_ulogic;
	signal square_freq  : std_ulogic;
	signal sine 	 	: signed (N-1 downto 0);
	signal mixer_out 	: signed (N-1 downto 0);

	
	-- Component Declarations
	component mixer is
		generic (
 		N : natural := 16	--Number of Bits of the sine wave (precision)
		);
  		port (
   		 reset_n  	  : in  std_ulogic; -- asynchronous reset
    	 clk      	  : in  std_ulogic; -- clock
    	 square_freq  : in  std_ulogic; -- asynchronous reset, active low
    	 sine 		  : in signed(N-1 downto 0);
    	 mixer_out 	  : out signed(N-1 downto 0)
    	);
	end component mixer;
	
	component mixer_verify is
		generic (
   		N : natural := 16  --Number of Bits of the sine wave (precision)
  		);
    	port (
    	 reset_n      : out  std_ulogic; -- asynchronous reset
     	 clk          : out  std_ulogic; -- clock
     	 square_freq  : out  std_ulogic; -- asynchronous reset, active low
    	 sine         : out signed(N-1 downto 0);
    	 mixer_out    : in signed(N-1 downto 0)
  		);
	end component mixer_verify;
	
begin
	
	-- Instance port mappings.
	verify_pm : entity work.mixer_verify
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			sine    => sine,
			square_freq     => square_freq,
			mixer_out => mixer_out
		); 

	mixer_pm : entity work.mixer
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			sine    => sine,
			square_freq     => square_freq,
			mixer_out => mixer_out
		); 
	
end architecture struct;