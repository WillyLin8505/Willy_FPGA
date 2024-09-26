-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Mon Sep 23 19:36:14 2024
-- Host        : DESKTOP-6O0UNV6 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_seven_seg_1_0_sim_netlist.vhdl
-- Design      : design_1_seven_seg_1_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg is
  port (
    o_seg : out STD_LOGIC_VECTOR ( 6 downto 0 );
    o_seg_sel : out STD_LOGIC;
    i_button_clr : in STD_LOGIC;
    i_button_mis : in STD_LOGIC;
    i_button_add : in STD_LOGIC;
    clk : in STD_LOGIC;
    rst_n : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg is
  signal \deb_cnt[3]_i_1_n_0\ : STD_LOGIC;
  signal \deb_cnt[4]_i_1_n_0\ : STD_LOGIC;
  signal \deb_cnt[4]_i_2_n_0\ : STD_LOGIC;
  signal \deb_cnt[5]_i_1_n_0\ : STD_LOGIC;
  signal \deb_cnt[5]_i_2_n_0\ : STD_LOGIC;
  signal \deb_cnt[6]_i_1_n_0\ : STD_LOGIC;
  signal \deb_cnt[7]_i_1_n_0\ : STD_LOGIC;
  signal \deb_cnt[7]_i_2_n_0\ : STD_LOGIC;
  signal \deb_cnt[7]_i_3_n_0\ : STD_LOGIC;
  signal deb_cnt_nxt : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal deb_cnt_reg : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \o_seg[0]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[1]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[2]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[3]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[4]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[5]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[6]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[6]_i_3_n_0\ : STD_LOGIC;
  signal o_seg_nxt : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal seg_sel : STD_LOGIC;
  signal seg_sel_nxt : STD_LOGIC;
  signal \seq_1st_cnt[0]_i_1_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[0]_i_2_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[2]_i_2_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[2]_i_3_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[2]_i_4_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[2]_i_5_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_1_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_3_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_4_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_5_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_6_n_0\ : STD_LOGIC;
  signal seq_1st_cnt_nxt : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \seq_1st_cnt_reg_n_0_[0]\ : STD_LOGIC;
  signal \seq_1st_cnt_reg_n_0_[1]\ : STD_LOGIC;
  signal \seq_1st_cnt_reg_n_0_[2]\ : STD_LOGIC;
  signal \seq_1st_cnt_reg_n_0_[3]\ : STD_LOGIC;
  signal \seq_2nd_cnt[1]_i_1_n_0\ : STD_LOGIC;
  signal \seq_2nd_cnt[2]_i_1_n_0\ : STD_LOGIC;
  signal \seq_2nd_cnt[3]_i_1_n_0\ : STD_LOGIC;
  signal \seq_2nd_cnt[3]_i_2_n_0\ : STD_LOGIC;
  signal \seq_2nd_cnt[3]_i_3_n_0\ : STD_LOGIC;
  signal seq_2nd_cnt_nxt : STD_LOGIC_VECTOR ( 0 to 0 );
  signal seq_2nd_cnt_reg : STD_LOGIC_VECTOR ( 3 downto 0 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \deb_cnt[0]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \deb_cnt[1]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \deb_cnt[4]_i_2\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \deb_cnt[5]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \o_seg[0]_i_2\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \o_seg[1]_i_2\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \o_seg[2]_i_2\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \o_seg[3]_i_2\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \o_seg[4]_i_2\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \o_seg[5]_i_2\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \o_seg[6]_i_3\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \seq_1st_cnt[1]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \seq_1st_cnt[2]_i_4\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \seq_1st_cnt[2]_i_5\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_3\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_6\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \seq_2nd_cnt[0]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \seq_2nd_cnt[1]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \seq_2nd_cnt[2]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \seq_2nd_cnt[3]_i_3\ : label is "soft_lutpair8";
begin
\deb_cnt[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"5554"
    )
        port map (
      I0 => deb_cnt_reg(0),
      I1 => i_button_clr,
      I2 => i_button_mis,
      I3 => i_button_add,
      O => deb_cnt_nxt(0)
    );
\deb_cnt[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"66666660"
    )
        port map (
      I0 => deb_cnt_reg(0),
      I1 => deb_cnt_reg(1),
      I2 => i_button_clr,
      I3 => i_button_mis,
      I4 => i_button_add,
      O => deb_cnt_nxt(1)
    );
\deb_cnt[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7878787878787800"
    )
        port map (
      I0 => deb_cnt_reg(1),
      I1 => deb_cnt_reg(0),
      I2 => deb_cnt_reg(2),
      I3 => i_button_clr,
      I4 => i_button_mis,
      I5 => i_button_add,
      O => deb_cnt_nxt(2)
    );
\deb_cnt[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"15554000"
    )
        port map (
      I0 => \deb_cnt[4]_i_2_n_0\,
      I1 => deb_cnt_reg(0),
      I2 => deb_cnt_reg(1),
      I3 => deb_cnt_reg(2),
      I4 => deb_cnt_reg(3),
      O => \deb_cnt[3]_i_1_n_0\
    );
\deb_cnt[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1555555540000000"
    )
        port map (
      I0 => \deb_cnt[4]_i_2_n_0\,
      I1 => deb_cnt_reg(2),
      I2 => deb_cnt_reg(1),
      I3 => deb_cnt_reg(0),
      I4 => deb_cnt_reg(3),
      I5 => deb_cnt_reg(4),
      O => \deb_cnt[4]_i_1_n_0\
    );
\deb_cnt[4]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => i_button_add,
      I1 => i_button_mis,
      I2 => i_button_clr,
      O => \deb_cnt[4]_i_2_n_0\
    );
\deb_cnt[5]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FE0000FE"
    )
        port map (
      I0 => i_button_clr,
      I1 => i_button_mis,
      I2 => i_button_add,
      I3 => \deb_cnt[5]_i_2_n_0\,
      I4 => deb_cnt_reg(5),
      O => \deb_cnt[5]_i_1_n_0\
    );
