// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2022
//
// File Name:           ip_recip12p11_rtl.v
// Author:              Humphrey Lin
//
// File Description:    By "Division by Convergence" method to caculate reciprocal
//                      unsigned reciprocal = 1/denominator
//                      u(1.11) = 1 / u(12.0)
//
//                      If parameter PRCIS_EXT == "LVL_0",
//                      original precision definition
//
//                      If parameter PRCIS_EXT == "LVL_1",
//                      the denominator == 0~7, original precision                                  [o_prcis_idx[0] = 1]
//                      the denominator >=   8, output reciprocal will be extened 2 extra bits      [o_prcis_idx[1] = 1]
//
//                      If parameter PRCIS_EXT == "LVL_2",
//                      the denominator ==   0 ~   7, original precision                              [o_prcis_idx[0] = 1]
//                      the denominator ==   8 ~  31, output reciprocal will be extened 2 extra bits  [o_prcis_idx[1] = 1]
//                      the denominator ==  32 ~ 127, output reciprocal will be extened 4 extra bits  [o_prcis_idx[2] = 1]
//                      the denominator == 128 ~ 511, output reciprocal will be extened 6 extra bits  [o_prcis_idx[3] = 1]
//                      the denominator == 512 ~2047, output reciprocal will be extened 8 extra bits  [o_prcis_idx[4] = 1]
//                      the denominator ==2048 ~    , output reciprocal will be extened 9 extra bits  [o_prcis_idx[5] = 1]
// -FHDR -----------------------------------------------------------------------

module ip_recip12p11

#(
  parameter                         PRCIS_EXT = "LVL_2",    // "LVL_0"/"LVL_1"/"LVL_2"
  parameter     [11:0]              DENM_ZERO = 12'h0,      // output value definition, if denominator == 0

  // local parameter [NOT modify it !!!]
  parameter                         IDX_WID   = PRCIS_EXT == "LVL_2" ? 6 :
                                                             "LVL_1" ? 2 : 1
 )
(
//----------------------------------------------------------//
// Output declaration                                       //
//----------------------------------------------------------//
output reg      [11:0]              o_recip,                // reciprocal value. precision: 1.11
output reg      [IDX_WID-1:0]       o_prcis_idx,            // precision index

//----------------------------------------------------------//
// Input declaration                                        //
//----------------------------------------------------------//
input           [11:0]              i_denm,                 //

// clk
input                               clk,                    //
input                               rst_n                   //
);

//----------------------------------------------------------//
// Local Parameter                                          //
//----------------------------------------------------------//

localparam                          DENM_MSB =  11;
localparam                          LUT_ISZ   =  6;

//----------------------------------------------------------//
// Register/Wire declaration                                //
//----------------------------------------------------------//

wire                                denm_zero;
reg                                 denm_zero_q;
wire            [DENM_MSB:0]        denm_lead_one;
reg             [DENM_MSB:0]        denm_lead_one_q;
wire            [LUT_ISZ-1:0]       denm_norm;

reg             [ 7:0]              lut_recip;
reg             [ 7:0]              lut_recip_q;

wire            [19:0]              a0_prod;
wire            [13:0]              a0_prod_adj;
reg             [13:0]              a0_prod_adj_q;

wire            [21:0]              x1_prod;
reg             [10:0]              x1_prod_adj;
reg             [20:0]              x1_rnd_bit;

wire            [11:0]              o_recip_nxt;
wire            [IDX_WID-1:0]       o_prcis_idx_nxt;

genvar                              gi;
integer                             i;

//----------------------------------------------------------//
// Code Descriptions                                        //
//----------------------------------------------------------//

assign denm_zero = i_denm == 0;

//--------------------------------------------------------------------------------
// Find Leading One for input normalization

generate

for(gi=0; gi<=DENM_MSB; gi=gi+1) begin : gen_denm_lead1

   if(gi==DENM_MSB) begin : gen_denm_l1_msb

assign denm_lead_one[gi] = i_denm[gi];

   end
   else begin : gen_denm_l1_exc_msb

