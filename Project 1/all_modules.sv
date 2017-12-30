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

module adder_8(a,b,sum,op);

input logic		[7:0] a,b;
input logic		op;
output logic 	[7:0] sum;

logic Cin, Cout;
logic [7:0] b_copy, b_inv, b_out;
logic [7:0] g,p;			// g = generated, p = propegated 
logic [6:0] c;				// CLU C registers

assign b_copy = b;

assign Cin = op ?  1: 0; 

always_comb begin		// Creates inverter 
	if (op == 1) begin
		b_inv 	= ~b_copy;
		//Cin 	= 1'b1;
	end
	//else Cin 	= 1'b0;
end

assign b_out = op ? b_inv : b; // b_out = output of mux

assign sum[0] 	= ((a[0]^b_out[0])^Cin); //Cin = Co
assign g[0] 	= a[0] & b_out[0];
assign p[0]		= a[0] | b_out[0];
assign c[0]		= g[0] | p[0]&Cin; //Cin == Co, and C[0] == C1

assign sum[1] 	= ((a[1]^b_out[1])^c[0]);
assign g[1] 	= a[1] & b_out[1];
assign p[1]		= a[1] | b_out[1];
assign c[1]		= g[1] | p[1]&c[0]; //c[0] == C1 / c[1] = C2

assign sum[2] 	= ((a[2]^b_out[2])^c[1]);
assign g[2] 	= a[2] & b_out[2];
assign p[2]		= a[2] | b_out[2];
assign c[2]		= g[2] | p[2]&c[1]; //c[1] == C2 / c[2] = C3

assign sum[3] 	= ((a[3]^b_out[3])^c[2]); 
assign g[3] 	= a[3] & b_out[3];
assign p[3]		= a[3] | b_out[3];
assign c[3]		= g[3] | p[3]&c[2]; //c[2] == C3 / c[3] = C4

assign sum[4] 	= ((a[4]^b_out[4])^c[3]); 
assign g[4] 	= a[4] & b_out[4];
assign p[4]		= a[4] | b_out[4];
assign c[4]		= g[4] | p[4]&c[3]; //c[3] == C4 / c[4] = C5

assign sum[5] 	= ((a[5]^b_out[5])^c[4]); 
assign g[5] 	= a[5] & b_out[5];
assign p[5]		= a[5] | b_out[5];
assign c[5]		= g[5] | p[5]&c[4]; //c[4] == C5 / c[5] = C6

assign sum[6] 	= ((a[6]^b_out[6])^c[5]); 
assign g[6] 	= a[6] & b_out[6];
assign p[6]		= a[6] | b_out[6];
assign c[6]		= g[6] | p[6]&c[5]; //c[5] == C6 / c[6] = C7

assign sum[7] 	= ((a[7]^b_out[7])^c[6]); 
assign g[7] 	= a[7] & b_out[7];
assign p[7]		= a[7] | b_out[7];
assign Cout		= g[7] | p[7]&c[6]; //c[6] == C7 / Cout = C8

endmodule
