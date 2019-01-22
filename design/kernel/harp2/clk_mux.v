module clk_mux(
	data_in_a, 
	data_in_b, 
	clk, 
//	reset, 
	enable, 
	data_out
);

parameter 	N = 8;

input 	[N-1:0]	 	data_in_a;
input 	[N-1:0]	 	data_in_b;
input 				clk; 
//input 				reset;
input 				enable;
output 	[N-1:0] 		data_out;

reg 				state;
reg 	[N-1:0] 		data_out_reg;

always @(posedge clk)
begin
	if(enable)
	begin
		state <= ~state;
	end
	else
	begin
		state <= 1'b1;
	end
end

always @(*)
begin
	if(state)
	begin
		data_out_reg <= data_in_a;
	end
	else
	begin
		data_out_reg <= data_in_b;
	end
end

assign data_out = data_out_reg;

endmodule