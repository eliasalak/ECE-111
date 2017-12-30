module multiplier_fp(

input logic clk, start,
input logic [31:0] A, B,

output logic ready, busy,
output logic [31:0] Y
);

parameter ONE = 3'b000, TWO = 3'b001, THREE = 3'b010, FOUR = 3'b011, FIVE = 3'b100, FINAL = 3'b101;

logic overf_bit;
logic [7:0] exA, exB, exResult;
logic [8:0] exSum;
logic [23:0] sigA, sigB, sigResult;
logic [49:0] multip_reg;	// {48'answer, 2'bRS}
logic sign;
logic [2:0] state;

always_ff @(posedge clk) begin
	case(state)
		ONE:
		begin
			busy <= 1;
			state <= TWO;
			// NaN: Expo 11..1 and sig != 00..0 (we made it 11..1)
		    // inf: Expo 11..1 and sig == 00..0
			
			// NaN input, NaN output
			if ((exA == 8'd255 && A[22:0] != 23'd0)||(exB == 8'd255 && B[22:0] != 23'd0)) begin
				Y = {1'b0,8'd255,23'd8388607};
				state <= FINAL;
			end

			// inf * 0 = NaN
			if ((exA == 8'd255 && A[22:0] == 23'd0) && (exB == 8'd0 && B[22:0] == 23'd0)) begin
				Y = {1'b0,8'd255,23'd8388607};
				state <= FINAL;
			end

			// 0 * inf = NaN
			if ((exA == 8'd0 && A[22:0] == 23'd0) && (exB == 8'd255 && B[22:0] == 23'd0)) begin
				Y = {1'b0,8'd255,23'd8388607};
				state <= FINAL;
			end

			// Anything * 0 = 0
			if ((exA == 8'd0 && A[22:0] == 23'd0)||(exB == 8'd0 && B[22:0] == 23'd0)) begin
				Y = {1'b0,8'd0,23'd0};
				state <= FINAL;
			end

			// Covers inf*inf or inf w/ another number:
			if ((exA == 8'd255 && A[22:0] == 23'd0)||(exB == 8'd255 && B[22:0] == 23'd0)) begin
				Y = {sign,8'd255,23'd0};
				state <= FINAL;
			end

			if ( exSum > 9'd381 ) begin 	// Overflow occurs
				exResult <= 8'b1111_1111;
				Y <= {sign,exResult[7:0],23'b0};
				state <= FINAL;
			end 	
		
			else if ( exSum < 8'd127 ) begin // If exResult - 127 < 0,  returns 0
				Y <= {1'b0,8'b0,23'b0};
				state <= FINAL;
			end
		end

		// The computer sees the following:
		// User:	-127	0		128 (unbiased)
		// Comp: 	0		127		255 (biased)
		// Therefore, just check where the exponent falls
		// using the computers perspective
			
		// NOTE: After adding exA and exB -> must -127 from it (step)
		// To convert from bias to unbias, subtract -127 from exResult

		 // Example: 2^5 * 2^4 = 2^9 [1. Add bias (add 127)]
		 // 			2^(132)*2^(131) = 2^(263 - 127) = 2^(136) [2. Remove bias]
		 // 			2^(136 - 127) = 2^9

		 // Example: 2^-100 * 2^-120 = 2^-240 
		 // 			2^(75) * 2^(7) 	= 2^(84 - 127) -> 2^(-45)
		 // Both are out of range [-127 - 128, 0 - 255], thus return 0
		 // Therefore: exResult >= 127 to be able to be represented 
		TWO: 
		begin
			exResult <= (exSum[8:0] - 8'd127);
			multip_reg[49:2] <= sigA * sigB;
			state <= THREE;
		end
	
		THREE:
		begin
			if (multip_reg[49] == 1) begin //sometimes the multiplication will not end up in 10.XX or 11.XX, you can also have 01.XX
				multip_reg <= multip_reg >> 1;
				exResult <= exResult + 8'b00000001;
				state <= FOUR;
			end	
			else begin
				Y <= {sign,exResult[7:0],multip_reg[47:25]}; //this is wrong
				state <= FINAL; 
			end
			
		end
	
		FOUR:
		begin
			if (exResult == 8'd255) begin
				
				Y <= {sign,exResult[7:0],23'b0};
				state <= FINAL;
			end
			else begin
				sigResult[22:0] <= multip_reg[47:25];
				multip_reg[0] <= |multip_reg[47:1]; // Assign to sticky bit
				state <= FIVE;
			end
		end
		
		FIVE:
		begin
			if (multip_reg[1:0] == 2'b11 || multip_reg[1:0] == 2'b10) begin
				if (sigResult[0] == 1'b1) begin
					if (sigResult == 23'd8388607) begin
						sigResult <= 23'b0;
						exResult <= 8'd255;
					end
					else begin
						sigResult <= sigResult + 23'd1;
					end
				end
			end
			state <= FINAL;
			Y <= {sign,exResult[7:0],sigResult[22:0]};
		end // SIX
	
		FINAL: 
		begin 
			busy <= 0;
			ready <= 1;
			state <= 3'b111;
		end
		
		default:
		begin 
			ready <= 0;
			busy <= 0;
			if (start) begin
				exA <= A[30:23];
				exB <= B[30:23];
				sigA <= { 1'b1 , A[22:0]}; // significand includes the 1.(mantissa), sticky bits at end
				sigB <= { 1'b1 , B[22:0]}; // sigA = 1. + mantissas
				sign <= 1'b0;
				multip_reg <= 50'd0;
				exResult <= 8'd0;
				sigResult <= 24'd0;
				sign  <= A[31] ^ B[31];
				exSum <= A[30:23] + B[30:23]; 		
				state <= ONE;
			end
		end
	endcase // state
end // always_ff 

endmodule // multiplier_fp
