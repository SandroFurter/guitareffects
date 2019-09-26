library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_stream_filter_v1_0 is
    generic(
        -- Users to add parameters here

        -- User parameters ends
        -- Do not modify the parameters beyond this line

        -- Parameters of Axi Slave Bus Interface S00_AXI_STREAM
        C_S00_AXI_STREAM_TDATA_WIDTH : integer := 32;
        -- Parameters of Axi Master Bus Interface M00_AXI_STREAM
        C_M00_AXI_STREAM_TDATA_WIDTH : integer := 32;
        C_M00_AXI_STREAM_START_COUNT : integer := 32;
        -- Parameters of Axi Slave Bus Interface S00_AXI_MM
        C_S00_AXI_MM_DATA_WIDTH      : integer := 32;
        C_S00_AXI_MM_ADDR_WIDTH      : integer := 4
    );
    port(
        -- Users to add ports here

        -- User ports ends
        -- Do not modify the ports beyond this line

        -- Ports of Axi Slave Bus Interface S00_AXI_STREAM
        s00_axi_stream_aclk    : in  std_logic;
        s00_axi_stream_aresetn : in  std_logic;
        s00_axi_stream_tready  : out std_logic;
        s00_axi_stream_tdata   : in  std_logic_vector(C_S00_AXI_STREAM_TDATA_WIDTH - 1 downto 0);
        s00_axi_stream_tstrb   : in  std_logic_vector((C_S00_AXI_STREAM_TDATA_WIDTH / 8) - 1 downto 0);
        s00_axi_stream_tlast   : in  std_logic;
        s00_axi_stream_tvalid  : in  std_logic;
        -- Ports of Axi Master Bus Interface M00_AXI_STREAM
        m00_axi_stream_aclk    : in  std_logic;
        m00_axi_stream_aresetn : in  std_logic;
        m00_axi_stream_tvalid  : out std_logic;
        m00_axi_stream_tdata   : out std_logic_vector(C_M00_AXI_STREAM_TDATA_WIDTH - 1 downto 0);
        m00_axi_stream_tstrb   : out std_logic_vector((C_M00_AXI_STREAM_TDATA_WIDTH / 8) - 1 downto 0);
        m00_axi_stream_tlast   : out std_logic;
        m00_axi_stream_tready  : in  std_logic;
        -- Ports of Axi Slave Bus Interface S00_AXI_MM
        s00_axi_mm_aclk        : in  std_logic;
        s00_axi_mm_aresetn     : in  std_logic;
        s00_axi_mm_awaddr      : in  std_logic_vector(C_S00_AXI_MM_ADDR_WIDTH - 1 downto 0);
        s00_axi_mm_awprot      : in  std_logic_vector(2 downto 0);
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
        s00_axi_mm_arprot      : in  std_logic_vector(2 downto 0);
        s00_axi_mm_arvalid     : in  std_logic;
        s00_axi_mm_arready     : out std_logic;
        s00_axi_mm_rdata       : out std_logic_vector(C_S00_AXI_MM_DATA_WIDTH - 1 downto 0);
        s00_axi_mm_rresp       : out std_logic_vector(1 downto 0);
        s00_axi_mm_rvalid      : out std_logic;
        s00_axi_mm_rready      : in  std_logic
    );
end axi_stream_filter_v1_0;

architecture arch_imp of axi_stream_filter_v1_0 is

    signal s_axi_mm_reg_0 : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH-1 downto 0);
    signal s_axi_mm_reg_1 : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH-1 downto 0);
    signal s_axi_mm_reg_2 : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH-1 downto 0);
    signal s_axi_mm_reg_3 : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH-1 downto 0);

    -- component declaration
    component axi_stream_filter_v1_0_S00_AXI_STREAM is
        generic(
            C_S_AXIS_TDATA_WIDTH : integer := 32
        );
        port(
            S_AXIS_ACLK    : in  std_logic;
            S_AXIS_ARESETN : in  std_logic;
            S_AXIS_TREADY  : out std_logic;
            S_AXIS_TDATA   : in  std_logic_vector(C_S_AXIS_TDATA_WIDTH - 1 downto 0);
            S_AXIS_TSTRB   : in  std_logic_vector((C_S_AXIS_TDATA_WIDTH / 8) - 1 downto 0);
            S_AXIS_TLAST   : in  std_logic;
            S_AXIS_TVALID  : in  std_logic
        );
    end component axi_stream_filter_v1_0_S00_AXI_STREAM;

    component axi_stream_master
        generic(C_M_AXIS_TDATA_WIDTH : integer);
        port(
            fifo_din         : in  std_logic_vector(63 downto 0);
            fifo_wr          : in  std_logic;
            fifo_empty       : out std_logic;
            fifo_almost_full : out std_logic;
            M_AXIS_ACLK      : in  std_logic;
            M_AXIS_ARESETN   : in  std_logic;
            M_AXIS_TVALID    : out std_logic;
            M_AXIS_TDATA     : out std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
            M_AXIS_TLAST     : out std_logic;
            M_AXIS_TREADY    : in  std_logic
        );
    end component axi_stream_master;

    component axi_stream_filter_v1_0_S00_AXI_MM
        generic(
            C_S_AXI_DATA_WIDTH : integer;
            C_S_AXI_ADDR_WIDTH : integer
        );
        port(
            s_axi_mm_reg_0 : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            s_axi_mm_reg_1 : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            s_axi_mm_reg_2 : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            s_axi_mm_reg_3 : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            S_AXI_ACLK     : in  std_logic;
            S_AXI_ARESETN  : in  std_logic;
            S_AXI_AWADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
            S_AXI_AWPROT   : in  std_logic_vector(2 downto 0);
            S_AXI_AWVALID  : in  std_logic;
            S_AXI_AWREADY  : out std_logic;
            S_AXI_WDATA    : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            S_AXI_WSTRB    : in  std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
            S_AXI_WVALID   : in  std_logic;
            S_AXI_WREADY   : out std_logic;
            S_AXI_BRESP    : out std_logic_vector(1 downto 0);
            S_AXI_BVALID   : out std_logic;
            S_AXI_BREADY   : in  std_logic;
            S_AXI_ARADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
            S_AXI_ARPROT   : in  std_logic_vector(2 downto 0);
            S_AXI_ARVALID  : in  std_logic;
            S_AXI_ARREADY  : out std_logic;
            S_AXI_RDATA    : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            S_AXI_RRESP    : out std_logic_vector(1 downto 0);
            S_AXI_RVALID   : out std_logic;
            S_AXI_RREADY   : in  std_logic
        );
    end component axi_stream_filter_v1_0_S00_AXI_MM;
    signal fifo_din : std_logic_vector(63 downto 0);
    signal fifo_wr : std_logic;
    signal fifo_empty : std_logic;
    signal fifo_almost_full : std_logic;

