-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : mixer_verify.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Stimulus and Monitor for mixer.vhd
-----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

entity mixer_verify is
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
end entity mixer_verify;

architecture stimuli_and_monitor of mixer_verify is
  constant c_cycle_time : time := 20 ns;
  signal enable         : boolean := true;
 
begin

  p_sine : process
  begin
    enable <= true;
    wait for 2*c_cycle_time;
  -- positiv
    square_freq <= '1';
    sine <= "0100000000000000";
    wait for 1*c_cycle_time;
    sine <= "1100000000000000";
    wait for 1*c_cycle_time;
  -- negativ
    square_freq <= '0';
    sine <= "0100000000000000";
    wait for 1*c_cycle_time;
    sine <= "1100000000000000";
    wait for 1*c_cycle_time;
    enable <= false;
    wait;
  end process p_sine;

  -- 50MHz
  p_system_clk : process
  begin
  	reset_n <= transport '0', '1' after 2*c_cycle_time;
    while enable loop
      clk <= '0';
      wait for c_cycle_time/2;
      clk <= '1';
      wait for c_cycle_time/2;
    end loop;
    wait;  -- don't do it again
  end process p_system_clk;

  
end architecture stimuli_and_monitor;
