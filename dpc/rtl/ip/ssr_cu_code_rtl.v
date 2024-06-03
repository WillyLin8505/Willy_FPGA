// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2023
//
// File Name:           ssr_cu_code_rtl.v
// Author:              Humphrey Lin
//
// File Description:    Sensor CU Code list & Result latch module
//
//                      1. Output of CU results are stored by D-latch.
//                      2. Output of CU results are treated as false path.
//                      3. It's better to constraint related latch_en as an individual clock root.
//                      4. A private reset is required.
//
//                    -----   -----   -----   -----   -----   -----   -----   -----   -----   ---
//      clk           |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
//                -----   -----   -----   -----   -----   -----   -----   -----   -----   -----
//      prod_lsb      /-------------------------------/-------------------------------/
//                    \-------------------------------\-------------------------------\
//                             -------                         -------
//      latch_en              |       |                       |       |
//                     --------       -------------------------       ----------------
//
// Abbreviations:       PC: Programming counter
//
// -FHDR -----------------------------------------------------------------------

module  ssr_cu_code

#(
parameter  ALU_SZ           = 2,
parameter  PC_BS            = 0,       // PC base addr
parameter  PC_NUM           = 1,       // number of PC

parameter  OPA_SZ           = 0,       // Size of OP operand-A [Inherited from upper module]
parameter  OPB_SZ           = 0,       // Size of OP operand-B [Inherited from upper module]

parameter  GAIN_CIW          = 0,
parameter  BLC_TGT_CIW       = 0,
parameter  DRKC_CIW          = 0,
parameter  CGCF_CIW          = 0,
parameter  PARM1_CIIW         = 0,
parameter  PARM2_CIIW         = 0,
parameter  PARM1_CIPW        = 0,
parameter  PARM2_CIPW        = 0,
parameter  CGCF_CIPW         = 0,

parameter  R_LOW_NLM_CIIW    = 0,
parameter  R_LOW_NLM_CIPW    = 0,
parameter  R_RTO_THRES_CIPW  = 0,
// local inference parameter [Don't change it]
parameter  AGX_WID          = 2**(GAIN_CIW-4) // real A-gain bit width

)
(
//--------------------------------------------------------------//
// Output declaration                                           //
//--------------------------------------------------------------//

output reg[ 1:0]                o_opcode,                       // OP coide, 0: +, 1: -, 2: *, 3: /
output reg[OPA_SZ-1:0]          o_opi_a,                        // ALU unit Operand input-A
output reg[OPB_SZ-1:0]          o_opi_b,                        // ALU unit Operand input-B

output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op0,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op1,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op2,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op3,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op4,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op5,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op6,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op7,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op8,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op9,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op10,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op11,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op12,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op13,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op14,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op15,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op16,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op17,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op18,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op19,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op20,
output reg[OPA_SZ+OPB_SZ-1:0]   o_cu_op21,

//--------------------------------------------------------------//
// Input declaration                                            //
//--------------------------------------------------------------//

input [OPB_SZ-1:0]              i_prod_msb,                     // OP result product MSB
input [OPA_SZ-1:0]              i_prod_lsb,                     // OP result product LSB
input [PC_NUM-1 :0]             i_cu_cmd_en,                    // command enable
input                           i_op_rdy_sm,                    // @ OP_RDY state
input [ALU_SZ*PC_NUM-1:0]       op_i0,
input [ALU_SZ*PC_NUM-1:0]       op_i1,
input                           i_cu_tsk_trg,                  

input                           clk,                            // clock
input                           rst_n                           // active low reset for clk domain
);


//--------------------------------------------------------------//
// Local Parameter                                              //
//--------------------------------------------------------------//

localparam[1:0]                 OP_ADD          = 2'b00,
                                OP_SUB          = 2'b01,
                                OP_MUL          = 2'b10,
                                OP_DIV          = 2'b11;

//--------------------------------------------------------------//
// Register/Wire declaration                                    //
//--------------------------------------------------------------//
wire[GAIN_CIW-4+1-1:0]          again_msb;
wire[PC_NUM*2-1:0]              opcode;
wire[PC_NUM*OPA_SZ-1:0]         opi_a;
wire[PC_NUM*OPB_SZ-1:0]         opi_b;

reg [ 1:0]                      o_opcode_nxt;
reg [OPA_SZ-1:0]                o_opi_a_nxt;
reg [OPB_SZ-1:0]                o_opi_b_nxt;

wire[PC_NUM-1 :0]               opo_lat_en_nxt;
reg [PC_NUM-1 :0]               opo_lat_en;

