class ahb_test extends uvm_test;
  `uvm_component_utils(ahb_test)
  virtual ahb_interface vif;
  
  function new(string name="ahb_test",uvm_component parent);
    super.new(name, parent);
  endfunction
  
  ahb_write_sequence seq1;
  ahb_read_sequence seq2;
  ahb_env env;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=ahb_env::type_id::create("env",this);
    if(!uvm_config_db#(virtual ahb_interface)::get(this,"","vif",vif))begin
      `uvm_error("ahb_test","test virtual interface failed")
     end
  endfunction
  
   virtual function void end_of_elaboration();
    print();
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq1=ahb_write_sequence::type_id::create("seq1");
    seq2=ahb_read_sequence::type_id::create("seq2");
     phase.raise_objection(this,"Starting base sequence");
    $display("%t Wr 1 known data sequence started",$time);
    seq1.start(env.agt.seqr);
    #20;
    $display("%t Rd 1 known data sequence started",$time);
    seq2.start(env.agt.seqr);
    #20;
    phase.drop_objection(this,"Ending base sequence");
    
   
  endtask
endclass