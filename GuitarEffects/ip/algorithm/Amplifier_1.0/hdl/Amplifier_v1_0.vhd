library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Amplifier_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AUDIO_AXIS
		C_S_AUDIO_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M_AUDIO_AXIS
		C_M_AUDIO_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_AUDIO_AXIS_START_COUNT	: integer	:= 32;

		-- Parameters of Axi Slave Bus Interface S_SETTING_AXI
		C_S_SETTING_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_SETTING_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_AUDIO_AXIS
		s_audio_axis_aclk	: in std_logic;
		s_audio_axis_aresetn	: in std_logic;
		s_audio_axis_tready	: out std_logic;
		s_audio_axis_tdata	: in std_logic_vector(C_S_AUDIO_AXIS_TDATA_WIDTH-1 downto 0);
		s_audio_axis_tstrb	: in std_logic_vector((C_S_AUDIO_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s_audio_axis_tlast	: in std_logic;
		s_audio_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M_AUDIO_AXIS
		m_audio_axis_aclk	: in std_logic;
		m_audio_axis_aresetn	: in std_logic;
		m_audio_axis_tvalid	: out std_logic;
		m_audio_axis_tdata	: out std_logic_vector(C_M_AUDIO_AXIS_TDATA_WIDTH-1 downto 0);
		m_audio_axis_tstrb	: out std_logic_vector((C_M_AUDIO_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m_audio_axis_tlast	: out std_logic;
		m_audio_axis_tready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S_SETTING_AXI
		s_setting_axi_aclk	: in std_logic;
		s_setting_axi_aresetn	: in std_logic;
		s_setting_axi_awaddr	: in std_logic_vector(C_S_SETTING_AXI_ADDR_WIDTH-1 downto 0);
		s_setting_axi_awprot	: in std_logic_vector(2 downto 0);
		s_setting_axi_awvalid	: in std_logic;
		s_setting_axi_awready	: out std_logic;
		s_setting_axi_wdata	: in std_logic_vector(C_S_SETTING_AXI_DATA_WIDTH-1 downto 0);
		s_setting_axi_wstrb	: in std_logic_vector((C_S_SETTING_AXI_DATA_WIDTH/8)-1 downto 0);
		s_setting_axi_wvalid	: in std_logic;
		s_setting_axi_wready	: out std_logic;
		s_setting_axi_bresp	: out std_logic_vector(1 downto 0);
		s_setting_axi_bvalid	: out std_logic;
		s_setting_axi_bready	: in std_logic;
		s_setting_axi_araddr	: in std_logic_vector(C_S_SETTING_AXI_ADDR_WIDTH-1 downto 0);
		s_setting_axi_arprot	: in std_logic_vector(2 downto 0);
		s_setting_axi_arvalid	: in std_logic;
		s_setting_axi_arready	: out std_logic;
		s_setting_axi_rdata	: out std_logic_vector(C_S_SETTING_AXI_DATA_WIDTH-1 downto 0);
		s_setting_axi_rresp	: out std_logic_vector(1 downto 0);
		s_setting_axi_rvalid	: out std_logic;
		s_setting_axi_rready	: in std_logic
	);
end Amplifier_v1_0;

architecture arch_imp of Amplifier_v1_0 is

	-- component declaration
	component Amplifier_v1_0_S_AUDIO_AXIS is
		generic (
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component Amplifier_v1_0_S_AUDIO_AXIS;

	component Amplifier_v1_0_M_AUDIO_AXIS is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component Amplifier_v1_0_M_AUDIO_AXIS;

	component Amplifier_v1_0_S_SETTING_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component Amplifier_v1_0_S_SETTING_AXI;

begin

-- Instantiation of Axi Bus Interface S_AUDIO_AXIS
Amplifier_v1_0_S_AUDIO_AXIS_inst : Amplifier_v1_0_S_AUDIO_AXIS
	generic map (
		C_S_AXIS_TDATA_WIDTH	=> C_S_AUDIO_AXIS_TDATA_WIDTH
	)
	port map (
		S_AXIS_ACLK	=> s_audio_axis_aclk,
		S_AXIS_ARESETN	=> s_audio_axis_aresetn,
		S_AXIS_TREADY	=> s_audio_axis_tready,
		S_AXIS_TDATA	=> s_audio_axis_tdata,
		S_AXIS_TSTRB	=> s_audio_axis_tstrb,
		S_AXIS_TLAST	=> s_audio_axis_tlast,
		S_AXIS_TVALID	=> s_audio_axis_tvalid
	);

-- Instantiation of Axi Bus Interface M_AUDIO_AXIS
Amplifier_v1_0_M_AUDIO_AXIS_inst : Amplifier_v1_0_M_AUDIO_AXIS
	generic map (
		C_M_AXIS_TDATA_WIDTH	=> C_M_AUDIO_AXIS_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M_AUDIO_AXIS_START_COUNT
	)
	port map (
		M_AXIS_ACLK	=> m_audio_axis_aclk,
		M_AXIS_ARESETN	=> m_audio_axis_aresetn,
		M_AXIS_TVALID	=> m_audio_axis_tvalid,
		M_AXIS_TDATA	=> m_audio_axis_tdata,
		M_AXIS_TSTRB	=> m_audio_axis_tstrb,
		M_AXIS_TLAST	=> m_audio_axis_tlast,
		M_AXIS_TREADY	=> m_audio_axis_tready
	);

-- Instantiation of Axi Bus Interface S_SETTING_AXI
Amplifier_v1_0_S_SETTING_AXI_inst : Amplifier_v1_0_S_SETTING_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_SETTING_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_SETTING_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s_setting_axi_aclk,
		S_AXI_ARESETN	=> s_setting_axi_aresetn,
		S_AXI_AWADDR	=> s_setting_axi_awaddr,
		S_AXI_AWPROT	=> s_setting_axi_awprot,
		S_AXI_AWVALID	=> s_setting_axi_awvalid,
		S_AXI_AWREADY	=> s_setting_axi_awready,
		S_AXI_WDATA	=> s_setting_axi_wdata,
		S_AXI_WSTRB	=> s_setting_axi_wstrb,
		S_AXI_WVALID	=> s_setting_axi_wvalid,
		S_AXI_WREADY	=> s_setting_axi_wready,
		S_AXI_BRESP	=> s_setting_axi_bresp,
		S_AXI_BVALID	=> s_setting_axi_bvalid,
		S_AXI_BREADY	=> s_setting_axi_bready,
		S_AXI_ARADDR	=> s_setting_axi_araddr,
		S_AXI_ARPROT	=> s_setting_axi_arprot,
		S_AXI_ARVALID	=> s_setting_axi_arvalid,
		S_AXI_ARREADY	=> s_setting_axi_arready,
		S_AXI_RDATA	=> s_setting_axi_rdata,
		S_AXI_RRESP	=> s_setting_axi_rresp,
		S_AXI_RVALID	=> s_setting_axi_rvalid,
		S_AXI_RREADY	=> s_setting_axi_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
