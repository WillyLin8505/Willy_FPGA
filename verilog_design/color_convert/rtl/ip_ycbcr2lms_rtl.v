// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_ycbcr2lms.v
// Author:              1.Willy Lin
//                      2.Martin Chen 
//                      3.Humphrey Lin
// Version:             1.0
// Last Modified On:    2022/10/25
//
// File Description:    ycbcr convert to lms
// Abbreviations:
// Parameters:          PRECISION:      S 1.12
// Data precision :     input  : Y    :   8.4
//                               CBCR : S 7.4 or 8.4
//                      outupt :          8.4
// Consuming time :     4T  
// -FHDR -----------------------------------------------------------------------

module ip_ycbcr2lms 
    #(
    parameter CIIW      = 8,            //Accuracy Input Integer Width  //Accuracy can be reduced , but not improved //sign bit are include
    parameter CIPW      = 4,            //Accuracy Input Point Width    //Accuracy can be reduced , but not improved 
    parameter COIW      = 8,            //Accuracy Output Integer Width //Accuracy can be reduced , but not improved //sign bit are include
    parameter COPW      = 4,            //Accuracy Output Point Width   //Accuracy can be reduced , but not improved 
    parameter CIW       = CIIW + CIPW,
    parameter COW       = COIW + COPW,
    parameter YCBCR_POS = 0
    )
(

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg      [COW-1:0] o_data_l,            // outputR
output reg      [COW-1:0] o_data_m,            // outputG
output reg      [COW-1:0] o_data_s,            // outputB
output                    o_hstr,
output                    o_hend,
output                    o_href,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input           [CIW-1:0] i_data_y,
input signed    [CIW  :0] i_data_cb_sgn,
input signed    [CIW  :0] i_data_cr_sgn,
input                     i_hstr,
input                     i_hend,
input                     i_href,
input                     clk,
input                     rst_n
);

//----------------------------------------------//
// Local parameter                              //
//----------------------------------------------//
localparam [4:0]               SHIFT_BIT = (12 +CIPW -COPW);
localparam [COW:0]             MAX_NUM   = (2**COW);

localparam [3:0]               QUE_NUM   = 4;
localparam [3:0]               QUE_TOL   = (QUE_NUM)*3-1;

localparam                     L_SFT_MSB = 15 + CIW-SHIFT_BIT;
localparam                     M_SFT_MSB = 15 + CIW-SHIFT_BIT;
localparam                     S_SFT_MSB = 15 + CIW-SHIFT_BIT;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
//-------------------------------------------------------------------------------------------- input 
reg          [CIW-1:0]                   i_data_y_q0;
wire signed  [CIW-1:0]                   i_data_cb_norm_sgn;
wire signed  [CIW-1:0]                   i_data_cr_norm_sgn;
reg  signed  [CIW-1:0]                   i_data_cb_norm_sgn_q0;
reg  signed  [CIW-1:0]                   i_data_cr_norm_sgn_q0;

//-------------------------------------------------------------------------------------------- color space convert  
reg          [13 + CIW -1 :0]            y_x4096;
wire         [13 + CIW -1 :0]            y_x4096_nxt;
wire signed  [14 + CIW -1 :0]            y_x4096_sgn;

reg  signed  [10 + CIW -1 :0]            cb_x384_part_1_sgn;
reg  signed  [11 + CIW -1 :0]            cr_x802_part_1_sgn;
wire signed  [10 + CIW -1 :0]            cb_x384_part_1_sgn_nxt;
wire signed  [11 + CIW -1 :0]            cr_x802_part_1_sgn_nxt;
reg  signed  [10 + CIW -1 :0]            cb_x384_sgn;
reg  signed  [11 + CIW -1 :0]            cr_x802_sgn;
wire signed  [10 + CIW -1 :0]            cb_x384_sgn_nxt;
wire signed  [11 + CIW -1 :0]            cr_x802_sgn_nxt;
wire signed  [SHIFT_BIT:0]               l_x4096_rnd_sgn;
reg  signed  [L_SFT_MSB : 0]             l_x4096_sft_sgn;
wire signed  [L_SFT_MSB : 0]             l_x4096_sft_sgn_nxt;
wire                                     l_x4096_bdy;

reg  signed  [9 + CIW -1 :0]             cb_x181_part_1_sgn;
reg  signed  [11  + CIW -1 :0]           cr_x777_part_1_sgn;
wire signed  [9  + CIW -1 :0]            cb_x181_part_1_sgn_nxt;
wire signed  [11 + CIW -1 :0]            cr_x777_part_1_sgn_nxt;
reg  signed  [9 + CIW -1 :0]             cb_x181_sgn;
reg  signed  [11  + CIW -1 :0]           cr_x777_sgn;
wire signed  [9 + CIW -1 :0]             cb_x181_sgn_nxt;
wire signed  [11  + CIW -1 :0]           cr_x777_sgn_nxt;
wire signed  [SHIFT_BIT:0]               m_x4096_rnd_sgn;
reg  signed  [M_SFT_MSB -1 : 0]          m_x4096_sft_sgn;
wire signed  [M_SFT_MSB -1 : 0]          m_x4096_sft_sgn_nxt;
wire                                     m_x4096_bdy;

