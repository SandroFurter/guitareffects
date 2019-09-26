library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_axi_stream_master is
end entity tb_axi_stream_master;

architecture RTL of tb_axi_stream_master is

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

    constant g_axi_data_width : integer := 32;

    signal clk : std_logic := '0';

    signal fifo_din         : std_logic_vector(31 downto 0) := (others => '0');
    signal fifo_wr          : std_logic                     := '0';
    signal fifo_empty       : std_logic;
    signal fifo_almost_full : std_logic;
    signal M_AXIS_ACLK      : std_logic                     := '0';
    signal M_AXIS_ARESETN   : std_logic                     := '0';
    signal M_AXIS_TVALID    : std_logic;
    signal M_AXIS_TDATA     : std_logic_vector(g_axi_data_width - 1 downto 0);
    signal M_AXIS_TLAST     : std_logic;
    signal M_AXIS_TREADY    : std_logic                     := '0';
    signal fifo_wr_ack      : std_logic;

begin

    clk <= not clk after 10 ns;

    rst : process
    begin
        -- issue reset async
        M_AXIS_ARESETN <= '0';
        wait for 1 us;
        -- set synchrounous
        wait until rising_edge(clk);
        M_AXIS_ARESETN <= '1';
        wait;
    end process rst;

    M_AXIS_ACLK <= clk;

    i_dut : axi_stream_master
        generic map(
            g_axi_data_width => g_axi_data_width
        )
        port map(
            fifo_din         => fifo_din,
            fifo_wr          => fifo_wr,
            fifo_wr_ack      => fifo_wr_ack,
            fifo_empty       => fifo_empty,
            fifo_almost_full => fifo_almost_full,
            M_AXIS_ACLK      => M_AXIS_ACLK,
            M_AXIS_ARESETN   => M_AXIS_ARESETN,
            M_AXIS_TVALID    => M_AXIS_TVALID,
            M_AXIS_TDATA     => M_AXIS_TDATA,
            M_AXIS_TLAST     => M_AXIS_TLAST,
            M_AXIS_TREADY    => M_AXIS_TREADY
        );

    -- (opt) Simulate Backpressure
    M_AXIS_TREADY <= '1';

    stimuli : process
    begin
        wait for 10 us;
        wait until rising_edge(clk);
        fifo_din <= x"1234_5678";
        fifo_wr  <= '1';
        wait until fifo_wr_ack = '1';
        fifo_din <= x"0000_0000";
        fifo_wr  <= '0';
        wait until rising_edge(clk);
        fifo_din <= x"0000_ABCD";
        fifo_wr  <= '1';
        wait until fifo_wr_ack = '1';
        fifo_din <= x"0000_0000";
        fifo_wr  <= '0';
        wait;
    end process stimuli;

end architecture RTL;
