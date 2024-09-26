-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Tue Sep 24 19:18:21 2024
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
    i_button_mis : in STD_LOGIC;
    clk : in STD_LOGIC;
    i_button_clr : in STD_LOGIC;
    i_button_add : in STD_LOGIC;
    rst_n : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg is
  signal always_cnt_nxt : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal \always_cnt_reg_n_0_[0]\ : STD_LOGIC;
  signal \always_cnt_reg_n_0_[1]\ : STD_LOGIC;
  signal button_clr_1_eq : STD_LOGIC;
  signal cnt_2nd_add_minus_sgn : STD_LOGIC_VECTOR ( 1 to 1 );
  signal \deb_cnt[0]_i_10_n_0\ : STD_LOGIC;
  signal \deb_cnt[0]_i_11_n_0\ : STD_LOGIC;
  signal \deb_cnt[0]_i_1_n_0\ : STD_LOGIC;
  signal \deb_cnt[0]_i_3_n_0\ : STD_LOGIC;
  signal \deb_cnt[0]_i_4_n_0\ : STD_LOGIC;
  signal \deb_cnt[0]_i_5_n_0\ : STD_LOGIC;
  signal \deb_cnt[0]_i_6_n_0\ : STD_LOGIC;
  signal \deb_cnt[0]_i_7_n_0\ : STD_LOGIC;
  signal \deb_cnt[0]_i_8_n_0\ : STD_LOGIC;
  signal \deb_cnt[0]_i_9_n_0\ : STD_LOGIC;
  signal \deb_cnt[12]_i_2_n_0\ : STD_LOGIC;
  signal \deb_cnt[12]_i_3_n_0\ : STD_LOGIC;
  signal \deb_cnt[12]_i_4_n_0\ : STD_LOGIC;
  signal \deb_cnt[12]_i_5_n_0\ : STD_LOGIC;
  signal \deb_cnt[16]_i_2_n_0\ : STD_LOGIC;
  signal \deb_cnt[4]_i_2_n_0\ : STD_LOGIC;
  signal \deb_cnt[4]_i_3_n_0\ : STD_LOGIC;
  signal \deb_cnt[4]_i_4_n_0\ : STD_LOGIC;
  signal \deb_cnt[4]_i_5_n_0\ : STD_LOGIC;
  signal \deb_cnt[8]_i_2_n_0\ : STD_LOGIC;
  signal \deb_cnt[8]_i_3_n_0\ : STD_LOGIC;
  signal \deb_cnt[8]_i_4_n_0\ : STD_LOGIC;
  signal \deb_cnt[8]_i_5_n_0\ : STD_LOGIC;
  signal deb_cnt_reg : STD_LOGIC_VECTOR ( 16 downto 0 );
  signal \deb_cnt_reg[0]_i_2_n_0\ : STD_LOGIC;
  signal \deb_cnt_reg[0]_i_2_n_1\ : STD_LOGIC;
  signal \deb_cnt_reg[0]_i_2_n_2\ : STD_LOGIC;
  signal \deb_cnt_reg[0]_i_2_n_3\ : STD_LOGIC;
  signal \deb_cnt_reg[0]_i_2_n_4\ : STD_LOGIC;
  signal \deb_cnt_reg[0]_i_2_n_5\ : STD_LOGIC;
  signal \deb_cnt_reg[0]_i_2_n_6\ : STD_LOGIC;
  signal \deb_cnt_reg[0]_i_2_n_7\ : STD_LOGIC;
  signal \deb_cnt_reg[12]_i_1_n_0\ : STD_LOGIC;
  signal \deb_cnt_reg[12]_i_1_n_1\ : STD_LOGIC;
  signal \deb_cnt_reg[12]_i_1_n_2\ : STD_LOGIC;
  signal \deb_cnt_reg[12]_i_1_n_3\ : STD_LOGIC;
  signal \deb_cnt_reg[12]_i_1_n_4\ : STD_LOGIC;
  signal \deb_cnt_reg[12]_i_1_n_5\ : STD_LOGIC;
  signal \deb_cnt_reg[12]_i_1_n_6\ : STD_LOGIC;
  signal \deb_cnt_reg[12]_i_1_n_7\ : STD_LOGIC;
  signal \deb_cnt_reg[16]_i_1_n_7\ : STD_LOGIC;
  signal \deb_cnt_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \deb_cnt_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \deb_cnt_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \deb_cnt_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \deb_cnt_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \deb_cnt_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \deb_cnt_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \deb_cnt_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \deb_cnt_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \deb_cnt_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \deb_cnt_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \deb_cnt_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \deb_cnt_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \deb_cnt_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \deb_cnt_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \deb_cnt_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal deb_keep_nxt : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \deb_keep_reg_n_0_[0]\ : STD_LOGIC;
  signal \deb_keep_reg_n_0_[1]\ : STD_LOGIC;
  signal deb_trg : STD_LOGIC;
  signal \o_seg[1]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[2]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[2]_i_3_n_0\ : STD_LOGIC;
  signal \o_seg[3]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg[3]_i_3_n_0\ : STD_LOGIC;
  signal \o_seg[3]_i_4_n_0\ : STD_LOGIC;
  signal \o_seg[3]_i_5_n_0\ : STD_LOGIC;
  signal \o_seg[6]_i_2_n_0\ : STD_LOGIC;
  signal o_seg_nxt : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal o_seg_sel_nxt : STD_LOGIC;
  signal seg_1 : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal \seq_1st_cnt[3]_i_10_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_11_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_12_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_13_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_14_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_15_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_16_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_1_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_2_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_3_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_4_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_5_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_6_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_9_n_0\ : STD_LOGIC;
  signal seq_1st_cnt_nxt : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal \seq_1st_cnt_reg_n_0_[0]\ : STD_LOGIC;
  signal \seq_1st_cnt_reg_n_0_[1]\ : STD_LOGIC;
  signal \seq_1st_cnt_reg_n_0_[2]\ : STD_LOGIC;
  signal \seq_1st_cnt_reg_n_0_[3]\ : STD_LOGIC;
  signal \seq_2nd_cnt[0]_i_1_n_0\ : STD_LOGIC;
  signal \seq_2nd_cnt[3]_i_1_n_0\ : STD_LOGIC;
  signal seq_2nd_cnt_nxt : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal seq_2nd_cnt_reg : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_deb_cnt_reg[16]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_deb_cnt_reg[16]_i_1_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \always_cnt[1]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \always_cnt[2]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \deb_cnt[0]_i_3\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \deb_cnt[0]_i_6\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \deb_keep[0]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \o_seg[0]_i_2\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \o_seg[1]_i_2\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \o_seg[2]_i_3\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \o_seg[3]_i_3\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \o_seg[3]_i_4\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \o_seg[3]_i_5\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \o_seg[4]_i_2\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \o_seg[5]_i_2\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \o_seg[6]_i_3\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \seq_1st_cnt[0]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \seq_1st_cnt[1]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_10\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_12\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_13\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_15\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_16\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_5\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_6\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_9\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \seq_2nd_cnt[1]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \seq_2nd_cnt[2]_i_1\ : label is "soft_lutpair3";