\deb_cnt[5]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFFFFFF"
    )
        port map (
      I0 => deb_cnt_reg(3),
      I1 => deb_cnt_reg(0),
      I2 => deb_cnt_reg(1),
      I3 => deb_cnt_reg(2),
      I4 => deb_cnt_reg(4),
      O => \deb_cnt[5]_i_2_n_0\
    );
\deb_cnt[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FE0000FE"
    )
        port map (
      I0 => i_button_clr,
      I1 => i_button_mis,
      I2 => i_button_add,
      I3 => \deb_cnt[7]_i_3_n_0\,
      I4 => deb_cnt_reg(6),
      O => \deb_cnt[6]_i_1_n_0\
    );
\deb_cnt[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F7F7F7F7F7F7F7FF"
    )
        port map (
      I0 => deb_cnt_reg(6),
      I1 => deb_cnt_reg(7),
      I2 => \deb_cnt[7]_i_3_n_0\,
      I3 => i_button_clr,
      I4 => i_button_mis,
      I5 => i_button_add,
      O => \deb_cnt[7]_i_1_n_0\
    );
\deb_cnt[7]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FE00FEFE00FE0000"
    )
        port map (
      I0 => i_button_clr,
      I1 => i_button_mis,
      I2 => i_button_add,
      I3 => \deb_cnt[7]_i_3_n_0\,
      I4 => deb_cnt_reg(6),
      I5 => deb_cnt_reg(7),
      O => \deb_cnt[7]_i_2_n_0\
    );
\deb_cnt[7]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => deb_cnt_reg(4),
      I1 => deb_cnt_reg(2),
      I2 => deb_cnt_reg(1),
      I3 => deb_cnt_reg(0),
      I4 => deb_cnt_reg(3),
      I5 => deb_cnt_reg(5),
      O => \deb_cnt[7]_i_3_n_0\
    );