assign denm_lead_one[gi] = i_denm[gi] & ~|i_denm[DENM_MSB:gi+1];

   end

end // for loop
endgenerate
//--------------------------------------------------------------------------------

// Input normalization
assign denm_norm = {LUT_ISZ{denm_lead_one[ 1]}} & {i_denm[ 1:0],4'b0} |
                   {LUT_ISZ{denm_lead_one[ 2]}} & {i_denm[ 2:0],3'b0} |
                   {LUT_ISZ{denm_lead_one[ 3]}} & {i_denm[ 3:0],2'b0} |
                   {LUT_ISZ{denm_lead_one[ 4]}} & {i_denm[ 4:0],1'b0} |
                   {LUT_ISZ{denm_lead_one[ 5]}} & {i_denm[ 5:0]}      |
                   {LUT_ISZ{denm_lead_one[ 6]}} & {i_denm[ 6:1]}      |
                   {LUT_ISZ{denm_lead_one[ 7]}} & {i_denm[ 7:2]}      |
                   {LUT_ISZ{denm_lead_one[ 8]}} & {i_denm[ 8:3]}      |
                   {LUT_ISZ{denm_lead_one[ 9]}} & {i_denm[ 9:4]}      |
                   {LUT_ISZ{denm_lead_one[10]}} & {i_denm[10:5]}      |
                   {LUT_ISZ{denm_lead_one[11]}} & {i_denm[11:6]};

// X0: reciprocal LUT [1 < lut_recip < 2]
always @* begin

   lut_recip = 8'h0;

   case (denm_norm[4 : 0])  // synopsys full_case

   5'h0:  lut_recip = 8'hFC;
   5'h1:  lut_recip = 8'hF5;
   5'h2:  lut_recip = 8'hED;
   5'h3:  lut_recip = 8'hE7;
   5'h4:  lut_recip = 8'hE0;
   5'h5:  lut_recip = 8'hDA;
   5'h6:  lut_recip = 8'hD5;
   5'h7:  lut_recip = 8'hCF;
   5'h8:  lut_recip = 8'hCA;
   5'h9:  lut_recip = 8'hC5;
   5'ha:  lut_recip = 8'hC1;
   5'hb:  lut_recip = 8'hBC;
   5'hc:  lut_recip = 8'hB8;
   5'hd:  lut_recip = 8'hB4;
   5'he:  lut_recip = 8'hB0;
   5'hf:  lut_recip = 8'hAC;
   5'h10: lut_recip = 8'hA9;
   5'h11: lut_recip = 8'hA6;
   5'h12: lut_recip = 8'hA2;
   5'h13: lut_recip = 8'h9F;
   5'h14: lut_recip = 8'h9C;
   5'h15: lut_recip = 8'h99;
   5'h16: lut_recip = 8'h96;
   5'h17: lut_recip = 8'h94;
   5'h18: lut_recip = 8'h91;
   5'h19: lut_recip = 8'h8E;
   5'h1a: lut_recip = 8'h8C;
   5'h1b: lut_recip = 8'h8A;
   5'h1c: lut_recip = 8'h87;
   5'h1d: lut_recip = 8'h85;
   5'h1e: lut_recip = 8'h83;
   5'h1f: lut_recip = 8'h81;

   endcase
end

// Pipe 0
//--------------------------------------------------------------------------------
// A0 = Denm * X0   [0.5 < A0 < 2]
// u(.12) * u(1.7) -> adj to 1.13

assign  a0_prod     = i_denm * lut_recip;

assign  a0_prod_adj = {14{denm_lead_one[ 1]}} & {a0_prod[ 9: 0], 4'h0} |
                      {14{denm_lead_one[ 2]}} & {a0_prod[10: 0], 3'h0} |
                      {14{denm_lead_one[ 3]}} & {a0_prod[11: 0], 2'h0} |
                      {14{denm_lead_one[ 4]}} & {a0_prod[12: 0], 1'h0} |
                      {14{denm_lead_one[ 5]}} & {a0_prod[13: 0]}       |
                      {14{denm_lead_one[ 6]}} & {a0_prod[14: 1]}       |
                      {14{denm_lead_one[ 7]}} & {a0_prod[15: 2]}       |
                      {14{denm_lead_one[ 8]}} & {a0_prod[16: 3]}       |
                      {14{denm_lead_one[ 9]}} & {a0_prod[17: 4]}       |
                      {14{denm_lead_one[10]}} & {a0_prod[18: 5]}       |
                      {14{denm_lead_one[11]}} & {a0_prod[19: 6]};
// Pipe 1
//--------------------------------------------------------------------------------
// X1 = X0 * (2-A0)
// u(1.7) * u(1.13)

//assign  x1_prod = lut_recip_q * ({1'b1,14'h0}-a0_prod_adj_q) + x1_rnd_bit;
assign  x1_prod = lut_recip_q * ((a0_prod_adj_q ^ {14{1'b1}}) + 1'b1) + x1_rnd_bit;

generate
if (PRCIS_EXT == "LVL_0") begin: gen_prod_lvl0

/*
assign  x1_prod_adj = {11{denm_lead_one_q[ 1]}} & {       x1_prod[11 +: 11]}  |
                      {11{denm_lead_one_q[ 2]}} & { 1'h0, x1_prod[12 +: 10]}  |
                      {11{denm_lead_one_q[ 3]}} & { 2'h0, x1_prod[13 +:  9]}  |
                      {11{denm_lead_one_q[ 4]}} & { 3'h0, x1_prod[14 +:  8]}  |
                      {11{denm_lead_one_q[ 5]}} & { 4'h0, x1_prod[15 +:  7]}  |
                      {11{denm_lead_one_q[ 6]}} & { 5'h0, x1_prod[16 +:  6]}  |
                      {11{denm_lead_one_q[ 7]}} & { 6'h0, x1_prod[17 +:  5]}  |
                      {11{denm_lead_one_q[ 8]}} & { 7'h0, x1_prod[18 +:  4]}  |
                      {11{denm_lead_one_q[ 9]}} & { 8'h0, x1_prod[19 +:  3]}  |
                      {11{denm_lead_one_q[10]}} & { 9'h0, x1_prod[20 +:  2]}  |
                      {11{denm_lead_one_q[11]}} & {10'h0, x1_prod[21 +:  1]};

assign  x1_rnd_bit  = {21{denm_lead_one_q[ 1]}} & {10'h0, 1'b1, 10'h0}  |
                      {21{denm_lead_one_q[ 2]}} & { 9'h0, 1'b1, 11'h0}  |
                      {21{denm_lead_one_q[ 3]}} & { 8'h0, 1'b1, 12'h0}  |
                      {21{denm_lead_one_q[ 4]}} & { 7'h0, 1'b1, 13'h0}  |
                      {21{denm_lead_one_q[ 5]}} & { 6'h0, 1'b1, 14'h0}  |
                      {21{denm_lead_one_q[ 6]}} & { 5'h0, 1'b1, 15'h0}  |
                      {21{denm_lead_one_q[ 7]}} & { 4'h0, 1'b1, 16'h0}  |
                      {21{denm_lead_one_q[ 8]}} & { 3'h0, 1'b1, 17'h0}  |
                      {21{denm_lead_one_q[ 9]}} & { 2'h0, 1'b1, 18'h0}  |
                      {21{denm_lead_one_q[10]}} & { 1'h0, 1'b1, 19'h0}  |
                      {21{denm_lead_one_q[11]}} & {       1'b1, 20'h0};
*/
always @* begin
   // i = 1
   x1_prod_adj = {11{denm_lead_one_q[ 1]}} & {      x1_prod[11 +: 11]};

   for (i = 2; i <= 11; i = i+1) begin
      x1_prod_adj = x1_prod_adj | ({11{denm_lead_one_q[i]}} & (x1_prod[21 : 12] >> i-2));

   end
end

always @* begin
   // i = 1
   x1_rnd_bit = {21{denm_lead_one_q[ 1]}} & {10'h0, 1'b1, 10'h0};

   for (i = 2; i <= 11; i = i+1) begin
      x1_rnd_bit = x1_rnd_bit | ({21{denm_lead_one_q[i]}} & ({ 9'h0, 1'b1, 11'h0} << i-2));
   end
end

end
else if (PRCIS_EXT == "LVL_1") begin: gen_prod_lvl1

always @* begin
   // i = 1, 2
   x1_prod_adj = {11{denm_lead_one_q[ 1]}} & {       x1_prod[11 +: 11]} |
                 {11{denm_lead_one_q[ 2]}} & { 1'h0, x1_prod[12 +: 10]};

   for (i = 3; i <= 11; i = i+1) begin
      x1_prod_adj = x1_prod_adj | ({11{denm_lead_one_q[i]}} & (x1_prod[21 : 11] >> i-3));

   end
end

always @* begin
   // i = 1, 2
   x1_rnd_bit = {21{denm_lead_one_q[ 1]}} & {10'h0, 1'b1, 10'h0}  |
                {21{denm_lead_one_q[ 2]}} & { 9'h0, 1'b1, 11'h0};

   for (i = 3; i <= 11; i = i+1) begin
      x1_rnd_bit = x1_rnd_bit | ({21{denm_lead_one_q[i]}} & ({10'h0, 1'b1, 10'h0} << i-3));
   end
end

end
else begin: gen_prod_lvl2

always @* begin
   // i = 11
   x1_prod_adj = {11{denm_lead_one_q[11]}} & {1'h0, x1_prod[12 +: 10]} ;

   for (i = 1; i <= 10; i = i+1) begin
      x1_prod_adj = x1_prod_adj | ({11{denm_lead_one_q[i]}} & (x1_prod[21 : 11] >> (i+1)%2));

   end
end

always @* begin
   // i = 11
   x1_rnd_bit = {21{denm_lead_one_q[11]}} & { 9'h0, 1'b1, 11'h0};

   for (i = 1; i <= 10; i = i+1) begin
      x1_rnd_bit = x1_rnd_bit | ({21{denm_lead_one_q[i]}} & ({10'h0, 1'b1, 10'h0} << (i+1)%2));
   end
end

end
endgenerate

// Pipe 2
//--------------------------------------------------------------------------------

assign  o_recip_nxt = denm_lead_one_q[0] ? 12'h800 :                        // i_denm == 1
                      denm_zero_q        ? DENM_ZERO : {1'b0,x1_prod_adj};

assign  o_prcis_idx_nxt = PRCIS_EXT == "LVL_2" ? { denm_lead_one_q[11]                              ,
                                                  |denm_lead_one_q[10:9] & ~(|denm_lead_one_q[11]  ),
                                                  |denm_lead_one_q[ 8:7] & ~(|denm_lead_one_q[11:9]),
                                                  |denm_lead_one_q[ 6:5] & ~(|denm_lead_one_q[11:7]),
                                                  |denm_lead_one_q[ 4:3] & ~(|denm_lead_one_q[11:5]),
                                                                           ~(|denm_lead_one_q[11:3])} :
                                       "LVL_1" ? {|denm_lead_one_q[11:3],
                                                                           ~(|denm_lead_one_q[11:3])} : 1'b1;


// Sequential Logic                                         //
//----------------------------------------------------------//

always @ (posedge clk, negedge rst_n) begin
  if(!rst_n) begin
     denm_zero_q        <= 0;
     denm_lead_one_q    <= 0;
     lut_recip_q        <= 0;
     a0_prod_adj_q      <= 0;
     o_recip            <= 0;
     o_prcis_idx        <= 0;
  end
  else begin
     denm_zero_q        <= denm_zero;
     denm_lead_one_q    <= denm_lead_one;
     lut_recip_q        <= lut_recip;
     a0_prod_adj_q      <= a0_prod_adj;
     o_recip            <= o_recip_nxt;
     o_prcis_idx        <= o_prcis_idx_nxt;
  end
end

endmodule

