// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2021                                   
// File Name: soisp_p14_reg_rtl.v                                               
// Author: REGISTER Generator                                                   
// Release History: 2021-12-10 Initial version                                  
// File Description: SOISP_P14 Register File                                    
// -FHDR -----------------------------------------------------------------------
module soisp_p14_reg(
	//output
	i2cm_data_0,
	i2cm_data_1,
	i2cm_data_10,
	i2cm_data_11,
	i2cm_data_12,
	i2cm_data_13,
	i2cm_data_14,
	i2cm_data_15,
	i2cm_data_16,
	i2cm_data_17,
	i2cm_data_18,
	i2cm_data_19,
	i2cm_data_2,
	i2cm_data_20,
	i2cm_data_21,
	i2cm_data_22,
	i2cm_data_23,
	i2cm_data_24,
	i2cm_data_25,
	i2cm_data_26,
	i2cm_data_27,
	i2cm_data_28,
	i2cm_data_29,
	i2cm_data_3,
	i2cm_data_30,
	i2cm_data_31,
	i2cm_data_4,
	i2cm_data_5,
	i2cm_data_6,
	i2cm_data_7,
	i2cm_data_8,
	i2cm_data_9,
	reg_rd,
	//input
	reg_awb_bgain_07_00,
	reg_awb_bgain_11_08,
	reg_awb_ggain_07_00,
	reg_awb_ggain_11_08,
	reg_awb_rgain_07_00,
	reg_awb_rgain_11_08,
	reg_ssr_expln_07_00,
	reg_ssr_expln_15_08,
	reg_ssr_exptp_07_00,
	reg_ssr_exptp_11_08,
	clk,
	rst_n,
	clk_ahbs_reg_wen,
	ahbs_reg_index_wr,
	ahbs_reg_wd,
	ahbs_reg_index_rd);

