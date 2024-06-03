// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           
// Author:              Willy Lin
// Version:             1.0
// Date:                2022
// Last Modified On:    
// Last Modified By:    $Author$
// limitation : 
//                      verified maximum input accuracy of 8.4
// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------

module bil_ftr_ver2
   #( 
      parameter  CIIW         = 8,
      parameter  CIPW         = 0,
      parameter  KRNV_SZ      = 5,
      parameter  KRNH_SZ      = 5,
      parameter  ODATA_RNG    = 5,
      parameter  COIW         = 8,               //Accuracy Output Integer Width    //Accuracy can be reduced , but not improved 
      parameter  COPW         = 0,               //Accuracy Output Point Width      //Accuracy can be reduced , but not improved 
      parameter  CIW          = CIIW + CIPW +1,  //for signed bit 
      parameter  COW          = COIW + COPW +1,   //for signed bit
      parameter  SIGN_EN      = 1'b0 
     )

(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg signed [COW-1:0] o_cv_data_sgn,
output reg                  o_cv_dvld,
output reg                  o_cv_vstr,
output reg                  o_cv_hstr,
output reg                  o_cv_hend,
output reg                  o_cv_vend,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input [(CIIW+CIPW)*KRNV_SZ*ODATA_RNG-1:0] i_data, //need to extension signed bit before input data 

input                    i_fstr,
input                    i_hstr,
input                    i_hend,
input                    i_href,
input                    i_vstr,
input                    i_vend,

input      [4:0]         r_bf_sigma_r, 
input                    r_bf_ofst_r,
input      [1:0]         r_bf_op_mode, 
input                    r_sigma_s_sel, 

input                    clk,
input                    rst_n
);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//
//-------------------------------------------------------------------width  
localparam                               KRNV_SZ_WTH   = $clog2(KRNV_SZ);
localparam                               KRNH_SZ_WTH   = $clog2(KRNH_SZ);
localparam                               RECIP_COW     = 14;

