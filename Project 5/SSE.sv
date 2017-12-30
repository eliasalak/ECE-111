module SSE (

input logic clk, rst, stop,
input logic [31:0] A, B, 

output logic ready, next,
output logic [31:0] Y

);

logic [31:0] current_sum, adder_out, multip_out, Y_before, Y_current;
logic  multip_busy, multip_ready;
logic adder_busy1, adder_ready1, adder_busy2, adder_ready2;
logic [31:0] An ,Bn;
logic start1, start2, start3;

logic [2:0] state;

// Y is the running sum
// rst initializes the module
// ready goes high when ready to give result
	// give result at the clock cycle that ready goes high
	// Don'€™t go high when no result to give
// next goes high when ready to receive the next input
	// receive the next input at the next clock cycle
// stop goes high the clock cycle after next goes high and thereâ€™s no input to give

parameter	ONE = 2'b00, TWO =  2'b01, THREE = 2'b10, FOUR = 2'b11, 
			FIVE = 3'b100, SIX = 3'b101, SEVEN = 3'b110, FINAL = 3'b111;

adder_fp adder_1(.clk(clk), .start(start1), .op(1'b1), .A(An), .B(Bn), .ready(adder_ready1), .busy(adder_busy1), .Y(adder_out));
multiplier_fp multip_1(.clk(clk), .start(start2), .A(adder_out), .B(adder_out), .ready(multip_ready), .busy(multip_busy), .Y(multip_out));
adder_fp adder_2(.clk(clk), .start(start3), .op(1'b0), .A(multip_out), .B(Y_before), .ready(adder_ready2), .busy(adder_busy2), .Y(Y_current));

always_ff@( posedge clk ) begin

	if (rst) begin
		An <= 32'b0;
		Bn <= 32'b0;
		Y_before <= 32'd0;
		ready <= 1'b0;
		next <= 1'b0;
		state <= ONE;
	end

	else begin
		case (state)
		
			ONE: 
			begin
				if (An != A && Bn != B) begin
					An <= A;
					Bn <= B;
					start1 <= 1'b1;
					
					state <= TWO;
				end
				else begin
					state <= ONE;
				end
			end

			TWO:     
			begin
				next <= 1'b0;
				start1 <= 1'b0;
				state <= (adder_ready1) ? THREE : TWO; // Keeps checking if subtraction is done
			end

			THREE: 
			begin
				// Computes the square
				start2 <= 1'b1;
				state <= FOUR;
			end

			FOUR: 
			begin
				start2 <= 1'b0;
				state <= (multip_ready) ? FIVE : FOUR;
			end

			FIVE: 
			begin
				start3 <= 1'b1;
				state <= SIX;			
			end

			SIX:
			begin 
				start3 <= 1'b0;
				state <= (adder_ready2) ? SEVEN : SIX;
				next <= adder_ready2;
			end

			SEVEN: 
			begin
				
				Y_before <= Y_current; // Y_before = Y_current = Y_before + (a-b)^2	
				if ( stop ) begin 
					state <= FINAL;
				end 
				else begin
					state <= ONE;
				end
			end

			FINAL: 
			begin
				ready <= 1'b1;
				Y <= Y_current;
			end

			default:
			begin
				state <= ONE;
			end
		endcase // state
	end
end

endmodule // SSE
