class axi_generator;
  mailbox mbox;
  int no_of_wr_txns = 0;

  function new();
    mbox = new();
  endfunction: new

  task run();
    axi_txn txn;

    for (int i = 0; i < no_of_wr_txns; i++) begin
      txn = new();
      assert(txn.randomize());
      mbox.put(txn);
      $display("drive_wr_addr: Send Write Txn %s", txn.convert2string());
    end
  endtask: run
endclass: axi_generator
