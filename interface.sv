interface axi_if(input logic aclk);
  logic arstn;
  logic awready,awvalid;
  logic wready,wvalid;
  logic bready,bvalid;
  logic arready,arvalid;
  logic rready,rvalid;
  logic [3:0] awid,awlen;
  logic [3:0] arid,arlen;
  logic [3:0] bid,wid,rid;
  logic [2:0] arsize,awsize;
  logic [1:0] arburst,awburst;
  logic [31:0] araddr,awaddr;
  logic [31:0] wdata,rdata;
  logic [3:0] wstrb; 
  logic rlast,wlast;
  logic [1:0] rresp,bresp;
  
  clocking axi_cb @(posedge aclk);
    default input #1ns output #3ns;
    output awaddr,awvalid,awlen,awburst,awsize,awid,wdata,wstrb,wvalid,wlast,
           wid, bready,araddr,arvalid,arsize,arlen,arburst,arid,rready;
    input awready,bvalid,bresp,bid,arready,rdata,rresp,rid,rlast,rvalid,wready;
  endclocking
endinterface