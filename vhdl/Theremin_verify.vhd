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
    N : natural := 16;  --Number of Bits of the sine wave (precision)
    freq_shift : boolean := false;
    antenna_def_freq : natural := 501000
    );
    port (
      reset_n        : out  std_ulogic; -- asynchronous reset
      clk            : out  std_ulogic; -- clock
      square_freq    : out  std_ulogic; -- asynchronous reset, active low
      audio_out      : in signed(N+9 downto 0);
      sine           : in signed(N-1 downto 0);
      mixer_out          : in signed(N-1 downto 0);
      sig_freq_up_down : out std_ulogic_vector(1 downto 0)
    );
end entity Theremin_verify;

architecture stimuli_and_monitor of Theremin_verify is
  constant c_cycle_time      : time := 20.833333333 ns; -- 48e6MHZ
  constant c_cycle_time_rect : time := 1.996008 us; --501kHz
  constant data_size         : natural := 5000000;
  signal count              : natural := 0;
  signal enable              : boolean := true;
  signal text_enable        : boolean := false;
 
begin
  
    p_count : process
    
  begin
    sig_freq_up_down <= "00";
    while count <= data_size+2000 loop
      wait for c_cycle_time;
      count <= count + 1;
      if count = 1000 and freq_shift = true then 
        f_up : for i in 0 to 999 loop
            sig_freq_up_down <= "10";
            wait for c_cycle_time;
            sig_freq_up_down <= "00";
            wait for c_cycle_time;
        end loop f_up;
      elsif count >= 2000 then
        text_enable <= true;
      end if;
    end loop;
    wait for 3*c_cycle_time;
    enable <= false;
    wait;
  end process p_count;

  p_write_cordic_out : process
   -- Declare and Open file in read mode: 
    file file_handler     : text open write_mode is "Theremin_cordic.txt";
    Variable row          : line;
    Variable v_data_write : integer;
  begin
    wait until text_enable = true;
    while enable loop
    -- Write value to line
      v_data_write := to_integer(sine);
      write(row, v_data_write, right, 16);
    -- Write line to the file
      writeline(file_handler ,row);
      wait for c_cycle_time;
    end loop;
    wait;
  end process p_write_cordic_out;

    p_write_square_out : process
   -- Declare and Open file in read mode: 
    file file_handler     : text open write_mode is "Theremin_square.txt";
    Variable row          : line;
    Variable v_data_write : integer;
  begin
    wait until text_enable = true;
    while enable loop
    -- Write value to line
      if square_freq = '1' then
        v_data_write := 1;
      else
        v_data_write := 0;
      end if;
      write(row, v_data_write, right, 1);
    -- Write line to the file
      writeline(file_handler ,row);
      wait for c_cycle_time;
    end loop;
    wait;
  end process p_write_square_out;

    p_write_mixer_out : process
   -- Declare and Open file in read mode: 
    file file_handler     : text open write_mode is "Theremin_mixer.txt";
    Variable row          : line;
    Variable v_data_write : integer;
  begin
    wait until text_enable = true;
    while enable loop
    -- Write value to line
      v_data_write := to_integer(mixer_out);
      write(row, v_data_write, right, 16);
    -- Write line to the file
      writeline(file_handler ,row);
      wait for c_cycle_time;
    end loop;
    wait;
  end process p_write_mixer_out;

  p_write_theremin_out : process
   -- Declare and Open file in read mode: 
    file file_handler     : text open write_mode is "Theremin_cic.txt";
    Variable row          : line;
    Variable v_data_write : integer;
  begin
    wait until text_enable = true;
    while enable loop
    -- Write value to line
      v_data_write := to_integer(audio_out);
      write(row, v_data_write, right, 26);
    -- Write line to the file
      writeline(file_handler ,row);
      wait for 1000*c_cycle_time;
    end loop;
    wait;
  end process p_write_theremin_out;

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

    -- 500kHz
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