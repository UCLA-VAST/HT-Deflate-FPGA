// ==============================================================
// Description: Match length calculation
// Author: Weikang Qiao
// Date: 10/10/2016
// VEC = 16, Stages = 1 + Stage(min_reduction) = 4
// ==============================================================
module calc_match_len(
	clk, 
	current_vec, 
	match_result, 
	match_length
);

input 	wire 				clk;
input 	wire	[127:0]		current_vec;
input 	wire 	[127:0]		match_result;
output	wire	[4:0]		match_length;

//compare each bite
wire 				match_id_0;
wire 				match_id_1;
wire 				match_id_2;
wire 				match_id_3;
wire 				match_id_4;
wire 				match_id_5;
wire 				match_id_6;
wire 				match_id_7;
wire 				match_id_8;
wire 				match_id_9;
wire 				match_id_10;
wire 				match_id_11;
wire 				match_id_12;
wire 				match_id_13;
wire 				match_id_14;
wire 				match_id_15;

/*
wire 				match_id_0_reg;
wire 				match_id_1_reg;
wire 				match_id_2_reg;
wire 				match_id_3_reg;
wire 				match_id_4_reg;
wire 				match_id_5_reg;
wire 				match_id_6_reg;
wire 				match_id_7_reg;
wire 				match_id_8_reg;
wire 				match_id_9_reg;
wire 				match_id_10_reg;
wire 				match_id_11_reg;
wire 				match_id_12_reg;
wire 				match_id_13_reg;
wire 				match_id_14_reg;
wire 				match_id_15_reg;
*/

wire 	[4:0]		min_i;


assign match_id_0 = (current_vec[127:120] == match_result[127:120])?{1'd1}:{1'd0};
assign match_id_1 = (current_vec[119:112] == match_result[119:112])?{1'd1}:{1'd0};
assign match_id_2 = (current_vec[111:104] == match_result[111:104])?{1'd1}:{1'd0};
assign match_id_3 = (current_vec[103:96] == match_result[103:96])?{1'd1}:{1'd0};
assign match_id_4 = (current_vec[95:88] == match_result[95:88])?{1'd1}:{1'd0};
assign match_id_5 = (current_vec[87:80] == match_result[87:80])?{1'd1}:{1'd0};
assign match_id_6 = (current_vec[79:72] == match_result[79:72])?{1'd1}:{1'd0};
assign match_id_7 = (current_vec[71:64] == match_result[71:64])?{1'd1}:{1'd0};
assign match_id_8 = (current_vec[63:56] == match_result[63:56])?{1'd1}:{1'd0};
assign match_id_9 = (current_vec[55:48] == match_result[55:48])?{1'd1}:{1'd0};
assign match_id_10 = (current_vec[47:40] == match_result[47:40])?{1'd1}:{1'd0};
assign match_id_11 = (current_vec[39:32] == match_result[39:32])?{1'd1}:{1'd0};
assign match_id_12 = (current_vec[31:24] == match_result[31:24])?{1'd1}:{1'd0};
assign match_id_13 = (current_vec[23:16] == match_result[23:16])?{1'd1}:{1'd0};
assign match_id_14 = (current_vec[15:8] == match_result[15:8])?{1'd1}:{1'd0};
assign match_id_15 = (current_vec[7:0] == match_result[7:0])?{1'd1}:{1'd0};

/*
register_compression #(.N(1))	match_id_0_U(.d(match_id_0), .clk(clk), .q(match_id_0_reg));
register_compression #(.N(1))	match_id_1_U(.d(match_id_1), .clk(clk), .q(match_id_1_reg));
register_compression #(.N(1))	match_id_2_U(.d(match_id_2), .clk(clk), .q(match_id_2_reg));
register_compression #(.N(1))	match_id_3_U(.d(match_id_3), .clk(clk), .q(match_id_3_reg));
register_compression #(.N(1))	match_id_4_U(.d(match_id_4), .clk(clk), .q(match_id_4_reg));
register_compression #(.N(1))	match_id_5_U(.d(match_id_5), .clk(clk), .q(match_id_5_reg));
register_compression #(.N(1))	match_id_6_U(.d(match_id_6), .clk(clk), .q(match_id_6_reg));
register_compression #(.N(1))	match_id_7_U(.d(match_id_7), .clk(clk), .q(match_id_7_reg));
register_compression #(.N(1))	match_id_8_U(.d(match_id_8), .clk(clk), .q(match_id_8_reg));
register_compression #(.N(1))	match_id_9_U(.d(match_id_9), .clk(clk), .q(match_id_9_reg));
register_compression #(.N(1))	match_id_10_U(.d(match_id_10), .clk(clk), .q(match_id_10_reg));
register_compression #(.N(1))	match_id_11_U(.d(match_id_11), .clk(clk), .q(match_id_11_reg));
register_compression #(.N(1))	match_id_12_U(.d(match_id_12), .clk(clk), .q(match_id_12_reg));
register_compression #(.N(1))	match_id_13_U(.d(match_id_13), .clk(clk), .q(match_id_13_reg));
register_compression #(.N(1))	match_id_14_U(.d(match_id_14), .clk(clk), .q(match_id_14_reg));
register_compression #(.N(1))	match_id_15_U(.d(match_id_15), .clk(clk), .q(match_id_15_reg));
*/

min_reduction 		min_reduction_UUT(
	.input_0(match_id_0), 
	.input_1(match_id_1), 
	.input_2(match_id_2), 
	.input_3(match_id_3), 
	.input_4(match_id_4), 
	.input_5(match_id_5), 
	.input_6(match_id_6), 
	.input_7(match_id_7), 
	.input_8(match_id_8), 
	.input_9(match_id_9), 
	.input_10(match_id_10), 
	.input_11(match_id_11), 
	.input_12(match_id_12), 
	.input_13(match_id_13), 
	.input_14(match_id_14), 
	.input_15(match_id_15), 
	.min_i(min_i) 
);

register_compression #(.N(5)) register_min_i(.d(min_i), .clk(clk), .q(match_length));

endmodule