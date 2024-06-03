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
`timescale 1ns/1ps  
`define   TB_TOP            vtm_tb
`define   MONITOR_TOP       vtm_mon
`define   vtm               `TB_TOP.vtm
`define   axi4l2ram_s       `TB_TOP.axi4l2ram_s_top_wrapper.axi4l2ram_s_top_i.axi4l2ram_s_0.inst

`define   HOST_WR           nope                 //get error when scarcing this parameter
`define   SSR_TOP           `TB_TOP              //get error when scarcing this parameter

// module start 
module vtm_tb();
import axi_vip_pkg::*;
import axi4l2ram_s_top_axi_vip_0_0_pkg::*;

//================================================================================
// simulation config console
//================================================================================

`include "reg_wire_declare.name"

string                    ini_file_name                = "reg_config.ini";
string                    test_pat_name                = "";
string                    gold_num                     = "";
string                    ppm_file_name                = "";
//================================================================================
//  parameter declaration
//================================================================================

//----------------------------------------------------------------tb
parameter                 PERIOD                       =  10;

parameter [14*8-1:0]      VIDEO_RESOLUTION [0:4]       =  {"1080p_60/30fps", "1080p_50fps","720p_60fps" , "720p_30fps", "custom" }; //one ASCII need one byte

//parameter [17:0]          VIDEO_RESOLUTION [0:4]       =  {18'd1080_60, 18'd1080_50,18'd720_60, 18'd720_30, 18'd0 }; 
parameter [11:0]          HOR_TOTAL_TIME   [0:4]       =  {12'd2200 , 12'd2640 , 12'd1650 , 12'd3300 , 12'd58 }; 
parameter [11:0]          HOR_ADDR_TIME    [0:4]       =  {12'd1920 , 12'd1920 , 12'd1280 , 12'd1280 , 12'd48 };
parameter [11:0]          HOR_BLANK_TIME   [0:4]       =  {12'd280  , 12'd720  , 12'd370  , 12'd2020 , 12'd10 };
parameter [11:0]          HOR_SYNC_START   [0:4]       =  {12'd2008 , 12'd2448 , 12'd1390 , 12'd3040 , 12'd51 };
parameter [11:0]          HOR_FRONT_PORCH  [0:4]       =  {12'd88   , 12'd528  , 12'd110  , 12'd1760 , 12'd3  };
parameter [11:0]          HOR_SYNC_TIME    [0:4]       =  {12'd44   , 12'd44   , 12'd40   , 12'd40   , 12'd2  };
parameter [11:0]          HOR_BACK_PORCH   [0:4]       =  {12'd148  , 12'd148  , 12'd220  , 12'd220  , 12'd5  };
parameter [11:0]          VER_TOTAL_TIME   [0:4]       =  {12'd1125 , 12'd1125 , 12'd750  , 12'd750  , 12'd29 };
parameter [11:0]          VER_ADDR_TIME    [0:4]       =  {12'd1080 , 12'd1080 , 12'd720  , 12'd720  , 12'd27 };
parameter [11:0]          VER_BLANK_TIME   [0:4]       =  {12'd45   , 12'd45   , 12'd30   , 12'd30   , 12'd2  };
parameter [11:0]          VER_SYNC_START   [0:4]       =  {12'd1084 , 12'd1084 , 12'd725  , 12'd725  , 12'd28 };
parameter [11:0]          VER_FRONT_PORCH  [0:4]       =  {12'd4    , 12'd4    , 12'd5    , 12'd5    , 12'd1  };
parameter [11:0]          VER_SYNC_TIME    [0:4]       =  {12'd5    , 12'd5    , 12'd5    , 12'd5    , 12'd1  };
parameter [11:0]          VER_BACK_PORCH   [0:4]       =  {12'd36   , 12'd36   , 12'd20   , 12'd20   , 12'd1  };

/*
parameter [11:0]          HOR_TOTAL_TIME   [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd58 }; 
parameter [11:0]          HOR_ADDR_TIME    [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd48 };
parameter [11:0]          HOR_BLANK_TIME   [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd10 };
parameter [11:0]          HOR_SYNC_START   [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd51 };
parameter [11:0]          HOR_FRONT_PORCH  [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd3  };
parameter [11:0]          HOR_SYNC_TIME    [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd2  };
parameter [11:0]          HOR_BACK_PORCH   [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd5  };
parameter [11:0]          VER_TOTAL_TIME   [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd29 };
parameter [11:0]          VER_ADDR_TIME    [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd27 };
parameter [11:0]          VER_BLANK_TIME   [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd2  };
parameter [11:0]          VER_SYNC_START   [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd28 };
parameter [11:0]          VER_FRONT_PORCH  [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd1  };
parameter [11:0]          VER_SYNC_TIME    [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd1  };
parameter [11:0]          VER_BACK_PORCH   [0:4]       =  {12'd0 , 12'd0, 12'd0 , 12'd0 , 12'd1  };
*/
//================================================================================
//  signal declaration
//================================================================================
//--------------------------------------------------------------------------------tb 
reg                                            rst_n;
reg                                            clk;

//--------------------------------------------------------------------------------config
reg                                            TB_SYS_CLK;
reg                                            reg_ini_done;

//--------------------------------------------------------------------------------vtm 
wire [4:0]                                     o_fstr;
wire [4:0]                                     o_fend;
wire [4:0]                                     o_vblk;
wire [4:0]                                     o_vsync;
wire [4:0]                                     o_vstr;
wire [4:0]                                     o_vend;
wire [4:0]                                     o_vref;
wire [4:0]                                     o_hstr;
wire [4:0]                                     o_hblk;
wire [4:0]                                     o_hsync;
wire [4:0]                                     o_hend;
wire [4:0]                                     o_href;
wire [35:0]                                    o_data   [0:4];
wire [31:0]                                    o_slv_rd [0:4];
reg                                            i_vtm_en;
reg                                            i_slv_en; 
reg                                            i_slv_we;
reg  [31:0]                                    i_slv_addr;
reg  [31:0]                                    i_slv_wd;
wire [5:0]                                     o_bug_vtm_ver_cs [0:4];                
wire [5:0]                                     o_bug_vtm_hor_cs [0:4];                
wire                                           o_bug_ver_cnt_clr[0:4];
wire                                           o_bug_hor_cnt_clr[0:4];
wire                                           o_bug_fsm_en[0:4];
wire                                           o_bug_ver_cnt_chg[0:4];
//---------------------------------------------------------------------------------simulation
reg                                            sim_fin;
wire                                           hor_idle;
genvar                                         gv_i,gv_n;
reg  [11:0]                                    hor_total_time [0:4] =  HOR_TOTAL_TIME ;
reg  [11:0]                                    hor_addr_time  [0:4] =  HOR_ADDR_TIME  ;
reg  [11:0]                                    hor_blank_time [0:4] =  HOR_BLANK_TIME ;
reg  [11:0]                                    hor_sync_start [0:4] =  HOR_SYNC_START ;
reg  [11:0]                                    hor_front_porch[0:4] =  HOR_FRONT_PORCH;
reg  [11:0]                                    hor_sync_time  [0:4] =  HOR_SYNC_TIME  ;
reg  [11:0]                                    hor_back_porch [0:4] =  HOR_BACK_PORCH ;
reg  [11:0]                                    ver_total_time [0:4] =  VER_TOTAL_TIME ;
reg  [11:0]                                    ver_addr_time  [0:4] =  VER_ADDR_TIME  ;
reg  [11:0]                                    ver_blank_time [0:4] =  VER_BLANK_TIME ;
reg  [11:0]                                    ver_sync_start [0:4] =  VER_SYNC_START ;
reg  [11:0]                                    ver_front_porch[0:4] =  VER_FRONT_PORCH;
reg  [11:0]                                    ver_sync_time  [0:4] =  VER_SYNC_TIME  ;
reg  [11:0]                                    ver_back_porch [0:4] =  VER_BACK_PORCH ;

// -------------------------------------------------//
// AXI VIP declaration                              //
// -------------------------------------------------//

xil_axi_resp_t 	        resp;
xil_axi_prot_t          prot = 0;
bit [31:0]              axt_rd;

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

always@(posedge clk or negedge rst_n) begin 
  if(!rst_n) begin 
    i_vtm_en     <= 0;
    i_slv_en     <= 0;
    i_slv_we     <= 0;
    i_slv_addr   <= 0;
    i_slv_wd     <= 0;
  end
  else begin
    i_vtm_en     <= 1;
    i_slv_en     <= 1;
    i_slv_we     <= 1;
    i_slv_addr   <= 0;
    i_slv_wd     <= 1;
  end
end


//--------------------------------------------------------------------------------
// simulation patten
//--------------------------------------------------------------------------------

// Initial step & Simulation scenario
// -------------------------------------------------//

assign hor_idle = o_bug_vtm_hor_cs[ini_sel] == 6'b00_0001;

axi4l2ram_s_top_axi_vip_0_0_mst_t axi_vip;


initial begin: TB_INI
   sim_fin = 0;
   // Create an agent
   axi_vip = new("master vip agent",axi4l2ram_s_top_wrapper.axi4l2ram_s_top_i.axi_vip_0.inst.IF);

   // set tag for agents for easy debug
   axi_vip.set_agent_tag("Master VIP");

   // set print out verbosity level.
   axi_vip.set_verbosity(400);

   //Start the agent
   axi_vip.start_master();


// Use the tasks AXI4LITE_READ_BURST and AXI4LITE_WRITE_BURST to send read and write commands

   repeat(10) @ (posedge clk);

   axi_vip.AXI4LITE_WRITE_BURST(32'h04,prot,r_vtc_en_sel,resp);           //en_sel

   axi_vip.AXI4LITE_WRITE_BURST(32'h08,prot,r_vtc_tp_sel,resp);           //tp_sel

   axi_vip.AXI4LITE_WRITE_BURST(32'h0c,prot,r_vtc_vsync_offset1108,resp); //offset1108

   axi_vip.AXI4LITE_WRITE_BURST(32'h10,prot,r_vtc_vsync_offset0700,resp); //offset0700

   axi_vip.AXI4LITE_WRITE_BURST(32'h00,prot,r_vtc_en,resp);               //enable

   wait(~o_fend[ini_sel])
   wait(o_fend[ini_sel])
   wait(~o_fend[ini_sel])
   wait(o_fend[ini_sel])

   axi_vip.AXI4LITE_WRITE_BURST(32'h00,prot,32'h0,resp); //disable


   wait(~o_fend[ini_sel])
   wait(o_fend[ini_sel])

   axi_vip.AXI4LITE_WRITE_BURST(32'h00,prot,32'h1,resp); //enable

   wait(~o_fend[ini_sel])
   wait(o_fend[ini_sel])
   repeat(10000) @ (posedge clk);

   axi_vip.AXI4LITE_WRITE_BURST(32'h00,prot,32'h0,resp); //disable


   wait(~o_fend[ini_sel])
   wait(o_fend[ini_sel])
   wait(~hor_idle)
   wait(hor_idle)
   repeat(10000) @ (posedge clk);

   axi_vip.AXI4LITE_WRITE_BURST(32'h00,prot,32'h1,resp); //enable

   wait(~o_fend[ini_sel])
   wait(o_fend[ini_sel])
   repeat(100000) @ (posedge clk);

   sim_fin = 1;
end

//================================================================================
//  module instantiation
//================================================================================
 
//--------------------------------------------------------------------------------axi4l2ram_s_top_wrapper
axi4l2ram_s_top_wrapper axi4l2ram_s_top_wrapper

   (
    .aclk_0     (clk),
    .aresetn_0  (rst_n));

generate 
  for(gv_i=0;gv_i<=4;gv_i=gv_i+1)begin 

  vtm #(
       .VIDEO_RESOLUTION   (VIDEO_RESOLUTION[gv_i] ) ,
       .HOR_TOTAL_TIME     (HOR_TOTAL_TIME[gv_i]   ) , 
       .HOR_ADDR_TIME      (HOR_ADDR_TIME[gv_i]    ) ,
       .HOR_BLANK_TIME     (HOR_BLANK_TIME[gv_i]   ) ,
       .HOR_SYNC_START     (HOR_SYNC_START[gv_i]   ) ,
       .HOR_FRONT_PORCH    (HOR_FRONT_PORCH[gv_i]  ) ,
       .HOR_SYNC_TIME      (HOR_SYNC_TIME[gv_i]    ) ,
       .HOR_BACK_PORCH     (HOR_BACK_PORCH[gv_i]   ) ,
       .VER_TOTAL_TIME     (VER_TOTAL_TIME[gv_i]   ) ,
       .VER_ADDR_TIME      (VER_ADDR_TIME[gv_i]    ) ,
       .VER_BLANK_TIME     (VER_BLANK_TIME[gv_i]   ) ,
       .VER_SYNC_START     (VER_SYNC_START[gv_i]   ) ,
       .VER_FRONT_PORCH    (VER_FRONT_PORCH [gv_i] ) ,
       .VER_SYNC_TIME      (VER_SYNC_TIME[gv_i]    ) ,
       .VER_BACK_PORCH     (VER_BACK_PORCH[gv_i]   ) 
        ) 

vtm
(

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
        .o_fstr            (o_fstr[gv_i]),
        .o_fend            (o_fend[gv_i]),
        .o_vblk            (o_vblk[gv_i]),
        .o_vsync           (o_vsync[gv_i]),
        .o_vstr            (o_vstr[gv_i]),
        .o_vend            (o_vend[gv_i]),
        .o_vref            (o_vref[gv_i]),
        .o_hstr            (o_hstr[gv_i]),
        .o_hblk            (o_hblk[gv_i]),
        .o_hsync           (o_hsync[gv_i]),
        .o_hend            (o_hend[gv_i]),
        .o_href            (o_href[gv_i]),
        .o_data            (o_data[gv_i]),
        .o_slv_rd          (o_slv_rd[gv_i]),
        .o_bug_vtm_ver_cs  (o_bug_vtm_ver_cs[gv_i]),
        .o_bug_vtm_hor_cs  (o_bug_vtm_hor_cs[gv_i]),
        .o_bug_ver_cnt_clr (o_bug_ver_cnt_clr[gv_i]),
        .o_bug_hor_cnt_clr (o_bug_hor_cnt_clr[gv_i]),
        .o_bug_fsm_en      (o_bug_fsm_en[gv_i]),
        .o_bug_ver_cnt_chg (o_bug_ver_cnt_chg[gv_i]),

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
        .vtm_clk        (clk),
        .vtm_rst_n      (rst_n),
        .slv_clk        (clk),
        .slv_rst_n      (rst_n),
        .i_vtm_en       (i_vtm_en),
        .i_slv_en       (`axi4l2ram_s.o_slv_en0),
        .i_slv_we       (`axi4l2ram_s.o_slv_we),
        .i_slv_addr     (`axi4l2ram_s.o_slv_addr),
        .i_slv_wd       (`axi4l2ram_s.o_slv_wd)
); 


  end 
endgenerate

       img_tpat 
       img_tpat(
        .data_o          (),            
        .tpat_en         (tpat_en),           
        .vstr_i          (o_vstr[0]),            
        .hstr_i          (o_hstr[0]),            
        .hend_i          (o_hend[0]),            
        .data_i          (10'h3ff),            
        .tpat_vcnt       (`MONITOR_TOP.mon_ver_cnt[4:0]),         
        .tpat_hcnt       (`MONITOR_TOP.mon_hor_cnt[4:0]),         
        .reg_tpat_sel    (32'b0),      
        .reg_tpat_ctrl   (6'b111111),     
        .clk             (clk),               
        .rst_n           (rst_n)
        );

//--------------------------------------------------------------------------------
// monitor patten
//--------------------------------------------------------------------------------

     vtm_mon 
     vtm_mon(
       .i_bug_vtm_ver_cs   (o_bug_vtm_ver_cs)  ,
       .i_bug_vtm_hor_cs   (o_bug_vtm_hor_cs)  ,
       .i_bug_ver_cnt_clr  (o_bug_ver_cnt_clr) ,
       .i_bug_hor_cnt_clr  (o_bug_hor_cnt_clr) ,
       .i_bug_fsm_en       (o_bug_fsm_en)      ,
       .i_bug_ver_cnt_chg  (o_bug_ver_cnt_chg),
       .i_hor_total_time   (hor_total_time), 
       .i_hor_addr_time    (hor_addr_time) ,
       .i_hor_blank_time   (hor_blank_time), 
       .i_hor_sync_start   (hor_sync_start) ,
       .i_hor_front_porch  (hor_front_porch),
       .i_hor_sync_time    (hor_sync_time),  
       .i_hor_back_porch   (hor_back_porch) ,
       .i_ver_total_time   (ver_total_time) ,
       .i_ver_addr_time    (ver_addr_time) , 
       .i_ver_blank_time   (ver_blank_time) ,
       .i_ver_sync_start   (ver_sync_start) ,
       .i_ver_front_porch  (ver_front_porch),
       .i_ver_sync_time    (ver_sync_time) , 
       .i_ver_back_porch   (ver_back_porch) 
   );


ppm_monitor #(
            .PX_FMT       ("RGB8"),
            .IMG_HSZ      (1920),
            .IMG_VSZ      (1080),
            .GOLD_HOFT    (0),
            .GOLD_VOFT    (0)
         )
ppm_monitor  (

            .vstr         (o_vstr[ini_sel]),          
            .vend         (o_vend[ini_sel]),            
            .hstr         (o_hstr[ini_sel]),           
            .hend         (o_hend[ini_sel]),            
            .dvld         (o_href[ini_sel]),                 
            .bidx         (1'b0),         
            .data         (o_data[ini_sel]),         
            .clk          (clk),           
            .rst_n        (rst_n)       
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
//  waveform dump setting
//--------------------------------------------------------------------------------

initial begin 
      $fsdbDumpfile("./wave/vtm_tb");
      $fsdbDumpvars(0,vtm_tb,"+all");
      $fsdbDumpvars(0,`MONITOR_TOP,"+all");
      wait(~sim_fin)
      wait(sim_fin)
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
