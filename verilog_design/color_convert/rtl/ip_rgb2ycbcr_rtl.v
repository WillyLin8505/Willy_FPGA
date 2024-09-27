// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_rgb2ycbcr_rtl.v
// Author:              1.Willy Lin
//                      2.Martin Chen 
//                      3.Humphrey Lin
// Version:             1.0
// Last Modified On:    2022/10/25
//
// File Description:    RGB to YCBCR Converter
// Abbreviations:
// Parameters:          PRECISION:      S 1.12
// Data precision :     input  :          8.0
//                      outupt : Y    :   8.4
//                               CBCR : S 7.4 or 8.4
// Consuming time :     4T  
//
// -FHDR -----------------------------------------------------------------------

module ip_rgb2ycbcr
    #(
         parameter   CIIW       = 8,             //Accuracy Input Integer Width  //Accuracy can be reduced , but not improved //sign bit are include
         parameter   CIPW       = 0,             //Accuracy Input Point Width    //Accuracy can be reduced , but not improved 
         parameter   COIW       = 8,             //Accuracy Output Integer Width //Accuracy can be reduced , but not improved //sign bit are include
         parameter   COPW       = 4,             //Accuracy Output Point Width   //Accuracy can be reduced , but not improved 
         parameter   CIW        = CIIW + CIPW,
         parameter   COW        = COIW + COPW,
         parameter   YCBCR_POS  = 1              //data output range 0 : -128 ~ 127
                                                 //                  1 :   0  ~ 255 
     )
(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output reg        [COW-1:0]              o_data_y,                      
output signed     [COW:0]                o_data_cb,
output signed     [COW:0]                o_data_cr,                    
output                                   o_hstr,
output                                   o_hend,
output                                   o_href,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input             [CIW-1:0]              i_data_r,                      // input R
input             [CIW-1:0]              i_data_g,                      // input G
input             [CIW-1:0]              i_data_b,                      // input B
input                                    i_hstr,
input                                    i_hend,
input                                    i_href,
input                                    clk,
input                                    rst_n
);

//----------------------------------------------//
// Local parameter                              //
//----------------------------------------------//
localparam   [4:0]              SHIFT_BIT = (12 +CIPW -COPW);
localparam   [COW:0]            MAX_NUM   = (2**COW);

localparam   [3:0]              QUE_NUM   = 4;
localparam   [3:0]              QUE_TOL   = (QUE_NUM)*3-1;

localparam                      Y_SFT_MSB = 13 + CIW-SHIFT_BIT;
localparam                      U_SFT_MSB = 14 + CIW-SHIFT_BIT;
localparam                      V_SFT_MSB = 14 + CIW-SHIFT_BIT;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
//-------------------------------------------------------------------------------------------- color space convert  
reg          [CIW-1:0]                   i_data_r_q0;
reg          [CIW-1:0]                   i_data_g_q0;
reg          [CIW-1:0]                   i_data_b_q0;

reg          [11 + CIW -1 :0]            r_x1225_part_1;
reg          [12 + CIW -1 :0]            g_x2404_part_1;
reg          [9  + CIW -1 :0]            b_x467_part_1;
wire         [11 + CIW -1 :0]            r_x1225_part_1_nxt;
wire         [12 + CIW -1 :0]            g_x2404_part_1_nxt;
wire         [9  + CIW -1 :0]            b_x467_part_1_nxt;
reg          [11 + CIW -1 :0]            r_x1225;
reg          [12 + CIW -1 :0]            g_x2404;
reg          [9  + CIW -1 :0]            b_x467;
wire         [11 + CIW -1 :0]            r_x1225_nxt;
wire         [12 + CIW -1 :0]            g_x2404_nxt;
wire         [9  + CIW -1 :0]            b_x467_nxt;
wire         [SHIFT_BIT-1:0]             y_x4096_rnd;
reg          [Y_SFT_MSB -1 : 0]          y_x4096_sft;
wire         [Y_SFT_MSB -1 : 0]          y_x4096_sft_nxt;
wire                                     y_x4096_bdy;