begin
\always_cnt[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \always_cnt_reg_n_0_[0]\,
      O => always_cnt_nxt(0)
    );
\always_cnt[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \always_cnt_reg_n_0_[0]\,
      I1 => \always_cnt_reg_n_0_[1]\,
      O => always_cnt_nxt(1)
    );
\always_cnt[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => \always_cnt_reg_n_0_[0]\,
      I1 => \always_cnt_reg_n_0_[1]\,
      I2 => o_seg_sel_nxt,
      O => always_cnt_nxt(2)
    );
\always_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg[6]_i_2_n_0\,
      D => always_cnt_nxt(0),
      Q => \always_cnt_reg_n_0_[0]\
    );
\always_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg[6]_i_2_n_0\,
      D => always_cnt_nxt(1),
      Q => \always_cnt_reg_n_0_[1]\
    );
\always_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg[6]_i_2_n_0\,
      D => always_cnt_nxt(2),
      Q => o_seg_sel_nxt
    );
\deb_cnt[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFEFFFFFFFF0000"
    )
        port map (
      I0 => \deb_cnt[0]_i_3_n_0\,
      I1 => \deb_cnt[0]_i_4_n_0\,
      I2 => \deb_cnt[0]_i_5_n_0\,
      I3 => \deb_cnt[0]_i_6_n_0\,
      I4 => \deb_keep_reg_n_0_[1]\,
      I5 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[0]_i_1_n_0\
    );
