// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_lms2rgb.v
// Author:              1.Willy Lin
//                      2.Martin Chen 
//                      3.Humphrey Lin
// Version:             1.0
// Last Modified On:    2022/10/28
//
// File Description:    LMS to RGB Converter
// Abbreviations:
// Parameters:          PRECISION: S 3.11
// Data precision :     input  :     8.6
//                      outupt :     8.0
// Consuming time :     4T  
// -FHDR -----------------------------------------------------------------------

module ip_lms2rgb 
   #(
    parameter CIIW    = 8,               //Accuracy Input Integer Width     //Accuracy can be reduced , but not improved 
    parameter CIPW    = 6,               //Accuracy Input Point Width       //Accuracy can be reduced , but not improved 
    parameter COIW    = 8,               //Accuracy Output Integer Width    //Accuracy can be reduced , but not improved 
    parameter COPW    = 0,               //Accuracy Output Point Width      //Accuracy can be reduced , but not improved 
    parameter CIW     = CIIW + CIPW,
    parameter COW     = COIW + COPW
    )
(
    
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg [COW-1:0]         o_data_r,
output reg [COW-1:0]         o_data_g,
output reg [COW-1:0]         o_data_b,
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
input                        clk,
input                        rst_n
);

//----------------------------------------------//
// Local parameter                              //
//----------------------------------------------//
localparam [4:0]            SHIFT_BIT = (11 +CIPW -COPW);  

localparam [3:0]            QUE_NUM   = 4;
localparam [3:0]            QUE_TOL   = (QUE_NUM)*3-1;

localparam                  R_SFT_MSB = 16 + CIW-SHIFT_BIT;
localparam                  G_SFT_MSB = 15 + CIW-SHIFT_BIT;
localparam                  B_SFT_MSB = 14 + CIW-SHIFT_BIT;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
//-------------------------------------------------------------------------------------------- input
reg          [CIW-1:0]                   i_data_l_q0;
reg          [CIW-1:0]                   i_data_m_q0;
reg          [CIW-1:0]                   i_data_s_q0;

reg                                      i_hstr_q0;
reg                                      i_hend_q0;
reg                                      i_href_q0;

//-------------------------------------------------------------------------------------------- color convert
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
wire signed  [SHIFT_BIT:0]               r_x2048_rnd_sgn;
reg  signed  [R_SFT_MSB -1 : 0]          r_x2048_sft_sgn;
wire signed  [R_SFT_MSB -1 : 0]          r_x2048_sft_sgn_nxt;

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
wire signed  [SHIFT_BIT:0]               g_x2048_rnd_sgn;
reg  signed  [G_SFT_MSB -1 : 0]          g_x2048_sft_sgn;
wire signed  [G_SFT_MSB -1 : 0]          g_x2048_sft_sgn_nxt;

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
wire signed  [SHIFT_BIT:0]               b_x2048_rnd_sgn;
reg  signed  [B_SFT_MSB -1 : 0]          b_x2048_sft_sgn;
wire signed  [B_SFT_MSB -1 : 0]          b_x2048_sft_sgn_nxt;

//-------------------------------------------------------------------------------------------- output
reg          [QUE_TOL:0]                 out_que;
wire         [QUE_TOL:0]                 out_que_nxt;

wire         [COW -1 : 0]                o_data_r_nxt;
wire         [COW -1 : 0]                o_data_g_nxt;
wire         [COW -1 : 0]                o_data_b_nxt;
//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

//-------------------------------------------------------------------------------------------- color convert
//In order to reduce the gate count, it must be divided into two parts 

// 11 bit precision 
// R = 4.07666015625*L+ -3.3076171875*M + 0.23095703125*S
// R = (8349/2048)*L+ (-6774/2048)*M + (473/2048)*S

//add stage 1 
assign  l_x8349_part_1_nxt  = (i_data_l << 13) + (i_data_l << 7)    + (i_data_l << 5);  
assign  m_x6774_part_1_nxt  = (i_data_m << 13) - (i_data_m << 10)   - (i_data_m << 8);
assign  s_x473_part_1_nxt   = (i_data_s << 9)  - (i_data_s << 5);

