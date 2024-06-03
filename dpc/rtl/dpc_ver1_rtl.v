 // +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2023
//
// File Name:           
// Author:              Willy Lin
// Version:             1.0
// Date:                2023
// Last Modified On:    
// Last Modified By:    
// limitation : SQRT_COPW       > R_RTO_THRES_CIW
//              SQRT_RECIP_COPW > RAW_CIIW
//
// i_raw_data matrix 
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_1[00] | step_2_color_2[00] | step_2_color_1[01] | step_2_color_2[01] | step_2_color_1[04] | step_2_color_2[02] | step_2_color_1[05] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_3[00] | step_1_color_4[00] | step_2_color_3[01] | step_1_color_4[01] | step_2_color_3[06] | step_1_color_4[02] | step_2_color_3[07] | 
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_1[02] | step_2_color_2[03] | step_2_color_1[03] | step_2_color_2[05] | step_2_color_1[07] | step_2_color_2[04] | step_2_color_1[06] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_3[02] | step_1_color_4[03] | step_2_color_3[05] | target pixel       | step_2_color_3[11] | step_1_color_4[05] | step_2_color_3[08] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_1[08] | step_2_color_2[06] | step_2_color_1[11] | step_2_color_2[11] | step_2_color_1[15] | step_2_color_2[07] | step_2_color_1[12] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_3[03] | step_1_color_4[06] | step_2_color_3[04] | step_1_color_4[07] | step_2_color_3[09] | step_1_color_4[08] | step_2_color_3[10] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_1[09] | step_2_color_2[08] | step_2_color_1[10] | step_2_color_2[09] | step_2_color_1[13] | step_2_color_2[10] | step_2_color_1[14] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |

// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------

module dpc_modify

   #( 
      //---------------------------------------------raw data precision 
      parameter  RAW_CIIW           = 10,
      parameter  RAW_CIPW           = 0,
      
      //---------------------------------------------noise level map precision
      parameter  GAIN_CIIW          = 5,
      parameter  GAIN_CIPW          = 4,
      parameter  BLC_TGT_CIIW       = 12, //S.11
      parameter  BLC_TGT_CIPW       = 0, 
      parameter  CGCF_CIIW          = 0,
      parameter  CGCF_CIPW          = 12,
      parameter  PARM1_CIIW         = 0,
      parameter  PARM1_CIPW         = 10,
      parameter  PARM2_CIIW         = 0,
      parameter  PARM2_CIPW         = 4,
      
      parameter  SQRT_CIIW          = 14, 
      parameter  SQRT_CIPW          = 4, 
      parameter  SQRT_COIW          = 7, 
      parameter  SQRT_COPW          = 5, 
      parameter  SQRT_RECIP_COIW    = 0, 
      parameter  SQRT_RECIP_COPW    = 10,  //must bigger than RAW_CIIW

      //---------------------------------------------output data precision  //local parameter //[don't modify]
      parameter  DPC_COIW           = RAW_CIIW, 
      parameter  DPC_COPW           = RAW_CIPW, 

      //---------------------------------------------register precision 
      parameter  R_LOW_NLM_CIIW     = 3,
      parameter  R_LOW_NLM_CIPW     = 2,
      parameter  R_RTO_THRES_CIIW   = 3,
      parameter  R_RTO_THRES_CIPW   = 2,
      parameter  R_CNT_THRES_CIIW   = 4,
      parameter  R_CNT_THRES_CIPW   = 2,

      //-----------------------------------------------------------------------------------------------------------step 1 ratio precision 
      parameter  RTO_CIW            = 4,  //step 1 ratio precision 

      //-----------------------------------------------------------------------------------------------------------step 2 ratio precision 
      parameter  SCORE_STG_0_CIW    = 6,  //step 2 ratio precision
      parameter  SCORE_STG_1_N3_CIW = 2,  //color 0 step_2_color_score_stage_3 integer precision 
      parameter  SCORE_STG_1_N5_CIW = 3,  //color 1 & color 2 step_2_color_score_stage_3 integer precision

      //---------------------------------------------total precision    //local parameter //[don't modify] 
      parameter  SHOT_CIIW          = GAIN_CIIW-1, 
      parameter  SHOT_CIPW          = CGCF_CIPW, 
      parameter  ROUT_CIIW          = (GAIN_CIIW-1+PARM1_CIIW)*2,
      parameter  ROUT_CIPW          = CGCF_CIPW, 
      parameter  RAW_CIW            = RAW_CIIW + RAW_CIPW,
      parameter  BLC_CIW            = BLC_TGT_CIIW + BLC_TGT_CIPW,
      parameter  SHOT_CIW           = SHOT_CIIW + SHOT_CIPW,
      parameter  ROUT_CIW           = ROUT_CIIW + ROUT_CIPW,
      parameter  DPC_COW            = DPC_COIW + DPC_COPW,
      parameter  SQRT_CIW           = SQRT_CIIW + SQRT_CIPW,
      parameter  SQRT_COW           = SQRT_COIW + SQRT_COPW,
      parameter  SQRT_RECIP_COW     = SQRT_RECIP_COIW + SQRT_RECIP_COPW,
      parameter  R_LOW_NLM_CIW      = R_LOW_NLM_CIIW + R_LOW_NLM_CIPW,
      parameter  R_RTO_THRES_CIW    = R_RTO_THRES_CIIW + R_RTO_THRES_CIPW,
      parameter  R_CNT_THRES_CIW    = R_CNT_THRES_CIIW + R_CNT_THRES_CIPW,

      //---------------------------------------------sqrt ip precision //local parameter //[don't modify]  
      parameter  IP_SQRT_IWID       = SQRT_CIW,
      parameter  IP_SQRT_OEXD       = (SQRT_COPW-SQRT_CIPW/2), 
      parameter  IP_SQRT_ORPCS      = SQRT_RECIP_COW+(SQRT_CIPW/2),
      
      //---------------------------------------------config
      parameter  MODE_SEL           = 1, //1 : static mode , 2 : dynamic mode , 3 : static + dynamic mode 
      parameter  IMG_HSZ            = 1920,
      parameter  IMG_VSZ            = 1080,
      parameter  DEBUG_MODE         = 0, 
      
      //---------------------------------------------width  //local parameter //[don't modify] 
      parameter  IMG_HSZ_WTH        = $clog2(IMG_HSZ),
      parameter  IMG_VSZ_WTH        = $clog2(IMG_VSZ),

      //---------------------------------------------cnt   
      parameter  MAX_DPC_NUM        = 512,
      parameter  MAX_DPC_NUM_WTH    = $clog2(MAX_DPC_NUM),
      parameter  MAX_COORD_NUM      = 20,
      parameter  MAX_COORD_NUM_WTH  = $clog2(MAX_COORD_NUM)
            
     )

(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
   output reg  [DPC_COW-1:0]         o_data,
   output reg                        o_href,
   output reg                        o_vstr,
   output reg                        o_hstr,
   output reg                        o_hend,
   output reg                        o_vend,
   output reg  [MAX_DPC_NUM_WTH-1:0] o_wdpc_cnt,           //white point counter , contain static and dynamic 
   output reg  [MAX_DPC_NUM_WTH-1:0] o_bdpc_cnt,
   output reg  [MAX_COORD_NUM-1:0]   o_static_num_cnt,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
   input       [RAW_CIW*49-1 : 0]      i_raw_data , 
   input       [BLC_CIW-1 : 0]         i_blc_dc_dlt_cu, 
   input       [SHOT_CIW-1 : 0]        i_shot_nvar_bs_cu,
   input       [ROUT_CIW-1 : 0]        i_rout_nvar_bs_cu ,
  
   input                               i_hstr,
   input                               i_href,
   input                               i_hend,
   input                               i_vstr,
   input                               i_vend,
   
   input                               i_dead_col,
 
   input       [R_LOW_NLM_CIW+1-1:0]   i_step1_w_high_nlm_cu,    //precision : 3.2 + 3.0  
   input       [R_LOW_NLM_CIW+1-1:0]   i_step1_b_high_nlm_cu,    //precision : 3.2 + 3.0
   input       [IMG_HSZ_WTH-1:0]       i_haddr_mirr_cu,
   input       [R_RTO_THRES_CIW-1:0]   i_step2_w_rto_thres_rng_cu,
   input       [R_RTO_THRES_CIW-1:0]   i_step2_b_rto_thres_rng_cu,
   input       [R_RTO_THRES_CIW+2-1:0] i_step2_w_rto_thres_3_cu,
   input       [R_RTO_THRES_CIW+2-1:0] i_step2_b_rto_thres_3_cu,
   input       [R_RTO_THRES_CIW+3-1:0] i_step2_w_rto_thres_5_cu,
   input       [R_RTO_THRES_CIW+3-1:0] i_step2_b_rto_thres_5_cu,
 
   input       [R_LOW_NLM_CIW-1:0]     r_step1_w_low_nlm,     //precision : 3.2 //range : 0~7.75    
   input       [2:0]                   r_step1_w_transit_rng, //range : {1,2,4}
   input       [R_LOW_NLM_CIW-1:0]     r_step1_b_low_nlm,     //precision : 3.2 //range : 0~7.75
   input       [2:0]                   r_step1_b_transit_rng, //range : {1,2,4}
           
   input       [R_RTO_THRES_CIW-1:0]   r_step2_w_rto_thres,   //precision : 3.2 //range : 0~7.75
   input       [2:0]                   r_step2_w_buf_rng,     //range : {1,2,4}
   input       [R_RTO_THRES_CIW-1:0]   r_step2_b_rto_thres,   //precision : 3.2 //range : 0~7.75
   input       [2:0]                   r_step2_b_buf_rng,     //range : {1,2,4}
         
   input       [R_CNT_THRES_CIW-1:0]   r_step2_w_cnt_thres,   //precision : 4.2 //range : 0~8
   input       [2:0]                   r_step2_w_cnt_buf_rng, //range : {1,2,4}
   input       [R_CNT_THRES_CIW-1:0]   r_step2_b_cnt_thres,   //precision : 4.2 //range : 0~8
   input       [2:0]                   r_step2_b_cnt_buf_rng, //range : {1,2,4}

   input                               r_dpc_en,              //0:not replace 1: replace if dpc          
   input                               r_debug_en,            //0:detect and replace , 1:detect and use r_repl_col to enhance color 
   input       [1:0]                   r_mode_sel,            //0:close all function, 1:static mode 2: dynamic mode 3: mix mode 
   input       [7:0]                   r_repl_col,            // enhance dpc in debug mode , replace 8 bit of msb      
         
   input       [64*8-1:0]              r_static_coord,        
   input                               r_coord_mirror, 
   input       [10:0]                  r_haddr_start,
   input       [10:0]                  r_ver_addr,
         
   input                               dpc_clk,
   input                               dpc_rst_n
);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//
//-----------------------------------------------------------------------------------------------------------delay 
localparam    STEP_1_ALL_SAME_DLY          = 1; // all_same_nxt
localparam    STEP_1_BIT_RESULT_DLY        = 1; // bit_result_max_nxt
localparam    STEP_1_RAW_MAX_MIN_DLY       = 1; // raw_max_fnl_nxt , raw_min_fnl_nxt
localparam    STEP_1_RAW_FNL_SEL_DLY       = 1; // raw_fnl_sel_num_nxt
localparam    STEP_1_PTNL_DLY              = 1; // ptnl_w_point_nxt
localparam    STEP_1_NLM_RTO_DLY           = 1; // nlm_rto_sgn_nxt
localparam    STEP_1_SCORE_DLY             = 1; // df_step_1_score_nxt
localparam    RECIP_DLY                    = 3; // ip_sqrt_pw
localparam    NLM_CLIP_DLY                 = 1; // nlm_clip_nxt
localparam    TOTAL_NLM_DLY                = 1; // total_nlm_nxt 
localparam    TOTAL_NLM_CLIP_DLY           = 1; // total_nlm_clip_nxt
localparam    STEP_2_MAX_MIN_DLY           = 1; // step_2_color_1_max_sgn_nxt , step_2_color_1_min_sgn_nxt
localparam    STEP_2_COL_CLIP              = 1; // step_2_color_1_clip_sgn_nxt
localparam    STEP_2_COL_SUM_DLY           = 2; // step_2_color_1_sum_sgn_nxt
localparam    STEP_2_STG_0_DLY             = 1; // step_2_color_1_score_stage_0_sgn_nxt
localparam    STEP_2_STG_1_DLY             = 1; // step_2_color_1_score_stage_1_sgn_nxt
localparam    STEP_2_SEL_NUM_DLY           = 1; // tep_2_color_1_sel_num_0_sgn_nxt
localparam    STEP_2_TOTAL_SUM_DLY         = 2; // step_2_color_total_sum_nxt
localparam    STEP_2_SCORE_INV             = 1; //df_step_2_score_inv_nxt
localparam    STEP_2_ALL_SCR_DLY           = 1; // df_all_step_score_nxt
localparam    STEP_2_RPEL_PX_DLY           = 1; // repl_pixel_nxt
localparam    OUTPUT_DLY                   = 1; // o_data_nxt
localparam    STATIC_DLY                   = 1;

/*
localparam    PIPE_STEP_1_1_RAW_MAX_MIN    = STEP_1_PTNL_DLY;
localparam    PIPE_STEP_1_1_PTNL           = PIPE_STEP_1_1_RAW_MAX_MIN + STEP_1_RAW_MAX_MIN_DLY;
localparam    PIPE_NLM_1_RAW_0             = PIPE_STEP_1_1_RAW_MAX_MIN + TOTAL_NLM_CLIP_DLY + RECIP_DLY;
localparam    PIPE_NLM_1_RAW_1             = TOTAL_NLM_CLIP_DLY + RECIP_DLY;
localparam    PIPE_STEP_1_2_SCR            = PIPE_NLM_1_RAW_0 + STEP_1_NLM_RTO_DLY + STEP_1_SCORE_DLY;
localparam    PIPE_STEP_2_1_TOTAL_SCR      = PIPE_NLM_1 + STEP_2_COL_CLIP + STEP_2_COL_SUM_DLY + STEP_2_STG_0_DLY + STEP_2_TOTAL_SUM_DLY;
lcoalparam    PIPE_STEP_2_2_ALL_SCR        = PIPE_STEP_2_1_TOTAL_SCR + STEP_2_ALL_SCR_DLY;
localparam    PIPE_OUTPUT                  = PIPE_STEP_2_2_ALL_SCR + OUTPUT_DLY;
*/

localparam    COM_CLR_4_DLY                = (STEP_1_ALL_SAME_DLY + STEP_1_BIT_RESULT_DLY)          - 1;
localparam    COM_STEP_1_RAW_FNL_DLY       = (STEP_1_ALL_SAME_DLY + STEP_1_BIT_RESULT_DLY + 
                                              STEP_1_RAW_MAX_MIN_DLY)                               - 1;
localparam    COM_NLM_IP_DLY               = (NLM_CLIP_DLY + TOTAL_NLM_DLY + 
                                              TOTAL_NLM_CLIP_DLY + RECIP_DLY);
localparam    COM_STEP_1_RAW_MAX_MIN_DLY   = (COM_NLM_IP_DLY+STEP_1_ALL_SAME_DLY+
                                              STEP_1_BIT_RESULT_DLY+STEP_1_RAW_MAX_MIN_DLY+
                                              STEP_1_RAW_FNL_SEL_DLY)                               - (STEP_1_ALL_SAME_DLY+STEP_1_BIT_RESULT_DLY+STEP_1_RAW_MAX_MIN_DLY+1);   
localparam    COM_STEP_1_NLM_RTO_DLY       = (COM_STEP_1_RAW_MAX_MIN_DLY + STEP_1_NLM_RTO_DLY);                                   
localparam    COM_STEP_2_COL_MAX_MIN_DLY   = (COM_NLM_IP_DLY)                                       - (STEP_1_ALL_SAME_DLY+STEP_1_BIT_RESULT_DLY+STEP_1_RAW_MAX_MIN_DLY+1);   

localparam    COM_STEP_2_COL_CLIP_DLY      = (COM_NLM_IP_DLY + STEP_2_MAX_MIN_DLY);                          
localparam    COM_STEP_2_COL_SUM_DLY       = (COM_STEP_2_COL_CLIP_DLY + STEP_2_COL_CLIP + 
                                              STEP_2_COL_SUM_DLY);                                                            
localparam    COM_STEP_2_COL_SEL_NUM_DLY   = (COM_STEP_2_COL_SUM_DLY)                               - (STEP_1_ALL_SAME_DLY+STEP_1_BIT_RESULT_DLY+STEP_1_PTNL_DLY+1);
localparam    COM_STEP_2_COL_NLM_REC_DLY   = (COM_STEP_2_COL_SUM_DLY+STEP_2_SEL_NUM_DLY+
                                              STEP_2_STG_0_DLY)            - (COM_NLM_IP_DLY+1);    
localparam    COM_STEP_2_COL_STG_1_DLY     = (COM_STEP_2_COL_SEL_NUM_DLY + STEP_2_STG_0_DLY+
                                              STEP_2_STG_1_DLY);

localparam    COM_STEP_2_COL_TOL_SUM_DLY   = (COM_STEP_2_COL_STG_1_DLY + STEP_2_SEL_NUM_DLY + 
                                              STEP_2_TOTAL_SUM_DLY);
