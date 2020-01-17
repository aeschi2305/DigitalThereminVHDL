-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : square.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : square wave generator for final tests
-----------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity square is
	generic (
	 N : natural := 16	--Number of Bits of the square wave (precision)
	);
  	port (
  	 reset_n  	  : in  std_ulogic; -- asynchronous reset
     clk      	  : in  std_ulogic; -- clock
     square_freq  : out  signed(N-1 downto 0) -- asynchronous reset, active low
     
  );
end entity square;

architecture rtl of square is
  -- Internal signals:


  signal square_cmb          : signed(N-1 downto 0);
  signal square_reg          : signed(N-1 downto 0);
  signal toggle				: std_ulogic;
  signal count_cmb          : natural range 0 to 24000;
  signal count_reg          : natural range 0 to 24000;

begin
  ------------------------------------------------------------------------------
  -- Registerd Process
  ------------------------------------------------------------------------------
  p_reg : process (reset_n, clk)
  variable square_reg_tmp : signed(N-1 downto 0);
  begin
    if reset_n = '0' then
      square_reg_tmp := (others => '1');
      square_reg_tmp(square_reg'high downto square_reg'high-1) := "00";
      square_reg <= square_reg_tmp;
    elsif rising_edge(clk) then
        square_reg <= square_cmb; 
        if count_reg = 24000 then
        	toggle <= '1';
        	count_reg <= 0;
        else
        	toggle <= '0';
        	count_reg <= count_cmb;
        end if;
    end if;
  end process p_reg;
  ------------------------------------------------------------------------------
  -- Combinatorial Process
  ------------------------------------------------------------------------------
  p_cmb : process (all)
  begin
    if toggle = '1' then
    	square_cmb <= (not square_reg) + 1;
    else
    	square_cmb <= square_reg;
    end if;
    count_cmb <= count_reg + 1;
  end process p_cmb;
  
  ------------------------------------------------------------------------------
  -- Output Assignments
  ------------------------------------------------------------------------------
  square_freq <= square_reg;
  
end rtl;