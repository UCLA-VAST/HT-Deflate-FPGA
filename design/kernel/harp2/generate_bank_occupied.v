// ==============================================================
// Description: Generate bank_occupied
// Author: Weikang Qiao
// Date: 2/28/2016
// VEC = 16, Stages = 1
// ==============================================================

module generate_bank_occupied(
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

input	[5:0]		din0;
input	[5:0]		din1;
input	[5:0]		din2;
input	[5:0]		din3;
input	[5:0]		din4;
input	[5:0]		din5;
input	[5:0]		din6;
input	[5:0]		din7;
input	[5:0]		din8;
input	[5:0]		din9;
input	[5:0]		din10;
input	[5:0]		din11;
input	[5:0]		din12;
input	[5:0]		din13;
input	[5:0]		din14;
input	[5:0]		din15;

input	[5:0]		sel;
output	[4:0]		dout;

wire 	[4:0]		temp0;
wire 	[4:0]		temp1;
wire 	[4:0]		temp2;
wire 	[4:0]		temp3;
wire 	[4:0]		temp4;
wire 	[4:0]		temp5;
wire 	[4:0]		temp6;
wire 	[4:0]		temp7;
wire 	[4:0]		temp8;
wire 	[4:0]		temp9;
wire 	[4:0]		temp10;
wire 	[4:0]		temp11;
wire 	[4:0]		temp12;
wire 	[4:0]		temp13;
wire 	[4:0]		temp14;
wire 	[4:0]		temp15;

assign temp0 = (sel == din0)?{5'd1}:{5'd0};
assign temp1 = (sel == din1)?{5'd2}:{5'd0};
assign temp2 = (sel == din2)?{5'd3}:{5'd0};
assign temp3 = (sel == din3)?{5'd4}:{5'd0};
assign temp4 = (sel == din4)?{5'd5}:{5'd0};
assign temp5 = (sel == din5)?{5'd6}:{5'd0};
assign temp6 = (sel == din6)?{5'd7}:{5'd0};
assign temp7 = (sel == din7)?{5'd8}:{5'd0};
assign temp8 = (sel == din8)?{5'd9}:{5'd0};
assign temp9 = (sel == din9)?{5'd10}:{5'd0};
assign temp10 = (sel == din10)?{5'd11}:{5'd0};
assign temp11 = (sel == din11)?{5'd12}:{5'd0};
assign temp12 = (sel == din12)?{5'd13}:{5'd0};
assign temp13 = (sel == din13)?{5'd14}:{5'd0};
assign temp14 = (sel == din14)?{5'd15}:{5'd0};
assign temp15 = (sel == din15)?{5'd16}:{5'd0};

wire	[4:0]		comp_result;
wire 	[4:0]		result;

assign comp_result = temp0 | temp1 | temp2 | temp3 | temp4 | temp5 | temp6 | temp7 
					| temp8 | temp9 | temp10 | temp11 | temp12 | temp13 | temp14 | temp15;

assign result = comp_result - 1;

assign dout = (comp_result == 0)?{5'd16}:result;


endmodule


