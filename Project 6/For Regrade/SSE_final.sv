module SSE_final (

input logic clk, rst, stop,
input logic [31:0] A, B, 

output logic ready, next,
output logic [31:0] Y

);

logic [31:0] current_sum, adder_out, multip_out, Y_before, Y_current, temp_b;
logic  multip_busy, multip_ready;
logic adder_busy1, adder_ready1, adder_busy2, adder_ready2;
logic [31:0] An ,Bn;
logic start1, start2, start3;

logic [3:0] state;

// Y is the running sum
// rst initializes the module
// ready goes high when ready to give result
	// give result at the clock cycle that ready goes high
	// Don'€™t go high when no result to give
// next goes high when ready to receive the next input
	// receive the next input at the next clock cycle
// stop goes high the clock cycle after next goes high and thereâ€™s no input to give

parameter	ONE = 2'b00, TWO =  2'b01, THREE = 2'b10, FOUR = 2'b11, 
			FIVE = 3'b100, SIX = 3'b101, SEVEN = 3'b110, FINAL = 3'b111, IDLE = 4'b1001;

adder_fp_final adder_1(.clk(clk), .start(start1), .op(1'b1), .A(An), .B(Bn), .ready(adder_ready1), .busy(adder_busy1), .Y(adder_out));
multiplier_fp_final multip_1(.clk(clk), .start(start2), .A(adder_out), .B(adder_out), .ready(multip_ready), .busy(multip_busy), .Y(multip_out));
adder_fp_final adder_2(.clk(clk), .start(start3), .op(1'b0), .A(multip_out), .B(Y_before), .ready(adder_ready2), .busy(adder_busy2), .Y(Y_current));

always_ff@( posedge clk ) begin
		case (state)	
			IDLE: begin
			next <= 1'b0;
			state <= ONE;
			end

			ONE: 
			begin
				An <= A;
				Bn <= B;
				start1 <= 1'b1;			
				state <= TWO;
			end

			TWO:     
			begin
				//next <= 1'b0;
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
				Y_before <= Y_current;
				next <= adder_ready2;
			end

			SEVEN: 
			begin
				ready <= 1'b1;
				Y <= Y_current;
				next <= 1'b0;
				temp_b <= B;
				state <= FINAL;
			end

			FINAL: 
			begin
				if ( stop ) begin 
					state <= 4'b1000;
				end 
				
				ready <= 1'b0;
				if (B != temp_b) begin
					state <= ONE;
				end
			end

			default:
			begin
				if (rst) begin
					Y_before <= 32'd0;
					ready <= 1'b0;
					next <= 1'b1;
					state <= IDLE;
				end
			end
		endcase // state
	
end

endmodule // SSE
