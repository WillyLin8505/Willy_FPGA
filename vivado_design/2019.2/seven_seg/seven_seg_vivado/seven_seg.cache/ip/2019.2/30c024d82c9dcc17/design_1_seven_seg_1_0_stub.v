// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue Sep 24 19:18:21 2024
// Host        : DESKTOP-6O0UNV6 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_seven_seg_1_0_stub.v
// Design      : design_1_seven_seg_1_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "seven_seg,Vivado 2019.2" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk, rst_n, i_button_add, i_button_mis, 
  i_button_clr, o_seg, o_seg_sel)
/* synthesis syn_black_box black_box_pad_pin="clk,rst_n,i_button_add,i_button_mis,i_button_clr,o_seg[6:0],o_seg_sel" */;
  input clk;
  input rst_n;
  input i_button_add;
  input i_button_mis;
  input i_button_clr;
  output [6:0]o_seg;
  output o_seg_sel;
endmodule
