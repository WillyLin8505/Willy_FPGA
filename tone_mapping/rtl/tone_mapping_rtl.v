// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           
// Author:              Willy Lin
// Version:             1.0
// Date:                2022
// Last Modified On:    
// Last Modified By:    $Author$
// Range limitation:    gm_val = 1.5 - 2.5          //control y value 
//                      toe_length = 0 ~ 0.33      //control y value 
//                      toe_strength = 0 ~ 0.5     //control y value 
//                      shoulder_length =0 ~ 0.33 //control y value 
//                      shoulder_strength = 0 ~ 0.5 //control y value 
//                      REFI_L : CIIW : 1
//                               CIPW : 12
//                               COIW : 1
//                               COPW : 10
//                      REFI_C : CIIW : 1
//                               CIPW : 12
//                               COIW : 1
//                               COPW : 7
//                      OK_L   : CIIW : 0
//                               CIPW : 15
//                               COIW : 0
//                               COPW : 13
//                      timing : 2T
// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------

module tone_mapping

   #( 
      parameter CIIW         = 0,
      parameter CIPW         = 15, 
      parameter COIW         = 0, 
      parameter COPW         = 13,
      parameter SEL_CURVE    = "OK_L", //REFI_L,REFI_C,OK_L
      parameter CIW          = CIIW + CIPW,
      parameter COW          = COIW + COPW,
      parameter LUT_MAP_WTH  = (SEL_CURVE == "REFI_L") ? 11 : 
                               (SEL_CURVE == "REFI_C") ? 8  : 13, 
      parameter LUT_MAP_NUM  = (SEL_CURVE == "REFI_L") ? 25 : 
                               (SEL_CURVE == "REFI_C") ? 9  : 25
     )

(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
  output reg                              o_hstr,
  output reg   [COW-1:0]                  o_data,
  output reg                              o_href,
  output reg                              o_hend,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
  input    [CIW-1:0]                      i_data,    //x3_value 
  input                                   i_hstr,
  input                                   i_href,
  input                                   i_hend,
  input    [LUT_MAP_WTH*LUT_MAP_NUM-1:0]  l_tone_y_data,
  
  input                                   clk,
  input                                   rst_n
);

//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//
//---------------------------------------------------DELAY 
localparam                                DLY_NUM        = 1;
//---------------------------------------------------WTH 
localparam                                LUT_SPL_WTH    = (SEL_CURVE == "REFI_L") ? 13 : 
                                                           (SEL_CURVE == "REFI_C") ? 13 : 17; //value width 
localparam                                LUT_SFT_WTH    = 4;                                 //max lut shift is 11                               
localparam                                X_VALUE_WTH    = (SEL_CURVE == "REFI_L") ? 5 : 
                                                           (SEL_CURVE == "REFI_C") ? 3 :5;
localparam                                Y_DIFF_MIN_WTH = (SEL_CURVE == "REFI_L") ? 8 : 
                                                           (SEL_CURVE == "REFI_C") ? 6 :10;   //max y diff value REFI_L:127, REFI_C:32 , OK_L:1023
//-----------------------------------------------------CODE PART 
localparam                                X_MIN_SFT      = (SEL_CURVE == "REFI_L") ? 7 : 
                                                           (SEL_CURVE == "REFI_C") ? 9 :10; //minium sft for x value 
localparam                                X_MAX_SFT      = (SEL_CURVE == "REFI_L") ? 9 : 
                                                           (SEL_CURVE == "REFI_C") ? 10 :12; //minium sft for x value                                                                                                 
//----------------------------------------------------LUT        