localparam    COM_STEP_2_ALL_SCR_DLY       = (COM_STEP_2_COL_SUM_DLY+STEP_2_SEL_NUM_DLY+
                                              STEP_2_STG_0_DLY+STEP_2_STG_1_DLY+
                                              STEP_2_TOTAL_SUM_DLY+STEP_2_SCORE_INV)                - (COM_NLM_IP_DLY+STEP_1_RAW_FNL_SEL_DLY+STEP_1_ALL_SAME_DLY+STEP_1_BIT_RESULT_DLY+
                                                                                                       STEP_1_RAW_MAX_MIN_DLY +STEP_1_NLM_RTO_DLY + 1); 
localparam    COM_STEP_2_REPL_DLY          = (COM_STEP_2_COL_SUM_DLY + STEP_2_STG_0_DLY+
                                              STEP_2_STG_1_DLY + STEP_2_SEL_NUM_DLY + 
                                              STEP_2_TOTAL_SUM_DLY + STEP_2_SCORE_INV+
                                              STEP_2_ALL_SCR_DLY)                                   - (STEP_1_ALL_SAME_DLY+STEP_1_BIT_RESULT_DLY+1);
localparam    COM_STEP_2_REPL_RAW_FNL_DLY  = (COM_STEP_2_COL_SUM_DLY + STEP_2_STG_0_DLY+
                                              STEP_2_SEL_NUM_DLY + STEP_2_STG_1_DLY + 
                                              STEP_2_TOTAL_SUM_DLY + STEP_2_ALL_SCR_DLY+
                                              STEP_2_SCORE_INV)                                     - (STEP_1_ALL_SAME_DLY+STEP_1_BIT_RESULT_DLY+STEP_1_RAW_MAX_MIN_DLY+1);
localparam    COM_STEP_2_TARGET_REPL       = (COM_STEP_2_REPL_DLY+1)                                - (COM_STEP_1_RAW_MAX_MIN_DLY-1);
localparam    COM_STEP_2_TAR_REPL_DLY      = (COM_STEP_2_REPL_DLY + STEP_2_RPEL_PX_DLY);
localparam    COM_STA_FNL_STA_SEL_DLY      = (COM_STEP_2_COL_SUM_DLY + STEP_2_SEL_NUM_DLY+
                                              STEP_2_STG_0_DLY + STEP_2_STG_1_DLY + 
                                              STEP_2_TOTAL_SUM_DLY + STEP_2_SCORE_INV+
                                              STEP_2_ALL_SCR_DLY + STEP_2_RPEL_PX_DLY)              - (STEP_1_ALL_SAME_DLY+STEP_1_BIT_RESULT_DLY+STEP_1_RAW_MAX_MIN_DLY+1);
localparam    COM_STA_ALL_SCORE_DLY        = (STEP_1_PTNL_DLY+COM_NLM_IP_DLY+
                                              STEP_2_MAX_MIN_DLY+STEP_2_COL_SUM_DLY+
                                              STEP_2_COL_CLIP+STEP_2_STG_0_DLY+
                                              STEP_2_STG_1_DLY+STEP_2_SEL_NUM_DLY+
                                              STEP_2_TOTAL_SUM_DLY+STEP_2_SCORE_INV)                - (STATIC_DLY+1);                       
localparam    COM_STA_TARGET_REPL_DLY      = (COM_STEP_2_COL_SUM_DLY + STEP_2_SEL_NUM_DLY+
                                              STEP_2_STG_0_DLY + STEP_2_STG_1_DLY + 
                                              STEP_2_TOTAL_SUM_DLY + STEP_2_SCORE_INV+
                                              STEP_2_ALL_SCR_DLY + STEP_2_RPEL_PX_DLY)              - 1;
localparam    COM_VIDEO_DLY                = (COM_STEP_2_COL_SUM_DLY + STEP_2_SEL_NUM_DLY+
                                              STEP_2_STG_0_DLY + STEP_2_STG_1_DLY + 
                                              STEP_2_TOTAL_SUM_DLY + STEP_2_SCORE_INV+
                                              STEP_2_ALL_SCR_DLY + STEP_2_RPEL_PX_DLY);                                                   

//-----------------------------------------------------------------------------------------------------------local parameter 
localparam    KRNV_SZ                      = 7;  //kernel vertical size
localparam    COLOR_ARRAY_NUM_0            = 16; //16 number of color 0 
localparam    COLOR_ARRAY_NUM_1            = 12; //12 number of color 1 and color 2
localparam    COLOR_ARRAY_NUM_2            = 9;  //9 number of color 3
localparam    STAGE_1_DATA_NUM_4           = 4;  //one column have 4 color 0 & color 2 , one row have 4 color 1 
localparam    STAGE_1_DATA_NUM_3           = 3;  //one column have 3 color 1 & color 3 , one row have 3 color 2 
localparam    STAGE_2_NBR_4                = 4;  //around target pixel have 4 color 0 , each stage 2 region have 4 color 0
localparam    STAGE_2_NBR_2                = 2;  //around target pixel have 2 color 1 & color 2
localparam    STAGE_2_NBR_2_SUB_6          = 6;  //each stage 2 region have 6 color 1 & color 2

//-----------------------------------------------------------------------------------------------------------static coord 
localparam    COORD_NUM                    = 20;
localparam    COORD_WTH                    = 24;

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
//-----------------------------------------------------------------------------------------------------------static dpc 
wire                                                                   coord_h_eq;
wire                                                                   coord_v_eq;
reg         [64*8-1:0]                                                 coord_sft;
wire        [64*8-1:0]                                                 coord_sft_nxt;
wire                                                                   coord_dp;
wire        [10:0]                                                     coord_v;
reg                                                                    coord_bw;
wire                                                                   coord_bw_nxt;
reg         [(COM_STEP_1_RAW_FNL_DLY+2)-1:0]                           coord_bw_que;
wire        [(COM_STEP_1_RAW_FNL_DLY+2)-1:0]                           coord_bw_que_nxt;
wire        [10:0]                                                     coord_h;
reg                                                                    coord_total_eq; 
wire                                                                   coord_total_eq_nxt; 
reg         [(COM_STA_TARGET_REPL_DLY+2)-1:0]                          coord_total_eq_que;
wire        [(COM_STA_TARGET_REPL_DLY+2)-1:0]                          coord_total_eq_que_nxt;
reg         [RAW_CIW-1:0]                                              raw_fnl_sta_sel_num;
wire        [RAW_CIW-1:0]                                              raw_fnl_sta_sel_num_nxt;
reg         [RAW_CIW*(COM_STA_FNL_STA_SEL_DLY+2)-1:0]                  raw_fnl_sta_sel_num_que;
wire        [RAW_CIW*(COM_STA_FNL_STA_SEL_DLY+2)-1:0]                  raw_fnl_sta_sel_num_que_nxt;
reg         [COORD_NUM-1:0]                                            coord_sft_en;
wire        [COORD_NUM-1:0]                                            coord_sft_en_nxt;
reg         [COORD_WTH-1:0]                                            coord_fnl;

//-----------------------------------------------------------------------------------------------------------counter       
reg  signed [IMG_HSZ_WTH+1-1:0]                                        dpc_hor_cnt;             //1 for signed bit    
wire signed [IMG_HSZ_WTH+1-1:0]                                        dpc_hor_cnt_nxt;         //1 for signed bit    
wire                                                                   dpc_hor_cnt_inc;
wire                                                                   dpc_hor_cnt_clr;
wire                                                                   dpc_hor_cnt_set;
wire        [IMG_HSZ_WTH-1:0]                                          dpc_hor_cnt_set_val;

reg         [IMG_VSZ_WTH-1:0]                                          dpc_ver_cnt;
wire        [IMG_VSZ_WTH-1:0]                                          dpc_ver_cnt_nxt;
wire                                                                   dpc_ver_cnt_inc;
wire                                                                   dpc_ver_cnt_clr;

reg         [MAX_COORD_NUM_WTH-1:0]                                    static_num_cnt;    
wire        [MAX_COORD_NUM_WTH-1:0]                                    static_num_cnt_nxt;
wire                                                                   static_num_cnt_inc;
wire                                                                   static_num_cnt_clr;

reg         [MAX_DPC_NUM_WTH-1:0]                                      dpc_wh_cnt;     
wire        [MAX_DPC_NUM_WTH-1:0]                                      dpc_wh_cnt_nxt;
wire                                                                   dpc_wh_cnt_inc;
wire                                                                   dpc_wh_cnt_clr;

reg         [MAX_DPC_NUM_WTH-1:0]                                      dpc_bk_cnt;     
wire        [MAX_DPC_NUM_WTH-1:0]                                      dpc_bk_cnt_nxt;
wire                                                                   dpc_bk_cnt_inc;
wire                                                                   dpc_bk_cnt_clr;

//-----------------------------------------------------------------------------------------------------------dpc step 1 find max and min number 
wire        [KRNV_SZ*RAW_CIW-1:0]                                      line_array                      [0:KRNV_SZ-1];
wire        [COLOR_ARRAY_NUM_0*RAW_CIW-1:0]                            step_1_color_1;     //number : 16
wire        [COLOR_ARRAY_NUM_1*RAW_CIW-1:0]                            step_1_color_2;     //number : 12
wire        [COLOR_ARRAY_NUM_1*RAW_CIW-1:0]                            step_1_color_3;     //number : 12
reg         [COLOR_ARRAY_NUM_2*RAW_CIW-1:0]                            step_1_color_4;     //number : 9
wire        [COLOR_ARRAY_NUM_2*RAW_CIW-1:0]                            step_1_color_4_nxt; //number : 9
reg         [COLOR_ARRAY_NUM_2*RAW_CIW*(COM_CLR_4_DLY+2)-1:0]          step_1_color_4_que; 
wire        [COLOR_ARRAY_NUM_2*RAW_CIW*(COM_CLR_4_DLY+2)-1:0]          step_1_color_4_que_nxt;
reg         [COLOR_ARRAY_NUM_2-1-1:0]                                  data_bit                        [0:RAW_CIW-1];
wire        [COLOR_ARRAY_NUM_2-1-1:0]                                  data_bit_nxt                    [0:RAW_CIW-1];
reg                                                                    all_same;
wire                                                                   all_same_nxt;
reg         [RAW_CIW-1:0]                                              bit_result_max                  [0:RAW_CIW-1];
wire        [RAW_CIW-1:0]                                              bit_result_max_nxt              [0:RAW_CIW-1];
reg         [RAW_CIW-1:0]                                              bit_result_min                  [0:RAW_CIW-1];
wire        [RAW_CIW-1:0]                                              bit_result_min_nxt              [0:RAW_CIW-1];
wire        [COLOR_ARRAY_NUM_2-1-1:0]                                  result_max_sel                  [0:RAW_CIW-2];
wire        [COLOR_ARRAY_NUM_2-1-1:0]                                  result_min_sel                  [0:RAW_CIW-2];
wire        [RAW_CIW-1:0]                                              raw_max               [0:COLOR_ARRAY_NUM_2-1] ;   
reg         [RAW_CIW*(RECIP_DLY+2)-1:0]                                raw_max_fnl_que; 
wire        [RAW_CIW*(RECIP_DLY+2)-1:0]                                raw_max_fnl_que_nxt;
reg         [RAW_CIW-1:0]                                              raw_max_fnl;
wire        [RAW_CIW-1:0]                                              raw_max_fnl_nxt;
wire        [RAW_CIW-1:0]                                              raw_min               [0:COLOR_ARRAY_NUM_2-1] ; //4
reg         [RAW_CIW*(RECIP_DLY+2)-1:0]                                raw_min_fnl_que;  
wire        [RAW_CIW*(RECIP_DLY+2)-1:0]                                raw_min_fnl_que_nxt;
reg         [RAW_CIW-1:0]                                              raw_min_fnl;
wire        [RAW_CIW-1:0]                                              raw_min_fnl_nxt;
reg         [(RAW_CIW)*(COM_STEP_2_TAR_REPL_DLY+2)-1:0]                target_pixel_que;
wire        [(RAW_CIW)*(COM_STEP_2_TAR_REPL_DLY+2)-1:0]                target_pixel_que_nxt;
reg         [RAW_CIW-1:0]                                              target_pixel;
wire        [RAW_CIW-1:0]                                              target_pixel_nxt;
reg                                                                    ptnl_w_point;
wire                                                                   ptnl_w_point_nxt;
reg         [(COM_STEP_2_REPL_RAW_FNL_DLY+2)-1:0]                      ptnl_w_point_que;
wire        [(COM_STEP_2_REPL_RAW_FNL_DLY+2)-1:0]                      ptnl_w_point_que_nxt;
reg         [RAW_CIW-1:0]                                              raw_fnl_sel_num;
wire        [RAW_CIW-1:0]                                              raw_fnl_sel_num_nxt;
reg         [(RAW_CIW)*(COM_STEP_2_REPL_RAW_FNL_DLY+2)-1:0]            raw_fnl_sel_num_que;
wire        [(RAW_CIW)*(COM_STEP_2_REPL_RAW_FNL_DLY+2)-1:0]            raw_fnl_sel_num_que_nxt;  

//-----------------------------------------------------------------------------------------------------------noise level map 
wire        [RAW_CIIW+BLC_TGT_CIPW-RAW_CIPW+1-1:0]                     nlm_raw                         [0:COLOR_ARRAY_NUM_2-1]; //add 1 for signed
wire signed [RAW_CIW+BLC_TGT_CIPW+2-1:0]                               nlm_sgn                         [0:COLOR_ARRAY_NUM_2-1]; //add 1 for signed , add 1 for add 
reg         [RAW_CIW+BLC_TGT_CIPW+1-1:0]                               nlm_clip                        [0:COLOR_ARRAY_NUM_2-1]; 
wire        [RAW_CIW+BLC_TGT_CIPW+1-1:0]                               nlm_clip_nxt                    [0:COLOR_ARRAY_NUM_2-1]; 
reg         [SHOT_CIW+RAW_CIW+BLC_TGT_CIPW+1-1:0]                      total_nlm                       [0:COLOR_ARRAY_NUM_2-1]; 
wire        [SHOT_CIW+RAW_CIW+BLC_TGT_CIPW+1-1:0]                      total_nlm_nxt                   [0:COLOR_ARRAY_NUM_2-1]; 
reg         [SQRT_CIW-1:0]                                             total_nlm_clip                  [0:COLOR_ARRAY_NUM_2-1]; //14.4
wire        [SQRT_CIW-1:0]                                             total_nlm_clip_nxt              [0:COLOR_ARRAY_NUM_2-1]; //14.4

//-----------------------------------------------------------------------------------------------------------step 1 pixel result
reg         [R_LOW_NLM_CIW-1:0]                                        step_1_low_nlm_sel_num; 
wire        [R_LOW_NLM_CIW-1:0]                                        step_1_low_nlm_sel_num_nxt; 
reg         [R_LOW_NLM_CIW*(COM_STEP_1_NLM_RTO_DLY+2)-1:0]             step_1_low_nlm_sel_num_que; 
wire        [R_LOW_NLM_CIW*(COM_STEP_1_NLM_RTO_DLY+2)-1:0]             step_1_low_nlm_sel_num_que_nxt; 
reg         [1:0]                                                      step_1_sft_sel_num; 
wire        [1:0]                                                      step_1_sft_sel_num_nxt; 
reg         [2*(COM_STEP_1_NLM_RTO_DLY+2)-1:0]                         step_1_sft_sel_num_que;
wire        [2*(COM_STEP_1_NLM_RTO_DLY+2)-1:0]                         step_1_sft_sel_num_que_nxt;
reg         [R_LOW_NLM_CIW:0]                                          step_1_high_nlm_sel_num;
wire        [R_LOW_NLM_CIW:0]                                          step_1_high_nlm_sel_num_nxt;
reg         [(R_LOW_NLM_CIW+1)*(COM_STEP_1_NLM_RTO_DLY+2)-1:0]         step_1_high_nlm_sel_num_que; 
wire        [(R_LOW_NLM_CIW+1)*(COM_STEP_1_NLM_RTO_DLY+2)-1:0]         step_1_high_nlm_sel_num_que_nxt; 

reg         [RAW_CIW-1:0]                                              df_rto_0_sel_num;
wire        [RAW_CIW-1:0]                                              df_rto_0_sel_num_nxt;
reg         [RAW_CIW*(COM_STEP_1_RAW_MAX_MIN_DLY+2)-1:0]               df_rto_0_sel_num_que;
wire        [RAW_CIW*(COM_STEP_1_RAW_MAX_MIN_DLY+2)-1:0]               df_rto_0_sel_num_que_nxt;
reg         [RAW_CIW-1:0]                                              df_rto_1_sel_num;
wire        [RAW_CIW-1:0]                                              df_rto_1_sel_num_nxt;
reg         [RAW_CIW*(COM_STEP_1_RAW_MAX_MIN_DLY+2)-1:0]               df_rto_1_sel_num_que;
wire        [RAW_CIW*(COM_STEP_1_RAW_MAX_MIN_DLY+2)-1:0]               df_rto_1_sel_num_que_nxt;
reg         [SQRT_RECIP_COW-1:0]                                       max_min_recip_sel_num;
wire        [SQRT_RECIP_COW-1:0]                                       max_min_recip_sel_num_nxt; // 0.10 

