----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/30/2019 07:41:00 PM
-- Design Name: 
-- Module Name: I2sAdcDriver - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.MathFunctions.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2sAdcDriver is
    generic(
        AUDIO_DATA_WIDTH : integer := 24;
        INPUTCLOCK_FREQUENCY : integer := 122880e3;
        SAMPLE_RATE : integer := 96e3; -- Choosable between 32e3, 44.1e3, 48e3, 64e3, 88.2e3, 96e3
        MCLK_FACTOR : integer := 128 -- CHOSABLE between, 96, 192, 384 and 768
    );
    port (
    -- General Input
        ClkxCI : in std_logic;
        ResetxRI : in std_logic;
        
        -- Control and Data Signals
        LeftDataxDO : out std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
        RightDataxDO : out std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
        ReadDataxSI : in std_logic;
        BusyxSO : out std_logic;
        
        -- Signals to ADC
        AD_MCLK : out std_logic;
        AD_LRCK : out std_logic;
        AD_SCLK : out std_logic;
        AD_SDI : in std_logic
     );
end I2sAdcDriver;

architecture Behavioral of I2sAdcDriver is
    type I2SStateType is (STANDBY, SENDLEFTDATA, WAITFORRIGHTDATA, SENDRIGHTDATA, WAITFORLEFTDATA);
    signal I2SDriverStatexDP, I2SDriverStatexDN : I2SStateType;
    
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
    BusyxSO <= '0' when (I2SDriverStatexDP = WAITFORLEFTDATA and I2SDriverStatexDN = SENDLEFTDATA) or I2SDriverStatexDP = STANDBY else '1';

    AD_MCLK <= '1' when MclkCounterxDP > to_unsigned(to_integer(MCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, MCLK_FREQUENCY_COUNTER_WIDTH) else '0';
    
    AD_LRCK <= '1' when I2SDriverStatexDP = WAITFORLEFTDATA or I2SDriverStatexDP = SENDRIGHTDATA else '0';
    
    AD_SCLK <= '1' when SclkCounterxDP > to_unsigned(to_integer(SCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, SCLK_FREQUENCY_COUNTER_WIDTH) else '0';

    
    MclkCounterxDN <= MclkCounterxDP + 1 when MclkCounterxDP < MCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
    
    LrclkCounterxDN <= LrclkCounterxDP + 1 when LrclkCounterxDP < LRCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
    
    SclkCounterxDN <= SclkCounterxDP + 1 when SclkCounterxDP < SCLK_FREQUENCY_COUNTER_MAXVALUE and I2SDriverStatexDP /= STANDBY else (others => '0');
                               
    ReadDataxS <= '1' when SclkCounterxDP = to_unsigned(to_integer(SCLK_FREQUENCY_COUNTER_MAXVALUE) / 2, SCLK_FREQUENCY_COUNTER_WIDTH) and (I2SDriverStatexDP = SENDLEFTDATA or I2SDriverStatexDP = SENDRIGHTDATA) else '0';
    
    LeftDataxDO <= LeftDataxDP;
    
    RightDataxDO <= RightDataxDP;
    
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
    
    InputRegisterLogic : process(I2SDriverStatexDP,ReadDataxS,LeftDataxDP,RightDataxDP, AD_SDI)
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

    RegisterLogic : process(ClkxCI)
    begin
        if(rising_edge(ClkxCI)) then
            if(ResetxRI = '1') then
                I2SDriverStatexDP <= STANDBY;
                DataCounterxDP <= (others => '0');
                MclkCounterxDP <= (others => '0');
                LrclkCounterxDP <= (others => '0');
                SclkCounterxDP <= (others => '0');
                LeftDataxDP <= (others => '0');
                RightDataxDP <= (others => '0');
            else
                I2SDriverStatexDP <= I2SDriverStatexDN;
                DataCounterxDP <= DataCounterxDN;
                MclkCounterxDP <= MclkCounterxDN;
                LrclkCounterxDP <= LrclkCounterxDN;
                SclkCounterxDP <= SclkCounterxDN;
                LeftDataxDP <= LeftDataxDN;
                RightDataxDP <= RightDataxDN;
            end if;
        end if;
    end process;

end Behavioral;
