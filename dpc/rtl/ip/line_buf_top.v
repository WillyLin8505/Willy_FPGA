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
    parameter KRNV_SZ      = 5,                     // vertical kernel size
    parameter KRNH_SZ      = 5,                     // horizontial kernel size
    parameter ODATA_RNG    = 5,                     // output data range
    parameter ODATA_FREQ   = 0,                     // output data frequence : 0:every 1 cycle change output data 
                                                    //                         1:every 2 cycle change output data 
                                                    //                         2:every 3 cycle change output data 
                                                    //                         3:every 4 cycle change output data 
    parameter PIXEL_DLY    = 0,
    parameter LINE_DLY     = 0,
    parameter IMG_HSZ      = 1920,
    parameter MEM_TYPE     = "1PSRAM",              // "FPGA_BLKRAM", 1PSRAM
    parameter MEM_NAME     = "asic_sram_sp960x128", // sram name 
    parameter SRAM_NUM     = 2,
    parameter TOP_PAD      = 2,                     // top padding line number 
    parameter BTM_PAD      = 2,                     // bottom padding line number 
    parameter FR_PAD       = 2,                     // front padding number 
    parameter BK_PAD       = 2,                     // back padding number 
    parameter PAD_MODE     = 0,                     // 0:for duplicate padding 
                                                    // 1:RAW padding 
    parameter SRAM_DEP     = IMG_HSZ,
    parameter SRAM_DWTH    = ((KRNV_SZ-1)*2*DBUF_DW)/SRAM_NUM //stack 2 data 
    
    )
(
    output [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0]     o_data,
    output                                     o_dvld,
    output                                     o_vstr,
    output                                     o_hstr,
    output                                     o_hend,
    output                                     o_vend,
        
    input  [DBUF_DW-1:0]                       i_data,
    input                                      i_hstr,
    input                                      i_href,
    input                                      i_hend,
    input                                      i_vstr,
    input  [DBUF_DW-1:0]                       i_wb,
    input                                      i_wb_vld,
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

//================================================================================
//  module instantiation
//================================================================================

line_buf_v2

#( 
      .DBUF_DW             (DBUF_DW )  ,
      .SRAM_DEP            (SRAM_DEP ) ,
      .SRAM_DWTH           (SRAM_DWTH),
      .KRNV_SZ             (KRNV_SZ)  ,
      .KRNH_SZ             (KRNH_SZ) ,
      .ODATA_FREQ          (ODATA_FREQ),
      
      .MEM_TYPE            (MEM_TYPE),
      .MEM_NAME            (MEM_NAME),
      .TOP_PAD             (TOP_PAD),
      .BTM_PAD             (BTM_PAD),
      .FR_PAD              (FR_PAD),
      .BK_PAD              (BK_PAD),
      .PAD_MODE            (PAD_MODE),
      
      .PIXEL_DLY           (PIXEL_DLY),
      .LINE_DLY            (LINE_DLY),
      
      .SRAM_NUM            (SRAM_NUM)

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
      .i_wb                (i_wb),
      .i_wb_vld            (i_wb_vld),

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

