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

module  nlm_cu_top

#(
      parameter               TSK0_START_PC   = 0,
      parameter               TSK0_END_PC     = 0,

      parameter               ALU_SZ          = 16,   // ENGY_SZ+2 
      parameter               EXD_SZ          = 0,                 

      parameter               PC_NUM          = TSK0_END_PC+1,
      parameter               PC_WID          = $clog2(PC_NUM),

      parameter               NUM0_SZ         = ALU_SZ + EXD_SZ - 1, 
      parameter               NUM1_SZ         = ALU_SZ,  

    //---------------------------------------------width 
      parameter  GAIN_CIW         = 5 ,
      parameter  GAIN_CPW         = 0 ,
      parameter  BLC_TGT_CIW      = 14,//raw_cip(10):s.11.0
      parameter  BLC_TGT_CPW      = 0 ,//raw_cip(12):s.13.0
      parameter  DRKC_CIW         = 14,//raw_cip(10):s.11.0
      parameter  DRKC_CPW         = 0 ,//raw_cip(12):s.13.0    
      parameter  CGCF_CIW         = 1 ,//raw_cip(10):0.12
      parameter  CGCF_CPW         = 12,//raw_cip(12):1.12  
      parameter  PARM1_CIW        = 2 ,//raw_cip(10):0.10
      parameter  PARM1_CPW        = 10,//raw_cip(12):2.10  
      parameter  PARM2_CIW        = 2 ,//raw_cip(10):0.4
      parameter  PARM2_CPW        = 4 ,//raw_cip(12):2.4  
      
    //---------------------------------------------parameter sum
      parameter  GAIN_CW          = GAIN_CIW + GAIN_CPW ,
      parameter  BLC_TGT_CW       = BLC_TGT_CIW + BLC_TGT_CPW,
      parameter  DRKC_CW          = DRKC_CIW + DRKC_CPW,
      parameter  CGCF_CW          = CGCF_CIW + CGCF_CPW,
      parameter  PARM1_CW         = PARM1_CIW + PARM1_CPW,
      parameter  PARM2_CW         = PARM2_CIW + PARM2_CPW
)
(

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output                cu_tsk_end,             // end of task operation
output [ALU_SZ-1:0] cu_op0,
output [ALU_SZ-1:0] cu_op1,
output [ALU_SZ-1:0] cu_op2,
output [ALU_SZ-1:0] cu_op3,
output [ALU_SZ-1:0] cu_op4,
output [ALU_SZ-1:0] cu_op5,


//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input  [GAIN_CW-1:0]    r_ssr_again,
input  [BLC_TGT_CW-1:0] r_ssr_blc_tgt,
input  [DRKC_CW-1:0]    r_ssr_drkc,
input  [CGCF_CW-1:0]    r_ssr_cgcf,
input  [PARM1_CW-1:0]   r_ssr_ns_parm1,
input  [PARM2_CW-1:0]   r_ssr_ns_parm2,

input                   i_cu_tsk_trg_i,

input                   clk,                    // clock
input                   rst_n                   // active low reset for clk domain

);

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
wire [ALU_SZ-1:0] r_ssr_again_ext;
wire [ALU_SZ-1:0] r_ssr_blc_tgt_ext;
wire [ALU_SZ-1:0] r_ssr_drkc_ext;
wire [ALU_SZ-1:0] r_ssr_cgcf_ext;
wire [ALU_SZ-1:0] r_ssr_ns_parm1_ext;
wire [ALU_SZ-1:0] r_ssr_ns_parm2_ext;

wire [6*ALU_SZ-1:0] op_i0_array;
wire [6*ALU_SZ-1:0] op_i1_array;

reg  [6*ALU_SZ-1:0] op_i0_array_sft;
wire [6*ALU_SZ-1:0] op_i0_array_sft_nxt;

reg  [6*ALU_SZ-1:0] op_i1_array_sft;
wire [6*ALU_SZ-1:0] op_i1_array_sft_nxt;

