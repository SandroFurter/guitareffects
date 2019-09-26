library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_stream_filter_v1_0_S00_AXI_STREAM is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
		ReadFifoxSI : in std_logic;
		FifoEmptyxSO : out std_logic;
		FifoDataValidxSO : out std_logic;
		FifoDataxDO : out std_logic_vector(C_S_AXIS_TDATA_WIDTH - 1 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end axi_stream_filter_v1_0_S00_AXI_STREAM;

architecture arch_imp of axi_stream_filter_v1_0_S00_AXI_STREAM is
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
    signal FifoAlmostFullxS : std_logic;
    signal FifoFullxS : std_logic;
    signal FifoDataCountxD : std_logic_vector(3 downto 0);
    signal FifoResetxS : std_logic;
begin
	S_AXIS_TREADY <= not(FifoAlmostFullxS) and S_AXIS_ARESETN;
    
    FifoResetxS <= not(S_AXIS_ARESETN);
    
	o_fifo : native_fifo_32bx16
        port map(
            clk         => S_AXIS_ACLK,
            rst         => FifoResetxS,
            din         => S_AXIS_TDATA,
            wr_en       => S_AXIS_TVALID,
            rd_en       => ReadFifoxSI,
            valid       => FifoDataValidxSO,
            dout        => FifoDataxDO,
            full        => FifoFullxS,
            almost_full => FifoAlmostFullxS,
            empty       => FifoEmptyxSO,
            data_count  => FifoDataCountxD
        );

end arch_imp;
