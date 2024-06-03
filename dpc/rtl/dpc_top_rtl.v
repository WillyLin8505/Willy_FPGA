 // +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2023
//
// File Name:           
// Author:              Willy Lin
// Version:             1.0
// Date:                2023
// Last Modified On:    
// Last Modified By:    
// limitation :

// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------
module dpc_top
 #(
      parameter  PX_RATE            = 2,
      
//----------------------------------------------------------------insert dpc 
      parameter  INS_CIW            = 20,
      
//----------------------------------------------------------------dpc para
      parameter  ALG_LVL            = "LVL_0", // "LVL_0", "LVL_1", "LVL_2"
      parameter  ALG_MODE           = "SDPC",      // "SDPC": static DPC only, "DDPC": dynamic DPC only, "ALL": static + dynamic DPC
      parameter  IMG_HSZ            = 1928,
      parameter  IMG_VSZ            = 1080,
      
      parameter  RAW_CIIW           = INS_CIW/PX_RATE,
      parameter  RAW_CIPW           = 0,
      parameter  R_LOW_NLM_CIIW     = 3,
      parameter  R_LOW_NLM_CIPW     = 2,
      parameter  R_RTO_THRES_CIIW   = 3,
      parameter  R_RTO_THRES_CIPW   = 2,
      parameter  R_CNT_THRES_CIIW   = 4,
      parameter  R_CNT_THRES_CIPW   = 2,
      parameter  BLC_TGT_CIIW       = 8, //raw_cip(10):s.11.0
      parameter  BLC_TGT_CIPW       = 0 ,//raw_cip(12):s.13.0
      parameter  DRKC_CIIW          = 12,//raw_cip(10):s.11.0
      parameter  DRKC_CIPW          = 0 ,//raw_cip(12):s.13.0    
      parameter  CGCF_CIIW          = 0 ,//raw_cip(10):0.12
      parameter  CGCF_CIPW          = (ALG_LVL == "LVL_0") ? 12 : 8, //raw_cip(12):1.12
      parameter  PARM1_CIIW         = 0 ,//raw_cip(10):0.10
      parameter  PARM1_CIPW         = 10,//raw_cip(12):2.10  
      parameter  PARM2_CIIW         = 0 ,//raw_cip(10):0.4
      parameter  PARM2_CIPW         = 4 ,//raw_cip(12):2.4  

      parameter  MAX_DPC_NUM        = 255,
      parameter  MAX_COORD_NUM      = 20,
      
//----------------------------------------------------------------cu para
      parameter  CU_GAIN_CIIW       = 3,
      parameter  CU_GAIN_CIPW       = 4,

//----------------------------------------------------------------line buffer para
      parameter  ODATA_FREQ         = 0,
      parameter  BUF_PIXEL_DLY      = 0,
      parameter  BUF_LINE_DLY       = 0,
      parameter  MEM_TYPE           = "1PSRAM",
      parameter  MEM_NAME           = "M31HDSP100PL040P_488X1X80CM4",        // sram name 
      parameter  SRAM_NUM           = 2,                                     // number of sram 

//---------------------------------------------dpc precision    //local parameter //[don't modify] 
      parameter  RAW_CIW            = RAW_CIIW + RAW_CIPW,
      parameter  MAX_DPC_NUM_WTH    = $clog2(MAX_DPC_NUM),
      parameter  MAX_COORD_NUM_WTH  = $clog2(MAX_COORD_NUM),
      parameter  IMG_HSZ_WTH        = $clog2(IMG_HSZ),
      parameter  IMG_VSZ_WTH        = $clog2(IMG_VSZ),
      parameter  R_LOW_NLM_CIW      = R_LOW_NLM_CIIW + R_LOW_NLM_CIPW,
      parameter  R_RTO_THRES_CIW    = R_RTO_THRES_CIIW + R_RTO_THRES_CIPW,
      parameter  R_CNT_THRES_CIW    = R_CNT_THRES_CIIW + R_CNT_THRES_CIPW,