reg          [10 + CIW -1 :0]            r_x688_part_1;
reg          [11 + CIW -1 :0]            g_x1352_part_1;
reg          [11 + CIW -1 :0]            b_x2040_part_1;
wire         [10 + CIW -1 :0]            r_x688_part_1_nxt;
wire         [11 + CIW -1 :0]            g_x1352_part_1_nxt;
wire         [11 + CIW -1 :0]            b_x2040_part_1_nxt;
reg          [10 + CIW -1 :0]            r_x688;
reg          [11 + CIW -1 :0]            g_x1352;
reg          [11 + CIW -1 :0]            b_x2040;
wire         [10 + CIW -1 :0]            r_x688_nxt;
wire         [11 + CIW -1 :0]            g_x1352_nxt;
wire         [11 + CIW -1 :0]            b_x2040_nxt;
wire signed  [11 + CIW -1 :0]            r_x688_sgn;
wire signed  [12 + CIW -1 :0]            g_x1352_sgn;
wire signed  [12 + CIW -1 :0]            b_x2040_sgn;
wire signed  [SHIFT_BIT:0]               cb_x4096_rnd_sgn;
reg  signed  [U_SFT_MSB -1 : 0]          cb_x4096_sft_sgn;
wire signed  [U_SFT_MSB -1 : 0]          cb_x4096_sft_sgn_nxt;
wire                                     cb_x4096_bdy;

reg          [11 + CIW -1 :0]            r_x2040_part_1;
reg          [11 + CIW -1 :0]            g_x1708_part_1;
reg          [9  + CIW -1 :0]            b_x332_part_1;
wire         [11 + CIW -1 :0]            r_x2040_part_1_nxt;
wire         [11 + CIW -1 :0]            g_x1708_part_1_nxt;
wire         [9  + CIW -1 :0]            b_x332_part_1_nxt;
reg          [11 + CIW -1 :0]            r_x2040;
reg          [11 + CIW -1 :0]            g_x1708;
reg          [9  + CIW -1 :0]            b_x332;
wire         [11 + CIW -1 :0]            r_x2040_nxt;
wire         [11 + CIW -1 :0]            g_x1708_nxt;
wire         [9  + CIW -1 :0]            b_x332_nxt;
wire signed  [12 + CIW -1 :0]            r_x2040_sgn;
wire signed  [12 + CIW -1 :0]            g_x1708_sgn;
wire signed  [10 + CIW -1 :0]            b_x332_sgn;
wire signed  [SHIFT_BIT:0]               cr_x4096_rnd_sgn;
reg  signed  [V_SFT_MSB -1 : 0]          cr_x4096_sft_sgn;
wire signed  [V_SFT_MSB -1 : 0]          cr_x4096_sft_sgn_nxt;
wire                                     cr_x4096_bdy;

//-------------------------------------------------------------------------------------------- output
reg          [QUE_TOL:0]                 out_que;
wire         [QUE_TOL:0]                 out_que_nxt;

wire         [COW-1 :0]                  o_data_y_nxt;  
wire signed  [COW:0]                     data_cb_sgn_nxt;
wire signed  [COW:0]                     data_cr_sgn_nxt;
reg  signed  [COW:0]                     data_cb_sgn;   
reg  signed  [COW:0]                     data_cr_sgn;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//-------------------------------------------------------------------------------------------- color space convert  

// 12 bit precision 
// Y = 0.299072265625*R' + 0.5869140625*G' + 0.114013671875*B'
// Y = (1225/4096)*R + (2404/4096)*G + (467/4096)*B


assign  r_x1225_part_1_nxt    = (i_data_r <<10) + (i_data_r <<7)    + (i_data_r <<6);
assign  g_x2404_part_1_nxt    = (i_data_g <<11) + (i_data_g <<8)    + (i_data_g <<6);
assign  b_x467_part_1_nxt     = (i_data_b <<8)  + (i_data_b <<7)    + (i_data_b <<6);

assign  r_x1225_nxt           = r_x1225_part_1  + (i_data_r_q0 <<3) +  i_data_r_q0; 
assign  g_x2404_nxt           = g_x2404_part_1  + (i_data_g_q0 <<5) + (i_data_g_q0 <<2);
assign  b_x467_nxt            = b_x467_part_1   + (i_data_b_q0 <<4) + (i_data_b_q0 <<1) + i_data_b_q0; 

