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
     clk_12         : in std_logic;
     reset_12     : in std_logic;
     mixer_out 	    : in signed(N-1 downto 0);
     audio_out      : out std_logic_vector(31 downto 0);
     valid_L        : out std_logic;
     ready_L        : in std_logic;
     valid_R        : out std_logic;
     ready_R        : in std_logic
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
  signal audio_cmb            : std_logic_vector(31 downto 0);
  signal audio_reg            : std_logic_vector(31 downto 0);
  signal valid_L_int          : std_ulogic;
  signal valid_R_int          : std_ulogic;
  signal valid_L_sync         : std_ulogic_vector(1 downto 0);
  signal valid_R_sync         : std_ulogic_vector(1 downto 0);
  signal valid_L_sync_int     : std_ulogic_vector(1 downto 0);
  signal valid_R_sync_int     : std_ulogic_vector(1 downto 0);
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

  p_clk_change : process (reset_12,clk_12)
  begin
    valid_L_sync <= valid_L_sync(0) & valid_L_int;
    valid_R_sync <= valid_R_sync(0) & valid_R_int;
    if reset_12 = '1' then
      valid_L <= '0';
      valid_R <= '0';
    elsif rising_edge(clk_12) then
      valid_L <= '0';
      if valid_L_sync(1) = '1' then
        valid_L <= '1';
      end if;
      valid_R <= '0';
      if valid_R_sync(1) = '1' then
        valid_R <= '1';
      end if;
    end if;
  end process p_clk_change;
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
          audio_reg <= audio_cmb;
          count_reg <= 0;
        end if;
        if en_comb = true then   --comb
          comb_reg <= comb_cmb;
          comb_in_reg <= integrator_reg;
          comb_old_reg <= comb_in_reg;
        end if;
        valid_L_sync_int <= valid_L_sync_int(0) & valid_L;
        valid_R_sync_int <= valid_R_sync_int(0) & valid_R;
        if ready_L = '1' and en_comb = true then
          valid_L_int <= '1';
        end if;
        if ready_R = '1' and en_comb = true then
          valid_R_int <= '1';
        end if;

        if valid_L_sync_int(1) = '1' then
          valid_L_int <= '0';
        end if;
        if valid_R_sync_int(1) = '1' then
          valid_R_int <= '0';
        end if;
    end if;
  end process p_comb_reg;
  ------------------------------------------------------------------------------
  -- Comb Combinatorial Process
  ------------------------------------------------------------------------------
  p_comb_cmb : process (all)
  variable audio_tmp : std_logic_vector(31 downto 0);
  begin
    comb_cmb <= comb_in_reg - comb_old_reg;
    count_cmb <= count_reg + 1;
    audio_tmp := std_logic_vector(comb_reg & "000000");
    audio_tmp(audio_tmp'high) := not audio_tmp(audio_tmp'high);
    audio_cmb <= audio_tmp;
  end process p_comb_cmb;

  ------------------------------------------------------------------------------
  -- Output Assignments
  ------------------------------------------------------------------------------
  audio_out <= audio_reg;

end rtl;