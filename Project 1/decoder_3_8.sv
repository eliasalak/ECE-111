module decoder_3_8(in,out);

input 	[2:0] in;
output	[7:0] out;
reg		[7:0] out;

always_comb begin

	if 		(in == 3'd0)	out = 8'd1;
	else if	(in == 3'd1)	out = 8'd2;
	else if (in == 3'd2)	out = 8'd4;
	else if (in == 3'd3)	out = 8'd8;
	else if (in == 3'd4)	out = 8'd16;
	else if (in == 3'd5)	out = 8'd32;
	else if (in == 3'd6)	out = 8'd64;
	else if (in == 3'd7)	out = 8'd128;
	else out = 8'd0;
end
endmodule
