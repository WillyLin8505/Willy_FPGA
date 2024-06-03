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
// Description     :
// ------------------------------------------------------------------------------//

// defination & include
`timescale 1ns/1ns  
`define   TB_TOP            tone_mapping_tb
`define   MONITOR_TOP       tone_mapping_mon
`define   TONE_MAPPING      `TB_TOP.tone_mapping

`define   SSR_TOP           `TB_TOP.sensor       //get error when scarcing this parameter
`define   HOST_WR           nope                 //get error when scarcing this parameter
`define   PPM_MON           `TB_TOP.ppm_monitor
// module start 
module tone_mapping_tb();

//================================================================================
// simulation config console
//================================================================================
`include "tb_parameter.vh"
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
//----------------------------------------------------------------tb
parameter           PERIOD                  = 10;
parameter           LUT_MAP_NUM             = (SEL_CURVE == "REFI_L") ? 25 : 
                                              (SEL_CURVE == "REFI_C") ? 9  : 25;
                               
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
                                              (SSR_PX_FMT == "RGB16")? 48 : 24;

parameter           SSR_PX_SZ_MAX           = (SSR_PX_FMT == "RAW8" )? 8  :
                                              (SSR_PX_FMT == "RAW10")? 10 :
                                              (SSR_PX_FMT == "RAW12")? 12 :
                                              (SSR_PX_FMT == "RGB8" )? 24 :
                                              (SSR_PX_FMT == "RGB10")? 30 :
                                              (SSR_PX_FMT == "RGB12")? 36 :
                                              (SSR_PX_FMT == "RGB14")? 42 :
                                              (SSR_PX_FMT == "RGB16")? 48 : 24;


parameter           SSR_PX_WTH              = SSR_PX_SZ_MAX/3;

// pixel data color sequence (only valid when SSR_PX_RATE !=1)
parameter           SSR_PX_CSEQ             = "G_LSB";

// exposure rate (exposure number per frame)
parameter           SSR_EXPO_RATE           = 1;

//----------------------------------------------------------------monitor
parameter           DUT_NAME                = "TONE_MAPPING";
parameter           MON_WTH                 = (MON_PX_FMT == "RGB8" )? 8 :
                                              (MON_PX_FMT == "RGB10")? 10 :
                                              (MON_PX_FMT == "RGB12")? 12 :
                                              (MON_PX_FMT == "RGB14")? 14 :
                                              (MON_PX_FMT == "RGB16")? 16 : 8;

//================================================================================
//  signal declaration
//================================================================================
//----------------------------------------------------------------------------------------config
reg                                 TB_SYS_CLK;
reg                                 reg_ini_done;

//----------------------------------------------------------------------------------------tb 
reg                                 rst_n;
reg                                 clk;
reg                                 data_fstr;
reg   [LUT_MAP_WTH*LUT_MAP_NUM-1:0] l_tone_y_data = {Y_DATA_24,Y_DATA_23,Y_DATA_22,Y_DATA_21,Y_DATA_20,Y_DATA_19,Y_DATA_18,Y_DATA_17,Y_DATA_16,Y_DATA_15,
                                                     Y_DATA_14,Y_DATA_13,Y_DATA_12,Y_DATA_11,Y_DATA_10,Y_DATA_9,Y_DATA_8,Y_DATA_7,Y_DATA_6,Y_DATA_5,Y_DATA_4,
                                                     Y_DATA_3,Y_DATA_2,Y_DATA_1,Y_DATA_0};
                                                     
//----------------------------------------------------------------------------------------sensor
wire        [SSR_EXPO_RATE-1:0]     ssr_dvp_href;                 //
wire        [SSR_PX_SZ_MAX-1:0]     ssr_dvp_data;  
reg         [SSR_PX_SZ_MAX-1:0]     ssr_dvp_data_dly;  
wire                                ssr_field;   
wire                                ssr_href;

wire        [CIW-1:0]               sensor_ch_0;
wire        [CIW-1:0]               sensor_ch_1;
wire        [CIW-1:0]               sensor_ch_2;

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

wire                                ssr_hstr;
wire                                ssr_hend;
wire                                ssr_vstr;
wire                                ssr_vend;
reg                                 ssr_vend_dly;
reg                                 ssr_vend_dly2;
reg                                 ssr_href_dly;
//-------------------------------------------------

//--------------------------------------------------------------------------------tone mapping 
wire                                tone_mapping_hstr;
wire  [COIW+COPW-1:0]               tone_mapping_data;
wire                                tone_mapping_href;
wire                                tone_mapping_hend;
    
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
`SSR_TOP.sensor_en = 1'b0;
data_fstr = 0;
wait(~reg_ini_done)
wait(reg_ini_done)
#1000
`SSR_TOP.sensor_en = 1'b1;
  @ (posedge clk);
  @ (posedge clk);
data_fstr  = 1;
  @ (posedge clk);
  @ (posedge clk);
data_fstr  = 0;
end

assign ssr_hstr   = ssr_href & !ssr_href_dly;
assign ssr_hend   = !ssr_href & ssr_href_dly;

always@(posedge clk or negedge rst_n) begin 
  if(!rst_n) begin 
    ssr_href_dly     <= 0;
    ssr_dvp_data_dly <= 0;
    ssr_vend_dly     <= 0;
    ssr_vend_dly2    <= 0;
  end 
  else  begin 
    ssr_href_dly     <= ssr_href;
    ssr_dvp_data_dly <= ssr_dvp_data; //R,G,B
    ssr_vend_dly     <= ssr_vend;
    ssr_vend_dly2    <= ssr_vend_dly;
  end
end 

assign sensor_ch_2   = ssr_dvp_data_dly[SSR_PX_SZ/3-1:0];  //b
assign sensor_ch_1   = ssr_dvp_data_dly[SSR_PX_SZ/3*2-1:SSR_PX_SZ/3];  //g
assign sensor_ch_0   = ssr_dvp_data_dly[SSR_PX_SZ/3*3-1:SSR_PX_SZ/3*2]; //r

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

      .reg_hsync_sz           (16'h4),              //control(just control the bit count )
      .reg_hblkf_sz           (ini_sensor_hblkf_sz),//control sync black 
      .reg_hblkb_sz           (ini_sensor_hblkb_sz),//control sync black 

      .reg_vsync_sz           (16'h2),              //control(just control the bit count )
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

tone_mapping#(
    .CIIW        ( CIIW ),
    .CIPW        ( CIPW ),
    .COIW        ( COIW ),
    .COPW        ( COPW ),
    .SEL_CURVE   ( SEL_CURVE )
)u_tone_mapping(
    .o_hstr         ( tone_mapping_hstr      ),
    .o_data         ( tone_mapping_data      ),
    .o_href         ( tone_mapping_href      ),
    .o_hend         ( tone_mapping_hend      ),
    
    .i_data         ( sensor_ch_2      ), //x3_value
    .i_hstr         ( ssr_hstr      ),
    .i_href         ( ssr_href_dly      ),
    .i_hend         ( ssr_hend      ),
    .l_tone_y_data  ( l_tone_y_data[LUT_MAP_WTH*LUT_MAP_NUM-1:0]  ), 
    .clk            (clk),
    .rst_n          (rst_n)
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



ppm_monitor #( 
            .DUT_NAME     (DUT_NAME),
            .PX_FMT       (MON_PX_FMT), //change type with ini file 
            .PX_RATE      (1),
            .IMG_HSZ      (IMG_HSZ),
            .IMG_VSZ      (IMG_VSZ),
            .GOLD_HOFT    (0),
            .GOLD_VOFT    (0)
         )
ppm_monitor_0  (

            .vstr         (ssr_vstr),          
            .vend         (ssr_vend),            
            .hstr         (tone_mapping_hstr),           
            .hend         (tone_mapping_hend),            
            .dvld         (tone_mapping_href),              
            .bidx         (1'b0),         
            .data         ({{{MON_WTH-COIW-COPW{1'b0}},tone_mapping_data},{{MON_WTH-COIW-COPW{1'b0}},tone_mapping_data},{{MON_WTH-COIW-COPW{1'b0}},tone_mapping_data}}),         
            .clk          (clk),           
            .rst_n        (rst_n)       
);

/*
tone_mapping_mon 
tone_mapping_mon();
*/
//--------------------------------------------------------------------------------
//  waveform dump setting
//--------------------------------------------------------------------------------

initial begin 
      $fsdbDumpfile("./wave/tone_mapping_tb");
      $fsdbDumpvars(0,tone_mapping_tb,"+all");
      //$fsdbDumpvars(0,`MONITOR_TOP,"+all");
      wait(~ssr_vend)
      wait(ssr_vend)
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
