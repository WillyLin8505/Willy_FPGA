// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2023
//
// File Name:           
// Author:              Willy Lin
// Version:             1.0
// Date:                2023
// Last Modified On:    
// Last Modified By:    
// limitation : 

// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------
/*
module bin_sorting 

   #( 
      //---------------------------------------------raw data precision 
      parameter  RAW_CIIW           = 10,
      parameter  RAW_CIPW           = 0,
      
      parameter  RAW_CIW            = RAW_CIIW + RAW_CIPW, 
      parameter  COLOR_ARRAY_NUM_2  = 9
     )

(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
  output [RAW_CIW-1:0]                       raw_max                         [0:COLOR_ARRAY_NUM_2-1] ,  
  output [RAW_CIW-1:0]                       raw_min                         [0:COLOR_ARRAY_NUM_2-1] ,  

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
  input  [RAW_CIW*(COLOR_ARRAY_NUM_2-1)-1:0] i_data
 
 
);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//

//-----------------------------------------------------------------------------------------------------------others 
genvar                                                                  index;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

assign data_bit = i_data;
assign data_bit_pipe_nxt[0] = data_bit;

 generate 
  for (index=1;index<RAW_CIW;index=index+1) begin : data_bit_pipe_gen
assign data_bit_pipe_nxt[index] = data_bit_pipe[index-1];
  end 
 endgenerate 

assign all_same_nxt           = (&  data_bit_pipe_nxt[0][(COLOR_ARRAY_NUM_2-1)*(RAW_CIW-1)+:(COLOR_ARRAY_NUM_2-1)]) | 
                                (&(~data_bit_pipe_nxt[0][(COLOR_ARRAY_NUM_2-1)*(RAW_CIW-1)+:(COLOR_ARRAY_NUM_2-1)]));

assign bit_result_max_nxt[0]  = {(COLOR_ARRAY_NUM_2-1){all_same}} | data_bit_pipe_nxt[1][(COLOR_ARRAY_NUM_2-1)*(RAW_CIW-1)+:(COLOR_ARRAY_NUM_2-1)];
assign bit_result_min_nxt[0]  = {(COLOR_ARRAY_NUM_2-1){all_same}} | (~data_bit_pipe_nxt[1][(COLOR_ARRAY_NUM_2-1)*(RAW_CIW-1)+:(COLOR_ARRAY_NUM_2-1)]);

 generate 
  for (index=1;index<RAW_CIW;index=index+1) begin : bit_result_gen //max and min 
    assign result_max_sel_nxt[index-1]   = (bit_result_max_nxt[index-1] & data_bit_pipe_nxt[index][(COLOR_ARRAY_NUM_2-1)*(RAW_CIW-index-1)+:(COLOR_ARRAY_NUM_2-1)]);
    assign result_min_sel_nxt[index-1]   = (bit_result_min_nxt[index-1] & ~data_bit_pipe_nxt[index][(COLOR_ARRAY_NUM_2-1)*(RAW_CIW-index-1)+:(COLOR_ARRAY_NUM_2-1)]);
    assign bit_result_max_nxt[index]     = result_max_sel[index-1] ? result_max_sel[index-1] : bit_result_max[index-1];  
    assign bit_result_min_nxt[index]     = result_min_sel[index-1] ? result_min_sel[index-1] : bit_result_min[index-1];
  end 
 endgenerate 
 
 
assign raw_max [0]  = {RAW_CIW{bit_result_max[RAW_CIW-1][0]}} & step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+:RAW_CIW]; //pipe 1
assign raw_min [0]  = {RAW_CIW{bit_result_min[RAW_CIW-1][0]}} & step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+:RAW_CIW]; //pipe 1

 generate 
  for (index=0;index<COLOR_ARRAY_NUM_2-1;index=index+1) begin : max_min_raw_gen //max and min 
    if (index >= 4) begin //over the middle pixel 
      assign raw_max [index+1] = raw_max [index] | ({RAW_CIW{bit_result_max[RAW_CIW-1][index]}} & 
                                                                                 step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*(index+1) +: RAW_CIW]);
      assign raw_min [index+1] = raw_min [index] | ({RAW_CIW{bit_result_min[RAW_CIW-1][index]}} & 
                                                                                 step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*(index+1) +: RAW_CIW]);
    end 
    else begin 
      assign raw_max [index+1] = raw_max [index] | ({RAW_CIW{bit_result_max[RAW_CIW-1][index]}} & 
                                                                                 step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*(index) +: RAW_CIW]);
      assign raw_min [index+1] = raw_min [index] | ({RAW_CIW{bit_result_min[RAW_CIW-1][index]}} & 
                                                                                 step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*(index) +: RAW_CIW]);
    end
  end 
 endgenerate 
 

 
assign target_pixel_nxt         = step_1_color_4_que_nxt[RAW_CIW*(COLOR_ARRAY_NUM_2)*COM_CLR_4_DLY+RAW_CIW*4 +: RAW_CIW];       // precision : RAW_CIW:10.0 
assign raw_max_fnl_nxt          = raw_max[COLOR_ARRAY_NUM_2-1];                                                                 // precision : RAW_CIW:10.0
assign raw_min_fnl_nxt          = raw_min[COLOR_ARRAY_NUM_2-1];                                                                 // precision : RAW_CIW:10.0
assign ptnl_w_point_nxt         = target_pixel >= raw_max_fnl;   
assign raw_fnl_sel_num_nxt      = ((!coord_total_eq_que_nxt[COM_STEP_1_RAW_FNL_DLY] & ptnl_w_point_nxt) | 
                                    (coord_total_eq_que_nxt[COM_STEP_1_RAW_FNL_DLY] & !coord_bw_que_nxt[COM_STEP_1_RAW_FNL_DLY])) ? raw_max_fnl : raw_min_fnl;  

                                                                                                                                                            // precision : RAW_CIW:10.0
assign target_pixel_que_nxt     = {target_pixel_que   [0+:RAW_CIW                   *(COM_STEP_2_TAR_REPL_DLY     +1)],target_pixel};
assign raw_max_fnl_que_nxt      = {raw_max_fnl_que    [0+:RAW_CIW                   *(RECIP_DLY                   +1)],raw_max_fnl};
assign raw_min_fnl_que_nxt      = {raw_min_fnl_que    [0+:RAW_CIW                   *(RECIP_DLY                   +1)],raw_min_fnl};
assign ptnl_w_point_que_nxt     = {ptnl_w_point_que   [0+:                           (COM_STEP_2_REPL_RAW_FNL_DLY +1)],ptnl_w_point};
assign raw_fnl_sel_num_que_nxt  = {raw_fnl_sel_num_que[0+:RAW_CIW                   *(COM_STEP_2_REPL_RAW_FNL_DLY +1)],raw_fnl_sel_num};
assign step_1_color_4_que_nxt   = {step_1_color_4_que [0+:COLOR_ARRAY_NUM_2*RAW_CIW *(COM_CLR_4_DLY               +1)],step_1_color_4};

generate   
  if(MODE_SEL == 1) begin 
    assign raw_fnl_sta_sel_num_nxt      = coord_bw_que_nxt[COM_STEP_1_RAW_FNL_DLY] ? raw_min_fnl : raw_max_fnl;
    assign raw_fnl_sta_sel_num_que_nxt  = {raw_fnl_sta_sel_num_que[0+:RAW_CIW*(COM_STA_FNL_STA_SEL_DLY+1)],raw_fnl_sta_sel_num};
  end 
endgenerate 

//-----------------------------------------------------------------------------------------------------------sequencial logic  
always@(posedge clk or negedge rst_n) begin 
if(!rst_n) begin 

end 
end 




endmodule 
*/