//------------------------------------------------------------------pipe 0 
localparam [KRNV_SZ_WTH-1:0]             KRNV_SZ_MID   = (KRNV_SZ >> 1);
localparam [KRNH_SZ_WTH-1:0]             KRNH_SZ_MID   = (KRNH_SZ >> 1);
localparam [KRNV_SZ_WTH+KRNH_SZ_WTH:0]   KERNEL_NUM    = (KRNV_SZ * KRNH_SZ);
localparam [KRNV_SZ_WTH+KRNH_SZ_WTH-1:0] KERNEL_SHIFT  = KERNEL_NUM >>1;
localparam                               GROUP_NUM     = (KERNEL_NUM ==5'd25) ? 7 : (KERNEL_NUM ==5'd15) ? 6 : (KERNEL_NUM ==5'd9) ? 3 : 10; 
localparam                               KERNEL_TOTAL  = GROUP_NUM << 2;
localparam [0:0]                         PIPE_0_RND    = (CIPW > 0) ? 1'b1 : 1'b0;

//-------------------------------------------------------------------dly
localparam                               DIFF_DLY      = 2'd2;                    //delta x dff delay     //pipe 0 + pipe 1 
localparam                               FILTER_DLY    = 1'd1;                    
localparam                               CONV_DLY      = (KRNH_SZ == 5) ? 2'd2 : 2'd2;      
localparam                               RECIP_DLY     = 2'd2;                    //wait for recip ip (2T)  
localparam                               RECIP_OUT     = 1'd1;                    

//-------------------------------------------------------------------control and constance 
localparam [3:0]                         CNVL_PRE_NUM  = DIFF_DLY   +              //delta x dff delay     //pipe 0 + pipe 1 
                                                         CONV_DLY   +              //convolution           //dff output 
                                                         FILTER_DLY + 
                                                         RECIP_DLY  + 
                                                         RECIP_OUT  -              //wait for recip ip (2T)  
                                                         1'd1; 

//-------------------------------------------------------------------width 2
localparam                               KERNEL_WTH       = $clog2(KERNEL_NUM);
localparam                               FILTER_WTH       = 8;                        // precision : 0.8 
localparam                               CONV_TOL_WTH     = FILTER_WTH+KERNEL_WTH+CIW;

//------------------------------------------------------------------convolution 
localparam                               HOR_MAX          = 5;
localparam                               VER_MAX          = 5;
localparam                               HOR_DIFF         = (HOR_MAX - KRNH_SZ) >> 1;
localparam                               VER_DIFF         = (VER_MAX - KRNV_SZ) >> 1;
localparam                               CONV_PART_WTH    = 11 + CIPW +1;  //reduce bit before data_conv_que_sgn*flt_recip + signed
localparam                               CONV_PART_WTH_10 = ((CONV_TOL_WTH-10) > (11 + CIPW)) ? 11 + CIPW : CONV_TOL_WTH-10;    //reduce bit before data_conv_que_sgn*flt_recip
localparam [VER_MAX*VER_MAX*HOR_MAX-1:0] KERNEL_TABLE     = {5'd27,5'd23,5'd15,5'd22,5'd26,
                                                             5'd21,5'd11,5'd7 ,5'd10,5'd20,
                                                             5'd14,5'd6 ,5'd0 ,5'd5 ,5'd13,
                                                             5'd19,5'd9 ,5'd4 ,5'd8 ,5'd18,
                                                             5'd25,5'd17,5'd12,5'd16,5'd24};
localparam                               CONV_PART_RND_10 = ((FILTER_WTH + CIPW) - 10 > 0) ? (FILTER_WTH + CIPW) - 4'd10 : 4'd0; //all float point number is removed by prcis_idx

//-------------------------------------------------------------------weight
localparam [FILTER_WTH-1:0]     FILTER_0_0_0    = 8'd9;
localparam [FILTER_WTH-1:0]     FILTER_0_0_1    = 8'd7;
localparam [FILTER_WTH-1:0]     FILTER_0_0_2    = 8'd6;
localparam [FILTER_WTH-1:0]     FILTER_0_0_3    = 8'd4;
localparam [FILTER_WTH-1:0]     FILTER_0_0_4    = 8'd3;
localparam [FILTER_WTH-1:0]     FILTER_0_0_5    = 8'd1;
localparam [FILTER_WTH-1:0]     FILTER_0_0_6    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_0_0_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_0_1_0    = 8'd29;
localparam [FILTER_WTH-1:0]     FILTER_0_1_1    = 8'd24;
localparam [FILTER_WTH-1:0]     FILTER_0_1_2    = 8'd19;
localparam [FILTER_WTH-1:0]     FILTER_0_1_3    = 8'd14;
localparam [FILTER_WTH-1:0]     FILTER_0_1_4    = 8'd9;
localparam [FILTER_WTH-1:0]     FILTER_0_1_5    = 8'd4;
localparam [FILTER_WTH-1:0]     FILTER_0_1_6    = 8'd1;
localparam [FILTER_WTH-1:0]     FILTER_0_1_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_0_2_0    = 8'd29;
localparam [FILTER_WTH-1:0]     FILTER_0_2_1    = 8'd24;
localparam [FILTER_WTH-1:0]     FILTER_0_2_2    = 8'd19;
localparam [FILTER_WTH-1:0]     FILTER_0_2_3    = 8'd14;
localparam [FILTER_WTH-1:0]     FILTER_0_2_4    = 8'd9;
localparam [FILTER_WTH-1:0]     FILTER_0_2_5    = 8'd4;
localparam [FILTER_WTH-1:0]     FILTER_0_2_6    = 8'd1;
localparam [FILTER_WTH-1:0]     FILTER_0_2_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_0_3_0    = 8'd45;
localparam [FILTER_WTH-1:0]     FILTER_0_3_1    = 8'd37;
localparam [FILTER_WTH-1:0]     FILTER_0_3_2    = 8'd29;
localparam [FILTER_WTH-1:0]     FILTER_0_3_3    = 8'd21;
localparam [FILTER_WTH-1:0]     FILTER_0_3_4    = 8'd13;
localparam [FILTER_WTH-1:0]     FILTER_0_3_5    = 8'd7;
localparam [FILTER_WTH-1:0]     FILTER_0_3_6    = 8'd2;
localparam [FILTER_WTH-1:0]     FILTER_0_3_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_0_4_0    = 8'd102;
localparam [FILTER_WTH-1:0]     FILTER_0_4_1    = 8'd85;
localparam [FILTER_WTH-1:0]     FILTER_0_4_2    = 8'd66;
localparam [FILTER_WTH-1:0]     FILTER_0_4_3    = 8'd47;
localparam [FILTER_WTH-1:0]     FILTER_0_4_4    = 8'd30;
localparam [FILTER_WTH-1:0]     FILTER_0_4_5    = 8'd15;
localparam [FILTER_WTH-1:0]     FILTER_0_4_6    = 8'd5;
localparam [FILTER_WTH-1:0]     FILTER_0_4_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_0_5_0    = 8'd154;
localparam [FILTER_WTH-1:0]     FILTER_0_5_1    = 8'd128;
localparam [FILTER_WTH-1:0]     FILTER_0_5_2    = 8'd100;
localparam [FILTER_WTH-1:0]     FILTER_0_5_3    = 8'd72;
localparam [FILTER_WTH-1:0]     FILTER_0_5_4    = 8'd45;
localparam [FILTER_WTH-1:0]     FILTER_0_5_5    = 8'd23;
localparam [FILTER_WTH-1:0]     FILTER_0_5_6    = 8'd7;
localparam [FILTER_WTH-1:0]     FILTER_0_5_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_0_6_0    = 8'd233;
localparam [FILTER_WTH-1:0]     FILTER_0_6_1    = 8'd193;
localparam [FILTER_WTH-1:0]     FILTER_0_6_2    = 8'd150;
localparam [FILTER_WTH-1:0]     FILTER_0_6_3    = 8'd108;
localparam [FILTER_WTH-1:0]     FILTER_0_6_4    = 8'd68;
localparam [FILTER_WTH-1:0]     FILTER_0_6_5    = 8'd35;
localparam [FILTER_WTH-1:0]     FILTER_0_6_6    = 8'd11;
localparam [FILTER_WTH-1:0]     FILTER_0_6_7    = 8'd0;

localparam [FILTER_WTH-1:0]     FILTER_1_0_0    = 8'd9;
localparam [FILTER_WTH-1:0]     FILTER_1_0_1    = 8'd7;
localparam [FILTER_WTH-1:0]     FILTER_1_0_2    = 8'd6;
localparam [FILTER_WTH-1:0]     FILTER_1_0_3    = 8'd4;
localparam [FILTER_WTH-1:0]     FILTER_1_0_4    = 8'd3;
localparam [FILTER_WTH-1:0]     FILTER_1_0_5    = 8'd1;
localparam [FILTER_WTH-1:0]     FILTER_1_0_6    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_1_0_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_1_1_0    = 8'd176;
localparam [FILTER_WTH-1:0]     FILTER_1_1_1    = 8'd146;
localparam [FILTER_WTH-1:0]     FILTER_1_1_2    = 8'd114;
localparam [FILTER_WTH-1:0]     FILTER_1_1_3    = 8'd82;
localparam [FILTER_WTH-1:0]     FILTER_1_1_4    = 8'd52;
localparam [FILTER_WTH-1:0]     FILTER_1_1_5    = 8'd26;
localparam [FILTER_WTH-1:0]     FILTER_1_1_6    = 8'd9;
localparam [FILTER_WTH-1:0]     FILTER_1_1_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_1_2_0    = 8'd176;
localparam [FILTER_WTH-1:0]     FILTER_1_2_1    = 8'd146;
localparam [FILTER_WTH-1:0]     FILTER_1_2_2    = 8'd114;
localparam [FILTER_WTH-1:0]     FILTER_1_2_3    = 8'd82;
localparam [FILTER_WTH-1:0]     FILTER_1_2_4    = 8'd52;
localparam [FILTER_WTH-1:0]     FILTER_1_2_5    = 8'd26;
localparam [FILTER_WTH-1:0]     FILTER_1_2_6    = 8'd9;
localparam [FILTER_WTH-1:0]     FILTER_1_2_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_1_3_0    = 8'd186;
localparam [FILTER_WTH-1:0]     FILTER_1_3_1    = 8'd155;
localparam [FILTER_WTH-1:0]     FILTER_1_3_2    = 8'd120;
localparam [FILTER_WTH-1:0]     FILTER_1_3_3    = 8'd87;
localparam [FILTER_WTH-1:0]     FILTER_1_3_4    = 8'd55;
localparam [FILTER_WTH-1:0]     FILTER_1_3_5    = 8'd28;
localparam [FILTER_WTH-1:0]     FILTER_1_3_6    = 8'd9;
localparam [FILTER_WTH-1:0]     FILTER_1_3_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_1_4_0    = 8'd208;
localparam [FILTER_WTH-1:0]     FILTER_1_4_1    = 8'd173;
localparam [FILTER_WTH-1:0]     FILTER_1_4_2    = 8'd135;
localparam [FILTER_WTH-1:0]     FILTER_1_4_3    = 8'd97;
localparam [FILTER_WTH-1:0]     FILTER_1_4_4    = 8'd61;
localparam [FILTER_WTH-1:0]     FILTER_1_4_5    = 8'd31;
localparam [FILTER_WTH-1:0]     FILTER_1_4_6    = 8'd10;
localparam [FILTER_WTH-1:0]     FILTER_1_4_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_1_5_0    = 8'd220;
localparam [FILTER_WTH-1:0]     FILTER_1_5_1    = 8'd183;
localparam [FILTER_WTH-1:0]     FILTER_1_5_2    = 8'd142;
localparam [FILTER_WTH-1:0]     FILTER_1_5_3    = 8'd102;
localparam [FILTER_WTH-1:0]     FILTER_1_5_4    = 8'd65;
localparam [FILTER_WTH-1:0]     FILTER_1_5_5    = 8'd33;
localparam [FILTER_WTH-1:0]     FILTER_1_5_6    = 8'd11;
localparam [FILTER_WTH-1:0]     FILTER_1_5_7    = 8'd0;
localparam [FILTER_WTH-1:0]     FILTER_1_6_0    = 8'd233;
localparam [FILTER_WTH-1:0]     FILTER_1_6_1    = 8'd193;
localparam [FILTER_WTH-1:0]     FILTER_1_6_2    = 8'd150;
localparam [FILTER_WTH-1:0]     FILTER_1_6_3    = 8'd108;
localparam [FILTER_WTH-1:0]     FILTER_1_6_4    = 8'd68;
localparam [FILTER_WTH-1:0]     FILTER_1_6_5    = 8'd35;
localparam [FILTER_WTH-1:0]     FILTER_1_6_6    = 8'd11;
localparam [FILTER_WTH-1:0]     FILTER_1_6_7    = 8'd0;

localparam [FILTER_WTH*56-1:0] FILTER_WHT_0   = {FILTER_0_0_0,FILTER_0_0_1,FILTER_0_0_2,FILTER_0_0_3,FILTER_0_0_4,FILTER_0_0_5,FILTER_0_0_6,FILTER_0_0_7,
                                                 FILTER_0_1_0,FILTER_0_1_1,FILTER_0_1_2,FILTER_0_1_3,FILTER_0_1_4,FILTER_0_1_5,FILTER_0_1_6,FILTER_0_1_7,
                                                 FILTER_0_2_0,FILTER_0_2_1,FILTER_0_2_2,FILTER_0_2_3,FILTER_0_2_4,FILTER_0_2_5,FILTER_0_2_6,FILTER_0_2_7,
                                                 FILTER_0_3_0,FILTER_0_3_1,FILTER_0_3_2,FILTER_0_3_3,FILTER_0_3_4,FILTER_0_3_5,FILTER_0_3_6,FILTER_0_3_7,
                                                 FILTER_0_4_0,FILTER_0_4_1,FILTER_0_4_2,FILTER_0_4_3,FILTER_0_4_4,FILTER_0_4_5,FILTER_0_4_6,FILTER_0_4_7,
                                                 FILTER_0_5_0,FILTER_0_5_1,FILTER_0_5_2,FILTER_0_5_3,FILTER_0_5_4,FILTER_0_5_5,FILTER_0_5_6,FILTER_0_5_7,
                                                 FILTER_0_6_0,FILTER_0_6_1,FILTER_0_6_2,FILTER_0_6_3,FILTER_0_6_4,FILTER_0_6_5,FILTER_0_6_6,FILTER_0_6_7};

localparam [FILTER_WTH*56-1:0] FILTER_WHT_1   = {FILTER_1_0_0,FILTER_1_0_1,FILTER_1_0_2,FILTER_1_0_3,FILTER_1_0_4,FILTER_1_0_5,FILTER_1_0_6,FILTER_1_0_7,
                                                 FILTER_1_1_0,FILTER_1_1_1,FILTER_1_1_2,FILTER_1_1_3,FILTER_1_1_4,FILTER_1_1_5,FILTER_1_1_6,FILTER_1_1_7,
                                                 FILTER_1_2_0,FILTER_1_2_1,FILTER_1_2_2,FILTER_1_2_3,FILTER_1_2_4,FILTER_1_2_5,FILTER_1_2_6,FILTER_1_2_7,
                                                 FILTER_1_3_0,FILTER_1_3_1,FILTER_1_3_2,FILTER_1_3_3,FILTER_1_3_4,FILTER_1_3_5,FILTER_1_3_6,FILTER_1_3_7,
                                                 FILTER_1_4_0,FILTER_1_4_1,FILTER_1_4_2,FILTER_1_4_3,FILTER_1_4_4,FILTER_1_4_5,FILTER_1_4_6,FILTER_1_4_7,
                                                 FILTER_1_5_0,FILTER_1_5_1,FILTER_1_5_2,FILTER_1_5_3,FILTER_1_5_4,FILTER_1_5_5,FILTER_1_5_6,FILTER_1_5_7,
                                                 FILTER_1_6_0,FILTER_1_6_1,FILTER_1_6_2,FILTER_1_6_3,FILTER_1_6_4,FILTER_1_6_5,FILTER_1_6_6,FILTER_1_6_7};

localparam [4*6-1:0]               SFT_TABLE  = {4'd10,4'd8,4'd6,4'd4,4'd2,4'd1};

//-------------------------------------------------------------------delta x interval
localparam [6:0]     DELTA_X_0       = 20; 
localparam [6:0]     DELTA_X_1       = 29; 
localparam [6:0]     DELTA_X_2       = 38; 
localparam [6:0]     DELTA_X_3       = 47; 
localparam [6:0]     DELTA_X_4       = 58; 
localparam [6:0]     DELTA_X_5       = 71; 
localparam [6:0]     DELTA_X_6       = 89; 

localparam [7*7-1:0] DELTA_X         = {DELTA_X_0,DELTA_X_1,DELTA_X_2,DELTA_X_3,DELTA_X_4,DELTA_X_5,DELTA_X_6};    
//-------------------------------------------------------------------recip ip 
localparam           PRCIS_EXT       = "LVL_2";    // "LVL_0"/"LVL_1"/"LVL_2"
localparam [11:0]    DENM_ZERO       = 12'h0;      // output value definition, if denominator == 0

//-------------------------------------------------------------------FSM
localparam [3:0]     BIL_IDLE        = 4'b0001;
localparam [3:0]     BIL_DELTA_X_CNT = 4'b0010;
localparam [3:0]     BIL_CNVL        = 4'b0100;
localparam [3:0]     BIL_OUT_EN      = 4'b1000;

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
//-------------------------------------------------------------------input data convert to 2 dimation 
wire signed [CIW-1:0]                     i_data_array_sgn       [0:KRNV_SZ*ODATA_RNG-1];
reg  signed [CIW-1:0]                     i_data_array_d0_sgn    [0:KRNV_SZ*ODATA_RNG-1];
reg  signed [CIW-1:0]                     i_data_array_d1_sgn    [0:KRNV_SZ*ODATA_RNG-1];
reg  signed [CIW-1:0]                     i_data_array_ppf1_sgn  [0:KRNV_SZ*ODATA_RNG-1];
reg  signed [CIW-1:0]                     i_data_array_ppf2_sgn  [0:KRNV_SZ*ODATA_RNG-1];

//-------------------------------------------------------------------control and constance 

wire        [3:0]                         pixel_num;
wire                                      filter_eq_ker;
wire                                      filter_eq_hstr;
wire                                      filter_eq_hend;
wire                                      filter_eq_vstr;

wire        [3:0]                         filter_cnt_nxt;
reg         [3:0]                         filter_cnt;
wire                                      filter_cnt_inc;
wirq                                      filter_cnt_clr;

//-------------------------------------------------------------------delta x 
wire        [6:0]                         delta_x_lut                  [0:6];
wire        [8*7-1:0]                     delta_x_sigma_r_lut_nxt;                        //5(r_bf_sigma_r) * 3.5(delta_x_lut) => unconditional carry to 8 bit
reg         [8*7-1:0]                     delta_x_sigma_r_lut ;
wire        [12:0]                        delta_x_sigma_r;
wire        [12:0]                        delta_x_sigma_r_rnd;
wire signed [CIW-1:0]                     delta_x_sgn                  [0:KRNH_SZ*KRNV_SZ-1];
wire        [CIW-1:0]                     delta_x                      [0:KERNEL_NUM-1];

//-------------------------------------------------------------------pipe 0 
wire        [CIW:0]                       weight_dis_group             [0:KERNEL_TOTAL-1];

reg                                       delta_x_sgn_bit              [0:KERNEL_NUM-1];
wire                                      delta_x_sgn_bit_nxt          [0:KERNEL_NUM-1];
reg         [CIW-1:0]                     delta_x_rnd                  [0:KERNEL_NUM-1];
wire        [CIW-1:0]                     delta_x_rnd_nxt              [0:KERNEL_NUM-1];

wire                                      comp_delta_x_0               [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ 
wire        [7:0]                         delta_x_sel_0                [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
wire                                      comp_delta_x_1               [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
wire        [7:0]                         delta_x_sel_1                [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
wire                                      comp_delta_x_2               [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ

wire        [3:0]                         comp_delta_x_nxt             [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
reg         [3:0]                         comp_delta_x                 [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
wire                                      comp_delta_x_zero            [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ

wire                                      comp_sign_bit_nxt            [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
reg                                       comp_sign_bit                [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ

wire        [7:0]                         delta_lut_0                  [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
wire        [7:0]                         delta_lut_1                  [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
wire                                      comp_delta_x_1_lsb           [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
wire                                      comp_delta_x_1_msb           [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
wire                                      comp_delta_x_2_lsb           [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ
wire                                      comp_delta_x_2_msb           [0:KERNEL_TOTAL-1]; //KERNEL_NUM + KRNH_SZ


//------------------------------------------------------------------- get kernel weight 
reg         [FILTER_WTH*8-1:0]            ker_weight_0_lut             [0:GROUP_NUM-1];
reg         [FILTER_WTH*8-1:0]            ker_weight_1_lut             [0:GROUP_NUM-1];
reg         [FILTER_WTH*8-1:0]            ker_weight_lut               [0:GROUP_NUM-1];
reg         [FILTER_WTH-1:0]              filter_x                     [0:KERNEL_TOTAL-1];
reg         [FILTER_WTH-1:0]              filter_x_out                 [0:KERNEL_TOTAL-1];

//----------------------------------------------------------------------convolution
reg  signed [FILTER_WTH  :0]              flt_weight_ppf0              [0:KERNEL_NUM-1];   //precision : 0.8
reg  signed [FILTER_WTH  :0]              flt_weight_ppf1              [0:KERNEL_NUM-1];   //precision : 0.8
wire signed [FILTER_WTH  :0]              flt_weight_d0_nxt            [0:KERNEL_NUM-1];   //precision : 0.8
reg  signed [FILTER_WTH  :0]              flt_weight_d0                [0:KERNEL_NUM-1];   //precision : 0.8

wire signed [CONV_TOL_WTH-1:0]            data_conv_ppr0_sgn_nxt;        //input 8 bit  -> : precision : 12.8 . 
                                                                         //input 8.4bit -> : precision : 13.12 
reg  signed [CONV_TOL_WTH-1:0]            data_conv_ppr0_sgn;            //input 8 bit  -> : precision : 12.8 . 
                                                                         //input 8.4bit -> : precision : 13.12 
reg  signed [CONV_TOL_WTH-1:0]            data_conv_d1_sgn;              //input 8 bit  -> : precision : 12.8 . 
                                                                         //input 8.4bit -> : precision : 13.12 
reg  signed [CONV_TOL_WTH-1:0]            data_conv_d2_sgn;              //input 8 bit  -> : precision : 12.8 . 
                                                                         //input 8.4bit -> : precision : 13.12                          
wire        [FILTER_WTH+KERNEL_WTH-1:0]   flt_sum_ar_nxt;                //input 8 bit  -> : precision : 4.8 . 
                                                                         //input 8.4bit -> : precision : 5.8
reg         [FILTER_WTH+KERNEL_WTH-1:0]   flt_sum_ar;                    //input 8 bit  -> : precision : 4.8 . 
                                                                         //input 8.4bit -> : precision : 5.8
wire signed [CONV_TOL_WTH+RECIP_COW-1:0]  conv_fin_data_sgn_nxt;         //input 8 bit  -> : precision : 12.19 . 
                                                                         //input 8.4bit -> : precision : 13.24
reg  signed [CONV_TOL_WTH+RECIP_COW-1:0]  conv_fin_data_sgn;             //input 8 bit  -> : precision : 12.19 . 
                                                                         //input 8.4bit -> : precision : 13.24
                                                                      
wire signed [CONV_PART_WTH-1:0]           data_conv_part1_sgn;   
wire                                      data_conv_part1_rnd;                                                                       

wire        [4-1:0]                       conv_sft_num;
wire        [4-1:0]                       rnd_sft_num;
//----------------------------------------------------------------------output
wire        [RECIP_COW  :0]               flt_recip;                                                //precision : 1.12
wire        [5:0]                         prcis_idx;
reg         [5:0]                         prcis_idx_q;

wire        [COW-1:0]                     o_cv_data_sgn_nxt;
wire                                      o_cv_dvld_nxt;
wire                                      o_cv_hstr_nxt;
wire                                      o_cv_hend_nxt;
wire                                      vstr_keep_nxt;
wire                                      vend_keep_nxt;
reg                                       vstr_keep;
reg                                       vend_keep;
wire                                      o_cv_vstr_nxt;
wire                                      o_cv_vend_nxt;

//----------------------------------------------------------------------FSM 
wire                                      idle_smo;
wire                                      delta_x_cnt_smo;
wire                                      cnvl_smo;
wire                                      out_enable_smo;
reg         [3:0]                         bil_filter_ns;
reg         [3:0]                         bil_filter_cs;

//----------------------------------------------------------------------for loop genvqar
genvar                                    flt_i,flt_i_2;
integer                                   rst_i;   

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//-------------------------------------------------------------------input data convert to 2 dimation 

generate 
for(flt_i=0;flt_i<KRNV_SZ*ODATA_RNG;flt_i=flt_i+1) begin : i_data_array_sign

assign i_data_array_sgn[flt_i]      = $signed({SIGN_EN & i_data[(flt_i+1)*(CIW-1)-1], i_data[(flt_i+1)*(CIW-1)-1:flt_i*(CIW-1)]});    

end 
endgenerate


//-------------------------------------------------------------------control and constance 
assign filter_eq_ker           = delta_x_cnt_smo & (filter_cnt == 7-1'b1);                              //BIL_DELTA_X_CNT
assign pixel_num               = DIFF_DLY + KRNH_SZ_MID -1'b1;                                          //BIL_OUT_EN      //delay number before pipe 1
assign filter_eq_hstr          = cnvl_smo        & (filter_cnt == CNVL_PRE_NUM);                        //BIL_CNVL status 
assign filter_eq_hend          = out_enable_smo  & (filter_cnt == pixel_num);                           //BIL_OUT_EN
assign filter_eq_vstr          = cnvl_smo        & (filter_cnt == CNVL_PRE_NUM-1);                      //BIL_CNVL status 

assign filter_cnt_nxt          = (filter_cnt_inc ? filter_cnt + 1'b1 : filter_cnt) & {4{~filter_cnt_clr}};                
assign filter_cnt_inc          = !idle_smo;
assign filter_cnt_clr          = (i_href & out_enable_smo) | idle_smo;

//-------------------------------------------------------------------delta x 
generate 
for(flt_i=0;flt_i<7;flt_i=flt_i+1) begin : delta_x_lut_gen

assign delta_x_lut[flt_i]      = DELTA_X[(flt_i+1)*7-1 : flt_i*7];    

end 
endgenerate
                                                                                                                                     //precision:5(r_bf_sigma_r) * 3.5(delta_x_lut) = 8.5
assign delta_x_sigma_r         = {13{delta_x_cnt_smo}} & (r_bf_sigma_r * delta_x_lut[filter_cnt]); 
assign delta_x_sigma_r_rnd     = delta_x_sigma_r + {1'b1,{5-1{1'b0}}};                                                               //predision 8.5 rounding to 8 
assign delta_x_sigma_r_lut_nxt = delta_x_cnt_smo ? {delta_x_sigma_r_lut[8*6-1:0],delta_x_sigma_r_rnd[12:5]} : delta_x_sigma_r_lut ;  //precision : 8

//-------------------------------------------------------------------pipe 0 
generate 
  for(flt_i=0;flt_i<KRNH_SZ;flt_i=flt_i+1) begin : delta_x_and_delta_sgn
    for(flt_i_2=0;flt_i_2<KRNV_SZ;flt_i_2=flt_i_2+1) begin: delta_x_and_delta_sgn_2
assign delta_x_sgn[(KRNH_SZ*KRNV_SZ)-(flt_i*KRNV_SZ+flt_i_2)-1]  = $signed(i_data_array_sgn[flt_i*KRNV_SZ+flt_i_2])- //pipe 0 start
                                                                   $signed(i_data_array_sgn[KERNEL_SHIFT]); //others pixel - center
assign delta_x_sgn_bit_nxt[flt_i*KRNV_SZ + flt_i_2]              = delta_x_sgn[(KRNH_SZ*KRNV_SZ)-(flt_i*KRNV_SZ+flt_i_2)-1][CIW-1];
assign delta_x[flt_i*KRNV_SZ + flt_i_2]                          = delta_x_sgn_bit_nxt[flt_i*KRNV_SZ + flt_i_2] ? -delta_x_sgn[(KRNH_SZ*KRNV_SZ)-(flt_i*KRNV_SZ+flt_i_2)-1] :
                                                                                                                   delta_x_sgn[(KRNH_SZ*KRNV_SZ)-(flt_i*KRNV_SZ+flt_i_2)-1]; 
  if(PIPE_0_RND) begin : gen_if_delta_x_rnd_nxt
    assign delta_x_rnd_nxt[flt_i*KRNV_SZ + flt_i_2]                  = (delta_x[flt_i*KRNV_SZ + flt_i_2] + {PIPE_0_RND,{CIPW-1{1'b0}}}) >> CIPW; 
  end 
  else begin
    assign delta_x_rnd_nxt[flt_i*KRNV_SZ + flt_i_2]                  = (delta_x[flt_i*KRNV_SZ + flt_i_2])>> CIPW; 
  end
  
    end
  end 
endgenerate 

//in order to compatible 3*n kernel 
assign weight_dis_group[0]  = 0;                                                                                              //12  
assign weight_dis_group[1]  = 0;
assign weight_dis_group[2]  = 0;
assign weight_dis_group[3]  = 0;

assign weight_dis_group[4]  = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ]      ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ][CIW-1:0]};       //7  
assign weight_dis_group[5]  = {delta_x_sgn_bit[KERNEL_SHIFT-1]            ,delta_x_rnd[KERNEL_SHIFT-1][CIW-1:0]};             //11  
assign weight_dis_group[6]  = {delta_x_sgn_bit[KERNEL_SHIFT+1]            ,delta_x_rnd[KERNEL_SHIFT+1][CIW-1:0]};             //13   
assign weight_dis_group[7]  = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ]      ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ][CIW-1:0]};       //17  

assign weight_dis_group[8]  = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ-1]    ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ-1][CIW-1:0]};     //6  
assign weight_dis_group[9]  = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ+1]    ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ+1][CIW-1:0]};     //8  
assign weight_dis_group[10] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ-1]    ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ-1][CIW-1:0]};     //16  
assign weight_dis_group[11] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ+1]    ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ+1][CIW-1:0]};     //18  

generate 
  if((KRNH_SZ != 3'd5) && (KRNV_SZ == 3'd5)) begin : gen_if_weight_dis_group_0
assign weight_dis_group[12] = 0;
assign weight_dis_group[13] = {delta_x_sgn_bit[KERNEL_SHIFT-2]            ,delta_x_rnd[KERNEL_SHIFT-2][CIW-1:0]};             //10
assign weight_dis_group[14] = {delta_x_sgn_bit[KERNEL_SHIFT+2]            ,delta_x_rnd[KERNEL_SHIFT+2][CIW-1:0]};             //14 
assign weight_dis_group[15] = 0;
assign weight_dis_group[16] = 0;
assign weight_dis_group[17] = 0;
assign weight_dis_group[18] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ-2]    ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ-2][CIW-1:0]};     //5
assign weight_dis_group[19] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ+2]    ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ+2][CIW-1:0]};     //9
assign weight_dis_group[20] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ-2]    ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ-2][CIW-1:0]};     //15
assign weight_dis_group[21] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ+2]    ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ+2][CIW-1:0]};     //19
assign weight_dis_group[22] = 0;
assign weight_dis_group[23] = 0;
  end 