\deb_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[7]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => deb_cnt_nxt(0),
      Q => deb_cnt_reg(0)
    );
\deb_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[7]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => deb_cnt_nxt(1),
      Q => deb_cnt_reg(1)
    );
\deb_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[7]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => deb_cnt_nxt(2),
      Q => deb_cnt_reg(2)
    );
\deb_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[7]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt[3]_i_1_n_0\,
      Q => deb_cnt_reg(3)
    );
\deb_cnt_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[7]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt[4]_i_1_n_0\,
      Q => deb_cnt_reg(4)
    );
\deb_cnt_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[7]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt[5]_i_1_n_0\,
      Q => deb_cnt_reg(5)
    );
\deb_cnt_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[7]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt[6]_i_1_n_0\,
      Q => deb_cnt_reg(6)
    );
\deb_cnt_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[7]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt[7]_i_2_n_0\,
      Q => deb_cnt_reg(7)
    );
\o_seg[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"11EDFFFF11ED0000"
    )
        port map (
      I0 => seq_2nd_cnt_reg(2),
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(0),
      I3 => seq_2nd_cnt_reg(3),
      I4 => seg_sel,
      I5 => \o_seg[0]_i_2_n_0\,
      O => o_seg_nxt(0)
    );
\o_seg[0]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"3365"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[2]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => \seq_1st_cnt_reg_n_0_[1]\,
      O => \o_seg[0]_i_2_n_0\
    );
\o_seg[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"039FFFFF039F0000"
    )
        port map (
      I0 => seq_2nd_cnt_reg(0),
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(2),
      I3 => seq_2nd_cnt_reg(3),
      I4 => seg_sel,
      I5 => \o_seg[1]_i_2_n_0\,
      O => o_seg_nxt(1)
    );
\o_seg[1]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"059F"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[1]\,
      I1 => \seq_1st_cnt_reg_n_0_[0]\,
      I2 => \seq_1st_cnt_reg_n_0_[2]\,
      I3 => \seq_1st_cnt_reg_n_0_[3]\,
      O => \o_seg[1]_i_2_n_0\
    );
\o_seg[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF001100FB"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[2]\,
      I1 => \seq_1st_cnt_reg_n_0_[1]\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => seg_sel,
      I4 => \seq_1st_cnt_reg_n_0_[3]\,
      I5 => \o_seg[2]_i_2_n_0\,
      O => o_seg_nxt(2)
    );
\o_seg[2]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"444440CC"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => seg_sel,
      I2 => seq_2nd_cnt_reg(0),
      I3 => seq_2nd_cnt_reg(1),
      I4 => seq_2nd_cnt_reg(2),
      O => \o_seg[2]_i_2_n_0\
    );
\o_seg[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF0000056B"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[1]\,
      I1 => \seq_1st_cnt_reg_n_0_[0]\,
      I2 => \seq_1st_cnt_reg_n_0_[2]\,
      I3 => \seq_1st_cnt_reg_n_0_[3]\,
      I4 => seg_sel,
      I5 => \o_seg[3]_i_2_n_0\,
      O => o_seg_nxt(3)
    );
\o_seg[3]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0228220A"
    )
        port map (
      I0 => seg_sel,
      I1 => seq_2nd_cnt_reg(3),
      I2 => seq_2nd_cnt_reg(2),
      I3 => seq_2nd_cnt_reg(1),
      I4 => seq_2nd_cnt_reg(0),
      O => \o_seg[3]_i_2_n_0\
    );
\o_seg[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF01004500"
    )
        port map (
      I0 => seq_2nd_cnt_reg(0),
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(2),
      I3 => seg_sel,
      I4 => seq_2nd_cnt_reg(3),
      I5 => \o_seg[4]_i_2_n_0\,
      O => o_seg_nxt(4)
    );
