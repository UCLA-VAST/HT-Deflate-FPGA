module generate_sel(
	clk, 
	reset, 
	enable, 
	sel
	);

input clk;
input reset;
input enable;

output sel;

//reg 				state;
reg 		 		sel_reg;
/*
always @(posedge clk)
begin
	if(reset)
	begin
		state <= 1'b0;
	end

	else
	if(enable)
	begin
		state <= 1'b1;
	end
	else
	begin
		state <= 1'b0;
	end
end

always @(*)
begin
	if(reset)
	begin
		sel_reg <= 0;	// sel_reg = 0 means select port a
	end
	else
	if(state)
	begin
		sel_reg <= ~sel_reg;	// sel_reg = 1 means select port b
	end
	else
	begin
		sel_reg <=sel_reg;
	end
end
*/

always @(posedge clk)
begin
	if(reset)
	begin
		sel_reg <= 1'b0;
	end

	else
	if(enable)
	begin
		sel_reg <= ~sel_reg;
	end
	else
	begin
		sel_reg <= sel_reg;
	end
end



assign sel = sel_reg;

endmodule