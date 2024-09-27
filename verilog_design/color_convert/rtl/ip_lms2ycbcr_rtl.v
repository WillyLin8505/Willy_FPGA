// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_lms2ycbcr.v
// Author:              1.Willy Lin
//                      2.Martin Chen
//                      3.Humphrey Lin
// Version:             1.0
// Last Modified On:    2023/1/5
//
// File Description:    LMS to YCBCR Converter
// Abbreviations:
// Parameters:          PRECISION: S 2.10
// Data precision :     input  :     8.6
//                      outupt : Y : 8.4
//                               Cb: S 7.4 or 8.4
//                               Cr: S 7.4 or 8.4
// Consuming time :     4T
// -FHDR -----------------------------------------------------------------------

module ip_lms2ycbcr
   #(
    parameter CIIW      = 8,               //Accuracy Input Integer Width     //Accuracy can be reduced , but not improved
    parameter CIPW      = 6,               //Accuracy Input Point Width       //Accuracy can be reduced , but not improved
    parameter COIW      = 8,               //Accuracy Output Integer Width    //Accuracy can be reduced , but not improved
    parameter COPW      = 4,               //Accuracy Output Point Width      //Accuracy can be reduced , but not improved
    parameter CIW       = CIIW + CIPW,
    parameter COW       = COIW + COPW,
    parameter YCBCR_POS = 1'b1
    )
(

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg    [COW-1:0]             o_data_y,
output signed [COW  :0]             o_data_cb,
output signed [COW  :0]             o_data_cr,
output                              o_hstr,
output                              o_hend,
output                              o_href,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input             [CIW-1:0]         i_data_l,
input             [CIW-1:0]         i_data_m,
input             [CIW-1:0]         i_data_s,
input                               i_hstr,
input                               i_hend,
input                               i_href,
input                               clk,
input                               rst_n
);

//----------------------------------------------//
// Local parameter                              //
//----------------------------------------------//
localparam [4:0]            SHIFT_BIT = (10 +CIPW -COPW);
localparam [COW:0]          MAX_NUM   = (2**COW);

localparam [3:0]            QUE_NUM   = 4;
localparam [3:0]            QUE_TOL   = (QUE_NUM)*3-1;

localparam                  Y_SFT_MSB = 11 + CIW;            //can not set to  " 11 + CIW-SHIFT_BIT " , i don't know why
localparam                  U_SFT_MSB = 13 + CIW-SHIFT_BIT;
localparam                  V_SFT_MSB = 15 + CIW-SHIFT_BIT;


//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
//-------------------------------------------------------------------------------------------- input

reg                                      i_hstr_q0;
reg                                      i_hend_q0;
reg                                      i_href_q0;

//-------------------------------------------------------------------------------------------- color convert

wire         [CIW-1:0]                   i_data_l_ppf0_nxt;
wire         [CIW-1:0]                   i_data_m_ppf0_nxt;
wire         [CIW-1:0]                   i_data_s_ppf0_nxt;
reg          [CIW-1:0]                   i_data_l_ppf0;
reg          [CIW-1:0]                   i_data_m_ppf0;
reg          [CIW-1:0]                   i_data_s_ppf0;

wire         [9  + CIW -1 : 0]           l_x485_ppr0_nxt;
wire         [9  + CIW -1 : 0]           m_x474_ppr0_nxt;
wire         [7  + CIW -1 : 0]           s_x65_ppr0_nxt;
reg          [9  + CIW -1 : 0]           l_x485_ppr0;
reg          [9  + CIW -1 : 0]           m_x474_ppr0;
reg          [7  + CIW -1 : 0]           s_x65_ppr0;

wire         [9  + CIW -1 : 0]           l_x485_ppf1_nxt;
wire         [9  + CIW -1 : 0]           m_x474_ppf1_nxt;
wire         [7  + CIW -1 : 0]           s_x65_ppf1_nxt;
reg          [9  + CIW -1 : 0]           l_x485_ppf1;
reg          [9  + CIW -1 : 0]           m_x474_ppf1;
reg          [7  + CIW -1 : 0]           s_x65_ppf1;


wire         [SHIFT_BIT: 0]              y_x2048_rnd;
//wire         [Y_SFT_MSB -1 : 0]          y_x2048_sft;
wire         [25 : 0]                    y_x2048;
wire         [13 : 0]                    y_x2048_sft;
wire                                     y_x2048_bdy;


