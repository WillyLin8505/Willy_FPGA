// ------------------------------------------------------------------------------//
// (C) Copyright. 2022
// SILICON OPTRONICS CORPORATION ALL RIGHTS RESERVED
//
// This design is confidential and proprietary owned by Silicon Optronics Corp.
// Any distribution and modification must be authorized by a licensing agreement
// ------------------------------------------------------------------------------//
// Filename        :
// Author          : Willylin
// Version         : $Revision$
// Create          : 2022/2/8
// Last Modified On: 
// Last Modified By: $Author$
// 
// Description     : GENERATE_SEL  : 0: rgb2ycbcr - ycbcr2oklab - oklab2lms - lms2rgb
//                                                                          - lms2ycbfcr

//                                   1: rgb2ycbcr - ycbcr2lms   - lms2oklab - oklab2lms - lms2rgb
//                                                                                      - lms2ycbcr

//                                   2: rgb2ycbcr - rgb2lms     - lms2oklab - oklab2lms - lms2rgb
//                                                                                      - lms2ycbcr

//                                   3: rgb2ycbcr - rgb2lms     - lms2oklab - oklab2lms - lms2rgb_ycbcr_psft
//                                                                                      - lms2rgb_ycbcr_rsft
//
//                  ini_source_sel : 0: sensor_input   : rgb2ycbcr
//                                      monitor_output : lms2rgb 

//                                   1: sensor_input   : rgb2ycbcr
//                                      monitor_output : lms2oklab

//                                   2: sensor_input   : rgb2ycbcr
//                                      monitor_output : rgb2ycbcr

//                                   3: sensor_input   : rgb2ycbcr
//                                      monitor_output : lms2ycbcr

//                                   4: sensor_input   : rgb2ycbcr
//                                      monitor_output : lms2rgb_ycbcr_psft

//                                   5: sensor_input   : rgb2ycbcr
//                                      monitor_output : lms2rgb_ycbcr_rsft

//                                   6: sensor_input   : ycbcr2lms           
//                                      monitor_output : lms2oklab                //in order to check lms,oklab over and under flow 
 
//                                   7: sensor_input   : oklab2lms
//                                      monitor_output : lms2ycbcr                //in order to check inv_lms,inv_ycbcr over and under flow 

//                                   8: sensor_input   : oklab2lms
//                                      monitor_output : lms2rgb                  //in order to check inv_lms,inv_rgb over and under flow 

// ------------------------------------------------------------------------------//

// defination & include
`timescale 1ns/1ns  
`define   TB_TOP            color_convert_tb
`define   MONITOR_TOP       color_convert_mon
`define   color_convert     `TB_TOP.color_convert

`define   SENSOR            `TB_TOP.sensor
`define   SSR_TOP           `TB_TOP.sensor       //get error when scarcing this parameter
`define   HOST_WR           nope                 //get error when scarcing this parameter
`define   PPM_MON           `TB_TOP.ppm_monitor
// module start 
module color_convert_tb();

//================================================================================
// simulation config console
//================================================================================

`include "reg_wire_declare.name"

string               ini_file_name                = "reg_config.ini";
string               test_pat_name                = "";
string               ppm_file_name                = "";
string               gold_img_num                 = "";
string               gold_vec_file                = "one_direction"; 
string               gold_num                     = "";
//================================================================================
//  parameter declaration
//================================================================================
`include "tb_parameter.vh"
//----------------------------------------------------------------tb
parameter           PERIOD                  = 10;

parameter           CIIW_LMS_SFT            = CIIW_LR;
parameter           CIPW_LMS_SFT            = CIPW_LR;
parameter           COIW_LMS_SFT            = (OUT_TYPE == "RGB") ? COIW_LR : COIW_LY;
parameter           COPW_LMS_SFT            = (OUT_TYPE == "RGB") ? COPW_LR : COPW_LY;

//----------------------------------------------------------------sensor
// pixel rate (pixel number per clock) depend on TX type
parameter           SSR_PX_RATE             = 1;

