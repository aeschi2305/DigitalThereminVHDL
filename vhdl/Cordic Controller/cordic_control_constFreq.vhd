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
constant sig_Freq : signed(20 downto 0) := to_signed(500000,21);      -- interpreted as 500000/2**20
constant clk_Period : signed(N-1 downto 0) := "0000001011001100";		-- clk_Period multiplied with 2**20
constant invert : signed(N downto 0) := '0'&(N-1 downto 0 => '1');			-- used to invert sawtooth angle to triangle angle
constant sign_inv : signed(N-1 downto 0) := "00000"&(N-6 downto 0 => '1');	-- inverts the sign because of shift right
signal phi_noninv_cmb : signed (N downto 0);    --Combinatorial calculated sawtooth angle
signal phi_noninv_reg : signed (N downto 0);    --Sequential calculated sawtooth angle
signal phi_cmb : signed (N-1 downto 0); 		--Combinatorial calculated triangle angle
signal phi_reg : signed (N-1 downto 0);			--Sequential calculated triangle angle
signal phi_step :  signed (N downto 0);  --Step for the calculation of the current sawtooth angle.



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
    variable phi_tmp1 : signed(N downto 0);
    variable phi_tmp2 : signed(N downto 0);
    begin
    	phi_tmp1 := phi_noninv_reg + phi_step;
    	phi_noninv_cmb <= phi_tmp1;
        if phi_tmp1(N downto N-1) = "01" or phi_tmp1(N downto N-1) = "10" then
            phi_tmp2 := phi_tmp1 xor invert;
            phi_cmb <= phi_tmp2(N-1 downto 0);
        else
            phi_cmb <= phi_tmp1(N-1 downto 0);
        end if;

 
    end process p_cmb_phicalc;

    p_cmb_stepcalc : process(all)
        variable phi_step_tmp : signed(2*N-1 downto 0);
        variable sig_Freq_shifted : signed(N-1 downto 0);
    begin
        sig_Freq_shifted := sig_Freq(20 downto 21-N);
        phi_step_tmp := (sig_Freq_shifted)*clk_Period;  --Problematic for N > 20
        phi_step <= phi_step_tmp(2*N-1 downto N-1);
  
    end process p_cmb_stepcalc;

    phi <= phi_reg;
            
end architecture behavioral;