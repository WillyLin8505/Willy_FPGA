// ****************************** Interconnect ENV ******************************
class sample_env extends uvm_env;
  `uvm_component_utils(sample_env)

  axi_wr_addr_agent m_axi_agent;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_axi_agent = axi_wr_addr_agent::type_id::create("axi_wr_addr_agent", this);
  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction: connect_phase

  task run_phase(uvm_phase phase);
  endtask: run_phase
endclass: sample_env
