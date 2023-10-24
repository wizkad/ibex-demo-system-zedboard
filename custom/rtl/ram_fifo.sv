module ram_fifo (
//system clk and rst_n
 input	logic	  clk_sys_i,
 input 	logic	  rst_sys_ni,

//Input
 input  	logic   	write_enable_i,
 input		logic   	read_enable_i,
 input		logic	[31:0]  data_in,
//Output 
 output		logic   	rx_ack_o,
 output		logic   	empty_o,
 output		logic   	full_o,
 output		logic	[31:0]  data_out
);

  localparam DEPTH = 12; // Depth of the circular FIFO
  localparam  int unsigned WIDTH = 32; // Data width of 32 bits
  reg [WIDTH-1:0] fifo [0:DEPTH-1];
  reg [3:0] write_ptr;
  reg [3:0] read_ptr;
  reg [3:0] count;

  always_ff @(posedge clk_sys_i or negedge rst_sys_ni) begin
    if (!rst_sys_ni) begin
      write_ptr <= 4'b0000;
      read_ptr <= 4'b0000;
      count <= 4'b0000;
      rx_ack_o <= 1'b0;
    end else begin
      if (write_enable_i) begin
        if (!full_o) begin
          fifo[write_ptr] <= data_in;
          write_ptr <= write_ptr + 1;
          count <= count + 1;
          if (write_ptr == DEPTH-1) begin
            write_ptr <= 0;
          end
        end
      end

      if (read_enable_i) begin
      	rx_ack_o <= 1'b0;
        if (!empty_o) begin
          data_out <= fifo[read_ptr];
          read_ptr <= read_ptr + 1;
          count <= count - 1;
          if (read_ptr == DEPTH-1) begin
            read_ptr <= 0;
          end
          rx_ack_o <= 1'b1;
        end
      end
    end
  end

  assign empty_o = (count == 0);
  assign full_o = (count == DEPTH);

endmodule
