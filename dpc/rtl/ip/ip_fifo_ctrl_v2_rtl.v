// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           ip_fifo_ctrl_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description:    FIFO Control
//
// Abbreviations:
//
// Parameters:  ASYNC_EN: async. FIFO enable
//              FIFO_AWID: Addr width of FIFO depth
//              DEPTH_CAL_EN: enable available FIFO depth calculation
//
// Clock Domain: wclk: write clock domain
//               rclk: read clock domain
// -FHDR -----------------------------------------------------------------------

module  ip_fifo_ctrl_v2

    #(
      parameter     FIFO_DEPTH      = 8,        // not necessary if DEPTH_2N == "TRUE"
                                                // not necessary if DEPTH_2N != "TRUE"
      parameter     FIFO_AWID       = log2(FIFO_DEPTH),
      parameter     ASYNC_EN        = 0,
      parameter     DEPTH_2N        = "TRUE",
      parameter     DEPTH_CAL_EN    = 0,
      parameter     DEPTH_CAL_SHORT = 0,        // for timing closure
//
      parameter[FIFO_AWID:0] FIFO_DEP = DEPTH_2N == "TRUE" ? 1'b1 << FIFO_AWID :
                                                             FIFO_DEPTH)
(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output [FIFO_AWID-1:0]  waddr,                  // Write addr
output [FIFO_AWID-1:0]  raddr,                  // Read addr
output reg ff_nfull,                            // FIFO near full
output reg ff_full,                             // FIFO full
output reg ff_nempty,                           // FIFO near empty
output reg ff_empty ,                           // FIFO empty
output reg[FIFO_AWID  :0] fifo_lvl_rck,         // avaliable FIFO data level @ rclk clock domain
output reg[FIFO_AWID  :0] fifo_free_wck = FIFO_DEP,// FIFO free space @ wclk clock domain

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input  push,                                    // FIFO push
input  pop,                                     // FIFO pop
input  wflush,                                  // FIFO flush @ wclk doman
input  rflush,                                  // FIFO flush @ rclk doman
input  wclk,                                    // write clock
input  rclk,                                    // read clock
input  wrst_n,                                  // active low reset @ wclk doman
input  rrst_n                                   // active low reset @ rclk doman
);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//

//localparam [FIFO_AWID:0] FIFO_DEPTH = 1'b1 << FIFO_AWID;
localparam          FLVL_LSB =  DEPTH_CAL_SHORT ? 4 : 0;

//----------------------------------------------//
// Register declaration                         //
//----------------------------------------------//

reg   [FIFO_AWID:0] wr_ptr;                     // Write pointer
reg   [FIFO_AWID:0] rd_ptr;                     // Read pointer
reg   [FIFO_AWID:0] wr_ptr_a1;                  // Write pointer add 1
reg   [FIFO_AWID:0] rd_ptr_a1;                  // Read pointer add 1

reg   [FIFO_AWID:0] wr_ptr_gray;                //
reg   [FIFO_AWID:0] rd_ptr_gray;                //
reg                 ff_mty_kep;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//

wire  [FIFO_AWID:0] rd_ptr_gray_wsyn;           // gray code read pointer sync by wclk
wire  [FIFO_AWID:0] wr_ptr_gray_rsyn;           // gray code write pointer sync by rclk
wire  [FIFO_AWID:0] rd_ptr_wsyn_bin;            // gray2bin(rd_ptr_gray_wsyn)
wire  [FIFO_AWID:0] wr_ptr_rsyn_bin;            // gray2bin(wr_ptr_gray_rsyn)
wire                ff_full_wck;
wire                ff_empty_wck;               // FIFO empty @ wclk clock domain
wire                ff_full_rck;                // FIFO full @ rclk clock domain
wire                ff_empty_rck;
wire  [FIFO_AWID:0] wr_ptr_nxt;                 //
wire  [FIFO_AWID:0] rd_ptr_nxt;                 //
wire  [FIFO_AWID:0] wr_ptr_a1_nxt;              //
wire  [FIFO_AWID:0] rd_ptr_a1_nxt;              //
wire  [FIFO_AWID:0] rd_ptr_gray_nxt;            //
wire  [FIFO_AWID:0] wr_ptr_gray_nxt;            //
wire  ff_nfull_nxt;                             //
wire  ff_full_nxt;                              //
wire  ff_nempty_nxt;                            //
wire  ff_empty_nxt;                             //
wire  [FIFO_AWID-FLVL_LSB:0] fifo_lvl_rck_nxt;
wire  [FIFO_AWID-FLVL_LSB:0] fifo_free_wck_nxt;
wire  ff_mty_kep_nxt;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

