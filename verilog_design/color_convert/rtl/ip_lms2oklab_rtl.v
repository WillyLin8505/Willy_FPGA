// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_lms2oklab.v
// Author:              1.Willy Lin
//                      2.Martin Chen 
//                      3.Humphrey Lin
// Version:             1.0
// Last Modified On:    2022/10/28
//
// File Description:    LMS to OKLAB Converter
// Abbreviations:
// Parameters:          PRECISION:    S 3.11
// Data precision :     input  :        8.4
//                      outupt : L  :   0.15
//                               AB : S 0.13
// Consuming time :     5T  
// -FHDR -----------------------------------------------------------------------

module ip_lms2oklab 
    #(
    parameter CIIW    = 8,                  //Accuracy Input Integer Width         //Accuracy can not be changed                //sign bit are include
    parameter CIPW    = 4,                  //Accuracy Input Point Width           //Accuracy can not be changed
    parameter COIW_L  = 0,                  //LAB-L Accuracy Output Integer Width  //Accuracy can be reduced , but not improved //sign bit are include
    parameter COPW_L  = 15,                 //LAB-L Accuracy Output Point Width    //Accuracy can be reduced , but not improved 
    parameter COIW_AB = 1,                  //LAB-AB Accuracy Output Integer Width //Accuracy can be reduced , but not improved //sign bit are include
    parameter COPW_AB = 13,                 //LAB-AB Accuracy Output Integer Width //Accuracy can be reduced , but not improved 
    parameter CIW     = CIIW + CIPW,
    parameter COW_L   = COIW_L + COPW_L,
    parameter COW_AB  = COIW_AB + COPW_AB
    )
(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg         [COW_L-1:0]  o_data_l,
output reg signed  [COW_AB-1:0] o_data_a_sgn,
output reg signed  [COW_AB-1:0] o_data_b_sgn,
output                          o_hstr,
output                          o_hend,
output                          o_href,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input              [CIW-1:0]    i_data_l,
input              [CIW-1:0]    i_data_m,
input              [CIW-1:0]    i_data_s,
input                           i_hstr,
input                           i_hend,
input                           i_href,
input                           clk,
input                           rst_n
);

//----------------------------------------------//
// Local parameter                              //
//----------------------------------------------//
localparam [4:0] CW_CUBE      = 14;
localparam [4:0] CW_CUBE_EX   = 14;                        //lut precision 
localparam [4:0] SHIFT_BIT_L  = (11 + CW_CUBE -COPW_L );
localparam [4:0] SHIFT_BIT_A  = (11 + CW_CUBE -COPW_AB);
localparam [4:0] SHIFT_BIT_B  = (11 + CW_CUBE -COPW_AB);

localparam [3:0] QUE_NUM      = 5;
localparam [3:0] QUE_TOL      = (QUE_NUM)*3-1;

localparam       L_SFT_MSB    = 13 + CW_CUBE_EX-SHIFT_BIT_L;
localparam       A_SFT_MSB    = 15 + CW_CUBE_EX-SHIFT_BIT_A;
localparam       B_SFT_MSB    = 13 + CW_CUBE_EX-SHIFT_BIT_B;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
//-------------------------------------------------------------------------------------------- color space convert  
reg           [9  + CW_CUBE_EX-1 :0]             l_x431_part_1;
reg           [11 + CW_CUBE_EX-1 :0]             a_x1625_part_1;
reg           [4  + CW_CUBE_EX-1 :0]             b_x8_part_1;
wire          [9  + CW_CUBE_EX-1 :0]             l_x431_part_1_nxt;
wire          [11 + CW_CUBE_EX-1 :0]             a_x1625_part_1_nxt;
wire          [4  + CW_CUBE_EX-1 :0]             b_x8_part_1_nxt;
reg           [9  + CW_CUBE_EX-1 :0]             l_x431;
reg           [11 + CW_CUBE_EX-1 :0]             a_x1625;
reg           [4  + CW_CUBE_EX-1 :0]             b_x8;
wire          [9  + CW_CUBE_EX-1 :0]             l_x431_nxt;
wire          [11 + CW_CUBE_EX-1 :0]             a_x1625_nxt;
wire          [4  + CW_CUBE_EX-1 :0]             b_x8_nxt;
wire signed   [10  + CW_CUBE_EX-1 :0]            l_x431_sgn;
wire signed   [12 + CW_CUBE_EX-1 :0]             a_x1625_sgn;
wire signed   [5  + CW_CUBE_EX-1 :0]             b_x8_sgn;
wire signed   [SHIFT_BIT_L  :0]                  l_x32768_rnd_sgn;
reg  signed   [L_SFT_MSB -1 :0]                  l_x32768_sft_sgn;
wire signed   [L_SFT_MSB -1 :0]                  l_x32768_sft_sgn_nxt;
wire                                             l_x32768_bdy;
wire          [COW_L- 1:0]                       o_data_l_nxt;

