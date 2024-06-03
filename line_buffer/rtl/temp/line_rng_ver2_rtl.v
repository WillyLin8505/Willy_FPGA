// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:
// Author:              Willy Lin
// Version:             1.0
// Date:                2022/11/30
// Modified On:
// Modified By:    $Author$
//
// File Description:
//
// -FHDR -----------------------------------------------------------------------


module line_rng_ver2 # 
      (
    parameter DBUF_DW      = 8,
    parameter KRNV_SZ      = 6,                     // vertical kernel size
    parameter ODATA_RNG    = 2                      // output data range
    )
(
    output reg [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0] o_data,
    output reg                                 o_dvld,
    output reg                                 o_vstr,
    output reg                                 o_hstr,
    output reg                                 o_hend,
    output reg                                 o_vend,
    
    input      [DBUF_DW*KRNV_SZ-1:0]           i_data,
    input                                      i_hstr,
    input                                      i_href,
    input                                      i_hend,
    input                                      i_vstr,
    input                                      i_vend,
    input                                      clk,
    input                                      rst_n
);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//
//-------------------------------------------------------------------width
localparam        ODATA_RNG_WTH  = $clog2(ODATA_RNG+1);

//-------------------------------------------------------------------DLY table
localparam        CKICK_DLY      = 1;

//-------------------------------------------------------------------fsm
localparam [2:0]  LINE_RNG_IDLE  = 3'b001;				
localparam [2:0]  LINE_RNG_BUF   = 3'b010;				
localparam [2:0]  LINE_RNG_EN    = 3'b100;				

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
//-------------------------------------------------------------------data stack 
reg  [ODATA_RNG-1:0]                 sel_sft;
wire [ODATA_RNG-1:0]                 sel_sft_nxt;
reg  [DBUF_DW*KRNV_SZ-1:0]           line_lat         [0:ODATA_RNG-1];
wire [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0] line_lat_com;
wire [ODATA_RNG-1:0]                 data_sel         [0:ODATA_RNG-1];
wire [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0] data_sel_en      [0:ODATA_RNG-1];
wire [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0] data_seg         [0:ODATA_RNG-1];
wire [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0] seg_com          [0:ODATA_RNG-1];
wire [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0] data_stack;
reg  [DBUF_DW*KRNV_SZ-1:0]           i_data_que;

//-------------------------------------------------------------------equal part 
wire                                 line_cnt_buf_eq;

//-------------------------------------------------------------------counter 
reg  [ODATA_RNG_WTH-1:0]             line_cnt;
wire [ODATA_RNG_WTH-1:0]             line_cnt_nxt;
wire                                 line_cnt_inc;
wire                                 line_cnt_clr;

//-------------------------------------------------------------------output part
reg  [ODATA_RNG-1:0]                 i_vstr_que;
wire [ODATA_RNG-1:0]                 i_vstr_que_nxt;

reg  [ODATA_RNG-1:0]                 i_vend_que;
wire [ODATA_RNG-1:0]                 i_vend_que_nxt;

reg  [ODATA_RNG-1:0]                           i_hend_que;
wire [ODATA_RNG-1:0]                           i_hend_que_nxt;
reg  [ODATA_RNG-1:0]                           i_href_que;
wire [ODATA_RNG-1:0]                           i_href_que_nxt;

wire [DBUF_DW*ODATA_RNG*KRNV_SZ-1:0] o_data_nxt;
wire                                 o_dvld_nxt;
wire                                 o_vstr_nxt;
wire                                 o_hstr_nxt;
wire                                 o_hend_nxt;
wire                                 o_vend_nxt;

//-------------------------------------------------------------------fsm
wire                                 line_rng_buf_smo;
wire                                 line_rng_en_smo;
wire                                 line_rng_idle_smo;

reg [2:0]                            line_rng_cs;
reg [2:0]                            line_rng_ns;

//-------------------------------------------------------------------ckicg
wire                                 clk_gt         [0:ODATA_RNG-1];

//-------------------------------------------------------------------genvar
genvar                               gmi,gmi_2;
integer                              rst_i;

