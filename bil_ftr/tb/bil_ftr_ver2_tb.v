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
// Desrciption     :
// ------------------------------------------------------------------------------//

// defination & include
`timescale 1ns/1ns  
`define   TB_TOP            bil_ftr_ver2_tb
`define   MONITOR_TOP       bil_ftr_ver2_mon
`define   BIL_FTR_VER2      `TB_TOP.bil_ftr_ver2
`define   LINE_BUF          `TB_TOP.line_buf_top.line_buf_v2
`define   LINE_RNG          `TB_TOP.line_buf_top.line_rng

`define   SENSOR            `TB_TOP.sensor
`define   SSR_TOP           `TB_TOP.sensor       //get error when scarcing this parameter
`define   HOST_WR           nope                 //get error when scarcing this parameter
`define   PPM_MON           `TB_TOP.ppm_monitor


// module start 
module bil_ftr_ver2_tb();

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
parameter           LINE_BUF_COW            = LINE_BUF_COIW + LINE_BUF_COPW;
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
parameter          PX_FMT                   = (LINE_BUF_COPW == 0)? "RGB8"  :
                                              (LINE_BUF_COPW == 2)? "RGB10" :
                                              (LINE_BUF_COPW == 4)? (YCBCR_POS) ? "RGB12" : "RGB14" : "RGB10";
parameter          PX_FMT_BIT               = (LINE_BUF_COPW == 0)? 8  :
                                              (LINE_BUF_COPW == 2)? 10 :
                                              (LINE_BUF_COPW == 4)? (YCBCR_POS) ? 12 : 14 : 10;
                                              
parameter          SSR_PX_WTH               = SSR_PX_SZ_MAX/3;

// pixel data color sequence (only valid when SSR_PX_RATE !=1)
parameter           SSR_PX_CSEQ             = "G_LSB";

// exposure rate (exposure number per frame)
parameter           SSR_EXPO_RATE           = 1;

//-----------------------------------------------------------------line buffer ver2 
parameter           MEM_TYPE                = "1PSRAM";              // "FPGA_BLKRAM", 1PSRAM

//-----------------------------------------------------------------ppm monitor 
parameter           DUT_NAME                = "BIL_FTR_VER2";

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
wire        [LINE_BUF_COW-1:0]      data_rgb;
wire                                hstr_rgb;
wire                                href_rgb;
wire                                hend_rgb;
wire                                vstr_rgb;
wire                                vend_rgb;

wire        [YCBCR_COIW+YCBCR_COPW-1:0]  data_yuv;
wire        [YCBCR_COIW+YCBCR_COPW:0]    data_cb_sgn;
wire                                     hstr_yuv;
wire                                     href_yuv;
wire                                     hend_yuv;
wire                                     vstr_yuv;
wire                                     vend_yuv;

wire        [LINE_BUF_COW-1:0]      data_src;
wire                                hstr_src;
wire                                href_src;
wire                                hend_src;
wire                                vstr_src;
wire                                vend_src;

reg                                 interrupt_mask;

wire                                control_eq;
reg         [4-1 : 0]               control_cnt;
wire        [4-1 : 0]               control_cnt_nxt;
wire                                control_cnt_inc;
wire                                control_cnt_clr;
//----------------------------------------------------------------------------------------sensor
wire        [SSR_EXPO_RATE-1:0]     ssr_dvp_href;                 //
wire        [SSR_PX_SZ_MAX-1:0]     ssr_dvp_data;  
reg         [SSR_PX_SZ_MAX-1:0]     ssr_dvp_data_dly;  
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

wire                                ssr_hstr;
wire                                ssr_hend;
wire                                ssr_vstr;
wire                                ssr_vend;
reg                                 ssr_vend_dly;
reg                                 ssr_vend_dly2;
reg                                 ssr_href_dly;
//---------------------------------------------------------------------------------------------line buffer
wire        [LINE_BUF_COW*KRNV_SZ*ODATA_RNG-1:0]   line_bf_data;
wire                                               line_bf_dvld;
wire                                               line_bf_vstr;
wire                                               line_bf_hstr;
wire                                               line_bf_hend;
wire                                               line_bf_vend;

