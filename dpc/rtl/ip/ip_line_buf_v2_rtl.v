// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:
// Author:              Willy Lin
// Version:             1.0
// Date:                2022/11/15
// Modified On:
// Modified By:    $Author$
//
// limitation : 
// 1. top padding cannot over KRNV_SZ-2 (MAX_TOP_PAD)
// 2. PIXEL_DLY cannot set to odds
// File Description:
// All output data will be package in one bus (o_data) , msb of o_data is the oldest line and lsb is the newest line 
//  
// -FHDR -----------------------------------------------------------------------

module line_buf_v2 # 
      (
    parameter IMG_HSZ      = 1920,
    parameter DBUF_DW      = 8,
    parameter KRNV_SZ      = 7,                     // vertical kernel size
    parameter KRNH_SZ      = 7,                     // horizontial kernel size
    parameter ODATA_FREQ   = 0,                     // output data frequence : 0:every 1 cycle change output data 
                                                    //                         1:every 2 cycle change output data 
                                                    //                         2:every 4 cycle change output data 
                                                    //                         3:every 8 cycle change output data 
    parameter MEM_TYPE     = "1PSRAM",              // "FPGA_BLKRAM", 1PSRAM
    parameter MEM_NAME     = "asic_sram_sp960x128", // sram name 
    parameter TOP_PAD      = 2,                     // top padding line number 
    parameter BTM_PAD      = 2,                     // bottom padding line number 
    parameter FR_PAD       = 2,                     // front padding number 
    parameter BK_PAD       = 2,                     // back padding number 
    parameter PAD_MODE     = 0,                     // 0:for duplicate padding 
                                                    // 1:RAW padding 
    parameter PIXEL_DLY    = 0,
    parameter LINE_DLY     = 0,
    
    parameter SRAM_NUM     = 2,
    parameter SRAM_DEP     = IMG_HSZ,                        //divid 2 for stack 2 data 
    parameter SRAM_DWTH    = ((KRNV_SZ-1)*2*DBUF_DW)/SRAM_NUM
    )
(
    output reg [DBUF_DW*KRNV_SZ-1:0]           o_data,
    output reg                                 o_dvld,
    output reg                                 o_vstr,
    output reg                                 o_hstr,
    output reg                                 o_hend,
    output reg                                 o_vend,
    
    input      [DBUF_DW-1:0]                   i_data,
    input                                      i_href,
    input                                      i_hend,
    input                                      i_vstr,
    
    input      [DBUF_DW-1:0]                   i_wb,
    input                                      i_wb_vld,
    
    input                                      clk,
    input                                      rst_n
);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//
//-------------------------------------------------------------------parameter width 
localparam                              KRNV_WTH           = $clog2(KRNV_SZ-1);                                  //only internal caculate need parameter width 
localparam                              KRNH_WTH           = $clog2(KRNH_SZ);
localparam                              HOR_WTH            = $clog2(SRAM_DEP);
localparam                              FR_PAD_WTH         = $clog2(FR_PAD);
localparam                              PIXEL_DLY_WTH      = $clog2(PIXEL_DLY);
localparam                              SRAM_NUM_WTH       = $clog2(SRAM_NUM);

//-------------------------------------------------------------------DLY table 0
localparam [1:0]                        GMEM_ADDR_DATA_DLY = 2;                                                  //delay from address to data 
localparam                              GMEM_SFT_DLY       = 1;                                                  //do_sel_en will cause one clock delay  

//-------------------------------------------------------------------ensure fsm stable
localparam [KRNV_WTH-1:0]               MAX_TOP_PAD        = KRNV_SZ -2;                                         //max top padding number 

//-------------------------------------------------------------------freq
localparam [ODATA_FREQ:0]               ODATA_FREQ_T       = 2**(ODATA_FREQ);                                
localparam [ODATA_FREQ+1:0]             ODATA_FREQ_T_1     = 2**(ODATA_FREQ+1);   
localparam                              ODATA_FREQ_MIN     = (ODATA_FREQ == 0) ? 1'b1 : ODATA_FREQ;

//-------------------------------------------------------------------DLY table 1 & padding num 
localparam [1:0]                        LOAD_FR_DA_DLY     = 1 + PAD_MODE;                                       //load front data delay 
localparam                              FR_PAD_NUM         = FR_PAD + LOAD_FR_DA_DLY - GMEM_ADDR_DATA_DLY;       // for HOR_FR_PAD state
localparam                              FR_PAD_NUM_SEL     = ((FR_PAD < 2) & ODATA_FREQ == 0) ? 2 +PIXEL_DLY: 
                                                             ((FR_PAD + LOAD_FR_DA_DLY + FR_PAD_NUM[0] + PIXEL_DLY) << ODATA_FREQ) - GMEM_ADDR_DATA_DLY; 
                                                                                                                 //minium front padding number is 2 
localparam                              FR_PAD_NUM_TOTAL   = FR_PAD_NUM_SEL + GMEM_ADDR_DATA_DLY;                //HOR_FR_PAD front padding number 
localparam                              STACK_DLY          = (FR_PAD_NUM_TOTAL +ODATA_FREQ_T) >> ODATA_FREQ; 
localparam [1:0]                        HOR_OUT_DLY        = GMEM_ADDR_DATA_DLY;                                 //use for hor_cur_sel to select front padding data or input data 