//----------------------------------------------//
// Parameter declaration                        //
//----------------------------------------------//
parameter SOISP_P14_AH00      = (16'h00);       //16'h00
parameter SOISP_P14_AH01      = (16'h01);       //16'h01
parameter SOISP_P14_AH02      = (16'h02);       //16'h02
parameter SOISP_P14_AH03      = (16'h03);       //16'h03
parameter SOISP_P14_AH04      = (16'h04);       //16'h04
parameter SOISP_P14_AH05      = (16'h05);       //16'h05
parameter SOISP_P14_AH06      = (16'h06);       //16'h06
parameter SOISP_P14_AH07      = (16'h07);       //16'h07
parameter SOISP_P14_AH08      = (16'h08);       //16'h08
parameter SOISP_P14_AH09      = (16'h09);       //16'h09
parameter SOISP_P14_AH10      = (16'h10);       //16'h10
parameter SOISP_P14_AH11      = (16'h11);       //16'h11
parameter SOISP_P14_AH12      = (16'h12);       //16'h12
parameter SOISP_P14_AH13      = (16'h13);       //16'h13
parameter SOISP_P14_AH14      = (16'h14);       //16'h14
parameter SOISP_P14_AH15      = (16'h15);       //16'h15
parameter SOISP_P14_AH16      = (16'h16);       //16'h16
parameter SOISP_P14_AH17      = (16'h17);       //16'h17
parameter SOISP_P14_AH18      = (16'h18);       //16'h18
parameter SOISP_P14_AH19      = (16'h19);       //16'h19
parameter SOISP_P14_AH1A      = (16'h1a);       //16'h1a
parameter SOISP_P14_AH1B      = (16'h1b);       //16'h1b
parameter SOISP_P14_AH1C      = (16'h1c);       //16'h1c
parameter SOISP_P14_AH1D      = (16'h1d);       //16'h1d
parameter SOISP_P14_AH1E      = (16'h1e);       //16'h1e
parameter SOISP_P14_AH1F      = (16'h1f);       //16'h1f
parameter SOISP_P14_AH20      = (16'h20);       //16'h20
parameter SOISP_P14_AH21      = (16'h21);       //16'h21
parameter SOISP_P14_AH22      = (16'h22);       //16'h22
parameter SOISP_P14_AH23      = (16'h23);       //16'h23
parameter SOISP_P14_AH24      = (16'h24);       //16'h24
parameter SOISP_P14_AH25      = (16'h25);       //16'h25
parameter SOISP_P14_AH26      = (16'h26);       //16'h26
parameter SOISP_P14_AH27      = (16'h27);       //16'h27
parameter SOISP_P14_AH28      = (16'h28);       //16'h28
parameter SOISP_P14_AH29      = (16'h29);       //16'h29
parameter SOISP_P14_AH2A      = (16'h2a);       //16'h2a
parameter SOISP_P14_AH2B      = (16'h2b);       //16'h2b
parameter SOISP_P14_AH2C      = (16'h2c);       //16'h2c
parameter SOISP_P14_AH2D      = (16'h2d);       //16'h2d
parameter SOISP_P14_AH2E      = (16'h2e);       //16'h2e
parameter SOISP_P14_AH2F      = (16'h2f);       //16'h2f

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output [7:0]  reg_rd;                           //reg read data bus
output [7:0]   i2cm_data_0;                     //i2cm_data_0
output [7:0]   i2cm_data_1;                     //i2cm_data_1
output [7:0]   i2cm_data_10;                    //i2cm_data_10
output [7:0]   i2cm_data_11;                    //i2cm_data_11
output [7:0]   i2cm_data_12;                    //i2cm_data_12
output [7:0]   i2cm_data_13;                    //i2cm_data_13
output [7:0]   i2cm_data_14;                    //i2cm_data_14
output [7:0]   i2cm_data_15;                    //i2cm_data_15
output [7:0]   i2cm_data_16;                    //i2cm_data_16
output [7:0]   i2cm_data_17;                    //i2cm_data_17
output [7:0]   i2cm_data_18;                    //i2cm_data_18
output [7:0]   i2cm_data_19;                    //i2cm_data_19
output [7:0]   i2cm_data_2;                     //i2cm_data_2
output [7:0]   i2cm_data_20;                    //i2cm_data_20
output [7:0]   i2cm_data_21;                    //i2cm_data_21
output [7:0]   i2cm_data_22;                    //i2cm_data_22
output [7:0]   i2cm_data_23;                    //i2cm_data_23
output [7:0]   i2cm_data_24;                    //i2cm_data_24
output [7:0]   i2cm_data_25;                    //i2cm_data_25
output [7:0]   i2cm_data_26;                    //i2cm_data_26
output [7:0]   i2cm_data_27;                    //i2cm_data_27
output [7:0]   i2cm_data_28;                    //i2cm_data_28
output [7:0]   i2cm_data_29;                    //i2cm_data_29
output [7:0]   i2cm_data_3;                     //i2cm_data_3
output [7:0]   i2cm_data_30;                    //i2cm_data_30
output [7:0]   i2cm_data_31;                    //i2cm_data_31
output [7:0]   i2cm_data_4;                     //i2cm_data_4
output [7:0]   i2cm_data_5;                     //i2cm_data_5
output [7:0]   i2cm_data_6;                     //i2cm_data_6
output [7:0]   i2cm_data_7;                     //i2cm_data_7
output [7:0]   i2cm_data_8;                     //i2cm_data_8
output [7:0]   i2cm_data_9;                     //i2cm_data_9

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input         clk;                              //clk clock
input         rst_n;                            //rst_n reset active low
input clk_ahbs_reg_wen;                         //write clk byte enable
input [7 :0]  ahbs_reg_index_wr;                //write index
input [7:0]  ahbs_reg_wd;                       //write data
input [7 :0]  ahbs_reg_index_rd;                //read index
input [7:0]   reg_awb_bgain_07_00;              //read id reg_awb_bgain_07_00
input [3:0]   reg_awb_bgain_11_08;              //read id reg_awb_bgain_11_08
input [7:0]   reg_awb_ggain_07_00;              //read id reg_awb_ggain_07_00
input [3:0]   reg_awb_ggain_11_08;              //read id reg_awb_ggain_11_08
input [7:0]   reg_awb_rgain_07_00;              //read id reg_awb_rgain_07_00
input [3:0]   reg_awb_rgain_11_08;              //read id reg_awb_rgain_11_08
input [7:0]   reg_ssr_expln_07_00;              //read id reg_ssr_expln_07_00
input [7:0]   reg_ssr_expln_15_08;              //read id reg_ssr_expln_15_08
input [7:0]   reg_ssr_exptp_07_00;              //read id reg_ssr_exptp_07_00
input [3:0]   reg_ssr_exptp_11_08;              //read id reg_ssr_exptp_11_08

//----------------------------------------------//
// Register declaration                         //
//----------------------------------------------//
reg [7:0]  reg_rd;                              //reg read bus
reg [7:0]   i2cm_data_0;                        //i2cm_data_0
reg [7:0]   i2cm_data_1;                        //i2cm_data_1
reg [7:0]   i2cm_data_10;                       //i2cm_data_10
reg [7:0]   i2cm_data_11;                       //i2cm_data_11
reg [7:0]   i2cm_data_12;                       //i2cm_data_12
reg [7:0]   i2cm_data_13;                       //i2cm_data_13
reg [7:0]   i2cm_data_14;                       //i2cm_data_14
reg [7:0]   i2cm_data_15;                       //i2cm_data_15
reg [7:0]   i2cm_data_16;                       //i2cm_data_16
reg [7:0]   i2cm_data_17;                       //i2cm_data_17
reg [7:0]   i2cm_data_18;                       //i2cm_data_18
reg [7:0]   i2cm_data_19;                       //i2cm_data_19
reg [7:0]   i2cm_data_2;                        //i2cm_data_2
reg [7:0]   i2cm_data_20;                       //i2cm_data_20
reg [7:0]   i2cm_data_21;                       //i2cm_data_21
reg [7:0]   i2cm_data_22;                       //i2cm_data_22
reg [7:0]   i2cm_data_23;                       //i2cm_data_23
reg [7:0]   i2cm_data_24;                       //i2cm_data_24
reg [7:0]   i2cm_data_25;                       //i2cm_data_25
reg [7:0]   i2cm_data_26;                       //i2cm_data_26
reg [7:0]   i2cm_data_27;                       //i2cm_data_27
reg [7:0]   i2cm_data_28;                       //i2cm_data_28
reg [7:0]   i2cm_data_29;                       //i2cm_data_29
reg [7:0]   i2cm_data_3;                        //i2cm_data_3
reg [7:0]   i2cm_data_30;                       //i2cm_data_30
reg [7:0]   i2cm_data_31;                       //i2cm_data_31
reg [7:0]   i2cm_data_4;                        //i2cm_data_4
reg [7:0]   i2cm_data_5;                        //i2cm_data_5
reg [7:0]   i2cm_data_6;                        //i2cm_data_6
reg [7:0]   i2cm_data_7;                        //i2cm_data_7
reg [7:0]   i2cm_data_8;                        //i2cm_data_8
reg [7:0]   i2cm_data_9;                        //i2cm_data_9

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
wire write_clk_reg_en;                          //define write clk reg enable
wire addr_en_ah00;                              //addr 00 enable
wire en_soisp_p14_clk_ah00;                     //write addr 00 clk enable
wire rd_soisp_p14_ah00;                         //read addr 00 enable
wire addr_en_ah01;                              //addr 01 enable
wire en_soisp_p14_clk_ah01;                     //write addr 01 clk enable
wire rd_soisp_p14_ah01;                         //read addr 01 enable
wire addr_en_ah02;                              //addr 02 enable
wire en_soisp_p14_clk_ah02;                     //write addr 02 clk enable
wire rd_soisp_p14_ah02;                         //read addr 02 enable
wire addr_en_ah03;                              //addr 03 enable
wire en_soisp_p14_clk_ah03;                     //write addr 03 clk enable
wire rd_soisp_p14_ah03;                         //read addr 03 enable
wire addr_en_ah04;                              //addr 04 enable
wire en_soisp_p14_clk_ah04;                     //write addr 04 clk enable
wire rd_soisp_p14_ah04;                         //read addr 04 enable
wire addr_en_ah05;                              //addr 05 enable
wire en_soisp_p14_clk_ah05;                     //write addr 05 clk enable
wire rd_soisp_p14_ah05;                         //read addr 05 enable
wire addr_en_ah06;                              //addr 06 enable
wire en_soisp_p14_clk_ah06;                     //write addr 06 clk enable
wire rd_soisp_p14_ah06;                         //read addr 06 enable
wire addr_en_ah07;                              //addr 07 enable
wire en_soisp_p14_clk_ah07;                     //write addr 07 clk enable
wire rd_soisp_p14_ah07;                         //read addr 07 enable
wire addr_en_ah08;                              //addr 08 enable
wire en_soisp_p14_clk_ah08;                     //write addr 08 clk enable
wire rd_soisp_p14_ah08;                         //read addr 08 enable
wire addr_en_ah09;                              //addr 09 enable
wire en_soisp_p14_clk_ah09;                     //write addr 09 clk enable
wire rd_soisp_p14_ah09;                         //read addr 09 enable
wire addr_en_ah10;                              //addr 10 enable
wire en_soisp_p14_clk_ah10;                     //write addr 10 clk enable
wire rd_soisp_p14_ah10;                         //read addr 10 enable
wire addr_en_ah11;                              //addr 11 enable
wire en_soisp_p14_clk_ah11;                     //write addr 11 clk enable
wire rd_soisp_p14_ah11;                         //read addr 11 enable
wire addr_en_ah12;                              //addr 12 enable
wire en_soisp_p14_clk_ah12;                     //write addr 12 clk enable
wire rd_soisp_p14_ah12;                         //read addr 12 enable
wire addr_en_ah13;                              //addr 13 enable
wire en_soisp_p14_clk_ah13;                     //write addr 13 clk enable
wire rd_soisp_p14_ah13;                         //read addr 13 enable
wire addr_en_ah14;                              //addr 14 enable
wire en_soisp_p14_clk_ah14;                     //write addr 14 clk enable
wire rd_soisp_p14_ah14;                         //read addr 14 enable
wire addr_en_ah15;                              //addr 15 enable
wire en_soisp_p14_clk_ah15;                     //write addr 15 clk enable
wire rd_soisp_p14_ah15;                         //read addr 15 enable
wire addr_en_ah16;                              //addr 16 enable
wire en_soisp_p14_clk_ah16;                     //write addr 16 clk enable
wire rd_soisp_p14_ah16;                         //read addr 16 enable
wire addr_en_ah17;                              //addr 17 enable
wire en_soisp_p14_clk_ah17;                     //write addr 17 clk enable
wire rd_soisp_p14_ah17;                         //read addr 17 enable
wire addr_en_ah18;                              //addr 18 enable
wire en_soisp_p14_clk_ah18;                     //write addr 18 clk enable
wire rd_soisp_p14_ah18;                         //read addr 18 enable
wire addr_en_ah19;                              //addr 19 enable
wire en_soisp_p14_clk_ah19;                     //write addr 19 clk enable
wire rd_soisp_p14_ah19;                         //read addr 19 enable
wire addr_en_ah1a;                              //addr 1a enable
wire en_soisp_p14_clk_ah1a;                     //write addr 1a clk enable
wire rd_soisp_p14_ah1a;                         //read addr 1a enable
wire addr_en_ah1b;                              //addr 1b enable
wire en_soisp_p14_clk_ah1b;                     //write addr 1b clk enable
wire rd_soisp_p14_ah1b;                         //read addr 1b enable
wire addr_en_ah1c;                              //addr 1c enable
wire en_soisp_p14_clk_ah1c;                     //write addr 1c clk enable
wire rd_soisp_p14_ah1c;                         //read addr 1c enable
wire addr_en_ah1d;                              //addr 1d enable
wire en_soisp_p14_clk_ah1d;                     //write addr 1d clk enable
wire rd_soisp_p14_ah1d;                         //read addr 1d enable
wire addr_en_ah1e;                              //addr 1e enable
wire en_soisp_p14_clk_ah1e;                     //write addr 1e clk enable
wire rd_soisp_p14_ah1e;                         //read addr 1e enable
wire addr_en_ah1f;                              //addr 1f enable
wire en_soisp_p14_clk_ah1f;                     //write addr 1f clk enable
wire rd_soisp_p14_ah1f;                         //read addr 1f enable
wire addr_en_ah20;                              //addr 20 enable
wire en_soisp_p14_clk_ah20;                     //write addr 20 clk enable
wire rd_soisp_p14_ah20;                         //read addr 20 enable
wire addr_en_ah21;                              //addr 21 enable
wire en_soisp_p14_clk_ah21;                     //write addr 21 clk enable
wire rd_soisp_p14_ah21;                         //read addr 21 enable
wire addr_en_ah22;                              //addr 22 enable
wire en_soisp_p14_clk_ah22;                     //write addr 22 clk enable
wire rd_soisp_p14_ah22;                         //read addr 22 enable
wire addr_en_ah23;                              //addr 23 enable
wire en_soisp_p14_clk_ah23;                     //write addr 23 clk enable
wire rd_soisp_p14_ah23;                         //read addr 23 enable
wire addr_en_ah24;                              //addr 24 enable
wire en_soisp_p14_clk_ah24;                     //write addr 24 clk enable
wire rd_soisp_p14_ah24;                         //read addr 24 enable
wire addr_en_ah25;                              //addr 25 enable
wire en_soisp_p14_clk_ah25;                     //write addr 25 clk enable
wire rd_soisp_p14_ah25;                         //read addr 25 enable
wire addr_en_ah26;                              //addr 26 enable
wire en_soisp_p14_clk_ah26;                     //write addr 26 clk enable
wire rd_soisp_p14_ah26;                         //read addr 26 enable
wire addr_en_ah27;                              //addr 27 enable
wire en_soisp_p14_clk_ah27;                     //write addr 27 clk enable
wire rd_soisp_p14_ah27;                         //read addr 27 enable
wire addr_en_ah28;                              //addr 28 enable
wire en_soisp_p14_clk_ah28;                     //write addr 28 clk enable
wire rd_soisp_p14_ah28;                         //read addr 28 enable
wire addr_en_ah29;                              //addr 29 enable
wire en_soisp_p14_clk_ah29;                     //write addr 29 clk enable
wire rd_soisp_p14_ah29;                         //read addr 29 enable
wire addr_en_ah2a;                              //addr 2a enable
wire en_soisp_p14_clk_ah2a;                     //write addr 2a clk enable
wire rd_soisp_p14_ah2a;                         //read addr 2a enable
wire addr_en_ah2b;                              //addr 2b enable
wire en_soisp_p14_clk_ah2b;                     //write addr 2b clk enable
wire rd_soisp_p14_ah2b;                         //read addr 2b enable
wire addr_en_ah2c;                              //addr 2c enable
wire en_soisp_p14_clk_ah2c;                     //write addr 2c clk enable
wire rd_soisp_p14_ah2c;                         //read addr 2c enable
wire addr_en_ah2d;                              //addr 2d enable
wire en_soisp_p14_clk_ah2d;                     //write addr 2d clk enable
wire rd_soisp_p14_ah2d;                         //read addr 2d enable
wire addr_en_ah2e;                              //addr 2e enable
wire en_soisp_p14_clk_ah2e;                     //write addr 2e clk enable
wire rd_soisp_p14_ah2e;                         //read addr 2e enable
wire addr_en_ah2f;                              //addr 2f enable
wire en_soisp_p14_clk_ah2f;                     //write addr 2f clk enable
wire rd_soisp_p14_ah2f;                         //read addr 2f enable
wire [7:0] reg_index_rd;                        //reg_index_rd
wire [7:0] reg_index_wr;                        //reg_index_wr
wire [7:0] reg_wd;                              //reg_wd

//----------------------------------------------//
// Define Combinational Logic                   //
//----------------------------------------------//
//define register read/write
assign reg_index_wr   = ahbs_reg_index_wr;
assign reg_wd      = ahbs_reg_wd;
assign reg_index_rd   = ahbs_reg_index_rd;
wire clk_reg_wen;                               //clk_reg_wen
assign clk_reg_wen = clk_ahbs_reg_wen;
assign write_clk_reg_en = clk_ahbs_reg_wen;

//define address/read enable
assign addr_en_ah00 = reg_index_wr == SOISP_P14_AH00      ;
assign en_soisp_p14_clk_ah00 = write_clk_reg_en & addr_en_ah00;
assign rd_soisp_p14_ah00 = reg_index_rd == SOISP_P14_AH00      ;
assign addr_en_ah01 = reg_index_wr == SOISP_P14_AH01      ;
assign en_soisp_p14_clk_ah01 = write_clk_reg_en & addr_en_ah01;
assign rd_soisp_p14_ah01 = reg_index_rd == SOISP_P14_AH01      ;
assign addr_en_ah02 = reg_index_wr == SOISP_P14_AH02      ;
assign en_soisp_p14_clk_ah02 = write_clk_reg_en & addr_en_ah02;
assign rd_soisp_p14_ah02 = reg_index_rd == SOISP_P14_AH02      ;
assign addr_en_ah03 = reg_index_wr == SOISP_P14_AH03      ;
assign en_soisp_p14_clk_ah03 = write_clk_reg_en & addr_en_ah03;
assign rd_soisp_p14_ah03 = reg_index_rd == SOISP_P14_AH03      ;
assign addr_en_ah04 = reg_index_wr == SOISP_P14_AH04      ;
assign en_soisp_p14_clk_ah04 = write_clk_reg_en & addr_en_ah04;
assign rd_soisp_p14_ah04 = reg_index_rd == SOISP_P14_AH04      ;
assign addr_en_ah05 = reg_index_wr == SOISP_P14_AH05      ;
assign en_soisp_p14_clk_ah05 = write_clk_reg_en & addr_en_ah05;
assign rd_soisp_p14_ah05 = reg_index_rd == SOISP_P14_AH05      ;
assign addr_en_ah06 = reg_index_wr == SOISP_P14_AH06      ;
assign en_soisp_p14_clk_ah06 = write_clk_reg_en & addr_en_ah06;
assign rd_soisp_p14_ah06 = reg_index_rd == SOISP_P14_AH06      ;
assign addr_en_ah07 = reg_index_wr == SOISP_P14_AH07      ;
assign en_soisp_p14_clk_ah07 = write_clk_reg_en & addr_en_ah07;
assign rd_soisp_p14_ah07 = reg_index_rd == SOISP_P14_AH07      ;
assign addr_en_ah08 = reg_index_wr == SOISP_P14_AH08      ;
assign en_soisp_p14_clk_ah08 = write_clk_reg_en & addr_en_ah08;
assign rd_soisp_p14_ah08 = reg_index_rd == SOISP_P14_AH08      ;
assign addr_en_ah09 = reg_index_wr == SOISP_P14_AH09      ;
assign en_soisp_p14_clk_ah09 = write_clk_reg_en & addr_en_ah09;
assign rd_soisp_p14_ah09 = reg_index_rd == SOISP_P14_AH09      ;
assign addr_en_ah10 = reg_index_wr == SOISP_P14_AH10      ;
assign en_soisp_p14_clk_ah10 = write_clk_reg_en & addr_en_ah10;
assign rd_soisp_p14_ah10 = reg_index_rd == SOISP_P14_AH10      ;
assign addr_en_ah11 = reg_index_wr == SOISP_P14_AH11      ;
assign en_soisp_p14_clk_ah11 = write_clk_reg_en & addr_en_ah11;
assign rd_soisp_p14_ah11 = reg_index_rd == SOISP_P14_AH11      ;
assign addr_en_ah12 = reg_index_wr == SOISP_P14_AH12      ;
assign en_soisp_p14_clk_ah12 = write_clk_reg_en & addr_en_ah12;
assign rd_soisp_p14_ah12 = reg_index_rd == SOISP_P14_AH12      ;
assign addr_en_ah13 = reg_index_wr == SOISP_P14_AH13      ;
assign en_soisp_p14_clk_ah13 = write_clk_reg_en & addr_en_ah13;
assign rd_soisp_p14_ah13 = reg_index_rd == SOISP_P14_AH13      ;
assign addr_en_ah14 = reg_index_wr == SOISP_P14_AH14      ;
assign en_soisp_p14_clk_ah14 = write_clk_reg_en & addr_en_ah14;
assign rd_soisp_p14_ah14 = reg_index_rd == SOISP_P14_AH14      ;
assign addr_en_ah15 = reg_index_wr == SOISP_P14_AH15      ;
assign en_soisp_p14_clk_ah15 = write_clk_reg_en & addr_en_ah15;
assign rd_soisp_p14_ah15 = reg_index_rd == SOISP_P14_AH15      ;
assign addr_en_ah16 = reg_index_wr == SOISP_P14_AH16      ;
assign en_soisp_p14_clk_ah16 = write_clk_reg_en & addr_en_ah16;
assign rd_soisp_p14_ah16 = reg_index_rd == SOISP_P14_AH16      ;
assign addr_en_ah17 = reg_index_wr == SOISP_P14_AH17      ;
assign en_soisp_p14_clk_ah17 = write_clk_reg_en & addr_en_ah17;
assign rd_soisp_p14_ah17 = reg_index_rd == SOISP_P14_AH17      ;
assign addr_en_ah18 = reg_index_wr == SOISP_P14_AH18      ;
assign en_soisp_p14_clk_ah18 = write_clk_reg_en & addr_en_ah18;
assign rd_soisp_p14_ah18 = reg_index_rd == SOISP_P14_AH18      ;
assign addr_en_ah19 = reg_index_wr == SOISP_P14_AH19      ;
assign en_soisp_p14_clk_ah19 = write_clk_reg_en & addr_en_ah19;
assign rd_soisp_p14_ah19 = reg_index_rd == SOISP_P14_AH19      ;
assign addr_en_ah1a = reg_index_wr == SOISP_P14_AH1A      ;
assign en_soisp_p14_clk_ah1a = write_clk_reg_en & addr_en_ah1a;
assign rd_soisp_p14_ah1a = reg_index_rd == SOISP_P14_AH1A      ;
assign addr_en_ah1b = reg_index_wr == SOISP_P14_AH1B      ;
assign en_soisp_p14_clk_ah1b = write_clk_reg_en & addr_en_ah1b;
assign rd_soisp_p14_ah1b = reg_index_rd == SOISP_P14_AH1B      ;
assign addr_en_ah1c = reg_index_wr == SOISP_P14_AH1C      ;
assign en_soisp_p14_clk_ah1c = write_clk_reg_en & addr_en_ah1c;
assign rd_soisp_p14_ah1c = reg_index_rd == SOISP_P14_AH1C      ;
assign addr_en_ah1d = reg_index_wr == SOISP_P14_AH1D      ;
assign en_soisp_p14_clk_ah1d = write_clk_reg_en & addr_en_ah1d;
assign rd_soisp_p14_ah1d = reg_index_rd == SOISP_P14_AH1D      ;
assign addr_en_ah1e = reg_index_wr == SOISP_P14_AH1E      ;
assign en_soisp_p14_clk_ah1e = write_clk_reg_en & addr_en_ah1e;
assign rd_soisp_p14_ah1e = reg_index_rd == SOISP_P14_AH1E      ;
assign addr_en_ah1f = reg_index_wr == SOISP_P14_AH1F      ;
assign en_soisp_p14_clk_ah1f = write_clk_reg_en & addr_en_ah1f;
assign rd_soisp_p14_ah1f = reg_index_rd == SOISP_P14_AH1F      ;
assign addr_en_ah20 = reg_index_wr == SOISP_P14_AH20      ;
assign en_soisp_p14_clk_ah20 = write_clk_reg_en & addr_en_ah20;
assign rd_soisp_p14_ah20 = reg_index_rd == SOISP_P14_AH20      ;
assign addr_en_ah21 = reg_index_wr == SOISP_P14_AH21      ;
assign en_soisp_p14_clk_ah21 = write_clk_reg_en & addr_en_ah21;
assign rd_soisp_p14_ah21 = reg_index_rd == SOISP_P14_AH21      ;
assign addr_en_ah22 = reg_index_wr == SOISP_P14_AH22      ;
assign en_soisp_p14_clk_ah22 = write_clk_reg_en & addr_en_ah22;
assign rd_soisp_p14_ah22 = reg_index_rd == SOISP_P14_AH22      ;
assign addr_en_ah23 = reg_index_wr == SOISP_P14_AH23      ;
assign en_soisp_p14_clk_ah23 = write_clk_reg_en & addr_en_ah23;
assign rd_soisp_p14_ah23 = reg_index_rd == SOISP_P14_AH23      ;
assign addr_en_ah24 = reg_index_wr == SOISP_P14_AH24      ;
assign en_soisp_p14_clk_ah24 = write_clk_reg_en & addr_en_ah24;
assign rd_soisp_p14_ah24 = reg_index_rd == SOISP_P14_AH24      ;
assign addr_en_ah25 = reg_index_wr == SOISP_P14_AH25      ;
assign en_soisp_p14_clk_ah25 = write_clk_reg_en & addr_en_ah25;
assign rd_soisp_p14_ah25 = reg_index_rd == SOISP_P14_AH25      ;
assign addr_en_ah26 = reg_index_wr == SOISP_P14_AH26      ;
assign en_soisp_p14_clk_ah26 = write_clk_reg_en & addr_en_ah26;
assign rd_soisp_p14_ah26 = reg_index_rd == SOISP_P14_AH26      ;
assign addr_en_ah27 = reg_index_wr == SOISP_P14_AH27      ;
assign en_soisp_p14_clk_ah27 = write_clk_reg_en & addr_en_ah27;
assign rd_soisp_p14_ah27 = reg_index_rd == SOISP_P14_AH27      ;
assign addr_en_ah28 = reg_index_wr == SOISP_P14_AH28      ;
assign en_soisp_p14_clk_ah28 = write_clk_reg_en & addr_en_ah28;
assign rd_soisp_p14_ah28 = reg_index_rd == SOISP_P14_AH28      ;
assign addr_en_ah29 = reg_index_wr == SOISP_P14_AH29      ;
assign en_soisp_p14_clk_ah29 = write_clk_reg_en & addr_en_ah29;
assign rd_soisp_p14_ah29 = reg_index_rd == SOISP_P14_AH29      ;
assign addr_en_ah2a = reg_index_wr == SOISP_P14_AH2A      ;
assign en_soisp_p14_clk_ah2a = write_clk_reg_en & addr_en_ah2a;
assign rd_soisp_p14_ah2a = reg_index_rd == SOISP_P14_AH2A      ;
assign addr_en_ah2b = reg_index_wr == SOISP_P14_AH2B      ;
assign en_soisp_p14_clk_ah2b = write_clk_reg_en & addr_en_ah2b;
assign rd_soisp_p14_ah2b = reg_index_rd == SOISP_P14_AH2B      ;
assign addr_en_ah2c = reg_index_wr == SOISP_P14_AH2C      ;
assign en_soisp_p14_clk_ah2c = write_clk_reg_en & addr_en_ah2c;
assign rd_soisp_p14_ah2c = reg_index_rd == SOISP_P14_AH2C      ;
assign addr_en_ah2d = reg_index_wr == SOISP_P14_AH2D      ;
assign en_soisp_p14_clk_ah2d = write_clk_reg_en & addr_en_ah2d;
assign rd_soisp_p14_ah2d = reg_index_rd == SOISP_P14_AH2D      ;
assign addr_en_ah2e = reg_index_wr == SOISP_P14_AH2E      ;
assign en_soisp_p14_clk_ah2e = write_clk_reg_en & addr_en_ah2e;
assign rd_soisp_p14_ah2e = reg_index_rd == SOISP_P14_AH2E      ;
assign addr_en_ah2f = reg_index_wr == SOISP_P14_AH2F      ;
assign en_soisp_p14_clk_ah2f = write_clk_reg_en & addr_en_ah2f;
assign rd_soisp_p14_ah2f = reg_index_rd == SOISP_P14_AH2F      ;

//define auto clear


//define register read bus
always@(*)begin: reg_bank_rd_blk

	reg_rd = 8'h0;
	if(rd_soisp_p14_ah00)
		reg_rd[7:0] = {reg_awb_bgain_07_00};
	else if(rd_soisp_p14_ah01)
		reg_rd[3:0] = {reg_awb_bgain_11_08};
	else if(rd_soisp_p14_ah02)
		reg_rd[7:0] = {reg_awb_ggain_07_00};
	else if(rd_soisp_p14_ah03)
		reg_rd[3:0] = {reg_awb_ggain_11_08};
	else if(rd_soisp_p14_ah04)
		reg_rd[7:0] = {reg_awb_rgain_07_00};
	else if(rd_soisp_p14_ah05)
		reg_rd[3:0] = {reg_awb_rgain_11_08};
	else if(rd_soisp_p14_ah06)
		reg_rd[7:0] = {reg_ssr_expln_07_00};
	else if(rd_soisp_p14_ah07)
		reg_rd[7:0] = {reg_ssr_expln_15_08};
	else if(rd_soisp_p14_ah08)
		reg_rd[7:0] = {reg_ssr_exptp_07_00};
	else if(rd_soisp_p14_ah09)
		reg_rd[3:0] = {reg_ssr_exptp_11_08};
	else if(rd_soisp_p14_ah10)
		reg_rd[7:0] = {i2cm_data_0};
	else if(rd_soisp_p14_ah11)
		reg_rd[7:0] = {i2cm_data_1};
	else if(rd_soisp_p14_ah12)
		reg_rd[7:0] = {i2cm_data_2};
	else if(rd_soisp_p14_ah13)
		reg_rd[7:0] = {i2cm_data_3};
	else if(rd_soisp_p14_ah14)
		reg_rd[7:0] = {i2cm_data_4};
	else if(rd_soisp_p14_ah15)
		reg_rd[7:0] = {i2cm_data_5};
	else if(rd_soisp_p14_ah16)
		reg_rd[7:0] = {i2cm_data_6};
	else if(rd_soisp_p14_ah17)
		reg_rd[7:0] = {i2cm_data_7};
	else if(rd_soisp_p14_ah18)
		reg_rd[7:0] = {i2cm_data_8};
	else if(rd_soisp_p14_ah19)
		reg_rd[7:0] = {i2cm_data_9};
	else if(rd_soisp_p14_ah1a)
		reg_rd[7:0] = {i2cm_data_10};
	else if(rd_soisp_p14_ah1b)
		reg_rd[7:0] = {i2cm_data_11};
	else if(rd_soisp_p14_ah1c)
		reg_rd[7:0] = {i2cm_data_12};
	else if(rd_soisp_p14_ah1d)
		reg_rd[7:0] = {i2cm_data_13};
	else if(rd_soisp_p14_ah1e)
		reg_rd[7:0] = {i2cm_data_14};
	else if(rd_soisp_p14_ah1f)
		reg_rd[7:0] = {i2cm_data_15};
	else if(rd_soisp_p14_ah20)
		reg_rd[7:0] = {i2cm_data_16};
	else if(rd_soisp_p14_ah21)
		reg_rd[7:0] = {i2cm_data_17};
	else if(rd_soisp_p14_ah22)
		reg_rd[7:0] = {i2cm_data_18};
	else if(rd_soisp_p14_ah23)
		reg_rd[7:0] = {i2cm_data_19};
	else if(rd_soisp_p14_ah24)
		reg_rd[7:0] = {i2cm_data_20};
	else if(rd_soisp_p14_ah25)
		reg_rd[7:0] = {i2cm_data_21};
	else if(rd_soisp_p14_ah26)
		reg_rd[7:0] = {i2cm_data_22};
	else if(rd_soisp_p14_ah27)
		reg_rd[7:0] = {i2cm_data_23};
	else if(rd_soisp_p14_ah28)
		reg_rd[7:0] = {i2cm_data_24};
	else if(rd_soisp_p14_ah29)
		reg_rd[7:0] = {i2cm_data_25};
	else if(rd_soisp_p14_ah2a)
		reg_rd[7:0] = {i2cm_data_26};
	else if(rd_soisp_p14_ah2b)
		reg_rd[7:0] = {i2cm_data_27};
	else if(rd_soisp_p14_ah2c)
		reg_rd[7:0] = {i2cm_data_28};
	else if(rd_soisp_p14_ah2d)
		reg_rd[7:0] = {i2cm_data_29};
	else if(rd_soisp_p14_ah2e)
		reg_rd[7:0] = {i2cm_data_30};
	else if(rd_soisp_p14_ah2f)
		reg_rd[7:0] = {i2cm_data_31};
end

//----------------------------------------------//
// Define Sequential Logic                      //
//----------------------------------------------//
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_0 <= 8'h00;
	else if(en_soisp_p14_clk_ah10)begin
		i2cm_data_0 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_1 <= 8'h00;
	else if(en_soisp_p14_clk_ah11)begin
		i2cm_data_1 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_10 <= 8'h00;
	else if(en_soisp_p14_clk_ah1a)begin
		i2cm_data_10 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_11 <= 8'h00;
	else if(en_soisp_p14_clk_ah1b)begin
		i2cm_data_11 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_12 <= 8'h00;
	else if(en_soisp_p14_clk_ah1c)begin
		i2cm_data_12 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_13 <= 8'h00;
	else if(en_soisp_p14_clk_ah1d)begin
		i2cm_data_13 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_14 <= 8'h00;
	else if(en_soisp_p14_clk_ah1e)begin
		i2cm_data_14 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_15 <= 8'h00;
	else if(en_soisp_p14_clk_ah1f)begin
		i2cm_data_15 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_16 <= 8'h00;
	else if(en_soisp_p14_clk_ah20)begin
		i2cm_data_16 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_17 <= 8'h00;
	else if(en_soisp_p14_clk_ah21)begin
		i2cm_data_17 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_18 <= 8'h00;
	else if(en_soisp_p14_clk_ah22)begin
		i2cm_data_18 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_19 <= 8'h00;
	else if(en_soisp_p14_clk_ah23)begin
		i2cm_data_19 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_2 <= 8'h00;
	else if(en_soisp_p14_clk_ah12)begin
		i2cm_data_2 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_20 <= 8'h00;
	else if(en_soisp_p14_clk_ah24)begin
		i2cm_data_20 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_21 <= 8'h00;
	else if(en_soisp_p14_clk_ah25)begin
		i2cm_data_21 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_22 <= 8'h00;
	else if(en_soisp_p14_clk_ah26)begin
		i2cm_data_22 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_23 <= 8'h00;
	else if(en_soisp_p14_clk_ah27)begin
		i2cm_data_23 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_24 <= 8'h00;
	else if(en_soisp_p14_clk_ah28)begin
		i2cm_data_24 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_25 <= 8'h00;
	else if(en_soisp_p14_clk_ah29)begin
		i2cm_data_25 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_26 <= 8'h00;
	else if(en_soisp_p14_clk_ah2a)begin
		i2cm_data_26 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_27 <= 8'h00;
	else if(en_soisp_p14_clk_ah2b)begin
		i2cm_data_27 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_28 <= 8'h00;
	else if(en_soisp_p14_clk_ah2c)begin
		i2cm_data_28 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_29 <= 8'h00;
	else if(en_soisp_p14_clk_ah2d)begin
		i2cm_data_29 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_3 <= 8'h00;
	else if(en_soisp_p14_clk_ah13)begin
		i2cm_data_3 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_30 <= 8'h00;
	else if(en_soisp_p14_clk_ah2e)begin
		i2cm_data_30 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_31 <= 8'h00;
	else if(en_soisp_p14_clk_ah2f)begin
		i2cm_data_31 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_4 <= 8'h00;
	else if(en_soisp_p14_clk_ah14)begin
		i2cm_data_4 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_5 <= 8'h00;
	else if(en_soisp_p14_clk_ah15)begin
		i2cm_data_5 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_6 <= 8'h00;
	else if(en_soisp_p14_clk_ah16)begin
		i2cm_data_6 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_7 <= 8'h00;
	else if(en_soisp_p14_clk_ah17)begin
		i2cm_data_7 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_8 <= 8'h00;
	else if(en_soisp_p14_clk_ah18)begin
		i2cm_data_8 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		i2cm_data_9 <= 8'h00;
	else if(en_soisp_p14_clk_ah19)begin
		i2cm_data_9 <= reg_wd[7:0];
	end
end


endmodule