// sensor pixel size (used by ISP sensor interface)
parameter           SSR_PX_SZ               = (SSR_PX_FMT == "RAW8" )? 8  :
                                              (SSR_PX_FMT == "RAW10")? 10 :
                                              (SSR_PX_FMT == "RAW12")? 12 :
                                              (SSR_PX_FMT == "RGB8" )? 24 :
                                              (SSR_PX_FMT == "RGB10")? 30 :
                                              (SSR_PX_FMT == "RGB12")? 36 :
                                              (SSR_PX_FMT == "RGB14")? 42 :
                                              (SSR_PX_FMT == "RGB16")? 48 : 10;

parameter           SSR_PX_SZ_MAX           = SSR_PX_SZ;

// pixel data color sequence (only valid when SSR_PX_RATE !=1)
parameter           SSR_PX_CSEQ             = "G_LSB";

// exposure rate (exposure number per frame)
parameter           SSR_EXPO_RATE           = 1;
    
//-----------------------------------------------------------------ppm monitor 
parameter           DUT_NAME                = "COLOR_CONVERT";
parameter           DATA_BIT_WID            = (MON_PX_FMT == "RAW8" )? 8  :
                                              (MON_PX_FMT == "RAW10")? 10 :
                                              (MON_PX_FMT == "RAW12")? 12 :
                                              (MON_PX_FMT == "RGB8" )? 8 :
                                              (MON_PX_FMT == "RGB10")? 10 :
                                              (MON_PX_FMT == "RGB12")? 12 :
                                              (MON_PX_FMT == "RGB14")? 14 :
                                              (MON_PX_FMT == "RGB16")? 16 : 10;

//-----------------------------------------------------------------local param

//================================================================================
//  signal declaration
//================================================================================
//----------------------------------------------------------------------------------------tb 
reg                                 rst_n;
reg                                 clk;
wire                                i_hstr_sensor;
wire                                i_href_sensor;
wire                                i_hend_sensor;
wire                                i_vstr;
wire                                i_vend;
reg                                 i_fstr;

wire                                mon_hstr;
wire                                mon_hend;
wire                                mon_href;
wire [15:0]                         mon_data_1;
wire [15:0]                         mon_data_2;
wire [15:0]                         mon_data_3;

//----------------------------------------------------------------------------------------sensor
wire        [SSR_EXPO_RATE-1:0]     ssr_dvp_href;                 //
wire        [SSR_PX_SZ-1:0]         ssr_dvp_data;  
reg         [SSR_PX_SZ-1:0]         ssr_dvp_data_dly;  
wire                                ssr_field;   
wire                                ssr_href;
//
wire        [SSR_PX_SZ/3-1:0]       sensor_ch_0;
wire        [SSR_PX_SZ/3-1:0]       sensor_ch_1;
wire        [SSR_PX_SZ/3-1:0]       sensor_ch_2;

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

wire                                ssr_hstr;
wire                                ssr_hend;
wire                                ssr_vstr;
wire                                ssr_vend;
reg                                 ssr_href_dly;

//----------------------------------------------------------------------------------------// ip_rgb2ycbcr Outputs
wire  [COIW_RY +COPW_RY -1:0]       data_r2y;
wire  [COIW_RY +COPW_RY   :0]       data_r2cb;
wire  [COIW_RY +COPW_RY   :0]       data_r2cr;
wire                                hstr_r2y;
wire                                hend_r2y;
wire                                href_r2y;

wire  [COIW_RY +COPW_RY -1:0]       data_y_chg;
wire  [COIW_RY +COPW_RY   :0]       data_cb_sgn_chg;
wire  [COIW_RY +COPW_RY   :0]       data_cr_sgn_chg;
wire                                data_ycbcr_hstr;
wire                                data_ycbcr_hend;
wire                                data_ycbcr_href;

wire  [COIW_YL +COPW_YL -1:0]       data_y2l;                 
wire  [COIW_YL +COPW_YL -1:0]       data_y2m;                    
wire  [COIW_YL +COPW_YL -1:0]       data_y2s;                  
wire                                hstr_y2l;
wire                                hend_y2l;
wire                                href_y2l;

wire  [COIW_L_LK  +COPW_L_LK -1:0]  data_l2l;                 
wire  [COIW_AB_LK +COPW_AB_LK-1 :0] data_l2a_sgn;                    
wire  [COIW_AB_LK +COPW_AB_LK-1 :0] data_l2b_sgn;                  
wire                                hstr_l2k;
wire                                hend_l2k;
wire                                href_l2k;

