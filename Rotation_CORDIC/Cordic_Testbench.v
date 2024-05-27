module Testbench;
  reg [15:0] x_in, y_in, theta_in;
  reg operands_val, Clk, Rst, ack;
  wire [15:0] x_out, y_out;
  wire out_valid;
  wire [1:0] state;

  top_module DUT(
    .x_in(x_in),
    .y_in(y_in),
    .theta_in(theta_in),
    .operands_val(operands_val),
    .Clk(Clk),
    .Rst(Rst),
    .ack(ack),
    .x_out(x_out),
    .y_out(y_out),
    .out_valid(out_valid),
    .state(state)
  );
  localparam SF = 2.0**-14.0;

  reg signed [15:0] angle_data[0:9]; 
  integer i; 
  
  initial begin 
    $dumpfile("dump.vcd"); 
    $dumpvars(0, DUT);
   
    Clk = 0;
    forever #5 Clk = ~Clk;
  end

  
  // Reading angles from file and iterating through test cases
  initial begin
    Rst = 1;
    operands_val = 0;
    ack = 0;
    #20;
    $readmemh("angle_hex.txt", angle_data);
    for (i = 0; i < 10; i = i + 1) begin
      $display("Test case %0d: theta_in = %h", i+1, angle_data[i]);
      Rst = 0;
      #5;
      Rst = 1;
      #5;
      Rst = 0;
      #5;
      ack = 1;
      x_in = 16'h26dd; 
      y_in = 0;        
      theta_in = angle_data[i]; 
      operands_val = 1;
      #20;
      ack = 0;
      operands_val = 0;    
      @ (posedge out_valid)
      $display("cosine = %f and sine = %f",($itor(x_out*SF)), ($itor(y_out*SF)));    
    end
    $finish;
  end
endmodule

