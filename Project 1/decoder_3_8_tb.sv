`timescale 1ns / 1ps

module decoder_3_8_tb;

//Inputs
reg [2:0] in;

//Outputs
reg	[7:0] out;

decoder_3_8 uut (
	.in(in),
	.out(out)
);

initial begin
in = 3'd0;
#100
$display("in: %b out: %b\n", in, out);

in = 3'd1;
#100
$display("in: %b out: %b\n", in, out);

in = 3'd2;
#100
$display("in: %b out: %b\n", in, out);

in = 3'd3;
#100
$display("in: %b out: %b\n", in, out);

in = 3'd4;
#100
$display("in: %b out: %b\n", in, out);

in = 3'd5;
#100
$display("in: %b out: %b\n", in, out);

in = 3'd6;
#100
$display("in: %b out: %b\n", in, out);

in = 3'd7;
#100
$display("in: %b out: %b\n", in, out);;

end
endmodule
