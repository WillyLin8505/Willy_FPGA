// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           ip_sync2_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description: Double F.F. sync for cross-clock domain
//
// Abbreviations: ffq = F.F. Q output
//                ffd = F.F. D input
//
// Parameters: DWID: Data Width
//
// Clock Domain: sync_clk
// -FHDR -----------------------------------------------------------------------

module ip_sync2(
                //outpu
                ffq,

                //input
                ffd,
                sync_clk,
                sync_rst_n
                );

//----------------------------------------------//
// Define Parameter                             //
//----------------------------------------------//

parameter       DWID  = 1;

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output[DWID-1:0] ffq;                           // Final F.F. Q output

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input [DWID-1:0] ffd;                           // Final F.F. D input
input sync_clk;                                 // Sync. clock
input sync_rst_n;                               // reset active low for sync_clk domain

//----------------------------------------------//
// Register declaration                         //
//----------------------------------------------//

(* ASYNC_REG = "TRUE" *) reg   [DWID-1:0] ffq;     //
(* ASYNC_REG = "TRUE" *) reg   [DWID-1:0] ffd_meta;// the 1st sync FF output

//----------------------------------------------//
// Define Sequential Logic                      //
//----------------------------------------------//

`ifdef  SYNTHESIS

always @(posedge sync_clk or negedge sync_rst_n) begin: sync2
   if(~sync_rst_n)
      {ffq, ffd_meta} <= {{DWID{1'b0}},{DWID{1'b0}}};
   else
      {ffq, ffd_meta} <= {ffd_meta, ffd};
end

`else
//----------------------------------------------//

reg   [DWID-1:0] rand_num;                      // random number
reg   [DWID-1:0] dly_rand;                      // random delay
reg   [DWID-1:0] ffd_syn;                       // the 2nd sync FF output
reg   [DWID-1:0] dly_ff;                        // F.F. for extra delay
genvar           gen_bit;                       //

always @(ffd)
   rand_num = {$random}%{1'b1,{DWID{1'b0}}};

always @(ffd)
   dly_rand = 0;

generate
   for (gen_bit=0; gen_bit<=DWID-1; gen_bit=gen_bit+1) begin: random_dly
      always @(ffd[gen_bit])                      // only random delay on switching bits
         #0 dly_rand[gen_bit] = rand_num[gen_bit];// #0 to make this process later
   end
endgenerate

always @* begin: bit_dly
integer i;
   for (i=0; i<=DWID-1 ; i=i+1)
      dly_ff[i] = dly_rand[i] ? ffd_syn[i] : ffd_meta[i];
end

always @(posedge sync_clk or negedge sync_rst_n) begin: sync2
   if(~sync_rst_n)
      {ffq, ffd_syn, ffd_meta} <= {{DWID{1'b0}}, {DWID{1'b0}}, {DWID{1'b0}}};
   else
      {ffq, ffd_syn, ffd_meta} <= {dly_ff, ffd_meta, ffd};
end

`endif

endmodule
