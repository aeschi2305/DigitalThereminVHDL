-------------------------------------------------------------
-- Musterloesung dt2 Uebung 8
-------------------------------------------------------------
-- File    : 08_verify.vhd
-- Library : work
-- Author  : stefan.brantschen@fhnw.ch
-- Created : 01.05.2014
-- Company : Institute for Sensors and Electronics (ISE) FHNW
-- Copyright(C) ISE
-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

entity verify is
  port(
    sine : in signed(15 downto 0);
    reset : out std_ulogic;
    clk : out std_ulogic;
    phi : out signed(15 downto 0)
  );
end entity verify;

architecture stimuli_and_monitor of verify is
  constant c_cycle_time : time := 20 ns;
  signal enable         : boolean := true;
  signal phi_n          : signed
 
begin

  -- System reset:
  rst_n <= transport '0', '1' after 10 ns;

  p_calculate_phi : process
    
  begin
    
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

  
end architecture stimuli_and_monitor;