reg         [RAW_CIW+SQRT_RECIP_COW+1-1:0]                             nlm_rto_sgn;               // add 1 for signed bit 
wire        [RAW_CIW+SQRT_RECIP_COW+1-1:0]                             nlm_rto_sgn_nxt;           //the result always positive, use the signed bit to prevent error result 
wire        [RTO_CIW+RAW_CIW-1:0]                                      df_clip_nlm;               //precision : 4.10
wire        [RTO_CIW+RAW_CIW-1:0]                                      df_step_1_score_temp;
reg         [(1+RAW_CIW)*(COM_STEP_2_ALL_SCR_DLY+2)-1:0]               df_step_1_score_que;
wire        [(1+RAW_CIW)*(COM_STEP_2_ALL_SCR_DLY+2)-1:0]               df_step_1_score_que_nxt;
reg         [(1+RAW_CIW)-1:0]                                          df_step_1_score;           //precision : 1.10
wire        [(1+RAW_CIW)-1:0]                                          df_step_1_score_nxt;       //precision : 1.10

//-----------------------------------------------------------------------------------------------------------step 2 get neighbor score 
wire        [R_RTO_THRES_CIW:0]                                         step_2_max_sel_num;  
wire        [R_RTO_THRES_CIW:0]                                         step_2_min_sel_num;    
wire        [R_RTO_THRES_CIW+2-1:0]                                     step_2_thres_sel_num_3;  
wire        [R_RTO_THRES_CIW+3-1:0]                                     step_2_thres_sel_num_5;   
wire        [1:0]                                                       step_2_rng_sel_num;  

reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_1_max_sgn               [0:STAGE_2_NBR_4-1]; //add 1 for signed , add 1 for over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_1_max_sgn_nxt           [0:STAGE_2_NBR_4-1]; //add 1 for signed , add 1 for over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_1_min_sgn               [0:STAGE_2_NBR_4-1]; //add 1 for signed , add 1 for over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_1_min_sgn_nxt           [0:STAGE_2_NBR_4-1]; //add 1 for signed , add 1 for over boundary 
wire        [(STAGE_2_NBR_4*STAGE_2_NBR_4)*RAW_CIW-1:0]                 step_2_color_1;
reg         [(STAGE_2_NBR_4*STAGE_2_NBR_4)*RAW_CIW*
             (COM_STEP_2_COL_SUM_DLY+2)-1:0]                            step_2_color_1_que;
wire        [(STAGE_2_NBR_4*STAGE_2_NBR_4)*RAW_CIW*
             (COM_STEP_2_COL_SUM_DLY+2)-1:0]                            step_2_color_1_que_nxt;  
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_1_clip_sgn              [0:STAGE_2_NBR_4*(STAGE_2_NBR_4-1)-1];//add 1 for signed bit,1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_1_clip_sgn_nxt          [0:STAGE_2_NBR_4*(STAGE_2_NBR_4-1)-1];//add 1 for signed bit,1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+3-1:0]                  step_2_color_1_sum_0_sgn             [0:STAGE_2_NBR_4-1]; //1 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+3-1:0]                  step_2_color_1_sum_0_sgn_nxt         [0:STAGE_2_NBR_4-1]; //1 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+3-1:0]                  step_2_color_1_sum_1_sgn             [0:STAGE_2_NBR_4-1]; //1 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+3-1:0]                  step_2_color_1_sum_1_sgn_nxt         [0:STAGE_2_NBR_4-1]; //1 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_1_sum_sgn               [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_1_sum_sgn_nxt           [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_1_num_0_sgn             [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_1_num_1_sgn             [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_1_sel_num_0_sgn         [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_1_sel_num_0_sgn_nxt     [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_1_sel_num_1_sgn         [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_1_sel_num_1_sgn_nxt     [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4+SQRT_RECIP_COW+1-1:0] step_2_color_1_score_stage_0_sgn     [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4+SQRT_RECIP_COW+1-1:0] step_2_color_1_score_stage_0_sgn_nxt [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4+SQRT_RECIP_COW+1-1:0] step_2_color_1_score_stage_1_sgn     [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4+SQRT_RECIP_COW+1-1:0] step_2_color_1_score_stage_1_sgn_nxt [0:STAGE_2_NBR_4-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [SCORE_STG_0_CIW+RAW_CIW+1-1:0]                             step_2_color_1_score_stage_2_sgn     [0:STAGE_2_NBR_4-1];  //add 1 for signed 
wire        [SCORE_STG_1_N3_CIW+RAW_CIW-1:0]                            step_2_color_1_score_stage_3         [0:STAGE_2_NBR_4-1];  

reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_2_max_sgn               [0:STAGE_2_NBR_2-1]; //add 1 for signed , add 1 for over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_2_max_sgn_nxt           [0:STAGE_2_NBR_2-1]; //add 1 for signed , add 1 for over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_2_min_sgn               [0:STAGE_2_NBR_2-1]; //add 1 for signed , add 1 for over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_2_min_sgn_nxt           [0:STAGE_2_NBR_2-1]; //add 1 for signed , add 1 for over boundary 
wire        [(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2)*RAW_CIW-1:0]           step_2_color_2;
reg         [(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2)*RAW_CIW*
             (COM_STEP_2_COL_SUM_DLY+2)-1:0]                            step_2_color_2_que;
wire        [(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2)*RAW_CIW*
             (COM_STEP_2_COL_SUM_DLY+2)-1:0]                            step_2_color_2_que_nxt;   

reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_2_clip_sgn              [0:(STAGE_2_NBR_2_SUB_6-1)*STAGE_2_NBR_2-1]; //1 signed ,1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_2_clip_sgn_nxt          [0:(STAGE_2_NBR_2_SUB_6-1)*STAGE_2_NBR_2-1]; //1 signed ,1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_2_sum_0_sgn             [0:STAGE_2_NBR_2-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_2_sum_0_sgn_nxt         [0:STAGE_2_NBR_2-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_2_sum_1_sgn             [0:STAGE_2_NBR_2-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_2_sum_1_sgn_nxt         [0:STAGE_2_NBR_2-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_2_sum_sgn               [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_2_sum_sgn_nxt           [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_2_num_0_sgn             [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_2_num_1_sgn             [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_2_sel_num_0_sgn         [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_2_sel_num_0_sgn_nxt     [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_2_sel_num_1_sgn         [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_2_sel_num_1_sgn_nxt     [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5+SQRT_RECIP_COW+1-1:0] step_2_color_2_score_stage_0_sgn     [0:STAGE_2_NBR_4-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5+SQRT_RECIP_COW+1-1:0] step_2_color_2_score_stage_0_sgn_nxt [0:STAGE_2_NBR_4-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5+SQRT_RECIP_COW+1-1:0] step_2_color_2_score_stage_1_sgn     [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5+SQRT_RECIP_COW+1-1:0] step_2_color_2_score_stage_1_sgn_nxt [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [SCORE_STG_0_CIW+RAW_CIW+SQRT_RECIP_COW+1-1:0]              step_2_color_2_score_stage_2_sgn     [0:STAGE_2_NBR_2-1]; //add 1 for signed 
wire        [SCORE_STG_1_N5_CIW+RAW_CIW-1:0]                            step_2_color_2_score_stage_3         [0:STAGE_2_NBR_2-1]; 

reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_3_max_sgn               [0:STAGE_2_NBR_2-1]; //add 1 for signed , add 1 for over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_3_max_sgn_nxt           [0:STAGE_2_NBR_2-1]; //add 1 for signed , add 1 for over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_3_min_sgn               [0:STAGE_2_NBR_2-1]; //add 1 for signed , add 1 for over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_3_min_sgn_nxt           [0:STAGE_2_NBR_2-1]; //add 1 for signed , add 1 for over boundary 
wire        [(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2)*RAW_CIW-1:0]           step_2_color_3;
reg         [(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2)*RAW_CIW*
             (COM_STEP_2_COL_SUM_DLY+2)-1:0]                            step_2_color_3_que;
wire        [(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2)*RAW_CIW*
             (COM_STEP_2_COL_SUM_DLY+2)-1:0]                            step_2_color_3_que_nxt;  

reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_3_clip_sgn              [0:(STAGE_2_NBR_2_SUB_6-1)*STAGE_2_NBR_2-1]; //1 signed ,1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+2-1:0]                  step_2_color_3_clip_sgn_nxt          [0:(STAGE_2_NBR_2_SUB_6-1)*STAGE_2_NBR_2-1]; //1 signed ,1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_3_sum_0_sgn             [0:STAGE_2_NBR_2-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_3_sum_0_sgn_nxt         [0:STAGE_2_NBR_2-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_3_sum_1_sgn             [0:STAGE_2_NBR_2-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+4-1:0]                  step_2_color_3_sum_1_sgn_nxt         [0:STAGE_2_NBR_2-1]; //2 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_3_sum_sgn               [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_3_sum_sgn_nxt           [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_3_num_0_sgn             [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_3_num_1_sgn             [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_3_sel_num_0_sgn         [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_3_sel_num_0_sgn_nxt     [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_3_sel_num_1_sgn         [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5-1:0]                  step_2_color_3_sel_num_1_sgn_nxt     [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5+SQRT_RECIP_COW+1-1:0] step_2_color_3_score_stage_0_sgn     [0:STAGE_2_NBR_4-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5+SQRT_RECIP_COW+1-1:0] step_2_color_3_score_stage_0_sgn_nxt [0:STAGE_2_NBR_4-1]; //3 for summerization , 1 signed bit  , 1 over boundary  
reg  signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5+SQRT_RECIP_COW+1-1:0] step_2_color_3_score_stage_1_sgn     [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [RAW_CIW+SQRT_COPW+R_RTO_THRES_CIPW+5+SQRT_RECIP_COW+1-1:0] step_2_color_3_score_stage_1_sgn_nxt [0:STAGE_2_NBR_2-1]; //3 for summerization , 1 signed bit  , 1 over boundary 
wire signed [SCORE_STG_0_CIW+RAW_CIW+SQRT_RECIP_COW+1-1:0]              step_2_color_3_score_stage_2_sgn     [0:STAGE_2_NBR_2-1]; //add 1 for signed 
wire        [SCORE_STG_1_N5_CIW+RAW_CIW-1:0]                            step_2_color_3_score_stage_3         [0:STAGE_2_NBR_2-1];  

reg         [RAW_CIW+SCORE_STG_1_N5_CIW+1-1:0]                          step_2_color_total_sum_0;
wire        [RAW_CIW+SCORE_STG_1_N5_CIW+1-1:0]                          step_2_color_total_sum_0_nxt;
reg         [RAW_CIW+SCORE_STG_1_N5_CIW+2-1:0]                          step_2_color_total_sum_1;
wire        [RAW_CIW+SCORE_STG_1_N5_CIW+2-1:0]                          step_2_color_total_sum_1_nxt;
reg         [RAW_CIW+SCORE_STG_1_N5_CIW+1-1:0]                          step_2_color_total_sum_2;
wire        [RAW_CIW+SCORE_STG_1_N5_CIW+1-1:0]                          step_2_color_total_sum_2_nxt;
reg         [RAW_CIW+SCORE_STG_1_N5_CIW+3-1:0]                          step_2_color_total_sum;
wire        [RAW_CIW+SCORE_STG_1_N5_CIW+3-1:0]                          step_2_color_total_sum_nxt;                               //add 3 for sum 8 value

//-----------------------------------------------------------------------------------------------------------step 2 get confidence score 
wire        [R_CNT_THRES_CIW-1:0]                                       step_2_cnt_thres_sel_num; 
wire        [2:0]                                                       step_2_cnt_rng_sel_num; 
wire signed [RAW_CIW+SCORE_STG_1_N5_CIW+3+1-2-1:0]                      df_step_2_score_sgn;        //add 3 for sum 8 value , add 1 for signed bit  , minus 2 for divid 4 
wire signed [RAW_CIW+SCORE_STG_1_N5_CIW+3+1-2-1:0]                      step_2_score_com_sgn;       //4.10 //add 3 for sum 8 value , add 1 for signed bit , minus 2 for divid 4 
wire        [RAW_CIW+1-1:0]                                             df_step_2_score_clip;       //1.10
reg         [RAW_CIW+1-1:0]                                             df_step_2_score_inv;        //1.10
wire        [RAW_CIW+1-1:0]                                             df_step_2_score_inv_nxt;    //1.10
reg         [1+RAW_CIW+RAW_CIW-1:0]                                     df_all_step_score;          //1.10 * 4.10 
wire        [1+RAW_CIW+RAW_CIW-1:0]                                     df_all_step_score_nxt;      //1.10 * 4.10 
reg         [RAW_CIW+1-1:0]                                             df_all_step_score_inv;      //1.10
wire        [RAW_CIW+1-1:0]                                             df_all_step_score_inv_nxt;  //1.10
reg         [RAW_CIW+1+RAW_CIW+R_LOW_NLM_CIPW:0]                        repl_pixel;                 //11.12
wire        [RAW_CIW+1+RAW_CIW+R_LOW_NLM_CIPW:0]                        repl_pixel_nxt;             //11.12
wire                                                                    all_score_msb_en;           // score integer part  //precisoin 1.0*1.0 => 1.0
wire        [RAW_CIW+RAW_CIW-1:0]                                       all_score_lsb_en;           // score floating part //precision 1.10*1.10 => 0.20
wire                                                                    step_2_en;
wire        [RAW_CIW-1:0]                                               target_repl;

//-----------------------------------------------------------------------------------------------------------sqrt_pw
wire        [(((SQRT_CIW/2)+IP_SQRT_OEXD)*COLOR_ARRAY_NUM_2)-1:0]                          nlm_sqrt;
reg         [(IP_SQRT_ORPCS+1)*COLOR_ARRAY_NUM_2-1:0]                                      nlm_sqrt_recip; //precision: 1.SQRT_RECIP_COW
wire        [(IP_SQRT_ORPCS+1)*COLOR_ARRAY_NUM_2-1:0]                                      nlm_sqrt_recip_nxt; //precision: 1.SQRT_RECIP_COW
reg         [(IP_SQRT_ORPCS+1)*COLOR_ARRAY_NUM_2*(COM_STEP_2_COL_NLM_REC_DLY+2)-1:0]       nlm_sqrt_recip_que;
wire        [(IP_SQRT_ORPCS+1)*COLOR_ARRAY_NUM_2*(COM_STEP_2_COL_NLM_REC_DLY+2)-1:0]       nlm_sqrt_recip_que_nxt;

//-----------------------------------------------------------------------------------------------------------output  
wire        [RAW_CIW-1:0]                                               o_data_nxt;
wire                                                                    o_href_nxt;
wire                                                                    o_vstr_nxt;
wire                                                                    o_hstr_nxt;
wire                                                                    o_hend_nxt;
wire                                                                    o_vend_nxt;
reg         [5*(COM_VIDEO_DLY+2)-1:0]                                   video_que;
wire        [5*(COM_VIDEO_DLY+2)-1:0]                                   video_que_nxt;
    
wire        [MAX_DPC_NUM_WTH-1:0]                                       o_wdpc_cnt_nxt;
wire        [MAX_DPC_NUM_WTH-1:0]                                       o_bdpc_cnt_nxt;
wire        [MAX_COORD_NUM-1:0]                                         o_static_num_cnt_nxt;

//-----------------------------------------------------------------------------------------------------------others 
genvar                                                                  index,index_2;
integer                                                                 int_index;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//-----------------------------------------------------------------------------------------------------------static dpc 
generate 
  if((MODE_SEL == 1) | (MODE_SEL == 3)) begin //generate static start 

  assign coord_h_eq           = (coord_h == dpc_hor_cnt);
  assign coord_v_eq           = (coord_v == r_ver_addr);
  if (MODE_SEL == 3) begin 
    assign coord_total_eq_nxt   = coord_h_eq & coord_v_eq & r_mode_sel[0];
  end 
  else begin 
    assign coord_total_eq_nxt   = coord_h_eq & coord_v_eq;
  end  

  assign coord_sft_en_nxt     = i_vstr             ? {{(COORD_NUM-1){1'b0}},1'b1} : 
                                coord_total_eq_nxt ? (coord_sft_en << 1) : coord_sft_en;
                                
  always @* begin

   coord_fnl = {COORD_WTH{coord_sft_en[0]}} & r_static_coord[0+:COORD_WTH];
   
   for (int_index=1; int_index < COORD_NUM; int_index=int_index+1) begin  : gen_coord_fnl

      coord_fnl = coord_fnl | ({COORD_WTH{coord_sft_en[int_index]}} & r_static_coord[int_index*COORD_WTH+:COORD_WTH]);

   end
  end
          
  assign coord_dp             = coord_fnl[COORD_WTH*(0)+23    ];
  assign coord_v              = coord_fnl[COORD_WTH*(0)+12+:11];
  assign coord_bw_nxt         = coord_fnl[COORD_WTH*(0)+11    ];
  assign coord_h              = coord_fnl[COORD_WTH*(0)+0 +:11];

//-------------------------------------------------------------------------------------- static counter 
assign dpc_hor_cnt_nxt        = (dpc_hor_cnt_set ? dpc_hor_cnt_set_val : dpc_hor_cnt_inc ? $signed(dpc_hor_cnt + $signed({r_coord_mirror,1'b1})) : dpc_hor_cnt) &
                                {IMG_HSZ_WTH+1{~dpc_hor_cnt_clr}};
                                
assign dpc_hor_cnt_inc        = i_href;
assign dpc_hor_cnt_clr        = i_hend;
assign dpc_hor_cnt_set        = i_hstr;
assign dpc_hor_cnt_set_val    = r_coord_mirror ? {1'b0,i_haddr_mirr_cu} : {1'b0,r_haddr_start};

assign static_num_cnt_nxt     = (static_num_cnt_inc ? static_num_cnt + 1'b1 : static_num_cnt) & {IMG_VSZ_WTH{~static_num_cnt_clr}};
assign static_num_cnt_inc     = coord_total_eq_nxt & i_href;
assign static_num_cnt_clr     = i_vend;

if(DEBUG_MODE == 1) begin 

assign dpc_ver_cnt_nxt        = (dpc_ver_cnt_inc ? dpc_ver_cnt + 1'b1 : dpc_ver_cnt) & {IMG_VSZ_WTH{~dpc_ver_cnt_clr}}; 
assign dpc_ver_cnt_inc        = i_hend;
assign dpc_ver_cnt_clr        = i_vend;

  end
  
end 
endgenerate //generate static end 

generate 
  if(MODE_SEL == 2) begin 
  
  assign coord_total_eq_nxt   = 0;
  assign coord_bw_nxt = 0;
  end 
endgenerate 

//-------------------------------------------------------------------------------------- static and dynamic  counter  
assign dpc_wh_cnt_nxt         = (dpc_wh_cnt_inc ? dpc_wh_cnt + 1'b1 : dpc_wh_cnt) & {IMG_VSZ_WTH{~dpc_wh_cnt_clr}};
assign dpc_wh_cnt_inc         = (step_2_en & ptnl_w_point_que_nxt[COM_STEP_2_REPL_RAW_FNL_DLY+:1]) | 
                                (coord_total_eq_que_nxt[COM_STEP_1_RAW_FNL_DLY] & !coord_bw_que_nxt[COM_STEP_1_RAW_FNL_DLY] & i_href);
assign dpc_wh_cnt_clr         = i_vend;

assign dpc_bk_cnt_nxt         = (dpc_bk_cnt_inc ? dpc_bk_cnt + 1'b1 : dpc_bk_cnt) & {IMG_VSZ_WTH{~dpc_bk_cnt_clr}};
assign dpc_bk_cnt_inc         = (step_2_en & !ptnl_w_point_que_nxt[COM_STEP_2_REPL_RAW_FNL_DLY+:1]) | 
                                (coord_total_eq_que_nxt[COM_STEP_1_RAW_FNL_DLY] & coord_bw_que_nxt[COM_STEP_1_RAW_FNL_DLY] & i_href);
assign dpc_bk_cnt_clr         = i_vend;
   
//-----------------------------------------------------------------------------------------------------------dpc step 1 potential point //pipe_step_1_1 start 
//--------------------------------------------------------------------------------------find max and min number
 generate 
  for (index=0;index<KRNV_SZ;index=index+1) begin : line_array_gen
    assign line_array[KRNV_SZ-index-1] = i_raw_data[RAW_CIW*KRNV_SZ*(index+1)-1 : RAW_CIW*KRNV_SZ*index] & {RAW_CIW*KRNV_SZ{i_href}}; 
  end //end generate 
 endgenerate 

 generate 
  for (index=0;index<KRNV_SZ;index=index+2) begin : step_1_color_1_gen //num:16
    for (index_2=0;index_2<KRNV_SZ;index_2=index_2+2) begin : step_1_color_1_gen_2
      assign step_1_color_1[RAW_CIW*((index/2)*STAGE_1_DATA_NUM_4+((index_2/2)+1))-1 : RAW_CIW*((index/2)*STAGE_1_DATA_NUM_4+(index_2/2))] = 
                                                                                       line_array[index][RAW_CIW*(KRNV_SZ-index_2-1)+:RAW_CIW];
    end
  end //end generate 
 endgenerate 

 generate 
  for (index=1;index<KRNV_SZ;index=index+2) begin : step_1_color_2_gen //num:12
    for (index_2=0;index_2<KRNV_SZ;index_2=index_2+2) begin : step_1_color_2_gen_2
      assign step_1_color_2[RAW_CIW*((index/2)*STAGE_1_DATA_NUM_4+((index_2/2)+1))-1 : RAW_CIW*((index/2)*STAGE_1_DATA_NUM_4+(index_2/2))] = 
                                                                                       line_array[index][RAW_CIW*(KRNV_SZ-index_2-1)+:RAW_CIW];
    end
  end //end generate 
 endgenerate 
  
 generate 
  for (index=0;index<KRNV_SZ;index=index+2) begin : step_1_color_3_gen //num:12
    for (index_2=1;index_2<KRNV_SZ;index_2=index_2+2) begin : step_1_color_3_gen_2
      assign step_1_color_3[RAW_CIW*((index/2)*STAGE_1_DATA_NUM_3+((index_2/2)+1))-1 : RAW_CIW*((index/2)*STAGE_1_DATA_NUM_3+(index_2/2))] = 
                                                                                       line_array[index][RAW_CIW*(KRNV_SZ-index_2-1)+:RAW_CIW];
    end
  end //end generate 
 endgenerate 
 
 generate 
  for (index=1;index<KRNV_SZ;index=index+2) begin : step_1_color_4_gen //num:9
    for (index_2=1;index_2<KRNV_SZ;index_2=index_2+2) begin : step_1_color_4_gen_2
      assign step_1_color_4_nxt[RAW_CIW*((index/2)*STAGE_1_DATA_NUM_3+((index_2/2)+1))-1 : RAW_CIW*((index/2)*STAGE_1_DATA_NUM_3+(index_2/2))] = 
                                                                                           line_array[index][RAW_CIW*(KRNV_SZ-index_2-1)+:RAW_CIW];
    end
  end //end generate 
 endgenerate 
 
 generate 
  for (index=0;index<RAW_CIW;index=index+1) begin : data_bit_gen //num:8  //data_bit[0] is i_data MSB  
    assign data_bit_nxt[RAW_CIW-index-1] = {step_1_color_4_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2-0)-index-1], //0
                                            step_1_color_4_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2-1)-index-1], //1
                                            step_1_color_4_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2-2)-index-1], //2
                                            step_1_color_4_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2-3)-index-1], //3
                                            step_1_color_4_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2-5)-index-1], //5
                                            step_1_color_4_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2-6)-index-1], //6
                                            step_1_color_4_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2-7)-index-1], //7
                                            step_1_color_4_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2-8)-index-1]};//8
  end //end generate 
 endgenerate 
 
