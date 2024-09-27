-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Tue Sep 17 17:52:31 2024
-- Host        : DESKTOP-6O0UNV6 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_seven_seg_0_0_sim_netlist.vhdl
-- Design      : design_1_seven_seg_0_0
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
    o_seg_1 : out STD_LOGIC_VECTOR ( 6 downto 0 );
    o_seg_2 : out STD_LOGIC_VECTOR ( 6 downto 0 );
    clk : in STD_LOGIC;
    i_buttom_clr : in STD_LOGIC;
    i_buttom_add : in STD_LOGIC;
    i_buttom_mis : in STD_LOGIC;
    rst_n : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg is
  signal \deb_cnt[4]_i_1_n_0\ : STD_LOGIC;
  signal deb_cnt_nxt : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal deb_cnt_reg : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal \o_seg_1[4]_i_1_n_0\ : STD_LOGIC;
  signal \o_seg_1[5]_i_1_n_0\ : STD_LOGIC;
  signal \o_seg_1[6]_i_2_n_0\ : STD_LOGIC;
  signal \o_seg_2[0]_i_1_n_0\ : STD_LOGIC;
  signal \o_seg_2[1]_i_1_n_0\ : STD_LOGIC;
  signal \o_seg_2[2]_i_1_n_0\ : STD_LOGIC;
  signal \o_seg_2[3]_i_1_n_0\ : STD_LOGIC;
  signal \o_seg_2[4]_i_1_n_0\ : STD_LOGIC;
  signal \o_seg_2[5]_i_1_n_0\ : STD_LOGIC;
  signal \o_seg_2[6]_i_1_n_0\ : STD_LOGIC;
  signal seg_com : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal \seq_1st_cnt[0]_i_1_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[0]_i_2_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[2]_i_2_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[2]_i_3_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[2]_i_4_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[2]_i_5_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[2]_i_6_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_1_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_3_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_4_n_0\ : STD_LOGIC;
  signal \seq_1st_cnt[3]_i_5_n_0\ : STD_LOGIC;
  signal seq_1st_cnt_nxt : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \seq_1st_cnt_reg_n_0_[0]\ : STD_LOGIC;
  signal \seq_1st_cnt_reg_n_0_[1]\ : STD_LOGIC;
  signal \seq_1st_cnt_reg_n_0_[2]\ : STD_LOGIC;
  signal \seq_1st_cnt_reg_n_0_[3]\ : STD_LOGIC;
  signal \seq_2nd_cnt[0]_i_1_n_0\ : STD_LOGIC;
  signal \seq_2nd_cnt[2]_i_1_n_0\ : STD_LOGIC;
  signal \seq_2nd_cnt[3]_i_1_n_0\ : STD_LOGIC;
  signal \seq_2nd_cnt[3]_i_2_n_0\ : STD_LOGIC;
  signal seq_2nd_cnt_nxt : STD_LOGIC_VECTOR ( 1 to 1 );
  signal seq_2nd_cnt_reg : STD_LOGIC_VECTOR ( 3 downto 0 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \deb_cnt[0]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \deb_cnt[1]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \deb_cnt[2]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \deb_cnt[3]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \deb_cnt[4]_i_2\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \o_seg_1[0]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \o_seg_1[1]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \o_seg_1[2]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \o_seg_1[3]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \o_seg_1[4]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \o_seg_1[5]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \o_seg_1[6]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \o_seg_2[0]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \o_seg_2[1]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \o_seg_2[2]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \o_seg_2[3]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \o_seg_2[4]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \o_seg_2[5]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \o_seg_2[6]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \seq_1st_cnt[1]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \seq_1st_cnt[2]_i_4\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \seq_1st_cnt[2]_i_6\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_3\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \seq_1st_cnt[3]_i_5\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \seq_2nd_cnt[1]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \seq_2nd_cnt[2]_i_1\ : label is "soft_lutpair2";
begin
\deb_cnt[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => deb_cnt_reg(0),
      O => deb_cnt_nxt(0)
    );
\deb_cnt[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => deb_cnt_reg(0),
      I1 => deb_cnt_reg(1),
      O => deb_cnt_nxt(1)
    );
\deb_cnt[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"6A"
    )
        port map (
      I0 => deb_cnt_reg(2),
      I1 => deb_cnt_reg(1),
      I2 => deb_cnt_reg(0),
      O => deb_cnt_nxt(2)
    );
\deb_cnt[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"6AAA"
    )
        port map (
      I0 => deb_cnt_reg(3),
      I1 => deb_cnt_reg(0),
      I2 => deb_cnt_reg(1),
      I3 => deb_cnt_reg(2),
      O => deb_cnt_nxt(3)
    );
\deb_cnt[4]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_3_n_0\,
      I1 => i_buttom_clr,
      I2 => i_buttom_add,
      I3 => i_buttom_mis,
      O => \deb_cnt[4]_i_1_n_0\
    );
