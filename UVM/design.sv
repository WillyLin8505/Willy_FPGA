// **************************** Interface ******************************
interface axi_wr_addr_intf(input clk, input rst);
  logic [3:0] awid;
  logic [31:0] awaddr;
  logic [3:0] awlen;
  logic awready;

  modport MASTER (input clk, rst, output awid, awaddr, awlen, awvalid, input awready);
  modport SLAVE (input awid, awaddr, awlen, awvalid, output awready);
endinterface: axi_wr_addr_intf

// ********************** Dummy design module **************************
module sample_dut (
  input clk,
  input rst,
  axi_wr_addr_intf.SLAVE axi_wr_addr_intf1
);

  always @(posedge clk) begin
    axi_wr_addr_intf1.awready = $urandom(); // Not Synthesizable
  end
endmodule: sample_dut