wire         [9  + CIW -1 : 0]           l_x275_ppr0_nxt;
wire         [10 + CIW -1 : 0]           m_x671_ppr0_nxt;
wire         [10 + CIW -1 : 0]           s_x946_ppr0_nxt;
reg          [9  + CIW -1 : 0]           l_x275_ppr0;
reg          [10 + CIW -1 : 0]           m_x671_ppr0;
reg          [10 + CIW -1 : 0]           s_x946_ppr0;

wire         [9  + CIW -1 : 0]           l_x275_ppf1_nxt;
wire         [10 + CIW -1 : 0]           m_x671_ppf1_nxt;
wire         [10 + CIW -1 : 0]           s_x946_ppf1_nxt;
reg          [9  + CIW -1 : 0]           l_x275_ppf1;
reg          [10 + CIW -1 : 0]           m_x671_ppf1;
reg          [10 + CIW -1 : 0]           s_x946_ppf1;

wire signed  [10 + CIW -1 : 0]           l_x275_sgn;
wire signed  [11 + CIW -1 : 0]           m_x671_sgn;
wire signed  [11 + CIW -1 : 0]           s_x946_sgn;
wire signed  [SHIFT_BIT: 0]              cb_x2048_rnd_sgn;
wire signed  [26 : 0]                    cb_x2048_sgn;  //fix

wire signed  [U_SFT_MSB -1 : 0]          cb_x2048_sft_sgn;
wire                                     cb_x2048_bdy;


wire         [12 + CIW -1 : 0]           l_x2621_ppr0_nxt;
wire         [12 + CIW -1 : 0]           m_x2743_ppr0_nxt;
wire         [8  + CIW -1 : 0]           s_x122_ppr0_nxt;
reg         [12 + CIW -1 : 0]            l_x2621_ppr0;
reg         [12 + CIW -1 : 0]            m_x2743_ppr0;
reg         [8  + CIW -1 : 0]            s_x122_ppr0;

wire         [12 + CIW -1 : 0]           l_x2621_ppf1_nxt;
wire         [12 + CIW -1 : 0]           m_x2743_ppf1_nxt;
wire         [8  + CIW -1 : 0]           s_x122_ppf1_nxt;
reg          [12 + CIW -1 : 0]           l_x2621_ppf1;
reg          [12 + CIW -1 : 0]           m_x2743_ppf1;
reg          [8  + CIW -1 : 0]           s_x122_ppf1;

wire signed  [13 + CIW -1 : 0]           l_x2621_sgn;
wire signed  [13 + CIW -1 : 0]           m_x2743_sgn;
wire signed  [9  + CIW -1 : 0]           s_x122_sgn;
wire signed  [SHIFT_BIT : 0]             cr_x2048_rnd_sgn;
wire signed  [26 : 0]                    cr_x2048_sgn; //fix 

wire signed  [V_SFT_MSB -1 : 0]          cr_x2048_sft_sgn;
wire                                     cr_x2048_bdy;

//-------------------------------------------------------------------------------------------- output
reg          [QUE_TOL:0]                 out_que;
wire         [QUE_TOL:0]                 out_que_nxt;

wire         [COW -1 : 0]                o_data_y_nxt;
wire signed  [COW :0]                    o_data_cb_sgn_nxt;
reg  signed  [COW :0]                    o_data_cb_sgn;
wire signed  [COW :0]                    o_data_cr_sgn_nxt;
reg  signed  [COW :0]                    o_data_cr_sgn;

integer                                  i;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
// Pipeline stages


//-------------------------------------------------------------------------------------------- color convert
//In order to reduce the gate count, it must be divided into two parts

// 10 bit precision
// Y = 0.4736328125*L+ 0.462890625*M + 0.0634765625*S
// Y = (485/1024)*L+ (474/1024)*M + (65/1024)*S
// ---------------------------------------------------------

// PP-0

assign  i_data_l_ppf0_nxt     = i_data_l;
assign  i_data_m_ppf0_nxt     = i_data_m;
assign  i_data_s_ppf0_nxt     = i_data_s;

assign  l_x485_ppr0_nxt       = (i_data_l_ppf0 << 8) + (i_data_l_ppf0 << 7)    + (i_data_l_ppf0 << 6)   + (i_data_l_ppf0 << 5) + (i_data_l_ppf0 << 2) + i_data_l_ppf0;
assign  m_x474_ppr0_nxt       = (i_data_m_ppf0 << 8) + (i_data_m_ppf0 << 7)    + (i_data_m_ppf0 << 6)   + (i_data_m_ppf0 << 4) + (i_data_m_ppf0 << 3) + (i_data_m_ppf0 << 1);
assign  s_x65_ppr0_nxt        = (i_data_s_ppf0 << 6) + i_data_s_ppf0;

// PP-1
// ---------------------------

