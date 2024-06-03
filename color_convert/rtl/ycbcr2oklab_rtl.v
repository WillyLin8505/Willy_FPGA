// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_ycbcr2oklab.v
// Author:              willylin
// Version:             $Revision$
// Last Modified On:    2022/10/25
// Last Modified By:    $Author$
//
// File Description:    ycbcr convert to oklab
// Abbreviations:
// Data precision :     input  : Y    :   8.4
//                               CBCR : S 7.4
//                      outupt : L    :   0.15
//                               AB   : S 0.13
//
// -FHDR -----------------------------------------------------------------------

module ycbcr2oklab 
    #(
    parameter           CIIW_YL                 = 8,
    parameter           CIPW_YL                 = 4,
    parameter           COIW_YL                 = 8,
    parameter           COPW_YL                 = 4,
    parameter           CIW_YL                  = CIIW_YL + CIPW_YL,
    parameter           YCBCR_POS               = 0,
    
    parameter           CIIW_LK                 = 8,
    parameter           CIPW_LK                 = 4,
    parameter           COIW_L_LK               = 0,
    parameter           COPW_L_LK               = 15,
    parameter           COIW_AB_LK              = 0,
    parameter           COPW_AB_LK              = 13,
    parameter           COW_L_LK                = COIW_L_LK + COPW_L_LK,
    parameter           COW_AB_LK               = COIW_AB_LK + COPW_AB_LK

    )
(

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg         [COW_L_LK-1:0]  o_data_l,
output reg signed  [COW_AB_LK-1:0] o_data_a_sgn,
output reg signed  [COW_AB_LK-1:0] o_data_b_sgn,
output                             o_hstr,
output                             o_hend,
output                             o_href,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input              [CIW_YL-1:0]    i_data_y,
input signed       [CIW_YL  :0]    i_data_cb_sgn,
input signed       [CIW_YL  :0]    i_data_cr_sgn,
input                              i_hstr,
input                              i_hend,
input                              i_href,
input                              clk,
input                              rst_n
);

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
wire  [COIW_YL +COPW_YL -1:0]      data_y2l;                 
wire  [COIW_YL +COPW_YL -1:0]      data_y2m;                    
wire  [COIW_YL +COPW_YL -1:0]      data_y2s;                  
wire                               hstr_y2l;
wire                               hend_y2l;
wire                               href_y2l;

//================================================================================
//  module instantiation
//==============================================================================


ip_ycbcr2lms#(
    .CIIW           ( CIIW_YL ),
    .CIPW           ( CIPW_YL ),
    .COIW           ( COIW_YL ),
    .COPW           ( COPW_YL ),
    .YCBCR_POS      (YCBCR_POS)
)u_ip_ycbcr2lms(
    .o_data_l       ( data_y2l      ),
    .o_data_m       ( data_y2m      ),
    .o_data_s       ( data_y2s      ),
    .o_hstr         ( hstr_y2l      ),
    .o_hend         ( hend_y2l      ),
    .o_href         ( href_y2l      ),
    
    .i_data_y       ( i_data_y      ), 
    .i_data_cb_sgn  ( i_data_cb_sgn ), 
    .i_data_cr_sgn  ( i_data_cr_sgn ),
    .i_hstr         ( i_hstr      ),
    .i_hend         ( i_hend      ),
    .i_href         ( i_href      ),
    .clk            ( clk      ),
    .rst_n          ( rst_n    )
);

ip_lms2oklab#(
    .CIIW           ( CIIW_LK ),
    .CIPW           ( CIPW_LK ),
    .COIW_L         ( COIW_L_LK ),
    .COPW_L         ( COPW_L_LK ),
    .COIW_AB        ( COIW_AB_LK ),
    .COPW_AB        ( COPW_AB_LK )
)u_ip_lms2oklab(
    .o_data_l       ( o_data_l ),
    .o_data_a_sgn   ( o_data_a_sgn ),
    .o_data_b_sgn   ( o_data_b_sgn ),
    .o_hstr         ( o_hstr   ),
    .o_hend         ( o_hend   ),
    .o_href         ( o_href   ),
    
    .i_data_l       ( data_y2l ),
    .i_data_m       ( data_y2m ),
    .i_data_s       ( data_y2s ),
    .i_hstr         ( hstr_y2l   ),
    .i_hend         ( hend_y2l   ),
    .i_href         ( href_y2l   ),
    .clk            ( clk      ),
    .rst_n          ( rst_n    )
);

endmodule

