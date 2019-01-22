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

input 	[11	:	0]		l_code;
input 	[3	:	0] 		l_len;
input	[7	:	0]		l_extra;
input 	[3	:	0]		l_extra_len;
input 	[4	:	0]		d_code; 
input 	[15	:	0]		d_extra;
input 	[3	:	0]		d_extra_len;
input 					input_valid;
input 					enable;
output 	[31	:	0]		l_d_packer_out;


wire 	[4	:	0]		l_len_total;

assign l_len_total = l_len + l_extra_len;

// first pack l_code and l_extra
reg 	[9:0]		l_pack;

always @(*)
begin
	case(l_extra_len)
		4'd0: 
		begin
			l_pack <= {3'd0, l_code[6:0]};
		end

		4'd1: 
		begin
			l_pack <= {2'd0, l_extra[0], l_code[6:0]};
		end

		4'd2: 
		begin
			l_pack <= {1'd0, l_extra[1:0], l_code[6:0]};
		end

		4'd3:
		begin
			l_pack <= {l_extra[2:0], l_code[6:0]};
		end

		default: 
		begin
			l_pack <= {3'd0, l_code[6:0]};
		end

	endcase
end


// pack l_pack with d_code and d_extra
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
		code_out_reg <= ({d_extra[15:0], d_code[4:0]} << l_len_total) | ({22'd0, l_pack[9:0]});
	end
end 

assign l_d_packer_out = code_out_reg;


endmodule