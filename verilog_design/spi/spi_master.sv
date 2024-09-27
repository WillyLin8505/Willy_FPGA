// +FHDR -----------------------------------------------------------------------
// Copyright Willy 2024
//
// File Name:          
// Author:              Willy Lin
// Version:             1.0
// Date:               2024
// Last Modified On:    
// Last Modified By:    $Author$
// limitation :
//                     
// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------

module spi_master #(
    parameter MOSI_DATA_BYTE = 1 , //how many byte for the outupt data
    parameter MISO_DATA_BYTE = 1 , //how many byte for the input data
    parameter MOSI_ADDR_BYTE = 1 , //how many byte for the output address
    parameter MISO_ADDR_BYTE = 1 , //how many byte for the input address
    parameter DATA_PAUSE_NUM = 4 , //how many sclk time for pause after transmit data
    parameter SLAVE_NUM      = 1   // 0: stream mode 

) 
(spi_interface spi_port);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//
localparam [7:0] SPI_DATA_BIT = MOSI_DATA_BYTE*8;

//-----------------------------------------------------------WTH parameter 
localparam SPI_DATA_BIT_WTH   = $clog2(SPI_DATA_BIT);
localparam SPI_ADDR_WTH       = MOSI_ADDR_BYTE*8;
localparam DATA_PAUSE_NUM_WTH = $clog2(DATA_PAUSE_NUM+1);

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//

//------------------------------------------fsm

logic  spi_idle_smo;
logic  spi_rd_wr_dir_smo;
logic  spi_data_smo;
logic  spi_data_pause_smo;
logic  count_en_smo;
logic  sclk_en_smo;

enum logic [5:0] {
SPI_IDLE   =  6'b00_0100,
SPI_RD_WR_DIR   =  6'b00_1001,
SPI_DATA   =  6'b01_0011,
SPI_DATA_PAUSE   =  6'b10_0010
    } spi_cs,spi_ns;

//----------------------rename input signal 
logic [8-1:0] r_data ; //write data from register 
logic [8*MOSI_ADDR_BYTE-1:0] r_address ; //write address from register 
logic [8-1:0] r_data_num ; //how many byte of data need to send 
logic         r_trg_start ; //trigger start 
logic [8-1:0] r_slv_sel;   //slave select 
logic [8-1:0] r_spi_mode;
logic         r_spi_wr;    //0:read 1:write 

//------------------------------------------counter
logic [SPI_DATA_BIT_WTH-1:0] spi_cnt;
logic [SPI_DATA_BIT_WTH-1:0] spi_cnt_nxt;
logic spi_cnt_inc;
logic spi_cnt_clr;

logic sclk_cnt;
logic sclk_cnt_nxt;
logic sclk_cnt_inc;
logic sclk_cnt_clr;

logic [SPI_ADDR_WTH-1:0] addr_cnt;
logic [SPI_ADDR_WTH-1:0] addr_cnt_nxt;
logic addr_cnt_inc;
logic addr_cnt_clr;
logic addr_cnt_set;
logic [SPI_ADDR_WTH-1:0] addr_cnt_set_val;

//------------------------------------------equal

logic sclk_cnt_1_eq;
logic [SPI_DATA_BIT_WTH-1:0] spi_cnt_eq_num;
logic spi_cnt_eq;
logic spi_cnt_fnl_eq;

//------------------------------------------data
logic [7:0] data_seq;
logic [7:0] data_seq_nxt;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//----------------------rename input signal 
assign r_data     = spi_port.master_port_clk.r_data; 
assign r_data_num = spi_port.master_port_clk.r_data_num;
assign r_address  = spi_port.master_port_clk.r_address;
assign r_trg_start = spi_port.master_port_clk.r_trg_start;
assign r_slv_sel = spi_port.master_port_clk.r_slv_sel;
assign r_spi_mode = spi_port.master_port_clk.r_spi_mode;
assign r_spi_wr   = spi_port.master_port_clk.r_spi_wr;

