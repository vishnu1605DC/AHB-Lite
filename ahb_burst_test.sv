class ahb_burst_test extends ahb_test;
  `uvm_component_utils(ahb_burst_test)
 // virtual ahb_interface vif;
  
  function new(string name="ahb_burst_test",uvm_component parent);
    super.new(name, parent);
  endfunction
  
  ahb_burst_sequence seq;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
//     env=ahb_env::type_id::create("env",this);
//     if(!uvm_config_db#(virtual ahb_interface)::get(this,"","vif",vif))begin
//       `uvm_error("ahb_test","test virtual interface failed")
   //  end
  endfunction
  
  /* virtual function void end_of_elaboration();
    print();
  endfunction
  */
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=ahb_burst_sequence::type_id::create("seq");
    phase.raise_objection(this,"Starting burst sequence");
    $display("%t Burst sequence started",$time);
    seq.start(env.agt.seqr);
    #200;
    phase.drop_objection(this,"Ending burst sequence");
  endtask
endclass