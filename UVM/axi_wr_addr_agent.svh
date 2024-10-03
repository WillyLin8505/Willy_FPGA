// ****************************** AXI Sequencer ******************************
class axi_wr_addr_sequencer extends uvm_sequencer #(axi_txn, axi_txn);
  `uvm_component_utils(axi_wr_addr_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
  endtask: run_phase
endclass: axi_wr_addr_sequencer

typedef uvm_sequencer #(axi_txn, axi_txn) axi_wr_addr_sequencer;


// ****************************** AXI Master Driver **************************
class axi_wr_addr_driver extends uvm_driver #(axi_txn, axi_txn);
  `uvm_component_utils(axi_wr_addr_driver)

  virtual axi_wr_addr_intf m_intf;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    axi_txn txn;

    if(null == m_intf) begin
      `uvm_fatal("run_phase", "Interface handle in null at run phase")
    end

    // Initialize signals
    init_signals();

    // wait_for_reset
    wait(!m_intf.rst);
    @(posedge m_intf.rst);

    // Drive txns
    forever begin
      seq_item_port.get_next_item(txn);
      drive_wr_addr(txn);
      seq_item_port.item_done();
    end
  endtask: run_phase

  task drive_wr_addr(axi_txn txn);
    while(!m_intf.awready) @(posedge m_intf.clk);
    m_intf.awid    <= txn.id;
    m_intf.awlen   <= txn.length;
    m_intf.awaddr  <= txn.addr;
    m_intf.awvalid <= 'b1;
    @(posedge m_intf.clk);
    m_intf.awvalid <= 'b0;

    `uvm_info("drive_wr_addr", $sformatf("Send Write Txn %s", txn.convert2string()), UVM_MEDIUM)
  endtask: drive_wr_addr

  task init_signals();
    m_intf.awvalid <= 1'b0;
  endtask: init_signals
endclass: axi_wr_addr_driver


// ****************************** AXI Agent ******************************
class axi_wr_addr_agent extends uvm_agent;
  `uvm_component_utils(axi_wr_addr_agent)

  axi_wr_addr_sequencer m_sequencer;
  axi_wr_addr_driver    m_driver;

  virtual axi_wr_addr_intf m_intf;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual axi_wr_addr_intf)::get(this, "", "axi_wr_addr_intf1", m_intf)) begin
      `uvm_error("build_phase", "ConfigDB: Unable to get axi_wr_addr_intf1");
    end

    m_sequencer = axi_wr_addr_sequencer::type_id::create("m_sequencer", this);
    m_driver = axi_wr_addr_driver::type_id::create("m_driver", this);
    m_driver.m_intf = m_intf;
  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase();

    // Connect the Analysis ports
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction: connect_phase

  virtual task run_phase(uvm_phase phase);
  endtask: run_phase
endclass: axi_wr_addr_agent
