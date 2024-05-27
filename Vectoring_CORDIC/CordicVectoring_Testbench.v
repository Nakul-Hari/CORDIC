// Code your testbench here
// or browse Examples
module CORDDICvectoring_tb;
  reg signed [15:0] x_in, y_in;
  reg operands_val, Clk, Rst, ack;
  wire signed [15:0] x_out, y_out, theta_out;
  wire out_valid;

  localparam SF = 2.0**-14.0;
  
  CORDDICvectoring DUT(
    .x_in(x_in),
    .y_in(y_in),
    .operands_val(operands_val),
    .Clk(Clk),
    .Rst(Rst),
    .ack(ack),
    .x_out(x_out),
    .y_out(y_out),
    .theta_out(theta_out),
    .out_valid(out_valid)
  );

  reg [15:0] coordinate_data[0:19]; 
  integer i; 
  
  initial begin 
    $dumpfile("dump_cordicvectong.vcd"); 
    $dumpvars(0, DUT);
  end
  
  always #5 Clk = ~Clk;
  
  // Reading angles from file and iterating through test cases
  initial begin
    Clk = 0;
    @ (negedge Clk)
	Rst = 0;
	@ (negedge Clk)
	Rst = 1;
	@ (negedge Clk)
	Rst = 0;
    operands_val = 0;
    ack = 0;
    $readmemh("coordinate_hex.txt", coordinate_data);
    
    for (i = 0; i < 10; i = i + 1) 
      begin
      $display("Test case %0d: x_in = %h and y_in = %h", i+1, coordinate_data[2*i],coordinate_data[2*i+1]); 
      @ (negedge Clk)
      operands_val = 1;
      x_in = coordinate_data[2*i];
      y_in = coordinate_data[2*i+1];
      operands_val = 1;
      @ (negedge Clk)
      operands_val = 0;
      
      @ (posedge out_valid)
      $display("theta = %f",($itor(theta_out*SF)*57.2958));
      $display("magnitude = %f",($itor(x_out*SF)));
      
      #10
      ack = 1;
      #10
      ack = 0;
    end
    #10
    $finish;
  end
endmodule
