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

entity verify is
	generic (
	 N : natural := 16;	--Number of Bits of the sine wave (precision)
	 n : natural := 100	--Number of calculated sine values from -pi/2 to pi/2
	);
  	port(
     reset_n : out std_ulogic;
   	 clk : out std_ulogic;
     phi : out signed(N-1 downto 0);
     sine : in signed(N-1 downto 0)
  	);
end entity verify;

architecture stimuli_and_monitor of verify is
  constant c_cycle_time : time := 20 ns;
  signal enable         : boolean := true;
  signal phi_n          : signed (N-1 downto 0);
  signal slope_ang 		: signed (N-1 downto 0) := to_signed(2*2**(N-1)/sig_Period,slope_ang'length);
  signal count 			: natural -n/2 to n/2;
 
begin

  -- System reset:
  rst_n <= transport '0', '1' after 10 ns;

  p_calculate_phi : process
    
  begin
  	count = -n/2;
    while count < n/2 loop
      phi_n = to_signed(count, slope_ang'length) * slope_ang;
      wait for c_cycle_time;
      count = count + 1;
    end loop;
    enable = false;
  end process p_calculate_phi;


  -- 50MHz
  p_system_clk : process
  begin
  	reset_n <= transport '0', '1' after 3*c_clk_cycle;
  	enable <= true;
    while enable loop
      clk <= transport '0', '1' after c_clk_cycle/2;
      wait for c_clk_cycle;
    end loop;
    wait;  -- don't do it again
  end process p_system_clk;

  
end architecture stimuli_and_monitor;
