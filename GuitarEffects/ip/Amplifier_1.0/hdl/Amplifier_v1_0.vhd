library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Amplifier_v1_0 is
	generic (
		-- Users to add parameters here
		AUDIO_DATA_WIDTH : integer := 24;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tstrb	: in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end Amplifier_v1_0;

architecture arch_imp of Amplifier_v1_0 is

	-- component declaration
	component Amplifier_v1_0_S00_AXIS is
		generic (
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
		ReadFifoxSI : in std_logic;
		FifoEmptyxSO : out std_logic;
		FifoDataValidxSO : out std_logic;
		FifoDataxDO : out std_logic_vector(C_S_AXIS_TDATA_WIDTH - 1 downto 0);
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component Amplifier_v1_0_S00_AXIS;

	component Amplifier_v1_0_M00_AXIS is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
		fifo_din         : in  std_logic_vector(31 downto 0);
        fifo_wr          : in  std_logic;
        fifo_wr_ack      : out std_logic;
        fifo_empty       : out std_logic;
        fifo_almost_full : out std_logic;
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component Amplifier_v1_0_M00_AXIS;

	component Amplifier_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		s_axi_mm_reg_0 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_mm_reg_1 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_mm_reg_2 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_mm_reg_3 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
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
	end component Amplifier_v1_0_S00_AXI;
	
	signal ReadFifoxS : std_logic;
	signal FifoInEmptyxS : std_logic;
	signal FifoOutEmptyxS : std_logic;
	signal FifoDataValidxS : std_logic;
	signal FifoWrAckxS : std_logic;
	signal FifoAlmostFullxS : std_logic;
	signal FifoDoutxD : std_logic;
	signal FifoDinxD : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal WriteFifoxS : std_logic;
	signal s_axi_mm_reg_0 : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0); --Right Channel Gain
	signal s_axi_mm_reg_1 : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0); --Left Channel Gain
	signal s_axi_mm_reg_2 : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal s_axi_mm_reg_3 : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	
	type AmplifierState is (STANDBY, GETDATA, CALCULATE, SENDDATA, WAIT_FOR_ACK);
	signal AmplifierStatexDP, AmplifierStatexDN : AmplifierState;
	signal PreparedDataxDP, PreparedDataxDN : signed(AUDIO_DATA_WIDTH - 1 downto 0);
	signal CalculatedDataxD : signed(AUDIO_DATA_WIDTH + GAIN_VECTOR_SIZE - 1 downto 0);
	signal LeftRigthBitxSP, LeftRigthBitxSN : std_logic;
	constant GAIN_VECTOR_SIZE : integer := 7;
	signal GainxS : signed(GAIN_VECTOR_SIZE - 1 downto 0);
begin

-- Instantiation of Axi Bus Interface S00_AXIS
Amplifier_v1_0_S00_AXIS_inst : Amplifier_v1_0_S00_AXIS
	generic map (
		C_S_AXIS_TDATA_WIDTH	=> C_S00_AXIS_TDATA_WIDTH
	)
	port map (
		ReadFifoxSI => ReadFifoxS,
		FifoEmptyxSO => FifoInEmptyxS,
		FifoDataValidxSO => FifoDataValidxS,
		FifoDataxDO => FifoDoutxD,
		S_AXIS_ACLK	=> s00_axis_aclk,
		S_AXIS_ARESETN	=> s00_axis_aresetn,
		S_AXIS_TREADY	=> s00_axis_tready,
		S_AXIS_TDATA	=> s00_axis_tdata,
		S_AXIS_TSTRB	=> s00_axis_tstrb,
		S_AXIS_TLAST	=> s00_axis_tlast,
		S_AXIS_TVALID	=> s00_axis_tvalid
	);

-- Instantiation of Axi Bus Interface M00_AXIS
Amplifier_v1_0_M00_AXIS_inst : Amplifier_v1_0_M00_AXIS
	generic map (
		C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
	)
	port map (
		fifo_din => FifoDinxD,
		fifo_wr => WriteFifoxS,
		fifo_wr_ack => FifoWrAckxS,
        fifo_empty => FifoOutEmptyxS,
        fifo_almost_full => FifoAlmostFullxS,
		M_AXIS_ACLK	=> m00_axis_aclk,
		M_AXIS_ARESETN	=> m00_axis_aresetn,
		M_AXIS_TVALID	=> m00_axis_tvalid,
		M_AXIS_TDATA	=> m00_axis_tdata,
		M_AXIS_TSTRB	=> m00_axis_tstrb,
		M_AXIS_TLAST	=> m00_axis_tlast,
		M_AXIS_TREADY	=> m00_axis_tready
	);

