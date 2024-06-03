// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           border_rtl.v
// Author:              Willy Lin
// Version:             1.0
// Date:                2022/2/8
// Last Modified On:    
// Last Modified By:    $Author$
//
// File Description:    draw the border of face detect 
//                      
// -FHDR -----------------------------------------------------------------------

module border

   #( 
      parameter  BORDER_COR_WIDTH  = 12,
      parameter  BORDER_DATA_WIDTH = 8
     )

(
//----------------------------------------------//
// Local Parameter                              //
//----------------------------------------------//


//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
 
output reg                                                       o_hstr,
output reg                                                       o_hend,
output reg                                                       o_vstr,
output reg                                                       o_vend,
output reg                                                       o_dvld,
output     [BORDER_DATA_WIDTH-1:0]                               o_data_y,
output     [BORDER_DATA_WIDTH-1:0]                               o_data_cb,
output     [BORDER_DATA_WIDTH-1:0]                               o_data_cr,
output reg                                                       o_finish_tgl,

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//

input                                                            i_vstr, 
input                                                            i_vend, 
input                                                            i_hstr, 
input                                                            i_hend, 
input                                                            i_dvld, 
input                                                            i_fstr,
input                                                            i_fend,
input      [BORDER_DATA_WIDTH-1:0]                               i_data_y,
input      [BORDER_DATA_WIDTH-1:0]                               i_data_cb,
input      [BORDER_DATA_WIDTH-1:0]                               i_data_cr,

input                                                            r_border_trg,
input      [4:0]                                                 r_border_en,
input                                                            r_border_type,
input      [BORDER_DATA_WIDTH-1:0]                               r_border_y,
input      [BORDER_DATA_WIDTH-1:0]                               r_border_cb,
input      [BORDER_DATA_WIDTH-1:0]                               r_border_cr,
input      [4:0]                                                 r_border_width,
input      [1:0]                                                 r_trn_rate,

input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_0_1st,
input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_0_2nd, 
input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_1_1st,
input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_1_2nd, 
input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_2_1st,
input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_2_2nd, 
input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_3_1st,
input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_3_2nd,           
input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_4_1st,
input      [BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1:0]           r_coord_4_2nd, 

input      [11:0]                                                r_dest_hwin,
input      [11:0]                                                r_dest_vwin,
                                                                   
input                                                            border_clk,             
input                                                            border_rst_n          


);

//----------------------------------------------//
// Register & Wire declaration                  //
//----------------------------------------------//
genvar                                 pad_ix,d_ix,i,k,i2,k2;
integer                                q,i_rst,i_rst2;
//-----------------------------------------------------counter 
reg         [BORDER_COR_WIDTH-1:0]     hor_cnt;               
wire        [BORDER_COR_WIDTH-1:0]     hor_cnt_nxt;  
wire                                   hor_cnt_int;
wire                                   hor_cnt_clr; 

reg         [BORDER_COR_WIDTH-1:0]     ver_cnt;               
wire        [BORDER_COR_WIDTH-1:0]     ver_cnt_nxt;            
wire                                   ver_cnt_int;
wire                                   ver_cnt_clr; 

reg         [2:0]                      ctrl_cnt;               
wire        [2:0]                      ctrl_cnt_nxt;            
wire                                   ctrl_cnt_int;
wire                                   ctrl_cnt_clr; 

reg         [1:0]                      data_cnt;               
wire        [1:0]                      data_cnt_nxt;            
wire                                   data_cnt_int;
wire                                   data_cnt_clr;


