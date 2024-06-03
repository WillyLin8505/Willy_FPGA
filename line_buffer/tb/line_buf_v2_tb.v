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
`define   TB_TOP            line_buf_v2_tb
`define   MONITOR_TOP       line_buf_v2_mon
`define   LINE_BUF          `TB_TOP.line_buf_top.line_buf_v2
`define   LINE_RNG          `TB_TOP.line_buf_top.line_rng
`define   LINE_TOP          `TB_TOP.line_buf_top

`define   SSR_TOP_0         `TB_TOP.sensor_0       //get error when scarcing this parameter
`define   SSR_TOP_1         `TB_TOP.sensor_1       //get error when scarcing this parameter
`define   HOST_WR           nope                   //get error when scarcing this parameter
`define   PPM_MON           `TB_TOP.ppm_monitor


// module start 
module line_buf_v2_tb();

//================================================================================
// simulation config console
//================================================================================

`include "reg_wire_declare.name"

string               ini_file_name          = "reg_config.ini";
string               test_pat_name          = "";
string               ppm_file_name          = "";
string               gold_img_num           = "";
string               gold_vec_file          = "one_direction"; 
string               gold_num               = "";
//================================================================================
//  parameter declaration
//================================================================================
`include "tb_parameter.vh"
//----------------------------------------------------------------tb
parameter           PERIOD                  = 10;
parameter           CNT_WTH                = $clog2(DBUF_DEP);

//----------------------------------------------------------------sensor
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

//-----------------------------------------------------------------ppm monitor 
parameter           DUT_NAME                = "LINE_BUF";

//-----------------------------------------------------------------line buffer ver2 
parameter MEM_TYPE     = "1PSRAM";              // "FPGA_BLKRAM", 1PSRAM
    
//================================================================================
//  signal declaration
//================================================================================
//----------------------------------------------------------------------------------------config
reg                                 TB_SYS_CLK;
reg                                 reg_ini_done;

//----------------------------------------------------------------------------------------tb 
reg                                 rst_n;
reg                                 clk;
wire [DBUF_DW-1:0]                  i_data_0;
wire                                i_hstr_0;
wire                                i_href_0;
wire                                i_hend_0;
wire                                i_vstr_0;
wire                                i_vend_0;
reg                                 i_fstr_0;
reg                                 i_href_0_dly;
reg  [DBUF_DW-1:0]                  i_data_0_dly;
    
wire [DBUF_DW-1:0]                  i_data_1;
wire                                i_hstr_1;
wire                                i_href_1;
wire                                i_hend_1;
wire                                i_vstr_1;
wire                                i_vend_1;
reg                                 i_fstr_1;
reg                                 i_href_1_dly;
reg  [DBUF_DW-1:0]                  i_data_1_dly;

reg                                 interrupt_mask;

wire                                control_eq;
reg  [4-1 : 0]                      control_cnt;
wire [4-1 : 0]                      control_cnt_nxt;
wire                                control_cnt_inc;
wire                                control_cnt_clr;

reg                                 o_line_bf_dvld_dly;
reg                                 o_line_bf_dvld_dly2;

reg  [SEN_PIXEL_DLY*CNT_WTH-1:0]    gmem_addra_q;
wire [SEN_PIXEL_DLY*CNT_WTH-1:0 ]   gmem_addra_q_nxt;

reg  [SEN_PIXEL_DLY-1:0]            wb_vld_q;
wire [SEN_PIXEL_DLY-1:0]            wb_vld_q_nxt;

wire [DBUF_DW-1:0]                  i_wb;
wire                                i_wb_vld ;
wire                                i_wb_vend;

reg  [8*SEN_PIXEL_DLY-1:0]          wb_data_que;
wire [8*SEN_PIXEL_DLY-1:0]          wb_data_que_nxt;
reg  [SEN_PIXEL_DLY-1:0]            wb_vld_que;
wire [SEN_PIXEL_DLY-1:0]            wb_vld_que_nxt;
reg  [SEN_PIXEL_DLY-1:0]            wb_hend_que;
wire [SEN_PIXEL_DLY-1:0]            wb_hend_que_nxt; 
reg  [SEN_PIXEL_DLY-1:0]            i_href_1_que;
wire [SEN_PIXEL_DLY-1:0]            i_href_1_que_nxt; 
reg  [SEN_PIXEL_DLY-1:0]            i_hstr_1_que;
wire [SEN_PIXEL_DLY-1:0]            i_hstr_1_que_nxt; 

//----------------------------------------------------------------------------------------sensor
wire [23:0]                         ssr_data_0;  
reg  [23:0]                         ssr_data_0_dly;  
wire                                ssr_field_0;   
wire                                ssr_href_0;
wire                                ssr_hstr_0;
wire                                ssr_hend_0;
wire                                ssr_vstr_0;
wire                                ssr_vend_0;
reg                                 ssr_vend_0_dly;
reg                                 ssr_vend_0_dly2;
reg                                 ssr_href_0_dly;

wire [23:0]                         ssr_data_1;  
reg  [23:0]                         ssr_data_1_dly;  
wire                                ssr_field_1;   
wire                                ssr_href_1;
wire                                ssr_hstr_1;
wire                                ssr_hend_1;
wire                                ssr_vstr_1;
wire                                ssr_vend_1;
reg                                 ssr_vend_1_dly;
reg                                 ssr_vend_1_dly2;
reg                                 ssr_href_1_dly;
//
reg  [15:0]                         reg_ssr_hwin_sz;
reg  [ 3:0]                         reg_ssr_hpad_sz;

reg  [15:0]                         reg_ssr_vwin_sz;
reg  [ 3:0]                         reg_ssr_vpad_sz;

//

wire [15:0]                         sensor_hwin_sz;
wire [15:0]                         sensor_vwin_sz;

wire [ 3:0]                         sensor_hpad_sz;
wire [ 3:0]                         sensor_vpad_sz;

// hsync+hblk = htotal - (hwin+2*hpad) = 1500 - (1280+8*2) = 204
reg [15:0]                          sensor_hsync_sz         = 4;
reg [15:0]                          sensor_hblkf_sz         = SSR_PX_RATE == 4 ?  40 :
                                                             SSR_PX_RATE == 2 ?  80 : 160; // limited by mipi_tx
reg [15:0]                          sensor_hblkb_sz         = SSR_PX_RATE == 4 ?  50 :
                                                             SSR_PX_RATE == 2 ? 100 : 200;

//
reg [15:0]                          sensor_vsync_sz         = 2;
// vblk = vtotal - (vwin+2*vpad) = 750-720 = 30
reg [16*SSR_EXPO_RATE-1:0]          sensor_vblkf1_sz        = (SSR_EXPO_RATE == 2)? {16'd6,16'd2} : 16'd6;
reg [15:0]                          sensor_vblkf2_sz        = 0;
reg [15:0]                          sensor_vblkb1_sz        = 2;
reg [16*SSR_EXPO_RATE-1:0]          sensor_vblkb2_sz        = (SSR_EXPO_RATE == 2)? {16'd2,16'd6} : 16'd4;

//
reg [ 2:0]                          sensor_pal_cyc_ofst     = 2;

//
reg [15:0]                          sensor_field_hofst      = 128;
reg [15:0]                          sensor_field_vofst      = 0;

reg [15:0]                          sensor_field_hofst_1    = 128;
reg [15:0]                          sensor_field_vofst_1    = 0;

//
reg [ 6:0]                          sensor_gain             = 0;
reg                                 sensor_ae_stbl          = 1'b1;
reg                                 sensor_ae_upd           = 1'b0;

//---------------------------------------------------------------------------------------------line buf
wire[DBUF_DW*KRNV_SZ*ODATA_RNG-1:0] o_line_bf_data;
wire                                o_line_bf_dvld;
wire                                o_line_bf_vstr;
wire                                o_line_bf_hstr;
wire                                o_line_bf_hend;
wire                                o_line_bf_vend;
wire                                wb_vld;
wire                                hor_act_line_smo        = `LINE_BUF.hor_act_line_smo; 
wire                                hor_href_eq             = `LINE_BUF.hor_href_eq; 
wire                                hor_line_blk_smo        = `LINE_BUF.hor_line_blk_smo;
wire                                ver_fr_buf_smo          = `LINE_BUF.ver_fr_buf_smo;
wire                                hor_clr_smo             = `LINE_BUF.hor_clr_smo;
wire                                ver_top_pad_smo         = `LINE_BUF.ver_top_pad_smo;

//---------------------------------------------------------------------------------------------bilateral filter 
wire [DBUF_DW-1:0]                  bil_flt_cv_data;
wire                                bil_flt_dvld;
wire                                bil_flt_vstr;
wire                                bil_flt_hstr;
wire                                bil_flt_hend;
wire                                bil_flt_vend;

//---------------------------------------------------------------------------------------------monitor

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

assign control_eq             = control_cnt == 4'd0;           
assign control_cnt_nxt        = (control_cnt_inc ? control_cnt + 1'b1 : control_cnt) & {(5){~control_cnt_clr}}; 
assign control_cnt_inc        = ssr_href_0;
assign control_cnt_clr        = control_eq;

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
  @ (posedge clk);
i_fstr_0  = 0;
end

assign ssr_hstr_0   = ssr_href_0 & !ssr_href_0_dly;
assign ssr_hend_0   = !ssr_href_0 & ssr_href_0_dly;

assign ssr_hstr_1   = ssr_href_1 & !ssr_href_1_dly;
assign ssr_hend_1   = !ssr_href_1 & ssr_href_1_dly;

initial begin 
      interrupt_mask = 1;
      wait(~ssr_vstr_0)
      wait(ssr_vstr_0)
      wait(~ssr_vend_0_dly2)
      wait(ssr_vend_0_dly2)
      wait(`LINE_BUF.hor_pad_cnt == 8'hff)
      interrupt_mask = 0;
      wait(~ssr_vstr_0)
      wait(ssr_vstr_0)
      wait(~ssr_vend_0_dly2)
      wait(ssr_vend_0_dly2)
      interrupt_mask = 1;
