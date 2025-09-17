
class ahb_sequence_item extends uvm_sequence_item;
  `uvm_object_param_utils(ahb_sequence_item)
  
  
  function new (string name="ahb_sequence_item");
    super.new(name);
  endfunction
    localparam ADDR_WIDTH = 20;
 localparam DATA_WIDTH = 32;
  randc logic start;
  randc logic [ADDR_WIDTH-1:0] addr_ip;
  randc logic [2:0] hsize_ip;
  randc logic [DATA_WIDTH-1:0] data_ip;
  randc logic [2:0] hburst_ip;
  randc logic hwrite_ip;
  logic [DATA_WIDTH-1:0]HWDATA;
  logic [ADDR_WIDTH-1:0]HADDR;
  logic [DATA_WIDTH-1:0]HRDATA;
  logic HWRITE;
  logic [1:0] HTRANS;
  logic HRSP,HREADY;
  logic [3:0] HWDATACHK;
  int seq_type;
  int burst_len;
  
  
endclass