endgenerate

generate 
  if((KRNH_SZ == 3'd5) && (KRNV_SZ != 3'd5)) begin : gen_if_weight_dis_group_1
assign weight_dis_group[12] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ*2]    ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ*2][CIW-1:0]};     //2
assign weight_dis_group[13] = 0;
assign weight_dis_group[14] = 0;
assign weight_dis_group[15] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ*2]    ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ*2][CIW-1:0]};     //22  
assign weight_dis_group[16] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ*2-1]  ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ*2-1][CIW-1:0]};   //1
assign weight_dis_group[17] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ*2+1]  ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ*2+1][CIW-1:0]};   //3
assign weight_dis_group[18] = 0;
assign weight_dis_group[19] = 0;
assign weight_dis_group[20] = 0;
assign weight_dis_group[21] = 0;
assign weight_dis_group[22] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ*2-1]  ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ*2-1][CIW-1:0]};   //21
assign weight_dis_group[23] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ*2+1]  ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ*2+1][CIW-1:0]};   //23
  end 
endgenerate

generate 
  if((KRNH_SZ == 3'd5) && (KRNV_SZ == 3'd5)) begin : gen_if_weight_dis_group_2
assign weight_dis_group[12] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ*2]    ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ*2][CIW-1:0]};     //2
assign weight_dis_group[13] = {delta_x_sgn_bit[KERNEL_SHIFT-2]            ,delta_x_rnd[KERNEL_SHIFT-2][CIW-1:0]};             //10
assign weight_dis_group[14] = {delta_x_sgn_bit[KERNEL_SHIFT+2]            ,delta_x_rnd[KERNEL_SHIFT+2][CIW-1:0]};             //14 
assign weight_dis_group[15] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ*2]    ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ*2][CIW-1:0]};     //22  
assign weight_dis_group[16] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ*2-1]  ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ*2-1][CIW-1:0]};   //1
assign weight_dis_group[17] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ*2+1]  ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ*2+1][CIW-1:0]};   //3
assign weight_dis_group[18] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ-2]    ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ-2][CIW-1:0]};     //5
assign weight_dis_group[19] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ+2]    ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ+2][CIW-1:0]};     //9
assign weight_dis_group[20] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ-2]    ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ-2][CIW-1:0]};     //15
assign weight_dis_group[21] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ+2]    ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ+2][CIW-1:0]};     //19
assign weight_dis_group[22] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ*2-1]  ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ*2-1][CIW-1:0]};   //21
assign weight_dis_group[23] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ*2+1]  ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ*2+1][CIW-1:0]};   //23
assign weight_dis_group[24] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ*2-2]  ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ*2-2][CIW-1:0]};   //0
assign weight_dis_group[25] = {delta_x_sgn_bit[KERNEL_SHIFT-KRNV_SZ*2+2]  ,delta_x_rnd[KERNEL_SHIFT-KRNV_SZ*2+2][CIW-1:0]};   //4
assign weight_dis_group[26] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ*2-2]  ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ*2-2][CIW-1:0]};   //20
assign weight_dis_group[27] = {delta_x_sgn_bit[KERNEL_SHIFT+KRNV_SZ*2+2]  ,delta_x_rnd[KERNEL_SHIFT+KRNV_SZ*2+2][CIW-1:0]};   //24
  end 
