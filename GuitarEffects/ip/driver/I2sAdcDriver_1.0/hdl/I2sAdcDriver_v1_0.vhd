library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2sAdcDriver_v1_0 is
	generic (
		-- Users to add parameters here
		AUDIO_DATA_WIDTH : integer := 24;
        INPUTCLOCK_FREQUENCY : integer := 122880e3;
        SAMPLE_RATE : integer := 96e3; -- Choosable between 32e3, 44.1e3, 48e3, 64e3, 88.2e3, 96e3
        MCLK_FACTOR : integer := 128; -- CHOSABLE between, 96, 192, 384 and 768
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
		AD_MCLK : out std_logic;
        AD_LRCK : out std_logic;
        AD_SCLK : out std_logic;
        AD_SDI : in std_logic;
        
        ReadDataxSI : in std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end I2sAdcDriver_v1_0;

architecture arch_imp of I2sAdcDriver_v1_0 is

	-- component declaration
	component I2sAdcDriver_v1_0_M00_AXIS is
		generic (
		AUDIO_DATA_WIDTH : integer := 24;
        INPUTCLOCK_FREQUENCY : integer := 122880e3;
        SAMPLE_RATE : integer := 96e3;
        MCLK_FACTOR : integer := 128;
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
		AD_MCLK : out std_logic;
        AD_LRCK : out std_logic;
        AD_SCLK : out std_logic;
        AD_SDI : in std_logic;
        ReadDataxSI : in std_logic;
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component I2sAdcDriver_v1_0_M00_AXIS;

begin

-- Instantiation of Axi Bus Interface M00_AXIS
I2sAdcDriver_v1_0_M00_AXIS_inst : I2sAdcDriver_v1_0_M00_AXIS
	generic map (
		AUDIO_DATA_WIDTH => AUDIO_DATA_WIDTH,
        INPUTCLOCK_FREQUENCY => INPUTCLOCK_FREQUENCY,
        SAMPLE_RATE => SAMPLE_RATE,
        MCLK_FACTOR => MCLK_FACTOR,
		C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
	)
	port map (
		AD_MCLK => AD_MCLK,
        AD_LRCK => AD_LRCK,
        AD_SCLK => AD_SCLK,
        AD_SDI => AD_SDI,
        ReadDataxSI => ReadDataxSI,
		M_AXIS_ACLK	=> m00_axis_aclk,
		M_AXIS_ARESETN	=> m00_axis_aresetn,
		M_AXIS_TVALID	=> m00_axis_tvalid,
		M_AXIS_TDATA	=> m00_axis_tdata,
		M_AXIS_TSTRB	=> m00_axis_tstrb,
		M_AXIS_TLAST	=> m00_axis_tlast,
		M_AXIS_TREADY	=> m00_axis_tready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
