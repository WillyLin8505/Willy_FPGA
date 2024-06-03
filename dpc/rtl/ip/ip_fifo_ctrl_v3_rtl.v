// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           ip_fifo_ctrl_v3_rtl.v
// Author:              Humphrey Lin
//
// File Description:    FIFO Control
//                      1. DON'T push or pop data immediately after flush is triggered,
//                         make sure fifo is empty before next push
//                      2. For DEPTH_CAL_SHORT == 1, it cannot represents precise FIFO level. Only for roughly FIFO level reference
// Abbreviations:
//
// Clock Domain: wclk: write clock domain
//               rclk: read  clock domain
// -FHDR -----------------------------------------------------------------------

module  ip_fifo_ctrl_v3

#(
  parameter                         FIFO_DEPTH      = 8,        // FIFO depth

  parameter                         ASYNC_EN        = 0,        // "1": Async wr, rd clock; "0": Sync wr, rd clock
  parameter                         DEPTH_CAL_EN    = 0,        // depth calculation enable
  parameter                         DEPTH_CAL_SHORT = 0,        // easy depth calculation for timing closure

  // local parameter [DON'T modify it !!!]
  parameter                         FIFO_AWID       = $clog2(FIFO_DEPTH),
  parameter [FIFO_AWID:0]           FIFO_DEP        = FIFO_DEPTH
 )

(
//--------------------------------------------------------------//
// Output declaration                                           //
//--------------------------------------------------------------//

output      [FIFO_AWID-1:0]         o_waddr,                    // Write addr
output      [FIFO_AWID-1:0]         o_raddr,                    // Read addr
output reg                          o_ff_nfull,                 // FIFO near full
output reg                          o_ff_full,                  // FIFO full
output reg                          o_ff_nempty,                // FIFO near empty
output reg                          o_ff_empty,                 // FIFO empty
output reg  [FIFO_AWID:0]           o_fifo_lvl_rck,             // avaliable FIFO data level @ rclk clock domain
output reg  [FIFO_AWID:0]           o_fifo_free_wck,            // FIFO free space @ wclk clock domain

//--------------------------------------------------------------//
// Input declaration                                            //
//--------------------------------------------------------------//

input                               i_push,                     // FIFO push
input                               i_pop,                      // FIFO pop
input                               i_wflush,                   // FIFO flush @ wclk doman
input                               i_rflush,                   // FIFO flush @ rclk doman
input                               wclk,                       // write clock
input                               rclk,                       // read clock
input                               wrst_n,                     // active low reset @ wclk doman
input                               rrst_n                      // active low reset @ rclk doman
);

//--------------------------------------------------------------//
// Local Parameter                                              //
//--------------------------------------------------------------//

localparam                          FLVL_LSB =  DEPTH_CAL_SHORT ? 4 : 0;

//--------------------------------------------------------------//
// Register/Wire declaration                                    //
//--------------------------------------------------------------//

reg         [FIFO_AWID:0]           wr_ptr;                     // Write pointer
wire        [FIFO_AWID:0]           wr_ptr_nxt;                 //
reg         [FIFO_AWID:0]           wr_ptr_a1;                  // Write pointer add 1
wire        [FIFO_AWID:0]           wr_ptr_a1_nxt;              //
reg         [FIFO_AWID:0]           rd_ptr;                     // Read pointer
wire        [FIFO_AWID:0]           rd_ptr_nxt;                 //
reg         [FIFO_AWID:0]           rd_ptr_a1;                  // Read pointer add 1
wire        [FIFO_AWID:0]           rd_ptr_a1_nxt;              //

reg         [FIFO_AWID:0]           wr_ptr_gray;
wire        [FIFO_AWID:0]           wr_ptr_gray_nxt;            //
wire        [FIFO_AWID:0]           wr_ptr_a1_gray_nxt;         //
wire        [FIFO_AWID:0]           sxr_wr_ptr_gray;            // gray code write pointer sync by rclk
wire        [FIFO_AWID:0]           sxr_wr_ptr_bin;             // gray2bin(sxr_wr_ptr_gray)
reg         [FIFO_AWID:0]           rd_ptr_gray;
wire        [FIFO_AWID:0]           rd_ptr_gray_nxt;            //
wire        [FIFO_AWID:0]           rd_ptr_a1_gray_nxt;         //
wire        [FIFO_AWID:0]           sxw_rd_ptr_gray;            // gray code read pointer sync by wclk
wire        [FIFO_AWID:0]           sxw_rd_ptr_bin;             // gray2bin(sxw_rd_ptr_gray)

