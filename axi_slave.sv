`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

module axi_slave( // global signals
                  input aclk,arstn,
                  // write address channel
                  input awvalid,
                  output reg awready,
                  input [3:0] awid,
                  input [3:0] awlen,
                  input [2:0] awsize,
                  input [1:0] awburst,
                  input[31:0] awaddr,
                  // write data channel
                  input wvalid,
                  output reg wready,
                  input [3:0] wid,
                  input [31:0] wdata,
                  input [3:0] wstrb,
                  input wlast,
                  //write response channel
                  input bready,
                  output reg bvalid,
                  output reg [3:0] bid,
                  output reg [1:0] bresp,
                  // read address channel
                  input arvalid,
                  output reg arready,
                  input [3:0] arid,
                  input [3:0] arlen,
                  input [2:0] arsize,
                  input [1:0] arburst,
                  input [31:0] araddr,
                  // read data channel
                  output reg rvalid,
                  input rready,
                  output reg [31:0] rdata,
                  output reg [1:0] rresp,
                  output reg rlast,
                  output reg [3:0] rid);
  
  typedef enum bit[1:0] {awidle = 0, awstart = 1, awreadys = 2} awstate_type;

  awstate_type aw_state, awnext_state;
  
  reg [31:0] awaddrt;
  
    reg [7:0] boundry;
  reg [3:0] wlen_count;
  reg [31:0] wdatat;
  reg [7:0]mem[0:127] = '{default:0};
  reg [31:0] nextaddr;
  reg [31:0] retaddr;
  reg first; // to detect first transfer of the transaction
  
    typedef enum bit [1:0] {bidle = 0, bdetect_last = 1, bstart = 2, bwait = 3} bstate_type;
  bstate_type b_state,bnext_state;
  
  typedef enum bit[1:0] {widle = 0, wstart = 1, wreadys = 2, wlasts = 3} wstate_type;
  wstate_type wstate, wnext_state;
  
  
  always_ff@(posedge aclk, negedge arstn)
    begin
      if  (!arstn)
        begin
          aw_state <= awidle;
          wstate <= widle;
          b_state <= bidle;
        end
      else 
        begin
          aw_state <= awnext_state;
          wstate <= wnext_state;
          b_state <= bnext_state;
        end
    end
  
  // write address channel
  
  always_comb
    begin
      case(aw_state)
        awidle:
          begin
            awready = 1'b0;
            awnext_state = awstart;
          end
        awstart:
          begin
            awready = 1'b1;
            if (awvalid && awready)
              begin
                awnext_state = awreadys; 
                awaddrt = awaddr;
              end
            else awnext_state = awstart;
          end
        awreadys:
          begin
            awready = 1'b0;
            if (wstate == wreadys) awnext_state = awidle;
            else awnext_state = awreadys;
          end
      endcase
    end
  
  // wride data channel
  
  
  
  // function to compute next address for fixted burst type
  
  function bit[31:0] fixed_type (input [3:0] wstrb, input [31:0] awaddrt);
   unique case (wstrb)
      4'b0001: mem[awaddrt] = wdatat[7:0];
      4'b0010: mem[awaddrt] = wdatat[15:8];
      4'b0100: mem[awaddrt] = wdatat[23:16];
      4'b1000: mem[awaddrt] = wdatat[31:24];
      4'b0011: 
        begin
          mem[awaddrt] = wdatat[7:0];
          mem[awaddrt + 1] = wdatat[15:8];
        end
      4'b1100:
        begin
          mem[awaddrt] = wdatat[23:16];
          mem[awaddrt + 1] = wdatat[31:24];
        end
      4'b1111:
        begin
          mem[awaddrt] = wdatat[7:0];
          mem[awaddrt + 1] = wdatat[15:8];
          mem[awaddrt + 2] = wdatat[23:16];
          mem[awaddrt + 3] = wdatat[31:24];
        end
    endcase
    return awaddrt;
  endfunction
  
  // function to compute next address for incr burst type
  
  function bit[31:0] incr_type(input [3:0] wstrb, input [31:0] awaddrt);
   unique case (wstrb)
      4'b0001:
        begin
          mem[awaddrt] = wdatat[7:0];
          awaddrt = awaddrt + 1;
        end
      4'b0010:
        begin
          mem[awaddrt] = wdatat[15:8];
          awaddrt = awaddrt + 1;
        end
      4'b0100:
        begin
          mem[awaddrt] = wdatat[23:16];
          awaddrt = awaddrt + 1;
        end
      4'b1000:
        begin
          mem[awaddrt] = wdatat[31:24];
          awaddrt = awaddrt + 1;
        end
      4'b0011:
        begin
          mem[awaddrt] = wdatat[7:0];
          mem[awaddrt + 1] = wdatat[15:8];
          awaddrt = awaddrt + 2;
        end
       4'b1100:
        begin
          mem[awaddrt] = wdatat[23:16];
          mem[awaddrt + 1] = wdatat[31:24];
          awaddrt = awaddrt + 2;
        end
      4'b1111:
        begin
          mem[awaddrt] = wdatat[7:0];
          mem[awaddrt + 1] = wdatat[15:8];
          mem[awaddrt + 2] = wdatat[23:16];
          mem[awaddrt + 3] = wdatat[31:24];
          $display("%0d :: %0d :: %0d :: %0d, @ %0d", mem[awaddrt], mem[awaddrt + 1], mem[awaddrt + 2], mem[awaddrt + 3], awaddrt);
          awaddrt = awaddrt + 4;
        end
    endcase
    return awaddrt;
  endfunction
  
  // function to compute wrapping boundry
  
  function bit[7:0] wrap_boundry (input [3:0] awlen, input [2:0] awsize);
    reg [7:0] boundry;
    unique case (awlen) 
      4'b0001:
        begin
          unique case(awsize)
            3'b000: boundry = 1*2;
            3'b001: boundry = 2*2;
            3'b010: boundry = 4*2;
          endcase
        end
      4'b0011:
        begin
           unique case(awsize)
            3'b000: boundry = 1*4;
            3'b001: boundry = 2*4;
            3'b010: boundry = 4*4;
          endcase
        end
      4'b0111:
        begin
           unique case(awsize)
            3'b000: boundry = 1*8;
            3'b001: boundry = 2*8;
            3'b010: boundry = 4*8;
          endcase
        end
      4'b1111:
        begin
           unique case(awsize)
            3'b000: boundry = 1*16;
            3'b001: boundry = 2*16;
            3'b010: boundry = 4*16;
          endcase
        end
    endcase
    return boundry;
  endfunction
  
  // function to calculate next address for wraptype
  
  function bit[31:0] wrap_type (input [3:0] wstrb, input [7:0] wboundry, input [31:0] awaddrt);
    reg [31:0] addr1,addr2,addr3,addr4;
    
    unique case(wstrb)
      4'b0001:
        begin
          mem[awaddrt] = wdatat[7:0];
          
          if ((awaddrt + 1) % wboundry == 0)
            addr1 = awaddrt + 1 - wboundry;
          else addr1 = awaddrt  + 1;
          
          return addr1;
        end
      4'b0010:
         begin
           mem[awaddrt] = wdatat[15:8];
          
          if ((awaddrt + 1) % wboundry == 0)
            addr1 = awaddrt + 1 - wboundry;
          else addr1 = awaddrt + 1;
          
          return addr1;
        end
      4'b0100:
         begin
           mem[awaddrt] = wdatat[23:16];
          
          if ((awaddrt + 1) % wboundry == 0)
            addr1 = awaddrt + 1 - wboundry;
          else addr1 = awaddrt + 1;
          
          return addr1;
        end
      4'b1000:
         begin
           mem[awaddrt] = wdatat[31:24];
          
           if ((awaddrt + 1) % wboundry == 0)
            addr1 = awaddrt + 1 - wboundry;
          else addr1 = awaddrt + 1;
          
          return addr1;
        end
      4'b0011:
        begin
          mem[awaddrt] = wdatat[7:0];
          
          if ((awaddrt + 1) % wboundry == 0)
            addr1 = awaddrt + 1 - wboundry;
          else addr1 = awaddrt + 1;
          
          mem[addr1] = wdatat[15:8];
          
          if ((addr1 + 1) % wboundry == 0) 
            addr2 = addr1 + 1 - wboundry;
          else addr2 = addr1 + 1;
          
          return addr2;
        end
      4'b1100:
        begin
          mem[awaddrt] = wdatat[23:16];
          
          if ((awaddrt + 1) % wboundry == 0)
            addr1 = awaddrt + 1 - wboundry;
          else addr1 = awaddrt + 1;
          
          mem[addr1] = wdatat[31:24];
          
          if ((addr1 + 1) % wboundry == 0) 
            addr2 = addr1 + 1 - wboundry;
          else addr2 = addr1 + 1;
          
          return addr2;
        end
      
      4'b1111:
        begin
          mem[awaddrt] = wdatat[7:0];
          
          if ((awaddrt + 1) % wboundry == 0) addr1 = awaddrt + 1 - wboundry;
          else addr1 = awaddrt + 1;
          
          mem[addr1] = wdatat[15:8];
          
          if ((addr1 + 1) % wboundry == 0) addr2 = addr1 + 1 - wboundry;
          else addr2 = addr1 + 1;
          
          mem[addr2] = wdatat[23:16];
          
          if ((addr2 + 1) % wboundry == 0) addr3 = addr2 + 1 - wboundry;
          else addr3 = addr2 + 1;
          
          mem[addr3] = wdatat[31:24];
          
          if ((addr3 + 1) % wboundry == 0) addr4 = addr3 + 1 - wboundry;
          else addr4 = addr3 + 1;
          
          return addr4;
          
        end  
    endcase
  endfunction
  
  // write data channel
  

  always_comb
    begin
      case (wstate)
        widle:
          begin
            wready = 1'b0;
            wlen_count = 0;
            wnext_state = wstart;
            first = 1'b0;
          end
        wstart:
          begin
            wready = 1'b1;
            if (wready && wvalid)
              begin
                wdatat = wdata;
                wnext_state = wreadys;
              end
            else wnext_state = wstart;
          end
        wreadys:
          begin
            wready = 0;
            unique case(awburst)
              2'b00:
                begin
                  if (!first)
                    begin
                      wlen_count = wlen_count + 1;
                      nextaddr = awaddrt;
                      retaddr = fixed_type(wstrb, nextaddr);
                      first = 1'b1;
                      wnext_state = wstart;
                    end
                  else if (wlen_count == awlen)
                    begin
                      wlen_count = wlen_count + 1;
                      nextaddr = retaddr;
                      retaddr = fixed_type(wstrb,nextaddr);
                      if (wlast) wnext_state = wlasts;
                      else wnext_state = wstart;
                    end
                end
              2'b01:
                begin
                  if (!first)
                    begin
                      wlen_count = wlen_count + 1;
                      nextaddr = awaddrt;
                      retaddr = incr_type(wstrb, nextaddr);
                      $display("%0d", wlen_count );
                      first = 1'b1;
                      wnext_state = wstart;
                    end
                  else if (wlen_count <= awlen)
                    begin
                      wlen_count = wlen_count + 1;
                      nextaddr = retaddr;
                      retaddr = incr_type(wstrb,nextaddr);
                      $display("%0d", wlen_count );
                      if (wlast) wnext_state = wlasts;
                      else wnext_state = wstart;
                    end
                end
              2'b10:
                begin
                  boundry = wrap_boundry(awlen,awsize);
                  if (!first)
                    begin
                      wlen_count = wlen_count + 1;
                      nextaddr = awaddrt;
                      retaddr = wrap_type(wstrb,boundry, nextaddr);
                      first = 1'b1;
                      wnext_state = wstart;
                    end
                  else if (wlen_count == awlen)
                    begin
                      wlen_count = wlen_count + 1;
                      nextaddr = retaddr;
                      retaddr = wrap_type(wstrb,boundry,nextaddr);
                      if (wlast) wnext_state = wlasts;
                      else wnext_state = wstart;
                    end
                end
            endcase
          end
        wlasts:
          begin
//             bvalid = 1'b1;
            wlen_count = 0;
            wready = 1'b0;
            wnext_state = widle;
          end
      endcase
    end
  
  
  // fsm for write response channel
  
  
  always_comb
    begin
      case(b_state)
        bidle:
          begin
            bvalid = 1'b0;
            bid = 0;
            bresp = 0;
            bnext_state = bdetect_last;
          end
        bdetect_last:
          begin
            if (wlast) bnext_state = bstart;
            else bnext_state = bdetect_last;
          end
        bstart:
          begin
            bid = awid;
            bvalid = 1'b1;
            bnext_state = bwait;
        end
        bwait:
          begin
            if (bvalid && bready) 
              begin
                bnext_state = bidle;
                if( (awaddr < 128 ) && (awsize <= 3'b010) )  bresp = 2'b00;  ///okay
                
                else if (awsize > 3'b010) bresp = 2'b10; /////slverr
            
                else  bresp = 2'b11; ///no slave address 
             end
                  
             else bnext_state = bwait;
          end
         endcase   
     end    
     
    
  
  // read address channel
  
  typedef enum bit[2:0] {aridle = 0, arstart = 1, arreadys = 2} arstate_type;
  arstate_type arstate,arnext_state;
  
    typedef enum bit [2:0] {ridle = 0, rstart = 1, rwait = 2, rlasts = 3, rerror = 4} rstate_type;
  rstate_type rstate, rnext_state;
  
 reg rdfirst;
 bit [31:0] rdnextaddr, rdretaddr;
 reg [3:0] len_count;
 reg [7:0] rboundry;
  
  
  always_ff @(posedge aclk, negedge arstn)
    begin
      if (!arstn) 
        begin
          arstate <= aridle;
          rstate <= ridle;
        end
      else begin
        arstate <= arnext_state;
        rstate <= rnext_state;
      end
    end
  
  reg [31:0] araddrt;
  
  always_comb
    begin
      case(arstate)
        aridle:
          begin
            arready = 0;
            arnext_state = arstart;
          end
        arstart:
          begin
            arready = 1'b1;
            if (arready && arvalid)
              begin
                araddrt = araddr;
                arnext_state = arreadys;
              end
            else arnext_state = arstart;
          end
        arreadys:
          begin
            arnext_state = aridle;
            arready  = 1'b0;
          end
      endcase
    end
  
  // address return in fixed mode
  
  function void read_fixed (input [2:0] arsize, input [31:0] raddrt);
    case(arsize)
      3'b000: rdata[7:0] = mem[raddrt];
      3'b001:
        begin 
          rdata[7:0] = mem[raddrt];
          rdata[15:8] = mem[raddrt + 1];
        end
      3'b010:
        begin
          rdata[7:0] = mem[raddrt];
          rdata[15:8] = mem[raddrt + 1];
          rdata[23:16] = mem[raddrt + 2];
          rdata[31:24] = mem[raddrt + 3];
        end
    endcase
  endfunction
  
  // address return for incr type
  
  function bit[31:0] read_incr (input [2:0] arsize, input [31:0] raddrt);
    reg [31:0] retaddr;
    
    unique case(arsize)
      3'b000:
        begin
          rdata[7:0] = mem[raddrt];
          retaddr = raddrt + 1;
          return retaddr;
        end
      3'b001:
        begin
          rdata[7:0] = mem[raddrt];
          rdata[15:8] = mem[raddrt + 1];
          retaddr = raddrt + 2;
          return retaddr;
        end
      3'b010:
        begin
          rdata[7:0] = mem[raddrt];
          rdata[15:8] = mem[raddrt + 1];
          rdata[23:16] = mem[raddrt + 2];
          rdata[31:24] = mem[raddrt + 3];
          retaddr = raddrt + 4;
          $display("--%0d :: %0d", raddrt, mem[ raddrt ]);
          return retaddr;
        end
    endcase
  endfunction
  
  // function to compute the wrap boundry
  
  function bit [7:0] read_wrap_boundry(input [2:0] arsize, input [3:0] arlen);
    reg boundry;
    unique case(arlen)
      4'b0001:
        begin
          unique case(arsize)
            3'b000: boundry = 1*2;
            3'b001: boundry = 2*2;
            3'b010: boundry = 4*2;
          endcase
        end
      4'b0011:
        begin
          unique case(arsize)
            3'b000: boundry = 1*4;
            3'b001: boundry = 2*4;
            3'b010: boundry = 4*4;
          endcase
        end
      4'b0111:
        begin
          unique case(arsize)
            3'b000: boundry = 1*8;
            3'b001: boundry = 2*8;
            3'b010: boundry = 4*8;
          endcase
        end
      4'b1111:
        begin
          unique case(arsize)
            3'b000: boundry = 1*16;
            3'b001: boundry = 2*16;
            3'b010: boundry = 4*16;
          endcase
        end
    endcase
    return boundry;
  endfunction
  
  // function to return wrap address
  
  function bit [31:0] read_wrap (input [7:0] wboundry, input [31:0] raddrt, input [2:0] arsize);
    reg [31:0] retaddr;
    reg addr1,addr2,addr3,addr4;
    
    case(awsize)
      3'b000:
        begin
          rdata[7:0] = mem[raddrt];
          if ((raddrt + 1) % wboundry == 0) addr1 = raddrt + 1 - wboundry;
          else addr1 = raddrt + 1;
          
          return addr1;
        end
      3'b001:
        begin
          rdata[7:0] = mem[raddrt];
          
          if ((raddrt + 1) % wboundry == 0) addr1 = raddrt + 1 - wboundry;
          else addr1 = raddrt + 1;
          
          rdata[15:8] = mem[addr1];
          
          if ((addr1 + 1) % wboundry == 0) addr2 = addr1 + 1 - wboundry;
          else addr2 = addr1 + 1;
          
          return addr2;
          
        end
      3'b010:
        begin
          rdata[7:0] = mem[raddrt];
          
          if ((raddrt + 1) % wboundry == 0) addr1 = raddrt + 1 - wboundry;
          else addr1 = raddrt + 1;
          
          rdata[15:8] = mem[addr1];
          
          if ((addr1 + 1) % wboundry == 0) addr2 = addr1 + 1 - wboundry;
          else addr2 = addr1 + 1;
          
          rdata[23:16] = mem[addr2];
          
          if ((addr2 + 1) % wboundry == 0) addr3 = addr2 + 1 - wboundry;
          else addr3 = addr2 + 1;
          
          rdata[31:24] = mem[addr3];
          
          if ((addr3 + 1) % wboundry == 0) addr4 = addr3 + 1 - wboundry;
          else addr4 = addr3 + 1;
          
          return addr4;
        end
    endcase
  endfunction
  
  // readdata fsm
  

  always_comb
    begin
      case (rstate)
        ridle:
          begin
            rvalid = 1'b0;
            rresp = 2'b00;
            rlast = 1'b0;
            rid = 3'b000;
            rdfirst = 0;
            len_count = 0;
            rdata = 0;
            
            if (arvalid) rnext_state = rstart;
            else rnext_state = ridle;
          end
        rstart:
          begin
            if ((araddrt < 128) && (arsize <= 3'b010))
              begin
                rid = arid;
                rvalid = 1'b1;
                rresp = 2'b00;
                if (rvalid && rready) rnext_state = rwait;
                else rnext_state = rstart;
              end
            else if ((araddrt > 128) && (arsize <= 3'b010))
              begin
                rresp = 2'b11;
                rvalid = 1'b0;
                rnext_state = rerror;
              end
            else if (arsize > 3'b010) 
              begin
                rresp = 2'b10;
                rvalid = 1'b0;
                rnext_state = rerror;
              end
          end
        rwait:
          begin
            rvalid = 1'b0;
            unique case (arburst)
              2'b00:
                begin
                  if (rdfirst == 0)
                    begin
                      rdfirst = 1'b1;
                      rdnextaddr = araddrt;
                      len_count = len_count + 1;
                      rnext_state = rstart;
                    end
                  else if (len_count < arlen)
                    begin
                      rdnextaddr = araddrt;
                      len_count = len_count + 1;
                      rnext_state = rstart;
                    end
                  else if (len_count == arlen) 
                    begin
                      rlast = 1'b1;
                      rdnextaddr = araddrt;
                      len_count = len_count + 1;
                      rnext_state = rlasts;
                    end
                  
                  read_fixed(arsize, rdnextaddr);
                end
              
              2'b01:
                begin
                  if (rdfirst == 0)
                    begin
                      rdfirst = 1;
                      len_count = len_count + 1;
                      rdnextaddr = araddrt;
                      rdretaddr = read_incr(arsize, rdnextaddr);
//                      $display("---%0d---", rdretaddr );
                      $display("read %0d  %0d", len_count , rdnextaddr);
                      rnext_state = rstart;
                    end
                  else if (len_count < arlen)
                    begin
                      len_count = len_count + 1;
                      rdnextaddr = rdretaddr;
                      rdretaddr = read_incr(arsize, rdnextaddr);
                      $display("read %0d  %0d", len_count , rdnextaddr);
                      rnext_state = rstart;
                    end
                  else if (len_count == arlen)
                    begin
//                      len_count = len_count + 1;
                      rdnextaddr = rdretaddr;
                      rdretaddr = read_incr(arsize, rdnextaddr);
                      $display("read %0d  %0d", len_count , rdnextaddr);
                      rnext_state = rlasts;
                    end
                end
              2'b10:
                begin
                  rboundry = read_wrap_boundry(arsize, arlen);
                  if (rdfirst == 0)
                    begin
                      rdfirst = 1'b1;
                      len_count = len_count + 1;
                      rdnextaddr = araddrt;
                      rdretaddr = read_wrap(rboundry, rdnextaddr, arsize);
                      rnext_state = rstart;
                    end
                  else if (len_count < arlen)
                    begin
                      len_count = len_count + 1;
                      rdnextaddr = rdretaddr ;
                      rdretaddr = read_wrap(rboundry, rdnextaddr, arsize);
                      rnext_state = rstart;
                    end
                  else if (len_count == arlen)
                    begin
                      rlast = 1'b1;
                      len_count = len_count + 1;
                      rdnextaddr = rdretaddr;
                      rdretaddr = read_wrap(rboundry, rdnextaddr, arsize);
                      rnext_state = rlasts;
                    end
                end
            endcase
          end
        rlasts:
          begin
            rlast = 1'b1;
            rnext_state = ridle;
            len_count = 0;
          end
        rerror:
          begin
            rvalid = 1'b0;
            if (len_count < arlen)
              begin
                if (arready) rnext_state = rstart;
                else rnext_state = ridle;
              end
            else begin
              rlast = 1;
              rnext_state = ridle;
              len_count = 0;
            end
          end
        default : rnext_state = ridle;
      endcase
    end
  
  
endmodule



