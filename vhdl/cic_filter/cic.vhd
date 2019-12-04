--=========================================================
--Filename:  cic.vhd
--Designer:  Andreas Frei
--Date    :  27.11.2019
--Content :  CIC decimators Filter
--=========================================================
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity cic is
	generic (
	 N : natural := 16	--Number of Bits of the sine wave (precision)
	);
  	port (
  	 reset_n  	    : in  std_ulogic; -- asynchronous reset
     clk      	    : in  std_ulogic; -- clock
     mixer_out 	    : in signed(N-1 downto 0);
     audio_out      : out signed(N+9 downto 0)
  );
end entity cic;

architecture rtl of cic is
  constant rc_factor : natural := 1000; --Rate Change Factor
  -- Internal signals:
  signal integrator_reg       : signed(N+9 downto 0);
  signal integrator_cmb       : signed(N+9 downto 0);
  signal comb_in_reg          : signed(N+9 downto 0);
  signal comb_old_reg         : signed(N+9 downto 0);
  signal comb_reg             : signed(N+9 downto 0);
  signal comb_cmb             : signed(N+9 downto 0);
  signal en_comb              : boolean := false;
  signal count_reg            : integer range 0 to 1000;
  signal count_cmb            : integer range 0 to 1001;

begin
  ------------------------------------------------------------------------------
  -- Integrator Registerd Process 
  ------------------------------------------------------------------------------
  p_integrator_reg : process (reset_n, clk)
  begin
    if reset_n = '0' then
      integrator_reg <= (others => '0');
    elsif rising_edge(clk) then
        integrator_reg <= integrator_cmb; 
    end if;
  end process p_integrator_reg;
  ------------------------------------------------------------------------------
  -- Integrator Combinatorial Process
  -----------------------------------------------------------------------------
  p_integrator_cmb : process (all)
  begin
    integrator_cmb <= integrator_reg + resize(mixer_out,integrator_reg'length);
  end process p_integrator_cmb;

  ------------------------------------------------------------------------------
  -- Comb Registerd Process 
  ------------------------------------------------------------------------------
  p_comb_reg : process (reset_n, clk)
  begin
    if reset_n = '0' then
      comb_reg <= (others => '0');
      comb_in_reg <= (others =>'0');
      comb_old_reg <= (others => '0');
      count_reg <= 0;
      en_comb <= false;
    elsif rising_edge(clk) then
        if count_reg < rc_factor then --1- rausgenommen
          count_reg <= count_cmb; --counter
          en_comb <= false;
        else
          en_comb <= true;
          count_reg <= 0;
        end if;
        if en_comb = true then   --comb
          comb_reg <= comb_cmb;
          comb_in_reg <= integrator_reg;
          comb_old_reg <= comb_in_reg;
        end if;
    end if;
  end process p_comb_reg;
  ------------------------------------------------------------------------------
  -- Comb Combinatorial Process
  ------------------------------------------------------------------------------
  p_comb_cmb : process (all)
  begin
    comb_cmb <= comb_in_reg - comb_old_reg;
    count_cmb <= count_reg + 1;
  end process p_comb_cmb;

  ------------------------------------------------------------------------------
  -- Output Assignments
  ------------------------------------------------------------------------------
  audio_out <= comb_reg;

end rtl;