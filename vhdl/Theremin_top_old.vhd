-----------------------------------------------------
-- Project : Digital Theremin
-----------------------------------------------------
-- File    : Theremin_top.vhd
-- Author  : andreas.frei@students.fhnw.ch
-----------------------------------------------------
-- Description : Top Theremin 
-----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Theremin_top is
  port( 
    clk_48            : in  std_ulogic;
    square_freq       : in  std_ulogic; 
    key               : in  std_ulogic_vector (3 downto 0);
    audio_codec       : out signed(31 downto 0)
  );
end entity Theremin_top;

architecture struct of Theremin_top is
  -- Architecture declarations
  constant N      : natural := 16;
  constant stages : natural := 3;
  constant cordic_def_freq :natural := 500000;
  -- Internal signal declarations:
  signal clk                  : std_ulogic;
  signal reset_n              : std_ulogic;
  signal square_freq_s        : std_ulogic;
  signal sine                 : signed(N-1 downto 0);
  signal phi                  : signed(N-1 downto 0);
  signal sig_freq_up_down     : std_ulogic_vector(1 downto 0);
  signal key_pulse            : std_ulogic_vector(key'range);
  signal mixer_out            : signed(N-1 downto 0);
  signal audio_out            : signed(31 downto 0);
  
begin
-- Wrapping between de1_soc and Theremin
  -- system clock:
  clk              <= clk_48;
  -- key:
  sig_freq_up_down <= key_pulse(3 downto 2);        -- up/down
  -- output:
  audio_codec      <= audio_out;
  
-- synchronize the reset
  rsync_1 : entity work.rsync
    generic map (
      g_mode => 0
    )
    port map (
      clk    => clk,
      irst_n => key(0),
      orst_n => reset_n,
      orst   => open
    );
  -- edge detection of the keys
  isync_2 : entity work.isync
    generic map (
      g_width => key'length,
      g_inv   => 0,
      g_mode  => 2 -- generate pulse on falling edge
    )
    port map (
      clk     => clk,
      rst_n   => reset_n,
      idata_a => key,
      odata_s => key_pulse
    ); 
  -- user design: mixer
  mixer_1 : entity work.mixer
    port map (
      clk         => clk,
      reset_n     => reset_n,
      square_freq => square_freq,
      sine        => sine,
      mixer_out   => mixer_out
    ); 

  -- user design: cordic_pipelinded
  cordic_pipelined_1 : entity work.cordic_pipelined
    generic map (
      N => N,
      stages => stages
    )
    port map (
      clk         => clk,
      reset_n     => reset_n,
      phi         => phi,
      sine        => sine
    ); 

  -- user design: cordic_control
  cordic_Control_1 : entity work.cordic_Control
    generic map (
      N => N,
      cordic_def_freq => cordic_def_freq
    )
    port map (
      clk         => clk,
      reset_n     => reset_n,
      phi         => phi,
      sig_freq_up_down => sig_freq_up_down
    ); 

  -- user design: cic
  cic_1 : entity work.cic
    generic map (
      N => N
    )
    port map (
      clk         => clk,
      reset_n     => reset_n,
      mixer_out   => mixer_out,
      audio_out   => audio_out
    ); 
  
end architecture struct;
