// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module top_zedboard (
  input               IO_CLK,
  input               IO_RST_N,
  input  [ 3:0]       SW,
  input  [ 3:0]       BTN,
  output [ 7:0]       LED,
  
  input               UART_RX,
  output              UART_TX,
  
  output              MISO,
  input               MOSI,
  input               SCLK,
  input               SS,
  input   [1:0]       MODE
);
  parameter              SRAMInitFile      = "";

  logic clk_sys, rst_sys_n;
  logic rst_n;
  logic [31:0]	data_spi;
  logic [31:0]	addr_spi;
  logic 				a_rvalid;
  logic [3:0]		b_en;
  logic 				en;
  logic 				req;
  
  assign IO_RSTN_N = rst_n;
  
   // Instantiating the Ibex Demo System.
  ibex_demo_system #(
    .GpiWidth(8),
    .GpoWidth(8),
    .PwmWidth(12),
    .SRAMInitFile(SRAMInitFile)
  ) u_ibex_demo_system (
    //input
    .clk_sys_i      (clk_sys),
    .rst_sys_ni     (rst_sys_n),
    .gp_i           ({SW, BTN}),
    .uart_rxd_out   (UART_RX),

    //output
    .gp_o           (LED),
    .pwm_o          (),
    .uart_txd_in    (UART_TX),
    .spi_rx_i				(1'b0),
    .spi_tx_o				(),
    .spi_sck_o			(),
    
    //ram signals
    .data_spi_i       (data_spi),
    .addr_spi_i       (addr_spi),
    .b_en_i           (b_en),
    .en_i             (en),
    .req_i            (req),
    .a_rvalid_o       (a_rvalid)
  );
// Generating the system clock and reset for the FPGA.
  clkgen_xil7series clkgen(
    .IO_CLK,
    .IO_RST_N     (rst_n),
    .clk_sys,
    .rst_sys_n
  );
//Ram configurator
  top_ram #(
    .WIDTH(32)
  ) u_top_ram(
    //clk rst
    .clk_sys        (clk_sys),
    .rst_sys_n      (rst_sys_n),
	  //Input ports
    .a_rvalid_i     (a_rvalid),
    .SS             (SS),
	  .MOSI           (MOSI),
	  .SCLK           (SCLK),
	  .MODE           (2'b01),
    //Output ports
    .MISO           (MISO),
    .data_o         (data_spi),
    .addr_o         (addr_spi),
    .rst_no         (rst_n),
    .b_en_o         (b_en),
    .en_o           (en),
    .req_o          (req) 
  );
  
endmodule