assign  l_x485_ppf1_nxt       = l_x485_ppr0;
assign  m_x474_ppf1_nxt       = m_x474_ppr0;
assign  s_x65_ppf1_nxt        = s_x65_ppr0;

assign  y_x2048_rnd           = {1'b1,{(SHIFT_BIT -1){1'b0}}};
assign  y_x2048               = (l_x485_ppf1 + m_x474_ppf1 + s_x65_ppf1 + y_x2048_rnd);

assign  y_x2048_sft           = y_x2048 >> SHIFT_BIT;

assign  y_x2048_bdy           = y_x2048_sft >= {COW{1'b1}};                                           //boundary

assign  o_data_y_nxt          = (y_x2048_bdy ? {COW{1'b1}} : y_x2048_sft[COW-1:0]);                   //0~255 //maybe overflow

// ---------------------------


// Cb = -0.2685546875*L+ -0.6552734375*M + 0.923828125*S
// Cb = (-275/1024)*L+ (-671/1024)*M + (946/1024)*S
// ---------------------------------------------------------

// PP-0
assign  l_x275_ppr0_nxt       = (i_data_l_ppf0 << 8) + (i_data_l_ppf0 << 4)   + (i_data_l_ppf0 << 1) + i_data_l_ppf0;
assign  m_x671_ppr0_nxt       = (i_data_m_ppf0 << 9) + (i_data_m_ppf0 << 7)   + (i_data_m_ppf0 << 5) - i_data_m_ppf0;
assign  s_x946_ppr0_nxt       = (i_data_s_ppf0 << 9) + (i_data_s_ppf0 << 8)   + (i_data_s_ppf0 << 7) + (i_data_s_ppf0 << 5) + (i_data_s_ppf0 << 4) + (i_data_s_ppf0 << 1);

// PP-1
// ---------------------------

assign  l_x275_ppf1_nxt       = l_x275_ppr0;
assign  m_x671_ppf1_nxt       = m_x671_ppr0;
assign  s_x946_ppf1_nxt       = s_x946_ppr0;

assign  l_x275_sgn            = $signed({1'b0,l_x275_ppf1});
assign  m_x671_sgn            = $signed({1'b0,m_x671_ppf1});
assign  s_x946_sgn            = $signed({1'b0,s_x946_ppf1});
assign  cb_x2048_rnd_sgn      = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});

assign  cb_x2048_sgn          = $signed(-l_x275_sgn - m_x671_sgn + s_x946_sgn + cb_x2048_rnd_sgn);

assign  cb_x2048_sft_sgn      = cb_x2048_sgn >>> SHIFT_BIT;

assign  cb_x2048_bdy          = $signed({cb_x2048_sft_sgn[U_SFT_MSB-1],1'b1})* cb_x2048_sft_sgn > $signed({1'b0,{(COW-1){1'b1}}});         //boundary
assign  o_data_cb_sgn_nxt     = (cb_x2048_bdy ? $signed({{2{cb_x2048_sft_sgn[U_SFT_MSB-1]}},{COW-1{!cb_x2048_sft_sgn[U_SFT_MSB-1]}}}) : cb_x2048_sft_sgn ) +
                                $signed({1'b0,YCBCR_POS,{COIW-1{1'b0}},{COPW{1'b0}}});

// ---------------------------

assign  o_data_cb             = o_data_cb_sgn;         //-128~127 or //0~255


// Cr = 2.5595703125*L+ -2.6787109375*M + 0.119140625*S
// Cr = (2621/1024)*L+ (-2743/1024)*M + (122/1024)*S
// ---------------------------------------------------------

assign  l_x2621_ppr0_nxt      = (i_data_l_ppf0 << 11) + (i_data_l_ppf0 << 9)    + (i_data_l_ppf0 << 6)   - (i_data_l_ppf0 << 1) - i_data_l_ppf0;
assign  m_x2743_ppr0_nxt      = (i_data_m_ppf0 << 11) + (i_data_m_ppf0 << 9)    + (i_data_m_ppf0 << 7)   + (i_data_m_ppf0 << 5) + (i_data_m_ppf0 << 4) + (i_data_m_ppf0 << 3) - i_data_m_ppf0;
assign  s_x122_ppr0_nxt       = (i_data_s_ppf0 << 7)  - (i_data_s_ppf0 << 2)    - (i_data_s_ppf0 << 1);

// PP-1
// ---------------------------

assign  l_x2621_ppf1_nxt      = l_x2621_ppr0;
assign  m_x2743_ppf1_nxt      = m_x2743_ppr0;
assign  s_x122_ppf1_nxt       = s_x122_ppr0;

assign  l_x2621_sgn           = $signed({1'b0,l_x2621_ppf1});
assign  m_x2743_sgn           = $signed({1'b0,m_x2743_ppf1});
assign  s_x122_sgn            = $signed({1'b0,s_x122_ppf1});
assign  cr_x2048_rnd_sgn      = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});

assign  cr_x2048_sgn          = $signed(l_x2621_sgn - m_x2743_sgn + s_x122_sgn + cr_x2048_rnd_sgn);

assign  cr_x2048_sft_sgn      = cr_x2048_sgn >>> SHIFT_BIT;

assign  cr_x2048_bdy          = $signed({cr_x2048_sft_sgn[V_SFT_MSB-1],1'b1})* cr_x2048_sft_sgn > $signed({1'b0,{(COW-1){1'b1}}});         //boundary
assign  o_data_cr_sgn_nxt     = (cr_x2048_bdy ? $signed({{2{cr_x2048_sft_sgn[V_SFT_MSB-1]}},{COW-1{!cr_x2048_sft_sgn[V_SFT_MSB-1]}}}) : cr_x2048_sft_sgn ) +
                                $signed({1'b0,YCBCR_POS,{COIW-1{1'b0}},{COPW{1'b0}}});

// ---------------------------

// F.F
assign  o_data_cr             = o_data_cr_sgn;         //-128~127 or //0~255


//-------------------------------------------------------------------------------------------- output
assign out_que_nxt            = {out_que[QUE_TOL:0] , i_hstr,i_href,i_hend};
assign o_hstr                 = out_que[QUE_TOL];
assign o_href                 = out_que[QUE_TOL-1];
assign o_hend                 = out_que[QUE_TOL-2];

always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        i_data_l_ppf0   <= 0;
        i_data_m_ppf0   <= 0;
        i_data_s_ppf0   <= 0;

        l_x485_ppr0     <= 0;
        m_x474_ppr0     <= 0;
        s_x65_ppr0      <= 0;
        l_x485_ppf1     <= 0;
        m_x474_ppf1     <= 0;
        s_x65_ppf1      <= 0;

        l_x275_ppr0     <= 0;
        m_x671_ppr0     <= 0;
        s_x946_ppr0     <= 0;
        l_x275_ppf1     <= 0;
        m_x671_ppf1     <= 0;
        s_x946_ppf1     <= 0;

        l_x2621_ppr0    <= 0;
        m_x2743_ppr0    <= 0;
        s_x122_ppr0     <= 0;
        l_x2621_ppf1    <= 0;
        m_x2743_ppf1    <= 0;
        s_x122_ppf1     <= 0;

//-------------------------------------------------------------------------------------------- output
        out_que         <= 0;
        o_data_y        <= 0;
        o_data_cb_sgn   <= 0;
        o_data_cr_sgn   <= 0;

    end
    else begin
        i_data_l_ppf0   <= i_data_l_ppf0_nxt;
        i_data_m_ppf0   <= i_data_m_ppf0_nxt;
        i_data_s_ppf0   <= i_data_s_ppf0_nxt;

        l_x485_ppr0     <= l_x485_ppr0_nxt;
        m_x474_ppr0     <= m_x474_ppr0_nxt;
        s_x65_ppr0      <= s_x65_ppr0_nxt;
        l_x485_ppf1     <= l_x485_ppf1_nxt;
        m_x474_ppf1     <= m_x474_ppf1_nxt;
        s_x65_ppf1      <= s_x65_ppf1_nxt;

        l_x275_ppr0     <= l_x275_ppr0_nxt;
        m_x671_ppr0     <= m_x671_ppr0_nxt;
        s_x946_ppr0     <= s_x946_ppr0_nxt;
        l_x275_ppf1     <= l_x275_ppf1_nxt;
        m_x671_ppf1     <= m_x671_ppf1_nxt;
        s_x946_ppf1     <= s_x946_ppf1_nxt;

        l_x2621_ppr0    <= l_x2621_ppr0_nxt;
        m_x2743_ppr0    <= m_x2743_ppr0_nxt;
        s_x122_ppr0     <= s_x122_ppr0_nxt;
        l_x2621_ppf1    <= l_x2621_ppf1_nxt;
        m_x2743_ppf1    <= m_x2743_ppf1_nxt;
        s_x122_ppf1     <= s_x122_ppf1_nxt;

//-------------------------------------------------------------------------------------------- output
        out_que         <= out_que_nxt;
        o_data_y        <= o_data_y_nxt;
        o_data_cb_sgn   <= o_data_cb_sgn_nxt;
        o_data_cr_sgn   <= o_data_cr_sgn_nxt;

    end
end
endmodule
