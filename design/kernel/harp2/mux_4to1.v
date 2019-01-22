module mux_4to1(
	din0,
	din1,
	din2,
	din3,
	sel,
	dout
);


input 	[127:0]		din0;
input 	[127:0]		din1;
input 	[127:0]		din2;
input 	[127:0]		din3;


input	[1:0]		sel;
output	[127:0]		dout;

reg		[127:0]		reg_dout;

always @(*)
	begin
		case(sel)
			2'd0:	reg_dout = din0;
			2'd1:	reg_dout = din1;
			2'd2: 	reg_dout = din2;
			2'd3: 	reg_dout = din3;
		endcase
	end


assign dout = reg_dout;

endmodule