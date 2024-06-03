// ------------------------------------------------------------------------------//
// (C) Copyright. 2015
// SILICON OPTRONICS INC. ALL RIGHTS RESERVED
//
// This design is confidential and proprietary owned by Silicon Optronics Inc.
// Any distribution and modification must be authorized by a licensing agreement
// ------------------------------------------------------------------------------//
// filename    : img_tpat_rtl.v
// author      : Humphrey Lin
//
// description : 1. Testing color pattern generator & mask for Bayer raw data
//               2. Combinational logic output
//
//               [0] = 0: Disable test pattern
//               [0] = 1: Enable test pattern
//               [1] = 0: R = 0
//               [1] = 1: R = 255
//               [2] = 0: G = 0
//               [2] = 1: G = 255
//               [3] = 0: B = 0
//               [3] = 1: B = 255
//               [5:4] = 2'b00: All pure color
//               [5:4] = 2'b01: Coordinate RGB
//               [5:4] = 2'b10: Horizontal color bar
//               [5:4] = 2'b11: Vertical color bar
//
// ------------------------------------------------------------------------------//
// Parameters :  CNT_SZ: input counter size to determine the color bar width
//               CNT_SZ+3 should be <= PX_SZ
//
// ------------------------------------------------------------------------------//

module img_tpat

#(// user config.
  parameter PX_RATE     = 1,                                // currently only support PX_RATE = 1
  parameter PX_SZ       = 10,                               // data bus bit-width depend on top module
                          
  parameter TPAT_ID     = 0,                                //

  // local derived
  parameter PX_DWID     = PX_SZ * PX_RATE,                  //
  
  // local config.
  parameter TPAT_RAW_SZ = 10,                               // test patent generated RAW data bit-width

  parameter LCNT_SZ     = 5,                                // 
  parameter PCNT_SZ     = 8)                                //

(
//================================================================================
//  I/O declaratioin
//================================================================================

// output
output      [PX_DWID-1:0]     data_o,                 // Raw data output with testing pattern mask

output                        tpat_en,                // output test pattern instant enable flag for upper reference

// input
input                         vstr_i,                 // Vertical frame start
input                         hstr_i,                 // Horizontal line start
input                         hend_i,                 // Horizontal line end

input       [PX_DWID-1:0]     data_i,                 // Original raw data

input       [LCNT_SZ-1:0]     tpat_vcnt,              // Vertical counter
input       [LCNT_SZ-1:0]     tpat_hcnt,              // Horizontal counter

// reg
input       [1:0]             reg_tpat_sel,           // Test pattern number select
input       [5:0]             reg_tpat_ctrl,          // Test pattern control reg

// clk
input                         clk,                    // clock
input                         rst_n                   // active low reset
);

//================================================================================
//  parameter
//================================================================================

//================================================================================
//  Internal wire declaration
//================================================================================
wire                          r_vld;                  // R cell valid
wire                          g_vld;                  // G cell valid
wire                          b_vld;                  // B cell valid

wire  [4:0]                   cbar_lsb_cnt;           // Color bar LSB counter. 32 lines/32 pixels per bar

wire                          bar_msb_cnt_inc;        // Color bar MSB counter increment
wire                          axis_cnt_inc;           // coordinate RGB counter increment

wire                          tpat_r_sel;             // test pattern R color select
wire                          tpat_g_sel;             // test pattern G color select
wire                          tpat_b_sel;             // test pattern B color select

//wire                          tpat_pure_sel;          // test pattern pure color select
wire                          tpat_axis_sel;          // test pattern coordinate RGB select
wire                          tpat_cbar_sel;          // test pattern color bar select
wire                          tpat_vbar_sel;          // test pattern Vertical color bar select
wire                          tpat_hbar_sel;          // test pattern Horizontal color bar select

wire                          dat_vld;                // data valid

wire  [PX_SZ-1:0]             mask_raw_r;             // R data with testing pattern mask
wire  [PX_SZ-1:0]             mask_raw_g;             // G data with testing pattern mask
wire  [PX_SZ-1:0]             mask_raw_b;             // B data with testing pattern mask

reg   [PCNT_SZ-1:0]           tpat_cnt;               // Test pattern counter
wire  [PCNT_SZ-1:0]           tpat_cnt_nxt;           // Test pattern counter

wire                          set_r_test;             // Set R color
wire                          set_g_test;             // Set G color
wire                          set_b_test;             // Set B color

//================================================================================
//  Behavior description
//================================================================================
assign r_vld =  tpat_vcnt[0] &  tpat_hcnt[0];
assign g_vld =  tpat_vcnt[0] ^  tpat_hcnt[0];
assign b_vld = ~tpat_vcnt[0] & ~tpat_hcnt[0];