//--------------------------------------------------------------------------------------coordinate control (control float)
reg                                    i_fstr_dly;
wire                                   h_keep_nxt;
reg                                    h_keep;
wire        [BORDER_COR_WIDTH-1:0]     ri_coord_orig              [0:19] ;
wire        [BORDER_COR_WIDTH-1:0]     border_compare;
wire                                   coord_ctrl_0;
wire                                   coord_ctrl_1;
wire                                   coord_ctrl;
wire                                   coord_blank_ctrl;
wire        [5:0]                      border_width;
wire        [BORDER_COR_WIDTH-1:0]     coord_blank_len;
wire        [5:0]                      coord_border_ctrl;
reg                                    sub_en;
wire                                   coord_sel_1_nxt;
wire                                   coord_sel_2_nxt;
wire                                   coord_sel_3_nxt;
wire                                   coord_sel_4_nxt;
wire                                   coord_sel_5_nxt;
reg                                    coord_sel_1;
reg                                    coord_sel_2;
reg                                    coord_sel_3;
reg                                    coord_sel_4;
reg                                    coord_sel_5;
//--------------------------------------------------------------------------------------coordinate produce (data float)
reg  signed [BORDER_COR_WIDTH:0]       add_port_0_sgn;
reg  signed [BORDER_COR_WIDTH:0]       add_port_1_sgn;
wire        [BORDER_COR_WIDTH-1:0]     coord_temp_nxt;
reg         [BORDER_COR_WIDTH-1:0]     coord_temp; 
reg         [BORDER_COR_WIDTH-1:0]     ri_coord_blank_compare     [0:19] ;
reg         [BORDER_COR_WIDTH-1:0]     ri_coord_2nd_compare       [0:19] ;
reg         [BORDER_COR_WIDTH-1:0]     ri_coord_orig_adj          [0:19] ;
reg         [BORDER_COR_WIDTH-1:0]     ri_coord_border            [0:19] ;
reg         [BORDER_COR_WIDTH-1:0]     ri_coord_blank             [0:19] ;
wire        [4:0]                      coord_sel_nxt;
wire        [4:0]                      coord_sel;
reg                                    coord_sel_en               [0:99] ;
wire                                   coord_sel_en_nxt           [0:99] ;
//--------------------------------------------------------------------------------------enable region 
wire        [4:0]                      coord_x_en_nxt; 
reg         [4:0]                      coord_x_en;
wire        [4:0]                      coord_y_en_nxt; 
reg         [4:0]                      coord_y_en; 
wire        [4:0]                      coord_x_pad_en_nxt; 
reg         [4:0]                      coord_x_pad_en; 
wire        [4:0]                      coord_y_pad_en_nxt; 
reg         [4:0]                      coord_y_pad_en; 
wire        [4:0]                      coord_comb_en; 
wire        [4:0]                      coord_pad_comb_en ; 
wire        [4:0]                      coord_total_en;
reg         [4:0]                      coord_x_blank_en; 
wire        [4:0]                      coord_x_blank_en_nxt; 
reg         [4:0]                      coord_y_blank_en; 
wire        [4:0]                      coord_y_blank_en_nxt; 

//--------------------------------------------------------------------------------------color part
wire        [7:0]                      ri_orig_in_data            [0:5] ;
wire        [7:0]                      ri_trans_data              [0:5] ;
wire        [7:0]                      ri_shift_data              [0:2] ;
wire        [7:0]                      border_data_cb_nxt;
wire        [7:0]                      border_data_cr_nxt;
wire        [7:0]                      border_data_y_nxt;
reg         [7:0]                      border_data_cb;
reg         [7:0]                      border_data_cr;
reg         [7:0]                      border_data_y;
reg         [BORDER_DATA_WIDTH-1:0]    r_border_y_keep;
reg         [BORDER_DATA_WIDTH-1:0]    r_border_cb_keep;
reg         [BORDER_DATA_WIDTH-1:0]    r_border_cr_keep;
wire        [BORDER_DATA_WIDTH-1:0]    r_border_y_keep_nxt;
wire        [BORDER_DATA_WIDTH-1:0]    r_border_cb_keep_nxt;
wire        [BORDER_DATA_WIDTH-1:0]    r_border_cr_keep_nxt;
//-----------------------------------------------------------------------------------------others
reg         [BORDER_COR_WIDTH-1:0]     hor_cnt_dly;
wire                                   finish_pulse;
reg                                    border_trg_keep;
wire                                   border_trg_keep_nxt;

