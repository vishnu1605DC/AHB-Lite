`include "ahb_master.sv"
`include "ahb_slave.sv"

module ahb_top #(
  parameter ADDR_WIDTH = 20,
  parameter DATA_WIDTH = 32
)(
  input  logic                  HCLK,
  input  logic                  HRESET,
  input  logic                  start,
  input  logic [ADDR_WIDTH-1:0] addr_ip,
  input  logic [2:0]            hsize_ip,
  input  logic [DATA_WIDTH-1:0] data_ip,
  input  logic [2:0]            hburst_ip,
  input  logic                  hwrite_ip,

  // Outputs to UVM monitor
  output logic [ADDR_WIDTH-1:0] HADDR,
  output logic [1:0]            HTRANS,
  output logic [DATA_WIDTH-1:0] HWDATA,
  output logic                  HWRITE,
  output logic [DATA_WIDTH-1:0] HRDATA,
  output logic                  HRSP,
  output logic                  HREADY,
  output logic [3:0]            HWDATACHK
);

  // Internal wires
  logic [2:0]            HBURST;
  logic [2:0]            HSIZE;
  logic                  HWRITE_wire;
  logic [1:0]            HTRANS_wire;
  logic [DATA_WIDTH-1:0] HWDATA_wire;
  logic [DATA_WIDTH-1:0] HRDATA_wire;
  logic                  HREADY_wire;
  logic                  HRSP_wire;

  // monitor input
  assign HWDATA       = HWDATA_wire;
  assign HRDATA       = HRDATA_wire;
  assign HREADY       = HREADY_wire;
  assign HRSP         = HRSP_wire;
  assign HTRANS       = HTRANS_wire;
  assign HWRITE       = HWRITE_wire;

  // master instantiation
  ahb_master u_master (
    .HCLK(HCLK),
    .HRESET(HRESET),
    .HREADY(HREADY_wire),
    .HRSP(HRSP_wire),
    .start(start),
    .HRDATA(HRDATA_wire),
    .HWDATA(HWDATA_wire),
    .HADDR(HADDR),
    .HBURST(HBURST),
    .HWRITE(HWRITE_wire),
    .HSIZE(HSIZE),
    .HTRANS(HTRANS_wire),
    .HWDATACHK(HWDATACHK),
    .addr_ip(addr_ip),
    .hsize_ip(hsize_ip),
    .data_ip(data_ip),
    .hburst_ip(hburst_ip),
    .hwrite_ip(hwrite_ip)
  );

  // slave instantiation
  ahb_slave u_slave (
    .HCLK(HCLK),
    .HRESET(HRESET),
    .HRSP(HRSP_wire),
    .HWDATA(HWDATA_wire),
    .HADDR(HADDR),
    .HBURST(HBURST),
    .HWRITE(HWRITE_wire),
    .HSIZE(HSIZE),
    .HTRANS(HTRANS_wire),
    .HWDATACHK(HWDATACHK),
    .HRDATA(HRDATA_wire),
    .HREADY(HREADY_wire)
  );

endmodule
