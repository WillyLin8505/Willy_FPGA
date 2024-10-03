module test_bench();

  logic clk, rst;
  int no_of_wr_txns = 10;

  // Instantiation
  sample_dut sample_dut1(.axi_wr_addr_intf1(m_intf), .*); 
  axi_wr_addr_intf m_intf(clk, rst);

  // Adding all signal to waveform viewer
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test_bench);
  end

  // Clock and reset generation
  initial begin
    clk = 1; forever #500 clk = ~clk;
  end

  initial begin
    rst = 1;
    repeat(1) @(posedge clk);
    rst = 0;
    repeat(4) @(posedge clk);
    rst = 1;
  end

  // TB Functional Code
  initial begin
    // Initialise signals.
    init_signals();

    // wait_for_reset
    wait(!m_intf.rst);
    @(posedge m_intf.rst);

    // Drive txns
    for(int i = 0; i < 10; i++) begin
      drive_wr_addr();
    end

    $finish("Completed sending all txns");
  end

task drive_wr_addr();

  while( !m_intf.awready) @(posedge m_intf.clk);
  m_intf.awid    <= $urandom();
  m_intf.awlen   <= $urandom();
  m_intf.awaddr  <= $urandom();
  m_intf.awvalid <= 'b1;
  @(posedge m_intf.clk);
  m_intf.awvalid <= 'b0;

  $display("drive_wr_addr: Send Write Txn. ID=%0h, Addr=%0h, length=%0d", m_intf.awid, m_intf.awaddr, m_intf.awlen);

endtask: drive_wr_addr

task init_signals();
  m_intf.awvalid <= 'b0;
endtask: init_signals

endmodule: test_bench

