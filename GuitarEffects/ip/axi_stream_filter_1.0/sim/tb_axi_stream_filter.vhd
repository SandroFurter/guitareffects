library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_axi_stream_filter is
end entity tb_axi_stream_filter;

architecture RTL of tb_axi_stream_filter is
    COMPONENT axi_traffic_gen_0_1
        PORT(
            s_axi_aclk      : IN  STD_LOGIC;
            s_axi_aresetn   : IN  STD_LOGIC;
            core_ext_start  : IN  STD_LOGIC;
            core_ext_stop   : IN  STD_LOGIC;
            s_axi_awaddr    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axi_awlen     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            s_axi_awsize    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            s_axi_awburst   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            s_axi_awlock    : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
            s_axi_awcache   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axi_awprot    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            s_axi_awqos     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axi_awvalid   : IN  STD_LOGIC;
            s_axi_wlast     : IN  STD_LOGIC;
            s_axi_wdata     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axi_wstrb     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axi_wvalid    : IN  STD_LOGIC;
            s_axi_bready    : IN  STD_LOGIC;
            s_axi_araddr    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axi_arlen     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            s_axi_arsize    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            s_axi_arburst   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            s_axi_arlock    : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
            s_axi_arcache   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axi_arprot    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            s_axi_arqos     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axi_arvalid   : IN  STD_LOGIC;
            s_axi_rready    : IN  STD_LOGIC;
            m_axis_1_tready : IN  STD_LOGIC;
            m_axis_1_tvalid : OUT STD_LOGIC;
            m_axis_1_tlast  : OUT STD_LOGIC;
            m_axis_1_tdata  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_1_tstrb  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            m_axis_1_tkeep  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            m_axis_1_tuser  : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            m_axis_1_tid    : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            m_axis_1_tdest  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            s_axis_1_tready : OUT STD_LOGIC;
            s_axis_1_tvalid : IN  STD_LOGIC;
            s_axis_1_tlast  : IN  STD_LOGIC;
            s_axis_1_tdata  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axis_1_tstrb  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axis_1_tkeep  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axis_1_tuser  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
            s_axis_1_tid    : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
            s_axis_1_tdest  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            axis_err_count  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            err_out         : OUT STD_LOGIC
        );
    END COMPONENT;

    component axi_stream_filter_v1_0
        generic(
            C_S00_AXI_MM_DATA_WIDTH : integer;
            C_S00_AXI_MM_ADDR_WIDTH : integer
        );
        port(
            s00_axi_stream_aclk    : in  std_logic;
            s00_axi_stream_aresetn : in  std_logic;
            s00_axi_stream_tready  : out std_logic;
            s00_axi_stream_tdata   : in  std_logic_vector(31 downto 0);
            s00_axi_stream_tlast   : in  std_logic;
            s00_axi_stream_tvalid  : in  std_logic;
            m00_axi_stream_aclk    : in  std_logic;
            m00_axi_stream_aresetn : in  std_logic;
            m00_axi_stream_tvalid  : out std_logic;
            m00_axi_stream_tdata   : out std_logic_vector(31 downto 0);
            m00_axi_stream_tlast   : out std_logic;
            m00_axi_stream_tready  : in  std_logic;
            s00_axi_mm_aclk        : in  std_logic;
            s00_axi_mm_aresetn     : in  std_logic;
            s00_axi_mm_awaddr      : in  std_logic_vector(C_S00_AXI_MM_ADDR_WIDTH - 1 downto 0);
            s00_axi_mm_awvalid     : in  std_logic;
            s00_axi_mm_awready     : out std_logic;
            s00_axi_mm_wdata       : in  std_logic_vector(C_S00_AXI_MM_DATA_WIDTH - 1 downto 0);
            s00_axi_mm_wstrb       : in  std_logic_vector((C_S00_AXI_MM_DATA_WIDTH / 8) - 1 downto 0);
            s00_axi_mm_wvalid      : in  std_logic;
            s00_axi_mm_wready      : out std_logic;
            s00_axi_mm_bresp       : out std_logic_vector(1 downto 0);
            s00_axi_mm_bvalid      : out std_logic;
            s00_axi_mm_bready      : in  std_logic;
            s00_axi_mm_araddr      : in  std_logic_vector(C_S00_AXI_MM_ADDR_WIDTH - 1 downto 0);
            s00_axi_mm_arvalid     : in  std_logic;
            s00_axi_mm_arready     : out std_logic;
            s00_axi_mm_rdata       : out std_logic_vector(C_S00_AXI_MM_DATA_WIDTH - 1 downto 0);
            s00_axi_mm_rresp       : out std_logic_vector(1 downto 0);
            s00_axi_mm_rvalid      : out std_logic;
            s00_axi_mm_rready      : in  std_logic
        );
    end component axi_stream_filter_v1_0;

    constant C_S00_AXI_MM_ADDR_WIDTH : integer := 4;
    constant C_S00_AXI_MM_DATA_WIDTH : integer := 32;

    signal s_axi_aclk     : std_logic := '0';
    signal s_axi_aresetn  : std_logic := '0';
    signal core_ext_start : STD_LOGIC;
    signal core_ext_stop  : STD_LOGIC;

    signal m_axis_1_tready : STD_LOGIC;
    signal m_axis_1_tvalid : STD_LOGIC;
    signal m_axis_1_tlast  : STD_LOGIC;
    signal m_axis_1_tdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);

    signal s_axis_1_tready : STD_LOGIC;
    signal s_axis_1_tvalid : STD_LOGIC;
    signal s_axis_1_tlast  : STD_LOGIC;
    signal s_axis_1_tdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);

    signal axis_err_count : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal err_out        : STD_LOGIC;

    signal s00_axi_stream_tready  : std_logic                                                    := '0';
    signal s00_axi_stream_tdata   : std_logic_vector(31 downto 0)                                := (others => '0');
    signal s00_axi_stream_tlast   : std_logic                                                    := '0';
    signal s00_axi_stream_tvalid  : std_logic                                                    := '0';
                                          
    signal m00_axi_stream_tvalid  : std_logic                                                    := '0';
    signal m00_axi_stream_tdata   : std_logic_vector(31 downto 0)                                := (others => '0');
    signal m00_axi_stream_tlast   : std_logic                                                    := '0';
    signal m00_axi_stream_tready  : std_logic                                                    := '0';

    signal s00_axi_mm_awaddr      : std_logic_vector(C_S00_AXI_MM_ADDR_WIDTH - 1 downto 0)       := (others => '0');
    signal s00_axi_mm_awvalid     : std_logic                                                    := '0';
    signal s00_axi_mm_awready     : std_logic                                                    := '0';
    signal s00_axi_mm_wdata       : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH - 1 downto 0)       := (others => '0');
    signal s00_axi_mm_wstrb       : std_logic_vector((C_S00_AXI_MM_DATA_WIDTH / 8) - 1 downto 0) := (others => '0');
    signal s00_axi_mm_wvalid      : std_logic                                                    := '0';
    signal s00_axi_mm_wready      : std_logic                                                    := '0';
    signal s00_axi_mm_bresp       : std_logic_vector(1 downto 0)                                 := (others => '0');
    signal s00_axi_mm_bvalid      : std_logic                                                    := '0';
    signal s00_axi_mm_bready      : std_logic                                                    := '0';
    signal s00_axi_mm_araddr      : std_logic_vector(C_S00_AXI_MM_ADDR_WIDTH - 1 downto 0)       := (others => '0');
    signal s00_axi_mm_arvalid     : std_logic                                                    := '0';
    signal s00_axi_mm_arready     : std_logic                                                    := '0';
    signal s00_axi_mm_rdata       : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH - 1 downto 0)       := (others => '0');
    signal s00_axi_mm_rresp       : std_logic_vector(1 downto 0)                                 := (others => '0');
    signal s00_axi_mm_rvalid      : std_logic                                                    := '0';
    signal s00_axi_mm_rready      : std_logic                                                    := '0';

