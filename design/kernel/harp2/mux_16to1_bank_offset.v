module mux_16to1_bank_offset(
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


input 	[7:0]		din0;
input 	[7:0]		din1;
input 	[7:0]		din2;
input 	[7:0]		din3;
input 	[7:0]		din4;
input 	[7:0]		din5;
input 	[7:0]		din6;
input 	[7:0]		din7;
input 	[7:0]		din8;
input 	[7:0]		din9;
input 	[7:0]		din10;
input 	[7:0]		din11;
input 	[7:0]		din12;
input 	[7:0]		din13;
input 	[7:0]		din14;
input 	[7:0]		din15;
input	[4:0]		sel;
output	[8:0]		dout;

reg		[8:0]		reg_dout;

always @(*)
	begin
		case(sel)
			5'd0:	reg_dout = {1'b0, din0};
			5'd1:	reg_dout = {1'b0, din1};
			5'd2: 	reg_dout = {1'b0, din2};
			5'd3: 	reg_dout = {1'b0, din3};
			5'd4: 	reg_dout = {1'b0, din4};
			5'd5: 	reg_dout = {1'b0, din5};
			5'd6: 	reg_dout = {1'b0, din6};
			5'd7: 	reg_dout = {1'b0, din7};
			5'd8:	reg_dout = {1'b0, din8};
			5'd9:	reg_dout = {1'b0, din9};
			5'd10: 	reg_dout = {1'b0, din10};
			5'd11: 	reg_dout = {1'b0, din11};
			5'd12: 	reg_dout = {1'b0, din12};
			5'd13: 	reg_dout = {1'b0, din13};
			5'd14: 	reg_dout = {1'b0, din14};
			5'd15: 	reg_dout = {1'b0, din15};
			default: 	reg_dout = 9'b100000000;
		endcase
	end

assign dout = reg_dout;

endmodule