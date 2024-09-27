program automatic spi_tb_func(spi_interface.tb_port tb_io);

    parameter SPI_MODE = 0,//{CPOL,CPHA} CPOL: 0: sclk start at 0 
                           //                  1: sclk start at 1 
                           //            CPHA: 0: sclk simple at raise 
                           //                  1: sclk simple at fall 
    parameter MOSI_ADDR_BYTE = 1 , //how many byte for the output address
    parameter MISO_ADDR_BYTE = 1 , //how many byte for the input address
    parameter ADDR_PAUSE_NUM = 4 , //how many sclk time for pause after transmit address
    parameter DATA_PAUSE_NUM = 4 , //how many sclk time for pause after transmit data
    parameter SLAVE_NUM      = 1   // 0: stream mode 

//put the program fuction in here 

endprogram : spi_tb
