// ==============================================================
// Description: Register without enable
// Author: Weikang Qiao
// Date: 10/10/2016
// ==============================================================
module register_compression_reset(d, clk, reset, q);

	parameter	N = 1;

	input	[N-1:0]	d; 
	input	clk;
	input	reset;
	output  [N-1:0]	q;


	reg  [N-1:0]	q_reg;

always @(posedge clk)
	begin
	if(reset)
		begin
			q_reg <= 0;
		end
	else
		begin
			q_reg <= d;
		end
	end

assign q = q_reg;

endmodule