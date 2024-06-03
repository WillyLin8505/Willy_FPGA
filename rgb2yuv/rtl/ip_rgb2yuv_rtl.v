// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           ip_rgb2y_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description:    RGB to Y Converter
// Abbreviations:
// Parameters:          PRECISION: 1: Higher precision; 0: Lower precision
//
// -FHDR -----------------------------------------------------------------------

module  ip_rgb2yuv(
            // Output
                o_data_y,
                o_data_cb,
                o_data_cr,
            // Input
                i_data_r,
                i_data_g,
                i_data_b
            );

parameter   DAT_SZ      = 10;
parameter   PRECISION   = 0;
parameter   COM_SZ      = DAT_SZ-1+9;

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output [7:0]                  o_data_y;                      //
output [7:0]                  o_data_cb;                     //
output [7:0]                  o_data_cr;                     //

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input [DAT_SZ-1:0]            i_data_r;                      // input R
input [DAT_SZ-1:0]            i_data_g;                      // input G
input [DAT_SZ-1:0]            i_data_b;                      // input B

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//

wire [DAT_SZ-1+7:0]           r_x77;                  // Pixel R*77
wire [DAT_SZ-1+8:0]           g_x150;                 // Pixel R*150
wire [DAT_SZ-1+5:0]           b_x29;                  // Pixel B*29
wire [DAT_SZ-1+9:0]           y_x256;                 // Y value * 256

wire [DAT_SZ-1+6:0]           r_x43;
wire [DAT_SZ-1+7:0]           g_x84;
wire [DAT_SZ-1+7:0]           b_x127;
wire signed [DAT_SZ-1+9:0]    cb_x256;

wire [DAT_SZ-1+7:0]           r_x127;
wire [DAT_SZ-1+7:0]           g_x106;
wire [DAT_SZ-1+5:0]           b_x21; 
wire signed [DAT_SZ-1+9:0]    cr_x256;

wire signed [DAT_SZ-1+4:0]    r_x9;                   // Pixel R*9
wire signed [DAT_SZ-1+5:0]    g_x19;                  // Pixel R*9
wire signed [DAT_SZ-1+2:0]    b_x4;                   // Pixel B*4
wire signed [DAT_SZ-1+5:0]    y_x32;                  // Y value * 32

wire signed [DAT_SZ-1+4:0]    r_x5; 
wire signed [DAT_SZ-1+5:0]    g_x11; 
wire signed [DAT_SZ-1+2:0]    b_x16; 
wire signed [DAT_SZ-1+5:0]    cb_x32; 

wire signed [DAT_SZ-1+4:0]    r_x16; 
wire signed [DAT_SZ-1+5:0]    g_x14; 
wire signed [DAT_SZ-1+2:0]    b_x3; 
wire signed [DAT_SZ-1+5:0]    cr_x32; 

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

generate
   if (PRECISION == 1) begin: gen_hi_precision
// 8 bit Higher precision
//Y =    0.299*R'+     0.587*G'+    0.114*B'
//Y = (77/256)*R + (150/256)*G + (29/256)*B = (R*77 + G*150 + B*29)/256
//R coefficient: 77  = 64 ( <<6) + 8 ( <<3) + 4( <<2) + 1( <<0)
//G coefficient: 150 = 128( <<7) + 16( <<4) + 4( <<2) + 2( <<1)
//B coefficient: 29  = 32 ( <<5) - 4( <<2) + 1( <<0)
assign  r_x77      = (i_data_r <<6) + (i_data_r <<3) + (i_data_r <<2) +  i_data_r;
assign  g_x150     = (i_data_g <<7) + (i_data_g <<4) + (i_data_g <<2) + (i_data_g <<1);
assign  b_x29      = (i_data_b <<5) - (i_data_b <<2) + i_data_b;

