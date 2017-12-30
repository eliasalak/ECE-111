
module adder_fp_tb;
timeunit 1ns;
timeprecision 1ps;


logic clk, start, op;
logic [31:0] A, B, Y;
logic ready, busy;

adder_fp uut(

	.clk(clk),
	.start(start),
	.op(op),
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
	A = 32'h92b2_18af;
	B = 32'h1ec2_2880;
	op = 0;

	#10

	start = 0;

	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);



	start = 1;
	A = 32'b0_01111111_00000000000000000000000;
	B = 32'b0_01111111_00000000000000000000000;
	op = 0;

	#10

	start = 0;

	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;
	A = 32'b0_10000000_10000000000000000000000;
	B = 32'b0_10000001_01000000000000000000000;
	op = 0;

	#10

	start = 0;

	//if ( busy != 1'b1) begin
	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;
	A = 32'b0_01111111_10000000000000000000000;
	B = 32'b1_01111111_01000000000000000000000;
	op = 0;

	#10

	start = 0;

	#10
	#10
	#10
	#10
	#10

	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;
	A = 32'b0_10000100_10000000000000000000000;
	B = 32'b0_01111111_10000000000000000000000;
	op = 0;

	#10

	start = 0;

	
	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);


	start = 1;
	A = 32'b0_11111111_10000000000000000000000;
	B = 32'b0_11111111_10000000000000000000000;
	op = 0;

	#10

	start = 0;

	//if ( busy != 1'b1) begin
	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;
	A = 32'b0_01111111_10000000000001000000001;
	B = 32'b0_01111111_10000000000001000000000;
	op = 0;

	#10

	start = 0;

	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;
	A = 32'b1_11111111_00000000000000000000000;
	B = 32'b1_11111111_00000000000000000000000;
	op = 0;

	#10

	start = 0;

	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;
	A = 32'b1_11111111_00000000000000000000000;
	B = 32'b1_11111111_00000000000000000000000;
	op = 1;

	#10

	start = 0;

	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;
	A = 32'b1_11111111_00000000000000000000000;
	B = 32'b1_11111111_00000000000000000000000;
	op = 1;

	#10

	start = 0;

	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;
	A = 32'b1_00000000_00000000000000000000000;
	B = 32'b1_11111111_00000000000000000000000;
	op = 1;

	#10

	start = 0;

	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);

	start = 1;
	A = 32'b1_00000000_00000000000000000000000;
	B = 32'b1_01111111_01000000000000000000000;
	op = 1;

	#10

	start = 0;

	#10
	#10
	#10
	#10
	#10
	$display("A: Sign: %b   Exponent: %b   Mantissa: %b", A[31], A[30:23], A[22:0]);
	$display("B: Sign: %b   Exponent: %b   Mantissa: %b", B[31], B[30:23], B[22:0]);
	$display("op: %b",op);
	$display("Y: Sign: %b   Exponent: %b   Mantissa: %b\n", Y[31], Y[30:23], Y[22:0]);
	
end // initial
endmodule