\deb_cnt[4]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"6AAAAAAA"
    )
        port map (
      I0 => deb_cnt_reg(4),
      I1 => deb_cnt_reg(2),
      I2 => deb_cnt_reg(1),
      I3 => deb_cnt_reg(0),
      I4 => deb_cnt_reg(3),
      O => deb_cnt_nxt(4)
    );
\deb_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[4]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => deb_cnt_nxt(0),
      Q => deb_cnt_reg(0)
    );
\deb_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[4]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => deb_cnt_nxt(1),
      Q => deb_cnt_reg(1)
    );
\deb_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[4]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => deb_cnt_nxt(2),
      Q => deb_cnt_reg(2)
    );
\deb_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[4]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => deb_cnt_nxt(3),
      Q => deb_cnt_reg(3)
    );
\deb_cnt_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \deb_cnt[4]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => deb_cnt_nxt(4),
      Q => deb_cnt_reg(4)
    );
\o_seg_1[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0E5B"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[1]\,
      I1 => \seq_1st_cnt_reg_n_0_[0]\,
      I2 => \seq_1st_cnt_reg_n_0_[3]\,
      I3 => \seq_1st_cnt_reg_n_0_[2]\,
      O => seg_com(0)
    );
\o_seg_1[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"213F"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      I3 => \seq_1st_cnt_reg_n_0_[2]\,
      O => seg_com(1)
    );
\o_seg_1[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"332F"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      I3 => \seq_1st_cnt_reg_n_0_[2]\,
      O => seg_com(2)
    );
\o_seg_1[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1563"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[3]\,
      I1 => \seq_1st_cnt_reg_n_0_[2]\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => \seq_1st_cnt_reg_n_0_[1]\,
      O => seg_com(3)
    );
\o_seg_1[4]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0151"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[2]\,
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      I3 => \seq_1st_cnt_reg_n_0_[3]\,
      O => \o_seg_1[4]_i_1_n_0\
    );
\o_seg_1[5]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"130D"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => \seq_1st_cnt_reg_n_0_[1]\,
      I3 => \seq_1st_cnt_reg_n_0_[2]\,
      O => \o_seg_1[5]_i_1_n_0\
    );
\o_seg_1[6]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"037C"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[1]\,
      I2 => \seq_1st_cnt_reg_n_0_[2]\,
      I3 => \seq_1st_cnt_reg_n_0_[3]\,
      O => seg_com(6)
    );
\o_seg_1[6]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => rst_n,
      O => \o_seg_1[6]_i_2_n_0\
    );
\o_seg_1_reg[0]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => seg_com(0),
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_1(0)
    );
\o_seg_1_reg[1]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => seg_com(1),
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_1(1)
    );
\o_seg_1_reg[2]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => seg_com(2),
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_1(2)
    );
\o_seg_1_reg[3]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => seg_com(3),
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_1(3)
    );
\o_seg_1_reg[4]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => \o_seg_1[4]_i_1_n_0\,
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_1(4)
    );
\o_seg_1_reg[5]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => \o_seg_1[5]_i_1_n_0\,
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_1(5)
    );
\o_seg_1_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => seg_com(6),
      Q => o_seg_1(6)
    );
\o_seg_2[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"11ED"
    )
        port map (
      I0 => seq_2nd_cnt_reg(2),
      I1 => seq_2nd_cnt_reg(1),
      I2 => seq_2nd_cnt_reg(0),
      I3 => seq_2nd_cnt_reg(3),
      O => \o_seg_2[0]_i_1_n_0\
    );
\o_seg_2[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"5317"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => seq_2nd_cnt_reg(2),
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(0),
      O => \o_seg_2[1]_i_1_n_0\
    );
\o_seg_2[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"554F"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => seq_2nd_cnt_reg(0),
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(2),
      O => \o_seg_2[2]_i_1_n_0\
    );
\o_seg_2[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1653"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => seq_2nd_cnt_reg(2),
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(0),
      O => \o_seg_2[3]_i_1_n_0\
    );
\o_seg_2[4]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0151"
    )
        port map (
      I0 => seq_2nd_cnt_reg(0),
      I1 => seq_2nd_cnt_reg(2),
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(3),
      O => \o_seg_2[4]_i_1_n_0\
    );