wire                                o_ff_nfull_nxt;
wire                                o_ff_full_nxt;
wire                                o_ff_full_wck;
wire                                o_ff_full_rck;              // FIFO full @ rclk clock domain
wire                                o_ff_nempty_nxt;
wire                                o_ff_empty_nxt;
wire                                o_ff_empty_wck;             // FIFO empty @ wclk clock domain
wire                                o_ff_empty_rck;

wire        [FIFO_AWID-FLVL_LSB:0]  o_fifo_lvl_rck_nxt;
wire        [FIFO_AWID-FLVL_LSB:0]  o_fifo_free_wck_nxt;
reg                                 ff_empty_kep;
wire                                ff_empty_kep_nxt;

//--------------------------------------------------------------//
// Code Descriptions                                            //
//--------------------------------------------------------------//

// read/write address
assign  o_waddr = wr_ptr[FIFO_AWID-1:0];
assign  o_raddr = rd_ptr[FIFO_AWID-1:0];

// read/write pointer
assign  wr_ptr_nxt = {(FIFO_AWID+1){~i_wflush}} & (i_push & ~o_ff_full  ? wr_ptr + 1'b1 : wr_ptr);
assign  rd_ptr_nxt = {(FIFO_AWID+1){~i_rflush}} & (i_pop  & ~o_ff_empty ? rd_ptr + 1'b1 : rd_ptr);


// empty flag @ rclk clock domain
//--------------------------------------------------------------//

assign  rd_ptr_a1_nxt = rd_ptr_nxt + 1'b1;

assign  o_ff_nempty_nxt = ((sxr_wr_ptr_gray[FIFO_AWID]     ==  rd_ptr_a1_gray_nxt[FIFO_AWID]) &
                           (sxr_wr_ptr_gray[FIFO_AWID-1:0] ==  rd_ptr_a1_gray_nxt[FIFO_AWID-1:0])) | o_ff_empty_nxt;

assign  o_ff_empty_nxt  = ((sxr_wr_ptr_gray[FIFO_AWID]     ==  rd_ptr_gray_nxt   [FIFO_AWID]) &
                           (sxr_wr_ptr_gray[FIFO_AWID-1:0] ==  rd_ptr_gray_nxt   [FIFO_AWID-1:0])) | (ff_empty_kep | (i_rflush & o_ff_empty));

// to avoid wr/rd point missmatch during flush interval
assign  ff_empty_kep_nxt = ((i_rflush & o_ff_empty) | ff_empty_kep) & ~(sxr_wr_ptr_gray == 0);


// full flag @ wclk clock domain
//--------------------------------------------------------------//

assign  wr_ptr_a1_nxt = wr_ptr_nxt + 1'b1;

assign  o_ff_nfull_nxt  = ((wr_ptr_a1_gray_nxt  [FIFO_AWID]     == ~sxw_rd_ptr_gray[FIFO_AWID])   &
                           (wr_ptr_a1_gray_nxt  [FIFO_AWID-1]   == ASYNC_EN ? ~sxw_rd_ptr_gray[FIFO_AWID-1] : sxw_rd_ptr_gray[FIFO_AWID-1]) &
                           (wr_ptr_a1_gray_nxt  [FIFO_AWID-2:0] ==  sxw_rd_ptr_gray[FIFO_AWID-2:0])) | o_ff_full_nxt;

assign  o_ff_full_nxt   = ((wr_ptr_gray_nxt     [FIFO_AWID]     == ~sxw_rd_ptr_gray[FIFO_AWID])   &
                           (wr_ptr_gray_nxt     [FIFO_AWID-1]   == ASYNC_EN ? ~sxw_rd_ptr_gray[FIFO_AWID-1] : sxw_rd_ptr_gray[FIFO_AWID-1]) &
                           (wr_ptr_gray_nxt     [FIFO_AWID-2:0] ==  sxw_rd_ptr_gray[FIFO_AWID-2:0]));


generate

   if (DEPTH_CAL_EN) begin: gen_fifo_lvl_cal


      if (DEPTH_CAL_SHORT) begin: gen_ff_lvl_cal_s  // for timing improvement

assign  o_ff_full_rck  = (sxr_wr_ptr_bin[FIFO_AWID]     == ~rd_ptr         [FIFO_AWID])  &
                         (sxr_wr_ptr_bin[FIFO_AWID-1:0] ==  rd_ptr         [FIFO_AWID-1:0]);

assign  o_ff_empty_wck = (wr_ptr        [FIFO_AWID]     ==  sxw_rd_ptr_bin [FIFO_AWID]) &
                         (wr_ptr        [FIFO_AWID-1:0] ==  sxw_rd_ptr_bin [FIFO_AWID-1:0]);


assign  o_fifo_lvl_rck_nxt  = ({(FIFO_AWID+1-4){(sxr_wr_ptr_bin[FIFO_AWID-1:0] < rd_ptr[FIFO_AWID-1:0]) |
                                                 o_ff_full_rck}}  & FIFO_DEP>>4)  +
                                 sxr_wr_ptr_bin[FIFO_AWID-1:4] - rd_ptr[FIFO_AWID-1:4];

assign  o_fifo_free_wck_nxt = ({(FIFO_AWID+1-4){~(wr_ptr[FIFO_AWID-1:0] < sxw_rd_ptr_bin[FIFO_AWID-1:0]) |
                                                 o_ff_empty_wck}} & FIFO_DEP>>4)  +
                                 sxw_rd_ptr_bin[FIFO_AWID-1:4] - wr_ptr[FIFO_AWID-1:4];
      end
      else begin: gen_ff_lvl_cal

assign  o_ff_full_rck  = (sxr_wr_ptr_bin[FIFO_AWID]     == ~rd_ptr_nxt     [FIFO_AWID])  &
                         (sxr_wr_ptr_bin[FIFO_AWID-1:0] ==  rd_ptr_nxt     [FIFO_AWID-1:0]);
assign  o_ff_empty_wck = (wr_ptr_nxt    [FIFO_AWID]     ==  sxw_rd_ptr_bin [FIFO_AWID]) &
                         (wr_ptr_nxt    [FIFO_AWID-1:0] ==  sxw_rd_ptr_bin [FIFO_AWID-1:0]);

assign  o_fifo_lvl_rck_nxt  = ({(FIFO_AWID+1){( (sxr_wr_ptr_bin[FIFO_AWID-1:0] < rd_ptr_nxt[FIFO_AWID-1:0]) & ~o_ff_empty_nxt) |
                                                 o_ff_full_rck}}  & FIFO_DEP) +
                                sxr_wr_ptr_bin[FIFO_AWID-1:0] - rd_ptr_nxt[FIFO_AWID-1:0];

assign  o_fifo_free_wck_nxt = ({(FIFO_AWID+1){(~(wr_ptr_nxt[FIFO_AWID-1:0] < sxw_rd_ptr_bin[FIFO_AWID-1:0]) & ~o_ff_full_nxt) |
                                                 o_ff_empty_wck}} & FIFO_DEP) +
                                sxw_rd_ptr_bin[FIFO_AWID-1:0] - wr_ptr_nxt[FIFO_AWID-1:0];
      end
   end
   else begin: gen_fifo_lvl_empty

assign  o_fifo_lvl_rck_nxt  = 0;
assign  o_fifo_free_wck_nxt = 0;

   end
endgenerate


// Sequential Logic                                             //
//--------------------------------------------------------------//

always @(posedge wclk or negedge wrst_n) begin
   if(~wrst_n) begin
      wr_ptr            <= 0;
      wr_ptr_a1         <= 0;
      wr_ptr_gray       <= 0;
      o_ff_nfull        <= 0;
      o_ff_full         <= 0;
      o_fifo_free_wck   <= FIFO_DEP;
   end
   else begin
      wr_ptr            <= wr_ptr_nxt;
      wr_ptr_a1         <= wr_ptr_a1_nxt;
      wr_ptr_gray       <= wr_ptr_gray_nxt;
      o_ff_nfull        <= o_ff_nfull_nxt;
      o_ff_full         <= o_ff_full_nxt;
      o_fifo_free_wck   <= DEPTH_CAL_SHORT ? {o_fifo_free_wck_nxt,4'h0} : o_fifo_free_wck_nxt;
   end
end

always @(posedge rclk or negedge rrst_n) begin
   if(~rrst_n) begin
      rd_ptr            <= 0;
      rd_ptr_a1         <= 0;
      rd_ptr_gray       <= 0;
      o_ff_nempty       <= 0;
      o_ff_empty        <= 1;
      o_fifo_lvl_rck    <= 0;
      ff_empty_kep      <= 0;
   end
   else begin
      rd_ptr            <= rd_ptr_nxt;
      rd_ptr_a1         <= rd_ptr_a1_nxt;
      rd_ptr_gray       <= rd_ptr_gray_nxt;
      o_ff_nempty       <= o_ff_nempty_nxt;
      o_ff_empty        <= o_ff_empty_nxt;
      o_fifo_lvl_rck    <= DEPTH_CAL_SHORT ? {o_fifo_lvl_rck_nxt,4'h0} : o_fifo_lvl_rck_nxt;
      ff_empty_kep      <= ff_empty_kep_nxt;
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

ip_bin2gray #(FIFO_AWID+1) bin2gray_wr_a1(
        // output
        .gray           (wr_ptr_a1_gray_nxt),
        // input
        .bin            (wr_ptr_a1_nxt)
        );


ip_bin2gray #(FIFO_AWID+1) bin2gray_rd(
        // output
        .gray           (rd_ptr_gray_nxt),
        // input
        .bin            (rd_ptr_nxt)
        );

ip_bin2gray #(FIFO_AWID+1) bin2gray_rd_a1(
        // output
        .gray           (rd_ptr_a1_gray_nxt),
        // input
        .bin            (rd_ptr_a1_nxt)
        );

//

ip_gray2bin #(FIFO_AWID+1) gray2bin_wr(
        // output
        .bin            (sxr_wr_ptr_bin),
        // input
        .gray           (sxr_wr_ptr_gray)
        );

