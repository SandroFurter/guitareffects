----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/26/2019 03:48:57 PM
-- Design Name: 
-- Module Name: AXI_Stream_Slave_tb - Behavioral
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

entity AXI_Stream_Slave_tb is
--  Port ( );
end AXI_Stream_Slave_tb;

architecture Behavioral of AXI_Stream_Slave_tb is
    component axi_stream_filter_v1_0_S00_AXI_STREAM is
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
    end component axi_stream_filter_v1_0_S00_AXI_STREAM;
    
    signal ReadFifoxSI : std_logic := '0';
    signal FifoEmptyxSO : std_logic := '1';
    signal FifoDataValidxSO : std_logic;
    signal FifoDataxDO : std_logic_vector(31 downto 0);
    signal S_AXIS_ACLK : std_logic;
    signal S_AXIS_ARESETN : std_logic;
    signal S_AXIS_TREADY : std_logic;
    signal S_AXIS_TDATA : std_logic_vector(31 downto 0);
    signal S_AXIS_TSTRB : std_logic_vector(3 downto 0);
    signal S_AXIS_TLAST : std_logic;
    signal S_AXIS_TVALID : std_logic;
begin

    DUT : axi_stream_filter_v1_0_S00_AXI_STREAM
    generic map(
        C_S_AXIS_TDATA_WIDTH => 32
    )
    port map(
        ReadFifoxSI => ReadFifoxSI,
		FifoEmptyxSO => FifoEmptyxSO,
		FifoDataValidxSO => FifoDataValidxSO,
		FifoDataxDO => FifoDataxDO,
		S_AXIS_ACLK	=> S_AXIS_ACLK,
		S_AXIS_ARESETN => S_AXIS_ARESETN,
		S_AXIS_TREADY => S_AXIS_TREADY,
		S_AXIS_TDATA => S_AXIS_TDATA,
		S_AXIS_TSTRB => S_AXIS_TSTRB,
		S_AXIS_TLAST => S_AXIS_TLAST,
		S_AXIS_TVALID => S_AXIS_TVALID
    );
    
    S_AXIS_ARESETN <= '0', '1' after 9 us;
    
    S_AXIS_TSTRB <= (others => '1');
    
    AxiStimuli : process
	begin
		S_AXIS_TDATA <= (others => '0');
		S_AXIS_TLAST <= '0';
		S_AXIS_TVALID <= '0';
		wait for 10 us;
		wait until rising_edge(S_AXIS_ACLK);
		wait for 500 ps;
		S_AXIS_TDATA <= x"01FEAF5B";
		S_AXIS_TLAST <= '0';
		S_AXIS_TVALID <= '1';
		wait until rising_edge(S_AXIS_ACLK);
		wait for 500 ps;
		S_AXIS_TDATA <= x"0563C89B";
		S_AXIS_TLAST <= '1';
		S_AXIS_TVALID <= '1';
		wait until rising_edge(S_AXIS_ACLK);
		wait for 500 ps;
		S_AXIS_TDATA <= (others => '0');
		S_AXIS_TLAST <= '0';
		S_AXIS_TVALID <= '0';
		wait for 200 ns;
		wait until S_AXIS_TREADY = '1';
	end process;
	
	ReadLogic : process
	begin
	   wait until rising_edge(S_AXIS_ACLK);
	   if(FifoEmptyxSO = '0') then
	       ReadFifoxSI <= '1';
	   else
	       ReadFifoxSI <= '0';
	   end if;	   
	end process;
    
    ClockGen : process
    begin
        S_AXIS_ACLK <= '1';
        wait for 5 ns;
        S_AXIS_ACLK <= '0';
        wait for 5 ns;
    end process;
end Behavioral;
