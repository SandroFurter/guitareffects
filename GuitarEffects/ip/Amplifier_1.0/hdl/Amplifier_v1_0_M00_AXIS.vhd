library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Amplifier_v1_0_M00_AXIS is
	generic (
		g_axi_data_width : integer := 32
	);
	port (
		--FIFO Interface
        fifo_din         : in  std_logic_vector(31 downto 0);
        fifo_wr          : in  std_logic;
        fifo_wr_ack      : out std_logic;
        fifo_empty       : out std_logic;
        fifo_almost_full : out std_logic;
        --AXI-S Interface
        M_AXIS_ACLK      : in  std_logic;
        M_AXIS_ARESETN   : in  std_logic;
        M_AXIS_TVALID    : out std_logic;
        M_AXIS_TDATA     : out std_logic_vector(g_axi_data_width - 1 downto 0);
        M_AXIS_TLAST     : out std_logic;
        M_AXIS_TREADY    : in  std_logic
	);
end Amplifier_v1_0_M00_AXIS;

architecture implementation of Amplifier_v1_0_M00_AXIS is
	type state is (IDLE,                -- This is the initial/idle state 
                   GET_DATA,
                   SEND_PACKET);        -- In this state the                               
    signal mst_exec_state : state                                           := IDLE;
    signal axis_tvalid    : std_logic                                       := '0';
    signal axis_tlast     : std_logic                                       := '0';
    signal axis_tdata     : std_logic_vector(g_axi_data_width - 1 downto 0) := (others => '0');

    -- FIFO Signals and Component 
    signal rd_en       : std_logic                     := '0';
    signal dout        : std_logic_vector(31 downto 0) := (others => '0');
    signal full        : std_logic                     := '0';
    signal almost_full : std_logic                     := '0';
    signal data_count  : std_logic_vector(3 downto 0)  := (others => '0');
    signal din         : std_logic_vector(31 downto 0) := (others => '0');
    signal wr_en       : std_logic                     := '0';
    signal empty       : std_logic                     := '0';
    signal rst         : std_logic                     := '0';
    signal clk         : std_logic                     := '0';

    -- This is a XILINX Primitive (FIFO Generator)
    COMPONENT native_fifo_32bx16
        PORT(
            clk          : IN  STD_LOGIC;
            rst          : IN  STD_LOGIC;
            din          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            wr_en        : IN  STD_LOGIC;
            rd_en        : IN  STD_LOGIC;
            dout         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            full         : OUT STD_LOGIC;
            almost_full  : OUT STD_LOGIC;
            wr_ack       : OUT STD_LOGIC;
            overflow     : OUT STD_LOGIC;
            empty        : OUT STD_LOGIC;
            almost_empty : OUT STD_LOGIC;
            valid        : OUT STD_LOGIC;
            underflow    : OUT STD_LOGIC;
            data_count   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            wr_rst_busy  : OUT STD_LOGIC;
            rd_rst_busy  : OUT STD_LOGIC
        );
    END COMPONENT;
    signal valid  : STD_LOGIC;
    signal wr_ack : STD_LOGIC;

begin
    -- I/O Connections assignments

    M_AXIS_TVALID <= axis_tvalid;
    M_AXIS_TDATA  <= axis_tdata;
    M_AXIS_TLAST  <= axis_tlast;

    -- state machine implementation                                               
    process(M_AXIS_ACLK)
    begin
        if (rising_edge(M_AXIS_ACLK)) then

            rd_en       <= '0';
            axis_tlast  <= '0';
            axis_tvalid <= '0';
            axis_tdata  <= (others => '0');

            if (M_AXIS_ARESETN = '0') then
                mst_exec_state <= IDLE;
            else
                case (mst_exec_state) is
                    when IDLE =>

                        if (empty = '0') AND (M_AXIS_TREADY = '1') then
                            mst_exec_state <= GET_DATA;
                            rd_en          <= '1';
                        else
                            mst_exec_state <= IDLE;
                        end if;

                    when GET_DATA =>
                        -- Fifo has 1 clock cycle read latency
                        if (valid = '1') then
                            mst_exec_state <= SEND_PACKET;
                        end if;

                    when SEND_PACKET =>
                        if (empty = '1') then
                            axis_tlast <= '1';
                        end if;

                        axis_tvalid    <= '1';
                        axis_tdata     <= dout(g_axi_data_width - 1 downto 0);
                        mst_exec_state <= IDLE;

                    when others =>
                        mst_exec_state <= IDLE;

                end case;
            end if;
        end if;
    end process;

    -- output port mapping
    fifo_almost_full <= almost_full;
    fifo_empty       <= empty;
    fifo_wr_ack      <= wr_ack;
    din              <= fifo_din;
    wr_en            <= fifo_wr;

    rst <= not M_AXIS_ARESETN;
    clk <= M_AXIS_ACLK;

    -- FIFO Implementation                                                          
    i_fifo : native_fifo_32bx16
        port map(
            clk         => clk,
            rst         => rst,
            din         => din,
            wr_en       => wr_en,
            wr_ack      => wr_ack,
            rd_en       => rd_en,
            valid       => valid,
            dout        => dout,
            full        => full,
            almost_full => almost_full,
            empty       => empty,
            data_count  => data_count
        );
end implementation;
