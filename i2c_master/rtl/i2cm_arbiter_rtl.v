// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2014
//
// File Name:           ip_i2c_m_top_trl.v
// Author:              Willy Lin
// Version:             $Revision$
// Last Modified On:    2021/11/5
// Last Modified By:    $Author$
//
// File Description:    i2c master muti trigger
//                      
// Clock Domain: input:384k,1536k,2048k,3072k
//               output(SCL):96k,384k,512k,768k
//               output(CLK):384k,1536k,2048k,3072k
// -FHDR -----------------------------------------------------------------------
module i2cm_arbiter

   #( 
      parameter    I2C_NUM     = 15,
      parameter    NUM_WID     = $clog2(I2C_NUM),
      parameter    TRG_CDC     = "ASYNC",                    // "SYNC"/"ASYNC"
      parameter    TRG_TYPE    = "MUTI"
     )
(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output reg                 o_finish_tgl_0,
output reg                 o_finish_tgl_1,
output reg                 o_nack_ntfy_tgl_0,
output reg                 o_nack_ntfy_tgl_1,

output                     o_abr_trg_cfg,
output                     o_abr_stb_cfg,
output                     o_abr_seq_cfg,
output     [7:0]           o_abr_dev_id_cfg,
output                     o_abr_nack_cfg,
output                     o_abr_type_cfg,

output     [NUM_WID-1:0]   o_abr_num_nxt,
output     [7:0]           o_abr_addr_nxt,
output     [7:0]           o_abr_data_nxt,
output                     o_abr_int_flag_nxt,
output                     o_abr_op,
//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input                      i2c_clk,
input                      i2c_rst_n,
input                      r_i2cm_nack_0,
input                      r_i2cm_nack_1,
input                      r_i2cm_type_0,
input                      r_i2cm_type_1,
input                      r_i2cm_stb_0,
input                      r_i2cm_stb_1,
input                      r_i2cm_seq_0,
input                      r_i2cm_seq_1,
input                      i_i2cm_trg_0,
input                      r_i2cm_trg_1,
input       [7:0]          r_i2cm_num_0,
input       [7:0]          r_i2cm_num_1,
input       [7:0]          r_i2cm_dev_id_0,
input       [7:0]          r_i2cm_dev_id_1,
input       [7:0]          r_i2cm_addr_0,
input       [7:0]          r_i2cm_addr_1,
input       [7:0]          i_i2cm_data,

input                      i_i2cm_finish_pulse,
input                      i_i2cm_wdata_nack,
input       [NUM_WID-1:0]  i_i2cm_num_cnt,
input       [7:0]          i_i2cm_addr_cnt,
input                      i_i2cm_clr_smo,
input                      i_i2cm_write_addr_smo,
input                      i_i2cm_addr_done,
input                      i_i2cm_type_flag,
input                      i_i2cm_num_cnt_inc
);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//
localparam [6:0]           ABR_IDLE           = 7'b000_0001,
                           ABR_TRG_0_OP       = 7'b000_0010,     //trigger 0 is working 
                           ABR_TRG_1_OP       = 7'b000_0100,     //trigger 1 is working 
                           ABR_WAIT_INT       = 7'b100_1000,     //wait for i2c master  I2C_NUM_ACK or I2C_RD_ACK
                           ABR_INT_1ST_ADDR   = 7'b101_0000,     //interrupt .i2c master: before I2C_WADDR
                           ABR_INT_DATA       = 7'b110_0000;     //interrupt .i2c master: after I2C_WADDR
//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
//------------------------------------------------select 
wire                       sxm_trg_0;
wire                       sxm_trg_1;
wire                       abr_trg_0_nxt;
reg                        abr_trg_0;
wire                       abr_trg_1_nxt;
reg                        abr_trg_1;
wire      [7:0]            abr_addr_cfg;
wire      [NUM_WID-1:0]    abr_num_cfg;
wire                       o_finish_tgl_0_nxt;
wire                       o_finish_tgl_1_nxt;
wire                       o_nack_ntfy_tgl_0_nxt;
wire                       o_nack_ntfy_tgl_1_nxt;
//-----------------------------------------------interrupt
reg       [NUM_WID-1:0]    o_abr_num;
wire      [7:0]            addr_keep_nxt;
reg       [7:0]            addr_keep;
wire      [NUM_WID-1:0]    num_keep_nxt;
reg       [NUM_WID-1:0]    num_keep;
wire      [7:0]            data_keep_high_nxt;
reg       [7:0]            data_keep_high;
wire      [8:0]            data_keep_low_cnt_nxt;  //have to add 1 address , low address may overflow 
reg       [8:0]            data_keep_low_cnt; 
wire                       data_keep_low_inc;      
wire                       data_keep_low_set;        
wire      [8:0]            data_keep_low_set_val;
reg                        o_abr_int_flag;
reg                        trg_1_restore;
wire                       trg_1_restore_nxt;
//-----------------------------------------------FSM
reg       [6:0]            i2cm_abr_cs;
reg       [6:0]            i2cm_abr_ns;
wire                       abr_idle_smo;
wire                       abr_wait_int_smo;
wire                       abr_trg_0_op_smo;
wire                       abr_trg_1_op_smo;
wire                       abr_int_1st_addr_smo;
wire                       abr_int_data_smo;
wire                       abr_int_smo;
//-----------------------------------------------other
reg                        i_i2cm_wdata_nack_q;
wire                       nack_pulse;
//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//