localparam  [LUT_SPL_WTH*LUT_MAP_NUM-1:0] LUT_SPL_VAL    = (SEL_CURVE == "REFI_L") ? {13'd4096,13'd3840,13'd3584,13'd3328,13'd3072,13'd2816,13'd2560,13'd2304,13'd2048,13'd1792,
                                                                                      13'd1664,13'd1536,13'd1408,13'd1280,13'd1152,13'd1024,13'd896,13'd768,13'd640,13'd512,
                                                                                      13'd384,13'd256,13'd192,13'd128,13'd0} : 
                                                           (SEL_CURVE == "REFI_C") ? {13'd4096,13'd3584,13'd3072,13'd2560,13'd2048,13'd1536,13'd1024,13'd512,13'd0}:
                                                                                     {17'd32768,17'd30720,17'd28672,17'd26624,17'd24576,17'd22528,17'd20480,17'd18432,17'd16384,
                                                                                      17'd14336,17'd13312,17'd12288,17'd11264,17'd10240,17'd9216,17'd8192,17'd7168,17'd6144,
                                                                                      17'd5120,17'd4096,17'd3072,17'd2048,17'd1536,17'd1024,17'd0};
localparam  [LUT_SFT_WTH*LUT_MAP_NUM-1:0] LUT_SFT        = (SEL_CURVE == "REFI_L") ? {4'd8,4'd8,4'd8,4'd8,4'd8,4'd8,4'd8,4'd8,4'd8,4'd7,4'd7,
                                                                                      4'd7,4'd7,4'd7,4'd7,4'd7,4'd7,4'd7,4'd7,4'd7,4'd7,4'd6,4'd6,4'd7} : 
                                                           (SEL_CURVE == "REFI_C") ? {4'd9,4'd9,4'd9,4'd9,4'd9,4'd9,4'd9,4'd9} :
                                                                                     {4'd11,4'd11,4'd11,4'd11,4'd11,4'd11,4'd11,4'd11,4'd11,4'd10,4'd10,
                                                                                      4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,4'd10,4'd9,4'd9,4'd10};

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
reg  [CIW-1:0]                              i_data_ppf0;    //x3_value 

wire                                        map_x_1_cmp;
wire                                        map_msb;
wire                                        map_lsb_nxt;
reg                                         map_lsb;

reg  [X_VALUE_WTH*2-1:0]                    x1_value;
reg  [X_VALUE_WTH*2-1:0]                    x1_value_q;
wire [LUT_MAP_WTH-1:0]                      y1_value_ppr0_nxt;
reg  [LUT_MAP_WTH-1:0]                      y1_value_ppr0;
reg  [LUT_MAP_WTH-1:0]                      y1_value_ppf1;
wire [LUT_MAP_WTH-1:0]                      y2_value; 
wire [Y_DIFF_MIN_WTH-1:0]                   y_diff_nxt;
reg  [Y_DIFF_MIN_WTH-1:0]                   y_diff;
wire [LUT_SFT_WTH-1:0]                      x_diff_ppr0_nxt;
reg  [LUT_SFT_WTH-1:0]                      x_diff_ppr0;
reg  [LUT_SFT_WTH-1:0]                      x_diff_ppf1;
wire [Y_DIFF_MIN_WTH+X_MAX_SFT:0]           y3_value_0_ppr0_nxt;
reg  [Y_DIFF_MIN_WTH+X_MAX_SFT:0]           y3_value_0_ppr0;
reg  [Y_DIFF_MIN_WTH+X_MAX_SFT:0]           y3_value_0_ppf1;
wire [Y_DIFF_MIN_WTH+X_MAX_SFT-X_MIN_SFT:0] y3_value_rnd;
wire [COW-1:0]                              y3_value; 

//----------------------------------------------output
reg  [(DLY_NUM+1)*3-1:0]                    hcomb;
wire [(DLY_NUM+1)*3-1:0]                    hcomb_nxt;
wire [COW-1:0]                              o_data_nxt; 
wire                                        o_hstr_nxt; 
wire                                        o_href_nxt; 
wire                                        o_hend_nxt; 

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//

generate 
  if((SEL_CURVE == "REFI_L") | (SEL_CURVE == "OK_L")) begin 
    assign map_x_1_cmp = i_data[X_MIN_SFT+:5] == 1'b1;
    assign map_msb     = i_data[CIW-1];
    assign map_lsb_nxt = map_x_1_cmp & i_data[X_MIN_SFT-1];
  end 
  else begin
    assign map_msb     = 0;
    assign map_lsb_nxt = 0;
  end 
endgenerate 

generate 
if((SEL_CURVE == "REFI_L") | (SEL_CURVE == "OK_L")) begin 
always@* begin 

  x1_value = 0;

  case (i_data[X_MIN_SFT+:5]) // synopsys full_case
    5'b00000  :  x1_value = {map_msb,1'b0,map_msb,map_msb,map_msb,map_msb,map_msb,map_msb,map_msb,1'b0}; //share with 0 4096 32768  
    5'b00001  :  x1_value = {1'b0,1'b0,1'b0,map_lsb_nxt,!map_lsb_nxt,5'd1}; //share with 128 , 192 
    5'b00010  :  x1_value = {5'd3,5'h2};
    5'b00011  :  x1_value = {5'd4,5'h3};
    5'b00100  :  x1_value = {5'd5,5'h4};
    5'b00101  :  x1_value = {5'd6,5'h5};
    5'b00110  :  x1_value = {5'd7,5'h6};
    5'b00111  :  x1_value = {5'd8,5'h7};
    5'b01000  :  x1_value = {5'd9,5'h8};
    5'b01001  :  x1_value = {5'd10,5'h9};
    5'b01010  :  x1_value = {5'd11,5'ha};
    5'b01011  :  x1_value = {5'd12,5'hb};
    5'b01100  :  x1_value = {5'd13,5'hc};
    5'b01101  :  x1_value = {5'd14,5'hd};
    5'b01110  :  x1_value = {5'd15,5'he};
    5'b01111  :  x1_value = {5'd15,5'he};
    5'b10000  :  x1_value = {5'd16,5'h10};
    5'b10001  :  x1_value = {5'd16,5'h10};
    5'b10010  :  x1_value = {5'd17,5'h12};
    5'b10011  :  x1_value = {5'd17,5'h12};
    5'b10100  :  x1_value = {5'd18,5'h14};
    5'b10101  :  x1_value = {5'd18,5'h14};
    5'b10110  :  x1_value = {5'd19,5'h16};
    5'b10111  :  x1_value = {5'd19,5'h16};
    5'b11000  :  x1_value = {5'd20,5'h18};
    5'b11001  :  x1_value = {5'd20,5'h18};
    5'b11010  :  x1_value = {5'd21,5'h1a};
    5'b11011  :  x1_value = {5'd21,5'h1a};
    5'b11100  :  x1_value = {5'd22,5'h1c};
    5'b11101  :  x1_value = {5'd22,5'h1c};
    5'b11110  :  x1_value = {5'd23,5'h1e};
    5'b11111  :  x1_value = {5'd23,5'h1e};
  endcase 
end 
end 
else begin 
always@* begin 

  x1_value = 0;

  case (i_data[X_MIN_SFT+:3]) // synopsys full_case
    3'b000  :  x1_value = {3'd0,3'd0};
    3'b001  :  x1_value = {3'd1,3'd1};
    3'b010  :  x1_value = {3'd2,3'd2};
    3'b011  :  x1_value = {3'd3,3'd3};
    3'b100  :  x1_value = {3'd4,3'd4};
    3'b101  :  x1_value = {3'd5,3'd5};
    3'b110  :  x1_value = {3'd6,3'd6};
    3'b111  :  x1_value = {3'd7,3'd7};

  endcase
end 
end 
endgenerate 

assign y1_value_ppr0_nxt   = l_tone_y_data >> (x1_value[X_VALUE_WTH*2-1:X_VALUE_WTH])*LUT_MAP_WTH;
assign y2_value            = l_tone_y_data >> (x1_value[X_VALUE_WTH*2-1:X_VALUE_WTH]+1)*LUT_MAP_WTH;
assign y_diff_nxt          = y2_value - y1_value_ppr0_nxt;
assign x_diff_ppr0_nxt     = LUT_SFT >> (x1_value[X_VALUE_WTH*2-1:X_VALUE_WTH])*LUT_SFT_WTH;
assign y3_value_0_ppr0_nxt = ((i_data - {x1_value[X_VALUE_WTH-1:0],map_lsb_nxt,{X_MIN_SFT-1{1'b0}}}) * y_diff_nxt); // rounding 
assign y3_value_rnd        = (y3_value_0_ppr0 >> x_diff_ppr0-1) + 1'b1;
assign y3_value            = y3_value_rnd[Y_DIFF_MIN_WTH+X_MAX_SFT-X_MIN_SFT:1] + y1_value_ppr0;

//----------------------------------------------output
assign o_data_nxt   = y3_value;
assign hcomb_nxt    = {hcomb[DLY_NUM*3-1:0],i_hstr,i_href,i_hend};
assign o_hstr_nxt   = hcomb[(DLY_NUM-1)*3+2];
assign o_href_nxt   = hcomb[(DLY_NUM-1)*3+1];
assign o_hend_nxt   = hcomb[(DLY_NUM-1)*3+0];

//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//


always@(posedge clk or negedge rst_n) begin 
if(!rst_n) begin 
  y3_value_0_ppr0 <= 0;
  y3_value_0_ppf1 <= 0;
  x_diff_ppr0     <= 0;
  x_diff_ppf1     <= 0;
  y1_value_ppr0   <= 0;
  y1_value_ppf1   <= 0;
  y_diff          <= 0;
  i_data_ppf0     <= 0;
  x1_value_q      <= 0;
  
//---------------------------output
  hcomb           <= 0;
  o_data          <= 0;
  o_hstr          <= 0;
  o_href          <= 0;
  o_hend          <= 0;
end
else begin 
  y3_value_0_ppr0 <= y3_value_0_ppr0_nxt;
  y3_value_0_ppf1 <= y3_value_0_ppr0;
  x_diff_ppr0     <= x_diff_ppr0_nxt;
  x_diff_ppf1     <= x_diff_ppr0;
  y1_value_ppr0   <= y1_value_ppr0_nxt;
  y1_value_ppf1   <= y1_value_ppr0;
  y_diff          <= y_diff_nxt;
  i_data_ppf0     <= i_data;
  x1_value_q      <= x1_value;
  
//---------------------------output
  hcomb           <= hcomb_nxt;
  o_data          <= o_data_nxt;
  o_hstr          <= o_hstr_nxt;
  o_href          <= o_href_nxt;
  o_hend          <= o_hend_nxt;
end 
end 


endmodule 
