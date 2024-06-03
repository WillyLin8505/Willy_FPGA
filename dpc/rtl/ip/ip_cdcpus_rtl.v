// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2015
//
// File Name:           ip_cdcpus_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description: Clock domain crossing pulse generaator
//                   Relation between input/output can be
//                   IN_TYPE = "PULSE"
//                   input : high pulse signal on clki domain
//                   output: high pulse signal with one clko width
//                   IN_TYPE = "LEVEL"
//                   input : high active signal with width > clko
//                   output: rising- or falling-edge input on clko domain
//
// Clock Domain: from clki to clko
// -FHDR -----------------------------------------------------------------------

module ip_cdcpus

    #(
      parameter         IN_TYPE       = "PULSE",// "PULSE": high pulse signal
                                                // "LEVEL": high active signal with longer with > clko
      parameter         SAMPLE_EDGE   = "RISE"  // Only available on "LEVEL" input type
                                                // "RISE": rising-edge pulse of input
                                                // "FALL": falling-edge pulse of input
                                                // "BOTH": on both rising and falling pulse
     )
(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg              pus_ckosyn,             // pulse output

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input                   in_cki,                 // input signal
input                   clki,                   // input clock domain
input                   clko,                   // output clock domain
input                   irst_n,                 // low active reset on input clk domain
input                   orst_n                  // low active reset on output clk domain
);

//----------------------------------------------//
// Register declaration                         //
//----------------------------------------------//

reg                     ref_toggle;             // an in_cki toggled reference signal
reg                     in_cki_q1;              //
reg                     in_proc_ckosyn_q1;      //

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//

wire                    in_proc;                // input signal for processing
wire                    in_proc_ckosyn;         // in_proc sync by clko domain

wire                    ref_toggle_nxt;
wire                    pus_ckosyn_nxt;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

generate

if (IN_TYPE == "PULSE") begin: gen_pulse_in

assign  ref_toggle_nxt = in_cki & ~in_cki_q1 ? ~ref_toggle : ref_toggle;

assign  in_proc = ref_toggle;

assign  pus_ckosyn_nxt = in_proc_ckosyn ^ in_proc_ckosyn_q1;
end
else if ((IN_TYPE == "LEVEL") && (SAMPLE_EDGE == "RISE")) begin: gen_level_rise

assign  in_proc = in_cki;

assign  pus_ckosyn_nxt =  in_proc_ckosyn & ~in_proc_ckosyn_q1;

end
else if ((IN_TYPE == "LEVEL") && (SAMPLE_EDGE == "FALL")) begin: gen_level_fall

assign  in_proc = in_cki;

assign  pus_ckosyn_nxt = ~in_proc_ckosyn &  in_proc_ckosyn_q1;

end
else if ((IN_TYPE == "LEVEL") && (SAMPLE_EDGE == "BOTH")) begin: gen_level_both

assign  in_proc = in_cki;

assign  pus_ckosyn_nxt = in_proc_ckosyn ^ in_proc_ckosyn_q1;

end

endgenerate

// ---------- Sequential Logic -----------------//

always @(posedge clki or negedge irst_n) begin
   if (~irst_n) begin
      ref_toggle        <= 0;
      in_cki_q1         <= 0;
   end
   else begin
      ref_toggle        <= ref_toggle_nxt;
      in_cki_q1         <= in_cki;
   end
end

always @(posedge clko or negedge orst_n) begin
   if (~orst_n) begin
      pus_ckosyn        <= 0;
      in_proc_ckosyn_q1 <= 0;
   end
   else begin
      pus_ckosyn        <= pus_ckosyn_nxt;
      in_proc_ckosyn_q1 <= in_proc_ckosyn;
   end
end

// ----------- Module Instance -----------------//

ip_sync2 #(.DWID(1)) sync2_in_proc(
        //outpu
        .ffq            (in_proc_ckosyn),
        //input
        .ffd            (in_proc),
        .sync_clk       (clko),
        .sync_rst_n     (orst_n)
        );

endmodule
