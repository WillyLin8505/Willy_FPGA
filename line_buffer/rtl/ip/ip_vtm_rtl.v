// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           
// Author:              Willy Lin
// Version:             1.0
// Date:                2022
// Last Modified On:    
// Last Modified By:    $Author$
//
// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------

module vtm

   #( 
      parameter VIDEO_RESOLUTION   = "" , 
      parameter HOR_TOTAL_TIME     = 0 ,
      parameter HOR_ADDR_TIME      = 0 ,
      parameter HOR_BLANK_TIME     = 0 ,
      parameter HOR_SYNC_START     = 0 ,
      parameter HOR_FRONT_PORCH    = 0 ,
      parameter HOR_SYNC_TIME      = 0 ,
      parameter HOR_BACK_PORCH     = 0 ,
      parameter VER_TOTAL_TIME     = 0 ,
      parameter VER_ADDR_TIME      = 0 ,
      parameter VER_BLANK_TIME     = 0 ,
      parameter VER_SYNC_START     = 0 ,
      parameter VER_FRONT_PORCH    = 0 ,
      parameter VER_SYNC_TIME      = 0 ,
      parameter VER_BACK_PORCH     = 0 ,
      parameter DATA_WD            = 12 //8,10,12
     )

(

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
 output reg          o_fstr,
 output reg          o_fend,
 output reg          o_vsync,
 output reg          o_vblk,
 output reg          o_vstr,
 output reg          o_vend,
 output reg          o_vref,
 output reg          o_hstr,
 output reg          o_hsync,
 output reg          o_hblk,
 output reg          o_hend,
 output reg          o_href,
 output reg [DATA_WD*3 -1 :0]   o_data,     //rgb 888
 output     [31:0]   o_slv_rd, 

 output     [5:0]    o_bug_vtm_ver_cs,  
 output     [5:0]    o_bug_vtm_hor_cs,  
 output              o_bug_ver_cnt_clr,  
 output              o_bug_hor_cnt_clr,  
 output              o_bug_fsm_en,  
 output              o_bug_ver_cnt_chg,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
 input               vtm_clk,
 input               vtm_rst_n,
 input               slv_clk,
 input               slv_rst_n,
 input               i_vtm_en,
 input               i_slv_en,    // & we enable 
 input  [3:0]        i_slv_we,    // byte enable
 input  [7:0]        i_slv_addr, 
 input  [31:0]       i_slv_wd  
);

//----------------------------------------------//
// local parameter declaration                  //
//----------------------------------------------// 

localparam [5:0] VTM_V_IDLE     = 6'b00_0001;  
localparam [5:0] VTM_VSYNC      = 6'b10_0010;
localparam [5:0] VTM_VBLK_BPCH  = 6'b10_0100;
localparam [5:0] VTM_V_ACTV     = 6'b00_1000;
localparam [5:0] VTM_VBLK_FPCH  = 6'b11_0000;

localparam [5:0] VTM_H_IDLE     = 6'b00_0001;
localparam [5:0] VTM_HSYNC      = 6'b10_0010;
localparam [5:0] VTM_HBLK_BPCH  = 6'b10_0100;
localparam [5:0] VTM_H_ACTV     = 6'b00_1000;
localparam [5:0] VTM_HBLK_FPCH  = 6'b11_0000;

