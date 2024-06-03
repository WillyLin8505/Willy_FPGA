// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2015
//
// File Name:           ip_cu_dp2_rtl.v
// Author:              Humphrey Lin
//
// File Description:    CU Datapath of elementary operation module
//                      2 steps operation: LSB OP first then MSB
// op = 0: ADD
// unsign (ALU_SZ+1.) = unsign (ALU_SZ.)  + unsign (ALU_SZ.)
// sum[ALU_SZ:0]      = num_0[ALU_SZ-1:0] + num_1[ALU_SZ-1:0]
//
// op = 1: SUB
// sign (ALU_SZ+1.)   = unsign (ALU_SZ.)  - unsign (ALU_SZ.)
// sum[ALU_SZ:0]      = num_0[ALU_SZ-1:0] - num_1[ALU_SZ-1:0]
//
// op = 2: MULT
// unsign (ALU_SZ*2.) = unsign (ALU_SZ.)  * unsign (ALU_SZ.)
// {prod_msb[ALU_SZ-1:0],prod_lsb[ALU_SZ-1:0]} = num_0[ALU_SZ-1:0] * num_1[ALU_SZ-1:0]
//
// op = 3: DIV
// unsign (ALU_SZ-1+FRA_SZ.) = unsign (ALU_SZ-1+FRA_SZ.)  / unsign (ALU_SZ-1.)
// prod_lsb[ALU_SZ+FRA_SZ-2:0] = num_0[ALU_SZ+FRA_SZ-2:0]  / num_1[ALU_SZ-2:0]
//
// Parameters:  ALU_SZ: Arithmetic operation width
//              FRA_SZ: Fraction size of divider
//                      Min. = 2
//              ZERO_DIV_EN: "TRUE"/"FALSE", zero divisor protection enable
//                           "TRUE": if divisor is "0", output result will be equal to dividend
// -FHDR -----------------------------------------------------------------------

module  ip_cu_dp2

//--------------------------------------------------------------//
// Parameter Declaration                                        //
//--------------------------------------------------------------//
#(
parameter                       ALU_SZ      = 8,
parameter                       FRA_SZ      = 2,
parameter                       ZERO_DIV_EN = "TRUE",

// local parameter [DON'T modify below parameters]
parameter                       OPA_SZ      = ALU_SZ + FRA_SZ - 1,
parameter                       OPB_SZ      = ALU_SZ
)
(
//--------------------------------------------------------------//
// Output declaration                                           //
//--------------------------------------------------------------//

output reg [ALU_SZ -1:0]        o_prod_msb,                     // operation product MSB
output reg [OPA_SZ-1:0]         o_prod_lsb,                     // operation product LSB

//--------------------------------------------------------------//
// Input declaration                                            //
//--------------------------------------------------------------//

input      [OPA_SZ-1:0]         i_opr_a,                        // ALU unit Operand input-A
input      [OPB_SZ-1:0]         i_opr_b,                        // ALU unit Operand input-B
input                           i_op_str_sm,                    // @ OP_STR current state
input                           i_op_rdy_sm,                    // @ OP_RDY current state
input                           i_op_act_sm,                    // CU op active
input                           i_op_halt_sm,                   // @ OP_HALT current state
input                           i_add_en,                       // Addition op enable
input                           i_sub_en,                       // Subtraction op enable
input                           i_mul_en,                       // Multiply op enable
input                           i_div_en,                       // Division enable
input                           i_op_msb,                       // @ MSB half-side operation
input                           clk,                            // sensor clock
input                           rst_n                           // active low reset for clk domain
);

//--------------------------------------------------------------//
// Local Parameter                                              //
//--------------------------------------------------------------//

localparam[3:0]                 OP_ADD      = 4'b0001,
                                OP_SUB      = 4'b0010,
                                OP_MUL      = 4'b0100,
                                OP_DIV      = 4'b1000;

//--------------------------------------------------------------//
// Register/Wire declaration                                    //
//--------------------------------------------------------------//

reg        [ALU_SZ -1:0]        prod_msb_src;                   // source of product MSB
reg        [OPA_SZ-1:0]         prod_lsb_src;                   // source of product LSB
wire signed[ALU_SZ/2:0]         lsb_sum_sgn_nxt;
reg  signed[ALU_SZ/2:0]         lsb_sum_sgn;                    // LSB part of sum
wire signed[ALU_SZ:0]           sum_prev_sgn_nxt;               //
reg  signed[ALU_SZ:0]           sum_prev_sgn;                   // previous sum_sgn


wire       [3:0]                op_sel;                         // operation select
wire       [ALU_SZ-1:0]         a_src;                          // Elementary Operation source A
wire       [ALU_SZ-1:0]         b_src;                          // Elementary Operation source B
wire signed[ALU_SZ/2:0]         a_lsb_sgn;                      //
wire signed[ALU_SZ/2:0]         b_lsb_sgn;                      //
wire signed[ALU_SZ/2:0]         a_msb_sgn;                      //
wire signed[ALU_SZ/2:0]         b_msb_sgn;                      //
wire signed[ALU_SZ/2:0]         half_sum_sgn;                   // half sum of a_src and b_src
wire signed[ALU_SZ:0]           sum_sgn;                        // sum of a_src and b_src
wire signed[1:0]                cay_sgn;                        // Carry bit

wire       [ALU_SZ -1:0]        o_prod_msb_nxt;                 //
wire       [OPA_SZ-1:0]         o_prod_lsb_nxt;                 //

wire                            div_zero_flg_nxt;
reg                             div_zero_flg;                   // zero divisor flag

