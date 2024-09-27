// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2021
//
// File Name:           s2p_dp.v
// Author:              Willy Lin
// Version:             $Revision$
// Last Modified On:    8/26
// Last Modified By:    $Author$
//
// File Description:   parallel to serial
//                      
// Clock Domain: clk
// -FHDR -----------------------------------------------------------------------

module i2cm_s2p_dp
(

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output  reg  [7:0]  o_data_par,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input               clk,
input               rst_n,
input               i_shift_en,
input               i_data_ser

);

//----------------------------------------------//
// Register & wire declaration                  //
//----------------------------------------------//

wire  [7:0]         o_data_par_nxt;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

assign o_data_par_nxt = i_shift_en ? {o_data_par[6:0],i_data_ser} : o_data_par; 

always@(posedge clk or negedge rst_n) begin
  if(~rst_n)
       o_data_par     <= 8'h00;
  else 
       o_data_par     <= o_data_par_nxt; 
end

endmodule 