begin

    s_axi_aclk <= not s_axi_aclk after 10 ns;

    rst : process
    begin
        -- issue reset async
        s_axi_aresetn <= '0';
        wait for 1 us;
        -- set synchrounous
        wait until rising_edge(s_axi_aclk);
        s_axi_aresetn <= '1';
        wait;
    end process rst;

    i_stimuli : process
    begin
        core_ext_start <= '0';
        wait for 10 us;
        wait until rising_edge(s_axi_aclk);
        core_ext_start <= '1';
        wait until rising_edge(s_axi_aclk);
        core_ext_start <= '0';

        wait for 20 us;

        wait until rising_edge(s_axi_aclk);
        core_ext_stop <= '1';
        wait until rising_edge(s_axi_aclk);
        core_ext_stop <= '0';
        wait;
    end process i_stimuli;

    i_checker : component axi_traffic_gen_0_1
        port map(
            s_axi_awprot => (others => '0'),
            s_axi_arprot => (others => '0'),
            s_axi_aclk      => s_axi_aclk,
            s_axi_aresetn   => s_axi_aresetn,
            core_ext_start  => core_ext_start,
            core_ext_stop   => core_ext_stop,
            s_axi_awaddr    => (others => '0'),
            s_axi_awlen     => (others => '0'),
            s_axi_awsize    => (others => '0'),
            s_axi_awburst   => (others => '0'),
            s_axi_awlock    => (others => '0'),
            s_axi_awcache   => (others => '0'),
            s_axi_awqos     => (others => '0'),
            s_axi_awvalid   => '0',
            s_axi_wlast     => '0',
            s_axi_wdata     => (others => '0'),
            s_axi_wstrb     => (others => '0'),
            s_axi_wvalid    => '0',
            s_axi_bready    => '0',
            s_axi_araddr    => (others => '0'),
            s_axi_arlen     => (others => '0'),
            s_axi_arsize    => (others => '0'),
            s_axi_arburst   => (others => '0'),
            s_axi_arlock    => (others => '0'),
            s_axi_arcache   => (others => '0'),
            s_axi_arqos     => (others => '0'),
            s_axi_arvalid   => '0',
            s_axi_rready    => '0',
            m_axis_1_tready => m_axis_1_tready,
            m_axis_1_tvalid => m_axis_1_tvalid,
            m_axis_1_tlast  => m_axis_1_tlast,
            m_axis_1_tdata  => m_axis_1_tdata,
            m_axis_1_tstrb  => open,
            m_axis_1_tkeep  => open,
            m_axis_1_tuser  => open,
            m_axis_1_tid    => open,
            m_axis_1_tdest  => open,
            s_axis_1_tready => s_axis_1_tready,
            s_axis_1_tvalid => s_axis_1_tvalid,
            s_axis_1_tlast  => s_axis_1_tlast,
            s_axis_1_tdata  => s_axis_1_tdata,
            s_axis_1_tstrb  => (others => '0'),
            s_axis_1_tkeep  => (others => '0'),
            s_axis_1_tuser  => (others => '0'),
            s_axis_1_tid    => (others => '0'),
            s_axis_1_tdest  => (others => '0'),
            axis_err_count  => axis_err_count,
            err_out         => err_out
        );

    -- DUT mapping
    m_axis_1_tready       <= s00_axi_stream_tready;
    s00_axi_stream_tvalid <= m_axis_1_tvalid;
    s00_axi_stream_tlast  <= m_axis_1_tlast;
    s00_axi_stream_tdata  <= m_axis_1_tdata;

    m00_axi_stream_tready <= s_axis_1_tready;
    s_axis_1_tvalid       <= m00_axi_stream_tvalid;
    s_axis_1_tlast        <= m00_axi_stream_tlast;
    s_axis_1_tdata        <= m00_axi_stream_tdata;

    -- sends an AXI-MM transaction to set the reg0(0) bit.
    i_config_for_bypass : process
    begin
        wait until s_axi_aresetn = '1';
        wait for 3 us;
        wait until rising_edge(s_axi_aclk);
        s00_axi_mm_awaddr  <= "0000";
        s00_axi_mm_awvalid <= '1';
        s00_axi_mm_wdata   <= x"0000_0001";
        s00_axi_mm_wstrb <= x"F";
        s00_axi_mm_wvalid  <= '1';
        s00_axi_mm_bready  <= '1';
        wait until rising_edge(s_axi_aclk) and s00_axi_mm_wready = '1' and s00_axi_mm_awready = '1';
        s00_axi_mm_wdata   <= x"0000_0000";
        s00_axi_mm_wstrb <= x"0";
        s00_axi_mm_wvalid  <= '0';
        s00_axi_mm_awvalid <= '0';
        wait until rising_edge(s_axi_aclk) and s00_axi_mm_bvalid = '1';
        s00_axi_mm_bready  <= '0';
        wait;
    end process i_config_for_bypass;

    i_dut : axi_stream_filter_v1_0
        generic map(
            C_S00_AXI_MM_DATA_WIDTH => 32,
            C_S00_AXI_MM_ADDR_WIDTH => 4
        )
        port map(
            s00_axi_stream_aclk    => s_axi_aclk,
            s00_axi_stream_aresetn => s_axi_aresetn,
            s00_axi_stream_tready  => s00_axi_stream_tready,
            s00_axi_stream_tdata   => s00_axi_stream_tdata,
            s00_axi_stream_tlast   => s00_axi_stream_tlast,
            s00_axi_stream_tvalid  => s00_axi_stream_tvalid,
            m00_axi_stream_aclk    => s_axi_aclk,
            m00_axi_stream_aresetn => s_axi_aresetn,
            m00_axi_stream_tvalid  => m00_axi_stream_tvalid,
            m00_axi_stream_tdata   => m00_axi_stream_tdata,
            m00_axi_stream_tlast   => m00_axi_stream_tlast,
            m00_axi_stream_tready  => m00_axi_stream_tready,
            s00_axi_mm_aclk        => s_axi_aclk,
            s00_axi_mm_aresetn     => s_axi_aresetn,
            s00_axi_mm_awaddr      => s00_axi_mm_awaddr,
            s00_axi_mm_awvalid     => s00_axi_mm_awvalid,
            s00_axi_mm_awready     => s00_axi_mm_awready,
            s00_axi_mm_wdata       => s00_axi_mm_wdata,
            s00_axi_mm_wstrb       => s00_axi_mm_wstrb,
            s00_axi_mm_wvalid      => s00_axi_mm_wvalid,
            s00_axi_mm_wready      => s00_axi_mm_wready,
            s00_axi_mm_bresp       => s00_axi_mm_bresp,
            s00_axi_mm_bvalid      => s00_axi_mm_bvalid,
            s00_axi_mm_bready      => s00_axi_mm_bready,
            s00_axi_mm_araddr      => s00_axi_mm_araddr,
            s00_axi_mm_arvalid     => s00_axi_mm_arvalid,
            s00_axi_mm_arready     => s00_axi_mm_arready,
            s00_axi_mm_rdata       => s00_axi_mm_rdata,
            s00_axi_mm_rresp       => s00_axi_mm_rresp,
            s00_axi_mm_rvalid      => s00_axi_mm_rvalid,
            s00_axi_mm_rready      => s00_axi_mm_rready
        );

end architecture RTL;