\deb_cnt[0]_i_10\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(1),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[0]_i_10_n_0\
    );
\deb_cnt[0]_i_11\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"41"
    )
        port map (
      I0 => deb_cnt_reg(0),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[0]_i_11_n_0\
    );
\deb_cnt[0]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7FFF"
    )
        port map (
      I0 => deb_cnt_reg(2),
      I1 => deb_cnt_reg(3),
      I2 => deb_cnt_reg(4),
      I3 => deb_cnt_reg(5),
      O => \deb_cnt[0]_i_3_n_0\
    );
\deb_cnt[0]_i_4\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFFFFFF"
    )
        port map (
      I0 => deb_cnt_reg(15),
      I1 => deb_cnt_reg(16),
      I2 => deb_cnt_reg(14),
      I3 => deb_cnt_reg(0),
      I4 => deb_cnt_reg(1),
      O => \deb_cnt[0]_i_4_n_0\
    );
\deb_cnt[0]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7FFF"
    )
        port map (
      I0 => deb_cnt_reg(10),
      I1 => deb_cnt_reg(11),
      I2 => deb_cnt_reg(12),
      I3 => deb_cnt_reg(13),
      O => \deb_cnt[0]_i_5_n_0\
    );
\deb_cnt[0]_i_6\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7FFF"
    )
        port map (
      I0 => deb_cnt_reg(6),
      I1 => deb_cnt_reg(7),
      I2 => deb_cnt_reg(8),
      I3 => deb_cnt_reg(9),
      O => \deb_cnt[0]_i_6_n_0\
    );
\deb_cnt[0]_i_7\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(0),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[0]_i_7_n_0\
    );
\deb_cnt[0]_i_8\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(3),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[0]_i_8_n_0\
    );
\deb_cnt[0]_i_9\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(2),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[0]_i_9_n_0\
    );
\deb_cnt[12]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(15),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[12]_i_2_n_0\
    );
\deb_cnt[12]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(14),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[12]_i_3_n_0\
    );
\deb_cnt[12]_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(13),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[12]_i_4_n_0\
    );
\deb_cnt[12]_i_5\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(12),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[12]_i_5_n_0\
    );
\deb_cnt[16]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(16),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[16]_i_2_n_0\
    );
\deb_cnt[4]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(7),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[4]_i_2_n_0\
    );
\deb_cnt[4]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(6),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[4]_i_3_n_0\
    );
\deb_cnt[4]_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(5),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[4]_i_4_n_0\
    );
\deb_cnt[4]_i_5\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(4),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[4]_i_5_n_0\
    );
\deb_cnt[8]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(11),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[8]_i_2_n_0\
    );
\deb_cnt[8]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(10),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[8]_i_3_n_0\
    );
\deb_cnt[8]_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(9),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[8]_i_4_n_0\
    );
\deb_cnt[8]_i_5\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"82"
    )
        port map (
      I0 => deb_cnt_reg(8),
      I1 => \deb_keep_reg_n_0_[1]\,
      I2 => \deb_keep_reg_n_0_[0]\,
      O => \deb_cnt[8]_i_5_n_0\
    );
\deb_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[0]_i_2_n_7\,
      Q => deb_cnt_reg(0)
    );
\deb_cnt_reg[0]_i_2\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \deb_cnt_reg[0]_i_2_n_0\,
      CO(2) => \deb_cnt_reg[0]_i_2_n_1\,
      CO(1) => \deb_cnt_reg[0]_i_2_n_2\,
      CO(0) => \deb_cnt_reg[0]_i_2_n_3\,
      CYINIT => '0',
      DI(3 downto 1) => B"000",
      DI(0) => \deb_cnt[0]_i_7_n_0\,
      O(3) => \deb_cnt_reg[0]_i_2_n_4\,
      O(2) => \deb_cnt_reg[0]_i_2_n_5\,
      O(1) => \deb_cnt_reg[0]_i_2_n_6\,
      O(0) => \deb_cnt_reg[0]_i_2_n_7\,
      S(3) => \deb_cnt[0]_i_8_n_0\,
      S(2) => \deb_cnt[0]_i_9_n_0\,
      S(1) => \deb_cnt[0]_i_10_n_0\,
      S(0) => \deb_cnt[0]_i_11_n_0\
    );
