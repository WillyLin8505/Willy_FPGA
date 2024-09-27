// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_lms2rgb_ycbcr_rsft
// Author:              1.Willy Lin
//                      2.Martin Chen 
//                      3.Humphrey Lin
// Version:             1.0
// Last Modified On:    2022/10/28
//
// File Description:    LMS to RGB or YCBCR Converter
//                      use register to select rgb or ycbcr output 
// Abbreviations:
// Parameters:          RGB : 
//                        PRECISION: S 3.11
//                      YCBCR :
//                        PRECISION: S 2.10                        
// Data precision :     RGB : 
//                        input  :     8.6
//                        outupt :     8.0
//                      YCBCR : 
//                        input  :     8.6
//                        outupt : Y : 8.4
//                                 Cb: S 7.4 or 8.4
//                                 Cr: S 7.4 or 8.4
// Consuming time :     4T  
// -FHDR -----------------------------------------------------------------------

module ip_lms2rgb_ycbcr_rsft 
   #(
    parameter CIIW      = 8,               //Accuracy Input Integer Width     //Accuracy can be reduced , but not improved 
    parameter CIPW      = 6,               //Accuracy Input Point Width       //Accuracy can be reduced , but not improved 
    parameter COIW_YUV  = 8,               //Accuracy Output Integer Width    //Accuracy can be reduced , but not improved 
    parameter COPW_YUV  = 4,               //Accuracy Output Point Width      //Accuracy can be reduced , but not improved 
    parameter COW_YUV   = COIW_YUV + COPW_YUV,
    parameter COIW_RGB  = 8,               //Accuracy Output Integer Width    //Accuracy can be reduced , but not improved 
    parameter COPW_RGB  = 0,               //Accuracy Output Point Width      //Accuracy can be reduced , but not improved 
    parameter COW_RGB   = COIW_RGB + COPW_RGB,
    parameter YCBCR_POS = 1,
    parameter CIW       = CIIW + CIPW,
    parameter COW       = (COW_YUV > COW_RGB) ? COW_YUV : COW_RGB 
    )
(
    
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg [COW-1:0]         o_data_ch1,
output reg [COW  :0]         o_data_ch2,
output reg [COW  :0]         o_data_ch3,
output                       o_hstr,
output                       o_hend,
output                       o_href,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input      [CIW-1:0]         i_data_l,
input      [CIW-1:0]         i_data_m,
input      [CIW-1:0]         i_data_s,
input                        i_hstr,
input                        i_hend,
input                        i_href,
input                        r_conv_sel, //0:ycbcr , 1:rgb
input                        clk,
input                        rst_n
);

//----------------------------------------------//
// Local parameter                              //
//----------------------------------------------//
localparam [4:0]            SHIFT_BIT_RGB   = (11 +CIPW -COPW_RGB); 
localparam [4:0]            SHIFT_BIT_YCBCR = (10 +CIPW -COPW_YUV);  

localparam [3:0]            QUE_NUM         = 4;
localparam [3:0]            QUE_TOL         = (QUE_NUM)*3-1;

localparam                  R_SFT_MSB       = 16 + CIW-SHIFT_BIT_RGB;
localparam                  G_SFT_MSB       = 15 + CIW-SHIFT_BIT_RGB;
localparam                  B_SFT_MSB       = 14 + CIW-SHIFT_BIT_RGB;

localparam                  Y_SFT_MSB       = 11 + CIW-SHIFT_BIT_YCBCR;          
localparam                  U_SFT_MSB       = 13 + CIW-SHIFT_BIT_YCBCR;
localparam                  V_SFT_MSB       = 15 + CIW-SHIFT_BIT_YCBCR;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
//-------------------------------------------------------------------------------------------- input
reg          [CIW-1:0]                   i_data_l_q0;
reg          [CIW-1:0]                   i_data_m_q0;
reg          [CIW-1:0]                   i_data_s_q0;