//-----------------------------------------------------------------------------------------output
wire                                   o_finish_tgl_nxt;
//----------------------------------------------//
// Code Descriptions                            //
//----------------------------------------------//
//---------------------------------------------------------------------counter 
assign hor_cnt_nxt         = (hor_cnt_int ? hor_cnt + 1'b1 : hor_cnt) & {(BORDER_COR_WIDTH){~hor_cnt_clr}};   
assign hor_cnt_int         = i_dvld | ((ctrl_cnt != 3'h0) & (data_cnt==2'h3));
assign hor_cnt_clr         = i_hend | ctrl_cnt_int;

assign ver_cnt_nxt         = (ver_cnt_int ? ver_cnt + 1'b1 : ver_cnt) & {(BORDER_COR_WIDTH){~ver_cnt_clr}};
assign ver_cnt_int         = i_hend | (((ctrl_cnt_nxt == 3'h1) | ((ctrl_cnt != 3'h0) &    //frist x
                             ((hor_cnt == {{(BORDER_COR_WIDTH-3){1'b0}},3'h4})  |       //first y
                             (hor_cnt == {{(BORDER_COR_WIDTH-4){1'b0}},4'h9})   |       //second x
                             (hor_cnt == {{(BORDER_COR_WIDTH-4){1'b0}},4'he})))) &       //second y
                             (data_cnt==2'h3));
assign ver_cnt_clr         = i_fend | ctrl_cnt_int | 
                             (((ver_cnt == {{(BORDER_COR_WIDTH-4){1'b0}},4'h9}) & (ctrl_cnt == 3'h1)) & (data_cnt==2'h3));     //only occur in ctrl 1
                                                                 
assign ctrl_cnt_nxt        = (ctrl_cnt_int ? ctrl_cnt + 1'b1 : ctrl_cnt) & {(BORDER_COR_WIDTH){~ctrl_cnt_clr}};                                   
assign ctrl_cnt_int        = (i_fstr_dly & border_trg_keep) | (!h_keep & hor_cnt == ({{(BORDER_COR_WIDTH-5){1'b0}},5'h13}) & (data_cnt==2'h3));
assign ctrl_cnt_clr        = i_fend | h_keep;

//-----------------------------------// ctrl_cnt mode 
//0:start draw the border 
//1:ri_coord_blank_compare
//2:ri_coord_2nd_compare 
//3:origin_coordinate 
//4:border_coordinate 
//5:blank_coordinate
//-----------------------------------//

assign data_cnt_nxt        = (data_cnt_int ? data_cnt + 1'b1 : data_cnt) & {(BORDER_COR_WIDTH){~data_cnt_clr}};                              
assign data_cnt_int        = (ctrl_cnt != 3'h0);
assign data_cnt_clr        = i_fend | h_keep;

//---------------------------------------------------------------------coordinate original 
assign ri_coord_orig [0]   = r_coord_0_1st[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH];
assign ri_coord_orig [1]   = r_coord_1_1st[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH];
assign ri_coord_orig [2]   = r_coord_2_1st[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH];
assign ri_coord_orig [3]   = r_coord_3_1st[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH];
assign ri_coord_orig [4]   = r_coord_4_1st[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH]; //-------------------------first x 
assign ri_coord_orig [5]   = r_coord_0_1st[BORDER_COR_WIDTH - 1 : 0];
assign ri_coord_orig [6]   = r_coord_1_1st[BORDER_COR_WIDTH - 1 : 0];
assign ri_coord_orig [7]   = r_coord_2_1st[BORDER_COR_WIDTH - 1 : 0];
assign ri_coord_orig [8]   = r_coord_3_1st[BORDER_COR_WIDTH - 1 : 0];
assign ri_coord_orig [9]   = r_coord_4_1st[BORDER_COR_WIDTH - 1 : 0];                                   //-------------------------first y 

assign ri_coord_orig [10]  = r_coord_0_2nd[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH];
assign ri_coord_orig [11]  = r_coord_1_2nd[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH];
assign ri_coord_orig [12]  = r_coord_2_2nd[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH];
assign ri_coord_orig [13]  = r_coord_3_2nd[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH];
assign ri_coord_orig [14]  = r_coord_4_2nd[BORDER_COR_WIDTH + BORDER_COR_WIDTH - 1 : BORDER_COR_WIDTH]; //--------------------------second x 
assign ri_coord_orig [15]  = r_coord_0_2nd[BORDER_COR_WIDTH - 1 : 0];
assign ri_coord_orig [16]  = r_coord_1_2nd[BORDER_COR_WIDTH - 1 : 0];
assign ri_coord_orig [17]  = r_coord_2_2nd[BORDER_COR_WIDTH - 1 : 0];
assign ri_coord_orig [18]  = r_coord_3_2nd[BORDER_COR_WIDTH - 1 : 0];
assign ri_coord_orig [19]  = r_coord_4_2nd[BORDER_COR_WIDTH - 1 : 0];                                 //--------------------------second y 

//-------------------------------------------------------------------------coordinate control            
assign h_keep_nxt            = (i_hstr | h_keep) & !i_hend;
assign border_compare        = (ver_cnt[0] == 1'h0) ? r_dest_hwin-1 : r_dest_vwin-1;                    //swift coordinate limit between x and y
assign coord_ctrl_0          = (ctrl_cnt != 3'h0) & (r_border_width <= ri_coord_orig[hor_cnt]);       //first point condition 
assign coord_ctrl_1          = (ctrl_cnt != 3'h0) & (ri_coord_2nd_compare[hor_cnt]) >= border_compare;  //second point condition 
assign coord_ctrl            = ver_cnt[1] ? coord_ctrl_1 : coord_ctrl_0;                                //border coordinate  , control bit of positive or negedge (coord_border_sgn)
assign coord_border_ctrl     =(ctrl_cnt == 3'h3) ? ({5{(!(coord_ctrl_0) | coord_ctrl_1)}}) : 
                                                   ({5{(coord_ctrl_0  & !(coord_ctrl_1))}});
assign border_width          = r_border_width & coord_border_ctrl ;
assign coord_blank_ctrl      = ver_cnt[1];                                                              //swift first coordinate or second ,control positive or negedge (coord_blank_sgn)
assign coord_blank_len       = ri_coord_blank_compare[hor_cnt];  
assign coord_sel_1_nxt       = (ctrl_cnt == 3'h1)& (data_cnt_nxt == 2'h3);
assign coord_sel_2_nxt       = (ctrl_cnt == 3'h2)& (data_cnt_nxt == 2'h3);
assign coord_sel_3_nxt       = (ctrl_cnt == 3'h3)& (data_cnt_nxt == 2'h3);
assign coord_sel_4_nxt       = (ctrl_cnt == 3'h4)& (data_cnt_nxt == 2'h3);
assign coord_sel_5_nxt       = (ctrl_cnt == 3'h5)& (data_cnt_nxt == 2'h3);

//-------------------------------------------------------------------------others
assign finish_pulse          = (ctrl_cnt==3'h7);
assign border_trg_keep_nxt   = (border_trg_keep | r_border_trg) & !(finish_pulse);

//-------------------------------------------------------------------------output 
assign o_finish_tgl_nxt      = o_finish_tgl ^ (finish_pulse & border_trg_keep); 


//-------------------------------------------------------------------------coordinate generate 
always@* begin 
  sub_en = 0;  //sub_en 
  case (ctrl_cnt)  //synopsys full_case
    3'h1 : sub_en = 1'b1;
    3'h2 : sub_en = 1'b0;
    3'h3 : sub_en = coord_ctrl;
    3'h4 : sub_en = coord_ctrl;
    3'h5 : sub_en = coord_blank_ctrl;
  endcase
end 

always@* begin 
  add_port_0_sgn = 0;  //add_port 0 
  case (ctrl_cnt)  //synopsys full_case
    3'h1 : add_port_0_sgn = $signed({1'b0,(ri_coord_orig[ver_cnt+10]>>> 2)});
    3'h2 : add_port_0_sgn = $signed({1'b0,ri_coord_orig[hor_cnt]});
    3'h3 : add_port_0_sgn = $signed({1'b0,ri_coord_orig[hor_cnt]});
    3'h4 : add_port_0_sgn = $signed({1'b0,ri_coord_orig[hor_cnt]});
    3'h5 : add_port_0_sgn = $signed({1'b0,ri_coord_orig_adj[hor_cnt]});
  endcase
end 

always@* begin  
  add_port_1_sgn = 0;  //add_port 1
  case (ctrl_cnt) //synopsys full_case
    3'h1 : add_port_1_sgn = $signed({1'b0,(ri_coord_orig[ver_cnt]>>>2)});
    3'h2 : add_port_1_sgn = $signed({1'b0,r_border_width});
    3'h3 : add_port_1_sgn = $signed({1'b0,border_width});
    3'h4 : add_port_1_sgn = $signed({1'b0,border_width});
    3'h5 : add_port_1_sgn = $signed({1'b0,coord_blank_len});
  endcase
end 

assign coord_temp_nxt     = $unsigned(add_port_0_sgn + $signed({sub_en,1'b1}) * add_port_1_sgn);

//---------------------------------------------------------------------------latch

assign coord_sel = {coord_sel_5,coord_sel_4,coord_sel_3,coord_sel_2,coord_sel_1};

generate 
  for(k=0;k<5;k=k+1) begin 
    for (i=0;i<20;i=i+1) begin 
      assign coord_sel_en_nxt[20*k + i] = (coord_sel[k] & (hor_cnt_dly == i)) | !border_rst_n;
    end
  end 

endgenerate 

always@* begin 
  for (q=0;q<20;q=q+1) begin 
    if (coord_sel_en[q])
      ri_coord_blank_compare[q] <= coord_temp;

    if (coord_sel_en[q+20])
      ri_coord_2nd_compare[q]   <= coord_temp;

    if (coord_sel_en[q+40])
      ri_coord_orig_adj[q]      <= coord_temp;

    if (coord_sel_en[q+60])
      ri_coord_border[q]        <= coord_temp;

    if (coord_sel_en[q+80])
      ri_coord_blank[q]         <= coord_temp;
  end
end    




generate  
  for (pad_ix=0 ; pad_ix <= 4 ; pad_ix = pad_ix + 1 ) begin : coord_enable //-------------------------------------------------------------------enable region 

    assign coord_x_en_nxt[pad_ix]         = (((ri_coord_orig_adj [pad_ix] == hor_cnt) & h_keep) | coord_x_en[pad_ix]) & 
                                            !(ri_coord_orig_adj [pad_ix+10] ==(hor_cnt));                                             //origin coordinate region (x)
    assign coord_y_en_nxt[pad_ix]         = (((ri_coord_orig_adj [pad_ix+5] == ver_cnt) & h_keep) | coord_y_en[pad_ix]) & 
                                            !(ri_coord_orig_adj [pad_ix+15] ==(ver_cnt));                                             //origin coordinate region (y)
    assign coord_x_pad_en_nxt[pad_ix]     = (((ri_coord_border [pad_ix] == hor_cnt) & h_keep) | coord_x_pad_en[pad_ix]) & 
                                            !(ri_coord_border [pad_ix+10] ==(hor_cnt));                                               //padding coordinate region (x)
    assign coord_y_pad_en_nxt[pad_ix]     = (((ri_coord_border [pad_ix+5] == ver_cnt) & h_keep) | coord_y_pad_en[pad_ix]) & 
                                            !(ri_coord_border [pad_ix+15] ==(ver_cnt));                                               //padding coordinate region (y)

    assign coord_x_blank_en_nxt[pad_ix]   = ((ri_coord_blank[pad_ix] == hor_cnt)   | (coord_x_blank_en[pad_ix])) & !(ri_coord_blank[pad_ix+10] == hor_cnt); 
    assign coord_y_blank_en_nxt[pad_ix]   = ((ri_coord_blank[pad_ix+5] == ver_cnt) | (coord_y_blank_en[pad_ix])) & !(ri_coord_blank[pad_ix+15] == ver_cnt);
    assign coord_comb_en[pad_ix]          = coord_x_en_nxt[pad_ix] & coord_y_en_nxt[pad_ix] &                                   //origin region 
                                            !((coord_x_blank_en_nxt[pad_ix] | coord_y_blank_en_nxt[pad_ix]) & r_border_type);   //blank control 
    assign coord_pad_comb_en[pad_ix]      = (coord_x_pad_en_nxt[pad_ix] & coord_y_pad_en_nxt[pad_ix] &                          //padding region 
                                            !((coord_x_blank_en_nxt[pad_ix] | coord_y_blank_en_nxt[pad_ix]) & r_border_type))   //blank control 
                                            & r_border_en[pad_ix] & h_keep;                                                     //each border have independent enable
    assign coord_total_en[pad_ix]         = (coord_pad_comb_en[pad_ix] & !coord_comb_en[pad_ix]);
    always@(posedge border_clk or negedge border_rst_n) begin 
    if(!border_rst_n) begin 
      coord_x_pad_en[pad_ix]  <= 0;
      coord_y_pad_en[pad_ix]  <= 0;
      coord_x_en[pad_ix]      <= 0; 
      coord_y_en[pad_ix]      <= 0;
      coord_x_blank_en[pad_ix]<= 0;
      coord_y_blank_en[pad_ix]<= 0;
    end
    else begin 
      coord_x_pad_en[pad_ix]  <= coord_x_pad_en_nxt[pad_ix];
      coord_y_pad_en[pad_ix]  <= coord_y_pad_en_nxt[pad_ix];
      coord_x_en[pad_ix]      <= coord_x_en_nxt[pad_ix];
      coord_y_en[pad_ix]      <= coord_y_en_nxt[pad_ix];
      coord_x_blank_en[pad_ix]<= coord_x_blank_en_nxt[pad_ix];
      coord_y_blank_en[pad_ix]<= coord_y_blank_en_nxt[pad_ix];
    end 
    end 

  end
endgenerate



//---------------------------------------------------------------------color part
assign r_border_y_keep_nxt            = (ctrl_cnt==3'h1) ? r_border_y  : r_border_y_keep;
assign r_border_cb_keep_nxt           = (ctrl_cnt==3'h1) ? r_border_cb : r_border_cb_keep;
assign r_border_cr_keep_nxt           = (ctrl_cnt==3'h1) ? r_border_cr : r_border_cr_keep;

assign ri_orig_in_data[0]             = i_data_y;
assign ri_orig_in_data[1]             = i_data_cb;
assign ri_orig_in_data[2]             = i_data_cr;
assign ri_orig_in_data[3]             = r_border_y_keep;
assign ri_orig_in_data[4]             = r_border_cb_keep;
assign ri_orig_in_data[5]             = r_border_cr_keep;

generate  //control the transparency of border 
  for (d_ix=0;d_ix<=2;d_ix=d_ix+1) begin 
    assign ri_shift_data[d_ix]        = (ri_orig_in_data[d_ix] >> 2);
    assign ri_trans_data[d_ix]        = (|coord_total_en)?
                                        ((r_trn_rate == 2'h0) ? 8'h00 :                                                                  //0%
                                        (({BORDER_DATA_WIDTH   {r_trn_rate[0]}} & (ri_orig_in_data[d_ix] >> 1)) +                        //50%
                                        ( {BORDER_DATA_WIDTH   {r_trn_rate[1]}} & ri_shift_data[d_ix]))) :                               //25%
                                        ri_orig_in_data[d_ix];                                                                           //100%

    assign ri_trans_data[d_ix+3]      = (|coord_total_en)?
                                        ((r_trn_rate == 2'h0) ? ri_orig_in_data[d_ix+3] :                                                //100%
                                        (({BORDER_DATA_WIDTH   {r_trn_rate[1]}}                 & (ri_orig_in_data[d_ix+3] >> 2)) +      //25%
                                        ( {BORDER_DATA_WIDTH   {(r_trn_rate[0]^r_trn_rate[1])}} & (ri_orig_in_data[d_ix+3] >> 1)))):     //50%
                                        8'h00;                                                                                           //0%

  end
endgenerate

assign {border_data_cb_nxt,
        border_data_cr_nxt,
        border_data_y_nxt}            = {(ri_trans_data[1]+ri_trans_data[4]),(ri_trans_data[2]+ri_trans_data[5]),(ri_trans_data[0]+ri_trans_data[3])};


//---------------------------------------------------------------------output 
assign o_data_y                       = border_data_y;
assign o_data_cb                      = border_data_cb;
assign o_data_cr                      = border_data_cr;

//-------------------------------------------------------------------combination 

always@(posedge border_clk or negedge border_rst_n) begin 
if(!border_rst_n) begin 
//---------------------------------------------------counter 
  hor_cnt                        <= 0;
  ver_cnt                        <= 0;
  ctrl_cnt                       <= 0;
  data_cnt                       <= 0;

//---------------------------------------------------control 
  i_fstr_dly                     <= 0;
  h_keep                         <= 0;
  coord_sel_1                    <= 0;
  coord_sel_2                    <= 0;
  coord_sel_3                    <= 0;
  coord_sel_4                    <= 0;
  coord_sel_5                    <= 0;
//---------------------------------------------------color 
  r_border_y_keep                <= 0;
  r_border_cb_keep               <= 0;
  r_border_cr_keep               <= 0;
//---------------------------------------------------output
  i_fstr_dly                     <= 0;
  o_hstr                         <= 0;
  o_hend                         <= 0;
  o_vstr                         <= 0;
  o_vend                         <= 0;
  o_dvld                         <= 0;
  border_data_y                  <= 0;
  border_data_cb                 <= 0;
  border_data_cr                 <= 0;
  o_finish_tgl                   <= 0;
//----------------------------------------------------others 
  hor_cnt_dly                    <= 0;
  border_trg_keep                <= 0;
//----------------------------------------------------coordinate produce (data float)
  coord_temp                     <= 0;
end
else begin 
//---------------------------------------------------counter 
  hor_cnt                        <= hor_cnt_nxt;
  ver_cnt                        <= ver_cnt_nxt;
  ctrl_cnt                       <= ctrl_cnt_nxt;
  data_cnt                       <= data_cnt_nxt;

//---------------------------------------------------control 
  h_keep                         <= h_keep_nxt;
  coord_sel_1                    <= coord_sel_1_nxt;
  coord_sel_2                    <= coord_sel_2_nxt;
  coord_sel_3                    <= coord_sel_3_nxt;
  coord_sel_4                    <= coord_sel_4_nxt;
  coord_sel_5                    <= coord_sel_5_nxt;
//---------------------------------------------------color 
  r_border_y_keep                <= r_border_y_keep_nxt;
  r_border_cb_keep               <= r_border_cb_keep_nxt;
  r_border_cr_keep               <= r_border_cr_keep_nxt;
//---------------------------------------------------output
  i_fstr_dly                     <= i_fstr;
  o_hstr                         <= i_hstr;
  o_hend                         <= i_hend;
  o_vstr                         <= i_vstr;
  o_vend                         <= i_vend;
  o_dvld                         <= i_dvld;
  border_data_y                  <= border_data_y_nxt;
  border_data_cb                 <= border_data_cb_nxt;
  border_data_cr                 <= border_data_cr_nxt;
  o_finish_tgl                   <= o_finish_tgl_nxt;
//----------------------------------------------------others
  hor_cnt_dly                    <= hor_cnt;
  border_trg_keep                <= border_trg_keep_nxt;
//----------------------------------------------------coordinate produce (data float)
  coord_temp                     <= coord_temp_nxt;

end 
end 

always@(posedge border_clk or negedge border_rst_n) begin 
if(!border_rst_n) begin 
//----------------------------------------------------coordinate produce (data float)
  for (i_rst=0;i_rst<=99;i_rst=i_rst+1) begin 
    coord_sel_en[i_rst]          <= 1;
  end 

end
else begin 
//----------------------------------------------------coordinate produce (data float)
  for (i_rst=0;i_rst<=99;i_rst=i_rst+1) begin 
    coord_sel_en[i_rst]          <= coord_sel_en_nxt[i_rst];
  end 
end
end



endmodule 
