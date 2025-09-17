`define driv_if vif.DRIVER.driver_cb

class ahb_driver extends uvm_driver#(ahb_sequence_item);
  `uvm_component_utils(ahb_driver)
  
  function new (string name="ahb_driver", uvm_component parent);
    super.new(name,parent);
    ap2=new("ap2",this);
  endfunction
  
  virtual ahb_interface vif;
  uvm_analysis_port #(ahb_sequence_item) ap2;
  
  ahb_sequence_item item;
  ahb_sequence_item temp;
  int burst_length;
  logic [2:0] jmp;
  
  //build phase : get config db
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_interface)::get(this,"","vif",vif)) begin
      `uvm_fatal("config db not found, fatal error",{"Virtual interface must be set for:", get_full_name(),".vif"});
      
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("ahb_driver","DRIVER Run Phase starting", UVM_MEDIUM)
    forever begin
      item=ahb_sequence_item::type_id::create("item");
      temp=ahb_sequence_item::type_id::create("temp");
      seq_item_port.get_next_item(item);
      if(item.hburst_ip!=3'b000) begin
         case (item.hburst_ip)
      3'b011: burst_length = 4;
      3'b010: burst_length = 8;
      3'b111: burst_length = 16;
      3'b100: burst_length =32;
      default: burst_length = 4;
    endcase
        case(item.hsize_ip)
      3'b000: begin
        jmp=3'b001; //addr+1
      end
       3'b001: begin
        jmp=3'b010; //addr+2
      end
       3'b010: begin
        jmp=3'b100; //addr+4
      end
    endcase
      end
      else burst_length =1;
      
      @(posedge vif.DRIVER.HCLK);
      if(item.hwrite_ip && burst_length==1) begin
        `driv_if.hwrite_ip<=item.hwrite_ip;
        `driv_if.addr_ip<=item.addr_ip;
        `driv_if.hburst_ip<=item.hburst_ip;
        `driv_if.hsize_ip<=item.hsize_ip;
        `driv_if.start<=item.start;
        `driv_if.data_ip<=item.data_ip;
        temp.addr_ip=item.addr_ip;
        temp.data_ip=item.data_ip;
        temp.seq_type=item.seq_type;
        $display("------seq_type=%d----------",item.seq_type);
         ap2.write(temp);
        #10;
      end
      else if(item.hwrite_ip && burst_length!=1) begin
        `driv_if.hwrite_ip<=item.hwrite_ip;
        `driv_if.addr_ip<=item.addr_ip;
        `driv_if.hburst_ip<=item.hburst_ip;
        `driv_if.hsize_ip<=item.hsize_ip;
        `driv_if.start<=item.start;
        temp.addr_ip=item.addr_ip;
        temp.seq_type=item.seq_type;
        temp.burst_len=burst_length;
        ap2.write(temp);
        for(int i=1;i<burst_length;i++) begin
          
          `driv_if.data_ip<=item.data_ip+(i*10);
          temp.addr_ip=temp.addr_ip+jmp;
          temp.data_ip=item.data_ip+(i*10);
           ap2.write(temp);
          #2;
        end
        #10;
        
      end
      else if(!item.hwrite_ip) begin
        `driv_if.hwrite_ip<=item.hwrite_ip;
        `driv_if.addr_ip<=item.addr_ip;
        `driv_if.hburst_ip<=item.hburst_ip;
        `driv_if.hsize_ip<=item.hsize_ip;
        `driv_if.start<=item.start;
        $display("------seq_type=%d----------",item.seq_type);
         temp.addr_ip=item.addr_ip;
        temp.seq_type=item.seq_type;
        ap2.write(item);
        #10;
      end
 
      seq_item_port.item_done(item);
     
      
    end
  endtask
endclass
        
        
      
                                                     
  