localparam       LCL_HOR_TOTAL_TIME      = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 2200 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 2640 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 1650 : ( VIDEO_RESOLUTION == "720p_30fps") ? 3300 :  HOR_TOTAL_TIME ; 
localparam       LCL_HOR_ADDR_TIME       = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 1920 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 1920 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 1280 : ( VIDEO_RESOLUTION == "720p_30fps") ? 1280 :  HOR_ADDR_TIME ;  
localparam       LCL_HOR_BLANK_TIME      = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 280 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 720 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 370 : ( VIDEO_RESOLUTION == "720p_30fps") ? 2020 :   HOR_BLANK_TIME ; 
localparam       LCL_HOR_SYNC_START      = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 2008 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 2448 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 1390 : ( VIDEO_RESOLUTION == "720p_30fps") ? 3040 :  HOR_SYNC_START;  
localparam       LCL_HOR_FRONT_PORCH     = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 88 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 528 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 110 : ( VIDEO_RESOLUTION == "720p_30fps") ? 1760 :   HOR_FRONT_PORCH ;
localparam       LCL_HOR_SYNC_TIME       = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 44 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 44 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 40 : ( VIDEO_RESOLUTION == "720p_30fps") ? 40 :      HOR_SYNC_TIME ;   
localparam       LCL_HOR_BACK_PORCH      = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 148 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 148 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 220 : ( VIDEO_RESOLUTION == "720p_30fps") ? 220 :    HOR_BACK_PORCH ; 
localparam       LCL_VER_TOTAL_TIME      = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 1125 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 1125 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 750 : ( VIDEO_RESOLUTION == "720p_30fps") ? 750 :    VER_TOTAL_TIME ; 
localparam       LCL_VER_ADDR_TIME       = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 1080 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 1080 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 720 : ( VIDEO_RESOLUTION == "720p_30fps") ? 720 :    VER_ADDR_TIME ;  
localparam       LCL_VER_BLANK_TIME      = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 45 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 45 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 30 : ( VIDEO_RESOLUTION == "720p_30fps") ? 30 :      VER_BLANK_TIME ;
localparam       LCL_VER_SYNC_START      = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 1084 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 1084 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 725 : ( VIDEO_RESOLUTION == "720p_30fps") ? 725 :    VER_SYNC_START ;
localparam       LCL_VER_FRONT_PORCH     = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 4 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 4 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 5 : ( VIDEO_RESOLUTION == "720p_30fps") ? 5 :        VER_FRONT_PORCH ;
localparam       LCL_VER_SYNC_TIME       = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 5 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 5 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 5 : ( VIDEO_RESOLUTION == "720p_30fps") ? 5 :        VER_SYNC_TIME ; 
localparam       LCL_VER_BACK_PORCH      = ( VIDEO_RESOLUTION == "1080p_60/30fps") ? 36 : ( VIDEO_RESOLUTION == "1080p_50fps") ? 36 : 
                                           ( VIDEO_RESOLUTION == "720p_60fps") ? 20 : ( VIDEO_RESOLUTION == "720p_30fps") ? 20 :      VER_BACK_PORCH ; 


localparam       V_CNT_WD                = $clog2(LCL_VER_ADDR_TIME);   
localparam       H_CNT_WD                = $clog2(LCL_HOR_ADDR_TIME);
//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
//-------------------------------------------------ver part 
wire [V_CNT_WD-1:0]           ver_cnt_nxt;
reg  [V_CNT_WD-1:0]           ver_cnt;
wire                          ver_cnt_inc;
wire                          ver_cnt_clr;
reg                           ver_cnt_chg;
wire                          ver_cnt_chg_nxt;
wire [V_CNT_WD-1:0]           ver_comp;
reg  [5:0]                    vtm_ver_cs;
reg  [5:0]                    vtm_ver_ns;
wire                          offset_enable;
wire [V_CNT_WD-1:0]           ver_count_total;
wire                          vtm_v_idle_smo;
wire                          vtm_vsync_smo;
wire                          vtm_vblk_bpch_smo;
wire                          vtm_v_actv_smo;
wire                          vtm_vblk_fpch_smo;
wire                          vtm_vblk_smo;
wire                          ver_fsm_chg;
//-------------------------------------------------hor part 
wire [H_CNT_WD-1:0]           hor_cnt_nxt;
reg  [H_CNT_WD-1:0]           hor_cnt;
wire                          hor_cnt_inc;
wire                          hor_cnt_clr;
reg  [5:0]                    vtm_hor_cs;
reg  [5:0]                    vtm_hor_ns;
wire [H_CNT_WD-1:0]           hor_count_total;
wire                          vtm_h_idle_smo;
wire                          vtm_hsync_smo;
wire                          vtm_hblk_bpch_smo;
wire                          vtm_h_actv_smo;
wire                          vtm_hblk_fpch_smo;
wire                          vtm_hblk_smo;
wire                          hor_fsm_chg;
wire                          hor_fsm_end;
//-------------------------------------------------register part
wire                          reg_vsync;
wire                          r_vtc_en;
wire                          r_vtc_en_sel;
wire [7:0]                    r_vtc_tp_sel;        
wire [15:0]                   r_vtc_vsync_offset;
wire [31:0]                   slv_wd;
wire [3:0]                    slv_wen;
//--------------------------------------------------output 
wire                          o_fstr_nxt; 
wire                          o_vblk_nxt; 
wire                          o_vsync_nxt;
wire                          o_vstr_nxt; 
wire                          o_vref_nxt; 
wire                          o_hblk_nxt; 
wire                          o_hsync_nxt;
wire                          o_hstr_nxt; 
wire                          o_href_nxt; 
wire                          o_hend_nxt; 
wire                          o_vend_nxt; 
wire                          o_fend_nxt;
wire [DATA_WD*3 -1:0]         o_data_nxt;
//--------------------------------------------------fsm control 
wire                          fsm_en;
//--------------------------------------------------test pattern 
reg  [H_CNT_WD-1:0]           slide_cnt;
wire [H_CNT_WD-1:0]           slide_cnt_nxt;
wire                          slide_cnt_inc;
wire                          slide_cnt_clr;
wire                          slide_cnt_set;
wire [H_CNT_WD:0]             slide_cnt_set_val;
wire [DATA_WD-1:0]                   color_g;
wire [DATA_WD-1:0]                   color_b;
wire [DATA_WD-1:0]                   color_r;
wire [H_CNT_WD-1:0]           color_cnt_sel;
wire [DATA_WD-1:0]                   color_r_pt;
wire [DATA_WD-1:0]                   color_g_pt;
wire [DATA_WD-1:0]                   color_b_pt;
wire [2:0]                    color_bar_mask;
//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