//-------------------------------------------------------------------code parameter 
localparam [1:0]                        STACK_NUM          = 2;                                                  //1 write 1 read
localparam [KRNV_WTH-1:0]               KRNV_PAD           = (KRNV_SZ-1)/STACK_NUM;                              
localparam [KRNH_WTH-1:0]               KRNH_PAD           = (KRNH_SZ-1)/STACK_NUM; 
localparam [DBUF_DW:0]                  STACK_DATA         = (DBUF_DW *STACK_NUM); 
localparam [1:0]                        STACK_WTH          = $clog2(STACK_NUM);
localparam [DBUF_DW-1:0]                STACK_DATA_WTH     = $clog2(STACK_DATA);

localparam                              BUF_LINE           = 1;                                                  //buffer first line in ver_fr_buf state
localparam                              GMEM_DWTH          = STACK_DATA*(KRNV_SZ-1);
localparam [DBUF_DW*KRNV_WTH:0]         HALF_DATA_WTH      = KRNV_PAD * STACK_DATA;
localparam [FR_PAD_WTH+ODATA_FREQ+
           PIXEL_DLY_WTH+2:0]           HSTR_NUM           = FR_PAD_NUM_TOTAL - (FR_PAD << ODATA_FREQ);          //timing for hstr
localparam [0:0]                        BK_PAD_EN          = BK_PAD>=1;                     
localparam                              SRAM_ZERO_EXT      = (SRAM_DWTH>GMEM_DWTH) ? SRAM_DWTH-GMEM_DWTH-1 : 0;
//-------------------------------------------------------------------gmem
localparam                              MEM_DEP            = SRAM_DEP/STACK_NUM;                                 //memory depth     
localparam                              MEM_DW             = GMEM_DWTH;                                          //memory data width
localparam                              DO_FFO             = "True";                                             // F.F. data output
localparam                              DO_ON_WR           = "True";                                             // "FALSE": Don't read data while WR for port-A
localparam                              MEM_AW             = $clog2(MEM_DEP); 

//-------------------------------------------------------------------FSM
//----------------------------------------------------------hor fsm			
localparam [7:0]                        HOR_IDLE           = 8'b0000_0100;			  	
localparam [7:0]                        HOR_FR_PAD         = 8'b0000_1010;				
localparam [7:0]                        HOR_FR_PAD_FNL     = 8'b0001_0011;				
localparam [7:0]                        HOR_ACT_LINE       = 8'b0010_0001;				
localparam [7:0]                        HOR_BK_PAD         = 8'b0100_0000;				
localparam [7:0]                        HOR_LINE_BLK       = 8'b1000_0100;				

//----------------------------------------------------------ver fsm				
localparam [5:0]                        VER_IDLE           = 6'b00_0001;				
localparam [5:0]                        VER_FR_BUF         = 6'b00_0100;				
localparam [5:0]                        VER_TOP_PAD        = 6'b00_1010;				
localparam [5:0]                        VER_ACT_LINE       = 6'b01_0010;				
localparam [5:0]                        VER_BTM_PAD        = 6'b10_0010;				


//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
//----------------------------------------------------------control part
wire                                       line_buf_hstr;
reg  [HOR_WTH+ODATA_FREQ-1 : 0]            hor_num;
wire [HOR_WTH+ODATA_FREQ-1 : 0]            hor_num_nxt;
wire [HOR_WTH-1 : 0]                       href_num;
reg  [HOR_WTH-1 : 0]                       blk_num;
wire [HOR_WTH-1 : 0]                       blk_num_nxt;
reg  [KRNV_WTH-1 : 0]                      last_2nd_num;
wire [KRNV_WTH-1 : 0]                      last_2nd_num_nxt;
reg                                        i_hend_dly;
reg                                        rst_en;
wire                                       rst_en_nxt;

//----------------------------------------------------------equal part
wire [HOR_WTH-2:0]                         ver_pad_cnt_num;
wire                                       ver_pad_cnt_eq;
wire [HOR_WTH-1:0]                         hor_pad_cnt_num;
wire                                       hor_pad_cnt_eq;
wire                                       buf_line_eq;
wire                                       top_pad_eq;
wire                                       btm_pad_eq;
wire                                       fr_pad_eq;
wire                                       fr_pad_final_eq;
wire                                       bk_pad_eq;
wire                                       act_pad_num_eq;
wire                                       rd_cnt_last_num_eq;
wire                                       hblk_eq;
wire                                       rd_cyc_eq;
wire                                       wr_cyc_eq;
wire                                       hor_fr_pad_1st_eq;
wire                                       hor_fr_pad_2nd_eq;
wire                                       do_pad_eq;
wire                                       hblk_zero_eq;
wire                                       ver_pad_zero_eq;
wire                                       ver_href_eq;
wire                                       do_sel_en_eq             [0:KRNV_SZ-2];
wire                                       hstr_eq;
wire                                       hor_href_eq;

//----------------------------------------------------------counter part
reg  [HOR_WTH-2 : 0]                       wr_cnt;
wire [HOR_WTH-2 : 0]                       wr_cnt_nxt;
wire                                       wr_cnt_inc;
wire                                       wr_cnt_clr;

reg  [STACK_WTH : 0]                       wr_cyc_cnt;
wire [STACK_WTH : 0]                       wr_cyc_cnt_nxt;
wire                                       wr_cyc_cnt_inc;
wire                                       wr_cyc_cnt_clr;

reg  [HOR_WTH-1 : 0]                       ver_pad_cnt;        //maybe this parameter is not fit
wire [HOR_WTH-1 : 0]                       ver_pad_cnt_nxt;    //maybe this parameter is not fit
wire                                       ver_pad_cnt_inc;
wire                                       ver_pad_cnt_clr;

reg  [HOR_WTH-1 : 0]                       rd_cnt;
wire [HOR_WTH-1 : 0]                       rd_cnt_nxt;
wire                                       rd_cnt_inc;
wire                                       rd_cnt_clr;

