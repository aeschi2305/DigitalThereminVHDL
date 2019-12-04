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

entity Theremin_tb is
end entity Theremin_tb;

architecture struct of Theremin_tb is
	
	constant N       : natural := 16; 

	constant stages  : natural := 3;	-- N-1 / stages has to be a natural number
	-- Internal signal declarations:
	signal clk      	: std_ulogic;
	signal reset_n   	: std_ulogic;
	signal phi 			: signed (N-1 downto 0);
	signal sine 		: signed (N-1 downto 0);
	signal mixer_out 	: signed (N-1 downto 0);
	signal square_freq  : std_ulogic;
	signal audio_out 	: signed (N+9 downto 0);


	
	-- Component Declarations
	component cordic_pipelined is
		generic (
    	  N : natural := 16; --Number of Bits of the sine wave (precision)
    	  stages : natural := 3
  		);
  		port(
  		  reset_n : in std_ulogic;
  		  clk : in std_ulogic;
  		  phi : in signed(N-1 downto 0);
  		  sine : out signed(N-1 downto 0)
  		);
	end component cordic_pipelined;
	
	component cordic_Control is
		generic (
		  N : natural := 16	--Number of Bits of the sine wave (precision)
		);
  		port(
    	  reset_n : in std_ulogic;
    	  clk : in std_ulogic;
    	  phi : out signed(N-1 downto 0)		--calculated angle for cordic processor
  		);
	end component cordic_Control;

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

	component cic is
		generic (
		  N : natural := 16	--Number of Bits of the sine wave (precision)
		);
	  	port (
	  	  reset_n  	    : in  std_ulogic; -- asynchronous reset
	      clk      	    : in  std_ulogic; -- clock
	      mixer_out 	: in signed(N-1 downto 0);
	      audio_out     : out signed(N+9 downto 0)
	  );
	end component cic;

	component Theremin_verify is
		generic (
		  N : natural := 16	--Number of Bits of the sine wave (precision)
		);
  		port(
    	  reset_n 		 : out std_ulogic;
   	 	  clk 			 : out std_ulogic;
     	  square_freq 	 : out std_ulogic;
     	  audio_out      : in signed(N+9 downto 0)
  		);
	end component Theremin_verify;
	
begin
	
	-- Instance port mappings.
	control_pm : entity work.cordic_Control
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			phi     => phi
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

	cic_pm : entity work.cic
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			audio_out => audio_out,
			mixer_out => mixer_out
		); 

	mixer_pm : entity work.mixer
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			sine => sine,
			square_freq => square_freq,
			mixer_out => mixer_out
		); 

	verify_pm : entity work.Theremin_verify
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n   => reset_n,
			square_freq => square_freq,
			audio_out => audio_out
		); 
	
end architecture struct;