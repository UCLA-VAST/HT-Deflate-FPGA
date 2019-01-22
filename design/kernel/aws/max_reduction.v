// ==============================================================
// Description: Perform min reduction 
// Author: Weikang Qiao
// Date: 10/10/2016
// VEC = 8, Stages = 1
// 
// ==============================================================
module max_reduction(
	input_0, 
	input_1, 
	input_2, 
	input_3, 
	input_4, 
	input_5, 
	input_6, 
	input_7,
	input_8, 
	input_9, 
	input_10, 
	input_11, 
	input_12, 
	input_13, 
	input_14, 
	input_15,
	max,  
	max_i
);


input 	[4:0]	input_0;
input 	[4:0]	input_1;
input 	[4:0]	input_2;
input 	[4:0]	input_3;
input 	[4:0]	input_4;
input 	[4:0]	input_5;
input 	[4:0]	input_6;
input 	[4:0]	input_7;
input 	[4:0]	input_8;
input 	[4:0]	input_9;
input 	[4:0]	input_10;
input 	[4:0]	input_11;
input 	[4:0]	input_12;
input 	[4:0]	input_13;
input 	[4:0]	input_14;
input 	[4:0]	input_15;
output 	[4:0]	max;
output	[4:0]	max_i;

// compare stage 1 port

wire 			comp_0_s1;
wire 			comp_1_s1;
wire 			comp_2_s1;
wire 			comp_3_s1;
wire 			comp_4_s1;
wire 			comp_5_s1;
wire 			comp_6_s1;
wire 			comp_7_s1;

wire	[4:0]	temp0_s1;
wire	[4:0]	temp1_s1;
wire	[4:0]	temp2_s1;
wire	[4:0]	temp3_s1;
wire	[4:0]	temp4_s1;
wire	[4:0]	temp5_s1;
wire	[4:0]	temp6_s1;
wire	[4:0]	temp7_s1;

wire	[4:0]	temp0_s1_i;
wire	[4:0]	temp1_s1_i;
wire	[4:0]	temp2_s1_i;
wire	[4:0]	temp3_s1_i;
wire	[4:0]	temp4_s1_i;
wire	[4:0]	temp5_s1_i;
wire	[4:0]	temp6_s1_i;
wire	[4:0]	temp7_s1_i;

