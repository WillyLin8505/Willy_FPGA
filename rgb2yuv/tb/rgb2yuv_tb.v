// ------------------------------------------------------------------------------//
// (C) Copyright. 2021
// SILICON OPTRONICS CORPORATION ALL RIGHTS RESERVED
//
// This design is confidential and proprietary owned by Silicon Optronics Corp.
// Any distribution and modification must be authorized by a licensing agreement
// ------------------------------------------------------------------------------//
// Filename        : rgb2yuv_tb.v
// Author          : Willylin
// Version         : $Revision$
// Last Modified On: 2021/12/21
// Last Modified By: $Author$
//
// Description     : rgb2yuv
// ------------------------------------------------------------------------------//

// defination & include
`timescale 1ns/1ns  
`define   TB_TOP            rgb2yuv_tb
`define   SENSOR_R          `TB_TOP.sensor_rgb
module rgb2yuv_tb();

//================================================================================
// simulation config console
//================================================================================
`include "reg_wire_declare.name"
//---------------------------------------------------ini_reg
string               ini_file_name                = "reg_config.ini";
string               test_pat_name                = "";
string               ppm_file_name                = "";
string               gold_img_num                 = "";

//---------------------------------------------------clk
parameter           CLK_PERIOD              = 10;
//---------------------------------------------------rgb2yuv
parameter           DAT_SZ                  = 10;
parameter           PRECISION               = 1;
//---------------------------------------------------sensor
// pixel rate (pixel number per clock) depend on TX type
parameter           SSR_PX_RATE             = 1;
parameter           SSR_PX_FMT              = "RGB8";

// sensor pixel size (used by ISP sensor interface)
parameter           SSR_PX_SZ               = (SSR_PX_FMT == "RAW8" )? 8  :
                                              (SSR_PX_FMT == "RAW10")? 10 :
                                              (SSR_PX_FMT == "RAW12")? 12 :
                                              (SSR_PX_FMT == "RGB8" )? 24 :
                                              (SSR_PX_FMT == "RGB10")? 30 : 10;

parameter           SSR_PX_SZ_MAX           = 24;

// pixel data color sequence (only valid when SSR_PX_RATE !=1)
parameter           SSR_PX_CSEQ             = "G_LSB";

// exposure rate (exposure number per frame)
parameter           SSR_EXPO_RATE           = 1;
//================================================================================
//  signal declaration
//================================================================================
//---------------------------------------------------------------------------------tb
wire [DAT_SZ-1:0]                   data_y;                      //
wire [DAT_SZ-1:0]                   data_cb;                     //
wire [DAT_SZ-1:0]                   data_cr;                     //
reg  [DAT_SZ-1:0]                   y_dly;                         // delay (for ido monitor)
reg  [DAT_SZ-1:0]                   cb_dly;                        // delay (for ido monitor)
reg  [DAT_SZ-1:0]                   cr_dly;                        // delay (for ido monitor)
wire [DAT_SZ-1:0]                   data_r;                      // input sensor R
wire [DAT_SZ-1:0]                   data_g;                      // input sensor G
wire [DAT_SZ-1:0]                   data_b;                      // input sensor B
//---------------------------------------------------------------------------------sensor
wire        [23:0]                  ssr_dvp_data_rgb;  
wire                                ssr_field_rgb;   
wire                                ssr_href_rgb;
reg                                 ssr_href_rgb_dly;
wire                                ssr_vstr_rgb;
wire                                ssr_vend_rgb;
wire                                ssr_hstr_rgb;
reg                                 ssr_hstr_rgb_dly;
wire                                ssr_hend_rgb;
reg                                 ssr_hend_rgb_dly;

//
reg         [15:0]                  reg_ssr_hwin_sz;
reg         [ 3:0]                  reg_ssr_hpad_sz;

reg         [15:0]                  reg_ssr_vwin_sz;
reg         [ 3:0]                  reg_ssr_vpad_sz;

reg                                 reg_dvp_x1=1'b1;     
//

wire        [15:0]                  sensor_hwin_sz;
wire        [15:0]                  sensor_vwin_sz;

wire        [ 3:0]                  sensor_hpad_sz;
wire        [ 3:0]                  sensor_vpad_sz;

reg                                 ssr_href_en;
wire                                ssr_href_en_nxt;

// hsync+hblk = htotal - (hwin+2*hpad) = 1500 - (1280+8*2) = 204
reg         [15:0]                  sensor_hsync_sz         = 4;
reg         [15:0]                  sensor_hblkf_sz         = SSR_PX_RATE == 4 ?  40 :
                                                              SSR_PX_RATE == 2 ?  80 : 160; // limited by mipi_tx
reg         [15:0]                  sensor_hblkb_sz         = SSR_PX_RATE == 4 ?  50 :
                                                              SSR_PX_RATE == 2 ? 100 : 200;

//
reg         [15:0]                  sensor_vsync_sz         = 2;
// vblk = vtotal - (vwin+2*vpad) = 750-720 = 30
reg         [16*SSR_EXPO_RATE-1:0]  sensor_vblkf1_sz        = (SSR_EXPO_RATE == 2)? {16'd6,16'd2} : 16'd6;
reg         [15:0]                  sensor_vblkf2_sz        = 0;
reg         [15:0]                  sensor_vblkb1_sz        = 2;
reg         [16*SSR_EXPO_RATE-1:0]  sensor_vblkb2_sz        = (SSR_EXPO_RATE == 2)? {16'd2,16'd6} : 16'd4;

//
reg         [ 2:0]                  sensor_pal_cyc_ofst     = 2;

//
reg         [15:0]                  sensor_field_hofst      = 128;
reg         [15:0]                  sensor_field_vofst      = 0;

//
reg         [ 6:0]                  sensor_gain             = 0;
reg                                 sensor_ae_stbl          = 1'b1;
reg                                 sensor_ae_upd           = 1'b0;  

//---------------------------------------------------------------------------------config
reg                                 TB_SYS_CLK;
reg                                 reg_ini_done;

//--------------------------------------------------------------------------------
//  clocking and reset
//--------------------------------------------------------------------------------
reg clk;
reg rst_n;

always #(CLK_PERIOD/2)  clk <= ~clk;
initial begin
clk   = 0;
rst_n = 0;
#10
rst_n = 1;
end
//================================================================================
//  behavior description
//================================================================================
//----------------------------------------------------------------------------------sensor 
assign sensor_hwin_sz         = reg_ssr_hwin_sz;
assign sensor_hpad_sz         = reg_ssr_hpad_sz;
assign sensor_vwin_sz         = reg_ssr_vwin_sz;
assign sensor_vpad_sz         = reg_ssr_vpad_sz;
assign ssr_href_en_nxt        = 1'b1;
assign ssr_hstr_rgb           = (ssr_href_rgb & !ssr_href_rgb_dly);
assign ssr_hend_rgb           = (!ssr_href_rgb & ssr_href_rgb_dly); 
//----------------------------------------------------------------------------------rgb2yuv
assign data_r                 = ssr_dvp_data_rgb[23:16];
assign data_g                 = ssr_dvp_data_rgb[15:8];
assign data_b                 = ssr_dvp_data_rgb[7:0];


always@(posedge clk or negedge rst_n) begin 
if(!rst_n) begin 
  ssr_href_en      <= 1'b0;
  ssr_href_rgb_dly <= 1'b0;
  ssr_hstr_rgb_dly <= 1'b0;
  ssr_hend_rgb_dly <= 1'b0;
  y_dly            <= 8'b0;
  cb_dly           <= 8'b0;
  cr_dly           <= 8'b0; 
end
else begin 
  ssr_href_en      <= ssr_href_en_nxt; 
  ssr_href_rgb_dly <= ssr_href_rgb;
  ssr_hstr_rgb_dly <= ssr_hstr_rgb;
  ssr_hend_rgb_dly <= ssr_hend_rgb;
  y_dly            <= data_y;
  cb_dly           <= data_cb;
  cr_dly           <= data_cr;
end
end
//--------------------------------------------------------------------------------
// simulation patten
//--------------------------------------------------------------------------------
initial begin
wait(reg_ini_done)
#1000
`SENSOR_R.sensor_en = 1'b1;
end


