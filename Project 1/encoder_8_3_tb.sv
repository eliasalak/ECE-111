`timescale 1ns / 1ps

module encoder_8_3_tb;

//Inputs
reg [7:0] in;

//Outputs
reg [2:0] out;

encoder_8_3 uut (
	.in(in),
	.out(out)
);

initial begin
in = 8'd1;
#100
$display("in: %b out:%b\n", in, out);

in = 8'd2;
#100
$display("in: %b out:%b\n", in, out);

in = 8'd4;
#100
$display("in: %b out:%b\n", in, out);

in = 8'd8;
#100
$display("in: %b out:%b\n", in, out);

in = 8'd16;
#100
$display("in: %b out:%b\n", in, out);
in = 8'd32;
#100
$display("in: %b out:%b\n", in, out);

in = 8'd64;
#100
$display("in: %b out:%b\n", in, out);

in = 8'd128;
#100
$display("in: %b out:%b\n", in, out);
end
endmodule
