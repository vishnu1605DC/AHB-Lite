class ahb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ahb_scoreboard)
  
  function new(string name="ahb_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  logic [31:0] assoc_array [logic [19:0]] [2];
  logic [19:0] addr;
  uvm_analysis_imp#(ahb_sequence_item,ahb_scoreboard) scb_export;
  uvm_tlm_analysis_fifo#(ahb_sequence_item) fifo;
  ahb_sequence_item qu[$];
  ahb_sequence_item item;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb_export=new("scb_export",this);
    fifo=new("fifo",this);
  endfunction
  
  function void write(ahb_sequence_item trans);
    $display(" ap.write function values :\n HWRITE = %b \n HTRANS = %b \n HADDR = %h \n HWDATA = %d \n HRDATA = %d \n HRSP = %b \n HREADY = %b \n HWDATACHK = %b",trans.HWRITE,trans.HTRANS,trans.HADDR,trans.HWDATA,trans.HRDATA,trans.HRSP,trans.HREADY,trans.HWDATACHK);
    qu.push_front(trans);
    
  endfunction

  
  
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
//       wait(qu.size()>0);
//     item=qu.pop_back();
//       assoc_array[item.HADDR] [1]=item.HWDATA
      ahb_sequence_item trans;
      wait(qu.size()>0);
      $display("-------------------Inside SCB run phase------------------");

      fifo.get(trans);
        
      
      //single write
        if(trans.seq_type==1) begin
        wait(qu.size()>0);
         item=qu.pop_back();
          assoc_array[trans.addr_ip][0]=trans.data_ip;
          assoc_array[item.HADDR][1] = item.HWDATA;
          $display("-------------------Inside SCB run phase inside wait------------------");
         if (assoc_array[trans.addr_ip][0] == assoc_array[item.HADDR][1]) begin
        `uvm_info("SCB", $sformatf("BURST MATCH addr=%h data=%h", trans.addr_ip, trans.data_ip), UVM_MEDIUM)
         end 
          else begin
        `uvm_error("SCB", $sformatf("BURST MISMATCH addr=%h: expected=%h got=%h",
                      trans.addr_ip, assoc_array[trans.addr_ip][0], assoc_array[trans.addr_ip][1]))
        end // else begin
      end
      
       //burst write
        else if(trans.seq_type==3) begin
        for(int i=0;i<trans.burst_len;i++) begin
        if(i>0) begin
          wait(qu.size()>0);
          item=qu.pop_back();
          assoc_array[trans.addr_ip][0]=trans.data_ip;
          assoc_array[item.HADDR][1] = item.HWDATA;
          if (assoc_array[trans.addr_ip][0] == assoc_array[item.HADDR][1]) begin
        `uvm_info("SCB", $sformatf("BURST MATCH addr=%h data=%h", trans.addr_ip, trans.data_ip), UVM_MEDIUM)
         end 
          else begin
        `uvm_error("SCB", $sformatf("BURST MISMATCH addr=%h: expected=%h got=%h",
                      trans.addr_ip, assoc_array[trans.addr_ip][0], assoc_array[trans.addr_ip][1]))
        end // else begin
        end//if(i>0)
      end // for
          end //else if
      
      //single read
        else if(trans.seq_type==2)begin
           wait(qu.size()>0);
         item=qu.pop_back();
        if(item.HADDR==20'b1000 && item.HRDATA== 32'haabb) begin
          `uvm_info("ahb_scoreboard", "DATA Match for Rd 1 known data", UVM_MEDIUM)
        end //if
          else begin
            `uvm_error("SCB","Read failed");
          end
            
      end //elseif
      
      
      else begin
        $display("-------------------Seq type not valid------------------");
      end
      

      
    end
  endtask
endclass

                                            
                                            
      
    
        
        
          
        
      
      
      
      
    
    
    
  
  