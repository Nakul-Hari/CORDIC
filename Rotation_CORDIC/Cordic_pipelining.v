module pipelined_cordic(
    input Clk, Rst,
    input signed[15:0] x_in, y_in, theta_in,
    output reg signed[15:0] sine_theta,
    output reg signed[15:0] cosine_theta
);

reg signed [15:0] x[0:15], y[0:15], theta[0:15], x_out[0:15], y_out[0:15], theta_out[0:15];
wire signed [15:0] atan_out [0:15];
reg [3:0] stage; // Counter to track pipeline stages

assign atan_out[0] = 16'b0011001001000100;
assign atan_out[1] = 16'b0001110110101100;
assign atan_out[2] = 16'b0000111110101101;
assign atan_out[3] = 16'b0000011111110101;
assign atan_out[4] = 16'b0000001111111110;
assign atan_out[5] = 16'b0000001000000000;
assign atan_out[6] = 16'b0000000100000000;
assign atan_out[7] = 16'b0000000010000000;
assign atan_out[8] = 16'b0000000001000000;
assign atan_out[9] = 16'b0000000000100000;
assign atan_out[10] = 16'b0000000000010000;
assign atan_out[11] = 16'b0000000000001000;
assign atan_out[12] = 16'b0000000000000100;
assign atan_out[13] = 16'b0000000000000010;
assign atan_out[14] = 16'b0000000000000001;
assign atan_out[15] = 16'b0000000000000000;

// Generate block for pipeline stages
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : stages
        always @(posedge Clk or posedge Rst) begin
            if (Rst)
                begin
                    x[i] <= 0;
                    y[i] <= 0;
                    theta[i] <= 0;
                end
            else 
                begin
                    if (i == 0) begin
                        x[i] <= x_in;
                        y[i] <= y_in;
                        theta[i] <= theta_in;
                    end else begin
                        x[i] <= x_out[i-1];
                        y[i] <= y_out[i-1];
                        theta[i] <= theta_out[i-1];
                    end
                end
        end

        always @(*) begin
            if (theta[i][15] == 1) begin
                x_out[i] = x[i] + (y[i] >> (i));
                y_out[i] = y[i] - (x[i] >> (i));
                theta_out[i] = theta[i] + atan_out[i];
            end else begin
                x_out[i] = x[i] - (y[i] >> (i));
                y_out[i] = y[i] + (x[i] >> (i));
                theta_out[i] = theta[i] - atan_out[i];
            end
        end
    end
endgenerate

always @(posedge Clk or posedge Rst) begin
    if (Rst) begin
        sine_theta <= 0;
        cosine_theta <= 0;
    end else begin
        sine_theta <= y_out[15]; // Output from the last stage
        cosine_theta <= x_out[15]; // Output from the last stage
    end
end

endmodule