\o_seg[4]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00001103"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[3]\,
      I1 => seg_sel,
      I2 => \seq_1st_cnt_reg_n_0_[2]\,
      I3 => \seq_1st_cnt_reg_n_0_[1]\,
      I4 => \seq_1st_cnt_reg_n_0_[0]\,
      O => \o_seg[4]_i_2_n_0\
    );
\o_seg[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0371FFFF03710000"
    )
        port map (
      I0 => seq_2nd_cnt_reg(0),
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(2),
      I3 => seq_2nd_cnt_reg(3),
      I4 => seg_sel,
      I5 => \o_seg[5]_i_2_n_0\,
      O => o_seg_nxt(5)
    );
\o_seg[5]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"130D"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      I3 => \seq_1st_cnt_reg_n_0_[2]\,
      O => \o_seg[5]_i_2_n_0\
    );
\o_seg[6]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"155AFFFF155A0000"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => seq_2nd_cnt_reg(0),
      I2 => seq_2nd_cnt_reg(2),
      I3 => seq_2nd_cnt_reg(1),
      I4 => seg_sel,
      I5 => \o_seg[6]_i_3_n_0\,
      O => o_seg_nxt(6)
    );
\o_seg[6]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => rst_n,
      O => \o_seg[6]_i_2_n_0\
    );
\o_seg[6]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"037C"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[1]\,
      I2 => \seq_1st_cnt_reg_n_0_[2]\,
      I3 => \seq_1st_cnt_reg_n_0_[3]\,
      O => \o_seg[6]_i_3_n_0\
    );
\o_seg_reg[0]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => o_seg_nxt(0),
      PRE => \o_seg[6]_i_2_n_0\,
      Q => o_seg(0)
    );
\o_seg_reg[1]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => o_seg_nxt(1),
      PRE => \o_seg[6]_i_2_n_0\,
      Q => o_seg(1)
    );
\o_seg_reg[2]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => o_seg_nxt(2),
      PRE => \o_seg[6]_i_2_n_0\,
      Q => o_seg(2)
    );
\o_seg_reg[3]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => o_seg_nxt(3),
      PRE => \o_seg[6]_i_2_n_0\,
      Q => o_seg(3)
    );
\o_seg_reg[4]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => o_seg_nxt(4),
      PRE => \o_seg[6]_i_2_n_0\,
      Q => o_seg(4)
    );
\o_seg_reg[5]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => o_seg_nxt(5),
      PRE => \o_seg[6]_i_2_n_0\,
      Q => o_seg(5)
    );
\o_seg_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg[6]_i_2_n_0\,
      D => o_seg_nxt(6),
      Q => o_seg(6)
    );
o_seg_sel_reg: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg[6]_i_2_n_0\,
      D => seg_sel,
      Q => o_seg_sel
    );
seg_sel_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => seg_sel,
      O => seg_sel_nxt
    );
seg_sel_reg: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg[6]_i_2_n_0\,
      D => seg_sel_nxt,
      Q => seg_sel
    );
\seq_1st_cnt[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt[0]_i_2_n_0\,
      O => \seq_1st_cnt[0]_i_1_n_0\
    );
\seq_1st_cnt[0]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0020000000000000"
    )
        port map (
      I0 => i_button_clr,
      I1 => \seq_1st_cnt[3]_i_5_n_0\,
      I2 => deb_cnt_reg(1),
      I3 => deb_cnt_reg(0),
      I4 => deb_cnt_reg(5),
      I5 => deb_cnt_reg(2),
      O => \seq_1st_cnt[0]_i_2_n_0\
    );
\seq_1st_cnt[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"40040440"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_4_n_0\,
      I1 => \seq_1st_cnt[2]_i_2_n_0\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => \seq_1st_cnt_reg_n_0_[1]\,
      I4 => i_button_mis,
      O => seq_1st_cnt_nxt(1)
    );
\seq_1st_cnt[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4440044400044000"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_4_n_0\,
      I1 => \seq_1st_cnt[2]_i_2_n_0\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => \seq_1st_cnt_reg_n_0_[1]\,
      I4 => i_button_mis,
      I5 => \seq_1st_cnt_reg_n_0_[2]\,
      O => seq_1st_cnt_nxt(2)
    );
