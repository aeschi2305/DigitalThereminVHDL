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
use ieee.math_real.all;




entity cordic_Control is
	generic (
	 N : natural := 16	--Number of Bits of the sine wave (precision)
	);
  port(
    reset_n : in std_ulogic;
    clk : in std_ulogic;
    phi : out signed(N-1 downto 0)		--calculated angle for cordic processor
  );
end entity cordic_Control;


architecture behavioral of cordic_Control is
constant sig_Freq : signed(20 downto 0) := to_signed(550000,21);      -- interpreted as 500000/2**20
constant clk_Period : signed(20 downto 0) := "000000101100101111010";		-- clk_Period multiplied with 2**20
constant invert : signed(41 downto 0) := '0'&(40 downto 0 => '1');			-- used to invert sawtooth angle to triangle angle

signal phi_noninv_cmb : signed (41 downto 0);    --Combinatorial calculated sawtooth angle
signal phi_noninv_reg : signed (41 downto 0);    --Sequential calculated sawtooth angle
signal phi_cmb : signed (N-1 downto 0); 		--Combinatorial calculated triangle angle
signal phi_reg : signed (N-1 downto 0);			--Sequential calculated triangle angle
signal phi_step :  signed (41 downto 0);  --Step for the calculation of the current sawtooth angle.



begin

    p_reg : process(reset_n,clk)
    begin
      if reset_n = '0' then
      		phi_reg <= (others => '0');
      		phi_noninv_reg <= (others => '0');
      		
        elsif rising_edge(clk) then
            phi_reg <= phi_cmb;
            phi_noninv_reg <= phi_noninv_cmb;
        end if;
    end process p_reg;

    p_cmb_phicalc : process(all)
    variable phi_tmp1 : signed(41 downto 0) := (others => '0');
    variable phi_tmp2 : signed(41 downto 0) := (others => '0');
    begin
    	phi_tmp1 := phi_noninv_reg + phi_step;
    	
        if phi_tmp1(41 downto 40) = "01" or phi_tmp1(41 downto 40) = "10" then
            phi_tmp2 := phi_tmp1 xor invert;
            phi_cmb <= phi_tmp2(40 downto 40-N+1);
        else
            phi_cmb <= phi_tmp1(40 downto 40-N+1);
        end if;
        phi_noninv_cmb <= phi_tmp1;

 
    end process p_cmb_phicalc;



    p_cmb_stepcalc : process(all)
        variable phi_step_tmp : signed(41 downto 0);
        --variable phi_step_tmp2 : signed(20 downto 0);
    begin 
        phi_step_tmp := sig_Freq*clk_Period;
        --phi_step_tmp2 :=  phi_step_tmp(41 downto 21);
        phi_step <= shift_left(phi_step_tmp,2);--resize(phi_step_tmp,phi_step'length);
  
    end process p_cmb_stepcalc;

    phi <= phi_reg;
    end architecture behavioral; 