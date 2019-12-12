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
    clk               : in  std_ulogic;
    square_freq       : in  std_ulogic; 
    key               : in  std_ulogic_vector (3 downto 0);
    I2C_SDAT          : inout std_logic;            
    I2C_SCLK          : out   std_logic;
    AUD_BCLK          : in  std_logic;            
    AUD_DACDAT        : out std_logic;                                    
    AUD_DACLRCK       : in  std_logic                                           
  );
end entity Theremin_top;

architecture struct of Theremin_top is
  -- Architecture declarations
  constant N      : natural := 16;
  constant stages : natural := 3;
  constant cordic_def_freq :natural := 500000;
  -- Internal signal declarations:
  signal clk_48               : std_ulogic;
  signal reset_n              : std_ulogic;
  signal square_freq_s        : std_ulogic;
  signal sine                 : signed(N-1 downto 0);
  signal phi                  : signed(N-1 downto 0);
  signal sig_freq_up_down     : std_ulogic_vector(1 downto 0);
  signal key_pulse            : std_ulogic_vector(key'range);
  signal mixer_out            : signed(N-1 downto 0);

  signal audio_out            : std_logic_vector(31 downto 0);
  signal audio_clk_clk        : std_logic; 
  signal reset_audio          : std_logic;
  signal valid_L              : std_logic;
  signal valid_R              : std_logic;
  signal ready_L              : std_logic;
  signal ready_R              : std_logic;


--PLL ip
component PLL_ip 
  port (
    refclk   : in  std_logic; --  refclk.clk
    rst      : in  std_logic; --   reset.reset
    outclk_0 : out std_logic;        -- outclk0.clk
    locked   : out std_logic         --  locked.export
  );
end component PLL_ip;

--Audio clock ip
component Audio_clock is
  port (
    ref_clk_clk        : in  std_logic; -- clk
    ref_reset_reset    : in  std_logic; -- reset
    audio_clk_clk      : out std_logic; -- clk
    reset_source_reset : out std_logic  -- reset
  );
end component Audio_clock;

--Audio ip
component Audio is
  port (
    clk                          : in  std_logic                     := 'X';             -- clk
    reset                        : in  std_logic                     := 'X';             -- reset
    AUD_BCLK                     : in  std_logic                     := 'X';             -- BCLK
    AUD_DACDAT                   : out std_logic;                                        -- DACDAT
    AUD_DACLRCK                  : in  std_logic                     := 'X';             -- DACLRCK
    to_dac_left_channel_data     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
    to_dac_left_channel_valid    : in  std_logic                     := 'X';             -- valid
    to_dac_left_channel_ready    : out std_logic;                                        -- ready
    to_dac_right_channel_data    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
    to_dac_right_channel_valid   : in  std_logic                     := 'X';             -- valid
    to_dac_right_channel_ready   : out std_logic                                         -- ready
  );
end component Audio;

component Audio_config is
  port (
    clk         : in    std_logic                     := 'X';             -- clk
    reset       : in    std_logic                     := 'X';             -- reset
    address     : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- address
    byteenable  : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
    read        : in    std_logic                     := 'X';             -- read
    write       : in    std_logic                     := 'X';             -- write
    writedata   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
    readdata    : out   std_logic_vector(31 downto 0);                    -- readdata
    waitrequest : out   std_logic;                                        -- waitrequest
    I2C_SDAT    : inout std_logic                     := 'X';             -- SDAT
    I2C_SCLK    : out   std_logic                                         -- SCLK
  );
end component Audio_config;

begin
-- Wrapping between de1_soc and Theremin
  -- key:
  sig_freq_up_down <= key_pulse(3 downto 2);        -- up/down


-- synchronize the reset
  rsync_1 : entity work.rsync
    generic map (
      g_mode => 0
    )
    port map (
      clk    => clk_48,
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
      clk     => clk_48,
      rst_n   => reset_n,
      idata_a => key,
      odata_s => key_pulse
    );


  pll_ip_1 : PLL_ip
    port map (
      refclk   => clk,   --  refclk.clk
      rst      => reset_n,      --   reset.reset
      outclk_0 => clk_48, -- outclk0.clk
      locked   => open
    ); 

  audio_clock_ip_1 : Audio_clock
    port map (
      ref_clk_clk        => clk,        --      ref_clk.clk
      ref_reset_reset    => reset_n,    --    ref_reset.reset
      audio_clk_clk      => audio_clk_clk,      --    audio_clk.clk
      reset_source_reset => reset_audio  -- reset_source.reset
    );

  audio_ip_1 : Audio
    port map (
      clk                          => audio_clk_clk,                          --                         clk.clk
      reset                        => reset_audio,                        --                       reset.reset
      AUD_BCLK                     => AUD_BCLK,                     --          external_interface.BCLK
      AUD_DACDAT                   => AUD_DACDAT,                   --                            .DACDAT
      AUD_DACLRCK                  => AUD_DACLRCK,                  --                            .DACLRCK
 --     from_adc_left_channel_ready  => open,  --  avalon_left_channel_source.ready
 --     from_adc_left_channel_data   => open,   --                            .data
 --     from_adc_left_channel_valid  => open,  --                            .valid
 --     from_adc_right_channel_ready => open, -- avalon_right_channel_source.ready
 --     from_adc_right_channel_data  => open,  --                            .data
 --     from_adc_right_channel_valid => open, --                            .valid
      to_dac_left_channel_data     => audio_out,     --    avalon_left_channel_sink.data
      to_dac_left_channel_valid    => valid_L,    --                            .valid
      to_dac_left_channel_ready    => ready_L,    --                            .ready
      to_dac_right_channel_data    => audio_out,    --   avalon_right_channel_sink.data
      to_dac_right_channel_valid   => valid_R,   --                            .valid
      to_dac_right_channel_ready   => ready_R    --                            .ready
    );
  
  audio_config_1 : Audio_config
    port map (
      clk         => audio_clk_clk,      
      reset       => reset_audio,       
      address     => open,     
      byteenable  => open,  
      read        => open,       
      write       => open,   
      writedata   => open,   
      readdata    => open,    
      waitrequest => open, 
      I2C_SDAT    => I2C_SDAT,    --     external_interface.SDAT
      I2C_SCLK    => I2C_SCLK     --                       .SCLK
    );

  -- user design: mixer
  mixer_1 : entity work.mixer
    port map (
      clk         => clk_48,
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
      clk         => clk_48,
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
      clk         => clk_48,
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
      clk         => clk_48,
      reset_n     => reset_n,
      mixer_out   => mixer_out,
      valid_R     => valid_R,
      valid_L     => valid_L,
      ready_R     => ready_R,
      ready_L     => ready_L,
      audio_out   => audio_out
    ); 
  
end architecture struct;