end 



assign i_data_0               = ssr_data_0_dly;
assign i_hstr_0               = ssr_hstr_0;
assign i_href_0               = ssr_href_0_dly & control_eq & `SSR_TOP_0.ssr_hcnt_cyc_eq & interrupt_mask;
assign i_hend_0               = ssr_hend_0 & interrupt_mask;
assign i_vstr_0               = ssr_vstr_0;
assign i_vend_0               = ssr_vend_0_dly2 & interrupt_mask;
           
assign i_data_1               = ssr_data_1_dly;
assign i_hstr_1               = ssr_hstr_1;
assign i_href_1               = ssr_href_1_dly & control_eq & `SSR_TOP_1.ssr_hcnt_cyc_eq & interrupt_mask;
assign i_hend_1               = ssr_hend_1 & interrupt_mask;
assign i_vstr_1               = ssr_vstr_1;
assign i_vend_1               = ssr_vend_1_dly2 & interrupt_mask;

assign wb_data_que_nxt        = {wb_data_que[8*SEN_PIXEL_DLY-1:0],i_data_1[7:0]};
assign wb_vld_que_nxt         = {wb_vld_que[SEN_PIXEL_DLY-1:0],(i_href_1 & (|i_data_1[7:0]) & !(hor_clr_smo | ver_fr_buf_smo | ver_top_pad_smo))};
assign wb_hend_que_nxt        = {wb_hend_que[SEN_PIXEL_DLY-1:0],i_hend_1};
assign i_href_1_que_nxt       = {i_href_1_que[SEN_PIXEL_DLY-1:0],i_href_1};
assign i_hstr_1_que_nxt       = {i_hstr_1_que[SEN_PIXEL_DLY-1:0],i_hstr_1};

