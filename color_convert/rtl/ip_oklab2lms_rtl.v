// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_oklab2lms.v
// Author:              1.Willy Lin
//                      2.Martin Chen 
//                      3.Humphrey Lin
// Version:             1.0
// Last Modified On:    2022/10/28
//
// File Description:    OKLAB to LMS Converter
// Abbreviations:
// Parameters:          PRECISION:       S 3.11
// Data precision :     input  : L     :   0.15
//                               AB    : S 0.13
//                               LMS   :   0.15
//                               mul_1 :   0.14
//                               mul_2 :   8.6
//                      outupt :           8.6
// Consuming time :     6T  
// -FHDR -----------------------------------------------------------------------

module ip_oklab2lms 
   #(
    parameter CIIW_L    = 0,                //LAB-L Accuracy Input Integer Width   //Accuracy can be reduced , but not improved 
    parameter CIPW_L    = 15,               //LAB-L Accuracy Input Point Width     //Accuracy can be reduced , but not improved 
    parameter CIIW_AB   = 1,                //LAB-AB Accuracy Input Integer Width  //Accuracy can be reduced , but not improved 
    parameter CIPW_AB   = 13,               //LAB-AB Accuracy Input Point Width    //Accuracy can be reduced , but not improved 
    parameter CIW_LMS   = 0,                //LMS Accuracy Input Integer Width     
    parameter CPW_LMS   = 15,               //LMS Accuracy Input Point Width       
    parameter CIW_L     = CIIW_L + CIPW_L,
    parameter CIW_AB    = CIIW_AB + CIPW_AB,
    parameter CIW_STG_1 = 0,                //stage1 multi Accuracy Integer Width  //Accuracy can be changed 
    parameter CPW_STG_1 = 14,               //stage1 multi Accuracy Point Width    //Accuracy can be changed 
    parameter COIW      = 8,                //LMS Accuracy Output Integer Width    //Accuracy can be reduced , but not improved 
    parameter COPW      = 6,                //LMS Accuracy Output Point Width      //Accuracy can be reduced , but not improved 
    parameter COW       = COIW + COPW
    )
(
    
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg   [COW-1:0]    o_data_l,
output reg   [COW-1:0]    o_data_m,
output reg   [COW-1:0]    o_data_s,
output                    o_hstr,
output                    o_hend,
output                    o_href,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input        [CIW_L-1:0]  i_data_l,
input signed [CIW_AB-1:0] i_data_a_sgn,
input signed [CIW_AB-1:0] i_data_b_sgn,
input                     i_hstr,
input                     i_hend,
input                     i_href,
input                     clk,
input                     rst_n
);

//----------------------------------------------//
// Local parameter                              //
//----------------------------------------------//
localparam          CIPW_LAB_FIX = (CIPW_L > CIPW_AB) ? CIPW_L : CIPW_AB;
localparam [4:0]    CW_LMS       = CIW_LMS + CPW_LMS;                        //total precision for lms
localparam [4:0]    SHIFT_BIT    = (11 + CIPW_LAB_FIX -CPW_LMS);             //CIPW_L and CIPW_AB will be fix

localparam [4:0]    CW_PART_1    = CIW_STG_1 + CPW_STG_1;                    //total precision for state1 multi

localparam [COW:0]  MAX_NUM      = (2**COW);

localparam [3:0]    QUE_NUM      = 6;
localparam [4:0]    QUE_TOL      = (QUE_NUM)*3-1;

localparam [2:0]    SHIFT_BIT_L  = CIPW_LAB_FIX - CIPW_L;
localparam [2:0]    SHIFT_BIT_AB = CIPW_LAB_FIX - CIPW_AB;

localparam          L_SFT_MSB    = 14 +CIW_L-SHIFT_BIT;
localparam          M_SFT_MSB    = 14 +CIW_AB-SHIFT_BIT;
localparam          S_SFT_MSB    = 15 +CIW_AB-SHIFT_BIT;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
//-------------------------------------------------------------------------------------------- common
reg         [CIW_L-1:0]                          i_data_l_q0;
reg  signed [CIW_AB-1:0]                         i_data_a_sgn_q0;
reg  signed [CIW_AB-1:0]                         i_data_b_sgn_q0;