\seq_1st_cnt[2]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFDFFFFFFFF"
    )
        port map (
      I0 => \seq_1st_cnt[2]_i_3_n_0\,
      I1 => \seq_1st_cnt[2]_i_4_n_0\,
      I2 => \seq_1st_cnt[2]_i_5_n_0\,
      I3 => \seq_1st_cnt[3]_i_6_n_0\,
      I4 => \seq_1st_cnt[3]_i_5_n_0\,
      I5 => i_button_mis,
      O => \seq_1st_cnt[2]_i_2_n_0\
    );
\seq_1st_cnt[2]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[2]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      O => \seq_1st_cnt[2]_i_3_n_0\
    );
\seq_1st_cnt[2]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[1]\,
      O => \seq_1st_cnt[2]_i_4_n_0\
    );
\seq_1st_cnt[2]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0001"
    )
        port map (
      I0 => seq_2nd_cnt_reg(0),
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(2),
      I3 => seq_2nd_cnt_reg(3),
      O => \seq_1st_cnt[2]_i_5_n_0\
    );
\seq_1st_cnt[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0F0E"
    )
        port map (
      I0 => i_button_clr,
      I1 => i_button_add,
      I2 => \seq_1st_cnt[3]_i_3_n_0\,
      I3 => i_button_mis,
      O => \seq_1st_cnt[3]_i_1_n_0\
    );
\seq_1st_cnt[3]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5554155500014000"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_4_n_0\,
      I1 => \seq_1st_cnt_reg_n_0_[2]\,
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      I3 => \seq_1st_cnt_reg_n_0_[0]\,
      I4 => i_button_mis,
      I5 => \seq_1st_cnt_reg_n_0_[3]\,
      O => seq_1st_cnt_nxt(3)
    );
\seq_1st_cnt[3]_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFF7FF"
    )
        port map (
      I0 => deb_cnt_reg(2),
      I1 => deb_cnt_reg(5),
      I2 => deb_cnt_reg(0),
      I3 => deb_cnt_reg(1),
      I4 => \seq_1st_cnt[3]_i_5_n_0\,
      O => \seq_1st_cnt[3]_i_3_n_0\
    );
\seq_1st_cnt[3]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000000BAAA"
    )
        port map (
      I0 => i_button_clr,
      I1 => \seq_2nd_cnt[3]_i_3_n_0\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => i_button_add,
      I4 => \seq_1st_cnt[3]_i_5_n_0\,
      I5 => \seq_1st_cnt[3]_i_6_n_0\,
      O => \seq_1st_cnt[3]_i_4_n_0\
    );
\seq_1st_cnt[3]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7FFF"
    )
        port map (
      I0 => deb_cnt_reg(7),
      I1 => deb_cnt_reg(6),
      I2 => deb_cnt_reg(4),
      I3 => deb_cnt_reg(3),
      O => \seq_1st_cnt[3]_i_5_n_0\
    );
\seq_1st_cnt[3]_i_6\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"DFFF"
    )
        port map (
      I0 => deb_cnt_reg(1),
      I1 => deb_cnt_reg(0),
      I2 => deb_cnt_reg(5),
      I3 => deb_cnt_reg(2),
      O => \seq_1st_cnt[3]_i_6_n_0\
    );
\seq_1st_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_1st_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \seq_1st_cnt[0]_i_1_n_0\,
      Q => \seq_1st_cnt_reg_n_0_[0]\
    );
\seq_1st_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_1st_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => seq_1st_cnt_nxt(1),
      Q => \seq_1st_cnt_reg_n_0_[1]\
    );
\seq_1st_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_1st_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => seq_1st_cnt_nxt(2),
      Q => \seq_1st_cnt_reg_n_0_[2]\
    );
\seq_1st_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_1st_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => seq_1st_cnt_nxt(3),
      Q => \seq_1st_cnt_reg_n_0_[3]\
    );
