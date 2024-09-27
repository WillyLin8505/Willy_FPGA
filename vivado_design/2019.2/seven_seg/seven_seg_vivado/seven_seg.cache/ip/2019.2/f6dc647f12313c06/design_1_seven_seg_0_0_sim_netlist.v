// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue Sep 17 17:52:31 2024
// Host        : DESKTOP-6O0UNV6 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_seven_seg_0_0_sim_netlist.v
// Design      : design_1_seven_seg_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_seven_seg_0_0,seven_seg,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* ip_definition_source = "package_project" *) 
(* x_core_info = "seven_seg,Vivado 2019.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clk,
    rst_n,
    i_buttom_add,
    i_buttom_mis,
    i_buttom_clr,
    o_seg_1,
    o_seg_2);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk, FREQ_HZ 50000000, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input clk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 rst_n RST" *) (* x_interface_parameter = "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input rst_n;
  input i_buttom_add;
  input i_buttom_mis;
  input i_buttom_clr;
  output [6:0]o_seg_1;
  output [6:0]o_seg_2;

  wire clk;
  wire i_buttom_add;
  wire i_buttom_clr;
  wire i_buttom_mis;
  wire [6:0]o_seg_1;
  wire [6:0]o_seg_2;
  wire rst_n;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg U0
       (.clk(clk),
        .i_buttom_add(i_buttom_add),
        .i_buttom_clr(i_buttom_clr),
        .i_buttom_mis(i_buttom_mis),
        .o_seg_1(o_seg_1),
        .o_seg_2(o_seg_2),
        .rst_n(rst_n));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_seven_seg
   (o_seg_1,
    o_seg_2,
    clk,
    i_buttom_clr,
    i_buttom_add,
    i_buttom_mis,
    rst_n);
  output [6:0]o_seg_1;
  output [6:0]o_seg_2;
  input clk;
  input i_buttom_clr;
  input i_buttom_add;
  input i_buttom_mis;
  input rst_n;

  wire clk;
  wire \deb_cnt[4]_i_1_n_0 ;
  wire [4:0]deb_cnt_nxt;
  wire [4:0]deb_cnt_reg;
  wire i_buttom_add;
  wire i_buttom_clr;
  wire i_buttom_mis;
  wire [6:0]o_seg_1;
  wire \o_seg_1[4]_i_1_n_0 ;
  wire \o_seg_1[5]_i_1_n_0 ;
  wire \o_seg_1[6]_i_2_n_0 ;
  wire [6:0]o_seg_2;
  wire \o_seg_2[0]_i_1_n_0 ;
  wire \o_seg_2[1]_i_1_n_0 ;
  wire \o_seg_2[2]_i_1_n_0 ;
  wire \o_seg_2[3]_i_1_n_0 ;
  wire \o_seg_2[4]_i_1_n_0 ;
  wire \o_seg_2[5]_i_1_n_0 ;
  wire \o_seg_2[6]_i_1_n_0 ;
  wire rst_n;
  wire [6:0]seg_com;
  wire \seq_1st_cnt[0]_i_1_n_0 ;
  wire \seq_1st_cnt[0]_i_2_n_0 ;
  wire \seq_1st_cnt[2]_i_2_n_0 ;
  wire \seq_1st_cnt[2]_i_3_n_0 ;
  wire \seq_1st_cnt[2]_i_4_n_0 ;
  wire \seq_1st_cnt[2]_i_5_n_0 ;
  wire \seq_1st_cnt[2]_i_6_n_0 ;
  wire \seq_1st_cnt[3]_i_1_n_0 ;
  wire \seq_1st_cnt[3]_i_3_n_0 ;
  wire \seq_1st_cnt[3]_i_4_n_0 ;
  wire \seq_1st_cnt[3]_i_5_n_0 ;
  wire [3:1]seq_1st_cnt_nxt;
  wire \seq_1st_cnt_reg_n_0_[0] ;
  wire \seq_1st_cnt_reg_n_0_[1] ;
  wire \seq_1st_cnt_reg_n_0_[2] ;
  wire \seq_1st_cnt_reg_n_0_[3] ;
  wire \seq_2nd_cnt[0]_i_1_n_0 ;
  wire \seq_2nd_cnt[2]_i_1_n_0 ;
  wire \seq_2nd_cnt[3]_i_1_n_0 ;
  wire \seq_2nd_cnt[3]_i_2_n_0 ;
  wire [1:1]seq_2nd_cnt_nxt;
  wire [3:0]seq_2nd_cnt_reg;

  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \deb_cnt[0]_i_1 
       (.I0(deb_cnt_reg[0]),
        .O(deb_cnt_nxt[0]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \deb_cnt[1]_i_1 
       (.I0(deb_cnt_reg[0]),
        .I1(deb_cnt_reg[1]),
        .O(deb_cnt_nxt[1]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \deb_cnt[2]_i_1 
       (.I0(deb_cnt_reg[2]),
        .I1(deb_cnt_reg[1]),
        .I2(deb_cnt_reg[0]),
        .O(deb_cnt_nxt[2]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h6AAA)) 
    \deb_cnt[3]_i_1 
       (.I0(deb_cnt_reg[3]),
        .I1(deb_cnt_reg[0]),
        .I2(deb_cnt_reg[1]),
        .I3(deb_cnt_reg[2]),
        .O(deb_cnt_nxt[3]));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \deb_cnt[4]_i_1 
       (.I0(\seq_1st_cnt[3]_i_3_n_0 ),
        .I1(i_buttom_clr),
        .I2(i_buttom_add),
        .I3(i_buttom_mis),
        .O(\deb_cnt[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h6AAAAAAA)) 
    \deb_cnt[4]_i_2 
       (.I0(deb_cnt_reg[4]),
        .I1(deb_cnt_reg[2]),
        .I2(deb_cnt_reg[1]),
        .I3(deb_cnt_reg[0]),
        .I4(deb_cnt_reg[3]),
        .O(deb_cnt_nxt[4]));
  FDCE \deb_cnt_reg[0] 
       (.C(clk),
        .CE(\deb_cnt[4]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(deb_cnt_nxt[0]),
        .Q(deb_cnt_reg[0]));
  FDCE \deb_cnt_reg[1] 
       (.C(clk),
        .CE(\deb_cnt[4]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(deb_cnt_nxt[1]),
        .Q(deb_cnt_reg[1]));
  FDCE \deb_cnt_reg[2] 
       (.C(clk),
        .CE(\deb_cnt[4]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(deb_cnt_nxt[2]),
        .Q(deb_cnt_reg[2]));
  FDCE \deb_cnt_reg[3] 
       (.C(clk),
        .CE(\deb_cnt[4]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(deb_cnt_nxt[3]),
        .Q(deb_cnt_reg[3]));
  FDCE \deb_cnt_reg[4] 
       (.C(clk),
        .CE(\deb_cnt[4]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(deb_cnt_nxt[4]),
        .Q(deb_cnt_reg[4]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h0E5B)) 
    \o_seg_1[0]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[1] ),
        .I1(\seq_1st_cnt_reg_n_0_[0] ),
        .I2(\seq_1st_cnt_reg_n_0_[3] ),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .O(seg_com[0]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h213F)) 
    \o_seg_1[1]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .I2(\seq_1st_cnt_reg_n_0_[1] ),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .O(seg_com[1]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h332F)) 
    \o_seg_1[2]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .I2(\seq_1st_cnt_reg_n_0_[1] ),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .O(seg_com[2]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h1563)) 
    \o_seg_1[3]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[3] ),
        .I1(\seq_1st_cnt_reg_n_0_[2] ),
        .I2(\seq_1st_cnt_reg_n_0_[0] ),
        .I3(\seq_1st_cnt_reg_n_0_[1] ),
        .O(seg_com[3]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h0151)) 
    \o_seg_1[4]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[2] ),
        .I2(\seq_1st_cnt_reg_n_0_[1] ),
        .I3(\seq_1st_cnt_reg_n_0_[3] ),
        .O(\o_seg_1[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h130D)) 
    \o_seg_1[5]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .I2(\seq_1st_cnt_reg_n_0_[1] ),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .O(\o_seg_1[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h037C)) 
    \o_seg_1[6]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .I2(\seq_1st_cnt_reg_n_0_[2] ),
        .I3(\seq_1st_cnt_reg_n_0_[3] ),
        .O(seg_com[6]));
  LUT1 #(
    .INIT(2'h1)) 
    \o_seg_1[6]_i_2 
       (.I0(rst_n),
        .O(\o_seg_1[6]_i_2_n_0 ));
  FDPE \o_seg_1_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(seg_com[0]),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_1[0]));
  FDPE \o_seg_1_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(seg_com[1]),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_1[1]));
  FDPE \o_seg_1_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(seg_com[2]),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_1[2]));
  FDPE \o_seg_1_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(seg_com[3]),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_1[3]));
  FDPE \o_seg_1_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\o_seg_1[4]_i_1_n_0 ),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_1[4]));
  FDPE \o_seg_1_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\o_seg_1[5]_i_1_n_0 ),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_1[5]));
  FDCE \o_seg_1_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(seg_com[6]),
        .Q(o_seg_1[6]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h11ED)) 
    \o_seg_2[0]_i_1 
       (.I0(seq_2nd_cnt_reg[2]),
        .I1(seq_2nd_cnt_reg[1]),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(seq_2nd_cnt_reg[3]),
        .O(\o_seg_2[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h5317)) 
    \o_seg_2[1]_i_1 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(seq_2nd_cnt_reg[2]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[0]),
        .O(\o_seg_2[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h554F)) 
    \o_seg_2[2]_i_1 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(seq_2nd_cnt_reg[0]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[2]),
        .O(\o_seg_2[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h1653)) 
    \o_seg_2[3]_i_1 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(seq_2nd_cnt_reg[2]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[0]),
        .O(\o_seg_2[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h0151)) 
    \o_seg_2[4]_i_1 
       (.I0(seq_2nd_cnt_reg[0]),
        .I1(seq_2nd_cnt_reg[2]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[3]),
        .O(\o_seg_2[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h052B)) 
    \o_seg_2[5]_i_1 
       (.I0(seq_2nd_cnt_reg[2]),
        .I1(seq_2nd_cnt_reg[0]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[3]),
        .O(\o_seg_2[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'h155A)) 
    \o_seg_2[6]_i_1 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(seq_2nd_cnt_reg[0]),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[1]),
        .O(\o_seg_2[6]_i_1_n_0 ));
  FDPE \o_seg_2_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\o_seg_2[0]_i_1_n_0 ),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_2[0]));
  FDPE \o_seg_2_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\o_seg_2[1]_i_1_n_0 ),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_2[1]));
  FDPE \o_seg_2_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\o_seg_2[2]_i_1_n_0 ),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_2[2]));
  FDPE \o_seg_2_reg[3] 
       (.C(clk),
        .CE(1'b1),
        .D(\o_seg_2[3]_i_1_n_0 ),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_2[3]));
  FDPE \o_seg_2_reg[4] 
       (.C(clk),
        .CE(1'b1),
        .D(\o_seg_2[4]_i_1_n_0 ),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_2[4]));
  FDPE \o_seg_2_reg[5] 
       (.C(clk),
        .CE(1'b1),
        .D(\o_seg_2[5]_i_1_n_0 ),
        .PRE(\o_seg_1[6]_i_2_n_0 ),
        .Q(o_seg_2[5]));
  FDCE \o_seg_2_reg[6] 
       (.C(clk),
        .CE(1'b1),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(\o_seg_2[6]_i_1_n_0 ),
        .Q(o_seg_2[6]));
  LUT2 #(
    .INIT(4'h1)) 
    \seq_1st_cnt[0]_i_1 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt[0]_i_2_n_0 ),
        .O(\seq_1st_cnt[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000002)) 
    \seq_1st_cnt[0]_i_2 
       (.I0(i_buttom_clr),
        .I1(deb_cnt_reg[3]),
        .I2(deb_cnt_reg[4]),
        .I3(deb_cnt_reg[2]),
        .I4(deb_cnt_reg[0]),
        .I5(deb_cnt_reg[1]),
        .O(\seq_1st_cnt[0]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h10010110)) 
    \seq_1st_cnt[1]_i_1 
       (.I0(\seq_1st_cnt[3]_i_4_n_0 ),
        .I1(\seq_1st_cnt[2]_i_2_n_0 ),
        .I2(\seq_1st_cnt_reg_n_0_[0] ),
        .I3(\seq_1st_cnt_reg_n_0_[1] ),
        .I4(i_buttom_mis),
        .O(seq_1st_cnt_nxt[1]));
  LUT6 #(
    .INIT(64'h1011110101000010)) 
    \seq_1st_cnt[2]_i_1 
       (.I0(\seq_1st_cnt[3]_i_4_n_0 ),
        .I1(\seq_1st_cnt[2]_i_2_n_0 ),
        .I2(i_buttom_mis),
        .I3(\seq_1st_cnt_reg_n_0_[0] ),
        .I4(\seq_1st_cnt_reg_n_0_[1] ),
        .I5(\seq_1st_cnt_reg_n_0_[2] ),
        .O(seq_1st_cnt_nxt[2]));
  LUT6 #(
    .INIT(64'h0808080808080008)) 
    \seq_1st_cnt[2]_i_2 
       (.I0(\seq_1st_cnt[2]_i_3_n_0 ),
        .I1(\seq_1st_cnt[2]_i_4_n_0 ),
        .I2(\seq_1st_cnt[2]_i_5_n_0 ),
        .I3(\seq_1st_cnt[2]_i_6_n_0 ),
        .I4(seq_2nd_cnt_reg[2]),
        .I5(seq_2nd_cnt_reg[3]),
        .O(\seq_1st_cnt[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000002)) 
    \seq_1st_cnt[2]_i_3 
       (.I0(i_buttom_mis),
        .I1(deb_cnt_reg[3]),
        .I2(deb_cnt_reg[4]),
        .I3(deb_cnt_reg[2]),
        .I4(deb_cnt_reg[0]),
        .I5(deb_cnt_reg[1]),
        .O(\seq_1st_cnt[2]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \seq_1st_cnt[2]_i_4 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .O(\seq_1st_cnt[2]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \seq_1st_cnt[2]_i_5 
       (.I0(\seq_1st_cnt_reg_n_0_[2] ),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .O(\seq_1st_cnt[2]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \seq_1st_cnt[2]_i_6 
       (.I0(seq_2nd_cnt_reg[1]),
        .I1(seq_2nd_cnt_reg[0]),
        .O(\seq_1st_cnt[2]_i_6_n_0 ));
  LUT4 #(
    .INIT(16'h0F0E)) 
    \seq_1st_cnt[3]_i_1 
       (.I0(i_buttom_clr),
        .I1(i_buttom_add),
        .I2(\seq_1st_cnt[3]_i_3_n_0 ),
        .I3(i_buttom_mis),
        .O(\seq_1st_cnt[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h5554155500014000)) 
    \seq_1st_cnt[3]_i_2 
       (.I0(\seq_1st_cnt[3]_i_4_n_0 ),
        .I1(\seq_1st_cnt_reg_n_0_[2] ),
        .I2(\seq_1st_cnt_reg_n_0_[1] ),
        .I3(\seq_1st_cnt_reg_n_0_[0] ),
        .I4(i_buttom_mis),
        .I5(\seq_1st_cnt_reg_n_0_[3] ),
        .O(seq_1st_cnt_nxt[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \seq_1st_cnt[3]_i_3 
       (.I0(deb_cnt_reg[1]),
        .I1(deb_cnt_reg[0]),
        .I2(deb_cnt_reg[2]),
        .I3(deb_cnt_reg[4]),
        .I4(deb_cnt_reg[3]),
        .O(\seq_1st_cnt[3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h00000000AEAAAAAA)) 
    \seq_1st_cnt[3]_i_4 
       (.I0(i_buttom_clr),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .I2(\seq_1st_cnt[3]_i_5_n_0 ),
        .I3(\seq_1st_cnt_reg_n_0_[0] ),
        .I4(i_buttom_add),
        .I5(\seq_1st_cnt[3]_i_3_n_0 ),
        .O(\seq_1st_cnt[3]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \seq_1st_cnt[3]_i_5 
       (.I0(\seq_1st_cnt_reg_n_0_[1] ),
        .I1(\seq_1st_cnt_reg_n_0_[2] ),
        .O(\seq_1st_cnt[3]_i_5_n_0 ));
  FDCE \seq_1st_cnt_reg[0] 
       (.C(clk),
        .CE(\seq_1st_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(\seq_1st_cnt[0]_i_1_n_0 ),
        .Q(\seq_1st_cnt_reg_n_0_[0] ));
  FDCE \seq_1st_cnt_reg[1] 
       (.C(clk),
        .CE(\seq_1st_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(seq_1st_cnt_nxt[1]),
        .Q(\seq_1st_cnt_reg_n_0_[1] ));
  FDCE \seq_1st_cnt_reg[2] 
       (.C(clk),
        .CE(\seq_1st_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(seq_1st_cnt_nxt[2]),
        .Q(\seq_1st_cnt_reg_n_0_[2] ));
  FDCE \seq_1st_cnt_reg[3] 
       (.C(clk),
        .CE(\seq_1st_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(seq_1st_cnt_nxt[3]),
        .Q(\seq_1st_cnt_reg_n_0_[3] ));
  LUT2 #(
    .INIT(4'h1)) 
    \seq_2nd_cnt[0]_i_1 
       (.I0(seq_2nd_cnt_reg[0]),
        .I1(\seq_1st_cnt[0]_i_2_n_0 ),
        .O(\seq_2nd_cnt[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'h0096)) 
    \seq_2nd_cnt[1]_i_1 
       (.I0(seq_2nd_cnt_reg[1]),
        .I1(seq_2nd_cnt_reg[0]),
        .I2(\seq_1st_cnt[2]_i_2_n_0 ),
        .I3(\seq_1st_cnt[0]_i_2_n_0 ),
        .O(seq_2nd_cnt_nxt));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h45511004)) 
    \seq_2nd_cnt[2]_i_1 
       (.I0(\seq_1st_cnt[0]_i_2_n_0 ),
        .I1(\seq_1st_cnt[2]_i_2_n_0 ),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[0]),
        .I4(seq_2nd_cnt_reg[2]),
        .O(\seq_2nd_cnt[2]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \seq_2nd_cnt[3]_i_1 
       (.I0(\seq_1st_cnt[3]_i_4_n_0 ),
        .I1(\seq_1st_cnt[2]_i_2_n_0 ),
        .O(\seq_2nd_cnt[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h5515545500400100)) 
    \seq_2nd_cnt[3]_i_2 
       (.I0(\seq_1st_cnt[0]_i_2_n_0 ),
        .I1(seq_2nd_cnt_reg[0]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(\seq_1st_cnt[2]_i_2_n_0 ),
        .I4(seq_2nd_cnt_reg[2]),
        .I5(seq_2nd_cnt_reg[3]),
        .O(\seq_2nd_cnt[3]_i_2_n_0 ));
  FDCE \seq_2nd_cnt_reg[0] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(\seq_2nd_cnt[0]_i_1_n_0 ),
        .Q(seq_2nd_cnt_reg[0]));
  FDCE \seq_2nd_cnt_reg[1] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(seq_2nd_cnt_nxt),
        .Q(seq_2nd_cnt_reg[1]));
  FDCE \seq_2nd_cnt_reg[2] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
        .D(\seq_2nd_cnt[2]_i_1_n_0 ),
        .Q(seq_2nd_cnt_reg[2]));
  FDCE \seq_2nd_cnt_reg[3] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg_1[6]_i_2_n_0 ),
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
