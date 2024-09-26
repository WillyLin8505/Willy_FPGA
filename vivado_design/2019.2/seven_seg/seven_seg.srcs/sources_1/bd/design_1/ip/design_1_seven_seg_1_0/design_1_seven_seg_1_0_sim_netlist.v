// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Thu Sep 26 15:56:50 2024
// Host        : DESKTOP-6O0UNV6 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               C:/Users/sssss/OneDrive/vivado_part/2019.2/seven_seg/seven_seg.srcs/sources_1/bd/design_1/ip/design_1_seven_seg_1_0/design_1_seven_seg_1_0_sim_netlist.v
// Design      : design_1_seven_seg_1_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_seven_seg_1_0,seven_seg,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* ip_definition_source = "package_project" *) 
(* x_core_info = "seven_seg,Vivado 2019.2" *) 
(* NotValidForBitStream *)
module design_1_seven_seg_1_0
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

  design_1_seven_seg_1_0_seven_seg U0
       (.clk(clk),
        .i_button_add(i_button_add),
        .i_button_clr(i_button_clr),
        .i_button_mis(i_button_mis),
        .o_seg(o_seg),
        .o_seg_sel(o_seg_sel),
        .rst_n(rst_n));
endmodule

(* ORIG_REF_NAME = "seven_seg" *) 
module design_1_seven_seg_1_0_seven_seg
   (o_seg,
    o_seg_sel,
    i_button_clr,
    clk,
    i_button_add,
    i_button_mis,
    rst_n);
  output [6:0]o_seg;
  output o_seg_sel;
  input i_button_clr;
  input clk;
  input i_button_add;
  input i_button_mis;
  input rst_n;

  wire [2:0]always_cnt_nxt;
  wire \always_cnt_reg_n_0_[0] ;
  wire \always_cnt_reg_n_0_[1] ;
  wire button_clr_1_eq;
  wire clk;
  wire [1:1]cnt_2nd_add_minus_sgn;
  wire \deb_cnt[0]_i_10_n_0 ;
  wire \deb_cnt[0]_i_11_n_0 ;
  wire \deb_cnt[0]_i_1_n_0 ;
  wire \deb_cnt[0]_i_3_n_0 ;
  wire \deb_cnt[0]_i_4_n_0 ;
  wire \deb_cnt[0]_i_5_n_0 ;
  wire \deb_cnt[0]_i_6_n_0 ;
  wire \deb_cnt[0]_i_7_n_0 ;
  wire \deb_cnt[0]_i_8_n_0 ;
  wire \deb_cnt[0]_i_9_n_0 ;
  wire \deb_cnt[12]_i_2_n_0 ;
  wire \deb_cnt[12]_i_3_n_0 ;
  wire \deb_cnt[12]_i_4_n_0 ;
  wire \deb_cnt[12]_i_5_n_0 ;
  wire \deb_cnt[16]_i_2_n_0 ;
  wire \deb_cnt[4]_i_2_n_0 ;
  wire \deb_cnt[4]_i_3_n_0 ;
  wire \deb_cnt[4]_i_4_n_0 ;
  wire \deb_cnt[4]_i_5_n_0 ;
  wire \deb_cnt[8]_i_2_n_0 ;
  wire \deb_cnt[8]_i_3_n_0 ;
  wire \deb_cnt[8]_i_4_n_0 ;
  wire \deb_cnt[8]_i_5_n_0 ;
  wire [16:0]deb_cnt_reg;
  wire \deb_cnt_reg[0]_i_2_n_0 ;
  wire \deb_cnt_reg[0]_i_2_n_1 ;
  wire \deb_cnt_reg[0]_i_2_n_2 ;
  wire \deb_cnt_reg[0]_i_2_n_3 ;
  wire \deb_cnt_reg[0]_i_2_n_4 ;
  wire \deb_cnt_reg[0]_i_2_n_5 ;
  wire \deb_cnt_reg[0]_i_2_n_6 ;
  wire \deb_cnt_reg[0]_i_2_n_7 ;
  wire \deb_cnt_reg[12]_i_1_n_0 ;
  wire \deb_cnt_reg[12]_i_1_n_1 ;
  wire \deb_cnt_reg[12]_i_1_n_2 ;
  wire \deb_cnt_reg[12]_i_1_n_3 ;
  wire \deb_cnt_reg[12]_i_1_n_4 ;
  wire \deb_cnt_reg[12]_i_1_n_5 ;
  wire \deb_cnt_reg[12]_i_1_n_6 ;
  wire \deb_cnt_reg[12]_i_1_n_7 ;
  wire \deb_cnt_reg[16]_i_1_n_7 ;
  wire \deb_cnt_reg[4]_i_1_n_0 ;
  wire \deb_cnt_reg[4]_i_1_n_1 ;
  wire \deb_cnt_reg[4]_i_1_n_2 ;
  wire \deb_cnt_reg[4]_i_1_n_3 ;
  wire \deb_cnt_reg[4]_i_1_n_4 ;
  wire \deb_cnt_reg[4]_i_1_n_5 ;
  wire \deb_cnt_reg[4]_i_1_n_6 ;
  wire \deb_cnt_reg[4]_i_1_n_7 ;
  wire \deb_cnt_reg[8]_i_1_n_0 ;
  wire \deb_cnt_reg[8]_i_1_n_1 ;
  wire \deb_cnt_reg[8]_i_1_n_2 ;
  wire \deb_cnt_reg[8]_i_1_n_3 ;
  wire \deb_cnt_reg[8]_i_1_n_4 ;
  wire \deb_cnt_reg[8]_i_1_n_5 ;
  wire \deb_cnt_reg[8]_i_1_n_6 ;
  wire \deb_cnt_reg[8]_i_1_n_7 ;
  wire [0:0]deb_keep_nxt;
  wire \deb_keep_reg_n_0_[0] ;
  wire \deb_keep_reg_n_0_[1] ;
  wire deb_trg;
  wire i_button_add;
  wire i_button_clr;
  wire i_button_mis;
  wire [6:0]o_seg;
  wire \o_seg[1]_i_2_n_0 ;
  wire \o_seg[2]_i_2_n_0 ;
  wire \o_seg[2]_i_3_n_0 ;
  wire \o_seg[3]_i_2_n_0 ;
  wire \o_seg[3]_i_3_n_0 ;
  wire \o_seg[3]_i_4_n_0 ;
  wire \o_seg[3]_i_5_n_0 ;
  wire \o_seg[6]_i_2_n_0 ;
  wire [6:0]o_seg_nxt;
  wire o_seg_sel;
  wire o_seg_sel_nxt;
  wire rst_n;
  wire [6:0]seg_1;
  wire seq_1st_9_cnt_eq__2;
  wire \seq_1st_cnt[1]_i_2_n_0 ;
  wire \seq_1st_cnt[2]_i_2_n_0 ;
  wire \seq_1st_cnt[2]_i_3_n_0 ;
  wire \seq_1st_cnt[3]_i_10_n_0 ;
  wire \seq_1st_cnt[3]_i_11_n_0 ;
  wire \seq_1st_cnt[3]_i_12_n_0 ;
  wire \seq_1st_cnt[3]_i_13_n_0 ;
  wire \seq_1st_cnt[3]_i_14_n_0 ;
  wire \seq_1st_cnt[3]_i_15_n_0 ;
  wire \seq_1st_cnt[3]_i_1_n_0 ;
  wire \seq_1st_cnt[3]_i_2_n_0 ;
  wire \seq_1st_cnt[3]_i_3_n_0 ;
  wire \seq_1st_cnt[3]_i_4_n_0 ;
  wire \seq_1st_cnt[3]_i_6_n_0 ;
  wire \seq_1st_cnt[3]_i_8_n_0 ;
  wire \seq_1st_cnt[3]_i_9_n_0 ;
  wire seq_1st_cnt_clr1__0;
  wire [2:0]seq_1st_cnt_nxt;
  wire \seq_1st_cnt_reg_n_0_[0] ;
  wire \seq_1st_cnt_reg_n_0_[1] ;
  wire \seq_1st_cnt_reg_n_0_[2] ;
  wire \seq_1st_cnt_reg_n_0_[3] ;
  wire \seq_2nd_cnt[0]_i_1_n_0 ;
  wire \seq_2nd_cnt[3]_i_1_n_0 ;
  wire [3:1]seq_2nd_cnt_nxt;
  wire [3:0]seq_2nd_cnt_reg;
  wire [3:0]\NLW_deb_cnt_reg[16]_i_1_CO_UNCONNECTED ;
  wire [3:1]\NLW_deb_cnt_reg[16]_i_1_O_UNCONNECTED ;

  LUT1 #(
    .INIT(2'h1)) 
    \always_cnt[0]_i_1 
       (.I0(\always_cnt_reg_n_0_[0] ),
        .O(always_cnt_nxt[0]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \always_cnt[1]_i_1 
       (.I0(\always_cnt_reg_n_0_[0] ),
        .I1(\always_cnt_reg_n_0_[1] ),
        .O(always_cnt_nxt[1]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \always_cnt[2]_i_1 
       (.I0(\always_cnt_reg_n_0_[0] ),
        .I1(\always_cnt_reg_n_0_[1] ),
        .I2(o_seg_sel_nxt),
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
  LUT6 #(
    .INIT(64'hFFFEFFFFFFFF0000)) 
    \deb_cnt[0]_i_1 
       (.I0(\deb_cnt[0]_i_3_n_0 ),
        .I1(\deb_cnt[0]_i_4_n_0 ),
        .I2(\deb_cnt[0]_i_5_n_0 ),
        .I3(\deb_cnt[0]_i_6_n_0 ),
        .I4(\deb_keep_reg_n_0_[1] ),
        .I5(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[0]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[0]_i_10 
       (.I0(deb_cnt_reg[1]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[0]_i_10_n_0 ));
  LUT3 #(
    .INIT(8'h41)) 
    \deb_cnt[0]_i_11 
       (.I0(deb_cnt_reg[0]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[0]_i_11_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \deb_cnt[0]_i_3 
       (.I0(deb_cnt_reg[2]),
        .I1(deb_cnt_reg[3]),
        .I2(deb_cnt_reg[4]),
        .I3(deb_cnt_reg[5]),
        .O(\deb_cnt[0]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \deb_cnt[0]_i_4 
       (.I0(deb_cnt_reg[15]),
        .I1(deb_cnt_reg[16]),
        .I2(deb_cnt_reg[14]),
        .I3(deb_cnt_reg[0]),
        .I4(deb_cnt_reg[1]),
        .O(\deb_cnt[0]_i_4_n_0 ));
  LUT4 #(
    .INIT(16'h7FFF)) 
    \deb_cnt[0]_i_5 
       (.I0(deb_cnt_reg[10]),
        .I1(deb_cnt_reg[11]),
        .I2(deb_cnt_reg[12]),
        .I3(deb_cnt_reg[13]),
        .O(\deb_cnt[0]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \deb_cnt[0]_i_6 
       (.I0(deb_cnt_reg[6]),
        .I1(deb_cnt_reg[7]),
        .I2(deb_cnt_reg[8]),
        .I3(deb_cnt_reg[9]),
        .O(\deb_cnt[0]_i_6_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[0]_i_7 
       (.I0(deb_cnt_reg[0]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[0]_i_7_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[0]_i_8 
       (.I0(deb_cnt_reg[3]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[0]_i_8_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[0]_i_9 
       (.I0(deb_cnt_reg[2]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[0]_i_9_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[12]_i_2 
       (.I0(deb_cnt_reg[15]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[12]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[12]_i_3 
       (.I0(deb_cnt_reg[14]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[12]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[12]_i_4 
       (.I0(deb_cnt_reg[13]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[12]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[12]_i_5 
       (.I0(deb_cnt_reg[12]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[12]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[16]_i_2 
       (.I0(deb_cnt_reg[16]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[16]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[4]_i_2 
       (.I0(deb_cnt_reg[7]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[4]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[4]_i_3 
       (.I0(deb_cnt_reg[6]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[4]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[4]_i_4 
       (.I0(deb_cnt_reg[5]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[4]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[4]_i_5 
       (.I0(deb_cnt_reg[4]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[4]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[8]_i_2 
       (.I0(deb_cnt_reg[11]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[8]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[8]_i_3 
       (.I0(deb_cnt_reg[10]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[8]_i_3_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[8]_i_4 
       (.I0(deb_cnt_reg[9]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[8]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h82)) 
    \deb_cnt[8]_i_5 
       (.I0(deb_cnt_reg[8]),
        .I1(\deb_keep_reg_n_0_[1] ),
        .I2(\deb_keep_reg_n_0_[0] ),
        .O(\deb_cnt[8]_i_5_n_0 ));
  FDCE \deb_cnt_reg[0] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[0]_i_2_n_7 ),
        .Q(deb_cnt_reg[0]));
  CARRY4 \deb_cnt_reg[0]_i_2 
       (.CI(1'b0),
        .CO({\deb_cnt_reg[0]_i_2_n_0 ,\deb_cnt_reg[0]_i_2_n_1 ,\deb_cnt_reg[0]_i_2_n_2 ,\deb_cnt_reg[0]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,\deb_cnt[0]_i_7_n_0 }),
        .O({\deb_cnt_reg[0]_i_2_n_4 ,\deb_cnt_reg[0]_i_2_n_5 ,\deb_cnt_reg[0]_i_2_n_6 ,\deb_cnt_reg[0]_i_2_n_7 }),
        .S({\deb_cnt[0]_i_8_n_0 ,\deb_cnt[0]_i_9_n_0 ,\deb_cnt[0]_i_10_n_0 ,\deb_cnt[0]_i_11_n_0 }));
  FDCE \deb_cnt_reg[10] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[8]_i_1_n_5 ),
        .Q(deb_cnt_reg[10]));
  FDCE \deb_cnt_reg[11] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[8]_i_1_n_4 ),
        .Q(deb_cnt_reg[11]));
  FDCE \deb_cnt_reg[12] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[12]_i_1_n_7 ),
        .Q(deb_cnt_reg[12]));
  CARRY4 \deb_cnt_reg[12]_i_1 
       (.CI(\deb_cnt_reg[8]_i_1_n_0 ),
        .CO({\deb_cnt_reg[12]_i_1_n_0 ,\deb_cnt_reg[12]_i_1_n_1 ,\deb_cnt_reg[12]_i_1_n_2 ,\deb_cnt_reg[12]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\deb_cnt_reg[12]_i_1_n_4 ,\deb_cnt_reg[12]_i_1_n_5 ,\deb_cnt_reg[12]_i_1_n_6 ,\deb_cnt_reg[12]_i_1_n_7 }),
        .S({\deb_cnt[12]_i_2_n_0 ,\deb_cnt[12]_i_3_n_0 ,\deb_cnt[12]_i_4_n_0 ,\deb_cnt[12]_i_5_n_0 }));
  FDCE \deb_cnt_reg[13] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[12]_i_1_n_6 ),
        .Q(deb_cnt_reg[13]));
  FDCE \deb_cnt_reg[14] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[12]_i_1_n_5 ),
        .Q(deb_cnt_reg[14]));
  FDCE \deb_cnt_reg[15] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[12]_i_1_n_4 ),
        .Q(deb_cnt_reg[15]));
  FDCE \deb_cnt_reg[16] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[16]_i_1_n_7 ),
        .Q(deb_cnt_reg[16]));
  CARRY4 \deb_cnt_reg[16]_i_1 
       (.CI(\deb_cnt_reg[12]_i_1_n_0 ),
        .CO(\NLW_deb_cnt_reg[16]_i_1_CO_UNCONNECTED [3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_deb_cnt_reg[16]_i_1_O_UNCONNECTED [3:1],\deb_cnt_reg[16]_i_1_n_7 }),
        .S({1'b0,1'b0,1'b0,\deb_cnt[16]_i_2_n_0 }));
  FDCE \deb_cnt_reg[1] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[0]_i_2_n_6 ),
        .Q(deb_cnt_reg[1]));
  FDCE \deb_cnt_reg[2] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[0]_i_2_n_5 ),
        .Q(deb_cnt_reg[2]));
  FDCE \deb_cnt_reg[3] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[0]_i_2_n_4 ),
        .Q(deb_cnt_reg[3]));
  FDCE \deb_cnt_reg[4] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[4]_i_1_n_7 ),
        .Q(deb_cnt_reg[4]));
  CARRY4 \deb_cnt_reg[4]_i_1 
       (.CI(\deb_cnt_reg[0]_i_2_n_0 ),
        .CO({\deb_cnt_reg[4]_i_1_n_0 ,\deb_cnt_reg[4]_i_1_n_1 ,\deb_cnt_reg[4]_i_1_n_2 ,\deb_cnt_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\deb_cnt_reg[4]_i_1_n_4 ,\deb_cnt_reg[4]_i_1_n_5 ,\deb_cnt_reg[4]_i_1_n_6 ,\deb_cnt_reg[4]_i_1_n_7 }),
        .S({\deb_cnt[4]_i_2_n_0 ,\deb_cnt[4]_i_3_n_0 ,\deb_cnt[4]_i_4_n_0 ,\deb_cnt[4]_i_5_n_0 }));
  FDCE \deb_cnt_reg[5] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[4]_i_1_n_6 ),
        .Q(deb_cnt_reg[5]));
  FDCE \deb_cnt_reg[6] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[4]_i_1_n_5 ),
        .Q(deb_cnt_reg[6]));
  FDCE \deb_cnt_reg[7] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[4]_i_1_n_4 ),
        .Q(deb_cnt_reg[7]));
  FDCE \deb_cnt_reg[8] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[8]_i_1_n_7 ),
        .Q(deb_cnt_reg[8]));
  CARRY4 \deb_cnt_reg[8]_i_1 
       (.CI(\deb_cnt_reg[4]_i_1_n_0 ),
        .CO({\deb_cnt_reg[8]_i_1_n_0 ,\deb_cnt_reg[8]_i_1_n_1 ,\deb_cnt_reg[8]_i_1_n_2 ,\deb_cnt_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\deb_cnt_reg[8]_i_1_n_4 ,\deb_cnt_reg[8]_i_1_n_5 ,\deb_cnt_reg[8]_i_1_n_6 ,\deb_cnt_reg[8]_i_1_n_7 }),
        .S({\deb_cnt[8]_i_2_n_0 ,\deb_cnt[8]_i_3_n_0 ,\deb_cnt[8]_i_4_n_0 ,\deb_cnt[8]_i_5_n_0 }));
  FDCE \deb_cnt_reg[9] 
       (.C(clk),
        .CE(\deb_cnt[0]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_cnt_reg[8]_i_1_n_6 ),
        .Q(deb_cnt_reg[9]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hFE)) 
    \deb_keep[0]_i_1 
       (.I0(i_button_mis),
        .I1(i_button_clr),
        .I2(i_button_add),
        .O(deb_keep_nxt));
  FDCE \deb_keep_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(deb_keep_nxt),
        .Q(\deb_keep_reg_n_0_[0] ));
  FDCE \deb_keep_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(\deb_keep_reg_n_0_[0] ),
        .Q(\deb_keep_reg_n_0_[1] ));
  LUT6 #(
    .INIT(64'h323DFFFF323D0000)) 
    \o_seg[0]_i_1 
       (.I0(seq_2nd_cnt_reg[0]),
        .I1(seq_2nd_cnt_reg[3]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[2]),
        .I4(o_seg_sel_nxt),
        .I5(seg_1[0]),
        .O(o_seg_nxt[0]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h323D)) 
    \o_seg[0]_i_2 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .I2(\seq_1st_cnt_reg_n_0_[1] ),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .O(seg_1[0]));
  LUT6 #(
    .INIT(64'hFFFFFFFFEAAEEEEE)) 
    \o_seg[1]_i_1 
       (.I0(\o_seg[3]_i_2_n_0 ),
        .I1(\o_seg[3]_i_3_n_0 ),
        .I2(\seq_1st_cnt_reg_n_0_[1] ),
        .I3(\seq_1st_cnt_reg_n_0_[0] ),
        .I4(\seq_1st_cnt_reg_n_0_[2] ),
        .I5(\o_seg[1]_i_2_n_0 ),
        .O(o_seg_nxt[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h40044444)) 
    \o_seg[1]_i_2 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(o_seg_sel_nxt),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[0]),
        .I4(seq_2nd_cnt_reg[2]),
        .O(\o_seg[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFABABABAA)) 
    \o_seg[2]_i_1 
       (.I0(\o_seg[3]_i_2_n_0 ),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .I2(o_seg_sel_nxt),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .I4(\o_seg[2]_i_2_n_0 ),
        .I5(\o_seg[2]_i_3_n_0 ),
        .O(o_seg_nxt[2]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \o_seg[2]_i_2 
       (.I0(\seq_1st_cnt_reg_n_0_[0] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .O(\o_seg[2]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h44404444)) 
    \o_seg[2]_i_3 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(o_seg_sel_nxt),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[0]),
        .I4(seq_2nd_cnt_reg[1]),
        .O(\o_seg[2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFAEEEEAAE)) 
    \o_seg[3]_i_1 
       (.I0(\o_seg[3]_i_2_n_0 ),
        .I1(\o_seg[3]_i_3_n_0 ),
        .I2(\seq_1st_cnt_reg_n_0_[2] ),
        .I3(\seq_1st_cnt_reg_n_0_[0] ),
        .I4(\seq_1st_cnt_reg_n_0_[1] ),
        .I5(\o_seg[3]_i_4_n_0 ),
        .O(o_seg_nxt[3]));
  LUT6 #(
    .INIT(64'hFF00101000001010)) 
    \o_seg[3]_i_2 
       (.I0(\seq_1st_cnt_reg_n_0_[1] ),
        .I1(\seq_1st_cnt_reg_n_0_[2] ),
        .I2(\seq_1st_cnt_reg_n_0_[3] ),
        .I3(\o_seg[3]_i_5_n_0 ),
        .I4(o_seg_sel_nxt),
        .I5(seq_2nd_cnt_reg[3]),
        .O(\o_seg[3]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \o_seg[3]_i_3 
       (.I0(o_seg_sel_nxt),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .O(\o_seg[3]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h04444004)) 
    \o_seg[3]_i_4 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(o_seg_sel_nxt),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[0]),
        .I4(seq_2nd_cnt_reg[1]),
        .O(\o_seg[3]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \o_seg[3]_i_5 
       (.I0(seq_2nd_cnt_reg[1]),
        .I1(seq_2nd_cnt_reg[2]),
        .O(\o_seg[3]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h0207FFFF02070000)) 
    \o_seg[4]_i_1 
       (.I0(seq_2nd_cnt_reg[1]),
        .I1(seq_2nd_cnt_reg[3]),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(seq_2nd_cnt_reg[2]),
        .I4(o_seg_sel_nxt),
        .I5(seg_1[4]),
        .O(o_seg_nxt[4]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h0207)) 
    \o_seg[4]_i_2 
       (.I0(\seq_1st_cnt_reg_n_0_[1] ),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .I2(\seq_1st_cnt_reg_n_0_[0] ),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .O(seg_1[4]));
  LUT6 #(
    .INIT(64'h121BFFFF121B0000)) 
    \o_seg[5]_i_1 
       (.I0(seq_2nd_cnt_reg[2]),
        .I1(seq_2nd_cnt_reg[1]),
        .I2(seq_2nd_cnt_reg[3]),
        .I3(seq_2nd_cnt_reg[0]),
        .I4(o_seg_sel_nxt),
        .I5(seg_1[5]),
        .O(o_seg_nxt[5]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h121B)) 
    \o_seg[5]_i_2 
       (.I0(\seq_1st_cnt_reg_n_0_[2] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .I2(\seq_1st_cnt_reg_n_0_[3] ),
        .I3(\seq_1st_cnt_reg_n_0_[0] ),
        .O(seg_1[5]));
  LUT6 #(
    .INIT(64'h161EFFFF161E0000)) 
    \o_seg[6]_i_1 
       (.I0(seq_2nd_cnt_reg[2]),
        .I1(seq_2nd_cnt_reg[1]),
        .I2(seq_2nd_cnt_reg[3]),
        .I3(seq_2nd_cnt_reg[0]),
        .I4(o_seg_sel_nxt),
        .I5(seg_1[6]),
        .O(o_seg_nxt[6]));
  LUT1 #(
    .INIT(2'h1)) 
    \o_seg[6]_i_2 
       (.I0(rst_n),
        .O(\o_seg[6]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h161E)) 
    \o_seg[6]_i_3 
       (.I0(\seq_1st_cnt_reg_n_0_[2] ),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .I2(\seq_1st_cnt_reg_n_0_[3] ),
        .I3(\seq_1st_cnt_reg_n_0_[0] ),
        .O(seg_1[6]));
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
  LUT5 #(
    .INIT(32'h00BB0BBB)) 
    \seq_1st_cnt[0]_i_1 
       (.I0(cnt_2nd_add_minus_sgn),
        .I1(\seq_1st_cnt_reg_n_0_[0] ),
        .I2(i_button_clr),
        .I3(deb_trg),
        .I4(\seq_1st_cnt[3]_i_6_n_0 ),
        .O(seq_1st_cnt_nxt[0]));
  LUT6 #(
    .INIT(64'h0000003700370000)) 
    \seq_1st_cnt[1]_i_1 
       (.I0(i_button_clr),
        .I1(deb_trg),
        .I2(\seq_1st_cnt[3]_i_6_n_0 ),
        .I3(cnt_2nd_add_minus_sgn),
        .I4(\seq_1st_cnt_reg_n_0_[0] ),
        .I5(\seq_1st_cnt[1]_i_2_n_0 ),
        .O(seq_1st_cnt_nxt[1]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \seq_1st_cnt[1]_i_2 
       (.I0(i_button_mis),
        .I1(\seq_1st_cnt_reg_n_0_[1] ),
        .O(\seq_1st_cnt[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000003700370000)) 
    \seq_1st_cnt[2]_i_1 
       (.I0(i_button_clr),
        .I1(deb_trg),
        .I2(\seq_1st_cnt[3]_i_6_n_0 ),
        .I3(cnt_2nd_add_minus_sgn),
        .I4(\seq_1st_cnt[2]_i_2_n_0 ),
        .I5(\seq_1st_cnt[2]_i_3_n_0 ),
        .O(seq_1st_cnt_nxt[2]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    \seq_1st_cnt[2]_i_2 
       (.I0(i_button_mis),
        .I1(\seq_1st_cnt_reg_n_0_[0] ),
        .I2(\seq_1st_cnt_reg_n_0_[1] ),
        .O(\seq_1st_cnt[2]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \seq_1st_cnt[2]_i_3 
       (.I0(\seq_1st_cnt_reg_n_0_[2] ),
        .I1(i_button_mis),
        .O(\seq_1st_cnt[2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFF00FE00)) 
    \seq_1st_cnt[3]_i_1 
       (.I0(\seq_1st_cnt[3]_i_3_n_0 ),
        .I1(\seq_1st_cnt[3]_i_4_n_0 ),
        .I2(i_button_clr),
        .I3(deb_trg),
        .I4(\seq_1st_cnt[3]_i_6_n_0 ),
        .I5(cnt_2nd_add_minus_sgn),
        .O(\seq_1st_cnt[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \seq_1st_cnt[3]_i_10 
       (.I0(deb_cnt_reg[6]),
        .I1(deb_cnt_reg[5]),
        .I2(deb_cnt_reg[4]),
        .I3(deb_cnt_reg[3]),
        .O(\seq_1st_cnt[3]_i_10_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \seq_1st_cnt[3]_i_11 
       (.I0(deb_cnt_reg[10]),
        .I1(deb_cnt_reg[9]),
        .I2(deb_cnt_reg[8]),
        .I3(deb_cnt_reg[7]),
        .O(\seq_1st_cnt[3]_i_11_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \seq_1st_cnt[3]_i_12 
       (.I0(deb_cnt_reg[11]),
        .I1(deb_cnt_reg[12]),
        .I2(deb_cnt_reg[13]),
        .I3(deb_cnt_reg[14]),
        .I4(deb_cnt_reg[16]),
        .I5(deb_cnt_reg[15]),
        .O(\seq_1st_cnt[3]_i_12_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \seq_1st_cnt[3]_i_13 
       (.I0(\seq_1st_cnt_reg_n_0_[3] ),
        .I1(\seq_1st_cnt_reg_n_0_[2] ),
        .I2(\seq_1st_cnt_reg_n_0_[0] ),
        .I3(\seq_1st_cnt_reg_n_0_[1] ),
        .O(\seq_1st_cnt[3]_i_13_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'hAAAAAAA8)) 
    \seq_1st_cnt[3]_i_14 
       (.I0(i_button_mis),
        .I1(seq_2nd_cnt_reg[1]),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(seq_2nd_cnt_reg[2]),
        .I4(seq_2nd_cnt_reg[3]),
        .O(\seq_1st_cnt[3]_i_14_n_0 ));
  LUT3 #(
    .INIT(8'h08)) 
    \seq_1st_cnt[3]_i_15 
       (.I0(deb_cnt_reg[2]),
        .I1(deb_cnt_reg[1]),
        .I2(deb_cnt_reg[0]),
        .O(\seq_1st_cnt[3]_i_15_n_0 ));
  LUT5 #(
    .INIT(32'h00EE0EEE)) 
    \seq_1st_cnt[3]_i_2 
       (.I0(cnt_2nd_add_minus_sgn),
        .I1(\seq_1st_cnt[3]_i_8_n_0 ),
        .I2(\seq_1st_cnt[3]_i_6_n_0 ),
        .I3(deb_trg),
        .I4(i_button_clr),
        .O(\seq_1st_cnt[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFF7FF00000000)) 
    \seq_1st_cnt[3]_i_3 
       (.I0(seq_1st_9_cnt_eq__2),
        .I1(seq_2nd_cnt_reg[3]),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[0]),
        .I4(seq_2nd_cnt_reg[1]),
        .I5(i_button_add),
        .O(\seq_1st_cnt[3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAAAAAAAA2)) 
    \seq_1st_cnt[3]_i_4 
       (.I0(i_button_mis),
        .I1(\seq_1st_cnt[3]_i_9_n_0 ),
        .I2(\seq_1st_cnt_reg_n_0_[3] ),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .I4(\seq_1st_cnt_reg_n_0_[0] ),
        .I5(\seq_1st_cnt_reg_n_0_[1] ),
        .O(\seq_1st_cnt[3]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0800000000000000)) 
    \seq_1st_cnt[3]_i_5 
       (.I0(deb_cnt_reg[2]),
        .I1(deb_cnt_reg[1]),
        .I2(deb_cnt_reg[0]),
        .I3(\seq_1st_cnt[3]_i_10_n_0 ),
        .I4(\seq_1st_cnt[3]_i_11_n_0 ),
        .I5(\seq_1st_cnt[3]_i_12_n_0 ),
        .O(deb_trg));
  LUT6 #(
    .INIT(64'h8888888888088888)) 
    \seq_1st_cnt[3]_i_6 
       (.I0(i_button_add),
        .I1(seq_1st_9_cnt_eq__2),
        .I2(seq_2nd_cnt_reg[3]),
        .I3(seq_2nd_cnt_reg[2]),
        .I4(seq_2nd_cnt_reg[0]),
        .I5(seq_2nd_cnt_reg[1]),
        .O(\seq_1st_cnt[3]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \seq_1st_cnt[3]_i_7 
       (.I0(\seq_1st_cnt[3]_i_13_n_0 ),
        .I1(\seq_1st_cnt[3]_i_14_n_0 ),
        .I2(\seq_1st_cnt[3]_i_12_n_0 ),
        .I3(\seq_1st_cnt[3]_i_11_n_0 ),
        .I4(\seq_1st_cnt[3]_i_10_n_0 ),
        .I5(\seq_1st_cnt[3]_i_15_n_0 ),
        .O(cnt_2nd_add_minus_sgn));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hF7EF0810)) 
    \seq_1st_cnt[3]_i_8 
       (.I0(\seq_1st_cnt_reg_n_0_[1] ),
        .I1(\seq_1st_cnt_reg_n_0_[0] ),
        .I2(i_button_mis),
        .I3(\seq_1st_cnt_reg_n_0_[2] ),
        .I4(\seq_1st_cnt_reg_n_0_[3] ),
        .O(\seq_1st_cnt[3]_i_8_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \seq_1st_cnt[3]_i_9 
       (.I0(seq_2nd_cnt_reg[3]),
        .I1(seq_2nd_cnt_reg[2]),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(seq_2nd_cnt_reg[1]),
        .O(\seq_1st_cnt[3]_i_9_n_0 ));
  FDCE \seq_1st_cnt_reg[0] 
       (.C(clk),
        .CE(\seq_1st_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(seq_1st_cnt_nxt[0]),
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
        .D(\seq_1st_cnt[3]_i_2_n_0 ),
        .Q(\seq_1st_cnt_reg_n_0_[3] ));
  LUT2 #(
    .INIT(4'h1)) 
    \seq_2nd_cnt[0]_i_1 
       (.I0(button_clr_1_eq),
        .I1(seq_2nd_cnt_reg[0]),
        .O(\seq_2nd_cnt[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h0096)) 
    \seq_2nd_cnt[1]_i_1 
       (.I0(cnt_2nd_add_minus_sgn),
        .I1(seq_2nd_cnt_reg[1]),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(button_clr_1_eq),
        .O(seq_2nd_cnt_nxt[1]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h0000BD42)) 
    \seq_2nd_cnt[2]_i_1 
       (.I0(cnt_2nd_add_minus_sgn),
        .I1(seq_2nd_cnt_reg[0]),
        .I2(seq_2nd_cnt_reg[1]),
        .I3(seq_2nd_cnt_reg[2]),
        .I4(button_clr_1_eq),
        .O(seq_2nd_cnt_nxt[2]));
  LUT6 #(
    .INIT(64'hFFFFFFFFFF008000)) 
    \seq_2nd_cnt[3]_i_1 
       (.I0(seq_1st_cnt_clr1__0),
        .I1(seq_1st_9_cnt_eq__2),
        .I2(i_button_add),
        .I3(deb_trg),
        .I4(i_button_clr),
        .I5(cnt_2nd_add_minus_sgn),
        .O(\seq_2nd_cnt[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000000DFFB2004)) 
    \seq_2nd_cnt[3]_i_2 
       (.I0(seq_2nd_cnt_reg[2]),
        .I1(cnt_2nd_add_minus_sgn),
        .I2(seq_2nd_cnt_reg[0]),
        .I3(seq_2nd_cnt_reg[1]),
        .I4(seq_2nd_cnt_reg[3]),
        .I5(button_clr_1_eq),
        .O(seq_2nd_cnt_nxt[3]));
  LUT5 #(
    .INIT(32'hFBFFFFFF)) 
    \seq_2nd_cnt[3]_i_3 
       (.I0(seq_2nd_cnt_reg[1]),
        .I1(seq_2nd_cnt_reg[0]),
        .I2(seq_2nd_cnt_reg[2]),
        .I3(seq_2nd_cnt_reg[3]),
        .I4(seq_1st_9_cnt_eq__2),
        .O(seq_1st_cnt_clr1__0));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h0040)) 
    \seq_2nd_cnt[3]_i_4 
       (.I0(\seq_1st_cnt_reg_n_0_[2] ),
        .I1(\seq_1st_cnt_reg_n_0_[3] ),
        .I2(\seq_1st_cnt_reg_n_0_[0] ),
        .I3(\seq_1st_cnt_reg_n_0_[1] ),
        .O(seq_1st_9_cnt_eq__2));
  LUT5 #(
    .INIT(32'h80000000)) 
    \seq_2nd_cnt[3]_i_5 
       (.I0(\seq_1st_cnt[3]_i_12_n_0 ),
        .I1(\seq_1st_cnt[3]_i_11_n_0 ),
        .I2(\seq_1st_cnt[3]_i_10_n_0 ),
        .I3(\seq_1st_cnt[3]_i_15_n_0 ),
        .I4(i_button_clr),
        .O(button_clr_1_eq));
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
        .D(seq_2nd_cnt_nxt[1]),
        .Q(seq_2nd_cnt_reg[1]));
  FDCE \seq_2nd_cnt_reg[2] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(seq_2nd_cnt_nxt[2]),
        .Q(seq_2nd_cnt_reg[2]));
  FDCE \seq_2nd_cnt_reg[3] 
       (.C(clk),
        .CE(\seq_2nd_cnt[3]_i_1_n_0 ),
        .CLR(\o_seg[6]_i_2_n_0 ),
        .D(seq_2nd_cnt_nxt[3]),
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
