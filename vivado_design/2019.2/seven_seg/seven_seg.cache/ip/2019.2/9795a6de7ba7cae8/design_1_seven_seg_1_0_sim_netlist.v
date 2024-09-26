// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue Sep 24 08:34:25 2024
// Host        : DESKTOP-6O0UNV6 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_seven_seg_1_0_sim_netlist.v
// Design      : design_1_seven_seg_1_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_seven_seg_1_0,seven_seg,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* ip_definition_source = "package_project" *) 
(* x_core_info = "seven_seg,Vivado 2019.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clk,
    rst_n,
    i_button_add,
    i_button_mis,
    i_button_clr,
    o_seg,
    o_seg_sel);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk, FREQ_HZ 50000000, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input clk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 rst_n RST" *) (* x_interface_parameter = "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input rst_n;
  input i_button_add;
  input i_button_mis;
  input i_button_clr;
  output [6:0]o_seg;
  output o_seg_sel;

  wire clk;
  wire i_button_add;
  wire i_button_clr;
  wire i_button_mis;
  wire [6:0]o_seg;
  wire o_seg_sel;
  wire rst_n;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg U0
       (.clk(clk),
        .i_button_add(i_button_add),
        .i_button_clr(i_button_clr),
        .i_button_mis(i_button_mis),
        .o_seg(o_seg),
        .o_seg_sel(o_seg_sel),
        .rst_n(rst_n));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg
   (o_seg,
    o_seg_sel,
    i_button_clr,
    i_button_mis,
    i_button_add,
    clk,
    rst_n);
  output [6:0]o_seg;
  output o_seg_sel;
  input i_button_clr;
  input i_button_mis;
  input i_button_add;
  input clk;
  input rst_n;

  wire [2:0]always_cnt_nxt;
  wire \always_cnt_reg_n_0_[0] ;
  wire \always_cnt_reg_n_0_[1] ;
  wire clk;
  wire \deb_cnt[3]_i_1_n_0 ;
  wire \deb_cnt[4]_i_1_n_0 ;
  wire \deb_cnt[4]_i_2_n_0 ;
  wire \deb_cnt[5]_i_1_n_0 ;
  wire \deb_cnt[5]_i_2_n_0 ;
  wire \deb_cnt[6]_i_1_n_0 ;
  wire \deb_cnt[7]_i_1_n_0 ;
  wire \deb_cnt[7]_i_2_n_0 ;
  wire \deb_cnt[7]_i_3_n_0 ;
  wire [2:0]deb_cnt_nxt;
  wire [7:0]deb_cnt_reg;
  wire i_button_add;
  wire i_button_clr;
  wire i_button_mis;
  wire [6:0]o_seg;
  wire \o_seg[0]_i_2_n_0 ;
  wire \o_seg[1]_i_2_n_0 ;
  wire \o_seg[2]_i_2_n_0 ;
  wire \o_seg[3]_i_2_n_0 ;
  wire \o_seg[4]_i_2_n_0 ;
  wire \o_seg[5]_i_2_n_0 ;
  wire \o_seg[6]_i_2_n_0 ;
  wire \o_seg[6]_i_3_n_0 ;
  wire [6:0]o_seg_nxt;
  wire o_seg_sel;
  wire o_seg_sel_nxt;
  wire rst_n;
  wire \seq_1st_cnt[0]_i_1_n_0 ;
  wire \seq_1st_cnt[2]_i_2_n_0 ;
  wire \seq_1st_cnt[2]_i_3_n_0 ;
  wire \seq_1st_cnt[3]_i_10_n_0 ;
  wire \seq_1st_cnt[3]_i_1_n_0 ;
  wire \seq_1st_cnt[3]_i_3_n_0 ;
  wire \seq_1st_cnt[3]_i_4_n_0 ;
  wire \seq_1st_cnt[3]_i_5_n_0 ;
  wire \seq_1st_cnt[3]_i_6_n_0 ;
  wire \seq_1st_cnt[3]_i_7_n_0 ;
  wire \seq_1st_cnt[3]_i_8_n_0 ;
  wire \seq_1st_cnt[3]_i_9_n_0 ;
  wire [3:1]seq_1st_cnt_nxt;
  wire \seq_1st_cnt_reg_n_0_[0] ;
  wire \seq_1st_cnt_reg_n_0_[1] ;
  wire \seq_1st_cnt_reg_n_0_[2] ;
  wire \seq_1st_cnt_reg_n_0_[3] ;
  wire \seq_2nd_cnt[0]_i_1_n_0 ;
  wire \seq_2nd_cnt[1]_i_1_n_0 ;
  wire \seq_2nd_cnt[2]_i_1_n_0 ;
  wire \seq_2nd_cnt[3]_i_1_n_0 ;
  wire \seq_2nd_cnt[3]_i_2_n_0 ;
  wire \seq_2nd_cnt[3]_i_3_n_0 ;
  wire [3:0]seq_2nd_cnt_reg;

  LUT1 #(
    .INIT(2'h1)) 
    \always_cnt[0]_i_1 
       (.I0(\always_cnt_reg_n_0_[0] ),
        .O(always_cnt_nxt[0]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \always_cnt[1]_i_1 
       (.I0(\always_cnt_reg_n_0_[0] ),
        .I1(\always_cnt_reg_n_0_[1] ),
        .O(always_cnt_nxt[1]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \always_cnt[2]_i_1 
       (.I0(o_seg_sel_nxt),
        .I1(\always_cnt_reg_n_0_[1] ),
        .I2(\always_cnt_reg_n_0_[0] ),
        .O(always_cnt_nxt[2]));
  FDCE \always_cnt_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(always_cnt_nxt[0]),
        .Q(\always_cnt_reg_n_0_[0] ));
  FDCE \always_cnt_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(always_cnt_nxt[1]),
        .Q(\always_cnt_reg_n_0_[1] ));
  FDCE \always_cnt_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(always_cnt_nxt[2]),
        .Q(o_seg_sel_nxt));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h5554)) 
    \deb_cnt[0]_i_1 
       (.I0(deb_cnt_reg[0]),
        .I1(i_button_clr),
        .I2(i_button_mis),
        .I3(i_button_add),
        .O(deb_cnt_nxt[0]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h66666660)) 
    \deb_cnt[1]_i_1 
       (.I0(deb_cnt_reg[0]),
        .I1(deb_cnt_reg[1]),
        .I2(i_button_clr),
        .I3(i_button_mis),
        .I4(i_button_add),
        .O(deb_cnt_nxt[1]));
  LUT6 #(
    .INIT(64'h7878787878787800)) 
    \deb_cnt[2]_i_1 
       (.I0(deb_cnt_reg[1]),
        .I1(deb_cnt_reg[0]),
        .I2(deb_cnt_reg[2]),
        .I3(i_button_clr),
        .I4(i_button_mis),
        .I5(i_button_add),
        .O(deb_cnt_nxt[2]));
  LUT5 #(
    .INIT(32'h15554000)) 
    \deb_cnt[3]_i_1 
       (.I0(\deb_cnt[4]_i_2_n_0 ),
        .I1(deb_cnt_reg[0]),
        .I2(deb_cnt_reg[1]),
        .I3(deb_cnt_reg[2]),
        .I4(deb_cnt_reg[3]),
        .O(\deb_cnt[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1555555540000000)) 
    \deb_cnt[4]_i_1 
       (.I0(\deb_cnt[4]_i_2_n_0 ),
        .I1(deb_cnt_reg[2]),
        .I2(deb_cnt_reg[1]),
        .I3(deb_cnt_reg[0]),
        .I4(deb_cnt_reg[3]),
        .I5(deb_cnt_reg[4]),
        .O(\deb_cnt[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h01)) 
    \deb_cnt[4]_i_2 
       (.I0(i_button_add),
        .I1(i_button_mis),
        .I2(i_button_clr),
        .O(\deb_cnt[4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFE0000FE)) 
    \deb_cnt[5]_i_1 
       (.I0(i_button_clr),
        .I1(i_button_mis),
        .I2(i_button_add),
        .I3(\deb_cnt[5]_i_2_n_0 ),
        .I4(deb_cnt_reg[5]),
        .O(\deb_cnt[5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \deb_cnt[5]_i_2 
       (.I0(deb_cnt_reg[3]),
        .I1(deb_cnt_reg[0]),
        .I2(deb_cnt_reg[1]),
        .I3(deb_cnt_reg[2]),
        .I4(deb_cnt_reg[4]),
        .O(\deb_cnt[5]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'hFE0000FE)) 
    \deb_cnt[6]_i_1 
       (.I0(i_button_clr),
        .I1(i_button_mis),
        .I2(i_button_add),
        .I3(\deb_cnt[7]_i_3_n_0 ),
        .I4(deb_cnt_reg[6]),
        .O(\deb_cnt[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF7F7F7F7F7F7F7FF)) 
    \deb_cnt[7]_i_1 
       (.I0(deb_cnt_reg[6]),
        .I1(deb_cnt_reg[7]),
        .I2(\deb_cnt[7]_i_3_n_0 ),
        .I3(i_button_clr),
        .I4(i_button_mis),
        .I5(i_button_add),
        .O(\deb_cnt[7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFE00FEFE00FE0000)) 
    \deb_cnt[7]_i_2 
       (.I0(i_button_clr),
        .I1(i_button_mis),
        .I2(i_button_add),
        .I3(\deb_cnt[7]_i_3_n_0 ),
        .I4(deb_cnt_reg[6]),
        .I5(deb_cnt_reg[7]),
        .O(\deb_cnt[7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    \deb_cnt[7]_i_3 
       (.I0(deb_cnt_reg[4]),
        .I1(deb_cnt_reg[2]),
        .I2(deb_cnt_reg[1]),
        .I3(deb_cnt_reg[0]),
        .I4(deb_cnt_reg[3]),
        .I5(deb_cnt_reg[5]),
        .O(\deb_cnt[7]_i_3_n_0 ));
  FDCE \deb_cnt_reg[0] 
       (.C(clk),
        .CE(\deb_cnt[7]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(deb_cnt_nxt[0]),
        .Q(deb_cnt_reg[0]));
  FDCE \deb_cnt_reg[1] 
       (.C(clk),
        .CE(\deb_cnt[7]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(deb_cnt_nxt[1]),
        .Q(deb_cnt_reg[1]));
  FDCE \deb_cnt_reg[2] 
       (.C(clk),
        .CE(\deb_cnt[7]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(deb_cnt_nxt[2]),
        .Q(deb_cnt_reg[2]));
  FDCE \deb_cnt_reg[3] 
       (.C(clk),
        .CE(\deb_cnt[7]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt[3]_i_1_n_0 ),
        .Q(deb_cnt_reg[3]));
  FDCE \deb_cnt_reg[4] 
       (.C(clk),
        .CE(\deb_cnt[7]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt[4]_i_1_n_0 ),
        .Q(deb_cnt_reg[4]));
  FDCE \deb_cnt_reg[5] 
       (.C(clk),
        .CE(\deb_cnt[7]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt[5]_i_1_n_0 ),
        .Q(deb_cnt_reg[5]));
  FDCE \deb_cnt_reg[6] 
       (.C(clk),
        .CE(\deb_cnt[7]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt[6]_i_1_n_0 ),
        .Q(deb_cnt_reg[6]));
  FDCE \deb_cnt_reg[7] 
       (.C(clk),
        .CE(\deb_cnt[7]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt[7]_i_2_n_0 ),
        .Q(deb_cnt_reg[7]));
  LUT6 #(
    .INIT(64'h11EDFFFF11ED0000)) 
    \o_seg[0]_i_1 
       (.I0(seq_2nd_cnt_reg[2]),
        .I1(seq_2nd_cnt_reg[1]),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(seq_2nd_cnt_reg[3]),
        .I4(o_seg_sel_nxt),
        .I5(\o_seg[0]_i_2_n_0 ),
        .O(o_seg_nxt[0]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h3365)) 
    \o_seg[0]_i_2 
       (.I0(\seq_1st_cnt_reg_n_0_[2] ),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .I2(\seq_1st_cnt_reg_n_0_[0] ),
        .I3(\seq_1st_cnt_reg_n_0_[1] ),
        .O(\o_seg[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h039FFFFF039F0000)) 
    \o_seg[1]_i_1 
       (.I0(seq_2nd_cnt_reg[0]),
        .I1(seq_2nd_cnt_reg[1]),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[3]),
        .I4(o_seg_sel_nxt),
        .I5(\o_seg[1]_i_2_n_0 ),
        .O(o_seg_nxt[1]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h059F)) 
    \o_seg[1]_i_2 
       (.I0(\seq_1st_cnt_reg_n_0_[1] ),
        .I1(\seq_1st_cnt_reg_n_0_[0] ),
        .I2(\seq_1st_cnt_reg_n_0_[2] ),
        .I3(\seq_1st_cnt_reg_n_0_[3] ),
        .O(\o_seg[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF001100FB)) 
    \o_seg[2]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[2] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .I2(\seq_1st_cnt_reg_n_0_[0] ),
        .I3(o_seg_sel_nxt),
        .I4(\seq_1st_cnt_reg_n_0_[3] ),
        .I5(\o_seg[2]_i_2_n_0 ),
        .O(o_seg_nxt[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h444440CC)) 
    \o_seg[2]_i_2 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(o_seg_sel_nxt),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(seq_2nd_cnt_reg[1]),
        .I4(seq_2nd_cnt_reg[2]),
        .O(\o_seg[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF0000056B)) 
    \o_seg[3]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[1] ),
        .I1(\seq_1st_cnt_reg_n_0_[0] ),
        .I2(\seq_1st_cnt_reg_n_0_[2] ),
        .I3(\seq_1st_cnt_reg_n_0_[3] ),
        .I4(o_seg_sel_nxt),
        .I5(\o_seg[3]_i_2_n_0 ),
        .O(o_seg_nxt[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h0228220A)) 
    \o_seg[3]_i_2 
       (.I0(o_seg_sel_nxt),
        .I1(seq_2nd_cnt_reg[3]),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[1]),
        .I4(seq_2nd_cnt_reg[0]),
        .O(\o_seg[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00010045)) 
    \o_seg[4]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .I2(\seq_1st_cnt_reg_n_0_[2] ),
        .I3(o_seg_sel_nxt),
        .I4(\seq_1st_cnt_reg_n_0_[3] ),
        .I5(\o_seg[4]_i_2_n_0 ),
        .O(o_seg_nxt[4]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h0000440C)) 
    \o_seg[4]_i_2 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(o_seg_sel_nxt),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[1]),
        .I4(seq_2nd_cnt_reg[0]),
        .O(\o_seg[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h130DFFFF130D0000)) 
    \o_seg[5]_i_1 
       (.I0(seq_2nd_cnt_reg[0]),
        .I1(seq_2nd_cnt_reg[3]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[2]),
        .I4(o_seg_sel_nxt),
        .I5(\o_seg[5]_i_2_n_0 ),
        .O(o_seg_nxt[5]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h112B)) 
    \o_seg[5]_i_2 
       (.I0(\seq_1st_cnt_reg_n_0_[2] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .I2(\seq_1st_cnt_reg_n_0_[0] ),
        .I3(\seq_1st_cnt_reg_n_0_[3] ),
        .O(\o_seg[5]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h155AFFFF155A0000)) 
    \o_seg[6]_i_1 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(seq_2nd_cnt_reg[0]),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[1]),
        .I4(o_seg_sel_nxt),
        .I5(\o_seg[6]_i_3_n_0 ),
        .O(o_seg_nxt[6]));
  LUT1 #(
    .INIT(2'h1)) 
    \o_seg[6]_i_2 
       (.I0(rst_n),
        .O(\o_seg[6]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h037C)) 
    \o_seg[6]_i_3 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .I2(\seq_1st_cnt_reg_n_0_[2] ),
        .I3(\seq_1st_cnt_reg_n_0_[3] ),
        .O(\o_seg[6]_i_3_n_0 ));
  FDPE \o_seg_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(o_seg_nxt[0]),
        .PRE(\o_seg[6]_i_2_n_0 ),
        .Q(o_seg[0]));
  FDPE \o_seg_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(o_seg_nxt[1]),
        .PRE(\o_seg[6]_i_2_n_0 ),
        .Q(o_seg[1]));
  FDPE \o_seg_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(o_seg_nxt[2]),
        .PRE(\o_seg[6]_i_2_n_0 ),
        .Q(o_seg[2]));
  FDPE \o_seg_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(o_seg_nxt[3]),
        .PRE(\o_seg[6]_i_2_n_0 ),
        .Q(o_seg[3]));
  FDPE \o_seg_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(o_seg_nxt[4]),
        .PRE(\o_seg[6]_i_2_n_0 ),
        .Q(o_seg[4]));
  FDPE \o_seg_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(o_seg_nxt[5]),
        .PRE(\o_seg[6]_i_2_n_0 ),
        .Q(o_seg[5]));
  FDCE \o_seg_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(o_seg_nxt[6]),
        .Q(o_seg[6]));
  FDCE o_seg_sel_reg
       (.C(clk),
        .CE(1'b1),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(o_seg_sel_nxt),
        .Q(o_seg_sel));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \seq_1st_cnt[0]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt[3]_i_3_n_0 ),
        .O(\seq_1st_cnt[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h40040440)) 
    \seq_1st_cnt[1]_i_1 
       (.I0(\seq_1st_cnt[3]_i_3_n_0 ),
        .I1(\seq_1st_cnt[2]_i_2_n_0 ),
        .I2(\seq_1st_cnt_reg_n_0_[0] ),
        .I3(\seq_1st_cnt_reg_n_0_[1] ),
        .I4(i_button_mis),
        .O(seq_1st_cnt_nxt[1]));
  LUT6 #(
    .INIT(64'h4044440404000040)) 
    \seq_1st_cnt[2]_i_1 
       (.I0(\seq_1st_cnt[3]_i_3_n_0 ),
        .I1(\seq_1st_cnt[2]_i_2_n_0 ),
        .I2(i_button_mis),
        .I3(\seq_1st_cnt_reg_n_0_[0] ),
        .I4(\seq_1st_cnt_reg_n_0_[1] ),
        .I5(\seq_1st_cnt_reg_n_0_[2] ),
        .O(seq_1st_cnt_nxt[2]));
  LUT5 #(
    .INIT(32'hFFFEFFFF)) 
    \seq_1st_cnt[2]_i_2 
       (.I0(\seq_1st_cnt[3]_i_10_n_0 ),
        .I1(\seq_1st_cnt[2]_i_3_n_0 ),
        .I2(\seq_1st_cnt[3]_i_8_n_0 ),
        .I3(\seq_1st_cnt[3]_i_9_n_0 ),
        .I4(i_button_mis),
        .O(\seq_1st_cnt[2]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \seq_1st_cnt[2]_i_3 
       (.I0(seq_2nd_cnt_reg[0]),
        .I1(seq_2nd_cnt_reg[1]),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[3]),
        .O(\seq_1st_cnt[2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAABAAABABBBBAABA)) 
    \seq_1st_cnt[3]_i_1 
       (.I0(\seq_1st_cnt[3]_i_3_n_0 ),
        .I1(\seq_1st_cnt[3]_i_4_n_0 ),
        .I2(i_button_add),
        .I3(\seq_1st_cnt[3]_i_5_n_0 ),
        .I4(i_button_mis),
        .I5(\seq_1st_cnt[3]_i_6_n_0 ),
        .O(\seq_1st_cnt[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    \seq_1st_cnt[3]_i_10 
       (.I0(\seq_1st_cnt_reg_n_0_[1] ),
        .I1(\seq_1st_cnt_reg_n_0_[0] ),
        .I2(\seq_1st_cnt_reg_n_0_[3] ),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .O(\seq_1st_cnt[3]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'h5554155500014000)) 
    \seq_1st_cnt[3]_i_2 
       (.I0(\seq_1st_cnt[3]_i_3_n_0 ),
        .I1(\seq_1st_cnt_reg_n_0_[2] ),
        .I2(\seq_1st_cnt_reg_n_0_[1] ),
        .I3(\seq_1st_cnt_reg_n_0_[0] ),
        .I4(i_button_mis),
        .I5(\seq_1st_cnt_reg_n_0_[3] ),
        .O(seq_1st_cnt_nxt[3]));
  LUT6 #(
    .INIT(64'h000000FF00000040)) 
    \seq_1st_cnt[3]_i_3 
       (.I0(\seq_1st_cnt[3]_i_7_n_0 ),
        .I1(\seq_1st_cnt_reg_n_0_[0] ),
        .I2(i_button_add),
        .I3(\seq_1st_cnt[3]_i_8_n_0 ),
        .I4(\seq_1st_cnt[3]_i_9_n_0 ),
        .I5(i_button_clr),
        .O(\seq_1st_cnt[3]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'hFFFFF7FF)) 
    \seq_1st_cnt[3]_i_4 
       (.I0(deb_cnt_reg[2]),
        .I1(deb_cnt_reg[5]),
        .I2(deb_cnt_reg[0]),
        .I3(deb_cnt_reg[1]),
        .I4(\seq_1st_cnt[3]_i_9_n_0 ),
        .O(\seq_1st_cnt[3]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0000002000000000)) 
    \seq_1st_cnt[3]_i_5 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt[3]_i_7_n_0 ),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(seq_2nd_cnt_reg[2]),
        .I4(seq_2nd_cnt_reg[1]),
        .I5(seq_2nd_cnt_reg[3]),
        .O(\seq_1st_cnt[3]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h00000001)) 
    \seq_1st_cnt[3]_i_6 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(seq_2nd_cnt_reg[2]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[0]),
        .I4(\seq_1st_cnt[3]_i_10_n_0 ),
        .O(\seq_1st_cnt[3]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hEF)) 
    \seq_1st_cnt[3]_i_7 
       (.I0(\seq_1st_cnt_reg_n_0_[2] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .I2(\seq_1st_cnt_reg_n_0_[3] ),
        .O(\seq_1st_cnt[3]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'hDFFF)) 
    \seq_1st_cnt[3]_i_8 
       (.I0(deb_cnt_reg[1]),
        .I1(deb_cnt_reg[0]),
        .I2(deb_cnt_reg[5]),
        .I3(deb_cnt_reg[2]),
        .O(\seq_1st_cnt[3]_i_8_n_0 ));
  LUT4 #(
    .INIT(16'h7FFF)) 
    \seq_1st_cnt[3]_i_9 
       (.I0(deb_cnt_reg[7]),
        .I1(deb_cnt_reg[6]),
        .I2(deb_cnt_reg[4]),
        .I3(deb_cnt_reg[3]),
        .O(\seq_1st_cnt[3]_i_9_n_0 ));
  FDCE \seq_1st_cnt_reg[0] 
       (.C(clk),
        .CE(\seq_1st_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\seq_1st_cnt[0]_i_1_n_0 ),
        .Q(\seq_1st_cnt_reg_n_0_[0] ));
  FDCE \seq_1st_cnt_reg[1] 
       (.C(clk),
        .CE(\seq_1st_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(seq_1st_cnt_nxt[1]),
        .Q(\seq_1st_cnt_reg_n_0_[1] ));
  FDCE \seq_1st_cnt_reg[2] 
       (.C(clk),
        .CE(\seq_1st_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(seq_1st_cnt_nxt[2]),
        .Q(\seq_1st_cnt_reg_n_0_[2] ));
  FDCE \seq_1st_cnt_reg[3] 
       (.C(clk),
        .CE(\seq_1st_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(seq_1st_cnt_nxt[3]),
        .Q(\seq_1st_cnt_reg_n_0_[3] ));
  LUT2 #(
    .INIT(4'h1)) 
    \seq_2nd_cnt[0]_i_1 
       (.I0(seq_2nd_cnt_reg[0]),
        .I1(\seq_2nd_cnt[3]_i_3_n_0 ),
        .O(\seq_2nd_cnt[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'h1441)) 
    \seq_2nd_cnt[1]_i_1 
       (.I0(\seq_2nd_cnt[3]_i_3_n_0 ),
        .I1(seq_2nd_cnt_reg[1]),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(\seq_1st_cnt[2]_i_2_n_0 ),
        .O(\seq_2nd_cnt[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h15544001)) 
    \seq_2nd_cnt[2]_i_1 
       (.I0(\seq_2nd_cnt[3]_i_3_n_0 ),
        .I1(\seq_1st_cnt[2]_i_2_n_0 ),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[0]),
        .I4(seq_2nd_cnt_reg[2]),
        .O(\seq_2nd_cnt[2]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'hB)) 
    \seq_2nd_cnt[3]_i_1 
       (.I0(\seq_1st_cnt[3]_i_3_n_0 ),
        .I1(\seq_1st_cnt[2]_i_2_n_0 ),
        .O(\seq_2nd_cnt[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1555555440000001)) 
    \seq_2nd_cnt[3]_i_2 
       (.I0(\seq_2nd_cnt[3]_i_3_n_0 ),
        .I1(seq_2nd_cnt_reg[0]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(\seq_1st_cnt[2]_i_2_n_0 ),
        .I4(seq_2nd_cnt_reg[2]),
        .I5(seq_2nd_cnt_reg[3]),
        .O(\seq_2nd_cnt[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \seq_2nd_cnt[3]_i_3 
       (.I0(i_button_clr),
        .I1(\seq_1st_cnt[3]_i_9_n_0 ),
        .I2(deb_cnt_reg[1]),
        .I3(deb_cnt_reg[0]),
        .I4(deb_cnt_reg[5]),
        .I5(deb_cnt_reg[2]),
        .O(\seq_2nd_cnt[3]_i_3_n_0 ));
  FDCE \seq_2nd_cnt_reg[0] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\seq_2nd_cnt[0]_i_1_n_0 ),
        .Q(seq_2nd_cnt_reg[0]));
  FDCE \seq_2nd_cnt_reg[1] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\seq_2nd_cnt[1]_i_1_n_0 ),
        .Q(seq_2nd_cnt_reg[1]));
  FDCE \seq_2nd_cnt_reg[2] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\seq_2nd_cnt[2]_i_1_n_0 ),
        .Q(seq_2nd_cnt_reg[2]));
  FDCE \seq_2nd_cnt_reg[3] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\seq_2nd_cnt[3]_i_2_n_0 ),
        .Q(seq_2nd_cnt_reg[3]));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
