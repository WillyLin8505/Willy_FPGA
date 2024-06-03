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
                                                            // "DFF_RST": DFF with reset
                                                            // "DFF"    : DFF wo reset
                                                            // "LATCH"  : Latch
                                                            // "FPGA_DISRAM": FPGA distributed RAM
                                                            // "FPGA_BLKRAM": FPGA block RAM
                                                            // "FPGA_ULTRAM": FPGA ultra RAM
                                                            // "SPSRAM": single-port SRAM
parameter                       MEM_NAME        = "",       // "SPSRAM" name
parameter                       DO_FFO          = "TRUE",   // F.F. data output
parameter                       DO_XTRA_1T      = "FALSE",  // Add 1T latency on data output
parameter                       DO_ON_WR        = "TRUE",   // "FALSE": Don't read data while WR for port-A
                                                            // i.e. doa will not change while wea active
parameter                       MEM_CLR_NUM     = 0,        // number of "DFF_RST" will be CLR by clr input
// local parameter
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

output      [MEM_DW*MEM_DEP-1:0]memo,                       // memory content output

//----------------------------------------------------------//
// Input declaration                                        //
//----------------------------------------------------------//

input                           wea,                        // port A write enable, active high
input                           ena,                        // port A enable, active high
input                           enb,                        // port B enable, active high
input                           clr,                        // Memory clear for "DFF_RST"
input       [MEM_AW-1:0]        addra,                      // port A address
input       [MEM_AW-1:0]        addrb,                      // port B address
input       [MEM_DW-1:0]        dia,                        // port A memory data input
input       [ 7:0]              mtest,                      // SPSRAM option/margin setting

input                           clka,                       // port A clock
input                           clkb,                       // port B clock
input                           arst_n,                     // active low reset for clka domain
input                           brst_n                      // active low reset for clkb domain
);

//----------------------------------------------------------//
// Register/Wire declaration                                //
//----------------------------------------------------------//

wire        [MEM_DW-1:0]        mem_doa;
wire        [MEM_DW-1:0]        mem_dob;
reg         [MEM_DW-1:0]        mem_rda;
wire        [MEM_DW-1:0]        mem_rda_nxt;
reg         [MEM_DW-1:0]        mem_rda_q;
reg         [MEM_DW-1:0]        mem_rdb;
wire        [MEM_DW-1:0]        mem_rdb_nxt;
reg         [MEM_DW-1:0]        mem_rdb_q;
wire                            mem_rda_en;
wire                            mem_rdb_en;

wire        [MEM_DEP-1:0]       mem_rst;                    // memory clear

wire                            rda_vld_nxt;
wire                            rdb_vld_nxt;
reg                             rda_vld;
reg                             rdb_vld;
reg                             rda_vld_q;
reg                             rdb_vld_q;

genvar  gi;
//integer i;

//----------------------------------------------------------//
// Code Descriptions                                        //
//----------------------------------------------------------//


//  Memory data write
// -----------------------------------------------

generate

case (MEM_TYPE)

   "DFF": begin: gen_ff_worst
   // ------------------------

