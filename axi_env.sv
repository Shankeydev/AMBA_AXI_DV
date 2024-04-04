class env extends uvm_env;
  `uvm_component_utils(env)
  
  scoreboard sb;
  agent a;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb = scoreboard::type_id::create("SB", this);
    a = agent::type_id::create("agent",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(sb.recv);
  endfunction
endclass