ip_gray2bin #(FIFO_AWID+1) gray2bin_rd(
        // output
        .bin            (sxw_rd_ptr_bin),
        // input
        .gray           (sxw_rd_ptr_gray)
        );

//

ip_sync2 #(.DWID(FIFO_AWID+1)) sync2_rd_ptr_gray(
        //outpu
        .ffq            (sxw_rd_ptr_gray),
        //input
        .ffd            (rd_ptr_gray),
        .sync_clk       (wclk),
        .sync_rst_n     (wrst_n)
        );

ip_sync2 #(.DWID(FIFO_AWID+1)) sync2_wr_ptr_gray(
        //outpu
        .ffq            (sxr_wr_ptr_gray),
        //input
        .ffd            (wr_ptr_gray),
        .sync_clk       (rclk),
        .sync_rst_n     (rrst_n)
        );

   end
   else begin: gen_sync_proc

assign  rd_ptr_gray_nxt    = rd_ptr_nxt;
assign  rd_ptr_a1_gray_nxt = rd_ptr_a1_nxt;
assign  wr_ptr_gray_nxt    = wr_ptr_nxt;
assign  wr_ptr_a1_gray_nxt = wr_ptr_a1_nxt;

assign  sxw_rd_ptr_gray = rd_ptr;
assign  sxw_rd_ptr_bin  = rd_ptr;
assign  sxr_wr_ptr_gray = wr_ptr;
assign  sxr_wr_ptr_bin  = wr_ptr;


   end
endgenerate


// ------------------ SVA ----------------------//

`ifndef SYNTHESIS

fifo_push_chk: assert property (@(posedge wclk) disable iff(~wrst_n)
                  (o_ff_full & ~i_push) | (~o_ff_full))
               else begin
                  $error ("***** SVA ERR @ FIFO Push Error *****");
                  $finish;
               end
fifo_pop_chk: assert property (@(posedge rclk) disable iff(~rrst_n)
                  (o_ff_empty & ~i_pop) | (~o_ff_empty))
               else begin
                  $error ("***** SVA ERR @ FIFO Pop Error *****");
                  $finish;
               end
`endif

endmodule