endgenerate 

// kernel: 3*3       weight_dis_group
// | 6 | 11 | 16 |    | 8 | 5 | 10 |
// | 7 | 12 | 17 | => | 4 | 0 | 7  |
// | 8 | 13 | 18 |    | 9 | 6 | 11 |

// kernel: 3*5                         weight_dis_group
// | 1  | 6  | 11 | 16 | 21  |    | 16 | 8  | 5  | 10 | 22  |
// | 2  | 7  | 12 | 17 | 22  | => | 12 | 4  | 0  | 7  | 15  |
// | 3  | 8  | 13 | 18 | 12  |    | 17 | 9  | 6  | 11 | 23  |

// kernel: 5*3       weight_dis_group
// | 5 | 10 | 15 |    | 18 | 13 | 20 |
// | 6 | 11 | 16 |    | 8  | 5  | 10 |
// | 7 | 12 | 17 | => | 4  | 0  | 7  |
// | 8 | 13 | 18 |    | 9  | 6  | 11 |
// | 9 | 14 | 19 |    | 19 | 14 | 21 |

// kernel: 5*5                         weight_dis_group
// | 0  | 5  | 10 | 15 | 20  |    | 24 | 18 | 13 | 20 | 26  |
// | 1  | 6  | 11 | 16 | 21  |    | 16 | 8  | 5  | 10 | 22  |
// | 2  | 7  | 12 | 17 | 22  | => | 12 | 4  | 0  | 7  | 15  |
// | 3  | 8  | 13 | 18 | 23  |    | 17 | 9  | 6  | 11 | 23  |
// | 4  | 9  | 14 | 19 | 24  |    | 25 | 19 | 14 | 21 | 27  |

