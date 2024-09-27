// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_rgb2lms_rtl.v
// Author:              1.Willy Lin
//                      2.Martin Chen 
//                      3.Humphrey Lin
// Version:             1.0
// Last Modified On:    2022/10/28
//
// File Description:    RGB to LMS Converter
// Abbreviations:
// Parameters:          PRECISION: S 1.12
// Data precision :     input  :     8.0
//                      outupt :     8.4
// Consuming time :     4T  
//
// -FHDR -----------------------------------------------------------------------

module ip_rgb2lms
    #(
         parameter   CIIW       = 8,             //Accuracy Input Integer Width  //Accuracy can be reduced , but not improved 
         parameter   CIPW       = 0,             //Accuracy Input Point Width    //Accuracy can be reduced , but not improved 
         parameter   COIW       = 8,             //Accuracy Output Integer Width //Accuracy can be reduced , but not improved 
         parameter   COPW       = 4,             //Accuracy Output Point Width   //Accuracy can be reduced , but not improved 
         parameter   CIW        = CIIW + CIPW,
         parameter   COW        = COIW + COPW
     )
(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output reg        [COW-1:0]   o_data_l,                      
output reg        [COW-1:0]   o_data_m,                     
output reg        [COW-1:0]   o_data_s,                    
output                        o_hstr,
output                        o_hend,
output                        o_href,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input             [CIW-1:0]   i_data_r,                      // input R
input             [CIW-1:0]   i_data_g,                      // input G
input             [CIW-1:0]   i_data_b,                      // input B
input                         i_hstr,
input                         i_hend,
input                         i_href,
input                         clk,
input                         rst_n
);

//----------------------------------------------//
// Local parameter                              //
//----------------------------------------------//
localparam [4:0]              SHIFT_BIT = (12 +CIPW -COPW);
localparam [COW:0]            MAX_NUM   = (2**COW);

localparam [3:0]              QUE_NUM   = 4;
localparam [3:0]              QUE_TOL   = (QUE_NUM)*3-1;

localparam                    L_SFT_MSB = 13 + CIW-SHIFT_BIT;
localparam                    M_SFT_MSB = 13 + CIW-SHIFT_BIT;
localparam                    S_SFT_MSB = 13 + CIW-SHIFT_BIT;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
//--------------------------------------------------------------------------------------------  input 
reg          [CIW-1:0]            i_data_r_q0;
reg          [CIW-1:0]            i_data_g_q0;
reg          [CIW-1:0]            i_data_b_q0;

//-------------------------------------------------------------------------------------------- color space convert  
wire         [11 + CIW -1 :0]            r_x1688_part_1_nxt;
wire         [12 + CIW -1 :0]            g_x2197_part_1_nxt;
wire         [8  + CIW -1 :0]            b_x211_part_1_nxt;
reg          [11 + CIW -1 :0]            r_x1688_part_1;
reg          [12 + CIW -1 :0]            g_x2197_part_1;
reg          [8  + CIW -1 :0]            b_x211_part_1;
wire         [11 + CIW -1 :0]            r_x1688_nxt;
wire         [12 + CIW -1 :0]            g_x2197_nxt;
wire         [8  + CIW -1 :0]            b_x211_nxt;
reg          [11 + CIW -1 :0]            r_x1688;
reg          [12 + CIW -1 :0]            g_x2197;
reg          [8  + CIW -1 :0]            b_x211;
wire         [SHIFT_BIT-1: 0]            l_x4096_rnd;
reg          [L_SFT_MSB -1 : 0]          l_x4096_sft;
wire         [L_SFT_MSB -1 : 0]          l_x4096_sft_nxt;
wire                                     l_x4096_bdy;

wire         [10 + CIW -1 :0]            r_x868_part_1_nxt;
wire         [12 + CIW -1 :0]            g_x2788_part_1_nxt;
wire         [9  + CIW -1 :0]            b_x440_part_1_nxt;
reg          [10 + CIW -1 :0]            r_x868_part_1;
reg          [12 + CIW -1 :0]            g_x2788_part_1;
reg          [9  + CIW -1 :0]            b_x440_part_1;
wire         [10 + CIW -1 :0]            r_x868_nxt;
wire         [12 + CIW -1 :0]            g_x2788_nxt;
wire         [9  + CIW -1 :0]            b_x440_nxt;
reg          [10 + CIW -1 :0]            r_x868;
reg          [12 + CIW -1 :0]            g_x2788;
reg          [9  + CIW -1 :0]            b_x440;
wire         [SHIFT_BIT-1: 0]            m_x4096_rnd;
reg          [M_SFT_MSB -1 : 0]          m_x4096_sft;
wire         [M_SFT_MSB -1 : 0]          m_x4096_sft_nxt;
wire                                     m_x4096_bdy;

