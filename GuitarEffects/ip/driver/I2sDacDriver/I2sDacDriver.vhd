library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MathFunctions.ALL;

entity I2sDacDriver is
    generic(
        AUDIO_DATA_WIDTH : integer := 24;
        INPUTCLOCK_FREQUENCY : integer := 122880e3;
        SAMPLE_RATE : integer := 192e3; -- Choosable between 32e3, 44.1e3, 48e3, 64e3, 88.2e3, 96e3, 128e3, 167.4e3, 192e3
        MCLK_FACTOR : integer := 128; -- CHOSABLE between, 96, 192, 384 and 768
        SCLK_FACTOR : integer := 64
    );
    port(
        -- General Input
        ClkxCI : in std_logic;
        ResetxRI : in std_logic;
        
        -- Control and Data Signals
        LeftDataxDI : in std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
        RightDataxDI : in std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
        WriteDataxSI : in std_logic;
        BusyxSO : out std_logic;
        
        -- Signals to DAC
        DA_MCLK : out std_logic;
        DA_LRCK : out std_logic;
        DA_SCLK : out std_logic;
        DA_SDO : out std_logic
    );
end entity I2sDacDriver;

architecture RTL of I2sDacDriver is
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
    
begin
    BusyxSO <= '0' when I2SDriverStatexDP = STANDBY else '1';
    
    DA_MCLK <= '1' when MclkCounterxDP > to_unsigned(to_integer(MCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, MCLK_FREQUENCY_COUNTER_WIDTH) else '0';
    
    DA_LRCK <= '1' when I2SDriverStatexDP = WAITFORLEFTDATA or I2SDriverStatexDP = SENDRIGHTDATA else '0';
    
    DA_SCLK <= '1' when SclkCounterxDP > to_unsigned(to_integer(SCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, SCLK_FREQUENCY_COUNTER_WIDTH) else '0';
    
    DA_SDO <= OutputRegisterxDP(AUDIO_DATA_WIDTH* 2 - 1 + 1);
    
    MclkCounterxDN <= MclkCounterxDP + 1 when MclkCounterxDP < MCLK_FREQUENCY_COUNTER_MAXVALUE else (others => '0');
    
    LrclkCounterxDN <= LrclkCounterxDP + 1 when LrclkCounterxDP < LRCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
    
    SclkCounterxDN <= SclkCounterxDP + 1 when SclkCounterxDP < SCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
    
    SendNextDataxS <= '1' when SclkCounterxDP = SCLK_FREQUENCY_COUNTER_MAXVALUE and (I2SDriverStatexDP = SENDLEFTDATA or I2SDriverStatexDP = SENDRIGHTDATA) else '0';
    
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
    
    OutputRegisterLogic : process(LeftDataxDI, RightDataxDI, OutputRegisterxDP, I2SDriverStatexDP, WriteDataxSI, SendNextDataxS)
    begin
        case I2SDriverStatexDP is
            when STANDBY =>
                if(WriteDataxSI = '1') then
                    OutputRegisterxDN <= '0' & LeftDataxDI & RightDataxDI;
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

    I2SStateLogic : process(WriteDataxSI, I2SDriverStatexDP, LrclkCounterxDP, DataCounterxDP)
    begin
        case I2SDriverStatexDP is
            when STANDBY =>
                if(WriteDataxSI = '1') then
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

    RegisterLogic : process(ClkxCI)
    begin
        if(rising_edge(ClkxCI)) then
            if(ResetxRI = '1') then
                OutputRegisterxDP <= (others => '0');
                I2SDriverStatexDP <= STANDBY;
                DataCounterxDP <= (others => '0');
                MclkCounterxDP <= (others => '0');
                LrclkCounterxDP <= (others => '0');
                SclkCounterxDP <= (others => '0');
            else
                OutputRegisterxDP <= OutputRegisterxDN;
                I2SDriverStatexDP <= I2SDriverStatexDN;
                DataCounterxDP <= DataCounterxDN;
                MclkCounterxDP <= MclkCounterxDN;
                LrclkCounterxDP <= LrclkCounterxDN;
                SclkCounterxDP <= SclkCounterxDN;
            end if;
        end if;
    end process;
end architecture RTL;
