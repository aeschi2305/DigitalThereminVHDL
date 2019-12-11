-- Audio_config.vhd

-- Generated using ACDS version 17.1 590

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Audio_config is
	port (
		address     : in    std_logic_vector(1 downto 0)  := (others => '0'); -- avalon_av_config_slave.address
		byteenable  : in    std_logic_vector(3 downto 0)  := (others => '0'); --                       .byteenable
		read        : in    std_logic                     := '0';             --                       .read
		write       : in    std_logic                     := '0';             --                       .write
		writedata   : in    std_logic_vector(31 downto 0) := (others => '0'); --                       .writedata
		readdata    : out   std_logic_vector(31 downto 0);                    --                       .readdata
		waitrequest : out   std_logic;                                        --                       .waitrequest
		clk         : in    std_logic                     := '0';             --                    clk.clk
		I2C_SDAT    : inout std_logic                     := '0';             --     external_interface.SDAT
		I2C_SCLK    : out   std_logic;                                        --                       .SCLK
		reset       : in    std_logic                     := '0'              --                  reset.reset
	);
end entity Audio_config;

architecture rtl of Audio_config is
	component Audio_config_audio_and_video_config_0 is
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
			I2C_SDAT    : inout std_logic                     := 'X';             -- export
			I2C_SCLK    : out   std_logic                                         -- export
		);
	end component Audio_config_audio_and_video_config_0;

begin

	audio_and_video_config_0 : component Audio_config_audio_and_video_config_0
		port map (
			clk         => clk,         --                    clk.clk
			reset       => reset,       --                  reset.reset
			address     => address,     -- avalon_av_config_slave.address
			byteenable  => byteenable,  --                       .byteenable
			read        => read,        --                       .read
			write       => write,       --                       .write
			writedata   => writedata,   --                       .writedata
			readdata    => readdata,    --                       .readdata
			waitrequest => waitrequest, --                       .waitrequest
			I2C_SDAT    => I2C_SDAT,    --     external_interface.export
			I2C_SCLK    => I2C_SCLK     --                       .export
		);

end architecture rtl; -- of Audio_config