reg  [ODATA_FREQ : 0]                      rd_cyc_cnt;
wire [ODATA_FREQ : 0]                      rd_cyc_cnt_nxt;
wire                                       rd_cyc_cnt_inc;
wire                                       rd_cyc_cnt_clr;

reg  [HOR_WTH+ODATA_FREQ-1 : 0]            hor_pad_cnt;
wire [HOR_WTH+ODATA_FREQ-1 : 0]            hor_pad_cnt_nxt;
wire                                       hor_pad_cnt_inc;
wire                                       hor_pad_cnt_clr;

reg  [KRNV_WTH-1 : 0]                      do_sel_cnt;
wire [KRNV_WTH-1 : 0]                      do_sel_cnt_nxt;
wire                                       do_sel_cnt_inc;
wire                                       do_sel_cnt_clr;
wire                                       do_sel_cnt_set;
wire [KRNV_WTH-1 : 0]                      do_sel_cnt_set_val;

//----------------------------------------------------------output part
//----------------------------------------------------------FSM
wire                                       hor_fr_pad_smo;
wire                                       hor_fr_pad_fnl_smo;
wire                                       hor_act_line_smo;
wire                                       hor_bk_pad_smo;
wire                                       hor_line_blk_smo;
wire                                       hor_clr_smo;
wire                                       fr_pad_com_smo;
wire                                       rd_cyc_smo;

reg  [7:0]                                 hor_line_buf_cs;
reg  [7:0]                                 hor_line_buf_ns;

wire                                       ver_fr_buf_smo;
wire                                       ver_top_pad_smo;
wire                                       ver_act_line_smo;
wire                                       ver_btm_pad_smo;
wire                                       ver_sel_sft_smo;
wire                                       ver_idle_smo;

reg  [5:0]                                 ver_line_buf_cs;
reg  [5:0]                                 ver_line_buf_ns;

//----------------------------------------------------------gmem input
reg  [STACK_DLY*DBUF_DW-1:0]               i_data_que;   
wire [STACK_DLY*DBUF_DW-1:0]               i_data_que_nxt;
reg  [STACK_DATA-1:0]                      stack_i_data;
wire [STACK_DATA-1:0]                      stack_i_data_nxt;
reg  [DBUF_DW-1:0]                         cur_data_1st;
wire [DBUF_DW-1:0]                         cur_data_1st_nxt;
reg  [DBUF_DW-1:0]                         cur_data_2nd;
wire [DBUF_DW-1:0]                         cur_data_2nd_nxt;
wire [STACK_DATA-1:0]                      cur_data;
reg                                        hor_cur_sel;
wire                                       hor_cur_sel_nxt;

reg  [STACK_DATA-1:0]                      stack_wb_data;
wire [STACK_DATA-1:0]                      stack_wb_data_nxt;

reg  [KRNV_SZ-1-1:0]                       we_shift;
wire [KRNV_SZ-1-1:0]                       we_shift_nxt;

reg  [KRNV_SZ-1-1:0]                       wb_shift;
wire [KRNV_SZ-1-1:0]                       wb_shift_nxt;

reg                                        stack_wb_1st;
wire                                       stack_wb_1st_nxt;
reg                                        stack_wb_2nd;
wire                                       stack_wb_2nd_nxt;
reg  [STACK_NUM-1:0]                       stack_wb_vld;
wire [STACK_NUM-1:0]                       stack_wb_vld_nxt;

wire [GMEM_DWTH-1:0]                       gmem_we_cur;
wire [GMEM_DWTH-1:0]                       gmem_we_wb_part;
wire [GMEM_DWTH-1:0]                       gmem_we;
wire                                       gmem_en;
wire                                       geme_addr_sel          [0:SRAM_NUM-1];
wire [MEM_AW-1 : 0]                       gmem_addr              [0:SRAM_NUM-1];
wire [GMEM_DWTH-1:0]                       gmem_di_cur;
wire [GMEM_DWTH-1:0]                       gmem_di_wb;
wire [GMEM_DWTH-1:0]                       gmem_di;


//----------------------------------------------------------gmem output
wire [GMEM_DWTH-1:0]                       gmem_doa;

reg  [GMEM_ADDR_DATA_DLY+GMEM_SFT_DLY-1:0] data_o_sel_que;
wire [GMEM_ADDR_DATA_DLY+GMEM_SFT_DLY-1:0] data_o_sel_que_nxt;

reg  [(KRNV_SZ-1)*KRNV_WTH-1 : 0]          do_sel_en;
wire [(KRNV_SZ-1)*KRNV_WTH-1 : 0]          do_sel_en_nxt;
wire [(KRNV_SZ-1)*KRNV_WTH-1 : 0]          do_sel_en_ini;

wire [STACK_DATA-1:0]                      do_sel_sft             [0:KRNV_SZ-1];

wire [(KRNV_SZ)*DBUF_DW-1:0]               gmem_data_part ;

wire                                       data_o_sel;

//----------------------line buffer output data 
reg                                        output_en;
wire                                       output_en_nxt;
reg                                        href_en;
wire                                       href_en_nxt;
wire [DBUF_DW*KRNV_SZ-1:0]                 o_data_nxt;
wire                                       o_dvld_nxt;
wire                                       o_vstr_nxt;
wire                                       o_hstr_nxt;
wire                                       o_hend_nxt;
wire                                       o_vend_nxt;

