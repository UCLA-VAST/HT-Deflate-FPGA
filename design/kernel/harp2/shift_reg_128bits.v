module shift_reg_128bits(
	clk, 
	reset, 
	prev_data, 
	data_in, 
	len_in, 
	enable, 	
//	last_shift, 
	prev_len,
	data_out, 
	data_len
);

input 	clk, reset; 
input 	enable;// enable means lower half of previous is full
input 	[127:0] 	prev_data;
input 	[31:0]	data_in;
input 	[5:0]	len_in;
//input 			last_shift;
input 	[7:0]	prev_len;
output 	[127:0] 	data_out;
output 	[7:0] 	data_len;

reg   [127:0]  data_out_reg;
reg   [7:0]	  data_len_reg;

always @(posedge clk)
begin
	if(reset)
	begin
		data_out_reg = 128'd0;
		data_len_reg = 8'd0;
	end

/*
	else
	if(enable)
		begin
			data_out_reg = {prev_data[95:0], data_in[31:0]};
			data_len_reg = prev_len + {8'd32};
		end

	else if(last_shift)
		begin
			data_out_reg = (prev_data << len_in) | data_in;
			data_len_reg = prev_len;
		end
*/
	else
	if(enable)
		begin
			data_out_reg = (prev_data << len_in) | data_in;
			data_len_reg = prev_len + len_in;
		end

		else
			begin
				data_out_reg = prev_data;
				data_len_reg = prev_len;
			end
end 

assign data_out = data_out_reg;
assign data_len = data_len_reg;


endmodule