reg  signed  [13 + CIW -1 :0]            cb_x4192_part_1_sgn;
reg  signed  [10 + CIW -1 :0]            cr_x318_part_1_sgn;
wire signed  [13 + CIW -1 :0]            cb_x4192_part_1_sgn_nxt;
wire signed  [10 + CIW -1 :0]            cr_x318_part_1_sgn_nxt;
reg  signed  [13 + CIW -1 :0]            cb_x4192_sgn;
reg  signed  [10 + CIW -1 :0]            cr_x318_sgn;
wire signed  [13 + CIW -1 :0]            cb_x4192_sgn_nxt;
wire signed  [10 + CIW -1 :0]            cr_x318_sgn_nxt;
wire signed  [SHIFT_BIT:0]               s_x4096_rnd_sgn;
reg  signed  [S_SFT_MSB -1 : 0]          s_x4096_sft_sgn;
wire signed  [S_SFT_MSB -1 : 0]          s_x4096_sft_sgn_nxt;
wire                                     s_x4096_bdy;

//-------------------------------------------------------------------------------------------- output
reg          [QUE_TOL:0]                 out_que;
wire         [QUE_TOL:0]                 out_que_nxt;

wire         [COW-1:0]                   o_data_l_nxt;                
wire         [COW-1:0]                   o_data_m_nxt;                     
wire         [COW-1:0]                   o_data_s_nxt;   

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

//-------------------------------------------------------------------------------------------- input 
assign  i_data_cb_norm_sgn     = i_data_cb_sgn - {YCBCR_POS,{CIIW-1{1'b0}},{CIPW{1'b0}}}; //normalize
assign  i_data_cr_norm_sgn     = i_data_cr_sgn - {YCBCR_POS,{CIIW-1{1'b0}},{CIPW{1'b0}}}; //normalize

//-------------------------------------------------------------------------------------------- color space convert  
// 12 bit precision
// L = 1*Y+ -0.09375*Cb + 0.19580078125*Cr
// L = (4096/4096)*Y+ (-384/4096)*Cb + (802/4096)*Cr

assign  y_x4096_nxt             = (i_data_y_q0 <<12) ;

assign  cb_x384_part_1_sgn_nxt  = (i_data_cb_norm_sgn <<8); 
assign  cr_x802_part_1_sgn_nxt  = (i_data_cr_norm_sgn <<9) + (i_data_cr_norm_sgn <<8);

assign  cb_x384_sgn_nxt         = cb_x384_part_1_sgn       + (i_data_cb_norm_sgn_q0 <<7); 
assign  cr_x802_sgn_nxt         = cr_x802_part_1_sgn       + (i_data_cr_norm_sgn_q0 <<5) + (i_data_cr_norm_sgn_q0 <<1);

assign  y_x4096_sgn             = $signed({1'b0,y_x4096});
assign  l_x4096_rnd_sgn         = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});
assign  l_x4096_sft_sgn_nxt     = $signed(y_x4096_sgn - cb_x384_sgn + cr_x802_sgn + l_x4096_rnd_sgn) >>> SHIFT_BIT;
assign  l_x4096_bdy             = l_x4096_sft_sgn > $unsigned({COW{!l_x4096_sft_sgn[L_SFT_MSB-1]}});                   //boundary 
assign  o_data_l_nxt            = (l_x4096_bdy ? {COW{!l_x4096_sft_sgn[L_SFT_MSB-1]}} : $unsigned(l_x4096_sft_sgn));   //0~255 //maybe overflow or underflow 

// M = 1*Y+ -0.044189453125*Cb + -0.189697265625*Cr
// M = (4096/4096)*Y+ (-181/4096)*Cb + (-777/4096)*Cr

assign  cb_x181_part_1_sgn_nxt  = (i_data_cb_norm_sgn <<7) + (i_data_cb_norm_sgn <<5);
assign  cr_x777_part_1_sgn_nxt  = (i_data_cr_norm_sgn <<9) + (i_data_cr_norm_sgn <<8);

assign  cb_x181_sgn_nxt         = cb_x181_part_1_sgn       + (i_data_cb_norm_sgn_q0 <<4) + (i_data_cb_norm_sgn_q0 <<2) + i_data_cb_norm_sgn_q0;
assign  cr_x777_sgn_nxt         = cr_x777_part_1_sgn       + (i_data_cr_norm_sgn_q0 <<3) + i_data_cr_norm_sgn_q0;

assign  m_x4096_rnd_sgn         = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});
assign  m_x4096_sft_sgn_nxt     = $signed(y_x4096_sgn - cb_x181_sgn - cr_x777_sgn + m_x4096_rnd_sgn) >>> SHIFT_BIT;
assign  m_x4096_bdy             = m_x4096_sft_sgn > $unsigned({COW{!m_x4096_sft_sgn[M_SFT_MSB-1]}});                   //boundary 
assign  o_data_m_nxt            = (m_x4096_bdy ? {COW{!m_x4096_sft_sgn[M_SFT_MSB-1]}} : $unsigned(m_x4096_sft_sgn));         //0~255 //maybe overflow or underflow 