//--------------------------------------------------------------//
// Code Descriptions                                            //
//--------------------------------------------------------------//

// Elementary Operation (a+b, a-b)
//--------------------------------------------------------------//

assign  a_lsb_sgn = $signed({1'b0,a_src[0 +: ALU_SZ/2]});
assign  b_lsb_sgn = $signed({(i_sub_en | i_div_en), 1'b1}) * $signed({1'b0,b_src[0 +: ALU_SZ/2]});

assign  a_msb_sgn = $signed({1'b0,a_src[ALU_SZ/2 +: ALU_SZ/2]});
assign  b_msb_sgn = $signed({(i_sub_en | i_div_en), 1'b1}) * $signed({1'b0,b_src[ALU_SZ/2 +: ALU_SZ/2]});

assign  cay_sgn = $signed({(i_sub_en | i_div_en), 1'b1}) * $signed({1'b0,lsb_sum_sgn[ALU_SZ/2]});

assign  half_sum_sgn = (i_op_msb ? a_msb_sgn : a_lsb_sgn) +
                       (i_op_msb ? b_msb_sgn : b_lsb_sgn) +
                       (i_op_msb ? cay_sgn   : 0);

assign  lsb_sum_sgn_nxt  = ~i_op_msb ? half_sum_sgn : lsb_sum_sgn;
assign  sum_prev_sgn_nxt =  i_op_msb ? sum_sgn : sum_prev_sgn;
assign  sum_sgn          =  i_op_msb ? {half_sum_sgn, lsb_sum_sgn[ALU_SZ/2-1:0]} : sum_prev_sgn;

// elementary op input: a, b source select
assign  a_src = ({ALU_SZ{(i_add_en | i_sub_en | i_mul_en) & ~i_op_halt_sm}} & i_opr_a[ALU_SZ-1:0]) |
                ({ALU_SZ{                  i_div_en}} & o_prod_msb[ALU_SZ-1:0]);

assign  b_src = ({ALU_SZ{(i_add_en | i_sub_en | i_div_en) & ~i_op_halt_sm}} & i_opr_b[ALU_SZ-1:0]) |
                ({ALU_SZ{                  i_mul_en}} & o_prod_msb[ALU_SZ-1:0]);

// elementary op product source select
assign  div_zero_flg_nxt = ZERO_DIV_EN == "TRUE" ?
                          ((i_div_en & i_op_str_sm & (i_opr_b == 0)) | div_zero_flg) & ~i_op_rdy_sm : 0;

assign  o_prod_lsb_nxt = (i_op_act_sm & ~i_op_rdy_sm & i_op_msb) | i_op_str_sm ? (div_zero_flg ? i_opr_a : prod_lsb_src) :
                                                                                 o_prod_lsb;
assign  o_prod_msb_nxt = (i_op_act_sm & ~i_op_rdy_sm & i_op_msb) | i_op_str_sm ? prod_msb_src : o_prod_msb;

assign  op_sel = {i_div_en,i_mul_en,i_sub_en,i_add_en};


always @* begin
   prod_lsb_src = 0;

   case (op_sel)// synopsys full_case
   OP_ADD: prod_lsb_src = {{OPA_SZ-ALU_SZ-1{1'b0}}, sum_sgn[ALU_SZ :0]};
   OP_SUB: prod_lsb_src = {{OPA_SZ-ALU_SZ-1{1'b0}}, sum_sgn[ALU_SZ :0]};
   OP_MUL: prod_lsb_src = {{OPA_SZ-ALU_SZ  {1'b0}},
                          i_op_str_sm ? i_opr_b  :
                                        {o_prod_lsb[0] ? sum_sgn[0] : o_prod_msb[0], o_prod_lsb[ALU_SZ-1:1]}};
   OP_DIV: prod_lsb_src = i_op_str_sm ? {i_opr_a   [OPA_SZ-2:0],1'b0}  :
                                        {o_prod_lsb[OPA_SZ-2:0], (~sum_sgn[ALU_SZ]) & (i_opr_a != 0 && i_opr_b != 0)};
   endcase
end

always @* begin
   prod_msb_src = 0;

   case (op_sel)// synopsys full_case
   OP_ADD,
   OP_SUB: prod_msb_src = 0;
   OP_MUL: prod_msb_src = i_op_str_sm ? 0 :
                                        o_prod_lsb[0] ? sum_sgn[ALU_SZ:1] : {1'b0, o_prod_msb[ALU_SZ-1:1]};
   OP_DIV: prod_msb_src = i_op_str_sm ? {{(ALU_SZ-1){1'b0}}, i_opr_a[OPA_SZ-1]} :
                                        (sum_sgn [ALU_SZ] ?           // sign bit
                                        {o_prod_msb[ALU_SZ-2:0], o_prod_lsb[OPA_SZ-1]} :
                                        {  sum_sgn [ALU_SZ-2:0], o_prod_lsb[OPA_SZ-1]});
   endcase
end


// Sequential Logic
//--------------------------------------------------------------//

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) begin
      o_prod_lsb        <= 0;
      o_prod_msb        <= 0;
      lsb_sum_sgn       <= 0;
      sum_prev_sgn      <= 0;
      div_zero_flg      <= 0;
   end
   else begin
      o_prod_lsb        <= o_prod_lsb_nxt;
      o_prod_msb        <= o_prod_msb_nxt;
      lsb_sum_sgn       <= lsb_sum_sgn_nxt;
      sum_prev_sgn      <= sum_prev_sgn_nxt;
      div_zero_flg      <= div_zero_flg_nxt;
   end
end


endmodule
