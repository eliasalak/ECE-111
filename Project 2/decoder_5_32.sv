module decoder_5_32(in,out);

input 	[4:0] in;
output	[31:0] out;

logic [31:0] out;

always_comb begin

	if 		(in == 5'd0)	out = 32'b1;
	else if	(in == 5'd1)	out = 32'b10;
	else if (in == 5'd2)	out = 32'b100;
	else if (in == 5'd3)	out = 32'b1000;
	else if (in == 5'd4)	out = 32'b10000;
	else if (in == 5'd5)	out = 32'b100000;
	else if (in == 5'd6)	out = 32'b1000000;
	else if (in == 5'd7)	out = 32'b10000000;
	else if (in == 5'd8)	out = 32'b100000000;
	else if (in == 5'd9)	out = 32'b1000000000;
	else if (in == 5'd10)	out = 32'b10000000000;
	else if (in == 5'd11)	out = 32'b100000000000;
	else if (in == 5'd12)	out = 32'b1000000000000;
	else if (in == 5'd13)	out = 32'b10000000000000;
	else if (in == 5'd14)	out = 32'b100000000000000;
	else if (in == 5'd15)	out = 32'b1000000000000000;
	else if (in == 5'd16)	out = 32'b10000000000000000;
	else if (in == 5'd17)	out = 32'b100000000000000000;
	else if (in == 5'd18)	out = 32'b1000000000000000000;
	else if (in == 5'd19)	out = 32'b10000000000000000000;
	else if (in == 5'd20)	out = 32'b100000000000000000000;
	else if (in == 5'd21)	out = 32'b1000000000000000000000;
	else if (in == 5'd22)	out = 32'b10000000000000000000000;
	else if (in == 5'd23)	out = 32'b100000000000000000000000;
	else if (in == 5'd24)	out = 32'b1000000000000000000000000;
	else if (in == 5'd25)	out = 32'b10000000000000000000000000;
	else if (in == 5'd26)	out = 32'b100000000000000000000000000;
	else if (in == 5'd27)	out = 32'b1000000000000000000000000000;
	else if (in == 5'd28)	out = 32'b10000000000000000000000000000;
	else if (in == 5'd29)	out = 32'b100000000000000000000000000000;
	else if (in == 5'd30)	out = 32'b1000000000000000000000000000000;
	else if (in == 5'd31)	out = 32'b10000000000000000000000000000000;

end
endmodule
