`timescale 1ns / 1ps

module one_hot_32_tb;

//Inputs
logic [31:0] in;

//Outputs
logic	[31:0] out;

one_hot_32 uut (
	.in(in),
	.out(out)
);

initial begin
in = 32'b00111101001000111100010010000000;
#100
$display("in: %b out: %b\n", in, out);

in = 32'b10111101110111100111110110111011;
#100
$display("in: %b out: %b\n", in, out);

in = 32'b00000000001001011011011110111101;
#100
$display("in: %b out: %b\n", in, out);

in = 32'b00000000000000000000000001101000;
#100
$display("in: %b out: %b\n", in, out);

in = 32'b00000010000011010100100001010101;
#100
$display("in: %b out: %b\n", in, out);

in = 32'b00001110000101011101001001010101;
#100
$display("in: %b out: %b\n", in, out);

in = 32'b00001000000000100000001001010101;
#100
$display("in: %b out: %b\n", in, out);

in = 32'b00000000000000100110001001010101;
#100
$display("in: %b out: %b\n", in, out);

in = 32'b00000000000000000000000000000101;
#100
$display("in: %b out: %b\n", in, out);

end
endmodule
