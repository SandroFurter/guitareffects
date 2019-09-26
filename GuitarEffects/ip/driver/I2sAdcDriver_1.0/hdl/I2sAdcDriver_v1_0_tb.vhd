----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2019 11:38:56
-- Design Name: 
-- Module Name: I2sAdcDriver_v1_0_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2sAdcDriver_v1_0_tb is
--  Port ( );
end I2sAdcDriver_v1_0_tb;

architecture Behavioral of I2sAdcDriver_v1_0_tb is

    component I2sAdcDriver_v1_0
    	generic (
            -- I2S
            AUDIO_DATA_WIDTH            : integer := 24;
            INPUTCLOCK_FREQUENCY        : integer := 122880e3;
            SAMPLE_RATE                 : integer := 96e3;
            MCLK_FACTOR                 : integer := 128;
            -- AXI
            C_M00_AXIS_TDATA_WIDTH      : integer	:= 32;
            C_M00_AXIS_START_COUNT	    : integer	:= 32
        );
        port (
            -- I2S
            AD_MCLK               : out std_logic;
            AD_LRCK               : out std_logic;
            AD_SCLK               : out std_logic;
            AD_SDI                : in std_logic;
            ReadDataxSI           : in std_logic;
            -- AXI
            m00_axis_aclk	      : in std_logic;
            m00_axis_aresetn	  : in std_logic;
            m00_axis_tvalid	      : out std_logic;
            m00_axis_tdata	      : out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
            m00_axis_tstrb	      : out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
            m00_axis_tlast	      : out std_logic;
            m00_axis_tready	      : in std_logic
        );
    end component;
    
    -- I2S
    constant AUDIO_DATA_WIDTH_tb        : integer := 24;
    constant INPUTCLOCK_FREQUENCY_tb    : integer := 122880e3;
    constant SAMPLE_RATE_tb             : integer := 96e3; 
    constant MCLK_FACTOR_tb             : integer := 128;
    -- AXI
    constant C_M_AXIS_TDATA_WIDTH_tb	: integer	:= 32;
    constant C_M_START_COUNT_tb	        : integer	:= 32;    
    
    -- I2S
    signal AD_MCLK_tb         : std_logic;
    signal AD_LRCK_tb         : std_logic;
    signal AD_SCLK_tb         : std_logic;
    signal AD_SDI_tb          : std_logic;
    signal ReadDataxSI_tb     : std_logic;
    -- AXI
    signal M_AXIS_ACLK_tb	  : std_logic;
    signal M_AXIS_ARESETN_tb  : std_logic;
    signal M_AXIS_TVALID_tb	  : std_logic;
    signal M_AXIS_TDATA_tb	  : std_logic_vector(C_M_AXIS_TDATA_WIDTH_tb-1 downto 0);
    signal M_AXIS_TSTRB_tb	  : std_logic_vector((C_M_AXIS_TDATA_WIDTH_tb/8)-1 downto 0);
    signal M_AXIS_TLAST_tb	  : std_logic;
    signal M_AXIS_TREADY_tb	  : std_logic;

    constant TbPeriod_tb      : time := 10 ns; -- EDIT Put right period here
    signal TbClock_tb         : std_logic := '0';
    signal TbSimEnded_tb      : std_logic := '0';

begin

    dut : I2sAdcDriver_v1_0
        generic map(
            AUDIO_DATA_WIDTH      => AUDIO_DATA_WIDTH_tb,
            INPUTCLOCK_FREQUENCY  => INPUTCLOCK_FREQUENCY_tb,
            SAMPLE_RATE           => SAMPLE_RATE_tb,
            MCLK_FACTOR           => MCLK_FACTOR_tb,
            -- AXI
            C_M00_AXIS_TDATA_WIDTH  => C_M_AXIS_TDATA_WIDTH_tb,
            C_M00_AXIS_START_COUNT	=> C_M_START_COUNT_tb
        )
        port map (            
            -- I2S
            AD_MCLK                => AD_MCLK_tb,
            AD_LRCK                => AD_LRCK_tb,
            AD_SDI                 => AD_SDI_tb,
            ReadDataxSI            => ReadDataxSI_tb,
            -- AXI
            m00_axis_aclk	         => M_AXIS_ACLK_tb,
            m00_axis_aresetn         => M_AXIS_ARESETN_tb,
            m00_axis_tvalid          => M_AXIS_TVALID_tb,
            m00_axis_tdata           => M_AXIS_TDATA_tb,
            m00_axis_tstrb           => M_AXIS_TSTRB_tb,
            m00_axis_tlast           => M_AXIS_TLAST_tb,
            m00_axis_tready          => M_AXIS_TREADY_tb
        );

    -- Clock generation
    TbClock_tb <= not TbClock_tb after TbPeriod_tb/2 when TbSimEnded_tb /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    M_AXIS_ACLK_tb <= TbClock_tb;
    M_AXIS_ARESETN_tb <= '0', '1' after 20 ns;
     
     Control : process
     begin
        wait for 500 ns;
        M_AXIS_TREADY_tb <= '1';
        ReadDataxSI_tb <= '1';
        AD_SDI_tb <= '1';
                
        for i in 0 to 50 loop
		  WAIT until rising_edge(AD_MCLK_tb);
		  AD_SDI_tb <= not AD_SDI_tb;	
	    END LOOP;
	    
	    wait until rising_edge(AD_LRCK_tb);
	    
        for i in 0 to 50 loop
		  WAIT until rising_edge(AD_MCLK_tb);
		  AD_SDI_tb <= not AD_SDI_tb;	
	    END LOOP;	
        
        wait for 10 ns;
        M_AXIS_TREADY_tb <= '1';
        
        wait for 10 ns;
        M_AXIS_TREADY_tb <= '1';
        
        wait for 20 ms;
        
        TbSimEnded_tb <= '1';
        wait;
     end process;

end Behavioral;
