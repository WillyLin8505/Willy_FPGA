// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2021                                   
// File Name: soisp_p10_reg_rtl.v                                               
// Author: REGISTER Generator                                                   
// Release History: 2021-12-02 Initial version                                  
// File Description: SOISP_P10 Register File                                    
// -FHDR -----------------------------------------------------------------------
module soisp_p10_reg(
	//output
	r_i2cm_addr_0,
	r_i2cm_addr_1,
	r_i2cm_dev_id_0,
	r_i2cm_dev_id_1,
	r_i2cm_nack_0,
	r_i2cm_nack_1,
	r_i2cm_num_0,
	r_i2cm_num_1,
	r_i2cm_seq_0,
	r_i2cm_seq_1,
	r_i2cm_stb_0,
	r_i2cm_stb_1,
	r_i2cm_trg_0,
	r_i2cm_trg_0_sel,
	r_i2cm_trg_1,
	r_i2cm_type_0,
	r_i2cm_type_1,
	clr_i_i2cm_finish_0,
	clr_i_i2cm_finish_1,
	clr_i_i2cm_nack_ntfy_0,
	clr_i_i2cm_nack_ntfy_1,
	reg_rd,
	//input
	i_i2cm_finish_0,
	i_i2cm_finish_1,
	i_i2cm_nack_ntfy_0,
	i_i2cm_nack_ntfy_1,
	clr_r_i2cm_trg_0,
	clr_r_i2cm_trg_1,
	clk,
	rst_n,
	clk_ahbs_reg_wen,
	ahbs_reg_index,
	ahbs_reg_wd,
);

