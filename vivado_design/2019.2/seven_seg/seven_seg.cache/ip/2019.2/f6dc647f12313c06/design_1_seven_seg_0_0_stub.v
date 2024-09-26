// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue Sep 17 17:52:31 2024
// Host        : DESKTOP-6O0UNV6 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_seven_seg_0_0_stub.v
// Design      : design_1_seven_seg_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "seven_seg,Vivado 2019.2" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk, rst_n, i_buttom_add, i_buttom_mis, 
  i_buttom_clr, o_seg_1, o_seg_2)
/* synthesis syn_black_box black_box_pad_pin="clk,rst_n,i_buttom_add,i_buttom_mis,i_buttom_clr,o_seg_1[6:0],o_seg_2[6:0]" */;
  input clk;
  input rst_n;
  input i_buttom_add;
  input i_buttom_mis;
  input i_buttom_clr;
  output [6:0]o_seg_1;
  output [6:0]o_seg_2;
endmodule
