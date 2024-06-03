// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           
// Author:              Willy Lin
// Version:             1.0
// Date:                2022/8/1
// Last Modified On:    
// Last Modified By:    $Author$
//
// File Description:    
//                      
// -FHDR -----------------------------------------------------------------------

module line_buffer

   #( 
      parameter  DUF_DW       = 24,
      parameter  DUF_DEP      = 1920, 
      parameter  KRN_VSZ      = 5,
      parameter  KRN_HSZ      = 5,
      parameter  MEM_TYPE     = "FPGA_BLKRAM"
     )

(
//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//

output     [DUF_DW-1:0]     o_data_0, 
output     [DUF_DW-1:0]     o_data_1, 
output     [DUF_DW-1:0]     o_data_2, 
output     [DUF_DW-1:0]     o_data_3, 
output     [DUF_DW-1:0]     o_data_4, 

output reg                  o_dvld,
output reg                  o_vstr,
output reg                  o_hstr,
output reg                  o_hend,
output reg                  o_vend,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input      [DUF_DW-1:0]     i_data,

input                       i_hstr,
input                       i_href,
input                       i_hend,
input                       i_vstr,
input                       i_vend,

input                       clk,
input                       rst_n
);

//----------------------------------------------//
// Local Parameter                              //   
//----------------------------------------------// 
//-------------------------------------------------------------------
localparam                       LINE_DEP        = $clog2(DUF_DEP);
localparam                       FILTER_WTH      = $clog2(KRN_HSZ);
localparam                       FILTER_DEPTH    = $clog2(KRN_VSZ);
localparam                       FILTER_QUE      = FILTER_WTH - 1;

//-------------------------------------------------------------------gmem
localparam                       MEM_DEP         = DUF_DEP/2;                    // memory depth
localparam                       MEM_DW          = DUF_DW*2;                     // memory data width
                                                                                     
localparam                       DO_FFO          = "FALSE";                      // F.F. data output
//localparam                       DO_XTRA_1T      = "FALSE",                    // Add 1T latency on data output
localparam                       DO_ON_WR        = "TRUE";                       // "FALSE": Don't read data while WR for port-A
                                                                                 // i.e. doa will not change while wea active
localparam                       MEM_AW          = $clog2(MEM_DEP);

//-------------------------------------------------------------------FSM
localparam [6:0]                 BUFFER_IDLE     = 7'b000_0001;
localparam [6:0]                 PADDING_LINE    = 7'b000_0010;
localparam [6:0]                 FR_PADDING      = 7'b000_0100;
localparam [6:0]                 ACTIVE_LINE     = 7'b001_0000;
localparam [6:0]                 BK_PADDING      = 7'b000_1000;
localparam [6:0]                 LINE_BLANK      = 7'b010_0000;
localparam [6:0]                 LAST_LINE       = 7'b101_0000;

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
//-------------------------------------------------------------------control part  
wire                                      vend_keep_nxt;
reg                                       vend_keep;
wire                                      total_we;
wire                                      total_href;
wire                                      fr_padding_en;
wire                                      last_line_flag_nxt;
reg                                       last_line_flag;

//-------------------------------------------------------------------counter  
wire   [LINE_DEP-1:0]                     line_cnt_nxt;
reg    [LINE_DEP-1:0]                     line_cnt;
wire                                      line_cnt_inc;
wire                                      line_cnt_clr;

wire   [LINE_DEP-1:0]                     out_addr_cnt_nxt;
reg    [LINE_DEP-1:0]                     out_addr_cnt;
wire                                      out_addr_cnt_inc;
wire                                      out_addr_cnt_clr;

wire   [LINE_DEP-1:0]                     filter_cnt_nxt;
reg    [LINE_DEP-1:0]                     filter_cnt;
wire                                      filter_cnt_inc;
wire                                      filter_cnt_clr;
wire                                      filter_cnt_set;
wire   [FILTER_DEPTH-1:0]                 filter_cnt_set_val;

//-------------------------------------------------------------------gmem part
wire                                      buf_wea[KRN_VSZ];
wire                                      buf_ena[KRN_VSZ];
wire   [LINE_DEP-1:0]                     buf_addra[KRN_VSZ];
wire   [DUF_DW*2-1:0]                     buf_data[KRN_VSZ];
wire   [DUF_DW-1:0]                       do_buf_data[KRN_VSZ];

