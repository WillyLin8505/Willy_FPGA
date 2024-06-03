// ------------------------------------------------------------------------------//
// (C) Copyright. 2021
// SILICON OPTRONICS CORPORATION ALL RIGHTS RESERVED
//
// This design is confidential and proprietary owned by Silicon Optronics Corp.
// Any distribution and modification must be authorized by a licensing agreement
// ------------------------------------------------------------------------------//
// Filename        : i2c_master_top_tb.v
// Author          : Willylin
// Version         : $Revision$
// Last Modified On: 2021/11/5
// Last Modified By: $Author$
// 
// Description     :verify ip_i2cm_top ,reg page 10
// ------------------------------------------------------------------------------//

// defination & include
`timescale 1ns/1ns  
`define   TB_TOP            i2c_master_cont_top_tb
`define   MONITOR_TOP       i2c_master_cont_top_mon
`define   REG_DATA_TOP      `TB_TOP.soisp_reg_top.data_page     
`define   REG_CONFIG_TOP    `TB_TOP.soisp_reg_top.config_page
`define   I2CM_ARBI         `TB_TOP.i2cm_top.i2cm_arbiter
`define   I2CM              `TB_TOP.i2cm_top.i2cm
`define   I2CM_CTRL         `TB_TOP.i2cm_top.i2cm.i2cm_ctrl
 // module start 
module i2c_master_cont_top_tb();

//================================================================================
// simulation config console
//================================================================================

`include "reg_wire_declare.name"

string               ini_file_name                = "reg_config.ini";
string               test_pat_name                = "";
string               ppm_file_name                = "";
string               gold_img_num                 = "";
//---------------------------------------------------clk
parameter            I2CM_DEV_CLK_PERIOD          = 20;
parameter            I2CM_FX3_CLK_PERIOD          = 60;
parameter            I2CS_DEV_CLK_PERIOD          = 5;
parameter            I2CS_FX3_CLK_PERIOD          = 20;
//---------------------------------------------------i2cm top
parameter            I2CM_TRG_CDC                 = "ASYNC";      //"SYNC"/"ASYNC"
parameter            I2CM_TRG_TYPE                = "MUTI";       //"MUTI" for muti trigger/"SGL" for one trigger
parameter            I2CM_NUM                     = 32;
parameter            I2CM_FIFO_DWID               = 16;           //cdc fifo bit width
parameter            I2CM_FIFO_DEPTH              = 4;            //cdc fifo deep width
parameter            I2CM_DO_FFO_EN               = 0;            //dff out 
//---------------------------------------------------device slave
parameter            I2C_SLAVE_ID                 = 7'b0101100;
parameter            I2C_SLAVE_FX3_ID             = 7'b1001100;


//================================================================================
//  signal declaration
//================================================================================
//----------------------------------------------test bench
reg                  i2cmd_rst_n;
reg                  i2cmd_clk;
reg                  i2cmf_rst_n;
reg                  i2cmf_clk;
reg                  i2csd_clk;
reg                  i2csd_rst_n;
reg                  i2csf_clk;
reg                  i2csf_rst_n;
reg                  ini_i2cm_trg_0;
//----------------------------------------------i2c master top
wire                 o_i2cm_sda_en;
wire                 o_i2cm_scl_en;
wire                 o_i2cm_finish_tgl_0;
wire                 o_i2cm_nack_ntfy_tgl_0;
wire                 o_i2cm_finish_tgl_1;
wire                 o_i2cm_nack_ntfy_tgl_1;

wire [7:0]           i2cm_wr_addr;                  
wire [7:0]           i2cm_wr_data;                  
wire                 i2cm_wr_en;  
wire [7:0]           i2cm_rd_addr;  
wire                 i2cm_chip_sel;                                

