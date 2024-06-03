// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           ip_gmem_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description:    Memory implemented by F.F., Latch, FPGA distributed RAM or Block RAM
//                      If read/write data at the same addr, always execute "Read first"
//
// Clock Domain: aclk: port A clock domain
//               bclk: port B clock domain
// -FHDR -----------------------------------------------------------------------

module ip_gmem
#(
parameter                       MEM_DEP         = 0,        // memory depth
parameter                       MEM_DW          = 0,        // memory data width
                                                            // memory type
parameter                       MEM_TYPE        = "FPGA_BLKRAM",
                                                            // "DFF_RST": DFF with sync. reset
                                                            // "DFF"    : DFF wo reset
                                                            // "LATCH"  : Latch
                                                            // "FPGA_DISRAM": FPGA distributed RAM
                                                            // "FPGA_BLKRAM": FPGA block RAM
                                                            // "FPGA_ULTRAM": FPGA ultra RAM
                                                            // "1PSRAM": single-port SRAM
                                                            // "2PSRAM": two-port SRAM
parameter                       MEM_NAME        = "",       // "1PSRAM" or "2PSRAM" name
parameter                       DO_FFO          = "TRUE",   // F.F. data output
//parameter                       DO_XTRA_1T      = "FALSE",  // Add 1T latency on data output
parameter                       DO_ON_WR        = "TRUE",   // "FALSE": Don't read data while WR for port-A
                                                            // i.e. doa will not change while wea active
//
parameter                       MEM_AW          = $clog2(MEM_DEP)
)

(
//----------------------------------------------------------//
// Output declaration                                       //
//----------------------------------------------------------//

output      [MEM_DW-1:0]        doa,                        // port A memory data output
output      [MEM_DW-1:0]        dob,                        // port B memory data output
output                          doa_vld,
output                          dob_vld,

output                          mbist_done,
output                          mbist_err,

//----------------------------------------------------------//
// Input declaration                                        //
//----------------------------------------------------------//

input       [MEM_DW-1:0]        wea,                        // port A write enable, active high
input                           ena,                        // port A enable, active high
input                           enb,                        // port B enable, active high
input                           clr,                        // Memory clear for "DFF_RST"
input       [MEM_AW-1:0]        addra,                      // port A address
input       [MEM_AW-1:0]        addrb,                      // port B address
input       [MEM_DW-1:0]        dia,                        // port A memory data input
input       [ 7:0]              mopt,                       // SRAM option/margin setting
input                           mbist_en,                   // SRAM mbist enable

input                           clka,                       // port A clock
input                           clkb,                       // port B clock
input                           arst_n,                     // active low reset for clka domain
input                           brst_n                      // active low reset for clkb domain
);

//----------------------------------------------------------//
// Local Parameter                                          //
//----------------------------------------------------------//

localparam                      MEM_USE_DFF     = (MEM_TYPE == "DFF")     |
                                                  (MEM_TYPE == "DFF_RST") |
                                                  (MEM_TYPE == "LATCH") ? "TRUE" : "FALSE";
localparam                      MEM_USE_FPGA    = (MEM_TYPE == "FPGA_DISRAM") |
                                                  (MEM_TYPE == "FPGA_BLKRAM") |
                                                  (MEM_TYPE == "FPGA_ULTRAM") ? "TRUE" : "FALSE";

//----------------------------------------------------------//
// Register/Wire declaration                                //
//----------------------------------------------------------//
wire                            rena;
wire                            renb;
reg                             rena_q;
reg                             renb_q;
wire                            mem_rena;
wire                            mem_renb;

wire        [MEM_DW-1:0]        mem_doa;
wire        [MEM_DW-1:0]        mem_dob;
reg         [MEM_DW-1:0]        mem_do_rega;
reg         [MEM_DW-1:0]        mem_do_regb;
wire        [MEM_DW-1:0]        doa_ltch_nxt;
reg         [MEM_DW-1:0]        doa_ltch;

reg         [MEM_DW-1:0]        mem_rda;
wire        [MEM_DW-1:0]        mem_rda_nxt;
reg         [MEM_DW-1:0]        mem_rda_dly;
reg         [MEM_DW-1:0]        mem_rdb;
wire        [MEM_DW-1:0]        mem_rdb_nxt;
reg         [MEM_DW-1:0]        mem_rdb_dly;

wire                            rda_vld_nxt;
wire                            rdb_vld_nxt;
reg                             rda_vld;
reg                             rdb_vld;
reg                             rda_vld_dly;
reg                             rdb_vld_dly;


genvar  gi;
integer i;

//----------------------------------------------------------//
// Code Descriptions                                        //
//----------------------------------------------------------//

//  Memory data write
// -----------------------------------------------

generate

case (MEM_TYPE)

   "DFF" : begin: gen_ff_worst
   // ------------------------