//----------------------------------------------//
// Parameter declaration                        //
//----------------------------------------------//
parameter SOISP_P10_AH00      = (16'h00);       //16'h00
parameter SOISP_P10_AH01      = (16'h01);       //16'h01
parameter SOISP_P10_AH10      = (16'h10);       //16'h10
parameter SOISP_P10_AH11      = (16'h11);       //16'h11
parameter SOISP_P10_AH12      = (16'h12);       //16'h12
parameter SOISP_P10_AH13      = (16'h13);       //16'h13
parameter SOISP_P10_AH14      = (16'h14);       //16'h14
parameter SOISP_P10_AH15      = (16'h15);       //16'h15
parameter SOISP_P10_AH16      = (16'h16);       //16'h16
parameter SOISP_P10_AH20      = (16'h20);       //16'h20
parameter SOISP_P10_AH21      = (16'h21);       //16'h21
parameter SOISP_P10_AH22      = (16'h22);       //16'h22
parameter SOISP_P10_AH23      = (16'h23);       //16'h23
parameter SOISP_P10_AH24      = (16'h24);       //16'h24
parameter SOISP_P10_AH25      = (16'h25);       //16'h25
parameter SOISP_P10_AH26      = (16'h26);       //16'h26
parameter SOISP_P10_AH27      = (16'h27);       //16'h27

//----------------------------------------------//
// Output declaration                           //
//----------------------------------------------//
output [7:0]  reg_rd;                           //reg read data bus
output [7:0]   r_i2cm_addr_0;                   //r_i2cm_addr_0
output [7:0]   r_i2cm_addr_1;                   //r_i2cm_addr_1
output [7:0]   r_i2cm_dev_id_0;                 //r_i2cm_dev_id_0
output [7:0]   r_i2cm_dev_id_1;                 //r_i2cm_dev_id_1
output         r_i2cm_nack_0;                   //r_i2cm_nack_0
output         r_i2cm_nack_1;                   //r_i2cm_nack_1
output [7:0]   r_i2cm_num_0;                    //r_i2cm_num_0
output [7:0]   r_i2cm_num_1;                    //r_i2cm_num_1
output         r_i2cm_seq_0;                    //r_i2cm_seq_0
output         r_i2cm_seq_1;                    //r_i2cm_seq_1
output         r_i2cm_stb_0;                    //r_i2cm_stb_0
output         r_i2cm_stb_1;                    //r_i2cm_stb_1
output         r_i2cm_trg_0;                    //r_i2cm_trg_0
output         r_i2cm_trg_0_sel;                //r_i2cm_trg_0_sel
output         r_i2cm_trg_1;                    //r_i2cm_trg_1
output         r_i2cm_type_0;                   //r_i2cm_type_0
output         r_i2cm_type_1;                   //r_i2cm_type_1
output         clr_i_i2cm_finish_0;             //write one to clear i_i2cm_finish_0
output         clr_i_i2cm_finish_1;             //write one to clear i_i2cm_finish_1
output         clr_i_i2cm_nack_ntfy_0;          //write one to clear i_i2cm_nack_ntfy_0
output         clr_i_i2cm_nack_ntfy_1;          //write one to clear i_i2cm_nack_ntfy_1

//----------------------------------------------//
// Input declaration                            //
//----------------------------------------------//
input         clk;                              //clk clock
input         rst_n;                            //rst_n reset active low
input clk_ahbs_reg_wen;                         //write clk byte enable
input [7 :0]  ahbs_reg_index;                   //write index
input [7:0]  ahbs_reg_wd;                       //write data
input         i_i2cm_finish_0;                  //read id i_i2cm_finish_0
input         i_i2cm_finish_1;                  //read id i_i2cm_finish_1
input         i_i2cm_nack_ntfy_0;               //read id i_i2cm_nack_ntfy_0
input         i_i2cm_nack_ntfy_1;               //read id i_i2cm_nack_ntfy_1
input         clr_r_i2cm_trg_0;                 //auto-clear r_i2cm_trg_0
input         clr_r_i2cm_trg_1;                 //auto-clear r_i2cm_trg_1

//----------------------------------------------//
// Register declaration                         //
//----------------------------------------------//
reg [7:0]  reg_rd;                              //reg read bus
reg [7:0]   r_i2cm_addr_0;                      //r_i2cm_addr_0
reg [7:0]   r_i2cm_addr_1;                      //r_i2cm_addr_1
reg [7:0]   r_i2cm_dev_id_0;                    //r_i2cm_dev_id_0
reg [7:0]   r_i2cm_dev_id_1;                    //r_i2cm_dev_id_1
reg         r_i2cm_nack_0;                      //r_i2cm_nack_0
reg         r_i2cm_nack_1;                      //r_i2cm_nack_1
reg [7:0]   r_i2cm_num_0;                       //r_i2cm_num_0
reg [7:0]   r_i2cm_num_1;                       //r_i2cm_num_1
reg         r_i2cm_seq_0;                       //r_i2cm_seq_0
reg         r_i2cm_seq_1;                       //r_i2cm_seq_1
reg         r_i2cm_stb_0;                       //r_i2cm_stb_0
reg         r_i2cm_stb_1;                       //r_i2cm_stb_1
reg         r_i2cm_trg_0;                       //r_i2cm_trg_0
reg         r_i2cm_trg_0_sel;                   //r_i2cm_trg_0_sel
reg         r_i2cm_trg_1;                       //r_i2cm_trg_1
reg         r_i2cm_type_0;                      //r_i2cm_type_0
reg         r_i2cm_type_1;                      //r_i2cm_type_1
reg         clr_i_i2cm_finish_0;                //clr_i_i2cm_finish_0
reg         clr_i_i2cm_finish_1;                //clr_i_i2cm_finish_1
reg         clr_i_i2cm_nack_ntfy_0;             //clr_i_i2cm_nack_ntfy_0
reg         clr_i_i2cm_nack_ntfy_1;             //clr_i_i2cm_nack_ntfy_1

//----------------------------------------------//
// Wire declaration                             //
//----------------------------------------------//
wire write_clk_reg_en;                          //define write clk reg enable
wire addr_en_ah00;                              //addr 00 enable
wire en_soisp_p10_clk_ah00;                     //write addr 00 clk enable
wire rd_soisp_p10_ah00;                         //read addr 00 enable
wire addr_en_ah01;                              //addr 01 enable
wire en_soisp_p10_clk_ah01;                     //write addr 01 clk enable
wire rd_soisp_p10_ah01;                         //read addr 01 enable
wire addr_en_ah10;                              //addr 10 enable
wire en_soisp_p10_clk_ah10;                     //write addr 10 clk enable
wire rd_soisp_p10_ah10;                         //read addr 10 enable
wire addr_en_ah11;                              //addr 11 enable
wire en_soisp_p10_clk_ah11;                     //write addr 11 clk enable
wire rd_soisp_p10_ah11;                         //read addr 11 enable
wire addr_en_ah12;                              //addr 12 enable
wire en_soisp_p10_clk_ah12;                     //write addr 12 clk enable
wire rd_soisp_p10_ah12;                         //read addr 12 enable
wire addr_en_ah13;                              //addr 13 enable
wire en_soisp_p10_clk_ah13;                     //write addr 13 clk enable
wire rd_soisp_p10_ah13;                         //read addr 13 enable
wire addr_en_ah14;                              //addr 14 enable
wire en_soisp_p10_clk_ah14;                     //write addr 14 clk enable
wire rd_soisp_p10_ah14;                         //read addr 14 enable
wire addr_en_ah15;                              //addr 15 enable
wire en_soisp_p10_clk_ah15;                     //write addr 15 clk enable
wire rd_soisp_p10_ah15;                         //read addr 15 enable
wire addr_en_ah16;                              //addr 16 enable
wire en_soisp_p10_clk_ah16;                     //write addr 16 clk enable
wire rd_soisp_p10_ah16;                         //read addr 16 enable
wire addr_en_ah20;                              //addr 20 enable
wire en_soisp_p10_clk_ah20;                     //write addr 20 clk enable
wire rd_soisp_p10_ah20;                         //read addr 20 enable
wire addr_en_ah21;                              //addr 21 enable
wire en_soisp_p10_clk_ah21;                     //write addr 21 clk enable
wire rd_soisp_p10_ah21;                         //read addr 21 enable
wire addr_en_ah22;                              //addr 22 enable
wire en_soisp_p10_clk_ah22;                     //write addr 22 clk enable
wire rd_soisp_p10_ah22;                         //read addr 22 enable
wire addr_en_ah23;                              //addr 23 enable
wire en_soisp_p10_clk_ah23;                     //write addr 23 clk enable
wire rd_soisp_p10_ah23;                         //read addr 23 enable
wire addr_en_ah24;                              //addr 24 enable
wire en_soisp_p10_clk_ah24;                     //write addr 24 clk enable
wire rd_soisp_p10_ah24;                         //read addr 24 enable
wire addr_en_ah25;                              //addr 25 enable
wire en_soisp_p10_clk_ah25;                     //write addr 25 clk enable
wire rd_soisp_p10_ah25;                         //read addr 25 enable
wire addr_en_ah26;                              //addr 26 enable
wire en_soisp_p10_clk_ah26;                     //write addr 26 clk enable
wire rd_soisp_p10_ah26;                         //read addr 26 enable
wire addr_en_ah27;                              //addr 27 enable
wire en_soisp_p10_clk_ah27;                     //write addr 27 clk enable
wire rd_soisp_p10_ah27;                         //read addr 27 enable
wire ac_r_i2cm_trg_0;                           //auto-clear r_i2cm_trg_0
wire ac_r_i2cm_trg_1;                           //auto-clear r_i2cm_trg_1
wire [7:0] reg_index;                           //reg_index
wire [7:0] reg_wd;                              //reg_wd

//----------------------------------------------//
// Define Combinational Logic                   //
//----------------------------------------------//
//define register read/write
assign reg_index   = ahbs_reg_index;
assign reg_wd      = ahbs_reg_wd;
wire clk_reg_wen;                               //clk_reg_wen
assign clk_reg_wen = clk_ahbs_reg_wen;
assign write_clk_reg_en = clk_ahbs_reg_wen;

//define address/read enable
assign addr_en_ah00 = reg_index == SOISP_P10_AH00      ;
assign en_soisp_p10_clk_ah00 = write_clk_reg_en & addr_en_ah00;
assign rd_soisp_p10_ah00 = reg_index == SOISP_P10_AH00      ;
assign addr_en_ah01 = reg_index == SOISP_P10_AH01      ;
assign en_soisp_p10_clk_ah01 = write_clk_reg_en & addr_en_ah01;
assign rd_soisp_p10_ah01 = reg_index == SOISP_P10_AH01      ;
assign addr_en_ah10 = reg_index == SOISP_P10_AH10      ;
assign en_soisp_p10_clk_ah10 = write_clk_reg_en & addr_en_ah10;
assign rd_soisp_p10_ah10 = reg_index == SOISP_P10_AH10      ;
assign addr_en_ah11 = reg_index == SOISP_P10_AH11      ;
assign en_soisp_p10_clk_ah11 = write_clk_reg_en & addr_en_ah11;
assign rd_soisp_p10_ah11 = reg_index == SOISP_P10_AH11      ;
assign addr_en_ah12 = reg_index == SOISP_P10_AH12      ;
assign en_soisp_p10_clk_ah12 = write_clk_reg_en & addr_en_ah12;
assign rd_soisp_p10_ah12 = reg_index == SOISP_P10_AH12      ;
assign addr_en_ah13 = reg_index == SOISP_P10_AH13      ;
assign en_soisp_p10_clk_ah13 = write_clk_reg_en & addr_en_ah13;
assign rd_soisp_p10_ah13 = reg_index == SOISP_P10_AH13      ;
assign addr_en_ah14 = reg_index == SOISP_P10_AH14      ;
assign en_soisp_p10_clk_ah14 = write_clk_reg_en & addr_en_ah14;
assign rd_soisp_p10_ah14 = reg_index == SOISP_P10_AH14      ;
assign addr_en_ah15 = reg_index == SOISP_P10_AH15      ;
assign en_soisp_p10_clk_ah15 = write_clk_reg_en & addr_en_ah15;
assign rd_soisp_p10_ah15 = reg_index == SOISP_P10_AH15      ;
assign addr_en_ah16 = reg_index == SOISP_P10_AH16      ;
assign en_soisp_p10_clk_ah16 = write_clk_reg_en & addr_en_ah16;
assign rd_soisp_p10_ah16 = reg_index == SOISP_P10_AH16      ;
assign addr_en_ah20 = reg_index == SOISP_P10_AH20      ;
assign en_soisp_p10_clk_ah20 = write_clk_reg_en & addr_en_ah20;
assign rd_soisp_p10_ah20 = reg_index == SOISP_P10_AH20      ;
assign addr_en_ah21 = reg_index == SOISP_P10_AH21      ;
assign en_soisp_p10_clk_ah21 = write_clk_reg_en & addr_en_ah21;
assign rd_soisp_p10_ah21 = reg_index == SOISP_P10_AH21      ;
assign addr_en_ah22 = reg_index == SOISP_P10_AH22      ;
assign en_soisp_p10_clk_ah22 = write_clk_reg_en & addr_en_ah22;
assign rd_soisp_p10_ah22 = reg_index == SOISP_P10_AH22      ;
assign addr_en_ah23 = reg_index == SOISP_P10_AH23      ;
assign en_soisp_p10_clk_ah23 = write_clk_reg_en & addr_en_ah23;
assign rd_soisp_p10_ah23 = reg_index == SOISP_P10_AH23      ;
assign addr_en_ah24 = reg_index == SOISP_P10_AH24      ;
assign en_soisp_p10_clk_ah24 = write_clk_reg_en & addr_en_ah24;
assign rd_soisp_p10_ah24 = reg_index == SOISP_P10_AH24      ;
assign addr_en_ah25 = reg_index == SOISP_P10_AH25      ;
assign en_soisp_p10_clk_ah25 = write_clk_reg_en & addr_en_ah25;
assign rd_soisp_p10_ah25 = reg_index == SOISP_P10_AH25      ;
assign addr_en_ah26 = reg_index == SOISP_P10_AH26      ;
assign en_soisp_p10_clk_ah26 = write_clk_reg_en & addr_en_ah26;
assign rd_soisp_p10_ah26 = reg_index == SOISP_P10_AH26      ;
assign addr_en_ah27 = reg_index == SOISP_P10_AH27      ;
assign en_soisp_p10_clk_ah27 = write_clk_reg_en & addr_en_ah27;
assign rd_soisp_p10_ah27 = reg_index == SOISP_P10_AH27      ;

//define auto clear
assign ac_r_i2cm_trg_0 = clr_r_i2cm_trg_0;
assign ac_r_i2cm_trg_1 = clr_r_i2cm_trg_1;


//define register read bus
always@(*)begin: reg_bank_rd_blk

	reg_rd = 8'h0;
	if(rd_soisp_p10_ah00)
		reg_rd[5:0] = {i_i2cm_nack_ntfy_0, i_i2cm_finish_0, 1'b0, 1'b0, 1'b0,
				r_i2cm_trg_0};
	else if(rd_soisp_p10_ah01)
		reg_rd[5:0] = {i_i2cm_nack_ntfy_1, i_i2cm_finish_1, 1'b0, 1'b0, 1'b0,
				r_i2cm_trg_1};
	else if(rd_soisp_p10_ah10)
		reg_rd[0] = {r_i2cm_nack_0};
	else if(rd_soisp_p10_ah11)
		reg_rd[0] = {r_i2cm_type_0};
	else if(rd_soisp_p10_ah12)
		reg_rd[0] = {r_i2cm_stb_0};
	else if(rd_soisp_p10_ah13)
		reg_rd[0] = {r_i2cm_seq_0};
	else if(rd_soisp_p10_ah14)
		reg_rd[7:0] = {r_i2cm_num_0};
	else if(rd_soisp_p10_ah15)
		reg_rd[7:0] = {r_i2cm_dev_id_0};
	else if(rd_soisp_p10_ah16)
		reg_rd[7:0] = {r_i2cm_addr_0};
	else if(rd_soisp_p10_ah20)
		reg_rd[0] = {r_i2cm_nack_1};
	else if(rd_soisp_p10_ah21)
		reg_rd[0] = {r_i2cm_type_1};
	else if(rd_soisp_p10_ah22)
		reg_rd[0] = {r_i2cm_stb_1};
	else if(rd_soisp_p10_ah23)
		reg_rd[0] = {r_i2cm_seq_1};
	else if(rd_soisp_p10_ah24)
		reg_rd[7:0] = {r_i2cm_num_1};
	else if(rd_soisp_p10_ah25)
		reg_rd[7:0] = {r_i2cm_dev_id_1};
	else if(rd_soisp_p10_ah26)
		reg_rd[7:0] = {r_i2cm_addr_1};
	else if(rd_soisp_p10_ah27)
		reg_rd[0] = {r_i2cm_trg_0_sel};
end

//----------------------------------------------//
// Define Sequential Logic                      //
//----------------------------------------------//
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		clr_i_i2cm_finish_0 <= 1'h0;
	else
		clr_i_i2cm_finish_0 <= ~clr_i_i2cm_finish_0 &
				en_soisp_p10_clk_ah00 & clk_reg_wen & reg_wd[4];
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		clr_i_i2cm_finish_1 <= 1'h0;
	else
		clr_i_i2cm_finish_1 <= ~clr_i_i2cm_finish_1 &
				en_soisp_p10_clk_ah01 & clk_reg_wen & reg_wd[4];
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		clr_i_i2cm_nack_ntfy_0 <= 1'h0;
	else
		clr_i_i2cm_nack_ntfy_0 <= ~clr_i_i2cm_nack_ntfy_0 &
				en_soisp_p10_clk_ah00 & clk_reg_wen & reg_wd[5];
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		clr_i_i2cm_nack_ntfy_1 <= 1'h0;
	else
		clr_i_i2cm_nack_ntfy_1 <= ~clr_i_i2cm_nack_ntfy_1 &
				en_soisp_p10_clk_ah01 & clk_reg_wen & reg_wd[5];
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_addr_0 <= 8'h0;
	else if(en_soisp_p10_clk_ah16)begin
		r_i2cm_addr_0 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_addr_1 <= 8'h0;
	else if(en_soisp_p10_clk_ah26)begin
		r_i2cm_addr_1 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_dev_id_0 <= 8'h0;
	else if(en_soisp_p10_clk_ah15)begin
		r_i2cm_dev_id_0 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_dev_id_1 <= 8'h0;
	else if(en_soisp_p10_clk_ah25)begin
		r_i2cm_dev_id_1 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_nack_0 <= 1'h0;
	else if(en_soisp_p10_clk_ah10 & clk_reg_wen)begin
		r_i2cm_nack_0 <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_nack_1 <= 1'h0;
	else if(en_soisp_p10_clk_ah20 & clk_reg_wen)begin
		r_i2cm_nack_1 <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_num_0 <= 8'h0;
	else if(en_soisp_p10_clk_ah14)begin
		r_i2cm_num_0 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_num_1 <= 8'h0;
	else if(en_soisp_p10_clk_ah24)begin
		r_i2cm_num_1 <= reg_wd[7:0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_seq_0 <= 1'h0;
	else if(en_soisp_p10_clk_ah13 & clk_reg_wen)begin
		r_i2cm_seq_0 <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_seq_1 <= 1'h0;
	else if(en_soisp_p10_clk_ah23 & clk_reg_wen)begin
		r_i2cm_seq_1 <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_stb_0 <= 1'h0;
	else if(en_soisp_p10_clk_ah12 & clk_reg_wen)begin
		r_i2cm_stb_0 <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_stb_1 <= 1'h0;
	else if(en_soisp_p10_clk_ah22 & clk_reg_wen)begin
		r_i2cm_stb_1 <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_trg_0 <= 1'h0;
	else if(ac_r_i2cm_trg_0)
		r_i2cm_trg_0 <= 1'h0;
	else if(en_soisp_p10_clk_ah00 & clk_reg_wen)begin
		r_i2cm_trg_0 <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_trg_0_sel <= 1'h0;
	else if(en_soisp_p10_clk_ah27 & clk_reg_wen)begin
		r_i2cm_trg_0_sel <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_trg_1 <= 1'h0;
	else if(ac_r_i2cm_trg_1)
		r_i2cm_trg_1 <= 1'h0;
	else if(en_soisp_p10_clk_ah01 & clk_reg_wen)begin
		r_i2cm_trg_1 <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_type_0 <= 1'h0;
	else if(en_soisp_p10_clk_ah11 & clk_reg_wen)begin
		r_i2cm_type_0 <= reg_wd[0];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_i2cm_type_1 <= 1'h0;
	else if(en_soisp_p10_clk_ah21 & clk_reg_wen)begin
		r_i2cm_type_1 <= reg_wd[0];
	end
end


endmodule

