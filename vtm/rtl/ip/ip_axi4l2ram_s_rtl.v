// +FHDR -----------------------------------------------------------------------
// Copyright (c) Silicon Optronics. Inc. 2016
//
// File Name:           ip_axi4l2ram_s_rtl.v
// Author:              Humphrey Lin
//
// File Description:    1. A wrapper to convert AXI-lite slave transactions to SRAM write/read or GPIO I/F.
//                      2. The wrapper is modified from Xilinx xapp1168/axi_lite_slave.v
//
// The key features of the AXI4-Lite interface are:
//         >> all transactions are burst length of 1
//         >> all data accesses are the same size as the width of the data bus
//         >> support for data bus width of 32-bit or 64-bit
// -FHDR -----------------------------------------------------------------------


module axi4l2ram_s

#(
parameter           S_AXI_ADDR_WID      = 16,
parameter           S_AXI_DATA_WID      = 32,

parameter           SLV_CH_NUM          = 1,    // output slave channel number, max: 8

parameter           SLV_ADDR_WID        = S_AXI_ADDR_WID-$clog2(SLV_CH_NUM),
parameter           SLV_WE_WID          = S_AXI_DATA_WID/8,

parameter           SLV_BASE_ADDR0      = {S_AXI_ADDR_WID{1'b0}},
parameter           SLV_BASE_ADDR1      = {S_AXI_ADDR_WID{1'b1}},
parameter           SLV_BASE_ADDR2      = {S_AXI_ADDR_WID{1'b1}},
parameter           SLV_BASE_ADDR3      = {S_AXI_ADDR_WID{1'b1}},
parameter           SLV_BASE_ADDR4      = {S_AXI_ADDR_WID{1'b1}},
parameter           SLV_BASE_ADDR5      = {S_AXI_ADDR_WID{1'b1}},
parameter           SLV_BASE_ADDR6      = {S_AXI_ADDR_WID{1'b1}},
parameter           SLV_BASE_ADDR7      = {S_AXI_ADDR_WID{1'b1}},


parameter           T_A2RD_LAT          = 1     // address-to-read data latency. 0~2
 )

(
////////////////////////////////////////////////////////////////////////////
// System Signals

// AXI clock signal
input                                   s_axi_aclk,
// AXI active low reset signal
input                                   s_axi_aresetn,

////////////////////////////////////////////////////////////////////////////
// Slave Interface Write Address channel Ports

// Write address (issued by master, acceped by Slave)
input       [S_AXI_ADDR_WID - 1:0]      s_axi_awaddr,

// Write address valid. This signal indicates that the master signaling
// valid write address and control information.
input                                   s_axi_awvalid,
// Write address ready. This signal indicates that the slave is ready
// to accept an address and associated control signals.
output                                  s_axi_awready,

////////////////////////////////////////////////////////////////////////////
// Slave Interface Write Data channel Ports
// Write data (issued by master, acceped by Slave)
input       [S_AXI_DATA_WID-1:0]        s_axi_wdata,

// Write strobes. This signal indicates which byte lanes hold
// valid data. There is one write strobe bit for each eight
// bits of the write data bus.
input       [S_AXI_DATA_WID/8-1:0]      s_axi_wstrb,

//Write valid. This signal indicates that valid write
// data and strobes are available.
input                                   s_axi_wvalid,

// Write ready. This signal indicates that the slave
// can accept the write data.
output                                  s_axi_wready,

////////////////////////////////////////////////////////////////////////////
// Slave Interface Write Response channel Ports


// Write response. This signal indicates the status
// of the write transaction.
output      [ 1:0]                      s_axi_bresp,

// Write response valid. This signal indicates that the channel
// is signaling a valid write response.
output                                  s_axi_bvalid,

// Response ready. This signal indicates that the master
// can accept a write response.
input                                   s_axi_bready,

////////////////////////////////////////////////////////////////////////////
// Slave Interface Read Address channel Ports
// Read address (issued by master, acceped by Slave)
input       [S_AXI_ADDR_WID - 1:0]      s_axi_araddr,

// Read address valid. This signal indicates that the channel
// is signaling valid read address and control information.
input                                   s_axi_arvalid,

// Read address ready. This signal indicates that the slave is
// ready to accept an address and associated control signals.
output                                  s_axi_arready,

////////////////////////////////////////////////////////////////////////////
// Slave Interface Read Data channel Ports
// Read data (issued by slave)
output      [S_AXI_DATA_WID-1:0]        s_axi_rdata,

// Read response. This signal indicates the status of the
// read transfer.
output      [ 1:0]                      s_axi_rresp,

// Read valid. This signal indicates that the channel is
// signaling the required read data.
output                                  s_axi_rvalid,

// Read ready. This signal indicates that the master can
// accept the read data and response information.
input                                   s_axi_rready,


// SRAM write/read I/F
// ----------------------------------------------
output                                  o_slv_en0,  // port enable
output                                  o_slv_en1,
output                                  o_slv_en2,
output                                  o_slv_en3,
output                                  o_slv_en4,
output                                  o_slv_en5,
output                                  o_slv_en6,
output                                  o_slv_en7,

output reg  [SLV_WE_WID-1:0]            o_slv_we,   // byte-write enable
output reg  [SLV_ADDR_WID-1:0]          o_slv_addr,
output reg  [S_AXI_DATA_WID-1:0]        o_slv_wd,   // write data/ GPIO-O
input       [S_AXI_DATA_WID-1:0]        i_slv_rd0,
input       [S_AXI_DATA_WID-1:0]        i_slv_rd1,
input       [S_AXI_DATA_WID-1:0]        i_slv_rd2,
input       [S_AXI_DATA_WID-1:0]        i_slv_rd3,
input       [S_AXI_DATA_WID-1:0]        i_slv_rd4,
input       [S_AXI_DATA_WID-1:0]        i_slv_rd5,
input       [S_AXI_DATA_WID-1:0]        i_slv_rd6,
input       [S_AXI_DATA_WID-1:0]        i_slv_rd7

);

////////////////////////////////////////////////////////////////////////////
// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WID
// ADDR_LSB is used for addressing 32/64 bit registers/memories
// ADDR_LSB = 2 for 32 bits (n downto 2)
// ADDR_LSB = 3 for 64 bits (n downto 3)

////////////////////////////////////////////////////////////////////////////
// function called clogb2 that returns an integer which has the
// value of the ceiling of the log base 2.
function integer clogb2 (input integer bd);
integer bit_depth;
begin
  bit_depth = bd;
  for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
    bit_depth = bit_depth >> 1;
  end
endfunction

localparam integer ADDR_LSB = clogb2(S_AXI_DATA_WID/8)-1;
localparam integer ADDR_MSB = S_AXI_ADDR_WID;

localparam[8*S_AXI_ADDR_WID-1:0]ALL_SLV_BASE_ADDR = {SLV_BASE_ADDR7[S_AXI_ADDR_WID-1:0],
                                                     SLV_BASE_ADDR6[S_AXI_ADDR_WID-1:0],
                                                     SLV_BASE_ADDR5[S_AXI_ADDR_WID-1:0],
                                                     SLV_BASE_ADDR4[S_AXI_ADDR_WID-1:0],
                                                     SLV_BASE_ADDR3[S_AXI_ADDR_WID-1:0],
                                                     SLV_BASE_ADDR2[S_AXI_ADDR_WID-1:0],
                                                     SLV_BASE_ADDR1[S_AXI_ADDR_WID-1:0],
                                                     SLV_BASE_ADDR0[S_AXI_ADDR_WID-1:0]};

localparam[8*S_AXI_ADDR_WID-1:0]ALL_SLV_MAX_ADDR  = {{SLV_ADDR_WID{1'b1}},
                                                      SLV_BASE_ADDR7[S_AXI_ADDR_WID-1:0]-(SLV_CH_NUM > 7),
                                                      SLV_BASE_ADDR6[S_AXI_ADDR_WID-1:0]-(SLV_CH_NUM > 6),
                                                      SLV_BASE_ADDR5[S_AXI_ADDR_WID-1:0]-(SLV_CH_NUM > 5),
                                                      SLV_BASE_ADDR4[S_AXI_ADDR_WID-1:0]-(SLV_CH_NUM > 4),
                                                      SLV_BASE_ADDR3[S_AXI_ADDR_WID-1:0]-(SLV_CH_NUM > 3),
                                                      SLV_BASE_ADDR2[S_AXI_ADDR_WID-1:0]-(SLV_CH_NUM > 2),
                                                      SLV_BASE_ADDR1[S_AXI_ADDR_WID-1:0]-(SLV_CH_NUM > 1)};

localparam[SLV_CH_NUM*S_AXI_ADDR_WID-1:0]SLV_BASE_ADDR = ALL_SLV_BASE_ADDR[SLV_CH_NUM*S_AXI_ADDR_WID-1:0];
localparam[SLV_CH_NUM*S_AXI_ADDR_WID-1:0]SLV_MAX_ADDR  = ALL_SLV_MAX_ADDR [SLV_CH_NUM*S_AXI_ADDR_WID-1:0];

////////////////////////////////////////////////////////////////////////////
// AXI4 Lite internal signals

////////////////////////////////////////////////////////////////////////////
// read response
reg [1 :0]                      axi_rresp;
wire[1 :0]                      axi_rresp_nxt;
////////////////////////////////////////////////////////////////////////////
// write response
reg [1 :0]                      axi_bresp;
////////////////////////////////////////////////////////////////////////////
// write address acceptance
reg                             axi_awready;
////////////////////////////////////////////////////////////////////////////
// write data acceptance
reg                             axi_wready;
////////////////////////////////////////////////////////////////////////////
// write response valid
reg                             axi_bvalid;
////////////////////////////////////////////////////////////////////////////
// read data valid
reg                             axi_rvalid;
wire                            axi_rvalid_nxt;

////////////////////////////////////////////////////////////////////////////
// write address
reg [ADDR_MSB-1:0]              axi_awaddr;
////////////////////////////////////////////////////////////////////////////
// read data
reg [S_AXI_DATA_WID-1:0]        axi_rdata;
wire[S_AXI_DATA_WID-1:0]        axi_rdata_nxt;

////////////////////////////////////////////////////////////////////////////
// read address acceptance
reg                             axi_arready;
wire                            axi_arready_nxt;


////////////////////////////////////////////////////////////////////////////
// Slave SRAM signals
wire [ 7:0]                     slv_en_nxt;
reg  [ 7:0]                     slv_en;

wire [SLV_WE_WID-1:0]           o_slv_we_nxt;
reg  [S_AXI_DATA_WID-1:0]       o_slv_wd_nxt;
wire [SLV_ADDR_WID-1:0]         o_slv_addr_nxt;
wire                            slv_ren;
wire                            slv_rd_vld;
reg                             slv_rd_vld_q;
reg  [ 1:0]                     slv_ren_q;

integer                         i;
genvar                          ix;

////////////////////////////////////////////////////////////////////////////
//I/O Connections assignments

////////////////////////////////////////////////////////////////////////////
//Write Address Ready (AWREADY)
assign s_axi_awready = axi_awready;

////////////////////////////////////////////////////////////////////////////
//Write Data Ready(WREADY)
assign s_axi_wready  = axi_wready;

////////////////////////////////////////////////////////////////////////////
//Write Response (BResp)and response valid (BVALID)
assign s_axi_bresp  = axi_bresp;
assign s_axi_bvalid = axi_bvalid;

////////////////////////////////////////////////////////////////////////////
//Read Address Ready(AREADY)
assign s_axi_arready = axi_arready;

////////////////////////////////////////////////////////////////////////////
//Read and Read Data (RDATA), Read Valid (RVALID) and Response (RRESP)
assign s_axi_rdata  = axi_rdata;
assign s_axi_rvalid = axi_rvalid;
assign s_axi_rresp  = axi_rresp;


////////////////////////////////////////////////////////////////////////////
// Implement axi_awready generation
//
//  axi_awready is asserted for one s_axi_aclk clock cycle when both
//  s_axi_awvalid and s_axi_wvalid are asserted. axi_awready is
//  de-asserted when reset is low.

always @( posedge s_axi_aclk )
begin
  if ( s_axi_aresetn == 1'b0 )
    begin
      axi_awready <= 1'b0;
    end
  else
    begin
      if (~axi_awready && s_axi_awvalid && s_axi_wvalid)
        begin
          ////////////////////////////////////////////////////////////////////////////
          // slave is ready to accept write address when
          // there is a valid write address and write data
          // on the write address and data bus. This design
          // expects no outstanding transactions.
          axi_awready <= 1'b1;
        end
      else
        begin
          axi_awready <= 1'b0;
        end
    end
end

////////////////////////////////////////////////////////////////////////////
// Implement axi_awaddr latching
//
//  This process is used to latch the address when both
//  s_axi_awvalid and s_axi_wvalid are valid.

always @( posedge s_axi_aclk )
begin
  if ( s_axi_aresetn == 1'b0 )
    begin
      axi_awaddr <= 0;
    end
  else
    begin
      if (~axi_awready && s_axi_awvalid && s_axi_wvalid)
        begin
          ////////////////////////////////////////////////////////////////////////////
          // address latching
          axi_awaddr <= s_axi_awaddr;
        end
    end
end

////////////////////////////////////////////////////////////////////////////
// Implement axi_wready generation
//
//  axi_wready is asserted for one s_axi_aclk clock cycle when both
//  s_axi_awvalid and s_axi_wvalid are asserted. axi_wready is
//  de-asserted when reset is low.

always @( posedge s_axi_aclk )
begin
  if ( s_axi_aresetn == 1'b0 )
    begin
      axi_wready <= 1'b0;
    end
  else
    begin
      if (~axi_wready && s_axi_wvalid && s_axi_awvalid)
        begin
          ////////////////////////////////////////////////////////////////////////////
          // slave is ready to accept write data when
          // there is a valid write address and write data
          // on the write address and data bus. This design
          // expects no outstanding transactions.
          axi_wready <= 1'b1;
        end
      else
        begin
          axi_wready <= 1'b0;
        end
    end
end

////////////////////////////////////////////////////////////////////////////
// Implement memory mapped register select and write logic generation
//
// The write data is accepted and written to memory mapped
// registers when axi_wready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted.
// Write strobes are used to select byte enables of slave registers while writing.
//
// Slave register write enable is asserted when valid address and data are available
// and the slave is ready to accept the write address and write data.

assign  {o_slv_en7,
         o_slv_en6,
         o_slv_en5,
         o_slv_en4,
         o_slv_en3,
         o_slv_en2,
         o_slv_en1,
         o_slv_en0} = slv_en;

generate

   for (ix = 0; ix < SLV_CH_NUM; ix = ix+1) begin: gen_slv_en
assign slv_en_nxt[ix] = ~slv_en[ix] ?
                         ((s_axi_awready & s_axi_awvalid) &
                          (s_axi_awaddr >= SLV_BASE_ADDR[ix*S_AXI_ADDR_WID +: S_AXI_ADDR_WID] &&
                           s_axi_awaddr <= SLV_MAX_ADDR [ix*S_AXI_ADDR_WID +: S_AXI_ADDR_WID])
                         ) |
                         ((s_axi_arready & s_axi_arvalid) &
                          (s_axi_araddr >= SLV_BASE_ADDR[ix*S_AXI_ADDR_WID +: S_AXI_ADDR_WID] &&
                           s_axi_araddr <= SLV_MAX_ADDR [ix*S_AXI_ADDR_WID +: S_AXI_ADDR_WID])
                         ) :
                         ~((o_slv_we != 0) | (s_axi_rready & s_axi_rvalid));
   end
   for (ix = SLV_CH_NUM; ix < 8; ix = ix+1) begin: gen_slv_en_empty
assign slv_en_nxt[ix] = 0;
   end

endgenerate


assign o_slv_we_nxt   = {SLV_WE_WID{axi_wready & s_axi_wvalid}} & s_axi_wstrb[SLV_WE_WID-1:0];

always @* begin
   for (i = 0; i< SLV_WE_WID; i = i+1)
      o_slv_wd_nxt[i*(S_AXI_DATA_WID/SLV_WE_WID) +: S_AXI_DATA_WID/SLV_WE_WID] = o_slv_we_nxt[i] ?
       s_axi_wdata[i*(S_AXI_DATA_WID/SLV_WE_WID) +: S_AXI_DATA_WID/SLV_WE_WID] :
          o_slv_wd[i*(S_AXI_DATA_WID/SLV_WE_WID) +: S_AXI_DATA_WID/SLV_WE_WID];
end

assign o_slv_addr_nxt = ~axi_awready & s_axi_awvalid & s_axi_wvalid ? s_axi_awaddr[SLV_ADDR_WID-1:0] :
                         axi_arready & s_axi_arvalid                ? s_axi_araddr[SLV_ADDR_WID-1:0] : o_slv_addr;

assign slv_ren    = (slv_en != 0) & (o_slv_we == 0);

// latency between ren and read data valid
assign slv_rd_vld = T_A2RD_LAT == 0 ? slv_ren      :
                    T_A2RD_LAT == 1 ? slv_ren_q[0] : slv_ren_q[1];


always @( posedge s_axi_aclk )
begin
  if ( s_axi_aresetn == 1'b0 )
    begin
      slv_en        <= 8'h0;
      o_slv_we      <= {SLV_WE_WID{1'b1}};
      o_slv_addr    <= 0;
      o_slv_wd      <= 0;
      slv_rd_vld_q  <= 0;
      slv_ren_q     <= 0;
    end
  else
    begin
      slv_en        <= slv_en_nxt;
      o_slv_we      <= o_slv_we_nxt;
      o_slv_addr    <= o_slv_addr_nxt;
      o_slv_wd      <= o_slv_wd_nxt;
      slv_rd_vld_q  <= slv_rd_vld;
      slv_ren_q     <= {slv_ren_q[0], slv_ren};
    end
end

////////////////////////////////////////////////////////////////////////////
// Implement write response logic generation
//
//  The write response and response valid signals are asserted by the slave
//  when axi_wready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted.
//  This marks the acceptance of address and indicates the status of
//  write transaction.

always @( posedge s_axi_aclk )
begin
  if ( s_axi_aresetn == 1'b0 )
    begin
      axi_bvalid  <= 0;
      axi_bresp   <= 2'b0;
    end
  else
    begin
      if (axi_awready && s_axi_awvalid && ~axi_bvalid && axi_wready && s_axi_wvalid)
        begin
          // indicates a valid write response is available
          axi_bvalid <= 1'b1;
          axi_bresp  <= 2'b0; // 'OKAY' response
        end                   // work error responses in future
      else
        begin
          if (s_axi_bready && axi_bvalid)
            //check if bready is asserted while bvalid is high)
            //(there is a possibility that bready is always asserted high)
            begin
              axi_bvalid <= 1'b0;
            end
        end
    end
end


////////////////////////////////////////////////////////////////////////////
// Implement axi_arready generation
//
//  axi_arready is asserted for one s_axi_aclk clock cycle when
//  s_axi_arvalid is asserted. axi_awready is
//  de-asserted when reset (active low) is asserted.

assign  axi_arready_nxt = axi_arready ? ~s_axi_awvalid : s_axi_bvalid | s_axi_arvalid;


always @( posedge s_axi_aclk )
begin
  if ( s_axi_aresetn == 1'b0 )
    begin
      axi_arready <= 1'b1;
    end
  else
    begin
      axi_arready <= axi_arready_nxt;
    end
end

////////////////////////////////////////////////////////////////////////////
// Implement memory mapped register select and read logic generation
//
//  The slave registers data are available on the axi_rdata bus at this instance.
//  The assertion of axi_rvalid marks the validity of read data on the
//  bus and axi_rresp indicates the status of read transaction.axi_rvalid
//  is deasserted on reset (active low). axi_rresp and axi_rdata are
//  cleared to zero on reset (active low).

assign  axi_rvalid_nxt = ~axi_rvalid ? slv_rd_vld & ~slv_rd_vld_q : ~s_axi_rready;
assign  axi_rresp_nxt  =  slv_rd_vld ? 2'h0 : axi_rresp;

always @( posedge s_axi_aclk )
begin
  if ( s_axi_aresetn == 1'b0 )
    begin
      axi_rvalid    <= 0;
      axi_rresp     <= 0;
    end
  else
    begin
      axi_rvalid    <= axi_rvalid_nxt;
      axi_rresp     <= axi_rresp_nxt;
    end
end


////////////////////////////////////////////////////////////////////////////
// Slave register read enable is asserted when valid address is available
// and the slave is ready to accept the read address.

assign  axi_rdata_nxt = slv_rd_vld ? (i_slv_rd0 & {S_AXI_DATA_WID{o_slv_en0}}) |
                                     (i_slv_rd1 & {S_AXI_DATA_WID{o_slv_en1}}) |
                                     (i_slv_rd2 & {S_AXI_DATA_WID{o_slv_en2}}) |
                                     (i_slv_rd3 & {S_AXI_DATA_WID{o_slv_en3}}) |
                                     (i_slv_rd4 & {S_AXI_DATA_WID{o_slv_en4}}) |
                                     (i_slv_rd5 & {S_AXI_DATA_WID{o_slv_en5}}) |
                                     (i_slv_rd6 & {S_AXI_DATA_WID{o_slv_en6}}) |
                                     (i_slv_rd7 & {S_AXI_DATA_WID{o_slv_en7}}) : axi_rdata;

always @( posedge s_axi_aclk )
begin
  if ( s_axi_aresetn == 1'b0 )
    begin
      axi_rdata <= 0;
    end
  else
    begin
      axi_rdata <= axi_rdata_nxt;
    end
end


endmodule
