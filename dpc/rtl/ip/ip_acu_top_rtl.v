// +FHDR -----------------------------------------------------------------------
// (C) Copyright. 2018
// SILICON OPTRONICS INC. ALL RIGHTS RESERVED
//
// File Name:           ip_acu_top_rtl.v
// Author:              Humphrey Lin
//
// File Description:    Arithmetic Calculation Unit top module
//                      A private reset is required.
//
// Parameters:          ALU_SZ: Arithmetic operation width
//                      FRA_SZ: Fraction size of divider; Min. = 2
//                      PC_NUM: number of PC
//
//                      ZERO_DIV_EN: "TRUE"/"FALSE", zero divisor protection enable
//                                   "TRUE": if divisor is "0", output result will be equal to dividend
// -FHDR -----------------------------------------------------------------------

module  ip_acu_top

//--------------------------------------------------------------//
// Parameter Declaration                                        //
//--------------------------------------------------------------//
#(
parameter                       ALU_SZ          = 16,
parameter                       FRA_SZ          = 8,

parameter                       PC_NUM          = 32,

parameter                       ZERO_DIV_EN     = "TRUE",

//
parameter                       OPA_SZ          = ALU_SZ + FRA_SZ - 1,   // Inherited from upper module [min. value: ALU_SZ + FRA_SZ - 1]
parameter                       OPB_SZ          = ALU_SZ,       // Inherited from upper module

// local parameter [DON'T modify below parameters]
parameter                       PC_WID          = PC_NUM == (1 << $clog2(PC_NUM)) ? $clog2(PC_NUM) + 1 : $clog2(PC_NUM)
                                                                // $clog2(PC_NUM) + 1: PC_NUM cannot occupy all bits, max code is reserved
)

(
//--------------------------------------------------------------//
// Output declaration                                           //
//--------------------------------------------------------------//

output                          o_cu_tsk_end,                   // end of task
output     [PC_NUM-1:0]         o_cu_cmd_en,                    // command enable
output                          o_cu_op_rdy,
output     [ALU_SZ-1:0]         o_cu_prod_msb,                  // product MSB
output     [OPA_SZ-1:0]         o_cu_prod_lsb,                  // product LSB

//--------------------------------------------------------------//
// Input declaration                                            //
//--------------------------------------------------------------//

input                           i_cu_tsk_trg,                   // Task trigger
input      [31:0]               i_cu_pcstr,                     // starting PC addr
input      [31:0]               i_cu_pcend,                     // ending   PC addr
input      [1:0]                i_cu_opcode,                    // OP code, 0: +, 1: -, 2: *, 3: /
input      [OPA_SZ-1:0]         i_cu_opr_a,                     // ALU unit Operand input-A
input      [OPB_SZ-1:0]         i_cu_opr_b,                     // ALU unit Operand input-B

input                           clk,                            //
input                           rst_n                           // low active reset for clk domain [a private reset is required]
);

//--------------------------------------------------------------//
// Local Parameter                                              //
//--------------------------------------------------------------//

localparam                      OP_STEP         = "X2";

localparam                      CYC_NUM         = ALU_SZ + FRA_SZ,
                                CYC_WID         = OP_STEP == "X1" ? $clog2(CYC_NUM) :
                                                                    $clog2(CYC_NUM*2);

//--------------------------------------------------------------//
// Register/Wire declaration                                    //
//--------------------------------------------------------------//

wire                            op_str_sm;                      // @ OP_STR state
wire                            add_en;                         // Addition op enable
wire                            sub_en;                         // Subtraction op enable
wire                            mul_en;                         // Multiply op enable
wire                            div_en;                         // Division op enable
wire                            op_msb;                         // @ MSB half-side operation
wire                            cu_act;                         // CU op active interval
wire       [PC_WID-1:0]         cu_pc;                          // program counter


//--------------------------------------------------------------//
// Code Descriptions                                            //
//--------------------------------------------------------------//

ip_acu_ctrl

#(
    .OP_STEP                    (OP_STEP),
    .ALU_SZ                     (ALU_SZ),
    .FRA_SZ                     (FRA_SZ),
    .PC_NUM                     (PC_NUM),
    .PC_WID                     (PC_WID),
    .CYC_WID                    (CYC_WID))

cu_ctrl(
    // output
    .o_cu_tsk_end               (o_cu_tsk_end),
    .o_op_act_sm                (cu_act),
    .o_op_str_sm                (op_str_sm),
    .o_op_rdy_sm                (o_cu_op_rdy),
    .o_op_halt_sm               (op_halt_sm),
    .o_add_en                   (add_en),
    .o_sub_en                   (sub_en),
    .o_mul_en                   (mul_en),
    .o_div_en                   (div_en),
    .o_cu_cmd_en                (o_cu_cmd_en),
    .o_cu_pc                    (cu_pc),
    .o_op_msb                   (op_msb),

    // input
    .i_cu_tsk_trg               (i_cu_tsk_trg),
    .i_cu_pcstr                 (i_cu_pcstr[PC_WID-1:0]),
    .i_cu_pcend                 (i_cu_pcend[PC_WID-1:0]),
    .i_opcode                   (i_cu_opcode),
    .clk                        (clk),
    .rst_n                      (rst_n)
    );


ip_cu_dp2

#(
    .ALU_SZ                     (ALU_SZ),
    .FRA_SZ                     (FRA_SZ),
    .ZERO_DIV_EN                (ZERO_DIV_EN))

cu_dp(
    // output
    .o_prod_msb                 (o_cu_prod_msb),
    .o_prod_lsb                 (o_cu_prod_lsb),

    // input
    .i_opr_a                    (i_cu_opr_a),
    .i_opr_b                    (i_cu_opr_b),
    .i_op_str_sm                (op_str_sm),
    .i_op_rdy_sm                (o_cu_op_rdy),
    .i_op_act_sm                (cu_act),
    .i_op_halt_sm               (op_halt_sm),
    .i_add_en                   (add_en),
    .i_sub_en                   (sub_en),
    .i_mul_en                   (mul_en),
    .i_div_en                   (div_en),
    .i_op_msb                   (op_msb),
    .clk                        (clk),
    .rst_n                      (rst_n)
    );


endmodule

