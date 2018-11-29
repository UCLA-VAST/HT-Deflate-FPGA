module l_d_packer(
	l_code,
	l_len, 
	l_extra, 
	l_extra_len,  
	d_code, 
	d_extra, 
	d_extra_len,
	input_valid,  
	enable, 
	l_d_packer_out
	);

input 	[11:0]	l_code;
input 	[3:0] 	l_len;
input	[7:0]	l_extra;
input 	[3:0]	l_extra_len;
input 	[4:0]	d_code; 
input 	[15:0]	d_extra;
input 	[3:0]	d_extra_len;
input 			input_valid;
input 			enable;
output 	[31:0]	l_d_packer_out;



//
reg 	[9:0]		l_pack;
/*
always @(*)
begin
	if(enable)
	begin
	case(l_extra_len)
		4'd0:begin
			l_pack <= {3'd0, l_code[6:0]};
		end

		4'd1:begin
			l_pack <= {2'd0, l_code[6:0], l_extra[0]};
		end

		4'd2:begin
			l_pack <= {1'd0, l_code[6:0], l_extra[1:0]};
		end

		4'd3:begin
			l_pack <= {l_code[6:0], l_extra[2:0]};
		end

		default: l_pack <= {3'd0, l_code[6:0]};

	endcase
	end
end
*/

always @(*)
begin
	case(l_extra_len)
		4'd0:begin
			l_pack <= {3'd0, l_code[6:0]};
		end

		4'd1:begin
			l_pack <= {2'd0, l_code[6:0], l_extra[0]};
		end

		4'd2:begin
			l_pack <= {1'd0, l_code[6:0], l_extra[1:0]};
		end

		4'd3:begin
			l_pack <= {l_code[6:0], l_extra[2:0]};
		end

		default: l_pack <= {3'd0, l_code[6:0]};

	endcase
end



//

reg 	[31:0]	code_out_reg;

always @(*)
begin
	if(~input_valid)
	begin
		code_out_reg <= 32'd0;
	end

	else if(d_code == 5'd0)
	begin
		if(l_len == 4'd8)
		begin
			code_out_reg <= {24'd0, l_code[7:0]};
		end
		else
		begin
			code_out_reg <= {23'd0, l_code[8:0]};
		end
	end

	else
	begin
		case(d_extra_len)
			4'd0: begin
				code_out_reg <= {17'd0, l_pack[9:0], d_code[4:0]};
			end

			4'd1: begin
				code_out_reg <= {16'd0, l_pack[9:0], d_code[4:0], d_extra[0]};
			end

			4'd2: begin
				code_out_reg <= {15'd0, l_pack[9:0], d_code[4:0], d_extra[1:0]};
			end

			4'd3: begin
				code_out_reg <= {14'd0, l_pack[9:0], d_code[4:0], d_extra[2:0]};
			end

			4'd4: begin
				code_out_reg <= {13'd0, l_pack[9:0], d_code[4:0], d_extra[3:0]};
			end

			4'd5: begin
				code_out_reg <= {12'd0, l_pack[9:0], d_code[4:0], d_extra[4:0]};
			end

			4'd6: begin
				code_out_reg <= {11'd0, l_pack[9:0], d_code[4:0], d_extra[5:0]};
			end

			4'd7: begin
				code_out_reg <= {10'd0, l_pack[9:0], d_code[4:0], d_extra[6:0]};
			end

			4'd8: begin
				code_out_reg <= {9'd0, l_pack[9:0], d_code[4:0], d_extra[7:0]};
			end

			4'd9: begin
				code_out_reg <= {8'd0, l_pack[9:0], d_code[4:0], d_extra[8:0]};
			end

			4'd10: begin
				code_out_reg <= {7'd0, l_pack[9:0], d_code[4:0], d_extra[9:0]};
			end

			4'd11: begin
				code_out_reg <= {6'd0, l_pack[9:0], d_code[4:0], d_extra[10:0]};
			end

			4'd12: begin
				code_out_reg <= {5'd0, l_pack[9:0], d_code[4:0], d_extra[11:0]};
			end

			4'd13: begin
				code_out_reg <= {4'd0, l_pack[9:0], d_code[4:0], d_extra[12:0]};
			end

		default: code_out_reg = 32'd0;

	endcase
end
end
 

assign l_d_packer_out = code_out_reg;






endmodule