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
`define   TB_TOP            dpc_tb
`define   MONITOR_TOP       tb_dpc_mon
`define   DPC_TOP           `TB_TOP.dpc_top
`define   LINE_BUF          `DPC_TOP.line_buf_top
`define   SSR_TOP_0         `TB_TOP.sensor_0       //get error when scarcing this parameter
`define   SSR_TOP_1         `TB_TOP.sensor_1       //get error when scarcing this parameter
`define   HOST_WR           nope                   //get error when scarcing this parameter
`define   PPM_MON           `TB_TOP.ppm_monitor
// module start 
module dpc_tb();

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
parameter           IMG_HSZ_WTH             = $clog2 (IMG_HSZ);
parameter           IMG_VSZ_WTH             = $clog2 (IMG_VSZ);
parameter           COORD_PACK              = 2;
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
parameter          PX_FMT                   = (DBUF_DW == 10)? "RGB10" : "RGB12";
                                              
parameter           SSR_PX_WTH              = SSR_PX_SZ_MAX/3;

// pixel data color sequence (only valid when SSR_PX_RATE !=1)
parameter           SSR_PX_CSEQ             = "G_LSB";

// exposure rate (exposure number per frame)
parameter           SSR_EXPO_RATE           = 1;

//-----------------------------------------------------------------ppm monitor 
parameter           DUT_NAME                = "DPC";

//----------------------------------------------------------------dpc    
parameter  MAX_DPC_NUM        = 512;
parameter  MAX_DPC_NUM_WTH    = $clog2(MAX_DPC_NUM);
parameter  MAX_COORD_NUM      = 20;
parameter  MAX_COORD_NUM_WTH  = $clog2(MAX_COORD_NUM);
      
//================================================================================
//  signal declaration
//================================================================================
//----------------------------------------------------------------------------------------config
reg                                       TB_SYS_CLK;
reg                                       reg_ini_done;

//----------------------------------------------------------------------------------------tb 
reg                                       rst_n;
reg                                       clk;
reg                                       rst_2_n;
reg                                       gated_clk;
reg                                       en_pulse;
wire        [SSR_PX_SZ-1:0]               i_data_0;
wire                                      i_hstr_0;
wire                                      i_href_0;
wire                                      i_hend_0;
wire                                      i_vstr_0;
wire                                      i_vend_0;
reg                                       i_fstr_0;

reg                                       i_href_0_dly;
reg         [SSR_PX_SZ-1:0]               i_data_0_dly;
reg                                       i_hstr_0_dly;

integer                                   seed;

reg         [IMG_HSZ_WTH-1 : 0]           tb_dpc_hor_cnt;
wire        [IMG_HSZ_WTH-1 : 0]           tb_dpc_hor_cnt_nxt;
wire                                      tb_dpc_hor_cnt_inc;
wire                                      tb_dpc_hor_cnt_clr;
wire                                      tb_dpc_hor_cnt_set;
wire        [IMG_HSZ_WTH-1 : 0]           tb_dpc_hor_cnt_set_val;

reg         [IMG_HSZ_WTH-1 : 0]           tb_dpc_ver_cnt;
wire        [IMG_HSZ_WTH-1 : 0]           tb_dpc_ver_cnt_nxt;
wire                                      tb_dpc_ver_cnt_inc;
wire                                      tb_dpc_ver_cnt_clr;

reg         [20*24-1:0]                   r_static_coord;
reg         [20*24-1:0]                   static_coord;
wire                                      tb_dpc_ver_eq;
wire                                      tb_dpc_hor_eq;
reg                                       tb_dpc_tgl;
wire                                      tb_dpc_tgl_nxt;

reg                                 cu_tsk_trg_i;
//----------------------------------------------------------------------------------------sensor
wire        [SSR_PX_SZ-1:0]         ssr_data_0;  
reg         [SSR_PX_SZ-1:0]         ssr_data_0_dly;  
wire                                ssr_field_0;   
wire                                ssr_href_0;
wire                                ssr_hstr_0;
wire                                ssr_hend_0;
wire                                ssr_vstr_0;
wire                                ssr_vend_0;
reg                                 ssr_vend_0_dly;
reg                                 ssr_vend_0_dly2;
reg                                 ssr_href_0_dly;

wire        [23:0]                  ssr_data_1;
wire                                ssr_href_1;
reg                                 ssr_href_1_dly;

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

//----------------------------------------------------------------------------------------dpc
reg [DPC_NUM*(RAW_CIIW+RAW_CIPW)-1:0]      dpc_data;
reg                           dpc_href;
reg                           dpc_vstr;
reg                           dpc_hstr;
reg                           dpc_hend;
reg                           dpc_vend;
reg [MAX_DPC_NUM_WTH-1:0]          o_wdpc_cnt;           //white point counter , contain static and dynamic 
reg [MAX_DPC_NUM_WTH-1:0]          o_bdpc_cnt;
reg [MAX_COORD_NUM-1:0]            o_static_num_cnt;

//----------------------------------------------------------------------------------------dpc insert 
wire [(RAW_CIIW+RAW_CIPW)-1:0]     insert_data;
wire                               insert_dvld;
    
//--------------------------------------------------------------------------------
//  clocking and reset
//--------------------------------------------------------------------------------


initial  begin 

 rst_n=0;
 
 repeat (10) @(posedge clk);
 
 rst_n=1;
 
end

initial begin 
 #3
 rst_2_n=0;
 repeat (10) @(posedge gated_clk);
 rst_2_n=1;

end 

initial begin 
clk = 0;
forever #(PERIOD/2) clk = ~clk;
end

initial begin 
gated_clk = 0;
forever #(PERIOD/2) gated_clk = ~gated_clk;
end

//================================================================================
//  behavior description
//================================================================================
//----------------------------------------------------------------------------------tb
assign tb_dpc_hor_cnt_nxt = (tb_dpc_hor_cnt_set ? tb_dpc_hor_cnt_set_val : tb_dpc_hor_cnt_inc ? tb_dpc_hor_cnt + 1'b1 : tb_dpc_hor_cnt) & {IMG_HSZ_WTH{~tb_dpc_hor_cnt_clr}};
assign tb_dpc_hor_cnt_inc = i_href_0;
assign tb_dpc_hor_cnt_clr = 1'b0;
assign tb_dpc_hor_cnt_set = i_hstr_0;
assign tb_dpc_hor_cnt_set_val = 10'd6;

assign tb_dpc_ver_cnt_nxt = (tb_dpc_ver_cnt_inc ? tb_dpc_ver_cnt + 1'b1 : tb_dpc_ver_cnt) & {IMG_VSZ_WTH{~tb_dpc_ver_cnt_clr}};
assign tb_dpc_ver_cnt_inc = `DPC_TOP.line_bf_hend;
assign tb_dpc_ver_cnt_clr = `DPC_TOP.line_bf_vend;

      
always@* begin 
  case(ini_src_sel)  
 10'd0 : r_static_coord =               {
{1'b0, 11'd235, 1'b0, 11'd296},
{1'b0, 11'd231, 1'b1, 11'd113},
{1'b0, 11'd229, 1'b1, 11'd252},
{1'b0, 11'd228, 1'b0, 11'd139},
{1'b0, 11'd209, 1'b0, 11'd84},
{1'b0, 11'd208, 1'b1, 11'd317},
{1'b0, 11'd191, 1'b0, 11'd373},
{1'b0, 11'd178, 1'b1, 11'd27},
{1'b0, 11'd175, 1'b0, 11'd446},
{1'b0, 11'd168, 1'b0, 11'd371},
{1'b0, 11'd165, 1'b1, 11'd194},
{1'b0, 11'd164, 1'b0, 11'd185},
{1'b0, 11'd144, 1'b1, 11'd55},
{1'b0, 11'd143, 1'b0, 11'd214},
{1'b0, 11'd134, 1'b1, 11'd36},
{1'b0, 11'd119, 1'b0, 11'd96},
{1'b0, 11'd108, 1'b1, 11'd316},
{1'b0, 11'd54, 1'b1, 11'd294},
{1'b0, 11'd45, 1'b1, 11'd334},
{1'b0, 11'd43, 1'b1, 11'd86}};

  10'd2 :  r_static_coord =              {
{1'b0, 11'd212, 1'b0, 11'd51},
{1'b0, 11'd210, 1'b0, 11'd15},
{1'b0, 11'd186, 1'b0, 11'd41},
{1'b0, 11'd173, 1'b0, 11'd370},
{1'b0, 11'd164, 1'b0, 11'd420},
{1'b0, 11'd161, 1'b1, 11'd29},
{1'b0, 11'd155, 1'b0, 11'd200},
{1'b0, 11'd140, 1'b0, 11'd256},
{1'b0, 11'd124, 1'b1, 11'd268},
{1'b0, 11'd114, 1'b0, 11'd309},
{1'b0, 11'd107, 1'b0, 11'd13},
{1'b0, 11'd104, 1'b1, 11'd361},
{1'b0, 11'd83, 1'b1, 11'd282},
{1'b0, 11'd80, 1'b1, 11'd72},
{1'b0, 11'd64, 1'b1, 11'd87},
{1'b0, 11'd60, 1'b1, 11'd14},
{1'b0, 11'd58, 1'b1, 11'd347},
{1'b0, 11'd43, 1'b0, 11'd133},
{1'b0, 11'd23, 1'b1, 11'd278},
{1'b0, 11'd0, 1'b1, 11'd314}};

  10'd8 :  r_static_coord =                {
{1'b0, 11'd212, 1'b0, 11'd419},
{1'b0, 11'd208, 1'b0, 11'd461},
{1'b0, 11'd203, 1'b0, 11'd291},
{1'b0, 11'd180, 1'b0, 11'd339},
{1'b0, 11'd164, 1'b0, 11'd353},
{1'b0, 11'd152, 1'b0, 11'd33},
{1'b0, 11'd138, 1'b0, 11'd61},
{1'b0, 11'd128, 1'b1, 11'd390},
{1'b0, 11'd127, 1'b1, 11'd41},
{1'b0, 11'd110, 1'b0, 11'd76},
{1'b0, 11'd94, 1'b1, 11'd327},
{1'b0, 11'd51, 1'b0, 11'd287},
{1'b0, 11'd47, 1'b0, 11'd286},
{1'b0, 11'd45, 1'b0, 11'd22},
{1'b0, 11'd36, 1'b0, 11'd426},
{1'b0, 11'd36, 1'b1, 11'd349},
{1'b0, 11'd32, 1'b1, 11'd222},
{1'b0, 11'd22, 1'b1, 11'd425},
{1'b0, 11'd19, 1'b1, 11'd360},
{1'b0, 11'd6, 1'b1, 11'd411}};

default : r_static_coord =  0;

endcase

end 

assign tb_dpc_hor_eq  = (tb_dpc_hor_cnt == static_coord[IMG_HSZ_WTH-1:0]) & (tb_dpc_hor_cnt != 0);
assign tb_dpc_ver_eq  = (tb_dpc_ver_cnt == static_coord[IMG_HSZ_WTH+:IMG_HSZ_WTH]) & (tb_dpc_hor_cnt != 0);
assign tb_dpc_tgl_nxt = tb_dpc_tgl ^ (tb_dpc_hor_eq & tb_dpc_ver_eq);
//----------------------------------------------------------------------------------sensor
initial begin
i_fstr_0 = 0;
wait(~reg_ini_done)
wait(reg_ini_done)
#1000
`SSR_TOP_0.sensor_en = 1'b1;
`SSR_TOP_1.sensor_en = 1'b1;
  @ (posedge clk);
  @ (posedge clk);
i_fstr_0  = 1;
  @ (posedge clk);
i_fstr_0  = 0;
end

assign ssr_hstr_0  = ssr_href_0 & !ssr_href_0_dly;
assign ssr_hend_0  = !ssr_href_0 & ssr_href_0_dly;

assign i_data_0    = ssr_data_0_dly;
assign i_hstr_0    = ssr_hstr_0;
assign i_href_0    = ssr_href_0_dly;
assign i_hend_0    = ssr_hend_0;
assign i_vstr_0    = ssr_vstr_0;
assign i_vend_0    = ssr_vend_0_dly2;

always@(posedge clk or negedge rst_n) begin 
  if(!rst_n) begin 
    ssr_href_0_dly     <= 0;
    ssr_href_1_dly     <= 0;
    ssr_data_0_dly     <= 0;
    ssr_vend_0_dly     <= 0;
    ssr_vend_0_dly2    <= 0;
    i_hstr_0_dly       <= 0;
    i_href_0_dly       <= 0;
    i_data_0_dly       <= 0;
    tb_dpc_hor_cnt     <= 0;
    tb_dpc_ver_cnt     <= 0;
    static_coord       <= 0;
    tb_dpc_tgl         <= 0;
    
  end 
  else  begin 
    ssr_href_0_dly     <= ssr_href_0;
    ssr_href_1_dly     <= ssr_href_1;
    ssr_data_0_dly     <= {ssr_data_0[SSR_PX_WTH-1:0],ssr_data_0[SSR_PX_WTH*2-1:SSR_PX_WTH],ssr_data_0[SSR_PX_WTH*3-1:SSR_PX_WTH*2]};
    ssr_vend_0_dly     <= ssr_vend_0;
    ssr_vend_0_dly2    <= ssr_vend_0_dly;
    i_hstr_0_dly       <= i_hstr_0;
    i_href_0_dly       <= i_href_0;
    i_data_0_dly       <= i_data_0;
    tb_dpc_hor_cnt     <= tb_dpc_hor_cnt_nxt;
    tb_dpc_ver_cnt     <= tb_dpc_ver_cnt_nxt;
    static_coord       <= r_static_coord;
    tb_dpc_tgl         <= tb_dpc_tgl_nxt;
    
  end
end 

//================================================================================
//  module instantiation
//================================================================================

sensor

#(.PX_RATE   (SSR_PX_RATE),

  .PX_FMT    (SSR_PX_FMT),

  .PX_CSEQ   ("NORMAL"),

  .EXPO_RATE (1),

  .SHOW_MSG  (1) ,
  
  .ODATA_FREQ  (ODATA_FREQ),
  
  .IMG_SEL     (0))

sensor_0(
// output
      .ssr_vsync              (),
      .ssr_vref               (),

      .ssr_hsync              (),
      .ssr_href               (ssr_href_0),

      .ssr_blue               (),
      .ssr_hbyps              (),
      .ssr_field              (ssr_field_0),

      .ssr_vstr               (ssr_vstr_0),
      .ssr_vend               (ssr_vend_0),

      .ssr_data               (ssr_data_0),

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

      .reg_tpat_en            (ini_sensor_tpat_en[0]), //control 1:counter ; 0:picture 
      .reg_dvp_x1             (1'b0),

      .reg_tv_pal             (1'b0),
      .reg_pal_cyc_ofst       (sensor_pal_cyc_ofst),

      .reg_field_hofst        (sensor_field_hofst),
      .reg_field_vofst        (sensor_field_vofst),

// clk
      .clk                    (clk),
      .rst_n                  (rst_n)
);

sensor

#(.PX_RATE   (SSR_PX_RATE),

  .PX_FMT    (SSR_PX_FMT),

  .PX_CSEQ   ("NORMAL"),

  .EXPO_RATE (1),

  .SHOW_MSG  (1) ,
  
  .ODATA_FREQ  (ODATA_FREQ),
  
  .IMG_SEL     (1))

sensor_1(
// output
      .ssr_vsync              (),
      .ssr_vref               (),

      .ssr_hsync              (),
      .ssr_href               (),

      .ssr_blue               (),
      .ssr_hbyps              (),
      .ssr_field              (),

      .ssr_vstr               (),
      .ssr_vend               (),

      .ssr_data               (),

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

      .reg_tpat_en            (ini_sensor_tpat_en[0]), //control 1:counter ; 0:picture 
      .reg_dvp_x1             (1'b0),

      .reg_tv_pal             (1'b0),
      .reg_pal_cyc_ofst       (sensor_pal_cyc_ofst),

      .reg_field_hofst        (sensor_field_hofst),
      .reg_field_vofst        (sensor_field_vofst),

// clk
      .clk                    (clk),
      .rst_n                  (rst_n)
);

initial begin 

 seed = 55;

end 

initial begin 
wait(~i_fstr_0)
wait(i_fstr_0)

 $display("ini_src_sel : %d ",ini_src_sel);
 
end 
                           
assign i_raw_dvld = 1'b1;

initial begin 
 cu_tsk_trg_i     = 0; 
 
 repeat(100) @ (posedge clk);
  
 cu_tsk_trg_i     = 1;
 
 repeat(1) @ (posedge clk);
 cu_tsk_trg_i     = 0;
 
end 

/*
dpc_insert#(
    .INS_CIW   ( 10 ),
    .STEP_WTH   ( 8 )
)u_dpc_insert(
    .o_data     ( insert_data     ),
    .o_dvld     ( insert_dvld     ),
    
    .i_raw_data ( i_data_0 ),
    .i_data_vld ( i_href_0 ),
    .i_hstr     ( i_hstr_0     ),
    
    .r_mode_sel ( 1'b1 ),
    .r_clr_chg  ( 8'd125 ),
    .r_hstep    ( 8'd10    ),
    .r_vstep    ( 8'd15    ),
    
    .clk        (clk),
    .rst_n      (rst_n)
);
*/

dpc_top#(
//----------------------------------------------------------------dpc top 
        .DPC_NUM                    (DPC_NUM        ),
        
//----------------------------------------------------------------insert dpc 
        .INS_CIW                    (INS_CIW        ),
        
//----------------------------------------------------------------dpc para
        .ALG_LVL                    (ALG_LVL),
        .ALG_MODE                   (ALG_MODE       ),
        .IMG_HSZ                    (IMG_HSZ        ),
        .IMG_VSZ                    (IMG_VSZ        ),

//----------------------------------------------------------------line buffer para
        .ODATA_FREQ                 (ODATA_FREQ     ),
        .BUF_PIXEL_DLY              (BUF_PIXEL_DLY  ),
        .BUF_LINE_DLY               (BUF_LINE_DLY   ),
        .MEM_TYPE                   (MEM_TYPE       ),
        .MEM_NAME                   (MEM_NAME       ),
        .SRAM_NUM                   (SRAM_NUM       ) 

       
        )dpc_top(
//---------------------------------------------------------------------------------output 
    .o_dpc_data                       ( dpc_data),
    .o_dpc_href                       ( dpc_href              ),
    .o_dpc_hstr                       ( dpc_hstr              ),
    .o_dpc_hend                       ( dpc_hend              ),
    .o_dpc_bidx                       (                       ),
    .o_dpc_wdpc_cnt                   ( o_wdpc_cnt),
    .o_dpc_bdpc_cnt                   ( o_bdpc_cnt),
    .o_static_num_cnt                 ( o_static_num_cnt),

//---------------------------------------------------------------------------------input 
//----------------------------------------------------------------line buf
    .i_fstr                           ( i_fstr_0                ),
    .i_hend                           ( i_hend_0                ),

//----------------------------------------------------------------insert dpc 
    .i_data                           ( {i_data_0[RAW_CIIW-1:0],i_data_0[RAW_CIIW-1:0]}                ),
    .i_hstr                           ( i_hstr_0                ),
    .i_href                           ( i_href_0                ),
    
//----------------------------------------------------------------dpc
    .i_dpc_bidx                       ( 1'b1                    ),           //VCNT_WD.0  
    .i_dpc_ver_addr                   ( tb_dpc_ver_cnt          ), 
    
//---------------------------------------------------------------------------------register 
//----------------------------------------------------------------dpc 
    .r_step1_w_low_nlm                ( r_step1_w_low_nlm[5-1:0]     ), //3.2
    .r_step1_w_transit_rng            ( r_step1_w_transit_rng[3-1:0] ), //3.0
    .r_step1_b_low_nlm                ( r_step1_b_low_nlm[5-1:0]     ), //3.2
    .r_step1_b_transit_rng            ( r_step1_b_transit_rng[3-1:0] ), //3.0
    
    .r_step2_w_rto_thres              ( r_step2_w_rto_thres[5-1:0]   ), //3.2
    .r_step2_w_buf_rng                ( r_step2_w_buf_rng[3-1:0]     ), //3.0
    .r_step2_b_rto_thres              ( r_step2_b_rto_thres[5-1:0]   ),
    .r_step2_b_buf_rng                ( r_step2_b_buf_rng[3-1:0]     ),
    
    .r_step2_w_cnt_thres              ( r_step2_w_cnt_thres[6-1:0]   ),
    .r_step2_w_cnt_buf_rng            (r_step2_w_cnt_buf_rng[3-1:0]),
    .r_step2_b_cnt_thres              (r_step2_b_cnt_thres[6-1:0]),
    .r_step2_b_cnt_buf_rng            (r_step2_b_cnt_buf_rng[3-1:0]),
    
    .r_dpc_en                         (r_dpc_en[1-1:0]),
    .r_dpc_debug_en                   (r_debug_en[1-1:0]),
    .r_dpc_mode_sel                   (r_mode_sel[2-1:0]),
    .r_dpc_repl_col                   (r_repl_col[RAW_CIIW-1:0]),
    
    .r_dpc_static_coord               (r_static_coord[480-1:0]),
    .r_dpc_coord_mirror               (r_coord_mirror[1-1:0]),
    .r_dpc_haddr_start                (11'd0),
    
//----------------------------------------------------------------cu 
    .r_ssr_again                      ( r_ssr_again[9-1:0]           ),
    .r_ssr_blc_tgt                    ( r_ssr_blc_tgt[12-1:0]         ),
    .r_ssr_drkc                       ( r_ssr_drkc[12-1:0]            ),
    .r_ssr_cgcf                       ( r_ssr_cgcf[12-1:0]            ),
    .r_ssr_ns_parm1                   ( r_ssr_ns_parm1[10-1:0]        ),
    .r_ssr_ns_parm2                   ( r_ssr_ns_parm2[4-1:0]        ),

//----------------------------------------------------------------insert dpc   
    .r_ins_en                         (1'b0),
    .r_ins_mode_sel                   (1'b1 ),
    .r_ins_clr_chg                    (10'd125),
    .r_ins_hstep                      (8'd3),
    .r_ins_vstep                      (8'd5),
    
//---------------------------------------------------------------------------------general 
    .clk                              ( clk),
    .gated_clk                        ( gated_clk),
    .rst_n                            ( rst_n)
);


//-----------------------------------------------------------------------------
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
            .PX_FMT       (PX_FMT),
            .IMG_HSZ      (IMG_HSZ),
            .IMG_VSZ      (IMG_VSZ),
            .GOLD_HOFT    (0),
            .GOLD_VOFT    (0)
         )
ppm_monitor_0  (

            .vstr         (ssr_vstr_0),          
            .vend         (ssr_vend_0),            
            .hstr         (dpc_hstr),           
            .hend         (dpc_hend),            
            .dvld         (dpc_href),              
            .bidx         (1'b0),         
            .data         ({dpc_data[RAW_CIIW*ini_golden_sel+:RAW_CIIW],dpc_data[RAW_CIIW*ini_golden_sel+:RAW_CIIW],dpc_data[RAW_CIIW*ini_golden_sel+:RAW_CIIW]}),         
            .clk          (clk),           
            .rst_n        (rst_n)       
);

/*
ppm_monitor #(
            .DUT_NAME     (DUT_NAME),
            .PX_FMT       (PX_FMT),
            .IMG_HSZ      (IMG_HSZ),
            .IMG_VSZ      (IMG_VSZ),
            .GOLD_HOFT    (0),
            .GOLD_VOFT    (0)
         )
ppm_monitor_0  (

            .vstr         (i_vstr_0),          
            .vend         (i_hend_0),            
            .hstr         (i_hstr_0),           
            .hend         (i_hend_0),            
            .dvld         (insert_dvld),              
            .bidx         (1'b0),         
            .data         ({insert_data,insert_data,insert_data}),         

            .clk          (clk),           
            .rst_n        (rst_n)       
);
*/
//--------------------------------------------------------------------------------
//  waveform dump setting
//--------------------------------------------------------------------------------

initial begin 
      $fsdbDumpfile("./wave/dpc_tb");
      $fsdbDumpvars(0,dpc_tb,"+all");
      wait(!dpc_vend)
      wait(dpc_vend)
   //   wait(!dpc_vend)
   //   wait(dpc_vend)
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
