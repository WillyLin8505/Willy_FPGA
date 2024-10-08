-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Tue Sep 17 17:52:31 2024
-- Host        : DESKTOP-6O0UNV6 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_seven_seg_0_0_stub.vhdl
-- Design      : design_1_seven_seg_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    clk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    i_buttom_add : in STD_LOGIC;
    i_buttom_mis : in STD_LOGIC;
    i_buttom_clr : in STD_LOGIC;
    o_seg_1 : out STD_LOGIC_VECTOR ( 6 downto 0 );
    o_seg_2 : out STD_LOGIC_VECTOR ( 6 downto 0 )
  );

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,rst_n,i_buttom_add,i_buttom_mis,i_buttom_clr,o_seg_1[6:0],o_seg_2[6:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "seven_seg,Vivado 2019.2";
begin
end;
