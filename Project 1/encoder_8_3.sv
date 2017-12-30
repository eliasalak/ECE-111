module encoder_8_3(in,out);

input	[7:0] in;
output	[2:0] out;
reg 	[2:0] out;

always_comb begin

	if		(in == 8'd1) 	out = 3'd0;
	else if (in == 8'd2) 	out = 3'd1;
	else if (in == 8'd4) 	out = 3'd2;
	else if (in == 8'd8) 	out = 3'd3;
	else if (in == 8'd16) 	out = 3'd4;
	else if (in == 8'd32) 	out = 3'd5;
	else if (in == 8'd64) 	out = 3'd6;
	else if (in == 8'd128) 	out = 3'd7;
	else out = 3'd0;

end
endmodule