//
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo0;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo1;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo2;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo3;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo4;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo5;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo6;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo7;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo8;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo9;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo10;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo11;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo12;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo13;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo14;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo15;
wire[OPA_SZ+OPB_SZ-1:0]         cu_opo16;

wire[OPA_SZ+OPB_SZ-1:0]         cu_temp_nxt;
reg [OPA_SZ+OPB_SZ-1:0]         cu_temp;



integer                         i;

//--------------------------------------------------------------//
// Code Descriptions                                            //
//--------------------------------------------------------------//

always @* begin
   // i = 0
   o_opcode_nxt = opcode[0*2 +: 2] & {2{i_cu_cmd_en[PC_BS+0]}};
   // i = 1~
   for (i=1; i<PC_NUM; i=i+1)
      o_opcode_nxt = o_opcode_nxt | (opcode[i*2 +: 2] & {2{i_cu_cmd_en[PC_BS+i]}});

end

always @* begin
   // i = 0
   o_opi_a_nxt = opi_a[0*OPA_SZ +: OPA_SZ] & {OPA_SZ{i_cu_cmd_en[PC_BS+0]}};
   // i = 1~
   for (i=1; i<PC_NUM; i=i+1)
      o_opi_a_nxt = o_opi_a_nxt | (opi_a[i*OPA_SZ +: OPA_SZ] & {OPA_SZ{i_cu_cmd_en[PC_BS+i]}});

end

always @* begin
   // i = 0
   o_opi_b_nxt = opi_b[0*OPB_SZ +: OPB_SZ] & {OPB_SZ{i_cu_cmd_en[PC_BS+0]}};
   // i = 1~
   for (i=1; i<PC_NUM; i=i+1)
      o_opi_b_nxt = o_opi_b_nxt | (opi_b[i*OPB_SZ +: OPB_SZ] & {OPB_SZ{i_cu_cmd_en[PC_BS+i]}});

end


// OP operand
//--------------------------------------------------------------//

assign  again_msb = 1'b1 << op_i0[6:4]; //cu_gain = 2^r_ssr_again[6:4]*(1+r_ssr_again[3:0])


// OP Code
//--------------------------------------------------------------//

