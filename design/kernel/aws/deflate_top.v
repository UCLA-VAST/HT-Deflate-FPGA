module deflate_top #
(
    parameter MEM_BANK_NUM = 'd5, 
	parameter MEM_BANK_DEPTH = 'd8
)
(
	clk,  
	rst, 
	start, 
	last, 
	inValid, 
	data_window_in, 
	out_data, 
	out_ready, 
	out_last, 
	out_last_len
);

input			clk;
input 			rst;
input			start;
input 			last;
input 			inValid;
input 	[255:0]	data_window_in;	


output 			out_ready;
output 	[511:0]	out_data;
output 			out_last;
output 	[8:0]	out_last_len;


// part 1 port
wire	[127:0]	hash_match_literals_out;
wire 	[127:0]	hash_match_len_raw_out;
wire	[255:0]	hash_match_dist_raw_out;
wire    [15:0]  hash_match_valid_raw_out;
wire 			hash_match_output_ready;
wire 			hash_match_start_out;
wire 			hash_match_last_out;


// part 1
hash_match 	#
(
	.MEM_BANK_NUM(5), 
	.MEM_BANK_DEPTH(8)
)
hash_match_UUT(
	.clk(clk), 
	.rst(rst), 
	.start(start), 
	.last(last), 
	.inValid(inValid), 
	.data_window_in(data_window_in),  
	.literals_out(hash_match_literals_out), 
	.len_raw_out(hash_match_len_raw_out),
	.dist_raw_out(hash_match_dist_raw_out),
    .valid_raw_out(hash_match_valid_raw_out),  
	.output_ready(hash_match_output_ready), 
	.start_out(hash_match_start_out), 
	.last_out(hash_match_last_out)
);


// part 2 port
wire 	[127:0]		match_selection_larray_out;
wire 	[255:0]		match_selection_darray_out;
wire	[15:0]		match_selection_valid_out;
wire				match_selection_ready_out;
wire 				match_selection_start_out;
wire 				match_selection_last_out;


// part 2
match_selection  match_selection_UUT(
	.clk(clk), 
	.reset(rst), 
	.start(hash_match_start_out),
	.last(hash_match_last_out),
	.en(hash_match_output_ready), 
	.literals(hash_match_literals_out), 
	.len_raw(hash_match_len_raw_out), 
	.dist_raw(hash_match_dist_raw_out),
    .valid_raw(hash_match_valid_raw_out), 
	.larray_out(match_selection_larray_out), 
	.darray_out(match_selection_darray_out), 
	.valid_out(match_selection_valid_out), 
	.ready_out(match_selection_ready_out),
	.start_out(match_selection_start_out), 
	.last_out(match_selection_last_out)
);


// part 3 port
wire 				pack_out_ready;
wire 	[255:0] 	pack_out_data;
wire 	[7:0]		pack_out_len;
wire 				pack_out_last;

// part 3
pack_out_data 	pack_out_data_UUT(
	.clk(clk), 
	.reset(rst), 
	.start(match_selection_start_out),
	.last(match_selection_last_out),
	.en(match_selection_ready_out), 
	.larray_in(match_selection_larray_out), 
	.darray_in(match_selection_darray_out), 
	.valid_in(match_selection_valid_out), 
	.out_data(pack_out_data), 
	.out_ready(pack_out_ready), 
	.out_len(pack_out_len), 
	.out_last(pack_out_last)
);

// part 4
wire 	[8:0] 	barrel_shifter_current_len;
wire 			barrel_shifter_data_full;
wire 	[255:0]	barrel_shifter_data_to_write;
wire 	[511:0]	barrel_shifter_data_out;

wire 	[255:0]	barrel_shifter_data_to_write_reg;

wire 			pack_out_last_s1;

barrel_shifter_512bits barrel_shifter_512bits_UUT(
	.clk(clk), 
	.reset(rst), 
	.data_in(pack_out_data), 
	.len_in(pack_out_len), 
	.enable(pack_out_ready), 
	.last(pack_out_last),
	.current_len(barrel_shifter_current_len), 
	.data_full(barrel_shifter_data_full), 
	.data_to_write(barrel_shifter_data_to_write), 
	.data_out(barrel_shifter_data_out)
);

register_compression_reset #(.N(1)) pack_out_last_s1_i0(.d(pack_out_last), .clk(clk), .reset(rst), .q(pack_out_last_s1));

register_compression #(.N(256)) barrel_shifter_data_to_write_i0(.d(barrel_shifter_data_to_write), .clk(clk), .q(barrel_shifter_data_to_write_reg));