\seq_2nd_cnt[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => seq_2nd_cnt_reg(0),
      I1 => \seq_1st_cnt[0]_i_2_n_0\,
      O => seq_2nd_cnt_nxt(0)
    );
\seq_2nd_cnt[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1441"
    )
        port map (
      I0 => \seq_1st_cnt[0]_i_2_n_0\,
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(0),
      I3 => \seq_1st_cnt[2]_i_2_n_0\,
      O => \seq_2nd_cnt[1]_i_1_n_0\
    );
\seq_2nd_cnt[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"15544001"
    )
        port map (
      I0 => \seq_1st_cnt[0]_i_2_n_0\,
      I1 => \seq_1st_cnt[2]_i_2_n_0\,
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(0),
      I4 => seq_2nd_cnt_reg(2),
      O => \seq_2nd_cnt[2]_i_1_n_0\
    );
\seq_2nd_cnt[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000BAAAFFFFFFFF"
    )
        port map (
      I0 => i_button_clr,
      I1 => \seq_2nd_cnt[3]_i_3_n_0\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => i_button_add,
      I4 => \seq_1st_cnt[3]_i_3_n_0\,
      I5 => \seq_1st_cnt[2]_i_2_n_0\,
      O => \seq_2nd_cnt[3]_i_1_n_0\
    );
\seq_2nd_cnt[3]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1555555440000001"
    )
        port map (
      I0 => \seq_1st_cnt[0]_i_2_n_0\,
      I1 => seq_2nd_cnt_reg(0),
      I2 => seq_2nd_cnt_reg(1),
      I3 => \seq_1st_cnt[2]_i_2_n_0\,
      I4 => seq_2nd_cnt_reg(2),
      I5 => seq_2nd_cnt_reg(3),
      O => \seq_2nd_cnt[3]_i_2_n_0\
    );
\seq_2nd_cnt[3]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"EF"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[2]\,
      I1 => \seq_1st_cnt_reg_n_0_[1]\,
      I2 => \seq_1st_cnt_reg_n_0_[3]\,
      O => \seq_2nd_cnt[3]_i_3_n_0\
    );
\seq_2nd_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => seq_2nd_cnt_nxt(0),
      Q => seq_2nd_cnt_reg(0)
    );
\seq_2nd_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \seq_2nd_cnt[1]_i_1_n_0\,
      Q => seq_2nd_cnt_reg(1)
    );
\seq_2nd_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \seq_2nd_cnt[2]_i_1_n_0\,
      Q => seq_2nd_cnt_reg(2)
    );
\seq_2nd_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \seq_2nd_cnt[3]_i_2_n_0\,
      Q => seq_2nd_cnt_reg(3)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  port (
    clk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    i_button_add : in STD_LOGIC;
    i_button_mis : in STD_LOGIC;
    i_button_clr : in STD_LOGIC;
    o_seg : out STD_LOGIC_VECTOR ( 6 downto 0 );
    o_seg_sel : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "design_1_seven_seg_1_0,seven_seg,{}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
  attribute ip_definition_source : string;
  attribute ip_definition_source of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "package_project";
  attribute x_core_info : string;
  attribute x_core_info of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "seven_seg,Vivado 2019.2";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  attribute x_interface_info : string;
  attribute x_interface_info of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of clk : signal is "XIL_INTERFACENAME clk, FREQ_HZ 50000000, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  attribute x_interface_info of rst_n : signal is "xilinx.com:signal:reset:1.0 rst_n RST";
  attribute x_interface_parameter of rst_n : signal is "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0";
begin
U0: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg
     port map (
      clk => clk,
      i_button_add => i_button_add,
      i_button_clr => i_button_clr,
      i_button_mis => i_button_mis,
      o_seg(6 downto 0) => o_seg(6 downto 0),
      o_seg_sel => o_seg_sel,
      rst_n => rst_n
    );
end STRUCTURE;