reg           [12 + CW_CUBE_EX-1 :0]             l_x4051_part_1;
reg           [13 + CW_CUBE_EX-1 :0]             a_x4974_part_1;
reg           [10 + CW_CUBE_EX-1 :0]             b_x923_part_1;
wire          [12 + CW_CUBE_EX-1 :0]             l_x4051_part_1_nxt;
wire          [13 + CW_CUBE_EX-1 :0]             a_x4974_part_1_nxt;
wire          [10 + CW_CUBE_EX-1 :0]             b_x923_part_1_nxt;
reg           [12 + CW_CUBE_EX-1 :0]             l_x4051;
reg           [13 + CW_CUBE_EX-1 :0]             a_x4974;
reg           [10 + CW_CUBE_EX-1 :0]             b_x923;
wire          [12 + CW_CUBE_EX-1 :0]             l_x4051_nxt;
wire          [13 + CW_CUBE_EX-1 :0]             a_x4974_nxt;
wire          [10 + CW_CUBE_EX-1 :0]             b_x923_nxt;
wire signed   [13 + CW_CUBE_EX-1 :0]             l_x4051_sgn;
wire signed   [14 + CW_CUBE_EX-1 :0]             a_x4974_sgn;
wire signed   [11 + CW_CUBE_EX-1 :0]             b_x923_sgn;
wire signed   [SHIFT_BIT_A  :0]                  a_x32768_rnd_sgn;
reg  signed   [A_SFT_MSB -1 :0]                  a_x32768_sft_sgn;
wire signed   [A_SFT_MSB -1 :0]                  a_x32768_sft_sgn_nxt;
wire                                             a_x32768_bdy;
wire signed   [COW_AB-1 :0]                      o_data_a_sgn_nxt;

reg           [6  + CW_CUBE_EX-1 :0]             l_x53_part_1;
reg           [11 + CW_CUBE_EX-1 :0]             a_x1603_part_1;
reg           [11 + CW_CUBE_EX-1 :0]             b_x1656_part_1;
wire          [6  + CW_CUBE_EX-1 :0]             l_x53_part_1_nxt;
wire          [11 + CW_CUBE_EX-1 :0]             a_x1603_part_1_nxt;
wire          [11 + CW_CUBE_EX-1 :0]             b_x1656_part_1_nxt;
reg           [6  + CW_CUBE_EX-1 :0]             l_x53;
reg           [11 + CW_CUBE_EX-1 :0]             a_x1603;
reg           [11 + CW_CUBE_EX-1 :0]             b_x1656;
wire          [6  + CW_CUBE_EX-1 :0]             l_x53_nxt;
wire          [11 + CW_CUBE_EX-1 :0]             a_x1603_nxt;
wire          [11 + CW_CUBE_EX-1 :0]             b_x1656_nxt;
wire signed   [7  + CW_CUBE_EX-1 :0]             l_x53_sgn;
wire signed   [12 + CW_CUBE_EX-1 :0]             a_x1603_sgn;
wire signed   [12 + CW_CUBE_EX-1 :0]             b_x1656_sgn;
wire signed   [SHIFT_BIT_B  :0]                  b_x32768_rnd_sgn;
reg  signed   [B_SFT_MSB -1 :0]                  b_x32768_sft_sgn;
wire signed   [B_SFT_MSB -1 :0]                  b_x32768_sft_sgn_nxt;
wire                                             b_x32768_bdy;
wire signed   [COW_AB-1 :0]                      o_data_b_sgn_nxt;

