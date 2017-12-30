module adder_fp(

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
	
	else if (exB == 8'b0 && B[22:0] == 23'b0) begin
		sign = A[31];
		sigResult[24:2] <= A[22:0];
		exResult <= exA;	
		state <= FIVE;
	end 

	else if (exA == 8'b0 && A[22:0] == 23'b0) begin
		sign = B[31] ^ op;
		sigResult[24:2] <= B[22:0];
		exResult <= exB;	
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

	TWO:
	begin	
		if (A[31] == B[31]) begin
			if (op == 1'b0) begin
		   		{overf_bit,sigResult} <= sigA + sigB;
			end
			else begin
				if (sigA > sigB) begin
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
					{overf_bit,sigResult} <= sigA - sigB;
				end
				else begin
					{overf_bit,sigResult} <= sigA + sigB;
				end
			end
			
			else begin
				sign <= B[31];
				if (op == 1'b0) begin
					{overf_bit,sigResult} <= sigB - sigA;
				end
				else begin
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