generate 
if (TRG_TYPE == "MUTI") begin

//---------------------------------------------data select
assign abr_trg_0_nxt            = ( abr_trg_0 | sxm_trg_0) & ~abr_trg_0_op_smo;
assign abr_trg_1_nxt            = ( abr_trg_1 | sxm_trg_1) & ~abr_trg_1_op_smo;
assign o_abr_trg_cfg            = abr_trg_0_op_smo | (abr_trg_1_op_smo | abr_int_1st_addr_smo);  
assign o_abr_stb_cfg            = (abr_trg_0_op_smo) ? r_i2cm_stb_0    : r_i2cm_stb_1;   
assign o_abr_seq_cfg            = (abr_trg_0_op_smo) ? r_i2cm_seq_0    : r_i2cm_seq_1;    
assign o_abr_dev_id_cfg         = (abr_trg_0_op_smo) ? r_i2cm_dev_id_0 : r_i2cm_dev_id_1;
assign o_abr_nack_cfg           = (abr_trg_0_op_smo) ? r_i2cm_nack_0   : r_i2cm_nack_1;
assign o_abr_type_cfg           = (abr_trg_0_op_smo) ? r_i2cm_type_0   : r_i2cm_type_1;
assign abr_num_cfg              = (abr_trg_0_op_smo) ? r_i2cm_num_0    : r_i2cm_num_1;
assign abr_addr_cfg             = (abr_trg_0_op_smo) ? r_i2cm_addr_0   : r_i2cm_addr_1;
assign o_finish_tgl_0_nxt       = (abr_trg_0_op_smo & i_i2cm_finish_pulse)  ^ o_finish_tgl_0;
assign o_nack_ntfy_tgl_0_nxt    = (abr_trg_0_op_smo & nack_pulse)           ^ o_nack_ntfy_tgl_0;
assign o_finish_tgl_1_nxt       = ((abr_trg_1_op_smo | abr_int_smo) & i_i2cm_finish_pulse ) ^ o_finish_tgl_1 ;
assign o_nack_ntfy_tgl_1_nxt    = ((abr_trg_1_op_smo | abr_int_smo) & nack_pulse)           ^ o_nack_ntfy_tgl_1;

//----------------interrupt 
assign o_abr_int_flag_nxt       = abr_wait_int_smo;                                          //ABR_TRG_1_OP will not chg to ABR_WAIT_INT
assign trg_1_restore_nxt        = ((abr_wait_int_smo & i_i2cm_clr_smo) | trg_1_restore) & ~abr_idle_smo;
assign num_keep_nxt             = (trg_1_restore ? num_keep  : i_i2cm_num_cnt);      
assign addr_keep_nxt            = (trg_1_restore ? addr_keep : i_i2cm_addr_cnt);
assign data_keep_high_nxt       = (i_i2cm_write_addr_smo & !i_i2cm_type_flag & (abr_trg_1_op_smo | abr_int_data_smo)) ? 
                                  i_i2cm_data : data_keep_high + data_keep_low_cnt_nxt[8];   //may overflow  

assign o_abr_num_nxt            = ((i_i2cm_addr_done) ? abr_num_cfg : num_keep) & ~{NUM_WID{i_i2cm_clr_smo & ~abr_int_1st_addr_smo}};
assign o_abr_addr_nxt           = trg_1_restore & (abr_int_1st_addr_smo | (abr_int_data_smo & o_abr_seq_cfg)) ? addr_keep :
                                  (i_i2cm_clr_smo ? abr_addr_cfg : i_i2cm_addr_cnt); 