// read/write address
assign waddr = wr_ptr[FIFO_AWID-1:0];
assign raddr = rd_ptr[FIFO_AWID-1:0];

// read/write pointer
assign wr_ptr_nxt = {(FIFO_AWID+1){~wflush}} & (push ? wr_ptr + 1 : wr_ptr);
assign rd_ptr_nxt = {(FIFO_AWID+1){~rflush}} & (pop  ? rd_ptr + 1 : rd_ptr);

generate

   if (DEPTH_CAL_EN) begin: gen_fifo_lvl_cal


      if (DEPTH_CAL_SHORT) begin: gen_ff_lvl_cal_m0  // for timing improvement
//assign ff_empty_rck = (wr_ptr_rsyn_bin[FIFO_AWID]     ==  rd_ptr         [FIFO_AWID]) &
//                      (wr_ptr_rsyn_bin[FIFO_AWID-1:0] ==  rd_ptr         [FIFO_AWID-1:0]);

assign ff_full_rck  = (wr_ptr_rsyn_bin[FIFO_AWID]     == ~rd_ptr         [FIFO_AWID])  &
                      (wr_ptr_rsyn_bin[FIFO_AWID-1:0] ==  rd_ptr         [FIFO_AWID-1:0]);

assign ff_empty_wck = (wr_ptr         [FIFO_AWID]     ==  rd_ptr_wsyn_bin[FIFO_AWID]) &
                      (wr_ptr         [FIFO_AWID-1:0] ==  rd_ptr_wsyn_bin[FIFO_AWID-1:0]);

//assign ff_full_wck  = (wr_ptr         [FIFO_AWID]     == ~rd_ptr_wsyn_bin[FIFO_AWID]) &
//                      (wr_ptr         [FIFO_AWID-1:0] ==  rd_ptr_wsyn_bin[FIFO_AWID-1:0]);

assign fifo_lvl_rck_nxt  = ({(FIFO_AWID+1-4){(wr_ptr_rsyn_bin[FIFO_AWID-1:0] < rd_ptr[FIFO_AWID-1:0]) |
                                              ff_full_rck}}  & FIFO_DEP>>4)  +
                              wr_ptr_rsyn_bin[FIFO_AWID-1:4] - rd_ptr[FIFO_AWID-1:4];

assign fifo_free_wck_nxt = ({(FIFO_AWID+1-4){~(wr_ptr[FIFO_AWID-1:0] < rd_ptr_wsyn_bin[FIFO_AWID-1:0]) |
                                              ff_empty_wck}} & FIFO_DEP>>4)  +
                              rd_ptr_wsyn_bin[FIFO_AWID-1:4] - wr_ptr[FIFO_AWID-1:4];
      end
      else begin: gen_ff_lvl_cal_m1

assign ff_full_rck  = (wr_ptr_rsyn_bin[FIFO_AWID]     == ~rd_ptr_nxt     [FIFO_AWID])  &
                      (wr_ptr_rsyn_bin[FIFO_AWID-1:0] ==  rd_ptr_nxt     [FIFO_AWID-1:0]);
