module #(
    .MOSI_DATA_BYTE ( MOSI_DATA_BYTE ),
    .MISO_DATA_BYTE ( MISO_DATA_BYTE ),
    .MOSI_ADDR_BYTE ( MOSI_ADDR_BYTE ),
    .MISO_ADDR_BYTE ( MISO_ADDR_BYTE ),
    .DATA_PAUSE_NUM ( DATA_PAUSE_NUM),
    .SLAVE_NUM      ( SLAVE_NUM )
)
spi_master_assert (

input  spi_idle_smo;
input  spi_rd_wr_dir_smo;
input  spi_data_smo;
input  spi_data_pause_smo;
input  count_en_smo;
input  sclk_en_smo;

//----------------------rename input signal 
input [8-1:0] r_data ; //write data from register 
input [8*MOSI_ADDR_BYTE-1:0] r_address ; //write address from register 
input [8-1:0] r_data_num ; //how many byte of data need to send 
input         r_trg_start ; //trigger start 
input [8-1:0] r_slv_sel;   //slave select 
input [8-1:0] r_spi_mode;
input         r_spi_wr;    //0:read 1:write 

//------------------------------------------counter
input [SPI_DATA_BIT_WTH-1:0] spi_cnt;
input [SPI_DATA_BIT_WTH-1:0] spi_cnt_nxt;
input spi_cnt_inc;
input spi_cnt_clr;

input sclk_cnt;
input sclk_cnt_nxt;
input sclk_cnt_inc;
input sclk_cnt_clr;

input [SPI_ADDR_WTH-1:0] addr_cnt;
input [SPI_ADDR_WTH-1:0] addr_cnt_nxt;
input addr_cnt_inc;
input addr_cnt_clr;
input addr_cnt_set;
input [SPI_ADDR_WTH-1:0] addr_cnt_set_val;

//------------------------------------------equal

input sclk_cnt_1_eq;
input [SPI_DATA_BIT_WTH-1:0] spi_cnt_eq_num;
input spi_cnt_eq;
input spi_cnt_fnl_eq;

//------------------------------------------data
input [7:0] data_seq;
input [7:0] data_seq_nxt;

);

sequence cnt_one_data;

 @(posedge master_assert.clk)  spi_cnt = (MOSI_DATA_BYTE*8-1) ##1 spi_cnt == 0;

endsequence 

property cnt_pro;

 spi_port.rst_n |-> cnt_one_data;

endproperty


counter_chk: assert property (cnt_pro);


endmodule