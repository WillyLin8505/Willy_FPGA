// ------------------------------------------------------------------------------//
// Copyright Willy 2024
// ------------------------------------------------------------------------------//
// Filename        :
// Author          : Willylin
// Version         : $Revision$
// Create          : 2024
// Last Modified On:
// Last Modified By: $Author$
//
// Description     :
// ------------------------------------------------------------------------------//

// defination & include
`timescale 1ns/1ns  
`define   TB_TOP            tb
`define   MONITOR_TOP       mon

// module start
module  spi_tb_top();

//================================================================================
// simulation config console
//================================================================================
//include file 

//string declaration


//================================================================================
//  parameter declaration
//================================================================================
//include parameter.h file 

//parameter 
//----------------------------------------------------------------------------------------tb
    parameter SPI_MODE = 0;//{CPOL,CPHA} CPOL: 0: sclk start at 0 
                           //                  1: sclk start at 1 
                           //            CPHA: 0: sclk simple at raise 
                           //                  1: sclk simple at fall 
    parameter MOSI_ADDR_BYTE = 1 ; //how many byte for the output address
    parameter MISO_ADDR_BYTE = 1 ; //how many byte for the input address
    parameter ADDR_PAUSE_NUM = 4 ; //how many sclk time for pause after transmit address
    parameter DATA_PAUSE_NUM = 4 ; //how many sclk time for pause after transmit data
    parameter SLAVE_NUM      = 1 ; // 0: stream mode 

    localparam SLAVE_NUM_WTH = $clog2(SLAVE_NUM);

//----------------------------------------------------------------------------------------ip


//================================================================================
//  signal declaration
//================================================================================
//----------------------------------------------------------------------------------------config

//----------------------------------------------------------------------------------------tb
logic bit clk ;
logic rst_n;

//----------------------------------------------------------------------------------------monitor

//================================================================================
//  clocking and reset
//================================================================================

initial begin 
    clk = 0;
    forever begin 
        #10;
        clk = ~clk;
    end 
end 

initial begin 
    rst_n = 0;
    @(negedge clk);
    @(negedge clk);
    rst_n = 1;
end 

//================================================================================
//  behavior description
//================================================================================
//initial 


//================================================================================
//  interfaces 
//================================================================================
spi_interface spi_inf(clk);

spi_tb_func #(
    .SPI_MODE       ( SPI_MODE ),
    .MOSI_ADDR_BYTE ( MOSI_ADDR_BYTE ),
    .MISO_ADDR_BYTE ( MISO_ADDR_BYTE ),
    .ADDR_PAUSE_NUM ( ADDR_PAUSE_NUM ),
    .DATA_PAUSE_NUM ( DATA_PAUSE_NUM ),
    .SLAVE_NUM      ( SLAVE_NUM )
    ) spi_tb_func(spi_inf);

//================================================================================
//  module instantiation
//================================================================================

spi_master #(
    .SPI_MODE       ( SPI_MODE ),
    .MOSI_ADDR_BYTE ( MOSI_ADDR_BYTE ),
    .MISO_ADDR_BYTE ( MISO_ADDR_BYTE ),
    .ADDR_PAUSE_NUM ( ADDR_PAUSE_NUM ),
    .DATA_PAUSE_NUM ( DATA_PAUSE_NUM ),
    .SLAVE_NUM      ( SLAVE_NUM )
) (
    .master_port(spi_inf.master_port)
);



//================================================================================
// register setting (override initial value)
//================================================================================


//================================================================================
//  task
//================================================================================

//================================================================================
// simulation patten
//================================================================================

//================================================================================
//  waveform dump setting
//================================================================================
  
initial begin
      $fsdbDumpfile("./wave/spi_tb_top");
      $fsdbDumpvars(0,spi_tb_top,"+all");
      #100000
      $display("test finish");
      $finish;
end

//================================================================================
//  register initial procedure
//================================================================================


endmodule