//----------------------------------------------------------others
genvar gmi,gmi_2;
integer rst_i;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//------------------------------------------------------------------------------- horizontial store
assign line_buf_hstr           = hor_clr_smo & i_href;
assign hor_num_nxt             = (ver_fr_buf_smo & !hor_clr_smo ? (rd_cnt_nxt+1) << ODATA_FREQ : hor_num) | {HOR_WTH-2{ver_idle_smo}};           //use hor_pad_cnt to count hor number
assign blk_num_nxt             = (ver_fr_buf_smo & line_buf_hstr) ? hor_pad_cnt : {HOR_WTH{ver_idle_smo}} | blk_num;                             //use hor_pad_cnt to count blank number
assign href_num                = (hor_num >> (ODATA_FREQ+STACK_NUM-1))-1;                                                                        //count href number 
assign last_2nd_num_nxt        = (i_hend) ? do_sel_cnt : last_2nd_num;                                                                           //save do_sel_cnt in raw paddding mode 
assign rst_en_nxt              = (rst_en | (hblk_eq & !(ver_act_line_smo | ver_btm_pad_smo))) & !(ver_idle_smo & hor_clr_smo);

//--------------------------------------------------equal part //combine condition 
assign ver_pad_cnt_num         = ({KRNV_WTH{ver_fr_buf_smo}}    & (BUF_LINE-1))                                |                                 //ver_padding_num  mux 
                                 ({KRNV_WTH{ver_top_pad_smo}}   & (MAX_TOP_PAD-1))                             |
                                 ({KRNV_WTH{ver_btm_pad_smo}}   & (BTM_PAD-1));
                                 
