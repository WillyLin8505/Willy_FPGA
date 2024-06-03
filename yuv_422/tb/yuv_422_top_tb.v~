// ------------------------------------------------------------------------------//
// (C) Copyright. 2021
// SILICON OPTRONICS CORPORATION ALL RIGHTS RESERVED
//
// This design is confidential and proprietary owned by Silicon Optronics Corp.
// Any distribution and modification must be authorized by a licensing agreement
// ------------------------------------------------------------------------------//
// Filename        : yuv_422_top_tb.v
// Author          : Willylin
// Version         : $Revision$
// Last Modified On: 2021/11/17
// Last Modified By: $Author$
//
// Description     :test yuv 422
// ------------------------------------------------------------------------------//

// defination & include
`timescale 1ns/1ns  
`define   TB_TOP            yuv_422_top_tb
`define   IDO               `TB_TOP.ido_top_temp
`define   YUV422            `IDO.ip_yuv_422
`define   SENSOR            `TB_TOP.sensor
module yuv_422_top_tb();

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
parameter            CLK_PERIOD = 10;

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
//-------------------------------------------------------------------------------tb
reg                      yuv_422_clk;
reg                      yuv_422_rst_n;
//reg                      isp_vstr;
//reg                      isp_vend;    
//reg                      isp_hstr;  
//reg                      isp_hend;     
wire                       isp_dvld;     
wire  [7:0]              isp_data_r;    
wire  [7:0]              isp_data_g;     
wire  [7:0]              isp_data_b;     
//-------------------------------------------------------------------------------ido 
//wire                     ido_vstr;             // frame start
//wire                     ido_vend;             // frame end
//wire                     ido_hstr;             // line start
//wire                     ido_hend;             // line end
wire                     ido_dvld;             // data valid
wire [7:0]               ido_data_r;           // R / Y  / Y data output
wire [7:0]               ido_data_g;           // G / Cb / U data output
wire [7:0]               ido_data_b;           // B / Cr / V data output
//---------------------------------------------------------------------------------sensor
wire        [SSR_EXPO_RATE-1:0]     ssr_dvp_href;                 //
wire        [23:0]                  ssr_dvp_data;  
wire                                ssr_field;   
wire                                ssr_href;
//
reg         [15:0]                  reg_ssr_hwin_sz;
reg         [ 3:0]                  reg_ssr_hpad_sz;

reg         [15:0]                  reg_ssr_vwin_sz;
reg         [ 3:0]                  reg_ssr_vpad_sz;

//

wire        [15:0]                  sensor_hwin_sz;
wire        [15:0]                  sensor_vwin_sz;

wire        [ 3:0]                  sensor_hpad_sz;
wire        [ 3:0]                  sensor_vpad_sz;

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

//---------------------------------------------------------------------------------simulation 

//---------------------------------------------------------------------------------config
reg                      TB_SYS_CLK;
reg                      reg_ini_done;
//--------------------------------------------------------------------------------
//  clocking and reset
//--------------------------------------------------------------------------------

initial begin
yuv_422_clk   = 1'b0;    
yuv_422_rst_n = 1'b0;
#100
yuv_422_rst_n = 1'b1;

end

initial begin
     
forever #(CLK_PERIOD/2) yuv_422_clk = ~yuv_422_clk;

end

//================================================================================
//  behavior description
//================================================================================
//----------------------------------------------------------------------------------sensor 
assign sensor_hwin_sz         = reg_ssr_hwin_sz;
assign sensor_hpad_sz         = reg_ssr_hpad_sz;
assign sensor_vwin_sz         = reg_ssr_vwin_sz;
assign sensor_vpad_sz         = reg_ssr_vpad_sz;
assign ssr_href_en            = 1'b1; 