// compare stage 1 
adder_5bits adder_5bits_0_s1_U(
	.a(input_0),
	.b(~input_1),
	.ci(1'b1),
	.s(),	//co = 1 : a >= b
	.co(comp_0_s1) 	//co = 0 : a < b
);

adder_5bits adder_5bits_1_s1_U(
	.a(input_2),
	.b(~input_3),
	.ci(1'b1),
	.s(),
	.co(comp_1_s1) 
);

adder_5bits adder_5bits_2_s1_U(
	.a(input_4),
	.b(~input_5),
	.ci(1'b1),
	.s(),
	.co(comp_2_s1) 
);

adder_5bits adder_5bits_3_s1_U(
	.a(input_6),
	.b(~input_7),
	.ci(1'b1),
	.s(),
	.co(comp_3_s1) 
);

adder_5bits adder_5bits_4_s1_U(
	.a(input_8),
	.b(~input_9),
	.ci(1'b1),
	.s(),	//co = 1 : a >= b
	.co(comp_4_s1) 	//co = 0 : a < b
);

adder_5bits adder_5bits_5_s1_U(
	.a(input_10),
	.b(~input_11),
	.ci(1'b1),
	.s(),
	.co(comp_5_s1) 
);

adder_5bits adder_5bits_6_s1_U(
	.a(input_12),
	.b(~input_13),
	.ci(1'b1),
	.s(),
	.co(comp_6_s1) 
);

adder_5bits adder_5bits_7_s1_U(
	.a(input_14),
	.b(~input_15),
	.ci(1'b1),
	.s(),
	.co(comp_7_s1) 
);

assign temp0_s1 = (comp_0_s1)?input_0:input_1;
assign temp1_s1 = (comp_1_s1)?input_2:input_3;
assign temp2_s1 = (comp_2_s1)?input_4:input_5;
assign temp3_s1 = (comp_3_s1)?input_6:input_7;
assign temp4_s1 = (comp_4_s1)?input_8:input_9;
assign temp5_s1 = (comp_5_s1)?input_10:input_11;
assign temp6_s1 = (comp_6_s1)?input_12:input_13;
assign temp7_s1 = (comp_7_s1)?input_14:input_15;

assign temp0_s1_i = (comp_0_s1)?5'd0:5'd1;
assign temp1_s1_i = (comp_1_s1)?5'd2:5'd3;
assign temp2_s1_i = (comp_2_s1)?5'd4:5'd5;
assign temp3_s1_i = (comp_3_s1)?5'd6:5'd7;
assign temp4_s1_i = (comp_4_s1)?5'd8:5'd9;
assign temp5_s1_i = (comp_5_s1)?5'd10:5'd11;
assign temp6_s1_i = (comp_6_s1)?5'd12:5'd13;
assign temp7_s1_i = (comp_7_s1)?5'd14:5'd15;

// compare stage 2 port
wire			comp_0_s2;
wire			comp_1_s2;
wire			comp_2_s2;
wire			comp_3_s2;

wire	[4:0]	temp0_s2;
wire	[4:0]	temp1_s2;
wire	[4:0]	temp2_s2;
wire	[4:0]	temp3_s2;

wire	[4:0]	temp0_s2_i;
wire	[4:0]	temp1_s2_i;
wire	[4:0]	temp2_s2_i;
wire	[4:0]	temp3_s2_i;

// compare stage 2
adder_5bits adder_5bits_0_s2_U(
	.a(temp0_s1),
	.b(~temp1_s1),
	.ci(1'b1),
	.s(),	
	.co(comp_0_s2) 	
);

adder_5bits adder_5bits_1_s2_U(
	.a(temp2_s1),
	.b(~temp3_s1),
	.ci(1'b1),
	.s(),	
	.co(comp_1_s2) 	
);

adder_5bits adder_5bits_2_s2_U(
	.a(temp4_s1),
	.b(~temp5_s1),
	.ci(1'b1),
	.s(),	
	.co(comp_2_s2) 	
);

adder_5bits adder_5bits_3_s2_U(
	.a(temp6_s1),
	.b(~temp7_s1),
	.ci(1'b1),
	.s(),	
	.co(comp_3_s2) 	
);

assign temp0_s2 = (comp_0_s2)?temp0_s1:temp1_s1;
assign temp1_s2 = (comp_1_s2)?temp2_s1:temp3_s1;
assign temp2_s2 = (comp_2_s2)?temp4_s1:temp5_s1;
assign temp3_s2 = (comp_3_s2)?temp6_s1:temp7_s1;

assign temp0_s2_i = (comp_0_s2)?temp0_s1_i:temp1_s1_i;
assign temp1_s2_i = (comp_1_s2)?temp2_s1_i:temp3_s1_i;
assign temp2_s2_i = (comp_2_s2)?temp4_s1_i:temp5_s1_i;
assign temp3_s2_i = (comp_3_s2)?temp6_s1_i:temp7_s1_i;

// compare stage 3 port
wire			comp_0_s3;
wire			comp_1_s3;

wire	[4:0]	temp0_s3;
wire	[4:0]	temp1_s3;

wire	[4:0]	temp0_s3_i;
wire	[4:0]	temp1_s3_i;

// compare stage 3
adder_5bits adder_5bits_0_s3_U(
	.a(temp0_s2),
	.b(~temp1_s2),
	.ci(1'b1),
	.s(),	
	.co(comp_0_s3) 	
);

adder_5bits adder_5bits_1_s3_U(
	.a(temp2_s2),
	.b(~temp3_s2),
	.ci(1'b1),
	.s(),	
	.co(comp_1_s3) 	
);

assign temp0_s3 = (comp_0_s3)?temp0_s2:temp1_s2;
assign temp1_s3 = (comp_1_s3)?temp2_s2:temp3_s2;

assign temp0_s3_i = (comp_0_s3)?temp0_s2_i:temp1_s2_i;
assign temp1_s3_i = (comp_1_s3)?temp2_s2_i:temp3_s2_i;

// compare stage 4 port
wire 	comp_s4;

// compare stage 4
adder_5bits adder_5bits_0_s4_U(
	.a(temp0_s3),
	.b(~temp1_s3),
	.ci(1'b1),
	.s(),	
	.co(comp_s4) 	
);

assign max = (comp_s4)?temp0_s3:temp1_s3;

assign max_i = (comp_s4)?temp0_s3_i:temp1_s3_i;





endmodule