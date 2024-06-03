// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2023
//
// File Name:           ip_sqrt_pw_rtl.v [pw: piecewise]
// Author:              Humphrey Lin
//
// File Description:    3-segment piecewise linear approximation "y=mx+b" method to caculate Square Root
//                      unsigned sqrt = i_bs^0.5
//                      o_sqrt[IWID/2.OEXD]   = Sqrt(i_base(IWID))
//                      o_sqrt_recip[ORPCS+1] = 1/Sqrt(i_base(IWID))
//
//                      Latency: 3T
//
// -FHDR -----------------------------------------------------------------------

module ip_sqrt_pw

#(
  parameter                         IWID    = 18,               // Input bit width
  parameter                         OEXD    = 4,                // "SQRT" output extending bit number
  parameter                         ORPCS   = 16,               // "1/SQRT" output precision; NOTE: *** "ORPCS" SHOULD BE < "IWID" ***
  parameter                         OPSEL   = "SQRT",           // Operation select: "SQRT", "SQRT_RECIP", "ALL"

  // local parameter [DON'T modify it !!!]
  parameter                         OWID    = IWID/2 + IWID%2 + OEXD, // SQRT output bit width
  parameter                         ORWD    = ORPCS+1           // 1/SQRT output bit width

 )
(
//--------------------------------------------------------------//
// Output declaration                                           //
//--------------------------------------------------------------//
output reg      [OWID-1:0]          o_sqrt,                     // sqrt value
output reg      [ORWD-1:0]          o_sqrt_recip,               // reciprocal of sqrt

//--------------------------------------------------------------//
// Input declaration                                            //
//--------------------------------------------------------------//
input           [IWID-1:0]          i_base,                     // input value

input                               clk,                        //
input                               rst_n                       //
);

//--------------------------------------------------------------//
// Local Parameter                                              //
//--------------------------------------------------------------//

