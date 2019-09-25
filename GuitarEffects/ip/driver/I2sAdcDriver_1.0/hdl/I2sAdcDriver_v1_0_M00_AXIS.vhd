library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2sAdcDriver_v1_0_M00_AXIS is
	generic (
		-- Users to add parameters here
		AUDIO_DATA_WIDTH : integer := 24;
        INPUTCLOCK_FREQUENCY : integer := 122880e3;
        SAMPLE_RATE : integer := 96e3; -- Choosable between 32e3, 44.1e3, 48e3, 64e3, 88.2e3, 96e3
        MCLK_FACTOR : integer := 128; -- CHOSABLE between, 96, 192, 384 and 768
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		-- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT	: integer	:= 32
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
end I2sAdcDriver_v1_0_M00_AXIS;

architecture implementation of I2sAdcDriver_v1_0_M00_AXIS is
	function getVectorSize( maxValue : integer) return integer is
        variable vectorSize : integer := 1;
    begin
        while 2**vectorSize <= maxValue loop
            vectorSize := vectorSize + 1;
        end loop;
        return vectorSize;
    end getVectorSize;
    
	type I2SStateType is (STANDBY, SENDLEFTDATA, WAITFORRIGHTDATA, SENDRIGHTDATA, WAITFORLEFTDATA);
    signal I2SDriverStatexDP, I2SDriverStatexDN : I2SStateType;
    
    type AxiStreamMasterState is (STANDBY, WAITFORSLAVE, SENDDATA);
    signal AxiMasterStatexDP, AxiMasterStatexDN : AxiStreamMasterState;
    
    signal LeftDataSentxSP, LeftDataSentxSN : std_logic;
    
    signal SendDataxS : std_logic;
    
    signal LeftDataxDP, LeftDataxDN : std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
    signal RightDataxDP, RightDataxDN : std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
    
    constant AUDIO_DATA_COUNTER_WIDTH : integer := getVectorSize(AUDIO_DATA_WIDTH * 2);
    
    signal DataCounterxDP, DataCounterxDN : unsigned(AUDIO_DATA_COUNTER_WIDTH - 1 downto 0);
    
    signal ReadDataxS : std_logic;
    
    
    constant MCLK_FREQUENCY : integer := SAMPLE_RATE * MCLK_FACTOR;
    constant MCLK_FREQUENCY_COUNTER_WIDTH : integer := getVectorSize(INPUTCLOCK_FREQUENCY / MCLK_FREQUENCY - 1); -- TODO: generisch
    constant MCLK_FREQUENCY_COUNTER_MAXVALUE : unsigned(MCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0) := to_unsigned(INPUTCLOCK_FREQUENCY / MCLK_FREQUENCY - 1, MCLK_FREQUENCY_COUNTER_WIDTH);
    signal MclkCounterxDP, MclkCounterxDN : unsigned(MCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0);
    
    constant LRCLK_FREQUENCY : integer := SAMPLE_RATE;
    constant LRCLK_FREQUENCY_COUNTER_WIDTH : integer:= getVectorSize(INPUTCLOCK_FREQUENCY / LRCLK_FREQUENCY - 1); -- TODO generisch
    constant LRCLK_FREQUENCY_COUNTER_MAXVALUE : unsigned(LRCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0) := to_unsigned(INPUTCLOCK_FREQUENCY / LRCLK_FREQUENCY - 1, LRCLK_FREQUENCY_COUNTER_WIDTH);
    signal LrclkCounterxDP, LrclkCounterxDN : unsigned(LRCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0);
    
    constant SCLK_FREQUENCY : integer := SAMPLE_RATE * 64;
    constant SCLK_FREQUENCY_COUNTER_WIDTH : integer := getVectorSize(INPUTCLOCK_FREQUENCY / SCLK_FREQUENCY - 1); -- TODO generisch
    constant SCLK_FREQUENCY_COUNTER_MAXVALUE : unsigned(SCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0) := to_unsigned(INPUTCLOCK_FREQUENCY / SCLK_FREQUENCY - 1, SCLK_FREQUENCY_COUNTER_WIDTH);
    signal SclkCounterxDP, SclkCounterxDN : unsigned(SCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0);
begin
	-- I/O Connections assignments

	M_AXIS_TVALID	<= '1' when AxiMasterStatexDP /= STANDBY;
	M_AXIS_TDATA	<= (C_M_AXIS_TDATA_WIDTH - 1 downto AUDIO_DATA_WIDTH => '0') & LeftDataxDP when LeftDataSentxSP = '0' else (C_M_AXIS_TDATA_WIDTH - 1 downto AUDIO_DATA_WIDTH => '0') & RightDataxDP;
	M_AXIS_TLAST	<= LeftDataSentxSP;
	M_AXIS_TSTRB	<= (others => '1');

	AD_MCLK <= '1' when MclkCounterxDP > to_unsigned(to_integer(MCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, MCLK_FREQUENCY_COUNTER_WIDTH) else '0';
    
    AD_LRCK <= '1' when I2SDriverStatexDP = WAITFORLEFTDATA or I2SDriverStatexDP = SENDRIGHTDATA else '0';
    
    AD_SCLK <= '1' when SclkCounterxDP > to_unsigned(to_integer(SCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, SCLK_FREQUENCY_COUNTER_WIDTH) else '0';

	MclkCounterxDN <= MclkCounterxDP + 1 when MclkCounterxDP < MCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
    
    LrclkCounterxDN <= LrclkCounterxDP + 1 when LrclkCounterxDP < LRCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
    
    SclkCounterxDN <= SclkCounterxDP + 1 when SclkCounterxDP < SCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
                               
    ReadDataxS <= '1' when SclkCounterxDP = to_unsigned(to_integer(SCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, SCLK_FREQUENCY_COUNTER_WIDTH) and (I2SDriverStatexDP = SENDLEFTDATA or I2SDriverStatexDP = SENDRIGHTDATA) else '0';
    
    SendDataxS <= '1' when I2SDriverStatexDP = SENDLEFTDATA and LrclkCounterxDP = LRCLK_FREQUENCY_COUNTER_MAXVALUE else '0';
    
    DataCounterLogic : process(I2SDriverStatexDP, DataCounterxDP, ReadDataxS)
    begin
        if(I2SDriverStatexDP = STANDBY or I2SDriverStatexDP = WAITFORLEFTDATA) then
            DataCounterxDN <= (others => '0');
        elsif(ReadDataxS = '1') then
            DataCounterxDN <= DataCounterxDP + 1;
        else
            DataCounterxDN <= DataCounterxDP;
        end if;
    end process;
    
    DataRegisterLogic : process(I2SDriverStatexDP,ReadDataxS,LeftDataxDP,RightDataxDP, AD_SDI)
    begin
        if(I2SDriverStatexDP = SENDLEFTDATA and ReadDataxS = '1') then
            LeftDataxDN <= LeftDataxDP(AUDIO_DATA_WIDTH - 2 downto 0) & AD_SDI;
            RightDataxDN <= RightDataxDP;
        elsif(I2SDriverStatexDP = SENDRIGHTDATA and ReadDataxS = '1') then
            RightDataxDN <= RightDataxDP(AUDIO_DATA_WIDTH - 2 downto 0) & AD_SDI;
            LeftDataxDN <= LeftDataxDP;
        else
             LeftDataxDN <= LeftDataxDP;
             RightDataxDN <= RightDataxDP;
        end if;
    end process;
    
    AxiStreamStateLogic : process(AxiMasterStatexDP, SendDataxS, M_AXIS_TREADY, LeftDataSentxSP)
    begin
    	case AxiMasterStatexDP is 
    		when STANDBY =>
    			if(SendDataxS = '1') then
    				if(M_AXIS_TREADY = '1') then
    					AxiMasterStatexDN <= SENDDATA;
    				else
    					AxiMasterStatexDN <= WAITFORSLAVE;
    				end if;
    			end if;    					
    		when WAITFORSLAVE =>
    			if(M_AXIS_TREADY = '1') then
    				AxiMasterStatexDN <= SENDDATA;
    			else
    				AxiMasterStatexDN <= WAITFORSLAVE;
    			end if;
    		when SENDDATA =>
    			if(LeftDataSentxSP = '1') then
    				AxiMasterStatexDN <= STANDBY;
    			else
    				if(M_AXIS_TREADY = '1') then
    					AxiMasterStatexDN <= SENDDATA;
    				else
    					AxiMasterStatexDN <= WAITFORSLAVE;
    				end if;
    			end if;	
    	end case;
    end process;
    
    I2SStateLogic : process(ReadDataxSI, I2SDriverStatexDP, LrclkCounterxDP, DataCounterxDP)
    begin
        case I2SDriverStatexDP is
            when STANDBY =>
                if(ReadDataxSI = '1') then
                    I2SDriverStatexDN <= SENDLEFTDATA;
                else
                    I2SDriverStatexDN <= STANDBY;
                end if;
            when SENDLEFTDATA =>
                if(DataCounterxDP < to_unsigned(AUDIO_DATA_WIDTH - 1 + 2, AUDIO_DATA_COUNTER_WIDTH)) then
                    I2SDriverStatexDN <= SENDLEFTDATA;
                else
                    I2SDriverStatexDN <= WAITFORRIGHTDATA;
                end if;
            when WAITFORRIGHTDATA =>
                if(LrclkCounterxDP = to_unsigned(to_integer(LRCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, LRCLK_FREQUENCY_COUNTER_WIDTH)) then
                    I2SDriverStatexDN <= SENDRIGHTDATA;
                else
                    I2SDriverStatexDN <= WAITFORRIGHTDATA;
                end if;
            when SENDRIGHTDATA =>
                if(DataCounterxDP < to_unsigned(AUDIO_DATA_WIDTH * 2 - 1 + 4, AUDIO_DATA_COUNTER_WIDTH)) then
                    I2SDriverStatexDN <= SENDRIGHTDATA;
                else
                    I2SDriverStatexDN <= WAITFORLEFTDATA;
                end if;
            when WAITFORLEFTDATA =>
                if(LrclkCounterxDP < LRCLK_FREQUENCY_COUNTER_MAXVALUE) then
                    I2SDriverStatexDN <= WAITFORLEFTDATA;
                else
                    if(ReadDataxSI = '1') then
                        I2SDriverStatexDN <= SENDLEFTDATA;
                    else
                        I2SDriverStatexDN <= STANDBY;
                    end if;
                end if;
        end case;
    end process;

    RegisterLogic : process(M_AXIS_ACLK, M_AXIS_ARESETN)
    begin
    	if(M_AXIS_ARESETN = '0') then
    		I2SDriverStatexDP <= STANDBY;
            DataCounterxDP <= (others => '0');
            MclkCounterxDP <= (others => '0');
            LrclkCounterxDP <= (others => '0');
            SclkCounterxDP <= (others => '0');
            LeftDataxDP <= (others => '0');
            RightDataxDP <= (others => '0');
        elsif(rising_edge(M_AXIS_ACLK)) then
            I2SDriverStatexDP <= I2SDriverStatexDN;
            DataCounterxDP <= DataCounterxDN;
            MclkCounterxDP <= MclkCounterxDN;
            LrclkCounterxDP <= LrclkCounterxDN;
            SclkCounterxDP <= SclkCounterxDN;
            LeftDataxDP <= LeftDataxDN;
            RightDataxDP <= RightDataxDN;
        end if;
    end process;
end implementation;
