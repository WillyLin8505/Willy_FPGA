// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2015
//
// File Name:           ip_acu_ctrl_rtl.v
// Author:              Humphrey Lin
// File Description:    CU control module
//
// -FHDR -----------------------------------------------------------------------

module  ip_acu_ctrl

//--------------------------------------------------------------//
// Parameter Declaration                                        //
//--------------------------------------------------------------//
#(
parameter                       OP_STEP         = "X2",         // "X1": one-step ALU; "X2": two-step ALU

parameter                       ALU_SZ          = 8,
parameter                       FRA_SZ          = 2,

parameter                       PC_NUM          = 1,            // total available numbers of PC
parameter                       PC_WID          = $clog2(PC_NUM),// Program counter width
parameter                       CYC_WID         = 1             // max cycle counter width of one math operator
)
(
//--------------------------------------------------------------//
// Output declaration                                           //
//--------------------------------------------------------------//

output                          o_cu_tsk_end,                   // end of task operation
output                          o_op_act_sm,                    // CU op active interval
output                          o_op_str_sm,                    // @ OP_CMD state
output                          o_op_rdy_sm,                    // @ OP_RDY state
output                          o_op_halt_sm,                   // @ OP_HALT state
output                          o_add_en,                       // Addition op enable
output                          o_sub_en,                       // Subtraction op enable
output                          o_mul_en,                       // Multiply op enable
output                          o_div_en,                       // Division op enable
output reg [PC_NUM-1:0]         o_cu_cmd_en,                    // command enable
output reg [PC_WID-1:0]         o_cu_pc,                        // program counter
output                          o_op_msb,                       // @ MSB half-side operation

//--------------------------------------------------------------//
// Input declaration                                            //
//--------------------------------------------------------------//

input                           i_cu_tsk_trg,                   // Task trigger
input      [PC_WID-1:0]         i_cu_pcstr,                     // starting PC number
input      [PC_WID-1:0]         i_cu_pcend,                     // ending   PC number
input      [1:0]                i_opcode,                       // 0: +, 1: -, 2: *, 3: /

input                           clk,                            // clock
input                           rst_n                           // low active reset for clk domain
);

//--------------------------------------------------------------//
// Local Parameter                                              //
//--------------------------------------------------------------//

localparam[ 1:0]                OP_ADD          = 2'b00,
                                OP_SUB          = 2'b01,
                                OP_MUL          = 2'b10,
                                OP_DIV          = 2'b11;

localparam[ 5:0]                CU_OP_IDLE      = 6'b00_0000,
                                OP_CMD          = 6'b00_0001,   // sent command enable
                                OP_STR          = 6'b00_0011,   // OP start
                                OP_ONGO         = 6'b00_0101,
                                OP_RDY          = 6'b00_1001,
                                OP_HALT         = 6'b01_0000,
                                OP_END          = 6'b10_0000;

//--------------------------------------------------------------//
// Register/Wire declaration                                    //
//--------------------------------------------------------------//

reg        [5:0]                cu_op_cs;                       // CU op current state
reg        [5:0]                cu_op_ns;                       // CU op next state

reg        [PC_WID-1:0]         o_cu_pc_nxt;                    //
reg        [PC_NUM-1:0]         o_cu_cmd_en_nxt;                //

wire                            op_ongo_sm;                     // @ OP_ONGO state
wire                            op_end_sm;                      // @ OP_END state
wire                            op_final;                       // Final op step
wire                            tri_load;                       // Tri-state address load

wire                            tsk_pcend_eq;                   // cu_pc == end of task
reg                             tsk_pcend_eq_q;                 // 1T delay to match FSM

wire                            op_cyc_cnt_rst;
wire                            op_cyc_cnt_inc;
wire       [CYC_WID-1:0]        op_cyc_cnt_nxt;
reg        [CYC_WID-1:0]        op_cyc_cnt;                     // ALU operator cycle counter

wire       [ 2:0]               pc_sel;                         // program counter select
wire                            pc_cnt_rst;
wire                            pc_cnt_inc;                     // program counter increment
wire       [PC_WID-1 :0]        pc_cnt_nxt;                     //
reg        [PC_WID-1:0]         pc_cnt;                         // PC counter

genvar                          gen_i;

//--------------------------------------------------------------//
// Code Descriptions                                            //
//--------------------------------------------------------------//

// Per OP Command operation
//--------------------------------------------------------------//

assign  o_add_en  = i_opcode == OP_ADD;
assign  o_sub_en  = i_opcode == OP_SUB;
assign  o_mul_en  = i_opcode == OP_MUL;
assign  o_div_en  = i_opcode == OP_DIV;

assign  o_op_msb = op_ongo_sm & op_cyc_cnt[0];

generate
   if (OP_STEP == "X2") begin: gen_x2_op