//-------------------------------------------------------------------pipe 1 (find the range)
generate 
  for (flt_i=0;flt_i<KERNEL_TOTAL;flt_i=flt_i+1) begin : find_the_range
 assign comp_delta_x_zero[flt_i]  = |(weight_dis_group[flt_i][CIW-1:0]);
 assign comp_delta_x_1_lsb[flt_i] = weight_dis_group[flt_i][CIW-1:0] >= delta_x_sigma_r_lut[8*2-1:8*1];
 assign comp_delta_x_1_msb[flt_i] = weight_dis_group[flt_i][CIW-1:0] >= delta_x_sigma_r_lut[8*6-1:8*5]; 
 assign delta_lut_0[flt_i]        = comp_delta_x_1_lsb[flt_i] ? delta_x_sigma_r_lut[8*3-1:8*2] : delta_x_sigma_r_lut[8*1-1:0  ];
 assign delta_lut_1[flt_i]        = comp_delta_x_1_msb[flt_i] ? delta_x_sigma_r_lut[8*7-1:8*6] : delta_x_sigma_r_lut[8*5-1:8*4];
 assign comp_delta_x_2_lsb[flt_i] = weight_dis_group[flt_i][CIW-1:0] >= delta_lut_0[flt_i];
 assign comp_delta_x_2_msb[flt_i] = weight_dis_group[flt_i][CIW-1:0] >= delta_lut_1[flt_i]; 
 assign comp_delta_x_0[flt_i]     = weight_dis_group[flt_i][CIW-1:0] >= delta_x_sigma_r_lut[8*4-1:8*3];
 assign comp_delta_x_1[flt_i]     = comp_delta_x_0[flt_i] ? comp_delta_x_1_msb[flt_i] : comp_delta_x_1_lsb[flt_i];
 assign comp_delta_x_2[flt_i]     = comp_delta_x_0[flt_i] ? comp_delta_x_2_msb[flt_i] : comp_delta_x_2_lsb[flt_i];
 assign comp_delta_x_nxt[flt_i]   = {comp_delta_x_zero[flt_i],comp_delta_x_0[flt_i],comp_delta_x_1[flt_i],comp_delta_x_2[flt_i]}; //pipe 0 end    //pipe 1 start 
 assign comp_sign_bit_nxt[flt_i]  = weight_dis_group[flt_i][CIW];
  end 
