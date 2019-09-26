-------------------------------------------------------------------------------
-- Project name      : ZE_DESIGN_RESSOURCES
-- Project number    : -
-- Customer          : -
--
-- Language / Version: Uses Xilinx Primitives
--
-- Author            : ster
-- Version           : 1.0
-- Date              : 26.09.2019
-------------------------------------------------------------------------------
-- Description :       Generic AXI Stream Filter 
--
-------------------------------------------------------------------------------
-- Modifications :
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_stream_filter_v1_0 is
    generic(
        -- Parameters of Axi Slave Bus Interface S00_AXI_MM
        C_S00_AXI_MM_DATA_WIDTH : integer := 32;
        C_S00_AXI_MM_ADDR_WIDTH : integer := 4
    );
    port(
        -- Users to add ports here

        -- User ports ends
        -- Do not modify the ports beyond this line

        -- Ports of Axi Slave Bus Interface S00_AXI_STREAM
        s00_axi_stream_aclk    : in  std_logic;
        s00_axi_stream_aresetn : in  std_logic;
        s00_axi_stream_tready  : out std_logic;
        s00_axi_stream_tdata   : in  std_logic_vector(31 downto 0);
        s00_axi_stream_tlast   : in  std_logic;
        s00_axi_stream_tvalid  : in  std_logic;
        -- Ports of Axi Master Bus Interface M00_AXI_STREAM
        m00_axi_stream_aclk    : in  std_logic;
        m00_axi_stream_aresetn : in  std_logic;
        m00_axi_stream_tvalid  : out std_logic;
        m00_axi_stream_tdata   : out std_logic_vector(31 downto 0);
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

    constant c_AXI_S_TDATA_WIDTH : integer := 32;

    -- STREAM INPUT
    -- AXI STREAM SLAVE
    signal fifo_in_rd : std_logic;
    signal fifo_in_valid : std_logic;
    signal fifo_in_dout : std_logic_vector(63 downto 0);
    signal fifo_in_empty : std_logic;

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
            S_AXIS_TLAST   : in  std_logic;
            S_AXIS_TVALID  : in  std_logic
        );
    end component axi_stream_filter_v1_0_S00_AXI_STREAM;

    -- STREAM OUTPUT
    -- AXI STREAM MASTER 
    signal fifo_out_din          : std_logic_vector(63 downto 0);
    signal fifo_out_wr           : std_logic;
    signal fifo_out_empty        : std_logic;
    signal fifo_out_almost_full  : std_logic;
    signal fifo_out_wr_ack       : std_logic;
    signal M_AXIS_ACLK           : std_logic;
    signal M_AXIS_ARESETN        : std_logic;
    signal M_AXIS_TVALID         : std_logic;
    signal M_AXIS_TDATA          : std_logic_vector(c_AXI_S_TDATA_WIDTH - 1 downto 0);
    signal M_AXIS_TLAST          : std_logic;
    signal M_AXIS_TREADY         : std_logic;

    component axi_stream_master
        generic(g_axi_data_width : integer);
        port(
            fifo_din         : in  std_logic_vector(31 downto 0);
            fifo_wr          : in  std_logic;
            fifo_wr_ack      : out std_logic;
            fifo_empty       : out std_logic;
            fifo_almost_full : out std_logic;
            M_AXIS_ACLK      : in  std_logic;
            M_AXIS_ARESETN   : in  std_logic;
            M_AXIS_TVALID    : out std_logic;
            M_AXIS_TDATA     : out std_logic_vector(g_axi_data_width - 1 downto 0);
            M_AXIS_TLAST     : out std_logic;
            M_AXIS_TREADY    : in  std_logic
        );
    end component axi_stream_master;

    -- AXI Configuration
    -- AXI MM
    signal s_axi_mm_reg_0 : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH - 1 downto 0);
    signal s_axi_mm_reg_1 : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH - 1 downto 0);
    signal s_axi_mm_reg_2 : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH - 1 downto 0);
    signal s_axi_mm_reg_3 : std_logic_vector(C_S00_AXI_MM_DATA_WIDTH - 1 downto 0);
    
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
    

    signal clk                   : std_logic;

    type state is (IDLE,                -- This is the initial/idle state 
                   TRANSFER_DATA,
                   WAIT_FOR_ACK);       -- In this state the                               
    signal bypass_copy_state : state := IDLE;


begin

    -- Instantiation of Axi Bus Interface S00_AXI_STREAM
    axi_stream_filter_v1_0_S00_AXI_STREAM_inst : axi_stream_filter_v1_0_S00_AXI_STREAM
        generic map(
            C_S_AXIS_TDATA_WIDTH => c_AXI_S_TDATA_WIDTH
        )
        port map(
            S_AXIS_ACLK    => s00_axi_stream_aclk,
            S_AXIS_ARESETN => s00_axi_stream_aresetn,
            S_AXIS_TREADY  => s00_axi_stream_tready,
            S_AXIS_TDATA   => s00_axi_stream_tdata,
            S_AXIS_TLAST   => s00_axi_stream_tlast,
            S_AXIS_TVALID  => s00_axi_stream_tvalid
        );

    -- Instantiation of Axi Bus Interface M00_AXI_STREAM
    axi_stream_filter_v1_0_M00_AXI_STREAM_inst : axi_stream_master
        generic map(
            g_axi_data_width => c_AXI_S_TDATA_WIDTH
        )
        port map(
            fifo_din         => fifo_out_din,
            fifo_wr          => fifo_out_wr,
            fifo_wr_ack      => fifo_out_wr_ack,
            fifo_empty       => fifo_out_empty,
            fifo_almost_full => fifo_out_almost_full,
            M_AXIS_ACLK      => M_AXIS_ACLK,
            M_AXIS_ARESETN   => M_AXIS_ARESETN,
            M_AXIS_TVALID    => M_AXIS_TVALID,
            M_AXIS_TDATA     => M_AXIS_TDATA,
            M_AXIS_TLAST     => M_AXIS_TLAST,
            M_AXIS_TREADY    => M_AXIS_TREADY
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

    clk <= s00_axi_stream_aclk;
    -- Add user logic here
    bypass : process(s00_axi_stream_aclk)
    begin
        if rising_edge(s00_axi_stream_aclk) then
            
            if (s00_axi_stream_aresetn = '0') then
                bypass_copy_state <= IDLE;
            elsif s_axi_mm_reg_0(0) = '1' then
                case (bypass_copy_state) is
                    when IDLE =>
                        if (fifo_out_almost_full = '0') AND (fifo_in_empty = '0') then
                            bypass_copy_state <= TRANSFER_DATA;
                            fifo_in_rd        <= '1';
                        end if;
                    when TRANSFER_DATA =>
                        if (fifo_in_valid = '1') then
                            fifo_out_din      <= fifo_in_dout;
                            fifo_out_wr       <= '1';
                            bypass_copy_state <= WAIT_FOR_ACK;
                        else
                            fifo_in_rd        <= '1';
                        end if;

                    when WAIT_FOR_ACK =>
                        if (fifo_out_wr_ack = '1') then
                            bypass_copy_state <= IDLE;
                        end if;
                    when others =>
                        bypass_copy_state <= IDLE;
                end case;
            end if;
        end if;
    end process bypass;

    -- User logic ends

end arch_imp;
