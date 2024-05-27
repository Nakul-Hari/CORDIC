
module CORDDICvectoring(
  input signed [15:0] x_in, y_in,
    input operands_val,
    input Clk, Rst, ack,
    output signed [15:0] x_out, y_out, theta_out,
    output out_valid
);

    wire x_MUX_sel, y_MUX_sel, theta_MUX_sel, i_MUX_sel, x_en, y_en, theta_en, i_en;
    wire i_eq_16;


    datapath d1 (
        .x_in(x_in),
        .y_in(y_in),
        .Clk(Clk),
      	.Rst(Rst),
        .x_MUX_sel(x_MUX_sel),
        .y_MUX_sel(y_MUX_sel),
        .theta_MUX_sel(theta_MUX_sel),
        .i_MUX_sel(i_MUX_sel),
        .x_en(x_en),
        .y_en(y_en),
        .theta_en(theta_en),
        .i_en(i_en),
        .x_out(x_out),
        .y_out(y_out),
        .theta_out(theta_out),
        .i_eq_16(i_eq_16)
    );
        
    controlpath c1 (
        .ack(ack),
        .Rst(Rst),
        .Clk(Clk),
        .operands_val(operands_val),
        .i_eq_16(i_eq_16),
        .x_MUX_sel(x_MUX_sel),
        .y_MUX_sel(y_MUX_sel),
        .theta_MUX_sel(theta_MUX_sel),
        .i_MUX_sel(i_MUX_sel),
        .x_en(x_en),
        .y_en(y_en),
        .theta_en(theta_en),
        .i_en(i_en),
        .out_valid(out_valid)
    );

endmodule



//Datapath

module datapath(
  input signed [15:0] x_in, y_in, 
	input Clk, Rst,
	input x_MUX_sel, y_MUX_sel, theta_MUX_sel, i_MUX_sel, x_en, y_en, theta_en, i_en,
	output reg signed [15:0] x_out, y_out, theta_out,
	output i_eq_16
	);
	
	wire signed [15:0] x_MUX_out, y_MUX_out, theta_MUX_out, x_i, y_i;
	reg signed [15:0] x, y, theta, atan_out;
	reg [3:0] i;
  
	// Look Up Table

	always @(*)
		begin
          case(i)
				4'b0000: atan_out <= 16'b0011001001000100;
    				4'b0001: atan_out <= 16'b0001110110101100;
    				4'b0010: atan_out <= 16'b0000111110101101;
    				4'b0011: atan_out <= 16'b0000011111110101;
    				4'b0100: atan_out <= 16'b0000001111111110;
    				4'b0101: atan_out <= 16'b0000001000000000;
    				4'b0110: atan_out <= 16'b0000000100000000;
    				4'b0111: atan_out <= 16'b0000000010000000;
    				4'b1000: atan_out <= 16'b0000000001000000;
    				4'b1001: atan_out <= 16'b0000000000100000;
    				4'b1010: atan_out <= 16'b0000000000010000;
    				4'b1011: atan_out <= 16'b0000000000001000;
    				4'b1100: atan_out <= 16'b0000000000000100;
    				4'b1101: atan_out <= 16'b0000000000000010;
    				4'b1110: atan_out <= 16'b0000000000000001;
    				4'b1111: atan_out <= 16'b0000000000000000;
    			endcase
    	end		
	always @(posedge Clk)
		begin
          if (Rst)
          begin
          x_out <= 0;
          y_out <= 0;
          theta_out <= 0;
          end
          else 
          begin
          if (x_en)	x_out <= x_MUX_out; 
          if (y_en)	y_out <= y_MUX_out; 
          if (theta_en)	theta_out <= theta_MUX_out;
          end
          if (i_en)	i <= i + 1; else i <= 0;
		end
		
		
	always @(*)
      if (y_out[15] == 0)
		begin
			x = x_out + y_i;
			y = y_out - x_i;
			theta = theta_out + atan_out;			
    		end	
		else
		begin
			x = x_out - y_i;
			y = y_out + x_i;
			theta = theta_out - atan_out;			
    		end	
	
				
	assign x_MUX_out = x_MUX_sel ? x : x_in;
	assign y_MUX_out = y_MUX_sel ? y : y_in;
	assign theta_MUX_out = theta_MUX_sel ? theta : 0;
	assign i_eq_16 = (i == 15);
	assign x_i = x_out >>> i;
  	assign y_i = y_out >>> i;
	
endmodule

// ControlPath

module controlpath(
	input ack, Rst, Clk, operands_val, i_eq_16,
	output reg x_MUX_sel, y_MUX_sel, theta_MUX_sel, i_MUX_sel,
	output reg x_en, y_en, theta_en, i_en,
	output out_valid
);

  reg [1:0] state;
  reg [1:0] state_next;


//parameters to define the states

	parameter idle = 2'b00;
	parameter busy = 2'b01; 
	parameter done = 2'b10;


// Finding current state

always @(posedge Clk)
	begin
		if (Rst)
			state <= idle;
		else
			state <= state_next;
	end

//combinational logic to find next state

always @(*)
	case(state)
		idle : begin
			x_MUX_sel = 0;
			y_MUX_sel = 0;
			theta_MUX_sel = 0;
			i_MUX_sel = 0;
			x_en = 1;
			y_en = 1;
			theta_en = 1;
			i_en = 0;
			
			if (operands_val  == 1)  state_next = busy;
			else state_next = idle;
			
			end
			
		busy : begin
			x_MUX_sel = 1;
			y_MUX_sel = 1;
			theta_MUX_sel = 1;
			i_MUX_sel = 1;
			x_en = 1;
			y_en = 1;
			theta_en = 1;
			i_en = 1;
			
			if (i_eq_16  == 1)  state_next = done;
			else state_next = busy;
			
			end
			
		done : begin
			x_MUX_sel = 0;
			y_MUX_sel = 0;
			theta_MUX_sel = 0;
			x_en = 0;
			y_en = 0;
			i_en = 0;
			theta_en = 0;
         	i_MUX_sel = 0;
			
			if (ack == 1)  state_next = idle;
			else state_next = done;
			
			end
		endcase
			
//Assigning Output

  assign out_valid = (state == done);

endmodule