wire  [COIW_L_LK  +COPW_L_LK -1:0]  data_l_chg;                 
wire  [COIW_AB_LK +COPW_AB_LK-1 :0] data_a_sgn_chg;                    
wire  [COIW_AB_LK +COPW_AB_LK-1 :0] data_b_sgn_chg;                  
wire                                data_lab_hstr;
wire                                data_lab_hend;
wire                                data_lab_href;

wire  [COIW_KL +COPW_KL -1:0]       data_k2l;                 
wire  [COIW_KL +COPW_KL -1:0]       data_k2m;                    
wire  [COIW_KL +COPW_KL -1:0]       data_k2s;                  
wire                                hstr_k2l;
wire                                hend_k2l;
wire                                href_k2l;

wire  [COIW_LY +COPW_LY -1:0]       data_l2y;                 
wire  [COIW_LY +COPW_LY   :0]       data_l2cb;                    
wire  [COIW_LY +COPW_LY   :0]       data_l2cr;                  
wire                                hstr_l2y;
wire                                hend_l2y;
wire                                href_l2y;

wire  [COIW_LR +COPW_LR -1:0]       data_l2r;                 
wire  [COIW_LR +COPW_LR -1:0]       data_l2g;                    
wire  [COIW_LR +COPW_LR -1:0]       data_l2b;                  
wire                                hstr_l2r;
wire                                hend_l2r;
wire                                href_l2r;

wire [COIW_LMS_SFT +COPW_LMS_SFT-1:0] data_ch1_p;
wire [COIW_LMS_SFT +COPW_LMS_SFT-1:0] data_ch2_p;
wire [COIW_LMS_SFT +COPW_LMS_SFT-1:0] data_ch3_p;
wire                                  hstr_sft_p;
wire                                  hend_sft_p;
wire                                  href_sft_p;

wire [COIW_LMS_SFT +COPW_LMS_SFT-1:0] data_ch1_r;
wire [COIW_LMS_SFT +COPW_LMS_SFT-1:0] data_ch2_r;
wire [COIW_LMS_SFT +COPW_LMS_SFT-1:0] data_ch3_r;
wire                                  hstr_sft_r;
wire                                  hend_sft_r;
wire                                  href_sft_r;

//----------------------------------------------------------------------------------------config
reg                                 TB_SYS_CLK;
reg                                 reg_ini_done;
//--------------------------------------------------------------------------------
//  clocking and reset
//--------------------------------------------------------------------------------


initial  begin 

 rst_n=0;
 #50;
 rst_n=1;

end

initial begin 
clk = 0;
forever #(PERIOD/2) clk = ~clk;
end