assign  y_x256     = r_x77 + g_x150 + b_x29;
assign  o_data_y   = (y_x256 + 8'h80)>> 8;

//Cb = 128 - 0.168*R' - 0.331*G' + 0.5*B' 
//Cb = -(43/256)*R' - (85/256)*G' + (128/256)*B' + 128
//fix equation  
//Cb = -(43/256)*R' - (84/256)*G' + (127/256)*B' + 128
//R coefficient: 43  = 32 ( <<5) + 8 ( <<3) + 2( <<1) + 1( <<0) 
//G coefficient: 84  = 64 ( <<6) + 16( <<4) + 4( <<2) 
//B coefficient: 127 = 128( <<7) - 1( <<0) 
assign  r_x43      = (i_data_r <<5) + (i_data_r <<3) + (i_data_r <<1)+ (i_data_r <<0);       
assign  g_x84      = (i_data_g <<6) + (i_data_g <<4) + (i_data_g <<2) ;
assign  b_x127     = (i_data_b <<7) - (i_data_b <<0);

assign  cb_x256    = -$signed({1'b0,r_x43}) - $signed({1'b0,g_x84}) + $signed({1'b0,b_x127});
assign  o_data_cb  = 8'h80 + ((cb_x256 + 8'h80)>>8); 
//Cr =  128 + 0.5*R' - 0.418*G' - 0.081*B' 
//Cr =  (128/256)*R' + (107/256)*G' + (21/256)*B' + 128
//fix equation  
//Cr =  (127/256)*R' + (106/256)*G' + (21/256)*B' + 128
//R coefficient: 127  = 128( <<7) - 1( <<0)
//G coefficient: 106  = 128( <<7) - 16( <<4) - 4 ( <<2) - 2( <<1)
//B coefficient: 21   = 16 ( <<4) + 4 ( <<2) + 1( <<0)
assign  r_x127     = (i_data_r <<7) - (i_data_r <<0);
assign  g_x106     = (i_data_g <<7) - (i_data_g <<4) - (i_data_g <<2) - (i_data_g <<1);
assign  b_x21      = (i_data_b <<4) + (i_data_b <<2) + (i_data_b <<0) ;

assign  cr_x256    = $signed({1'b0,r_x127}) - g_x106 - $signed({1'b0,b_x21});
assign  o_data_cr  = 8'h80 + ((cr_x256 + 8'h80)>>8); 
   end
   else begin: gen_low_precision
// 8 bit Lower precision
//Y = (9/32)*R + (19/32)*G + (4/32)*B = (R*9 + G*19 + B*4)/32
//R coefficient: 9  = 8 ( <<3) + 1( <<0)
//G coefficient: 19 = 16( <<4) + 2( <<1) + 1( <<0)
//B coefficient: 4  = 4( <<2)

assign  r_x9     = (i_data_r <<3) + i_data_r;
assign  g_x19    = (i_data_g <<4) + (i_data_g <<1) + i_data_g;
assign  b_x4     = i_data_b <<2;

assign  y_x32    = r_x9 + g_x19 + b_x4;
assign  o_data_y = y_x32 >> 5;

//R coefficient: 5  = 4 ( <<2) + 1( <<0)
//G coefficient: 11 = 8 ( <<3) + 2( <<1) + 1( <<0)
//B coefficient: 16 = 16( <<4)

assign  r_x5      = (i_data_r <<2) + i_data_r;
assign  g_x11     = (i_data_g <<3) + (i_data_g <<1) + i_data_g;
assign  b_x16     = i_data_b <<4;

assign  cb_x32    = r_x5 + g_x11 + b_x16;
assign  o_data_cb = cb_x32 >> 5;

//R coefficient: 16 = 16( <<4)
//G coefficient: 14 = 8 ( <<3) + 4( <<2) + 2( <<1)
//B coefficient: 3 = 2( <<1) + 1( <<0)

assign  r_x16      = (i_data_r <<4);
assign  g_x14      = (i_data_g <<3) + (i_data_g <<2) + (i_data_g <<1);
assign  b_x3       = (i_data_b <<1) + i_data_b;

assign  cr_x32     = r_x16 + g_x14 + b_x3;
assign  o_data_cr  = cr_x32 >> 5;

   end
endgenerate

endmodule