wire [KRNV_SZ*DBUF_DW*ODATA_RNG-1:0] rng_data_nxt;
reg [KRNV_SZ*DBUF_DW*ODATA_RNG-1:0] rng_data;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
assign rng_data_nxt      = i_href ? {rng_data[KRNV_SZ*DBUF_DW*(ODATA_RNG-1)-1:0],i_data} : rng_data;  

//-------------------------------------------------------------------equal part 
assign line_cnt_buf_eq     = (line_cnt == ODATA_RNG-1) & line_cnt_inc;

//-------------------------------------------------------------------counter 
assign line_cnt_nxt        = (line_cnt_inc ? line_cnt + 1'b1 : line_cnt) & {(ODATA_RNG_WTH){~line_cnt_clr}};
assign line_cnt_inc        = line_rng_buf_smo & i_href;
assign line_cnt_clr        = line_cnt_buf_eq;

//-------------------------------------------------------------------output part  
assign i_vstr_que_nxt      = {i_vstr_que[0],i_vstr};
assign i_vend_que_nxt      = {i_vend_que[0],i_vend};
assign i_href_que_nxt      = {i_href_que[0],i_href};
assign i_hend_que_nxt      = {i_hend_que[0],i_hend};

assign o_data_nxt          = rng_data;
assign o_dvld_nxt          = line_rng_en_smo & i_href_que[1];
assign o_vstr_nxt          = i_vstr_que[1];
assign o_hstr_nxt          = line_cnt_buf_eq;
assign o_hend_nxt          = i_hend_que[1];
assign o_vend_nxt          = i_vend_que[1];

//-------------------------------------------------------------------fsm
assign  line_rng_buf_smo   = line_rng_cs[1];
assign  line_rng_en_smo    = line_rng_cs[2];
assign  line_rng_idle_smo  = line_rng_cs[0];

always@* begin : buffer_ver_fsm

line_rng_ns = line_rng_cs;

case (line_rng_cs)

  LINE_RNG_IDLE   : begin
                        if (i_hstr)
                          line_rng_ns = LINE_RNG_BUF;
                      end

  LINE_RNG_BUF  :   begin
                        if (line_cnt_buf_eq)
                          line_rng_ns = LINE_RNG_EN;
                      end

  LINE_RNG_EN  :    begin
                        if(i_hend_que[1])
                          line_rng_ns = LINE_RNG_IDLE;
                      end
endcase
end

    
    
//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//

//----------------------------------------------//
// non - blocking                               //
//----------------------------------------------//

always@(posedge clk or negedge rst_n) begin
if (!rst_n) begin
//-------------------------------------------------------------------data stack 
  sel_sft     <= 0;
//  i_data_que  <= 0;
//-------------------------------------------------------------------counter 
  line_cnt    <= 0;
//-------------------------------------------------------------------output part
  i_vstr_que  <= 0;
  i_vend_que  <= 0;
  i_hend_que  <= 0;
  i_href_que  <= 0;
  o_data      <= 0;
  o_dvld      <= 0;
  o_vstr      <= 0;
  o_hstr      <= 0;
  o_hend      <= 0;
  o_vend      <= 0;
  
end
else begin
//-------------------------------------------------------------------data stack 
  sel_sft     <= sel_sft_nxt;
//  i_data_que  <= i_data;
//-------------------------------------------------------------------counter 
  line_cnt    <= line_cnt_nxt;
//-------------------------------------------------------------------output part
  i_vstr_que  <= i_vstr_que_nxt;
  i_vend_que  <= i_vend_que_nxt;
  i_hend_que  <= i_hend_que_nxt;
  i_href_que  <= i_href_que_nxt;
  o_data      <= o_data_nxt;
  o_dvld      <= o_dvld_nxt;
  o_vstr      <= o_vstr_nxt;
  o_hstr      <= o_hstr_nxt;
  o_hend      <= o_hend_nxt;
  o_vend      <= o_vend_nxt;
  
end
end

always@(posedge clk or negedge rst_n) begin
if (!rst_n) begin
  rng_data <= 0;
end
else begin
  rng_data <= rng_data_nxt;
end
end

always@(posedge clk or negedge rst_n) begin
if (!rst_n) begin
  line_rng_cs <= LINE_RNG_IDLE;
end
else begin
  line_rng_cs <= line_rng_ns;
end
end

endmodule

