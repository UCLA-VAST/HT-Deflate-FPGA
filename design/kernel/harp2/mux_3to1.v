module mux_3to1(
	din0,
	din1,
	din2,
	sel,
	dout
);

parameter N = 32;

input 	[N-1:0]		din0;
input 	[N-1:0]		din1;
input 	[N-1:0]		din2;
input	[1:0]		sel;
output	[N-1:0]		dout;

reg		[N-1:0]		reg_dout;

always @(*)
	begin
		case(sel)
			2'd0:	reg_dout <= din0;
			2'd1:	reg_dout <= din1;
			2'd2: 	reg_dout <= din2;
			default: reg_dout <= din0;
		endcase
	end


assign dout = reg_dout;

endmodule