assign  y_x4096_rnd           = {1'b1,{(SHIFT_BIT -1){1'b0}}};
assign  y_x4096_sft_nxt       = (r_x1225 + g_x2404 + b_x467 + y_x4096_rnd) >> SHIFT_BIT; 
assign  y_x4096_bdy           = y_x4096_sft > {COW{1'b1}};                                            //boundary 
assign  o_data_y_nxt          = (y_x4096_bdy ? {COW{1'b1}} : y_x4096_sft[COW-1:0]);                   //0~255 //maybe overflow 

// Y = -0.16796875*R' + -0.330078125*G' + 0.498046875*B'
// Y = (-688/4096)*R + (-1352/4096)*G + (2040/4096)*B


assign  r_x688_part_1_nxt     = (i_data_r <<9)  + (i_data_r <<7);
assign  g_x1352_part_1_nxt    = (i_data_g <<10) + (i_data_g <<8);
assign  b_x2040_part_1_nxt    = (i_data_b <<11) ;

assign  r_x688_nxt            = r_x688_part_1   + (i_data_r_q0 <<5) + (i_data_r_q0 <<4);
assign  g_x1352_nxt           = g_x1352_part_1  + (i_data_g_q0 <<6) + (i_data_g_q0 <<3);
assign  b_x2040_nxt           = b_x2040_part_1  - (i_data_b_q0 <<3);

assign  r_x688_sgn            = $signed({1'b0,r_x688});
assign  g_x1352_sgn           = $signed({1'b0,g_x1352});
assign  b_x2040_sgn           = $signed({1'b0,b_x2040});
assign  cb_x4096_rnd_sgn      = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});

assign  cb_x4096_sft_sgn_nxt  = $signed(-r_x688_sgn - g_x1352_sgn + b_x2040_sgn + cb_x4096_rnd_sgn) >>> SHIFT_BIT;
assign  cb_x4096_bdy          = $signed({cb_x4096_sft_sgn[U_SFT_MSB-1],1'b1})* cb_x4096_sft_sgn > $signed({1'b0,{(COW-1){1'b1}}});         //boundary 
assign  data_cb_sgn_nxt       = (cb_x4096_bdy ? $signed({{2{cb_x4096_sft_sgn[U_SFT_MSB-1]}},{COW-1{!cb_x4096_sft_sgn[U_SFT_MSB-1]}}}) : cb_x4096_sft_sgn ) + 
                                $signed({1'b0,YCBCR_POS,{COIW-1{1'b0}},{COPW{1'b0}}});
assign  o_data_cb             = data_cb_sgn;                                                                                               //-128~127 or //0~255 
                                                                                                                                           //maybe overflow or underflow 

// Y = 0.498046875*R' + -0.4169921875*G' + -0.0810546875*B'
// Y = (2040/4096)*R + (-1708/4096)*G + (-332/4096)*B

assign  r_x2040_part_1_nxt    = (i_data_r <<11);
assign  g_x1708_part_1_nxt    = (i_data_g <<10) + (i_data_g <<9)    + (i_data_g <<7);
assign  b_x332_part_1_nxt     = (i_data_b <<8)  + (i_data_b <<6) ;

assign  r_x2040_nxt           = r_x2040_part_1  - (i_data_r_q0 <<3);
assign  g_x1708_nxt           = g_x1708_part_1  + (i_data_g_q0 <<5) + (i_data_g_q0 <<3) + (i_data_g_q0 <<2);
assign  b_x332_nxt            = b_x332_part_1   + (i_data_b_q0 <<3) + (i_data_b_q0 <<2);

assign  r_x2040_sgn           = $signed({1'b0,r_x2040});
assign  g_x1708_sgn           = $signed({1'b0,g_x1708});
assign  b_x332_sgn            = $signed({1'b0,b_x332});
assign  cr_x4096_rnd_sgn      = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});

assign  cr_x4096_sft_sgn_nxt  = $signed(r_x2040_sgn - g_x1708_sgn - b_x332_sgn + cr_x4096_rnd_sgn) >>> SHIFT_BIT;
assign  cr_x4096_bdy          = $signed({cr_x4096_sft_sgn[V_SFT_MSB-1],1'b1})* cr_x4096_sft_sgn > $signed({1'b0,{(COW-1){1'b1}}});         //boundary 
assign  data_cr_sgn_nxt       = (cr_x4096_bdy ? $signed({{2{cr_x4096_sft_sgn[V_SFT_MSB-1]}},{COW-1{!cr_x4096_sft_sgn[V_SFT_MSB-1]}}}) : cr_x4096_sft_sgn ) + 
                                $signed({1'b0,YCBCR_POS,{COIW-1{1'b0}},{COPW{1'b0}}});
assign  o_data_cr             = data_cr_sgn;                                                                                               //-128~127 or //0~255 
                                                                                                                                           //maybe overflow or underflow 

//-------------------------------------------------------------------------------------------- output
assign  out_que_nxt           = {out_que[QUE_TOL:0] , i_hstr,i_href,i_hend};
assign  o_hstr                = out_que[QUE_TOL];
assign  o_href                = out_que[QUE_TOL-1];
assign  o_hend                = out_que[QUE_TOL-2];

always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
//-------------------------------------------------------------------------------------------- color space convert 
        i_data_r_q0      <= 0;
        i_data_g_q0      <= 0;
        i_data_b_q0      <= 0;
        
        r_x1225_part_1   <= 0;
        g_x2404_part_1   <= 0;
        b_x467_part_1    <= 0;
        r_x1225          <= 0;
        g_x2404          <= 0;
        b_x467           <= 0;
        r_x688_part_1    <= 0;
        g_x1352_part_1   <= 0;
        b_x2040_part_1   <= 0;
        r_x688           <= 0;
        g_x1352          <= 0;
        b_x2040          <= 0;
        r_x2040_part_1   <= 0;
        g_x1708_part_1   <= 0;
        b_x332_part_1    <= 0;
        r_x2040          <= 0;
        g_x1708          <= 0;
        b_x332           <= 0;
        
        y_x4096_sft      <= 0;
        cb_x4096_sft_sgn <= 0;
        cr_x4096_sft_sgn <= 0;
        
//-------------------------------------------------------------------------------------------- output 
        out_que          <= 0;
        o_data_y         <= 0;
        data_cb_sgn      <= 0;
        data_cr_sgn      <= 0;
        
    end
    else begin
//-------------------------------------------------------------------------------------------- color space convert 
        i_data_r_q0      <= i_data_r ;
        i_data_g_q0      <= i_data_g ;
        i_data_b_q0      <= i_data_b ;
        
        r_x1225_part_1   <= r_x1225_part_1_nxt;
        g_x2404_part_1   <= g_x2404_part_1_nxt;
        b_x467_part_1    <= b_x467_part_1_nxt ;
        r_x1225          <= r_x1225_nxt;
        g_x2404          <= g_x2404_nxt;
        b_x467           <= b_x467_nxt ;
        r_x688_part_1    <= r_x688_part_1_nxt ;
        g_x1352_part_1   <= g_x1352_part_1_nxt;
        b_x2040_part_1   <= b_x2040_part_1_nxt;
        r_x688           <= r_x688_nxt ;
        g_x1352          <= g_x1352_nxt;
        b_x2040          <= b_x2040_nxt;
        r_x2040_part_1   <= r_x2040_part_1_nxt;
        g_x1708_part_1   <= g_x1708_part_1_nxt;
        b_x332_part_1    <= b_x332_part_1_nxt ;
        r_x2040          <= r_x2040_nxt;
        g_x1708          <= g_x1708_nxt;
        b_x332           <= b_x332_nxt ;

        y_x4096_sft      <= y_x4096_sft_nxt;
        cb_x4096_sft_sgn <= cb_x4096_sft_sgn_nxt;
        cr_x4096_sft_sgn <= cr_x4096_sft_sgn_nxt;
        
//-------------------------------------------------------------------------------------------- output
        out_que          <= out_que_nxt;
        o_data_y         <= o_data_y_nxt;
        data_cb_sgn      <= data_cb_sgn_nxt;
        data_cr_sgn      <= data_cr_sgn_nxt;
        
    end
end




endmodule

