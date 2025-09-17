module ahb_master
  #(parameter ADDR_WIDTH = 20,
    parameter DATA_WIDTH = 32
   )(
  input logic HCLK,
  input logic HRESET,
  input logic HREADY,
  input bit HRSP,
  input logic start,
  input logic [DATA_WIDTH-1:0] HRDATA,
    output logic [DATA_WIDTH-1:0] HWDATA,
    output logic [ADDR_WIDTH-1:0] HADDR, 
    output logic [2:0] HBURST,
    output logic HWRITE,
    output logic [2:0] HSIZE,
    output logic [1:0] HTRANS,
    output logic [3:0] HWDATACHK,
    //tb signals
    input logic [ADDR_WIDTH-1:0] addr_ip,
    input  logic [2:0] hsize_ip,
    input logic [DATA_WIDTH-1:0] data_ip,
    input logic [2:0] hburst_ip,
    input logic hwrite_ip
  );
  
  
  int beats_count;
  bit prev_seq,stop;
  bit stop_burst;
  logic [DATA_WIDTH-1:0] data_op;
  logic [DATA_WIDTH-1:0] backup_data_ip;
  logic [2:0] jmp;
  
  typedef enum logic [1:0]{
     IDLE = 2'b00,
     ADDR_PHASE = 2'b01,
     DATA_PHASE = 2'b11,
     WAIT = 2'b10
  } state;
  state present_state, next_state;
  
  always_comb begin
    case(hsize_ip)
      3'b000: begin
        jmp=3'b001; //addr+1
      end
       3'b001: begin
        jmp=3'b010; //addr+2
      end
       3'b010: begin
        jmp=3'b100; //addr+4
      end
    endcase
  end
  
    
  always@(posedge HCLK or negedge HRESET) begin
    if(HRESET) begin
      present_state<=IDLE;
      HTRANS<=2'b00; //HTRANS output shows IDLE State
      HADDR<='0;
      HWDATA<='0;
      data_op<='0;
      beats_count<=1;
      HBURST<=3'b0;
      HSIZE<=3'b0;
      stop<=0;
      prev_seq<=0;
      HWDATACHK<=4'b0;
      
    end
  end
    
  always@(posedge HCLK or negedge HRESET) begin
    if(!HRESET&&start) begin
      present_state<=next_state;
      case(present_state)
        
        IDLE: begin
          if(hsize_ip>3'b010) $error("HSIZE-%b too large for 32 bit Bus",hsize_ip);
          else begin
              HSIZE<=hsize_ip;
              HTRANS<=2'b0;// HTRANS---->IDLE
              HBURST<=hburst_ip;
              beats_count<=1;
              stop<=0;
              prev_seq<=0;        
                 
          end
        end
        
        ADDR_PHASE: begin
      
          HADDR<=addr_ip;
          HBURST<=hburst_ip;
          HWRITE<=hwrite_ip;
        end
        
        WAIT: begin
          if(!HREADY) begin
            //do nothing 
          end
        end
        
        DATA_PHASE: begin
          if (HREADY&&!HRSP) begin
    // First beat: non_seq
    if(HBURST==3'b100 || beats_count==1) begin
      beats_count<=beats_count+1;
      HTRANS<=2'b10;
      if (HWRITE) begin
      HWDATA <= data_ip;
        HWDATACHK[0] <= ($countones(HWDATA[7:0]) % 2) == 0; 
        HWDATACHK[1] <= ($countones(HWDATA[15:8]) % 2) == 0; 
        HWDATACHK[2] <= ($countones(HWDATA[23:16]) % 2) == 0; 
        HWDATACHK[3] <= ($countones(HWDATA[31:24]) % 2) == 0;
        backup_data_ip<=HWDATA;
    end 
    else begin
      data_op <= HRDATA;
   	 end
    end
    
     //Last beat
    else if ((HBURST==3'b011 && beats_count == 5)||(HBURST==3'b101 && beats_count == 9)||                        (HBURST==3'b111 && beats_count == 17)||(HBURST==3'b0 && beats_count == 2)) begin
     
      HTRANS          <= 2'b00; // IDLE
     // HWRITE          <= ~HWRITE; // toggle hwrite
      stop<=1;
    end  
    
    
    // Subsequent beats : seq
    else if (beats_count > 1) begin
     
      if(stop_burst) begin
           HTRANS<=2'b0; // idle
      end 
      else if(!HREADY) begin
        HTRANS<=2'b01; //HTRANS BUSY
      end
      else begin
      HTRANS          <= 2'b11; // SEQ
      prev_seq<=1;
        stop_burst<=(prev_seq==1 && HTRANS ==2'b10 && HTRANS!=2'b01);
        HADDR           <= HADDR + jmp; 
        beats_count <= beats_count + 1;
      if (HWRITE) begin
       
        HWDATA <= data_ip;
        HWDATACHK[0] <= ($countones(HWDATA[7:0]) % 2) == 1; 
        HWDATACHK[1] <= ($countones(HWDATA[15:8]) % 2) == 1; 
        HWDATACHK[2] <= ($countones(HWDATA[23:16]) % 2) == 1; 
        HWDATACHK[3] <= ($countones(HWDATA[31:24]) % 2) == 1;
        backup_data_ip<=HWDATA;
    end 
    else begin
      data_op <= HRDATA;
   	 end
        
        
      end
    end  //seq if block ends here
            else if( HRSP) begin
      //if HRSP=1(error detected by slave)
      HADDR<=HADDR-jmp;
              if (HWRITE) begin
      HWDATA <= backup_data_ip;
    end 
    else begin
      data_op <= HRDATA;
   	 end
              
      
    end
 	 end
        end  
         endcase
    end
  end
 // assign stop_burst=prev_seq && (HTRANS!=2'b11) && (HTRANS!=2'b01);
  
  always @* begin 
    
   // next_state=present_state;
    case(present_state)
      IDLE : next_state=(start? ADDR_PHASE : IDLE);
      ADDR_PHASE: next_state=(HREADY? DATA_PHASE : WAIT);
      WAIT : if(HREADY) next_state=DATA_PHASE;
      DATA_PHASE: if(stop || start==0 || stop_burst) next_state=IDLE;
      default : next_state=IDLE;
    endcase
  end  
endmodule