//================================================================================
//  behavior description
//================================================================================
//----------------------------------------------------------------------------------sensor
initial begin
i_fstr = 0;
wait(~reg_ini_done)
wait(reg_ini_done)
#1000
`SENSOR.sensor_en = 1'b1;
  @ (posedge clk);
  @ (posedge clk);
i_fstr  = 1;
  @ (posedge clk);
  @ (posedge clk);
i_fstr  = 0;
end

assign ssr_hstr   = ssr_href & !ssr_href_dly;
assign ssr_hend   = !ssr_href & ssr_href_dly;

always@(posedge clk or negedge rst_n) begin 
  if(!rst_n) begin 
    ssr_href_dly     <= 0;
    ssr_dvp_data_dly <= 0;
  end 
  else  begin 
    ssr_href_dly     <= ssr_href;
    ssr_dvp_data_dly <= ssr_dvp_data;
  end
end 
//================================================================================
//  module instantiation
//================================================================================
assign sensor_ch_2   = ssr_dvp_data_dly[SSR_PX_SZ/3-1:0];
assign sensor_ch_1   = ssr_dvp_data_dly[SSR_PX_SZ/3*2-1:SSR_PX_SZ/3];
assign sensor_ch_0   = ssr_dvp_data_dly[SSR_PX_SZ/3*3-1:SSR_PX_SZ/3*2];
assign i_hstr_sensor = ssr_hstr;
assign i_href_sensor = ssr_href_dly;
assign i_hend_sensor = ssr_hend;
assign i_vstr        = ssr_vstr;
assign i_vend        = ssr_vend;

sensor

#(.PX_RATE   (SSR_PX_RATE),

  .PX_FMT    (SSR_PX_FMT),

  .PX_CSEQ   ("NORMAL"),

  .EXPO_RATE (1),

  .SHOW_MSG  (1),
  
  .PX_SZ_MAX (SSR_PX_SZ_MAX))

sensor(
// output
      .ssr_vsync              (),
      .ssr_vref               (),

      .ssr_hsync              (),
      .ssr_href               (ssr_href),

      .ssr_blue               (),
      .ssr_hbyps              (),
      .ssr_field              (ssr_field),

      .ssr_vstr               (ssr_vstr),
      .ssr_vend               (ssr_vend),

      .ssr_data               (ssr_dvp_data),

// input control
      .ssr_href_en            (1'b1),               //control enable
// reg
      .reg_ssr_raw_bit        (4'ha),
      .reg_ssr_halfln_md      (1'b0),
      .reg_hwin_sz            (ini_ssr_hwin_sz),    //control horizontial 
      .reg_vwin_sz            (ini_ssr_vwin_sz),    //control vertical 

      .reg_hpad_sz            (4'h0),    
      .reg_vpad_sz            (4'h0),     

      .reg_hsync_sz           (15'h4),              //control(just control the bit count )   
      .reg_hblkf_sz           (ini_sensor_hblkf_sz),//control sync black 
      .reg_hblkb_sz           (ini_sensor_hblkb_sz),//control sync black 

      .reg_vsync_sz           (15'h2),              //control(just control the bit count )
      .reg_vblkf1_sz          (sensor_vblkf1_sz),
      .reg_vblkf2_sz          (sensor_vblkf2_sz),
      .reg_vblkb1_sz          (sensor_vblkb1_sz),
      .reg_vblkb2_sz          (sensor_vblkb2_sz),

      .reg_tpat_en            (ini_sensor_tpat_en), //control 1:counter ; 0:picture 
      .reg_dvp_x1             (1'b0),

      .reg_tv_pal             (1'b0),
      .reg_pal_cyc_ofst       (sensor_pal_cyc_ofst),

      .reg_field_hofst        (sensor_field_hofst),
      .reg_field_vofst        (sensor_field_vofst),

// clk
      .clk                    (clk),
      .rst_n                  (rst_n)
);

generate 
  if(GENERATE_SEL==0 | GENERATE_SEL==1)

ip_rgb2ycbcr #(
    .CIIW           ( CIIW_RY ),
    .CIPW           ( CIPW_RY ),
    .COIW           ( COIW_RY ),
    .COPW           ( COPW_RY ),
    .YCBCR_POS      ( YCBCR_POS )
)u_ip_rgb2ycbcr (
    .o_data_y       ( data_r2y ),
    .o_data_cb      ( data_r2cb),
    .o_data_cr      ( data_r2cr),
    .o_hstr         ( hstr_r2y   ),
    .o_hend         ( hend_r2y   ),
    .o_href         ( href_r2y   ),
    
    .i_data_r       ( sensor_ch_0 ), 
    .i_data_g       ( sensor_ch_1 ), 
    .i_data_b       ( sensor_ch_2 ),
    .i_hstr         ( i_hstr_sensor   ),
    .i_hend         ( i_hend_sensor   ),
    .i_href         ( i_href_sensor   ),
    .clk            ( clk      ),
    .rst_n          ( rst_n    )
    
);

endgenerate

generate 
  if(GENERATE_SEL==1) begin 

assign data_y_chg        = (ini_source_sel == 4'd6) ? sensor_ch_0   : data_r2y;
assign data_cb_sgn_chg   = (ini_source_sel == 4'd6) ? sensor_ch_1   : data_r2cb;
assign data_cr_sgn_chg   = (ini_source_sel == 4'd6) ? sensor_ch_2   : data_r2cr;
assign data_ycbcr_hstr   = (ini_source_sel == 4'd6) ? i_hstr_sensor : hstr_r2y;
assign data_ycbcr_hend   = (ini_source_sel == 4'd6) ? i_hend_sensor : hend_r2y;
assign data_ycbcr_href   = (ini_source_sel == 4'd6) ? i_href_sensor : href_r2y;

ip_ycbcr2lms#(
    .CIIW           ( CIIW_YL ),
    .CIPW           ( CIPW_YL ),
    .COIW           ( COIW_YL ),
    .COPW           ( COPW_YL ),
    .YCBCR_POS      ( YCBCR_POS)
    
)u_ip_ycbcr2lms(
    .o_data_l       ( data_y2l      ),
    .o_data_m       ( data_y2m      ),
    .o_data_s       ( data_y2s      ),
    .o_hstr         ( hstr_y2l      ),
    .o_hend         ( hend_y2l      ),
    .o_href         ( href_y2l      ),
    
    .i_data_y       ( data_y_chg      ), 
    .i_data_cb_sgn  ( data_cb_sgn_chg ),
    .i_data_cr_sgn  ( data_cr_sgn_chg ),
    .i_hstr         ( data_ycbcr_hstr ),
    .i_hend         ( data_ycbcr_hend ),
    .i_href         ( data_ycbcr_href ),
    .clk            ( clk      ),
    .rst_n          ( rst_n    )
);
end 
endgenerate

generate 
  if(GENERATE_SEL==2 | GENERATE_SEL==3)
  
ip_rgb2lms#(
    .CIIW     ( CIIW_RY ),
    .CIPW     ( CIPW_RY ),
    .COIW     ( COIW_YL ),
    .COPW     ( COPW_YL )
)u_rgb2lms(
    .o_data_l ( data_y2l ),
    .o_data_m ( data_y2m ),
    .o_data_s ( data_y2s ),
    .o_hstr   ( hstr_y2l   ),
    .o_hend   ( hend_y2l   ),
    .o_href   ( href_y2l   ),
    
    .i_data_r ( sensor_ch_0 ),
    .i_data_g ( sensor_ch_1 ),
    .i_data_b ( sensor_ch_2 ),
    .i_hstr   ( i_hstr_sensor   ),
    .i_hend   ( i_hend_sensor   ),
    .i_href   ( i_href_sensor   ),
    .clk      ( clk      ),
    .rst_n    ( rst_n    )
);

endgenerate

generate 
  if(GENERATE_SEL==1 | GENERATE_SEL==2 | GENERATE_SEL==3)
  
ip_lms2oklab#(
    .CIIW           ( CIIW_LK ),
    .CIPW           ( CIPW_LK ),
    .COIW_L         ( COIW_L_LK ),
    .COPW_L         ( COPW_L_LK ),
    .COIW_AB        ( COIW_AB_LK ),
    .COPW_AB        ( COPW_AB_LK )
)u_ip_lms2oklab(
    .o_data_l       ( data_l2l ),
    .o_data_a_sgn   ( data_l2a_sgn ),
    .o_data_b_sgn   ( data_l2b_sgn ),
    .o_hstr         ( hstr_l2k   ),
    .o_hend         ( hend_l2k   ), 
    .o_href         ( href_l2k   ),
    
    .i_data_l       ( data_y2l ),
    .i_data_m       ( data_y2m ),
    .i_data_s       ( data_y2s ),
    .i_hstr         ( hstr_y2l   ),
    .i_hend         ( hend_y2l   ),
    .i_href         ( href_y2l   ),
    .clk            ( clk      ),
    .rst_n          ( rst_n    )
);

endgenerate

generate 
  if(GENERATE_SEL==0)
  
ycbcr2oklab#(
    .CIIW_YL       ( CIIW_YL ),
    .CIPW_YL       ( CIPW_YL ),
    .COIW_YL       ( COIW_YL ),
    .COPW_YL       ( COPW_YL ),
    .CIIW_LK       ( CIIW_LK ),
    .CIPW_LK       ( CIPW_LK ),
    .COIW_L_LK     ( COIW_L_LK ),
    .COPW_L_LK     ( COPW_L_LK ),
    .COIW_AB_LK    ( COIW_AB_LK ),
    .COPW_AB_LK    ( COPW_AB_LK ),
    .YCBCR_POS     (YCBCR_POS)
)u_ycbcr2oklab(
    .o_data_l      ( data_l2l      ),
    .o_data_a_sgn  ( data_l2a_sgn  ),
    .o_data_b_sgn  ( data_l2b_sgn  ),
    .o_hstr        ( hstr_l2k        ),
    .o_hend        ( hend_l2k        ),
    .o_href        ( href_l2k        ),
    
    .i_data_y      ( data_r2y      ),
    .i_data_cb_sgn ( data_r2cb ),
    .i_data_cr_sgn ( data_r2cr ),
    .i_hstr        ( hstr_r2y        ),
    .i_hend        ( hend_r2y        ),
    .i_href        ( href_r2y        ),
    .clk           ( clk           ),
    .rst_n         ( rst_n         )
);

endgenerate

assign data_l_chg      = ((ini_source_sel == 4'd7) | (ini_source_sel == 4'd8)) ? sensor_ch_0   : data_l2l;
assign data_a_sgn_chg  = ((ini_source_sel == 4'd7) | (ini_source_sel == 4'd8)) ? sensor_ch_1   : data_l2a_sgn;
assign data_b_sgn_chg  = ((ini_source_sel == 4'd7) | (ini_source_sel == 4'd8)) ? sensor_ch_2   : data_l2b_sgn;
assign data_lab_hstr   = ((ini_source_sel == 4'd7) | (ini_source_sel == 4'd8)) ? i_hstr_sensor : hstr_l2k;
assign data_lab_hend   = ((ini_source_sel == 4'd7) | (ini_source_sel == 4'd8)) ? i_hend_sensor : hend_l2k;
assign data_lab_href   = ((ini_source_sel == 4'd7) | (ini_source_sel == 4'd8)) ? i_href_sensor : href_l2k;

ip_oklab2lms#(
    .CIIW_L         ( CIIW_KL ),
    .CIPW_L         ( CIPW_KL ),
    .CIIW_AB        ( CIIW_KAB ),
    .CIPW_AB        ( CIPW_KAB ),
    .CIW_LMS        ( CIW_LMS),
    .CPW_LMS        ( CPW_LMS),
    .CIW_STG_1      ( CIW_STG_1_KL),
    .CPW_STG_1      ( CPW_STG_1_KL),
    .COIW           ( COIW_KL ),
    .COPW           ( COPW_KL )
)u_ip_oklab2lms(
    .o_data_l       ( data_k2l     ),
    .o_data_m       ( data_k2m     ),
    .o_data_s       ( data_k2s     ),
    .o_hstr         ( hstr_k2l       ),
    .o_hend         ( hend_k2l       ),
    .o_href         ( href_k2l       ),
    
    .i_data_l       ( data_l_chg     ),
    .i_data_a_sgn   ( data_a_sgn_chg ), 
    .i_data_b_sgn   ( data_b_sgn_chg ), 
    .i_hstr         ( data_lab_hstr       ),
    .i_hend         ( data_lab_hend       ),
    .i_href         ( data_lab_href       ),
    .clk            ( clk          ),
    .rst_n          ( rst_n        )
);

generate 
  if(GENERATE_SEL==3) begin 
ip_lms2rgb_ycbcr_psft#(
    .CIIW       ( CIIW_LMS_SFT ),
    .CIPW       ( CIPW_LMS_SFT ),
    .COIW       ( COIW_LMS_SFT ),
    .COPW       ( COPW_LMS_SFT ),
    .YCBCR_POS  ( YCBCR_POS ),
    .OUT_TYPE   ( OUT_TYPE )
)u_ip_lms2rgb_ycbcr_psft(
    .o_data_ch1 ( data_ch1_p ),
    .o_data_ch2 ( data_ch2_p ),
    .o_data_ch3 ( data_ch3_p ),
    .o_hstr     ( hstr_sft_p  ),
    .o_hend     ( hend_sft_p  ),
    .o_href     ( href_sft_p  ),
    
    .i_data_l   ( data_k2l   ),
    .i_data_m   ( data_k2m   ),
    .i_data_s   ( data_k2s   ),
    .i_hstr     ( hstr_k2l     ),
    .i_hend     ( hend_k2l     ),
    .i_href     ( href_k2l     ),
    .clk        ( clk        ),
    .rst_n      ( rst_n      )
);

ip_lms2rgb_ycbcr_rsft#(

    .CIIW       ( CIIW_LMS_SFT ),
    .CIPW       ( CIPW_LMS_SFT ),
    .COIW_YUV   ( COIW_LY ),
    .COPW_YUV   ( COPW_LY ),
    .COIW_RGB   ( COIW_LR ),
    .COPW_RGB   ( COPW_LR ),
    .YCBCR_POS  ( YCBCR_POS )
    
)u_ip_lms2rgb_ycbcr_rsft(
    .o_data_ch1 ( data_ch1_r ),
    .o_data_ch2 ( data_ch2_r ),
    .o_data_ch3 ( data_ch3_r ),
    .o_hstr     ( hstr_sft_r   ),
    .o_hend     ( hend_sft_r   ),
    .o_href     ( href_sft_r   ),
    
    .i_data_l   ( data_k2l   ),
    .i_data_m   ( data_k2m   ),
    .i_data_s   ( data_k2s   ),
    .i_hstr     ( hstr_k2l     ),
    .i_hend     ( hend_k2l     ),
    .i_href     ( href_k2l     ),
    .r_conv_sel ( r_conv_sel ),
    .clk        ( clk        ),
    .rst_n      ( rst_n      )
);

  end 
  else begin 
ip_lms2ycbcr#(
    .CIIW      ( CIIW_LR ),
    .CIPW      ( CIPW_LR ),
    .COIW      ( COIW_LY ),
    .COPW      ( COPW_LY ),
    .YCBCR_POS ( YCBCR_POS) 
)u_ip_lms2ycbcr(
    .o_data_y  ( data_l2y  ),
    .o_data_cb ( data_l2cb ),
    .o_data_cr ( data_l2cr ),
    .o_hstr    ( hstr_l2y    ),
    .o_hend    ( hend_l2y    ),
    .o_href    ( href_l2y    ),
    
    .i_data_l  ( data_k2l  ),
    .i_data_m  ( data_k2m  ),
    .i_data_s  ( data_k2s  ),
    .i_hstr    ( hstr_k2l    ),
    .i_hend    ( hend_k2l    ),
    .i_href    ( href_k2l    ),
    .clk       ( clk       ),
    .rst_n     ( rst_n     )

);

ip_lms2rgb#(
    .CIIW           ( CIIW_LR  ),
    .CIPW           ( CIPW_LR  ),
    .COIW           ( COIW_LR  ),
    .COPW           ( COPW_LR  )
)u_ip_lms2rgb(
    .o_data_r       ( data_l2r ),
    .o_data_g       ( data_l2g ),
    .o_data_b       ( data_l2b ),
    .o_hstr         ( hstr_l2r ),
    .o_hend         ( hend_l2r ),
    .o_href         ( href_l2r ),
    
    .i_data_l       ( data_k2l ),
    .i_data_m       ( data_k2m ),
    .i_data_s       ( data_k2s ),
    .i_hstr         ( hstr_k2l ),
    .i_hend         ( hend_k2l ),
    .i_href         ( href_k2l ),
    .clk            ( clk      ),
    .rst_n          ( rst_n    )
);
end 
endgenerate 

//--------------------------------------------------------------------------------
// register setting (override initial value)
//--------------------------------------------------------------------------------
initial begin: REG_INI
  reg_ini_done = 0;
  reg_ini.open_ini(ini_file_name);
  @ (posedge clk);
  reg_ini_done = 1;
end

//================================================================================
//  task
//================================================================================
task nope;
input port1;
input port2;
endtask 

//--------------------------------------------------------------------------------
// simulation patten
//--------------------------------------------------------------------------------

assign mon_hstr   = (ini_source_sel == 3'd5) ? hstr_sft_r  :(ini_source_sel == 3'd4) ? hstr_sft_p  :((ini_source_sel == 3'd3) | (ini_source_sel == 3'd7)) ? hstr_l2y  : 
                    (ini_source_sel == 3'd2) ? hstr_r2y    : ((ini_source_sel == 3'd1) | (ini_source_sel == 3'd6)) ? hstr_l2k                                         : hstr_l2r;
assign mon_hend   = (ini_source_sel == 3'd5) ? hend_sft_r  :(ini_source_sel == 3'd4) ? hend_sft_p  :((ini_source_sel == 3'd3) | (ini_source_sel == 3'd7)) ? hend_l2y  : 
                    (ini_source_sel == 3'd2) ? hend_r2y    : ((ini_source_sel == 3'd1) | (ini_source_sel == 3'd6)) ? hend_l2k                                         : hend_l2r;
assign mon_href   = (ini_source_sel == 3'd5) ? href_sft_r  :(ini_source_sel == 3'd4) ? href_sft_p  :((ini_source_sel == 3'd3) | (ini_source_sel == 3'd7)) ? href_l2y  : 
                    (ini_source_sel == 3'd2) ? href_r2y    : ((ini_source_sel == 3'd1) | (ini_source_sel == 3'd6)) ? href_l2k                                         : href_l2r;
assign mon_data_1 = (ini_source_sel == 3'd5) ? data_ch1_r  :(ini_source_sel == 3'd4) ? data_ch1_p  :((ini_source_sel == 3'd3) | (ini_source_sel == 3'd7)) ? data_l2y  : 
                    (ini_source_sel == 3'd2) ? data_r2y    : ((ini_source_sel == 3'd1) | (ini_source_sel == 3'd6)) ? {1'b0,data_l2l}                                  : data_l2r;
assign mon_data_2 = (ini_source_sel == 3'd5) ? data_ch2_r  :(ini_source_sel == 3'd4) ? data_ch2_p  :((ini_source_sel == 3'd3) | (ini_source_sel == 3'd7)) ? data_l2cb : 
                    (ini_source_sel == 3'd2) ? data_r2cb   : ((ini_source_sel == 3'd1) | (ini_source_sel == 3'd6)) ? {1'b0,data_l2a_sgn[COIW_AB_LK +COPW_AB_LK-1:0]}  : data_l2g;
assign mon_data_3 = (ini_source_sel == 3'd5) ? data_ch3_r  :(ini_source_sel == 3'd4) ? data_ch3_p  :((ini_source_sel == 3'd3) | (ini_source_sel == 3'd7)) ? data_l2cr : 
                    (ini_source_sel == 3'd2) ? data_r2cr   : ((ini_source_sel == 3'd1) | (ini_source_sel == 3'd6)) ? {1'b0,data_l2b_sgn[COIW_AB_LK +COPW_AB_LK-1:0]}  : data_l2b;

ppm_monitor #( 
            .DUT_NAME     (DUT_NAME),
            .PX_FMT       (MON_PX_FMT), //change type with ini file 
            .PX_RATE      (1),
            .IMG_HSZ      (1920),
            .IMG_VSZ      (1080),
            .GOLD_HOFT    (0),
            .GOLD_VOFT    (0)
         )
ppm_monitor_0  (

            .vstr         (i_vstr),          
            .vend         (i_vend),            
            .hstr         (mon_hstr),           
            .hend         (mon_hend),            
            .dvld         (mon_href),              
            .bidx         (1'b0),         
            .data         ({mon_data_3[DATA_BIT_WID-1:0],mon_data_2[DATA_BIT_WID-1:0],mon_data_1[DATA_BIT_WID-1:0]}),         
            .clk          (clk),           
            .rst_n        (rst_n)       
);




//--------------------------------------------------------------------------------
//  waveform dump setting
//--------------------------------------------------------------------------------

initial begin 
  if(GENERATE_SEL == 0) 
      $fsdbDumpfile("./wave/color_convert_0_tb");
  else
    if(GENERATE_SEL == 1)
      $fsdbDumpfile("./wave/color_convert_1_tb");
    else
      if(GENERATE_SEL == 2)
        $fsdbDumpfile("./wave/color_convert_2_tb");
      else
        if(GENERATE_SEL == 3)
          $fsdbDumpfile("./wave/color_convert_3_tb");
end 
  
initial begin 
      $fsdbDumpvars(0,color_convert_tb,"+all");
      $fsdbDumpvars(0,color_convert_tb.sensor.SSR_PPM[0],"+functions");
      wait(~ssr_vend)
      wait(ssr_vend)
      #1000
      $display("\n\n test finish");
      $finish;
end

//--------------------------------------------------------------------------------
//  register initial procedure
//--------------------------------------------------------------------------------
reg_ini
reg_ini();

//--------------------------------------------------------------------------------

endmodule       