//---------------------------------------------cu parameter sum //local parameter //[don't modify] 
      parameter  CU_GAIN_CIW        = CU_GAIN_CIIW + CU_GAIN_CIPW ,
      parameter  BLC_TGT_CIW        = BLC_TGT_CIIW + BLC_TGT_CIPW,
      parameter  DRKC_CIW           = DRKC_CIIW    + DRKC_CIPW,
      parameter  CGCF_CIW           = CGCF_CIIW    + CGCF_CIPW,
      parameter  PARM1_CIW          = PARM1_CIIW   + PARM1_CIPW,
      parameter  PARM2_CIW          = PARM2_CIIW   + PARM2_CIPW

)
(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
//----------------------------------------------------------------------------------------dpc
output reg [PX_RATE*RAW_CIW-1:0]                  o_dpc_data,
output reg                                        o_dpc_href,
output reg                                        o_dpc_hstr,
output reg                                        o_dpc_hend,
output reg                                        o_dpc_bidx,
output reg [MAX_DPC_NUM_WTH-1:0]                  o_dpc_wdpc_cnt,        //white point counter , contain static and dynamic 
output reg [MAX_DPC_NUM_WTH-1:0]                  o_dpc_bdpc_cnt,
output reg [MAX_COORD_NUM_WTH-1:0]                o_static_num_cnt,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
//---------------------------------------------------------------------------------------------dpc 
input  [IMG_VSZ_WTH-1:0]              i_dpc_ver_addr,
input                                 i_dpc_bidx,

input  [R_LOW_NLM_CIW-1:0]            r_step1_w_low_nlm,     //precision : 3.2 //range : 0~7.75    
input  [2:0]                          r_step1_w_transit_rng, //range : {1,2,4}
input  [R_LOW_NLM_CIW-1:0]            r_step1_b_low_nlm,     //precision : 3.2 //range : 0~7.75
input  [2:0]                          r_step1_b_transit_rng, //range : {1,2,4}
           
input  [R_RTO_THRES_CIW-1:0]          r_step2_w_rto_thres,   //precision : 3.2 //range : 0~7.75
input  [2:0]                          r_step2_w_buf_rng,     //range : {1,2,4}
input  [R_RTO_THRES_CIW-1:0]          r_step2_b_rto_thres,   //precision : 3.2 //range : 0~7.75
input  [2:0]                          r_step2_b_buf_rng,     //range : {1,2,4}
         
input  [R_CNT_THRES_CIW-1:0]          r_step2_w_cnt_thres,   //precision : 4.2 //range : 0~8
input  [2:0]                          r_step2_w_cnt_buf_rng, //range : {1,2,4}
input  [R_CNT_THRES_CIW-1:0]          r_step2_b_cnt_thres,   //precision : 4.2 //range : 0~8
input  [2:0]                          r_step2_b_cnt_buf_rng, //range : {1,2,4}

input                                 r_dpc_en,              //0:not replace 1: replace if dpc          
input                                 r_dpc_debug_en,        //0:detect and replace , 1:detect and use r_repl_col to enhance color 
input  [1:0]                          r_dpc_mode_sel,        //0:close all function, 1:static mode 2: dynamic mode 3: mix mode 
input  [RAW_CIIW-1:0]                 r_dpc_repl_col,        // enhance dpc in debug mode , replace 8 bit of msb      
         
input  [MAX_COORD_NUM*24-1:0]         r_dpc_static_coord,        
input                                 r_dpc_coord_mirror, 
input  [IMG_HSZ_WTH-1:0]              r_dpc_haddr_start,
   
//---------------------------------------------------------------------------------------------line buf
input                                 i_hend,
input                                 i_fstr,

//---------------------------------------------------------------------------------------------cu 
input  [CU_GAIN_CIW-1:0]              r_ssr_again,
input  [BLC_TGT_CIW-1:0]              r_ssr_blc_tgt,
input  [DRKC_CIW-1:0]                 r_ssr_drkc,
input  [CGCF_CIW-1:0]                 r_ssr_cgcf,
input  [PARM1_CIW-1:0]                r_ssr_ns_parm1,
input  [PARM2_CIW-1:0]                r_ssr_ns_parm2,

//---------------------------------------------------------------------------------------------insert dpc 
input  [INS_CIW-1:0]                  i_data,
input                                 i_hstr,
input                                 i_href,
input                                 r_ins_en,
input                                 r_ins_mode_sel,  //0 : pixel mode 1: dead column mode 
input  [RAW_CIIW-1:0]                 r_ins_clr_chg,
input  [8-1:0]                        r_ins_hstep,
input  [8-1:0]                        r_ins_vstep,

//---------------------------------------------------------------------------------------------clk
input                                 clk,
input                                 gated_clk,
input                                 rst_n
);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//
//----------------------------------------------------------------dpc para
localparam  GAIN_CIIW          = 4 ;//precision for dpc core 
localparam  GAIN_CIPW          = 0 ;//precision for dpc core 

