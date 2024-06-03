// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           ram_1p_rtl.v
// Author:              Humphrey Lin
//
// File Description:    Single-port SRAM wrapper
// -FHDR -----------------------------------------------------------------------

module ram_1p

#(
parameter                       RAM_NAME        = "",           // name of RAM
parameter                       RAM_DEP         = 0,            // SRAM depth
parameter                       RAM_DW          = 0,            // SRAM data width
parameter                       RAM_WWWD        = 1,            // SRAM word write width
parameter                       MBIST           = "FALSE",
`ifdef SRAM_TIMING_SIM
parameter real                  TDELAY          = 1.5,
`else
parameter                       TDELAY          = 0,
`endif
//
parameter                       RAM_AW          = $clog2(RAM_DEP)// SRAM addr width
 )

(
//----------------------------------------------------------//
// Output declaration                                       //
//----------------------------------------------------------//

output[RAM_DW-1:0]              rmdo,                       // memory read data
output                          mbist_done,
output                          mbist_err,

//----------------------------------------------------------//
// Input declaration                                        //
//----------------------------------------------------------//

input [RAM_WWWD-1:0]            we,                         // write enable, high active
input                           ce,                         // chip enable, high active
input [RAM_AW-1:0]              addr,                       // Write/Read address
input [RAM_DW-1:0]              wmdi,                       // memory write data

input [ 7:0]                    mopt,                       // option/margin setting
input                           mbist_en,                   // MBIST enable
input                           clk,                        // write clock
input                           rst_n
);

//----------------------------------------------------------//
// Local Parameter                                          //
//----------------------------------------------------------//

//----------------------------------------------------------//
// REG/Wire declaration                                     //
//----------------------------------------------------------//

wire  [RAM_AW-1:0]              spram_addr;
wire                            spram_ce_n;
wire  [RAM_WWWD-1:0]            spram_we_n;
wire  [RAM_DW-1:0]              spram_wd;

wire                            mbist_we;                   // MBIST write enable
wire  [RAM_AW-1:0]              mbist_addr;                 // MBIST address
wire  [RAM_DW-1:0]              mbist_data_o;               // MBIST data output
wire  [ 2:0]                    mbist_step;                 // MBIST test step
wire  [RAM_DW-1:0]              mbist_err_bit;              // MBIST error bit
wire  [RAM_AW-1:0]              mbist_err_addr;             // MBIST error located address

//----------------------------------------------------------//
// Code Descriptions                                        //
//----------------------------------------------------------//

// ~~ SPRAM control
assign  #TDELAY spram_addr = mbist_en ? mbist_addr : addr;

assign  #TDELAY spram_ce_n = ~(ce | mbist_en);
assign  #TDELAY spram_we_n = ~(we | {RAM_WWWD{mbist_we}});

assign  #TDELAY spram_wd   = mbist_en ? mbist_data_o : wmdi;


generate

if (MBIST == "TRUE") begin: gen_mbist

mbist_top
#(
            .AW                 (RAM_AW),
            .DW                 (RAM_DW),
            .DEPTH              (RAM_DEP))

            mbist_top(
            // output
            .sram_we_o          (mbist_we),
            .sram_addr_o        (mbist_addr),
            .sram_data_o        (mbist_data_o),
            .bist_busy_o        (),
            .bist_done_o        (mbist_done),
            .sram_err_o         (mbist_err),
            .sram_err_addr_o    (mbist_err_addr),
            .sram_err_bit_o     (mbist_err_bit),
            .bist_step_o        (mbist_step),

            // input
            .mbist_en_i         (mbist_en),
            .sram_data_i        (rmdo),

            // clk
            .clk                (clk),
            .rst_n              (rst_n));

end
else begin: gen_byp

assign  mbist_we       = 0;
assign  mbist_addr     = 0;
assign  mbist_data_o   = 0;
assign  mbist_done     = 0;
assign  mbist_err      = 0;
assign  mbist_err_addr = 0;
assign  mbist_err_bit  = 0;
assign  mbist_step     = 0;

end

endgenerate

generate

case (RAM_NAME)

   "GM_SRAM_242X80_1p2T90_B01": begin: gen_gm_sram_sp242x80
      GM_SRAM_242X80_1p2T90_B01 sram_sp242x80
      (
      .DO   (rmdo),
      .AD   (spram_addr),
      .DI   (spram_wd),
      .CEB  (spram_ce_n),
      .WEB  (spram_we_n),
      .OEB  (1'b0),
      .CLK  (clk));
   end

   "GM_SRAM_482X120_1p2T90_B01": begin: gen_gm_sram_sp482x120
      GM_SRAM_482X120_1p2T90_B01 sram_sp482x120
      (
      .DO   (rmdo),
      .AD   (spram_addr),
      .DI   (spram_wd),
      .CEB  (spram_ce_n),
      .WEB  (spram_we_n),
      .OEB  (1'b0),
      .CLK  (clk));
   end

   "asic_sram_sp242x80": begin: gen_sram_sp242x80
      asic_sram_sp242x80 sram_sp242x80
      (
      .Q    (rmdo),
      .A    (addr),
      .D    (wmdi),
      .CEN  (spram_ce_n),
      .WEN  (spram_we_n),
      .MSE  (mopt[0]),
      .MS   (mopt[4:1]),
      .CLK  (clk));
   end

   "M31HDSP100PL040P_488X1X80CM4": begin: gen_sram_sp488x80
      M31HDSP100PL040P_488X1X80CM4 sram_sp488x80
      (
      .Q    (rmdo),
      .A    (addr),
      .D    (wmdi),
      .CEN  (spram_ce_n),
      .WEN  (spram_we_n),
      .MSE  (mopt[0]),
      .MS   (mopt[4:1]),
      .CLK  (clk));
   end

   "asic_sram_sp240x160": begin: gen_sram_sp240x160
      asic_sram_sp240x160 asic_sram_sp240x160
      (
      .Q    (rmdo), //read data
      .A    (addr), //address
      .D    (wmdi), //write data
      .CEN  (spram_ce_n),
      .WEN  (spram_we_n), //write enable
      .MSE  (1'b0), //mopt[0]
      .MS   (mopt[4:1]),
      .CLK  (clk));

   end


endcase

endgenerate

endmodule
