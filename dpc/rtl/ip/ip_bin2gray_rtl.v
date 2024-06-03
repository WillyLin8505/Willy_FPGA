// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2012
//
// File Name:           ip_bin2gray_rtl.v
// Author:              Humphrey Lin
// Version:             $Revision$
// Last Modified On:    $Date$
// Last Modified By:    $Author$
//
// File Description:    Binary code to Gray code Conversion
//
// Abbreviations:
//
// Parameters: DWID = Data Width
//
// Clock Domain:
// -FHDR -----------------------------------------------------------------------

module ip_bin2gray(
                // output
                gray,

                // input
                bin
                );

//----------------------------------------------//
// Define Parameter                             //
//----------------------------------------------//

parameter       DWID  = 1;

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output[DWID-1:0] gray;                          // gray code output

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input [DWID-1:0] bin;	                        // binary code input

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

genvar i;

assign gray[DWID-1] = bin[DWID-1];

generate
   for (i = 0; i < DWID-1; i = i+1) begin: bin2gray
      assign gray[i] = bin[i] ^ bin[i+1];
   end
endgenerate

endmodule
