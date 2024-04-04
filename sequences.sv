/////////////////////////////////////////////////////////////////////////////////

class seq1 extends uvm_sequence #(packet); // write_data_fixed sequence
  `uvm_object_utils(seq1)
  
  packet pkt;
  
  function new(string path = "SEQ1");
    super.new(path);
  endfunction
  
  task body();
    pkt = packet::type_id::create("PKT");
    start_item(pkt);
    assert(pkt.randomize());
    pkt.awburst = fixed;
    pkt.seq = write_data_fixed;
    pkt.wid = pkt.awid;
    if (pkt.awsize == 0) pkt.wstrb = 4'b0001;
    else if (pkt.awsize == 1) pkt.wstrb = 4'b0011;
    else if (pkt.awsize == 2) pkt.wstrb = 4'b1111;
    for (int i = 0; i<= pkt.awlen;i++)
      begin
        pkt.wdata.push_back($urandom());
      end
    finish_item(pkt);
  endtask
endclass

/////////////////////////////////////////////////////////////////////////////////

class seq2 extends uvm_sequence #(packet); // write_data_incr sequence
  `uvm_object_utils(seq2)
  
  packet pkt;
  
  function new(string path = "SEQ2");
    super.new(path);
  endfunction
  
  task body();
    pkt = packet::type_id::create("PKT");
    start_item(pkt);
    assert(pkt.randomize());
    pkt.awburst = incr;
    pkt.seq = write_data_incr;
    pkt.wid = pkt.awid;
    if (pkt.awsize == 0) pkt.wstrb = 4'b0001;
    else if (pkt.awsize == 1) pkt.wstrb = 4'b0011;
    else if (pkt.awsize == 2) pkt.wstrb = 4'b1111;
    for (int i = 0; i<= pkt.awlen;i++)
      begin
        pkt.wdata.push_back($urandom());
      end
    finish_item(pkt);
  endtask
endclass

/////////////////////////////////////////////////////////////////////////////////

class seq3 extends uvm_sequence #(packet); // write_data_wrap sequence
  `uvm_object_utils(seq3)
  
  packet pkt;
  
  function new(string path = "SEQ3");
    super.new(path);
  endfunction
  
  task body();
    pkt = packet::type_id::create("PKT");
    start_item(pkt);
    assert(pkt.randomize());
    pkt.awburst = wrap;
    pkt.seq = write_data_wrap;
    pkt.wid = pkt.awid;
    if (pkt.awsize == 0) pkt.wstrb = 4'b0001;
    else if (pkt.awsize == 1) pkt.wstrb = 4'b0011;
    else if (pkt.awsize == 2) pkt.wstrb = 4'b1111;
    for (int i = 0; i<= pkt.awlen;i++)
      begin
        pkt.wdata.push_back($urandom());
      end
    finish_item(pkt);
  endtask
endclass

/////////////////////////////////////////////////////////////////////////////////

class seq4 extends uvm_sequence #(packet); // read_data_fixed sequence
  `uvm_object_utils(seq4)
  
  packet pkt;
  
  function new(string path = "SEQ4");
    super.new(path);
  endfunction
  
  task body();
    pkt = packet::type_id::create("PKT");
    start_item(pkt);
    assert(pkt.randomize());
    pkt.arburst = fixed;
    pkt.seq = read_data_fixed;
    finish_item(pkt);
  endtask
endclass

/////////////////////////////////////////////////////////////////////////////////

class seq5 extends uvm_sequence #(packet); // read_data_incr sequence
  `uvm_object_utils(seq5)
  
  packet pkt;
  
  function new(string path = "SEQ5");
    super.new(path);
  endfunction
  
  task body();
    pkt = packet::type_id::create("PKT");
    start_item(pkt);
    assert(pkt.randomize());
    pkt.arburst = incr;
    pkt.seq = read_data_incr;
    finish_item(pkt);
  endtask
endclass

/////////////////////////////////////////////////////////////////////////////////

class seq6 extends uvm_sequence #(packet); // read_data_wrap sequence
  `uvm_object_utils(seq6)
  
  packet pkt;
  
  function new(string path = "SEQ6");
    super.new(path);
  endfunction
  
  task body();
    pkt = packet::type_id::create("PKT");
    start_item(pkt);
    assert(pkt.randomize());
    pkt.arburst = wrap;
    pkt.seq = read_data_wrap;
    finish_item(pkt);
  endtask
endclass

/////////////////////////////////////////////////////////////////////////////////

class seq7 extends uvm_sequence #(packet); // read_write_fixed sequence
  `uvm_object_utils(seq7)
  
  packet pkt;
  
  function new(string path = "SEQ7");
    super.new(path);
  endfunction
  
  task body();
    pkt = packet::type_id::create("PKT");
    start_item(pkt);
    assert(pkt.randomize());
    pkt.awburst = fixed;
    pkt.seq = read_write_fixed;
    pkt.wid = pkt.awid;
    if (pkt.awsize == 0) pkt.wstrb = 4'b0001;
    else if (pkt.awsize == 1) pkt.wstrb = 4'b0011;
    else if (pkt.awsize == 2) pkt.wstrb = 4'b1111;
    pkt.arburst = fixed;
    for (int i = 0; i<= pkt.awlen;i++)
      begin
        pkt.wdata.push_back($urandom());
      end
    finish_item(pkt);
  endtask
endclass

/////////////////////////////////////////////////////////////////////////////////

class seq8 extends uvm_sequence #(packet); // read_write_incr sequence
  `uvm_object_utils(seq8)
  
  packet pkt;
  
  function new(string path = "SEQ8");
    super.new(path);
  endfunction
  
  task body();
    pkt = packet::type_id::create("PKT");
    start_item(pkt);
    assert(pkt.randomize());
    pkt.awburst = incr;
    pkt.seq = read_write_incr;
    pkt.wid = pkt.awid;
    if (pkt.awsize == 0) pkt.wstrb = 4'b0001;
    else if (pkt.awsize == 1) pkt.wstrb = 4'b0011;
    else if (pkt.awsize == 2) pkt.wstrb = 4'b1111;
    for (int i = 0; i<= pkt.awlen;i++)
      begin
        pkt.wdata.push_back($urandom());
      end
    pkt.arburst = incr;
    finish_item(pkt);
  endtask
endclass

/////////////////////////////////////////////////////////////////////////////////

class seq9 extends uvm_sequence #(packet); // read_write_wrap sequence
  `uvm_object_utils(seq9)
  
  packet pkt;
  
  function new(string path = "SEQ9");
    super.new(path);
  endfunction
  
  task body();
    pkt = packet::type_id::create("PKT");
    start_item(pkt);
    assert(pkt.randomize());
    pkt.awburst = wrap;
    pkt.seq = read_write_wrap;
    pkt.wid = pkt.awid;
    if (pkt.awsize == 0) pkt.wstrb = 4'b0001;
    else if (pkt.awsize == 1) pkt.wstrb = 4'b0011;
    else if (pkt.awsize == 2) pkt.wstrb = 4'b1111;
    for (int i = 0; i<= pkt.awlen;i++)
      begin
        pkt.wdata.push_back($urandom());
      end
    pkt.arburst = wrap;
    finish_item(pkt);
  endtask
endclass

////////////////////////////////////////////////////////////////////////////////