wire         [9  + CIW -1 :0]            r_x362_part_1_nxt;
wire         [11 + CIW -1 :0]            g_x1154_part_1_nxt;
wire         [12 + CIW -1 :0]            b_x2580_part_1_nxt;
reg          [9  + CIW -1 :0]            r_x362_part_1;
reg          [11 + CIW -1 :0]            g_x1154_part_1;
reg          [12 + CIW -1 :0]            b_x2580_part_1;
wire         [9  + CIW -1 :0]            r_x362_nxt;
wire         [11 + CIW -1 :0]            g_x1154_nxt;
wire         [12 + CIW -1 :0]            b_x2580_nxt;
reg          [9  + CIW -1 :0]            r_x362;
reg          [11 + CIW -1 :0]            g_x1154;
reg          [12 + CIW -1 :0]            b_x2580;
wire         [12 + CIW-COW:0]            s_x4096_rnd;
reg          [S_SFT_MSB -1 : 0]          s_x4096_sft;
wire         [S_SFT_MSB -1 : 0]          s_x4096_sft_nxt;
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
//-------------------------------------------------------------------------------------------- color space convert  

// 12 bit precision 
// L = 0.412109375*R+ 0.536376953125*G + 0.051513671875*B
// L = (1688/4096)*R+ (2197/4096)*G + (211/4096)*B

assign  r_x1688_part_1_nxt = (i_data_r <<10) + (i_data_r <<9)    + (i_data_r <<7);
assign  g_x2197_part_1_nxt = (i_data_g <<11) + (i_data_g <<7)    + (i_data_g <<4);
assign  b_x211_part_1_nxt  = (i_data_b <<7)  + (i_data_b <<6)    + (i_data_b <<4);

assign  r_x1688_nxt        = r_x1688_part_1  + (i_data_r_q0 <<4) + (i_data_r_q0 <<3); 
assign  g_x2197_nxt        = g_x2197_part_1  + (i_data_g_q0 <<2) + (i_data_g_q0 <<0);
assign  b_x211_nxt         = b_x211_part_1   + (i_data_b_q0 <<1) + (i_data_b_q0 <<0);

