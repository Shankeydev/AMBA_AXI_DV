class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp #(packet,scoreboard) recv;
  packet pkt;
  byte j;
  reg [7:0]mem[0:127] = '{default:0};
  
  function new(string path = "SB", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("SB","inside build phase of sb", "UVM_NONE")
    super.build_phase(phase);
    recv = new("recv", this);
  endfunction
  
  virtual function void write(packet pkt);
    this.pkt = pkt;
    mem_write(pkt);
    comp(pkt);
   endfunction
  
  function mem_write(packet p);
    reg [31:0] next_addr;
    next_addr  = p.awaddr;
    unique case(p.wstrb)
      4'b0001:
        begin
          for (int i=0;i<=p.awlen;i++)
            begin
              mem[next_addr] = p.wdata[i][7:0];
              next_addr = next_addr + 1;
              $display("write : mem[%d] = %d", next_addr, mem[next_addr]);
            end
        end
      4'b0011:
        begin
          for (int i=0;i<=p.awlen;i++)
            begin
              mem[next_addr] = p.wdata[i][7:0];
              mem[next_addr+1] = p.wdata[i][15:8];
              $display("for test %0d", p.wdata[i]);
              $display("write : mem[%d] = %d", next_addr, mem[next_addr]);
              $display("write : mem[%d] = %d", (next_addr + 1), mem[next_addr+1]);
              next_addr = next_addr + 2;
              
            end
        end
      4'b1111:
        begin
          for (int i=0;i<=p.awlen;i++)
            begin
              mem[next_addr] = p.wdata[i][7:0];
              mem[next_addr+1] = p.wdata[i][15:8];
              mem[next_addr+2] = p.wdata[i][23:16];
              mem[next_addr+3] = p.wdata[i][31:24];
              $display("write : mem[%d] = %d", next_addr, mem[next_addr]);
              $display("write : mem[%d] = %d", (next_addr + 1), mem[next_addr+1]);
              $display("write : mem[%d] = %d", (next_addr + 2), mem[next_addr+2]);
              $display("write : mem[%d] = %d", (next_addr + 3), mem[next_addr+3]);
              next_addr = next_addr + 4;
            end
        end
    endcase
  endfunction
  
  function comp(packet p);
    int j = 0;
    reg[31:0] next_addr;
    next_addr = p.araddr;
    unique case(p.arsize)
      3'd0:
        begin
          for(int i = 0; i<=p.arlen; i++)
            begin
              if(mem[next_addr] == p.rdata[i][7:0])
                begin
                  j = j + 1;
                end
              next_addr = next_addr+1;
            end
          if (j == p.arlen + 1)
                begin
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                  $display("***********TEST PASSED*************");
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                end
              else 
                begin
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                  $display("***********TEST FAILED*************");
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                end
        end
      3'd1:
        begin
          for(int i = 0; i<=p.arlen; i++)
            begin
              if(mem[next_addr] == p.rdata[i][7:0] && mem[next_addr+1]== p.rdata[i][15:8])
                begin
                  j = j + 1;
                end
              next_addr = next_addr+2;
            end
          if (j == p.arlen + 1)
                begin
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                  $display("***********TEST PASSED*************");
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                end
              else 
                begin
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                  $display("***********TEST FAILED*************");
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                end
            end
      3'd2:
        begin
          for(int i = 0; i<=p.arlen; i++)
            begin
              if(mem[next_addr] == p.rdata[i][7:0] && mem[next_addr+1]== p.rdata[i][15:8] && mem[next_addr] == p.rdata[i][23:16] && mem[next_addr+1]== p.rdata[i][31:24])
                begin
                  j = j + 1;
                end
              next_addr = next_addr+4;
            end
          if (j == p.arlen + 1)
                begin
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                  $display("***********TEST PASSED*************");
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                end
              else 
                begin
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                  $display("***********TEST FAILED*************");
                  $display("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                end
        end
    endcase
  endfunction
  
endclass