//-------------------------------------------------------------------------------------------- color convert rgb 
reg          [14 + CIW -1 : 0]           l_x8349_part_1;
reg          [13 + CIW -1 : 0]           m_x6774_part_1;
reg          [9  + CIW -1 : 0]           s_x473_part_1;
wire         [14 + CIW -1 : 0]           l_x8349_part_1_nxt;
wire         [13 + CIW -1 : 0]           m_x6774_part_1_nxt;
wire         [9  + CIW -1 : 0]           s_x473_part_1_nxt;
reg          [14 + CIW -1 : 0]           l_x8349;
reg          [13 + CIW -1 : 0]           m_x6774;
reg          [9  + CIW -1 : 0]           s_x473;
wire         [14 + CIW -1 : 0]           l_x8349_nxt;
wire         [13 + CIW -1 : 0]           m_x6774_nxt;
wire         [9  + CIW -1 : 0]           s_x473_nxt;
wire signed  [15 + CIW -1 : 0]           l_x8349_sgn;
wire signed  [14 + CIW -1 : 0]           m_x6774_sgn;
wire signed  [10 + CIW -1 : 0]           s_x473_sgn;
wire signed  [SHIFT_BIT_RGB:0]           r_x2048_rnd_sgn;
reg  signed  [R_SFT_MSB -1 : 0]          r_x2048_sft_sgn;
wire signed  [R_SFT_MSB -1 : 0]          r_x2048_sft_sgn_nxt;
wire         [COW_RGB-1:0]               data_r;

reg          [12 + CIW -1 : 0]           l_x2598_part_1;
reg          [13 + CIW -1 : 0]           m_x5345_part_1;
reg          [10 + CIW -1 : 0]           s_x699_part_1;
wire         [12 + CIW -1 : 0]           l_x2598_part_1_nxt;
wire         [13 + CIW -1 : 0]           m_x5345_part_1_nxt;
wire         [10 + CIW -1 : 0]           s_x699_part_1_nxt;
reg          [12 + CIW -1 : 0]           l_x2598;
reg          [13 + CIW -1 : 0]           m_x5345;
reg          [10 + CIW -1 : 0]           s_x699;
wire         [12 + CIW -1 : 0]           l_x2598_nxt;
wire         [13 + CIW -1 : 0]           m_x5345_nxt;
wire         [10 + CIW -1 : 0]           s_x699_nxt;
wire signed  [13 + CIW -1 : 0]           l_x2598_sgn;
wire signed  [14 + CIW -1 : 0]           m_x5345_sgn;
wire signed  [11 + CIW -1 : 0]           s_x699_sgn;
wire signed  [SHIFT_BIT_RGB:0]           g_x2048_rnd_sgn;
reg  signed  [G_SFT_MSB -1 : 0]          g_x2048_sft_sgn;
wire signed  [G_SFT_MSB -1 : 0]          g_x2048_sft_sgn_nxt;
wire         [COW_RGB-1:0]               data_g;

reg          [4  + CIW -1 : 0]           l_x9_part_1;
reg          [11 + CIW -1 : 0]           m_x1441_part_1;
reg          [12 + CIW -1 : 0]           s_x3497_part_1;
wire         [4  + CIW -1 : 0]           l_x9_part_1_nxt;
wire         [11 + CIW -1 : 0]           m_x1441_part_1_nxt;
wire         [12 + CIW -1 : 0]           s_x3497_part_1_nxt;
reg          [4  + CIW -1 : 0]           l_x9;
reg          [11 + CIW -1 : 0]           m_x1441;
reg          [12 + CIW -1 : 0]           s_x3497;
wire         [4  + CIW -1 : 0]           l_x9_nxt;
wire         [11 + CIW -1 : 0]           m_x1441_nxt;
wire         [12 + CIW -1 : 0]           s_x3497_nxt;
wire signed  [5  + CIW -1 : 0]           l_x9_sgn;
wire signed  [12 + CIW -1 : 0]           m_x1441_sgn;
wire signed  [13 + CIW -1 : 0]           s_x3497_sgn;
wire signed  [SHIFT_BIT_RGB:0]           b_x2048_rnd_sgn;
reg  signed  [B_SFT_MSB -1 : 0]          b_x2048_sft_sgn;
wire signed  [B_SFT_MSB -1 : 0]          b_x2048_sft_sgn_nxt;
wire         [COW_RGB-1:0]               data_b;