assign ver_pad_cnt_eq          =                                  (ver_pad_cnt    == ver_pad_cnt_num);
assign buf_line_eq             = ver_fr_buf_smo                 &  ver_pad_cnt_eq                              & line_buf_hstr;                  //buffer line 
assign top_pad_eq              = ver_top_pad_smo                &  ver_pad_cnt_eq                              & line_buf_hstr;                  //top padding , 
assign btm_pad_eq              = ver_btm_pad_smo                &  ver_pad_cnt_eq;                                                               //bottom padding 
assign hblk_zero_eq            = ver_btm_pad_smo                & (ver_pad_cnt[0] == 1'b0)                     & PAD_MODE & hblk_eq;
assign ver_pad_zero_eq         = ver_top_pad_smo                & (ver_pad_cnt    == 0)                        & PAD_MODE;
assign ver_href_eq             = !ver_fr_buf_smo                & (ver_pad_cnt    == (MAX_TOP_PAD - TOP_PAD))  | (!TOP_PAD & ver_act_line_smo);  //control href 

assign hor_pad_cnt_num         = ({HOR_WTH{hor_fr_pad_smo}}     & ((FR_PAD_NUM_SEL)-1))                        |                                 //hor_padding_num  mux 
                                 ({HOR_WTH{hor_fr_pad_fnl_smo}} & ((FR_PAD_NUM_TOTAL)-1))                      |              
                                 ({HOR_WTH{hor_bk_pad_smo}}     & ((BK_PAD << ODATA_FREQ)-1))                  | 
                                 ({HOR_WTH{hor_line_blk_smo}}   & (blk_num-1))                                 | 
                                 ({HOR_WTH{hor_act_line_smo}}   & (HOR_OUT_DLY));
assign hor_pad_cnt_eq          =                                  (hor_pad_cnt    == hor_pad_cnt_num); 
assign fr_pad_eq               = hor_fr_pad_smo                 &  hor_pad_cnt_eq;                                                               //front padding 
assign fr_pad_final_eq         = hor_fr_pad_fnl_smo             &  hor_pad_cnt_eq;
assign bk_pad_eq               = hor_bk_pad_smo                 &  hor_pad_cnt_eq;                                                               //back padding 
assign act_pad_num_eq          = !ver_fr_buf_smo                & (hor_pad_cnt    == hor_num-1)                & BK_PAD_EN;                      //count line number 
assign hblk_eq                 = hor_line_blk_smo               &  hor_pad_cnt_eq;                                                               //line blank number
assign hor_fr_pad_1st_eq       = hor_fr_pad_smo                 & (hor_pad_cnt    == 0); 
assign hor_fr_pad_2nd_eq       = hor_fr_pad_smo                 & (hor_pad_cnt    == ODATA_FREQ_T);
assign hstr_eq                 = fr_pad_com_smo                 & (hor_pad_cnt    == HSTR_NUM-1); 
assign hor_href_eq             =                 (hor_pad_cnt[ODATA_FREQ_MIN-1:0] == ODATA_FREQ_T-1)           | !ODATA_FREQ; 

assign do_pad_eq               =                                  (do_sel_cnt     == KRNV_SZ-1-1)              & do_sel_cnt_inc;                 //do_sel_cnt equal 
assign rd_cyc_eq               =                                  (rd_cyc_cnt     == (ODATA_FREQ_T_1)-1);                                        //times two cause 1 write 1 read
assign href_num_eq             =                                  (wr_cnt         == href_num)                 & wr_cyc_eq & (!BK_PAD_EN | ver_fr_buf_smo);
assign wr_cyc_eq               =                                  (wr_cyc_cnt     == STACK_NUM-1)              & wr_cyc_cnt_inc;
assign rd_cnt_last_num_eq      =                                  (rd_cnt         == href_num);                                                  //count line number 

generate 
  for (gmi = 0;gmi<KRNV_SZ-1;gmi = gmi+1) begin : do_sel_en_equal
    assign do_sel_en_eq[gmi]   = (do_sel_en[(gmi+1)*KRNV_WTH-1 : (gmi)*KRNV_WTH] == 1'b1) & ver_pad_zero_eq;                                     //control do_sel_sft
  end 
endgenerate 

//--------------------------------------------------counter part
assign wr_cnt_nxt              = (wr_cnt_inc ? wr_cnt + 1'b1 : wr_cnt) & {(HOR_WTH){~wr_cnt_clr}};
assign wr_cnt_inc              = wr_cyc_eq;
assign wr_cnt_clr              = ver_idle_smo | hor_fr_pad_smo;

assign wr_cyc_cnt_nxt          = (wr_cyc_cnt_inc ? wr_cyc_cnt + 1'b1 : wr_cyc_cnt) & {(STACK_WTH+1){~wr_cyc_cnt_clr}};
assign wr_cyc_cnt_inc          = (hor_href_eq & hor_act_line_smo & !act_pad_num_eq) | bk_pad_eq;
assign wr_cyc_cnt_clr          = ver_idle_smo | hor_line_blk_smo | wr_cyc_eq | ver_btm_pad_smo;

assign ver_pad_cnt_nxt         = (ver_pad_cnt_inc ? ver_pad_cnt + 1'b1 : ver_pad_cnt) & {(HOR_WTH){~ver_pad_cnt_clr}};
assign ver_pad_cnt_inc         = line_buf_hstr | hblk_eq;
assign ver_pad_cnt_clr         = ver_idle_smo | (hblk_eq & ver_act_line_smo) | buf_line_eq | top_pad_eq;

assign rd_cnt_nxt              = (rd_cnt_inc ? rd_cnt + 1'b1 : rd_cnt) & {(HOR_WTH){~rd_cnt_clr}};
assign rd_cnt_inc              = (ver_fr_buf_smo & i_href) |                                                                                     //count href number in buffer state
                                 rd_cyc_eq & !(rd_cnt_last_num_eq);                                                                              //in order to keep the last address 
assign rd_cnt_clr              = hor_clr_smo;

assign rd_cyc_cnt_nxt          = (rd_cyc_cnt_inc ? rd_cyc_cnt + 1'b1 : rd_cyc_cnt) & {(ODATA_FREQ+1){~rd_cyc_cnt_clr}};
assign rd_cyc_cnt_inc          = rd_cyc_smo & !ver_fr_buf_smo;
assign rd_cyc_cnt_clr          = ver_idle_smo | rd_cyc_eq | hor_line_blk_smo;

assign hor_pad_cnt_nxt         = (hor_pad_cnt_inc ? hor_pad_cnt + 1'b1 : hor_pad_cnt) & {(HOR_WTH+ODATA_FREQ){~hor_pad_cnt_clr}};
assign hor_pad_cnt_inc         = !ver_idle_smo;
assign hor_pad_cnt_clr         = ver_idle_smo | ((ver_fr_buf_smo | hor_line_blk_smo) & (line_buf_hstr | i_hend)) | 
                                                (fr_pad_final_eq & !ver_fr_buf_smo) | act_pad_num_eq | bk_pad_eq | hblk_eq | (href_num_eq & !ver_fr_buf_smo); 

assign do_sel_cnt_nxt          = do_sel_cnt_set ? do_sel_cnt_set_val : (do_sel_cnt_inc ? do_sel_cnt + 1'b1 : do_sel_cnt) & {(KRNV_WTH+1){~do_sel_cnt_clr}};
assign do_sel_cnt_inc          = (!ver_fr_buf_smo & line_buf_hstr) | ((ver_act_line_smo | PAD_MODE) & hblk_eq);
assign do_sel_cnt_clr          = ver_idle_smo | do_pad_eq;
assign do_sel_cnt_set          = (PAD_MODE & hblk_zero_eq);                                                                                         //only occur in raw padding mode 
assign do_sel_cnt_set_val      = last_2nd_num;                  

//--------------------------------------------------output part
//-------------------------------------------------- HOR FSM
assign  hor_fr_pad_smo         = hor_line_buf_cs[3];
assign  hor_fr_pad_fnl_smo     = hor_line_buf_cs[4];
assign  hor_act_line_smo       = hor_line_buf_cs[5];
assign  hor_bk_pad_smo         = hor_line_buf_cs[6];
assign  hor_line_blk_smo       = hor_line_buf_cs[7];
assign  hor_clr_smo            = hor_line_buf_cs[2];
assign  fr_pad_com_smo         = hor_line_buf_cs[1];
assign  rd_cyc_smo             = hor_line_buf_cs[0];

always@* begin : buf_hor_fsm

hor_line_buf_ns = hor_line_buf_cs;

case (hor_line_buf_cs)

  HOR_IDLE   :       begin
                       if (line_buf_hstr)
                         hor_line_buf_ns = HOR_FR_PAD;
                     end

  HOR_FR_PAD  :      begin
                       if (fr_pad_eq | ver_idle_smo)
                         hor_line_buf_ns = HOR_FR_PAD_FNL;
                     end

  HOR_FR_PAD_FNL  :  begin
                         if (fr_pad_final_eq | ver_idle_smo)
                           hor_line_buf_ns = HOR_ACT_LINE;
                       end
                     
  HOR_ACT_LINE  :    begin
                       if (act_pad_num_eq | href_num_eq | ver_idle_smo)
                         if(BK_PAD_EN & !ver_fr_buf_smo)
                           hor_line_buf_ns = HOR_BK_PAD; 
                         else 
                           hor_line_buf_ns = HOR_LINE_BLK; 
                     end

  HOR_BK_PAD  :      begin
                       if (bk_pad_eq | ver_idle_smo)
                         hor_line_buf_ns = HOR_LINE_BLK;
                     end

  HOR_LINE_BLK  :  begin
                       if (hblk_eq & (btm_pad_eq | !BTM_PAD) | ver_idle_smo)
                         hor_line_buf_ns = HOR_IDLE;
                       else
                         if (hblk_eq | line_buf_hstr)
                           hor_line_buf_ns = HOR_FR_PAD;
                     end
endcase
end

//-------------------------------------------------- VER FSM
assign  ver_fr_buf_smo       = ver_line_buf_cs[2];
assign  ver_top_pad_smo      = ver_line_buf_cs[3];
assign  ver_act_line_smo     = ver_line_buf_cs[4];
assign  ver_btm_pad_smo      = ver_line_buf_cs[5];
assign  ver_sel_sft_smo      = ver_line_buf_cs[1];
assign  ver_idle_smo         = ver_line_buf_cs[0];


always@* begin : buf_ver_fsm

ver_line_buf_ns = ver_line_buf_cs;

case (ver_line_buf_cs)

  VER_IDLE   :        begin
                        if (line_buf_hstr)
                          ver_line_buf_ns = VER_FR_BUF;
                      end

  VER_FR_BUF  :       begin
                        if (buf_line_eq | rst_en)
                          ver_line_buf_ns = VER_TOP_PAD;
                      end

  VER_TOP_PAD  :      begin
                        if (top_pad_eq | rst_en)
                          ver_line_buf_ns = VER_ACT_LINE;
                      end
                      
  VER_ACT_LINE  :     begin
                       if (hblk_eq | rst_en) 
                          if(BTM_PAD)
                            ver_line_buf_ns = VER_BTM_PAD;
                          else
                            ver_line_buf_ns = VER_IDLE;
                      end
                      
  VER_BTM_PAD  :      begin
                        if ((hblk_eq & btm_pad_eq) | rst_en)
                          ver_line_buf_ns = VER_IDLE;
                      end
endcase
end

//-------------------------------------------------------------------------------gmem part 
//----------------------current line
assign i_data_que_nxt    = (i_href | hor_href_eq) ? {i_data_que[(STACK_DLY-1)*DBUF_DW-1:0],i_data} : i_data_que;
assign stack_i_data_nxt  = (hor_bk_pad_smo) ? {cur_data_1st,cur_data_2nd} : 
                           hor_href_eq      ? {stack_i_data[DBUF_DW-1:0],i_data_que[(STACK_DLY)*DBUF_DW-1:(STACK_DLY-1)*DBUF_DW]} : stack_i_data;          //stack data into 2 data
assign cur_data_1st_nxt  = (hor_fr_pad_1st_eq)  ? i_data_que[DBUF_DW-1:0] : i_hend ? i_data_que[DBUF_DW-1:0] : cur_data_1st ; 
assign cur_data_2nd_nxt  = (hor_fr_pad_2nd_eq | i_hend_dly) ? i_data_que[DBUF_DW-1:0] : cur_data_2nd ;                                                     //first and second data of line
assign cur_data          = hor_act_line_smo ? {STACK_DATA{i_data_que[(STACK_DLY)*DBUF_DW-1:(STACK_DLY-1)*DBUF_DW]}} : 
                                              {cur_data_1st,cur_data_2nd};                                                                                 //change input or padding data
assign stack_wb_data_nxt = ((fr_pad_com_smo | hor_act_line_smo) & hor_href_eq) ? {stack_wb_data[DBUF_DW-1:0],i_wb} : stack_wb_data;                        //stack two write back data
//----------------------gmem input control 
generate 
  if(LINE_DLY == 0) 
    assign wb_shift_nxt  = 0;
  else 
    if(LINE_DLY == 1) 
      assign wb_shift_nxt  = ver_idle_smo ? {{KRNV_SZ-2{1'b0}},1'b1} : (ver_pad_cnt_inc) ? {wb_shift[KRNV_SZ-1-1-1:0],wb_shift[KRNV_SZ-1-1]}: wb_shift;
    else 
      assign wb_shift_nxt  = ver_idle_smo ? {{LINE_DLY-2{1'b0}},1'b1,{KRNV_SZ-2-(LINE_DLY-2){1'b0}}} : (ver_pad_cnt_inc) ? {wb_shift[KRNV_SZ-1-1-1:0],wb_shift[KRNV_SZ-1-1]}: wb_shift;
endgenerate      


assign we_shift_nxt      = ver_idle_smo ? {{KRNV_SZ-1-1{1'b0}},1'b1} : (ver_pad_cnt_inc) ? {we_shift[KRNV_SZ-1-1-1:0],we_shift[KRNV_SZ-1-1]} :  we_shift;  //control write enable 

assign stack_wb_1st_nxt  = (hor_href_eq & !wr_cyc_eq) ? i_wb_vld : stack_wb_1st;                                                                           //the first write back data
assign stack_wb_2nd_nxt  = (hor_href_eq & wr_cyc_eq) ? i_wb_vld : stack_wb_2nd;                                                                            //the second write back data
assign stack_wb_vld_nxt  = hor_bk_pad_smo ? stack_wb_vld : {stack_wb_1st_nxt,stack_wb_2nd_nxt};

generate
  for (gmi = 0;gmi < KRNV_SZ-1;gmi = gmi+1) begin : gmem_wb_en
    for (gmi_2 = 0;gmi_2 < STACK_NUM;gmi_2 = gmi_2+1) begin : gmem_wb_en
      assign gmem_we_wb_part[DBUF_DW*(STACK_NUM*gmi +gmi_2+1)-1 : DBUF_DW*(STACK_NUM*gmi +gmi_2)]  = {DBUF_DW{stack_wb_vld_nxt[gmi_2] & wb_shift[gmi] & wr_cyc_eq}};//enable wb line 
    end
  end
endgenerate

generate
  for (gmi = 0;gmi < KRNV_SZ-1;gmi = gmi+1) begin : gmem_wr_en
      assign gmem_we_cur[STACK_DATA*(gmi+1)-1 : STACK_DATA*(gmi)] = {STACK_DATA{wr_cyc_eq & we_shift[gmi]}}; 
      assign gmem_we[STACK_DATA*(gmi+1)-1 : STACK_DATA*(gmi)]     = gmem_we_cur[STACK_DATA*(gmi+1)-1 : STACK_DATA*(gmi)] | gmem_we_wb_part[STACK_DATA*(gmi+1)-1 : STACK_DATA*(gmi)]; 
  end
endgenerate

assign gmem_en           = !ver_idle_smo;  
assign gmem_di_cur       = {KRNV_SZ-1{stack_i_data_nxt}}  & gmem_we_cur;
assign gmem_di_wb        = {KRNV_SZ-1{stack_wb_data_nxt}} & gmem_we_wb_part;
assign gmem_di           = ((gmem_we & ~gmem_we_wb_part) & gmem_di_cur) | (gmem_we_wb_part & gmem_di_wb);                                       //merge write back data and write data

generate 
  for (gmi = 0;gmi<SRAM_NUM;gmi = gmi+1) begin : gen_addr_sel
  if (SRAM_NUM > 1)begin 
assign geme_addr_sel[gmi]     = |we_shift[((KRNV_SZ-1)/SRAM_NUM)*gmi+:((KRNV_SZ-1)/SRAM_NUM)];
assign gmem_addr[gmi]         = (wr_cyc_eq & geme_addr_sel[gmi]) ? wr_cnt : ({HOR_WTH-1{!ver_fr_buf_smo}} & rd_cnt); 
  end 
  else begin 
assign gmem_addr[0]           = (wr_cyc_eq) ? wr_cnt : ({HOR_WTH-1{!ver_fr_buf_smo}} & rd_cnt); 
  end  
  end 
endgenerate 

//----------------------gmem output data 
assign do_sel_en_ini     = (!PAD_MODE) ? {KRNV_SZ*KRNV_WTH{1'b0}} : {KRNV_PAD{({{KRNV_WTH-1{1'b0}},1'b0}),({{KRNV_WTH-1{1'b0}},1'b1})}};        //duplicate padding or raw padding 
assign do_sel_en_nxt     = ({KRNV_SZ*KRNV_WTH{ver_fr_buf_smo}}                           & do_sel_en_ini) |                                     //initial 
                           ({KRNV_SZ*KRNV_WTH{(!hor_fr_pad_1st_eq)}}                     & do_sel_en) |                                         //keep sel_en 
                           ({KRNV_SZ*KRNV_WTH{(ver_sel_sft_smo & (hor_fr_pad_1st_eq))}}  & {do_sel_en[(KRNV_SZ-1)*KRNV_WTH-1:0],do_sel_cnt});   //do_sel_cnt shift  do_sel_cnt name 


generate 
  for (gmi = 1;gmi<KRNV_SZ;gmi = gmi+1) begin : do_sel
    assign do_sel_sft[gmi] = (do_sel_en_eq[gmi-1]) ? cur_data : (gmem_doa & {GMEM_DWTH{!ver_fr_buf_smo}}) >> 
                                                                STACK_DATA*(do_sel_en[(gmi)*KRNV_WTH-1 : (gmi-1)*KRNV_WTH]);                    //use shift to get data from sram 
  end 
endgenerate 

    assign do_sel_sft[0]   = ver_btm_pad_smo ? do_sel_sft[PAD_MODE+1] : cur_data;                                                               //lsb output 

generate
  for (gmi = 0;gmi<KRNV_SZ;gmi = gmi+1) begin : data_o_ressemble
    assign gmem_data_part[DBUF_DW*(gmi+1)-1 : DBUF_DW*gmi]   = (((hor_bk_pad_smo & !PAD_MODE) | hor_pad_cnt[ODATA_FREQ]) & (!fr_pad_com_smo | PAD_MODE))  ?  
                                                               do_sel_sft[gmi][DBUF_DW*(STACK_NUM-1)-1 : 0] :                                   //select one data from two stack data 
                                                               do_sel_sft[gmi][(STACK_DATA)-1   : DBUF_DW*(STACK_NUM-1)];                       
end
endgenerate //timing critical 

//----------------------line buffer output data 

//---------------------------------------------------------------------------------------------------------------------// 
//-----------------------------------------(gmem_data_part data sorting)-----------------------------------------------//
//     MSB|------------------------------------------------------------------------|LSB                           -----//
//<--------{gmem_data_part[KRNV_SZ],gmem_data_part[KRNV_SZ-1]....,gmem_data_part[0]} <----------- new data input  -----//
//old line|------------------------------------------------------------------------|new line                      -----//
//---------------------------------------------------------------------------------------------------------------------//

assign output_en_nxt    = (ver_href_eq | output_en) & !ver_idle_smo; 
assign href_en_nxt      = (o_hstr_nxt | href_en) & !o_hend_nxt;
                                                                         
assign o_data_nxt       = gmem_data_part;
assign o_dvld_nxt       = href_en & hor_href_eq;
assign o_vstr_nxt       = i_vstr;
assign o_hstr_nxt       = output_en_nxt & hstr_eq;
assign o_hend_nxt       = output_en_nxt & (((BK_PAD_EN) & bk_pad_eq) | (!BK_PAD_EN & href_num_eq));
assign o_vend_nxt       = (o_hend & btm_pad_eq) | (!BTM_PAD & hblk_eq);

//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//
generate  
  for(gmi=0;gmi<SRAM_NUM;gmi=gmi+1) begin : ip_gmem_gen
ip_gmem
#(
  .MEM_DEP           (MEM_DEP),
  .MEM_DW            (SRAM_DWTH),
  .MEM_WWWD          (SRAM_DWTH), 
  .MEM_TYPE          (MEM_TYPE),
  .MEM_NAME          (MEM_NAME),
  .DO_FFO            (DO_FFO),
  .DO_XTRA_1T        (),
  .DO_ON_WR          (DO_ON_WR),
  .MEM_AW            (MEM_AW)
)
f_buf
(
  .doa               (gmem_doa[(GMEM_DWTH/SRAM_NUM)*gmi+:(GMEM_DWTH/SRAM_NUM)]), 
  .dob               (),
  .doa_vld           (),
  .dob_vld           (),

  .mbist_done        (),
  .mbist_err         (),

  .wea               ({{SRAM_ZERO_EXT{1'b0}},gmem_we[(GMEM_DWTH/SRAM_NUM)*gmi+:(GMEM_DWTH/SRAM_NUM)]}),
  .ena               (gmem_en),
  .enb               (1'b0),
  .clr               (1'b0),
  .addra             (gmem_addr[gmi]),
  .addrb             ({HOR_WTH-1{1'b0}}),
  .dia               ({{SRAM_ZERO_EXT{1'b0}},gmem_di[(GMEM_DWTH/SRAM_NUM)*gmi+:(GMEM_DWTH/SRAM_NUM)]}),
  .mopt              (8'b0),
  .mbist_en          (1'b0),

  .clka              (clk),
  .clkb              (clk),
  .arst_n            (rst_n),
  .brst_n            (rst_n)
);
end 
endgenerate

always@(posedge clk or negedge rst_n) begin
if (!rst_n) begin

//----------------------------------------------------------control part
  hor_num          <= {HOR_WTH+ODATA_FREQ{1'b1}};
  blk_num          <= {HOR_WTH+ODATA_FREQ{1'b1}};
  last_2nd_num     <= 0;
  i_hend_dly       <= 0;
  rst_en           <= 0;
  
//----------------------------------------------------------counter part 
  wr_cnt           <= 0;
  wr_cyc_cnt       <= 0;
  ver_pad_cnt      <= 0;
  rd_cnt           <= 0;
  rd_cyc_cnt       <= 0;
  hor_pad_cnt      <= 0;
  do_sel_cnt       <= 0;

//----------------------------------------------------------output part
//------------------------------------------------gmem input
  i_data_que       <= 0;
  stack_i_data     <= 0;
  cur_data_1st     <= 0;
  cur_data_2nd     <= 0;
  hor_cur_sel      <= 0;
  we_shift         <= 0; 
  stack_wb_data    <= 0;
  stack_wb_vld     <= 0;
  
  stack_wb_1st     <= 0;
  stack_wb_2nd     <= 0;
  wb_shift         <= 0;
  
//-----------------------------------------------gmem output
  data_o_sel_que   <= 0;
  do_sel_en        <= 0;

//----------------------------------------------------------line buffer output data 
  output_en        <= 0;
  href_en          <= 0;
  o_data           <= 0;
  o_dvld           <= 0;
  o_vstr           <= 0;
  o_hstr           <= 0;
  o_hend           <= 0;
  o_vend           <= 0;
  
end
else begin

//----------------------------------------------------------control part
  hor_num          <= hor_num_nxt;
  blk_num          <= blk_num_nxt;
  last_2nd_num     <= last_2nd_num_nxt;
  i_hend_dly       <= i_hend;
  rst_en           <= rst_en_nxt;
  
//----------------------------------------------------------counter part 
  wr_cnt           <= wr_cnt_nxt;
  wr_cyc_cnt       <= wr_cyc_cnt_nxt;
  ver_pad_cnt      <= ver_pad_cnt_nxt;
  rd_cnt           <= rd_cnt_nxt;
  rd_cyc_cnt       <= rd_cyc_cnt_nxt;
  hor_pad_cnt      <= hor_pad_cnt_nxt;
  do_sel_cnt       <= do_sel_cnt_nxt;
  
//----------------------------------------------------------output part
//------------------------------------------------gmem input
  i_data_que       <= i_data_que_nxt;
  stack_i_data     <= stack_i_data_nxt;
  cur_data_1st     <= cur_data_1st_nxt;
  cur_data_2nd     <= cur_data_2nd_nxt;
  hor_cur_sel      <= hor_cur_sel_nxt;
  we_shift         <= we_shift_nxt;
  stack_wb_data    <= stack_wb_data_nxt;
  stack_wb_vld     <= stack_wb_vld_nxt;
  
  stack_wb_1st     <= stack_wb_1st_nxt;
  stack_wb_2nd     <= stack_wb_2nd_nxt;
  wb_shift         <= wb_shift_nxt;
  
//-----------------------------------------------gmem output
  data_o_sel_que   <= data_o_sel_que_nxt;
  do_sel_en        <= do_sel_en_nxt;

//----------------------------------------------------------line buffer output data 
  output_en        <= output_en_nxt;
  href_en          <= href_en_nxt;
  o_data           <= o_data_nxt;
  o_dvld           <= o_dvld_nxt;
  o_vstr           <= o_vstr_nxt;
  o_hstr           <= o_hstr_nxt;
  o_hend           <= o_hend_nxt;
  o_vend           <= o_vend_nxt;
  
end
end

always@(posedge clk or negedge rst_n) begin
if (!rst_n) begin
  hor_line_buf_cs <= HOR_IDLE;
  ver_line_buf_cs <= VER_IDLE;
end
else begin
  hor_line_buf_cs <= hor_line_buf_ns;
  ver_line_buf_cs <= ver_line_buf_ns;
end
end

endmodule