localparam  SQRT_CIIW          = 14;
localparam  SQRT_CIPW          = 4;
localparam  SQRT_COIW          = 7;
localparam  SQRT_COPW          = 5;
localparam  SQRT_RECIP_COIW    = 0;
localparam  SQRT_RECIP_COPW    = 10; 

//---------------------------------------------total precision    //local parameter //[don't modify]    
localparam  DPC_COIW           = RAW_CIIW; 
localparam  DPC_COPW           = RAW_CIPW; 
localparam  SHOT_CIIW          = GAIN_CIIW-1; 
localparam  SHOT_CIPW          = CGCF_CIPW; 
localparam  ROUT_CIIW          = (GAIN_CIIW-1+PARM1_CIIW)*2;
localparam  ROUT_CIPW          = CGCF_CIPW; 
      
localparam  BLC_CIW            = BLC_TGT_CIIW + BLC_TGT_CIPW;
localparam  ROUT_CIW           = ROUT_CIIW + ROUT_CIPW;
localparam  DPC_COW            = DPC_COIW + DPC_COPW;
localparam  SQRT_CIW           = SQRT_CIIW + SQRT_CIPW;
localparam  SQRT_COW           = SQRT_COIW + SQRT_COPW;
localparam  SQRT_RECIP_COW     = SQRT_RECIP_COIW + SQRT_RECIP_COPW;
localparam  SHOT_CIW           = SHOT_CIIW + SHOT_CIPW;

//----------------------------------------------------------------cu para

localparam  TSK0_START_PC      = 0;
localparam  TSK0_END_PC        = 16;

localparam  ALU_SZ             = 28;  
localparam  EXD_SZ             = 2;

localparam  NUM0_SZ            = ALU_SZ + EXD_SZ - 1;
localparam  NUM1_SZ            = ALU_SZ;

//---------------------------------------------cu parameter sum //local parameter //[don't modify] 
localparam  GAIN_CIW           = GAIN_CIIW    + GAIN_CIPW ;
      
//----------------------------------------------------------------line buffer para
localparam  DBUF_DW            = INS_CIW;
localparam  KRNV_SZ            = (ALG_MODE == "SDPC") ? 5 : 7;
localparam  KRNH_SZ            = (ALG_MODE == "SDPC") ? 5 : 7;
localparam  TOP_PAD            = (ALG_MODE == "SDPC") ? 2 : 3;
localparam  BTM_PAD            = (ALG_MODE == "SDPC") ? 2 : 3;
localparam  FR_PAD             = (ALG_MODE == "SDPC") ? 1 : 2;
localparam  BK_PAD             = (ALG_MODE == "SDPC") ? 1 : 2;
localparam  PAD_MODE           = 1;
localparam  ODATA_RNG          = (ALG_MODE == "SDPC") ? 3 : 5;
localparam  SRAM_DEP           = IMG_HSZ/PX_RATE;
localparam  SRAM_DWTH          = ((KRNV_SZ-1)*2*DBUF_DW)/SRAM_NUM; //stack 2 data 

//----------------------------------------------------------------insert dpc 
localparam  PX_RATE_WTH        = $clog2(PX_RATE+1);                //

//================================================================================
//  signal declaration
//================================================================================
//---------------------------------------------------------------------------------------------dpc top 

wire       [RAW_CIW*PX_RATE*ODATA_RNG-1:0]                line_buf_line            [0:KRNV_SZ-1];
wire       [RAW_CIW*KRNV_SZ*KRNH_SZ-1:0]                  line_buf_com;
wire       [RAW_CIW*7*7-1:0]                              dpc_raw                  [0:PX_RATE-1];

wire       [PX_RATE*RAW_CIW-1:0]                          o_dpc_data_nxt;
wire                                                      o_dpc_href_nxt;
wire                                                      o_dpc_hend_nxt;
wire                                                      o_dpc_vend_nxt;
wire       [MAX_DPC_NUM_WTH-1:0]                          o_dpc_wdpc_cnt_nxt;        //white point counter , contain static and dynamic 
wire       [MAX_DPC_NUM_WTH-1:0]                          o_dpc_bdpc_cnt_nxt;
wire       [MAX_COORD_NUM_WTH-1:0]                        o_static_num_cnt_nxt;
wire       [PX_RATE-1:0]                                  dpc_bidx;
wire                                                      o_dpc_bidx_nxt;

