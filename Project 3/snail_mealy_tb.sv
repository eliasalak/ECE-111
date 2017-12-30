module snail_mealy_tb;
timeunit 1ns;
timeprecision 1ps;

//Inputs
logic A, clk, rst;

//Outputs
logic Y;

logic [23:0] A_sequence;


snail uut(
	.A(A),
	.clk(clk),
	.rst(rst),
	.Y(Y)
);

//Model Clock
always begin
	#5 clk = ~clk;
end

initial begin
clk = 1;
rst = 1;
#10

rst = 0;

A_sequence = 24'b111000110100111011101101;

for (int i = 23; i >= 0; i--) begin
		A = A_sequence[i];
		#10
		$display("A: %b Y: %b", A, Y);
	end



end
endmodule 

