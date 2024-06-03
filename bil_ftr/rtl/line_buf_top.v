// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:
// Author:              Willy Lin
// Version:             1.0
// Date:                2022/11/15
// Modified On:
// Modified By:    $Author$
//
// limitation : 
// 1.top padding cannot over KRNV_SZ-2 (MAX_TOP_PAD)
// 2.ODATA_RNG cannot set to 0 or 1
//
// File Description:
// line buffer top 
//  
// -FHDR -----------------------------------------------------------------------

module line_buf_top # 
    (
    parameter DBUF_DW      = 8,
    parameter DBUF_DEP     = 1920,
    parameter KRNV_SZ      = 7,                     // vertical kernel size
    parameter KRNH_SZ      = 7,                     // horizontial kernel size
    parameter ODATA_RNG    = 6,                     // output data range
    parameter ODATA_FREQ   = 0,                     // output data frequence : 0:every 1 cycle change output data 
                                                    //                         1:every 2 cycle change output data 
                                                    //                         2:every 3 cycle change output data 
                                                    //                         3:every 4 cycle change output data 
    parameter MEM_TYPE     = "1PSRAM",              // "FPGA_BLKRAM", 1PSRAM
    parameter TOP_PAD      = 3,                     // top padding line number 
    parameter BTM_PAD      = 2,                     // bottom padding line number 
    parameter FR_PAD       = 1,                     // front padding number 
    parameter BK_PAD       = 6,                     // back padding number 
    parameter PAD_MODE     = 1                      // 0:for duplicate padding 
                                                    // 1:RAW padding 
    )
(
    output [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0]     o_data,
    output                                     o_dvld,
    output                                     o_vstr,
    output                                     o_hstr,
    output                                     o_hend,
    output                                     o_vend,

    output [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0]     o_data_ver2,
    output                                     o_dvld_ver2,
    output                                     o_vstr_ver2,
    output                                     o_hstr_ver2,
    output                                     o_hend_ver2,
    output                                     o_vend_ver2,
        
    input  [DBUF_DW-1:0]                       i_data,
    input                                      i_hstr,
    input                                      i_href,
    input                                      i_hend,
    input                                      i_vstr,
    input                                      clk,
    input                                      rst_n
);

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
wire [DBUF_DW*ODATA_RNG*KRNV_SZ-1:0] line_rng_data;
wire                                 line_rng_dvld;
wire                                 line_rng_vstr;
wire                                 line_rng_hstr;
wire                                 line_rng_hend;
wire                                 line_rng_vend;

wire [DBUF_DW*ODATA_RNG*KRNV_SZ-1:0] line_rng_ver2_data;
wire                                 line_rng_ver2_dvld;
wire                                 line_rng_ver2_vstr;
wire                                 line_rng_ver2_hstr;
wire                                 line_rng_ver2_hend;
wire                                 line_rng_ver2_vend;

wire [DBUF_DW*KRNV_SZ-1:0]           line_bf_data;
wire                                 line_bf_dvld;
wire                                 line_bf_vstr;
wire                                 line_bf_hstr;
wire                                 line_bf_hend;
wire                                 line_bf_vend;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
assign o_data         = line_rng_data;
assign o_dvld         = line_rng_dvld;
assign o_vstr         = line_rng_vstr;
assign o_hstr         = line_rng_hstr;
assign o_hend         = line_rng_hend;
assign o_vend         = line_rng_vend;

assign o_data_ver2    = line_rng_ver2_data;
assign o_dvld_ver2    = line_rng_ver2_dvld;
assign o_vstr_ver2    = line_rng_ver2_vstr;
assign o_hstr_ver2    = line_rng_ver2_hstr;
assign o_hend_ver2    = line_rng_ver2_hend;
assign o_vend_ver2    = line_rng_ver2_vend;

//================================================================================
//  module instantiation
//================================================================================

line_buf_v2

#( 
      .DBUF_DW             (DBUF_DW )  ,
      .DBUF_DEP            (DBUF_DEP ) ,
      .KRNV_SZ             (KRNV_SZ)  ,
      .KRNH_SZ             (KRNH_SZ) ,
      .ODATA_FREQ          (ODATA_FREQ),
      
      .MEM_TYPE            (MEM_TYPE),
      .TOP_PAD             (TOP_PAD),
      .BTM_PAD             (BTM_PAD),
      .FR_PAD              (FR_PAD),
      .BK_PAD              (BK_PAD),
      .PAD_MODE            (PAD_MODE)

)

line_buf_v2
(

      .o_dvld              (line_bf_dvld),
      .o_vstr              (line_bf_vstr),
      .o_hstr              (line_bf_hstr),
      .o_hend              (line_bf_hend),
      .o_vend              (line_bf_vend),
      .o_data              (line_bf_data),

      .i_data              (i_data),
      .i_href              (i_href),
      .i_hend              (i_hend),
      .i_vstr              (i_vstr),

      .clk                 (clk),
      .rst_n               (rst_n)
);

line_rng 
#(
      .DBUF_DW             (DBUF_DW     ) ,
      .KRNV_SZ             (KRNV_SZ     ) ,  
      .ODATA_RNG           (ODATA_RNG)
)
line_rng
(
      .o_data              (line_rng_data),
      .o_dvld              (line_rng_dvld),
      .o_vstr              (line_rng_vstr),
      .o_hstr              (line_rng_hstr),
      .o_hend              (line_rng_hend),
      .o_vend              (line_rng_vend),

      .i_data              (line_bf_data),
      .i_hstr              (line_bf_hstr),
      .i_href              (line_bf_dvld),
      .i_hend              (line_bf_hend),
      .i_vstr              (line_bf_vstr),
      .i_vend              (line_bf_vend),
      .clk                 (clk),
      .rst_n               (rst_n)
);

endmodule