(* ram_style = "registers" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

assign  mem_doa = mem[addra];
assign  mem_dob = mem[addrb];

always @(posedge clka) begin

   if (ena & (wea !=0))
      mem[addra]    <= (wea & dia) | ((~wea) & mem_doa);
end
   end

   "LATCH" : begin: gen_lat
   // ------------------------

(* ram_style = "registers" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

assign  mem_doa = mem[addra];
assign  mem_dob = mem[addrb];

always @* begin
   if (ena & wea & ~clka)
      mem[addra]    = dia;
end
   end

   "FPGA_DISRAM" : begin: gen_fpga_disram
   // ------------------------

(* ram_style = "distributed" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

initial begin
   for (i = 0; i < MEM_DEP; i = i+1) begin
      mem[i] = 0;
   end
end

always @(posedge clka) begin

   if (ena) begin
     if (wea)
      mem[addra]    <= dia;
     else
      mem_do_rega   <= mem[addra];
   end
end

always @(posedge clkb) begin
   if (enb)
      mem_do_regb   <= mem[addrb];
end

   end

   "FPGA_BLKRAM" : begin: gen_fpga_blkram
   // ------------------------

(* ram_style = "block" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

initial begin
   for (i = 0; i < MEM_DEP; i = i+1) begin
      mem[i] = 0;
   end
end

always @(posedge clka) begin

   if (ena) begin
     if (wea)
      mem[addra]    <= dia;
     else
      mem_do_rega   <= mem[addra];
   end
end

always @(posedge clkb) begin
   if (enb)
      mem_do_regb   <= mem[addrb];
end

   end

   "FPGA_ULTRAM" : begin: gen_fpga_ultram
   // ------------------------

(* ram_style = "ultra" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

initial begin
   for (i = 0; i < MEM_DEP; i = i+1) begin
      mem[i] = 0;
   end
end

always @(posedge clka) begin

   if (ena) begin
     if (wea)
      mem[addra]    <= dia;
     else
      mem_do_rega   <= mem[addra];
   end
end

always @(posedge clkb) begin
   if (enb)
      mem_do_regb   <= mem[addrb];
end

   end

   "1PSRAM" : begin: gen_1psram
   // ------------------------

ram_1p
#(
    .RAM_NAME       (MEM_NAME),
    .RAM_DEP        (MEM_DEP),
    .RAM_DW         (MEM_DW)
 )
ram_1p (
    .rmdo           (mem_doa),
    .mbist_done     (mbist_done),
    .mbist_err      (mbist_err),

    .we             (wea),
    .ce             (ena),
    .addr           (addra),
    .wmdi           (dia),
    .mopt           (mopt),
    .mbist_en       (mbist_en),

    .clk            (clka),
    .rst_n          (arst_n)
);
   end

   "2PSRAM" : begin: gen_2psram
   // ------------------------

ram_2p
#(
    .RAM_NAME       (MEM_NAME),
    .RAM_DEP        (MEM_DEP),
    .RAM_DW         (MEM_DW)
 )
ram_2p (
    .rmdo           (mem_dob),
    .mbist_done     (mbist_done),
    .mbist_err      (mbist_err),

    .we             (wea),
    .re             (enb),
    .waddr          (addra),
    .raddr          (addrb),
    .wmdi           (dia),
    .mopt           (mopt),
    .mbist_en       (mbist_en),

    .wclk           (clka),
    .rclk           (clkb),
    .wrst_n         (arst_n),
    .rrst_n         (brst_n)
);

   end
endcase


endgenerate


//  Memory data read
// -----------------------------------------------
// ~~ to make sinport-port DO as FPGA SRAM's No-Change mode
assign  rena        = ena & ~|wea;
assign  renb        = enb;

assign  mem_rena    = MEM_USE_DFF == "TRUE" ? rena : rena_q;
assign  mem_renb    = MEM_USE_DFF == "TRUE" ? renb : renb_q;

assign  mem_rda_nxt = mem_rena ? (MEM_USE_FPGA == "TRUE" ? mem_do_rega : mem_doa) : mem_rda;
assign  mem_rdb_nxt = mem_renb ? (MEM_USE_FPGA == "TRUE" ? mem_do_regb : mem_dob) : mem_rdb;

assign  rda_vld_nxt = mem_rena;
assign  rdb_vld_nxt = mem_renb;

assign  doa         = DO_FFO     == "True" ? mem_rda : mem_rda_nxt;
assign  dob         = DO_FFO     == "True" ? mem_rdb : mem_rdb_nxt;

assign  doa_vld     = DO_FFO     == "True" ? rda_vld : rda_vld_nxt;
assign  dob_vld     = DO_FFO     == "True" ? rdb_vld : rdb_vld_nxt;


always @(posedge clka or negedge arst_n) begin
   if (~arst_n) begin
      mem_rda       <= 0;
      mem_rda_dly   <= 0;
      rda_vld_dly   <= 0;
      rdb_vld_dly   <= 0;
      rda_vld       <= 0;
      rena_q        <= 0;
   end
   else begin
      mem_rda       <= mem_rda_nxt;
      mem_rda_dly   <= mem_rda;
      rda_vld_dly   <= rda_vld;
      rdb_vld_dly   <= rdb_vld;
      rda_vld       <= rda_vld_nxt;
      rena_q        <= rena;
   end
end

always @(posedge clkb or negedge brst_n) begin
   if (~brst_n) begin
      mem_rdb       <= 0;
      mem_rdb_dly   <= 0;
      rdb_vld       <= 0;
      renb_q        <= 0;
   end
   else begin
      mem_rdb       <= mem_rdb_nxt;
      mem_rdb_dly   <= mem_rdb;
      rdb_vld       <= rdb_vld_nxt;
      renb_q        <= renb;
   end
end


endmodule
