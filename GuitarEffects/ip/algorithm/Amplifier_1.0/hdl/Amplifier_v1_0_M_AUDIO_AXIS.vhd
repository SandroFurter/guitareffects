library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Amplifier_v1_0_M_AUDIO_AXIS is
	generic (
		-- Users to add parameters here
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		-- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
		ReadFifoxSI : in std_logic;
		FifoEmptyxSO : out std_logic;
		FifoFullxSO : out std_logc;
		DataxDO : out std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK	: in std_logic;
		-- 
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end Amplifier_v1_0_M_AUDIO_AXIS;

architecture implementation of Amplifier_v1_0_M_AUDIO_AXIS is
	function getVectorSize( maxValue : integer) return integer is
        variable vectorSize : integer := 1;
    begin
        while 2**vectorSize <= maxValue loop
            vectorSize := vectorSize + 1;
        end loop;
        return vectorSize;
    end getVectorSize;
    
    constant FIFO_SIZE : integer := 8;
    type FifoArray is array(0 to FIFO_SIZE - 1) of std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
    signal FifoxDP, FifoxDN : FifoArray;
    
    constant FIFO_COUNTER_SIZE : integer := gitVectorSize(FIFO_SIZE);
    signal FifoWriteCounterxDP, FifoWriteCounterxDN : unsigned(FIFO_COUNTER_SIZE - 1 downto 0);
    signal FifoReadCounterxDP, FifoReadCounterxDN : unsigned(FIFO_COUNTER_SIZE - 1 downto 0);
    constant FIFO_COUNTER_MAX_VALUE : unsigned := to_unsigned(FIFO_SIZE, FIFO_COUNTER_SIZE);
begin
	DataxDO <= FifoxDP(FifoReadCounterxDP);
	
	FifoEmptyxSO <= '0' when FifoWriteCounterxDP = FifoReadCounterxDP else '1';
	
	FifoFullxSO <= '1' when FifoWriteCounterxDP + 1 = FifoReadCounterxDP else '0';
	
	FifoLogic : process(M_AXIS_TVALID, M_AXIS_TDATA,FifoWriteCounterxDP, FifoxDP)
	begin
		if(M_AXIS_TVALID = '1') then
			if(FifoWriteCounterxDP = (FIFO_COUNTER_SIZE - 1 downto 0 => '0')) then
				FifoxDN(0) <= M_AXIS_TDATA;
				FifoxDN(1 to FIFO_SIZE - 1) <= FifoxDP(1 to FIFO_SIZE - 1);
			elsif(FifoWriteCounterxDP = FIFO_COUNTER_MAX_VALUE) then
				FifoxDN(FIFO_SIZE - 1) <= M_AXIS_TDATA;
				FifoxDN(0 to FIFO_SIZE - 2) <= FifoxDP(0 to FIFO_SIZE - 2);
			else
				FifoxDN(integer(FifoWriteCounterxDP)) <= M_AXIS_TDATA;
				FifoxDN(0 to integer(FifoWriteCounterxDP) - 1) <= FifoxDP(0 to integer(FifoWriteCounterxDP) - 1);
				FifoxDN(integer(FifoWriteCounterxDP) + 1 to FIFO_SIZE - 1) <= FifoxDP(integer(FifoWriteCounterxDP) + 1 to FIFO_SIZE - 1);
			end if;
		else
			FifoxDN <= FifoxDP;
		end if;
	end process;
	
	WriteCounterLogic : process(M_AXIS_TVALID, FifoWriteCounterxDP)
	begin
		if(M_AXIS_TVALID = '1') then
			if(FifoWriteCounterxDP < FIFO_COUNTER_MAX_VALUE) then
				FifoWriteCounterxDN <= FifoWriteCounterxDP + 1;
			else
				FifoWriteCounterxDN <= (others => '0');
			end if;
		else
			FifoWriteCounterxDN <= FifoWriteCounterxDP;
		end if;
	end process;
	
	ReadCounterLogic : process(ReadFifoxSI, FifoReadCounterxDP)
	begin
		if(ReadFifoxSI = '1') then
			if(FifoReadCounterxDP < FIFO_COUNTER_MAX_VALUE) then
				FifoReadCounterxDN <= FifoReadCounterxDP + 1;
			else
				FifoReadCounterxDN <= (others => '0');
			end if;
		else
			FifoReadCounterxDN <= FifoReadCounterxDP;
		end if;
	end process;
	
	RegisterLogic : process(M_AXIS_ACLK,M_AXIS_ARESETN)
	begin
		if(M_AXIS_ARESETN = '1') then
			FifoxDP <= (others => (others => '0'));
			FifoWriteCounterxDP <= (others => '0');
			FifoReadCounterxDP <= (others => '0');
		elsif(rising_edge(M_AXIS_ACLK)) then
			FifoxDP <= FifoxDN;
			FifoWriteCounterxDP <= FifoWriteCounterxDN;
			FifoReadCounterxDP <= FifoReadCounterxDN;
		end if;
	end process;
end implementation;
