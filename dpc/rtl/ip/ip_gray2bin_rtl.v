// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           ip_gray2bin_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description:    Gray code to Binary code Conversion
//
// Abbreviations:
//
// Parameters: DWID = Data Width
//
// Clock Domain:
// -FHDR -----------------------------------------------------------------------

module ip_gray2bin(
                // outpu
                bin,

                // input
                gray
                );

//----------------------------------------------//
// Define Parameter                             //
//----------------------------------------------//

parameter       DWID  = 1;

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output[DWID-1:0] bin;                           // binary code output

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input [DWID-1:0] gray;	                        // gray code input

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

genvar i;

generate
   for (i = 0; i < DWID; i = i+1) begin: gray2bin
      assign bin[i] = ^gray[DWID-1:i];
   end
endgenerate

endmodule
