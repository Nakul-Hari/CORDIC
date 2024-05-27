module top_module(
    input signed [15:0] x_in, y_in, theta_in, 
    input operands_val,
    input Clk, Rst, ack,
    output signed [15:0] x_out, y_out,
    output out_valid,
    output [1:0] state
);

    wire x_MUX_sel, y_MUX_sel, theta_MUX_sel, i_MUX_sel, x_en, y_en, theta_en, i_en;
    wire i_eq_16;


    datapath d1 (
        .x_in(x_in),
        .y_in(y_in),
        .theta_in(theta_in),
        .Clk(Clk),
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
        .out_valid(out_valid),
        .state(state)
    );

endmodule



//Datapath

module datapath(
	input signed [15:0] x_in, y_in, theta_in,
	input Clk,
	input x_MUX_sel, y_MUX_sel, theta_MUX_sel, i_MUX_sel, x_en, y_en, theta_en, i_en,
	output reg signed [15:0] x_out, y_out, theta_out,
	output i_eq_16
	);
	
	wire signed [15:0] x_MUX_out, y_MUX_out, theta_MUX_out, x_i, y_i;
	reg signed [15:0] x, y, theta, atan_out;
	reg [3:0] address, i;
	wire [3:0] i_1;

	// Look Up Table

	always @(*)
		begin
		address <= i;
		begin
			case(address)
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
    	end		
	always @(posedge Clk)
		begin
			if (x_en)
				x <= x_MUX_out;
			if (y_en)
				y <= y_MUX_out;
			if (theta_en)
				theta <= theta_MUX_out;
			if (i_en)
				i <= i_1;
		end
		
		
	always @(*)
		if (theta[15] == 1)
		begin
			x_out = x + y_i;
			y_out = y - x_i;
			theta_out = theta + atan_out;			
    		end	
		else
		begin
			x_out = x - y_i;
			y_out = y + x_i;
			theta_out = theta - atan_out;			
    		end	
	
				
	assign i_1 = i_MUX_sel ? i + 1 : 0;	
	assign x_MUX_out = x_MUX_sel ? x_out : x_in;
	assign y_MUX_out = y_MUX_sel ? y_out : y_in;
	assign theta_MUX_out = theta_MUX_sel ? theta_out : theta_in;
	assign i_eq_16 = (i == 15);

	barrel_shifter b1 (x, i, x_i);
	barrel_shifter b2 (y, i, y_i);
	
	
	
endmodule

// implementation of Barrel Shifter

module barrel_shifter(
	input [15:0] input_data, 
	input [3:0] control, 
	output reg [15:0] output_data);

always @(*)
begin
  case(control)
    4'b0000: output_data <= input_data;
    4'b0001: output_data <= {1'b0, input_data[15:1]}; 
    4'b0010: output_data <= {2'b00, input_data[15:2]}; 
    4'b0011: output_data <= {3'b000, input_data[15:3]}; 
    4'b0100: output_data <= {4'b0000, input_data[15:4]}; 
    4'b0101: output_data <= {5'b00000, input_data[15:5]};
    4'b0110: output_data <= {6'b000000, input_data[15:6]}; 
    4'b0111: output_data <= {7'b0000000, input_data[15:7]}; 
    4'b1000: output_data <= {8'b00000000, input_data[15:8]}; 
    4'b1001: output_data <= {9'b000000000, input_data[15:9]}; 
    4'b1010: output_data <= {10'b0000000000, input_data[15:10]};
    4'b1011: output_data <= {11'b00000000000, input_data[15:11]};
    4'b1100: output_data <= {12'b000000000000, input_data[15:12]}; 
    4'b1101: output_data <= {13'b0000000000000, input_data[15:13]}; 
    4'b1110: output_data <= {14'b00000000000000, input_data[15:14]}; 
    4'b1111: output_data <= {15'b000000000000000, input_data[15]}; 
  endcase
end

endmodule

// ControlPath

module controlpath(
	input ack, Rst, Clk, operands_val, i_eq_16,
	output reg x_MUX_sel, y_MUX_sel, theta_MUX_sel, i_MUX_sel,
	output reg x_en, y_en, theta_en, i_en,
	output out_valid,
	output reg [1:0] state = 2'b00
);


	reg [1:0] state_next;


//parameters to define the states

	parameter idle = 2'b00;
	parameter busy = 2'b01; 
	parameter done = 2'b10;


// Finding current state

always @(posedge Clk or posedge ack)
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
			i_en = 1;
			
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
			
			if (ack == 1)  state_next = idle;
			else state_next = done;
			
			end
		endcase
			
//Assigning Output

assign out_valid = (i_eq_16 == 1);

endmodule


