module ram_config(
 //general clk and rst_n
 input	 logic            clk_sys_i,
 input 	 logic            rst_sys_ni,
 input	 logic            rx_ack_i,
 input   logic            SS,
 
 input 	 logic            a_rvalid,
 input   logic	[31:0]    data_in,
 input	 logic            empty_i,
 output	 logic            en,
 output  logic            read_enable_o,
 output	 logic            req,
 output	 logic            rst_n,
 output	 logic	[31:0]    addr, 
 output	 logic	[31:0]    data_out,
 output  logic	[3:0]     b_en
);
 
 reg [31:0] base_addr = 32'h00100000;
 logic [31:0] data_next;

  always_ff @(posedge clk_sys_i or negedge rst_sys_ni) begin
  	if (!rst_sys_ni) begin
  		base_addr <= 32'h00100000;
  		data_next <= 32'b0;
  		read_enable_o <= 1'b0;
  		en <= 1'b0;
  		req <= 1'b0;
  		rst_n <= 1'b1;
  	end else begin
  	  if(!empty_i)	begin
  	    read_enable_o <= 1'b1;
  	  end
  	  else  begin
  	   read_enable_o <= 1'b0; 
  	  end
  	  if (rx_ack_i) begin
  	  	data_next <= data_in;
  	  	addr <= base_addr;
		  	data_out <= data_next;
		  	b_en <= 4'hF;
		  	req <= 1'b1;
		  	req <= #1 1'b0;
		  	en <= 1'b1;
		  	if (!a_rvalid);
		  	base_addr <= base_addr + 4;
		  	en <= 1'b0;
		  	data_next <= 32'b0;
		  end
	  	if(empty_i && !(base_addr ==32'h00100000) && SS)
		   rst_n <= 1'b0;
		end   
  end
endmodule
