module mux_16to1(
	din0,
	din1,
	din2,
	din3,
	din4,
	din5,
	din6,
	din7,
	din8,
	din9,
	din10,
	din11,
	din12,
	din13,
	din14,
	din15,
	sel,
	dout
);

parameter N = 8;

input 	[N-1:0]		din0;
input 	[N-1:0]		din1;
input 	[N-1:0]		din2;
input 	[N-1:0]		din3;
input 	[N-1:0]		din4;
input 	[N-1:0]		din5;
input 	[N-1:0]		din6;
input 	[N-1:0]		din7;
input 	[N-1:0]		din8;
input 	[N-1:0]		din9;
input 	[N-1:0]		din10;
input 	[N-1:0]		din11;
input 	[N-1:0]		din12;
input 	[N-1:0]		din13;
input 	[N-1:0]		din14;
input 	[N-1:0]		din15;
input	[4:0]		sel;
output	[N-1:0]		dout;

reg		[N-1:0]		reg_dout;

always @(*)
	begin
		case(sel)
			5'd0:	reg_dout = din0;
			5'd1:	reg_dout = din1;
			5'd2: 	reg_dout = din2;
			5'd3: 	reg_dout = din3;
			5'd4: 	reg_dout = din4;
			5'd5: 	reg_dout = din5;
			5'd6: 	reg_dout = din6;
			5'd7: 	reg_dout = din7;
			5'd8:	reg_dout = din8;
			5'd9:	reg_dout = din9;
			5'd10: 	reg_dout = din10;
			5'd11: 	reg_dout = din11;
			5'd12: 	reg_dout = din12;
			5'd13: 	reg_dout = din13;
			5'd14: 	reg_dout = din14;
			5'd15: 	reg_dout = din15;
			default: 	reg_dout = din0;
		endcase
	end


assign dout = reg_dout;

endmodule