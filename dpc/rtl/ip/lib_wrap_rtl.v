// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2018
//
// File Name:        lib_wrap_rtl.v
//
// File Description: Library wrapper
//                   LIB: Library, "TSMC"/"PSC"/"PSC_L40"
//                   DRV: Driving strength
// -FHDR -----------------------------------------------------------------------

// Integrated Clock Gated Cell
// -----------------------------------------------
module CKICG

#(
parameter           LIB     = "USER")

(
input               TE,
input               E,
input               CK,

output              Q);

`ifdef SYNTHESIS

generate
if      (LIB == "TSMC")     begin: gen_tsmc

CKLNQD8     CKLNQD8     (.TE(TE), .E(E), .CP(CK), .Q(Q));

end
else if (LIB == "PSC")      begin: gen_psc

CLKLANQX8   CLKLANQX8   (.TE(TE), .E(E), .CK(CK), .Q(Q));

end
else if (LIB == "PSC_L40")  begin: gen_psc_l40

GCKESLDHMX8 GCKESLDHMX8 (.Q(Q), .E(E), .TE(TE), .CK(CK));

end
else if (LIB == "PSC_L90")  begin: gen_psc_l90

LGCKLBQX2 LGCKLBQX2 (.ENL(Q), .E(E), .TE(TE), .CKB(CK));

end

else begin

reg gt_en;

always @(negedge CK) begin
   gt_en    <= E | TE;
end

assign  Q = CK & gt_en;

end

endgenerate

`else

reg gt_en;

always @(negedge CK) begin
   gt_en    <= E | TE;
end

assign  Q = CK & gt_en;

`endif

endmodule


// Non-inverting Clock Buffer
// -----------------------------------------------
module CKBUF

#(
parameter           LIB     = "PSC")

(
input               I,

output              Z);

`ifdef SYNTHESIS

generate
if (LIB == "TSMC") begin: gen_tsmc

CKBXD8      CKBXD8      (.I(I), .Z(Z));

end
else               begin: gen_psc

CLKBUFX8    CLKBUFX8    (.I(I), .Z(Z));

end
endgenerate

`else

assign  Z = I;

`endif

endmodule


// Inverting Clock Buffer
// -----------------------------------------------
module CKINV

#(
parameter           LIB     = "PSC",
parameter           DRV     = 8)

(
input               I,
output              ZN);

generate
if (LIB == "TSMC") begin: gen_tsmc

   case(DRV)
   3: begin: x3
CKND3       CKND3       (.CLK(I), .CN(ZN));
   end
   default: begin: x8
CKND8       CKND8       (.CLK(I), .CN(ZN));
   end
   endcase

end
else               begin: gen_psc
   case(DRV)
   3: begin: x3
CLKNX3      CLKNX3      (.I(I), .ZN(ZN));
   end
   default: begin: x8
CLKNX8      CLKNX8      (.I(I), .ZN(ZN));
   end
   endcase

end
endgenerate

endmodule


// D Filp-Flop with Async Reset
// -----------------------------------------------
module DFRN

#(
parameter           LIB     = "PSC")

(
input               D,
input               RDN,
input               CK,

output              Q,
output              QN);

generate
if (LIB == "TSMC") begin: gen_tsmc

DFCND2      DFCND2      (.D(D), .CDN(RDN), .CP(CK), .Q(Q), .QN(QN));

end
else               begin: gen_psc

DRNX2       DRNX2       (.D(D), .RDN(RDN), .CK(CK), .Q(Q), .QN(QN));

end
endgenerate

endmodule

// CK MUX
// -----------------------------------------------
module CKMUX

#(
parameter           LIB     = "PSC")

(
input               I0,
input               I1,
input               S,

output              Z);

generate
if (LIB == "TSMC") begin: gen_tsmc

 CKMUX2D1  CKMUX2D1 (.I0(I0), .I1(I1), .S(S), .Z(Z));

end
else               begin: gen_psc

 CKMUX2X1  CKMUX2X1 (.I0(I0), .I1(I1), .S(S), .Z(Z));

end
endgenerate
endmodule

// DEL CELL
// -----------------------------------------------
module DELX4

#(
parameter           LIB     = "PSC")

(
input               I,

output              Z);

generate
if (LIB == "TSMC") begin: gen_tsmc

  DEL3X4    DEL3X4( .Z(Z), .I(I));

end
else               begin: gen_psc

  DEL3X4    DEL3X4( .Z(Z), .I(I));

end
endgenerate
endmodule