//-------------------------------------------------------------------------------------------- color convert ycbcr
reg          [9  + CIW -1 : 0]           l_x485_part_1;
reg          [9  + CIW -1 : 0]           m_x474_part_1;
reg          [7  + CIW -1 : 0]           s_x65_part_1;
wire         [9  + CIW -1 : 0]           l_x485_part_1_nxt;
wire         [9  + CIW -1 : 0]           m_x474_part_1_nxt;
wire         [7  + CIW -1 : 0]           s_x65_part_1_nxt;
reg          [9  + CIW -1 : 0]           l_x485;
reg          [9  + CIW -1 : 0]           m_x474;
reg          [7  + CIW -1 : 0]           s_x65;
wire         [9  + CIW -1 : 0]           l_x485_nxt;
wire         [9  + CIW -1 : 0]           m_x474_nxt;
wire         [7  + CIW -1 : 0]           s_x65_nxt;
wire         [SHIFT_BIT_YCBCR: 0]        y_x1024_rnd;
wire         [11 + CIW  -1 : 0]          y_x1024_sum;
reg          [Y_SFT_MSB -1 : 0]          y_x1024_sft;
wire         [Y_SFT_MSB -1 : 0]          y_x1024_sft_nxt;
wire                                     y_x1024_bdy;
wire         [COW_YUV -1 : 0]            data_y;

reg          [9  + CIW -1 : 0]           l_275_part_1;
reg          [10 + CIW -1 : 0]           m_x671_part_1;
reg          [10 + CIW -1 : 0]           s_x946_part_1;
wire         [9  + CIW -1 : 0]           l_275_part_1_nxt;
wire         [10 + CIW -1 : 0]           m_x671_part_1_nxt;
wire         [10 + CIW -1 : 0]           s_x946_part_1_nxt;
reg          [9  + CIW -1 : 0]           l_275;
reg          [10 + CIW -1 : 0]           m_x671;
reg          [10 + CIW -1 : 0]           s_x946;
wire         [9  + CIW -1 : 0]           l_275_nxt;
wire         [10 + CIW -1 : 0]           m_x671_nxt;
wire         [10 + CIW -1 : 0]           s_x946_nxt;
wire signed  [10 + CIW -1 : 0]           l_275_sgn;
wire signed  [11 + CIW -1 : 0]           m_x671_sgn;
wire signed  [11 + CIW -1 : 0]           s_x946_sgn;
wire signed  [SHIFT_BIT_YCBCR: 0]        cb_x1024_rnd_sgn;
reg  signed  [U_SFT_MSB -1 : 0]          cb_x1024_sft_sgn;
wire signed  [U_SFT_MSB -1 : 0]          cb_x1024_sft_sgn_nxt;
wire                                     cb_x1024_bdy;
wire signed  [COW_YUV  : 0]              data_cb_sgn;

