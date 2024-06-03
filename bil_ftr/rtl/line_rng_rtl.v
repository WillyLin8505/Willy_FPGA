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
// limitation : 
// ODATA_RNG min number is 2 
//
// File Description:
//
// -FHDR -----------------------------------------------------------------------


module line_rng # 
      (
    parameter DBUF_DW      = 8,
    parameter KRNV_SZ      = 6,                     // vertical kernel size
    parameter ODATA_RNG    = 2                      // output data range

    )
(
    output   [DBUF_DW*KRNV_SZ*ODATA_RNG-1:0] o_data,
    output                                   o_dvld,
    output                                   o_vstr,
    output                                   o_hstr,
    output                                   o_hend,
    output                                   o_vend,
    
    input      [DBUF_DW*KRNV_SZ-1:0]         i_data,
    input                                    i_hstr,
    input                                    i_href,
    input                                    i_hend,
    input                                    i_vstr,
    input                                    i_vend,
    input                                    clk,
    input                                    rst_n
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
reg  [DBUF_DW*KRNV_SZ-1:0]           i_data_dly;

//-------------------------------------------------------------------equal part 
wire                                 line_cnt_buf_eq;

//-------------------------------------------------------------------counter 
reg  [ODATA_RNG_WTH-1:0]             line_cnt;
wire [ODATA_RNG_WTH-1:0]             line_cnt_nxt;
wire                                 line_cnt_inc;
wire                                 line_cnt_clr;

wire [ODATA_RNG-1:0]                 ckicg_we;

//-------------------------------------------------------------------output part
reg  [ODATA_RNG-1:0]                 i_vstr_dly;

reg  [ODATA_RNG-1:0]                 i_vend_dly;

reg  i_href_dly ;
reg  i_hend_dly ;
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

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//-------------------------------------------------------------------control part 
assign sel_sft_nxt         = line_rng_idle_smo ? {1'b1,{ODATA_RNG-1{1'b0}}} : i_href ? {sel_sft[ODATA_RNG-2:0],sel_sft[ODATA_RNG-1]} : sel_sft;
assign ckicg_we            = {ODATA_RNG{i_href}} & sel_sft;
assign data_sel[0]         = sel_sft;

generate 
  for (gmi = 0;gmi<ODATA_RNG-1;gmi = gmi+1) begin : gen_data_sel
    assign data_sel[gmi+1] = {sel_sft[ODATA_RNG-2-gmi:0],sel_sft[ODATA_RNG-1:ODATA_RNG-1-gmi]};
  end
endgenerate

generate 
  for (gmi = 0;gmi<ODATA_RNG;gmi = gmi+1) begin : gen_data_sel_en_0
    for (gmi_2 = 0;gmi_2<ODATA_RNG;gmi_2 = gmi_2+1) begin : gen_data_sel_en_1
      assign data_sel_en[gmi][DBUF_DW*KRNV_SZ*(gmi_2+1)-1:DBUF_DW*KRNV_SZ*gmi_2] = {DBUF_DW*KRNV_SZ{data_sel[gmi][gmi_2]}}; //extension enable 
    end
  end
endgenerate

//-------------------------------------------------------------------data
    
generate 
  for (gmi = 0;gmi<ODATA_RNG;gmi = gmi+1) begin : gen_lat            //data latch 
    always@(clk_gt[gmi] or i_data_dly) begin
      if(clk_gt[gmi])
        line_lat[gmi] = i_data_dly;                                     
    end
  end
endgenerate

generate 
  for (gmi = 0;gmi<ODATA_RNG;gmi = gmi+1) begin : gen_line_lat_com   //combine latch into bus 
    assign line_lat_com[DBUF_DW*KRNV_SZ*(gmi+1)-1:DBUF_DW*KRNV_SZ*gmi] = line_lat[gmi];
  end
endgenerate


generate 
  for (gmi = 0;gmi<ODATA_RNG;gmi = gmi+1) begin : gen_data_seg_0     //select data
      assign data_seg[gmi] = (data_sel_en[gmi] & line_lat_com);
  end
