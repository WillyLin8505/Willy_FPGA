 // +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2023
//
// File Name:           dpc_insert
// Author:              Willy Lin
// Version:             1.0
// Date:                2023
// Last Modified On:    
// Last Modified By:    
// limitation :

// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------
module dpc_insert 

  #(
//---------------------------------------------raw data precision 
      parameter  RAW_CIIW           = 10,
      parameter  PX_RATE            = 2,
      
      parameter  IMG_VSZ_WTH        = 11,
      
      //localparam 
      parameter  PX_WD              = RAW_CIIW * PX_RATE,
      parameter  PX_RATE_WTH        = $clog2(PX_RATE+1),
      parameter  STEP_WTH           = 8,
      parameter  MAX_STEP           = 2**STEP_WTH
  )
(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg [PX_WD-1:0]       o_data,
output reg                   o_dvld,
output reg                   o_hstr,
output reg                   o_hend,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input      [PX_WD-1:0]       i_raw_data,
input                        i_data_vld,
input                        i_hstr,
input                        i_hend,
input      [PX_RATE_WTH-1:0] i_cnt_add_cu,

input                        r_mode_sel, //0 : pixel mode 1: dead column mode 
input      [RAW_CIIW-1:0]    r_clr_chg,
input      [STEP_WTH-1:0]    r_hstep,
input      [STEP_WTH-1:0]    r_vstep,
input                        r_ins_en,

input                        clk,
input                        rst_n
);

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
//-----------------------------------------------------------------------------------------------------------hor 
wire       [PX_RATE_WTH-1:0] cnt_add_cu;
wire       [PX_RATE_WTH-1:0] cnt_add_num;
wire       [8-1:0]           hor_cnt_num     [0:PX_RATE-1];
wire                         hor_cnt_eq      [0:PX_RATE-1];
reg        [8-1:0]           hor_cnt         [0:PX_RATE-1];
wire       [8-1:0]           hor_cnt_nxt     [0:PX_RATE-1];
wire                         hor_cnt_inc     [0:PX_RATE-1];
wire                         hor_cnt_clr     [0:PX_RATE-1];
wire                         hor_cnt_set     [0:PX_RATE-1];
wire       [8-1:0]           hor_cnt_set_val [0:PX_RATE-1];
//-----------------------------------------------------------------------------------------------------------ver 
wire                         ver_cnt_eq;
reg        [IMG_VSZ_WTH-1:0] ver_cnt;
wire       [IMG_VSZ_WTH-1:0] ver_cnt_nxt;
wire                         ver_cnt_inc;
wire                         ver_cnt_clr;

//-----------------------------------------------------------------------------------------------------------replace 
wire       [PX_WD-1:0]       repl_px;

//-----------------------------------------------------------------------------------------------------------output  
wire       [PX_WD-1:0]       o_data_nxt;
wire                         o_dvld_nxt;
wire                         o_hstr_nxt;
wire                         o_hend_nxt;

//-----------------------------------------------------------------------------------------------------------general 
genvar                       index;
integer                      int_index;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//-----------------------------------------------------------------------------------------------------------hor 
assign cnt_add_cu                 = i_cnt_add_cu; //PX_RATE - r_hstep;
assign cnt_add_num                = (PX_RATE > r_hstep) ? cnt_add_cu : PX_RATE;

generate 
  for (index=0;index<PX_RATE;index=index+1) begin : hor_cnt_gen
assign hor_cnt_num[index]         = hor_cnt[index]+PX_RATE;

assign hor_cnt_nxt[index]         = (hor_cnt_set[index] ? hor_cnt_set_val[index] : hor_cnt_inc[index] ? hor_cnt[index] + cnt_add_num : hor_cnt[index]) & 
                                                                                                                                           {IMG_VSZ_WTH{!hor_cnt_clr[index]}};
assign hor_cnt_inc[index]         = r_ins_en & i_data_vld;
assign hor_cnt_clr[index]         = (hor_cnt_num[index] == r_hstep);
assign hor_cnt_set[index]         = r_ins_en & (i_hstr | (hor_cnt_num[index] > r_hstep));
assign hor_cnt_set_val[index]     = (i_hstr & r_ins_en) ? (index > r_hstep) ? (index%r_hstep) : index : (hor_cnt_num[index] - r_hstep);

assign hor_cnt_eq[index]          = hor_cnt[index] == r_hstep - 1'b1;
  end 
endgenerate 


//-----------------------------------------------------------------------------------------------------------ver 
assign ver_cnt_eq                 = r_vstep == ver_cnt-1;

assign ver_cnt_nxt                = (ver_cnt_inc ? ver_cnt + 1'b1 : ver_cnt) & {IMG_VSZ_WTH{!ver_cnt_clr}};
assign ver_cnt_inc                = i_hstr;
assign ver_cnt_clr                = i_hstr & ver_cnt_eq;

//-----------------------------------------------------------------------------------------------------------replace   
generate 
  for (index=0;index<PX_RATE;index=index+1) begin : insert_sft_en_gen
    assign repl_px[index*RAW_CIIW+:RAW_CIIW] = (hor_cnt_eq[index] & ver_cnt_eq) ? r_clr_chg : i_raw_data[RAW_CIIW*index+:RAW_CIIW];
  end 
endgenerate 

//-----------------------------------------------------------------------------------------------------------output  
assign o_data_nxt                 = repl_px;
assign o_hstr_nxt                 = i_hstr;
assign o_dvld_nxt                 = i_data_vld;
assign o_hend_nxt                 = i_hend;

//----------------------------------------------//
// sequencial logic                             //
//----------------------------------------------//
always@(posedge clk or negedge rst_n) begin 
  if(!rst_n) begin 
//---------------------------------------------------------------------------------ver
    ver_cnt        <= 0;
    
//---------------------------------------------------------------------------------output  
    o_data         <= 0;
    o_hstr         <= 0;
    o_dvld         <= 0;
    o_hend         <= 0;
    
  end 
  else begin  
//---------------------------------------------------------------------------------ver 
    ver_cnt        <= ver_cnt_nxt;
    
//---------------------------------------------------------------------------------output  
    o_data         <= o_data_nxt;
    o_hstr         <= o_hstr_nxt;
    o_dvld         <= o_dvld_nxt;
    o_hend         <= o_hend_nxt;
    
  end 
end 

always@(posedge clk or negedge rst_n) begin 
if(!rst_n) begin 
for(int_index=0;int_index<PX_RATE;int_index=int_index+1) begin : rst_0_gen
  hor_cnt[int_index] <= 0;
end
end
else begin 
  for(int_index=0;int_index<PX_RATE;int_index=int_index+1) begin : rst_1_gen
 hor_cnt[int_index] <= hor_cnt_nxt[int_index];
  end 
end 
end 


endmodule 