begin

    -- Instantiation of Axi Bus Interface S00_AXI_STREAM
    axi_stream_filter_v1_0_S00_AXI_STREAM_inst : axi_stream_filter_v1_0_S00_AXI_STREAM
        generic map(
            C_S_AXIS_TDATA_WIDTH => C_S00_AXI_STREAM_TDATA_WIDTH
        )
        port map(
            S_AXIS_ACLK    => s00_axi_stream_aclk,
            S_AXIS_ARESETN => s00_axi_stream_aresetn,
            S_AXIS_TREADY  => s00_axi_stream_tready,
            S_AXIS_TDATA   => s00_axi_stream_tdata,
            S_AXIS_TSTRB   => s00_axi_stream_tstrb,
            S_AXIS_TLAST   => s00_axi_stream_tlast,
            S_AXIS_TVALID  => s00_axi_stream_tvalid
        );

    -- Instantiation of Axi Bus Interface M00_AXI_STREAM
    axi_stream_filter_v1_0_M00_AXI_STREAM_inst : axi_stream_master
        generic map(
            C_M_AXIS_TDATA_WIDTH => 32
        )
        port map(
            fifo_din         => fifo_din,
            fifo_wr          => fifo_wr,
            fifo_empty       => fifo_empty,
            fifo_almost_full => fifo_almost_full,
            M_AXIS_ACLK      => m00_axi_stream_aclk,
            M_AXIS_ARESETN   => m00_axi_stream_aresetn,
            M_AXIS_TVALID    => m00_axi_stream_tvalid,
            M_AXIS_TDATA     => m00_axi_stream_tdata,
            M_AXIS_TLAST     => m00_axi_stream_tlast,
            M_AXIS_TREADY    => m00_axi_stream_tready
        );

    -- Instantiation of Axi Bus Interface S00_AXI_MM
    axi_stream_filter_v1_0_S00_AXI_MM_inst : axi_stream_filter_v1_0_S00_AXI_MM
        generic map(
            C_S_AXI_DATA_WIDTH => C_S00_AXI_MM_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH => C_S00_AXI_MM_ADDR_WIDTH
        )
        port map(
            s_axi_mm_reg_0 => s_axi_mm_reg_0,
            s_axi_mm_reg_1 => s_axi_mm_reg_1,
            s_axi_mm_reg_2 => s_axi_mm_reg_2,
            s_axi_mm_reg_3 => s_axi_mm_reg_3,
            S_AXI_ACLK     => s00_axi_mm_aclk,
            S_AXI_ARESETN  => s00_axi_mm_aresetn,
            S_AXI_AWADDR   => s00_axi_mm_awaddr,
            S_AXI_AWPROT   => s00_axi_mm_awprot,
            S_AXI_AWVALID  => s00_axi_mm_awvalid,
            S_AXI_AWREADY  => s00_axi_mm_awready,
            S_AXI_WDATA    => s00_axi_mm_wdata,
            S_AXI_WSTRB    => s00_axi_mm_wstrb,
            S_AXI_WVALID   => s00_axi_mm_wvalid,
            S_AXI_WREADY   => s00_axi_mm_wready,
            S_AXI_BRESP    => s00_axi_mm_bresp,
            S_AXI_BVALID   => s00_axi_mm_bvalid,
            S_AXI_BREADY   => s00_axi_mm_bready,
            S_AXI_ARADDR   => s00_axi_mm_araddr,
            S_AXI_ARPROT   => s00_axi_mm_arprot,
            S_AXI_ARVALID  => s00_axi_mm_arvalid,
            S_AXI_ARREADY  => s00_axi_mm_arready,
            S_AXI_RDATA    => s00_axi_mm_rdata,
            S_AXI_RRESP    => s00_axi_mm_rresp,
            S_AXI_RVALID   => s00_axi_mm_rvalid,
            S_AXI_RREADY   => s00_axi_mm_rready
        );

        -- Add user logic here
        
        -- User logic ends

end arch_imp;
