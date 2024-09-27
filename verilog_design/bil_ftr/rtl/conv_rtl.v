module  conv 
   #( 
      parameter  KRNV_SZ      = 5,
      parameter  KRNH_SZ      = 5,
      parameter  CONV_TOL_WTH = 8,
      parameter  CIW          = 0,
      parameter  ODATA_RNG    = 0,
      parameter  KERNEL_NUM   = 0,
      parameter  FILTER_WTH   = 0,
      parameter  KRNH_SZ_MID  = 0,
      parameter  DIFF_DLY     = 0,
      parameter  FILTER_DLY   = 0
     )

(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output reg [CONV_TOL_WTH-1:0]     o_data,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input      [CIW*KRNV_SZ*ODATA_RNG-1:0] i_data,
input      [FILTER_WTH*KERNEL_NUM-1:0]            i_flt_weight                   ,   //precision : 0.8
input                                  clk,
input                                  rst_n
);


//----------------------------------------------//
// register declaration                            //
//----------------------------------------------//
reg         [CIW*KRNV_SZ*ODATA_RNG-1:0] i_data_ppf0;
reg         [CIW*KRNV_SZ*ODATA_RNG-1:0] i_data_ppf1;
reg         [CIW*KRNV_SZ*ODATA_RNG-1:0] i_data_ppf2;
reg         [CIW*KRNV_SZ*ODATA_RNG-1:0] i_data_ppf3;
reg         [CIW*KRNV_SZ*ODATA_RNG-1:0] i_data_ppf4;
reg         [CIW*KRNV_SZ*ODATA_RNG-1:0] i_data_ppf5;
wire        [CONV_TOL_WTH-1:0]       o_data_nxt;

wire        [CONV_TOL_WTH-1:0]       data_conv_ppr0_nxt                ;      //input 8 bit  -> : precision : 12.8 . 
                                                                                     //input 8.4bit -> : precision : 13.12 
reg         [CONV_TOL_WTH-1:0]       data_conv_ppr0                    ;      //input 8 bit  -> : precision : 12.8 . 

wire         [FILTER_WTH-1:0]         flt_weight_nxt                   [0:KERNEL_NUM-1];   //precision : 0.8
reg         [FILTER_WTH-1:0]          flt_weight                      [0:KERNEL_NUM-1]; 
reg         [FILTER_WTH-1:0]          flt_weight_q                    [0:KERNEL_NUM-1];   
reg         [FILTER_WTH-1:0]          flt_weight_q2                   [0:KERNEL_NUM-1];   
reg         [FILTER_WTH-1:0]          flt_weight_ppf0                 [0:KERNEL_NUM-1];   
reg         [FILTER_WTH-1:0]          flt_weight_ppf1                 [0:KERNEL_NUM-1];  
reg         [FILTER_WTH-1:0]          flt_weight_ppf2                 [0:KERNEL_NUM-1];  
reg         [FILTER_WTH-1:0]          flt_weight_ppf3                 [0:KERNEL_NUM-1];   
reg         [FILTER_WTH-1:0]          flt_weight_ppf4                 [0:KERNEL_NUM-1];  
reg         [FILTER_WTH-1:0]          flt_weight_ppf5                 [0:KERNEL_NUM-1]; 

//----------------------------------------------------------------------for loop genvar
genvar                      flt_i,flt_i_2;
integer                     rst_i;   

generate 
  for(flt_i=0;flt_i<KRNH_SZ;flt_i=flt_i+1) begin : flt_weight_array_gen //pipe 1 end
    for(flt_i_2=0;flt_i_2<KRNV_SZ;flt_i_2=flt_i_2+1) begin : flt_weight_array_gen_2
assign flt_weight_nxt[flt_i*KRNV_SZ+flt_i_2] = i_flt_weight[(FILTER_WTH)*(flt_i*KRNV_SZ+flt_i_2+1)-1 : (FILTER_WTH)*(flt_i*KRNV_SZ+flt_i_2)];
    end 
  end
endgenerate  

generate 
  if((KRNH_SZ == 3'd3) && (KRNV_SZ == 3'd3)) begin
    assign data_conv_ppr0_nxt = 
       i_data_ppf1[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-0)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-1)*CIW] * flt_weight_ppf2[0*KRNV_SZ + 2] + 
       i_data_ppf1[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-1)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-2)*CIW] * flt_weight_ppf2[0*KRNV_SZ + 1] + 
       i_data_ppf1[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-2)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-3)*CIW] * flt_weight_ppf2[0*KRNV_SZ + 0] +
       i_data_ppf1[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-0)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-1)*CIW] * flt_weight_ppf2[1*KRNV_SZ + 2] + 
       i_data_ppf1[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-1)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-2)*CIW] * flt_weight_ppf2[1*KRNV_SZ + 1] + 
       i_data_ppf1[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-2)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-3)*CIW] * flt_weight_ppf2[1*KRNV_SZ + 0] +
       i_data_ppf1[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-0)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-1)*CIW] * flt_weight_ppf2[2*KRNV_SZ + 2] + 
       i_data_ppf1[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-1)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-2)*CIW] * flt_weight_ppf2[2*KRNV_SZ + 1] + 
       i_data_ppf1[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-2)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-3)*CIW] * flt_weight_ppf2[2*KRNV_SZ + 0] ;
    end 
endgenerate

