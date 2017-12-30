`timescale 1ns / 1ps

module scientific_tb;

//Inputs
logic	[31:0] in;

//Outputs
logic	[7:0] mantissa;
logic	[4:0] exponent;

 scientific uut(
	.in(in),
	.mantissa(mantissa),
	.exponent(exponent)
);

initial begin

in = 32'b00111101001000111100010010000000;
#100
$display("in: %b mantissa: %b exponent: %b\n", in, mantissa, exponent);

in = 32'b10111101110111100111110110111011;
#100
$display("in: %b mantissa: %b exponent: %b\n", in, mantissa, exponent);

in = 32'b00000000001001011011011110111101;
#100
$display("in: %b mantissa: %b exponent: %b\n", in, mantissa, exponent);

in = 32'b00000000000000000000000001101000;
#100
$display("in: %b mantissa: %b exponent: %b\n", in, mantissa, exponent);

in = 32'b00000000101101001101010010111111;
#100
$display("in: %b mantissa: %b exponent: %b\n", in, mantissa, exponent);

in = 32'b00100000111010011010101000111101;
#100
$display("in: %b mantissa: %b exponent: %b\n", in, mantissa, exponent);

in = 32'b00000000000000000000001111011011;
#100
$display("in: %b mantissa: %b exponent: %b\n", in, mantissa, exponent);

in = 32'b00000000010101101000000000000000;
#100
$display("in: %b mantissa: %b exponent: %b\n", in, mantissa, exponent);

end
endmodule
