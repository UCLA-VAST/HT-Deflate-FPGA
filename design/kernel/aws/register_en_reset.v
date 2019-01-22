// ==============================================================
// Description: Register with enable
// Author: Weikang Qiao
// Date: 10/10/2016
// ==============================================================
module register_en_reset(d, clk, reset, enable, q);

	parameter	N = 1;

	input	[N-1:0]	d; 
	input	clk;
	input	reset;
	input   enable;
	output  [N-1:0]	q;


	reg  [N-1:0]	q_reg;

always @(posedge clk)
	begin
	if(reset)
		begin
			q_reg <= 0;
		end
	else
		if(enable)
		begin
			q_reg <= d;
		end
		else
		begin
			q_reg <= q_reg;
		end
	end

assign q = q_reg;

endmodule