generate 
  if((KRNH_SZ == 3'd5) && (KRNV_SZ == 3'd5)) begin
    assign data_conv_ppr0_nxt = 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-0)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-1)*CIW] * flt_weight_ppf4[0*KRNV_SZ + 4] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-1)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-2)*CIW] * flt_weight_ppf4[0*KRNV_SZ + 3] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-2)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-3)*CIW] * flt_weight_ppf4[0*KRNV_SZ + 2] +
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-3)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-4)*CIW] * flt_weight_ppf4[0*KRNV_SZ + 1] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-4)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+0)*KRNV_SZ)-5)*CIW] * flt_weight_ppf4[0*KRNV_SZ + 0] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-0)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-1)*CIW] * flt_weight_ppf4[1*KRNV_SZ + 4] +
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-1)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-2)*CIW] * flt_weight_ppf4[1*KRNV_SZ + 3] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-2)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-3)*CIW] * flt_weight_ppf4[1*KRNV_SZ + 2] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-3)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-4)*CIW] * flt_weight_ppf4[1*KRNV_SZ + 1] +
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-4)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+1)*KRNV_SZ)-5)*CIW] * flt_weight_ppf4[1*KRNV_SZ + 0] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-0)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-1)*CIW] * flt_weight_ppf4[2*KRNV_SZ + 4] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-1)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-2)*CIW] * flt_weight_ppf4[2*KRNV_SZ + 3] +
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-2)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-3)*CIW] * flt_weight_ppf4[2*KRNV_SZ + 2] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-3)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-4)*CIW] * flt_weight_ppf4[2*KRNV_SZ + 1] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-4)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+2)*KRNV_SZ)-5)*CIW] * flt_weight_ppf4[2*KRNV_SZ + 0] +
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-0)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-1)*CIW] * flt_weight_ppf4[3*KRNV_SZ + 4] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-1)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-2)*CIW] * flt_weight_ppf4[3*KRNV_SZ + 3] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-2)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-3)*CIW] * flt_weight_ppf4[3*KRNV_SZ + 2] +
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-3)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-4)*CIW] * flt_weight_ppf4[3*KRNV_SZ + 1] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-4)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+3)*KRNV_SZ)-5)*CIW] * flt_weight_ppf4[3*KRNV_SZ + 0] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-0)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-1)*CIW] * flt_weight_ppf4[4*KRNV_SZ + 4] +
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-1)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-2)*CIW] * flt_weight_ppf4[4*KRNV_SZ + 3] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-2)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-3)*CIW] * flt_weight_ppf4[4*KRNV_SZ + 2] + 
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-3)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-4)*CIW] * flt_weight_ppf4[4*KRNV_SZ + 1] +
       i_data_ppf4[(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-4)*CIW-1:(((-KRNH_SZ_MID+DIFF_DLY+FILTER_DLY+4)*KRNV_SZ)-5)*CIW] * flt_weight_ppf4[4*KRNV_SZ + 0] ;
    end 
endgenerate

assign o_data_nxt = data_conv_ppr0;


always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin 
  i_data_ppf0                <= 0;
  i_data_ppf1               <= 0;
  i_data_ppf2             <= 0;
  i_data_ppf3                <= 0;
  i_data_ppf4               <= 0;
  i_data_ppf5             <= 0;
  data_conv_ppr0          <= 0;
  o_data                  <= 0;

end
else begin 
  i_data_ppf0                <= i_data;
  i_data_ppf1               <= i_data_ppf0;
  i_data_ppf2             <= i_data_ppf1;
  i_data_ppf3                <= i_data_ppf2;
  i_data_ppf4               <= i_data_ppf3;
  i_data_ppf5             <= i_data_ppf4;
  data_conv_ppr0        <= data_conv_ppr0_nxt;
  o_data                  <= o_data_nxt;
end 
end 


always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin 
  for(rst_i=0;rst_i<KERNEL_NUM;rst_i=rst_i+1) begin 
  flt_weight[rst_i]         <= 0;
  flt_weight_q[rst_i]       <= 0;  
  flt_weight_q2[rst_i]      <= 0;
  flt_weight_ppf0[rst_i]    <= 0;  
  flt_weight_ppf1[rst_i]    <= 0;  
  flt_weight_ppf2[rst_i]    <= 0;  
  flt_weight_ppf3[rst_i]    <= 0;  
  flt_weight_ppf4[rst_i]    <= 0;  
  flt_weight_ppf5[rst_i]    <= 0;    
  end

end
else begin
//---------------------------------------------------------------convolution  
  for(rst_i=0;rst_i<KERNEL_NUM;rst_i=rst_i+1) begin 
  flt_weight[rst_i]       <= flt_weight_nxt[rst_i];
  flt_weight_q[rst_i]       <= flt_weight[rst_i];  
  flt_weight_q2[rst_i]      <= flt_weight_q[rst_i];
  flt_weight_ppf0[rst_i]    <= flt_weight[rst_i];  
  flt_weight_ppf1[rst_i]    <= flt_weight_ppf0[rst_i];  
  flt_weight_ppf2[rst_i]    <= flt_weight_ppf1[rst_i]; 
  flt_weight_ppf3[rst_i]    <= flt_weight_ppf2[rst_i]; 
  flt_weight_ppf4[rst_i]    <= flt_weight_ppf3[rst_i]; 
  flt_weight_ppf5[rst_i]    <= flt_weight_ppf4[rst_i];  
  end
end
end
  
endmodule 
