//---------------- Sequence 1 - Write 1 known data---------------------------

class ahb_write_sequence extends uvm_sequence#(ahb_sequence_item);
  `uvm_object_utils(ahb_write_sequence)
  
  function new(string name="ahb_write_sequence");
    super.new(name);
  endfunction
  
  ahb_sequence_item req;
  
  virtual task body;
      req=ahb_sequence_item::type_id::create("req");
    
      wait_for_grant();
   
      req.hburst_ip=3'b000;
      req.hsize_ip=3'b001;
      req.data_ip =32'haabb;
      req.start=1;
      req.addr_ip=20'b1000;
      req.hwrite_ip=1;
      req.seq_type=1;
       $display(" Values sent to Drv via Sqr is :\n hwrite_ip = %b \n hburst_ip = %b \n hsize_ip = %b \n haddr_in = %h \n hwdata = %d",req.hwrite_ip,req.hburst_ip,req.hsize_ip,req.addr_ip,req.data_ip);
      

      send_request(req);
      wait_for_item_done();
     
      //set_response_queue_depth(5);
   
  endtask
endclass


//---------------------Sequence 2 - Read 1 known data----------------

class ahb_read_sequence extends uvm_sequence#(ahb_sequence_item);
  `uvm_object_utils(ahb_read_sequence)
  
  function new(string name="ahb_read_sequence");
    super.new(name);
  endfunction
  
  ahb_sequence_item req;
  
  virtual task body;
      req=ahb_sequence_item::type_id::create("req");
      wait_for_grant();
   
      req.hburst_ip=3'b000;
      req.hsize_ip=3'b001;
      //req.data_ip ==32'haabb;
      req.start=1;
      req.addr_ip=20'b1000;
      req.hwrite_ip=0;
    req.seq_type=2;

     
     $display(" Values sent to Drv via Sqr is :\n hwrite_ip = %b \n hburst_ip = %b \n hsize_ip = %b \n haddr_in = %h \n ",req.hwrite_ip,req.hburst_ip,req.hsize_ip,req.addr_ip);
      send_request(req);
      wait_for_item_done();
     
      //set_response_queue_depth(5);
    
  endtask
endclass


//---------------------Sequence 3 - HBURST 4/8/16 beats----------------
class ahb_burst_sequence extends uvm_sequence#(ahb_sequence_item);
  `uvm_object_utils(ahb_burst_sequence)
  
  function new(string name="ahb_burst_sequence");
    super.new(name);
  endfunction
  
  ahb_sequence_item req;
  logic [2:0] burst_len;

     
  virtual task body;
      req = ahb_sequence_item::type_id::create("req");

burst_len = $urandom_range(0, 7);

assert(req.randomize() with {    
  req.hburst_ip   == burst_len;
  req.hsize_ip    inside {3'b001, 3'b010, 3'b011};
  req.start       == 1;
  req.hwrite_ip   == 1;
  req.seq_type    == 3;
});
      
     $display(" Values sent to Drv via Sqr is :\n hwrite_ip = %b \n hburst_ip = %b \n hsize_ip = %b \n haddr_in = %h \n hwdata = %d",req.hwrite_ip,req.hburst_ip,req.hsize_ip,req.addr_ip,req.data_ip);
    start_item(req);
    finish_item(req);
     
      //set_response_queue_depth(5);
    
  endtask
endclass


//---------------------Sequence 4 - HSIZE 8/16/32 bit----------------


//---------------------Sequence 5 - HBURST INCR variable beats-------

      