assign i_wb                   = ini_wb_en ? wb_data_que_nxt[8*SEN_PIXEL_DLY-1:8*(SEN_PIXEL_DLY-1)] : 8'd0;
assign i_wb_vld               = wb_vld_que_nxt[SEN_PIXEL_DLY-1];
assign i_wb_hend              = wb_hend_que_nxt[SEN_PIXEL_DLY-1];

always@(posedge clk or negedge rst_n) begin 
  if(!rst_n) begin 
    ssr_href_0_dly     <= 0;
    ssr_data_0_dly     <= 0;
    ssr_vend_0_dly     <= 0;
    ssr_vend_0_dly2    <= 0;

    ssr_href_1_dly     <= 0;
    ssr_data_1_dly     <= 0;
    ssr_vend_1_dly     <= 0;
    ssr_vend_1_dly2    <= 0;
    
    control_cnt        <= 0;
    i_href_0_dly       <= 0;
    i_data_0_dly       <= 0;
    i_href_1_dly       <= 0;
    i_data_1_dly       <= 0;
    
    wb_data_que        <= 0;
    wb_vld_que         <= 0;
    wb_hend_que        <= 0;
    i_href_1_que       <= 0;
    i_hstr_1_que       <= 0;

    o_line_bf_dvld_dly <= 0;
    o_line_bf_dvld_dly2<= 0;
  end 
  else  begin 
    ssr_href_0_dly     <= ssr_href_0;
    ssr_data_0_dly     <= {ssr_data_0[7:0],ssr_data_0[15:8],ssr_data_0[23:16]};
    ssr_vend_0_dly     <= ssr_vend_0;
    ssr_vend_0_dly2    <= ssr_vend_0_dly;

    ssr_href_1_dly     <= ssr_href_1;
    ssr_data_1_dly     <= {ssr_data_1[7:0],ssr_data_1[15:8],ssr_data_1[23:16]};
    ssr_vend_1_dly     <= ssr_vend_1;
    ssr_vend_1_dly2    <= ssr_vend_1_dly;
      
    control_cnt        <= control_cnt_nxt;
    i_href_0_dly       <= i_href_0;
    i_data_0_dly       <= i_data_0;
    i_href_1_dly       <= i_href_1;
    i_data_1_dly       <= i_data_1;
    
    wb_data_que        <= wb_data_que_nxt;
    wb_vld_que         <= wb_vld_que_nxt;
    wb_hend_que        <= wb_hend_que_nxt;
    i_href_1_que       <= i_href_1_que_nxt;
    i_hstr_1_que       <= i_hstr_1_que_nxt;

    o_line_bf_dvld_dly <= o_line_bf_dvld;
    o_line_bf_dvld_dly2<= o_line_bf_dvld_dly;

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

