module shift_reg_512bits(
	clk, 
	reset, 
	state, 
	enable, 
	data_in, 
	data_out
);

input 	clk, reset, enable;
input 	[2:0]	state;
input 	[255:0]	data_in;
output 	[511:0]	data_out;

reg 	[511:0]	data_out_reg;

always @(posedge clk)
begin
	if(reset)
	begin
		data_out_reg <= 512'd0;
	end

	else
	if(enable)
	begin
		if(state == 3'd1)
			data_out_reg <= {data_in, data_out_reg[255:0]};
		else
			data_out_reg <= {256'd0, data_in};
	end
	else
	begin
		data_out_reg <= data_out_reg;
	end
end 

assign data_out = data_out_reg;

endmodule