endgenerate 

//--------------------------------------------------------------- get kernel weighting  
generate
  for(flt_i=0;flt_i<GROUP_NUM;flt_i=flt_i+1) begin  : get_kernel
    for(flt_i_2=0;flt_i_2<8;flt_i_2=flt_i_2+1) begin : get_kernel_2
      always@* begin 
        ker_weight_0_lut[GROUP_NUM-flt_i-1][(flt_i_2+1)*FILTER_WTH-1:(flt_i_2)*FILTER_WTH] = 
                                                                   FILTER_WHT_0[((GROUP_NUM-flt_i)*FILTER_WTH-flt_i_2)*FILTER_WTH-1:((GROUP_NUM-flt_i)*FILTER_WTH-flt_i_2-1)*FILTER_WTH];
        ker_weight_1_lut[GROUP_NUM-flt_i-1][(flt_i_2+1)*FILTER_WTH-1:(flt_i_2)*FILTER_WTH] = 
                                                                   FILTER_WHT_1[((GROUP_NUM-flt_i)*FILTER_WTH-flt_i_2)*FILTER_WTH-1:((GROUP_NUM-flt_i)*FILTER_WTH-flt_i_2-1)*FILTER_WTH];
        ker_weight_lut[GROUP_NUM-flt_i-1][(flt_i_2+1)*FILTER_WTH-1:(flt_i_2)*FILTER_WTH]   = 
                                                                   r_sigma_s_sel ? ker_weight_1_lut[GROUP_NUM-flt_i-1][(flt_i_2+1)*FILTER_WTH-1:(flt_i_2)*FILTER_WTH]:
                                                                                   ker_weight_0_lut[GROUP_NUM-flt_i-1][(flt_i_2+1)*FILTER_WTH-1:(flt_i_2)*FILTER_WTH]; 
      end
    end
  end 
endgenerate

generate 
  for(flt_i=0;flt_i<GROUP_NUM;flt_i=flt_i+1) begin : find_weight
    for(flt_i_2=0;flt_i_2<4;flt_i_2=flt_i_2+1) begin : find_weight_2
    
  if(flt_i==0) begin : gen_if_find_weight_2
    always@* begin 
      filter_x[flt_i_2] = ker_weight_lut[0][FILTER_WTH-1:0];
    end
  end 
  else begin 
    always@* begin 

                 filter_x[(flt_i)*4+flt_i_2]    = 0;  
  
      case (comp_delta_x[(flt_i)*4+flt_i_2][2:0]) //synopsys full_case
        3'b000 : filter_x[(flt_i)*4+flt_i_2]    = ker_weight_lut[flt_i][FILTER_WTH-1:0];
        3'b001 : filter_x[(flt_i)*4+flt_i_2]    = ker_weight_lut[flt_i][FILTER_WTH*2-1:FILTER_WTH*1];
        3'b010 : filter_x[(flt_i)*4+flt_i_2]    = ker_weight_lut[flt_i][FILTER_WTH*3-1:FILTER_WTH*2];
        3'b011 : filter_x[(flt_i)*4+flt_i_2]    = ker_weight_lut[flt_i][FILTER_WTH*4-1:FILTER_WTH*3];
        3'b100 : filter_x[(flt_i)*4+flt_i_2]    = ker_weight_lut[flt_i][FILTER_WTH*5-1:FILTER_WTH*4];
        3'b101 : filter_x[(flt_i)*4+flt_i_2]    = ker_weight_lut[flt_i][FILTER_WTH*6-1:FILTER_WTH*5];
        3'b110 : filter_x[(flt_i)*4+flt_i_2]    = ker_weight_lut[flt_i][FILTER_WTH*7-1:FILTER_WTH*6];
        3'b111 : filter_x[(flt_i)*4+flt_i_2]    = ker_weight_lut[flt_i][FILTER_WTH*8-1:FILTER_WTH*7];
      endcase
    end
  end 

  always@* begin 
    case (r_bf_op_mode)
      2'b00 : filter_x_out[flt_i*4+flt_i_2] = 1;
      2'b01 : filter_x_out[flt_i*4+flt_i_2] = {FILTER_WTH{~comp_sign_bit[flt_i*4+flt_i_2]}} & filter_x[flt_i*4+flt_i_2];
      2'b10 : filter_x_out[flt_i*4+flt_i_2] = {FILTER_WTH{(comp_sign_bit[flt_i*4+flt_i_2]) | (comp_delta_x[flt_i*4+flt_i_2][3]==0)}} & filter_x[flt_i*4+flt_i_2]; 
                                                                                              //all input are zero situation 
      2'b11 : filter_x_out[flt_i*4+flt_i_2] = filter_x[flt_i*4+flt_i_2];
    endcase
    end
  end
  end 
endgenerate  

//------------------------------------------------------------------convolution
generate 
  for(flt_i=0;flt_i<KRNH_SZ;flt_i=flt_i+1) begin : flt_weight_ppf0_gen //pipe 1 end
    for(flt_i_2=0;flt_i_2<KRNV_SZ;flt_i_2=flt_i_2+1) begin : flt_weight_ppf0_gen_2
assign flt_weight_d0_nxt[flt_i*KRNV_SZ+flt_i_2] = $signed({1'b0,filter_x_out[KERNEL_TABLE[((HOR_DIFF+flt_i)*VER_MAX+VER_DIFF+flt_i_2+1)*VER_MAX-1: 
                                                                                            ((HOR_DIFF+flt_i)*VER_MAX+VER_DIFF+flt_i_2)*VER_MAX]]});
    end 
  end
endgenerate  

generate 
  if((KRNH_SZ == 3'd3) && (KRNV_SZ == 3'd3)) begin : gen_if_conv_3_3
    assign data_conv_ppr0_sgn_nxt = 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 2]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 0]) +
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 2]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 0]) +
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 2]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 0]) ;
    end 
endgenerate

generate 
  if((KRNH_SZ == 3'd5) && (KRNV_SZ == 3'd3)) begin : gen_if_conv_5_3
    assign data_conv_ppr0_sgn_nxt = 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 2]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 0]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 2]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 0]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 2]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 0]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[3*KRNV_SZ + 2]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[3*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[3*KRNV_SZ + 0]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[4*KRNV_SZ + 2]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[4*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[4*KRNV_SZ + 0]);
    end 
endgenerate

generate 
  if((KRNH_SZ == 3'd3) && (KRNV_SZ == 3'd5)) begin : gen_if_conv_3_5
    assign data_conv_ppr0_sgn_nxt = 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 4]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 3]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 2]) +
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-4)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-5)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 0]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 4]) +
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 3]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 2]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-4)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 1]) +
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-5)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 0]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 4]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 3]) +
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 2]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-4)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf1_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-5)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 0]);
    end 
endgenerate

