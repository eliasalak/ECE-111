module adder_fp_final(

input logic clk, start, op, 
input logic [31:0] A, B, 

output logic ready, busy,
output logic [31:0] Y

);

logic [2:0] state;
logic overf_bit;
logic [7:0] expo_diff, exA, exB, exResult;
logic [25:0] sigA, sigB, sigResult;
logic sign;

parameter ONE = 2'b00, TWO = 2'b01, THREE = 2'b10, FOUR = 2'b11, FOURNHALF =3'b110 , FIVE = 3'b100, SIX = 3'b101;

always_ff @(posedge clk) begin
	case(state)
	ONE:
	begin
	busy <= 1;
	if (exA == 8'b1111_1111 && exB == 8'b1111_1111) begin
		exResult = 8'b1111_1111;
		if (A[22:0] == 23'b0 && B[22:0] == 23'b0) begin //both infinity
			if (op == 0 && A[31] == B[31]) begin //addition, both the same sign
				sign <= A[31];
				sigResult <= 26'b0;
			end
			else if (op == 1 && A[31] == B[31]) begin //subtraction, both the same sign
				sign <= 1'b0;
				sigResult <= 26'd67108863;
			end			
		end	
		else if (A[22:0] != 23'b0 || B[22:0] != 23'b0) begin //either one NaN
			sign <= 1'b0;
			sigResult <= 26'd67108863;
		end	
		state <= FIVE;		
	end	
	
	//either A or B are infinity or NaN
	else if (exA == 8'b1111_1111 ^ exB == 8'b1111_1111) begin 
		exResult <= 8'b1111_1111;
		if (exA == 8'b1111_1111 && A[22:0] != 23'b0) begin
			sign <= 1'b0;
			sigResult <= 26'd67108863;
		end
		else if (exB == 8'b1111_1111 && B[22:0] != 23'b0) begin
			sign <= 1'b0;
			sigResult <= 26'd67108863;
		end
		else if (exA == 8'b1111_1111 && A[22:0] == 23'b0) begin
			sign = A[31];
			sigResult <= 26'b0;
		end
		else if (exB == 8'b1111_1111 && B[22:0] == 23'b0) begin
			sign <= op ^  B[31];
			sigResult <= 26'b0;
		end
		state <= FIVE;	
	end
	
	//B is zero
	else if (exB == 8'b0 && B[22:0] == 23'b0) begin
		sign = A[31];
		sigResult[24:2] <= A[22:0];
		exResult <= exA;	
		state <= FIVE;
	end 

	//A is zero
	else if (exA == 8'b0 && A[22:0] == 23'b0) begin
		sign = B[31] ^ op;
		sigResult[24:2] <= B[22:0];
		exResult <= exB;	
		state <= FIVE;
	end
	

	else begin
		if (op == 1'b1 && A == B) begin
			exResult <= 8'b0;
			sigResult <= 26'b0;
			state <= FIVE;
		end
		
		else begin
		if ( exA < exB ) begin	// Checks which exponent is larger
			sigA <= sigA >> expo_diff;		// Shifts sigA until MSB matches B
			exResult <= exA + expo_diff;		// Makes exponent the same
		end

		else if ( exA > exB ) begin
			sigB <= sigB >> expo_diff;		// Shifts sigB until MSB matches
			exResult <= exB + expo_diff;
		end	

		state <= TWO;
		end
	end
	end

	TWO:
	begin	
		if (A[31] == B[31]) begin
			if (op == 1'b0) begin
				sign <= A[31];
		   		{overf_bit,sigResult} <= sigA + sigB;
			end
			else begin
				if (sigA > sigB) begin
					sign <= A[31];
					{overf_bit,sigResult} <= sigA - sigB;
				end
				else begin
					sign = op ^ B[31];
					{overf_bit,sigResult} <= sigB - sigA;
				end
			end
		end

		else begin
			if (sigA > sigB) begin
				if (op == 1'b0) begin
					sign <= A[31];
					{overf_bit,sigResult} <= sigA - sigB;
				end
				else begin
					sign <= A[31];
					{overf_bit,sigResult} <= sigA + sigB;
				end
			end
			
			else begin
				if (op == 1'b0) begin
					sign <= B[31];
					{overf_bit,sigResult} <= sigB - sigA;
				end
				else begin
					sign <= op ^ B[31];
					{overf_bit,sigResult} <= sigB + sigA;
				end
			end
		end
		state <= THREE;
	end

	THREE:
	begin
		if (overf_bit == 1'b0) begin
			if (sigResult[25] == 1'b0) begin
				sigResult <= sigResult << 1;
				exResult <= exResult - 1'b1;
				state <= THREE;
			end

			else begin
				state <= FOUR;
			end
		end
	
		else if (overf_bit == 1'b1) begin
			if (exResult == 8'b1111_1111) begin
				state <= FIVE;
				sigResult <= 26'b0;
			end
			else begin
				//sigResult <= sigResult >> 1;
				exResult <= exResult + 8'b00000001;
				sigResult <= {overf_bit,sigResult[25:1]};
				state <= FOUR;
			end
		end
	end
	
	FOUR:
	begin
		if (exResult == 8'b1111_1111) begin
			sigResult <= 26'b0;
		end

		else begin
			sigResult[0] = |sigResult[24:1];
			if (sigResult[1:0] == 2'b11 || sigResult[1:0] == 2'b10) begin 
				if (sigResult[2] == 1'b1) begin
					sigResult <= sigResult + 2'b10;
				end
			end
		end

	state <= FIVE;
	end

	FIVE: 
	begin
		ready <= 1;
		busy <= 0;
		Y <= {sign,exResult,sigResult[24:2]};
		state <= 3'b111;
	end

	default:
	begin
	busy <= 0;
	ready <= 0;

	if (start) begin
		ready <= 0;
		exA <= A[30:23];	// Exponent of A extracted
		exB <= B[30:23];
		sign <= A[31];
		sigA <= {1'b1 , A[22:0], 2'b0}; // significand includes the 1.(mantissa), sticky bits at en
		sigB <= {1'b1 , B[22:0], 2'b0}; // SigA = 1. + mantissas
		exResult <= A[30:23];
		expo_diff <= (A[30:23] > B[30:23]) ? (A[30:23] - B[30:23]) : (B[30:23] - A[30:23]);
		state <= ONE;
	end
	end

	endcase // state
	
end // always_ff @(posedge clk, posedge rst)

endmodule


module multiplier_fp_final(

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
			// NaN: Expo 11..1 and sig != 00..0 (we made it 11..1)
		    // inf: Expo 11..1 and sig == 00..0

			if (exA == 8'd255 || exB == 8'd255) begin //either input is either NaN or infinity
				state <= FINAL;
				if ((A[22:0] != 23'd0 && exA == 8'd255) || (B[22:0] != 23'd0 && exB == 8'd255)) begin //either input is NaN
					Y = {1'b0,8'd255,23'd8388607};
				end

				else begin //either input is infinity
					if ((exA == 8'd0 && A[22:0] == 23'd0) || (exB == 8'd0 && B[22:0] == 23'd0)) begin //if either input is 0 (inf*0)
						Y = {1'b0,8'd255,23'd8388607};
					end
		
					else begin //anything * inf or inf*inf
						Y = {sign,8'd255,23'd0};
					end
				end
			end
			

			// Anything * 0 = 0
			else if (exA == 8'd0 || exB == 8'd0) begin
				Y = {1'b0,8'd0,23'd0};
				state <= FINAL;
			end

			else begin 
				if ( exSum > 9'd381 ) begin 	// Overflow occurs
					exResult <= 8'b1111_1111;
					Y <= {sign,exResult[7:0],23'b0};
					state <= FINAL;
				end 	
		
				else if ( exSum < 8'd127 ) begin // If exResult - 127 < 0,  returns 0
					Y <= {1'b0,8'b0,23'b0};
					state <= FINAL;
				end

				else begin
					state <= TWO;
				end
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
				multip_reg <= 50'd0;
				exResult <= 8'd0;
				sigResult <= 24'd0;
				sign  <= A[31]^B[31];
				exSum <= A[30:23] + B[30:23]; 		
				state <= ONE;
			end
		end
	endcase // state
end // always_ff 

endmodule // multiplier_fp

module SSE_final (

input logic clk, rst, stop,
input logic [31:0] A, B, 
input logic pause,
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
				if ( stop ) begin 
					state <= 4'b1000;
				end 
				else begin
					state <= FINAL;
				end
			end

			FINAL: 
			begin
				ready <= 1'b0;
				if (pause == 1'b0) begin
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

module FIR_final(clk, rst, stop, in, pause, next, ready, out);

input logic pause;
input logic clk, rst, stop;
input logic [31:0] in;
output logic next, ready;
output logic [31:0] out;

logic [31:0] coeff, coeff2, temp_in;
logic [31:0] A_mult1, B_mult1, A_mult2, B_mult2, mult_out1, mult_out2;
logic [31:0] A_add1, B_add1, A_add2, B_add2, add_out1, add_out2, temp_out1, temp_out2;
logic [31:0] x [200:0];
logic [31:0] temp_add [100:0];
logic [31:0] temp_mult [100:0];
logic start_a1, start_a2, add_ready1, add_ready2, add_busy1, add_busy2, a_ready1, a_ready2;
logic start_m1, start_m2,mult_ready1, mult_ready2, mult_busy1, mult_busy2, t_ready1, t_ready2;
logic valid, flag;
logic [7:0] counter, k,c2;
logic [10:0]  master_counter;
logic [3:0] state;

parameter ONE = 3'b0, TWO = 3'b001, THREE = 3'b010, FOUR = 3'b011, FIVE = 3'b100, SIX = 3'b101, SEVEN = 3'b111, EIGHT = 4'b1000, FOURNEXT = 4'b1001, FOURNEXT2 = 4'b1010, SIXNEXT = 4'b1011, SIXNEXT2 = 4'b1100;

always_comb begin
if (valid) begin
case (counter) 
8'd0: coeff[31:0] = 32'hbbcc4aca;
8'd1: coeff[31:0] = 32'hbb215c45;
8'd2: coeff[31:0] = 32'h3c13004e;
8'd3: coeff[31:0] = 32'h3bb3f395;
8'd4: coeff[31:0] = 32'h3bc49cac;
8'd5: coeff[31:0] = 32'hba75cc87;
8'd6: coeff[31:0] = 32'hbc6bffbd;
8'd7: coeff[31:0] = 32'h3ab95ba1;
8'd8: coeff[31:0] = 32'h3b4ce7c3;
8'd9: coeff[31:0] = 32'hbc1191d5;
8'd10: coeff[31:0] = 32'h3a4924c0;
8'd11: coeff[31:0] = 32'h3b4fd659;
8'd12: coeff[31:0] = 32'h3b1bfaf7;
8'd13: coeff[31:0] = 32'h3a583d5d;
8'd14: coeff[31:0] = 32'h3a2ff173;
8'd15: coeff[31:0] = 32'h3bd1822c;
8'd16: coeff[31:0] = 32'hba95c705;
8'd17: coeff[31:0] = 32'hba17de74;
8'd18: coeff[31:0] = 32'h3ad13127;
8'd19: coeff[31:0] = 32'hbb3b8b4e;
8'd20: coeff[31:0] = 32'hba300412;
8'd21: coeff[31:0] = 32'hbb8e35d6;
8'd22: coeff[31:0] = 32'hba81833f;
8'd23: coeff[31:0] = 32'hba60263a;
8'd24: coeff[31:0] = 32'hbb69bfe5;
8'd25: coeff[31:0] = 32'h3b36481b;
8'd26: coeff[31:0] = 32'hba185a1f;
8'd27: coeff[31:0] = 32'h3b2d163a;
8'd28: coeff[31:0] = 32'h3b4cedc4;
8'd29: coeff[31:0] = 32'h3a58defe;
8'd30: coeff[31:0] = 32'h3baeb9a3;
8'd31: coeff[31:0] = 32'hba8a434d;
8'd32: coeff[31:0] = 32'h3ae7d442;
8'd33: coeff[31:0] = 32'hb80472f8;
8'd34: coeff[31:0] = 32'hbb87d263;
8'd35: coeff[31:0] = 32'h397829f3;
8'd36: coeff[31:0] = 32'hbbcca71c;
8'd37: coeff[31:0] = 32'hbab6b5da;
8'd38: coeff[31:0] = 32'hbb17bd4f;
8'd39: coeff[31:0] = 32'hbb6ef600;
8'd40: coeff[31:0] = 32'h3b721e18;
8'd41: coeff[31:0] = 32'hbafcef0e;
8'd42: coeff[31:0] = 32'h3bac992f;
8'd43: coeff[31:0] = 32'h3b73d8dd;
8'd44: coeff[31:0] = 32'h3af4a46b;
8'd45: coeff[31:0] = 32'h3bf75c42;
8'd46: coeff[31:0] = 32'hbaeec151;
8'd47: coeff[31:0] = 32'h3b7d021a;
8'd48: coeff[31:0] = 32'hbae233fe;
8'd49: coeff[31:0] = 32'hbba7b545;
8'd50: coeff[31:0] = 32'h36a66c39;
8'd51: coeff[31:0] = 32'hbc25a059;
8'd52: coeff[31:0] = 32'hba83bc02;
8'd53: coeff[31:0] = 32'hbba9db30;
8'd54: coeff[31:0] = 32'hbb8696f0;
8'd55: coeff[31:0] = 32'h3ba264fb;
8'd56: coeff[31:0] = 32'hbb5b6573;
8'd57: coeff[31:0] = 32'h3c1e6500;
8'd58: coeff[31:0] = 32'h3b8166a0;
8'd59: coeff[31:0] = 32'h3b9cacd9;
8'd60: coeff[31:0] = 32'h3c32aca6;
8'd61: coeff[31:0] = 32'hbb46ac4e;
8'd62: coeff[31:0] = 32'h3bf8387a;
8'd63: coeff[31:0] = 32'hbba4edfc;
8'd64: coeff[31:0] = 32'hbbc3108a;
8'd65: coeff[31:0] = 32'hbac6b5a5;
8'd66: coeff[31:0] = 32'hbc86ba3b;
8'd67: coeff[31:0] = 32'hb954c6ee;
8'd68: coeff[31:0] = 32'hbc37d138;
8'd69: coeff[31:0] = 32'hbb8341c3;
8'd70: coeff[31:0] = 32'h3bca3738;
8'd71: coeff[31:0] = 32'hbbac4f70;
8'd72: coeff[31:0] = 32'h3c9387cb;
8'd73: coeff[31:0] = 32'h3b75521f;
8'd74: coeff[31:0] = 32'h3c44b41c;
8'd75: coeff[31:0] = 32'h3c869945;
8'd76: coeff[31:0] = 32'hbb8dfedd;
8'd77: coeff[31:0] = 32'h3c7abb09;
8'd78: coeff[31:0] = 32'hbc515c26;
8'd79: coeff[31:0] = 32'hbbd04b55;
8'd80: coeff[31:0] = 32'hbbe1dae6;
8'd81: coeff[31:0] = 32'hbcf65064;
8'd82: coeff[31:0] = 32'h3a6796ce;
8'd83: coeff[31:0] = 32'hbcdfe866;
8'd84: coeff[31:0] = 32'hbb166fb5;
8'd85: coeff[31:0] = 32'h3be6e50f;
8'd86: coeff[31:0] = 32'hbc0cc7b9;
8'd87: coeff[31:0] = 32'h3d2cb157;
8'd88: coeff[31:0] = 32'h3b49eb83;
8'd89: coeff[31:0] = 32'h3d2066e4;
8'd90: coeff[31:0] = 32'h3d0b4888;
8'd91: coeff[31:0] = 32'hbbb302e0;
8'd92: coeff[31:0] = 32'h3d40a3e2;
8'd93: coeff[31:0] = 32'hbd4d4da2;
8'd94: coeff[31:0] = 32'hbbcaa26f;
8'd95: coeff[31:0] = 32'hbd4554bb;
8'd96: coeff[31:0] = 32'hbe0660fb;
8'd97: coeff[31:0] = 32'h3b063e1a;
8'd98: coeff[31:0] = 32'hbe88b191;
8'd99: coeff[31:0] = 32'h3d55e7b0;
8'd100: coeff[31:0] = 32'h3f2c8d43;
default: coeff = 32'b0;
endcase

case (c2) 
8'd50: coeff2[31:0] = 32'h36a66c39;
8'd51: coeff2[31:0] = 32'hbc25a059;
8'd52: coeff2[31:0] = 32'hba83bc02;
8'd53: coeff2[31:0] = 32'hbba9db30;
8'd54: coeff2[31:0] = 32'hbb8696f0;
8'd55: coeff2[31:0] = 32'h3ba264fb;
8'd56: coeff2[31:0] = 32'hbb5b6573;
8'd57: coeff2[31:0] = 32'h3c1e6500;
8'd58: coeff2[31:0] = 32'h3b8166a0;
8'd59: coeff2[31:0] = 32'h3b9cacd9;
8'd60: coeff2[31:0] = 32'h3c32aca6;
8'd61: coeff2[31:0] = 32'hbb46ac4e;
8'd62: coeff2[31:0] = 32'h3bf8387a;
8'd63: coeff2[31:0] = 32'hbba4edfc;
8'd64: coeff2[31:0] = 32'hbbc3108a;
8'd65: coeff2[31:0] = 32'hbac6b5a5;
8'd66: coeff2[31:0] = 32'hbc86ba3b;
8'd67: coeff2[31:0] = 32'hb954c6ee;
8'd68: coeff2[31:0] = 32'hbc37d138;
8'd69: coeff2[31:0] = 32'hbb8341c3;
8'd70: coeff2[31:0] = 32'h3bca3738;
8'd71: coeff2[31:0] = 32'hbbac4f70;
8'd72: coeff2[31:0] = 32'h3c9387cb;
8'd73: coeff2[31:0] = 32'h3b75521f;
8'd74: coeff2[31:0] = 32'h3c44b41c;
8'd75: coeff2[31:0] = 32'h3c869945;
8'd76: coeff2[31:0] = 32'hbb8dfedd;
8'd77: coeff2[31:0] = 32'h3c7abb09;
8'd78: coeff2[31:0] = 32'hbc515c26;
8'd79: coeff2[31:0] = 32'hbbd04b55;
8'd80: coeff2[31:0] = 32'hbbe1dae6;
8'd81: coeff2[31:0] = 32'hbcf65064;
8'd82: coeff2[31:0] = 32'h3a6796ce;
8'd83: coeff2[31:0] = 32'hbcdfe866;
8'd84: coeff2[31:0] = 32'hbb166fb5;
8'd85: coeff2[31:0] = 32'h3be6e50f;
8'd86: coeff2[31:0] = 32'hbc0cc7b9;
8'd87: coeff2[31:0] = 32'h3d2cb157;
8'd88: coeff2[31:0] = 32'h3b49eb83;
8'd89: coeff2[31:0] = 32'h3d2066e4;
8'd90: coeff2[31:0] = 32'h3d0b4888;
8'd91: coeff2[31:0] = 32'hbbb302e0;
8'd92: coeff2[31:0] = 32'h3d40a3e2;
8'd93: coeff2[31:0] = 32'hbd4d4da2;
8'd94: coeff2[31:0] = 32'hbbcaa26f;
8'd95: coeff2[31:0] = 32'hbd4554bb;
8'd96: coeff2[31:0] = 32'hbe0660fb;
8'd97: coeff2[31:0] = 32'h3b063e1a;
8'd98: coeff2[31:0] = 32'hbe88b191;
8'd99: coeff2[31:0] = 32'h3d55e7b0;
8'd100: coeff2[31:0] = 32'h3f2c8d43;
default: coeff2[31:0] = 32'b0;
endcase
end
end

adder_fp_final adder1(.clk(clk), .start(start_a1), .op(1'b0), .A(A_add1), .B(B_add1), .ready(add_ready1), .busy(add_busy1), .Y(add_out1));
adder_fp_final adder2(.clk(clk), .start(start_a2), .op(1'b0), .A(A_add2), .B(B_add2), .ready(add_ready2), .busy(add_busy2), .Y(add_out2));
multiplier_fp_final multip1(.clk(clk), .start(start_m1), .A(A_mult1), .B(B_mult1), .ready(mult_ready1), .busy(mult_busy1), .Y(mult_out1));
multiplier_fp_final multip2(.clk(clk), .start(start_m2), .A(A_mult2), .B(B_mult2), .ready(mult_ready2), .busy(mult_busy2), .Y(mult_out2));
//generate block creates multipliers
always_ff@( posedge clk ) begin
		case(state)

		//originally we would need 200 additions and 201 multiplications to solve difference equation
		//we can add the x values that have the same coefficients, this will reduce the amount of computations done 
		ONE: begin
			if (master_counter < 8'd101) begin 
				temp_add[100:1] <= temp_add[99:0];
				temp_add[0][31:0] <= in;
				valid = 1'b1;
				counter <= 8'd0;
				k <= k + 8'd1;
				state <= THREE;
			end 
	
			else if (master_counter >= 8'd101 && master_counter < 8'd200) begin
				if (flag == 1) begin
					temp_add[99:0] <= x[99:0];
					flag <= 0;
				end
				if (x[101 + counter] != 32'b0) begin
					A_add1 <= x[101 + counter];
					B_add1 <= x[99 - counter];
					start_a1 <= 1'b1;
					state <= TWO;
				end
				else begin
					valid = 1'b1;
					temp_add[100] = x[100];
					counter <= 8'd0;
					state <= THREE;					
				end				
			end

			else begin
				if (counter !=100) begin
					A_add1 <= x[101 + counter];
					B_add1 <= x[99 - counter];
					start_a1 <= 1'b1;
					state <= TWO;
				end
			
				else if (counter == 8'd100) begin
					temp_add[100] = x[100];
					valid = 1'b1;
					counter <= 8'd0;
					state <= THREE;
				end
			end
		end

		//jump back between ONE and TWO to add the x's with the same coefficients
		//go to state THREE once all the x's have been added
		TWO: begin
			next <= 1'b0;
			start_a1 <= 1'b0;
			if (add_ready1) begin
				temp_add[99 - counter] <= add_out1;
				counter <= counter + 8'd1;
				state <= ONE;
			end
		end
	
		//multiply the coefficients with the added x values
		//will stay in state TWO until all the coefficients have been multiplied with x values
		THREE: begin
			if (k < 8'd101) begin
				if (k == counter) begin
					valid <= 1'b0;
					counter <= 8'd0;
					state <= FIVE;
				end
	
				else begin
					A_mult1 <= temp_add[counter];
					B_mult1 <= coeff;
					start_m1 <= 1'b1;
					state <= FOUR;
				end
			end

			else begin
				if (8'd100 == c2) begin
					valid <= 1'b0;	
					counter <= 8'd0;
					state <= FOURNEXT;		
				end
	
				else begin
					A_mult1 <= temp_add[counter];
					B_mult1 <= coeff;
					start_m1 <= 1'b1;
	
					A_mult2 <= temp_add[c2];
					B_mult2 <= coeff2;
					start_m2 <= 1'b1;
					state <= FOUR;
				end		
			end	
		end


		//jump between THREE and FOUR to multiply the coefficients with their respective x values
		//go to FIVE once all the coefficients have been multiplied
		FOUR: begin
			if (k < 8'd101) begin
				start_m1 <= 1'b0;
				if (mult_ready1 == 1'b1) begin
					temp_mult[counter] <= mult_out1;
					counter <= counter + 8'd1;
					state <= THREE;
				end
			end
			
			else begin
				start_m1 <= 1'b0;
				start_m2 <= 1'b0;

				if (mult_ready1 == 1'b1) begin
					t_ready1 <= mult_ready1;
				end

				if (mult_ready2 == 1'b1) begin
					t_ready2 <= mult_ready2;
				end


				if (t_ready1 == 1'b1 && t_ready2 == 1'b1) begin
					temp_mult[counter] <= mult_out1;
					temp_mult[c2] <= mult_out2;
					counter <= counter + 8'd1;
					c2 <= c2 + 8'd1;
					t_ready2 <= 1'b0;
					t_ready1 <= 1'b0;
					state <= THREE;
				end
			end
		end
	
		FOURNEXT: begin
			A_mult2 <= temp_add[c2];
			B_mult2 <= coeff2;
			start_m2 <= 1'b1;
			state <= FOURNEXT2;
		end

		FOURNEXT2: begin
			start_m2 <= 1'b0;
			if (mult_ready2 == 1'b1) begin
				temp_mult[c2] <= mult_out2;	
				c2 <= 8'd50;
				state <= FIVE;
			end
		end

		//calculate the final output
		//will keep adding until all values in temp_mult have been added together
		FIVE: begin
			if (k < 8'd101) begin
				if (k == counter) begin
					counter <= 8'd0;
					state <= SEVEN;
				end
	
				else begin
					A_add1 <= temp_mult[counter];
					B_add1 <= temp_out1;
					start_a1 <= 1'b1;
					state <= SIX;
				end
			end

			else begin
				if (8'd100 == c2) begin	
					counter <= 8'd0;
					state <= SIXNEXT;		
				end
	
				else begin
					A_add1 <= temp_mult[counter];
					B_add1 <= temp_out1;
					start_a1 <= 1'b1;
	
					A_add2 <= temp_mult[c2];
					B_add2 <= temp_out2;
					start_a2 <= 1'b1;
					state <= SIX;
				end		
			end	
		end
	
		SIX: begin
			if (k < 8'd101) begin
				start_a1 <= 1'b0;
				if (add_ready1 == 1'b1) begin
					temp_out1 <= add_out1;
					counter <= counter + 8'd1;
					state <= FIVE;
				end
			end
			
			else begin
				start_a1 <= 1'b0;
				start_a2 <= 1'b0;

				if (add_ready1 == 1'b1) begin
					a_ready1 <= add_ready1;
				end

				if (add_ready2 == 1'b1) begin
					a_ready2 <= add_ready2;
				end


				if (a_ready1 == 1'b1 && a_ready2 == 1'b1) begin
					temp_out1 <= add_out1;
					temp_out2 <= add_out2;
					counter <= counter + 8'd1;
					c2 <= c2 + 8'd1;
					a_ready2 <= 1'b0;
					a_ready1 <= 1'b0;
					state <= FIVE;
				end
			end
		end


		SIXNEXT: begin
			if (c2 == 8'd100) begin
				A_add2 <= temp_out1;
				B_add2 <= temp_out2;
				start_a2 <= 1'b1;
			end

			else begin
				A_add2 <= temp_mult[100];
				B_add2 <= temp_out2;
				start_a2 <= 1'b1;
			end
			state <= SIXNEXT2;
		end

		SIXNEXT2: begin
			start_a2 <= 1'b0;
			if (add_ready2 == 1'b1) begin
				temp_out2 <= add_out2;

				if (c2 == 8'd100) begin
					c2 <= 8'd50;
					state <= SIXNEXT;
				end

				else begin
					state <= SEVEN;
				end
			end
		end


		//give the output to the top module
		//check if the stop bit is 1
		//if 1, go to "default" state, otherwise, start calculating with next input
		SEVEN: begin
			out <= (k <8'd101) ? add_out1 : add_out2;
			ready <= 1'b1;
			master_counter <= master_counter + 11'd1;
			flag <= 1'b1;
			next <= 1'b0;
			x[200:1] <= x[199:0];//shift the values of the array to accomodate for the next input
			temp_in <= in;
			temp_out1 <= 32'b0;
			temp_out2 <= 32'b0;
			state <= EIGHT;
		end	

		EIGHT: begin
			if (stop) begin
				state <= 4'b1111;
			end

			ready <= 1'b0;
			if (pause == 1'b0) begin
				x[0][31:0] <= in;
				state <= ONE;
			end
		end

		default: begin
				//initialize registers used
			if (rst) begin
				k<= 8'b0;
				master_counter <= 8'd0;
				c2 <= 8'd50;
				flag <= 1'b1;
				next <= 1'b0;
				ready <= 1'b0;
				valid <=1'b0;
				counter <= 8'd0;
				temp_out1 <= 32'b0;
				temp_out2 <= 32'b0;
				x[0][31:0] <= in;
				state <= ONE;
			end
		end
		endcase
end
endmodule


module FIR_SSE(clk,rst,stop,in,out_gold,next,ready,out_filt,out_sse);
input logic clk, rst, stop;
input logic [31:0] in, out_gold;
output logic next, ready;
output logic [31:0] out_filt,out_sse;

logic [31:0] queue_1, queue_2;
logic sse_ready, fir_ready, sse_next, fir_next,rst1,rst2;
logic counter;
logic [31:0] in_filt,temp_filt,temp_sse, Am, Bm, temp_gold;
logic [2:0] state;
logic [1:0] flag;
logic pause1, pause2;

parameter ONE = 3'b0, TWO = 3'b001, THREE =  3'b010, FOUR = 3'b011, FIVE = 3'b100;
SSE_final sse(.clk(clk), .rst(rst2), .stop(stop), .A(Am), .B(Bm), .pause(pause2), .ready(sse_ready), .next(sse_next), .Y(temp_sse));
FIR_final fir(.clk(clk), .rst(rst1), .stop(stop), .in(in),.pause(pause1), .next(fir_next),.ready(fir_ready), .out(temp_filt));

always_ff@( posedge clk ) begin
	if (rst) begin
		ready <= 1'b0;
		counter <= 1'b0;
		flag <= 2'd0;
		pause1 <= 1'b1;
		pause2 <= 1'b1;
		state <= ONE;
	end

	else begin
		case(state) 
		
		//pass input to FIR module first
		ONE: begin
			next <= 1'b1;
			state <= TWO;
		end

		//wait for FIR module to have an ouput ready
		TWO: begin	
			if (flag == 2'd0) begin
				rst1 <= 1'b1;
				flag <= 2'd1;
			end

			else begin
				rst1 <= 1'b0;
			end
			
			ready <= 1'b0;
			next <= 1'b0;
			queue_1 <= out_gold;
			if (fir_ready) begin
				queue_2 <= temp_filt;
				next <= 1'b1;
				state <= THREE;
			end
		end

		THREE: begin
			if (flag) begin
				rst2 <= 1'b1;
				flag <= 2'd2;
			end
			pause2 <= 1'b0;
			Am <= queue_1;
			Bm <= queue_2;
			next <= 1'b0;
			state <= FOUR;
		end		

		//calculate SSE between FIR output and golden output
		//display SSE output and FIR output together, as specified on writeup
		FOUR: begin
			pause1 <= 1'b0;
			pause2 <= 1'b1;
			rst2 <= 1'b0;
			if (queue_1 != out_gold) begin
				queue_1 <= out_gold;
			end

			if (sse_ready) begin
				ready <= 1'b1;
				out_filt <= Bm;
				out_sse <= temp_sse;
				state <= FIVE;
			end
		end

		//check if stop is 1. If it is, stop calculations and go to "default" state 
		//otherwise, go to ONE again
		FIVE: begin
			ready <= 1'b0;
			pause1 <= 1'b1;
			if (stop) begin
				state <= 3'b111;
			end

			else begin
				state <= TWO;
			end
		end

		default: begin
			if (rst) begin
				state <= ONE;
			end
		end

	endcase
end
end
endmodule