//---------------------------------------------------------------------------------------------line buf
wire       [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0]                line_bf_data;
wire                                                      line_bf_dvld;
wire                                                      line_bf_vstr;
wire                                                      line_bf_hstr;
wire                                                      line_bf_hend;
wire                                                      line_bf_vend;

//----------------------------------------------------------------------------------------cu
reg                                                       cu_tsk_trg_i;        // Task trigger
wire                                                      cu_tsk_trg_i_nxt;    // Task trigger
wire       [BLC_TGT_CIW-1:0]                              blc_dc_dlt;
wire       [SHOT_CIW-1:0]                                 shot_nvar_bs;
wire       [ROUT_CIW-1:0]                                 rout_nvar_bs;
wire       [R_LOW_NLM_CIW+1-1:0]                          step1_w_high_nlm_cu;
wire       [R_LOW_NLM_CIW+1-1:0]                          step1_b_high_nlm_cu;
wire       [IMG_HSZ_WTH-1:0]                              haddr_mirr_cu;
wire       [R_RTO_THRES_CIW-1:0]                          step2_w_rto_thres_rng_cu;
wire       [R_RTO_THRES_CIW-1:0]                          step2_b_rto_thres_rng_cu;
wire       [R_RTO_THRES_CIW+2-1:0]                        step2_w_rto_thres_3_cu;
wire       [R_RTO_THRES_CIW+2-1:0]                        step2_b_rto_thres_3_cu;
wire       [R_RTO_THRES_CIW+3-1:0]                        step2_w_rto_thres_5_cu;
wire       [R_RTO_THRES_CIW+3-1:0]                        step2_b_rto_thres_5_cu;
wire       [PX_RATE_WTH-1:0]                              cnt_add_cu;

wire                                                      cu_tsk_end;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op1;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op2;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op6;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op7;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op8;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op9;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op10;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op11;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op12;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op13;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op14;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op15;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op16;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op17;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op18;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op19;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op20;
wire       [NUM0_SZ+NUM1_SZ-1:0]                          cu_top_op21;

//----------------------------------------------------------------------------------------insert dpc 
wire       [INS_CIW-1:0]                                  ins_data;
wire                                                      ins_hstr;
wire                                                      ins_dvld;
wire                                                      ins_hend;

//----------------------------------------------------------------------------------------dpc core
wire       [PX_RATE*RAW_CIW-1:0]                          ip_dpc_data;
wire       [PX_RATE-1:0]                                  ip_dpc_href;
wire       [PX_RATE-1:0]                                  ip_dpc_vstr;
wire       [PX_RATE-1:0]                                  ip_dpc_hstr;
wire       [PX_RATE-1:0]                                  ip_dpc_hend;
wire       [PX_RATE-1:0]                                  ip_dpc_vend;
wire       [PX_RATE*MAX_DPC_NUM_WTH-1:0]                  ip_dpc_wdpc_cnt;        //white point counter , contain static and dynamic 
wire       [PX_RATE*MAX_DPC_NUM_WTH-1:0]                  ip_dpc_bdpc_cnt;
wire       [PX_RATE*MAX_COORD_NUM-1:0]                    ip_static_num_cnt;

