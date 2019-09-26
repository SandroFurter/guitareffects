----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/10/2019 08:42:55 PM
-- Design Name: 
-- Module Name: GainController - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GainController is
    generic(
        AUDIO_DATA_WIDTH : integer := 24

    );
    port(
        -- General Input
        ClkxCI : in std_logic;
        ResetxRI : in std_logic;
        
        -- Control and Data Signals
        LeftDataxDI : in std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
        RightDataxDI : in std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
        LeftDataxDO : out std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
        RightDataxDO : out std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
        
        EnablexSI : in std_logic;
        EnablexSO : out std_logic;
        
        GainSettingxSI : in std_logic_vector(3 downto 0) 

    );
end GainController;

architecture Behavioral of GainController is
    signal LeftCalculatedDataxD : signed(AUDIO_DATA_WIDTH + 5 - 1 downto 0);
    signal RightCalculatedDataxD : signed(AUDIO_DATA_WIDTH + 5 - 1 downto 0);
    
    signal LeftDataxDP, LeftDataxDN : std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
    signal RightDataxDP, RightDataxDN : std_logic_vector(AUDIO_DATA_WIDTH - 1 downto 0);
   
    signal EnablexSP, EnablexSN : std_logic;
begin
    EnablexSN <= EnablexSI;
    
    EnablexSO <= EnablexSP;
    
    LeftDataxDN <= LeftDataxDI when EnablexSI = '1' else LeftDataxDP;
    RightDataxDN <= RightDataxDI when EnablexSI = '1' else RightDataxDP;
    
    LeftCalculatedDataxD <= signed(LeftDataxDP) * signed("0" & GainSettingxSI);  
    RightCalculatedDataxD <= signed(RightDataxDP) * signed("0" & GainSettingxSI);

    LeftDataxDO <= std_logic_vector(LeftCalculatedDataxD(AUDIO_DATA_WIDTH  - 1 downto 0));
    RightDataxDO <= std_logic_vector(RightCalculatedDataxD(AUDIO_DATA_WIDTH - 1 downto 0));

    RegisterLogic : process(ClkxCI)
    begin
        if(rising_edge(ClkxCI)) then
            if(ResetxRI = '1') then
                LeftDataxDP <= (others => '0');
                RightDataxDP <= (others => '0');
                EnablexSP <= '0';
            else
                LeftDataxDP <= LeftDataxDN;
                RightDataxDP <= RightDataxDN;
                EnablexSP <= EnablexSN;
            end if;
        end if;
    end process;
    
end Behavioral;
