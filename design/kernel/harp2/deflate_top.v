module deflate_top(
	clk,  
	rst, 
	start, 
	data_window_in, 
	out_data, 
	out_ready
	);

input			clk;
input 			rst;
input			start;
input 	[255:0]	data_window_in;	


output 			out_ready;
output 	[511:0]	out_data;


// part 1 port
wire	[127:0]	hash_match_literals_out;
wire 	[127:0]	hash_match_len_raw_out;
wire	[255:0]	hash_match_dist_raw_out;
wire 			hash_match_output_ready;


// part 1
hash_match 	hash_match_UUT(
	.clk(clk), 
	.rst(rst), 
	.start(start), 
	.data_window_in(data_window_in), 
//	in_size_in, 
	.literals_out(hash_match_literals_out), 
	.len_raw_out(hash_match_len_raw_out),
	.dist_raw_out(hash_match_dist_raw_out), 
	.output_ready(hash_match_output_ready)
);


// part 2 port
wire 	[127:0]		match_selection_larray_out;
wire 	[255:0]		match_selection_darray_out;
wire	[15:0]		match_selection_valid_out;
wire				match_selection_ready_out;


// part 2
match_selection  match_selection_UUT(
	.clk(clk), 
	.reset(rst), 
	.en(hash_match_output_ready), 
	.literals(hash_match_literals_out), 
	.len_raw(hash_match_len_raw_out), 
	.dist_raw(hash_match_dist_raw_out),
	.larray_out(match_selection_larray_out), 
	.darray_out(match_selection_darray_out), 
	.valid_out(match_selection_valid_out), 
	.ready_out(match_selection_ready_out)
);


// part 3 port
wire 				pack_out_ready;
wire 	[255:0] 		pack_out_data;
wire 	[7:0]		pack_out_len;

// part 3
pack_out_data 	pack_out_data_UUT(
	.clk(clk), 
	.reset(rst), 
	.en(match_selection_ready_out), 
	.larray_in(match_selection_larray_out), 
	.darray_in(match_selection_darray_out), 
	.valid_in(match_selection_valid_out), 
	.out_data(pack_out_data), 
	.out_ready(pack_out_ready), 
	.out_len(pack_out_len)
);

// part 4
wire 	[8:0] 	barrel_shifter_current_len;
wire 			barrel_shifter_data_full;
wire 	[255:0]	barrel_shifter_data_to_write;
wire 	[511:0]	barrel_shifter_data_out;

barrel_shifter_512bits barrel_shifter_512bits_UUT(
	.clk(clk), 
	.reset(rst), 
	.data_in(pack_out_data), 
	.len_in(pack_out_len), 
	.enable(pack_out_ready), 
	.current_len(barrel_shifter_current_len), 
	.data_full(barrel_shifter_data_full), 
	.data_to_write(barrel_shifter_data_to_write), 
	.data_out(barrel_shifter_data_out)
);



shift_reg_512bits 	shift_reg_512bits_UUT(
	.clk(clk), 
	.reset(rst), 
	.enable(barrel_shifter_data_full), 
	.data_in(barrel_shifter_data_to_write), 
	.data_out(out_data)
);



//use FSM to monitor if 512 bits buffer is full
reg 	[2:0]	state, next_state;
reg 			out_ready_reg;

parameter s0 = 3'd0;
parameter s1 = 3'd1;
parameter s2 = 3'd2;
parameter s3 = 3'd3;
parameter s4 = 3'd4;
parameter s5 = 3'd5;


always @(posedge clk)
begin
	if(rst)
	begin
		state <= s0;
	end
	else
	begin
		state <= next_state;
	end
end 

always @(*)
begin
	case(state)
		s0: 
		begin
			if(barrel_shifter_data_full)
			begin
				next_state = s1;
				out_ready_reg = 1'b0;
			end

			else
			begin
				next_state = s0;
				out_ready_reg = 1'b0;
			end
		end


		s1:
		begin
			if(barrel_shifter_data_full)
			begin
				next_state = s2;
				out_ready_reg = 1'b0;
			end

			else
			begin
				next_state = s1;
				out_ready_reg = 1'b0;
			end
		end


		s2:
		begin
			if(barrel_shifter_data_full)
			begin
				next_state = s1;
				out_ready_reg = 1'b1;
			end

			else
			begin
				next_state = s0;
				out_ready_reg = 1'b1;
			end
		end

/*
		s3:
		begin
			if(barrel_shifter_data_full)
			begin
				next_state = s4;
				out_ready_reg = 1'b0;
			end

			else
			begin
				next_state = s3;
				out_ready_reg = 1'b0;
			end
		end


		s4: 
		begin
			if(barrel_shifter_data_full)
			begin
				next_state = s1;
				out_ready_reg = 1'b1;
			end

			else
			begin
				next_state = s0;
				out_ready_reg = 1'b0;
			end
		end



		s5: 
		begin
			if(barrel_shifter_data_full)
			begin
				next_state = s1;
				out_ready_reg = 1'b1;
			end

			else
			begin
				next_state = s0;
				out_ready_reg = 1'b0;
			end
		end

*/
		default:
		begin
			next_state = s0;
			out_ready_reg = 1'b0;
		end


		
		
	endcase

end

assign out_ready = out_ready_reg;

endmodule