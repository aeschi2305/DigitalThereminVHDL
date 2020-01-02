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

entity cordic_control_verify is
	generic (
	 N : natural := 16;	--Number of Bits of the sine wave (precision)
   freq_shift : boolean := true
	);
  	port(
     reset_n : out std_ulogic;
   	 clk : out std_ulogic;
     sine : in signed(N-1 downto 0);
     sig_freq_up_down : out std_ulogic_vector(1 downto 0)
  	);
end entity cordic_control_verify;

architecture stimuli_and_monitor of cordic_control_verify is
  constant c_cycle_time : time := 20.833333333333333333333 ns;
  signal count 			: integer := 0;
  signal enable         : boolean := true;
  signal text_enable : boolean := false;
 
begin

  reset_n <= transport '0', '1' after 2*c_cycle_time;

  p_textWrite : process
	file file_handler	: text open write_mode is "sinegen.txt";
	variable row		: line;
	variable v_data_write	: integer; 
  begin
  	wait until text_enable = true;
    	while enable = true loop
      	v_data_write := to_integer(sine);
    		write(row,v_data_write,right,16);
    		writeline(file_handler,row);
  		wait for c_cycle_time;
	  end loop;
    wait;
  end process p_textWrite;


  p_count : process
    
  begin
    sig_freq_up_down <= "00";
    while count <= 5003000 loop
      wait for c_cycle_time;
      count <= count + 1;
      if count = 1000 then 
        f_up : for i in 0 to 100 loop
            sig_freq_up_down <= "10";
            wait for c_cycle_time;
            sig_freq_up_down <= "00";
            wait for c_cycle_time;
        end loop f_up;
      elsif count = 2000 then
        f_down : for i in 0 to 100 loop
            sig_freq_up_down <= "01";
            wait for c_cycle_time;
            sig_freq_up_down <= "00";
            wait for c_cycle_time;
        end loop f_down;
      elsif count >= 3000 then
        text_enable <= true;
      end if;
    end loop;
    wait for 3*c_cycle_time;
    enable <= false;
    wait;
  end process p_count;


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
