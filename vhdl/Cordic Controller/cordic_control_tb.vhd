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

entity cordic_control_tb is
end entity cordic_control_tb;

architecture struct of cordic_control_tb is
	
	constant N       : natural := 16; 

	constant stages  : natural := 3;	-- N-1 / stages has to be a natural number
	-- Internal signal declarations:
	signal clk       : std_ulogic;
	signal reset_n     : std_ulogic;
	signal phi 		 : signed (N-1 downto 0);
	signal sine 	 : signed (N-1 downto 0);
	signal sig_freq_up_down : std_ulogic_vector(1 downto 0);


	
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
	
	component cordic_Control is
		generic (
		 N : natural := 16	--Number of Bits of the sine wave (precision)
		);
  		port(
    	 
    	 reset_n : out std_ulogic;
    	 clk : out std_ulogic;
    	 phi : out signed(N-1 downto 0);
    	 sig_freq_up_down : in std_ulogic_vector(1 downto 0)
  		);
	end component cordic_Control;

	component cordic_control_verify is
	generic (
	 N : natural := 16	--Number of Bits of the sine wave (precision)
	);
  	port(
     reset_n : out std_ulogic;
   	 clk : out std_ulogic;
     sine : in signed(N downto 0);
     sig_freq_up_down : out std_ulogic_vector(1 downto 0)
  	);
	end component cordic_control_verify;
	
begin
	
	-- Instance port mappings.
	control_pm : entity work.cordic_Control
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n     => reset_n,
			phi     => phi,
			sig_freq_up_down => sig_freq_up_down
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

	verify_pm : entity work.cordic_control_verify
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			reset_n   => reset_n,
			sine => sine,
			sig_freq_up_down => sig_freq_up_down
		); 
	
end architecture struct;