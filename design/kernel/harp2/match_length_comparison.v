module match_length_comparison (
	match_length_q1,    
	match_length_q2,
	match_length_q3,
	match_position_q1, 
	match_position_q2, 
	match_position_q3, 
	hash_valid_q1, 
	hash_valid_q2, 
	hash_valid_q3,  
	match_length_out, 
	hash_position_out, 
	hash_valid_out
);

input wire	[4:0]	match_length_q1;
input wire	[4:0]	match_length_q2;
input wire	[4:0]	match_length_q3;

input wire 	[31:0]	match_position_q1;
input wire 	[31:0]	match_position_q2;
input wire 	[31:0]	match_position_q3;

input wire 			hash_valid_q1;
input wire 			hash_valid_q2;
input wire 			hash_valid_q3;

output wire [4:0]	match_length_out;
output wire [31:0]	hash_position_out;
output wire 		hash_valid_out;

reg 	[4:0]	reg_match_length_out;
reg 	[31:0]	reg_hash_position_out;

always @(*)
	begin
		case ({hash_valid_q1, hash_valid_q2, hash_valid_q3})
			3'b001:	begin
			 			reg_match_length_out <= match_length_q3;
			 			reg_hash_position_out <= match_position_q3;
			 		end

			3'b010: begin
			 			reg_match_length_out <= match_length_q2;
			 			reg_hash_position_out <= match_position_q2;
			 		end

			3'b011: begin
						if(match_length_q2<match_length_q3)
						begin
							reg_match_length_out <= match_length_q3;
			 				reg_hash_position_out <= match_position_q3;
						end
						else
						begin
							reg_match_length_out <= match_length_q2;
			 				reg_hash_position_out <= match_position_q2;
						end
					end

			3'b100: begin
						reg_match_length_out <= match_length_q1;
			 			reg_hash_position_out <= match_position_q1;
					end

			3'b101: begin
						if(match_length_q1<match_length_q3)
						begin
							reg_match_length_out <= match_length_q3;
			 				reg_hash_position_out <= match_position_q3;
						end
						else
						begin
							reg_match_length_out <= match_length_q1;
			 				reg_hash_position_out <= match_position_q1;
						end
					end

			3'b110: begin
						if(match_length_q1<match_length_q2)
						begin
							reg_match_length_out <= match_length_q2;
			 				reg_hash_position_out <= match_position_q2;
						end
						else
						begin
							reg_match_length_out <= match_length_q1;
			 				reg_hash_position_out <= match_position_q1;
						end
					end

			3'b111: begin
						if(match_length_q1<match_length_q2)
							if(match_length_q2<match_length_q3)
							begin
								reg_match_length_out <= match_length_q3;
			 					reg_hash_position_out <= match_position_q3;
							end
							else
							begin
								reg_match_length_out <= match_length_q2;
			 					reg_hash_position_out <= match_position_q2;
							end
							
						else if(match_length_q1 < match_length_q3)
						begin
							reg_match_length_out <= match_length_q3;
			 				reg_hash_position_out <= match_position_q3;
						end
						else
						begin
							reg_match_length_out <= match_length_q1;
			 				reg_hash_position_out <= match_position_q1;
						end
					end

			default : begin
						reg_match_length_out <= 5'd0;
						reg_hash_position_out <= 32'd0;
					  end
		endcase
	end


assign match_length_out = reg_match_length_out;
assign hash_position_out = reg_hash_position_out;
assign hash_valid_out = hash_valid_q1 | hash_valid_q2 | hash_valid_q3;

endmodule