assign all_same_nxt           = (&data_bit_nxt[RAW_CIW-1]) | (&(~data_bit_nxt[RAW_CIW-1]));

assign bit_result_max_nxt[0]  = {RAW_CIW{all_same}} | data_bit[RAW_CIW-1];
assign bit_result_min_nxt[0]  = {RAW_CIW{all_same}} | (~data_bit[RAW_CIW-1]);

 generate 
  for (index=1;index<RAW_CIW;index=index+1) begin : bit_result_gen //max and min 
    assign result_max_sel[index-1]   = (bit_result_max_nxt[index-1] & data_bit[RAW_CIW-index-1]);
    assign result_min_sel[index-1]   = (bit_result_min_nxt[index-1] & ~data_bit[RAW_CIW-index-1]);
    assign bit_result_max_nxt[index] = result_max_sel[index-1] ? result_max_sel[index-1] : bit_result_max_nxt[index-1]; //set 
    assign bit_result_min_nxt[index] = result_min_sel[index-1] ? result_min_sel[index-1] : bit_result_min_nxt[index-1];
  end 
 endgenerate 
 
 
assign raw_max [0]  = {RAW_CIW{bit_result_max[RAW_CIW-1][0]}} & step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+:RAW_CIW]; //pipe 1
assign raw_min [0]  = {RAW_CIW{bit_result_min[RAW_CIW-1][0]}} & step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+:RAW_CIW]; //pipe 1

 generate 
  for (index=0;index<COLOR_ARRAY_NUM_2-1;index=index+1) begin : max_min_raw_gen //max and min 
    if (index >= 4) begin //over the middle pixel 
      assign raw_max [index+1] = raw_max [index] | ({RAW_CIW{bit_result_max[RAW_CIW-1][index]}} & 
                                                                                 step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*(index+1) +: RAW_CIW]);
      assign raw_min [index+1] = raw_min [index] | ({RAW_CIW{bit_result_min[RAW_CIW-1][index]}} & 
                                                                                 step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*(index+1) +: RAW_CIW]);
    end 
    else begin 
      assign raw_max [index+1] = raw_max [index] | ({RAW_CIW{bit_result_max[RAW_CIW-1][index]}} & 
                                                                                 step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*(index) +: RAW_CIW]);
      assign raw_min [index+1] = raw_min [index] | ({RAW_CIW{bit_result_min[RAW_CIW-1][index]}} & 
                                                                                 step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*(index) +: RAW_CIW]);
    end
  end 
 endgenerate 
 

 
assign target_pixel_nxt         = step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*4 +: RAW_CIW];       // precision : RAW_CIW:10.0 
assign raw_max_fnl_nxt          = raw_max[COLOR_ARRAY_NUM_2-1];                                                                 // precision : RAW_CIW:10.0
assign raw_min_fnl_nxt          = raw_min[COLOR_ARRAY_NUM_2-1];                                                                 // precision : RAW_CIW:10.0
assign ptnl_w_point_nxt         = target_pixel >= raw_max_fnl;   
assign raw_fnl_sel_num_nxt      = ((!coord_total_eq_que_nxt[COM_STEP_1_RAW_FNL_DLY] & ptnl_w_point_nxt) | 
                                    (coord_total_eq_que_nxt[COM_STEP_1_RAW_FNL_DLY] & !coord_bw_que_nxt[COM_STEP_1_RAW_FNL_DLY])) ? raw_max_fnl : raw_min_fnl;  

                                                                                                                                                            // precision : RAW_CIW:10.0
assign target_pixel_que_nxt     = {target_pixel_que   [0+:RAW_CIW                   *(COM_STEP_2_TAR_REPL_DLY     +1)],target_pixel};
assign raw_max_fnl_que_nxt      = {raw_max_fnl_que    [0+:RAW_CIW                   *(RECIP_DLY                   +1)],raw_max_fnl};
assign raw_min_fnl_que_nxt      = {raw_min_fnl_que    [0+:RAW_CIW                   *(RECIP_DLY                   +1)],raw_min_fnl};
assign ptnl_w_point_que_nxt     = {ptnl_w_point_que   [0+:                           (COM_STEP_2_REPL_RAW_FNL_DLY +1)],ptnl_w_point};
assign raw_fnl_sel_num_que_nxt  = {raw_fnl_sel_num_que[0+:RAW_CIW                   *(COM_STEP_2_REPL_RAW_FNL_DLY +1)],raw_fnl_sel_num};
assign step_1_color_4_que_nxt   = {step_1_color_4_que [0+:COLOR_ARRAY_NUM_2*RAW_CIW *(COM_CLR_4_DLY               +1)],step_1_color_4};

generate   
  if(MODE_SEL == 1) begin 
    assign raw_fnl_sta_sel_num_nxt      = coord_bw_que_nxt[COM_STEP_1_RAW_FNL_DLY] ? raw_min_fnl : raw_max_fnl;
    assign raw_fnl_sta_sel_num_que_nxt  = {raw_fnl_sta_sel_num_que[0+:RAW_CIW*(COM_STA_FNL_STA_SEL_DLY+1)],raw_fnl_sta_sel_num};
  end 
endgenerate 

//|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|
//| step_1_color_1[00] | step_1_color_2[00] | step_1_color_1[04] | step_1_color_2[04] | step_1_color_1[08] | step_1_color_2[08] | step_1_color_1[12] |
//|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|
//| step_1_color_3[00] | step_1_color_4[00] | step_1_color_3[03] | step_1_color_4[01] | step_1_color_3[06] | step_1_color_4[02] | step_1_color_3[09] |
//|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|
//| step_1_color_1[01] | step_1_color_2[01] | step_1_color_1[05] | step_1_color_2[05] | step_1_color_1[09] | step_1_color_2[09] | step_1_color_1[13] |
//|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|
//| step_1_color_3[01] | step_1_color_4[03] | step_1_color_3[04] | step_1_color_4[04] | step_1_color_3[07] | step_1_color_4[05] | step_1_color_3[10] |
//|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|
//| step_1_color_1[02] | step_1_color_2[02] | step_1_color_1[06] | step_1_color_2[06] | step_1_color_1[10] | step_1_color_2[10] | step_1_color_1[14] |
//|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|
//| step_1_color_3[02] | step_1_color_4[06] | step_1_color_3[05] | step_1_color_4[07] | step_1_color_3[08] | step_1_color_4[08] | step_1_color_3[11] |
//|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|
//| step_1_color_1[03] | step_1_color_2[03] | step_1_color_1[07] | step_1_color_2[07] | step_1_color_1[11] | step_1_color_2[11] | step_1_color_1[15] |  
//|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|:-------------------|

//-----------------------------------------------------------------------------------------------------------noise level map //pipe_step_1_1 end  //pipe_nlm_1 start 
generate 
  if((MODE_SEL == 2) | (MODE_SEL == 3)) begin : dynamic_part_1_start
  
assign nlm_raw[0] = {1'b0,raw_fnl_sel_num,{BLC_TGT_CIPW-RAW_CIPW{1'b0}}}; 
assign nlm_raw[1] = {1'b0,step_1_color_1[RAW_CIW*5 +:RAW_CIW],{BLC_TGT_CIPW-RAW_CIPW{1'b0}}}; //b0
assign nlm_raw[2] = {1'b0,step_1_color_1[RAW_CIW*6 +:RAW_CIW],{BLC_TGT_CIPW-RAW_CIPW{1'b0}}}; //b1
assign nlm_raw[3] = {1'b0,step_1_color_1[RAW_CIW*9 +:RAW_CIW],{BLC_TGT_CIPW-RAW_CIPW{1'b0}}}; //b2
assign nlm_raw[4] = {1'b0,step_1_color_1[RAW_CIW*10+:RAW_CIW],{BLC_TGT_CIPW-RAW_CIPW{1'b0}}}; //b3
assign nlm_raw[5] = {1'b0,step_1_color_2[RAW_CIW*5 +:RAW_CIW],{BLC_TGT_CIPW-RAW_CIPW{1'b0}}}; //gb0
assign nlm_raw[6] = {1'b0,step_1_color_2[RAW_CIW*6 +:RAW_CIW],{BLC_TGT_CIPW-RAW_CIPW{1'b0}}}; //gb1
assign nlm_raw[7] = {1'b0,step_1_color_3[RAW_CIW*4 +:RAW_CIW],{BLC_TGT_CIPW-RAW_CIPW{1'b0}}}; //gr0
assign nlm_raw[8] = {1'b0,step_1_color_3[RAW_CIW*7 +:RAW_CIW],{BLC_TGT_CIPW-RAW_CIPW{1'b0}}}; //gr1

//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |        b0          |         gb0        |         b1         |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |        gr0         |    target pixel    |         gr1        |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |        b2          |         gb1        |         b3         |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |

  for(index=0;index<COLOR_ARRAY_NUM_2;index=index+1) begin : gen_nlm
  
