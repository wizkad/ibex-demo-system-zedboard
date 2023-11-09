module top_ram #(
	parameter 	WIDTH = 32
) (
	input logic     	  clk_sys,
	input logic     	  rst_sys_n,
	input logic         a_rvalid_i,
	input logic         SS,
	input logic         MOSI,
	input logic         SCLK,
	input logic  [1:0]  MODE,
	
	output logic        MISO,
	output logic [31:0]	data_o,
	output logic [31:0]	addr_o,
	output logic 		    rst_no,
	output logic [3:0] 	b_en_o,
	output logic	    	en_o,
	output logic	    	req_o
);
  logic			        	read_enable;	
  logic 							write_enable;	
  logic				        rx_ack;
  logic	[31:0]		    tx_ram;
  logic				        empty;
  logic               done;
  logic [WIDTH-1:0]        RxData;
  
ram_fifo #(
  .DEPTH(16),
  .WIDTH(WIDTH)
) u_ram_fifo(
	.clk_sys_i		      (clk_sys),
  .rst_sys_ni		      (rst_sys_n),
	.write_enable_i	    (write_enable),
	.read_enable_i	    (read_enable),
	.data_in 		        (RxData),
	.rx_ack_o		        (rx_ack),
	.empty_o		        (empty),
	.full_o			        (),
	.data_out 		      (tx_ram)
);

ram_config u_ram_config(
  .clk_sys_i		      (clk_sys),
 	.rst_sys_ni		      (rst_sys_n),
 	.rx_ack_i		        (rx_ack),
 	.a_rvalid		        (a_rvalid_i),
 	.data_in		        (tx_ram),
 	.empty_ni		        (empty),
 	.we_o				        (en_o),
 	.read_enable_o	    (read_enable),
 	.req			          (req_o),
 	.rst_n			        (rst_no),
 	.addr			          (addr_o),
 	.data_out		        (data_o),
 	.b_en			          (b_en_o)
);

spi_slave #(
  .DATA_WIDTH(WIDTH)
) u_spi_slave (
   .Clk               (clk_sys),                            
   .MODE              (MODE),
   .TxData            (),                           // Transmit Data
   .Done              (done),                             // Transmit Completed
   .RxData            (RxData),                                // Receive Data
// SPI Interface Signals
   .SClk              (SCLK),                           // SPI clock
   .MOSI              (MOSI),                           // Master Out Slave In
   .SS                (SS),                           // Slave Select
   .MISO              (MISO)
);
edge_detc u_edge_detc(
  .clk                (clk_sys),
  .signal             (done),
  .edge_o             (write_enable)
);

endmodule
