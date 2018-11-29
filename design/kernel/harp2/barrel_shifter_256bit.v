module barrel_shifter_256bits(
	clk, 
	reset, 
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
input 	[127:0] 	data_in;
input 	[7:0]	len_in;
input 	 		enable;
output 	[7:0] 	current_len;
output 			data_full;
output 	[127:0]	data_to_write;
output 	[255:0]	data_out;


reg 	[7:0] 	len_sum;
reg 	[255:0]	data_tmp;

reg 	[7:0] 	current_len_reg;
reg 	[255:0]	data_out_reg;
reg 	[127:0] 	data_to_write_reg;
reg 			data_full_reg;





always @(posedge clk)
begin
	if(reset)
	begin
		current_len_reg = 8'd0;
		data_out_reg = 256'd0;
		data_full_reg = 1'b0;
		data_to_write_reg = 128'd0;
	end

	else
	begin
		if(enable)
		begin
			len_sum = current_len_reg + len_in;
			data_tmp = (data_out_reg << len_in) | data_in;
			if(len_sum[7]) //means lower half is full
			begin
				data_out_reg = {128'd0, data_tmp[255:128]};
				current_len_reg = {1'b0, len_sum[6:0]};
				data_full_reg = 1'b1;
				data_to_write_reg = data_tmp[127:0];
			end
			else
			begin
				data_out_reg = data_tmp;
				current_len_reg = len_sum;
				data_full_reg = 1'b0;
				data_to_write_reg = 128'd0;
			end			
		end

		else
		begin
			data_full_reg = 1'b0;
			current_len_reg = current_len_reg;
			data_out_reg = data_out_reg;
			data_to_write_reg = 128'd0;
		end

	end
end 

assign current_len = current_len_reg;
assign data_full = data_full_reg;
assign data_to_write = data_to_write_reg;
assign data_out = data_out_reg;








endmodule