assign  op_final  = ((o_add_en | o_sub_en) & op_ongo_sm)     |
                    ( o_mul_en & (op_cyc_cnt ==  ALU_SZ*2))  |
                    ( o_div_en & (op_cyc_cnt == (ALU_SZ+FRA_SZ-1)*2));

assign  op_cyc_cnt_rst = ~(o_op_rdy_sm | i_cu_tsk_trg);
assign  op_cyc_cnt_inc = op_ongo_sm | ((o_add_en | o_sub_en) & o_op_str_sm);
assign  op_cyc_cnt_nxt = {CYC_WID{op_cyc_cnt_rst}} &
                         (op_cyc_cnt_inc ? op_cyc_cnt + 1'b1 :  op_cyc_cnt);

   end
   else begin: gen_x1_op

assign  op_final  = ((o_add_en | o_sub_en) & o_op_str_sm)  |
                    ( o_mul_en & (op_cyc_cnt == ALU_SZ-1)) |
                    ( o_div_en & (op_cyc_cnt == ALU_SZ+FRA_SZ-1));

assign  op_cyc_cnt_rst = ~(o_op_rdy_sm | i_cu_tsk_trg);
assign  op_cyc_cnt_inc = op_ongo_sm;
assign  op_cyc_cnt_nxt = {CYC_WID{op_cyc_cnt_rst}} &
                         (op_cyc_cnt_inc ? op_cyc_cnt + 1'b1 :  op_cyc_cnt);

   end
endgenerate

// command enable
always @* begin: cmd_en_mux
   integer i;

   for (i=0; i <= PC_NUM-1; i=i+1)
      o_cu_cmd_en_nxt[i] = o_cu_pc_nxt == i;
end


// PC operation
//--------------------------------------------------------------//

assign  pc_cnt_rst = i_cu_tsk_trg;
assign  pc_cnt_inc = o_op_rdy_sm & ~tsk_pcend_eq_q;

assign  pc_cnt_nxt = pc_cnt_rst ? i_cu_pcstr :
                     pc_cnt_inc ? o_cu_pc + 1'b1 : pc_cnt;

assign  tri_load   = o_op_rdy_sm;

assign  pc_sel     = {tri_load, o_op_halt_sm, i_cu_tsk_trg};

always @* begin

   o_cu_pc_nxt = o_cu_pc;

   case (pc_sel)
   3'b001: o_cu_pc_nxt = i_cu_pcstr;
   3'b010: o_cu_pc_nxt = pc_cnt;
   3'b100: o_cu_pc_nxt = {PC_WID{1'b1}};

   endcase
end


// Task end indication

assign  tsk_pcend_eq = o_cu_pc == i_cu_pcend;

assign  o_cu_tsk_end = op_end_sm;


// State Machine
//--------------------------------------------------------------//

assign  o_op_act_sm  = cu_op_cs[0];
assign  o_op_str_sm  = cu_op_cs[1];
assign  op_ongo_sm   = cu_op_cs[2];
assign  o_op_rdy_sm  = cu_op_cs[3];
assign  o_op_halt_sm = cu_op_cs[4];
assign  op_end_sm    = cu_op_cs[5];

always @* begin: CU_OP_FSM

   cu_op_ns = cu_op_cs;

   case (cu_op_cs)

   CU_OP_IDLE:
      if (i_cu_tsk_trg)
         cu_op_ns = OP_CMD;

   OP_CMD:
      if (op_final)
         cu_op_ns = OP_RDY;
      else
         cu_op_ns = OP_STR;

   OP_STR:
         cu_op_ns = OP_ONGO;

   OP_ONGO:
      if (op_final)
         cu_op_ns = OP_RDY;

   OP_RDY:
      if (tsk_pcend_eq_q)
         cu_op_ns = OP_END;
      else
         cu_op_ns = OP_HALT;

   OP_HALT:
         cu_op_ns = OP_CMD;

   OP_END:
         cu_op_ns = CU_OP_IDLE;

   endcase

   if (i_cu_tsk_trg)
      cu_op_ns = OP_CMD;

end

always @(posedge clk or negedge rst_n) begin
   if (~rst_n)
      cu_op_cs <= CU_OP_IDLE;
   else
      cu_op_cs <= cu_op_ns;
end


// Sequential Logic
//--------------------------------------------------------------//

always @(posedge clk or negedge rst_n) begin
   if (~rst_n) begin
      o_cu_pc           <= 0;
      op_cyc_cnt        <= 0;
      pc_cnt            <= 0;
      o_cu_cmd_en       <= 0;
      tsk_pcend_eq_q    <= 0;
   end
   else begin
      o_cu_pc           <= o_cu_pc_nxt;
      op_cyc_cnt        <= op_cyc_cnt_nxt;
      pc_cnt            <= pc_cnt_nxt;
      o_cu_cmd_en       <= o_cu_cmd_en_nxt;
      tsk_pcend_eq_q    <= tsk_pcend_eq;
   end
end


endmodule
