typedef enum bit[3:0] {write_data_fixed = 0, read_data_fixed = 1, read_write_fixed = 2, write_data_incr = 3, read_data_incr = 4, read_write_incr = 5, write_data_wrap = 6, read_data_wrap = 7, read_write_wrap = 8} seq_type;
typedef enum bit[1:0] {fixed = 0, incr = 1, wrap = 2} burst_type;

class packet extends uvm_sequence_item;
  `uvm_object_utils(packet)
  
  seq_type seq;
  // write address
  
  rand bit[3:0] awid;
  rand bit[3:0] awlen;
  rand bit[2:0] awsize;
  burst_type awburst;
  rand bit[31:0] awaddr;
  
  //write data
  
  bit[3:0] wid;
  bit[31:0] wdata [$];
  bit [4:0] wstrb;
  bit wlast;
  
  //write response channel
  
  bit[3:0] bid;
  bit[1:0] bresp;
  
  // read data channel
  
  rand bit[3:0] arid;
  rand bit[3:0] arlen;
  rand bit[2:0] arsize;
  burst_type arburst;
  rand bit[31:0] araddr;
  
  //read data channel
  
  bit[31:0] rdata[$];
  bit[1:0] rresp;
  bit rlast;
  bit[3:0] rid;
  
  constraint cons1 {awaddr inside{[0:127]};}
  constraint cons2 { araddr == awaddr; }
  constraint cons3 {arsize inside {0,1,2};}
  constraint cons4 {awsize inside {0,1,2};}
  constraint cons5 {awlen inside {1,3,7,15};}
  constraint cons6 {arlen inside {1,3,7,15};}
  
//   `uvm_object_utils_begin(packet)
//   `uvm_field_int(awid, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(awlen, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(awsize, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(awaddr, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(wid, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(wdata, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(wstrb, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(wlast, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(bid, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(bresp, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(araddr, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(arid, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(arlen, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(arsize, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_queue_int(rdata,UVM_DEFAULT)
//   `uvm_field_int(rresp, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(rlast, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_int(rid, UVM_DEFAULT+UVM_DEC)
//   `uvm_field_enum(seq_type,seq,UVM_DEFAULT)
//   `uvm_field_enum(burst_type,awburst,UVM_DEFAULT)
//   `uvm_field_enum(burst_type,arburst,UVM_DEFAULT)
//   `uvm_object_utils_end
  
  function new(string path = "PKT");
    super.new(path);
  endfunction
  
endclass