//---------------------------------------------------------------------------------ido 
assign isp_data_r             = ssr_dvp_data[23:16];
assign isp_data_g             = ssr_dvp_data[15:8];
assign isp_data_b             = ssr_dvp_data[7:0];
assign isp_dvld               = ssr_href;
//--------------------------------------------------------------------------------
// simulation patten
//--------------------------------------------------------------------------------
initial begin
wait(reg_ini_done)
#1000
`SENSOR.sensor_en = 1'b1;
end

//================================================================================
//  module instantiation
//================================================================================

sensor

#(.PX_RATE   (SSR_PX_RATE),

  .PX_FMT    (SSR_PX_FMT),

  .PX_CSEQ   ("NORMAL"),

  .EXPO_RATE (1),

  .SHOW_MSG  (1))

sensor(
// output
      .ssr_vsync              (),
      .ssr_vref               (),

      .ssr_hsync              (),
      .ssr_href               (ssr_href),

      .ssr_blue               (),
      .ssr_hbyps              (),
      .ssr_field              (ssr_field),

      .ssr_vstr               (),
      .ssr_vend               (),

      .ssr_data               (ssr_dvp_data),

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

      .reg_tv_pal             (1'b0),
      .reg_pal_cyc_ofst       (sensor_pal_cyc_ofst),

      .reg_field_hofst        (sensor_field_hofst),
      .reg_field_vofst        (sensor_field_vofst),

// clk
      .clk                    (yuv_422_clk),
      .rst_n                  (yuv_422_rst_n)
);


ido_top_temp ido_top_temp
(
// output
         .ido_vstr           (ido_vstr),          // frame start
         .ido_vend           (ido_vend),          // frame end
         .ido_hstr           (ido_hstr),          // line start
         .ido_hend           (ido_hend),          // line end
         .ido_dvld           (ido_dvld),          // data valid
         .ido_data_r         (ido_data_r),        // R / Y  / Y data output
         .ido_data_g         (ido_data_g),        // G / Cb / U data output
         .ido_data_b         (ido_data_b),        // B / Cr / V data output

// input


         .isp_vstr           (1'b0),              // ISP RGB/YCbCr
         .isp_vend           (1'b0),              //
         .isp_hstr           (1'b0),              //
         .isp_hend           (1'b0),              //
         .isp_dvld           (isp_dvld),          //
         .isp_data_r         (isp_data_r),        //
         .isp_data_g         (isp_data_g),        //
         .isp_data_b         (isp_data_b),        //

         .tvp_vstr           (1'b0),              // TVP YCbCr
         .tvp_vend           (1'b0),              //
         .tvp_hstr           (1'b0),              //
         .tvp_hend           (1'b0),              //
         .tvp_dvld           (1'b0),              //
         .tvp_data_y         (8'h00),             //
         .tvp_data_cb        (8'h00),             //
         .tvp_data_cr        (8'h00),             //

         .tve_vstr           (1'b0),              // TVE YUV
         .tve_vend           (1'b0),              //
         .tve_hstr           (1'b0),              //
         .tve_hend           (1'b0),              //
         .tve_dvld           (1'b0),              //
         .tve_data_y         (8'h00),             //
         .tve_data_u         (8'h00),             //
         .tve_data_v         (8'h00),             //

// reg
         .reg_ido_format     (3'b100),            // output format select
                                                  // 0 => CV_RGB, 1 => ORG_RGB
         .reg_ido_ycbcr_sel  (1'b0),              // YCbCr source select:
                                                  // 0 => ISP YCbCr, 1 => TVP YCbCr
         .reg_ido_yuv_sel    (1'b0),              // YUV / YCbCr select:
                                                  // 0 => YCbCr    , 1 => YUV
         .reg_ido_ycbcr_rng  (1'b0),              // YCbCr with nominal range
                                                  // 0=> 0~255, 1=> 16~235/16~240
         .r_yuv_422_swap_yc  (r_yuv_422_swap_yc),
// clk
         .pclk               (yuv_422_clk),       // pixel clock
         .prst_n             (yuv_422_rst_n)      // sync reset @ pclk
);

//--------------------------------------------------------------------------------
// register setting (override initial value)
//--------------------------------------------------------------------------------
initial begin: REG_INI
  reg_ini_done = 0;
  reg_ini.open_ini(ini_file_name);
  @ (posedge yuv_422_clk);
  reg_ini_done = 1;
end

initial begin 
 wait(reg_ini_done)
 pass_string(ppm_file_name);
end 

//================================================================================
//  task
//================================================================================

task pass_string;
input string input_string;
begin 
`SENSOR.ppm_file_name = input_string;
end
endtask 

//--------------------------------------------------------------------------------
//  waveform dump setting
//--------------------------------------------------------------------------------

initial begin 
      $fsdbDumpfile("./wave/yuv_422_top_tb");
      $fsdbDumpvars(0,yuv_422_top_tb,"+all");
      $fsdbDumpvars(0,yuv_422_top_mon,"+all");
      wait(ssr_field)
      wait(~ssr_field)
      $finish;
end

//--------------------------------------------------------------------------------
//  register initial procedure
//--------------------------------------------------------------------------------
reg_ini
reg_ini();

//--------------------------------------------------------------------------------

endmodule       