\deb_cnt_reg[10]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[8]_i_1_n_5\,
      Q => deb_cnt_reg(10)
    );
\deb_cnt_reg[11]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[8]_i_1_n_4\,
      Q => deb_cnt_reg(11)
    );
\deb_cnt_reg[12]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[12]_i_1_n_7\,
      Q => deb_cnt_reg(12)
    );
\deb_cnt_reg[12]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \deb_cnt_reg[8]_i_1_n_0\,
      CO(3) => \deb_cnt_reg[12]_i_1_n_0\,
      CO(2) => \deb_cnt_reg[12]_i_1_n_1\,
      CO(1) => \deb_cnt_reg[12]_i_1_n_2\,
      CO(0) => \deb_cnt_reg[12]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \deb_cnt_reg[12]_i_1_n_4\,
      O(2) => \deb_cnt_reg[12]_i_1_n_5\,
      O(1) => \deb_cnt_reg[12]_i_1_n_6\,
      O(0) => \deb_cnt_reg[12]_i_1_n_7\,
      S(3) => \deb_cnt[12]_i_2_n_0\,
      S(2) => \deb_cnt[12]_i_3_n_0\,
      S(1) => \deb_cnt[12]_i_4_n_0\,
      S(0) => \deb_cnt[12]_i_5_n_0\
    );
\deb_cnt_reg[13]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[12]_i_1_n_6\,
      Q => deb_cnt_reg(13)
    );
\deb_cnt_reg[14]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[12]_i_1_n_5\,
      Q => deb_cnt_reg(14)
    );
\deb_cnt_reg[15]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[12]_i_1_n_4\,
      Q => deb_cnt_reg(15)
    );
\deb_cnt_reg[16]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[16]_i_1_n_7\,
      Q => deb_cnt_reg(16)
    );
\deb_cnt_reg[16]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \deb_cnt_reg[12]_i_1_n_0\,
      CO(3 downto 0) => \NLW_deb_cnt_reg[16]_i_1_CO_UNCONNECTED\(3 downto 0),
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 1) => \NLW_deb_cnt_reg[16]_i_1_O_UNCONNECTED\(3 downto 1),
      O(0) => \deb_cnt_reg[16]_i_1_n_7\,
      S(3 downto 1) => B"000",
      S(0) => \deb_cnt[16]_i_2_n_0\
    );
\deb_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[0]_i_2_n_6\,
      Q => deb_cnt_reg(1)
    );
\deb_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[0]_i_2_n_5\,
      Q => deb_cnt_reg(2)
    );
\deb_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[0]_i_2_n_4\,
      Q => deb_cnt_reg(3)
    );
\deb_cnt_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[4]_i_1_n_7\,
      Q => deb_cnt_reg(4)
    );
\deb_cnt_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \deb_cnt_reg[0]_i_2_n_0\,
      CO(3) => \deb_cnt_reg[4]_i_1_n_0\,
      CO(2) => \deb_cnt_reg[4]_i_1_n_1\,
      CO(1) => \deb_cnt_reg[4]_i_1_n_2\,
      CO(0) => \deb_cnt_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \deb_cnt_reg[4]_i_1_n_4\,
      O(2) => \deb_cnt_reg[4]_i_1_n_5\,
      O(1) => \deb_cnt_reg[4]_i_1_n_6\,
      O(0) => \deb_cnt_reg[4]_i_1_n_7\,
      S(3) => \deb_cnt[4]_i_2_n_0\,
      S(2) => \deb_cnt[4]_i_3_n_0\,
      S(1) => \deb_cnt[4]_i_4_n_0\,
      S(0) => \deb_cnt[4]_i_5_n_0\
    );
\deb_cnt_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[4]_i_1_n_6\,
      Q => deb_cnt_reg(5)
    );
