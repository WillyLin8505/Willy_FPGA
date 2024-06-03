// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           mbist_cmp_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description:    MBIST read back result comparator
// Abbreviations:

// Parameters:
//
// -FHDR -----------------------------------------------------------------------


module  mbist_cmp(

            // Output
                err_addr_o,
                err_bit_o,
                mem_err_tmp_o,
                mem_err_o,

            // Input
                test_start_i,
                test_busy_i,
                test_finish_i,
                test_byte_i,
                mem_we_i,
                mem_addr_i,
                mem_data_i,
                golden_data_i,
                rst_n,
                clk
            );

parameter           DW    = 10;
parameter           AW    = 8;
parameter           DEPTH = 0;

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output[AW-1:0]      err_addr_o;
output[DW-1:0]      err_bit_o;
output              mem_err_tmp_o;
output              mem_err_o;

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input               test_start_i;
input               test_busy_i;
input               test_finish_i;
input               test_byte_i;
input               mem_we_i;
input [AW-1:0]      mem_addr_i;
input [DW-1:0]      mem_data_i;
input [DW-1:0]      golden_data_i;
input               rst_n;
input               clk;

//----------------------------------------------//
// Register declaration                         //
//----------------------------------------------//

reg                 mem_err_o;
reg   [AW-1:0]      err_addr_o;
reg   [DW-1:0]      err_bit_o;
reg                 check_flag;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//


assign  mem_err_tmp_o = check_flag & (mem_data_i[DW-1:0] != golden_data_i[DW-1:0]) & ~mem_err_o &
                                     (mem_addr_i>= {AW{1'b0}}) & (mem_addr_i<=DEPTH);

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
       check_flag <= 1'b0;
    else
       check_flag <= ~mem_we_i & test_busy_i & ~test_finish_i;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mem_err_o   <= 1'b0;
        err_addr_o  <= 0;
        err_bit_o   <= 0;
    end
    else if (test_start_i) begin
        mem_err_o   <= 1'b0;
        err_addr_o  <= 0;
        err_bit_o   <= 0;
    end
    else if(mem_err_tmp_o) begin
        mem_err_o   <= 1'b1;
        err_addr_o  <= {test_byte_i,mem_addr_i};
        err_bit_o   <= mem_data_i[DW-1:0] ^ golden_data_i[DW-1:0];
    end
end

endmodule