line_buf_top
#( 
      .DBUF_DW             (DBUF_DW )  ,
      .DBUF_DEP            (DBUF_DEP ) ,
      .KRNV_SZ             (KRNV_SZ)  ,
      .KRNH_SZ             (KRNH_SZ) ,
      .ODATA_FREQ          (ODATA_FREQ),
      .PIXEL_DLY           (BUF_PIXEL_DLY),
      .LINE_DLY            (BUF_LINE_DLY),
      
      .MEM_TYPE            (MEM_TYPE),
      .TOP_PAD             (TOP_PAD),
      .BTM_PAD             (BTM_PAD),
      .FR_PAD              (FR_PAD),
      .BK_PAD              (BK_PAD),
      .PAD_MODE            (PAD_MODE),
      .ODATA_RNG           (ODATA_RNG)

)

line_buf_top
(

      .o_dvld                 (o_line_bf_dvld),
      .o_vstr                 (o_line_bf_vstr),
      .o_hstr                 (o_line_bf_hstr),
      .o_hend                 (o_line_bf_hend),
      .o_vend                 (o_line_bf_vend),
      .o_data                 (o_line_bf_data),

      .i_data                 ((ODATA_FREQ == 0) ? i_data_0 : i_data_0_dly), //in order to map valid and hend 
      .i_hstr                 (i_hstr_0),
      .i_href                 ((ODATA_FREQ == 0) ? i_href_0 : i_href_0_dly), //in order to map valid and hend 
      .i_hend                 (i_hend_0),
      .i_vstr                 (i_vstr_0),
      
      .i_wb                   (i_wb),
      .i_wb_vld               (i_wb_vld), 

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
      .ssr_href               (ssr_href_1),

      .ssr_blue               (),
      .ssr_hbyps              (),
      .ssr_field              (ssr_field_1),

      .ssr_vstr               (ssr_vstr_1),
      .ssr_vend               (ssr_vend_1),

      .ssr_data               (ssr_data_1),

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

      .reg_field_hofst        (sensor_field_hofst_1),
      .reg_field_vofst        (sensor_field_vofst_1),

// clk
      .clk                    (clk),
      .rst_n                  (rst_n)
);

/*

bil_ftr

#( 
      .DATA_WD        (DBUF_DW ) ,
      .KRN_VSZ        (KRN_VSZ) ,
      .KRN_HSZ        (KRN_HSZ)
)
bil_ftr
(
      .o_cv_data      (bil_flt_cv_data),
      .o_cv_dvld      (bil_flt_dvld),
      .o_cv_vstr      (bil_flt_vstr),
      .o_cv_hstr      (bil_flt_hstr),
      .o_cv_hend      (bil_flt_hend),
      .o_cv_vend      (bil_flt_vend),

      .i_data_0       (o_line_bf_data),
      .i_data_1       (),
      .i_data_2       (),

      .i_fstr         (i_fstr_0),
      .i_hstr         (o_line_bf_hstr),
      .i_hend         (o_line_bf_hend),
      .i_href         (o_line_bf_dvld),
      .i_vstr         (o_line_bf_vstr),
      .i_vend         (o_line_bf_vend),

      .r_bf_sigma_r   (r_bf_sigma_r),
      .r_bf_ofst_r    (r_bf_ofst_r),
      .r_bf_op_mode   (r_bf_op_mode),
      .r_sigma_s_sel  (r_sigma_s_sel),

      .clk            (clk),
      .rst_n          (rst_n)
);
*/

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

line_buf_v2_mon 
line_buf_v2_mon();

//--------------------------------------------------------------------------------
//  waveform dump setting
//--------------------------------------------------------------------------------

initial begin 
      $fsdbDumpfile("./wave/line_buf_v2_tb");
      $fsdbDumpvars(0,line_buf_v2_tb,"+all");
      wait(~o_line_bf_vend & interrupt_mask)
      wait(o_line_bf_vend & interrupt_mask)
      wait(~o_line_bf_vend & interrupt_mask)
      wait(o_line_bf_vend & interrupt_mask)
      #100000
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