//-------------------------------------------------------------------------------------------- color convert
reg         [12+CIPW_LAB_FIX+CIIW_L  -1: 0]      l_x2048_part_1;                   // CIPW_L and CIPW_AB will be fix
reg  signed [11+CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x812_sgn_part_1;
reg  signed [10+CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x442_sgn_part_1;
wire        [12+CIPW_LAB_FIX+CIIW_L  -1: 0]      l_x2048_part_1_nxt;               // CIPW_L and CIPW_AB will be fix
wire signed [11+CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x812_sgn_part_1_nxt;
wire signed [10+CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x442_sgn_part_1_nxt;
reg         [12+CIPW_LAB_FIX+CIIW_L  -1: 0]      l_x2048;                          // CIPW_L and CIPW_AB will be fix
wire        [12+CIPW_LAB_FIX+CIIW_L  -1: 0]      l_x2048_nxt;                      // CIPW_L and CIPW_AB will be fix
wire signed [13+CIPW_LAB_FIX+CIIW_L  -1: 0]      l_x2048_sgn;
reg  signed [11+CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x812_sgn;
reg  signed [10+CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x442_sgn;
wire signed [11+CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x812_sgn_nxt;
wire signed [10+CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x442_sgn_nxt;
wire signed [SHIFT_BIT:0]                        l_x2048_rnd_sgn;
reg  signed [L_SFT_MSB-1 :0]                     l_x2048_sft_sgn;
wire signed [L_SFT_MSB-1 :0]                     l_x2048_sft_sgn_nxt;
wire                                             l_x2048_bdy;

reg  signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x216_sgn_part_1;
reg  signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x131_sgn_part_1;
wire signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x216_sgn_part_1_nxt;
wire signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x131_sgn_part_1_nxt;
reg  signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x216_sgn;
reg  signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x131_sgn;
wire signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x216_sgn_nxt;
wire signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x131_sgn_nxt;
wire signed [SHIFT_BIT  :0]                      m_x2048_rnd_sgn;
reg  signed [M_SFT_MSB-1 :0]                     m_x2048_sft_sgn;
wire signed [M_SFT_MSB-1 :0]                     m_x2048_sft_sgn_nxt;
wire                                             m_x2048_bdy;

reg  signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x183_sgn_part_1;
reg  signed [13+CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x2645_sgn_part_1;
wire signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x183_sgn_part_1_nxt;
wire signed [13+CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x2645_sgn_part_1_nxt;
reg  signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x183_sgn;
reg  signed [13+CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x2645_sgn;
wire signed [9 +CIPW_LAB_FIX+CIIW_AB -1: 0]      a_x183_sgn_nxt;
wire signed [13+CIPW_LAB_FIX+CIIW_AB -1: 0]      b_x2645_sgn_nxt;
wire signed [SHIFT_BIT  :0]                      s_x2048_rnd_sgn;
reg  signed [S_SFT_MSB -1 :0]                    s_x2048_sft_sgn;
wire signed [S_SFT_MSB -1 :0]                    s_x2048_sft_sgn_nxt;
wire                                             s_x2048_bdy;

//-------------------------------------------------------------------------------------------- cubic calculation 
wire        [CPW_LMS*2-1 :0]                     stg_1_rnd;
wire        [CPW_STG_1+CPW_LMS-1 :0]             stg_2_rnd;

wire        [CW_LMS-1 :0]                        l_mul_stg_0_nxt;
wire        [CW_LMS-1 :0]                        m_mul_stg_0_nxt;
wire        [CW_LMS-1 :0]                        s_mul_stg_0_nxt;
reg         [CW_LMS-1 :0]                        l_mul_stg_0;
reg         [CW_LMS-1 :0]                        m_mul_stg_0;
reg         [CW_LMS-1 :0]                        s_mul_stg_0;
reg         [CW_LMS-1 :0]                        l_mul_stg_0_q;
reg         [CW_LMS-1 :0]                        m_mul_stg_0_q;
reg         [CW_LMS-1 :0]                        s_mul_stg_0_q;

wire        [CW_LMS+CW_LMS-1 :0]                 l_mul_part_1;
wire        [CW_LMS+CW_LMS-1 :0]                 m_mul_part_1;
wire        [CW_LMS+CW_LMS-1 :0]                 s_mul_part_1;

reg         [CW_PART_1-1 :0]                     l_mul_part_1_pt; 
reg         [CW_PART_1-1 :0]                     m_mul_part_1_pt; 
reg         [CW_PART_1-1 :0]                     s_mul_part_1_pt;

wire        [CW_PART_1-1 :0]                     l_mul_part_1_pt_nxt; 
wire        [CW_PART_1-1 :0]                     m_mul_part_1_pt_nxt; 
wire        [CW_PART_1-1 :0]                     s_mul_part_1_pt_nxt; 

wire        [CW_PART_1 +CW_LMS-1 :0]             l_mul; 
wire        [CW_PART_1 +CW_LMS-1 :0]             m_mul; 
wire        [CW_PART_1 +CW_LMS-1 :0]             s_mul; 

//-------------------------------------------------------------------------------------------- output
wire        [COW-1 :0]                           o_data_l_nxt; 
wire        [COW-1 :0]                           o_data_m_nxt; 
wire        [COW-1 :0]                           o_data_s_nxt; 

reg         [QUE_TOL:0]                          out_que;
wire        [QUE_TOL:0]                          out_que_nxt;
//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//-------------------------------------------------------------------------------------------- common


//-------------------------------------------------------------------------------------------- color convert
// 11 bit precision
// L = 1*L+ 0.396484375*a + 0.2158203125*b
// L = (2048/2048)*L+ (812/2048)*a + (442/2048)*b

assign  l_x2048_part_1_nxt     = (i_data_l <<(11 +SHIFT_BIT_L));
assign  a_x812_sgn_part_1_nxt  = (i_data_a_sgn <<(9 +SHIFT_BIT_AB)) + (i_data_a_sgn <<(8 +SHIFT_BIT_AB))    + (i_data_a_sgn <<(5 +SHIFT_BIT_AB));
assign  b_x442_sgn_part_1_nxt  = (i_data_b_sgn <<(8 +SHIFT_BIT_AB)) + (i_data_b_sgn <<(7 +SHIFT_BIT_AB))    + (i_data_b_sgn <<(5 +SHIFT_BIT_AB));

assign  l_x2048_nxt            = l_x2048_part_1;
assign  a_x812_sgn_nxt         = a_x812_sgn_part_1                  + (i_data_a_sgn_q0 <<(3 +SHIFT_BIT_AB)) + (i_data_a_sgn_q0 <<(2 +SHIFT_BIT_AB));
assign  b_x442_sgn_nxt         = b_x442_sgn_part_1                  + (i_data_b_sgn_q0 <<(4 +SHIFT_BIT_AB)) + (i_data_b_sgn_q0 <<(3 +SHIFT_BIT_AB)) + 
                                 (i_data_b_sgn_q0 <<(1 +SHIFT_BIT_AB));

assign  l_x2048_sgn            = $signed({1'b0,l_x2048});
assign  l_x2048_rnd_sgn        = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});
assign  l_x2048_sft_sgn_nxt    = $signed(l_x2048_sgn + a_x812_sgn + b_x442_sgn + l_x2048_rnd_sgn) >>> SHIFT_BIT;
assign  l_x2048_bdy            = l_x2048_sft_sgn > $unsigned({CW_LMS{!l_x2048_sft_sgn[L_SFT_MSB-1]}});                       //boundary //compare to msb 
assign  l_mul_stg_0_nxt        = (l_x2048_bdy ? {CW_LMS{!l_x2048_sft_sgn[L_SFT_MSB-1]}} : $unsigned(l_x2048_sft_sgn));       //0~255 //maybe overflow or underflow 
                    
// M = 1*L+ -0.10546875*a + -0.06396484375*b
// M = (2048/2048)*L+ (-216/2048)*a + (-131/2048)*b

assign  a_x216_sgn_part_1_nxt  = (i_data_a_sgn <<(7 +SHIFT_BIT_AB)) + (i_data_a_sgn <<(6 +SHIFT_BIT_AB));
assign  b_x131_sgn_part_1_nxt  = (i_data_b_sgn <<(7 +SHIFT_BIT_AB)) + (i_data_b_sgn <<(1 +SHIFT_BIT_AB));

assign  a_x216_sgn_nxt         = a_x216_sgn_part_1                  + (i_data_a_sgn_q0 <<(4 +SHIFT_BIT_AB)) + (i_data_a_sgn_q0 <<(3 +SHIFT_BIT_AB));
assign  b_x131_sgn_nxt         = b_x131_sgn_part_1                  + (i_data_b_sgn_q0 <<(SHIFT_BIT_AB)) ;

assign  m_x2048_rnd_sgn        = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});
assign  m_x2048_sft_sgn_nxt    = $signed(l_x2048_sgn - a_x216_sgn - b_x131_sgn + m_x2048_rnd_sgn) >>> SHIFT_BIT;
assign  m_x2048_bdy            = m_x2048_sft_sgn > $unsigned({CW_LMS{!m_x2048_sft_sgn[M_SFT_MSB-1]}});                       //boundary 
assign  m_mul_stg_0_nxt        = (m_x2048_bdy ? {CW_LMS{!m_x2048_sft_sgn[M_SFT_MSB-1]}} : $unsigned(m_x2048_sft_sgn));       //0~255 //maybe overflow or underflow 

// S = 1*L+ -0.08935546875*a + -1.29150390625*b
// S = (2048/2048)*L+ (-183/2048)*a + (-2645/2048)*b

assign  a_x183_sgn_part_1_nxt  = (i_data_a_sgn <<(7 +SHIFT_BIT_AB))  + (i_data_a_sgn <<(5 +SHIFT_BIT_AB))    + (i_data_a_sgn <<(4 +SHIFT_BIT_AB)) + (i_data_a_sgn <<(2 +SHIFT_BIT_AB));
assign  b_x2645_sgn_part_1_nxt = (i_data_b_sgn <<(11 +SHIFT_BIT_AB)) + (i_data_b_sgn <<(9 +SHIFT_BIT_AB))    + (i_data_b_sgn <<(6 +SHIFT_BIT_AB)) + (i_data_b_sgn <<(4 +SHIFT_BIT_AB));
  
assign  a_x183_sgn_nxt         = a_x183_sgn_part_1                   + (i_data_a_sgn_q0 <<(1 +SHIFT_BIT_AB)) + (i_data_a_sgn_q0 <<(SHIFT_BIT_AB));
assign  b_x2645_sgn_nxt        = b_x2645_sgn_part_1                  + (i_data_b_sgn_q0 <<(2 +SHIFT_BIT_AB)) + (i_data_b_sgn_q0 <<(SHIFT_BIT_AB));

assign  s_x2048_rnd_sgn        = $signed({1'b0,1'b1,{(SHIFT_BIT -1){1'b0}}});
assign  s_x2048_sft_sgn_nxt    = $signed(l_x2048_sgn - a_x183_sgn - b_x2645_sgn + s_x2048_rnd_sgn) >>> SHIFT_BIT;
assign  s_x2048_bdy            = s_x2048_sft_sgn > $unsigned({CW_LMS{!s_x2048_sft_sgn[S_SFT_MSB-1]}});                      //boundary 
assign  s_mul_stg_0_nxt        = (s_x2048_bdy ? {CW_LMS{!s_x2048_sft_sgn[S_SFT_MSB-1]}} : $unsigned(s_x2048_sft_sgn));      //0~255 //maybe overflow or underflow 

//-------------------------------------------------------------------------------------------- cubic calculation 
assign stg_1_rnd               = 1'b1 << (CPW_LMS*2-CPW_STG_1-1);
assign stg_2_rnd               = 1'b1 << (CPW_STG_1+CPW_LMS-COW-1); //COPW

assign l_mul_part_1            = l_mul_stg_0 * l_mul_stg_0 + stg_1_rnd; 
assign l_mul_part_1_pt_nxt     = l_mul_part_1[CW_LMS+CW_LMS-1 -: CW_PART_1]; //0.14
assign l_mul                   = l_mul_part_1_pt * l_mul_stg_0_q + stg_2_rnd;      
assign o_data_l_nxt            = l_mul[CW_PART_1 +CW_LMS-1 -: COW];   //0.14 //-2

assign m_mul_part_1            = m_mul_stg_0 * m_mul_stg_0 + stg_1_rnd; 
assign m_mul_part_1_pt_nxt     = m_mul_part_1[CW_LMS+CW_LMS-1 -: CW_PART_1]; //0.14
assign m_mul                   = m_mul_part_1_pt * m_mul_stg_0_q + stg_2_rnd;
assign o_data_m_nxt            = m_mul[CW_PART_1 +CW_LMS-1 -: COW];   //0.14 //-2

assign s_mul_part_1            = s_mul_stg_0 * s_mul_stg_0 + stg_1_rnd; 
assign s_mul_part_1_pt_nxt     = s_mul_part_1[CW_LMS+CW_LMS-1 -: CW_PART_1]; //0.14
assign s_mul                   = s_mul_part_1_pt * s_mul_stg_0_q + stg_2_rnd; 
assign o_data_s_nxt            = s_mul[CW_PART_1 +CW_LMS-1 -: COW];   //0.14 //-2

//-------------------------------------------------------------------------------------------- output 
assign out_que_nxt             = {out_que[QUE_TOL:0] , i_hstr,i_href,i_hend};
assign o_hstr                  = out_que[QUE_TOL];
assign o_href                  = out_que[QUE_TOL-1];
assign o_hend                  = out_que[QUE_TOL-2];

always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        i_data_l_q0        <= 0;
        i_data_a_sgn_q0    <= 0;
        i_data_b_sgn_q0    <= 0;

//-------------------------------------------------------------------------------------------- color convert
        l_x2048_part_1     <= 0;
        a_x812_sgn_part_1  <= 0;
        b_x442_sgn_part_1  <= 0;
        l_x2048            <= 0;
        a_x812_sgn         <= 0;
        b_x442_sgn         <= 0;

        a_x216_sgn_part_1  <= 0;
        b_x131_sgn_part_1  <= 0;
        a_x216_sgn         <= 0;
        b_x131_sgn         <= 0;
        
        a_x183_sgn_part_1  <= 0;
        b_x2645_sgn_part_1 <= 0;
        a_x183_sgn         <= 0;
        b_x2645_sgn        <= 0;
        
        l_x2048_sft_sgn    <= 0;
        m_x2048_sft_sgn    <= 0;
        s_x2048_sft_sgn    <= 0;
        
//-------------------------------------------------------------------------------------------- cubic calculation 
        l_mul_stg_0        <= 0;
        m_mul_stg_0        <= 0;
        s_mul_stg_0        <= 0;
        l_mul_stg_0_q      <= 0;
        m_mul_stg_0_q      <= 0;
        s_mul_stg_0_q      <= 0;    
        l_mul_part_1_pt    <= 0;
        m_mul_part_1_pt    <= 0;
        s_mul_part_1_pt    <= 0;
        
//-------------------------------------------------------------------------------------------- output
        o_data_l           <= 0;
        o_data_m           <= 0;
        o_data_s           <= 0;
        out_que            <= 0;

    end
    else begin
        i_data_l_q0        <= i_data_l;
        i_data_a_sgn_q0    <= i_data_a_sgn;
        i_data_b_sgn_q0    <= i_data_b_sgn;
        
//-------------------------------------------------------------------------------------------- color convert
        l_x2048_part_1     <= l_x2048_part_1_nxt;
        a_x812_sgn_part_1  <= a_x812_sgn_part_1_nxt;
        b_x442_sgn_part_1  <= b_x442_sgn_part_1_nxt; 
        l_x2048            <= l_x2048_nxt;
        a_x812_sgn         <= a_x812_sgn_nxt; 
        b_x442_sgn         <= b_x442_sgn_nxt; 

        a_x216_sgn_part_1  <= a_x216_sgn_part_1_nxt; 
        b_x131_sgn_part_1  <= b_x131_sgn_part_1_nxt; 
        a_x216_sgn         <= a_x216_sgn_nxt; 
        b_x131_sgn         <= b_x131_sgn_nxt; 
        
        a_x183_sgn_part_1  <= a_x183_sgn_part_1_nxt; 
        b_x2645_sgn_part_1 <= b_x2645_sgn_part_1_nxt;
        a_x183_sgn         <= a_x183_sgn_nxt; 
        b_x2645_sgn        <= b_x2645_sgn_nxt;

        l_x2048_sft_sgn    <= l_x2048_sft_sgn_nxt;
        m_x2048_sft_sgn    <= m_x2048_sft_sgn_nxt;
        s_x2048_sft_sgn    <= s_x2048_sft_sgn_nxt;
        
//-------------------------------------------------------------------------------------------- cubic calculation 
        l_mul_stg_0        <= l_mul_stg_0_nxt;
        m_mul_stg_0        <= m_mul_stg_0_nxt;
        s_mul_stg_0        <= s_mul_stg_0_nxt;
        l_mul_stg_0_q      <= l_mul_stg_0;
        m_mul_stg_0_q      <= m_mul_stg_0;
        s_mul_stg_0_q      <= s_mul_stg_0; 
        l_mul_part_1_pt    <= l_mul_part_1_pt_nxt;
        m_mul_part_1_pt    <= m_mul_part_1_pt_nxt;
        s_mul_part_1_pt    <= s_mul_part_1_pt_nxt;
        
//-------------------------------------------------------------------------------------------- output
        o_data_l           <= o_data_l_nxt;
        o_data_m           <= o_data_m_nxt;
        o_data_s           <= o_data_s_nxt;
        out_que            <= out_que_nxt;
        
    end
end
endmodule