\deb_cnt_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[4]_i_1_n_5\,
      Q => deb_cnt_reg(6)
    );
\deb_cnt_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[4]_i_1_n_4\,
      Q => deb_cnt_reg(7)
    );
\deb_cnt_reg[8]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[8]_i_1_n_7\,
      Q => deb_cnt_reg(8)
    );
\deb_cnt_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \deb_cnt_reg[4]_i_1_n_0\,
      CO(3) => \deb_cnt_reg[8]_i_1_n_0\,
      CO(2) => \deb_cnt_reg[8]_i_1_n_1\,
      CO(1) => \deb_cnt_reg[8]_i_1_n_2\,
      CO(0) => \deb_cnt_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \deb_cnt_reg[8]_i_1_n_4\,
      O(2) => \deb_cnt_reg[8]_i_1_n_5\,
      O(1) => \deb_cnt_reg[8]_i_1_n_6\,
      O(0) => \deb_cnt_reg[8]_i_1_n_7\,
      S(3) => \deb_cnt[8]_i_2_n_0\,
      S(2) => \deb_cnt[8]_i_3_n_0\,
      S(1) => \deb_cnt[8]_i_4_n_0\,
      S(0) => \deb_cnt[8]_i_5_n_0\
    );
\deb_cnt_reg[9]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[0]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_cnt_reg[8]_i_1_n_6\,
      Q => deb_cnt_reg(9)
    );
\deb_keep[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => i_button_mis,
      I1 => i_button_clr,
      I2 => i_button_add,
      O => deb_keep_nxt(0)
    );
\deb_keep_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg[6]_i_2_n_0\,
      D => deb_keep_nxt(0),
      Q => \deb_keep_reg_n_0_[0]\
    );
\deb_keep_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg[6]_i_2_n_0\,
      D => \deb_keep_reg_n_0_[0]\,
      Q => \deb_keep_reg_n_0_[1]\
    );
\o_seg[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"323DFFFF323D0000"
    )
        port map (
      I0 => seq_2nd_cnt_reg(0),
      I1 => seq_2nd_cnt_reg(3),
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(2),
      I4 => o_seg_sel_nxt,
      I5 => seg_1(0),
      O => o_seg_nxt(0)
    );
\o_seg[0]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"323D"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      I3 => \seq_1st_cnt_reg_n_0_[2]\,
      O => seg_1(0)
    );
\o_seg[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFEAAEEEEE"
    )
        port map (
      I0 => \o_seg[3]_i_2_n_0\,
      I1 => \o_seg[3]_i_3_n_0\,
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      I3 => \seq_1st_cnt_reg_n_0_[0]\,
      I4 => \seq_1st_cnt_reg_n_0_[2]\,
      I5 => \o_seg[1]_i_2_n_0\,
      O => o_seg_nxt(1)
    );
\o_seg[1]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"40044444"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => o_seg_sel_nxt,
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(0),
      I4 => seq_2nd_cnt_reg(2),
      O => \o_seg[1]_i_2_n_0\
    );
\o_seg[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFABABABAA"
    )
        port map (
      I0 => \o_seg[3]_i_2_n_0\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => o_seg_sel_nxt,
      I3 => \seq_1st_cnt_reg_n_0_[2]\,
      I4 => \o_seg[2]_i_2_n_0\,
      I5 => \o_seg[2]_i_3_n_0\,
      O => o_seg_nxt(2)
    );
\o_seg[2]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[1]\,
      O => \o_seg[2]_i_2_n_0\
    );
\o_seg[2]_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"44404444"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => o_seg_sel_nxt,
      I2 => seq_2nd_cnt_reg(2),
      I3 => seq_2nd_cnt_reg(0),
      I4 => seq_2nd_cnt_reg(1),
      O => \o_seg[2]_i_3_n_0\
    );
\o_seg[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFAEEEEAAE"
    )
        port map (
      I0 => \o_seg[3]_i_2_n_0\,
      I1 => \o_seg[3]_i_3_n_0\,
      I2 => \seq_1st_cnt_reg_n_0_[2]\,
      I3 => \seq_1st_cnt_reg_n_0_[0]\,
      I4 => \seq_1st_cnt_reg_n_0_[1]\,
      I5 => \o_seg[3]_i_4_n_0\,
      O => o_seg_nxt(3)
    );