wire                 io_dev_sda; 
wire                 io_dev_scl;
//------------------------------------------------master data page reg 
wire [7:0]           r_i2cm_data; 
//------------------------------------------------master config page reg 
wire                 r_i2cm_nack_0;
wire                 r_i2cm_nack_1;
wire                 r_i2cm_type_0;
wire                 r_i2cm_type_1;
wire                 r_i2cm_stb_0;
wire                 r_i2cm_stb_1;
wire                 r_i2cm_seq_0;
wire                 r_i2cm_seq_1;
wire [7:0]           r_i2cm_num_0;
wire [7:0]           r_i2cm_num_1;
wire [7:0]           r_i2cm_dev_id_0;
wire [7:0]           r_i2cm_dev_id_1;
wire [7:0]           r_i2cm_addr_0;
wire [7:0]           r_i2cm_addr_1;
reg                  r_i2cm_trg_1;
wire [7:0]           reg_cfg_data;
//------------------------------------------------i2c slave 
wire                 d_mem_csn;
wire                 d_mem_wen;
reg                  type_sel;
reg  [7:0]           i2cs_device_rdata;
wire [7:0]           i2cs_device_wdata;
wire [15:0]          i2cs_device_addr;
//------------------------------------------------i2c slave FX3
wire                 f_mem_csn;
wire                 f_mem_wen;
reg  [7:0]           i2cs_fx3_rdata;
wire [7:0]           i2cs_fx3_wdata;
wire [15:0]          i2cs_fx3_addr;
//-------------------------------------------------i2c master behaver (fx3)
wire                 io_fx3_sda; 
wire                 io_fx3_scl;
//-----------------------------------------------config
reg                  TB_SYS_CLK;
reg                  reg_ini_done;
//-----------------------------------------------simulation patten 
reg                  trg_1_ctrl;
reg                  config_fin_0;
reg                  config_fin_1;
reg                  data_nack_ctrl;
wire                 nack_pulse           = `I2CM_ARBI.nack_pulse;
reg                  id_ack_ctrl;
reg  [7:0]           master_mem  [0:255];
reg  [7:0]           slave_mem   [0:65535];
reg                  read_mem_done;

//--------------------------------------------------------------------------------
//  clocking and reset
//--------------------------------------------------------------------------------


initial  begin 

  i2cmd_rst_n=0;
  #50;
  i2cmd_rst_n=1;

end

initial  begin 

  i2csf_rst_n=0;
  #50;
  i2csf_rst_n=1;

end

initial  begin 

  i2csd_rst_n=0;
  #50;
  i2csd_rst_n=1;

end


initial begin 
i2cmd_clk = 0;
forever #(I2CM_DEV_CLK_PERIOD/2) i2cmd_clk = ~i2cmd_clk;
end

initial begin 
i2cmf_clk = 0;
forever #(I2CM_FX3_CLK_PERIOD/2) i2cmf_clk = ~i2cmf_clk;
end

initial begin
i2csf_clk = 0;
forever #(I2CS_FX3_CLK_PERIOD/2) i2csf_clk = ~i2csf_clk;
end

initial begin
i2csd_clk = 0;
forever #(I2CS_DEV_CLK_PERIOD/2) i2csd_clk = ~i2csd_clk;
end

//================================================================================
//  behavior description
//================================================================================

assign i2cs_dev_we       = (~d_mem_csn & ~d_mem_wen);
assign i2cs_fx3_we       = (~f_mem_csn & ~f_mem_wen);

pullup x1(io_dev_sda);   //connect ip_i2cm_top and i2c slave devcie    
pullup x2(io_dev_scl);   //connect ip_i2cm_top and i2c slave devcie    
pullup x3(io_fx3_sda);   //connect i2cm bev and i2c slave fx3    
pullup x4(io_fx3_scl);   //connect i2cm bev and i2c slave fx3    
//================================================================================
//  module instantiation
//================================================================================

//-----------------------i2c_master
i2cm_top 
        #(
         .I2C_NUM                (I2CM_NUM),
         .TRG_CDC                (I2CM_TRG_CDC),
         .TRG_TYPE               (I2CM_TRG_TYPE),
         .FIFO_DWID              (I2CM_FIFO_DWID),
         .FIFO_DEPTH             (I2CM_FIFO_DEPTH),
         .DO_FFO_EN              (I2CM_DO_FFO_EN)
         )

i2cm_top(
//----------------master clock domain
         .o_i2cm_sda_en          (o_i2cm_sda_en),
         .o_i2cm_scl_en          (o_i2cm_scl_en),
         .o_i2cm_finish_tgl_0    (o_i2cm_finish_tgl_0),
         .o_i2cm_nack_ntfy_tgl_0 (o_i2cm_nack_ntfy_tgl_0),
         .o_i2cm_finish_tgl_1    (o_i2cm_finish_tgl_1),
         .o_i2cm_nack_ntfy_tgl_1 (o_i2cm_nack_ntfy_tgl_1),
         .o_i2cm_rd_addr         (i2cm_rd_addr),
         .o_i2cm_op              (i2cm_chip_sel),
//----------------slave clock domain
         .o_i2cm_wr_addr         (i2cm_wr_addr),
         .o_i2cm_wr_data         (i2cm_wr_data),
         .o_i2cm_wr_en           (i2cm_wr_en),
//----------------master clock domain
         .i2cm_clk               (i2cmd_clk),
         .i2cm_rst_n             (i2cmd_rst_n),
         .i_i2cm_data            (r_i2cm_data),               
         .r_i2cm_nack_0          (r_i2cm_nack_0),
         .r_i2cm_type_0          (r_i2cm_type_0),
         .r_i2cm_stb_0           (r_i2cm_stb_0),
         .r_i2cm_seq_0           (r_i2cm_seq_0),
         .i_i2cm_trg_0           (ini_i2cm_trg_0),
         .r_i2cm_num_0           (r_i2cm_num_0),
         .r_i2cm_dev_id_0        ({id_ack_ctrl,r_i2cm_dev_id_0[5:0],ini_id_dir_0}),
         .r_i2cm_addr_0          (r_i2cm_addr_0),
         .r_i2cm_nack_1          (r_i2cm_nack_1),
         .r_i2cm_type_1          (r_i2cm_type_1),
         .r_i2cm_stb_1           (r_i2cm_stb_1),
         .r_i2cm_seq_1           (r_i2cm_seq_1),
         .r_i2cm_trg_1           (r_i2cm_trg_1),
         .r_i2cm_num_1           (r_i2cm_num_1),
         .r_i2cm_dev_id_1        ({id_ack_ctrl,r_i2cm_dev_id_1[5:0],ini_id_dir_1}),
         .r_i2cm_addr_1          (r_i2cm_addr_1),
         .io_sda                 (io_dev_sda), 
         .io_scl                 (io_dev_scl),
//----------------slave clock domain
         .i2cs_clk               (i2csf_clk),
         .i2cs_rst_n             (i2csf_rst_n)

);


i2c_slave_rtl   
        #(
          I2C_SLAVE_ID
         ) 

slave_device(

         .clk                    (i2csd_clk),                      
         .rst_n                  (i2csd_rst_n),                        
         .mem_rd                 (i2cs_device_rdata),                       
         .scl                    (io_dev_scl),                          
         .sda                    (io_dev_sda),                         

         .mem_csn                (d_mem_csn),                      
         .mem_wen                (d_mem_wen),                      
         .load_addr              (i2cs_device_addr),                    
         .mem_wd                 (i2cs_device_wdata),   

         .data_type_ctrl         (type_sel),   
         .data_nack_ctrl         (data_nack_ctrl),
         .i_ini_id_dir_0         (ini_id_dir_0),
         .i_ini_id_dir_1         (ini_id_dir_1)          

);

soisp_reg 
       #(
         .NUM_WID                (NUM_WID)
        )
soisp_reg_top(

//----------------------------------------------i2c master top
         .i_i2cm_finish_tgl_0    (1'b0),
         .i_i2cm_nack_ntfy_tgl_0 (1'b0),
         .i_i2cm_finish_tgl_1    (1'b0),
         .i_i2cm_nack_ntfy_tgl_1 (1'b0),

         .i_i2cm_wr_addr         (i2cm_wr_addr),                  
         .i_i2cm_wr_data         (i2cm_wr_data),                  
         .i_i2cm_wr_en           (i2cm_wr_en),  
         .i_i2cm_rd_addr         (8'h00), 
         .i_i2cm_chip_sel        (i2cm_chip_sel),

//------------------------------------------------master data page reg 
         .r_i2cm_data            (), 
//------------------------------------------------master config page reg 
         .r_i2cm_nack_0          (r_i2cm_nack_0),
         .r_i2cm_nack_1          (r_i2cm_nack_1),
         .r_i2cm_type_0          (r_i2cm_type_0),
         .r_i2cm_type_1          (r_i2cm_type_1),
         .r_i2cm_stb_0           (r_i2cm_stb_0),
         .r_i2cm_stb_1           (r_i2cm_stb_1),
         .r_i2cm_seq_0           (r_i2cm_seq_0),
         .r_i2cm_seq_1           (r_i2cm_seq_1),
         .r_i2cm_trg_0           (),
         .r_i2cm_trg_1           (),
         .r_i2cm_num_0           (r_i2cm_num_0),
         .r_i2cm_num_1           (r_i2cm_num_1),
         .r_i2cm_dev_id_0        (r_i2cm_dev_id_0),
         .r_i2cm_dev_id_1        (r_i2cm_dev_id_1),
         .r_i2cm_addr_0          (r_i2cm_addr_0),
         .r_i2cm_addr_1          (r_i2cm_addr_1),

// host I/F
         .reg_we                 (i2cs_fx3_we),                      
         .reg_addr               (i2cs_fx3_addr[7:0]),                     
         .reg_wdata              (i2cs_fx3_wdata),                    
         .reg_rdata              (i2cs_fx3_rdata),                   

// clk
         .i2csf_clk              (i2csf_clk),                                                  
         .i2csf_rst_n            (i2csf_rst_n)                    
);


i2c_slave_rtl 
        #(
          I2C_SLAVE_FX3_ID
         ) 

slave_fx3(

         .clk                    (i2csf_clk),                      
         .rst_n                  (i2csf_rst_n),                        
         .mem_rd                 (i2cs_fx3_rdata),                       
         .scl                    (io_fx3_scl),                          
         .sda                    (io_fx3_sda),                         

         .mem_csn                (f_mem_csn),                      
         .mem_wen                (f_mem_wen),                      
         .load_addr              (i2cs_fx3_addr),                    
         .mem_wd                 (i2cs_fx3_wdata),   

         .data_type_ctrl         (1'b0),   
         .data_nack_ctrl         (data_nack_ctrl),
         .i_ini_id_dir_0         (ini_id_dir_0),
         .i_ini_id_dir_1         (ini_id_dir_1)           

);


i2c_master
        #(
         .I2C_SLAVE_ID           (I2C_SLAVE_FX3_ID)
         )

i2c_master_fx3
(
         .scl                    (io_fx3_scl),
         .sda                    (io_fx3_sda),
         .clk                    (i2cmf_clk)
);


//--------------------------------------------------------------------------------
// register setting (override initial value)
//--------------------------------------------------------------------------------
initial begin: REG_INI
  reg_ini_done = 0;
  reg_ini.open_ini(ini_file_name);
  reg_ini.reg_set_by_name(ppm_file_name);
  @ (posedge i2cmf_clk);
  reg_ini_done = 1;
end
  
//--------------------------------------------------------------------------------
// simulation patten
//--------------------------------------------------------------------------------

initial begin  //static setting 
force  type_sel = `I2CM_ARBI.o_abr_type_cfg;
end