reg          [12 + CIW -1 : 0]           l_x2621_part_1;
reg          [12 + CIW -1 : 0]           m_x2743_part_1;
reg          [8  + CIW -1 : 0]           s_x122_part_1;
wire         [12 + CIW -1 : 0]           l_x2621_part_1_nxt;
wire         [12 + CIW -1 : 0]           m_x2743_part_1_nxt;
wire         [8  + CIW -1 : 0]           s_x122_part_1_nxt;
reg          [12 + CIW -1 : 0]           l_x2621;
reg          [12 + CIW -1 : 0]           m_x2743;
reg          [8  + CIW -1 : 0]           s_x122;
wire         [12 + CIW -1 : 0]           l_x2621_nxt;
wire         [12 + CIW -1 : 0]           m_x2743_nxt;
wire         [8  + CIW -1 : 0]           s_x122_nxt;
wire signed  [13 + CIW -1 : 0]           l_x2621_sgn;
wire signed  [13 + CIW -1 : 0]           m_x2743_sgn;
wire signed  [9  + CIW -1 : 0]           s_x122_sgn;
wire signed  [SHIFT_BIT_YCBCR : 0]       cr_x1024_rnd_sgn;
reg  signed  [V_SFT_MSB -1 : 0]          cr_x1024_sft_sgn;
wire signed  [V_SFT_MSB -1 : 0]          cr_x1024_sft_sgn_nxt;
wire                                     cr_x1024_bdy;
wire signed  [COW_YUV  : 0]              data_cr_sgn;

//-------------------------------------------------------------------------------------------- output
reg          [QUE_TOL:0]                 out_que;
wire         [QUE_TOL:0]                 out_que_nxt;

wire         [COW-1:0]                   o_data_ch1_nxt;
wire         [COW  :0]                   o_data_ch2_nxt;
wire         [COW  :0]                   o_data_ch3_nxt;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

//-------------------------------------------------------------------------------------------- color convert
//In order to reduce the gate count, it must be divided into two parts 

// 11 bit precision 
// R = 4.07666015625*L+ -3.3076171875*M + 0.23095703125*S
// R = (8349/2048)*L+ (-6774/2048)*M + (473/2048)*S

//add stage 1 
assign  l_x8349_part_1_nxt    = (i_data_l << 13)+ (i_data_l << 7)    + (i_data_l << 5);  
assign  m_x6774_part_1_nxt    = (i_data_m << 13)- (i_data_m << 10)   - (i_data_m << 8);
assign  s_x473_part_1_nxt     = (i_data_s << 9) - (i_data_s << 5);

assign  l_x8349_nxt           = l_x8349_part_1  - (i_data_l_q0 << 1) - (i_data_l_q0 << 0);
assign  m_x6774_nxt           = m_x6774_part_1  - (i_data_m_q0 << 7) - (i_data_m_q0 << 3) - (i_data_m_q0 << 1);
assign  s_x473_nxt            = s_x473_part_1   - (i_data_s_q0 << 2) - (i_data_s_q0 << 1) - (i_data_s_q0 << 0);

