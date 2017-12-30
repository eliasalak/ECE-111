module snail_mealy (A, clk, rst, Y);

input logic A, clk, rst;
output logic Y;
logic [2:0] state;

parameter	s_0 = 3'd0, s_A = 3'd1, s_B = 3'd2, s_C = 3'd3, 
			s_D = 3'd4, s_E = 3'd5, s_F = 3'd6;

always_ff @(posedge clk, posedge rst) begin
	if (rst) state <= s_0;

else begin
	case(state)

		s_0: begin
			//Y <= 0;  Doing this causes Y to be out of phase
			if(A)	begin state <= s_A; Y <= 0; end
			else 	begin state <= s_0; Y <= 0;	end	// Doing it this way causes Y to be updated within	
		end											// the a same cycle instead of cycle after

		s_A: begin
			if(A) 	begin state <= s_B; Y <= 0; end //IMPORTANT: All if AND elses need there own begin-end
			else 	begin state <= s_0; Y <= 0; end // or the code won't work
		end

		s_B: begin
			if(A)	begin state <= s_D; Y <= 0; end
			else	begin state <= s_C; Y <= 0; end
		end

		s_C: begin
			if(A)	begin state <= s_E; Y <= 1;	end
			else 	begin state <= s_0; Y <= 0; end
		end

		s_D: begin
			if(A) 	begin state <= s_D; Y <= 0; end
			else 	begin state <= s_F; Y <= 1; end
		end

		s_E: begin
			if(A) 	begin state <= s_B; Y <= 0; end
			else 	begin state <= s_0; Y <= 0; end
		end

		s_F: begin
			if(A) 	begin state <= s_E; Y <= 1; end
			else 	begin state <= s_0; Y <= 0; end
		end
	endcase

	end //end else
end //end always_ff

endmodule
