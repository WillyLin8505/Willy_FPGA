// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           mbist_gen_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description:    MBIST Pattern generator
// Abbreviations:

// Parameters:
//
// -FHDR -----------------------------------------------------------------------


module  mbist_gen(

            // Output
                sram_we_o,
                sram_addr_o,
                sram_data_o,
                golden_addr_o,
                golden_data_o,
                test_start_o,
                test_busy_o,
                test_finish_o,
                test_done_o,
                test_byte_o,
                bist_step_o,

            // Input
                mbist_en_i,
                cmp_err_i,
                clk,
                rst_n
                );

parameter           DW    = 16;
parameter           AW    = 8;
parameter           DEPTH = 0;

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output              sram_we_o;
output[AW-1:0]      sram_addr_o;
output[DW-1:0]      sram_data_o;
output[AW-1:0]      golden_addr_o;
output[DW-1:0]      golden_data_o;
output              test_start_o;
output              test_busy_o;
output              test_finish_o;
output              test_done_o;
output              test_byte_o;
output[2:0]         bist_step_o;

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input               mbist_en_i;
input               cmp_err_i;
input               clk;
input               rst_n;

//----------------------------------------------//
// Register declaration                         //
//----------------------------------------------//

reg                 tst;
reg   [AW+4:0]      test_cnt;
reg   [AW+4:0]      test_cnt_q1;
reg                 test_busy_o;
reg   [2:0]         test_step;
reg                 bist_en_q1;
reg                 bist_en_q2;
reg                 bist_en_q3;
reg   [2:0]         test_step_q1;
reg                 test_done_o;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//

wire  [AW-1:0]      addr;
wire  [DW-1:0]      test_in;
wire                sram_we_o;
wire  [DW-1:0]      sram_data_o;
wire  [AW-1:0]      sram_addr_o;
wire                test_finish_o;
wire                test_end_tmp;
wire                test_end;
wire                test_start_o;
wire                test_byte_o;
wire  [DW-1:0]      test_in_tmp;
wire  [AW-1:0]      addr_tmp;
wire  [DW-1:0]      golden_data_o;
wire  [AW-1:0]      golden_addr_o;
wire  [2:0]         bist_step_o;
wire                test_done_o_nxt;
wire  [2:0]         test_step_nxt;
wire  [2:0]         test_step_q1_nxt;
wire  [AW+4:0]      test_cnt_q1_nxt;
wire                test_busy_o_nxt;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

assign  addr    =  test_step[0] ? (DEPTH - 1 - test_cnt[AW+3:4]) : test_cnt[AW+3:4];
assign  test_in = ~test_cnt[3]  ? (                        {DW>2*(DW/2)} ?  {{(DW/2)+1}{test_cnt[2:1]}} :  {{DW/2}{test_cnt[2:1]}}) :
                                   test_cnt[2:1]==2'b00 ? ({DW>2*(DW/2)} ?  {{(DW/2)+1}{test_cnt[5:4]}} :  {{DW/2}{test_cnt[5:4]}}) :
                                   test_cnt[2:1]==2'b01 ? ({DW>2*(DW/2)} ? ~{{(DW/2)+1}{test_cnt[5:4]}} : ~{{DW/2}{test_cnt[5:4]}}) :
                                   test_cnt[2:1]==2'b10 ?  {DW{test_cnt[4]}} :
                                                          ~{DW{test_cnt[4]}};
assign  sram_we_o     = test_busy_o_nxt ? ~test_cnt[0] : 1'b0;
assign  test_finish_o = test_step[2];
assign  test_end_tmp  = (test_cnt[AW+3:4] == DEPTH - 1);
assign  test_end      = test_end_tmp && (&test_cnt[3:0]);
assign  test_start_o  = bist_en_q2 & ~bist_en_q3;
assign  test_byte_o   = test_cnt[AW+4];

assign  sram_data_o = test_in;
assign  sram_addr_o = addr;

assign  addr_tmp    =  test_step_q1[0] ? (DEPTH - 1 - test_cnt_q1[AW+3:4]) : test_cnt_q1[AW+3:4];
assign  test_in_tmp = ~test_cnt_q1[3]          ? ({DW>2*(DW/2)} ?  {{(DW/2)+1}{test_cnt_q1[2:1]}} :  {{DW/2}{test_cnt_q1[2:1]}}) :
                       test_cnt_q1[2:1]==2'b00 ? ({DW>2*(DW/2)} ?  {{(DW/2)+1}{test_cnt_q1[5:4]}} :  {{DW/2}{test_cnt_q1[5:4]}}) :
                       test_cnt_q1[2:1]==2'b01 ? ({DW>2*(DW/2)} ? ~{{(DW/2)+1}{test_cnt_q1[5:4]}} : ~{{DW/2}{test_cnt_q1[5:4]}}) :
                       test_cnt_q1[2:1]==2'b10 ?  {DW{test_cnt_q1[4]}} :
                                                 ~{DW{test_cnt_q1[4]}};

assign  golden_data_o = test_in_tmp;
assign  golden_addr_o = addr_tmp;
assign  bist_step_o   = test_step_q1;

assign  test_step_nxt    = {3{~(test_start_o | test_finish_o)}} & (test_end ? test_step + 1'b1 : test_step);
assign  test_step_q1_nxt = {3{~test_start_o}} & (~cmp_err_i ? test_step : test_step_q1);
assign  test_cnt_q1_nxt  = {AW+4{~test_start_o}} & (~cmp_err_i ? test_cnt : test_cnt_q1);

assign  test_busy_o_nxt  = ~test_busy_o ? test_start_o : ~test_finish_o;
assign  test_done_o_nxt  = ~test_done_o ? test_finish_o : test_done_o;

always @(posedge clk or negedge rst_n) begin
   if(~rst_n)
     test_cnt <= 0;
   else if(test_start_o | test_finish_o)
     test_cnt <= 0;
   else if(test_step[1]) begin
       if(test_end_tmp) begin
           test_cnt[AW+3:4] <= 0;
           test_cnt[3:0]    <= test_cnt[3:0] + 1'b1;
       end
       else if(test_busy_o)
          test_cnt[AW+3:4]  <= test_cnt[AW+3:4] + 1'b1;
   end
   else begin
       if(test_end)
          test_cnt <= 0;
       else if(test_busy_o)
          test_cnt <= test_cnt + 1'b1;
   end
end

// ---------- Sequential Logic -----------------//

always @(posedge clk or negedge rst_n) begin
   if(~rst_n) begin
      test_done_o   <= 0;
      test_step     <= 0;
      test_busy_o   <= 0;
      test_step_q1  <= 0;
      test_cnt_q1   <= 0;
   end
   else begin
      test_done_o   <= test_done_o_nxt;
      test_step     <= test_step_nxt;
      test_busy_o   <= test_busy_o_nxt;
      test_step_q1  <= test_step_q1_nxt;
      test_cnt_q1   <= test_cnt_q1_nxt;
   end
end

always @(posedge clk or negedge rst_n) begin
   if(~rst_n) begin
      bist_en_q1 <= 1'b0;
      bist_en_q2 <= 1'b0;
      bist_en_q3 <= 1'b0;
   end
   else begin
      bist_en_q1 <= mbist_en_i;
      bist_en_q2 <= bist_en_q1;
      bist_en_q3 <= bist_en_q2;
   end
end


endmodule