assign  l_x8349_sgn           = $signed({1'b0,l_x8349});
assign  m_x6774_sgn           = $signed({1'b0,m_x6774});
assign  s_x473_sgn            = $signed({1'b0,s_x473});
assign  r_x2048_rnd_sgn       = $signed({1'b0,1'b1,{(SHIFT_BIT_RGB -1){1'b0}}});

assign  r_x2048_sft_sgn_nxt   = $signed(l_x8349_sgn - m_x6774_sgn + s_x473_sgn + r_x2048_rnd_sgn) >>> SHIFT_BIT_RGB;
assign  r_x2048_bdy           = r_x2048_sft_sgn > $unsigned({COW{!r_x2048_sft_sgn[R_SFT_MSB-1]}});                 //boundary 
assign  data_r                = r_x2048_bdy ? {COW{!r_x2048_sft_sgn[R_SFT_MSB-1]}} : $unsigned(r_x2048_sft_sgn);   //0~255  //maybe overflow or underflow 

// G = -1.2685546875*L+ 2.60986328125*M + -0.34130859375*S
// G = (-2598/2048)*L+ (5345/2048)*M + (-699/2048)*S

assign  l_x2598_part_1_nxt    = (i_data_l << 11)+ (i_data_l << 9)    + (i_data_l << 5);
assign  m_x5345_part_1_nxt    = (i_data_m << 12)+ (i_data_m << 10)   + (i_data_m << 7);
assign  s_x699_part_1_nxt     = (i_data_s << 9) + (i_data_s << 7);

assign  l_x2598_nxt           = l_x2598_part_1  + (i_data_l_q0 << 2) + (i_data_l_q0 << 1);
assign  m_x5345_nxt           = m_x5345_part_1  + (i_data_m_q0 << 6) + (i_data_m_q0 << 5) + (i_data_m_q0 << 0);
assign  s_x699_nxt            = s_x699_part_1   + (i_data_s_q0 << 6) - (i_data_s_q0 << 2) - (i_data_s_q0 << 0);

assign  l_x2598_sgn           = $signed({1'b0,l_x2598});
assign  m_x5345_sgn           = $signed({1'b0,m_x5345});
assign  s_x699_sgn            = $signed({1'b0,s_x699});
assign  g_x2048_rnd_sgn       = $signed({1'b0,1'b1,{(SHIFT_BIT_RGB -1){1'b0}}});

assign  g_x2048_sft_sgn_nxt   = $signed(-l_x2598_sgn + m_x5345_sgn - s_x699_sgn + g_x2048_rnd_sgn) >>> SHIFT_BIT_RGB;
assign  g_x2048_bdy           = g_x2048_sft_sgn > $unsigned({COW{!g_x2048_sft_sgn[G_SFT_MSB-1]}});                 //boundary 
assign  data_g                = g_x2048_bdy ? {COW{!g_x2048_sft_sgn[G_SFT_MSB-1]}} : $unsigned(g_x2048_sft_sgn);   //0~255  //maybe overflow or underflow 


// B = -0.00439453125*L+ -0.70361328125*M + 1.70751953125*S
// B = (-9/2048)*L+ (-1441/2048)*M + (3497/2048)*S

assign  l_x9_part_1_nxt       = (i_data_l << 3)  + (i_data_l << 0);
assign  m_x1441_part_1_nxt    = (i_data_m << 10) + (i_data_m << 8)    + (i_data_m << 7);
assign  s_x3497_part_1_nxt    = (i_data_s << 12) - (i_data_s << 9)    - (i_data_s << 6);

assign  l_x9_nxt              = l_x9_part_1;
assign  m_x1441_nxt           = m_x1441_part_1   + (i_data_m_q0 << 5) + (i_data_m_q0 << 0);
assign  s_x3497_nxt           = s_x3497_part_1   - (i_data_s_q0 << 4) - (i_data_s_q0 << 3) + (i_data_s_q0 << 0);

assign  l_x9_sgn              = $signed({1'b0,l_x9});
assign  m_x1441_sgn           = $signed({1'b0,m_x1441});
assign  s_x3497_sgn           = $signed({1'b0,s_x3497});
assign  b_x2048_rnd_sgn       = $signed({1'b0,1'b1,{(SHIFT_BIT_RGB -1){1'b0}}});

assign  b_x2048_sft_sgn_nxt   = $signed(-l_x9_sgn - m_x1441_sgn + s_x3497_sgn + b_x2048_rnd_sgn) >>> SHIFT_BIT_RGB;
assign  b_x2048_bdy           = b_x2048_sft_sgn > $unsigned({COW{!b_x2048_sft_sgn[B_SFT_MSB-1]}});                 //boundary 
assign  data_b                = b_x2048_bdy ? {COW{!b_x2048_sft_sgn[B_SFT_MSB-1]}} : $unsigned(b_x2048_sft_sgn);   //0~255  //maybe overflow or underflow 

// 10 bit precision 
// Y = 0.4736328125*L+ 0.462890625*M + 0.0634765625*S
// Y = (485/1024)*L+ (474/1024)*M + (65/1024)*S

//add stage 1 
assign  l_x485_part_1_nxt     = (i_data_l << 8)  + (i_data_l << 7)    + (i_data_l << 6);  
assign  m_x474_part_1_nxt     = (i_data_m << 8)  + (i_data_m << 7)    + (i_data_m << 6);
assign  s_x65_part_1_nxt      = (i_data_s << 6)  + i_data_s;

assign  l_x485_nxt            = l_x485_part_1    + (i_data_l_q0 << 5) + (i_data_l_q0 << 2) + i_data_l_q0;
assign  m_x474_nxt            = m_x474_part_1    + (i_data_m_q0 << 4) + (i_data_m_q0 << 3) + (i_data_m_q0 << 1);
assign  s_x65_nxt             = s_x65_part_1;

assign  y_x1024_rnd           = {1'b1,{(SHIFT_BIT_YCBCR -1){1'b0}}};
assign  y_x1024_sum           = (l_x485 + m_x474 + s_x65 + y_x1024_rnd);
assign  y_x1024_sft_nxt       = y_x1024_sum >> SHIFT_BIT_YCBCR;
assign  y_x1024_bdy           = y_x1024_sft > {COW{1'b1}};                                                         //boundary 
assign  data_y                = (y_x1024_bdy ? {COW_YUV{1'b1}} : y_x1024_sft[COW_YUV-1:0]);                        //0~255 //maybe overflow

// Cb = -0.2685546875*L+ -0.6552734375*M + 0.923828125*S
// Cb = (-275/1024)*L+ (-671/1024)*M + (946/1024)*S

//add stage 1 
assign  l_275_part_1_nxt      = (i_data_l << 8)  + (i_data_l << 4);  
assign  m_x671_part_1_nxt     = (i_data_m << 9)  + (i_data_m << 7);
assign  s_x946_part_1_nxt     = (i_data_s << 9)  + (i_data_s << 8)    + (i_data_s << 7);

assign  l_275_nxt             = l_275_part_1     + (i_data_l_q0 << 1) + i_data_l_q0;
assign  m_x671_nxt            = m_x671_part_1    + (i_data_m_q0 << 5) - i_data_m_q0;
assign  s_x946_nxt            = s_x946_part_1    + (i_data_s_q0 << 5) + (i_data_s_q0 << 4) + (i_data_s_q0 << 1);

assign  l_275_sgn             = $signed({1'b0,l_275});
assign  m_x671_sgn            = $signed({1'b0,m_x671});
assign  s_x946_sgn            = $signed({1'b0,s_x946});
assign  cb_x1024_rnd_sgn      = $signed({1'b0,1'b1,{(SHIFT_BIT_YCBCR -1){1'b0}}});

assign  cb_x1024_sft_sgn_nxt  = $signed(-l_275_sgn - m_x671_sgn + s_x946_sgn + cb_x1024_rnd_sgn) >>> SHIFT_BIT_YCBCR;
assign  cb_x1024_bdy          = $signed({cb_x1024_sft_sgn[U_SFT_MSB-1],1'b1})* cb_x1024_sft_sgn > $signed({1'b0,{(COW-1){1'b1}}});         //boundary 
assign  data_cb_sgn           = (cb_x1024_bdy ? $signed({{2{cb_x1024_sft_sgn[U_SFT_MSB-1]}},{COW-1{!cb_x1024_sft_sgn[U_SFT_MSB-1]}}}) : cb_x1024_sft_sgn ) + 
                                $signed({1'b0,YCBCR_POS,{COIW_YUV-1{1'b0}},{COPW_YUV{1'b0}}});                                             //-128~127 or //0~255 
                                                                                                                                           //maybe overflow or underflow  

// Cr = 2.5595703125*L+ -2.6787109375*M + 0.119140625*S
// Cr = (2621/1024)*L+ (-2743/1024)*M + (122/1024)*S

//add stage 1 
assign  l_x2621_part_1_nxt    = (i_data_l << 11) + (i_data_l << 9)    + (i_data_l << 6);  
assign  m_x2743_part_1_nxt    = (i_data_m << 11) + (i_data_m << 9)    + (i_data_m << 7)    + (i_data_m << 5);
assign  s_x122_part_1_nxt     = (i_data_s << 7)  - (i_data_s << 2);

assign  l_x2621_nxt           = l_x2621_part_1   - (i_data_l_q0 << 1) - i_data_l_q0;
assign  m_x2743_nxt           = m_x2743_part_1   + (i_data_m_q0 << 4) + (i_data_m_q0 << 3) - i_data_m_q0;
assign  s_x122_nxt            = s_x122_part_1    - (i_data_s_q0 << 1);

assign  l_x2621_sgn           = $signed({1'b0,l_x2621});
assign  m_x2743_sgn           = $signed({1'b0,m_x2743});
assign  s_x122_sgn            = $signed({1'b0,s_x122});
assign  cr_x1024_rnd_sgn      = $signed({1'b0,1'b1,{(SHIFT_BIT_YCBCR -1){1'b0}}});

assign  cr_x1024_sft_sgn_nxt  = $signed(l_x2621_sgn - m_x2743_sgn + s_x122_sgn + cr_x1024_rnd_sgn) >>> SHIFT_BIT_YCBCR;
assign  cr_x1024_bdy          = $signed({cr_x1024_sft_sgn[V_SFT_MSB-1],1'b1})* cr_x1024_sft_sgn > $signed({1'b0,{(COW-1){1'b1}}});         //boundary 
assign  data_cr_sgn           = (cr_x1024_bdy ? $signed({{2{cr_x1024_sft_sgn[V_SFT_MSB-1]}},{COW-1{!cr_x1024_sft_sgn[V_SFT_MSB-1]}}}) : cr_x1024_sft_sgn ) + 
                                $signed({1'b0,YCBCR_POS,{COIW_YUV-1{1'b0}},{COPW_YUV{1'b0}}});                                             //-128~127 or //0~255 
                                                                                                                                           //maybe overflow or underflow 

//-------------------------------------------------------------------------------------------- output
assign  o_data_ch1_nxt        = r_conv_sel ? data_r : {1'b0,data_y};
assign  o_data_ch2_nxt        = r_conv_sel ? data_g : {1'b0,data_cb_sgn};
assign  o_data_ch3_nxt        = r_conv_sel ? data_b : {1'b0,data_cr_sgn};

assign  out_que_nxt           = {out_que[QUE_TOL:0] , i_hstr,i_href,i_hend};
assign  o_hstr                = out_que[QUE_TOL];
assign  o_href                = out_que[QUE_TOL-1];
assign  o_hend                = out_que[QUE_TOL-2];


always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
//-------------------------------------------------------------------------------------------- input
        i_data_l_q0       <= 0;
        i_data_m_q0       <= 0;
        i_data_s_q0       <= 0;
        
//-------------------------------------------------------------------------------------------- color convert rgb
        l_x8349_part_1    <= 0;
        m_x6774_part_1    <= 0;
        s_x473_part_1     <= 0;
        l_x2598_part_1    <= 0;
        m_x5345_part_1    <= 0;
        s_x699_part_1     <= 0;
        l_x9_part_1       <= 0;
        m_x1441_part_1    <= 0;
        s_x3497_part_1    <= 0;

        l_x8349           <= 0;
        m_x6774           <= 0;
        s_x473            <= 0;
        l_x2598           <= 0;
        m_x5345           <= 0;
        s_x699            <= 0;
        l_x9              <= 0;
        m_x1441           <= 0;
        s_x3497           <= 0; 
        
        r_x2048_sft_sgn   <= 0;
        g_x2048_sft_sgn   <= 0;
        b_x2048_sft_sgn   <= 0;
        
//-------------------------------------------------------------------------------------------- color convert ycbcr
        l_x485_part_1     <= 0;
        m_x474_part_1     <= 0;
        s_x65_part_1      <= 0;
        l_275_part_1      <= 0;
        m_x671_part_1     <= 0;
        s_x946_part_1     <= 0;
        l_x2621_part_1    <= 0;
        m_x2743_part_1    <= 0;
        s_x122_part_1     <= 0;

        l_x485            <= 0;
        m_x474            <= 0;
        s_x65             <= 0;
        l_275             <= 0;
        m_x671            <= 0;
        s_x946            <= 0;
        l_x2621           <= 0;
        m_x2743           <= 0;
        s_x122            <= 0;
        
        y_x1024_sft       <= 0;
        cb_x1024_sft_sgn  <= 0;
        cr_x1024_sft_sgn  <= 0;
        
//-------------------------------------------------------------------------------------------- output
        out_que           <= 0;
        o_data_ch1        <= 0;
        o_data_ch2        <= 0;
        o_data_ch3        <= 0;
        
    end
    else begin
//-------------------------------------------------------------------------------------------- input
        i_data_l_q0       <= i_data_l;
        i_data_m_q0       <= i_data_m;
        i_data_s_q0       <= i_data_s;
        
//-------------------------------------------------------------------------------------------- color convert rgb
        l_x8349_part_1    <= l_x8349_part_1_nxt;
        m_x6774_part_1    <= m_x6774_part_1_nxt;
        s_x473_part_1     <= s_x473_part_1_nxt ;
        l_x2598_part_1    <= l_x2598_part_1_nxt;
        m_x5345_part_1    <= m_x5345_part_1_nxt;
        s_x699_part_1     <= s_x699_part_1_nxt ;
        l_x9_part_1       <= l_x9_part_1_nxt;
        m_x1441_part_1    <= m_x1441_part_1_nxt;
        s_x3497_part_1    <= s_x3497_part_1_nxt;

        l_x8349           <= l_x8349_nxt;
        m_x6774           <= m_x6774_nxt;
        s_x473            <= s_x473_nxt ;
        l_x2598           <= l_x2598_nxt;
        m_x5345           <= m_x5345_nxt;
        s_x699            <= s_x699_nxt ;
        l_x9              <= l_x9_nxt;
        m_x1441           <= m_x1441_nxt;
        s_x3497           <= s_x3497_nxt;
        
        r_x2048_sft_sgn   <= r_x2048_sft_sgn_nxt;
        g_x2048_sft_sgn   <= g_x2048_sft_sgn_nxt;
        b_x2048_sft_sgn   <= b_x2048_sft_sgn_nxt;
        
//-------------------------------------------------------------------------------------------- color convert ycbcr
        l_x485_part_1     <= l_x485_part_1_nxt;
        m_x474_part_1     <= m_x474_part_1_nxt;
        s_x65_part_1      <= s_x65_part_1_nxt ;
        l_275_part_1      <= l_275_part_1_nxt;
        m_x671_part_1     <= m_x671_part_1_nxt;
        s_x946_part_1     <= s_x946_part_1_nxt ;
        l_x2621_part_1    <= l_x2621_part_1_nxt;
        m_x2743_part_1    <= m_x2743_part_1_nxt;
        s_x122_part_1     <= s_x122_part_1_nxt;

        l_x485            <= l_x485_nxt;
        m_x474            <= m_x474_nxt;
        s_x65             <= s_x65_nxt ;
        l_275             <= l_275_nxt;
        m_x671            <= m_x671_nxt;
        s_x946            <= s_x946_nxt ;
        l_x2621           <= l_x2621_nxt;
        m_x2743           <= m_x2743_nxt;
        s_x122            <= s_x122_nxt;
        
        y_x1024_sft       <= y_x1024_sft_nxt;
        cb_x1024_sft_sgn  <= cb_x1024_sft_sgn_nxt;
        cr_x1024_sft_sgn  <= cr_x1024_sft_sgn_nxt;
        
//-------------------------------------------------------------------------------------------- output
        out_que           <= out_que_nxt;
        o_data_ch1        <= o_data_ch1_nxt;
        o_data_ch2        <= o_data_ch2_nxt;
        o_data_ch3        <= o_data_ch3_nxt;
        
    end
end

endmodule
