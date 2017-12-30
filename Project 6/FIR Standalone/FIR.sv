module FIR(clk, rst, stop, in, next, ready, out);

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

parameter ONE = 3'b0, TWO = 3'b001, THREE = 3'b010, FOUR = 3'b011, FIVE = 3'b100, SIX = 3'b101, SEVEN = 3'b111, EIGHT = 4'b1000, FOURNEXT = 4'b1001, FOURNEXT2 = 4'b1010, SIXNEXT = 4'b1011, SIXNEXT2 = 4'b1100, IDLE = 4'b1101;

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

adder_fp adder1(.clk(clk), .start(start_a1), .op(1'b0), .A(A_add1), .B(B_add1), .ready(add_ready1), .busy(add_busy1), .Y(add_out1));
adder_fp adder2(.clk(clk), .start(start_a2), .op(1'b0), .A(A_add2), .B(B_add2), .ready(add_ready2), .busy(add_busy2), .Y(add_out2));
multiplier_fp multip1(.clk(clk), .start(start_m1), .A(A_mult1), .B(B_mult1), .ready(mult_ready1), .busy(mult_busy1), .Y(mult_out1));
multiplier_fp multip2(.clk(clk), .start(start_m2), .A(A_mult2), .B(B_mult2), .ready(mult_ready2), .busy(mult_busy2), .Y(mult_out2));
//generate block creates multipliers
always_ff@( posedge clk ) begin
		case(state)

		IDLE: begin
			next <= 1'b0;
			state <= ONE;
		end

		//originally we would need 200 additions and 201 multiplications to solve difference equation
		//we can add the x values that have the same coefficients, this will reduce the amount of computations done 
		ONE: begin
			next <= 1'b0;
			if (master_counter < 8'd101) begin 
				temp_add[100:1] <= temp_add[99:0];
				temp_add[0][31:0] <= in;
				valid = 1'b1;
				counter <= 8'd0;
				x[0][31:0] <= in;
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
			//next <= 1'b0;
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
					next <= 1'b1;
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
					next <= 1'b1;
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
			if (stop) begin
				state <= 4'b1111;
			end
			
			else begin
				state <= EIGHT;
			end
			
		end	

		EIGHT: begin
			ready <= 1'b0;
			if (temp_in != in) begin
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
				next <= 1'b1;
				ready <= 1'b0;
				valid <=1'b0;
				counter <= 8'd0;
				temp_out1 <= 32'b0;
				temp_out2 <= 32'b0;
				x[0][31:0] <= in;
				state <= IDLE;
			end
		end
		endcase
end
endmodule
