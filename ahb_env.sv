class ahb_env extends uvm_env;
  `uvm_component_utils(ahb_env)
  
  ahb_agent agt;
  ahb_scoreboard scb;
  
  function new(string name="ahb_env", uvm_component parent);
    super.new(name,parent);
  endfunction
  
   function void build_phase(uvm_phase phase);    
    super.build_phase(phase);
     agt=ahb_agent::type_id::create("agt",this);
     scb=ahb_scoreboard::type_id::create("scb",this);
   endfunction
  
   function void connect_phase(uvm_phase phase);    
    super.connect_phase(phase);
     agt.mon.ap.connect(scb.scb_export);
     agt.drv.ap2.connect(scb.fifo.analysis_export);
      uvm_report_info("FIFO_ENVIRONMENT", "connect_phase, Connected monitor to scoreboard");
  endfunction
endclass