//--------------------------------------------------ver part 
assign fsm_en          = (r_vtc_en_sel ? i_vtm_en : r_vtc_en);
assign ver_cnt_nxt     = (ver_cnt_inc ? ver_cnt + 1'b1 : ver_cnt) & {(V_CNT_WD){~ver_cnt_clr}};  
assign ver_cnt_inc     = (vtm_v_idle_smo & fsm_en)|                                                             //count in the idle delay , count in every clock 
                         (ver_cnt_chg & hor_cnt_inc) |                                                          //count the vsync offset  , coult in every clock 
                         (vtm_hblk_fpch_smo & hor_fsm_chg & !vtm_v_idle_smo);                                   //count in hend       
assign ver_cnt_clr     = (ver_cnt == ver_comp) & (ver_cnt_inc);                                                 //clear when match 

assign offset_enable   = |r_vtc_vsync_offset & (vtm_v_idle_smo | vtm_vsync_smo | vtm_vblk_fpch_smo);            //offset vsync only     
assign ver_cnt_chg_nxt = ((ver_cnt_clr & offset_enable) ^ ver_cnt_chg);                                         //0: count in hend , 1:count in offset
assign ver_comp        = ver_cnt_chg ? (r_vtc_vsync_offset-1) : (ver_count_total-1);                            //compare number is offset num or the protocal demanding number                   

//--------------------------------------------------ver fsm control 
assign ver_fsm_chg     = offset_enable ? ver_cnt_chg & ver_cnt_clr: ver_cnt_clr;                                //change fsm signal, the offset delay count will behind the hend count 

assign ver_count_total = ({11'b0,vtm_v_idle_smo}) | 
                         ({12{vtm_vsync_smo}} & LCL_VER_SYNC_TIME) | 
                         ({12{vtm_vblk_bpch_smo}} & LCL_VER_BACK_PORCH) | 
                         ({12{vtm_v_actv_smo}} & LCL_VER_ADDR_TIME) | 
                         ({12{vtm_vblk_fpch_smo}} & LCL_VER_FRONT_PORCH);


//vertical FSM

assign vtm_v_idle_smo     = vtm_ver_cs[0];
assign vtm_vsync_smo      = vtm_ver_cs[1];
assign vtm_vblk_bpch_smo  = vtm_ver_cs[2];
assign vtm_v_actv_smo     = vtm_ver_cs[3];
assign vtm_vblk_fpch_smo  = vtm_ver_cs[4];
assign vtm_vblk_smo       = vtm_ver_cs[5];

always@* begin : ver_fsm

  vtm_ver_ns = vtm_ver_cs;
  
  case (vtm_ver_cs)
 
    VTM_V_IDLE : begin 

      if(ver_fsm_chg & fsm_en)
        vtm_ver_ns = VTM_VSYNC;

    end

    VTM_VSYNC : begin 
   
      if(ver_fsm_chg)
        vtm_ver_ns = VTM_VBLK_BPCH;

    end

    VTM_VBLK_BPCH : begin 

      if(ver_fsm_chg)
        vtm_ver_ns = VTM_V_ACTV;

    end 

    VTM_V_ACTV    : begin 

      if(ver_fsm_chg)
        vtm_ver_ns = VTM_VBLK_FPCH;

    end 

    VTM_VBLK_FPCH : begin 

      if(ver_fsm_chg & fsm_en)
        vtm_ver_ns = VTM_VSYNC;
      else 
        if(ver_fsm_chg)
          vtm_ver_ns = VTM_V_IDLE;
    end 

  endcase 
end 


always@(posedge vtm_clk or negedge vtm_rst_n) begin 
if(!vtm_rst_n) begin 
  vtm_ver_cs             <= VTM_V_IDLE;
end
else begin 
  vtm_ver_cs             <= vtm_ver_ns;

end 
end 



//-------------------------------------------------hor part 
assign hor_cnt_nxt = (hor_cnt_inc ? hor_cnt + 1'b1 : hor_cnt) & {(H_CNT_WD){~hor_cnt_clr}};  
assign hor_cnt_inc = !vtm_h_idle_smo;
assign hor_cnt_clr = hor_cnt == (hor_count_total-1);

assign hor_count_total = ({11'b0,vtm_h_idle_smo}) | 
                         ({12{vtm_hsync_smo}} & LCL_HOR_SYNC_TIME) | 
                         ({12{vtm_hblk_bpch_smo}} & LCL_HOR_BACK_PORCH) | 
                         ({12{vtm_h_actv_smo}} & LCL_HOR_ADDR_TIME) | 
                         ({12{vtm_hblk_fpch_smo}} & LCL_HOR_FRONT_PORCH);

assign hor_fsm_chg = hor_cnt_clr; 
assign hor_fsm_end = hor_fsm_chg & vtm_v_idle_smo;

//horizontile FSM

assign vtm_h_idle_smo     = vtm_hor_cs[0];
assign vtm_hsync_smo      = vtm_hor_cs[1];
assign vtm_hblk_bpch_smo  = vtm_hor_cs[2];
assign vtm_h_actv_smo     = vtm_hor_cs[3];
assign vtm_hblk_fpch_smo  = vtm_hor_cs[4];
assign vtm_hblk_smo       = vtm_hor_cs[5];

always@* begin : hor_fsm

  vtm_hor_ns = vtm_hor_cs;
  
  case (vtm_hor_cs)
 
    VTM_H_IDLE : begin 

      if(ver_cnt_clr)
        vtm_hor_ns = VTM_HSYNC;

    end

    VTM_HSYNC : begin 

      if(hor_fsm_chg)
        vtm_hor_ns = VTM_HBLK_BPCH;
   
    end

    VTM_HBLK_BPCH : begin 

      if(hor_fsm_chg)
        vtm_hor_ns = VTM_H_ACTV;

    end 

    VTM_H_ACTV    : begin 

      if(hor_fsm_chg)
        vtm_hor_ns = VTM_HBLK_FPCH;

    end 

    VTM_HBLK_FPCH : begin 

      if(hor_fsm_end) // 
        vtm_hor_ns = VTM_H_IDLE;
      else 
        if(hor_fsm_chg)
          vtm_hor_ns = VTM_HSYNC;
    end 

  endcase 
end 

always@(posedge vtm_clk or negedge vtm_rst_n) begin 
if(!vtm_rst_n) begin 
  vtm_hor_cs             <= VTM_H_IDLE;
end
else begin 
  vtm_hor_cs             <= vtm_hor_ns;
end 
end 


//-------------------------------------------------output signal
assign o_fstr_nxt        = vtm_vsync_smo       & ver_fsm_chg;
assign o_vsync_nxt       = vtm_vsync_smo;
assign o_vblk_nxt        = vtm_vblk_smo;
assign o_vstr_nxt        = vtm_vblk_bpch_smo   & ver_fsm_chg;
assign o_vref_nxt        = vtm_v_actv_smo;
assign o_hsync_nxt       = vtm_hsync_smo;
assign o_hblk_nxt        = vtm_hblk_smo;
assign o_hstr_nxt        = vtm_hblk_bpch_smo   & hor_fsm_chg      & o_vref_nxt;
assign o_href_nxt        = vtm_h_actv_smo                         & o_vref_nxt;
assign o_hend_nxt        = vtm_h_actv_smo      & hor_fsm_chg      & o_vref_nxt;
assign o_vend_nxt        = vtm_v_actv_smo      & ver_fsm_chg;
assign o_fend_nxt        = vtm_vblk_fpch_smo   & ver_fsm_chg;
assign o_data_nxt        = {color_r,color_g,color_b};

assign o_bug_vtm_ver_cs  = vtm_ver_cs;
assign o_bug_vtm_hor_cs  = vtm_hor_cs; 
assign o_bug_ver_cnt_clr = ver_cnt_clr;
assign o_bug_hor_cnt_clr = hor_cnt_clr; 
assign o_bug_fsm_en      = fsm_en;
assign o_bug_ver_cnt_chg = ver_cnt_chg;

//-------------------------------------------------test pattern
assign slide_cnt_nxt     = slide_cnt_set ? slide_cnt_set_val : (slide_cnt_inc ? slide_cnt + 1'b1 : slide_cnt) & {(V_CNT_WD){~slide_cnt_clr}};  
assign slide_cnt_inc     = hor_cnt_inc;
assign slide_cnt_clr     = o_fend;
assign slide_cnt_set     = hor_cnt_clr;
assign slide_cnt_set_val = ver_cnt;

//r_vtc_tp_sel function
//[0]   enable 
//[3:1] g r b                               (mask)
//[4]   0:grandient color 1: fix color      (color)
//[5]   0:close color bar 1: open color bar (color and mask)
//[7:6] 0:ver cnt 1:hor cnt 2:slide cnt     (color)

//color counter 
assign color_cnt_sel     = (r_vtc_tp_sel[7:6] ==2'b00) ? ver_cnt : (r_vtc_tp_sel[7:6] ==2'b01) ? hor_cnt : slide_cnt;
assign color_r_pt        = (r_vtc_tp_sel[4]) ? 12'hfff : color_cnt_sel;
assign color_g_pt        = (r_vtc_tp_sel[4]) ? 12'hfff : color_cnt_sel;
assign color_b_pt        = (r_vtc_tp_sel[4]) ? 12'hfff : color_cnt_sel;

//color mask 
assign color_bar_mask    = r_vtc_tp_sel[5] ? ((r_vtc_tp_sel[7:6] ==2'b00)? ~(hor_cnt[6:4]): ~(ver_cnt[6:4])) : r_vtc_tp_sel[3:1];

//final color 
assign color_r           = color_r_pt & {DATA_WD{color_bar_mask[1]}};
assign color_g           = color_g_pt & {DATA_WD{color_bar_mask[2]}};
assign color_b           = color_b_pt & {DATA_WD{color_bar_mask[0]}};


//-------------------------------------------------sequence 

always@(posedge vtm_clk or negedge vtm_rst_n) begin 
if(!vtm_rst_n) begin 
//-------------------------------------------------ver part 
  ver_cnt                <= 0;
  ver_cnt_chg            <= 0;
//-------------------------------------------------hor part 
  hor_cnt                <= 0;
//-------------------------------------------------output 
  o_fstr                 <= 0;
  o_vblk                 <= 0;
  o_vsync                <= 0;
  o_vstr                 <= 0;
  o_vref                 <= 0;
  o_hblk                 <= 0;
  o_hsync                <= 0;
  o_hstr                 <= 0;
  o_href                 <= 0;
  o_hend                 <= 0;
  o_vend                 <= 0;
  o_fend                 <= 0;
  o_data                 <= 0; 
//-------------------------------------------------test pattern
  slide_cnt              <= 0;
end
else begin 
//-------------------------------------------------ver part 
  ver_cnt                <= ver_cnt_nxt;
  ver_cnt_chg            <= ver_cnt_chg_nxt;
//-------------------------------------------------hor part 
  hor_cnt                <= hor_cnt_nxt;
//-------------------------------------------------output 
  o_fstr                 <= o_fstr_nxt;  
  o_vblk                 <= o_vblk_nxt;  
  o_vsync                <= o_vsync_nxt; 
  o_vstr                 <= o_vstr_nxt;  
  o_vref                 <= o_vref_nxt;  
  o_hblk                 <= o_hblk_nxt;  
  o_hsync                <= o_hsync_nxt; 
  o_hstr                 <= o_hstr_nxt;  
  o_href                 <= o_href_nxt;  
  o_hend                 <= o_hend_nxt;  
  o_vend                 <= o_vend_nxt;  
  o_fend                 <= o_fend_nxt;  
  o_data                 <= o_data_nxt;
//-------------------------------------------------test pattern
  slide_cnt              <= slide_cnt_nxt;
end 
end 

//-----------------------------------------------soisp register 

assign slv_wd  = i_slv_wd;

assign slv_wen = {4{i_slv_en}} & i_slv_we;
//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//
assign reg_vsync = o_vsync | (vtm_v_idle_smo & vtm_h_idle_smo);

soisp_p00_reg
soisp_vtc_page(
	//output
	.r_vtc_en               (r_vtc_en),
	.r_vtc_en_sel           (r_vtc_en_sel),
	.r_vtc_tp_sel           (r_vtc_tp_sel),
	.r_vtc_vsync_offset0700 (r_vtc_vsync_offset[7:0]),
	.r_vtc_vsync_offset1508 (r_vtc_vsync_offset[15:8]), 
	.reg_rd                 (o_slv_rd),
	//input
	.clk                    (slv_clk),
	.rst_n                  (slv_rst_n),
        .vsync                  (reg_vsync),
	.clk_ahbs_reg_wen       (slv_wen),
	.ahbs_reg_index         (i_slv_addr),
	.ahbs_reg_wd            (slv_wd)
        );



endmodule 
