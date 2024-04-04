class driver extends uvm_driver #(packet);
  `uvm_component_utils(driver)
  
  packet pkt;
  virtual axi_if vif;
  
  function new(string path = "DRV", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("DRV","inside build_phase of drv",UVM_NONE)
    super.build_phase(phase);
    pkt = packet::type_id::create("PKT");
    if(!uvm_config_db #(virtual axi_if)::get(this,"","vif",vif))
      begin
        `uvm_error("DRV","cannot connect with interface")
      end   
  endfunction
  
  task reset_dut();
    vif.arstn <= 0;
    repeat (2) @(posedge vif.axi_cb);
    vif.arstn <= 1;
  endtask
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info("DRV","inside run_phase of driver",UVM_NONE)
    reset_dut();
    @(posedge vif.arstn);
    `uvm_info("DRV","DUT reset done",UVM_NONE)
    forever begin
      seq_item_port.get_next_item(pkt);
      drive_dut(pkt);
      seq_item_port.item_done();
    end    
  endtask
  
  task drive_dut(packet tx);
    case (tx.seq)
      write_data_fixed : 
        begin
          vif.axi_cb.awburst <= 2'b00;
          write_addr(tx);
		  write_data(tx);
		  write_resp(tx);
        end
      write_data_incr : 
        begin
          vif.axi_cb.awburst <= 2'b01;
          write_addr(tx);
		  write_data(tx);
		  write_resp(tx);
        end
      write_data_wrap : 
        begin
          vif.axi_cb.awburst <= 2'b10;
          write_addr(tx);
		  write_data(tx);
		  write_resp(tx);
        end
      read_data_fixed : 
        begin
          vif.axi_cb.arburst <= 2'b00;
          @(posedge vif.axi_cb);
          read_addr(tx);
		  read_data(tx);
        end
      read_data_incr : 
        begin
          vif.axi_cb.arburst <= 2'b01;
          @(posedge vif.axi_cb);
          read_addr(tx);
		  read_data(tx);
        end
      read_data_wrap : 
        begin
          vif.axi_cb.arburst <= 2'b10;
          @(posedge vif.axi_cb);
          read_addr(tx);
		  read_data(tx);
        end
      read_write_fixed : 
        begin
          fork
            begin
              vif.axi_cb.awburst <= 2'b00;
              write_addr(tx);
              write_data(tx);
              write_resp(tx);
            end
            begin
              vif.axi_cb.arburst <= 2'b00;
              @(posedge vif.axi_cb);
              read_addr(tx);
              read_data(tx);
            end
          join
        end
      read_write_incr : 
        begin
          fork
            begin
              vif.axi_cb.awburst <= 2'b01;
              write_addr(tx);
              write_data(tx);
              write_resp(tx);
            end
            begin
              vif.axi_cb.arburst <= 2'b01;
              @(posedge vif.axi_cb);
              read_addr(tx);
              read_data(tx);
            end
          join
        end
      read_write_wrap : 
        begin
          fork
            begin
              vif.axi_cb.awburst <= 2'b10;
              write_addr(tx);
              write_data(tx);
              write_resp(tx);
            end
            begin
              vif.axi_cb.arburst <= 2'b10;
              @(posedge vif.axi_cb);
              read_addr(tx);
              read_data(tx);
            end
          join
        end
    endcase
  endtask
  
  // write address task
  
  task write_addr(packet pkt);
    vif.axi_cb.awvalid <= 1'b1;
    vif.axi_cb.awaddr <= pkt.awaddr;
    vif.axi_cb.awlen <= pkt.awlen;
    vif.axi_cb.awsize <= pkt.awsize;
    vif.axi_cb.awid <= pkt.awid;
    while (!vif.axi_cb.awready) @(vif.axi_cb);
    @(vif.axi_cb);
  endtask
  
  // write data task
  
  task write_data(packet pkt);
    vif.axi_cb.wlast <= 1'b0;
    vif.axi_cb.wvalid <= 1'b1;
    vif.axi_cb.wid <= pkt.wid;
    vif.axi_cb.wstrb <= pkt.wstrb;
    for (int i = 0; i <= pkt.awlen; i++) begin
      vif.axi_cb.wdata <= pkt.wdata.pop_front();
      if (i == pkt.awlen)
          pkt.wlast = 1'b1;
      else
          pkt.wlast = 1'b0;
      vif.axi_cb.wlast <= pkt.wlast;
      repeat (2) @(posedge vif.axi_cb);
	end
    vif.axi_cb.wvalid <= 1'b0;
   while (!vif.axi_cb.wready) @(vif.axi_cb);
  endtask
  
  // write resp task
  
  task write_resp(packet pkt);
    vif.axi_cb.bready <= 1'b1;
    while (vif.axi_cb.bvalid==0) @(vif.axi_cb);
    pkt.bresp <= vif.axi_cb.bresp;
    pkt.bid <= vif.axi_cb.bid;
  endtask
  
  // read address task
  
  task read_addr(packet pkt);
    vif.axi_cb.arvalid <= 1'b1;
    vif.axi_cb.araddr <= pkt.araddr;
    vif.axi_cb.arlen <= pkt.arlen;
    vif.axi_cb.arsize <= pkt.arsize;
    vif.axi_cb.arid <= pkt.arid;
    @(vif.axi_cb);
    vif.axi_cb.arvalid <= 1'b0;
    while (!vif.axi_cb.arready) @(vif.axi_cb);
  endtask
  
  // read data task
  
  task read_data(packet pkt);
    vif.axi_cb.rready <= 1;
    while (!vif.axi_cb.rvalid) @(posedge vif.axi_cb);
    for (int i = 0 ; i<= pkt.arlen; i++)
      begin
        repeat (2) @(posedge vif.axi_cb);
        pkt.rdata.push_back(vif.axi_cb.rdata);
      end
    pkt.rid <= vif.axi_cb.rid;
    pkt.rresp <= vif.axi_cb.rresp;
    pkt.rlast <= vif.axi_cb.rlast;
  endtask
endclass