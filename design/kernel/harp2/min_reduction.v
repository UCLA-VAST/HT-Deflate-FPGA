// ==============================================================
// Description: Perform min reduction 
// Author: Weikang Qiao
// Date: 03/2/2017
// VEC = 16, Stages = 1
// min_i = 16 means all inputs are matched
// min_i = 0 means no input is matched
// ==============================================================

module min_reduction (
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
	min_i
);



input 			 	input_0;
input 				input_1;
input 			 	input_2;
input 			 	input_3;
input 			 	input_4;
input 			 	input_5;
input 			 	input_6;
input 			 	input_7;
input 			 	input_8;
input 				input_9;
input 			 	input_10;
input 			 	input_11;
input 			 	input_12;
input 			 	input_13;
input 			 	input_14;
input 			 	input_15;
output	[4:0]		min_i;
//output 				min_ready;


//step 1
wire 			temp0;
wire 			temp1;
wire 			temp2;
wire 			temp3;
wire 			temp4;
wire 			temp5;
wire 			temp6;
wire 			temp7;
wire 	[4:0] 	temp0_i;
wire 	[4:0] 	temp1_i;
wire  	[4:0] 	temp2_i;
wire 	[4:0] 	temp3_i;
wire 	[4:0] 	temp4_i;
wire 	[4:0] 	temp5_i;
wire  	[4:0] 	temp6_i;
wire 	[4:0] 	temp7_i;

assign temp0 = (input_0 == 1'd0)?input_0:input_1;
assign temp0_i = (input_0 == 1'd0)?5'd0:5'd1;
assign temp1 = (input_2 == 1'd0)?input_2:input_3;
assign temp1_i = (input_2 == 1'd0)?5'd2:5'd3;
assign temp2 = (input_4 == 1'd0)?input_4:input_5;
assign temp2_i = (input_4 == 1'd0)?5'd4:5'd5;
assign temp3 = (input_6 == 1'd0)?input_6:input_7;
assign temp3_i = (input_6 == 1'd0)?5'd6:5'd7;
assign temp4 = (input_8 == 1'd0)?input_8:input_9;
assign temp4_i = (input_8 == 1'd0)?5'd8:5'd9;
assign temp5 = (input_10 == 1'd0)?input_10:input_11;
assign temp5_i = (input_10 == 1'd0)?5'd10:5'd11;
assign temp6 = (input_12 == 1'd0)?input_12:input_13;
assign temp6_i = (input_12 == 1'd0)?5'd12:5'd13;
assign temp7 = (input_14 == 1'd0)?input_14:input_15;
assign temp7_i = (input_14 == 1'd0)?5'd14:5'd15;


//step 2
wire			temp0_s1;
wire	[4:0]	temp0_i_s1;
wire			temp1_s1;
wire	[4:0]	temp1_i_s1;
wire			temp2_s1;
wire	[4:0]	temp2_i_s1;
wire			temp3_s1;
wire	[4:0]	temp3_i_s1;

assign temp0_s1 = (temp0 == 1'd0)?temp0:temp1;
assign temp0_i_s1 = (temp0 == 1'd0)?temp0_i:temp1_i;
assign temp1_s1 = (temp2 == 1'd0)?temp2:temp3;
assign temp1_i_s1 = (temp2 == 1'd0)?temp2_i:temp3_i;
assign temp2_s1 = (temp4 == 1'd0)?temp4:temp5;
assign temp2_i_s1 = (temp4 == 1'd0)?temp4_i:temp5_i;
assign temp3_s1 = (temp6 == 1'd0)?temp6:temp7;
assign temp3_i_s1 = (temp6 == 1'd0)?temp6_i:temp7_i;


//step 3
wire			temp0_s2;
wire	[4:0]	temp0_i_s2;
wire			temp1_s2;
wire	[4:0]	temp1_i_s2;

assign temp0_s2 = (temp0_s1 == 1'd0)?temp0_s1:temp1_s1;
assign temp0_i_s2 = (temp0_s1 == 1'd0)?temp0_i_s1:temp1_i_s1;
assign temp1_s2 = (temp2_s1 == 1'd0)?temp2_s1:temp3_s1;
assign temp1_i_s2 = (temp2_s1 == 1'd0)?temp2_i_s1:temp3_i_s1;

assign min_i = (temp0_s2 == 1'd0)?(temp0_i_s2):((temp1_s2 == 1'd0)?(temp1_i_s2):5'd16);

endmodule