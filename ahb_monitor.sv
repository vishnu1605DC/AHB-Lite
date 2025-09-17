

class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)
  
  virtual ahb_interface vif;
  ahb_sequence_item item;
  uvm_analysis_port#(ahb_sequence_item) ap;
  logic [19:0] addr;
  logic [1:0] htrans;

  
  
  function new(string name="ahb_monitor",uvm_component parent);
    super.new(name,parent);
    ap=new("ap",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_interface#())::get(this,"","vif",vif))
      begin
      `uvm_fatal("Monitor config db not found",{"Virtual interface must be set for : ",get_full_name(),".vif"})
      end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("ahb_monitor","Monitor Run Phase starting", UVM_MEDIUM)
    forever begin
      @(posedge vif.MONITOR.HCLK);
    item=ahb_sequence_item::type_id::create("item");
      
      
      addr=vif.monitor_cb.HADDR;
      htrans=vif.monitor_cb.HTRANS;
      
      if(addr!=20'b0 && htrans!=2'b00 ) begin
        @(posedge vif.MONITOR.HCLK)
      
      item.HWRITE=vif.monitor_cb.HWRITE;
      item.HTRANS=vif.monitor_cb.HTRANS;
      item.HADDR=vif.monitor_cb.HADDR;
      item.HWDATA=vif.monitor_cb.HWDATA;
      item.HRDATA=vif.monitor_cb.HRDATA;
      item.HRSP=vif.monitor_cb.HRSP;
      item.HREADY=vif.monitor_cb.HREADY;
      item.HWDATACHK=vif.monitor_cb.HWDATACHK;
      
      // $display(" 1. Values sent to SCB via Mon is :\n HWRITE = %b \n HTRANS = %b \n HADDR = %h \n HWDATA = %d \n HRDATA = %d \n HRSP = %b \n HREADY = %b \n HWDATACHK = %b",item.HWRITE,item.HTRANS,item.HADDR,item.HWDATA,item.HRDATA,item.HRSP,item.HREADY,item.HWDATACHK);
      
      
      
          
        $display(" at %t 1. Values sent to SCB via Mon is :\n HWRITE = %b \n HTRANS = %b \n HADDR = %h \n HWDATA = %d \n HRDATA = %d \n HRSP = %b \n HREADY = %b \n HWDATACHK = %b",$time,item.HWRITE,item.HTRANS,item.HADDR,item.HWDATA,item.HRDATA,item.HRSP,item.HREADY,item.HWDATACHK);
   ap.write(item);

         end
 


      
    
 
      
    end
  endtask
endclass
      
    
    
    
     
    
    
    