// S = 1*Y+ 1.0234375*Cb + -0.07763671875*Cr
// S = (4096/4096)*Y+ (4192/4096)*Cb + (-318/4096)*Cr

assign  cb_x4192_part_1_sgn_nxt = (i_data_cb_norm_sgn <<12);
assign  cr_x318_part_1_sgn_nxt  = (i_data_cr_norm_sgn <<8) ;

assign  cb_x4192_sgn_nxt        = cb_x4192_part_1_sgn     + (i_data_cb_norm_sgn_q0 <<6) + (i_data_cb_norm_sgn_q0 <<5);
assign  cr_x318_sgn_nxt         = cr_x318_part_1_sgn      + (i_data_cr_norm_sgn_q0 <<6) - (i_data_cr_norm_sgn_q0 <<1);

assign  s_x4096_rnd_sgn         = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});
assign  s_x4096_sft_sgn_nxt     = $signed(y_x4096_sgn + cb_x4192_sgn - cr_x318_sgn + s_x4096_rnd_sgn) >>> SHIFT_BIT;
assign  s_x4096_bdy             = s_x4096_sft_sgn > $unsigned({COW{!s_x4096_sft_sgn[S_SFT_MSB-1]}});                   //boundary 
assign  o_data_s_nxt            = (s_x4096_bdy ? {COW{!s_x4096_sft_sgn[S_SFT_MSB-1]}} : $unsigned(s_x4096_sft_sgn));         //0~255 //maybe overflow or underflow 

//-------------------------------------------------------------------------------------------- output
assign  out_que_nxt             = {out_que[QUE_TOL:0] , i_hstr,i_href,i_hend}; 
assign  o_hstr                  = out_que[QUE_TOL];
assign  o_href                  = out_que[QUE_TOL-1];
assign  o_hend                  = out_que[QUE_TOL-2];

always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
//-------------------------------------------------------------------------------------------- color space convert 
        i_data_y_q0           <= 0;
        i_data_cb_norm_sgn_q0 <= 0;
        i_data_cr_norm_sgn_q0 <= 0;
        cb_x384_part_1_sgn    <= 0;
        cr_x802_part_1_sgn    <= 0;
        cb_x181_part_1_sgn    <= 0;
        cr_x777_part_1_sgn    <= 0;
        cb_x4192_part_1_sgn   <= 0;
        cr_x318_part_1_sgn    <= 0;
        
        y_x4096               <= 0;
        cb_x384_sgn           <= 0;
        cr_x802_sgn           <= 0;
        cb_x181_sgn           <= 0;
        cr_x777_sgn           <= 0;
        cb_x4192_sgn          <= 0;
        cr_x318_sgn           <= 0;

        l_x4096_sft_sgn       <= 0;
        m_x4096_sft_sgn       <= 0;
        s_x4096_sft_sgn       <= 0;
        
//-------------------------------------------------------------------------------------------- output
        out_que               <= 0;
        o_data_l              <= 0;                
        o_data_m              <= 0;                     
        o_data_s              <= 0; 
        
    end
    else begin
//-------------------------------------------------------------------------------------------- color space convert 
        i_data_y_q0           <= i_data_y;
        i_data_cb_norm_sgn_q0 <= i_data_cb_norm_sgn;
        i_data_cr_norm_sgn_q0 <= i_data_cr_norm_sgn;
        cb_x384_part_1_sgn    <= cb_x384_part_1_sgn_nxt;
        cr_x802_part_1_sgn    <= cr_x802_part_1_sgn_nxt;
        cb_x181_part_1_sgn    <= cb_x181_part_1_sgn_nxt;
        cr_x777_part_1_sgn    <= cr_x777_part_1_sgn_nxt;
        cb_x4192_part_1_sgn   <= cb_x4192_part_1_sgn_nxt;
        cr_x318_part_1_sgn    <= cr_x318_part_1_sgn_nxt;

        y_x4096               <= y_x4096_nxt    ;
        cb_x384_sgn           <= cb_x384_sgn_nxt;
        cr_x802_sgn           <= cr_x802_sgn_nxt;
        cb_x181_sgn           <= cb_x181_sgn_nxt;
        cr_x777_sgn           <= cr_x777_sgn_nxt;
        cb_x4192_sgn          <= cb_x4192_sgn_nxt;
        cr_x318_sgn           <= cr_x318_sgn_nxt;

        l_x4096_sft_sgn       <= l_x4096_sft_sgn_nxt;
        m_x4096_sft_sgn       <= m_x4096_sft_sgn_nxt;
        s_x4096_sft_sgn       <= s_x4096_sft_sgn_nxt;
        
//-------------------------------------------------------------------------------------------- output
        out_que               <= out_que_nxt;
        o_data_l              <= o_data_l_nxt;                
        o_data_m              <= o_data_m_nxt;                     
        o_data_s              <= o_data_s_nxt; 
        
    end
end




endmodule