\o_seg_2[5]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"052B"
    )
        port map (
      I0 => seq_2nd_cnt_reg(2),
      I1 => seq_2nd_cnt_reg(0),
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(3),
      O => \o_seg_2[5]_i_1_n_0\
    );
\o_seg_2[6]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"155A"
    )
        port map (
      I0 => seq_2nd_cnt_reg(3),
      I1 => seq_2nd_cnt_reg(0),
      I2 => seq_2nd_cnt_reg(2),
      I3 => seq_2nd_cnt_reg(1),
      O => \o_seg_2[6]_i_1_n_0\
    );
\o_seg_2_reg[0]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => \o_seg_2[0]_i_1_n_0\,
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_2(0)
    );
\o_seg_2_reg[1]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => \o_seg_2[1]_i_1_n_0\,
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_2(1)
    );
\o_seg_2_reg[2]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => \o_seg_2[2]_i_1_n_0\,
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_2(2)
    );
\o_seg_2_reg[3]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => \o_seg_2[3]_i_1_n_0\,
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_2(3)
    );
\o_seg_2_reg[4]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => \o_seg_2[4]_i_1_n_0\,
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_2(4)
    );
\o_seg_2_reg[5]\: unisim.vcomponents.FDPE
     port map (
      C => clk,
      CE => '1',
      D => \o_seg_2[5]_i_1_n_0\,
      PRE => \o_seg_1[6]_i_2_n_0\,
      Q => o_seg_2(5)
    );
\o_seg_2_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => '1',
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => \o_seg_2[6]_i_1_n_0\,
      Q => o_seg_2(6)
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
      INIT => X"0000000000000002"
    )
        port map (
      I0 => i_buttom_clr,
      I1 => deb_cnt_reg(3),
      I2 => deb_cnt_reg(4),
      I3 => deb_cnt_reg(2),
      I4 => deb_cnt_reg(0),
      I5 => deb_cnt_reg(1),
      O => \seq_1st_cnt[0]_i_2_n_0\
    );
\seq_1st_cnt[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"10010110"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_4_n_0\,
      I1 => \seq_1st_cnt[2]_i_2_n_0\,
      I2 => \seq_1st_cnt_reg_n_0_[0]\,
      I3 => \seq_1st_cnt_reg_n_0_[1]\,
      I4 => i_buttom_mis,
      O => seq_1st_cnt_nxt(1)
    );
\seq_1st_cnt[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1011110101000010"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_4_n_0\,
      I1 => \seq_1st_cnt[2]_i_2_n_0\,
      I2 => i_buttom_mis,
      I3 => \seq_1st_cnt_reg_n_0_[0]\,
      I4 => \seq_1st_cnt_reg_n_0_[1]\,
      I5 => \seq_1st_cnt_reg_n_0_[2]\,
      O => seq_1st_cnt_nxt(2)
    );
\seq_1st_cnt[2]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0808080808080008"
    )
        port map (
      I0 => \seq_1st_cnt[2]_i_3_n_0\,
      I1 => \seq_1st_cnt[2]_i_4_n_0\,
      I2 => \seq_1st_cnt[2]_i_5_n_0\,
      I3 => \seq_1st_cnt[2]_i_6_n_0\,
      I4 => seq_2nd_cnt_reg(2),
      I5 => seq_2nd_cnt_reg(3),
      O => \seq_1st_cnt[2]_i_2_n_0\
    );
\seq_1st_cnt[2]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000000002"
    )
        port map (
      I0 => i_buttom_mis,
      I1 => deb_cnt_reg(3),
      I2 => deb_cnt_reg(4),
      I3 => deb_cnt_reg(2),
      I4 => deb_cnt_reg(0),
      I5 => deb_cnt_reg(1),
      O => \seq_1st_cnt[2]_i_3_n_0\
    );
\seq_1st_cnt[2]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[0]\,
      I1 => \seq_1st_cnt_reg_n_0_[1]\,
      O => \seq_1st_cnt[2]_i_4_n_0\
    );
\seq_1st_cnt[2]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[2]\,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      O => \seq_1st_cnt[2]_i_5_n_0\
    );
\seq_1st_cnt[2]_i_6\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => seq_2nd_cnt_reg(1),
      I1 => seq_2nd_cnt_reg(0),
      O => \seq_1st_cnt[2]_i_6_n_0\
    );