assign ff_empty_wck = (wr_ptr_nxt     [FIFO_AWID]     ==  rd_ptr_wsyn_bin [FIFO_AWID]) &
                      (wr_ptr_nxt     [FIFO_AWID-1:0] ==  rd_ptr_wsyn_bin [FIFO_AWID-1:0]);

assign fifo_lvl_rck_nxt  = ({(FIFO_AWID+1){( (wr_ptr_rsyn_bin[FIFO_AWID-1:0] < rd_ptr_nxt[FIFO_AWID-1:0]) & ~ff_empty_nxt) |
                                            ff_full_rck}}  & FIFO_DEP) +
                             wr_ptr_rsyn_bin[FIFO_AWID-1:0] - rd_ptr_nxt[FIFO_AWID-1:0];

assign fifo_free_wck_nxt = ({(FIFO_AWID+1){(~(wr_ptr_nxt[FIFO_AWID-1:0] < rd_ptr_wsyn_bin[FIFO_AWID-1:0]) & ~ff_full_nxt) |
                                            ff_empty_wck}} & FIFO_DEP) +
                             rd_ptr_wsyn_bin[FIFO_AWID-1:0] - wr_ptr_nxt[FIFO_AWID-1:0];
      end
   end
   else begin: gen_fifo_lvl_empty

assign  fifo_lvl_rck_nxt  = 0;
assign  fifo_free_wck_nxt = 0;

   end

// empty flag @ rclk clock domain
assign rd_ptr_a1_nxt = rd_ptr_nxt + 1'b1;

assign ff_nempty_nxt = ((wr_ptr_rsyn_bin[FIFO_AWID]     ==  rd_ptr_a1_nxt  [FIFO_AWID]) &
                        (wr_ptr_rsyn_bin[FIFO_AWID-1:0] ==  rd_ptr_a1_nxt  [FIFO_AWID-1:0])) | ff_empty_nxt;
assign ff_empty_nxt  = ((wr_ptr_rsyn_bin[FIFO_AWID]     ==  rd_ptr_nxt     [FIFO_AWID]) &
                        (wr_ptr_rsyn_bin[FIFO_AWID-1:0] ==  rd_ptr_nxt     [FIFO_AWID-1:0])) | 
                        (ff_mty_kep | (rflush & ff_empty));

assign ff_mty_kep_nxt = ((rflush & ff_empty) | ff_mty_kep) & ~(wr_ptr_gray_rsyn == 0);

// full flag @ wclk clock domain
assign wr_ptr_a1_nxt = wr_ptr_nxt + 1'b1;

assign ff_nfull_nxt  = ((wr_ptr_a1_nxt  [FIFO_AWID]     == ~rd_ptr_wsyn_bin[FIFO_AWID]) &
                        (wr_ptr_a1_nxt  [FIFO_AWID-1:0] ==  rd_ptr_wsyn_bin[FIFO_AWID-1:0])) | ff_full_nxt;
assign ff_full_nxt   = ((wr_ptr_nxt     [FIFO_AWID]     == ~rd_ptr_wsyn_bin[FIFO_AWID]) &
                        (wr_ptr_nxt     [FIFO_AWID-1:0] ==  rd_ptr_wsyn_bin[FIFO_AWID-1:0]));

endgenerate

// ---------- Sequential Logic -----------------//