assign nlm_sgn[index]            = $signed(nlm_raw[index]) + $signed(i_blc_dc_dlt_cu);                              // precision : (10.0 + s.11.0 = s.12.0) 
assign nlm_clip_nxt[index]       = nlm_sgn[index][RAW_CIW+BLC_TGT_CIPW+1] ? {RAW_CIW+BLC_TGT_CIPW+1{1'b0}} : nlm_sgn[index]; 
assign total_nlm_nxt[index]      = nlm_clip[index] * {i_shot_nvar_bs_cu,{(ROUT_CIPW-SHOT_CIPW-BLC_TGT_CIPW-RAW_CIPW){1'b0}}} + i_rout_nvar_bs_cu +  //set 
                                   {1'b1,{CGCF_CIPW-SQRT_CIPW-1{1'b0}}};                                            // precision : (s.12.0 * 4.12) + 8.12 = s.13.12 + rounding
assign total_nlm_clip_nxt[index] = (total_nlm[index][CGCF_CIPW-SQRT_CIPW+:SQRT_CIW] >= {{1'b1},{(SQRT_CIPW-1){1'b0}},{1'b1}}) ? total_nlm[index][CGCF_CIPW-SQRT_CIPW+:SQRT_CIW] : 
                                   {{1'b1},{(SQRT_CIPW-1){1'b0}},{1'b1}};                                      // precision : s.13.4
end

assign nlm_sqrt[0+:((SQRT_CIW/2)+IP_SQRT_OEXD)] = 0;

assign nlm_sqrt_recip_que_nxt     = {nlm_sqrt_recip_que   [0+:(IP_SQRT_ORPCS+1)*COLOR_ARRAY_NUM_2 * (COM_STEP_2_COL_NLM_REC_DLY+1)],nlm_sqrt_recip};

//-----------------------------------------------------------------------------------------------------------step 1 pixel result //pipe_nlm_1 end  //pipe_step_1_2 start 
assign step_1_low_nlm_sel_num_nxt    = ptnl_w_point_nxt                                 ? r_step1_w_low_nlm                : r_step1_b_low_nlm;               //precision : 3.2
assign step_1_sft_sel_num_nxt        = ptnl_w_point_nxt                                 ? r_step1_w_transit_rng[1+:2]      : r_step1_b_transit_rng[1+:2];     //value = {1,2,4} 
assign df_rto_0_sel_num_nxt          = ptnl_w_point_nxt                                 ? target_pixel_que_nxt[0+:RAW_CIW] : raw_min_fnl; 
assign df_rto_1_sel_num_nxt          = ptnl_w_point_nxt                                 ? raw_max_fnl                      : target_pixel_que_nxt[0+:RAW_CIW]; //set 
assign step_1_high_nlm_sel_num_nxt   = ptnl_w_point_nxt                                 ? i_step1_w_high_nlm_cu            : i_step1_b_high_nlm_cu;           //precision : 3.2
assign max_min_recip_sel_num_nxt     = nlm_sqrt_recip_nxt[(IP_SQRT_ORPCS+1)-1:0];                                                                             //precision : 0.10
assign nlm_rto_sgn_nxt               = $signed({1'b0,df_rto_0_sel_num_que_nxt[RAW_CIW*COM_STEP_1_RAW_MAX_MIN_DLY+:RAW_CIW]} -   
                                               {1'b0,df_rto_1_sel_num_que_nxt[RAW_CIW*COM_STEP_1_RAW_MAX_MIN_DLY+:RAW_CIW]}) * $signed({1'b0,max_min_recip_sel_num_nxt});  //set 
                                                                                                                                                //precision : (10.0-10.0)*0.10 = 10.10
                                               
  if (SQRT_RECIP_COPW == RAW_CIW) //not rounding 
  assign df_clip_nlm =  
       (nlm_rto_sgn[SQRT_RECIP_COPW-R_LOW_NLM_CIPW+:RAW_CIW] >= step_1_high_nlm_sel_num_que_nxt[(R_LOW_NLM_CIW+1)*(COM_STEP_1_NLM_RTO_DLY)+:(R_LOW_NLM_CIW+1)]) ? 
                     {step_1_high_nlm_sel_num_que_nxt[(R_LOW_NLM_CIW+1)*(COM_STEP_1_NLM_RTO_DLY)+:(R_LOW_NLM_CIW+1)],{RAW_CIW-R_LOW_NLM_CIPW{1'b0}}} :  //compare precision : 4.2
       (nlm_rto_sgn[SQRT_RECIP_COPW-R_LOW_NLM_CIPW+:RAW_CIW] < step_1_low_nlm_sel_num_que_nxt[R_LOW_NLM_CIW*(COM_STEP_1_NLM_RTO_DLY)+:R_LOW_NLM_CIW]) ? 
                     {step_1_low_nlm_sel_num_que_nxt[R_LOW_NLM_CIW*(COM_STEP_1_NLM_RTO_DLY)+:R_LOW_NLM_CIW],{RAW_CIW-R_LOW_NLM_CIPW{1'b0}}} :           //compare precision : 4.2
       (nlm_rto_sgn[SQRT_RECIP_COPW-RAW_CIW+:RTO_CIW+RAW_CIW-1]);                                                                                    //precision : 4.10 
  else 
  assign df_clip_nlm =  
       (nlm_rto_sgn[SQRT_RECIP_COPW-R_LOW_NLM_CIPW+:RAW_CIW] >= step_1_high_nlm_sel_num_que_nxt[(R_LOW_NLM_CIW+1)*(COM_STEP_1_NLM_RTO_DLY)+:(R_LOW_NLM_CIW+1)]) ? 
                     {step_1_high_nlm_sel_num_que_nxt[(R_LOW_NLM_CIW+1)*(COM_STEP_1_NLM_RTO_DLY)+:(R_LOW_NLM_CIW+1)],{RAW_CIW-R_LOW_NLM_CIPW{1'b0}}} :  //compare precision : 4.2
       (nlm_rto_sgn[SQRT_RECIP_COPW-R_LOW_NLM_CIPW+:RAW_CIW] < step_1_low_nlm_sel_num_que_nxt[R_LOW_NLM_CIW*(COM_STEP_1_NLM_RTO_DLY)+:R_LOW_NLM_CIW]) ? 
                     {step_1_low_nlm_sel_num_que_nxt[R_LOW_NLM_CIW*(COM_STEP_1_NLM_RTO_DLY)+:R_LOW_NLM_CIW],{RAW_CIW-R_LOW_NLM_CIPW{1'b0}}} :           //compare precision : 4.2
       (nlm_rto_sgn[SQRT_RECIP_COPW-RAW_CIW+:RTO_CIW+RAW_CIW-1] + nlm_rto_sgn[SQRT_RECIP_COPW-RAW_CIW-1]);                                           //precision : 4.10 + rounding
                  
assign df_step_1_score_temp            = (df_clip_nlm - {step_1_low_nlm_sel_num_que_nxt[R_LOW_NLM_CIW*(COM_STEP_1_NLM_RTO_DLY)+:R_LOW_NLM_CIW],{RAW_CIW-R_LOW_NLM_CIPW{1'b0}}}) + 
                                         step_1_sft_sel_num_que_nxt[2*COM_STEP_1_NLM_RTO_DLY+:2];                                         //precision : 4.10 - 3.2 + rounding = 4.10

assign df_step_1_score_nxt             = (df_step_1_score_temp & {RTO_CIW+RAW_CIW{!nlm_rto_sgn[RAW_CIW+SQRT_RECIP_COW]}}) >> step_1_sft_sel_num_que_nxt[2*COM_STEP_1_NLM_RTO_DLY+:2];

assign df_rto_0_sel_num_que_nxt        = {df_rto_0_sel_num_que        [0+:RAW_CIW          *(COM_STEP_1_RAW_MAX_MIN_DLY+1)],df_rto_0_sel_num};
assign df_rto_1_sel_num_que_nxt        = {df_rto_1_sel_num_que        [0+:RAW_CIW          *(COM_STEP_1_RAW_MAX_MIN_DLY+1)],df_rto_1_sel_num};
assign step_1_high_nlm_sel_num_que_nxt = {step_1_high_nlm_sel_num_que [0+:(R_LOW_NLM_CIW+1) *(COM_STEP_1_NLM_RTO_DLY    +1)],step_1_high_nlm_sel_num};
assign step_1_low_nlm_sel_num_que_nxt  = {step_1_low_nlm_sel_num_que  [0+:R_LOW_NLM_CIW     *(COM_STEP_1_NLM_RTO_DLY    +1)],step_1_low_nlm_sel_num};
assign step_1_sft_sel_num_que_nxt      = {step_1_sft_sel_num_que      [0+:2                *(COM_STEP_1_NLM_RTO_DLY    +1)],step_1_sft_sel_num};
assign df_step_1_score_que_nxt         = {df_step_1_score_que         [0+:(1+RAW_CIW)      *(COM_STEP_2_ALL_SCR_DLY    +1)],df_step_1_score}; 

//-----------------------------------------------------------------------------------------------------------step 2 get neighbor score //pipe_step_1_2 end //pipe_step_2_1 start  
//--------------------------------------------------------------------------------------step_2_color_1
assign step_2_color_1[RAW_CIW*1-1:RAW_CIW*0]     = step_1_color_1[RAW_CIW*1-1:RAW_CIW*0];
assign step_2_color_1[RAW_CIW*2-1:RAW_CIW*1]     = step_1_color_1[RAW_CIW*2-1:RAW_CIW*1];
assign step_2_color_1[RAW_CIW*3-1:RAW_CIW*2]     = step_1_color_1[RAW_CIW*5-1:RAW_CIW*4];
assign step_2_color_1[RAW_CIW*4-1:RAW_CIW*3]     = step_1_color_1[RAW_CIW*6-1:RAW_CIW*5]; //target pixel 

assign step_2_color_1[RAW_CIW*5-1:RAW_CIW*4]     = step_1_color_1[RAW_CIW*3-1:RAW_CIW*2];
assign step_2_color_1[RAW_CIW*6-1:RAW_CIW*5]     = step_1_color_1[RAW_CIW*4-1:RAW_CIW*3];
assign step_2_color_1[RAW_CIW*7-1:RAW_CIW*6]     = step_1_color_1[RAW_CIW*8-1:RAW_CIW*7];
assign step_2_color_1[RAW_CIW*8-1:RAW_CIW*7]     = step_1_color_1[RAW_CIW*7-1:RAW_CIW*6]; //target pixel 

assign step_2_color_1[RAW_CIW*9-1:RAW_CIW*8]     = step_1_color_1[RAW_CIW*9-1:RAW_CIW*8];
assign step_2_color_1[RAW_CIW*10-1:RAW_CIW*9]    = step_1_color_1[RAW_CIW*13-1:RAW_CIW*12];
assign step_2_color_1[RAW_CIW*11-1:RAW_CIW*10]   = step_1_color_1[RAW_CIW*14-1:RAW_CIW*13];
assign step_2_color_1[RAW_CIW*12-1:RAW_CIW*11]   = step_1_color_1[RAW_CIW*10-1:RAW_CIW*9]; //target pixel 

assign step_2_color_1[RAW_CIW*13-1:RAW_CIW*12]   = step_1_color_1[RAW_CIW*12-1:RAW_CIW*11];
assign step_2_color_1[RAW_CIW*14-1:RAW_CIW*13]   = step_1_color_1[RAW_CIW*15-1:RAW_CIW*14];
assign step_2_color_1[RAW_CIW*15-1:RAW_CIW*14]   = step_1_color_1[RAW_CIW*16-1:RAW_CIW*15];
assign step_2_color_1[RAW_CIW*16-1:RAW_CIW*15]   = step_1_color_1[RAW_CIW*11-1:RAW_CIW*10]; //target pixel 

//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_1[00] |                    | step_2_color_1[01] |                    | step_2_color_1[04] |                    | step_2_color_1[05] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_1[02] |                    |(step_2_color_1[03])|                    |(step_2_color_1[07])|                    | step_2_color_1[06] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |    target pixel    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_1[08] |                    |(step_2_color_1[11])|                    |(step_2_color_1[15])|                    | step_2_color_1[12] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_1[09] |                    | step_2_color_1[10] |                    | step_2_color_1[13] |                    | step_2_color_1[14] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |

assign step_2_max_sel_num     = ptnl_w_point_que_nxt[COM_STEP_2_COL_MAX_MIN_DLY+:1] ? r_step2_w_rto_thres        : i_step2_b_rto_thres_rng_cu;  //precision : 3.2
assign step_2_min_sel_num     = ptnl_w_point_que_nxt[COM_STEP_2_COL_MAX_MIN_DLY+:1] ? i_step2_w_rto_thres_rng_cu : r_step2_b_rto_thres;         //precision : 3.2
assign step_2_rng_sel_num     = ptnl_w_point_que_nxt[COM_STEP_2_COL_STG_1_DLY+:1] ? r_step2_w_buf_rng[2:1]     : r_step2_b_buf_rng[2:1];      //precision : 2.0 //use for shift 
assign step_2_thres_sel_num_3 = ptnl_w_point_que_nxt[COM_STEP_2_COL_STG_1_DLY+:1] ? i_step2_w_rto_thres_3_cu   : i_step2_b_rto_thres_3_cu;    //precision : 6.2 
assign step_2_thres_sel_num_5 = ptnl_w_point_que_nxt[COM_STEP_2_COL_STG_1_DLY+:1] ? i_step2_w_rto_thres_5_cu   : i_step2_b_rto_thres_5_cu;    //precision : 7.2

  for(index=0;index<STAGE_2_NBR_4;index=index+1) begin : gen_step_2_0_color_1_find_score
  
    assign step_2_color_1_max_sgn_nxt[index] =   
         $signed({1'b0,step_2_color_1_que_nxt[RAW_CIW*(STAGE_2_NBR_4*STAGE_2_NBR_4*(COM_NLM_IP_DLY)+(STAGE_2_NBR_4*(index+1)-1))+:RAW_CIW],{SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW{1'b0}}}) + 
         $signed({ptnl_w_point_que_nxt[COM_STEP_2_COL_MAX_MIN_DLY+:1],1'b1}) * $signed(step_2_max_sel_num) * 
         $signed({1'b0,nlm_sqrt[((SQRT_CIW/2)+IP_SQRT_OEXD)*(index+1)+:((SQRT_CIW/2)+IP_SQRT_OEXD)]}); 
                                                                                                                                   //precision : (10.0 +- (3.2*7.5) = s.10.7 => s.11.7
    assign step_2_color_1_min_sgn_nxt[index] =    
         $signed({1'b0,step_2_color_1_que_nxt[RAW_CIW*(STAGE_2_NBR_4*STAGE_2_NBR_4*(COM_NLM_IP_DLY)+(STAGE_2_NBR_4*(index+1)-1))+:RAW_CIW],
                                                                                                                                           {SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW{1'b0}}}) + 
         $signed({ptnl_w_point_que_nxt[COM_STEP_2_COL_MAX_MIN_DLY+:1],1'b1}) * $signed(step_2_min_sel_num) * 
         $signed({1'b0,nlm_sqrt[((SQRT_CIW/2)+IP_SQRT_OEXD)*(index+1)+:((SQRT_CIW/2)+IP_SQRT_OEXD)]}); 
                                                                                                                                   //precision : (10.0 +- (3.2*7.5) = s.10.7 => s.11.7
                                      
      for(index_2=0;index_2<STAGE_2_NBR_4-1;index_2=index_2+1) begin : gen_step_2_1_color_1_find_score
        if(index_2 != STAGE_2_NBR_4-1) begin
            assign step_2_color_1_clip_sgn_nxt[index*(STAGE_2_NBR_4-1)+index_2] =  //set 
               ($signed({1'b0,step_2_color_1_que_nxt[RAW_CIW*COM_STEP_2_COL_CLIP_DLY*STAGE_2_NBR_4*STAGE_2_NBR_4+RAW_CIW*(index*STAGE_2_NBR_4+index_2)+:RAW_CIW]}) > 
                               $signed(step_2_color_1_max_sgn[index][SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW+:RAW_CIW+1])) ? $signed(step_2_color_1_max_sgn[index]) :
               ($signed({1'b0,step_2_color_1_que_nxt[RAW_CIW*COM_STEP_2_COL_CLIP_DLY*STAGE_2_NBR_4*STAGE_2_NBR_4+RAW_CIW*(index*STAGE_2_NBR_4+index_2)+:RAW_CIW]}) <= 
                               $signed(step_2_color_1_min_sgn[index][SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW+:RAW_CIW+1])) ? $signed(step_2_color_1_min_sgn[index]) : 
               {step_2_color_1_que_nxt[RAW_CIW*COM_STEP_2_COL_CLIP_DLY*STAGE_2_NBR_4*STAGE_2_NBR_4+RAW_CIW*(index*STAGE_2_NBR_4+index_2)+:RAW_CIW],
                                                                                                                         {SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW{1'b0}}}; //precision :s.11.7
        end 
      end 
      
    assign step_2_color_1_sum_0_sgn_nxt[index]         = $signed(step_2_color_1_clip_sgn[0+((STAGE_2_NBR_4-1)*index)]) + 
                                                         $signed(step_2_color_1_clip_sgn[1+((STAGE_2_NBR_4-1)*index)]);                       //precision : s.12.7
                                                         
    assign step_2_color_1_sum_1_sgn_nxt[index]         = $signed(step_2_color_1_clip_sgn[2+((STAGE_2_NBR_4-1)*index)]);                       //precision : s.11.7
                                                         
    assign step_2_color_1_sum_sgn_nxt[index]           = $signed(step_2_color_1_sum_0_sgn[index]) + $signed(step_2_color_1_sum_1_sgn[index]); //precision : s.13.7
                                                                                                             
    assign step_2_color_1_num_0_sgn[index]             = $signed({1'b0,2'd3}) *$signed({1'b0,step_2_color_1_que_nxt[RAW_CIW*(STAGE_2_NBR_4*STAGE_2_NBR_4*
                                                                             COM_STEP_2_COL_SUM_DLY+(STAGE_2_NBR_4*(index+1)-1))+:RAW_CIW],{SQRT_COPW+R_RTO_THRES_CIPW{1'b0}}}); 
                                                                                                                                              //precision : 10.0 * 2.0 = s.12.0
    assign step_2_color_1_num_1_sgn[index]             = $signed(step_2_color_1_sum_sgn[index]);
    assign step_2_color_1_sel_num_0_sgn_nxt[index]     = ptnl_w_point_que_nxt[COM_STEP_2_COL_SEL_NUM_DLY+:1] ? step_2_color_1_num_0_sgn[index] : step_2_color_1_num_1_sgn[index];
    assign step_2_color_1_sel_num_1_sgn_nxt[index]     = ptnl_w_point_que_nxt[COM_STEP_2_COL_SEL_NUM_DLY+:1] ? step_2_color_1_num_1_sgn[index] : step_2_color_1_num_0_sgn[index];

    assign step_2_color_1_score_stage_0_sgn_nxt[index] = $signed(step_2_color_1_sel_num_0_sgn[index] - step_2_color_1_sel_num_1_sgn[index]); //precision : (s.13.7-s.13.7) 

    assign step_2_color_1_score_stage_1_sgn_nxt[index] = $signed(step_2_color_1_score_stage_0_sgn[index])*   //set
                                                         $signed({1'b0,nlm_sqrt_recip_que_nxt[((IP_SQRT_ORPCS+1)*COLOR_ARRAY_NUM_2 * 
                                                                    COM_STEP_2_COL_NLM_REC_DLY)+(IP_SQRT_ORPCS+1)*(index+1)+:(IP_SQRT_ORPCS+1)]}) + 
                                                         $signed({1'b0,1'b1,{SQRT_RECIP_COPW+SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIW-1{1'b0}}}); 
                                                                                                                                       //precision : (s.13.7)*0.10 +rounding = 
                                                                                                                                       //             s.13.17 => 6.10 
                                                                                                                                          
                                                         
    assign step_2_color_1_score_stage_2_sgn[index]     = ($signed(step_2_color_1_score_stage_1_sgn[index][SQRT_RECIP_COPW+SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIW+:SCORE_STG_0_CIW+RAW_CIW])- 
                                                         $signed({1'b0,step_2_thres_sel_num_3,{RAW_CIW-R_RTO_THRES_CIPW{1'b0}}})) >>> step_2_rng_sel_num; //precision : 6.10  => 2.10 
                                                         
    assign step_2_color_1_score_stage_3[index]         = (($signed(step_2_color_1_score_stage_2_sgn[index][RAW_CIW+:SCORE_STG_0_CIW]) >= $signed({1'b0,2'd3})) ? {2'd3,{RAW_CIW{1'b0}}} : 
                                                         (step_2_color_1_score_stage_2_sgn[index][0+:SCORE_STG_1_N3_CIW+RAW_CIW] & 
                                                         {SCORE_STG_1_N3_CIW+RAW_CIW{!step_2_color_1_score_stage_2_sgn[index][SCORE_STG_0_CIW+RAW_CIW+1-1]}})) >>> step_2_rng_sel_num;
                                                                                                                                                         //precision : 2.10 //range:0~3
  end //end generate 

assign step_2_color_1_que_nxt          = {step_2_color_1_que[0+:RAW_CIW*(STAGE_2_NBR_4*STAGE_2_NBR_4)*(COM_STEP_2_COL_SUM_DLY+1)],step_2_color_1};

//--------------------------------------------------------------------------------------step_2_color_2
assign step_2_color_2[RAW_CIW*1-1:RAW_CIW*0]   = step_1_color_2[RAW_CIW*1 -1:RAW_CIW*0]; 
assign step_2_color_2[RAW_CIW*2-1:RAW_CIW*1]   = step_1_color_2[RAW_CIW*2 -1:RAW_CIW*1]; 
assign step_2_color_2[RAW_CIW*3-1:RAW_CIW*2]   = step_1_color_2[RAW_CIW*5 -1:RAW_CIW*4];
assign step_2_color_2[RAW_CIW*4-1:RAW_CIW*3]   = step_1_color_2[RAW_CIW*9 -1:RAW_CIW*8];
assign step_2_color_2[RAW_CIW*5-1:RAW_CIW*4]   = step_1_color_2[RAW_CIW*10-1:RAW_CIW*9];
assign step_2_color_2[RAW_CIW*6-1:RAW_CIW*5]   = step_1_color_2[RAW_CIW*6 -1:RAW_CIW*5]; //gb0

assign step_2_color_2[RAW_CIW*7-1:RAW_CIW*6]   = step_1_color_2[RAW_CIW*3 -1:RAW_CIW*2];
assign step_2_color_2[RAW_CIW*8-1:RAW_CIW*7]   = step_1_color_2[RAW_CIW*4 -1:RAW_CIW*3];
assign step_2_color_2[RAW_CIW*9-1:RAW_CIW*8]   = step_1_color_2[RAW_CIW*8 -1:RAW_CIW*7];
assign step_2_color_2[RAW_CIW*10-1:RAW_CIW*9]  = step_1_color_2[RAW_CIW*11-1:RAW_CIW*10];
assign step_2_color_2[RAW_CIW*11-1:RAW_CIW*10] = step_1_color_2[RAW_CIW*12-1:RAW_CIW*11];
assign step_2_color_2[RAW_CIW*12-1:RAW_CIW*11] = step_1_color_2[RAW_CIW*7 -1:RAW_CIW*6]; //gb1


//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    | step_2_color_2[00] |                    | step_2_color_2[01] |                    | step_2_color_2[02] |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    | step_2_color_2[03] |                    |(step_2_color_2[05])|                    | step_2_color_2[04] |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    | step_2_color_2[06] |                    |(step_2_color_2[11])|                    | step_2_color_2[07] |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    | step_2_color_2[08] |                    | step_2_color_2[09] |                    | step_2_color_2[10] |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |

  for(index=0;index<2;index=index+1) begin : gen_step_2_0_color_2_find_score
                    
    assign step_2_color_2_max_sgn_nxt[index] = //set 
               $signed({1'b0,step_2_color_2_que_nxt[RAW_CIW*(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2*(COM_NLM_IP_DLY)+(STAGE_2_NBR_2_SUB_6*(index+1)-1))+:RAW_CIW],
                                                                                                                                           {SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW{1'b0}}}) + 
               $signed({ptnl_w_point_que_nxt[COM_STEP_2_COL_MAX_MIN_DLY+:1],1'b1}) * $signed(step_2_max_sel_num) * 
               $signed({1'b0,nlm_sqrt[((SQRT_CIW/2)+IP_SQRT_OEXD)*(STAGE_2_NBR_4+index+1)+:((SQRT_CIW/2)+IP_SQRT_OEXD)]});            //precision : (10.0 +- (3.2*7.5) = s.10.7 => s.11.7
    assign step_2_color_2_min_sgn_nxt[index] = 
               $signed({1'b0,step_2_color_2_que_nxt[RAW_CIW*(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2*(COM_NLM_IP_DLY)+(STAGE_2_NBR_2_SUB_6*(index+1)-1))+:RAW_CIW],
                                                                                                                                           {SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW{1'b0}}}) + 
               $signed({ptnl_w_point_que_nxt[COM_STEP_2_COL_MAX_MIN_DLY+:1],1'b1}) * $signed(step_2_min_sel_num) * 
               $signed({1'b0,nlm_sqrt[((SQRT_CIW/2)+IP_SQRT_OEXD)*(STAGE_2_NBR_4+index+1)+:((SQRT_CIW/2)+IP_SQRT_OEXD)]});            //precision : (10.0 +- (3.2*7.5) = s.10.7 => s.11.7
      
      for(index_2=0;index_2<(6-1);index_2=index_2+1) begin : gen_step_2_1_color_2_find_score
        if(index_2 != (6-1)) begin
              assign step_2_color_2_clip_sgn_nxt[index*(6-1)+index_2] = 
                    ($signed({1'b0,step_2_color_2_que_nxt[RAW_CIW*COM_STEP_2_COL_CLIP_DLY*STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2+RAW_CIW*(index*STAGE_2_NBR_2_SUB_6+index_2)+:RAW_CIW]}) > 
                                              $signed(step_2_color_2_max_sgn[index][SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW+:RAW_CIW+1])) ? $signed(step_2_color_2_max_sgn[index]) :
                    ($signed({1'b0,step_2_color_2_que_nxt[RAW_CIW*COM_STEP_2_COL_CLIP_DLY*STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2+RAW_CIW*(index*STAGE_2_NBR_2_SUB_6+index_2)+:RAW_CIW]}) <= 
                                              $signed(step_2_color_2_min_sgn[index][SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW+:RAW_CIW+1])) ? $signed(step_2_color_2_min_sgn[index]) : 
                    {step_2_color_2_que_nxt[RAW_CIW*COM_STEP_2_COL_CLIP_DLY*STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2+RAW_CIW*(index*STAGE_2_NBR_2_SUB_6+index_2)+:RAW_CIW],
                                                                                                                        {SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW{1'b0}}};//precision :s.11.7
                                                                                                                                                                         
        end 
      end 
      
    assign step_2_color_2_sum_0_sgn_nxt[index]         = $signed(step_2_color_2_clip_sgn[0+((STAGE_2_NBR_2_SUB_6-1)*index)]) +  
                                                         $signed(step_2_color_2_clip_sgn[1+((STAGE_2_NBR_2_SUB_6-1)*index)]) + 
                                                         $signed(step_2_color_2_clip_sgn[2+((STAGE_2_NBR_2_SUB_6-1)*index)]);  //precision : s.13.7

    assign step_2_color_2_sum_1_sgn_nxt[index]         = $signed(step_2_color_2_clip_sgn[3+((STAGE_2_NBR_2_SUB_6-1)*index)]) +  
                                                         $signed(step_2_color_2_clip_sgn[4+((STAGE_2_NBR_2_SUB_6-1)*index)]);  //precision : s.13.7

    assign step_2_color_2_sum_sgn_nxt[index]           = $signed(step_2_color_2_sum_0_sgn[index]) + $signed(step_2_color_2_sum_1_sgn[index]);  //precision : s.14.7
                                                       
    assign step_2_color_2_num_0_sgn[index]             = $signed({1'b0,3'd5})*$signed({1'b0,step_2_color_2_que_nxt[RAW_CIW*(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2*COM_STEP_2_COL_SUM_DLY+
                                                                (STAGE_2_NBR_2_SUB_6*(index+1)-1))+:RAW_CIW],{SQRT_COPW+R_RTO_THRES_CIPW{1'b0}}});
    assign step_2_color_2_num_1_sgn[index]             = $signed(step_2_color_2_sum_sgn[index]);
    assign step_2_color_2_sel_num_0_sgn_nxt[index]     = ptnl_w_point_que_nxt[COM_STEP_2_COL_SEL_NUM_DLY+:1] ? step_2_color_2_num_0_sgn[index] : step_2_color_2_num_1_sgn[index];
    assign step_2_color_2_sel_num_1_sgn_nxt[index]     = ptnl_w_point_que_nxt[COM_STEP_2_COL_SEL_NUM_DLY+:1] ? step_2_color_2_num_1_sgn[index] : step_2_color_2_num_0_sgn[index];

    assign step_2_color_2_score_stage_0_sgn_nxt[index] = $signed(step_2_color_2_sel_num_0_sgn[index] - step_2_color_2_sel_num_1_sgn[index]); //precision : (s.14.7-s.14.7) 

    assign step_2_color_2_score_stage_1_sgn_nxt[index] = $signed(step_2_color_2_score_stage_0_sgn[index])* 
                                                         $signed({1'b0,nlm_sqrt_recip_que_nxt[((IP_SQRT_ORPCS+1)*COLOR_ARRAY_NUM_2 * 
                                                                  COM_STEP_2_COL_NLM_REC_DLY)+(IP_SQRT_ORPCS+1)*(STAGE_2_NBR_4+index+1)+:(IP_SQRT_ORPCS+1)]}) + 
                                                         $signed({1'b0,1'b1,{SQRT_RECIP_COPW+SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIW-1{1'b0}}}); //precision : s.14.7 + 0.10 = s.14.17
                                                                                                                                           //                          => 6.10 //rounding
                                                         
    assign step_2_color_2_score_stage_2_sgn[index]     = ($signed(step_2_color_2_score_stage_1_sgn[index][SQRT_RECIP_COPW+SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIW+:SCORE_STG_0_CIW+RAW_CIW]) -
                                                         $signed({1'b0,step_2_thres_sel_num_5,{RAW_CIW-R_RTO_THRES_CIPW{1'b0}}})) >>> step_2_rng_sel_num; //precision : 6.10  => 3.10
                                                         
    assign step_2_color_2_score_stage_3[index]         = (($signed(step_2_color_2_score_stage_2_sgn[index][RAW_CIW+:SCORE_STG_0_CIW+1]) >= $signed({1'b0,3'd5})) ? 
                                                                                                                                                              {3'd5,{RAW_CIW{1'b0}}} : 
                                                         (step_2_color_2_score_stage_2_sgn[index][0+:SCORE_STG_1_N5_CIW+RAW_CIW] & 
                                                         {SCORE_STG_1_N5_CIW+RAW_CIW{!step_2_color_2_score_stage_2_sgn[index][SCORE_STG_0_CIW+RAW_CIW+1-1]}})) >>> step_2_rng_sel_num; 
                                                                                                                                                       //precision : 3.10 //range : 0~5
    
  end //end generate 

assign step_2_color_2_que_nxt = {step_2_color_2_que[0+:RAW_CIW*(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2)*(COM_STEP_2_COL_SUM_DLY+1)],step_2_color_2};

//--------------------------------------------------------------------------------------step_2_color_3
assign step_2_color_3[RAW_CIW*1-1:RAW_CIW*0]   = step_1_color_3[RAW_CIW*1-1:RAW_CIW*0]; 
assign step_2_color_3[RAW_CIW*2-1:RAW_CIW*1]   = step_1_color_3[RAW_CIW*2-1:RAW_CIW*1]; 
assign step_2_color_3[RAW_CIW*3-1:RAW_CIW*2]   = step_1_color_3[RAW_CIW*3-1:RAW_CIW*2];
assign step_2_color_3[RAW_CIW*4-1:RAW_CIW*3]   = step_1_color_3[RAW_CIW*4-1:RAW_CIW*3];
assign step_2_color_3[RAW_CIW*5-1:RAW_CIW*4]   = step_1_color_3[RAW_CIW*6-1:RAW_CIW*5];
assign step_2_color_3[RAW_CIW*6-1:RAW_CIW*5]   = step_1_color_3[RAW_CIW*5-1:RAW_CIW*4]; //gr0

assign step_2_color_3[RAW_CIW*7-1:RAW_CIW*6]   = step_1_color_3[RAW_CIW*7 -1:RAW_CIW*6];
assign step_2_color_3[RAW_CIW*8-1:RAW_CIW*7]   = step_1_color_3[RAW_CIW*9 -1:RAW_CIW*8];
assign step_2_color_3[RAW_CIW*9-1:RAW_CIW*8]   = step_1_color_3[RAW_CIW*10-1:RAW_CIW*9];
assign step_2_color_3[RAW_CIW*10-1:RAW_CIW*9]  = step_1_color_3[RAW_CIW*11-1:RAW_CIW*10];
assign step_2_color_3[RAW_CIW*11-1:RAW_CIW*10] = step_1_color_3[RAW_CIW*12-1:RAW_CIW*11];
assign step_2_color_3[RAW_CIW*12-1:RAW_CIW*11] = step_1_color_3[RAW_CIW*8 -1:RAW_CIW*7]; //gr1

//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_3[00] |                    | step_2_color_3[01] |                    | step_2_color_3[06] |                    | step_2_color_3[07] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_3[02] |                    |(step_2_color_3[05])|                    |(step_2_color_3[11])|                    | step_2_color_3[08] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//| step_2_color_3[03] |                    | step_2_color_3[04] |                    | step_2_color_3[09] |                    | step_2_color_3[10] |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |
//|                    |                    |                    |                    |                    |                    |                    |
//|:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |:------------------ |

  for(index=0;index<2;index=index+1) begin : gen_step_2_0_color_3_find_score
  
    assign step_2_color_3_max_sgn_nxt[index] = 
                   $signed({1'b0,step_2_color_3_que_nxt[RAW_CIW*(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2*(COM_NLM_IP_DLY)+(STAGE_2_NBR_2_SUB_6*(index+1)-1))+:RAW_CIW],
                                                                                                                                         {SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW{1'b0}}}) + 
                   $signed({ptnl_w_point_que_nxt[COM_STEP_2_COL_MAX_MIN_DLY+:1],1'b1}) * $signed(step_2_max_sel_num) * 
                   $signed({1'b0,nlm_sqrt[((SQRT_CIW/2)+IP_SQRT_OEXD)*(STAGE_2_NBR_4+STAGE_2_NBR_2+index+1)+:((SQRT_CIW/2)+IP_SQRT_OEXD)]}); 
                                                                                                                                   //precision : (10.0 +- (3.2*7.5) = s.10.7 => s.11.7
    assign step_2_color_3_min_sgn_nxt[index] =   
                   $signed({1'b0,step_2_color_3_que_nxt[RAW_CIW*(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2*(COM_NLM_IP_DLY)+(STAGE_2_NBR_2_SUB_6*(index+1)-1))+:RAW_CIW],
                                                                                                                                         {SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW{1'b0}}}) + 
                   $signed({ptnl_w_point_que_nxt[COM_STEP_2_COL_MAX_MIN_DLY+:1],1'b1}) * $signed(step_2_min_sel_num) * 
                   $signed({1'b0,nlm_sqrt[((SQRT_CIW/2)+IP_SQRT_OEXD)*(STAGE_2_NBR_4+STAGE_2_NBR_2+index+1)+:((SQRT_CIW/2)+IP_SQRT_OEXD)]}); 
                                                                                                                                   //precision : (10.0 +- (3.2*7.5) = s.10.7 => s.11.7
      for(index_2=0;index_2<(6-1);index_2=index_2+1) begin : gen_step_2_1_color_3_find_score
        if(index_2 != (6-1)) begin
              assign step_2_color_3_clip_sgn_nxt[index*(6-1)+index_2] = 
              ($signed({1'b0,step_2_color_3_que_nxt[RAW_CIW*COM_STEP_2_COL_CLIP_DLY*STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2+RAW_CIW*(index*STAGE_2_NBR_2_SUB_6+index_2)+:RAW_CIW]}) > 
                                              $signed(step_2_color_3_max_sgn[index][SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW+:RAW_CIW+1])) ? $signed(step_2_color_3_max_sgn[index]) :
              ($signed({1'b0,step_2_color_3_que_nxt[RAW_CIW*COM_STEP_2_COL_CLIP_DLY*STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2+RAW_CIW*(index*STAGE_2_NBR_2_SUB_6+index_2)+:RAW_CIW]}) <= 
                                              $signed(step_2_color_3_min_sgn[index][SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW+:RAW_CIW+1])) ? $signed(step_2_color_3_min_sgn[index]) : 
              {step_2_color_3_que_nxt[RAW_CIW*COM_STEP_2_COL_CLIP_DLY*STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2+RAW_CIW*(index*STAGE_2_NBR_2_SUB_6+index_2)+:RAW_CIW],
                                                                                                                      {SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIPW{1'b0}}}; //precision :s.11.7
        end 
      end 
      
    assign step_2_color_3_sum_0_sgn_nxt[index]         = $signed(step_2_color_3_clip_sgn[0+((STAGE_2_NBR_2_SUB_6-1)*index)]) + 
                                                         $signed(step_2_color_3_clip_sgn[1+((STAGE_2_NBR_2_SUB_6-1)*index)]) + 
                                                         $signed(step_2_color_3_clip_sgn[2+((STAGE_2_NBR_2_SUB_6-1)*index)]);  //precision : s.13.7

    assign step_2_color_3_sum_1_sgn_nxt[index]         = $signed(step_2_color_3_clip_sgn[3+((STAGE_2_NBR_2_SUB_6-1)*index)]) + 
                                                         $signed(step_2_color_3_clip_sgn[4+((STAGE_2_NBR_2_SUB_6-1)*index)]);  //precision : s.13.7

    assign step_2_color_3_sum_sgn_nxt[index]           = $signed(step_2_color_3_sum_0_sgn[index]) + $signed(step_2_color_3_sum_1_sgn[index]); //precision : s.14.7
                                                                                                                
    assign step_2_color_3_num_0_sgn[index]             = $signed({1'b0,3'd5})*$signed({1'b0,step_2_color_3_que_nxt[RAW_CIW*(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2*
                                                                       COM_STEP_2_COL_SUM_DLY+(STAGE_2_NBR_2_SUB_6*(index+1)-1))+:RAW_CIW],{SQRT_COPW+R_RTO_THRES_CIPW{1'b0}}});
                                                                       
    assign step_2_color_3_num_1_sgn[index]             = $signed(step_2_color_3_sum_sgn[index]);
    assign step_2_color_3_sel_num_0_sgn_nxt[index]     = ptnl_w_point_que_nxt[COM_STEP_2_COL_SEL_NUM_DLY+:1] ? step_2_color_3_num_0_sgn[index] : step_2_color_3_num_1_sgn[index];
    assign step_2_color_3_sel_num_1_sgn_nxt[index]     = ptnl_w_point_que_nxt[COM_STEP_2_COL_SEL_NUM_DLY+:1] ? step_2_color_3_num_1_sgn[index] : step_2_color_3_num_0_sgn[index];
    
    assign step_2_color_3_score_stage_0_sgn_nxt[index] = $signed(step_2_color_3_sel_num_0_sgn[index] - step_2_color_3_sel_num_1_sgn[index]); //precision : (s.14.7-s.14.7) 
    
    assign step_2_color_3_score_stage_1_sgn_nxt[index] = $signed(step_2_color_3_score_stage_0_sgn[index])*    
                                                         $signed({1'b0,nlm_sqrt_recip_que_nxt[((IP_SQRT_ORPCS+1)*COLOR_ARRAY_NUM_2 * 
                                                                  COM_STEP_2_COL_NLM_REC_DLY)+(IP_SQRT_ORPCS+1)*(STAGE_2_NBR_4+STAGE_2_NBR_2+index+1)+:(IP_SQRT_ORPCS+1)]}) + 
                                                         {1'b1,{SQRT_RECIP_COPW+SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIW-1{1'b0}}};                //precision : s.14.7 + 0.10 = s.14.17
                                                                                                                                            //                          => 6.10 //rounding
                                                         
    assign step_2_color_3_score_stage_2_sgn[index]     = ($signed(step_2_color_3_score_stage_1_sgn[index][SQRT_RECIP_COPW+SQRT_COPW+R_RTO_THRES_CIPW-RAW_CIW+:SCORE_STG_0_CIW+RAW_CIW])-
                                                         $signed({1'b0,step_2_thres_sel_num_5,{RAW_CIW-R_RTO_THRES_CIPW{1'b0}}})) >>> step_2_rng_sel_num; //precision : 6.10  => 3.10
                                                         
    assign step_2_color_3_score_stage_3[index]         = (($signed(step_2_color_3_score_stage_2_sgn[index][RAW_CIW+:SCORE_STG_0_CIW+1]) >= $signed({1'b0,3'd5})) ? //set 
                                                                                                                                                                 {3'd5,{RAW_CIW{1'b0}}} : 
                                                         (step_2_color_3_score_stage_2_sgn[index][0+:SCORE_STG_1_N5_CIW+RAW_CIW] & 
                                                         {SCORE_STG_1_N5_CIW+RAW_CIW{!step_2_color_3_score_stage_2_sgn[index][SCORE_STG_0_CIW+RAW_CIW+1-1]}})) >>> step_2_rng_sel_num; 
                                                                                                                                                       //precision : 3.10  //range : 0~5
    
    
  end //end generate 

assign step_2_color_total_sum_0_nxt = step_2_color_1_score_stage_3[0] + //2.10 //set 
                                      step_2_color_1_score_stage_3[1] + //2.10
                                      step_2_color_1_score_stage_3[2] ; //2.10
 

assign step_2_color_total_sum_1_nxt = step_2_color_1_score_stage_3[3] + 
                                      step_2_color_2_score_stage_3[0] + //3.10
                                      step_2_color_2_score_stage_3[1] ; //3.10

assign step_2_color_total_sum_2_nxt = step_2_color_3_score_stage_3[0] + //3.10  
                                      step_2_color_3_score_stage_3[1] + //3.10  //6.10 //range from 0~32 => 0~8  
                                      {1'b1,1'b0};                      //rounding 
                                
assign step_2_color_total_sum_nxt   = step_2_color_total_sum_0 + step_2_color_total_sum_1 + step_2_color_total_sum_2;


assign step_2_color_3_que_nxt       = {step_2_color_3_que[0+:RAW_CIW*(STAGE_2_NBR_2_SUB_6*STAGE_2_NBR_2)*(COM_STEP_2_COL_SUM_DLY+1)],step_2_color_3};

//-----------------------------------------------------------------------------------------------------------step 2 get confidence score //pipe_step_2_1 end //pipe_step_2_2 start
assign step_2_cnt_thres_sel_num     = ptnl_w_point_que_nxt[COM_STEP_2_COL_TOL_SUM_DLY+:1] ? r_step2_w_cnt_thres   : r_step2_b_cnt_thres;    //precison : 3.2 
assign step_2_cnt_rng_sel_num       = ptnl_w_point_que_nxt[COM_STEP_2_COL_TOL_SUM_DLY+:1] ? r_step2_w_cnt_buf_rng : r_step2_b_cnt_buf_rng; 

assign df_step_2_score_sgn          = (step_2_color_total_sum[RAW_CIW+SCORE_STG_1_N5_CIW+3-1:2] - {step_2_cnt_thres_sel_num,{RAW_CIW-R_CNT_THRES_CIPW{1'b0}}}); //4.10 
                                                                                                               
assign step_2_score_com_sgn         = ($signed(df_step_2_score_sgn) >>> step_2_cnt_rng_sel_num[2:1]) + step_2_cnt_rng_sel_num[2:1]; //4.10 //rounding 
assign df_step_2_score_clip         = (step_2_score_com_sgn[RAW_CIW+SCORE_STG_1_N5_CIW+1] == 1'b1) ? {RAW_CIW+1{1'b0}} : 
                                      (step_2_score_com_sgn[RAW_CIW+:SCORE_STG_1_N5_CIW+1] >= 2'b1) ? {1'b1,{RAW_CIW{1'b0}}} : step_2_score_com_sgn;
                                      
assign df_step_2_score_inv_nxt      = {1'b1,{RAW_CIW{1'b0}}} - df_step_2_score_clip; //1.10   
                             
  if(MODE_SEL == 2) begin : all_score                          
    assign df_all_step_score_nxt        = r_debug_en ? {r_repl_col,{RAW_CIW-8{1'b0}}} :  
                                          (df_step_2_score_inv * df_step_1_score_que_nxt[(1+RAW_CIW)*COM_STEP_2_ALL_SCR_DLY+:(1+RAW_CIW)]) &   //1.10 * 1.10  => 1.20 
                                          {(1+RAW_CIW+RAW_CIW){r_dpc_en}};
  end 
  else begin 
    assign all_score_msb_en             = (df_step_2_score_inv[RAW_CIW] & df_step_1_score_que_nxt[(1+RAW_CIW)*COM_STEP_2_ALL_SCR_DLY+(1+RAW_CIW-1)] & r_mode_sel[1]) | 
                                          (coord_total_eq_que_nxt[COM_STA_ALL_SCORE_DLY] & r_mode_sel[0]);                                              //1.0 * 1.0 => 1.0
    
    assign all_score_lsb_en             = ((df_step_2_score_inv * df_step_1_score_que_nxt[(1+RAW_CIW)*COM_STEP_2_ALL_SCR_DLY+:(1+RAW_CIW)]) & 
                                          {1'b0,{(RAW_CIW+RAW_CIW){r_mode_sel[1] & 
                                          !(coord_total_eq_que_nxt[COM_STA_ALL_SCORE_DLY] & r_mode_sel[0])}}});  //1.10 * 1.10  => 1.20 

    assign df_all_step_score_nxt        = r_debug_en ? {r_repl_col,{RAW_CIW-8{1'b0}}} :
                                          {all_score_msb_en,all_score_lsb_en} & {(1+RAW_CIW+RAW_CIW){r_dpc_en}}; //static priority higher than dynamic 
  end //end generate 
  
assign df_all_step_score_inv_nxt    = {1'b1,{RAW_CIW{1'b0}}} - df_all_step_score[RAW_CIW+:RAW_CIW+1];            //1.10  
assign repl_pixel_nxt               = target_pixel_que_nxt[(RAW_CIW)*COM_STEP_2_REPL_DLY+:(RAW_CIW)]* //set 
                                      df_all_step_score_inv_nxt + 
                                      raw_fnl_sel_num_que_nxt[(RAW_CIW)*(COM_STEP_2_REPL_RAW_FNL_DLY)+:(RAW_CIW)]*
                                      df_all_step_score[RAW_CIW+:RAW_CIW+1] + {1'b1,{RAW_CIW-1{1'b0}}};   //RAW_CIW * 1.10 + RAW_CIW * 1.10 +rounding
                                      

end 
endgenerate //dynamic_part_1_end //end generate 

generate 
  if(MODE_SEL == 1'd1) begin   
    assign step_2_en                    = 0;
  end 
  else  begin                                   
    assign step_2_en                    = !df_all_step_score_inv[RAW_CIW];
  end 
endgenerate

generate   //static_confidence_start 
  if(MODE_SEL == 1) begin : static_confidence_start
      
  assign target_repl          = r_debug_en ? {r_repl_col,{RAW_CIW-8{1'b0}}} : 
                                (r_dpc_en & coord_total_eq_que_nxt[COM_STA_TARGET_REPL_DLY])?raw_fnl_sta_sel_num_que_nxt[(RAW_CIW)*(COM_STA_FNL_STA_SEL_DLY)+:(RAW_CIW)]:
                                target_pixel_que_nxt[(RAW_CIW)*COM_STEP_2_TAR_REPL_DLY+:(RAW_CIW)]; 
end 
  else begin 
  assign target_repl          = step_2_en ? repl_pixel[RAW_CIW+:RAW_CIW+1] : target_pixel_que_nxt[(RAW_CIW)*COM_STEP_2_TAR_REPL_DLY+:(RAW_CIW)];
  end 
endgenerate //static_confidence_end

assign coord_total_eq_que_nxt       = {coord_total_eq_que[0+:(COM_STA_TARGET_REPL_DLY+1)],coord_total_eq};
assign coord_bw_que_nxt             = {coord_bw_que[0+:(COM_STEP_1_RAW_FNL_DLY+1)],coord_bw};
  
//-----------------------------------------------------------------------------------------------------------output  //pipe_step_2_2 end //pipe_output start 
assign o_data_nxt                   = target_repl;
assign o_vstr_nxt                   = video_que_nxt[5*(COM_VIDEO_DLY)+4];
assign o_hstr_nxt                   = video_que_nxt[5*(COM_VIDEO_DLY)+3];
assign o_href_nxt                   = video_que_nxt[5*(COM_VIDEO_DLY)+2];
assign o_hend_nxt                   = video_que_nxt[5*(COM_VIDEO_DLY)+1];
assign o_vend_nxt                   = video_que_nxt[5*(COM_VIDEO_DLY)+0];
assign o_wdpc_cnt_nxt               = dpc_wh_cnt;
assign o_bdpc_cnt_nxt               = dpc_bk_cnt;
assign o_static_num_cnt_nxt         = static_num_cnt;

assign video_que_nxt                = {video_que[0+:5*(COM_VIDEO_DLY)],i_vstr,i_hstr,i_href,i_hend,i_vend};

//-----------------------------------------------------------------------------------------------------------sequencial logic  //pipe_output end  
always@(posedge dpc_clk or negedge dpc_rst_n) begin 
if(!dpc_rst_n) begin 
//--------------------------------------------------------------------------------------static dpc 
  coord_sft_en                <= 0;
  coord_bw                    <= 0;
  coord_bw_que                <= 0;
  coord_total_eq              <= 0;
  coord_total_eq_que          <= 0;
  
//--------------------------------------------------------------------------------------counter 
  dpc_hor_cnt                 <= 0;
  dpc_ver_cnt                 <= 0;
  dpc_wh_cnt                  <= 0;
  dpc_bk_cnt                  <= 0;
  static_num_cnt              <= 0;
  
//--------------------------------------------------------------------------------------dpc step 1 potential point
  all_same                    <= 0;
  step_1_color_4              <= 0;
  target_pixel                <= 0;
  raw_max_fnl                 <= 0;
  raw_min_fnl                 <= 0;
  ptnl_w_point                <= 0;
  
  target_pixel_que            <= 0;
  raw_max_fnl_que             <= 0;
  raw_min_fnl_que             <= 0;
  ptnl_w_point_que            <= 0;
  step_1_color_4_que          <= 0;
  
  raw_fnl_sta_sel_num         <= 0;
  raw_fnl_sta_sel_num_que     <= 0;
  
//--------------------------------------------------------------------------------------step 1 pixel result
  step_1_low_nlm_sel_num      <= 0;
  step_1_sft_sel_num          <= 0;
  df_rto_0_sel_num            <= 0;
  df_rto_0_sel_num_que        <= 0;
  df_rto_1_sel_num            <= 0;
  df_rto_1_sel_num_que        <= 0;
  step_1_high_nlm_sel_num     <= 0;
  step_1_high_nlm_sel_num_que <= 0;
  step_1_low_nlm_sel_num      <= 0;
  step_1_low_nlm_sel_num_que  <= 0;
  step_1_sft_sel_num_que      <= 0;
  max_min_recip_sel_num       <= 0;
  step_1_high_nlm_sel_num     <= 0;
  nlm_rto_sgn                 <= 0;
  df_step_1_score             <= 0;
  df_step_1_score_que         <= 0;

//--------------------------------------------------------------------------------------nlm 
  nlm_sqrt_recip              <= 0;
  nlm_sqrt_recip_que          <= 0;
  
//--------------------------------------------------------------------------------------step 2 get neighbor score 
  step_2_color_1_que          <= 0;
  step_2_color_2_que          <= 0;
  step_2_color_3_que          <= 0;
  step_2_color_total_sum_0    <= 0;
  step_2_color_total_sum_1    <= 0;
  step_2_color_total_sum_2    <= 0;
  step_2_color_total_sum      <= 0;
  
//--------------------------------------------------------------------------------------step 2 get confidence score 
  df_step_2_score_inv         <= 0;
  df_all_step_score           <= 0;
  raw_fnl_sel_num             <= 0;
  raw_fnl_sel_num_que         <= 0;
  df_all_step_score_inv       <= 0;
  repl_pixel                  <= 0;
  
//--------------------------------------------------------------------------------------output  
  o_data                      <= 0;
  o_vstr                      <= 0;
  o_hstr                      <= 0;
  o_href                      <= 0;
  o_hend                      <= 0;
  o_vend                      <= 0;
  o_wdpc_cnt                  <= 0;
  o_bdpc_cnt                  <= 0;
  o_static_num_cnt            <= 0;
  video_que                   <= 0;
  
end
else begin 
//--------------------------------------------------------------------------------------static dpc 
  coord_sft_en                <= coord_sft_en_nxt;
  coord_bw                    <= coord_bw_nxt;
  coord_bw_que                <= coord_bw_que_nxt;
  coord_total_eq              <= coord_total_eq_nxt;
  coord_total_eq_que          <= coord_total_eq_que_nxt;
  
//--------------------------------------------------------------------------------------counter 
  dpc_hor_cnt                 <= dpc_hor_cnt_nxt;
  dpc_ver_cnt                 <= dpc_ver_cnt_nxt;
  dpc_wh_cnt                  <= dpc_wh_cnt_nxt;
  dpc_bk_cnt                  <= dpc_bk_cnt_nxt;
  static_num_cnt              <= static_num_cnt_nxt;
  
//--------------------------------------------------------------------------------------dpc step 1 potential point
  all_same                    <= all_same_nxt;
  step_1_color_4              <= step_1_color_4_nxt;
  target_pixel                <= target_pixel_nxt;
  raw_max_fnl                 <= raw_max_fnl_nxt;
  raw_min_fnl                 <= raw_min_fnl_nxt;
  ptnl_w_point                <= ptnl_w_point_nxt;
  
  target_pixel_que            <= target_pixel_que_nxt;
  raw_max_fnl_que             <= raw_max_fnl_que_nxt;
  raw_min_fnl_que             <= raw_min_fnl_que_nxt;
  ptnl_w_point_que            <= ptnl_w_point_que_nxt;
  step_1_color_4_que          <= step_1_color_4_que_nxt;
  
  raw_fnl_sta_sel_num         <= raw_fnl_sta_sel_num_nxt;
  raw_fnl_sta_sel_num_que     <= raw_fnl_sta_sel_num_que_nxt;
  
//--------------------------------------------------------------------------------------step 1 pixel result
  step_1_low_nlm_sel_num      <= step_1_low_nlm_sel_num_nxt;
  step_1_sft_sel_num          <= step_1_sft_sel_num_nxt;
  df_rto_0_sel_num            <= df_rto_0_sel_num_nxt;
  df_rto_0_sel_num_que        <= df_rto_0_sel_num_que_nxt;
  df_rto_1_sel_num            <= df_rto_1_sel_num_nxt;
  df_rto_1_sel_num_que        <= df_rto_1_sel_num_que_nxt;
  step_1_high_nlm_sel_num     <= step_1_high_nlm_sel_num_nxt;
  step_1_high_nlm_sel_num_que <= step_1_high_nlm_sel_num_que_nxt;
  step_1_low_nlm_sel_num_que  <= step_1_low_nlm_sel_num_que_nxt;
  step_1_sft_sel_num_que      <= step_1_sft_sel_num_que_nxt;
  max_min_recip_sel_num       <= max_min_recip_sel_num_nxt;
  step_1_high_nlm_sel_num     <= step_1_high_nlm_sel_num_nxt;
  nlm_rto_sgn                 <= nlm_rto_sgn_nxt;
  df_step_1_score             <= df_step_1_score_nxt;
  df_step_1_score_que         <= df_step_1_score_que_nxt;
  
//--------------------------------------------------------------------------------------nlm 
  nlm_sqrt_recip              <= nlm_sqrt_recip_nxt;
  nlm_sqrt_recip_que          <= nlm_sqrt_recip_que_nxt;
  
//--------------------------------------------------------------------------------------step 2 get neighbor score 
  step_2_color_1_que          <= step_2_color_1_que_nxt;
  step_2_color_2_que          <= step_2_color_2_que_nxt;
  step_2_color_3_que          <= step_2_color_3_que_nxt;
  step_2_color_total_sum_0    <= step_2_color_total_sum_0_nxt;
  step_2_color_total_sum_1    <= step_2_color_total_sum_1_nxt;
  step_2_color_total_sum_2    <= step_2_color_total_sum_2_nxt;
  step_2_color_total_sum      <= step_2_color_total_sum_nxt;
  
//--------------------------------------------------------------------------------------step 2 get confidence score 
  df_step_2_score_inv         <= df_step_2_score_inv_nxt;
  df_all_step_score           <= df_all_step_score_nxt;
  raw_fnl_sel_num             <= raw_fnl_sel_num_nxt;
  raw_fnl_sel_num_que         <= raw_fnl_sel_num_que_nxt;
  df_all_step_score_inv       <= df_all_step_score_inv_nxt;
  repl_pixel                  <= repl_pixel_nxt;
  
//--------------------------------------------------------------------------------------output  
  o_data                      <= o_data_nxt;
  o_vstr                      <= o_vstr_nxt;
  o_hstr                      <= o_hstr_nxt;
  o_href                      <= o_href_nxt;
  o_hend                      <= o_hend_nxt;
  o_vend                      <= o_vend_nxt;
  o_wdpc_cnt                  <= o_wdpc_cnt_nxt;
  o_bdpc_cnt                  <= o_bdpc_cnt_nxt;
  o_static_num_cnt            <= o_static_num_cnt_nxt;
  video_que                   <= video_que_nxt;
  
end 
end 

always@(posedge dpc_clk or negedge dpc_rst_n) begin 
if(!dpc_rst_n) begin
  for(int_index=0;int_index<STAGE_2_NBR_4;int_index=int_index+1) begin : rst_0_gen 
//--------------------------------------------------------------------------------------step 2 get neighbor score 
  step_2_color_1_sum_0_sgn[int_index]         <= 0;
  step_2_color_1_sum_1_sgn[int_index]         <= 0; 
  step_2_color_1_sum_sgn[int_index]           <= 0;  
  step_2_color_1_sel_num_0_sgn[int_index]     <= 0;  
  step_2_color_1_sel_num_1_sgn[int_index]     <= 0;  
  step_2_color_1_score_stage_0_sgn[int_index] <= 0; 
  step_2_color_1_score_stage_1_sgn[int_index] <= 0; 
  step_2_color_1_max_sgn[int_index]           <= 0; 
  step_2_color_1_min_sgn[int_index]           <= 0; 
  
end
end 
else begin 
  for(int_index=0;int_index<STAGE_2_NBR_4;int_index=int_index+1) begin : rst_1_gen
//--------------------------------------------------------------------------------------step 2 get neighbor score 
  step_2_color_1_sum_0_sgn[int_index]         <= step_2_color_1_sum_0_sgn_nxt[int_index];
  step_2_color_1_sum_1_sgn[int_index]         <= step_2_color_1_sum_1_sgn_nxt[int_index];
  step_2_color_1_sum_sgn[int_index]           <= step_2_color_1_sum_sgn_nxt[int_index];  
  step_2_color_1_sel_num_0_sgn[int_index]     <= step_2_color_1_sel_num_0_sgn_nxt[int_index];  
  step_2_color_1_sel_num_1_sgn[int_index]     <= step_2_color_1_sel_num_1_sgn_nxt[int_index];  
  step_2_color_1_score_stage_0_sgn[int_index] <= step_2_color_1_score_stage_0_sgn_nxt[int_index]; 
  step_2_color_1_score_stage_1_sgn[int_index] <= step_2_color_1_score_stage_1_sgn_nxt[int_index]; 
  step_2_color_1_max_sgn[int_index]           <= step_2_color_1_max_sgn_nxt[int_index]; 
  step_2_color_1_min_sgn[int_index]           <= step_2_color_1_min_sgn_nxt[int_index]; 
  end
end 
end

always@(posedge dpc_clk or negedge dpc_rst_n) begin 
if(!dpc_rst_n) begin
  for(int_index=0;int_index<STAGE_2_NBR_2;int_index=int_index+1) begin : rst_2_gen 
//--------------------------------------------------------------------------------------step 2 get neighbor score 
  step_2_color_2_sum_0_sgn[int_index]         <= 0;
  step_2_color_3_sum_0_sgn[int_index]         <= 0; 
  step_2_color_2_sum_1_sgn[int_index]         <= 0;
  step_2_color_3_sum_1_sgn[int_index]         <= 0; 
  step_2_color_2_sum_sgn[int_index]           <= 0;  
  step_2_color_3_sum_sgn[int_index]           <= 0; 
  step_2_color_2_sel_num_0_sgn[int_index]     <= 0;  
  step_2_color_3_sel_num_0_sgn[int_index]     <= 0; 
  step_2_color_2_sel_num_1_sgn[int_index]     <= 0;  
  step_2_color_3_sel_num_1_sgn[int_index]     <= 0; 
  step_2_color_2_score_stage_0_sgn[int_index] <= 0; 
  step_2_color_3_score_stage_0_sgn[int_index] <= 0; 
  step_2_color_2_score_stage_1_sgn[int_index] <= 0; 
  step_2_color_3_score_stage_1_sgn[int_index] <= 0; 
  step_2_color_2_max_sgn[int_index]           <= 0; 
  step_2_color_3_max_sgn[int_index]           <= 0; 
  step_2_color_2_min_sgn[int_index]           <= 0; 
  step_2_color_3_min_sgn[int_index]           <= 0;
  
end
end 
else begin 
  for(int_index=0;int_index<STAGE_2_NBR_2;int_index=int_index+1) begin : rst_3_gen
//--------------------------------------------------------------------------------------step 2 get neighbor score 
  step_2_color_2_sum_0_sgn[int_index]         <= step_2_color_2_sum_0_sgn_nxt[int_index];  
  step_2_color_3_sum_0_sgn[int_index]         <= step_2_color_3_sum_0_sgn_nxt[int_index];
  step_2_color_2_sum_1_sgn[int_index]         <= step_2_color_2_sum_1_sgn_nxt[int_index];  
  step_2_color_3_sum_1_sgn[int_index]         <= step_2_color_3_sum_1_sgn_nxt[int_index];
  step_2_color_2_sum_sgn[int_index]           <= step_2_color_2_sum_sgn_nxt[int_index];  
  step_2_color_3_sum_sgn[int_index]           <= step_2_color_3_sum_sgn_nxt[int_index];  
  step_2_color_2_sel_num_0_sgn[int_index]     <= step_2_color_2_sel_num_0_sgn_nxt[int_index];  
  step_2_color_3_sel_num_0_sgn[int_index]     <= step_2_color_3_sel_num_0_sgn_nxt[int_index]; 
  step_2_color_2_sel_num_1_sgn[int_index]     <= step_2_color_2_sel_num_1_sgn_nxt[int_index];  
  step_2_color_3_sel_num_1_sgn[int_index]     <= step_2_color_3_sel_num_1_sgn_nxt[int_index];  
  step_2_color_2_score_stage_0_sgn[int_index] <= step_2_color_2_score_stage_0_sgn_nxt[int_index]; 
  step_2_color_3_score_stage_0_sgn[int_index] <= step_2_color_3_score_stage_0_sgn_nxt[int_index]; 
  step_2_color_2_score_stage_1_sgn[int_index] <= step_2_color_2_score_stage_1_sgn_nxt[int_index]; 
  step_2_color_3_score_stage_1_sgn[int_index] <= step_2_color_3_score_stage_1_sgn_nxt[int_index]; 
  step_2_color_2_max_sgn[int_index]           <= step_2_color_2_max_sgn_nxt[int_index]; 
  step_2_color_3_max_sgn[int_index]           <= step_2_color_3_max_sgn_nxt[int_index]; 
  step_2_color_2_min_sgn[int_index]           <= step_2_color_2_min_sgn_nxt[int_index]; 
  step_2_color_3_min_sgn[int_index]           <= step_2_color_3_min_sgn_nxt[int_index]; 
  
  end
end 
end

always@(posedge dpc_clk or negedge dpc_rst_n) begin 
if(!dpc_rst_n) begin
  for(int_index=0;int_index<RAW_CIW;int_index=int_index+1) begin : rst_4_gen
    bit_result_max[int_index]                  <= 0;
    bit_result_min[int_index]                  <= 0;
    data_bit      [int_index]                  <= 0;
  end 
end 
else begin 
  for(int_index=0;int_index<RAW_CIW;int_index=int_index+1) begin : rst_5_gen
    bit_result_max[int_index]                  <= bit_result_max_nxt[int_index];
    bit_result_min[int_index]                  <= bit_result_min_nxt[int_index];
    data_bit      [int_index]                  <= data_bit_nxt      [int_index];
  end 
end 
end 




always@(posedge dpc_clk or negedge dpc_rst_n) begin 
if(!dpc_rst_n) begin
  for(int_index=0;int_index<STAGE_2_NBR_4*(STAGE_2_NBR_4-1);int_index=int_index+1) begin : rst_6_gen
    
    step_2_color_1_clip_sgn[int_index]     <= 0;
    
  end 
end 
else begin 
  for(int_index=0;int_index<STAGE_2_NBR_4*(STAGE_2_NBR_4-1);int_index=int_index+1) begin : rst_7_gen

    step_2_color_1_clip_sgn[int_index]     <= step_2_color_1_clip_sgn_nxt[int_index];
  end 
end 
end  

always@(posedge dpc_clk or negedge dpc_rst_n) begin 
if(!dpc_rst_n) begin
  for(int_index=0;int_index<(STAGE_2_NBR_2_SUB_6-1)*STAGE_2_NBR_2;int_index=int_index+1) begin : rst_8_gen
    
    step_2_color_2_clip_sgn[int_index]     <= 0;
    step_2_color_3_clip_sgn[int_index]     <= 0;
    
  end 
end 
else begin 
  for(int_index=0;int_index<(STAGE_2_NBR_2_SUB_6-1)*STAGE_2_NBR_2;int_index=int_index+1) begin : rst_9_gen

    step_2_color_2_clip_sgn[int_index]     <= step_2_color_2_clip_sgn_nxt[int_index];
    step_2_color_3_clip_sgn[int_index]     <= step_2_color_3_clip_sgn_nxt[int_index];
  end 
end 
end  


always@(posedge dpc_clk or negedge dpc_rst_n) begin 
if(!dpc_rst_n) begin 
for(int_index=0;int_index<COLOR_ARRAY_NUM_2;int_index=int_index+1) begin : rst_10_gen
  nlm_clip      [int_index] <= 0;
  total_nlm     [int_index] <= 0;
  total_nlm_clip[int_index] <= 0; 
end
end
else begin 
  for(int_index=0;int_index<COLOR_ARRAY_NUM_2;int_index=int_index+1) begin : rst_11_gen
  nlm_clip      [int_index] <= nlm_clip_nxt[int_index]; 
  total_nlm     [int_index] <= total_nlm_nxt[int_index];
  total_nlm_clip[int_index] <= total_nlm_clip_nxt[int_index]; 
  end 
end 
end 

generate 
  if((MODE_SEL == 1) | (MODE_SEL == 3)) begin 
always@(posedge dpc_clk or negedge dpc_rst_n) begin 
if(!dpc_rst_n) begin 
  coord_sft <= 0;
end
else begin 
  coord_sft <= coord_sft_nxt;
end 
end 
end 
endgenerate

//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//
ip_sqrt_pw#( //set
    .IWID         ( IP_SQRT_IWID ),
    .OEXD         ( IP_SQRT_OEXD ),
    .ORPCS        ( IP_SQRT_ORPCS ),
    .OPSEL        ( "SQRT_RECIP" ) // Operation select: "SQRT", "SQRT_RECIP", "ALL"
)u_ip_sqrt_recip(
    .o_sqrt       (             ),
    .o_sqrt_recip ( nlm_sqrt_recip_nxt[(IP_SQRT_ORPCS+1)-1:0] ),        //precision : 0.10
    .i_base       ( total_nlm_clip[0]       ),      //precision : 14.4
    .clk          ( dpc_clk          ),
    .rst_n        ( dpc_rst_n        )
);

generate 
  for(index=1;index<COLOR_ARRAY_NUM_2;index=index+1) begin : gen_nlm_sqrt
  
ip_sqrt_pw#(
    .IWID         ( IP_SQRT_IWID ),
    .OEXD         ( IP_SQRT_OEXD ),
    .ORPCS        ( IP_SQRT_ORPCS ),
    .OPSEL        ( "ALL" ) // Operation select: "SQRT", "SQRT_RECIP", "ALL"
)u_ip_sqrt_all(
    .o_sqrt       ( nlm_sqrt[((SQRT_CIW/2)+IP_SQRT_OEXD)*index+:((SQRT_CIW/2)+IP_SQRT_OEXD)]       ),        //precision : 7.5
    .o_sqrt_recip ( nlm_sqrt_recip_nxt[(IP_SQRT_ORPCS+1)*index+:(IP_SQRT_ORPCS+1)] ),    //precision : 0.10
    .i_base       ( total_nlm_clip[index]       ),  //precision : 14.4
    .clk          ( dpc_clk          ),
    .rst_n        ( dpc_rst_n        )
);

  end 
endgenerate


endmodule 
