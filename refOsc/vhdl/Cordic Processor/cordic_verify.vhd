-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : cordic_verify.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Stimulus and Monitor for cordic.vhd
-----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

entity cordic_verify is
	generic (
	 N : natural := 16;	--Number of Bits of the sine wave (precision)
	 nn : integer := 100	--Number of calculated sine values from -pi/2 to pi/2
	);
  	port(
     reset_n : out std_ulogic;
   	 clk : out std_ulogic;
     phi : out signed(N-1 downto 0);
     sine : in signed(N-1 downto 0)
  	);
end entity cordic_verify;

architecture stimuli_and_monitor of cordic_verify is
  constant c_cycle_time : time := 20 ns;
  constant sig_freq : natural := 500000;
  constant clk_Period : natural := 1/50000000;
  constant slope_ang    : signed (N-1 downto 0) := to_signed(2*(2**(N)-1)/nn,N);
  signal enable         : boolean := true;
  signal phi_n          : signed (N-1 downto 0);
  signal count 			: integer range 0 to nn/2;
 
begin

  p_calculate_phi : process
    
  begin
    wait for 5*c_cycle_time;
    enable <= true;
  	count <= -nn/4;
    while count < nn/4 loop
      phi_n <= to_signed(count, slope_ang'length) * slope_ang;
      wait for c_cycle_time;
      count <= count + 1;
    end loop;
    enable <= false;
  end process p_calculate_phi;


  -- 50MHz
  p_system_clk : process
  begin
  	reset_n <= transport '0', '1' after 3*c_cycle_time;
  	
    while enable loop
      clk <= transport '0', '1' after c_cycle_time/2;
      wait for c_cycle_time;
    end loop;
    wait;  -- don't do it again
  end process p_system_clk;

  
end architecture stimuli_and_monitor;