//---------------------------------------------------------------------------------------------bilateral filter 
wire        [LINE_BUF_COW:0]                       bil_flt_cv_data;
wire                                               bil_flt_dvld;
wire                                               bil_flt_vstr;
wire                                               bil_flt_hstr;
wire                                               bil_flt_hend;
wire                                               zbil_flt_vend;


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
//  behavior desrciption
//================================================================================
assign control_eq             = control_cnt == 4'd0;
assign control_cnt_nxt        = (control_cnt_inc ? control_cnt + 1'b1 : control_cnt) & {(5){~control_cnt_clr}}; 
assign control_cnt_inc        = ssr_href;
assign control_cnt_clr        = control_eq;

//----------------------------------------------------------------------------------sensor
initial begin
data_fstr = 0;
wait(~reg_ini_done)
wait(reg_ini_done)
#1000
`SENSOR.sensor_en = 1'b1;
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
    control_cnt      <= 0;
    ssr_vend_dly     <= 0;
    ssr_vend_dly2    <= 0;
  end 
  else  begin 
    ssr_href_dly     <= ssr_href;
    ssr_dvp_data_dly <= ssr_dvp_data; //R,G,B
    control_cnt      <= control_cnt_nxt;
    ssr_vend_dly     <= ssr_vend;
    ssr_vend_dly2    <= ssr_vend_dly;
  end
end 

//================================================================================
//  module instantiation
//================================================================================

initial begin 
      interrupt_mask = 1;
      wait(~ssr_vstr)
      wait(ssr_vstr)
      wait(~ssr_vend_dly2)
      wait(ssr_vend_dly2)
      wait(~ssr_vstr)
      wait(ssr_vstr)
      wait(`LINE_BUF.hor_pad_cnt == 8'hff)
      interrupt_mask = 0;
      wait(~ssr_vend_dly2)
      wait(ssr_vend_dly2)
      interrupt_mask = 1;
end 



assign data_rgb    = ssr_dvp_data_dly[23:16]; //R
assign hstr_rgb    = ssr_hstr;
assign href_rgb    = ssr_href_dly;
assign hend_rgb    = ssr_hend ;
assign vstr_rgb    = ssr_vstr;
assign vend_rgb    = ssr_vend_dly2;


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

ip_rgb2ycbcr #(
    .CIIW           ( 8 ),
    .CIPW           ( 0 ),
    .COIW           ( YCBCR_COIW ),
    .COPW           ( YCBCR_COPW ),
    .YCBCR_POS      ( YCBCR_POS )
)u_ip_rgb2ycbcr (
    .o_data_y       ( data_yuv ),
    .o_data_cb      ( data_cb_sgn),
    .o_data_cr      ( ),
    .o_hstr         ( hstr_yuv   ),
    .o_hend         ( hend_yuv   ),
    .o_href         ( href_yuv   ),
    
    .i_data_r       ( ssr_dvp_data_dly[SSR_PX_WTH*3-1:SSR_PX_WTH*2] ), 
    .i_data_g       ( ssr_dvp_data_dly[SSR_PX_WTH*2-1:SSR_PX_WTH] ), 
    .i_data_b       ( ssr_dvp_data_dly[SSR_PX_WTH-1:0] ),
    .i_hstr         ( ssr_hstr   ),
    .i_hend         ( ssr_hend   ),
    .i_href         ( ssr_href_dly   ),
    .clk            ( clk      ),
    .rst_n          ( rst_n    )
    
);

assign href_src = (ini_src_sel == 1) ? href_rgb : href_yuv;
assign vstr_src = vstr_rgb;
assign hstr_src = (ini_src_sel == 1) ? hstr_rgb : hstr_yuv;
assign hend_src = (ini_src_sel == 1) ? hend_rgb : hend_yuv;
assign vend_src = vend_rgb;
assign data_src = (ini_src_sel == 2) ? $signed(data_cb_sgn) : (ini_src_sel == 1) ? $signed({1'b0,data_rgb}) : $signed({1'b0,data_yuv});

line_buf_top
#( 
      .DBUF_DW             (LINE_BUF_COW )  ,
      .DBUF_DEP            (DUF_DEP ) ,
      .KRNV_SZ             (KRNV_SZ)  ,
      .KRNH_SZ             (KRNH_SZ) ,
      .ODATA_FREQ          (ODATA_FREQ),
      
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

      .o_dvld                 (line_bf_dvld),
      .o_vstr                 (line_bf_vstr),
      .o_hstr                 (line_bf_hstr),
      .o_hend                 (line_bf_hend),
      .o_vend                 (line_bf_vend),
      .o_data                 (line_bf_data),

      .i_data                 (data_src),
      .i_hstr                 (hstr_src),
      .i_href                 (href_src),
      .i_hend                 (hend_src),
      .i_vstr                 (vstr_src),

      .clk                    (clk),
      .rst_n                  (rst_n)
);


bil_ftr_ver2

