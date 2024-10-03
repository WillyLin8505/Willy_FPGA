class axi_wr_addr_driver;
  mailbox mbox;
  int no_of_wr_txns = 0;
  virtual axi_wr_addr_intf m_intf;

  function new();
    mbox = new();
  endfunction: new

  virtual task run();
    axi_txn txn;

    if (null == m_intf) begin
      $display("run: ERROR: Interface handle in null at run phase");
    end

    // Initialize signals
    init_signals();

    // wait_for_reset
    wait(!m_intf.rst);
    @(posedge m_intf.rst);

    // Drive txns
    for (int i = 0; i < no_of_wr_txns; i++) begin
      mbox.get(txn);
      drive_wr_addr(txn);
    end
  endtask: run

  task drive_wr_addr(axi_txn txn);
    while(!m_intf.awready) @(posedge m_intf.clk);
    m_intf.awid    <= txn.id;
    m_intf.awlen   <= txn.length;
    m_intf.awaddr  <= txn.addr;
    m_intf.awvalid <= 'b1;
    @(posedge m_intf.clk);
    m_intf.awvalid <= 'b0;

    $display("drive_wr_addr: Send Write Txn %s", txn.convert2string());
  endtask: drive_wr_addr

  task init_signals();
    m_intf.awvalid <= 1'b0;
  endtask: init_signals
endclass: axi_wr_addr_driver
