import uvm_pkg::*;
 `include "uvm_macros.svh"
`include "ahb_interface.sv"
`include "ahb_sequence_item.sv"
`include "ahb_sequence.sv"
`include "ahb_sequencer.sv"
`include "ahb_driver.sv"
`include "ahb_monitor.sv"
`include "ahb_agent.sv"
`include "ahb_scoreboard.sv"
`include "ahb_env.sv"
`include "ahb_test.sv"
//`include "ahb_read_test.sv"
`include "ahb_burst_test.sv"


module tbench_top();
  parameter ADDR_WIDTH = 20;
  parameter DATA_WIDTH = 32;
   logic HCLK;
  logic HRESET;
  
 
  ahb_interface intf(HCLK, HRESET);
  ahb_top  #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) dut (
    .HCLK      (HCLK),
    .HRESET    (HRESET),
    .start     (intf.start),
    .addr_ip   (intf.addr_ip),
    .hsize_ip  (intf.hsize_ip),
    .data_ip   (intf.data_ip),
    .hburst_ip (intf.hburst_ip),
    .hwrite_ip (intf.hwrite_ip),
    .HADDR     (intf.HADDR),
    .HTRANS    (intf.HTRANS),
    .HWDATA    (intf.HWDATA),
    .HWRITE    (intf.HWRITE),
    .HRDATA    (intf.HRDATA),
    .HRSP      (intf.HRSP),
    .HREADY    (intf.HREADY),
    .HWDATACHK (intf.HWDATACHK)
  );
   initial HCLK = 0;
  always #5 HCLK = ~HCLK;
   initial begin
    HRESET = 1;
    #20;
    HRESET = 0;
     
  end
  
  initial begin
    uvm_config_db#(virtual ahb_interface)::set(null,"*","vif",intf);
  end
  
  
  initial begin
    run_test("ahb_test");
    #200;
   
  end
  initial begin 
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
endmodule
  
  
  