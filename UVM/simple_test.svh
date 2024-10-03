class sample_test extends uvm_test;
  `uvm_component_utils(sample_test)

  sample_env m_env;
  axi_sequence m_seq;

  function new(string name = "tb_test_base", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_env = sample_env::type_id::create("sample_env", this);
    m_seq = axi_sequence::type_id::create("axi_sequence", this);
  endfunction: build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    // Select verbosity among UVM_NONE, UVM_LOW, UVM_MEDIUM, UVM_HIGH, UVM_FULL, UVM_DEBUG
    uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
    this.print();
  endfunction: end_of_elaboration_phase

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this, "Starting TB Test functionality");

    uvm_info("run_phase", "Test begins", UVM_MEDIUM);
    m_seq.no_of_wr_txns = 10;
    m_seq.start(m_env.m_axi_agent.m_sequencer);

    `uvm_info("run_phase", "Test ends", UVM_MEDIUM);
    phase.drop_objection(this, "End of TB Test functionality");
  endtask: run_phase
endclass: sample_test