(* ram_style = "register" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

assign  mem_doa = mem[addra];
assign  mem_dob = mem[addrb];

   for (gi = 0; gi < MEM_DEP; gi = gi + 1) begin: gen_memo
assign memo[gi*MEM_DW +: MEM_DW] = mem[gi];
   end

always @(posedge clka) begin

   if (ena & wea)
      mem[addra]    <= dia;
end
   end

   "DFF_RST": begin: gen_ff
   // ------------------------

(* ram_style = "register" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

assign  mem_doa = mem[addra];
assign  mem_dob = mem[addrb];

   for (gi = 0; gi < MEM_DEP; gi = gi + 1) begin: gen_memo
assign memo[gi*MEM_DW +: MEM_DW] = mem[gi];
   end

   for (gi = 0; gi < MEM_DEP; gi = gi + 1) begin: gen_mem_rst
      if (gi < MEM_CLR_NUM)
assign  mem_rst[gi] = clr | ~arst_n;
      else
assign  mem_rst[gi] = ~arst_n;
   end

   for (gi=0; gi < MEM_DEP; gi=gi+1) begin: gen_mem_wr
always @(posedge clka) begin
   if (mem_rst[gi])
      mem[gi]        <= {MEM_DW{1'b0}};
   else if (ena & wea & (addra == gi))
      mem[gi]        <= dia;
end
   end // for
   end

   "LATCH": begin: gen_lat
   // ------------------------

(* ram_style = "register" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

assign  mem_doa = mem[addra];
assign  mem_dob = mem[addrb];

   for (gi = 0; gi < MEM_DEP; gi = gi + 1) begin: gen_memo
assign memo[gi*MEM_DW +: MEM_DW] = mem[gi];
   end

always @* begin
   if (ena & wea & ~clka)
      mem[addra]    = dia;
end
   end

   "FPGA_DISRAM": begin: gen_fpga_disram
   // ------------------------

(* ram_style = "distributed" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

assign  mem_doa = mem[addra];
assign  mem_dob = mem[addrb];

   for (gi = 0; gi < MEM_DEP; gi = gi + 1) begin: gen_memo
assign memo[gi*MEM_DW +: MEM_DW] = mem[gi];
   end

always @(posedge clka) begin

   if (ena) begin
     if (wea)
      mem[addra]    <= dia;
   end
end
   end

   "FPGA_BLKRAM": begin: gen_fpga_blkram
   // ------------------------

(* ram_style = "block" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

assign  mem_doa = mem[addra];
assign  mem_dob = mem[addrb];

   for (gi = 0; gi < MEM_DEP; gi = gi + 1) begin: gen_memo
assign memo[gi*MEM_DW +: MEM_DW] = mem[gi];
   end

always @(posedge clka) begin

   if (ena) begin
     if (wea)
      mem[addra]    <= dia;
   end
end
   end

   "FPGA_ULTRAM": begin: gen_fpga_ultram
   // ------------------------

(* ram_style = "ultra" *)
reg         [MEM_DW-1:0] mem [0:MEM_DEP-1];

assign  mem_doa = mem[addra];
assign  mem_dob = mem[addrb];

   for (gi = 0; gi < MEM_DEP; gi = gi + 1) begin: gen_memo
assign memo[gi*MEM_DW +: MEM_DW] = mem[gi];
   end

always @(posedge clka) begin

   if (ena) begin
     if (wea)
      mem[addra]    <= dia;
   end
end
   end

   "2PSRAM": begin: gen_spsram
   // ------------------------

ram_2p
#(
    .RAM_NAME       (MEM_NAME),
    .RAM_DEP        (MEM_DEP),
    .RAM_DW         (MEM_DW)
 )
ram_2p (
    .rmdo           (mem_dob),
    .we             (wea),
    .re             (enb),
    .waddr          (addra),
    .raddr          (addrb),
    .wmdi           (dia),
    .mtest          (mtest),

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
assign  mem_rda_en  = DO_ON_WR == "TRUE" ? ena : ena & ~wea;
assign  mem_rdb_en  = enb;

assign  mem_rda_nxt = mem_rda_en ? mem_doa : mem_rda;
assign  mem_rdb_nxt = mem_rdb_en ? mem_dob : mem_rdb;

assign  rda_vld_nxt = mem_rda_en;
assign  rdb_vld_nxt = mem_rdb_en;

assign  doa         = DO_FFO     == "FALSE" ? mem_rda_nxt :
                      DO_XTRA_1T == "FALSE" ? mem_rda     : mem_rda_q;
assign  dob         = DO_FFO     == "FALSE" ? mem_rdb_nxt :
                      DO_XTRA_1T == "FALSE" ? mem_rdb     : mem_rdb_q;

assign  doa_vld     = DO_FFO     == "FALSE" ? rda_vld_nxt :
                      DO_XTRA_1T == "FALSE" ? rda_vld     : rda_vld_q;

assign  dob_vld     = DO_FFO     == "FALSE" ? rdb_vld_nxt :
                      DO_XTRA_1T == "FALSE" ? rdb_vld     : rdb_vld_q;

always @(posedge clka or negedge arst_n) begin
   if (~arst_n) begin
      mem_rda       <= 0;
      mem_rda_q     <= 0;
      rda_vld       <= 0;
      rda_vld_q     <= 0;
   end
   else begin
      mem_rda       <= mem_rda_nxt;
      mem_rda_q     <= mem_rda;
      rda_vld       <= rda_vld_nxt;
      rda_vld_q     <= rda_vld;
   end
end

always @(posedge clkb or negedge brst_n) begin
   if (~brst_n) begin
      mem_rdb       <= 0;
      mem_rdb_q     <= 0;
      rdb_vld       <= 0;
      rdb_vld_q     <= 0;
   end
   else begin
      mem_rdb       <= mem_rdb_nxt;
      mem_rdb_q     <= mem_rdb;
      rdb_vld       <= rdb_vld_nxt;
      rdb_vld_q     <= rdb_vld;
   end
end


endmodule
