`timescale 1ns/1ps
module ram_config(
 //general clk and rst_n
 input	 logic            clk_sys_i,	//general clock
 input 	 logic            rst_sys_ni,	//general reset
 input	 logic            rx_ack_i,	//read acknowledge input
 input   logic  [31:0]    addr_ini,
 input   logic  [31:0]    size,
 
 input 	 logic            a_rvalid,
 input   logic	[31:0]    data_in,	//data in
 input	 logic            empty_ni,	//empty input signal
 output	 logic            we_o,		//ram write enable signal
 output  logic            req,
 output  logic            read_enable_o,//read enable output signal
 output	 logic            rst_n,	//core reset signal
 output	 logic	[31:0]    addr, 	//ram address
 output	 logic	[31:0]    data_out,	//ram data out
 output  logic	[3:0]     b_en,		//byte enable ram
 output  logic            done
);
 
 logic [31:0] base_addr = 32'h00100000;
 logic [31:0] data_next;
 logic [3:0]  rst_cnt;
 
 // Define states
 reg [2:0] state; // State variable
 localparam IDLE = 3'b000;
 localparam RX_ACK = 3'b001;
 localparam DATA_TRANSFER = 3'b010;
 localparam DONE = 3'b011;
 localparam LAST = 3'b100;

 
  always_ff @(posedge clk_sys_i or negedge rst_sys_ni) begin
  	if (!rst_sys_ni) begin
  		base_addr <= 32'h00100000;
  		data_next <= 32'b0;
  		read_enable_o <= 1'b0;
  		we_o <= 1'b0;
  		req <= 1'b0;
  		rst_n = #4 1'b1;
  		rst_cnt <= 0;
  		state <= IDLE;
  	end else begin
  	  case(state)
  	    IDLE: begin
  	      addr_end <= addr_ini + size - 1;
  	      if(!empty_ni)	begin
  	        read_enable_o <= 1'b1;
  	        state <= RX_ACK;
  	      end
  	      if(addr_end == base_addr) begin
  	     	  done <= 1'b1;
  	     	  base_addr <= 32'h00100000;
  	     	  rst_cnt <= rst_cnt + 1;
  	     	end
  	     	if(rst_cnt == 5) begin
  	     	  rst_n <= 1'b0;
  	     	  rst_cnt <= 0;
  	     	  base_addr <= 32'h00100000;
		    end
		    
  	    RX_ACK: begin
  	      if(rx_ack_i) begin
  	        read_enable_o <= 1'b0;
  	        if(!first_cycle) begin
  	          state <= FIRST;
  	        end else begin
  	        state <= DATA_TRANSFER;
  	        end
  	      end 
  	    end 
  	    DATA_TRANSFER: begin
  	      data_next <= data_in;
  	      addr <= base_addr;
	        data_out <=  data_next;
	        b_en <= 4'hF;
	        req = 1'b1;
	        req = #1 1'b0;
	        we_o = #1 1'b1;
		      state <= DONE;
		    end	
		    
  	    DONE: begin
  	     if (a_rvalid) begin
		  	  base_addr = base_addr + 4;
		  	  we_o = 1'b0;
		  	  data_next = 32'b0;
		  	  state <= IDLE;
		  	
  	     end 
  	    end
  	    LAST:  
  	  endcase
		end   
  end
endmodule
