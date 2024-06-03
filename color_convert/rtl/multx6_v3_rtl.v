module  multx6_v3 (

output reg [13:0] mult0_pwr3,
output reg [13:0] mult1_pwr3,
output reg [13:0] mult2_pwr3,

input [14:0] i_op0,
input [14:0] i_op1,
input [14:0] i_op2,

input  clk,
input  rst_n

);

wire [29:0] mult0_pwr3_p0;
wire [29:0] mult1_pwr3_p0;
wire [29:0] mult2_pwr3_p0;

wire [13:0] op0_pwr3_p0_nxt;
wire [13:0] op1_pwr3_p0_nxt;
wire [13:0] op2_pwr3_p0_nxt;

reg [13:0] op0_pwr3_p0;
reg [13:0] op1_pwr3_p0;
reg [13:0] op2_pwr3_p0;

wire [28:0] op0_pwr3;
wire [28:0] op1_pwr3;
wire [28:0] op2_pwr3;

wire [13:0] mult0_pwr3_nxt;
wire [13:0] mult1_pwr3_nxt;
wire [13:0] mult2_pwr3_nxt;

reg [14:0] i_op0_q;
reg [14:0] i_op1_q;
reg [14:0] i_op2_q;

//
assign  mult0_pwr3_p0 = i_op0 * i_op0 + 16'h8000;
assign  mult1_pwr3_p0 = i_op1 * i_op1 + 16'h8000;
assign  mult2_pwr3_p0 = i_op2 * i_op2 + 16'h8000;

assign  op0_pwr3_p0_nxt = mult0_pwr3_p0[16 +: 14];
assign  op1_pwr3_p0_nxt = mult1_pwr3_p0[16 +: 14];
assign  op2_pwr3_p0_nxt = mult2_pwr3_p0[16 +: 14];

assign  op0_pwr3 = op0_pwr3_p0 * i_op0_q + 15'h2000;
assign  op1_pwr3 = op1_pwr3_p0 * i_op1_q + 15'h2000;
assign  op2_pwr3 = op2_pwr3_p0 * i_op2_q + 15'h2000;

assign  mult0_pwr3_nxt = op0_pwr3[14 +: 14];
assign  mult1_pwr3_nxt = op1_pwr3[14 +: 14];
assign  mult2_pwr3_nxt = op2_pwr3[14 +: 14];


always @(posedge clk or negedge rst_n)
   if (~rst_n) begin
        op0_pwr3_p0 <= 0;
        op1_pwr3_p0 <= 0;
        op2_pwr3_p0 <= 0;

        mult0_pwr3  <= 0;
        mult1_pwr3  <= 0;
        mult2_pwr3  <= 0;
        
        i_op0_q     <= 0;
        i_op1_q     <= 0;
        i_op2_q     <= 0;
    end
    else begin
        op0_pwr3_p0 <= op0_pwr3_p0_nxt;
        op1_pwr3_p0 <= op1_pwr3_p0_nxt;
        op2_pwr3_p0 <= op2_pwr3_p0_nxt;

        mult0_pwr3  <= mult0_pwr3_nxt;
        mult1_pwr3  <= mult1_pwr3_nxt;
        mult2_pwr3  <= mult2_pwr3_nxt;

        i_op0_q     <= i_op0;
        i_op1_q     <= i_op1;
        i_op2_q     <= i_op2;
    end
endmodule
