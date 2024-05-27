module cordic_tb;
  reg Clk, Rst;
  reg  [15:0] x_in, y_in, theta_in;
  wire  [15:0] sine_theta, cosine_theta;
  reg  [15:0] angle_data[0:29];
  integer i, write_data;
  
  localparam SF = -2.0 ** -14.0;
  
  // DUT instantiation
  pipelined_cordic pc1 (
    .Clk(Clk),
    .Rst(Rst),
    .x_in(x_in),
    .y_in(y_in),
    .theta_in(theta_in),
    .sine_theta(sine_theta),
    .cosine_theta(cosine_theta)
  );
  
    initial begin 
    $dumpfile("dump.vcd"); 
    $dumpvars(0, pc1);
   
    Clk = 0;
    forever #5 Clk = ~Clk;
  end

  
  // Reading angles from file and iterating through test cases
  initial begin
    Rst = 1;

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
      x_in = 16'h26dd; 
      y_in = 0;        
      theta_in = angle_data[i]; 
      #200
      $display("cosine = %f and sine = %f",($itor(cosine_theta*SF)), ($itor(sine_theta*SF)));
    end
    $finish;
  end
endmodule
