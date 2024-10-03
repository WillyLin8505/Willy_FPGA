// *************************** AXI Sequence **************************
class axi_sequence extends uvm_sequence #(axi_txn);
  `uvm_object_utils(axi_sequence)

  int no_of_wr_txns = 0;

  function new(string name = "");
    super.new(name);
  endfunction: new

  virtual task body();
    send_wr_txn();
  endtask: body

  virtual task send_wr_txn();
    axi_txn txn;

    for (int i = 0; i < no_of_wr_txns; i++) begin
      txn = axi_txn::type_id::create("wr_addr_txn");
      assert(txn.randomize());
      start_item(txn);
      finish_item(txn);
    end

    // get_response(resp_txn);
    `uvm_info("send_wr_txn", $sformatf("Sending AXI Write txn %s", txn.convert2string()), UVM_MEDIUM)
  endtask: send_wr_txn

endclass: axi_sequence