//use FSM to monitor if 512 bits buffer is full
reg 	[2:0]	state, next_state;

reg 			out_ready_reg;
reg 	[8:0]	out_last_len_reg;
reg 	[511:0]	out_data_op1;
reg 			out_last_reg;

parameter s0 = 3'd0;
parameter s1 = 3'd1;
parameter s2 = 3'd2;
parameter s3 = 3'd3;
parameter s4 = 3'd4;
parameter s5 = 3'd5;

wire 	[511:0]		out_data_op2;

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
	out_data_op1 <= barrel_shifter_data_out;
	out_last_len_reg <= barrel_shifter_current_len;
	out_last_reg <= 1'b0;
	case(state)
		s0: 
		begin
			if((!barrel_shifter_data_full) && pack_out_last_s1)
			begin
				next_state <= s0;
				out_ready_reg <= 1'b1;
				out_data_op1 <= barrel_shifter_data_out;
				out_last_len_reg <= barrel_shifter_current_len;
				out_last_reg <= 1'b1;
			end

			else if(barrel_shifter_data_full && pack_out_last_s1)
			begin
				next_state <= s0;
				out_ready_reg <= 1'b1;
				out_data_op1 <= {barrel_shifter_data_out[255:0], barrel_shifter_data_to_write};
				out_last_len_reg <= 9'd256 + barrel_shifter_current_len;
				out_last_reg <= 1'b1;
			end

			else if(barrel_shifter_data_full && (!pack_out_last_s1))
			begin
				next_state <= s1;
				out_ready_reg <= 1'b0;
			end

			else
			begin
				next_state <= s0;
				out_ready_reg <= 1'b0;
			end
		end


		s1:
		begin
			if(barrel_shifter_data_full && (!pack_out_last_s1))
			begin
				next_state <= s2;
				out_ready_reg <= 1'b0;
			end

			else if ((!barrel_shifter_data_full) && pack_out_last_s1)
			begin
				next_state <= s0;
				out_ready_reg <= 1'b1;
				out_data_op1 <= {barrel_shifter_data_out[255:0], out_data_op2[255:0]};
				out_last_len_reg <= 9'd256 + barrel_shifter_current_len;
				out_last_reg <= 1'b1;
			end

			else if (barrel_shifter_data_full && pack_out_last_s1)
			begin
				next_state <= s3;
				out_ready_reg <= 1'b0;
			end

			else
			begin
				next_state <= s1;
				out_ready_reg <= 1'b0;
			end
		end


		s2:
		begin
			if(barrel_shifter_data_full && (!pack_out_last_s1))
			begin
				next_state <= s1;
				out_ready_reg <= 1'b1;
			end

			else if((!barrel_shifter_data_full) && pack_out_last_s1)
			begin
				next_state <= s4;
				out_ready_reg <= 1'b1;
			end

			else if(barrel_shifter_data_full && pack_out_last_s1)
			begin
				next_state <= s5;
				out_ready_reg <= 1'b1;
				
			end

			else
			begin
				next_state <= s0;
				out_ready_reg <= 1'b1;
			end
		end

		s3: 
		begin
			next_state <= s4;
			out_ready_reg <= 1'b1;
		end

		s4: 
		begin	
			next_state <= s0;
			out_ready_reg <= 1'b1;
			out_last_len_reg <= barrel_shifter_current_len;
			out_last_reg <= 1'b1;
		end

		s5: 
		begin
			next_state <= s0;
			out_ready_reg <= 1'b1;
			out_data_op1 <= {barrel_shifter_data_out[255:0], barrel_shifter_data_to_write_reg};
			out_last_len_reg <= 9'd256 + barrel_shifter_current_len;
			out_last_reg <= 1'b1;
		end

		
		default:
		begin
			next_state <= s0;
			out_ready_reg <= 1'b0;
			out_last_reg <= 1'b0;
		end
		
	endcase

end


shift_reg_512bits 	shift_reg_512bits_UUT(
	.clk(clk), 
	.reset(rst), 
	.state(state),
	.enable(barrel_shifter_data_full), 
	.data_in(barrel_shifter_data_to_write), 
	.data_out(out_data_op2)
);

assign out_data = ((state == s2) || (state == s3)) ? out_data_op2 : out_data_op1;
assign out_ready = out_ready_reg;

assign out_last = out_last_reg;
assign out_last_len = out_last_len_reg; 

endmodule