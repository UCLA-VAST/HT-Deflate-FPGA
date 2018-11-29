// ==============================================================
// Description: Register with enable
// Author: Weikang Qiao
// Date: 10/10/2016
// ==============================================================
module register_en(d, clk, enable, q);

	parameter	N = 1;

	input	[N-1:0]	d; 
	input	clk;
	input   enable;
	output  [N-1:0]	q;


	reg  [N-1:0]	q_reg;

always @(posedge clk)
	begin
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