wire [ALU_SZ-1:0] op_i0;
wire [ALU_SZ-1:0] op_i1;
//--------------------------------------------------------scu_top
wire cu_op_rdy;


//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
assign r_ssr_again_ext = {{ALU_SZ-GAIN_CW{1'b0}},r_ssr_again};
assign r_ssr_blc_tgt_ext = {{ALU_SZ-BLC_TGT_CW{1'b0}},r_ssr_blc_tgt};
assign r_ssr_drkc_ext = {{ALU_SZ-DRKC_CW{1'b0}},r_ssr_drkc};
assign r_ssr_cgcf_ext = {{ALU_SZ-CGCF_CW{1'b0}},r_ssr_cgcf};
assign r_ssr_ns_parm1_ext = {{ALU_SZ-PARM1_CW{1'b0}},r_ssr_ns_parm1};
assign r_ssr_ns_parm2_ext = {{ALU_SZ-PARM2_CW{1'b0}},r_ssr_ns_parm2};

assign op_i0_array[0*ALU_SZ+:ALU_SZ] = r_ssr_again_ext;
assign op_i1_array[0*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}};

assign op_i0_array[1*ALU_SZ+:ALU_SZ] = r_ssr_blc_tgt_ext;
assign op_i1_array[1*ALU_SZ+:ALU_SZ] = r_ssr_drkc_ext;

assign op_i0_array[2*ALU_SZ+:ALU_SZ] = r_ssr_cgcf_ext;
assign op_i1_array[2*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //cu_op0;

assign op_i0_array[3*ALU_SZ+:ALU_SZ] = r_ssr_ns_parm1_ext;
assign op_i1_array[3*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //cu_op0;

assign op_i0_array[4*ALU_SZ+:ALU_SZ] = r_ssr_ns_parm2_ext; 
assign op_i1_array[4*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //cu_op3;

assign op_i0_array[5*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //cu_op4;
assign op_i1_array[5*ALU_SZ+:ALU_SZ] = {ALU_SZ{1'b0}}; //cu_op4;
      
scu_top#(
    .TSK0_START_PC ( TSK0_START_PC ),
    .TSK0_END_PC   ( TSK0_END_PC),
    
    .ALU_SZ        ( ALU_SZ ),
    .EXD_SZ        (EXD_SZ),
    .GAIN_CIW       ( 5 ),
    .GAIN_CPW       ( 0 ),
    .BLC_TGT_CIW    ( 14 ),
    .BLC_TGT_CPW    ( 0 ),
    .DRKC_CIW       ( 14 ),
    .DRKC_CPW       ( 0 ),
    .CGCF_CIW       ( 1 ),
    .CGCF_CPW       ( 12 ),
    .PARM1_CIW      ( 2 ),
    .PARM1_CPW      ( 10 ),
    .PARM2_CIW      ( 2 ),
    .PARM2_CPW      ( 4 )
)u_scu_top(
    .o_cu_tsk_end    ( cu_tsk_end    ),
    .o_cu_top_op0        ( cu_op0        ),
    .o_cu_top_op1        ( cu_op1        ),
    .o_cu_top_op2        ( cu_op2        ),
    .o_cu_top_op3        ( cu_op3        ),
    .o_cu_top_op4        ( cu_op4        ),
    .o_cu_top_op5        ( cu_op5        ),
    
    .i_cu_tsk_trg_i  ( i_cu_tsk_trg_i  ),
    
    .r_ssr_again    ( r_ssr_again    ),
    .r_ssr_blc_tgt  ( r_ssr_blc_tgt  ),
    .r_ssr_drkc     ( r_ssr_drkc     ),
    .r_ssr_cgcf     ( r_ssr_cgcf     ),
    .r_ssr_ns_parm1 ( r_ssr_ns_parm1 ),
    .r_ssr_ns_parm2 ( r_ssr_ns_parm2 ),
    
    .clk           ( clk           ),
    .rst_n         ( rst_n         )
);

endmodule
