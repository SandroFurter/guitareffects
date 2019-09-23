library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GuitarTop is
    port(
        clk : in std_logic;
        rst : in std_logic
    );
end entity GuitarTop;

architecture RTL of GuitarTop is
    component GuitarEffectBD is
  port (
    reset_rtl : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    btns_5bits_tri_i : in STD_LOGIC_VECTOR ( 4 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC
  );
  end component GuitarEffectBD;
begin
    
    i_zynq: component GuitarEffectBD
        port map(
            reset_rtl         => reset_rtl,
            sys_clock         => sys_clock,
            btns_5bits_tri_i  => btns_5bits_tri_i,
            DDR_cas_n         => DDR_cas_n,
            DDR_cke           => DDR_cke,
            DDR_ck_n          => DDR_ck_n,
            DDR_ck_p          => DDR_ck_p,
            DDR_cs_n          => DDR_cs_n,
            DDR_reset_n       => DDR_reset_n,
            DDR_odt           => DDR_odt,
            DDR_ras_n         => DDR_ras_n,
            DDR_we_n          => DDR_we_n,
            DDR_ba            => DDR_ba,
            DDR_addr          => DDR_addr,
            DDR_dm            => DDR_dm,
            DDR_dq            => DDR_dq,
            DDR_dqs_n         => DDR_dqs_n,
            DDR_dqs_p         => DDR_dqs_p,
            FIXED_IO_mio      => FIXED_IO_mio,
            FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
            FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
            FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
            FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
            FIXED_IO_ps_porb  => FIXED_IO_ps_porb
        );

end architecture RTL;
