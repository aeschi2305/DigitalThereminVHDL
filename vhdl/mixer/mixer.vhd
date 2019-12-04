--=========================================================
--Filename:  mixer.vhd
--Designer:  Andreas Frei
--Date    :  25.11.2019
--Content :  mixer
--=========================================================
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity mixer is
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
end entity mixer;

architecture rtl of mixer is
  -- Internal signals:
  signal mixer_reg       : signed(N-1 downto 0);
  signal mixer_cmb       : signed(N-1 downto 0);

begin
  ------------------------------------------------------------------------------
  -- Registerd Process
  ------------------------------------------------------------------------------
  p_reg : process (reset_n, clk)
  begin
    if reset_n = '0' then
      mixer_reg <= (others => '0');
    elsif rising_edge(clk) then
        mixer_reg <= mixer_cmb; 
    end if;
  end process p_reg;
  ------------------------------------------------------------------------------
  -- Combinatorial Process
  ------------------------------------------------------------------------------
  p_cmb : process (all)
  begin
    if square_freq = '1' then
    	mixer_cmb <= sine;
    elsif square_freq = '0' then
    	mixer_cmb <= (not sine) + 1;
    end if;
  end process p_cmb;
  
  ------------------------------------------------------------------------------
  -- Output Assignments
  ------------------------------------------------------------------------------
  mixer_out <= mixer_reg;
  
end rtl;