//-------------------------------------------------------------------------------------------- lms2 cube root  
wire          [CW_CUBE-1:0]                      data_l2root;
wire          [CW_CUBE-1:0]                      data_m2root;
wire          [CW_CUBE-1:0]                      data_s2root;
reg           [CW_CUBE_EX-1:0]                   data_l2root_ex;
reg           [CW_CUBE_EX-1:0]                   data_m2root_ex;
reg           [CW_CUBE_EX-1:0]                   data_s2root_ex;
wire          [CW_CUBE_EX-1:0]                   data_l2root_ex_nxt;
wire          [CW_CUBE_EX-1:0]                   data_m2root_ex_nxt;
wire          [CW_CUBE_EX-1:0]                   data_s2root_ex_nxt;

//-------------------------------------------------------------------------------------------- output
reg           [QUE_TOL:0]                        out_que;
wire          [QUE_TOL:0]                        out_que_nxt;


//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

//-------------------------------------------------------------------------------------------- color space convert  
// 11 bit precision 
// L = 0.21044921875*L+ 0.79345703125*M + -0.00390625*S
// L = (431/32768)*L+ (1625/32768)*M + (-8/32768)*S

assign  l_x431_part_1_nxt    = (data_l2root_ex_nxt <<8)  + (data_l2root_ex_nxt <<7);
assign  a_x1625_part_1_nxt   = (data_m2root_ex_nxt <<10) + (data_m2root_ex_nxt <<9) + (data_m2root_ex_nxt <<6);
assign  b_x8_part_1_nxt      = (data_s2root_ex_nxt <<3);

assign  l_x431_nxt           = l_x431_part_1             + (data_l2root_ex <<5)     + (data_l2root_ex <<4)     - data_l2root_ex;
assign  a_x1625_nxt          = a_x1625_part_1            + (data_m2root_ex <<4)     + (data_m2root_ex <<3)     + data_m2root_ex;
assign  b_x8_nxt             = b_x8_part_1;