assign  l_x8349_nxt         = l_x8349_part_1   - (i_data_l_q0 << 1) - (i_data_l_q0 << 0);
assign  m_x6774_nxt         = m_x6774_part_1   - (i_data_m_q0 << 7) - (i_data_m_q0 << 3) - (i_data_m_q0 << 1);
assign  s_x473_nxt          = s_x473_part_1    - (i_data_s_q0 << 2) - (i_data_s_q0 << 1) - (i_data_s_q0 << 0);

assign  l_x8349_sgn         = $signed({1'b0,l_x8349});
assign  m_x6774_sgn         = $signed({1'b0,m_x6774});
assign  s_x473_sgn          = $signed({1'b0,s_x473});
assign  r_x2048_rnd_sgn     = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});

assign  r_x2048_sft_sgn_nxt = $signed(l_x8349_sgn - m_x6774_sgn + s_x473_sgn + r_x2048_rnd_sgn) >>> SHIFT_BIT;
assign  r_x2048_bdy         = r_x2048_sft_sgn > $unsigned({COW{!r_x2048_sft_sgn[R_SFT_MSB-1]}});                 //boundary 
assign  o_data_r_nxt        = r_x2048_bdy ? {COW{!r_x2048_sft_sgn[R_SFT_MSB-1]}} : $unsigned(r_x2048_sft_sgn);   //0~255  //maybe overflow or underflow 

// G = -1.2685546875*L+ 2.60986328125*M + -0.34130859375*S
// G = (-2598/2048)*L+ (5345/2048)*M + (-699/2048)*S

assign  l_x2598_part_1_nxt  = (i_data_l << 11) + (i_data_l << 9)    + (i_data_l << 5);
assign  m_x5345_part_1_nxt  = (i_data_m << 12) + (i_data_m << 10)   + (i_data_m << 7);
assign  s_x699_part_1_nxt   = (i_data_s << 9)  + (i_data_s << 7);

assign  l_x2598_nxt         = l_x2598_part_1   + (i_data_l_q0 << 2) + (i_data_l_q0 << 1);
assign  m_x5345_nxt         = m_x5345_part_1   + (i_data_m_q0 << 6) + (i_data_m_q0 << 5) + (i_data_m_q0 << 0);
assign  s_x699_nxt          = s_x699_part_1    + (i_data_s_q0 << 6) - (i_data_s_q0 << 2) - (i_data_s_q0 << 0);

assign  l_x2598_sgn         = $signed({1'b0,l_x2598});
assign  m_x5345_sgn         = $signed({1'b0,m_x5345});
assign  s_x699_sgn          = $signed({1'b0,s_x699});
assign  g_x2048_rnd_sgn     = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});

assign  g_x2048_sft_sgn_nxt = $signed(-l_x2598_sgn + m_x5345_sgn - s_x699_sgn + g_x2048_rnd_sgn) >>> SHIFT_BIT;
assign  g_x2048_bdy         = g_x2048_sft_sgn > $unsigned({COW{!g_x2048_sft_sgn[G_SFT_MSB-1]}});                 //boundary 
assign  o_data_g_nxt        = g_x2048_bdy ? {COW{!g_x2048_sft_sgn[COW+1]}} : $unsigned(g_x2048_sft_sgn);         //0~255  //maybe overflow or underflow 


// B = -0.00439453125*L+ -0.70361328125*M + 1.70751953125*S
// B = (-9/2048)*L+ (-1441/2048)*M + (3497/2048)*S

assign  l_x9_part_1_nxt     = (i_data_l << 3)  + (i_data_l << 0);
assign  m_x1441_part_1_nxt  = (i_data_m << 10) + (i_data_m << 8)    + (i_data_m << 7);
assign  s_x3497_part_1_nxt  = (i_data_s << 12) - (i_data_s << 9)    - (i_data_s << 6);

assign  l_x9_nxt            = l_x9_part_1;
assign  m_x1441_nxt         = m_x1441_part_1   + (i_data_m_q0 << 5) + (i_data_m_q0 << 0);
assign  s_x3497_nxt         = s_x3497_part_1   - (i_data_s_q0 << 4) - (i_data_s_q0 << 3) + (i_data_s_q0 << 0);

assign  l_x9_sgn            = $signed({1'b0,l_x9});
assign  m_x1441_sgn         = $signed({1'b0,m_x1441});
assign  s_x3497_sgn         = $signed({1'b0,s_x3497});
assign  b_x2048_rnd_sgn     = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});

assign  b_x2048_sft_sgn_nxt = $signed(-l_x9_sgn - m_x1441_sgn + s_x3497_sgn + b_x2048_rnd_sgn) >>> SHIFT_BIT;
assign  b_x2048_bdy         = b_x2048_sft_sgn > $unsigned({COW{!b_x2048_sft_sgn[B_SFT_MSB-1]}});                 //boundary 
assign  o_data_b_nxt        = b_x2048_bdy ? {COW{!b_x2048_sft_sgn[COW+1]}} : $unsigned(b_x2048_sft_sgn);         //0~255  //maybe overflow or underflow 

//-------------------------------------------------------------------------------------------- output
assign  out_que_nxt         = {out_que[QUE_TOL:0] , i_hstr,i_href,i_hend};
assign  o_hstr              = out_que[QUE_TOL];
assign  o_href              = out_que[QUE_TOL-1];
assign  o_hend              = out_que[QUE_TOL-2];

always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
//-------------------------------------------------------------------------------------------- input
        i_data_l_q0      <= 0;
        i_data_m_q0      <= 0;
        i_data_s_q0      <= 0;
        
//-------------------------------------------------------------------------------------------- color convert
        l_x8349_part_1   <= 0;
        m_x6774_part_1   <= 0;
        s_x473_part_1    <= 0;
        l_x2598_part_1   <= 0;
        m_x5345_part_1   <= 0;
        s_x699_part_1    <= 0;
        l_x9_part_1      <= 0;
        m_x1441_part_1   <= 0;
        s_x3497_part_1   <= 0;

        l_x8349          <= 0;
        m_x6774          <= 0;
        s_x473           <= 0;
        l_x2598          <= 0;
        m_x5345          <= 0;
        s_x699           <= 0;
        l_x9             <= 0;
        m_x1441          <= 0;
        s_x3497          <= 0;
        
        r_x2048_sft_sgn  <= 0;
        g_x2048_sft_sgn  <= 0;
        b_x2048_sft_sgn  <= 0;
//-------------------------------------------------------------------------------------------- output
        out_que          <= 0;
        o_data_r         <= 0;
        o_data_g         <= 0;
        o_data_b         <= 0; 
  
    end
    else begin
//-------------------------------------------------------------------------------------------- input
        i_data_l_q0      <= i_data_l;
        i_data_m_q0      <= i_data_m;
        i_data_s_q0      <= i_data_s;
        
//-------------------------------------------------------------------------------------------- color convert
        l_x8349_part_1   <= l_x8349_part_1_nxt;
        m_x6774_part_1   <= m_x6774_part_1_nxt;
        s_x473_part_1    <= s_x473_part_1_nxt ;
        l_x2598_part_1   <= l_x2598_part_1_nxt;
        m_x5345_part_1   <= m_x5345_part_1_nxt;
        s_x699_part_1    <= s_x699_part_1_nxt ;
        l_x9_part_1      <= l_x9_part_1_nxt;
        m_x1441_part_1   <= m_x1441_part_1_nxt;
        s_x3497_part_1   <= s_x3497_part_1_nxt;

        l_x8349          <= l_x8349_nxt;
        m_x6774          <= m_x6774_nxt;
        s_x473           <= s_x473_nxt ;
        l_x2598          <= l_x2598_nxt;
        m_x5345          <= m_x5345_nxt;
        s_x699           <= s_x699_nxt ;
        l_x9             <= l_x9_nxt   ;
        m_x1441          <= m_x1441_nxt;
        s_x3497          <= s_x3497_nxt;

        r_x2048_sft_sgn  <= r_x2048_sft_sgn_nxt;
        g_x2048_sft_sgn  <= g_x2048_sft_sgn_nxt;
        b_x2048_sft_sgn  <= b_x2048_sft_sgn_nxt;
        
//-------------------------------------------------------------------------------------------- output
        out_que          <= out_que_nxt;
        o_data_r         <= o_data_r_nxt;
        o_data_g         <= o_data_g_nxt;
        o_data_b         <= o_data_b_nxt; 
        
    end
end
endmodule
