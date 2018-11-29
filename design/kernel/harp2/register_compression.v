// ==============================================================
// Description: Register without enable
// Author: Weikang Qiao
// Date: 10/10/2016
// ==============================================================
module register_compression(d, clk, q);

	parameter	N = 1;

	input	wire	[N-1:0]	d; 
	input	wire			clk;
	output	wire  [N-1:0]	q;


	reg  [N-1:0]	q_reg;

always @(posedge clk)
	begin
		q_reg <= d;
	end

assign q = q_reg;

endmodule