generate 
  if((KRNH_SZ == 3'd5) && (KRNV_SZ == 3'd5)) begin : gen_if_conv_5_5
    assign data_conv_ppr0_sgn_nxt =
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 4]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 3]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 2]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-4)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-5)]) * $signed(flt_weight_ppf0[0*KRNV_SZ + 0]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 4]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 3]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 2]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-4)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 1]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-5)]) * $signed(flt_weight_ppf0[1*KRNV_SZ + 0]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 4]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 3]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 2]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-4)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-5)]) * $signed(flt_weight_ppf0[2*KRNV_SZ + 0]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[3*KRNV_SZ + 4]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[3*KRNV_SZ + 3]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[3*KRNV_SZ + 2]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-4)]) * $signed(flt_weight_ppf0[3*KRNV_SZ + 1]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-5)]) * $signed(flt_weight_ppf0[3*KRNV_SZ + 0]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-1)]) * $signed(flt_weight_ppf0[4*KRNV_SZ + 4]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-2)]) * $signed(flt_weight_ppf0[4*KRNV_SZ + 3]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-3)]) * $signed(flt_weight_ppf0[4*KRNV_SZ + 2]) + 
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-4)]) * $signed(flt_weight_ppf0[4*KRNV_SZ + 1]) +
  $signed(i_data_array_ppf2_sgn[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-5)]) * $signed(flt_weight_ppf0[4*KRNV_SZ + 0]) ;
    end 
endgenerate
                                                                                      //input 8.4 bit ,kernel size:5*5 -> precision : 13.12
generate 
  if((KRNH_SZ == 3'd3) && (KRNV_SZ == 3'd3)) begin : gen_if_flt_sum_ar_3_3
    assign flt_sum_ar_nxt = 
                    flt_weight_ppf0[0*3] + flt_weight_ppf0[0*3+1] + flt_weight_ppf0[0*3+2] +
                    flt_weight_ppf0[1*3] + flt_weight_ppf0[1*3+1] + flt_weight_ppf0[1*3+2] +
                    flt_weight_ppf0[2*3] + flt_weight_ppf0[2*3+1] + flt_weight_ppf0[2*3+2];
    end 
endgenerate

generate 
  if((KRNH_SZ == 3'd5) && (KRNV_SZ == 3'd3)) begin : gen_if_flt_sum_ar_5_3
    assign flt_sum_ar_nxt = 
                    flt_weight_ppf0[0*KRNV_SZ] + flt_weight_ppf0[0*KRNV_SZ+1] + flt_weight_ppf0[0*KRNV_SZ+2] +
                    flt_weight_ppf0[1*KRNV_SZ] + flt_weight_ppf0[1*KRNV_SZ+1] + flt_weight_ppf0[1*KRNV_SZ+2] +
                    flt_weight_ppf0[2*KRNV_SZ] + flt_weight_ppf0[2*KRNV_SZ+1] + flt_weight_ppf0[2*KRNV_SZ+2] +
                    flt_weight_ppf0[3*KRNV_SZ] + flt_weight_ppf0[3*KRNV_SZ+1] + flt_weight_ppf0[3*KRNV_SZ+2] +
                    flt_weight_ppf0[4*KRNV_SZ] + flt_weight_ppf0[4*KRNV_SZ+1] + flt_weight_ppf0[4*KRNV_SZ+2];
    end 
endgenerate

generate 
  if((KRNH_SZ == 3'd3) && (KRNV_SZ == 3'd5)) begin : gen_if_flt_sum_ar_3_5
    assign flt_sum_ar_nxt =   
                    flt_weight_ppf0[0*KRNV_SZ+4] + flt_weight_ppf0[0*KRNV_SZ+3] + flt_weight_ppf0[0*KRNV_SZ+2] + flt_weight_ppf0[0*KRNV_SZ+1] + flt_weight_ppf0[0*KRNV_SZ+0] +
                    flt_weight_ppf0[1*KRNV_SZ+4] + flt_weight_ppf0[1*KRNV_SZ+3] + flt_weight_ppf0[1*KRNV_SZ+2] + flt_weight_ppf0[1*KRNV_SZ+1] + flt_weight_ppf0[1*KRNV_SZ+0] +
                    flt_weight_ppf0[2*KRNV_SZ+4] + flt_weight_ppf0[2*KRNV_SZ+3] + flt_weight_ppf0[2*KRNV_SZ+2] + flt_weight_ppf0[2*KRNV_SZ+1] + flt_weight_ppf0[2*KRNV_SZ+0];
    end 
endgenerate

generate 
  if((KRNH_SZ == 3'd5) && (KRNV_SZ == 3'd5)) begin : gen_if_flt_sum_ar_5_5
    assign flt_sum_ar_nxt =
                    flt_weight_ppf0[0*KRNV_SZ + 4] + flt_weight_ppf0[0*KRNV_SZ + 3] + flt_weight_ppf0[0*KRNV_SZ + 2] + flt_weight_ppf0[0*KRNV_SZ + 1] + flt_weight_ppf0[0*KRNV_SZ + 0] +
                    flt_weight_ppf0[1*KRNV_SZ + 4] + flt_weight_ppf0[1*KRNV_SZ + 3] + flt_weight_ppf0[1*KRNV_SZ + 2] + flt_weight_ppf0[1*KRNV_SZ + 1] + flt_weight_ppf0[1*KRNV_SZ + 0] +
                    flt_weight_ppf0[2*KRNV_SZ + 4] + flt_weight_ppf0[2*KRNV_SZ + 3] + flt_weight_ppf0[2*KRNV_SZ + 2] + flt_weight_ppf0[2*KRNV_SZ + 1] + flt_weight_ppf0[2*KRNV_SZ + 0] +
                    flt_weight_ppf0[3*KRNV_SZ + 4] + flt_weight_ppf0[3*KRNV_SZ + 3] + flt_weight_ppf0[3*KRNV_SZ + 2] + flt_weight_ppf0[3*KRNV_SZ + 1] + flt_weight_ppf0[3*KRNV_SZ + 0] +
                    flt_weight_ppf0[4*KRNV_SZ + 4] + flt_weight_ppf0[4*KRNV_SZ + 3] + flt_weight_ppf0[4*KRNV_SZ + 2] + flt_weight_ppf0[4*KRNV_SZ + 1] + flt_weight_ppf0[4*KRNV_SZ + 0];

    end 
endgenerate

assign conv_sft_num            = (SFT_TABLE[6*4-1:5*4] & {4{prcis_idx[5]}}) | (SFT_TABLE[5*4-1:4*4] & {4{prcis_idx[4]}}) | (SFT_TABLE[4*4-1:3*4] & {4{prcis_idx[3]}}) | 
                                 (SFT_TABLE[3*4-1:2*4] & {4{prcis_idx[2]}}) | (SFT_TABLE[2*4-1:1*4] & {4{prcis_idx[1]}}) | (SFT_TABLE[1*4-1:0*4] & {4{prcis_idx[0]}});

assign data_conv_part1_sgn     =  data_conv_d2_sgn >>> conv_sft_num;

assign rnd_sft_num             = ((SFT_TABLE[6*4-1:5*4] & {4{prcis_idx[5]}}) | (SFT_TABLE[5*4-1:4*4] & {4{prcis_idx[4]}}) | (SFT_TABLE[4*4-1:3*4] & {4{prcis_idx[3]}}) | 
                                  (SFT_TABLE[3*4-1:2*4] & {4{prcis_idx[2]}}) | (SFT_TABLE[2*4-1:1*4] & {4{prcis_idx[1]}})) -1'b1;              

assign data_conv_part1_rnd     = (data_conv_d2_sgn & {CONV_TOL_WTH{!prcis_idx[0]}}) >> rnd_sft_num;
             
