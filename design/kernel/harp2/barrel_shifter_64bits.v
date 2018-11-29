module barrel_shifter_64bits(
	clk, 
	reset, 
	pre_data, 
	pre_len, 
	data_in, 
	len_in, 
	enable, 
	current_len, 
	data_full, 
	data_to_write, 
	data_out
);

input 	clk;
input 	reset;
input 	[63:0]	pre_data;
input 	[5:0] 	pre_len;
input 	[31:0] 	data_in;
input 	[4:0]	len_in;
input 	 		enable;
output 	[5:0] 	current_len;
output 			data_full;
output 	[31:0]	data_to_write;
output 	[63:0]	data_out;


reg 	[5:0] 	len_sum;
reg 	[63:0]	data_tmp;

reg 	[5:0] 	current_len_reg;
reg 	[63:0]	data_out_reg;
reg 	[31:0] 	data_to_write_reg;
reg 			data_full_reg;





always @(posedge clk)
begin
	if(reset)
	begin
		current_len_reg = 6'd0;
		data_out_reg = 64'd0;
		data_full_reg = 1'b0;
		data_to_write_reg = 32'd0;
	end

	else
	begin
		if(enable)
		begin
			len_sum = pre_len + len_in;
			data_tmp = (pre_data << len_in) | data_in;
			if(len_sum[5]) //means lower half is full
			begin
				data_out_reg = {32'd0, data_tmp[63:32]};
				current_len_reg = {1'b0, len_sum[4:0]};
				data_full_reg = 1'b1;
				data_to_write_reg = data_tmp[31:0];
			end
			else
			begin
				data_out_reg = data_tmp;
				current_len_reg = len_sum;
				data_full_reg = 1'b0;
				data_to_write_reg = 32'd0;
			end			
		end

		else
		begin
			data_out_reg = 0;
			current_len_reg = 0;
			data_full_reg = 0;
			data_to_write_reg = 0;
		end
	end
end 

assign current_len = current_len_reg;
assign data_full = data_full_reg;
assign data_to_write = data_to_write_reg;
assign data_out = data_out_reg;




endmodule

