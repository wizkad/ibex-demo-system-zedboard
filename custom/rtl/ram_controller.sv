module RAM_Controller #(
  parameter WIDTH = 32
  ) (
  input logic                 clk_sys,    // Clock input
  input logic                 rst_sys_n,  // Reset input
  input logic                 spi_done,
  input logic                 pack_done,
  input logic   [WIDTH-1:0]   data_in,   // Data input to RAM
  output logic  [WIDTH-1:0]   data_out,  // Data output from RA
  output logic  [WIDTH-1:0]   addr, 
  output logic  [WIDTH-1:0]   size 

);
  
  localparam CMD_WRITE = 8'h01;
  localparam CMD_READ = 8'h02;
  

  logic [7:0]   cmd;
  logic         hold;
  logic [7:0]   stored_cmd;
  logic [1:0]   count;
  
  assign cmd = data_in & 8'h11;
  

  always_ff @(posedge clk_sys or negedge rst_sys_n) begin
    if (!rst_sys_n) begin
      hold  <= 1'b0;
      cmd   <= 8'h00;
      stored_cmd <= 8'h00;
    end else begin
      
      if(!hold & spi_done) begin
        stored_cmd <= cmd;
        hold <= 1'b1;
      end
      case (stored_cmd)
        CMD_WRITE: 
          if(spi_done && (count == 2'b00)) begin
            addr <= data_in;
            count <= 2'b01;
          end
          if(spi_done && (count == 2'b01)) begin
            size <= data_in;
            count <= 2'b10;
          end
          if(spi_done && (count == 2'b10)) begin
            data_out <= data_in;  
          end
          if(pack_done) begin
            count <= 2'b00;
            hold <= 1'b0;
            stored_cmd <= 8'h00;
            addr <= 'b0;
            size <= 'b0;
          end  

        CMD_READ: 
         

        default: // Unknown code
          // Handle unknown code
      endcase
    end
  end

endmodule