initial begin
read_mem_done = 1'b0;
wait(reg_ini_done)
$readmemh(ppm_file_name,slave_mem);
$readmemh(ppm_file_name,master_mem);
read_mem_done = 1'b1;
end

always@(posedge i2csd_clk)begin

if(read_mem_done)begin
  if(i2cs_dev_we) begin
    slave_mem[i2cs_device_addr] <= i2cs_device_wdata;
  end

  i2cs_device_rdata <= slave_mem[i2cs_device_addr];
end
end

assign r_i2cm_data = master_mem[i2cm_rd_addr];


initial begin
ini_i2cm_trg_0 = 0;
wait(config_fin_0)
wait(config_fin_1)
case(ini_trg_0_dly)
  2'b00 : begin
           wait(~i2csf_clk)
           wait(i2csf_clk)
           ini_i2cm_trg_0 = ini_trg_0;
          end

  2'b01 : begin
           wait(~`I2CM_CTRL.trans_finish)
           wait(`I2CM_CTRL.trans_finish)
           ini_i2cm_trg_0 = ini_trg_0;
          end

  2'b10 : begin
           #4000
           wait(~i2csf_clk)
           wait(i2csf_clk)
           ini_i2cm_trg_0 = ini_trg_0;
          end

  2'b11 : begin
           wait(~`I2CM_CTRL.o_i2c_write_addr_smo)
           wait(`I2CM_CTRL.o_i2c_write_addr_smo)
           ini_i2cm_trg_0 = ini_trg_0;
          end
