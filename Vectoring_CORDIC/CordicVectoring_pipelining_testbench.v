module cordic_tb;
  reg Clk, Rst;
  reg  [15:0] x_in, y_in, theta_in;
  wire  [15:0] magnitude, angle;
  reg  [15:0] coordinate_data[0:19]; // Define coordinate_data array
  integer i;
  
  // DUT instantiation
  pipelined_cordic pc1 (
    .Clk(Clk),
    .Rst(Rst),
    .x_in(x_in),
    .y_in(y_in),
    .magnitude(magnitude),
    .angle(angle)
  );
    localparam SF = 2.0**-14.0;
  // Clock generation
  initial begin 
    $dumpfile("dump_cordicvectoringpipelining.vcd"); 
    $dumpvars(0, pc1);
   
    Clk = 0;
    forever #5 Clk = ~Clk;
  end

  // Reading angles from file and iterating through test cases
  initial begin
    Rst = 1;

    #20;
    $readmemh("coordinate_hex.txt", coordinate_data);
    for (i = 0; i < 10; i = i + 1) begin
      $display("Test case %0d: x_in = %h and y_in = %h", i+1, coordinate_data[2*i], coordinate_data[2*i+1]);
      Rst = 0;
      #5;
      Rst = 1;
      #5;
      Rst = 0;
      #5;
      x_in = coordinate_data[2*i]; 
      y_in = coordinate_data[2*i+1];
      #200;
      $display("theta = %f",($itor(angle*SF)*57.2958));
      $display("magnitude = %f",($itor(magnitude*SF)));
    end
    $finish;
  end
endmodule