-- Instantiation of Axi Bus Interface S00_AXI
Amplifier_v1_0_S00_AXI_inst : Amplifier_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		s_axi_mm_reg_0 => s_axi_mm_reg_0,
		s_axi_mm_reg_1 => s_axi_mm_reg_1,
		s_axi_mm_reg_2 => s_axi_mm_reg_2,
		s_axi_mm_reg_3 => s_axi_mm_reg_3,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here
	PreparedDataxDN <= to_signed(FifoDoutxD(23 downto 0)) when FifoDataValidxS = '1' and AmplifierStatexDP = GETDDATA else PreparedDataxDP;
	
	LeftRigthBitxSN <= FifoDoutxD(24) when FifoDataValidxS = '1' and AmplifierStatexDP = GETDDATA else LeftRigthBitxSP;
	
	--GainxS <= "0" & s_axi_mm_reg_0(GAIN_VECTOR_SIZE -2 downto 0) when LeftRigthBitxSP = '1' else "0" & s_axi_mm_reg_1(GAIN_VECTOR_SIZE - 2 downto 0);
	GainxS <= "0011111";
	CalculatedDataxD <= GainxS * PreparedDataxDP;
	
	FifoDinxD <= (C_M00_AXIS_TDATA_WIDTH - GAIN_VECTOR_WITH - AUDIO_DATA_WIDTH - 2 downto 0 => '0') & LeftRigthBitxSP & CalculatedDataxD(AUDIO_DATA_WIDTH + GAIN_VECTOR_SIZE - 1 downto GAIN_VECTOR_SIZE);
	
	StateLogic : process(AmplifierStatexDP, FifoInEmptyxS, FifoAlmostFullxS, FifoDataValidxS, FifoWrAckxS)
	begin
		case AmplifierStatexDP is 
			when STANDBY =>
				WriteFifoxS <= '0';
				if(FifoInEmptyxS = '0') then
					AmplifierStatexDN <= GETDATA;
					ReadFifoxS <= '1';
				else
					AmplifierStatexDN <= STANDBY;
					ReadFifoxS <= '0';
				end if;
			when GETDATA =>
				WriteFifoxS <= '0';
				if(FifoDataValidxS = '1') then
					ReadFifoxS <= '0';
					AmplifierStatexDN <= CALCULATE;
				else
					AmplifierStatexDN <= GETDATA;
					ReadFifoxS <= '1';
				end if;
			when CALCULATE =>
				WriteFifoxS <= '0';
				ReadFifoxS <= '0';
				AmplifierStatexDN <= SENDDATA;
			when SENDDATA =>
				ReadFifoxS <= '0';
				if(FifoAlmostFullxS = '1') then
					AmplifierStatexDN <= SENDDATA;
					WriteFifoxS <= '0';
				else
					AmplifierStatexDN <= WAIT_FOR_ACK;
					WriteFifoxS <= '1';
				end if;
			when WAIT_FOR_ACK =>
				ReadFifoxS <= '0';
				if(FifoWrAckxS = '1') then
					AmplifierStatexDN <= STANDBY;
					WriteFifoxS <= '0';
				else
					AmplifierStatexDN <= WAIT_FOR_ACK;
					WriteFifoxS <= '1';
				end if;
		end case;
	end process;
	
	RegisterLogic : process(s00_axis_aclk, s00_axis_aresetn)
	begin
		if(s00_axis_aresetn = '0') then
			PreparedDataxDP <= (others => '0');
			AmplifierStatexDP <= STANDBY;
			LeftRigthBitxSP <= '0';
		elsif(rising_edge(s00_axis_aclk)) then
			PreparedDataxDP <= PreparedDataxDN;
			AmplifierStatexDP <= AmplifierStatexDN;
			LeftRigthBitxSP <= LeftRigthBitxSN;
		end if;
	end process;
	-- User logic ends

end arch_imp;
