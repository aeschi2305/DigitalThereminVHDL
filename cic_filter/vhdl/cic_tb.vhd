-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : cic_tb.vhd
-- Author  : andreas.frei@students.fhnw.ch
-----------------------------------------------------
-- Description : Testbench for cic.vhd
-----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cic_tb is
end entity cic_tb;

architecture struct of cic_tb is
	
	constant N       	: natural := 16; 
	-- Internal signal declarations:
	signal clk       	: std_ulogic;
	signal reset_n   	: std_ulogic;
	signal audio_out 	: signed (N+9 downto 0);
	signal mixer_out 	: signed (N-1 downto 0);

	
	-- Component Declarations
	component cic is
		generic (
	 		N : natural := 16	--Number of Bits of the sine wave (precision)
		);
  		port (
  	 		reset_n  	    : in  std_ulogic; -- asynchronous reset
     		clk      	    : in  std_ulogic; -- clock
     		mixer_out 	    : in signed(N-1 downto 0);
     		audio_out       : out signed(N+9 downto 0)
  		);
	end component cic;
	
	component cic_verify is
		generic (
   		N : natural := 16  --Number of Bits of the sine wave (precision)
  		);
    	port (
    		reset_n        : out  std_ulogic; -- asynchronous reset
     		clk            : out  std_ulogic; -- clock
    		mixer_out 	    : out signed(N-1 downto 0);
     		audio_out      : in signed(N+9 downto 0)
  		);
	end component cic_verify;
	
begin
	
	-- Instance port mappings.
	verify_pm : entity work.cic_verify
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			mixer_out    => mixer_out,
			audio_out     => audio_out
		); 

	cic_pm : entity work.cic
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			mixer_out    => mixer_out,
			audio_out     => audio_out
		); 


	
end architecture struct;