localparam                          COE_PRCS    = OEXD+(IWID/2)+IWID%2;// coefficient precision for SQRT
localparam                          COE_SZ      = {$clog2(COE_PRCS){1'b1}} <= COE_PRCS ? $clog2(COE_PRCS)+1 : $clog2(COE_PRCS); // COE_PRCS bit size

localparam                          EQA_BSZ    = IWID-(IWID-COE_PRCS); // piecewise equation-a bit size for SQRT
localparam                          EQB_BSZ    = COE_PRCS;             // piecewise equation-b bit size for SQRT


localparam                          RCOE_PRCS   = ORPCS < 8 ? 8 : ORPCS;// coefficient precision for 1/SQRT
localparam                          RCOE_SZ     = {$clog2(RCOE_PRCS){1'b1}} < RCOE_PRCS ? $clog2(RCOE_PRCS)+1 : $clog2(RCOE_PRCS); // RCOE_PRCS bit size

localparam                          REQA_BSZ   = IWID-(IWID-RCOE_PRCS); // piecewise equation-a bit size for 1/SQRT
localparam                          REQB_BSZ   = RCOE_PRCS+2;           // piecewise equation-b bit size for 1/SQRT

// coeficient of piecewise linear equation for SQRT [DON'T modify it !!!]
// coeficient A
localparam      [ 1:0]              ECOEF_M00 = 1,              // coef_m0 @seg_0 for normalize shifting by even number
                                    ECOEF_M10 = 1,              // coef_m0 @seg_1 for normalize shifting by even number
                                    ECOEF_M20 = 1,              // coef_m0 @seg_2 for normalize shifting by even number

                                    OCOEF_M00 = 2,              // coef_m0 @seg_0 for normalize shifting by odd number
                                    OCOEF_M10 = 2,              // coef_m0 @seg_1 for normalize shifting by odd number
                                    OCOEF_M20 = 2;              // coef_m0 @seg_2 for normalize shifting by odd number

localparam      [ 2:0]              ECOEF_M01 = 5,              // coef_m1 @seg_0 for normalize shifting by even number
                                    ECOEF_M11 = 3,              // coef_m1 @seg_1 for normalize shifting by even number
                                    ECOEF_M21 = 3,              // coef_m1 @seg_2 for normalize shifting by even number

                                    OCOEF_M01 = 4,              // coef_m1 @seg_0 for normalize shifting by odd number
                                    OCOEF_M11 = 5,              // coef_m1 @seg_1 for normalize shifting by odd number
                                    OCOEF_M21 = 6;              // coef_m1 @seg_2 for normalize shifting by odd number

localparam      [ 3:0]              ECOEF_M02 = 8,              // coef_m2 @seg_0 for normalize shifting by even number
                                    ECOEF_M12 = 4,              // coef_m2 @seg_1 for normalize shifting by even number
                                    ECOEF_M22 = 8,              // coef_m2 @seg_2 for normalize shifting by even number

                                    OCOEF_M02 = 6,              // coef_m2 @seg_0 for normalize shifting by odd number
                                    OCOEF_M12 = 6,              // coef_m2 @seg_1 for normalize shifting by odd number
                                    OCOEF_M22 = 8;              // coef_m2 @seg_2 for normalize shifting by odd number

// coeficient B
localparam      [COE_SZ-1:0]        ECOEF_B00 = COE_PRCS-1,     // coef_b0 @seg_0 for normalize shifting by even number
                                    ECOEF_B10 = COE_PRCS-1,     // coef_b0 @seg_1 for normalize shifting by even number
                                    ECOEF_B20 = COE_PRCS-1,     // coef_b0 @seg_2 for normalize shifting by even number

                                    OCOEF_B00 = COE_PRCS-2,     // coef_b0 @seg_0 for normalize shifting by odd number
                                    OCOEF_B10 = COE_PRCS-2,     // coef_b0 @seg_1 for normalize shifting by odd number
                                    OCOEF_B20 = COE_PRCS-2;     // coef_b0 @seg_2 for normalize shifting by odd number

localparam      [COE_SZ-1:0]        ECOEF_B01 = COE_PRCS-6,     // coef_b1 @seg_0 for normalize shifting by even number
                                    ECOEF_B11 = COE_PRCS-4,     // coef_b1 @seg_1 for normalize shifting by even number
                                    ECOEF_B21 = COE_PRCS-3,     // coef_b1 @seg_2 for normalize shifting by even number

                                    OCOEF_B01 = COE_PRCS-4,     // coef_b1 @seg_0 for normalize shifting by odd number
                                    OCOEF_B11 = COE_PRCS-3,     // coef_b1 @seg_1 for normalize shifting by odd number
                                    OCOEF_B21 = COE_PRCS-3;     // coef_b1 @seg_2 for normalize shifting by odd number

localparam      [COE_SZ-1:0]        ECOEF_B02 = COE_PRCS-7,     // coef_b2 @seg_0 for normalize shifting by even number
                                    ECOEF_B12 = COE_PRCS-7,     // coef_b2 @seg_1 for normalize shifting by even number
                                    ECOEF_B22 = COE_PRCS-5,     // coef_b2 @seg_2 for normalize shifting by even number

                                    OCOEF_B02 = COE_PRCS-4,     // coef_b2 @seg_0 for normalize shifting by odd number
                                    OCOEF_B12 = COE_PRCS-7,     // coef_b2 @seg_1 for normalize shifting by odd number
                                    OCOEF_B22 = COE_PRCS-4;     // coef_b2 @seg_2 for normalize shifting by odd number

localparam      [COE_SZ-1:0]        EOFST_B  = COE_PRCS >= 8 ? COE_PRCS-8 : 0,// coef_b offset for normalize shifting by even number

                                    OOFST_B0 = COE_PRCS >= 8 ? COE_PRCS-8 : 0,// coef_b offset @seg_0 for normalize shifting by odd number
                                    OOFST_B1 = COE_PRCS-5,      // coef_b offset @seg_1 for normalize shifting by odd number
                                    OOFST_B2 = COE_PRCS-6;      // coef_b offset @seg_2 for normalize shifting by odd number


// coeficient of piecewise linear equation for 1/SQRT [DON'T modify it !!!]
// coeficient A
localparam      [RCOE_SZ-1:0]       ERCOE_M00 = 2,              // coef_m0 @seg_0 for normalize shifting by even number
                                    ERCOE_M10 = 2,              // coef_m0 @seg_1 for normalize shifting by even number
                                    ERCOE_M20 = 3,              // coef_m0 @seg_2 for normalize shifting by even number

                                    ORCOE_M00 = 1,              // coef_m0 @seg_0 for normalize shifting by odd number
                                    ORCOE_M10 = 2,              // coef_m0 @seg_1 for normalize shifting by odd number
                                    ORCOE_M20 = 2;              // coef_m0 @seg_2 for normalize shifting by odd number

localparam      [RCOE_SZ-1:0]       ERCOE_M01 = 3,              // coef_m1 @seg_0 for normalize shifting by even number
                                    ERCOE_M11 = 4,              // coef_m1 @seg_1 for normalize shifting by even number
                                    ERCOE_M21 = 4,              // coef_m1 @seg_2 for normalize shifting by even number

                                    ORCOE_M01 = 4,              // coef_m1 @seg_0 for normalize shifting by odd number
                                    ORCOE_M11 = 3,              // coef_m1 @seg_1 for normalize shifting by odd number
                                    ORCOE_M21 = 4;              // coef_m1 @seg_2 for normalize shifting by odd number

localparam      [RCOE_SZ:0]         ERCOE_M02 = 4,              // coef_m2 @seg_0 for normalize shifting by even number
                                    ERCOE_M12 = 1'b1 << RCOE_SZ,// coef_m2 @seg_1 for normalize shifting by even number, MSB bit to indicate "empty item"
                                    ERCOE_M22 = 5,              // coef_m2 @seg_2 for normalize shifting by even number

                                    ORCOE_M02 = 5,              // coef_m2 @seg_0 for normalize shifting by odd number
                                    ORCOE_M12 = 4,              // coef_m2 @seg_1 for normalize shifting by odd number
                                    ORCOE_M22 = 1'b1 << RCOE_SZ;// coef_m2 @seg_2 for normalize shifting by odd number, MSB bit to indicate "empty item"

// coeficient B
localparam      [RCOE_SZ-1:0]       ERCOE_B00 = RCOE_PRCS-2,    // coef_b0 @seg_0 for normalize shifting by even number
                                    ERCOE_B10 = RCOE_PRCS-2,    // coef_b0 @seg_1 for normalize shifting by even number
                                    ERCOE_B20 = RCOE_PRCS-3,    // coef_b0 @seg_2 for normalize shifting by even number

                                    ORCOE_B00 = RCOE_PRCS-0,    // coef_b0 @seg_0 for normalize shifting by odd number
                                    ORCOE_B10 = RCOE_PRCS-1,    // coef_b0 @seg_1 for normalize shifting by odd number
                                    ORCOE_B20 = RCOE_PRCS-1;    // coef_b0 @seg_2 for normalize shifting by odd number

localparam      [RCOE_SZ-1:0]       ERCOE_B01 = RCOE_PRCS-3,    // coef_b1 @seg_0 for normalize shifting by even number
                                    ERCOE_B11 = RCOE_PRCS-5,    // coef_b1 @seg_1 for normalize shifting by even number
                                    ERCOE_B21 = RCOE_PRCS-6,    // coef_b1 @seg_2 for normalize shifting by even number

                                    ORCOE_B01 = RCOE_PRCS-7,    // coef_b1 @seg_0 for normalize shifting by odd number
                                    ORCOE_B11 = RCOE_PRCS-2,    // coef_b1 @seg_1 for normalize shifting by odd number
                                    ORCOE_B21 = RCOE_PRCS-3;    // coef_b1 @seg_2 for normalize shifting by odd number

localparam      [RCOE_SZ:0]         ERCOE_B02 = RCOE_PRCS-4,    // coef_b2 @seg_0 for normalize shifting by even number
                                    ERCOE_B12 = 1'b1 << RCOE_SZ,// coef_b2 @seg_1 for normalize shifting by even number, MSB bit to indicate "empty item"
                                    ERCOE_B22 = RCOE_PRCS-8,    // coef_b2 @seg_2 for normalize shifting by even number

                                    ORCOE_B02 = RCOE_PRCS-8,    // coef_b2 @seg_0 for normalize shifting by odd number
                                    ORCOE_B12 = RCOE_PRCS-4,    // coef_b2 @seg_1 for normalize shifting by odd number
                                    ORCOE_B22 = 1'b1 << RCOE_SZ;// coef_b2 @seg_2 for normalize shifting by odd number, MSB bit to indicate "empty item"

//--------------------------------------------------------------//
// Register/Wire declaration                                    //
//--------------------------------------------------------------//

reg             [IWID-1:0]          i_base_q;

wire            [IWID-1:0]          lead_one;
reg             [IWID-1:0]          lead_one_q[1:0];

reg                                 lead_parity;
reg                                 lead_parity_q;

reg             [IWID:0]            base_norm;
reg             [IWID:0]            base_norm_q;

wire            [COE_SZ-1:0]        coef_m0;
wire            [COE_SZ-1:0]        coef_m1;
wire            [COE_SZ-1:0]        coef_m2;
wire            [COE_SZ-1:0]        coef_b0;
wire            [COE_SZ-1:0]        coef_b1;
wire            [COE_SZ-1:0]        coef_b2;
wire            [COE_SZ-1:0]        bofst;

wire            [RCOE_SZ-1:0]       rcoe_m0;
wire            [RCOE_SZ-1:0]       rcoe_m1;
wire            [RCOE_SZ  :0]       rcoe_m2;
wire            [RCOE_SZ-1:0]       rcoe_b0;
wire            [RCOE_SZ-1:0]       rcoe_b1;
wire            [RCOE_SZ  :0]       rcoe_b2;

reg             [COE_SZ-1:0]        coef_m0_q;
reg             [COE_SZ-1:0]        coef_m1_q;
reg             [COE_SZ-1:0]        coef_m2_q;
reg             [COE_SZ-1:0]        coef_b0_q;
reg             [COE_SZ-1:0]        coef_b1_q;
reg             [COE_SZ-1:0]        coef_b2_q;
reg             [COE_SZ-1:0]        bofst_q;

reg             [RCOE_SZ-1:0]       rcoe_m0_q;
reg             [RCOE_SZ-1:0]       rcoe_m1_q;
reg             [RCOE_SZ  :0]       rcoe_m2_q;
reg             [RCOE_SZ-1:0]       rcoe_b0_q;
reg             [RCOE_SZ-1:0]       rcoe_b1_q;
reg             [RCOE_SZ  :0]       rcoe_b2_q;

wire signed     [EQA_BSZ  :0]       sqrt_pw_eq_m_sgn;
wire            [EQA_BSZ-1:0]       sqrt_pw_eq_m_nxt;
reg             [EQA_BSZ-1:0]       sqrt_pw_eq_m;
wire            [EQB_BSZ-1:0]       sqrt_pw_eq_b_nxt;
reg             [EQB_BSZ-1:0]       sqrt_pw_eq_b;
wire            [EQB_BSZ:0]         sqrt_pw_eq;
reg             [IWID/2-1:0]        sqrt_pw_eq_rnd_bit;
reg             [OWID-1:0]          sqrt_pw_eq_trunc;

wire            [REQA_BSZ-1:0]      rsqrt_pw_eq_m_nxt;
reg             [REQA_BSZ-1:0]      rsqrt_pw_eq_m;
wire            [REQB_BSZ-1:0]      rsqrt_pw_eq_b_nxt;
reg             [REQB_BSZ-1:0]      rsqrt_pw_eq_b;
wire            [REQB_BSZ-1:0]      rsqrt_pw_eq;
reg             [IWID/2-1:0]        rsqrt_pw_eq_rnd_bit;
reg             [ORWD-1:0]          rsqrt_pw_eq_trunc;

wire            [OWID-1:0]          o_sqrt_nxt;
wire            [ORWD-1:0]          o_sqrt_recip_nxt;
//
genvar                              gi;
integer                             i;

//--------------------------------------------------------------//
// Code Descriptions                                            //
//--------------------------------------------------------------//


// Find Leading One for input normalization
//--------------------------------------------------------------------------------

generate

for(gi=IWID-1; gi >= 0; gi=gi-1) begin : gen_lead1

   if(gi==IWID-1) begin : gen_l1_msb

assign  lead_one[gi] = i_base[gi];

   end
   else begin : gen_l1_excl_msb

assign  lead_one[gi] = i_base[gi] & ~|i_base[IWID-1:gi+1];

   end

end // for loop
endgenerate


//--------------------------------------------------------------------------------

// parity of normalization shifting distance
// lead_parity = lead_one[IWID-1] | lead_one[WID-3] | lead_one[WID-5] | ......

always @* begin
   // i = IWID-1
   lead_parity = lead_one[IWID-1];

   for (i=IWID-3; i >= 0; i=i-2) begin  // lead_parity==1 --> odd shifting distance

      lead_parity = lead_parity | lead_one[i];

   end
end


//--------------------------------------------------------------------------------
// Input normalization [ 1.0 <= i_base < 2 ]

// Input range normalization [to fit LUT index size]
always @* begin
   // i = 0
   base_norm = {IWID+1{lead_one[0]}} & (i_base[0] << IWID);

   for (i = 1; i <= IWID-1; i = i+1) begin

      base_norm = base_norm | ({IWID+1{lead_one[i]}} & (i_base << IWID-i));

   end
end

//--------------------------------------------------------------------------------

// SQRT equation coefficient select
// seg-0: 1.00~1.25
// seg-1: 1.25~1.5
// seg-2: 1.50~2
generate
   if (OPSEL == "SQRT" || OPSEL == "ALL") begin: gen_coe_sqrt

assign  coef_m0 = base_norm[IWID-1] ? (lead_parity ? OCOEF_M20 : ECOEF_M20) :
                  base_norm[IWID-2] ? (lead_parity ? OCOEF_M10 : ECOEF_M10) : (lead_parity ? OCOEF_M00 : ECOEF_M00);
assign  coef_m1 = base_norm[IWID-1] ? (lead_parity ? OCOEF_M21 : ECOEF_M21) :
                  base_norm[IWID-2] ? (lead_parity ? OCOEF_M11 : ECOEF_M11) : (lead_parity ? OCOEF_M01 : ECOEF_M01);
assign  coef_m2 = base_norm[IWID-1] ? (lead_parity ? OCOEF_M22 : ECOEF_M22) :
                  base_norm[IWID-2] ? (lead_parity ? OCOEF_M12 : ECOEF_M12) : (lead_parity ? OCOEF_M02 : ECOEF_M02);

assign  coef_b0 = base_norm[IWID-1] ? (lead_parity ? OCOEF_B20 : ECOEF_B20) :
                  base_norm[IWID-2] ? (lead_parity ? OCOEF_B10 : ECOEF_B10) : (lead_parity ? OCOEF_B00 : ECOEF_B00);
assign  coef_b1 = base_norm[IWID-1] ? (lead_parity ? OCOEF_B21 : ECOEF_B21) :
                  base_norm[IWID-2] ? (lead_parity ? OCOEF_B11 : ECOEF_B11) : (lead_parity ? OCOEF_B01 : ECOEF_B01);
assign  coef_b2 = base_norm[IWID-1] ? (lead_parity ? OCOEF_B22 : ECOEF_B22) :
                  base_norm[IWID-2] ? (lead_parity ? OCOEF_B12 : ECOEF_B12) : (lead_parity ? OCOEF_B02 : ECOEF_B02);

assign  bofst   = lead_parity ? (base_norm[IWID-1] ? OOFST_B2 : base_norm[IWID-2] ? OOFST_B1 : OOFST_B0) : EOFST_B;

// 1/SQRT equation coefficient select
// seg-0: 1.00~1.25
// seg-1: 1.25~1.5
// seg-2: 1.50~2
   end
   if (OPSEL == "SQRT_RECIP" || OPSEL == "ALL") begin: gen_coe_sqrt_recip

assign  rcoe_m0 = base_norm[IWID-1] ? (lead_parity ? ORCOE_M20 : ERCOE_M20) :
                  base_norm[IWID-2] ? (lead_parity ? ORCOE_M10 : ERCOE_M10) : (lead_parity ? ORCOE_M00 : ERCOE_M00);
assign  rcoe_m1 = base_norm[IWID-1] ? (lead_parity ? ORCOE_M21 : ERCOE_M21) :
                  base_norm[IWID-2] ? (lead_parity ? ORCOE_M11 : ERCOE_M11) : (lead_parity ? ORCOE_M01 : ERCOE_M01);
assign  rcoe_m2 = base_norm[IWID-1] ? (lead_parity ? ORCOE_M22 : ERCOE_M22) :
                  base_norm[IWID-2] ? (lead_parity ? ORCOE_M12 : ERCOE_M12) : (lead_parity ? ORCOE_M02 : ERCOE_M02);

assign  rcoe_b0 = base_norm[IWID-1] ? (lead_parity ? ORCOE_B20 : ERCOE_B20) :
                  base_norm[IWID-2] ? (lead_parity ? ORCOE_B10 : ERCOE_B10) : (lead_parity ? ORCOE_B00 : ERCOE_B00);
assign  rcoe_b1 = base_norm[IWID-1] ? (lead_parity ? ORCOE_B21 : ERCOE_B21) :
                  base_norm[IWID-2] ? (lead_parity ? ORCOE_B11 : ERCOE_B11) : (lead_parity ? ORCOE_B01 : ERCOE_B01);
assign  rcoe_b2 = base_norm[IWID-1] ? (lead_parity ? ORCOE_B22 : ERCOE_B22) :
                  base_norm[IWID-2] ? (lead_parity ? ORCOE_B12 : ERCOE_B12) : (lead_parity ? ORCOE_B02 : ERCOE_B02);
   end
endgenerate


// Pipe 1
//--------------------------------------------------------------------------------
// SQRT piecewise equationa m
// base_norm >> coef_m0 + base_norm >> coef_m1 + base_norm >> coef_m2 + rounding bit
// even: coe_m0 - coe_m1 + coe_m2
// odd:  coe_m0 + coe_m1 + coe_m2
generate
   if (OPSEL == "SQRT" || OPSEL == "ALL") begin: gen_eqmb_sqrt

assign  sqrt_pw_eq_m_sgn = (($signed({1'b0, base_norm_q}) >>> coef_m0_q) + ($signed({~lead_parity_q,1'b1}) * ($signed({1'b0, base_norm_q}) >>> coef_m1_q)) +
                            ($signed({1'b0, base_norm_q}) >>> coef_m2_q) +
                            ($signed({1'b0, 1'b1}) <<< IWID-COE_PRCS-1)) >>> IWID-COE_PRCS;

assign  sqrt_pw_eq_m_nxt = $unsigned(sqrt_pw_eq_m_sgn[EQA_BSZ-1:0]);

// SQRT piecewise equationa b
// ((1 >> COE_B0) + (1 >> COE_B1) + (1 >> COE_B2) + offset) << RCOE_PRCS

assign  sqrt_pw_eq_b_nxt = (1'b1 << coef_b0_q) + (1'b1 << coef_b1_q) + (1'b1 << coef_b2_q) + (1'b1 << bofst_q);

   end
   if (OPSEL == "SQRT_RECIP" || OPSEL == "ALL") begin: gen_eqmb_sqrt_recip

// 1/SQRT piecewise equationa a
// base_norm >> coef_m0 + base_norm >> coef_m1 + base_norm >> coef_m2 + rounding bit

assign  rsqrt_pw_eq_m_nxt = ((base_norm_q >> rcoe_m0_q) + (base_norm_q >> rcoe_m1_q) + (({IWID+1{~rcoe_m2_q[RCOE_SZ]}} & base_norm_q) >> rcoe_m2_q[RCOE_SZ-1:0]) +
                             (1'b1 << IWID-RCOE_PRCS-1) ) >> IWID-RCOE_PRCS;

// 1/SQRT piecewise equationa b
// ((1 >> COE_B0) + (1 >> COE_B1) + (1 >> COE_B2) + 1) << RCOE_PRCS

assign  rsqrt_pw_eq_b_nxt = (1'b1 << rcoe_b0_q) + (1'b1 << rcoe_b1_q) + (~rcoe_b2_q[RCOE_SZ] ? (1'b1 << rcoe_b2_q[RCOE_SZ-1:0]) : 0) + (1'b1 << RCOE_PRCS);

   end
endgenerate

// Pipe 2
//--------------------------------------------------------------------------------

// SQRT piecewise equation: mx + b + rounding bit
generate
   if (OPSEL == "SQRT" || OPSEL == "ALL") begin: gen_eq_sqrt

assign  sqrt_pw_eq = sqrt_pw_eq_m + sqrt_pw_eq_b + sqrt_pw_eq_rnd_bit;

// piecewise equation rounding bit
always @* begin
   // i = IWID-1 [R-shift: 0]
   sqrt_pw_eq_rnd_bit = {IWID-2{lead_one_q[1][IWID-1]}} & {IWID-2{1'b0}};

   for (i = IWID-2; i >= 0; i = i-1) begin

      sqrt_pw_eq_rnd_bit = sqrt_pw_eq_rnd_bit | ( {IWID-2{lead_one_q[1][i]}} & (1'b1 << (((IWID-i)/2))-1) );

   end
end

// piecewise equation truncating
always @* begin
   // i = IWID-1 [R-shift: 0]
   sqrt_pw_eq_trunc = {OWID{lead_one_q[1][IWID-1]}} & sqrt_pw_eq;

   for (i = IWID-2; i >= 0; i = i-1) begin

      sqrt_pw_eq_trunc = sqrt_pw_eq_trunc | ( {OWID{lead_one_q[1][i]}} & (sqrt_pw_eq >> ((IWID-i)/2)) );

   end
end

   end

   if (OPSEL == "SQRT_RECIP" || OPSEL == "ALL") begin: gen_eq_sqrt_recip

// 1/SQRT piecewise equation: -mx + b + rounding bit

assign  rsqrt_pw_eq = rsqrt_pw_eq_b - rsqrt_pw_eq_m + rsqrt_pw_eq_rnd_bit;

// piecewise equation rounding bit
always @* begin
   // i = 0
   rsqrt_pw_eq_rnd_bit = {IWID-2{lead_one_q[1][0]}} & {IWID-2{1'b0}};

   for (i = 1; i <= IWID-1; i = i+1) begin

      rsqrt_pw_eq_rnd_bit = rsqrt_pw_eq_rnd_bit | ( {IWID-2{lead_one_q[1][i]}} & (1'b1 << ((IWID/2)-((IWID-i)/2))-1) );

   end
end

// piecewise equation truncating
always @* begin
   // i = 0
   rsqrt_pw_eq_trunc = {ORWD{lead_one_q[1][0]}} & {1'b1, {ORWD-1{1'b0}}}; // i_base = 1

   for (i = 1; i <= IWID-1; i = i+1) begin

      rsqrt_pw_eq_trunc = rsqrt_pw_eq_trunc | ( {ORWD{lead_one_q[1][i]}} & (rsqrt_pw_eq >> ((IWID/2)-((IWID-i)/2))) );

   end
end

   end
endgenerate

// Pipe 3
//--------------------------------------------------------------------------------

generate
   if (OPSEL == "SQRT" || OPSEL == "ALL") begin: gen_sqrt

assign  o_sqrt_nxt = sqrt_pw_eq_trunc;

   end
   else begin: gen_sqrt_null

assign  o_sqrt_nxt = 0;

   end

   if (OPSEL == "SQRT_RECIP" || OPSEL == "ALL") begin: gen_sqrt_recip

assign  o_sqrt_recip_nxt = rsqrt_pw_eq_trunc;

   end
   else begin: gen_sqrt_recip_null

assign  o_sqrt_recip_nxt = 0;

   end
endgenerate


// Sequential Logic                                             //
//--------------------------------------------------------------//

always @ (posedge clk, negedge rst_n) begin
  if(!rst_n) begin
     i_base_q           <= 0;
     lead_parity_q      <= 0;
     base_norm_q        <= 0;
     coef_m0_q          <= 0;
     coef_m1_q          <= 0;
     coef_m2_q          <= 0;
     coef_b0_q          <= 0;
     coef_b1_q          <= 0;
     coef_b2_q          <= 0;
     rcoe_m0_q          <= 0;
     rcoe_m1_q          <= 0;
     rcoe_m2_q          <= 0;
     rcoe_b0_q          <= 0;
     rcoe_b1_q          <= 0;
     rcoe_b2_q          <= 0;
     bofst_q            <= 0;

     sqrt_pw_eq_m       <= 0;
     sqrt_pw_eq_b       <= 0;
     rsqrt_pw_eq_m      <= 0;
     rsqrt_pw_eq_b      <= 0;

     o_sqrt             <= 0;
     o_sqrt_recip       <= 0;

     for (i = 0; i<=1; i=i+1) begin
        lead_one_q[i]   <= 0;
     end
  end
  else begin
     i_base_q           <= i_base;
     lead_parity_q      <= lead_parity;
     base_norm_q        <= base_norm;
     coef_m0_q          <= coef_m0;
     coef_m1_q          <= coef_m1;
     coef_m2_q          <= coef_m2;
     coef_b0_q          <= coef_b0;
     coef_b1_q          <= coef_b1;
     coef_b2_q          <= coef_b2;
     rcoe_m0_q          <= rcoe_m0;
     rcoe_m1_q          <= rcoe_m1;
     rcoe_m2_q          <= rcoe_m2;
     rcoe_b0_q          <= rcoe_b0;
     rcoe_b1_q          <= rcoe_b1;
     rcoe_b2_q          <= rcoe_b2;
     bofst_q            <= bofst;

     sqrt_pw_eq_m       <= sqrt_pw_eq_m_nxt;
     sqrt_pw_eq_b       <= sqrt_pw_eq_b_nxt;
     rsqrt_pw_eq_m      <= rsqrt_pw_eq_m_nxt;
     rsqrt_pw_eq_b      <= rsqrt_pw_eq_b_nxt;

     o_sqrt             <= o_sqrt_nxt;
     o_sqrt_recip       <= o_sqrt_recip_nxt;

     lead_one_q[0]      <= lead_one;
     for (i = 1; i<=1; i=i+1) begin
        lead_one_q[i]   <= lead_one_q[i-1];
     end
  end
end

endmodule

