// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2014
//
// File Name:           ip_i2c_m_top_trl.v
// Author:              Willy Lin
// Version:             $Revision$
// Last Modified On:    2021/11/5
// Last Modified By:    $Author$
//
// File Description:    combine i2c master data path and control path. have only one trigger  
//                      
// Clock Domain: input:384k,1536k,2048k,3072k
//               output(SCL):96k,384k,512k,768k
//               output(CLK):384k,1536k,2048k,3072k
// -FHDR -----------------------------------------------------------------------
module i2cm
   #( 
      parameter    NUM_WID     = 5,
      parameter    TRG_CDC     = "SYNC"                    // "SYNC"/"ASYNC"
     )
(

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output                 o_sda_en,
output                 o_scl_en,
output                 o_wr_data_wen,
output [7:0]           o_data_addr,
output [7:0]           o_wr_data,
output                 o_trans_finish_pulse,
output                 o_wdata_nack,
output [7:0]           o_addr_cnt,
output [NUM_WID-1:0]   o_num_cnt,
output                 o_i2c_clr_smo,
output                 o_i2c_write_addr_smo,
output                 o_addr_done,
output                 o_type_flag,
output                 o_num_cnt_inc,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input                  i2c_clk,
input                  i2c_rst_n,
input                  i_i2cm_nack,
input                  i_i2cm_type,
input                  i_i2cm_stb,
input                  i_i2cm_seq,
input                  i_i2cm_trg,
input [7:0]            i_i2cm_dev_id,
input [7:0]            i_i2cm_data,  
input [NUM_WID-1:0]    i_i2cm_num,
input [7:0]            i_i2cm_addr,
input                  i_int_flag,

//----------------------------------------------//
// Inoutput declaration                         //
//----------------------------------------------//

inout                  io_sda, 
inout                  io_scl

);

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//

//---------------------------------------------data
wire [7:0]              dev_id;
reg  [7:0]              inter_data;
reg                     i2c_p2s_smo_q;
reg                     p2s_dp_en_q;
//---------------------------------------------block wire 
wire                    dev_id_dir;
wire                    i2c_p2s_smo;
wire                    i2c_data_0_smo;
wire                    i2c_data_1_smo;
wire                    sxi_trg;
wire                    p2s_dp_en;
wire                    s2p_dp_en;
wire                    s_data;
//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

//---------------------------------------------data  

assign io_scl   = (o_scl_en)?1'hz : 1'h0 ;              //fsm use o_scl_en to control io_scl
assign io_sda   = (o_sda_en)?1'hz : 1'h0 ;              //fsm use o_scl_en to control io_sda
assign dev_id   = {i_i2cm_dev_id[7:1],dev_id_dir};      //device id for output id address

always @* begin : inter_data_block

  inter_data = 8'h00; 

  case({i2c_data_0_smo,i2c_data_1_smo}) // synopsys full_case
   2'b00:  inter_data = 8'h80;       //stb
   2'b01:  inter_data = dev_id;      //dev_id
   2'b10:  inter_data = i_i2cm_data; //address and data
  endcase
end     

always@(posedge i2c_clk or negedge i2c_rst_n) begin
   if(~i2c_rst_n) begin
     i2c_p2s_smo_q <= 1'b0;
     p2s_dp_en_q   <= 1'b0;
   end
   else begin
     i2c_p2s_smo_q <= i2c_p2s_smo;
     p2s_dp_en_q   <= p2s_dp_en;
   end
end
                                  
//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//
   

i2cm_ctrl #(.NUM_WID(NUM_WID)) i2cm_ctrl(
                .o_sda_en                     (o_sda_en),
                .o_scl_en                     (o_scl_en),
                .o_wr_data_wen                (o_wr_data_wen),
                .o_data_addr                  (o_data_addr),
                .o_trans_finish_pulse         (o_trans_finish_pulse),
                .o_wdata_nack                 (o_wdata_nack),
                .o_num_cnt                    (o_num_cnt),
                .o_addr_cnt                   (o_addr_cnt),
                .o_i2c_clr_smo                (o_i2c_clr_smo),
                .o_i2c_write_addr_smo         (o_i2c_write_addr_smo),
                .o_addr_done                  (o_addr_done),
                .o_type_flag                  (o_type_flag),
                .o_num_cnt_inc                (o_num_cnt_inc),

                .o_i2c_p2s_smo                (i2c_p2s_smo),                     
                .o_i2c_data_0_smo             (i2c_data_0_smo),
                .o_i2c_data_1_smo             (i2c_data_1_smo), 
                .o_dev_id_dir                 (dev_id_dir),                
                .o_p2s_dp_en                  (p2s_dp_en),
                .o_s2p_dp_en                  (s2p_dp_en),

                .i2c_clk                      (i2c_clk),
                .i2c_rst_n                    (i2c_rst_n),
                .i_i2cm_nack                  (i_i2cm_nack),
                .i_i2cm_type                  (i_i2cm_type),
                .i_i2cm_seq                   (i_i2cm_seq),
                .i_i2cm_stb                   (i_i2cm_stb),
                .i_i2cm_trg                   (i_i2cm_trg),
                .i_i2cm_num                   (i_i2cm_num),
                .i_i2cm_addr                  (i_i2cm_addr),
                .i_int_flag                   (i_int_flag),

                .i_dev_id_msb                 (i_i2cm_dev_id[0]),
                .i_sda                        (io_sda),
                .i_scl                        (io_scl),
                .i_s_data                     (s_data)

                );

i2cm_p2s_dp p2s(
               .o_data_ser                    (s_data),
               .clk                           (i2c_clk),
               .rst_n                         (i2c_rst_n),
               .i_shift_en                    (p2s_dp_en_q),
               .i_store_en                    (i2c_p2s_smo_q),
               .i_data_par                    (inter_data)
               );

i2cm_s2p_dp s2p(
               .o_data_par                    (o_wr_data),
               .clk                           (i2c_clk),
               .rst_n                         (i2c_rst_n),
               .i_shift_en                    (s2p_dp_en),
               .i_data_ser                    (io_sda)
               );



endmodule 
