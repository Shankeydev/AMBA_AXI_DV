`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi_slave.sv"
`include "axi_agent.sv"
`include "axi_env.sv"
`include "axi_drv.sv"
`include "axi_monitor.sv"
`include "axi_scoreboard.sv"
`include "sequences.sv"
`include "axi_packet.sv"
`include "interface.sv"
`include "axi_test.sv"

module top;
  reg aclk;
  
  axi_if vif(aclk);
  
  axi_slave dut(
  // Global signals
  .aclk(vif.aclk),
  .arstn(vif.arstn),

  // Write address channel
  .awvalid(vif.awvalid),
  .awready(vif.awready),
  .awid(vif.awid),
  .awlen(vif.awlen),
  .awsize(vif.awsize),
  .awburst(vif.awburst),
  .awaddr(vif.awaddr),

  // Write data channel
  .wvalid(vif.wvalid),
  .wready(vif.wready),
  .wid(vif.wid),
  .wdata(vif.wdata),
  .wstrb(vif.wstrb),
  .wlast(vif.wlast),

  // Write response channel
  .bready(vif.bready),
  .bvalid(vif.bvalid),
  .bid(vif.bid),
  .bresp(vif.bresp),

  // Read address channel
  .arvalid(vif.arvalid),
  .arready(vif.arready),
  .arid(vif.arid),
  .arlen(vif.arlen),
  .arsize(vif.arsize),
  .arburst(vif.arburst),
  .araddr(vif.araddr),

  // Read data channel
  .rvalid(vif.rvalid),
  .rready(vif.rready),
  .rdata(vif.rdata),
  .rresp(vif.rresp),
  .rlast(vif.rlast),
  .rid(vif.rid)
);

  
  initial begin
    aclk = 0;
  end
  
  initial begin
    uvm_config_db #(virtual axi_if)::set(null,"*","vif",vif);
    run_test("test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  always #10 aclk = ~aclk;
endmodule