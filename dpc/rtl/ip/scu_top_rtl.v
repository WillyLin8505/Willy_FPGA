// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2013
//
// File Name:           scu_top_rtl.v
// Author:              Humphrey Lin
//
// File Description:    Arithmetic Calculation Unit
// Abbreviations:
//
// Parameters:          TSK1_START_PC: Task1 Start program counter
//                      TSK1_END_PC:   Task1 End program counter
//                      PC_SZ: Program counter width, depended on all PC number
//                      CYC_SZ: max cycle counter width of math operator,
//                              depended on the width of Divend
// Clock Domain: ssr_clk
// -FHDR -----------------------------------------------------------------------

module  scu_top

#(

      parameter  TSK0_START_PC     = 0,
      parameter  TSK0_END_PC       = 0,

      parameter  ALU_SZ            = 16,   // ENGY_SZ+2
      parameter  EXD_SZ            = 8,

      parameter  PC_NUM            = TSK0_END_PC+1,
      parameter  PC_WID            = $clog2(PC_NUM),
      
      parameter  NUM0_SZ           = ALU_SZ+EXD_SZ-1,
      parameter  NUM1_SZ           = ALU_SZ,
      
      parameter  PX_RATE           = 2,
      
    //---------------------------------------------width 
      parameter  GAIN_CIIW         = 5 ,
      parameter  GAIN_CIPW         = 0 ,
      parameter  BLC_TGT_CIIW      = 14,//raw_cip(10):s.11.0
      parameter  BLC_TGT_CIPW      = 0 ,//raw_cip(12):s.13.0
      parameter  DRKC_CIIW         = 14,//raw_cip(10):s.11.0
      parameter  DRKC_CIPW         = 0 ,//raw_cip(12):s.13.0    
      parameter  CGCF_CIIW         = 1 ,//raw_cip(10):0.12
      parameter  CGCF_CIPW         = 12,//raw_cip(12):1.12  
      parameter  PARM1_CIIW        = 2 ,//raw_cip(10):0.10
      parameter  PARM1_CIPW        = 10,//raw_cip(12):2.10  
      parameter  PARM2_CIIW        = 2 ,//raw_cip(10):0.4
      parameter  PARM2_CIPW        = 4 ,//raw_cip(12):2.4  
      
      parameter  R_LOW_NLM_CIIW    = 3,
      parameter  R_LOW_NLM_CIPW    = 2,
      parameter  IMG_HSZ           = 1920,
      parameter  IMG_HSZ_WTH       = $clog2(IMG_HSZ),
      parameter  R_RTO_THRES_CIIW  = 3,
      parameter  R_RTO_THRES_CIPW  = 2,
      
      parameter  PX_RATE_WTH       = $clog2(PX_RATE),
      
    //---------------------------------------------parameter sum
      parameter  GAIN_CIW          = GAIN_CIIW + GAIN_CIPW ,
      parameter  BLC_TGT_CIW       = BLC_TGT_CIIW + BLC_TGT_CIPW,
      parameter  DRKC_CIW          = DRKC_CIIW + DRKC_CIPW,
      parameter  CGCF_CIW          = CGCF_CIIW + CGCF_CIPW,
      parameter  PARM1_CIW         = PARM1_CIIW + PARM1_CIPW,
      parameter  PARM2_CIW         = PARM2_CIIW + PARM2_CIPW,
      
      parameter  R_LOW_NLM_CIW     = R_LOW_NLM_CIIW + R_LOW_NLM_CIPW,
      parameter  R_RTO_THRES_CIW   = R_RTO_THRES_CIIW + R_RTO_THRES_CIPW
)
(

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output                             o_cu_tsk_end,             // end of task operation
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op0, 
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op1,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op2,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op3,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op4,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op5,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op6,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op7,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op8,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op9,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op10,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op11,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op12,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op13,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op14,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op15,
output[NUM0_SZ+NUM1_SZ-1:0]        o_cu_top_op16,


//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input                         i_cu_tsk_trg_i,           // Task trigger
input  [GAIN_CIW-1:0]         r_ssr_again,
input  [BLC_TGT_CIW-1:0]      r_ssr_blc_tgt,
input  [DRKC_CIW-1:0]         r_ssr_drkc,
input  [CGCF_CIW-1:0]         r_ssr_cgcf,
input  [PARM1_CIW-1:0]        r_ssr_ns_parm1,
input  [PARM2_CIW-1:0]        r_ssr_ns_parm2,

input  [R_LOW_NLM_CIW-1:0]    r_step1_w_low_nlm,      //precision : 3.2
input  [2:0]                  r_step1_w_transit_rng,  //precision : 3.0
input  [R_LOW_NLM_CIW-1:0]    r_step1_b_low_nlm,      //precision : 3.2
input  [2:0]                  r_step1_b_transit_rng,  //precision : 3.0
input  [R_RTO_THRES_CIW-1:0]  r_step2_w_rto_thres,   //precision : 3.2 //range : 0~7.75
input  [2:0]                  r_step2_w_buf_rng,     //range : {1,2,4}
input  [R_RTO_THRES_CIW-1:0]  r_step2_b_rto_thres,   //precision : 3.2 //range : 0~7.75
input  [2:0]                  r_step2_b_buf_rng,     //range : {1,2,4}
input  [IMG_HSZ_WTH-1:0]      r_haddr_start,

input  [8-1:0]                r_hstep,

input                         clk,                    // clock
input                         rst_n                   // active low reset for clk domain

);

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
wire [ALU_SZ-1:0]                  r_ssr_again_ext;
wire [ALU_SZ-1:0]                  r_ssr_blc_tgt_ext;
wire [ALU_SZ-1:0]                  r_ssr_drkc_ext;
wire [ALU_SZ-1:0]                  r_ssr_cgcf_ext;
wire [ALU_SZ-1:0]                  r_ssr_ns_parm1_ext;
wire [ALU_SZ-1:0]                  r_ssr_ns_parm2_ext;