\o_seg[3]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF00101000001010"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[1]\,
      I1 => \seq_1st_cnt_reg_n_0_[2]\,
      I2 => \seq_1st_cnt_reg_n_0_[3]\,
      I3 => \o_seg[3]_i_5_n_0\,
      I4 => o_seg_sel_nxt,
      I5 => seq_2nd_cnt_reg(3),
      O => \o_seg[3]_i_2_n_0\
    );
\o_seg[3]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => o_seg_sel_nxt,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      O => \o_seg[3]_i_3_n_0\
    );
\o_seg[3]_i_4\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"04444004"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => o_seg_sel_nxt,
      I2 => seq_2nd_cnt_reg(2),
      I3 => seq_2nd_cnt_reg(0),
      I4 => seq_2nd_cnt_reg(1),
      O => \o_seg[3]_i_4_n_0\
    );
\o_seg[3]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => seq_2nd_cnt_reg(1),
      I1 => seq_2nd_cnt_reg(2),
      O => \o_seg[3]_i_5_n_0\
    );
\o_seg[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0207FFFF02070000"
    )
        port map (
      I0 => seq_2nd_cnt_reg(1),
      I1 => seq_2nd_cnt_reg(3),
      I2 => seq_2nd_cnt_reg(0),
      I3 => seq_2nd_cnt_reg(2),
      I4 => o_seg_sel_nxt,
      I5 => seg_1(4),
      O => o_seg_nxt(4)
    );
\o_seg[4]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0207"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[1]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => \seq_1st_cnt_reg_n_0_[2]\,
      O => seg_1(4)
    );
\o_seg[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"121BFFFF121B0000"
    )
        port map (
      I0 => seq_2nd_cnt_reg(2),
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(3),
      I3 => seq_2nd_cnt_reg(0),
      I4 => o_seg_sel_nxt,
      I5 => seg_1(5),
      O => o_seg_nxt(5)
    );
\o_seg[5]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"121B"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[2]\,
      I1 => \seq_1st_cnt_reg_n_0_[1]\,
      I2 => \seq_1st_cnt_reg_n_0_[3]\,
      I3 => \seq_1st_cnt_reg_n_0_[0]\,
      O => seg_1(5)
    );
\o_seg[6]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"161EFFFF161E0000"
    )
        port map (
      I0 => seq_2nd_cnt_reg(2),
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(3),
      I3 => seq_2nd_cnt_reg(0),
      I4 => o_seg_sel_nxt,
      I5 => seg_1(6),
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
      INIT => X"161E"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[2]\,
      I1 => \seq_1st_cnt_reg_n_0_[1]\,
      I2 => \seq_1st_cnt_reg_n_0_[3]\,
      I3 => \seq_1st_cnt_reg_n_0_[0]\,
      O => seg_1(6)
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
      D => o_seg_sel_nxt,
      Q => o_seg_sel
    );
\seq_1st_cnt[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"0B"
    )
        port map (
      I0 => cnt_2nd_add_minus_sgn(1),
      I1 => \seq_1st_cnt_reg_n_0_[0]\,
      I2 => \seq_1st_cnt[3]_i_4_n_0\,
      O => seq_1st_cnt_nxt(0)
    );
\seq_1st_cnt[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"10010110"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_4_n_0\,
      I1 => cnt_2nd_add_minus_sgn(1),
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => \seq_1st_cnt_reg_n_0_[1]\,
      I4 => i_button_mis,
      O => seq_1st_cnt_nxt(1)
    );
\seq_1st_cnt[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1110011100011000"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_4_n_0\,
      I1 => cnt_2nd_add_minus_sgn(1),
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      I3 => \seq_1st_cnt_reg_n_0_[0]\,
      I4 => i_button_mis,
      I5 => \seq_1st_cnt_reg_n_0_[2]\,
      O => seq_1st_cnt_nxt(2)
    );
