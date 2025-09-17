module ahb_slave
  #(parameter ADDR_WIDTH = 20,
    parameter DATA_WIDTH = 32)
  (
    input  logic                   HCLK,
    input  logic                   HRESET,
    output logic                   HRSP,
    input  logic [DATA_WIDTH-1:0]  HWDATA,
    input  logic [ADDR_WIDTH-1:0]  HADDR,
    input  logic [2:0]             HBURST,
    input  logic                   HWRITE,
    input  logic [2:0]             HSIZE,
    input  logic [1:0]             HTRANS,
    input logic [3:0]              HWDATACHK,
    output logic [DATA_WIDTH-1:0]  HRDATA,
    output logic                   HREADY
  );

  logic [7:0] mem [0:(1<<ADDR_WIDTH)-1];
  logic [DATA_WIDTH-1:0] temp_read_data;
  logic [3:0] HWDATACHK_reg;

  always_ff @(posedge HCLK or negedge HRESET) begin
    if (HRESET) begin
      for (int i = 0; i < (1 << ADDR_WIDTH); i++) begin
        mem[i] <= 8'd0;
      end
      HRDATA <= 32'd0;
      HRSP   <= 0;
      HREADY <= 1;
      HWDATACHK_reg<=4'b0;
    end else begin
      if (HTRANS == 2'b10 || HTRANS == 2'b11) begin
        HREADY <= 1;
        HRSP   <= 0;

        case (HSIZE)
          3'b000: begin
            if (HWRITE)
              mem[HADDR] <= HWDATA[7:0];
            else
              temp_read_data = {24'd0, mem[HADDR]};
          end

          3'b001: begin
            if (HWRITE) begin
              mem[HADDR]     <= HWDATA[7:0];
              mem[HADDR + 1] <= HWDATA[15:8];
            end else begin
              temp_read_data = {16'd0, mem[HADDR + 1], mem[HADDR]};
            end
          end

          3'b010: begin
            if (HWRITE) begin
              mem[HADDR]     <= HWDATA[7:0];
              mem[HADDR + 1] <= HWDATA[15:8];
              mem[HADDR + 2] <= HWDATA[23:16];
              mem[HADDR + 3] <= HWDATA[31:24];
            end else begin
              temp_read_data = {mem[HADDR + 3], mem[HADDR + 2], mem[HADDR + 1], mem[HADDR]};
            end
          end

          default: begin
            HRSP   <= 1;
            HREADY <= 0;
          end
        endcase

        if (!HWRITE)
          HRDATA <= temp_read_data;

      end else begin
        HREADY <= 1;
        HWDATACHK_reg[0] <= ($countones(HWDATA[7:0]) % 2) == 1; 
        HWDATACHK_reg[1] <= ($countones(HWDATA[15:8]) % 2) == 1; 
        HWDATACHK_reg[2] <= ($countones(HWDATA[23:16]) % 2) == 1; 
        HWDATACHK_reg[3] <= ($countones(HWDATA[31:24]) % 2) == 1;
        if(HWDATACHK_reg==HWDATACHK) begin
          HRSP<=0;
        end
        else HRSP<=1;
      end
    end
  end
endmodule