wire [ALU_SZ-1:0]                  r_step1_w_low_nlm_ext;
wire [ALU_SZ-1:0]                  r_step1_w_transit_rng_ext;
wire [ALU_SZ-1:0]                  r_step1_b_low_nlm_ext;
wire [ALU_SZ-1:0]                  r_step1_b_transit_rng_ext;
wire [ALU_SZ-1:0]                  r_haddr_start_ext;
wire [ALU_SZ-1:0]                  r_step2_w_rto_thres_ext;
wire [ALU_SZ-1:0]                  r_step2_w_buf_rng_ext;
wire [ALU_SZ-1:0]                  r_step2_b_rto_thres_ext;
wire [ALU_SZ-1:0]                  r_step2_b_buf_rng_ext;

wire [ALU_SZ-1:0]                  r_hstep_ext;

wire [PC_NUM*ALU_SZ-1:0]           op_i0_array;
wire [PC_NUM*ALU_SZ-1:0]           op_i1_array;

wire                               op_ini_sm;              // @ OP_INI state
wire                               op_rdy_sm;              // @ OP_RDY state
wire                               add_en;                 // Addition op enable
wire                               sub_en;                 // Subtraction op enable
wire                               mul_en;                 // Multiply op enable
wire                               div_en;                 // Division enable
wire [PC_WID-1:0]                  cu_pc;                  // program counter
wire [PC_NUM-1:0]                  cu_opcmd_en;            // command enable
wire [1:0]                         cu_opcode;              // 0: +, 1: -, 2: *, 3: /
wire [NUM0_SZ-1:0]                 cu_opr0;                // input number 0 
wire [NUM1_SZ-1:0]                 cu_opr1;                // input number 1 
wire [NUM1_SZ-1:0]                 cu_prod_msb;            // product MSB 
wire [NUM0_SZ-1:0]                 cu_prod_lsb;            // product LSB 

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
assign r_ssr_again_ext               = {{ALU_SZ-GAIN_CIW{1'b0}}        ,r_ssr_again};
assign r_ssr_blc_tgt_ext             = {{ALU_SZ-BLC_TGT_CIW{1'b0}}     ,r_ssr_blc_tgt};
assign r_ssr_drkc_ext                = {{ALU_SZ-DRKC_CIW{1'b0}}        ,r_ssr_drkc};
assign r_ssr_cgcf_ext                = {{ALU_SZ-CGCF_CIW{1'b0}}        ,r_ssr_cgcf};
assign r_ssr_ns_parm1_ext            = {{ALU_SZ-PARM1_CIW{1'b0}}       ,r_ssr_ns_parm1};
assign r_ssr_ns_parm2_ext            = {{ALU_SZ-PARM2_CIW{1'b0}}       ,r_ssr_ns_parm2};

assign r_step1_w_low_nlm_ext         = {{ALU_SZ-R_LOW_NLM_CIW{1'b0}}   ,r_step1_w_low_nlm};
assign r_step1_w_transit_rng_ext     = {{ALU_SZ-3{1'b0}}              ,r_step1_w_transit_rng};
assign r_step1_b_low_nlm_ext         = {{ALU_SZ-R_LOW_NLM_CIW{1'b0}}   ,r_step1_b_low_nlm};
assign r_step1_b_transit_rng_ext     = {{ALU_SZ-3{1'b0}}              ,r_step1_b_transit_rng};
assign r_haddr_start_ext             = {{ALU_SZ-11{1'b0}}             ,r_haddr_start};
assign r_step2_w_rto_thres_ext       = {{ALU_SZ-R_RTO_THRES_CIW{1'b0}} ,r_step2_w_rto_thres};
assign r_step2_w_buf_rng_ext         = {{ALU_SZ-3{1'b0}}              ,r_step2_w_buf_rng};
assign r_step2_b_rto_thres_ext       = {{ALU_SZ-R_RTO_THRES_CIW{1'b0}} ,r_step2_b_rto_thres};
assign r_step2_b_buf_rng_ext         = {{ALU_SZ-3{1'b0}}              ,r_step2_b_buf_rng};

assign r_hstep_ext                   = {{ALU_SZ-3{1'b0}}              ,r_hstep};


assign op_i0_array[0*ALU_SZ+:ALU_SZ] = r_ssr_again_ext;
assign op_i1_array[0*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}};

assign op_i0_array[1*ALU_SZ+:ALU_SZ] = r_ssr_drkc_ext;
assign op_i1_array[1*ALU_SZ+:ALU_SZ] = r_ssr_blc_tgt_ext;

assign op_i0_array[2*ALU_SZ+:ALU_SZ] = r_ssr_cgcf_ext;
assign op_i1_array[2*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //o_cu_top_op0;

assign op_i0_array[3*ALU_SZ+:ALU_SZ] = r_ssr_ns_parm1_ext;
assign op_i1_array[3*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //o_cu_top_op0;

assign op_i0_array[4*ALU_SZ+:ALU_SZ] = r_ssr_ns_parm2_ext; 
assign op_i1_array[4*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //cu_op3;

assign op_i0_array[5*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //o_cu_top_op4;
assign op_i1_array[5*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //o_cu_top_op4;

assign op_i0_array[6*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; 
assign op_i1_array[6*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; 

assign op_i0_array[7*ALU_SZ+:ALU_SZ] = r_step1_w_low_nlm_ext; 
assign op_i1_array[7*ALU_SZ+:ALU_SZ] = r_step1_w_transit_rng_ext; 

assign op_i0_array[8*ALU_SZ+:ALU_SZ] = r_step1_b_low_nlm_ext; 
assign op_i1_array[8*ALU_SZ+:ALU_SZ] = r_step1_b_transit_rng_ext; 

assign op_i0_array[9*ALU_SZ+:ALU_SZ] = {{ALU_SZ-IMG_HSZ_WTH{1'b0}},IMG_HSZ}; 
assign op_i1_array[9*ALU_SZ+:ALU_SZ] = r_haddr_start_ext; 

assign op_i0_array[10*ALU_SZ+:ALU_SZ] = r_step2_w_rto_thres_ext; 
assign op_i1_array[10*ALU_SZ+:ALU_SZ] = r_step2_w_buf_rng_ext; 

assign op_i0_array[11*ALU_SZ+:ALU_SZ] = r_step2_b_rto_thres_ext; 
assign op_i1_array[11*ALU_SZ+:ALU_SZ] = r_step2_b_buf_rng_ext; 

assign op_i0_array[12*ALU_SZ+:ALU_SZ] = r_step2_w_rto_thres_ext; 
assign op_i1_array[12*ALU_SZ+:ALU_SZ] = {{ALU_SZ-2{1'b0}},2'd3}; 

assign op_i0_array[13*ALU_SZ+:ALU_SZ] = r_step2_b_rto_thres_ext; 
assign op_i1_array[13*ALU_SZ+:ALU_SZ] = {{ALU_SZ-2{1'b0}},2'd3}; 

assign op_i0_array[14*ALU_SZ+:ALU_SZ] = r_step2_w_rto_thres_ext; 
assign op_i1_array[14*ALU_SZ+:ALU_SZ] = {{ALU_SZ-3{1'b0}},3'd5}; 

assign op_i0_array[15*ALU_SZ+:ALU_SZ] = r_step2_b_rto_thres_ext; 
assign op_i1_array[15*ALU_SZ+:ALU_SZ] = {{ALU_SZ-3{1'b0}},3'd5}; 

assign op_i0_array[16*ALU_SZ+:ALU_SZ] = {{ALU_SZ-PX_RATE_WTH{1'b0}},PX_RATE}; 
assign op_i1_array[16*ALU_SZ+:ALU_SZ] = r_hstep_ext; 

/*
assign op_i0_array[17*ALU_SZ+:ALU_SZ] = {{ALU_SZ-PX_RATE_WTH{1'b0}},PX_RATE}; 
assign op_i1_array[17*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}};                        //r_hstep*2 - PX_RATE;

assign op_i0_array[18*ALU_SZ+:ALU_SZ] = r_hstep_ext; 
assign op_i1_array[18*ALU_SZ+:ALU_SZ] = {{ALU_SZ-PX_RATE_WTH{1'b0}},PX_RATE};  //r_hstep   - PX_RATE;

assign op_i0_array[19*ALU_SZ+:ALU_SZ] = {{ALU_SZ-PX_RATE_WTH{1'b0}},PX_RATE}; 
assign op_i1_array[19*ALU_SZ+:ALU_SZ] = r_hstep_ext;                           //PX_RATE   - r_hstep;
 
assign op_i0_array[20*ALU_SZ+:ALU_SZ] = r_hstep_ext; 
assign op_i1_array[20*ALU_SZ+:ALU_SZ] = {{ALU_SZ-2{1'b0}},2'd3}; 

assign op_i0_array[21*ALU_SZ+:ALU_SZ] = {{ALU_SZ-PX_RATE_WTH{1'b0}},PX_RATE};  
assign op_i1_array[21*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}};                        //r_hstep*3 - PX_RATE;
*/

ip_acu_top

#(  .ALU_SZ                 (ALU_SZ),
    .FRA_SZ                 (EXD_SZ),
    .PC_NUM                 (PC_NUM)
    )

acu_top(
    // Output
    .o_cu_tsk_end           (o_cu_tsk_end),
    .o_cu_cmd_en            (cu_opcmd_en),
    .o_cu_op_rdy            (cu_op_rdy),
    .o_cu_prod_msb          (cu_prod_msb),
    .o_cu_prod_lsb          (cu_prod_lsb),

    // Input
    .i_cu_tsk_trg           (i_cu_tsk_trg_i),
    .i_cu_pcstr             (TSK0_START_PC),
    .i_cu_pcend             (TSK0_END_PC),
    .i_cu_opcode            (cu_opcode),
    .i_cu_opr_a             (cu_opr0),
    .i_cu_opr_b             (cu_opr1),

    .clk                    (clk),
    .rst_n                  (rst_n)
    );



ssr_cu_code #( .ALU_SZ           (ALU_SZ),
               .OPA_SZ           (NUM0_SZ),
               .OPB_SZ           (NUM1_SZ),
               .PC_BS            (TSK0_START_PC),
               .PC_NUM           (PC_NUM),
               .GAIN_CIW         (GAIN_CIW),
               .BLC_TGT_CIW      (BLC_TGT_CIW),
               .DRKC_CIW         (DRKC_CIW),
               .CGCF_CIW         (CGCF_CIW),
               .PARM1_CIIW       (PARM1_CIIW),
               .PARM2_CIIW       (PARM2_CIIW),
               .PARM1_CIPW       (PARM1_CIPW),
               .PARM2_CIPW       (PARM2_CIPW),
               .CGCF_CIPW        (CGCF_CIPW),
               
               .R_LOW_NLM_CIIW   (R_LOW_NLM_CIIW),
               .R_LOW_NLM_CIPW   (R_LOW_NLM_CIPW),
               .R_RTO_THRES_CIPW (R_RTO_THRES_CIPW)
               
               )

    ssr_cu_code(

            // Output
            .o_opcode           (cu_opcode),
            .o_opi_a            (cu_opr0),
            .o_opi_b            (cu_opr1),
            .o_cu_op0           (o_cu_top_op0),
            .o_cu_op1           (o_cu_top_op1),
            .o_cu_op2           (o_cu_top_op2),
            .o_cu_op3           (o_cu_top_op3),
            .o_cu_op4           (o_cu_top_op4),
            .o_cu_op5           (o_cu_top_op5),
            .o_cu_op6           (o_cu_top_op6),
            .o_cu_op7           (o_cu_top_op7),
            .o_cu_op8           (o_cu_top_op8),
            .o_cu_op9           (o_cu_top_op9),
            .o_cu_op10          (o_cu_top_op10),
            .o_cu_op11          (o_cu_top_op11),
            .o_cu_op12          (o_cu_top_op12),
            .o_cu_op13          (o_cu_top_op13),
            .o_cu_op14          (o_cu_top_op14),
            .o_cu_op15          (o_cu_top_op15),
            .o_cu_op16          (o_cu_top_op16),
                                                   
            // Input
            .i_prod_msb         (cu_prod_msb),
            .i_prod_lsb         (cu_prod_lsb),
            .i_cu_cmd_en        (cu_opcmd_en),
            .i_op_rdy_sm        (cu_op_rdy),
            .op_i0              (op_i0_array),
            .op_i1              (op_i1_array),
            .i_cu_tsk_trg       (i_cu_tsk_trg_i),

            .clk                (clk),
            .rst_n              (rst_n)
            );

// ----------------- Function ------------------//

function integer log2;
   input integer value;
   begin
      log2 = 0;
      while (2**log2 < value)
         log2 = log2 + 1;
   end
endfunction

endmodule
