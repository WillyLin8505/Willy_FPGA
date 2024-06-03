// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           mbist_top_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description:    MBIST top module
// Abbreviations:

// Parameters:
//
// -FHDR -----------------------------------------------------------------------

module  mbist_top(

    // Output
        sram_we_o,
        sram_addr_o,
        sram_data_o,
        bist_busy_o,
        bist_done_o,
        sram_err_o,
        sram_err_addr_o,
        sram_err_bit_o,
        bist_step_o,

    // Input
        mbist_en_i,
        sram_data_i,
        clk,
        rst_n
        );

parameter           AW = 10;
parameter           DW = 40;
parameter           DEPTH = 0;

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output              sram_we_o;
output[AW-1:0]      sram_addr_o;
output[DW-1:0]      sram_data_o;
output              bist_busy_o;
output              bist_done_o;
output              sram_err_o;
output[AW-1:0]      sram_err_addr_o;
output[DW-1:0]      sram_err_bit_o;
output[2:0]         bist_step_o;

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input               mbist_en_i;
input [DW-1:0]      sram_data_i;
input               clk;
input               rst_n;

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//

wire    [AW-1:0]    golden_addr;
wire    [DW-1:0]    golden_data;
wire                cmp_err;
wire                sram_err_o;
wire                err_flg;

assign              err_flg = cmp_err | sram_err_o;

mbist_gen #(.DW(DW),.AW(AW),.DEPTH(DEPTH)) mbist_gen(

    // Output
        .sram_we_o      (sram_we_o),
        .sram_addr_o    (sram_addr_o),
        .sram_data_o    (sram_data_o),
        .golden_addr_o  (golden_addr),
        .golden_data_o  (golden_data),
        .test_start_o   (test_start),
        .test_busy_o    (bist_busy_o),
        .test_finish_o  (test_finish_o),
        .test_done_o    (bist_done_o),
        .test_byte_o    (bist_byte_o),
        .bist_step_o    (bist_step_o),

    // Input
        .mbist_en_i     (mbist_en_i),
        .cmp_err_i      (err_flg),
        .rst_n          (rst_n),
        .clk            (clk)
        );

mbist_cmp #(.DW(DW),.AW(AW),.DEPTH(DEPTH)) bist_cmp(

    // Output
        .err_addr_o     (sram_err_addr_o),
        .err_bit_o      (sram_err_bit_o),
        .mem_err_tmp_o  (cmp_err),
        .mem_err_o      (sram_err_o),

    // Input
        .test_start_i   (test_start),
        .test_busy_i    (bist_busy_o),
        .test_finish_i  (test_finish_o),
        .test_byte_i    (bist_byte_o),
        .mem_we_i       (sram_we_o),
        .mem_addr_i     (golden_addr),
        .mem_data_i     (sram_data_i),
        .golden_data_i  (golden_data),
        .rst_n          (rst_n),
        .clk            (clk)
        );

endmodule