endgenerate

generate 
  for (gmi = 0;gmi<ODATA_RNG;gmi = gmi+1) begin : gen_seg_com_0      //combine segment 
  
    assign seg_com[gmi][DBUF_DW*KRNV_SZ-1:0] = data_seg[gmi][DBUF_DW*KRNV_SZ-1:0];
                                                                                                
      for (gmi_2 = 0;gmi_2<ODATA_RNG-1;gmi_2 = gmi_2+1) begin : gen_seg_com_1
        assign seg_com[gmi][DBUF_DW*KRNV_SZ*(gmi_2+2)-1:DBUF_DW*KRNV_SZ*(gmi_2+1)] = data_seg[gmi][DBUF_DW*KRNV_SZ*(gmi_2+2)-1:DBUF_DW*KRNV_SZ*(gmi_2+1)] | 
                                                                                     seg_com[gmi][DBUF_DW*KRNV_SZ*(gmi_2+1)-1:DBUF_DW*KRNV_SZ*gmi_2];
    end
  end
endgenerate

generate 
  for (gmi = 0;gmi<ODATA_RNG;gmi = gmi+1) begin : gen_data_stack     //stack data as output data
      assign data_stack[DBUF_DW*KRNV_SZ*(ODATA_RNG-gmi)-1:DBUF_DW*KRNV_SZ*(ODATA_RNG-gmi-1)] = seg_com[gmi][DBUF_DW*KRNV_SZ*(ODATA_RNG)-1:DBUF_DW*KRNV_SZ*(ODATA_RNG-1)];
  end
endgenerate

//-------------------------------------------------------------------equal part 
assign line_cnt_buf_eq     = (line_cnt == (ODATA_RNG-1)) & line_cnt_inc;

//-------------------------------------------------------------------counter 
assign line_cnt_nxt        = (line_cnt_inc ? line_cnt + 1'b1 : line_cnt) & {(ODATA_RNG_WTH){~line_cnt_clr}};
assign line_cnt_inc        = line_rng_buf_smo & i_href;
assign line_cnt_clr        = line_cnt_buf_eq;

//-------------------------------------------------------------------output part  
assign o_data              = data_stack & {DBUF_DW*KRNV_SZ*ODATA_RNG{line_rng_en_smo}};
assign o_dvld              = i_href_dly & !line_rng_buf_smo;
assign o_vstr              = i_vstr_dly;
assign o_hstr              = line_cnt_buf_eq;
assign o_hend              = i_hend_dly;
assign o_vend              = i_vend_dly;

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
                        if(i_hend_dly)
                          line_rng_ns = LINE_RNG_IDLE;
                      end
endcase
end

    
    
//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//
  

generate
  for (gmi = 0;gmi<ODATA_RNG;gmi = gmi+1) begin : gen_ckicg
  CKICG
  CKICG(
    .TE(1'b0),
    .E(ckicg_we[gmi]),
    .CK(clk),
    .Q(clk_gt[gmi])
);
  end
endgenerate

//----------------------------------------------//
// non - blocking                               //
//----------------------------------------------//

always@(posedge clk or negedge rst_n) begin
if (!rst_n) begin
//-------------------------------------------------------------------data stack 
  sel_sft     <= 0;
  i_data_dly  <= 0;
  
//-------------------------------------------------------------------counter 
  line_cnt    <= 0;
  
//-------------------------------------------------------------------output part
  i_vstr_dly  <= 0;
  i_vend_dly  <= 0;
  i_href_dly  <= 0;
  i_hend_dly  <= 0;
  
end
else begin
//-------------------------------------------------------------------data stack 
  sel_sft     <= sel_sft_nxt;
  i_data_dly  <= i_data;
  
//-------------------------------------------------------------------counter 
  line_cnt    <= line_cnt_nxt;
  
//-------------------------------------------------------------------output part
  i_vstr_dly  <= i_vstr;
  i_vend_dly  <= i_vend;
  i_href_dly  <= i_href;
  i_hend_dly  <= i_hend;
  
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

