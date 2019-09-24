--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
--Date        : Tue Sep 24 14:57:17 2019
--Host        : zrhn2444 running 64-bit major release  (build 9200)
--Command     : generate_target GuitarEffectBD_wrapper.bd
--Design      : GuitarEffectBD_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity GuitarEffectBD_wrapper is
  port (
    AD_LRCK_0 : out STD_LOGIC;
    AD_MCLK_0 : out STD_LOGIC;
    AD_SCLK_0 : out STD_LOGIC;
    AD_SDI_0 : in STD_LOGIC;
    DA_LRCK_0 : out STD_LOGIC;
    DA_MCLK_0 : out STD_LOGIC;
    DA_SCLK_0 : out STD_LOGIC;
    DA_SDO_0 : out STD_LOGIC;
    GainSettingxSI_0 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    reset_rtl : in STD_LOGIC;
    sys_clock : in STD_LOGIC
  );
end GuitarEffectBD_wrapper;

architecture STRUCTURE of GuitarEffectBD_wrapper is
  component GuitarEffectBD is
  port (
    reset_rtl : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    DA_MCLK_0 : out STD_LOGIC;
    DA_LRCK_0 : out STD_LOGIC;
    DA_SCLK_0 : out STD_LOGIC;
    DA_SDO_0 : out STD_LOGIC;
    AD_SDI_0 : in STD_LOGIC;
    AD_MCLK_0 : out STD_LOGIC;
    AD_LRCK_0 : out STD_LOGIC;
    AD_SCLK_0 : out STD_LOGIC;
    GainSettingxSI_0 : in STD_LOGIC_VECTOR ( 3 downto 0 )
  );
  end component GuitarEffectBD;
begin
GuitarEffectBD_i: component GuitarEffectBD
     port map (
      AD_LRCK_0 => AD_LRCK_0,
      AD_MCLK_0 => AD_MCLK_0,
      AD_SCLK_0 => AD_SCLK_0,
      AD_SDI_0 => AD_SDI_0,
      DA_LRCK_0 => DA_LRCK_0,
      DA_MCLK_0 => DA_MCLK_0,
      DA_SCLK_0 => DA_SCLK_0,
      DA_SDO_0 => DA_SDO_0,
      GainSettingxSI_0(3 downto 0) => GainSettingxSI_0(3 downto 0),
      reset_rtl => reset_rtl,
      sys_clock => sys_clock
    );
end STRUCTURE;
