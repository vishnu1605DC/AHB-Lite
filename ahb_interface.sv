interface ahb_interface  (input logic HCLK,HRESET);

  localparam ADDR_WIDTH = 20;
 localparam DATA_WIDTH = 32;

  logic start;
  logic [ADDR_WIDTH-1:0] addr_ip;
  logic [2:0] hsize_ip;
  logic [DATA_WIDTH-1:0] data_ip;
  logic [2:0] hburst_ip;
  logic hwrite_ip;


  logic [DATA_WIDTH-1:0] HRDATA;
  logic HRSP;
  logic HREADY;
  logic [DATA_WIDTH-1:0] HWDATA;
  logic HWRITE;
  logic [1:0] HTRANS;
  logic [3:0] HWDATACHK;
  logic [ADDR_WIDTH-1:0] HADDR;
                                                               
                                                               
  clocking driver_cb @(posedge HCLK);
     default input #1 output #1;
    output addr_ip,data_ip;
    output hsize_ip,hburst_ip,hwrite_ip,start;
    input  HRDATA, HRSP, HREADY, HWDATA;
  endclocking
  
  clocking monitor_cb @ (posedge HCLK);
    default input #1 output #1;
    input  HRDATA, HRSP, HREADY, HWDATA, HADDR, HWDATACHK, HTRANS,HWRITE;
  endclocking
  
  modport DRIVER(clocking driver_cb,input HCLK,HRESET);
  modport MONITOR(clocking monitor_cb,input HCLK,HRESET);
    
endinterface 
    
    
                                                               
                                                               
                                                              