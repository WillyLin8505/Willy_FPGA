
//-----------------------------------------------------------------------------
//  RTL design config
//-----------------------------------------------------------------------------

`define     FF_RESET_SYNC
//`define     FF_RESET_ASYN

`ifdef FF_RESET_SYNC
    `define always_ff(_clk, _reset_n) always @(posedge _clk)
`elsif FF_RESET_ASYN
    `define always_ff(_clk, _reset_n) always @(posedge _clk or negedge _reset_n)
`endif