\seq_1st_cnt[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EFEEFFEECCCCCCCC"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_3_n_0\,
      I1 => \seq_1st_cnt[3]_i_4_n_0\,
      I2 => \seq_1st_cnt[3]_i_5_n_0\,
      I3 => i_button_mis,
      I4 => \seq_1st_cnt[3]_i_6_n_0\,
      I5 => deb_trg,
      O => \seq_1st_cnt[3]_i_1_n_0\
    );
\seq_1st_cnt[3]_i_10\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0400"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[2]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => seq_2nd_cnt_reg(2),
      I3 => seq_2nd_cnt_reg(3),
      O => \seq_1st_cnt[3]_i_10_n_0\
    );
\seq_1st_cnt[3]_i_11\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
        port map (
      I0 => deb_cnt_reg(2),
      I1 => deb_cnt_reg(1),
      I2 => deb_cnt_reg(0),
      O => \seq_1st_cnt[3]_i_11_n_0\
    );
\seq_1st_cnt[3]_i_12\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => deb_cnt_reg(6),
      I1 => deb_cnt_reg(5),
      I2 => deb_cnt_reg(4),
      I3 => deb_cnt_reg(3),
      O => \seq_1st_cnt[3]_i_12_n_0\
    );
\seq_1st_cnt[3]_i_13\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => deb_cnt_reg(10),
      I1 => deb_cnt_reg(9),
      I2 => deb_cnt_reg(8),
      I3 => deb_cnt_reg(7),
      O => \seq_1st_cnt[3]_i_13_n_0\
    );
\seq_1st_cnt[3]_i_14\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8000000000000000"
    )
        port map (
      I0 => deb_cnt_reg(11),
      I1 => deb_cnt_reg(12),
      I2 => deb_cnt_reg(13),
      I3 => deb_cnt_reg(14),
      I4 => deb_cnt_reg(16),
      I5 => deb_cnt_reg(15),
      O => \seq_1st_cnt[3]_i_14_n_0\
    );
\seq_1st_cnt[3]_i_15\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00004000"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[2]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => i_button_add,
      I3 => \seq_1st_cnt_reg_n_0_[0]\,
      I4 => \seq_1st_cnt_reg_n_0_[1]\,
      O => \seq_1st_cnt[3]_i_15_n_0\
    );
\seq_1st_cnt[3]_i_16\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AAAAAAA8"
    )
        port map (
      I0 => i_button_mis,
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(0),
      I3 => seq_2nd_cnt_reg(2),
      I4 => seq_2nd_cnt_reg(3),
      O => \seq_1st_cnt[3]_i_16_n_0\
    );
\seq_1st_cnt[3]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000FBEFAEBA"
    )
        port map (
      I0 => cnt_2nd_add_minus_sgn(1),
      I1 => \seq_1st_cnt[3]_i_9_n_0\,
      I2 => i_button_mis,
      I3 => \seq_1st_cnt_reg_n_0_[2]\,
      I4 => \seq_1st_cnt_reg_n_0_[3]\,
      I5 => \seq_1st_cnt[3]_i_4_n_0\,
      O => \seq_1st_cnt[3]_i_2_n_0\
    );
\seq_1st_cnt[3]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAAAAAAAAA2AAAAA"
    )
        port map (
      I0 => i_button_add,
      I1 => \seq_1st_cnt[3]_i_10_n_0\,
      I2 => seq_2nd_cnt_reg(0),
      I3 => seq_2nd_cnt_reg(1),
      I4 => \seq_1st_cnt_reg_n_0_[0]\,
      I5 => \seq_1st_cnt_reg_n_0_[1]\,
      O => \seq_1st_cnt[3]_i_3_n_0\
    );
\seq_1st_cnt[3]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"C000000080000000"
    )
        port map (
      I0 => i_button_clr,
      I1 => \seq_1st_cnt[3]_i_11_n_0\,
      I2 => \seq_1st_cnt[3]_i_12_n_0\,
      I3 => \seq_1st_cnt[3]_i_13_n_0\,
      I4 => \seq_1st_cnt[3]_i_14_n_0\,
      I5 => \seq_1st_cnt[3]_i_15_n_0\,
      O => \seq_1st_cnt[3]_i_4_n_0\
    );
\seq_1st_cnt[3]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0001"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[3]\,
      I1 => \seq_1st_cnt_reg_n_0_[2]\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => \seq_1st_cnt_reg_n_0_[1]\,
      O => \seq_1st_cnt[3]_i_5_n_0\
    );
