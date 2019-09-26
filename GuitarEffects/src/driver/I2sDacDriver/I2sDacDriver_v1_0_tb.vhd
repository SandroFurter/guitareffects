----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/26/2019 08:44:40 AM
-- Design Name: 
-- Module Name: I2sDacDriver_v1_0_tb - Behavioral
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

entity I2sDacDriver_v1_0_tb is
--  Port ( );
end I2sDacDriver_v1_0_tb;

architecture Behavioral of I2sDacDriver_v1_0_tb is
    constant AUDIO_DATA_WIDTH : integer := 24;
	constant INPUT_CLOCK_FREQUENCY : integer := 122880000;
	constant SAMPLE_RATE : integer := 96000;
	constant C_S_AXIS_TDATA_WDITH : integer := 32;
	
	
	-- component declaration
	COMPONENT I2sDacDriver_tb
  PORT (
    DA_MCLK : OUT STD_LOGIC;
    DA_LRCK : OUT STD_LOGIC;
    DA_SCLK : OUT STD_LOGIC;
    DA_SDO : OUT STD_LOGIC;
    s00_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axis_tstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s00_axis_tlast : IN STD_LOGIC;
    s00_axis_tvalid : IN STD_LOGIC;
    s00_axis_tready : OUT STD_LOGIC;
    s00_axis_aclk : IN STD_LOGIC;
    s00_axis_aresetn : IN STD_LOGIC
  );
END COMPONENT;
	signal DA_MCLK : std_logic;
	signal DA_LRCK : std_logic;
	signal DA_SCLK : std_logic;
	signal DA_SDO : std_logic;
	signal s00_axis_aclk : std_logic;
	signal s00_axis_aresetn : std_logic;
	signal s00_axis_tready : std_logic;
	signal s00_axis_tdata : std_logic_vector(C_S_AXIS_TDATA_WDITH - 1 downto 0);
	signal s00_axis_tstrb : std_logic_vector((C_S_AXIS_TDATA_WDITH / 8) - 1 downto 0);
	signal s00_axis_tlast : std_logic;
	signal s00_axis_tvalid : std_logic;
begin
    -- Instantiation of Axi Bus Interface S00_AXIS
I2sDacDriver_v1_0_S00_AXIS_inst : I2sDacDriver_tb
	port map (
		DA_MCLK => DA_MCLK,
        DA_LRCK => DA_LRCK,
        DA_SCLK => DA_SCLK,
        DA_SDO => DA_SDO,
		s00_axis_aclk	=> s00_axis_aclk,
		s00_axis_aresetn	=> s00_axis_aresetn,
		s00_axis_tready	=> s00_axis_tready,
		s00_axis_tdata	=> s00_axis_tdata,
		s00_axis_tstrb	=> s00_axis_tstrb,
		s00_axis_tlast	=> s00_axis_tlast,
		s00_axis_tvalid	=> s00_axis_tvalid
	);
	
	s00_axis_aresetn <= '0', '1' after 19 ns;
	
	s00_axis_tstrb <= (others => '1');
		
	AxiStimuli : process
	begin
		s00_axis_tdata <= (others => '0');
		s00_axis_tlast <= '0';
		s00_axis_tvalid <= '0';
		wait for 31 ns;
		wait until rising_edge(s00_axis_aclk);
		wait for 500 ps;
		s00_axis_tdata <= x"01FEAF5B";
		s00_axis_tlast <= '0';
		s00_axis_tvalid <= '1';
		wait until rising_edge(s00_axis_aclk);
		wait for 500 ps;
		s00_axis_tdata <= x"0563C89B";
		s00_axis_tlast <= '1';
		s00_axis_tvalid <= '1';
		wait until rising_edge(s00_axis_aclk);
		wait for 500 ps;
		s00_axis_tdata <= (others => '0');
		s00_axis_tlast <= '0';
		s00_axis_tvalid <= '0';
		wait for 200 ns;
		wait until s00_axis_tready = '1';
	end process;
	
	ClockStimuli : process
	begin
		s00_axis_aclk <= '1';
		wait for 5 ns;
		s00_axis_aclk <= '0';
		wait for 5 ns;
	end process;


end Behavioral;
