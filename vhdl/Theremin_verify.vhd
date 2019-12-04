-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : theremin_verify.vhd
-- Author  : andreas.frei@students.fhnw.ch
-----------------------------------------------------
-- Description : Stimulus and Monitor 
-----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

entity Theremin_verify is
  generic (
    N : natural := 16  --Number of Bits of the sine wave (precision)
    );
    port (
      reset_n        : out  std_ulogic; -- asynchronous reset
      clk            : out  std_ulogic; -- clock
      square_freq    : out  std_ulogic; -- asynchronous reset, active low
      audio_out      : in signed(N+9 downto 0)
    );
end entity Theremin_verify;

architecture stimuli_and_monitor of Theremin_verify is
  constant c_cycle_time      : time := 20.83 ns; -- 48e6MHZ
  constant c_cycle_time_rect : time := 1.901 us; --524.8kHz
  constant data_size         : natural := 5000000;
  signal count1              : natural := 0;
  signal enable              : boolean := true;
 
begin

  p_count : process
  begin
    while enable loop
      if count1 < data_size-1 then
        count1 <= count1 + 1;
        enable <= true;
      else
        count1 <= 0;
        enable <= false;
      end if;
      wait for c_cycle_time;
    end loop;
    wait;
  end process p_count;


  p_write : process
   -- Declare and Open file in read mode: 
    file file_handler     : text open write_mode is "theremin_out.txt";
    Variable row          : line;
    Variable v_data_write : integer;
  begin
    wait for 2*c_cycle_time;
    while enable loop
    -- Write value to line
      v_data_write := to_integer(audio_out);
      write(row, v_data_write, right, 26);
    -- Write line to the file
      writeline(file_handler ,row);
      wait for 1000*c_cycle_time;
    end loop;
    wait;
  end process p_write;

  -- 48MHz
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

    -- 525.8kHz
  p_clk_rect : process
  begin
    square_freq <= '0';
    wait for 2*c_cycle_time;
    while enable loop
      square_freq <= '0';
      wait for c_cycle_time_rect/2;
      square_freq <= '1';
      wait for c_cycle_time_rect/2;
    end loop;
    wait;  -- don't do it again
  end process p_clk_rect;


end architecture stimuli_and_monitor;