\seq_1st_cnt[3]_i_6\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0001"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => seq_2nd_cnt_reg(2),
      I2 => seq_2nd_cnt_reg(0),
      I3 => seq_2nd_cnt_reg(1),
      O => \seq_1st_cnt[3]_i_6_n_0\
    );
\seq_1st_cnt[3]_i_7\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0800000000000000"
    )
        port map (
      I0 => deb_cnt_reg(2),
      I1 => deb_cnt_reg(1),
      I2 => deb_cnt_reg(0),
      I3 => \seq_1st_cnt[3]_i_12_n_0\,
      I4 => \seq_1st_cnt[3]_i_13_n_0\,
      I5 => \seq_1st_cnt[3]_i_14_n_0\,
      O => deb_trg
    );
\seq_1st_cnt[3]_i_8\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8000000000000000"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_5_n_0\,
      I1 => \seq_1st_cnt[3]_i_16_n_0\,
      I2 => \seq_1st_cnt[3]_i_14_n_0\,
      I3 => \seq_1st_cnt[3]_i_13_n_0\,
      I4 => \seq_1st_cnt[3]_i_12_n_0\,
      I5 => \seq_1st_cnt[3]_i_11_n_0\,
      O => cnt_2nd_add_minus_sgn(1)
    );
\seq_1st_cnt[3]_i_9\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E8"
    )
        port map (
      I0 => i_button_mis,
      I1 => \seq_1st_cnt_reg_n_0_[0]\,
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      O => \seq_1st_cnt[3]_i_9_n_0\
    );
\seq_1st_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_1st_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => seq_1st_cnt_nxt(0),
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
      D => \seq_1st_cnt[3]_i_2_n_0\,
      Q => \seq_1st_cnt_reg_n_0_[3]\
    );
\seq_2nd_cnt[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => button_clr_1_eq,
      I1 => seq_2nd_cnt_reg(0),
      O => \seq_2nd_cnt[0]_i_1_n_0\
    );
\seq_2nd_cnt[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0096"
    )
        port map (
      I0 => cnt_2nd_add_minus_sgn(1),
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(0),
      I3 => button_clr_1_eq,
      O => seq_2nd_cnt_nxt(1)
    );
\seq_2nd_cnt[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0000BD42"
    )
        port map (
      I0 => cnt_2nd_add_minus_sgn(1),
      I1 => seq_2nd_cnt_reg(0),
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(2),
      I4 => button_clr_1_eq,
      O => seq_2nd_cnt_nxt(2)
    );
\seq_2nd_cnt[3]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_4_n_0\,
      I1 => cnt_2nd_add_minus_sgn(1),
      O => \seq_2nd_cnt[3]_i_1_n_0\
    );
\seq_2nd_cnt[3]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000DFFB2004"
    )
        port map (
      I0 => seq_2nd_cnt_reg(2),
      I1 => cnt_2nd_add_minus_sgn(1),
      I2 => seq_2nd_cnt_reg(0),
      I3 => seq_2nd_cnt_reg(1),
      I4 => seq_2nd_cnt_reg(3),
      I5 => button_clr_1_eq,
      O => seq_2nd_cnt_nxt(3)
    );
\seq_2nd_cnt[3]_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_14_n_0\,
      I1 => \seq_1st_cnt[3]_i_13_n_0\,
      I2 => \seq_1st_cnt[3]_i_12_n_0\,
      I3 => \seq_1st_cnt[3]_i_11_n_0\,
      I4 => i_button_clr,
      O => button_clr_1_eq
    );
\seq_2nd_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => \seq_2nd_cnt[0]_i_1_n_0\,
      Q => seq_2nd_cnt_reg(0)
    );
\seq_2nd_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => seq_2nd_cnt_nxt(1),
      Q => seq_2nd_cnt_reg(1)
    );
\seq_2nd_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => seq_2nd_cnt_nxt(2),
      Q => seq_2nd_cnt_reg(2)
    );
\seq_2nd_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg[6]_i_2_n_0\,
      D => seq_2nd_cnt_nxt(3),
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