wire   [DUF_DW*2-1:0]                     do_buf[KRN_VSZ];
wire                                      do_buf_vld[KRN_VSZ];

//-------------------------------------------------------------------data part 
wire   [FILTER_WTH-2:0]                   padding_hor_num;
wire   [FILTER_DEPTH-2:0]                 padding_ver_num;
wire   [DUF_DW*2-1:0]                     data_stack_nxt;
reg    [DUF_DW*2-1:0]                     data_stack; 
wire   [LINE_DEP-1:0]                     line_blk_nxt;
reg    [LINE_DEP-1:0]                     line_blk;    
wire   [LINE_DEP-1:0]                     line_num_nxt; 
reg    [LINE_DEP-1:0]                     line_num;   
                                     
wire   [FILTER_DEPTH-1:0]                 curr_pad_line_nxt;
reg    [FILTER_DEPTH-1:0]                 curr_pad_line;

wire   [DUF_DW*(2+FILTER_WTH)-1:0]        do_buf_que_nxt[KRN_VSZ];
reg    [DUF_DW*(2+FILTER_WTH)-1:0]        do_buf_que[KRN_VSZ];

wire   [DUF_DW-1:0]                       pad_num_nxt[KRN_VSZ];
reg    [DUF_DW-1:0]                       pad_num[KRN_VSZ];

//-------------------------------------------------------------------output part
wire   [DUF_DW-1:0]                       o_data_nxt[KRN_VSZ];
reg    [DUF_DW-1:0]                       o_data[KRN_VSZ];

wire                                      o_dvld_nxt;    
wire                                      o_vstr_nxt;    
wire                                      o_hstr_nxt;    
wire                                      o_hend_nxt;    
wire                                      o_vend_nxt;    

//-------------------------------------------------------------------FSM 
reg    [6:0]                              line_buffer_cs;
reg    [6:0]                              line_buffer_ns;
wire                                      idle_smo;
wire                                      fr_padding_smo;
wire                                      top_padding_smo;
wire                                      bk_padding_smo;
wire                                      active_smo;
wire                                      line_blank_smo;
wire                                      btm_padding_smo;

//--------------------------------------------------------------------compare part 
wire                                      line_cnt_eq_blk;       
wire                                      line_cnt_eq_num;       
wire                                      line_cnt_eq_blk_s;     
wire                                      line_cnt_eq_hsz_a1;    
wire                                      line_cnt_eq_blk_m1;    
wire                                      line_cnt_eq_0;         
wire                                      line_cnt_eq_1;         

wire                                      out_addr_cnt_eq_num;   
wire                                      out_addr_cnt_eq_ver_m1;
wire                                      out_addr_cnt_eq_hor;   

wire                                      filter_cnt_eq_1;       
wire                                      filter_cnt_eq_0;       
wire                                      filter_cnt_eq_ver_m1; 
wire                                      filter_cnt_eq_hor_m1; 
wire                                      filter_cnt_eq_hor;     
//--------------------------------------------------------------------for loop genvar 
genvar  gmi;
genvar  gpi;
genvar  pad_i;
integer rst_i;
genvar  que_i;
genvar  out_i;

//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//--------------------------------------------------control part
assign vend_keep_nxt       = (vend_keep | i_vend) & !idle_smo;
assign total_we            = (i_href | btm_padding_smo) & line_cnt[0];                       //write enable for gmem
assign total_href          = i_href | active_smo | fr_padding_smo;                           //enable for gmem
assign fr_padding_en       = line_cnt_eq_blk;                                                //for padding fsm
assign last_line_flag_nxt  = ((vend_keep & fr_padding_smo) | last_line_flag) & !idle_smo;    //for the the last line in LAST_LINE status