assign dat_vld = r_vld | g_vld | b_vld;
//--------------------------------------------------------------------------------
//  Counter for Color Bar & XY-Coordinate RGB
//--------------------------------------------------------------------------------
assign cbar_lsb_cnt    = tpat_vbar_sel ? tpat_hcnt[4:0] : tpat_vcnt[4:0];
assign bar_msb_cnt_inc = tpat_cbar_sel & ((~tpat_vbar_sel & hend_i) | tpat_vbar_sel) & (&cbar_lsb_cnt) & dat_vld;
assign axis_cnt_inc    = tpat_axis_sel & dat_vld;

assign tpat_cnt_nxt = {PCNT_SZ{tpat_axis_sel | tpat_hbar_sel ? ~vstr_i : ~hstr_i}} &
                       ((tpat_axis_sel & hstr_i) ? {{PCNT_SZ-LCNT_SZ{1'b0}},tpat_vcnt} :
                                                   bar_msb_cnt_inc | axis_cnt_inc ? tpat_cnt + 1'b1 : tpat_cnt);

//
always @(posedge clk or negedge rst_n) begin : TPAT_CNT
   if (~rst_n) begin
      tpat_cnt <= 0;
   end
   else begin
      tpat_cnt <= tpat_cnt_nxt;
   end
end

//--------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------
assign tpat_en       = (reg_tpat_ctrl[0] & (reg_tpat_sel == TPAT_ID));

assign tpat_r_sel    = reg_tpat_ctrl[1];
assign tpat_g_sel    = reg_tpat_ctrl[2];
assign tpat_b_sel    = reg_tpat_ctrl[3];

//assign tpat_pure_sel = reg_tpat_ctrl[5:4] == 2'b00;
assign tpat_axis_sel = reg_tpat_ctrl[5:4] == 2'b01;
assign tpat_vbar_sel = reg_tpat_ctrl[4];
assign tpat_cbar_sel = reg_tpat_ctrl[5];
assign tpat_hbar_sel = tpat_cbar_sel & ~tpat_vbar_sel;

assign mask_raw_r =  ~tpat_axis_sel ? {PX_SZ{set_r_test}} :
                                      {{PX_SZ-TPAT_RAW_SZ{1'b0}},tpat_cnt[PCNT_SZ-1:0],{(TPAT_RAW_SZ-PCNT_SZ){1'b0}}} & {PX_SZ{tpat_r_sel}};

assign mask_raw_g =  ~tpat_axis_sel ? {PX_SZ{set_g_test}} :
                                      {{PX_SZ-TPAT_RAW_SZ{1'b0}},tpat_cnt[PCNT_SZ-1:0],{(TPAT_RAW_SZ-PCNT_SZ){1'b0}}} & {PX_SZ{tpat_g_sel}};

assign mask_raw_b =  ~tpat_axis_sel ? {PX_SZ{set_b_test}} :
                                      {{PX_SZ-TPAT_RAW_SZ{1'b0}},tpat_cnt[PCNT_SZ-1:0],{(TPAT_RAW_SZ-PCNT_SZ){1'b0}}} & {PX_SZ{tpat_b_sel}};

assign set_r_test = tpat_cbar_sel ? (tpat_cnt[0 +: 3]== 1 || tpat_cnt[0 +: 3]== 3 ||
                                     tpat_cnt[0 +: 3]== 5 || tpat_cnt[0 +: 3]== 7) : tpat_r_sel;

assign set_g_test = tpat_cbar_sel ? (tpat_cnt[0 +: 3]== 2 || tpat_cnt[0 +: 3]== 3 ||
                                     tpat_cnt[0 +: 3]== 6 || tpat_cnt[0 +: 3]== 7) : tpat_g_sel;

assign set_b_test = tpat_cbar_sel ? (tpat_cnt[0 +: 3]== 4 || tpat_cnt[0 +: 3]== 5 ||
                                     tpat_cnt[0 +: 3]== 6 || tpat_cnt[0 +: 3]== 7) : tpat_b_sel;
/*
assign data_o = (tpat_en)? (mask_raw_r & {PX_SZ{r_vld}}) |
                           (mask_raw_g & {PX_SZ{g_vld}}) |
                           (mask_raw_b & {PX_SZ{b_vld}}) : data_i;
*/
assign data_o = (tpat_en & (PX_RATE == 1))? (mask_raw_r & {PX_SZ{r_vld}}) |
                                            (mask_raw_g & {PX_SZ{g_vld}}) |
                                            (mask_raw_b & {PX_SZ{b_vld}}) : data_i;

//================================================================================
//  Module instantiation
//================================================================================

//================================================================================
//    Function
//================================================================================
function integer log2;

input integer n;

begin
  log2 = 0;
  while(2**log2 < n) begin
    log2=log2+1;
  end
end

endfunction

//================================================================================

endmodule