//================================================================================
//  module instantiation
//================================================================================
ip_rgb2yuv  
#(.DAT_SZ    (DAT_SZ),
  .PRECISION (PRECISION)
)
rgb2yuv(
            // Output
  .o_data_y    (data_y),
  .o_data_cb   (data_cb),
  .o_data_cr   (data_cr),
            // Input
  .i_data_r    (data_r),
  .i_data_g    (data_g),
  .i_data_b    (data_b)
);


sensor

#(.PX_RATE     (SSR_PX_RATE),

  .PX_FMT      (SSR_PX_FMT),

  .PX_CSEQ     ("NORMAL"),

  .EXPO_RATE   (1),

  .SHOW_MSG    (1))

sensor_rgb(
// output
  .ssr_vsync              (),
  .ssr_vref               (),

  .ssr_hsync              (),
  .ssr_href               (ssr_href_rgb),

  .ssr_blue               (),
  .ssr_hbyps              (),
  .ssr_field              (ssr_field_rgb),

  .ssr_vstr               (ssr_vstr_rgb),
  .ssr_vend               (ssr_vend_rgb),

  .ssr_data               (ssr_dvp_data_rgb),

// input control
  .ssr_href_en            (ssr_href_en),        //control
// reg
  .reg_ssr_raw_bit        (4'ha),
  .reg_ssr_halfln_md      (1'b0),
  .reg_hwin_sz            (sensor_hwin_sz),     //control
  .reg_vwin_sz            (sensor_vwin_sz),     //control

  .reg_hpad_sz            (sensor_hpad_sz),     //control
  .reg_vpad_sz            (sensor_vpad_sz),     //control

  .reg_hsync_sz           (sensor_hsync_sz),
  .reg_hblkf_sz           (sensor_hblkf_sz),
  .reg_hblkb_sz           (sensor_hblkb_sz),

  .reg_vsync_sz           (sensor_vsync_sz ),
  .reg_vblkf1_sz          (sensor_vblkf1_sz),
  .reg_vblkf2_sz          (sensor_vblkf2_sz),
  .reg_vblkb1_sz          (sensor_vblkb1_sz),
  .reg_vblkb2_sz          (sensor_vblkb2_sz),

  .reg_tpat_en            (sensor_tpat_en),
  .reg_dvp_x1             (reg_dvp_x1),

  .reg_tv_pal             (1'b0),
  .reg_pal_cyc_ofst       (sensor_pal_cyc_ofst),

  .reg_field_hofst        (sensor_field_hofst),
  .reg_field_vofst        (sensor_field_vofst),

// clk
  .clk                    (clk),
  .rst_n                  (rst_n)
);


//--------------------------------------------------------------------------------
// register setting (override initial value)
//--------------------------------------------------------------------------------
initial begin: REG_INI
  reg_ini_done = 0;
  reg_ini.open_ini(ini_file_name);
  @ (posedge clk);
  reg_ini_done = 1;
end

initial begin 
 wait(reg_ini_done)
 pass_string_r(ppm_file_name);
 #50
 reg_ini_done = 0;
end 

//================================================================================
//  task
//================================================================================

task pass_string_r;
input string input_string;
begin 
`SENSOR_R.ppm_file_name = input_string;
end
endtask 




//--------------------------------------------------------------------------------
//  waveform dump setting
//--------------------------------------------------------------------------------

initial begin 
      $fsdbDumpfile("./wave/rgb2yuv_tb");
      $fsdbDumpvars(0,rgb2yuv_tb,"+all");
      $fsdbDumpvars(0,ido_mon,"+all");
      $fsdbDumpvars(0,rgb2yuv_mon,"+all");
      #3000000;
      $finish;
end

//--------------------------------------------------------------------------------
//  register initial procedure
//--------------------------------------------------------------------------------

reg_ini
reg_ini();



//--------------------------------------------------------------------------------

endmodule       
