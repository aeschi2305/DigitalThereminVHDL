-----------------------------------------------------
-- Project : Cordic Control
-----------------------------------------------------
-- File    : cordic.vhd
-- Author  : dennis.aeschbacher@students.fhnw.ch
-----------------------------------------------------
-- Description : Calculates the angle for use in the cordic algorithm
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;




entity cordic_Control is
    generic (
     N : natural := 16;  --Number of Bits of the sine wave (precision)
     cordic_def_freq : natural := 577000
    );
  port(
    reset_n : in std_ulogic;
    clk : in std_ulogic;
    phi : out signed(N-1 downto 0);      --calculated angle for cordic processor
    sig_freq_up_down : in std_ulogic_vector(1 downto 0)
  );
end entity cordic_Control;


architecture behavioral of cordic_Control is

constant clk_Period : signed(20 downto 0) := "000010110010111101010";       -- clk_Period multiplied with 2**20
constant invert : signed(20 downto 0) := '0'&(19 downto 0 => '1');          -- used to invert sawtooth angle to triangle angle

signal sig_Freq : signed(20 downto 0);      -- interpreted as cordic_def_freq/2**20
signal phi_noninv_cmb : signed (20 downto 0);    --Combinatorial calculated sawtooth angle
signal phi_noninv_reg : signed (20 downto 0);    --Sequential calculated sawtooth angle
signal phi_cmb : signed (N-1 downto 0);         --Combinatorial calculated triangle angle
signal phi_reg : signed (N-1 downto 0);         --Sequential calculated triangle angle
signal phi_step :  signed (20 downto 0);  --Step for the calculation of the current sawtooth angle.
signal freq_up_down_1 : std_ulogic_vector(1 downto 0);
signal freq_up_down_2 : std_ulogic_vector(1 downto 0);
signal freq_up_down_3 : std_ulogic_vector(1 downto 0);
signal sig_Freq_cmb : signed(20 downto 0);

begin
    
    --Registered Process--
    p_reg : process(reset_n,clk)
    begin
      if reset_n = '0' then
            phi_reg <= (others => '0');
            phi_noninv_reg <= (others => '0');
            sig_Freq <= to_signed(cordic_def_freq,21);
        elsif rising_edge(clk) then
            phi_reg <= phi_cmb;
            phi_noninv_reg <= phi_noninv_cmb;
            sig_Freq <= sig_Freq_cmb;
            freq_up_down_1 <= sig_freq_up_down;
            freq_up_down_2 <= freq_up_down_1;
            freq_up_down_3 <= freq_up_down_1 and not freq_up_down_2;
        end if;
    end process p_reg;

    --Combinatorial Process to calculate current sawtooth and triangle angle
    p_cmb_phicalc : process(all)
    variable phi_tmp1 : signed(20 downto 0) := (others => '0');
    variable phi_tmp2 : signed(20 downto 0) := (others => '0');
    begin
        phi_tmp1 := phi_noninv_reg + phi_step;
        
        if phi_tmp1(20 downto 19) = "01" or phi_tmp1(20 downto 19) = "10" then
            phi_tmp2 := phi_tmp1 xor invert;
            phi_cmb <= phi_tmp2(19 downto 19-N+1);
        else
            phi_cmb <= phi_tmp1(19 downto 19-N+1);
        end if;
        phi_noninv_cmb <= phi_tmp1;
    end process p_cmb_phicalc;

    --Combinatorial process to calibrate Sine frequency
    p_cmb_sig_freq : process(all)
    begin
        sig_Freq_cmb <= sig_Freq;
        if freq_up_down_3(1) = '1' then
            sig_Freq_cmb <= sig_Freq + to_signed(100,21);
        elsif freq_up_down_3(0) = '1' then
            sig_Freq_cmb <= sig_Freq - to_signed(100,21);
        end if;
    end process p_cmb_sig_freq;

    --Combinatorial Process to calculate current angle step size
    p_cmb_stepcalc : process(all)
        variable phi_step_tmp : signed(41 downto 0);
        variable phi_step_tmp2 : signed(20 downto 0);
    begin 
        phi_step_tmp := sig_Freq*clk_Period;
        phi_step <=  phi_step_tmp(41 downto 21);
    end process p_cmb_stepcalc;

    phi <= phi_reg;
    end architecture behavioral; 