#( 
      .CIIW           (BIL_FTR_COIW),
      .CIPW           (BIL_FTR_COPW),
      .COIW           (BIL_FTR_COIW),
      .COPW           (BIL_FTR_COPW),
      .KRNV_SZ        (KRNV_SZ) ,
      .KRNH_SZ        (KRNH_SZ) ,
      .ODATA_RNG      (ODATA_RNG),
      .SIGN_EN        (SIGN_EN)
)
bil_ftr_ver2
(
      .o_cv_data_sgn  (bil_flt_cv_data),
      .o_cv_dvld      (bil_flt_dvld),
      .o_cv_vstr      (bil_flt_vstr),
      .o_cv_hstr      (bil_flt_hstr),
      .o_cv_hend      (bil_flt_hend),
      .o_cv_vend      (bil_flt_vend),
      

      .i_data         (line_bf_data),
      .i_fstr         (data_fstr),
      .i_hstr         (line_bf_hstr),
      .i_hend         (line_bf_hend),
      .i_href         (line_bf_dvld),
      .i_vstr         (line_bf_vstr),
      .i_vend         (line_bf_vend),

      .r_bf_sigma_r   (r_bf_sigma_r),
      .r_bf_ofst_r    (r_bf_ofst_r),
      .r_bf_op_mode   (r_bf_op_mode),
      .r_sigma_s_sel  (r_sigma_s_sel),

      .clk            (clk),
      .rst_n          (rst_n)
);


bil_ftr_ver2_test_4

#( 
      .CIIW           (LINE_BUF_COIW),
      .CIPW           (LINE_BUF_COPW),
      .COIW           (LINE_BUF_COIW),
      .COPW           (LINE_BUF_COPW),
      .KRNV_SZ        (KRNV_SZ) ,
      .KRNH_SZ        (KRNH_SZ) ,
      .ODATA_RNG      (ODATA_RNG)
)
bil_ftr_ver2_test_4
(

      .o_cv_data      (),
      .o_cv_dvld      (),
      .o_cv_vstr      (),
      .o_cv_hstr      (),
      .o_cv_hend      (),
      .o_cv_vend      (),
/*
      .o_cv_data      (bil_flt_cv_data),
      .o_cv_dvld      (bil_flt_dvld),
      .o_cv_vstr      (bil_flt_vstr),
      .o_cv_hstr      (bil_flt_hstr),
      .o_cv_hend      (bil_flt_hend),
      .o_cv_vend      (bil_flt_vend),
*/
      .i_data         (line_bf_data),
      .i_fstr         (data_fstr),
      .i_hstr         (line_bf_hstr),
      .i_hend         (line_bf_hend),
      .i_href         (line_bf_dvld),
      .i_vstr         (line_bf_vstr),
      .i_vend         (line_bf_vend),

      .r_bf_sigma_r   (r_bf_sigma_r),
      .r_bf_ofst_r    (r_bf_ofst_r),
      .r_bf_op_mode   (r_bf_op_mode),
      .r_sigma_s_sel  (r_sigma_s_sel),

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
            .PX_FMT       (PX_FMT),
            .IMG_HSZ      (IMG_HSZ),
            .IMG_VSZ      (IMG_VSZ),
            .GOLD_HOFT    (0),
            .GOLD_VOFT    (0)
         )
ppm_monitor_0  (

            .vstr         (bil_flt_vstr),          
            .vend         (bil_flt_vend),            
            .hstr         (bil_flt_hstr),           
            .hend         (bil_flt_hend),            
            .dvld         (bil_flt_dvld),              
            .bidx         (1'b0),         
            .data         ({{{PX_FMT_BIT-LINE_BUF_COW-1{1'b0}},bil_flt_cv_data[BIL_FTR_COIW+BIL_FTR_COPW:0]},
                            {{PX_FMT_BIT-LINE_BUF_COW-1{1'b0}},bil_flt_cv_data[BIL_FTR_COIW+BIL_FTR_COPW:0]},
                            {{PX_FMT_BIT-LINE_BUF_COW-1{1'b0}},bil_flt_cv_data[BIL_FTR_COIW+BIL_FTR_COPW:0]}}),         
            .clk          (clk),           
            .rst_n        (rst_n)       
);



/*
bil_ftr_ver2_mon 
bil_ftr_ver2_mon();
*/
//--------------------------------------------------------------------------------
//  waveform dump setting
//--------------------------------------------------------------------------------

initial begin 
      $fsdbDumpfile("./wave/bil_ftr_ver2_tb");
      $fsdbDumpvars(0,bil_ftr_ver2_tb,"+all");
      wait(~bil_flt_vend)
      wait(bil_flt_vend)
      wait(~bil_flt_vend)
      wait(bil_flt_vend)
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
