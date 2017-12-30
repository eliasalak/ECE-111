`timescale 1ns / 1ps

module adder_8_tb;

//Inputs
logic signed [7:0] a,b;
logic op;

//Outputs
logic signed [7:0] sum;


adder_8 uut(
	.a(a),
	.b(b),
	.op(op),
	.sum(sum)
);

initial begin

a = 8'd15;
b = 8'd13;
op = 1'd0;
#100
$display("op = %d, a = %d, b = %d, sum = %d\n", op, a, b, sum); 

a = 8'd15;
b = -8'd13;
op = 1'd0;
#100
$display("op = %d, a = %d, b = %d, sum = %d\n", op, a, b, sum); 

a = -8'd15;
b = 8'd13;
op = 1'd0;
#100
$display("op = %d, a = %d, b = %d, sum = %d\n", op, a, b, sum); 

a = -8'd15;
b = -8'd13;
op = 1'd0;
#100
$display("op = %d, a = %d, b = %d, sum = %d\n", op, a, b, sum); 

a = 8'd15;
b = 8'd13;
op = 1'd1;
#100
$display("op = %d, a = %d, b = %d, sum = %d\n", op, a, b, sum); 

a = -8'd15;
b = 8'd13;
op = 1'd1;
#100
$display("op = %d, a = %d, b = %d, sum = %d\n", op, a, b, sum); 

a = 8'd15;
b = -8'd13;
op = 1'd1;
#100
$display("op = %d, a = %d, b = %d, sum = %d\n", op, a, b, sum); 

a = -8'd15;
b = -8'd13;
op = 1'd1;
#100
$display("op = %d, a = %d, b = %d, sum = %d\n", op, a, b, sum); 
end

endmodule
