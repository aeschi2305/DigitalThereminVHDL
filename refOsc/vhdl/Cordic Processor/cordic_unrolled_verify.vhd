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

entity cordic_unrolled_verify is
	generic (
	 N : natural := 16;	--Number of Bits of the sine wave (precision)
	 nn : integer := 100	--Number of calculated sine values from -pi/2 to pi/2
	);
  	port(
     reset_n : out std_ulogic;
   	 clk : out std_ulogic;
     phi : out signed(N-1 downto 0);
     sine : in signed(N downto 0)
  	);
end entity cordic_unrolled_verify;

architecture stimuli_and_monitor of cordic_unrolled_verify is
  constant c_cycle_time : time := 20 ns;
  constant slope_ang    : integer := 2*(2**(N)-1)/nn;
  signal enable         : boolean := true;
  signal phi_n          : signed (N-1 downto 0);
  signal count 			: integer;
 
begin

  reset_n <= transport '0', '1' after 2*c_cycle_time;

  p_calculate_phi : process
    
  begin
    count <= -nn/4;
    phi_n <= (others => '0');
    wait for 2*c_cycle_time;
  	
    while count <= nn/4 loop
      phi_n <= to_signed(count * slope_ang, phi_n'length);
      wait for c_cycle_time;
      count <= count + 1;
    end loop;
    wait for 3*c_cycle_time;
    enable <= false;
    wait;
  end process p_calculate_phi;


  -- 50MHz
  p_system_clk : process
  begin
  	
  	
    while enable loop
      clk <= '0';
      wait for c_cycle_time/2;
      clk <= '1';
      wait for c_cycle_time/2;
    end loop;
    wait;  -- don't do it again
  end process p_system_clk;

phi <= phi_n;
  
end architecture stimuli_and_monitor;
