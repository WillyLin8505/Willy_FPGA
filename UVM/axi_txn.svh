// *************************** AXI Tnx ***************************
class axi_txn;
  rand bit [3:0] id;
  rand bit [3:0] length;
  rand bit [31:0] addr;

  function new();
    // Initialize length to 0 to avoid hang in functions when the txn is used as monitor txn
    length = 0;
  endfunction: new

  constraint data_length { length >= 1; }

  function void copy(axi_txn rhs);
    axi_txn l_rhs;

    if(!$cast(l_rhs, rhs)) begin
      $display("copy: ERROR. Casting of rhs txn to AXI txn failed ");
    end

    this.id     = l_rhs.id;
    this.length = l_rhs.length;
    this.addr   = l_rhs.addr;
  endfunction: copy

  function string convert2string();
    string rpt;
    $sformat(rpt, "id=%0h, addr=%0h length=%0h", id, addr, length);
    return rpt;
  endfunction: convert2string
endclass: axi_txn
