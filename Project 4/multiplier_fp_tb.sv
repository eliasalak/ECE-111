module multiplier_fp_tb;
timeunit 1ns;
timeprecision 1ps;

logic clk, start, ready, busy;
logic [31:0] A, B, Y;

multiplier_fp uut(

	.clk(clk),
	.start(start),
	.A(A),
	.B(B),
	.ready(ready),
	.busy(busy),
	.Y(Y)
);

always begin 
	#5 
	clk = ~clk;
end // always

initial begin
	clk = 1;
	start = 1;

	A = 32'b0_10000001_10000000000000000000000;
	B = 32'b0_10000011_01000000000000000000000;

	#10
	start = 0;
	#60
	
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;

	A = 32'b0_11001000_10010011000000000000000;
	B = 32'b0_11001000_11000001011100000000000;

	#10
	start = 0;
	#60
	
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;

	A = 32'b0_10111111_10011000010000000000000;
	B = 32'b0_10110101_01001000010100000000000;

	#10
	start = 0;
	#60
	
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;

	A = 32'b1_10000001_10000000000000000000000;
	B = 32'b0_10000011_01000000000000000000000;

	#10
	start = 0;
	#60
	
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;

	A = 32'b1_10111111_10011000010000000000000;
	B = 32'b1_10110101_01001000010100000000000;

	#10
	start = 0;
	#60

	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;

	A = 32'b0_10111111_11111000010000000000000;
	B = 32'b0_10110101_01001000010111111111111;

	#10
	start = 0;
	#60

	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;

	A = 32'b0_00000000_00000000000000000000000;
	B = 32'b0_10110101_01001000010111111111111;

	#10
	start = 0;
	#60

	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;

	A = 32'b0_11111111_11100000000000000000000;
	B = 32'b0_10110101_01001000010111111111111;

	#10
	start = 0;
	#60

	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;

	A = 32'b0_11111111_00000000000000000000000;
	B = 32'b0_10110101_01001000010111111111111;

	#10
	start = 0;
	#60

	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);
end // initial
endmodule

