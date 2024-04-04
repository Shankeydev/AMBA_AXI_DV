class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  packet pkt;
  virtual axi_if vif;
  uvm_analysis_port #(packet) send;
  bit [31:0] write_data[$];
  
  function new(string path = "MON", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("MON","inside build_phase of monitor",UVM_NONE)
    super.build_phase(phase);
    pkt = packet::type_id::create("PKT");
    send = new("send", this);
    if(!uvm_config_db #(virtual axi_if)::get(this,"","vif",vif))
      begin
        `uvm_error("MON","cannot connect with interface")
      end   
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    @(posedge vif.arstn);
    forever begin
      fork
        begin  // for write transaction
          @(posedge vif.axi_cb.awready);
//           @(posedge vif.axi_cb);
          pkt.awid = vif.axi_cb.awid;
          pkt.awlen = vif.axi_cb.awlen;
          pkt.awsize = vif.axi_cb.awsize;
//           pkt.awburst = vif.axi_cb.awburst;
          pkt.awaddr = vif.axi_cb.awaddr;
          @(posedge vif.axi_cb.wvalid);
          pkt.wid = vif.axi_cb.wid;
          pkt.wstrb = vif.axi_cb.wstrb;
          pkt.wlast = vif.axi_cb.wlast;
          for (int i = 0; i <= vif.axi_cb.awlen; i++)
            begin
              pkt.wdata.push_back(vif.axi_cb.wdata);
              repeat (2) @(posedge vif.axi_cb);
              $display("*** %0d***", pkt.wdata[i]);
            end
//           @(posedge vif.axi_cb.bvalid);
          pkt.bid = vif.axi_cb.bid;
          pkt.bresp = vif.axi_cb.bresp;
          $display("write done");
//           send.write(pkt);
        end
        begin  // for read transactions
          @(posedge vif.axi_cb);
          @(posedge vif.axi_cb.arready);
          @(posedge vif.axi_cb);
          $display("=+-*/*-+");
          pkt.arid = vif.axi_cb.arid;
          pkt.arlen = vif.axi_cb.arlen;
          pkt.arsize = vif.axi_cb.arsize;
//           pkt.arburst = vif.axi_cb.arburst;
          pkt.araddr = vif.axi_cb.araddr;
          @(posedge vif.axi_cb.rvalid);
          $display("=+-*/*-+");
          pkt.rid = vif.axi_cb.rid;
          pkt.rresp = vif.axi_cb.rresp;
          pkt.rlast = vif.axi_cb.rlast;
          for (int i = 0; i <= vif.axi_cb.arlen; i++)
            begin
              pkt.rdata.push_back(vif.axi_cb.rdata);
              repeat (2) @(posedge vif.axi_cb);
            end
          $display("read done");
        end
      join
      send.write(pkt);
    end
    
  endtask
endclass