\seq_1st_cnt[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0F0E"
    )
        port map (
      I0 => i_buttom_clr,
      I1 => i_buttom_add,
      I2 => \seq_1st_cnt[3]_i_3_n_0\,
      I3 => i_buttom_mis,
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
      I4 => i_buttom_mis,
      I5 => \seq_1st_cnt_reg_n_0_[3]\,
      O => seq_1st_cnt_nxt(3)
    );
\seq_1st_cnt[3]_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFFFFE"
    )
        port map (
      I0 => deb_cnt_reg(1),
      I1 => deb_cnt_reg(0),
      I2 => deb_cnt_reg(2),
      I3 => deb_cnt_reg(4),
      I4 => deb_cnt_reg(3),
      O => \seq_1st_cnt[3]_i_3_n_0\
    );
\seq_1st_cnt[3]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000AEAAAAAA"
    )
        port map (
      I0 => i_buttom_clr,
      I1 => \seq_1st_cnt_reg_n_0_[3]\,
      I2 => \seq_1st_cnt[3]_i_5_n_0\,
      I3 => \seq_1st_cnt_reg_n_0_[0]\,
      I4 => i_buttom_add,
      I5 => \seq_1st_cnt[3]_i_3_n_0\,
      O => \seq_1st_cnt[3]_i_4_n_0\
    );
\seq_1st_cnt[3]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \seq_1st_cnt_reg_n_0_[1]\,
      I1 => \seq_1st_cnt_reg_n_0_[2]\,
      O => \seq_1st_cnt[3]_i_5_n_0\
    );
\seq_1st_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_1st_cnt[3]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => \seq_1st_cnt[0]_i_1_n_0\,
      Q => \seq_1st_cnt_reg_n_0_[0]\
    );
\seq_1st_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_1st_cnt[3]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => seq_1st_cnt_nxt(1),
      Q => \seq_1st_cnt_reg_n_0_[1]\
    );
\seq_1st_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_1st_cnt[3]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => seq_1st_cnt_nxt(2),
      Q => \seq_1st_cnt_reg_n_0_[2]\
    );
\seq_1st_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_1st_cnt[3]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
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
      O => \seq_2nd_cnt[0]_i_1_n_0\
    );
\seq_2nd_cnt[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0096"
    )
        port map (
      I0 => seq_2nd_cnt_reg(1),
      I1 => seq_2nd_cnt_reg(0),
      I2 => \seq_1st_cnt[2]_i_2_n_0\,
      I3 => \seq_1st_cnt[0]_i_2_n_0\,
      O => seq_2nd_cnt_nxt(1)
    );
\seq_2nd_cnt[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"45511004"
    )
        port map (
      I0 => \seq_1st_cnt[0]_i_2_n_0\,
      I1 => \seq_1st_cnt[2]_i_2_n_0\,
      I2 => seq_2nd_cnt_reg(1),
      I3 => seq_2nd_cnt_reg(0),
      I4 => seq_2nd_cnt_reg(2),
      O => \seq_2nd_cnt[2]_i_1_n_0\
    );
\seq_2nd_cnt[3]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \seq_1st_cnt[3]_i_4_n_0\,
      I1 => \seq_1st_cnt[2]_i_2_n_0\,
      O => \seq_2nd_cnt[3]_i_1_n_0\
    );
\seq_2nd_cnt[3]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5515545500400100"
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
\seq_2nd_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => \seq_2nd_cnt[0]_i_1_n_0\,
      Q => seq_2nd_cnt_reg(0)
    );
\seq_2nd_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => seq_2nd_cnt_nxt(1),
      Q => seq_2nd_cnt_reg(1)
    );
\seq_2nd_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
      D => \seq_2nd_cnt[2]_i_1_n_0\,
      Q => seq_2nd_cnt_reg(2)
    );
\seq_2nd_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => clk,
      CE => \seq_2nd_cnt[3]_i_1_n_0\,
      CLR => \o_seg_1[6]_i_2_n_0\,
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
    i_buttom_add : in STD_LOGIC;
    i_buttom_mis : in STD_LOGIC;
    i_buttom_clr : in STD_LOGIC;
    o_seg_1 : out STD_LOGIC_VECTOR ( 6 downto 0 );
    o_seg_2 : out STD_LOGIC_VECTOR ( 6 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "design_1_seven_seg_0_0,seven_seg,{}";
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
      i_buttom_add => i_buttom_add,
      i_buttom_clr => i_buttom_clr,
      i_buttom_mis => i_buttom_mis,
      o_seg_1(6 downto 0) => o_seg_1(6 downto 0),
      o_seg_2(6 downto 0) => o_seg_2(6 downto 0),
      rst_n => rst_n
    );
end STRUCTURE;
