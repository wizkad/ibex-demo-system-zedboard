module edge_detc (
  input  logic clk,
  input  logic signal,
  output logic edge_o
);

  logic signalPrev;

  always_ff @(posedge clk) begin
    signalPrev <= signal;
    edge_o       <= signal ^ signalPrev;
  end

endmodule