endcase
wait(~i2csf_clk)
wait(i2csf_clk)
wait(~i2csf_clk)
wait(i2csf_clk)
wait(~i2csf_clk)
wait(i2csf_clk)
ini_i2cm_trg_0 = 1'b0;
end


initial begin
config_fin_0 = 1'b0;
config_fin_1 = 1'b0;

i2c_master_fx3.start;
i2c_master_fx3.rw_slave_addr  (I2C_SLAVE_FX3_ID, 0);
i2c_master_fx3.send_byte      (8'hff);
i2c_master_fx3.send_byte      (8'h0a);

i2c_master_fx3.start;
i2c_master_fx3.rw_slave_addr  (I2C_SLAVE_FX3_ID, 0);
i2c_master_fx3.send_byte      (8'h10);
i2c_master_fx3.send_byte      (r_i2cm_top_nack_0);
i2c_master_fx3.send_byte      (r_i2cm_top_type_0);
i2c_master_fx3.send_byte      (r_i2cm_top_stb_0);
i2c_master_fx3.send_byte      (r_i2cm_top_seq_0);
i2c_master_fx3.send_byte      (r_i2cm_top_num_0);
i2c_master_fx3.send_byte      (r_i2cm_top_dev_id_0);
i2c_master_fx3.send_byte      (r_i2cm_top_addr_0);

config_fin_0 = 1'b1;

i2c_master_fx3.start;
i2c_master_fx3.rw_slave_addr  (I2C_SLAVE_FX3_ID, 0);
i2c_master_fx3.send_byte      (8'h20);
i2c_master_fx3.send_byte      (r_i2cm_top_nack_1);
i2c_master_fx3.send_byte      (r_i2cm_top_type_1);
i2c_master_fx3.send_byte      (r_i2cm_top_stb_1);
i2c_master_fx3.send_byte      (r_i2cm_top_seq_1);
i2c_master_fx3.send_byte      (r_i2cm_top_num_1);
i2c_master_fx3.send_byte      (r_i2cm_top_dev_id_1);
i2c_master_fx3.send_byte      (r_i2cm_top_addr_1);
config_fin_1 = 1'b1;

end

initial begin
r_i2cm_trg_1 = 1'b0;
wait(config_fin_0)
wait(config_fin_1)
case(ini_trg_1_dly)
 2'b00 : begin
           wait(~i2csf_clk)
           wait(i2csf_clk)
           r_i2cm_trg_1 = ini_trg_1;
           wait(~i2csf_clk)
           wait(i2csf_clk)
           wait(~i2csf_clk)
           wait(i2csf_clk)
           wait(~i2csf_clk)
           wait(i2csf_clk)
           r_i2cm_trg_1 = 1'b0;
         end

 2'b01 : begin
           wait(~`I2CM_CTRL.trans_finish)
           wait(`I2CM_CTRL.trans_finish)
           r_i2cm_trg_1 = ini_trg_1;
           wait(~i2csf_clk)
           wait(i2csf_clk)
           wait(~i2csf_clk)
           wait(i2csf_clk)
           wait(~i2csf_clk)
           wait(i2csf_clk)
           r_i2cm_trg_1 = 1'b0;
         end

 2'b10 : begin
           #4000
           r_i2cm_trg_1 = ini_trg_1;
           wait(~i2csf_clk)
           wait(i2csf_clk)
           wait(~i2csf_clk)
           wait(i2csf_clk)
           wait(~i2csf_clk)
           wait(i2csf_clk)
           r_i2cm_trg_1 = 1'b0;
         end
endcase
end

initial begin 
data_nack_ctrl = 0;
#50
wait(~`I2CM_CTRL.o_i2c_write_addr_smo)
wait(`I2CM_CTRL.o_i2c_write_addr_smo)
case(ini_nack_timing)
  2'b00 : begin
            data_nack_ctrl = ini_data_nack;
            wait(nack_pulse)
            wait(~nack_pulse)
            wait(~i2csf_clk)
            wait(i2csf_clk)
            wait(~i2csf_clk)
            wait(i2csf_clk)
            data_nack_ctrl = 1'b0;
          end

  2'b01 : begin
            wait(`I2CM_ARBI.sxm_trg_0)
            wait(~`I2CM_ARBI.sxm_trg_0)
            wait(~`I2CM_ARBI.abr_trg_0_op_smo)
            wait(`I2CM_ARBI.abr_trg_0_op_smo)
            wait(~`I2CM_CTRL.o_i2c_write_addr_smo)
            wait(`I2CM_CTRL.o_i2c_write_addr_smo)
            data_nack_ctrl = ini_data_nack;
            wait(nack_pulse)
            wait(~nack_pulse)
            wait(~i2csf_clk)
            wait(i2csf_clk)
            wait(~i2csf_clk)
            wait(i2csf_clk)
            data_nack_ctrl = 1'b0;
          end

  2'b10 : begin
            wait(`I2CM_ARBI.sxm_trg_0)
            wait(~`I2CM_ARBI.sxm_trg_0)
            wait(~`I2CM_ARBI.trg_1_restore)
            wait(`I2CM_ARBI.trg_1_restore)
            wait(~`I2CM_ARBI.abr_int_1st_addr_smo)
            wait(`I2CM_ARBI.abr_int_1st_addr_smo)
            wait(~`I2CM_CTRL.o_i2c_write_addr_smo)
            wait(`I2CM_CTRL.o_i2c_write_addr_smo)
            data_nack_ctrl = ini_data_nack;
            wait(nack_pulse)
            wait(~nack_pulse)
            wait(~i2csf_clk)
            wait(i2csf_clk)
            wait(~i2csf_clk)
            wait(i2csf_clk)
            data_nack_ctrl = 1'b0;
          end
  endcase
end

always @(posedge i2cmd_clk or negedge i2cmd_rst_n) begin
if(~i2cmd_rst_n)
  id_ack_ctrl <= ini_dev_id_nack;
else
  if((`I2CM_ARBI.i_i2cm_finish_pulse & ~`I2CM_ARBI.abr_trg_0_op_smo) | (`I2CM_ARBI.abr_trg_0_op_smo & `I2CM_CTRL.o_i2c_clr_smo))
    id_ack_ctrl <= ini_dev_id_nack;
  else
    if(nack_pulse)
      id_ack_ctrl <= 1'b0;
    else 
      id_ack_ctrl <= id_ack_ctrl;
end

//--------------------------------------------------------------------------------
//  waveform dump setting
//--------------------------------------------------------------------------------

initial begin 
      $fsdbDumpfile("./wave/i2c_master_cont_top_tb");
      $fsdbDumpvars(0,i2c_master_cont_top_tb,"+all");
      $fsdbDumpvars(0,`MONITOR_TOP,"+all");
      wait(`MONITOR_TOP.mon_fin)
      $finish;
end

//--------------------------------------------------------------------------------
//  register initial procedure
//--------------------------------------------------------------------------------
reg_ini
reg_ini();

//--------------------------------------------------------------------------------

endmodule       