//----------------------------------------------------------------------------------------general
genvar                                                    index,index_2;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//-----------------------------------------------------------------------bypass data 
assign o_dpc_data_nxt       = r_dpc_en ? ip_dpc_data                              : i_data;
assign o_dpc_href_nxt       = r_dpc_en ? ip_dpc_href[0]                           : i_href;
assign o_dpc_hstr_nxt       = r_dpc_en ? ip_dpc_hstr[0]                           : i_hstr;
assign o_dpc_hend_nxt       = r_dpc_en ? ip_dpc_hend[0]                           : i_hend;
assign o_dpc_wdpc_cnt_nxt   = r_dpc_en ? ip_dpc_wdpc_cnt[MAX_DPC_NUM_WTH-1:0]     : {MAX_DPC_NUM_WTH{1'b0}};
assign o_dpc_bdpc_cnt_nxt   = r_dpc_en ? ip_dpc_bdpc_cnt[MAX_DPC_NUM_WTH-1:0]     : {MAX_DPC_NUM_WTH{1'b0}};
assign o_static_num_cnt_nxt = r_dpc_en ? ip_static_num_cnt[MAX_COORD_NUM_WTH-1:0] : {MAX_COORD_NUM_WTH{1'b0}};
assign o_dpc_bidx_nxt       = r_dpc_en ? dpc_bidx[0]                              : 1'b0;
//-----------------------------------------------------------------------line buffer 
 generate 
  for (index=0;index<KRNV_SZ;index=index+1) begin : line_buf_chnl_gen_0
    for (index_2=0;index_2<ODATA_RNG;index_2=index_2+1) begin : line_buf_chnl_gen_1
      assign line_buf_line[index][RAW_CIW*PX_RATE*index_2+:RAW_CIW*PX_RATE] = line_bf_data[(RAW_CIW*PX_RATE*KRNV_SZ)*index_2+RAW_CIW*PX_RATE*index+:RAW_CIW*PX_RATE];  
    end 
  end 
 endgenerate 

 generate 
  for (index=0;index<KRNV_SZ;index=index+1) begin : line_buf_com_gen_0
      assign line_buf_com[KRNH_SZ*RAW_CIW*index+:KRNH_SZ*RAW_CIW] = line_buf_line[index][0+:KRNH_SZ*RAW_CIW];  
  end 
 endgenerate 
 

generate 
  
for (index=0;index<PX_RATE;index=index+1) begin : dpc_raw_gen
  if(ALG_MODE == "SDPC")begin 
    assign dpc_raw[index] = {{RAW_CIW{1'b0}},{RAW_CIW*(KRNV_SZ){1'b0}}                          ,{RAW_CIW{1'b0}},
                             {RAW_CIW{1'b0}},line_buf_com[RAW_CIW*KRNV_SZ*4+:RAW_CIW*KRNV_SZ],{RAW_CIW{1'b0}},
                             {RAW_CIW{1'b0}},line_buf_com[RAW_CIW*KRNV_SZ*3+:RAW_CIW*KRNV_SZ],{RAW_CIW{1'b0}},
                             {RAW_CIW{1'b0}},line_buf_com[RAW_CIW*KRNV_SZ*2+:RAW_CIW*KRNV_SZ],{RAW_CIW{1'b0}},
                             {RAW_CIW{1'b0}},line_buf_com[RAW_CIW*KRNV_SZ*1+:RAW_CIW*KRNV_SZ],{RAW_CIW{1'b0}},
                             {RAW_CIW{1'b0}},line_buf_com[RAW_CIW*KRNV_SZ*0+:RAW_CIW*KRNV_SZ],{RAW_CIW{1'b0}},
                             {RAW_CIW{1'b0}},{RAW_CIW*(KRNV_SZ){1'b0}}                          ,{RAW_CIW{1'b0}}};
               
    end 
  else begin 
  
    assign dpc_raw[index] = line_buf_com[index];
    
  end 
  end 
endgenerate 
    
  
//-----------------------------------------------------------------------cu 
assign cu_tsk_trg_i_nxt         = i_fstr;
assign blc_dc_dlt               = cu_top_op1[BLC_TGT_CIW-1:0];
assign shot_nvar_bs             = cu_top_op2[SHOT_CIW-1:0];
assign rout_nvar_bs             = cu_top_op6[ROUT_CIW-1:0];
assign step1_w_high_nlm_cu      = cu_top_op7[R_LOW_NLM_CIW+1-1:0];
assign step1_b_high_nlm_cu      = cu_top_op8[R_LOW_NLM_CIW+1-1:0];
assign haddr_mirr_cu            = cu_top_op9[IMG_HSZ_WTH-1:0];
assign step2_w_rto_thres_rng_cu = cu_top_op10[R_RTO_THRES_CIW-1:0];
assign step2_b_rto_thres_rng_cu = cu_top_op11[R_RTO_THRES_CIW-1:0];
assign step2_w_rto_thres_3_cu   = cu_top_op12[R_RTO_THRES_CIW+2-1:0];
assign step2_b_rto_thres_3_cu   = cu_top_op13[R_RTO_THRES_CIW+2-1:0];
assign step2_w_rto_thres_5_cu   = cu_top_op14[R_RTO_THRES_CIW+3-1:0];
assign step2_b_rto_thres_5_cu   = cu_top_op15[R_RTO_THRES_CIW+3-1:0];
assign cnt_add_cu               = cu_top_op16[PX_RATE_WTH-1:0];

//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//

dpc_insert#(
    .RAW_CIIW        ( RAW_CIIW ),
    .PX_RATE         ( PX_RATE  ),
    
    .IMG_VSZ_WTH     ( IMG_VSZ_WTH)
    
)u_dpc_insert(
    .o_data         ( ins_data     ),
    .o_hstr         ( ins_hstr     ),
    .o_dvld         ( ins_dvld     ),
    .o_hend         ( ins_hend     ),
    
    .i_raw_data     ( i_data ),
    .i_data_vld     ( i_href ),
    .i_hstr         ( i_hstr     ),
    .i_hend         ( i_hend ),
    
    .r_ins_en       ( r_ins_en),
    .r_mode_sel     ( r_ins_mode_sel ),
    .r_clr_chg      ( r_ins_clr_chg ),
    .r_hstep        ( r_ins_hstep    ),
    .r_vstep        ( r_ins_vstep    ),
    
    .i_cnt_add_cu   ( cnt_add_cu),
     
    .clk            (gated_clk),
    .rst_n          (rst_n)
);

line_buf_top
#( 
      .PIXEL_DLY   (BUF_PIXEL_DLY),
      .LINE_DLY    (BUF_LINE_DLY),
      
      .DBUF_DW     (DBUF_DW )  ,
      .KRNV_SZ     (KRNV_SZ)  ,
      .KRNH_SZ     (KRNH_SZ) ,
      .ODATA_FREQ  (ODATA_FREQ),
      .TOP_PAD     (TOP_PAD),
      .BTM_PAD     (BTM_PAD),
      .FR_PAD      (FR_PAD),
      .BK_PAD      (BK_PAD),
      .PAD_MODE    (PAD_MODE),
      .ODATA_RNG   (ODATA_RNG),
      
      .IMG_HSZ     (IMG_HSZ),
      .MEM_TYPE    (MEM_TYPE),
      .MEM_NAME    (MEM_NAME),
      .SRAM_NUM    (SRAM_NUM),
      .SRAM_DEP    (SRAM_DEP),
      .SRAM_DWTH   (SRAM_DWTH)
      

)

line_buf_top
(
      
      .o_dvld      (line_bf_dvld),
      .o_vstr      (line_bf_vstr),
      .o_hstr      (line_bf_hstr),
      .o_hend      (line_bf_hend),
      .o_vend      (line_bf_vend),
      .o_data      (line_bf_data),

      .i_data      (ins_data), 
      .i_hstr      (ins_hstr),
      .i_href      (ins_dvld),
      .i_hend      (ins_hend),
      .i_vstr      (1'b0),

      .i_wb        (20'd0),
      .i_wb_vld    (1'd0), 

      .clk         (gated_clk),
      .rst_n       (rst_n)
);


generate 
  for (index=0;index<PX_RATE;index=index+1) begin : dpc_core_gen
dpc
#(
    .RAW_CIIW                   ( RAW_CIIW ),
    .ALG_LVL                    ( ALG_LVL),
    .BUF_PART                   ( index),
    .ALG_MODE                   ( ALG_MODE ),
    .IMG_HSZ                    ( IMG_HSZ),
    .IMG_VSZ                    ( IMG_VSZ),
    .MAX_DPC_NUM                ( MAX_DPC_NUM)

)
u_dpc(
    .o_data                     ( ip_dpc_data[RAW_CIW*index+:RAW_CIW]                ),
    .o_href                     ( ip_dpc_href[index+:1]                ),
//    .o_vstr                     ( ip_dpc_vstr[index+:1]                ),
    .o_hstr                     ( ip_dpc_hstr[index+:1]                ),
    .o_hend                     ( ip_dpc_hend[index+:1]                ),
    .o_vend                     ( ip_dpc_vend[index+:1]                ),
    .o_wdpc_cnt                 ( ip_dpc_wdpc_cnt[MAX_DPC_NUM_WTH*index+:MAX_DPC_NUM_WTH]            ),
    .o_bdpc_cnt                 ( ip_dpc_bdpc_cnt[MAX_DPC_NUM_WTH*index+:MAX_DPC_NUM_WTH]            ),
    .o_static_num_cnt           ( ip_static_num_cnt[MAX_COORD_NUM_WTH*index+:MAX_COORD_NUM_WTH]          ),
    .o_dpc_bidx                 ( dpc_bidx[index+:1]              ),
    
    .i_raw_data                 ( dpc_raw[index]              ),
    .i_blc_dc_dlt_cu            ( blc_dc_dlt                  ),
    .i_shot_nvar_bs_cu          ( shot_nvar_bs                ),
    .i_rout_nvar_bs_cu          ( rout_nvar_bs                ),
    .i_hstr                     ( line_bf_hstr                ),
    .i_href                     ( line_bf_dvld                ),
    .i_hend                     ( line_bf_hend                ),
    .i_fstr                     ( i_fstr                ),
    .i_vend                     ( line_bf_vend                ),
    .i_dead_col                 ( 1'b0                        ),
    .i_ver_addr                 ( i_dpc_ver_addr              ),      
    .i_dpc_bidx                 ( i_dpc_bidx                  ),
    
    .i_step1_w_high_nlm_cu      ( step1_w_high_nlm_cu     ),
    .i_step1_b_high_nlm_cu      ( step1_b_high_nlm_cu     ),
    .i_haddr_mirr_cu            ( haddr_mirr_cu),
    .i_step2_w_rto_thres_rng_cu ( step2_w_rto_thres_rng_cu),
    .i_step2_b_rto_thres_rng_cu ( step2_b_rto_thres_rng_cu),
    .i_step2_w_rto_thres_3_cu   ( step2_w_rto_thres_3_cu),
    .i_step2_b_rto_thres_3_cu   ( step2_b_rto_thres_3_cu),
    .i_step2_w_rto_thres_5_cu   ( step2_w_rto_thres_5_cu),
    .i_step2_b_rto_thres_5_cu   ( step2_b_rto_thres_5_cu),
    
    .r_step1_w_low_nlm          ( r_step1_w_low_nlm     ),
    .r_step1_w_transit_rng      ( r_step1_w_transit_rng ),
    .r_step1_b_low_nlm          ( r_step1_b_low_nlm     ),
    .r_step1_b_transit_rng      ( r_step1_b_transit_rng ),
    .r_step2_w_rto_thres        ( r_step2_w_rto_thres   ),
    .r_step2_w_buf_rng          ( r_step2_w_buf_rng     ),
    .r_step2_b_rto_thres        ( r_step2_b_rto_thres   ),
    .r_step2_b_buf_rng          ( r_step2_b_buf_rng     ),
    .r_step2_w_cnt_thres        ( r_step2_w_cnt_thres   ),
    .r_step2_w_cnt_buf_rng      ( r_step2_w_cnt_buf_rng ),
    .r_step2_b_cnt_thres        ( r_step2_b_cnt_thres   ),
    .r_step2_b_cnt_buf_rng      ( r_step2_b_cnt_buf_rng ),
    
    .r_debug_en                 ( r_dpc_debug_en ),     //sta 
    .r_mode_sel                 ( r_dpc_mode_sel ),     //sta
    .r_repl_col                 ( r_dpc_repl_col),      //sta 
    .r_dpc_en                   ( r_dpc_en),            //sta 
    .r_static_coord             ( r_dpc_static_coord ), //sta
    .r_coord_mirror             ( r_dpc_coord_mirror ), //sta 
    .r_haddr_start              ( r_dpc_haddr_start ),  //sta 

    .dpc_clk                    ( gated_clk                   ),
    .dpc_rst_n                  ( rst_n                 )
);
end 
endgenerate 

scu_top#(
    .TSK0_START_PC         ( TSK0_START_PC ),
    .TSK0_END_PC           ( TSK0_END_PC),
    
    .ALU_SZ                ( ALU_SZ ),
    .EXD_SZ                ( EXD_SZ),
    .GAIN_CIIW             ( CU_GAIN_CIIW ),
    .GAIN_CIPW             ( CU_GAIN_CIPW ),
    .BLC_TGT_CIIW          ( BLC_TGT_CIIW ),
    .BLC_TGT_CIPW          ( BLC_TGT_CIPW ),
    .DRKC_CIIW             ( DRKC_CIIW ),
    .DRKC_CIPW             ( DRKC_CIPW ),
    .CGCF_CIIW             ( CGCF_CIIW ),
    .CGCF_CIPW             ( CGCF_CIPW ),
    .PARM1_CIIW            ( PARM1_CIIW ),
    .PARM1_CIPW            ( PARM1_CIPW ),
    .PARM2_CIIW            ( PARM2_CIIW ),
    .PARM2_CIPW            ( PARM2_CIPW ),
    
    .R_LOW_NLM_CIIW        ( R_LOW_NLM_CIIW),
    .R_LOW_NLM_CIPW        ( R_LOW_NLM_CIPW),
    .IMG_HSZ               ( IMG_HSZ),
    .R_RTO_THRES_CIIW      ( R_RTO_THRES_CIIW),
    .R_RTO_THRES_CIPW      ( R_RTO_THRES_CIPW),
    
    .PX_RATE_WTH           ( PX_RATE_WTH)
    
)u_scu_top(
    .o_cu_tsk_end          ( cu_tsk_end   ),
    .o_cu_top_op0          (              ),     //gain 
    .o_cu_top_op1          ( cu_top_op1   ),     //ssr_blc_dc_dlt
    .o_cu_top_op2          ( cu_top_op2 ),       //ssr_shot_nvar_bs //cfcg_gain 
    .o_cu_top_op3          (         ),
    .o_cu_top_op4          (         ),
    .o_cu_top_op5          (         ),
    .o_cu_top_op6          ( cu_top_op6 ),       //ssr_rout_nvar_bs
    .o_cu_top_op7          ( cu_top_op7 ),       //i_step1_w_high_nlm_cu
    .o_cu_top_op8          ( cu_top_op8 ),       //i_step1_b_high_nlm_cu  
    .o_cu_top_op9          ( cu_top_op9),
    .o_cu_top_op10         ( cu_top_op10),
    .o_cu_top_op11         ( cu_top_op11),
    .o_cu_top_op12         ( cu_top_op12),
    .o_cu_top_op13         ( cu_top_op13),
    .o_cu_top_op14         ( cu_top_op14),
    .o_cu_top_op15         ( cu_top_op15),
    .o_cu_top_op16         ( cu_top_op16),       //cnt_add_cu
 
    .i_cu_tsk_trg_i        ( cu_tsk_trg_i  ),

    .r_ssr_again           ( r_ssr_again    ),
    .r_ssr_blc_tgt         ( r_ssr_blc_tgt  ),
    .r_ssr_drkc            ( r_ssr_drkc     ),
    .r_ssr_cgcf            ( r_ssr_cgcf     ),
    .r_ssr_ns_parm1        ( r_ssr_ns_parm1 ),
    .r_ssr_ns_parm2        ( r_ssr_ns_parm2 ),

    .r_step1_w_low_nlm     ( r_step1_w_low_nlm     ),
    .r_step1_w_transit_rng ( r_step1_w_transit_rng ),
    .r_step1_b_low_nlm     ( r_step1_b_low_nlm     ),
    .r_step1_b_transit_rng ( r_step1_b_transit_rng ),
    .r_step2_w_rto_thres   ( r_step2_w_rto_thres ),
    .r_step2_w_buf_rng     ( r_step2_w_buf_rng ),
    .r_step2_b_rto_thres   ( r_step2_b_rto_thres),
    .r_step2_b_buf_rng     ( r_step2_b_buf_rng ),
    .r_haddr_start         ( r_dpc_haddr_start),
    
    .r_hstep               ( r_ins_hstep    ),
        
    .clk                   ( gated_clk           ),
    .rst_n                 ( rst_n         )
);

//----------------------------------------------//
// sequencial logic                             //
//----------------------------------------------//
always@(posedge gated_clk or negedge rst_n) begin 
if(!rst_n) begin 
  cu_tsk_trg_i <= 0;
end 
else begin 
  cu_tsk_trg_i <= cu_tsk_trg_i_nxt;
end 
end 

always@(posedge clk or negedge rst_n) begin 
if(!rst_n) begin 
  o_dpc_data       <=0;
  o_dpc_href       <=0;
  o_dpc_hstr       <=0;
  o_dpc_hend       <=0;
  o_dpc_bidx       <=0;
  o_dpc_wdpc_cnt   <=0;
  o_dpc_bdpc_cnt   <=0;
  o_static_num_cnt <=0;
  
end 
else begin 
  o_dpc_data       <=o_dpc_data_nxt      ;
  o_dpc_href       <=o_dpc_href_nxt      ;
  o_dpc_hstr       <=o_dpc_hstr_nxt      ;
  o_dpc_hend       <=o_dpc_hend_nxt      ;
  o_dpc_bidx       <=o_dpc_bidx_nxt      ;
  o_dpc_wdpc_cnt   <=o_dpc_wdpc_cnt_nxt  ;
  o_dpc_bdpc_cnt   <=o_dpc_bdpc_cnt_nxt  ;
  o_static_num_cnt <=o_static_num_cnt_nxt;
end 
end 


endmodule 

