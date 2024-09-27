// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           
// Author:              Willy Lin
// Version:             1.0
// Date:                2022
// Last Modified On:    
// Last Modified By:    $Author$
//
// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------

module bil_ftr
   #( 
      parameter  DATA_WD      = 8,
      parameter  KRN_VSZ      = 3,
      parameter  KRN_HSZ      = 5
     )

(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg [DATA_WD-1:0] o_cv_data,
output reg               o_cv_dvld,
output reg               o_cv_vstr,
output reg               o_cv_hstr,
output reg               o_cv_hend,
output reg               o_cv_vend,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input      [DATA_WD-1:0] i_data_0,
input      [DATA_WD-1:0] i_data_1,
input      [DATA_WD-1:0] i_data_2,

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
localparam [3:0] KERNEL_NUM    = (KRN_VSZ * KRN_HSZ);
localparam [2:0] KERNEL_SHIFT  = KERNEL_NUM >>1;
localparam [2:0] KERNEL_WID    = $clog2(KERNEL_NUM);
localparam [2:0] KRN_HSZ_SHIFT = KRN_HSZ >>1;
localparam [3:0] CNVL_PRE_NUM  = KRN_HSZ_SHIFT + 1'b1 +       //delta x               //pipe 0   
                                 3'd1 +                       //delta x dff delay     //pipe 1 
                                 KRN_HSZ + 1'b1 +             //convolution //dff output 
                                 3'd2 -                       //wait for recip ip (2T)  
                                 3'd1 ; 
//-------------------------------------------------------------------weight
localparam [7:0]     FILTER_0_0_0    = 8'd29;
localparam [7:0]     FILTER_0_0_1    = 8'd24;
localparam [7:0]     FILTER_0_0_2    = 8'd19;
localparam [7:0]     FILTER_0_0_3    = 8'd14;
localparam [7:0]     FILTER_0_0_4    = 8'd9;
localparam [7:0]     FILTER_0_0_5    = 8'd4;
localparam [7:0]     FILTER_0_0_6    = 8'd1;
localparam [7:0]     FILTER_0_0_7    = 8'd0;
localparam [7:0]     FILTER_0_1_0    = 8'd45;
localparam [7:0]     FILTER_0_1_1    = 8'd37;
localparam [7:0]     FILTER_0_1_2    = 8'd29;
localparam [7:0]     FILTER_0_1_3    = 8'd21;
localparam [7:0]     FILTER_0_1_4    = 8'd13;
localparam [7:0]     FILTER_0_1_5    = 8'd7;
localparam [7:0]     FILTER_0_1_6    = 8'd2;
localparam [7:0]     FILTER_0_1_7    = 8'd0;
localparam [7:0]     FILTER_0_2_0    = 8'd102;
localparam [7:0]     FILTER_0_2_1    = 8'd85;
localparam [7:0]     FILTER_0_2_2    = 8'd66;
localparam [7:0]     FILTER_0_2_3    = 8'd47;
localparam [7:0]     FILTER_0_2_4    = 8'd30;
localparam [7:0]     FILTER_0_2_5    = 8'd15;
localparam [7:0]     FILTER_0_2_6    = 8'd5;
localparam [7:0]     FILTER_0_2_7    = 8'd0;
localparam [7:0]     FILTER_0_3_0    = 8'd154;
localparam [7:0]     FILTER_0_3_1    = 8'd128;
localparam [7:0]     FILTER_0_3_2    = 8'd100;
localparam [7:0]     FILTER_0_3_3    = 8'd72;
localparam [7:0]     FILTER_0_3_4    = 8'd45;
localparam [7:0]     FILTER_0_3_5    = 8'd23;
localparam [7:0]     FILTER_0_3_6    = 8'd7;
localparam [7:0]     FILTER_0_3_7    = 8'd0;
localparam [7:0]     FILTER_0_4_0    = 8'd233;
localparam [7:0]     FILTER_0_4_1    = 8'd193;
localparam [7:0]     FILTER_0_4_2    = 8'd150;
localparam [7:0]     FILTER_0_4_3    = 8'd108;
localparam [7:0]     FILTER_0_4_4    = 8'd68;
localparam [7:0]     FILTER_0_4_5    = 8'd35;
localparam [7:0]     FILTER_0_4_6    = 8'd11;
localparam [7:0]     FILTER_0_4_7    = 8'd0;

localparam [7:0]     FILTER_1_0_0    = 8'd176;
localparam [7:0]     FILTER_1_0_1    = 8'd146;
localparam [7:0]     FILTER_1_0_2    = 8'd114;
localparam [7:0]     FILTER_1_0_3    = 8'd82;
localparam [7:0]     FILTER_1_0_4    = 8'd52;
localparam [7:0]     FILTER_1_0_5    = 8'd26;
localparam [7:0]     FILTER_1_0_6    = 8'd9;
localparam [7:0]     FILTER_1_0_7    = 8'd0;
localparam [7:0]     FILTER_1_1_0    = 8'd186;
localparam [7:0]     FILTER_1_1_1    = 8'd155;
localparam [7:0]     FILTER_1_1_2    = 8'd120;
localparam [7:0]     FILTER_1_1_3    = 8'd87;
localparam [7:0]     FILTER_1_1_4    = 8'd55;
localparam [7:0]     FILTER_1_1_5    = 8'd28;
localparam [7:0]     FILTER_1_1_6    = 8'd9;
localparam [7:0]     FILTER_1_1_7    = 8'd0;
localparam [7:0]     FILTER_1_2_0    = 8'd208;
localparam [7:0]     FILTER_1_2_1    = 8'd173;
localparam [7:0]     FILTER_1_2_2    = 8'd135;
localparam [7:0]     FILTER_1_2_3    = 8'd97;
localparam [7:0]     FILTER_1_2_4    = 8'd61;
localparam [7:0]     FILTER_1_2_5    = 8'd31;
localparam [7:0]     FILTER_1_2_6    = 8'd10;
localparam [7:0]     FILTER_1_2_7    = 8'd0;
localparam [7:0]     FILTER_1_3_0    = 8'd220;
localparam [7:0]     FILTER_1_3_1    = 8'd183;
localparam [7:0]     FILTER_1_3_2    = 8'd142;
localparam [7:0]     FILTER_1_3_3    = 8'd102;
localparam [7:0]     FILTER_1_3_4    = 8'd65;
localparam [7:0]     FILTER_1_3_5    = 8'd33;
localparam [7:0]     FILTER_1_3_6    = 8'd11;
localparam [7:0]     FILTER_1_3_7    = 8'd0;
localparam [7:0]     FILTER_1_4_0    = 8'd233;
localparam [7:0]     FILTER_1_4_1    = 8'd193;
localparam [7:0]     FILTER_1_4_2    = 8'd150;
localparam [7:0]     FILTER_1_4_3    = 8'd108;
localparam [7:0]     FILTER_1_4_4    = 8'd68;
localparam [7:0]     FILTER_1_4_5    = 8'd35;
localparam [7:0]     FILTER_1_4_6    = 8'd11;
localparam [7:0]     FILTER_1_4_7    = 8'd0;

localparam [8*40-1:0] FILTER_WHT_0   = {FILTER_0_0_0,FILTER_0_0_1,FILTER_0_0_2,FILTER_0_0_3,FILTER_0_0_4,FILTER_0_0_5,FILTER_0_0_6,FILTER_0_0_7,
                                        FILTER_0_1_0,FILTER_0_1_1,FILTER_0_1_2,FILTER_0_1_3,FILTER_0_1_4,FILTER_0_1_5,FILTER_0_1_6,FILTER_0_1_7,
                                        FILTER_0_2_0,FILTER_0_2_1,FILTER_0_2_2,FILTER_0_2_3,FILTER_0_2_4,FILTER_0_2_5,FILTER_0_2_6,FILTER_0_2_7,
                                        FILTER_0_3_0,FILTER_0_3_1,FILTER_0_3_2,FILTER_0_3_3,FILTER_0_3_4,FILTER_0_3_5,FILTER_0_3_6,FILTER_0_3_7,
                                        FILTER_0_4_0,FILTER_0_4_1,FILTER_0_4_2,FILTER_0_4_3,FILTER_0_4_4,FILTER_0_4_5,FILTER_0_4_6,FILTER_0_4_7};

localparam [8*40-1:0] FILTER_WHT_1   = {FILTER_1_0_0,FILTER_1_0_1,FILTER_1_0_2,FILTER_1_0_3,FILTER_1_0_4,FILTER_1_0_5,FILTER_1_0_6,FILTER_1_0_7,
                                        FILTER_1_1_0,FILTER_1_1_1,FILTER_1_1_2,FILTER_1_1_3,FILTER_1_1_4,FILTER_1_1_5,FILTER_1_1_6,FILTER_1_1_7,
                                        FILTER_1_2_0,FILTER_1_2_1,FILTER_1_2_2,FILTER_1_2_3,FILTER_1_2_4,FILTER_1_2_5,FILTER_1_2_6,FILTER_1_2_7,
                                        FILTER_1_3_0,FILTER_1_3_1,FILTER_1_3_2,FILTER_1_3_3,FILTER_1_3_4,FILTER_1_3_5,FILTER_1_3_6,FILTER_1_3_7,
                                        FILTER_1_4_0,FILTER_1_4_1,FILTER_1_4_2,FILTER_1_4_3,FILTER_1_4_4,FILTER_1_4_5,FILTER_1_4_6,FILTER_1_4_7};

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
//-------------------------------------------------------------------control and constance 
wire        [3:0]           pixel_num;
wire                        filter_eq_ker;
wire                        filter_eq_hstr;
wire                        filter_eq_hend;
wire                        filter_eq_vstr;

wire        [3:0]           filter_cnt_nxt;
reg         [3:0]           filter_cnt;
wire                        filter_cnt_inc;
wire                        filter_cnt_clr;

//-------------------------------------------------------------------input data 
wire        [DATA_WD-1:0]   i_data                       [0:KRN_VSZ-1];
reg         [DATA_WD*8-1:0] i_data_que                   [0:KRN_VSZ-1];
wire        [DATA_WD*8-1:0] i_data_que_nxt               [0:KRN_VSZ-1];

//-------------------------------------------------------------------delta x 
wire        [6:0]           delta_x_lut                  [0:6];
wire        [8*7-1:0]       delta_x_sigma_r_lut_nxt;                        //5(r_bf_sigma_r) * 3.5(delta_x_lut) => unconditional carry to 8 bit
reg         [8*7-1:0]       delta_x_sigma_r_lut ;
wire        [12:0]          delta_x_sigma_r;
wire        [12:0]          delta_x_sigma_r_rnd;
wire signed [DATA_WD:0]     delta_x_sgn                  [0:KERNEL_NUM-1];
wire        [DATA_WD-1:0]   delta_x                      [0:KERNEL_NUM-1];
wire        [DATA_WD:0]     weight_dis_group             [0:KERNEL_WID*KRN_HSZ-1];
wire                        delta_x_sgn_bit              [0:KERNEL_NUM-1];

wire                        comp_delta_x_0               [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ 
wire        [7:0]           delta_x_sel_0                [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
wire                        comp_delta_x_1               [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
wire        [7:0]           delta_x_sel_1                [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
wire                        comp_delta_x_2               [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ

wire        [3:0]           comp_delta_x_nxt             [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
reg         [3:0]           comp_delta_x                 [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
wire                        comp_delta_x_zero            [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ

wire                        comp_sign_bit_nxt            [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
reg                         comp_sign_bit                [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ

wire        [7:0]           delta_lut_0                  [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
wire        [7:0]           delta_lut_1                  [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
wire                        comp_delta_x_1_lsb           [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
wire                        comp_delta_x_1_msb           [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
wire                        comp_delta_x_2_lsb           [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ
wire                        comp_delta_x_2_msb           [0:KERNEL_NUM+KRN_HSZ-1]; //KERNEL_NUM + KRN_HSZ


//------------------------------------------------------------------- get kernel weight 
reg         [8*8-1:0]       ker_weight_0_lut             [0:KRN_HSZ-1];
reg         [8*8-1:0]       ker_weight_1_lut             [0:KRN_HSZ-1];
reg         [8*8-1:0]       ker_weight_lut               [0:KRN_HSZ-1];
reg         [8-1:0]         filter_x                     [0:KRN_HSZ*4-1];
reg         [8-1:0]         filter_x_out                 [0:KRN_HSZ*4-1];

//----------------------------------------------------------------------convolution
wire        [8-1:0]         flt_weight                   [0:KERNEL_NUM-1];   //precision : 0.8
wire        [19:0]          data_conv_nxt                [0:KRN_HSZ-1];      //precision : 12.8
reg         [19:0]          data_conv                    [0:KRN_HSZ-1];      //precision : 12.8
wire        [19:0]          data_conv_add_nxt            [0:KRN_HSZ-1];      //precision : 12.8
reg         [19:0]          data_conv_add                [0:KRN_HSZ-1];      //precision : 12.8

wire        [20*3-1:0]      data_conv_que_nxt;
reg         [20*3-1:0]      data_conv_que;
wire        [11:0]          flt_sum_ar_nxt               [0:KRN_HSZ-1];      //precision : 4.8
reg         [11:0]          flt_sum_ar                   [0:KRN_HSZ-1];      //precision : 4.8
wire        [11:0]          flt_sum_ar_add_nxt           [0:KRN_HSZ-1];      //precision : 4.8
reg         [11:0]          flt_sum_ar_add               [0:KRN_HSZ-1];      //precision : 4.8

wire        [30:0]          conv_fin_data;                                   //precision : 12.19

wire        [11:0]          flt_recip;                                       //precision : 1.11
wire        [5:0]           prcis_idx;

//----------------------------------------------------------------------output
wire        [DATA_WD-1:0]   o_cv_data_nxt;
wire                        o_cv_dvld_nxt;
wire                        o_cv_hstr_nxt;
wire                        o_cv_hend_nxt;
wire                        vstr_keep_nxt;
wire                        vend_keep_nxt;
reg                         vstr_keep;
reg                         vend_keep;
wire                        o_cv_vstr_nxt;
wire                        o_cv_vend_nxt;

//----------------------------------------------------------------------FSM 
wire                        idle_smo;
wire                        delta_x_cnt_smo;
wire                        cnvl_smo;
wire                        out_enable_smo;
reg         [3:0]           bil_filter_ns;
reg         [3:0]           bil_filter_cs;

//----------------------------------------------------------------------for loop genvar
genvar                      flt_i,flt_i_2;
integer                     rst_i;   

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//-------------------------------------------------------------------control and constance 
assign filter_eq_ker         = delta_x_cnt_smo & (filter_cnt == 7-1'b1);                              //BIL_DELTA_X_CNT
assign pixel_num             = CNVL_PRE_NUM - KRN_HSZ_SHIFT -1 ;                                      //BIL_OUT_EN
assign filter_eq_hstr        = cnvl_smo        & (filter_cnt == CNVL_PRE_NUM);                        //BIL_CNVL status 
assign filter_eq_hend        = out_enable_smo  & (filter_cnt == pixel_num);                           //BIL_OUT_EN
assign filter_eq_vstr        = cnvl_smo        & (filter_cnt == CNVL_PRE_NUM-1);                      //BIL_CNVL status 

assign filter_cnt_nxt        = (filter_cnt_inc ? filter_cnt + 1'b1 : filter_cnt) & {4{~filter_cnt_clr}};                
assign filter_cnt_inc        = !idle_smo;
assign filter_cnt_clr        = (i_href & out_enable_smo) | idle_smo;

//-------------------------------------------------------------------input data 
assign i_data[0]             = i_data_0 ;
assign i_data[1]             = i_data_1 ;
assign i_data[2]             = i_data_2 ;

generate 
  for(flt_i=0;flt_i<KRN_VSZ;flt_i=flt_i+1) begin : que_data   
assign i_data_que_nxt[flt_i] = {i_data_que[flt_i][DATA_WD*7-1:0],i_data[flt_i]}; 
  end 
endgenerate

//-------------------------------------------------------------------delta x 
generate 
for(flt_i=0;flt_i<7;flt_i=flt_i+1) begin : delta_x_lut_gen

assign delta_x_lut[flt_i]    = DELTA_X[(flt_i+1)*7-1 : flt_i*7];    

end 
endgenerate
                                                                                                                                     //precision:5(r_bf_sigma_r) * 3.5(delta_x_lut) = 8.5
assign delta_x_sigma_r         = {13{delta_x_cnt_smo}} & (r_bf_sigma_r * delta_x_lut[filter_cnt]); 
assign delta_x_sigma_r_rnd     = delta_x_sigma_r + {|delta_x_sigma_r[4:0],5'b0};
assign delta_x_sigma_r_lut_nxt = delta_x_cnt_smo ? {delta_x_sigma_r_lut[8*6-1:0],delta_x_sigma_r_rnd[12:5]} : delta_x_sigma_r_lut ;  //precision : 8
//
//---------------------------------------------------pipe 0
generate 
  for(flt_i=0;flt_i<KRN_HSZ;flt_i=flt_i+1) begin : delta_x_and_delta_sgn
    for(flt_i_2=0;flt_i_2<KRN_VSZ;flt_i_2=flt_i_2+1) begin: delta_x_and_delta_sgn_2
assign delta_x_sgn[flt_i*KRN_VSZ + flt_i_2]     = $signed({1'b0,i_data_que[1][DATA_WD*(flt_i+1)-1:0+DATA_WD*flt_i]} - 
                                                          {1'b0,i_data_que[flt_i_2][DATA_WD*(KRN_HSZ_SHIFT+1)-1:0+DATA_WD*(KRN_HSZ_SHIFT)]});  
assign delta_x_sgn_bit[flt_i*KRN_VSZ + flt_i_2] = delta_x_sgn[flt_i*KRN_VSZ + flt_i_2][DATA_WD];
assign delta_x[flt_i*KRN_VSZ + flt_i_2]         = delta_x_sgn_bit[flt_i*KRN_VSZ + flt_i_2] ? -delta_x_sgn[flt_i*KRN_VSZ + flt_i_2] : delta_x_sgn[flt_i*KRN_VSZ + flt_i_2];
    end
  end 
endgenerate 

//in order to compatible 3*n kernel 
assign weight_dis_group[0]  = {delta_x_sgn[KERNEL_SHIFT]         [DATA_WD],delta_x[KERNEL_SHIFT]};                //7 //4
assign weight_dis_group[1]  = 0;
assign weight_dis_group[2]  = 0;
assign weight_dis_group[3]  = 0;


assign weight_dis_group[4]  = {delta_x_sgn[KERNEL_SHIFT-3]       [DATA_WD],delta_x[KERNEL_SHIFT-3][DATA_WD-1:0]}; //4  //1
assign weight_dis_group[5]  = {delta_x_sgn[KERNEL_SHIFT-1]       [DATA_WD],delta_x[KERNEL_SHIFT-1][DATA_WD-1:0]}; //6  //3
assign weight_dis_group[6]  = {delta_x_sgn[KERNEL_SHIFT+1]       [DATA_WD],delta_x[KERNEL_SHIFT+1][DATA_WD-1:0]}; //8  //5   
assign weight_dis_group[7]  = {delta_x_sgn[KERNEL_SHIFT+3]       [DATA_WD],delta_x[KERNEL_SHIFT+3][DATA_WD-1:0]}; //10 //7

assign weight_dis_group[8]  = {delta_x_sgn[KERNEL_SHIFT-4]       [DATA_WD],delta_x[KERNEL_SHIFT-4][DATA_WD-1:0]}; //3  //0
assign weight_dis_group[9]  = {delta_x_sgn[KERNEL_SHIFT-2]       [DATA_WD],delta_x[KERNEL_SHIFT-2][DATA_WD-1:0]}; //5  //2
assign weight_dis_group[10] = {delta_x_sgn[KERNEL_SHIFT+2]       [DATA_WD],delta_x[KERNEL_SHIFT+2][DATA_WD-1:0]}; //9  //6
assign weight_dis_group[11] = {delta_x_sgn[KERNEL_SHIFT+4]       [DATA_WD],delta_x[KERNEL_SHIFT+4][DATA_WD-1:0]}; //11 //8

assign weight_dis_group[12] = {delta_x_sgn[KERNEL_SHIFT-6]       [DATA_WD],delta_x[KERNEL_SHIFT-6][DATA_WD-1:0]}; //1
assign weight_dis_group[13] = {delta_x_sgn[KERNEL_SHIFT+6]       [DATA_WD],delta_x[KERNEL_SHIFT+6][DATA_WD-1:0]}; //13
assign weight_dis_group[14] = 0;
assign weight_dis_group[15] = 0;

assign weight_dis_group[16] = {delta_x_sgn[KERNEL_SHIFT-7]       [DATA_WD],delta_x[KERNEL_SHIFT-7][DATA_WD-1:0]}; //0
assign weight_dis_group[17] = {delta_x_sgn[KERNEL_SHIFT-5]       [DATA_WD],delta_x[KERNEL_SHIFT-5][DATA_WD-1:0]}; //2
assign weight_dis_group[18] = {delta_x_sgn[KERNEL_SHIFT+5]       [DATA_WD],delta_x[KERNEL_SHIFT+5][DATA_WD-1:0]}; //12
assign weight_dis_group[19] = {delta_x_sgn[KERNEL_SHIFT+7]       [DATA_WD],delta_x[KERNEL_SHIFT+7][DATA_WD-1:0]}; //14


//---------------------------------------------------pipe 1
generate 
  for (flt_i=0;flt_i<KERNEL_NUM+KRN_HSZ;flt_i=flt_i+1) begin : find_the_range
 assign comp_delta_x_zero[flt_i]  = |(weight_dis_group[flt_i][DATA_WD-1:0]);
 assign comp_delta_x_1_lsb[flt_i] = weight_dis_group[flt_i][DATA_WD-1:0] >= delta_x_sigma_r_lut[8*2-1:8*1];
 assign comp_delta_x_1_msb[flt_i] = weight_dis_group[flt_i][DATA_WD-1:0] >= delta_x_sigma_r_lut[8*6-1:8*5]; 
 assign delta_lut_0[flt_i]        = comp_delta_x_1_lsb[flt_i] ? delta_x_sigma_r_lut[8*3-1:8*2] : delta_x_sigma_r_lut[8*1-1:0  ];
 assign delta_lut_1[flt_i]        = comp_delta_x_1_msb[flt_i] ? delta_x_sigma_r_lut[8*7-1:8*6] : delta_x_sigma_r_lut[8*5-1:8*4];
 assign comp_delta_x_2_lsb[flt_i] = weight_dis_group[flt_i][DATA_WD-1:0] >= delta_lut_0[flt_i];
 assign comp_delta_x_2_msb[flt_i] = weight_dis_group[flt_i][DATA_WD-1:0] >= delta_lut_1[flt_i]; 
 assign comp_delta_x_0[flt_i]     = weight_dis_group[flt_i][DATA_WD-1:0] >= delta_x_sigma_r_lut[8*4-1:8*3];
 assign comp_delta_x_1[flt_i]     = comp_delta_x_0[flt_i] ? comp_delta_x_1_msb[flt_i] : comp_delta_x_1_lsb[flt_i];
 assign comp_delta_x_2[flt_i]     = comp_delta_x_0[flt_i] ? comp_delta_x_2_msb[flt_i] : comp_delta_x_2_lsb[flt_i];
 assign comp_delta_x_nxt[flt_i]   = {comp_delta_x_zero[flt_i],comp_delta_x_0[flt_i],comp_delta_x_1[flt_i],comp_delta_x_2[flt_i]};
 assign comp_sign_bit_nxt[flt_i]  = weight_dis_group[flt_i][DATA_WD];
  end 
endgenerate 

//----------------------------------------------- get kernel weighting  
generate
  for(flt_i=0;flt_i<KRN_HSZ;flt_i=flt_i+1) begin  : get_kernel
    for(flt_i_2=0;flt_i_2<8;flt_i_2=flt_i_2+1) begin : get_kernel_2
      always@* begin 
        ker_weight_0_lut[KRN_HSZ-flt_i-1][(flt_i_2+1)*8-1:(flt_i_2)*8] = FILTER_WHT_0[((KRN_HSZ-flt_i)*8-flt_i_2)*8-1:((KRN_HSZ-flt_i)*8-flt_i_2-1)*8];
        ker_weight_1_lut[KRN_HSZ-flt_i-1][(flt_i_2+1)*8-1:(flt_i_2)*8] = FILTER_WHT_1[((KRN_HSZ-flt_i)*8-flt_i_2)*8-1:((KRN_HSZ-flt_i)*8-flt_i_2-1)*8];
        ker_weight_lut[KRN_HSZ-flt_i-1][(flt_i_2+1)*8-1:(flt_i_2)*8]   = r_sigma_s_sel ? ker_weight_1_lut[KRN_HSZ-flt_i-1][(flt_i_2+1)*8-1:(flt_i_2)*8]:
                                                                                         ker_weight_0_lut[KRN_HSZ-flt_i-1][(flt_i_2+1)*8-1:(flt_i_2)*8]; 
      end
    end
  end 
endgenerate
                      


generate 
  for(flt_i=0;flt_i<KRN_HSZ;flt_i=flt_i+1) begin : find_weight
    for(flt_i_2=0;flt_i_2<4;flt_i_2=flt_i_2+1) begin : find_weight_2
  always@* begin 

               filter_x[flt_i*4+flt_i_2]    = 0;  
  
    case (comp_delta_x[flt_i*4+flt_i_2][2:0]) //synopsys full_case
      3'b000 : filter_x[flt_i*4+flt_i_2]    = ker_weight_lut[flt_i][7:0];
      3'b001 : filter_x[flt_i*4+flt_i_2]    = ker_weight_lut[flt_i][15:8];
      3'b010 : filter_x[flt_i*4+flt_i_2]    = ker_weight_lut[flt_i][23:16];
      3'b011 : filter_x[flt_i*4+flt_i_2]    = ker_weight_lut[flt_i][31:24];
      3'b100 : filter_x[flt_i*4+flt_i_2]    = ker_weight_lut[flt_i][39:32];
      3'b101 : filter_x[flt_i*4+flt_i_2]    = ker_weight_lut[flt_i][47:40];
      3'b110 : filter_x[flt_i*4+flt_i_2]    = ker_weight_lut[flt_i][55:48];
      3'b111 : filter_x[flt_i*4+flt_i_2]    = ker_weight_lut[flt_i][63:56];
    endcase
  end

  always@* begin 
    case (r_bf_op_mode)
      2'b00 : filter_x_out[flt_i*4+flt_i_2] = 1;
      2'b01 : filter_x_out[flt_i*4+flt_i_2] = (comp_delta_x[flt_i*4+flt_i_2][3]==0) ? 
                                              filter_x[flt_i*4+flt_i_2] : {DATA_WD{comp_sign_bit[flt_i*4+flt_i_2]}} & filter_x[flt_i*4+flt_i_2];
      2'b10 : filter_x_out[flt_i*4+flt_i_2] = {DATA_WD{~comp_sign_bit[flt_i*4+flt_i_2]}} & filter_x[flt_i*4+flt_i_2];
      2'b11 : filter_x_out[flt_i*4+flt_i_2] = filter_x[flt_i*4+flt_i_2];
    endcase
    end
  end
  end 
endgenerate  

//--------------------------------------------------convolution
assign flt_weight[KERNEL_SHIFT]   = filter_x_out[0];
assign flt_weight[KERNEL_SHIFT-3] = filter_x_out[4];
assign flt_weight[KERNEL_SHIFT-1] = filter_x_out[5];
assign flt_weight[KERNEL_SHIFT+1] = filter_x_out[6];
assign flt_weight[KERNEL_SHIFT+3] = filter_x_out[7];
assign flt_weight[KERNEL_SHIFT-4] = filter_x_out[8];
assign flt_weight[KERNEL_SHIFT-2] = filter_x_out[9];
assign flt_weight[KERNEL_SHIFT+2] = filter_x_out[10];
assign flt_weight[KERNEL_SHIFT+4] = filter_x_out[11];
assign flt_weight[KERNEL_SHIFT-6] = filter_x_out[12];
assign flt_weight[KERNEL_SHIFT+6] = filter_x_out[13];
assign flt_weight[KERNEL_SHIFT-7] = filter_x_out[16];
assign flt_weight[KERNEL_SHIFT-5] = filter_x_out[17];
assign flt_weight[KERNEL_SHIFT+5] = filter_x_out[18];
assign flt_weight[KERNEL_SHIFT+7] = filter_x_out[19];

generate 
  for(flt_i=0;flt_i<KRN_HSZ;flt_i=flt_i+1) begin : data_convolution  //convolution need to wait 3T (pipe0 + pipe1)
assign data_conv_nxt[flt_i] = {12'h0,i_data_que[0][DATA_WD*(KRN_HSZ_SHIFT+2)-1:0+DATA_WD*(KRN_HSZ_SHIFT+1)]} * {12'h0,flt_weight[flt_i*KRN_VSZ + 0]} +  
                              {12'h0,i_data_que[1][DATA_WD*(KRN_HSZ_SHIFT+2)-1:0+DATA_WD*(KRN_HSZ_SHIFT+1)]} * {12'h0,flt_weight[flt_i*KRN_VSZ + 1]} + 
                              {12'h0,i_data_que[2][DATA_WD*(KRN_HSZ_SHIFT+2)-1:0+DATA_WD*(KRN_HSZ_SHIFT+1)]} * {12'h0,flt_weight[flt_i*KRN_VSZ + 2]} ;
  end 
endgenerate

assign data_conv_add_nxt[0] = data_conv[0];
assign data_conv_add_nxt[1] = data_conv_add[0] + data_conv[1];
assign data_conv_add_nxt[2] = data_conv_add[1] + data_conv[2];
assign data_conv_add_nxt[3] = data_conv_add[2] + data_conv[3];
assign data_conv_add_nxt[4] = data_conv_add[3] + data_conv[4];

assign data_conv_que_nxt    = {data_conv_que[20*2-1:0],data_conv_add[KRN_HSZ-1]}; //precision : 12.8


generate 
  for(flt_i=0;flt_i<KRN_HSZ;flt_i=flt_i+1) begin : filter_summation               //precision : 4.8
assign flt_sum_ar_nxt[flt_i] = flt_weight[flt_i*3] + flt_weight[flt_i*3+1] + flt_weight[flt_i*3+2];
  end 
endgenerate


assign flt_sum_ar_add_nxt[0] = flt_sum_ar[0];
assign flt_sum_ar_add_nxt[1] = flt_sum_ar_add[0] + flt_sum_ar[1];
assign flt_sum_ar_add_nxt[2] = flt_sum_ar_add[1] + flt_sum_ar[2];
assign flt_sum_ar_add_nxt[3] = flt_sum_ar_add[2] + flt_sum_ar[3];
assign flt_sum_ar_add_nxt[4] = flt_sum_ar_add[3] + flt_sum_ar[4];

assign conv_fin_data   = data_conv_que[20*2-1:20*1] * flt_recip[10:0] + (({31{prcis_idx[0]}}  & {20'b0,1'b1,10'b0}) |   //use a*b + c coding style 
                                                                        ( {31{prcis_idx[1]}}  & {18'b0,1'b1,12'b0}) | 
                                                                        ( {31{prcis_idx[2]}}  & {16'b0,1'b1,14'b0}) | 
                                                                        ( {31{prcis_idx[3]}}  & {14'b0,1'b1,16'b0}) | 
                                                                        ( {31{prcis_idx[4]}}  & {12'b0,1'b1,18'b0}) |   //rounding the convolution output
                                                                        ( {31{prcis_idx[5]}}  & {11'b0,1'b1,19'b0}));                     

//--------------------------------------------------output

assign o_cv_data_nxt   = ({8{prcis_idx[0]}}  & conv_fin_data[18:11]) | // precision : 12.19 => 8
                         ({8{prcis_idx[1]}}  & conv_fin_data[20:13]) |
                         ({8{prcis_idx[2]}}  & conv_fin_data[22:15]) |
                         ({8{prcis_idx[3]}}  & conv_fin_data[24:17]) |
                         ({8{prcis_idx[4]}}  & conv_fin_data[26:19]) |
                         ({8{prcis_idx[5]}}  & conv_fin_data[27:20]) ;

assign o_cv_dvld_nxt   = out_enable_smo;
assign o_cv_hstr_nxt   = filter_eq_hstr;
assign o_cv_hend_nxt   = filter_eq_hend;
assign vstr_keep_nxt   = (vstr_keep | i_vstr) & !o_cv_vstr;
assign vend_keep_nxt   = (vend_keep | i_vend) & !o_cv_vend;
assign o_cv_vstr_nxt   = vstr_keep & filter_eq_vstr;
assign o_cv_vend_nxt   = vend_keep & o_cv_hend;

//--------------------------------------------------FSM 
assign idle_smo        = bil_filter_cs[0];
assign delta_x_cnt_smo = bil_filter_cs[1];
assign cnvl_smo        = bil_filter_cs[2];
assign out_enable_smo  = bil_filter_cs[3];

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

ip_recip12p11
#(
    .PRCIS_EXT      (PRCIS_EXT),             // "LVL_0"/"LVL_1"/"LVL_2"
    .DENM_ZERO      (DENM_ZERO)              // output value definition, if denominator == 0
) 
ip_recip12p11
(
  .o_recip          (flt_recip),             // reciprocal value. precision: 1.11
  .o_prcis_idx      (prcis_idx),             // precision index

  .i_denm           (flt_sum_ar_add[KRN_HSZ-1]),   

  .clk              (clk),        
  .rst_n            (rst_n)         
);

always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin 
//-----------------------------------------------delta x 
  delta_x_sigma_r_lut     <= 0;

//-----------------------------------------------control and constance 
  filter_cnt              <= 0;

//-----------------------------------------------convolution
  data_conv_que           <= 0;

//-----------------------------------------------output
  vstr_keep               <= 0;
  vend_keep               <= 0;
  o_cv_data               <= 0;
  o_cv_dvld               <= 0;
  o_cv_hstr               <= 0;
  o_cv_hend               <= 0;
  o_cv_vstr               <= 0;
  o_cv_vend               <= 0;

end
else begin 
//-----------------------------------------------delta x 
  delta_x_sigma_r_lut     <= delta_x_sigma_r_lut_nxt;

//-----------------------------------------------control and constance 
  filter_cnt              <= filter_cnt_nxt;

//-----------------------------------------------convolution
  data_conv_que           <= data_conv_que_nxt;

//-----------------------------------------------output
  vstr_keep               <= vstr_keep_nxt;
  vend_keep               <= vend_keep_nxt;
  o_cv_data               <= o_cv_data_nxt;
  o_cv_dvld               <= o_cv_dvld_nxt;
  o_cv_hstr               <= o_cv_hstr_nxt;
  o_cv_hend               <= o_cv_hend_nxt;
  o_cv_vstr               <= o_cv_vstr_nxt;
  o_cv_vend               <= o_cv_vend_nxt;

end 
end 

always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin 
//-----------------------------------------------input data 
  for(rst_i=0;rst_i<KRN_VSZ;rst_i=rst_i+1) begin
  i_data_que[rst_i]       <= 0;
  end 

//-----------------------------------------------delta x 
  for(rst_i=0;rst_i<KERNEL_NUM+KRN_HSZ;rst_i=rst_i+1) begin
  comp_delta_x[rst_i]     <= 0;
  comp_sign_bit[rst_i]    <= 0;
  end

//-----------------------------------------------convolution
  for(rst_i=0;rst_i<KRN_HSZ;rst_i=rst_i+1) begin
  data_conv[rst_i]        <= 0;
  flt_sum_ar[rst_i]       <= 0;
  flt_sum_ar_add[rst_i]   <= 0;
  data_conv_add[rst_i]    <= 0;
  end 

end
else begin
//-----------------------------------------------input data 
  for(rst_i=0;rst_i<KRN_VSZ;rst_i=rst_i+1) begin
  i_data_que[rst_i]       <= i_data_que_nxt[rst_i];
  end 

//-----------------------------------------------delta x 
  for(rst_i=0;rst_i<KERNEL_NUM+KRN_HSZ;rst_i=rst_i+1) begin
  comp_delta_x[rst_i]     <= comp_delta_x_nxt[rst_i];
  comp_sign_bit[rst_i]    <= comp_sign_bit_nxt[rst_i];
  end 

//-----------------------------------------------convolution
  for(rst_i=0;rst_i<KRN_HSZ;rst_i=rst_i+1) begin
  data_conv[rst_i]        <= data_conv_nxt[rst_i];
  flt_sum_ar[rst_i]       <= flt_sum_ar_nxt[rst_i];
  flt_sum_ar_add[rst_i]   <= flt_sum_ar_add_nxt[rst_i];
  data_conv_add[rst_i]    <= data_conv_add_nxt[rst_i];
  end 

end 
end 

always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin 
  bil_filter_cs           <= BIL_IDLE;
end
else begin 
  bil_filter_cs           <= bil_filter_ns;
end 
end 


endmodule 