always @(posedge wclk or negedge wrst_n) begin
   if(~wrst_n) begin
      wr_ptr        <= 0;
      wr_ptr_a1     <= 0;
      wr_ptr_gray   <= 0;
      ff_nfull      <= 0;
      ff_full       <= 0;
      fifo_free_wck <= FIFO_DEP;
   end
   else begin
      wr_ptr        <= wr_ptr_nxt;
      wr_ptr_a1     <= wr_ptr_a1_nxt;
      wr_ptr_gray   <= wr_ptr_gray_nxt;
      ff_nfull      <= ff_nfull_nxt;
      ff_full       <= ff_full_nxt;
      fifo_free_wck <= DEPTH_CAL_SHORT ? {fifo_free_wck_nxt,4'h0} : fifo_free_wck_nxt;
   end
end

always @(posedge rclk or negedge rrst_n) begin
   if(~rrst_n) begin
      rd_ptr        <= 0;
      rd_ptr_a1     <= 0;
      rd_ptr_gray   <= 0;
      ff_nempty     <= 0;
      ff_empty      <= 1;
      fifo_lvl_rck  <= 0;
      ff_mty_kep    <= 0;
   end
   else begin
      rd_ptr        <= rd_ptr_nxt;
      rd_ptr_a1     <= rd_ptr_a1_nxt;
      rd_ptr_gray   <= rd_ptr_gray_nxt;
      ff_nempty     <= ff_nempty_nxt;
      ff_empty      <= ff_empty_nxt;
      fifo_lvl_rck  <= DEPTH_CAL_SHORT ? {fifo_lvl_rck_nxt,4'h0} : fifo_lvl_rck_nxt;
      ff_mty_kep    <= ff_mty_kep_nxt;
   end
end

// ----------- Module Instance -----------------//

generate
   if (ASYNC_EN) begin: gen_async_proc

ip_bin2gray #(FIFO_AWID+1) bin2gray_wr(
        // output
        .gray           (wr_ptr_gray_nxt),
        // input
        .bin            (wr_ptr_nxt)
        );

ip_bin2gray #(FIFO_AWID+1) bin2gray_rd(
        // output
        .gray           (rd_ptr_gray_nxt),
        // input
        .bin            (rd_ptr_nxt)
        );

ip_gray2bin #(FIFO_AWID+1) gray2bin_wr(
        // output
        .bin            (wr_ptr_rsyn_bin),
        // input
        .gray           (wr_ptr_gray_rsyn)
        );

ip_gray2bin #(FIFO_AWID+1) gray2bin_rd(
        // output
        .bin            (rd_ptr_wsyn_bin),
        // input
        .gray           (rd_ptr_gray_wsyn)
        );

ip_sync2 #(.DWID(FIFO_AWID+1)) sync2_rd_ptr_gray(
        //outpu
        .ffq            (rd_ptr_gray_wsyn),
        //input
        .ffd            (rd_ptr_gray),
        .sync_clk       (wclk),
        .sync_rst_n     (wrst_n)
        );

ip_sync2 #(.DWID(FIFO_AWID+1)) sync2_wr_ptr_gray(
        //outpu
        .ffq            (wr_ptr_gray_rsyn),
        //input
        .ffd            (wr_ptr_gray),
        .sync_clk       (rclk),
        .sync_rst_n     (rrst_n)
        );

   end
   else begin: gen_sync_proc
assign  rd_ptr_gray_wsyn= rd_ptr;
assign  rd_ptr_wsyn_bin = rd_ptr; // using F.F. output value to improve timing
assign  wr_ptr_gray_rsyn= wr_ptr;
assign  wr_ptr_rsyn_bin = wr_ptr;
   end
endgenerate

// ----------------- Function ------------------//

function integer log2;
   input integer value;
   begin
      log2 = 0;
      while (2**log2 < value)
         log2 = log2 + 1;
   end
endfunction

// ------------------ SVA ----------------------//
/*
`ifndef SYNTHESIS

fifo_push_chk: assert property (@(posedge wclk) disable iff(~wrst_n)
                  (ff_full & ~push) | (~ff_full))
               else begin
                  $error ("***** SVA ERR @ FIFO Push Error *****");
                  $finish;
               end
fifo_pop_chk: assert property (@(posedge rclk) disable iff(~rrst_n)
                  (ff_empty & ~pop) | (~ff_empty))
               else begin
                  $error ("***** SVA ERR @ FIFO Pop Error *****");
                  $finish;
               end
`endif
*/
endmodule
