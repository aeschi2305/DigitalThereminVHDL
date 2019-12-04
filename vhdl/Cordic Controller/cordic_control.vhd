-----------------------------------------------------
-- Project : Cordic Control
-----------------------------------------------------
-- File    : cordic.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Calculates the sine value of a given angle phi
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all




entity cordic_Control is
	generic (
	 N : natural := 16	--Number of Bits of the sine wave (precision)
	 n : natural := 1	-- Cordic Latency (in Clock Cycles)
	);
  port(
    reset_n : in std_ulogic;
    clk : in std_ulogic;
    phi : out signed(N-1 downto 0);			--calculated angle for cordic processor
    cordic_sine : in signed(N-1 downto 0);	--result of cordic
    sine : out signed(N-1 downto 0);					--final sine wave
    freq_up : in std_ulogic;				--Button to increment frequency
    freq_down : in std_ulogic 				--Button to decrement frequency
  );
end entity cordic_Control;


architecture behavioral of cordic_Control is
constant sig_Period : natural := 1/500000;
constant clk_Period : natural := 1/50000000;
constant ONE : signed (cordic_sine'range) := (0 => '1', others => '0');
signal phi_cmb : signed (N-1 downto 0); 		--Combinatorial calculated angle
signal phi_reg : signed (N-1 downto 0);			--Sequential calculated angle
signal freq : natural 450000 to 550000;			--Generator Frequency
signal quad_reg : std_ulogic_vector (n-1 downto 0) 	--Safed Quadrant information to shift the Amplitude (Vector length corresponds to the number of piplines in the cordic processor)
signal quad_cmb : std_ulogic;
constant slope_ang : signed (N-1 downto 0) := to_unsigned(clk_Period/sig_Period,slope_ang'length); --Slope for the calculation of the current angle.
signal sine_conv : signed (N-1 downto 0);
signal count : natural -25 to 25;				-- Counter to calculate the angle

begin

    p_reg : process(reset,clk)
    begin
      if reset_n = '0' then
      		quad_reg <= (others => '0');
      		
        elsif rising_edge(clk) then
            quad_reg <= quad_reg(N-2 downto 0) & quad_cmb;
            sine <= sine_conv
            count <= count + 1;
        end if;
    end process p_reg;

    p_cmb_anglecalc : process(all)
    begin
    	phi_cmb <= slope_ang * to_unsigned(count,slope_ang'length);
    	if phi_cmb < phi_reg then
    		quad_cmb <= quad_cmb xor '1';
       	end if;
    end process p_cmb_anglecalc;

	p_cmb_sine : process(all)
    begin
    	if quad_reg(N-1) = '1' then
    		sine_conv <= not cordic_sine + ONE;
    	else 
    		sine_conv <= cordic_sine;
    	end if;
    end process p_cmb_sine;
            
end architecture behavioral;