library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2sDacDriver_v1_0_S00_AXIS is
	generic (
		-- Users to add parameters here
		AUDIO_DATA_WIDTH : integer := 24;
        INPUTCLOCK_FREQUENCY : integer := 122880e3;
        SAMPLE_RATE : integer := 192e3; -- Choosable between 32e3, 44.1e3, 48e3, 64e3, 88.2e3, 96e3, 128e3, 167.4e3, 192e3
        MCLK_FACTOR : integer := 128; -- CHOSABLE between, 96, 192, 384 and 768
        SCLK_FACTOR : integer := 64;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
		DA_MCLK : out std_logic;
        DA_LRCK : out std_logic;
        DA_SCLK : out std_logic;
        DA_SDO : out std_logic;
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
end I2sDacDriver_v1_0_S00_AXIS;

architecture arch_imp of I2sDacDriver_v1_0_S00_AXIS is
	function getVectorSize( maxValue : integer) return integer is
        variable vectorSize : integer := 1;
    begin
        while 2**vectorSize <= maxValue loop
            vectorSize := vectorSize + 1;
        end loop;
        return vectorSize;
    end getVectorSize;
    
    signal OutputRegisterxDP, OutputRegisterxDN : std_logic_vector(AUDIO_DATA_WIDTH * 2 - 1 + 1 downto 0);
    type I2SStateType is (STANDBY, SENDLEFTDATA, WAITFORRIGHTDATA, SENDRIGHTDATA, WAITFORLEFTDATA);
    signal I2SDriverStatexDP, I2SDriverStatexDN : I2SStateType;
    
    constant AUDIO_DATA_COUNTER_WIDTH : integer := getVectorSize(AUDIO_DATA_WIDTH * 2);
    
    signal DataCounterxDP, DataCounterxDN : unsigned(AUDIO_DATA_COUNTER_WIDTH - 1 downto 0);
    
    signal SendNextDataxS : std_logic;
    
    constant MCLK_FREQUENCY : integer := SAMPLE_RATE * MCLK_FACTOR;
    constant MCLK_FREQUENCY_COUNTER_WIDTH : integer := getVectorSize(INPUTCLOCK_FREQUENCY / MCLK_FREQUENCY - 1); 
    constant MCLK_FREQUENCY_COUNTER_MAXVALUE : unsigned(MCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0) := to_unsigned(INPUTCLOCK_FREQUENCY / MCLK_FREQUENCY - 1, MCLK_FREQUENCY_COUNTER_WIDTH);
    signal MclkCounterxDP, MclkCounterxDN : unsigned(MCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0);
    
    constant SCLK_FREQUENCY : integer := SAMPLE_RATE * SCLK_FACTOR;
    constant SCLK_FREQUENCY_COUNTER_WIDTH : integer := getVectorSize(INPUTCLOCK_FREQUENCY / SCLK_FREQUENCY - 1);
    constant SCLK_FREQUENCY_COUNTER_MAXVALUE : unsigned(SCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0) := to_unsigned(INPUTCLOCK_FREQUENCY / SCLK_FREQUENCY - 1, SCLK_FREQUENCY_COUNTER_WIDTH);
    signal SclkCounterxDP, SclkCounterxDN : unsigned(SCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0);
    
    constant LRCLK_FREQUENCY : integer := SAMPLE_RATE;
    constant LRCLK_FREQUENCY_COUNTER_WIDTH : integer:= getVectorSize(INPUTCLOCK_FREQUENCY / LRCLK_FREQUENCY - 1); 
    constant LRCLK_FREQUENCY_COUNTER_MAXVALUE : unsigned(LRCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0) := to_unsigned(INPUTCLOCK_FREQUENCY / LRCLK_FREQUENCY - 1, LRCLK_FREQUENCY_COUNTER_WIDTH);
    signal LrclkCounterxDP, LrclkCounterxDN : unsigned(LRCLK_FREQUENCY_COUNTER_WIDTH - 1 downto 0);
    
    signal LeftDataxDP, LeftDataxDN : std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
    signal RightDataxDP, RightDataxDN : std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
    
    signal WriteDataxS : std_logic;
    
    signal TValidLastStatexDP, TValidLastStatexDN : std_logic;
begin
	S_AXIS_TREADY <= '1' when I2SDriverStatexDP = STANDBY else '0';
    
    DA_MCLK <= '1' when MclkCounterxDP > to_unsigned(to_integer(MCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, MCLK_FREQUENCY_COUNTER_WIDTH) else '0';
    
    DA_LRCK <= '1' when I2SDriverStatexDP = WAITFORLEFTDATA or I2SDriverStatexDP = SENDRIGHTDATA else '0';
    
    DA_SCLK <= '1' when SclkCounterxDP > to_unsigned(to_integer(SCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, SCLK_FREQUENCY_COUNTER_WIDTH) else '0';
    
    DA_SDO <= OutputRegisterxDP(AUDIO_DATA_WIDTH* 2 - 1 + 1);
    
    MclkCounterxDN <= MclkCounterxDP + 1 when MclkCounterxDP < MCLK_FREQUENCY_COUNTER_MAXVALUE else (others => '0');
    
    LrclkCounterxDN <= LrclkCounterxDP + 1 when LrclkCounterxDP < LRCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
    
    SclkCounterxDN <= SclkCounterxDP + 1 when SclkCounterxDP < SCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
    
    SendNextDataxS <= '1' when SclkCounterxDP = SCLK_FREQUENCY_COUNTER_MAXVALUE and (I2SDriverStatexDP = SENDLEFTDATA or I2SDriverStatexDP = SENDRIGHTDATA) else '0';
    
 
    TValidLastStatexDN <= S_AXIS_TVALID;
    
    WriteDataxS <= '1' when TvalidLastStatexDP = '1' and S_AXIS_TVALID = '0' else '0';
    
    LeftDataxDN <= S_AXIS_TDATA(AUDIO_DATA_WIDTH - 1 downto 0) when S_AXIS_TVALID = '1' and S_AXIS_TLAST = '0' else LeftDataxDP;
    RightDataxDN <= S_AXIS_TDATA(AUDIO_DATA_WIDTH - 1 downto 0) when S_AXIS_TVALID = '1' and S_AXIS_TLAST = '1' else RightDataxDP;
    
    DataCounterLogic : process(SendNextDataxS, I2SDriverStatexDP, DataCounterxDP)
    begin
        if(I2SDriverStatexDP = STANDBY) then
            DataCounterxDN <= (others => '0');
        elsif(SendNextDataxS = '1') then
            DataCounterxDN <= DataCounterxDP + 1;
        else
            DataCounterxDN <= DataCounterxDP;
        end if;
    end process;
    
    OutputRegisterLogic : process(LeftDataxDP, RightDataxDP, OutputRegisterxDP, I2SDriverStatexDP, WriteDataxS, SendNextDataxS)
    begin
        case I2SDriverStatexDP is
            when STANDBY =>
                if(WriteDataxS = '1') then
                    OutputRegisterxDN <= '0' & LeftDataxDP & RightDataxDP;
                else
                    OutputRegisterxDN <= (others => '0');
                end if;
            when SENDLEFTDATA =>
                if(SendNextDataxS = '1') then
                    OutputRegisterxDN <= OutputRegisterxDP(AUDIO_DATA_WIDTH * 2 - 2 + 1 downto 0) & '0';
                else
                    OutputRegisterxDN <= OutputRegisterxDP;
                end if;
            when WAITFORRIGHTDATA =>
                OutputRegisterxDN <= OutputRegisterxDP;
            when SENDRIGHTDATA =>
                if(SendNextDataxS = '1') then
                    OutputRegisterxDN <= OutputRegisterxDP(AUDIO_DATA_WIDTH * 2 - 2 + 1 downto 0) & '0';
                else
                    OutputRegisterxDN <= OutputRegisterxDP;
                end if;
            when WAITFORLEFTDATA =>
                OutputRegisterxDN <= (others => '0');
        end case;
    end process;

    I2SStateLogic : process(WriteDataxS, I2SDriverStatexDP, LrclkCounterxDP, DataCounterxDP)
    begin
        case I2SDriverStatexDP is
            when STANDBY =>
                if(WriteDataxS = '1') then
                    I2SDriverStatexDN <= SENDLEFTDATA;
                else
                    I2SDriverStatexDN <= STANDBY;
                end if;
            when SENDLEFTDATA =>
                if(DataCounterxDP = to_unsigned(AUDIO_DATA_WIDTH - 1 + 1, AUDIO_DATA_COUNTER_WIDTH)) then
                    I2SDriverStatexDN <= WAITFORRIGHTDATA;
                else
                    I2SDriverStatexDN <= SENDLEFTDATA;
                end if;
            when WAITFORRIGHTDATA =>
                if(LrclkCounterxDP = to_unsigned(to_integer(LRCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, LRCLK_FREQUENCY_COUNTER_WIDTH)) then
                    I2SDriverStatexDN <= SENDRIGHTDATA;
                else
                    I2SDriverStatexDN <= WAITFORRIGHTDATA;
                end if;
            when SENDRIGHTDATA =>
                if(DataCounterxDP < to_unsigned(AUDIO_DATA_WIDTH * 2 - 1 + 2, AUDIO_DATA_COUNTER_WIDTH)) then
                    I2SDriverStatexDN <= SENDRIGHTDATA;
                else
                    I2SDriverStatexDN <= WAITFORLEFTDATA;
                end if;
            when WAITFORLEFTDATA =>
                if(LrclkCounterxDP < LRCLK_FREQUENCY_COUNTER_MAXVALUE) then
                    I2SDriverStatexDN <= WAITFORLEFTDATA;
                else
                    I2SDriverStatexDN <= STANDBY;
                end if;
        end case;
    end process;

    RegisterLogic : process(S_AXIS_ACLK, S_AXIS_ARESETN)
    begin
    	if(S_AXIS_ARESETN = '0') then
            OutputRegisterxDP <= (others => '0');
            I2SDriverStatexDP <= STANDBY;
            DataCounterxDP <= (others => '0');
            MclkCounterxDP <= (others => '0');
            LrclkCounterxDP <= (others => '0');
            SclkCounterxDP <= (others => '0');
            RightDataxDP <= (others => '0');
    		LeftDataxDP <= (others => '0');
    		TValidLastStatexDP <= '0';
        elsif(rising_edge(S_AXIS_ACLK)) then
            OutputRegisterxDP <= OutputRegisterxDN;
            I2SDriverStatexDP <= I2SDriverStatexDN;
            DataCounterxDP <= DataCounterxDN;
            MclkCounterxDP <= MclkCounterxDN;
            LrclkCounterxDP <= LrclkCounterxDN;
            SclkCounterxDP <= SclkCounterxDN;
            RightDataxDP <= RightDataxDN;
    		LeftDataxDP <= LeftDataxDN;
    		TValidLastStatexDP <= TValidLastStatexDN;
        end if;
    end process;
end arch_imp;