//----------------------counter 
assign spi_cnt_nxt = (spi_cnt_inc ? spi_cnt + 1'b1 : spi_cnt) & {SPI_DATA_BIT_WTH{!spi_cnt_clr}};
assign spi_cnt_inc = sclk_cnt_1_eq & count_en_smo;
assign spi_cnt_clr = spi_idle_smo | (spi_cnt_eq & sclk_cnt_1_eq);

assign sclk_cnt_nxt = (sclk_cnt_inc ? sclk_cnt + 1'b1 : sclk_cnt) & !sclk_cnt_clr;
assign sclk_cnt_inc = !spi_idle_smo;
assign sclk_cnt_clr = spi_idle_smo;

assign addr_cnt_nxt = addr_cnt_set ? addr_cnt_set_val : (addr_cnt_inc ? addr_cnt + ({1'b1,{MOSI_DATA_BYTE-1{1'b0}}}) : addr_cnt) & {SPI_ADDR_WTH{!addr_cnt_clr}};
assign addr_cnt_inc = spi_data_smo & spi_cnt_eq & sclk_cnt_1_eq;
assign addr_cnt_clr = spi_idle_smo;
assign addr_cnt_set = spi_idle_smo;  
assign addr_cnt_set_val = spi_port.master_port_clk.r_address;

//----------------------equal 
assign sclk_cnt_1_eq = sclk_cnt;
assign spi_cnt_eq_num = ({SPI_DATA_BIT_WTH{(spi_data_smo)}}       & (SPI_DATA_BIT-1'b1)) |          //total shift number 
                        ({DATA_PAUSE_NUM_WTH{spi_data_pause_smo}} & DATA_PAUSE_NUM-1'b1); //for pause state 

assign spi_cnt_eq = spi_cnt_eq_num == spi_cnt;
assign spi_cnt_fnl_eq = ((r_data_num -1) == spi_cnt) & spi_data_pause_smo; //the number is reach to the ddr number 

//----------------------data 
assign data_seq_nxt =  spi_data_smo ? sclk_cnt_1_eq ? {data_seq[0],data_seq[7:1]} : data_seq : r_data;

//----------------------fsm 
assign  spi_idle_smo       = spi_cs[2];
assign  spi_rd_wr_dir_smo       = spi_cs[3];
assign  spi_data_smo       = spi_cs[4];
assign  spi_data_pause_smo       = spi_cs[5];
assign  count_en_smo       = spi_cs[1];
assign  sclk_en_smo       = spi_cs[0];

always_comb begin : spi_fsm

 spi_ns = spi_cs;

  case(spi_cs)

  SPI_IDLE : begin
    if(spi_port.master_port_clk.r_trg_start) 
      spi_ns = SPI_RD_WR_DIR;
  end 

  SPI_RD_WR_DIR : begin 
    if(sclk_cnt_1_eq)
      spi_ns = SPI_DATA;
  end 

  SPI_DATA : begin 
    if(spi_cnt_eq & sclk_cnt_1_eq)
      spi_ns = SPI_DATA_PAUSE;
  end 

  SPI_DATA_PAUSE : begin 
    if(sclk_cnt_1_eq) begin 
      if(spi_cnt_fnl_eq)
        spi_ns = SPI_IDLE;
      else
        if(spi_cnt_eq)
          spi_ns = SPI_DATA;
    end 
  end 

 endcase
end 

//----------------------output 
assign o_sclk = sclk_cnt_1_eq & sclk_en_smo; //fix
assign o_mosi = spi_rd_wr_dir_smo ? r_spi_wr : data_seq[0];

//----------------------sequencial  
always_ff @(posedge spi_port.clk or negedge spi_port.rst_n) begin 
if(!spi_port.rst_n)begin 
  spi_cnt <= 0;
  sclk_cnt <= 0;
  addr_cnt <= 0;
  data_seq <= 0;
end else begin 
  spi_cnt <= spi_cnt_nxt;
  sclk_cnt <= sclk_cnt_nxt;
  addr_cnt <= addr_cnt_nxt;
  data_seq <= data_seq_nxt;
end 
end 


always_ff @(posedge spi_port.clk or negedge spi_port.rst_n) begin 
     if(!spi_port.rst_n) begin 
        spi_cs <= SPI_IDLE;
     end 
     else begin 
spi_cs <= spi_ns;
     end 
end 

//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//



endmodule