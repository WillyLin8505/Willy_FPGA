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

//================================================================================
//  interface 
//================================================================================
`timescale 1ns/1ns  

interface spi_interface #(
    parameter MOSI_ADDR_BYTE = 1 , //how many byte for the output address
    parameter MISO_ADDR_BYTE = 1 , //how many byte for the input address
    parameter DATA_PAUSE_NUM = 4 , //how many sclk time for pause after transmit data
    parameter SLAVE_NUM      = 1 , // 0: stream mode 

    parameter SLAVE_NUM_WTH = $clog2(SLAVE_NUM)
)
   (input bit clk ,rst_n);
//-------------------------------------------------------------------logic 
    logic o_sclk;
    logic o_mosi;
    logic [SLAVE_NUM_WTH-1:0] o_cs;
    logic [8-1:0] o_data_reg;
    logic [8*MOSI_ADDR_BYTE-1:0] o_address_reg;
    logic o_en_reg;
    logic o_tgl_fnl;
    logic i_miso ; 
    logic [8-1:0] r_data ; //write data from register 
    logic [8*MOSI_ADDR_BYTE-1:0] r_address ; //write address from register 
    logic [8-1:0] r_data_num ; //how many byte of data need to send 
    logic         r_trg_start ; //trigger start 
    logic [8-1:0] r_slv_sel;   //slave select 
    logic [8-1:0] r_spi_mode;
    logic         r_spi_wr;
//-------------------------------------------------------------------task (reset)

//-------------------------------------------------------------------clk   
    clocking master_port_clk @(posedge clk);
    default input #1ns output #1ns;
    input   i_miso ; 
    input   r_data ; //write data from register 
    input   r_address ; //write address from register 
    input   r_data_num ; //how many byte of data need to send 
    input   r_trg_start ; //trigger start 
    input   r_slv_sel;   //slave select 
    input   r_spi_mode;    //{CPOL,CPHA} CPOL: 0: sclk start at 0 
                           //                  1: sclk start at 1 
                           //            CPHA: 0: sclk simple at raise 
                           //                  1: sclk simple at fall 
    input   r_spi_wr;    //0:read 1:write 

    output  o_sclk;
    output  o_mosi;
    output  o_cs;
    output  o_data_reg;
    output  o_address_reg;
    output  o_en_reg;
    output  o_tgl_fnl;
    endclocking 

    clocking assert_clk @(posedge clk);
    default input #1ns output #1ns;
    input   i_miso ; 
    input   r_data ; //write data from register 
    input   r_address ; //write address from register 
    input   r_data_num ; //how many byte of data need to send 
    input   r_trg_start ; //trigger start 
    input   r_slv_sel;   //slave select 
    input   r_spi_mode;
    input   r_spi_wr; 

    input   o_sclk;
    input   o_mosi;
    input   o_cs;
    input   o_data_reg;
    input   o_address_reg;
    input   o_en_reg;
    input   o_tgl_fnl;
    endclocking 

//-------------------------------------------------------------------modport   
 modport master_port (clocking master_port_clk,input rst_n);
 modport master_assert (clocking assert_clk);

endinterface 

//================================================================================
//  module
//================================================================================
module spi_top #(
    parameter MOSI_ADDR_BYTE = 1 , //how many byte for the output address
    parameter MISO_ADDR_BYTE = 1 , //how many byte for the input address
    parameter DATA_PAUSE_NUM = 4 , //how many sclk time for pause after transmit data
    parameter SLAVE_NUM      = 1 , // 0: stream mode 

    parameter  SLAVE_NUM_WTH = $clog2(SLAVE_NUM)
) (spi_interface spi_inter_top);

spi_master #(
    .MOSI_ADDR_BYTE ( MOSI_ADDR_BYTE ),
    .MISO_ADDR_BYTE ( MISO_ADDR_BYTE ),
    .DATA_PAUSE_NUM ( DATA_PAUSE_NUM ),
    .SLAVE_NUM      ( SLAVE_NUM )
) spi_master (
    .spi_port(spi_inter_top)
);


endmodule