assign  l_x431_sgn           = $signed({1'b0,l_x431});
assign  a_x1625_sgn          = $signed({1'b0,a_x1625});
assign  b_x8_sgn             = $signed({1'b0,b_x8});
assign  l_x32768_rnd_sgn     = $signed({1'b0,1'b1,{(SHIFT_BIT_L -1){1'b0}}});

assign  l_x32768_sft_sgn_nxt = $signed(l_x431_sgn + a_x1625_sgn - b_x8_sgn + l_x32768_rnd_sgn) >>> SHIFT_BIT_L;
assign  l_x32768_bdy         = l_x32768_sft_sgn > $unsigned({COW_L{!l_x32768_sft_sgn[L_SFT_MSB-1]}}); //boundary 
assign  o_data_l_nxt         = (l_x32768_bdy ? {COW_L{!l_x32768_sft_sgn[L_SFT_MSB-1]}} : $unsigned(l_x32768_sft_sgn)); //range : 0~1 //maybe overflow or underflow 


// a = 1.97802734375*L+ -2.4287109375*M + 0.45068359375*S
// a = (4051/8192)*L+ (-4974/8192)*M + (923/8192)*S

assign  l_x4051_part_1_nxt   = (data_l2root_ex_nxt <<12) - (data_l2root_ex_nxt <<5) - (data_l2root_ex_nxt <<4);
assign  a_x4974_part_1_nxt   = (data_m2root_ex_nxt <<13) - (data_m2root_ex_nxt <<12)+ (data_m2root_ex_nxt <<10) ;
assign  b_x923_part_1_nxt    = (data_s2root_ex_nxt <<10) - (data_s2root_ex_nxt <<7) + (data_s2root_ex_nxt <<5) ;

assign  l_x4051_nxt          = l_x4051_part_1            + (data_l2root_ex <<1)     + data_l2root_ex;
assign  a_x4974_nxt          = a_x4974_part_1            - (data_m2root_ex <<7)     - (data_m2root_ex <<4)     - (data_m2root_ex <<1);
assign  b_x923_nxt           = b_x923_part_1             - (data_s2root_ex <<2)     - data_s2root_ex ;

assign  l_x4051_sgn          = $signed({1'b0,l_x4051});
assign  a_x4974_sgn          = $signed({1'b0,a_x4974});
assign  b_x923_sgn           = $signed({1'b0,b_x923});
assign  a_x32768_rnd_sgn     = $signed({1'b0,1'b1,{(SHIFT_BIT_A -1){1'b0}}});

assign  a_x32768_sft_sgn_nxt = $signed(l_x4051_sgn - a_x4974_sgn + b_x923_sgn + a_x32768_rnd_sgn) >>> SHIFT_BIT_A; 
assign  a_x32768_bdy         = $signed({a_x32768_sft_sgn[A_SFT_MSB-1],1'b1})* a_x32768_sft_sgn > $signed({1'b0,{(COW_AB-1){1'b1}}});         //boundary 
assign  o_data_a_sgn_nxt     = (a_x32768_bdy ? $signed({{2{a_x32768_sft_sgn[A_SFT_MSB-1]}},{COW_AB-1{!a_x32768_sft_sgn[A_SFT_MSB-1]}}}) : a_x32768_sft_sgn );

// b = 0.02587890625*L+ 0.78271484375*M + -0.80859375*S
// b = (53/2048)*L+ (1603/2048)*M + (-1656/2048)*S

assign  l_x53_part_1_nxt     = (data_l2root_ex_nxt <<5)  + (data_l2root_ex_nxt <<4);
assign  a_x1603_part_1_nxt   = (data_m2root_ex_nxt <<10) + (data_m2root_ex_nxt <<9) + (data_m2root_ex_nxt <<6);
assign  b_x1656_part_1_nxt   = (data_s2root_ex_nxt <<11) - (data_s2root_ex_nxt <<8);

assign  l_x53_nxt            = l_x53_part_1              + (data_l2root_ex <<2)     + data_l2root_ex;
assign  a_x1603_nxt          = a_x1603_part_1            + (data_m2root_ex <<1)     + data_m2root_ex;
assign  b_x1656_nxt          = b_x1656_part_1            - (data_s2root_ex <<7)     - (data_s2root_ex <<3);

assign  l_x53_sgn            = $signed({1'b0,l_x53});
assign  a_x1603_sgn          = $signed({1'b0,a_x1603});
assign  b_x1656_sgn          = $signed({1'b0,b_x1656});
assign  b_x32768_rnd_sgn     = $signed({1'b0,1'b1,{(SHIFT_BIT_B -1){1'b0}}});

assign  b_x32768_sft_sgn_nxt = $signed(l_x53_sgn + a_x1603_sgn - b_x1656_sgn + b_x32768_rnd_sgn) >>> SHIFT_BIT_B;
assign  b_x32768_bdy         = $signed({b_x32768_sft_sgn[B_SFT_MSB-1],1'b1})* b_x32768_sft_sgn > $signed({1'b0,{(COW_AB-1){1'b1}}});         //boundary 
assign  o_data_b_sgn_nxt     = (b_x32768_bdy ? $signed({{2{b_x32768_sft_sgn[B_SFT_MSB-1]}},{COW_AB-1{!b_x32768_sft_sgn[B_SFT_MSB-1]}}}) : b_x32768_sft_sgn );    
//-------------------------------------------------------------------------------------------- cube root 

assign data_l2root_ex_nxt    = data_l2root;
assign data_m2root_ex_nxt    = data_m2root;
assign data_s2root_ex_nxt    = data_s2root;

//-------------------------------------------------------------------------------------------- output
assign out_que_nxt           = {out_que[QUE_TOL:0] , i_hstr,i_href,i_hend}; 
assign o_hstr                = out_que[QUE_TOL];
assign o_href                = out_que[QUE_TOL-1];
assign o_hend                = out_que[QUE_TOL-2];

//================================================================================
//  module instantiation
//================================================================================

ip_cube_lut_12_14_ver2
ip_cube_lut_12_14_ver2_l(
    .o_data         ( data_l2root ),
    
    .i_data         ( i_data_l ),
    .clk            ( clk    ),
    .rst_n          ( rst_n  )
);

ip_cube_lut_12_14_ver2  
ip_cube_lut_12_14_ver2_m(
    .o_data         ( data_m2root ),
    
    .i_data         ( i_data_m ),
    .clk            ( clk    ),
    .rst_n          ( rst_n  )
);

ip_cube_lut_12_14_ver2
ip_cube_lut_12_14_ver2_s(
    .o_data         ( data_s2root ),
    
    .i_data         ( i_data_s ),
    .clk            ( clk    ),
    .rst_n          ( rst_n  )
);

always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
//-------------------------------------------------------------------------------------------- color space convert 
        data_l2root_ex   <= 0;
        data_m2root_ex   <= 0;
        data_s2root_ex   <= 0;
        l_x431_part_1    <= 0;
        a_x1625_part_1   <= 0;
        b_x8_part_1      <= 0;
        l_x431           <= 0;
        a_x1625          <= 0;
        b_x8             <= 0;
        l_x4051_part_1   <= 0;
        a_x4974_part_1   <= 0;
        b_x923_part_1    <= 0;
        l_x4051          <= 0;
        a_x4974          <= 0;
        b_x923           <= 0;
        l_x53_part_1     <= 0;
        a_x1603_part_1   <= 0;
        b_x1656_part_1   <= 0;
        l_x53            <= 0;
        a_x1603          <= 0;
        b_x1656          <= 0;
        l_x32768_sft_sgn <= 0;
        a_x32768_sft_sgn <= 0;
        b_x32768_sft_sgn <= 0;
//-------------------------------------------------------------------------------------------- output
        out_que          <= 0;
        o_data_l         <= 0;
        o_data_a_sgn     <= 0;
        o_data_b_sgn     <= 0;
        
    end
    else begin
//-------------------------------------------------------------------------------------------- color space convert 
        data_l2root_ex   <= data_l2root_ex_nxt;
        data_m2root_ex   <= data_m2root_ex_nxt;
        data_s2root_ex   <= data_s2root_ex_nxt;
        l_x431_part_1    <= l_x431_part_1_nxt;
        a_x1625_part_1   <= a_x1625_part_1_nxt;
        b_x8_part_1      <= b_x8_part_1_nxt;
        l_x431           <= l_x431_nxt;
        a_x1625          <= a_x1625_nxt;
        b_x8             <= b_x8_nxt;
        l_x4051_part_1   <= l_x4051_part_1_nxt;
        a_x4974_part_1   <= a_x4974_part_1_nxt;
        b_x923_part_1    <= b_x923_part_1_nxt;
        l_x4051          <= l_x4051_nxt;
        a_x4974          <= a_x4974_nxt;
        b_x923           <= b_x923_nxt;
        l_x53_part_1     <= l_x53_part_1_nxt;
        a_x1603_part_1   <= a_x1603_part_1_nxt;
        b_x1656_part_1   <= b_x1656_part_1_nxt;
        l_x53            <= l_x53_nxt;
        a_x1603          <= a_x1603_nxt;
        b_x1656          <= b_x1656_nxt;
        l_x32768_sft_sgn <= l_x32768_sft_sgn_nxt;
        a_x32768_sft_sgn <= a_x32768_sft_sgn_nxt;
        b_x32768_sft_sgn <= b_x32768_sft_sgn_nxt;
//-------------------------------------------------------------------------------------------- output
        out_que          <= out_que_nxt;
        o_data_l         <= o_data_l_nxt;
        o_data_a_sgn     <= o_data_a_sgn_nxt;
        o_data_b_sgn     <= o_data_b_sgn_nxt;
    end
end
endmodule