//--------------------------------------------------counter
assign line_cnt_nxt        = (line_cnt_inc ? line_cnt + 1'b1 : line_cnt) & {(MEM_DEP){~line_cnt_clr}};                    //count for gmem input address 
assign line_cnt_inc        = !idle_smo;
assign line_cnt_clr        = idle_smo | i_hstr | i_hend | (line_blank_smo & fr_padding_en) | line_cnt_eq_num;             //reset in the last of line blank 

assign out_addr_cnt_nxt    = (out_addr_cnt_inc ? out_addr_cnt + 1'b1 : out_addr_cnt) & {(MEM_DEP){~out_addr_cnt_clr}};    //count for gmem output address 
assign out_addr_cnt_inc    = fr_padding_smo | active_smo;
assign out_addr_cnt_clr    = line_blank_smo | out_addr_cnt_eq_num | idle_smo;

assign filter_cnt_nxt      = (filter_cnt_set ? filter_cnt_set_val : filter_cnt_inc ? filter_cnt + 1'b1 : filter_cnt) & {(MEM_DEP){~filter_cnt_clr}};   //count for filter padding 
assign filter_cnt_inc      = fr_padding_smo | bk_padding_smo | (top_padding_smo & i_hstr) | 
                             vend_keep & (line_blank_smo & line_cnt_eq_blk_s);                      //last line   //blank cannot min than 14 
assign filter_cnt_clr      = (top_padding_smo & filter_cnt_eq_ver_m1 & i_hstr ) |                   //first line 
                             (btm_padding_smo & out_addr_cnt_eq_ver_m1)  |                          //last line 
                             (line_blank_smo  & vend_keep & line_cnt_eq_blk) |                      //last line blank
                             ((bk_padding_smo|fr_padding_smo)  & filter_cnt_eq_hor) |               //back padding 
                             idle_smo;
assign filter_cnt_set      = vend_keep & line_cnt_eq_hsz_a1;
assign filter_cnt_set_val  = curr_pad_line;

//--------------------------------------------------compare part
assign line_cnt_eq_blk        = line_cnt == line_blk;
assign line_cnt_eq_num        = line_cnt == line_num;
assign line_cnt_eq_blk_s      = line_cnt == line_blk>>1;
assign line_cnt_eq_hsz_a1     = line_cnt == KRN_HSZ+1;
assign line_cnt_eq_blk_m1     = line_cnt == line_blk-1;
assign line_cnt_eq_0          = line_cnt == 0;
assign line_cnt_eq_1          = line_cnt == 1;

assign out_addr_cnt_eq_num    = out_addr_cnt == line_num;
assign out_addr_cnt_eq_ver_m1 = out_addr_cnt == padding_ver_num-1;
assign out_addr_cnt_eq_hor    = out_addr_cnt == padding_hor_num;

assign filter_cnt_eq_1        = filter_cnt == 1;
assign filter_cnt_eq_0        = filter_cnt == 0;
assign filter_cnt_eq_ver_m1   = filter_cnt == padding_ver_num-1;
assign filter_cnt_eq_hor_m1   = filter_cnt == padding_hor_num-1;
assign filter_cnt_eq_hor      = filter_cnt == padding_hor_num;

assign curr_pad_eq_ver        = curr_pad_line == padding_ver_num;

//--------------------------------------------------gmem part
generate 
  for(gpi=0;gpi<KRN_VSZ;gpi=gpi+1) begin : gen_gmem_ctrl
assign buf_wea[gpi]           = total_we & (!(filter_cnt_eq_1 & top_padding_smo) | (gpi == 0));
assign buf_ena[gpi]           = total_href;
assign buf_addra[gpi]         = total_we ? line_cnt>>1 : out_addr_cnt>>1;
assign buf_data[gpi]          = (gpi == 0) ? data_stack_nxt : (top_padding_smo & filter_cnt_eq_0) ? buf_data[0] : do_buf[gpi-1] ;
assign do_buf_data[gpi]       = out_addr_cnt[0] ? do_buf[gpi][DUF_DW*2-1:DUF_DW] : do_buf[gpi][DUF_DW-1:0];
  end 
endgenerate

//--------------------------------------------------data part 
assign padding_hor_num     = (KRN_HSZ>>1);                                                
assign padding_ver_num     = (KRN_VSZ>>1);                                                
assign data_stack_nxt      = {data_stack[DUF_DW-1:0],i_data};                                  //stack data for gmem 
assign line_blk_nxt        = (i_hstr & top_padding_smo) ? line_cnt : line_blk;                 //already -1   //blank number 
assign line_num_nxt        = (i_hend & top_padding_smo) ? line_cnt : line_num;                 //already -1   //line number 

generate
  for(que_i=0;que_i<KRN_VSZ;que_i=que_i+1) begin : gen_buf_que
assign do_buf_que_nxt[que_i] = (que_i == 0) ? {do_buf_que[que_i][DUF_DW*(FILTER_QUE)-1:0],i_data} : 
                                              {do_buf_que[que_i][DUF_DW*(FILTER_QUE)-1:0],do_buf_data[que_i-1]};
  end  
endgenerate

assign curr_pad_line_nxt   = ((vend_keep & line_blank_smo & line_cnt_eq_blk_m1) ? filter_cnt : curr_pad_line) & {FILTER_DEPTH{(!o_vend)}};

generate 
  for (pad_i=0;pad_i<KRN_VSZ;pad_i=pad_i+1) begin : gen_pad_num
assign pad_num_nxt[pad_i] = (pad_i == KRN_VSZ-1) ? ((fr_padding_smo & line_cnt_eq_0) | (active_smo & line_cnt_eq_num) ? i_data : pad_num[pad_i]):
                                                   ( fr_padding_smo & line_cnt_eq_1) | (active_smo & line_cnt_eq_0)   ? do_buf_data[KRN_VSZ-pad_i-2] : pad_num[pad_i];
end 
endgenerate

//--------------------------------------------------output part

generate
  for(out_i=0;out_i<KRN_VSZ;out_i=out_i+1) begin : gen_o_data_2_d_array
    assign o_data_nxt[out_i]  = (last_line_flag & curr_pad_eq_ver & (out_i==3)) ? o_data_nxt[2] :                                      //last line //only use in KRN_VSZ == 5
                                (last_line_flag & (out_i==KRN_VSZ-1))                                      ? o_data_nxt[KRN_VSZ-2] :   //last line 
                                (fr_padding_smo|bk_padding_smo) ? pad_num_nxt[out_i] : do_buf_que[KRN_VSZ-out_i-1][DUF_DW*((FILTER_QUE+(out_i==KRN_VSZ-1)))-1:DUF_DW*((FILTER_QUE+(out_i==KRN_VSZ-1))-1)];
  end 
endgenerate 

assign o_data_0            = o_data[0];
assign o_data_1            = o_data[1];
assign o_data_2            = o_data[2];
assign o_data_3            = o_data[3];
assign o_data_4            = o_data[4];
assign o_dvld_nxt          = ((active_smo | bk_padding_smo) & !o_hend) | (fr_padding_smo & (!o_hstr_nxt)); 
assign o_vstr_nxt          = i_hstr & top_padding_smo & filter_cnt_eq_ver_m1;      
assign o_hstr_nxt          = fr_padding_smo & filter_cnt_eq_0;
assign o_hend_nxt          = bk_padding_smo & filter_cnt_eq_hor_m1;
assign o_vend_nxt          = o_hend_nxt & curr_pad_eq_ver;

//--------------------------------------------------FSM 
assign idle_smo            = line_buffer_cs[0];
assign top_padding_smo     = line_buffer_cs[1];
assign fr_padding_smo      = line_buffer_cs[2];
assign bk_padding_smo      = line_buffer_cs[3];
assign active_smo          = line_buffer_cs[4];
assign line_blank_smo      = line_buffer_cs[5];
assign btm_padding_smo     = line_buffer_cs[6];

always@* begin : buffer_fsm

  line_buffer_ns = line_buffer_cs;
  
  case (line_buffer_cs)
  
  BUFFER_IDLE   :  begin 
                     if(i_hstr)
                       line_buffer_ns = PADDING_LINE;
                   end

  PADDING_LINE  :  begin 
                     if(i_hstr & filter_cnt_eq_ver_m1)
                       line_buffer_ns = FR_PADDING;
                   end 

  FR_PADDING    :  begin 
                     if(filter_cnt_clr & vend_keep)
                       line_buffer_ns = LAST_LINE;
                     else
                       if(filter_cnt_clr)
                         line_buffer_ns = ACTIVE_LINE;
                   end 
                   
  ACTIVE_LINE   :  begin 
                     if(out_addr_cnt_eq_hor)
                       line_buffer_ns = BK_PADDING;
                   end 

  BK_PADDING    :  begin 
                     if(filter_cnt_clr & curr_pad_eq_ver)
                       line_buffer_ns = BUFFER_IDLE;
                     else
                       if(filter_cnt_clr)
                         line_buffer_ns = LINE_BLANK;                     
                   end   

  LINE_BLANK    :  begin 
                     if(fr_padding_en)
                       line_buffer_ns = FR_PADDING;
                   end 

  LAST_LINE     :  begin 
                     if(out_addr_cnt_eq_hor)
                       line_buffer_ns = BK_PADDING;
                   end 

  endcase
end


//----------------------------------------------//
// Module Instance                              //
//----------------------------------------------//
generate
  for(gmi=0;gmi<KRN_VSZ;gmi=gmi+1) begin : gen_rst 
//--------------------------------------------------gmem part

ip_gmem 
         #(
         .MEM_DEP           (MEM_DEP),    
         .MEM_DW            (MEM_DW),      
         .MEM_TYPE          (MEM_TYPE),           
         .MEM_NAME          (),    
         .DO_FFO            (DO_FFO),      
         .DO_XTRA_1T        (),
         .DO_ON_WR          (DO_ON_WR),    
         .MEM_AW            (LINE_DEP)     
         ) 
f_buf    
(
         .doa               (do_buf[gmi]),                
         .dob               (),                
         .doa_vld           (do_buf_vld[gmi]),
         .dob_vld           (),

         .mbist_done        (),
         .mbist_err         (),

         .wea               (buf_wea[gmi]),                
         .ena               (buf_ena[gmi]),                
         .enb               (1'b0),                
         .clr               (1'b0),                
         .addra             (buf_addra[gmi]),              
         .addrb             (0),              
         .dia               (buf_data[gmi]),                
         .mopt              (8'b0),               
         .mbist_en          (1'b0),           

         .clka              (clk),               
         .clkb              (clk),               
         .arst_n            (rst_n),             
         .brst_n            (rst_n)
);
end 
endgenerate

always@(posedge clk or negedge rst_n) begin 
if(!rst_n) begin 
//--------------------------------------------------counter 
  line_cnt         <= 0;
  out_addr_cnt     <= 0;
  filter_cnt       <= 0;
  data_stack       <= 0;
  line_blk         <= 0;
  line_num         <= DUF_DEP;

//--------------------------------------------------control part 
  vend_keep        <= 0;
  last_line_flag   <= 0;

//--------------------------------------------------data part 
  curr_pad_line    <= 0;

//--------------------------------------------------output part
  o_dvld           <= 0;
  o_vstr           <= 0;
  o_hstr           <= 0;
  o_hend           <= 0;
  o_vend           <= 0;
 
end
else begin 
//--------------------------------------------------counter 
  line_cnt         <= line_cnt_nxt    ;
  out_addr_cnt     <= out_addr_cnt_nxt;
  filter_cnt       <= filter_cnt_nxt  ;
  data_stack       <= data_stack_nxt  ;  
  line_blk         <= line_blk_nxt    ;  
  line_num         <= line_num_nxt    ;    

//--------------------------------------------------control part  
  vend_keep        <= vend_keep_nxt   ;
  last_line_flag   <= last_line_flag_nxt;

//--------------------------------------------------data part 
  curr_pad_line    <= curr_pad_line_nxt;

//--------------------------------------------------output part
  o_dvld           <= o_dvld_nxt      ;
  o_vstr           <= o_vstr_nxt      ;
  o_hstr           <= o_hstr_nxt      ;
  o_hend           <= o_hend_nxt      ;
  o_vend           <= o_vend_nxt      ;

end 
end 

always@(posedge clk or negedge rst_n) begin 
if(!rst_n) begin 
for (rst_i=0;rst_i<KRN_VSZ;rst_i=rst_i+1) begin  : rst
//--------------------------------------------------data part 
  pad_num[rst_i]      <= 0;
  do_buf_que[rst_i]   <= 0;
//--------------------------------------------------output part
  o_data[rst_i]       <= 0;
end 
end
else begin 
for (rst_i=0;rst_i<KRN_VSZ;rst_i=rst_i+1) begin 
//--------------------------------------------------data part 
  pad_num[rst_i]      <= pad_num_nxt[rst_i];
  do_buf_que[rst_i]   <= do_buf_que_nxt[rst_i];
//--------------------------------------------------output part
  o_data[rst_i]       <= o_data_nxt[rst_i];
end
end 
end 

always@(posedge clk or negedge rst_n) begin 
if(!rst_n) begin 
  line_buffer_cs   <= BUFFER_IDLE;
end
else begin 
  line_buffer_cs   <= line_buffer_ns;

end 
end 


endmodule 