assign conv_fin_data_sgn_nxt   = ($signed(data_conv_part1_sgn) + $signed({1'b0,data_conv_part1_rnd})) * $signed({1'b0,flt_recip[RECIP_COW-1:0]}) + 
                                  $signed({1'b0,{1'b1,{RECIP_COW-1{1'b0}}}});  //pipe 2 start

//------------------------------------------------------------------output
assign o_cv_data_sgn_nxt = $signed(conv_fin_data_sgn[RECIP_COW+COW:RECIP_COW]); //pipe 2 end 
//assign o_cv_data_sgn_nxt = data_conv_part1_sgn;
assign o_cv_dvld_nxt     = out_enable_smo;
assign o_cv_hstr_nxt     = filter_eq_hstr;
assign o_cv_hend_nxt     = filter_eq_hend;
assign vstr_keep_nxt     = (vstr_keep | i_vstr) & !o_cv_vstr;
assign vend_keep_nxt     = (vend_keep | i_vend) & !o_cv_vend;
assign o_cv_vstr_nxt     = vstr_keep & filter_eq_vstr;
assign o_cv_vend_nxt     = vend_keep & o_cv_hend;

//------------------------------------------------------------------FSM 
assign idle_smo          = bil_filter_cs[0];
assign delta_x_cnt_smo   = bil_filter_cs[1];
assign cnvl_smo          = bil_filter_cs[2];
assign out_enable_smo    = bil_filter_cs[3];

always@* begin 

  bil_filter_ns = bil_filter_cs;

  case(bil_filter_cs)

  BIL_IDLE :        begin 
                      if(i_fstr)
                        bil_filter_ns = BIL_DELTA_X_CNT;
                      else 
                        if(i_hstr)
                        bil_filter_ns = BIL_CNVL;
                    end 

  BIL_DELTA_X_CNT : begin 
                      if(filter_eq_ker)
                        bil_filter_ns = BIL_IDLE;
                    end 

  BIL_CNVL :        begin 
                      if(filter_eq_hstr)
                        bil_filter_ns = BIL_OUT_EN;
                    end 

  BIL_OUT_EN :      begin 
                      if(filter_eq_hend)
                        bil_filter_ns = BIL_IDLE;
                    end 
endcase 
end 


//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//

ip_recip13p14v1
#(
    .PRCIS_EXT      (PRCIS_EXT),                                          // "LVL_0"/"LVL_1"/"LVL_2"
    .DENM_ZERO      (DENM_ZERO)                                           // output value definition, if denominator == 0
) 
ip_recip13p14v1
(
  .o_recip          (flt_recip),                                          // reciprocal value. precision: 1.12 //the minimun is 233(distance value = 0)
  .o_prcis_idx      (prcis_idx),                                          // precision index

  .i_denm           ({{4'd13-(FILTER_WTH+KERNEL_WTH){1'b0}},flt_sum_ar}), //recip input precision is 13

  .clk              (clk),        
  .rst_n            (rst_n)         
);

always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin 
  
//---------------------------------------------------------------delta x 
  delta_x_sigma_r_lut     <= 0;

//---------------------------------------------------------------control and constance 
  filter_cnt              <= 0;

//---------------------------------------------------------------convolution
  conv_fin_data_sgn       <= 0;
  data_conv_ppr0_sgn      <= 0;
  data_conv_d1_sgn        <= 0;
  data_conv_d2_sgn        <= 0;
  flt_sum_ar              <= 0;
  
//---------------------------------------------------------------output
  prcis_idx_q             <= 0;
  vstr_keep               <= 0;
  vend_keep               <= 0;
  o_cv_data_sgn           <= 0;
  o_cv_dvld               <= 0;
  o_cv_hstr               <= 0;
  o_cv_hend               <= 0;
  o_cv_vstr               <= 0;
  o_cv_vend               <= 0;

end
else begin 
  
//---------------------------------------------------------------delta x 
  delta_x_sigma_r_lut     <= delta_x_sigma_r_lut_nxt;

//---------------------------------------------------------------control and constance 
  filter_cnt              <= filter_cnt_nxt;

//---------------------------------------------------------------convolution
  conv_fin_data_sgn       <= conv_fin_data_sgn_nxt;
  data_conv_ppr0_sgn      <= data_conv_ppr0_sgn_nxt;
  data_conv_d1_sgn        <= data_conv_ppr0_sgn;
  data_conv_d2_sgn        <= data_conv_d1_sgn;
  flt_sum_ar              <= flt_sum_ar_nxt;
  
//---------------------------------------------------------------output
  prcis_idx_q             <= prcis_idx;
  vstr_keep               <= vstr_keep_nxt;
  vend_keep               <= vend_keep_nxt;
  o_cv_data_sgn           <= o_cv_data_sgn_nxt;
  o_cv_dvld               <= o_cv_dvld_nxt;
  o_cv_hstr               <= o_cv_hstr_nxt;
  o_cv_hend               <= o_cv_hend_nxt;
  o_cv_vstr               <= o_cv_vstr_nxt;
  o_cv_vend               <= o_cv_vend_nxt;

end 
end 

always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin 
//-------------------------------------------------------------------input data convert to 2 dimation 
  for(rst_i=0;rst_i<KRNV_SZ*ODATA_RNG;rst_i=rst_i+1) begin
  i_data_array_d0_sgn[rst_i]          <= 0;
  i_data_array_d1_sgn[rst_i]          <= 0;
  i_data_array_ppf1_sgn[rst_i]        <= 0;
  i_data_array_ppf2_sgn[rst_i]        <= 0;
  end
  
//---------------------------------------------------------------delta x 
  for(rst_i=0;rst_i<KERNEL_TOTAL;rst_i=rst_i+1) begin
  comp_delta_x[rst_i]                 <= 0;
  comp_sign_bit[rst_i]                <= 0;
  end

//---------------------------------------------------------------pipe 0 
  for(rst_i=0;rst_i<KERNEL_NUM;rst_i=rst_i+1) begin 
  delta_x_rnd[rst_i]                  <= 0;
  delta_x_sgn_bit[rst_i]              <= 0;
  end 
  
//---------------------------------------------------------------convolution
  
  for(rst_i=0;rst_i<KERNEL_NUM;rst_i=rst_i+1) begin 
  flt_weight_ppf0[rst_i]              <= 0;
  flt_weight_ppf1[rst_i]              <= 0;
  end

end
else begin
//-------------------------------------------------------------------input data convert to 2 dimation 
  for(rst_i=0;rst_i<KRNV_SZ*ODATA_RNG;rst_i=rst_i+1) begin
  i_data_array_d0_sgn[rst_i]          <= i_data_array_sgn[rst_i];
  i_data_array_d1_sgn[rst_i]          <= i_data_array_d0_sgn[rst_i];
  i_data_array_ppf1_sgn[rst_i]        <= i_data_array_d1_sgn[rst_i];
  i_data_array_ppf2_sgn[rst_i]        <= i_data_array_ppf1_sgn[rst_i];
  end
  
//---------------------------------------------------------------delta x 
  for(rst_i=0;rst_i<KERNEL_TOTAL;rst_i=rst_i+1) begin
  comp_delta_x[rst_i]                 <= comp_delta_x_nxt[rst_i];
  comp_sign_bit[rst_i]                <= comp_sign_bit_nxt[rst_i];
  end 

//---------------------------------------------------------------pipe 0 
  for(rst_i=0;rst_i<KERNEL_NUM;rst_i=rst_i+1) begin 
  delta_x_rnd[rst_i]                  <= delta_x_rnd_nxt[rst_i];
  delta_x_sgn_bit[rst_i]              <= delta_x_sgn_bit_nxt[rst_i];
  end
  
//---------------------------------------------------------------convolution  
  for(rst_i=0;rst_i<KERNEL_NUM;rst_i=rst_i+1) begin 
  flt_weight_d0[rst_i]                <= flt_weight_d0_nxt[rst_i];
  flt_weight_ppf0[rst_i]              <= flt_weight_d0[rst_i];
  flt_weight_ppf1[rst_i]              <= flt_weight_ppf0[rst_i];
  end

end 
end 

always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin 
  bil_filter_cs                       <= BIL_IDLE;
end
else begin 
  bil_filter_cs                       <= bil_filter_ns;
end 
end 

endmodule 