assign  l_x4096_rnd        = {1'b1,{(SHIFT_BIT -1){1'b0}}};
assign  l_x4096_sft_nxt    = (r_x1688 + g_x2197 + b_x211 + l_x4096_rnd) >> SHIFT_BIT;
assign  l_x4096_bdy        = l_x4096_sft > {COW{1'b1}};                                 //boundary 
assign  o_data_l_nxt       = (l_x4096_bdy ? {COW{1'b1}} : l_x4096_sft[COW-1:0]);        //0~255  //maybe overflow 


// M = 0.2119140625*R+ 0.6806640625*G + 0.107421875*B
// M = (868/4096)*R+ (2788/4096)*G + (440/4096)*B

assign  r_x868_part_1_nxt  = (i_data_r <<9)  + (i_data_r <<8)    + (i_data_r <<6);
assign  g_x2788_part_1_nxt = (i_data_g <<11) + (i_data_g <<9)    + (i_data_g <<8);
assign  b_x440_part_1_nxt  = (i_data_b <<9);

assign  r_x868_nxt         = r_x868_part_1   + (i_data_r_q0 <<5) + (i_data_r_q0 <<2);
assign  g_x2788_nxt        = g_x2788_part_1  - (i_data_g_q0 <<5) + (i_data_g_q0 <<2);
assign  b_x440_nxt         = b_x440_part_1   - (i_data_b_q0 <<6) - (i_data_b_q0 <<3) ;

assign  m_x4096_rnd        = {1'b1,{(SHIFT_BIT -1){1'b0}}};
assign  m_x4096_sft_nxt    = (r_x868 + g_x2788 + b_x440 + m_x4096_rnd) >> SHIFT_BIT;
assign  m_x4096_bdy        = m_x4096_sft > {COW{1'b1}};                                 //boundary 
assign  o_data_m_nxt       = (m_x4096_bdy ? {COW{1'b1}} : m_x4096_sft[COW-1:0]);        //0~255  //maybe overflow 

// S = 0.08837890625*R+ 0.28173828125*G + 0.6298828125*B
// S = (362/4096)*R+ (1154/4096)*G + (2580/4096)*B

assign  r_x362_part_1_nxt  = (i_data_r <<8)  + (i_data_r <<6)    + (i_data_r <<5);
assign  g_x1154_part_1_nxt = (i_data_g <<10);
assign  b_x2580_part_1_nxt = (i_data_b <<11) + (i_data_b <<9);

assign  r_x362_nxt         = r_x362_part_1   + (i_data_r_q0 <<3) + (i_data_r_q0 <<1);
assign  g_x1154_nxt        = g_x1154_part_1  + (i_data_g_q0 <<7) + (i_data_g_q0 <<1);
assign  b_x2580_nxt        = b_x2580_part_1  + (i_data_b_q0 <<4) + (i_data_b_q0 <<2);

assign  s_x4096_rnd        = {1'b1,{(SHIFT_BIT -1){1'b0}}};
assign  s_x4096_sft_nxt    = (r_x362 + g_x1154 + b_x2580 + s_x4096_rnd) >> SHIFT_BIT;
assign  s_x4096_bdy        = s_x4096_sft > {COW{1'b1}};                                 //boundary 
assign  o_data_s_nxt       = (s_x4096_bdy ? {COW{1'b1}} : s_x4096_sft[COW-1:0]);        //0~255 //maybe overflow 

//-------------------------------------------------------------------------------------------- output
assign  out_que_nxt        = {out_que[QUE_TOL:0] , i_hstr,i_href,i_hend};
assign  o_hstr             = out_que[QUE_TOL];
assign  o_href             = out_que[QUE_TOL-1];
assign  o_hend             = out_que[QUE_TOL-2];

always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
//-------------------------------------------------------------------------------------------- color space convert 
        r_x1688_part_1    <= 0;
        g_x2197_part_1    <= 0;
        b_x211_part_1     <= 0;
        r_x868_part_1     <= 0;
        g_x2788_part_1    <= 0;
        b_x440_part_1     <= 0;
        r_x362_part_1     <= 0;
        g_x1154_part_1    <= 0;
        b_x2580_part_1    <= 0;
        
        r_x1688           <= 0;
        g_x2197           <= 0;
        b_x211            <= 0;
        r_x868            <= 0;
        g_x2788           <= 0;
        b_x440            <= 0;
        r_x362            <= 0;
        g_x1154           <= 0;
        b_x2580           <= 0;
        
        i_data_r_q0       <= 0;
        i_data_g_q0       <= 0;
        i_data_b_q0       <= 0;
        
        l_x4096_sft       <= 0;
        m_x4096_sft       <= 0;
        s_x4096_sft       <= 0;
        
//-------------------------------------------------------------------------------------------- output
        out_que           <= 0;
        o_data_l          <= 0;                
        o_data_m          <= 0;                     
        o_data_s          <= 0; 
        
    end
    else begin
//-------------------------------------------------------------------------------------------- color space convert 
        r_x1688_part_1    <= r_x1688_part_1_nxt;
        g_x2197_part_1    <= g_x2197_part_1_nxt;
        b_x211_part_1     <= b_x211_part_1_nxt;
        r_x868_part_1     <= r_x868_part_1_nxt;
        g_x2788_part_1    <= g_x2788_part_1_nxt;
        b_x440_part_1     <= b_x440_part_1_nxt;
        r_x362_part_1     <= r_x362_part_1_nxt;
        g_x1154_part_1    <= g_x1154_part_1_nxt;
        b_x2580_part_1    <= b_x2580_part_1_nxt;
        
        r_x1688           <= r_x1688_nxt;
        g_x2197           <= g_x2197_nxt;
        b_x211            <= b_x211_nxt ;
        r_x868            <= r_x868_nxt ;
        g_x2788           <= g_x2788_nxt;
        b_x440            <= b_x440_nxt ;
        r_x362            <= r_x362_nxt ;
        g_x1154           <= g_x1154_nxt;
        b_x2580           <= b_x2580_nxt;
        
        i_data_r_q0       <= i_data_r;
        i_data_g_q0       <= i_data_g;
        i_data_b_q0       <= i_data_b;

        l_x4096_sft       <= l_x4096_sft_nxt;
        m_x4096_sft       <= m_x4096_sft_nxt;
        s_x4096_sft       <= s_x4096_sft_nxt;
        
//-------------------------------------------------------------------------------------------- output
        out_que           <= out_que_nxt;
        o_data_l          <= o_data_l_nxt;                
        o_data_m          <= o_data_m_nxt;                     
        o_data_s          <= o_data_s_nxt; 
        
    end
end




endmodule