assign o_abr_data_nxt           = (trg_1_restore & abr_int_1st_addr_smo & o_abr_seq_cfg) ? 
                                  ((i_i2cm_type_flag == o_abr_type_cfg) ? data_keep_low_cnt_nxt[7:0] : data_keep_high_nxt) : i_i2cm_data;
//---------------counter                                                      
assign data_keep_low_cnt_nxt    = data_keep_low_set ? data_keep_low_set_val : 
                                  (data_keep_low_inc ? data_keep_low_cnt + 1'b1 : data_keep_low_cnt);
assign data_keep_low_inc        = i_i2cm_num_cnt_inc & (abr_trg_1_op_smo | abr_int_smo) & ~(trg_1_restore);
assign data_keep_low_set        = i_i2cm_write_addr_smo & (i_i2cm_type_flag == o_abr_type_cfg) & (abr_trg_1_op_smo | abr_int_data_smo);
assign data_keep_low_set_val    = i_i2cm_data;
//---------------other
assign o_abr_op                 = ~abr_idle_smo;
assign nack_pulse               = i_i2cm_wdata_nack & i_i2cm_wdata_nack_q;
end
else begin //the code below will be generated when TRG_TYPE isn't setted to "MUTI"

//---------------------------------------------data   
assign abr_trg_0_nxt            = sxm_trg_0;
assign abr_trg_1_nxt            = 1'b0;

assign o_abr_trg_cfg            = abr_trg_0_op_smo | abr_int_1st_addr_smo;  
assign o_abr_stb_cfg            = r_i2cm_stb_0;
assign o_abr_seq_cfg            = r_i2cm_seq_0;
assign o_abr_dev_id_cfg         = r_i2cm_dev_id_0;
assign o_abr_nack_cfg           = r_i2cm_nack_0;
assign o_abr_type_cfg           = r_i2cm_type_0;
assign abr_addr_cfg             = r_i2cm_addr_0;
assign abr_num_cfg              = r_i2cm_num_0;

assign o_finish_tgl_0_nxt       = i_i2cm_finish_pulse ^ o_finish_tgl_0;
assign o_finish_tgl_1_nxt       = 1'b0;
assign o_nack_ntfy_tgl_0_nxt    = nack_pulse ^ o_nack_ntfy_tgl_0;
assign o_nack_ntfy_tgl_1_nxt    = 1'b0;

assign o_abr_num_nxt            = {NUM_WID{i_i2cm_addr_done}} & abr_num_cfg;
assign o_abr_addr_nxt           = i_i2cm_addr_done ? i_i2cm_addr_cnt : abr_addr_cfg; 
assign o_abr_data_nxt           = i_i2cm_data;

assign trg_0_chg                = abr_trg_0_op_smo;
assign o_abr_int_flag_nxt       = 1'b0;
assign trg_1_restore_nxt        = 1'b0;

assign o_abr_op                 = ~abr_idle_smo;
end

endgenerate

// ---------- State Machine --------------------//
assign abr_idle_smo             = i2cm_abr_cs[0];
assign abr_trg_0_op_smo         = i2cm_abr_cs[1];
assign abr_trg_1_op_smo         = i2cm_abr_cs[2];
assign abr_wait_int_smo         = i2cm_abr_cs[3];
assign abr_int_1st_addr_smo     = i2cm_abr_cs[4];
assign abr_int_data_smo         = i2cm_abr_cs[5];
assign abr_int_smo              = i2cm_abr_cs[6];

always @* begin : I2CM_ABR_FSM

   i2cm_abr_ns  = i2cm_abr_cs;

   case (i2cm_abr_cs)
     
     ABR_IDLE :         begin 

                            if(abr_trg_0)
                              i2cm_abr_ns = ABR_TRG_0_OP;
                            else
                              if(abr_trg_1)
                                i2cm_abr_ns = ABR_TRG_1_OP;

                        end

     ABR_TRG_0_OP :     begin 

                            if(i_i2cm_finish_pulse) begin     
                              if(trg_1_restore)       
                                i2cm_abr_ns = ABR_INT_1ST_ADDR;
                              else
                                i2cm_abr_ns = ABR_IDLE;
                            end

                        end

     ABR_TRG_1_OP :     begin 

                            if(i_i2cm_finish_pulse) 
                              i2cm_abr_ns = ABR_IDLE;
                            else
                              if(i_i2cm_num_cnt_inc & abr_trg_0)
                                i2cm_abr_ns = ABR_WAIT_INT;

                        end

     ABR_WAIT_INT :     begin 

                            if(i_i2cm_clr_smo)                           // i2c master idle state 
                              i2cm_abr_ns = ABR_TRG_0_OP;

                        end

     ABR_INT_1ST_ADDR : begin                                            //trigger first address  
                        
                            if(i_i2cm_addr_done)
                              i2cm_abr_ns = ABR_INT_DATA;
                            else
                              if(i_i2cm_finish_pulse)                    //nack finish 
                                i2cm_abr_ns = ABR_IDLE;
                        end

     ABR_INT_DATA :     begin 

                            if(nack_pulse)                               //in order to transmit address again 
                              i2cm_abr_ns = ABR_INT_1ST_ADDR;
                            else 
                              if(i_i2cm_finish_pulse)
                                i2cm_abr_ns = ABR_IDLE;

                        end


    endcase

end

always @(posedge i2c_clk or negedge i2c_rst_n) begin
   if(~i2c_rst_n) begin 
     i2cm_abr_cs           <= ABR_IDLE;
   end
   else begin 
     i2cm_abr_cs           <= i2cm_abr_ns;
   end
end


always @(posedge i2c_clk or negedge i2c_rst_n) begin
   if (~i2c_rst_n) begin
//----------------------------------------------select 
     o_finish_tgl_0        <= 1'b0;
     o_finish_tgl_1        <= 1'b0;
     o_nack_ntfy_tgl_0     <= 1'b0;
     o_nack_ntfy_tgl_1     <= 1'b0;
//---------------------------------------------interrupt
     o_abr_num             <= {(NUM_WID){1'h0}};
     addr_keep             <= 8'h0;
     num_keep              <= {(NUM_WID){1'h0}};
     data_keep_high        <= {(NUM_WID){1'h0}};
     data_keep_low_cnt     <= {(NUM_WID){1'h0}};
     o_abr_int_flag        <= 1'b0;
     trg_1_restore         <= 1'b0;
     abr_trg_0             <= 1'b0;
     abr_trg_1             <= 1'b0;
//---------------------------------------------others
     i_i2cm_wdata_nack_q   <= 1'b0;
   end
   else begin
//----------------------------------------------select 
     o_finish_tgl_0        <= o_finish_tgl_0_nxt;
     o_finish_tgl_1        <= o_finish_tgl_1_nxt;
     o_nack_ntfy_tgl_0     <= o_nack_ntfy_tgl_0_nxt;
     o_nack_ntfy_tgl_1     <= o_nack_ntfy_tgl_1_nxt;
//---------------------------------------------interrupt
     o_abr_num             <= o_abr_num_nxt;
     addr_keep             <= addr_keep_nxt;
     num_keep              <= num_keep_nxt;
     data_keep_high        <= data_keep_high_nxt;
     data_keep_low_cnt     <= data_keep_low_cnt_nxt;
     o_abr_int_flag        <= o_abr_int_flag_nxt;
     trg_1_restore         <= trg_1_restore_nxt;
     abr_trg_0             <= abr_trg_0_nxt;
     abr_trg_1             <= abr_trg_1_nxt;
//---------------------------------------------others
     i_i2cm_wdata_nack_q   <= i_i2cm_wdata_nack;
   end
end



//----------------------------------------------//
// generate block                               //
//----------------------------------------------//
   

generate

if ((TRG_CDC == "ASYNC") & (TRG_TYPE == "MUTI")) begin
ip_sync2 trg_0_sync(
                //output
                .ffq                          (sxm_trg_0),

                //input
                .ffd                          (i_i2cm_trg_0),
                .sync_clk                     (i2c_clk),
                .sync_rst_n                   (i2c_rst_n)
                );

ip_sync2 trg_1_sync(
                //output
                .ffq                          (sxm_trg_1),

                //input
                .ffd                          (r_i2cm_trg_1),
                .sync_clk                     (i2c_clk),
                .sync_rst_n                   (i2c_rst_n)
                );

end
else if (TRG_TYPE == "MUTI") begin

assign sxm_trg_0 = i_i2cm_trg_0;
assign sxm_trg_1 = r_i2cm_trg_1;

end
else if (TRG_CDC == "ASYNC") begin
ip_sync2 trg_0(
                //output
                .ffq                          (sxm_trg_0),

                //input
                .ffd                          (i_i2cm_trg_0),
                .sync_clk                     (i2c_clk),
                .sync_rst_n                   (i2c_rst_n)
                );
  assign sxm_trg_1 = 1'b0;
end
else begin
assign sxm_trg_0 = i_i2cm_trg_0;
assign sxm_trg_1 = 1'b0;
end

endgenerate


endmodule