// PC_BS+0: ssr_again = ssr_gain_msb * (1'b1, r_ssr_again[3:0]}
assign  opcode[0*2 +: 2] = OP_MUL;
assign  opi_a[0*OPA_SZ +: OPA_SZ] = {{ALU_SZ-3{1'b0}},again_msb};
assign  opi_b[0*OPB_SZ +: OPB_SZ] = {{ALU_SZ-4{1'b0}},{1'b1,op_i0[3:0]}};

// PC_BS+1: ssr_blc_dc_dlt = -r_ssr_blc_tgt + r_ssr_drkc //maybe be negedge 
assign  opcode[1*2 +: 2] = op_i1[ALU_SZ+DRKC_CIW] ? OP_ADD : OP_SUB;
assign  opi_a[1*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*1+:ALU_SZ];
assign  opi_b[1*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*1+:ALU_SZ];

// PC_BS+2: ssr_shot_nvar_bs = r_ssr_cgcf * ssr_again //4.12
assign  opcode[2*2 +: 2] = OP_MUL;
assign  opi_a[2*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*2+:ALU_SZ];
assign  opi_b[2*OPB_SZ +: OPB_SZ] = cu_temp[OPA_SZ-1:4];

// PC_BS+3: ssr_rout_nvar_bs = r_ssr_ns_parm1 *  ssr_again //4.10
assign  opcode[3*2 +: 2] = OP_MUL;
assign  opi_a[3*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*3+:ALU_SZ];
assign  opi_b[3*OPB_SZ +: OPB_SZ] = cu_temp[OPA_SZ-1:4];

// PC_BS+4: ssr_rout_nvar_bs = ssr_rout_nvar_bs + r_ssr_ns_parm2 //4.10 + 0.4
assign  opcode[4*2 +: 2] = OP_ADD;
assign  opi_a[4*OPA_SZ +: OPA_SZ] = cu_temp;
assign  opi_b[4*OPB_SZ +: OPB_SZ] = {op_i0[ALU_SZ*4+:ALU_SZ],{PARM1_CIPW-PARM2_CIPW{1'b0}}};

// PC_BS+5: ssr_rout_nvar_bs = ssr_rout_nvar_bs * ssr_rout_nvar_bs
assign  opcode[5*2 +: 2] = OP_MUL;
assign  opi_a[5*OPA_SZ +: OPA_SZ] = cu_temp;
assign  opi_b[5*OPB_SZ +: OPB_SZ] = cu_temp;

// PC_BS+6: round(ssr_rout_nvar_bs)
assign  opcode[6*2 +: 2] = OP_ADD;
assign  opi_a[6*OPA_SZ +: OPA_SZ] = cu_temp[PARM1_CIPW*2-CGCF_CIPW-1+:(GAIN_CIW-1)+CGCF_CIPW+1]; //precision : 8.13 , 
assign  opi_b[6*OPB_SZ +: OPB_SZ] = 1'b1;

// PC_BS+7: r_step1_w_low_nlm_ext + r_step1_w_transit_rng_ext
assign  opcode[7*2 +: 2] = OP_ADD;
assign  opi_a[7*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*7+:ALU_SZ];
assign  opi_b[7*OPB_SZ +: OPB_SZ] = {op_i1[ALU_SZ*7+:ALU_SZ],{R_LOW_NLM_CIPW{1'b0}}};

// PC_BS+8: r_step1_b_low_nlm_ext + r_step1_b_transit_rng_ext
assign  opcode[8*2 +: 2] = OP_ADD;
assign  opi_a[8*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*8+:ALU_SZ];
assign  opi_b[8*OPB_SZ +: OPB_SZ] = {op_i1[ALU_SZ*8+:ALU_SZ],{R_LOW_NLM_CIPW{1'b0}}};

// PC_BS+9: 
assign  opcode[9*2 +: 2] = OP_SUB;
assign  opi_a[9*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*9+:ALU_SZ]-1;
assign  opi_b[9*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*9+:ALU_SZ];

// PC_BS+10: 
assign  opcode[10*2 +: 2] = OP_ADD;
assign  opi_a[10*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*10+:ALU_SZ];
assign  opi_b[10*OPB_SZ +: OPB_SZ] = {op_i1[ALU_SZ*10+:ALU_SZ],{R_RTO_THRES_CIPW{1'b0}}};

// PC_BS+11: 
assign  opcode[11*2 +: 2] = OP_ADD;
assign  opi_a[11*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*11+:ALU_SZ];
assign  opi_b[11*OPB_SZ +: OPB_SZ] = {op_i1[ALU_SZ*11+:ALU_SZ],{R_RTO_THRES_CIPW{1'b0}}};

// PC_BS+12: 
assign  opcode[12*2 +: 2] = OP_MUL;
assign  opi_a[12*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*12+:ALU_SZ];
assign  opi_b[12*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*12+:ALU_SZ];

// PC_BS+13: 
assign  opcode[13*2 +: 2] = OP_MUL;
assign  opi_a[13*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*13+:ALU_SZ];
assign  opi_b[13*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*13+:ALU_SZ];

// PC_BS+14: 
assign  opcode[14*2 +: 2] = OP_MUL;
assign  opi_a[14*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*14+:ALU_SZ];
assign  opi_b[14*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*14+:ALU_SZ];

// PC_BS+15: 
assign  opcode[15*2 +: 2] = OP_MUL;
assign  opi_a[15*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*15+:ALU_SZ];
assign  opi_b[15*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*15+:ALU_SZ];

// PC_BS+16: 
assign  opcode[16*2 +: 2] = OP_SUB;
assign  opi_a[16*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*16+:ALU_SZ];
assign  opi_b[16*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*16+:ALU_SZ];
/*
// PC_BS+17: 
assign  opcode[17*2 +: 2] = OP_SUB;
assign  opi_a[17*OPA_SZ +: OPA_SZ] = cu_temp;
assign  opi_b[17*OPB_SZ +: OPB_SZ] = op_i0[ALU_SZ*17+:ALU_SZ]; 

// PC_BS+18: 
assign  opcode[18*2 +: 2] = OP_SUB;
assign  opi_a[18*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*18+:ALU_SZ];
assign  opi_b[18*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*18+:ALU_SZ];

// PC_BS+19: 
assign  opcode[19*2 +: 2] = OP_SUB;
assign  opi_a[19*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*19+:ALU_SZ];
assign  opi_b[19*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*19+:ALU_SZ];

// PC_BS+20: 
assign  opcode[20*2 +: 2] = OP_MUL;
assign  opi_a[20*OPA_SZ +: OPA_SZ] = op_i0[ALU_SZ*20+:ALU_SZ];
assign  opi_b[20*OPB_SZ +: OPB_SZ] = op_i1[ALU_SZ*20+:ALU_SZ];

// PC_BS+21: 
assign  opcode[21*2 +: 2] = OP_SUB;
assign  opi_a[21*OPA_SZ +: OPA_SZ] = cu_temp;
assign  opi_b[21*OPB_SZ +: OPB_SZ] = op_i0[ALU_SZ*21+:ALU_SZ];
*/

// OP Result
//--------------------------------------------------------------//

assign  opo_lat_en_nxt= ({PC_NUM{i_op_rdy_sm}} & i_cu_cmd_en);

//
assign  cu_opo0  = i_prod_lsb; //mul
assign  cu_opo1  = i_prod_lsb; //sub or add 
assign  cu_opo2  = i_prod_lsb; //mul
assign  cu_opo3  = i_prod_lsb; //mul 
assign  cu_opo4  = i_prod_lsb; //add
assign  cu_opo5  = i_prod_lsb; //mul
assign  cu_opo6  = i_prod_lsb[OPA_SZ-1:1]; //add
assign  cu_opo7  = i_prod_lsb; //add
assign  cu_opo8  = i_prod_lsb; //add
assign  cu_opo9  = i_prod_lsb; //sub
assign  cu_opo10 = i_prod_lsb; //add 
assign  cu_opo11 = i_prod_lsb; //add
assign  cu_opo12 = i_prod_lsb; //mul
assign  cu_opo13 = i_prod_lsb; //mul
assign  cu_opo14 = i_prod_lsb; //mul
assign  cu_opo15 = i_prod_lsb; //mul
assign  cu_opo16 = i_prod_lsb; //mul
assign  cu_opo17 = i_prod_lsb; //mul
assign  cu_opo18 = i_prod_lsb; //mul
assign  cu_opo19 = i_prod_lsb; //mul
assign  cu_opo20 = i_prod_lsb; //mul
assign  cu_opo21 = i_prod_lsb; //mul

// OP temp register

assign  cu_temp_nxt   = i_op_rdy_sm & (i_cu_cmd_en[PC_BS+0]  | 
                                       i_cu_cmd_en[PC_BS+3]  | 
                                       i_cu_cmd_en[PC_BS+4]  | 
                                       i_cu_cmd_en[PC_BS+5]  |
                                       i_cu_cmd_en[PC_BS+6]  ) ? {i_prod_lsb[OPA_SZ-1:0]} : cu_temp;


// Sequential Logic
//--------------------------------------------------------------//

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) begin
      o_opcode      <= 0;
      o_opi_a       <= 0;
      o_opi_b       <= 0;
      opo_lat_en    <= {PC_NUM{1'b1}};

      cu_temp       <= 0;
   end
   else begin
      o_opcode      <= o_opcode_nxt;
      o_opi_a       <= o_opi_a_nxt;
      o_opi_b       <= o_opi_b_nxt;
      opo_lat_en    <= opo_lat_en_nxt;

      cu_temp       <= cu_temp_nxt;
   end
end

// OP output Latch w/o asyc reset
always@*    if(opo_lat_en[0]) o_cu_op0 <= cu_opo0;
always@*    if(opo_lat_en[1]) o_cu_op1 <= cu_opo1;
always@*    if(opo_lat_en[2]) o_cu_op2 <= cu_opo2;
always@*    if(opo_lat_en[3]) o_cu_op3 <= cu_opo3;
always@*    if(opo_lat_en[4]) o_cu_op4 <= cu_opo4;
always@*    if(opo_lat_en[5]) o_cu_op5 <= cu_opo5;
always@*    if(opo_lat_en[6]) o_cu_op6 <= cu_opo6;
always@*    if(opo_lat_en[7]) o_cu_op7 <= cu_opo7;
always@*    if(opo_lat_en[8]) o_cu_op8 <= cu_opo8;
always@*    if(opo_lat_en[9]) o_cu_op9 <= cu_opo9;
always@*    if(opo_lat_en[10]) o_cu_op10 <= cu_opo10;
always@*    if(opo_lat_en[11]) o_cu_op11 <= cu_opo11;
always@*    if(opo_lat_en[12]) o_cu_op12 <= cu_opo12;
always@*    if(opo_lat_en[13]) o_cu_op13 <= cu_opo13;
always@*    if(opo_lat_en[14]) o_cu_op14 <= cu_opo14;
always@*    if(opo_lat_en[15]) o_cu_op15 <= cu_opo15;
always@*    if(opo_lat_en[16]) o_cu_op16 <= cu_opo16;

endmodule
