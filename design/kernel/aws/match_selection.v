/******************************************************************************
* 
* Description： Match selection
* Author: Weikang Qiao
* Date: 06/27/2018
* 
* Parameters:
*
* Note: 
*		Total stage number is 22
* 		s1-s2:  perform max reduction
* 		s3-s4:  tail match trimming
* 		s5-s6:  set bits within tail and head to be 0
*		s7-s22: lazy match (VEC stage)
* 
******************************************************************************/

module match_selection(
	clk, 
	reset, 
	start, 
	last, 
	en, 
	literals, 
	len_raw, 
	dist_raw,
	valid_raw, 
	larray_out, 
	darray_out, 
	valid_out, 
	ready_out, 
	start_out, 
	last_out
);

// ====================================================================
//
//  Input & output ports defined here
//
// ====================================================================

input 				clk;
input 				reset;

// enable signal passed from hash match module
// enable is high means the coming literal, len_raw, dist_raw and 
// valid_raw information is valid
input 				en;

input 				start;

input 				last;

// literal[127:120] is input[0]
input	[127:0]		literals;

// matched length information for each substring
input	[127:0]		len_raw;

// matched distance information for each substring
input 	[255:0]		dist_raw; 

// indicate if each len_raw & dist_raw are for a real match
input 	[15:0]		valid_raw;

// output the length information after match selection
output 	[127:0]		larray_out;

// output the distance information after match selection
output 	[255:0]		darray_out;

// output the valid information for each (length & distance pair)
output	[15:0]		valid_out;

// ready signal for next huffman encoding stages
output				ready_out;

output 				start_out; 

output 				last_out;


// ====================================================================
//
//  Stage 1: Max reduction #1
//
// ====================================================================

// stage 1 ports definition
// calculate the matched reach distance for each substring
wire	[4:0]		reach_0_op;
wire	[4:0]		reach_1_op;
wire	[4:0]		reach_2_op;
wire	[4:0]		reach_3_op;
wire	[4:0]		reach_4_op;
wire	[4:0]		reach_5_op;
wire	[4:0]		reach_6_op;
wire	[4:0]		reach_7_op;
wire	[4:0]		reach_8_op;
wire	[4:0]		reach_9_op;
wire	[4:0]		reach_10_op;
wire	[4:0]		reach_11_op;
wire	[4:0]		reach_12_op;
wire	[4:0]		reach_13_op;
wire	[4:0]		reach_14_op;
wire	[4:0]		reach_15_op;

// the real matched reach distance exclude the case where len_raw is 
// indeed a literal
wire	[4:0]		reach_0;
wire	[4:0]		reach_1;
wire	[4:0]		reach_2;
wire	[4:0]		reach_3;
wire	[4:0]		reach_4;
wire	[4:0]		reach_5;
wire	[4:0]		reach_6;
wire	[4:0]		reach_7;
wire	[4:0]		reach_8;
wire	[4:0]		reach_9;
wire	[4:0]		reach_10;
wire	[4:0]		reach_11;
wire	[4:0]		reach_12;
wire	[4:0]		reach_13;
wire	[4:0]		reach_14;
wire	[4:0]		reach_15;

wire	[4:0]		reg_reach_0_s1;
wire	[4:0]		reg_reach_1_s1;
wire	[4:0]		reg_reach_2_s1;
wire	[4:0]		reg_reach_3_s1;
wire	[4:0]		reg_reach_4_s1;
wire	[4:0]		reg_reach_5_s1;
wire	[4:0]		reg_reach_6_s1;
wire	[4:0]		reg_reach_7_s1;
wire	[4:0]		reg_reach_8_s1;
wire	[4:0]		reg_reach_9_s1;
wire	[4:0]		reg_reach_10_s1;
wire	[4:0]		reg_reach_11_s1;
wire	[4:0]		reg_reach_12_s1;
wire	[4:0]		reg_reach_13_s1;
wire	[4:0]		reg_reach_14_s1;
wire	[4:0]		reg_reach_15_s1;

// 


//
wire	[127:0]		literals_s1_reg;
wire	[127:0]		len_raw_s1_reg;
wire 	[255:0]		dist_raw_s1_reg;
wire 	[15:0]		valid_raw_s1_reg;

// 
wire 				en_s1_reg;
wire 				start_s1_reg;
wire 				last_s1_reg;

// stage 1
// for VEC=16 design, 5 LSBs is enough to get the reached length 
assign reach_0_op = len_raw[124:120] + 5'd3;
assign reach_1_op = len_raw[116:112] + 5'd4;
assign reach_2_op = len_raw[108:104] + 5'd5;
assign reach_3_op = len_raw[100:96] + 5'd6;
assign reach_4_op = len_raw[92:88] + 5'd7;
assign reach_5_op = len_raw[84:80] + 5'd8;
assign reach_6_op = len_raw[76:72] + 5'd9;
assign reach_7_op = len_raw[68:64] + 5'd10;
assign reach_8_op = len_raw[60:56] + 5'd11;
assign reach_9_op = len_raw[52:48] + 5'd12;
assign reach_10_op = len_raw[44:40] + 5'd13;
assign reach_11_op = len_raw[36:32] + 5'd14;
assign reach_12_op = len_raw[28:24] + 5'd15;
assign reach_13_op = len_raw[20:16] + 5'd16;
assign reach_14_op = len_raw[12:8] + 5'd17;
assign reach_15_op = len_raw[4:0] + 5'd18;

// valid_raw[k]== 0 means the len_raw is a literal
assign reach_0 = (valid_raw[15])?{reach_0_op}:5'd1;	
assign reach_1 = (valid_raw[14])?{reach_1_op}:5'd2;
assign reach_2 = (valid_raw[13])?{reach_2_op}:5'd3;
assign reach_3 = (valid_raw[12])?{reach_3_op}:5'd4;
assign reach_4 = (valid_raw[11])?{reach_4_op}:5'd5;
assign reach_5 = (valid_raw[10])?{reach_5_op}:5'd6;
assign reach_6 = (valid_raw[9])?{reach_6_op}:5'd7;
assign reach_7 = (valid_raw[8])?{reach_7_op}:5'd8;
assign reach_8 = (valid_raw[7])?{reach_8_op}:5'd9;	
assign reach_9 = (valid_raw[6])?{reach_9_op}:5'd10;
assign reach_10 = (valid_raw[5])?{reach_10_op}:5'd11;
assign reach_11 = (valid_raw[4])?{reach_11_op}:5'd12;
assign reach_12 = (valid_raw[3])?{reach_12_op}:5'd13;
assign reach_13 = (valid_raw[2])?{reach_13_op}:5'd14;
assign reach_14 = (valid_raw[1])?{reach_14_op}:5'd15;
assign reach_15 = (valid_raw[0])?{reach_15_op}:5'd16;

// 
register_compression #(.N(5)) register_reach_0_s1_U(.d(reach_0), .clk(clk), .q(reg_reach_0_s1));
register_compression #(.N(5)) register_reach_1_s1_U(.d(reach_1), .clk(clk), .q(reg_reach_1_s1));
register_compression #(.N(5)) register_reach_2_s1_U(.d(reach_2), .clk(clk), .q(reg_reach_2_s1));
register_compression #(.N(5)) register_reach_3_s1_U(.d(reach_3), .clk(clk), .q(reg_reach_3_s1));
register_compression #(.N(5)) register_reach_4_s1_U(.d(reach_4), .clk(clk), .q(reg_reach_4_s1));
register_compression #(.N(5)) register_reach_5_s1_U(.d(reach_5), .clk(clk), .q(reg_reach_5_s1));
register_compression #(.N(5)) register_reach_6_s1_U(.d(reach_6), .clk(clk), .q(reg_reach_6_s1));
register_compression #(.N(5)) register_reach_7_s1_U(.d(reach_7), .clk(clk), .q(reg_reach_7_s1));
register_compression #(.N(5)) register_reach_8_s1_U(.d(reach_8), .clk(clk), .q(reg_reach_8_s1));
register_compression #(.N(5)) register_reach_9_s1_U(.d(reach_9), .clk(clk), .q(reg_reach_9_s1));
register_compression #(.N(5)) register_reach_10_s1_U(.d(reach_10), .clk(clk), .q(reg_reach_10_s1));
register_compression #(.N(5)) register_reach_11_s1_U(.d(reach_11), .clk(clk), .q(reg_reach_11_s1));
register_compression #(.N(5)) register_reach_12_s1_U(.d(reach_12), .clk(clk), .q(reg_reach_12_s1));
register_compression #(.N(5)) register_reach_13_s1_U(.d(reach_13), .clk(clk), .q(reg_reach_13_s1));
register_compression #(.N(5)) register_reach_14_s1_U(.d(reach_14), .clk(clk), .q(reg_reach_14_s1));
register_compression #(.N(5)) register_reach_15_s1_U(.d(reach_15), .clk(clk), .q(reg_reach_15_s1));

// 
register_compression #(.N(128)) register_literals_s1_U(.d(literals), .clk(clk), .q(literals_s1_reg));
register_compression #(.N(128)) register_len_raw_s1_U(.d(len_raw), .clk(clk), .q(len_raw_s1_reg));
register_compression #(.N(256)) register_dist_raw_s1_U(.d(dist_raw), .clk(clk), .q(dist_raw_s1_reg));
register_compression #(.N(16)) register_valid_raw_U(.d(valid_raw), .clk(clk), .q(valid_raw_s1_reg));

//
register_compression #(.N(1)) register_en_s1_U(.d(en), .clk(clk), .q(en_s1_reg));
register_compression #(.N(1)) register_start_s1_U(.d(start), .clk(clk), .q(start_s1_reg));
register_compression #(.N(1)) register_last_s1_U(.d(last), .clk(clk), .q(last_s1_reg));


// ====================================================================
//
//  Stage 2: Max reduction #2
//
// ====================================================================

// stage 2 ports definition
// the maximum reach distance & its corresponding substring index
wire 	[4:0]	max_reach;
wire	[4:0]	max_reach_index;

wire 	[4:0]	reg_max_reach_s2;
wire	[4:0]	reg_max_reach_index_s2;

// 
wire	[4:0]		reg_reach_0_s2;
wire	[4:0]		reg_reach_1_s2;
wire	[4:0]		reg_reach_2_s2;
wire	[4:0]		reg_reach_3_s2;
wire	[4:0]		reg_reach_4_s2;
wire	[4:0]		reg_reach_5_s2;
wire	[4:0]		reg_reach_6_s2;
wire	[4:0]		reg_reach_7_s2;
wire	[4:0]		reg_reach_8_s2;
wire	[4:0]		reg_reach_9_s2;
wire	[4:0]		reg_reach_10_s2;
wire	[4:0]		reg_reach_11_s2;
wire	[4:0]		reg_reach_12_s2;
wire	[4:0]		reg_reach_13_s2;
wire	[4:0]		reg_reach_14_s2;
wire	[4:0]		reg_reach_15_s2;

// 
wire	[127:0]		literals_s2_reg;
wire	[127:0]		len_raw_s2_reg;
wire 	[255:0]		dist_raw_s2_reg;
wire 	[15:0]		valid_raw_s2_reg;

// 
wire 				en_s2_reg;
wire 				start_s2_reg;
wire 				last_s2_reg;

// stage 2
max_reduction max_reduction_U(
	.input_0(reg_reach_0_s1), 
	.input_1(reg_reach_1_s1), 
	.input_2(reg_reach_2_s1), 
	.input_3(reg_reach_3_s1), 
	.input_4(reg_reach_4_s1), 
	.input_5(reg_reach_5_s1), 
	.input_6(reg_reach_6_s1), 
	.input_7(reg_reach_7_s1),
	.input_8(reg_reach_8_s1), 
	.input_9(reg_reach_9_s1), 
	.input_10(reg_reach_10_s1), 
	.input_11(reg_reach_11_s1), 
	.input_12(reg_reach_12_s1), 
	.input_13(reg_reach_13_s1), 
	.input_14(reg_reach_14_s1), 
	.input_15(reg_reach_15_s1),
	.max(max_reach),  
	.max_i(max_reach_index)
);

//
register_compression #(.N(5)) 		register_max_reach_s2_U(.d(max_reach), .clk(clk), .q(reg_max_reach_s2));
register_compression #(.N(5)) 		register_max_reach_index_s2_U(.d(max_reach_index), .clk(clk), .q(reg_max_reach_index_s2));

register_compression #(.N(5)) 		register_reach_0_s2_U(.d(reg_reach_0_s1), .clk(clk), .q(reg_reach_0_s2));
register_compression #(.N(5)) 		register_reach_1_s2_U(.d(reg_reach_1_s1), .clk(clk), .q(reg_reach_1_s2));
register_compression #(.N(5)) 		register_reach_2_s2_U(.d(reg_reach_2_s1), .clk(clk), .q(reg_reach_2_s2));
register_compression #(.N(5)) 		register_reach_3_s2_U(.d(reg_reach_3_s1), .clk(clk), .q(reg_reach_3_s2));
register_compression #(.N(5)) 		register_reach_4_s2_U(.d(reg_reach_4_s1), .clk(clk), .q(reg_reach_4_s2));
register_compression #(.N(5)) 		register_reach_5_s2_U(.d(reg_reach_5_s1), .clk(clk), .q(reg_reach_5_s2));
register_compression #(.N(5)) 		register_reach_6_s2_U(.d(reg_reach_6_s1), .clk(clk), .q(reg_reach_6_s2));
register_compression #(.N(5)) 		register_reach_7_s2_U(.d(reg_reach_7_s1), .clk(clk), .q(reg_reach_7_s2));
register_compression #(.N(5)) 		register_reach_8_s2_U(.d(reg_reach_8_s1), .clk(clk), .q(reg_reach_8_s2));
register_compression #(.N(5)) 		register_reach_9_s2_U(.d(reg_reach_9_s1), .clk(clk), .q(reg_reach_9_s2));
register_compression #(.N(5)) 		register_reach_10_s2_U(.d(reg_reach_10_s1), .clk(clk), .q(reg_reach_10_s2));
register_compression #(.N(5)) 		register_reach_11_s2_U(.d(reg_reach_11_s1), .clk(clk), .q(reg_reach_11_s2));
register_compression #(.N(5)) 		register_reach_12_s2_U(.d(reg_reach_12_s1), .clk(clk), .q(reg_reach_12_s2));
register_compression #(.N(5)) 		register_reach_13_s2_U(.d(reg_reach_13_s1), .clk(clk), .q(reg_reach_13_s2));
register_compression #(.N(5)) 		register_reach_14_s2_U(.d(reg_reach_14_s1), .clk(clk), .q(reg_reach_14_s2));
register_compression #(.N(5)) 		register_reach_15_s2_U(.d(reg_reach_15_s1), .clk(clk), .q(reg_reach_15_s2));

register_compression #(.N(128)) 	register_literals_s2_U(.d(literals_s1_reg), .clk(clk), .q(literals_s2_reg));
register_compression #(.N(128)) 	register_len_raw_s2_U(.d(len_raw_s1_reg), .clk(clk), .q(len_raw_s2_reg));
register_compression #(.N(256)) 	register_dist_raw_s2_U(.d(dist_raw_s1_reg), .clk(clk), .q(dist_raw_s2_reg));
register_compression #(.N(16)) 		register_valid_raw_s2_U(.d(valid_raw_s1_reg), .clk(clk), .q(valid_raw_s2_reg));

// 
register_compression #(.N(1)) 		register_en_s2_U(.d(en_s1_reg), .clk(clk), .q(en_s2_reg));
register_compression #(.N(1)) 		register_start_s2_U(.d(start_s1_reg), .clk(clk), .q(start_s2_reg));
register_compression #(.N(1)) 		register_last_s2_U(.d(last_s1_reg), .clk(clk), .q(last_s2_reg));


// ====================================================================
//
//  Stage 3: Tail match trimming #1
//
// ====================================================================

// stage 3 ports definition
// max_reach_equal_17 ==1 indicates if max_reach == VEC + 1
wire				max_reach_equal_17; 
// max_reach_equal_16 == 1 indicate if max_reach == VEC	
wire				max_reach_equal_16;		

// head match position of current window exclude the case where
// current head match position == 17 && previous head (current 	
// tail)== 15/14 
wire	[4:0]		head_match_pos_op_s3;
// head match position of current window include the case
wire	[4:0] 		head_match_pos;

// indicate if previous head is equal to 15/14
wire				old_head_match_pos_equal_15;
wire				old_head_match_pos_equal_14;

// max_reach_index_valid_0 == 1 indicates the maximum reach index is 
// from position 15 
wire 				max_reach_index_valid_0;
wire 				max_reach_index_valid_0_reg;
// max reach index either inherited from reg_max_reach_index_s2 or 
// position 15 determined by max_reach_index_valid_0
wire 	[4:0]		max_reach_index_temp;
wire 	[4:0]		max_reach_index_temp_s3_reg;

// judge if max_reach_index < old_head_match_pos
// max_reach_index_larger = 1 means reg_max_reach_index_s2 is larger
wire 				max_reach_index_larger;
wire				max_reach_index_larger_reg;
// calculate the difference between them
wire 	[4:0]		diff;
wire 	[4:0]		diff_reg;

// original len_raw/dist_raw/reach distance information
wire 	[7:0]		len_raw_max_reach_index;
wire	[15:0]		dist_raw_max_reach_index;
wire	[4:0]		reach_max_reach_index;

wire 	[7:0]		len_raw_max_reach_index_reg;
wire	[15:0]		dist_raw_max_reach_index_reg;
wire	[4:0]		reach_max_reach_index_reg;

// previous head position (equivalent current tail position)
wire 	[4:0]		old_head_match_pos_s2_reg;

// 
wire 	[4:0]		old_head_match_pos_s3_reg;

//
wire 	[4:0]		reg_reach_0_s3;
wire 	[4:0]		reg_reach_1_s3;
wire 	[4:0]		reg_reach_2_s3;
wire 	[4:0]		reg_reach_3_s3;
wire 	[4:0]		reg_reach_4_s3;
wire 	[4:0]		reg_reach_5_s3;
wire 	[4:0]		reg_reach_6_s3;
wire 	[4:0]		reg_reach_7_s3;
wire 	[4:0]		reg_reach_8_s3;
wire 	[4:0]		reg_reach_9_s3;
wire 	[4:0]		reg_reach_10_s3;
wire 	[4:0]		reg_reach_11_s3;
wire 	[4:0]		reg_reach_12_s3;
wire 	[4:0]		reg_reach_13_s3;
wire 	[4:0]		reg_reach_14_s3;
wire 	[4:0]		reg_reach_15_s3;

// 
wire	[127:0]		literals_s3_reg;
wire	[127:0]		len_raw_s3_reg;
wire 	[255:0]		dist_raw_s3_reg;
wire 	[15:0]		valid_raw_s3_reg;

// 
wire 				en_s3_reg;
wire 				start_s3_reg;
wire 				last_s3_reg;

// stage 3
// check if max_reach == VEC + 1
assign max_reach_equal_17 = (reg_max_reach_s2 == 5'd17); 
// check if max_reach = VEC
assign max_reach_equal_16 = (reg_max_reach_s2 == 5'd16);	

// substract 16 from reg_max_reach_s2 to get head match position
adder_5bits	adder_5bits_head_match_pos_U(
	.a(reg_max_reach_s2),
	.b(5'b10000),
	.ci(1'b0),
	.s(head_match_pos_op_s3),
	.co()
);

// 
assign old_head_match_pos_equal_15 = (old_head_match_pos_s2_reg == 5'd15);
assign old_head_match_pos_equal_14 = (old_head_match_pos_s2_reg == 5'd14);

// 
assign max_reach_index_valid_0 = (max_reach_equal_17 & old_head_match_pos_equal_15) || (max_reach_equal_16 & (old_head_match_pos_equal_15 || old_head_match_pos_equal_14));

assign head_match_pos = (max_reach_equal_17 && old_head_match_pos_equal_15)?{5'b00000}:head_match_pos_op_s3;

// 
assign max_reach_index_temp = (max_reach_index_valid_0)?{5'b01111}:reg_max_reach_index_s2;

// judge if max_reach_index < old_head_match_pos
// max_reach_index_larger = 1 means reg_max_reach_index_s2 >= old_head_match_pos
adder_5bits	adder_5bits_max_reach_index_U(	
	.a(reg_max_reach_index_s2),
	.b(~old_head_match_pos_s2_reg),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_larger)	
);
//calculate the difference between old_head_match_pos & max_reach_index
adder_5bits	adder_5bits_max_reach_index_U_1(	
	.a(old_head_match_pos_s2_reg),
	.b(~reg_max_reach_index_s2),
	.ci(1'b1),
	.s(diff),
	.co()	
);

// select the original len_raw/dist_raw/reach distance information 
// based on the max_reach_index from stage 2
mux_16to1 #(.N(8)) mux_len_raw_max_reach_index_U(
	.din0(len_raw_s2_reg[127:120]),
	.din1(len_raw_s2_reg[119:112]),
	.din2(len_raw_s2_reg[111:104]),
	.din3(len_raw_s2_reg[103:96]),
	.din4(len_raw_s2_reg[95:88]),
	.din5(len_raw_s2_reg[87:80]),
	.din6(len_raw_s2_reg[79:72]),
	.din7(len_raw_s2_reg[71:64]),
	.din8(len_raw_s2_reg[63:56]),
	.din9(len_raw_s2_reg[55:48]),
	.din10(len_raw_s2_reg[47:40]),
	.din11(len_raw_s2_reg[39:32]),
	.din12(len_raw_s2_reg[31:24]),
	.din13(len_raw_s2_reg[23:16]),
	.din14(len_raw_s2_reg[15:8]),
	.din15(len_raw_s2_reg[7:0]),
	.sel(reg_max_reach_index_s2),
	.dout(len_raw_max_reach_index)
);

mux_16to1 #(.N(16)) mux_dist_raw_max_reach_index_U(
	.din0(dist_raw_s2_reg[255:240]),
	.din1(dist_raw_s2_reg[239:224]), 
	.din2(dist_raw_s2_reg[223:208]), 
	.din3(dist_raw_s2_reg[207:192]), 
	.din4(dist_raw_s2_reg[191:176]), 
	.din5(dist_raw_s2_reg[175:160]), 
	.din6(dist_raw_s2_reg[159:144]), 
	.din7(dist_raw_s2_reg[143:128]), 
	.din8(dist_raw_s2_reg[127:112]),
	.din9(dist_raw_s2_reg[111:96]), 
	.din10(dist_raw_s2_reg[95:80]), 
	.din11(dist_raw_s2_reg[79:64]), 
	.din12(dist_raw_s2_reg[63:48]), 
	.din13(dist_raw_s2_reg[47:32]), 
	.din14(dist_raw_s2_reg[31:16]), 
	.din15(dist_raw_s2_reg[15:0]), 
	.sel(reg_max_reach_index_s2), 
	.dout(dist_raw_max_reach_index)
);

mux_16to1 #(.N(5)) mux_reach_max_reach_index_U(
	.din0(reg_reach_0_s2), 
	.din1(reg_reach_1_s2), 
	.din2(reg_reach_2_s2), 
	.din3(reg_reach_3_s2), 
	.din4(reg_reach_4_s2), 
	.din5(reg_reach_5_s2), 
	.din6(reg_reach_6_s2), 
	.din7(reg_reach_7_s2), 
	.din8(reg_reach_8_s2), 
	.din9(reg_reach_9_s2), 
	.din10(reg_reach_10_s2), 
	.din11(reg_reach_11_s2), 
	.din12(reg_reach_12_s2), 
	.din13(reg_reach_13_s2), 
	.din14(reg_reach_14_s2), 
	.din15(reg_reach_15_s2), 
	.sel(reg_max_reach_index_s2), 
	.dout(reach_max_reach_index)
);

// 
register_en_reset #(.N(5)) register_en_old_head_match_pos_s2_U(.d(head_match_pos), .clk(clk), .enable(en_s2_reg), .reset(reset), .q(old_head_match_pos_s2_reg));

// 
register_compression #(.N(5)) register_old_head_match_pos_s3_U(.d(old_head_match_pos_s2_reg), .clk(clk), .q(old_head_match_pos_s3_reg));

register_compression #(.N(5)) register_max_reach_index_temp_s3_U(.d(max_reach_index_temp), .clk(clk), .q(max_reach_index_temp_s3_reg));

register_compression #(.N(1)) register_max_reach_index_larger_U(.d(max_reach_index_larger), .clk(clk), .q(max_reach_index_larger_reg));
register_compression #(.N(5)) register_diff_U(.d(diff), .clk(clk), .q(diff_reg));

register_compression #(.N(1)) register_max_reach_index_valid_0_U(.d(max_reach_index_valid_0), .clk(clk), .q(max_reach_index_valid_0_reg));

register_compression #(.N(8)) register_len_raw_max_reach_index_U(.d(len_raw_max_reach_index), .clk(clk), .q(len_raw_max_reach_index_reg));
register_compression #(.N(16)) register_dist_raw_max_reach_index_U(.d(dist_raw_max_reach_index), .clk(clk), .q(dist_raw_max_reach_index_reg));
register_compression #(.N(5)) register_reach_max_reach_index_U(.d(reach_max_reach_index), .clk(clk), .q(reach_max_reach_index_reg));

register_compression #(.N(5)) register_reach_0_s3_U(.d(reg_reach_0_s2), .clk(clk), .q(reg_reach_0_s3));
register_compression #(.N(5)) register_reach_1_s3_U(.d(reg_reach_1_s2), .clk(clk), .q(reg_reach_1_s3));
register_compression #(.N(5)) register_reach_2_s3_U(.d(reg_reach_2_s2), .clk(clk), .q(reg_reach_2_s3));
register_compression #(.N(5)) register_reach_3_s3_U(.d(reg_reach_3_s2), .clk(clk), .q(reg_reach_3_s3));
register_compression #(.N(5)) register_reach_4_s3_U(.d(reg_reach_4_s2), .clk(clk), .q(reg_reach_4_s3));
register_compression #(.N(5)) register_reach_5_s3_U(.d(reg_reach_5_s2), .clk(clk), .q(reg_reach_5_s3));
register_compression #(.N(5)) register_reach_6_s3_U(.d(reg_reach_6_s2), .clk(clk), .q(reg_reach_6_s3));
register_compression #(.N(5)) register_reach_7_s3_U(.d(reg_reach_7_s2), .clk(clk), .q(reg_reach_7_s3));
register_compression #(.N(5)) register_reach_8_s3_U(.d(reg_reach_8_s2), .clk(clk), .q(reg_reach_8_s3));
register_compression #(.N(5)) register_reach_9_s3_U(.d(reg_reach_9_s2), .clk(clk), .q(reg_reach_9_s3));
register_compression #(.N(5)) register_reach_10_s3_U(.d(reg_reach_10_s2), .clk(clk), .q(reg_reach_10_s3));
register_compression #(.N(5)) register_reach_11_s3_U(.d(reg_reach_11_s2), .clk(clk), .q(reg_reach_11_s3));
register_compression #(.N(5)) register_reach_12_s3_U(.d(reg_reach_12_s2), .clk(clk), .q(reg_reach_12_s3));
register_compression #(.N(5)) register_reach_13_s3_U(.d(reg_reach_13_s2), .clk(clk), .q(reg_reach_13_s3));
register_compression #(.N(5)) register_reach_14_s3_U(.d(reg_reach_14_s2), .clk(clk), .q(reg_reach_14_s3));
register_compression #(.N(5)) register_reach_15_s3_U(.d(reg_reach_15_s2), .clk(clk), .q(reg_reach_15_s3));

register_compression #(.N(128)) register_literals_s3_U(.d(literals_s2_reg), .clk(clk), .q(literals_s3_reg));
register_compression #(.N(128)) register_len_raw_s3_U(.d(len_raw_s2_reg), .clk(clk), .q(len_raw_s3_reg));
register_compression #(.N(256)) register_dist_raw_s3_U(.d(dist_raw_s2_reg), .clk(clk), .q(dist_raw_s3_reg));
register_compression #(.N(16)) register_valid_raw_s3_U(.d(valid_raw_s2_reg), .clk(clk), .q(valid_raw_s3_reg));

register_compression #(.N(1)) register_en_s3_U(.d(en_s2_reg), .clk(clk), .q(en_s3_reg));
register_compression #(.N(1)) register_start_s3_U(.d(start_s2_reg), .clk(clk), .q(start_s3_reg));
register_compression #(.N(1)) register_last_s3_U(.d(last_s2_reg), .clk(clk), .q(last_s3_reg));


// ====================================================================
//
//  Stage 4: Tail match trimming #2
//
// ====================================================================

// stage 4 ports definition
// 
wire 	[4:0]		max_reach_index_final;

wire 	[7:0]		len_raw_new_max_reach_index;


reg 	[127:0]		len_raw_modified;
reg 	[255:0]		dist_raw_modified;
reg 	[79:0] 		reach_modified;

wire	[127:0]		larray_s4;
wire	[255:0] 	darray_s4;
wire	[79:0]		reach_s4;

wire	[4:0]		old_head_match_pos_s4_reg;
wire	[4:0]		max_reach_index_s4_reg;

wire	[127:0]		literals_s4_reg;
wire	[127:0]		larray_s4_reg;
wire	[255:0]		darray_s4_reg;
wire	[79:0]		reach_s4_reg;

wire 	[15:0]		valid_raw_s4_reg;

wire 				en_s4_reg;
wire 				start_s4_reg;
wire 				last_s4_reg;

// stage 4
assign max_reach_index_final = ((~max_reach_index_larger_reg) && (~max_reach_index_valid_0_reg))?old_head_match_pos_s3_reg:max_reach_index_temp_s3_reg;

adder_8bits adder_8bits_len_raw_alt_U(		
	.a(len_raw_max_reach_index_reg),
	.b({3'b111, ~diff_reg}),
	.ci(1'b1),
	.s(len_raw_new_max_reach_index),
	.co() 
);

always @(*)
	begin
		if((~max_reach_index_larger_reg) && (~max_reach_index_valid_0_reg))
		begin
			case(old_head_match_pos_s3_reg)
				5'd0:	begin
							len_raw_modified <= {len_raw_new_max_reach_index, len_raw_s3_reg[119:0]};
							dist_raw_modified <= {dist_raw_max_reach_index_reg, dist_raw_s3_reg[239:0]};
							reach_modified <= {reach_max_reach_index_reg, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
							      			   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd1:	begin
							len_raw_modified <= {len_raw_s3_reg[127:120], len_raw_new_max_reach_index, len_raw_s3_reg[111:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:240], dist_raw_max_reach_index_reg, dist_raw_s3_reg[223:0]};
							reach_modified <= {reg_reach_0_s3, reach_max_reach_index_reg, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd2: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:112], len_raw_new_max_reach_index, len_raw_s3_reg[103:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:224], dist_raw_max_reach_index_reg, dist_raw_s3_reg[207:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reach_max_reach_index_reg, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd3: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:104], len_raw_new_max_reach_index, len_raw_s3_reg[95:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:208], dist_raw_max_reach_index_reg, dist_raw_s3_reg[191:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reach_max_reach_index_reg, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd4: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:96], len_raw_new_max_reach_index, len_raw_s3_reg[87:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:192], dist_raw_max_reach_index_reg, dist_raw_s3_reg[175:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reach_max_reach_index_reg, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd5: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:88], len_raw_new_max_reach_index, len_raw_s3_reg[79:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:176], dist_raw_max_reach_index_reg, dist_raw_s3_reg[159:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reach_max_reach_index_reg, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd6: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:80], len_raw_new_max_reach_index, len_raw_s3_reg[71:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:160], dist_raw_max_reach_index_reg, dist_raw_s3_reg[143:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reach_max_reach_index_reg, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd7: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:72], len_raw_new_max_reach_index, len_raw_s3_reg[63:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:144], dist_raw_max_reach_index_reg, dist_raw_s3_reg[127:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reach_max_reach_index_reg,
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3}; 
							end

				5'd8:	begin
							len_raw_modified <= {len_raw_s3_reg[127:64], len_raw_new_max_reach_index, len_raw_s3_reg[55:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:128], dist_raw_max_reach_index_reg, dist_raw_s3_reg[111:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reach_max_reach_index_reg, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd9:	begin
							len_raw_modified <= {len_raw_s3_reg[127:56], len_raw_new_max_reach_index, len_raw_s3_reg[47:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:112], dist_raw_max_reach_index_reg, dist_raw_s3_reg[95:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reach_max_reach_index_reg, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd10: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:48], len_raw_new_max_reach_index, len_raw_s3_reg[39:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:96], dist_raw_max_reach_index_reg, dist_raw_s3_reg[79:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reach_max_reach_index_reg, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd11: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:40], len_raw_new_max_reach_index, len_raw_s3_reg[31:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:80], dist_raw_max_reach_index_reg, dist_raw_s3_reg[63:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reach_max_reach_index_reg, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd12: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:32], len_raw_new_max_reach_index, len_raw_s3_reg[23:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:64], dist_raw_max_reach_index_reg, dist_raw_s3_reg[47:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reach_max_reach_index_reg, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd13: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:24], len_raw_new_max_reach_index, len_raw_s3_reg[15:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:48], dist_raw_max_reach_index_reg, dist_raw_s3_reg[31:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reach_max_reach_index_reg, reg_reach_14_s3, reg_reach_15_s3};
							end

				5'd14: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:16], len_raw_new_max_reach_index, len_raw_s3_reg[7:0]};
							dist_raw_modified <= {dist_raw_s3_reg[255:32], dist_raw_max_reach_index_reg, dist_raw_s3_reg[15:0]};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reach_max_reach_index_reg, reg_reach_15_s3};
							end

				5'd15: 	begin
							len_raw_modified <= {len_raw_s3_reg[127:8], len_raw_new_max_reach_index};
							dist_raw_modified <= {dist_raw_s3_reg[255:16], dist_raw_max_reach_index_reg};
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reach_max_reach_index_reg};
							end

				default: 	begin
							len_raw_modified <= len_raw_s3_reg;
							dist_raw_modified <= dist_raw_s3_reg;
							reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
											   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
							end
			endcase
		end
		else
		begin
			len_raw_modified <= len_raw_s3_reg;
			dist_raw_modified <= dist_raw_s3_reg;
			reach_modified <= {reg_reach_0_s3, reg_reach_1_s3, reg_reach_2_s3, reg_reach_3_s3, reg_reach_4_s3, reg_reach_5_s3, reg_reach_6_s3, reg_reach_7_s3, 
							   reg_reach_8_s3, reg_reach_9_s3, reg_reach_10_s3, reg_reach_11_s3, reg_reach_12_s3, reg_reach_13_s3, reg_reach_14_s3, reg_reach_15_s3};
		end
	end

assign larray_s4 = len_raw_modified;
assign darray_s4 = dist_raw_modified;
assign reach_s4 = reach_modified;

// 
register_compression #(.N(5)) 	register_old_head_match_pos_s4_U(.d(old_head_match_pos_s3_reg), .clk(clk), .q(old_head_match_pos_s4_reg));
register_compression #(.N(5)) 	register_max_reach_index_s4_U(.d(max_reach_index_final), .clk(clk), .q(max_reach_index_s4_reg));

register_compression #(.N(80)) 	register_reach_s4_U(.d(reach_s4), .clk(clk), .q(reach_s4_reg));

register_compression #(.N(128)) register_literals_s4_U(.d(literals_s3_reg), .clk(clk), .q(literals_s4_reg));
register_compression #(.N(128)) register_len_raw_s4_U(.d(larray_s4), .clk(clk), .q(larray_s4_reg));
register_compression #(.N(256)) register_dist_raw_s4_U(.d(darray_s4), .clk(clk), .q(darray_s4_reg));
register_compression #(.N(16)) 	register_valid_raw_s4_U(.d(valid_raw_s3_reg), .clk(clk), .q(valid_raw_s4_reg));

register_compression #(.N(1)) register_en_s4_U(.d(en_s3_reg), .clk(clk), .q(en_s4_reg));
register_compression #(.N(1)) register_start_s4_U(.d(start_s3_reg), .clk(clk), .q(start_s4_reg));
register_compression #(.N(1)) register_last_s4_U(.d(last_s3_reg), .clk(clk), .q(last_s4_reg));


// ====================================================================
//
//  Stage 5: set bits between tail and head to be 0 #1
//
// ====================================================================

// stage 5 ports definition
// old_head_match_pos_lsequ_k = 1 means old_head_match_pos <= k
wire				old_head_match_pos_lsequ_0;	
wire				old_head_match_pos_lsequ_1;
wire				old_head_match_pos_lsequ_2;
wire				old_head_match_pos_lsequ_3;
wire				old_head_match_pos_lsequ_4;
wire				old_head_match_pos_lsequ_5;
wire				old_head_match_pos_lsequ_6;
wire				old_head_match_pos_lsequ_7;
wire				old_head_match_pos_lsequ_8;
wire				old_head_match_pos_lsequ_9;
wire				old_head_match_pos_lsequ_10;
wire				old_head_match_pos_lsequ_11;
wire				old_head_match_pos_lsequ_12;
wire				old_head_match_pos_lsequ_13;
wire				old_head_match_pos_lsequ_14;
wire				old_head_match_pos_lsequ_15;

// max_reach_index_lgequ_k = 1 means max_reach_index >= k
wire				max_reach_index_lgequ_0;
wire				max_reach_index_lgequ_1;
wire				max_reach_index_lgequ_2;
wire				max_reach_index_lgequ_3;
wire				max_reach_index_lgequ_4;
wire				max_reach_index_lgequ_5;
wire				max_reach_index_lgequ_6;
wire				max_reach_index_lgequ_7;
wire				max_reach_index_lgequ_8;
wire				max_reach_index_lgequ_9;
wire				max_reach_index_lgequ_10;
wire				max_reach_index_lgequ_11;
wire				max_reach_index_lgequ_12;
wire				max_reach_index_lgequ_13;
wire				max_reach_index_lgequ_14;
wire				max_reach_index_lgequ_15;

// ldvalid is set if the corresponding byte is 
// in between tail of previous window and head
// of current window
wire				ldvalid_0;
wire 				ldvalid_1;
wire				ldvalid_2;
wire				ldvalid_3;
wire 				ldvalid_4;
wire				ldvalid_5;
wire				ldvalid_6;
wire				ldvalid_7;
wire				ldvalid_8;
wire 				ldvalid_9;
wire				ldvalid_10;
wire				ldvalid_11;
wire 				ldvalid_12;
wire				ldvalid_13;
wire				ldvalid_14;
wire				ldvalid_15;
wire	[15:0]		ldvalid;

// reach_k_lsequ_max_reach_index = 1 means reach[k] <= max_reach_index
wire				reach_0_lsequ_max_reach_index;	
wire				reach_1_lsequ_max_reach_index;
wire				reach_2_lsequ_max_reach_index;
wire				reach_3_lsequ_max_reach_index;
wire				reach_4_lsequ_max_reach_index;
wire				reach_5_lsequ_max_reach_index;
wire				reach_6_lsequ_max_reach_index;
wire				reach_7_lsequ_max_reach_index;
wire				reach_8_lsequ_max_reach_index;	
wire				reach_9_lsequ_max_reach_index;
wire				reach_10_lsequ_max_reach_index;
wire				reach_11_lsequ_max_reach_index;
wire				reach_12_lsequ_max_reach_index;
wire				reach_13_lsequ_max_reach_index;
wire				reach_14_lsequ_max_reach_index;
wire				reach_15_lsequ_max_reach_index;

wire				reach_0_lsequ_max_reach_index_reg;
wire				reach_1_lsequ_max_reach_index_reg;
wire				reach_2_lsequ_max_reach_index_reg;
wire				reach_3_lsequ_max_reach_index_reg;
wire				reach_4_lsequ_max_reach_index_reg;
wire				reach_5_lsequ_max_reach_index_reg;
wire				reach_6_lsequ_max_reach_index_reg;
wire				reach_7_lsequ_max_reach_index_reg;
wire				reach_8_lsequ_max_reach_index_reg;
wire				reach_9_lsequ_max_reach_index_reg;
wire				reach_10_lsequ_max_reach_index_reg;
wire				reach_11_lsequ_max_reach_index_reg;
wire				reach_12_lsequ_max_reach_index_reg;
wire				reach_13_lsequ_max_reach_index_reg;
wire				reach_14_lsequ_max_reach_index_reg;
wire				reach_15_lsequ_max_reach_index_reg;

// calculate the difference between max_reach_index & reach[k]
wire	[4:0]		max_reach_index_minus_reach_0;
wire	[4:0]		max_reach_index_minus_reach_1;
wire	[4:0]		max_reach_index_minus_reach_2;
wire	[4:0]		max_reach_index_minus_reach_3;
wire	[4:0]		max_reach_index_minus_reach_4;
wire	[4:0]		max_reach_index_minus_reach_5;
wire	[4:0]		max_reach_index_minus_reach_6;
wire	[4:0]		max_reach_index_minus_reach_7;
wire	[4:0]		max_reach_index_minus_reach_8;
wire	[4:0]		max_reach_index_minus_reach_9;
wire	[4:0]		max_reach_index_minus_reach_10;
wire	[4:0]		max_reach_index_minus_reach_11;
wire	[4:0]		max_reach_index_minus_reach_12;
wire	[4:0]		max_reach_index_minus_reach_13;
wire	[4:0]		max_reach_index_minus_reach_14;
wire	[4:0]		max_reach_index_minus_reach_15;

wire	[4:0]		max_reach_index_minus_reach_0_reg;
wire	[4:0]		max_reach_index_minus_reach_1_reg;
wire	[4:0]		max_reach_index_minus_reach_2_reg;
wire	[4:0]		max_reach_index_minus_reach_3_reg;
wire	[4:0]		max_reach_index_minus_reach_4_reg;
wire	[4:0]		max_reach_index_minus_reach_5_reg;
wire	[4:0]		max_reach_index_minus_reach_6_reg;
wire	[4:0]		max_reach_index_minus_reach_7_reg;
wire	[4:0]		max_reach_index_minus_reach_8_reg;
wire	[4:0]		max_reach_index_minus_reach_9_reg;
wire	[4:0]		max_reach_index_minus_reach_10_reg;
wire	[4:0]		max_reach_index_minus_reach_11_reg;
wire	[4:0]		max_reach_index_minus_reach_12_reg;
wire	[4:0]		max_reach_index_minus_reach_13_reg;
wire	[4:0]		max_reach_index_minus_reach_14_reg;
wire	[4:0]		max_reach_index_minus_reach_15_reg;

// 
wire	[4:0]		larray_0_plus_3;
wire	[4:0]		larray_0_plus_3_s5_reg;

// 
wire	[4:0]		old_head_match_pos_s5_reg;

// 
wire	[15:0]		ldvalid_s5_reg;

//
wire	[4:0]		max_reach_index_s5_reg;

//
wire	[127:0]		larray_s5_reg;
wire	[255:0]		darray_s5_reg;

// 
wire	[127:0]		literals_s5_reg;
wire	[15:0]		valid_raw_s5_reg;

//
wire 				en_s5_reg;
wire 				start_s5_reg;
wire 				last_s5_reg;

// stage 5
//judge if k >= old_head_match_pos
adder_5bits adder_5bits_old_head_match_pos_lsequ_0_U(
	.a(5'd0),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_0) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_1_U(
	.a(5'd1),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_1) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_2_U(
	.a(5'd2),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_2) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_3_U(
	.a(5'd3),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_3) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_4_U(
	.a(5'd4),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_4) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_5_U(
	.a(5'd5),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_5) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_6_U(
	.a(5'd6),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_6) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_7_U(
	.a(5'd7),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_7) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_8_U(
	.a(5'd8),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_8) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_9_U(
	.a(5'd9),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_9) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_10_U(
	.a(5'd10),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_10) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_11_U(
	.a(5'd11),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_11) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_12_U(
	.a(5'd12),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_12) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_13_U(
	.a(5'd13),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_13) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_14_U(
	.a(5'd14),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_14) 
);

adder_5bits adder_5bits_old_head_match_pos_lsequ_15_U(
	.a(5'd15),
	.b(~old_head_match_pos_s4_reg),
	.ci(1'b1),
	.s(),
	.co(old_head_match_pos_lsequ_15) 
);

// 
//judge if k <= max_reach_index
adder_5bits adder_5bits_max_reach_index_lgequ_0_U(
	.a(max_reach_index_s4_reg),
	.b(5'b11111),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_0) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_1_U(
	.a(max_reach_index_s4_reg),
	.b(5'b11110),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_1) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_2_U(
	.a(max_reach_index_s4_reg),
	.b(5'b11101),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_2) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_3_U(
	.a(max_reach_index_s4_reg),
	.b(5'b11100),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_3) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_4_U(
	.a(max_reach_index_s4_reg),
	.b(5'b11011),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_4) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_5_U(
	.a(max_reach_index_s4_reg),
	.b(5'b11010),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_5) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_6_U(
	.a(max_reach_index_s4_reg),
	.b(5'b11001),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_6) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_7_U(
	.a(max_reach_index_s4_reg),
	.b(5'b11000),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_7) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_8_U(
	.a(max_reach_index_s4_reg),
	.b(5'b10111),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_8) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_9_U(
	.a(max_reach_index_s4_reg),
	.b(5'b10110),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_9) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_10_U(
	.a(max_reach_index_s4_reg),
	.b(5'b10101),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_10) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_11_U(
	.a(max_reach_index_s4_reg),
	.b(5'b10100),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_11) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_12_U(
	.a(max_reach_index_s4_reg),
	.b(5'b10011),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_12) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_13_U(
	.a(max_reach_index_s4_reg),
	.b(5'b10010),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_13) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_14_U(
	.a(max_reach_index_s4_reg),
	.b(5'b10001),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_14) 
);

adder_5bits adder_5bits_max_reach_index_lgequ_15_U(
	.a(max_reach_index_s4_reg),
	.b(5'b10000),
	.ci(1'b1),
	.s(),
	.co(max_reach_index_lgequ_15) 
);

// 
assign ldvalid_0 = (old_head_match_pos_lsequ_0 && max_reach_index_lgequ_0)?1'b1:1'b0;
assign ldvalid_1 = (old_head_match_pos_lsequ_1 && max_reach_index_lgequ_1)?1'b1:1'b0;
assign ldvalid_2 = (old_head_match_pos_lsequ_2 && max_reach_index_lgequ_2)?1'b1:1'b0;
assign ldvalid_3 = (old_head_match_pos_lsequ_3 && max_reach_index_lgequ_3)?1'b1:1'b0;
assign ldvalid_4 = (old_head_match_pos_lsequ_4 && max_reach_index_lgequ_4)?1'b1:1'b0;
assign ldvalid_5 = (old_head_match_pos_lsequ_5 && max_reach_index_lgequ_5)?1'b1:1'b0;
assign ldvalid_6 = (old_head_match_pos_lsequ_6 && max_reach_index_lgequ_6)?1'b1:1'b0;
assign ldvalid_7 = (old_head_match_pos_lsequ_7 && max_reach_index_lgequ_7)?1'b1:1'b0;
assign ldvalid_8 = (old_head_match_pos_lsequ_8 && max_reach_index_lgequ_8)?1'b1:1'b0;
assign ldvalid_9 = (old_head_match_pos_lsequ_9 && max_reach_index_lgequ_9)?1'b1:1'b0;
assign ldvalid_10 = (old_head_match_pos_lsequ_10 && max_reach_index_lgequ_10)?1'b1:1'b0;
assign ldvalid_11 = (old_head_match_pos_lsequ_11 && max_reach_index_lgequ_11)?1'b1:1'b0;
assign ldvalid_12 = (old_head_match_pos_lsequ_12 && max_reach_index_lgequ_12)?1'b1:1'b0;
assign ldvalid_13 = (old_head_match_pos_lsequ_13 && max_reach_index_lgequ_13)?1'b1:1'b0;
assign ldvalid_14 = (old_head_match_pos_lsequ_14 && max_reach_index_lgequ_14)?1'b1:1'b0;
assign ldvalid_15 = (old_head_match_pos_lsequ_15 && max_reach_index_lgequ_15)?1'b1:1'b0;

assign ldvalid = {ldvalid_0, ldvalid_1, ldvalid_2, ldvalid_3, ldvalid_4, ldvalid_5, ldvalid_6, ldvalid_7, 
				  ldvalid_8, ldvalid_9, ldvalid_10, ldvalid_11, ldvalid_12, ldvalid_13, ldvalid_14, ldvalid_15};

// 
adder_5bits adder_5bits_reach_0_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[79:75]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_0),
	.co(reach_0_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_1_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[74:70]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_1),
	.co(reach_1_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_2_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[69:65]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_2),
	.co(reach_2_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_3_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[64:60]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_3),
	.co(reach_3_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_4_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[59:55]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_4),
	.co(reach_4_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_5_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[54:50]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_5),
	.co(reach_5_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_6_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[49:45]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_6),
	.co(reach_6_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_7_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[44:40]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_7),
	.co(reach_7_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_8_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[39:35]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_8),
	.co(reach_8_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_9_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[34:30]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_9),
	.co(reach_9_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_10_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[29:25]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_10),
	.co(reach_10_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_11_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[24:20]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_11),
	.co(reach_11_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_12_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[19:15]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_12),
	.co(reach_12_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_13_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[14:10]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_13),
	.co(reach_13_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_14_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[9:5]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_14),
	.co(reach_14_lsequ_max_reach_index) 
);

adder_5bits adder_5bits_reach_15_lsequ_max_reach_index_U(
	.a(max_reach_index_s4_reg),
	.b(~reach_s4_reg[4:0]),
	.ci(1'b1),
	.s(max_reach_index_minus_reach_15),
	.co(reach_15_lsequ_max_reach_index) 
);
 
//calculate the original larray[0] + 3
assign larray_0_plus_3 = larray_s4_reg[124:120] + 5'd3;

// 
register_compression #(.N(5)) register_larray_0_plus_3_s5_U(.d(larray_0_plus_3), .clk(clk), .q(larray_0_plus_3_s5_reg));

register_compression #(.N(5)) register_old_head_match_pos_s5_U(.d(old_head_match_pos_s4_reg), .clk(clk), .q(old_head_match_pos_s5_reg));

register_compression #(.N(16)) register_ldvalid_s5_U(.d(ldvalid), .clk(clk), .q(ldvalid_s5_reg));

register_compression #(.N(5)) register_max_reach_index_s5_U(.d(max_reach_index_s4_reg), .clk(clk), .q(max_reach_index_s5_reg));

register_compression #(.N(1)) register_reach_0_lsequ_max_reach_index_U(.d(reach_0_lsequ_max_reach_index), .clk(clk), .q(reach_0_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_1_lsequ_max_reach_index_U(.d(reach_1_lsequ_max_reach_index), .clk(clk), .q(reach_1_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_2_lsequ_max_reach_index_U(.d(reach_2_lsequ_max_reach_index), .clk(clk), .q(reach_2_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_3_lsequ_max_reach_index_U(.d(reach_3_lsequ_max_reach_index), .clk(clk), .q(reach_3_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_4_lsequ_max_reach_index_U(.d(reach_4_lsequ_max_reach_index), .clk(clk), .q(reach_4_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_5_lsequ_max_reach_index_U(.d(reach_5_lsequ_max_reach_index), .clk(clk), .q(reach_5_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_6_lsequ_max_reach_index_U(.d(reach_6_lsequ_max_reach_index), .clk(clk), .q(reach_6_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_7_lsequ_max_reach_index_U(.d(reach_7_lsequ_max_reach_index), .clk(clk), .q(reach_7_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_8_lsequ_max_reach_index_U(.d(reach_8_lsequ_max_reach_index), .clk(clk), .q(reach_8_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_9_lsequ_max_reach_index_U(.d(reach_9_lsequ_max_reach_index), .clk(clk), .q(reach_9_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_10_lsequ_max_reach_index_U(.d(reach_10_lsequ_max_reach_index), .clk(clk), .q(reach_10_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_11_lsequ_max_reach_index_U(.d(reach_11_lsequ_max_reach_index), .clk(clk), .q(reach_11_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_12_lsequ_max_reach_index_U(.d(reach_12_lsequ_max_reach_index), .clk(clk), .q(reach_12_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_13_lsequ_max_reach_index_U(.d(reach_13_lsequ_max_reach_index), .clk(clk), .q(reach_13_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_14_lsequ_max_reach_index_U(.d(reach_14_lsequ_max_reach_index), .clk(clk), .q(reach_14_lsequ_max_reach_index_reg));
register_compression #(.N(1)) register_reach_15_lsequ_max_reach_index_U(.d(reach_15_lsequ_max_reach_index), .clk(clk), .q(reach_15_lsequ_max_reach_index_reg));

register_compression #(.N(5)) register_max_reach_index_minus_reach_0_U(.d(max_reach_index_minus_reach_0), .clk(clk), .q(max_reach_index_minus_reach_0_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_1_U(.d(max_reach_index_minus_reach_1), .clk(clk), .q(max_reach_index_minus_reach_1_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_2_U(.d(max_reach_index_minus_reach_2), .clk(clk), .q(max_reach_index_minus_reach_2_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_3_U(.d(max_reach_index_minus_reach_3), .clk(clk), .q(max_reach_index_minus_reach_3_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_4_U(.d(max_reach_index_minus_reach_4), .clk(clk), .q(max_reach_index_minus_reach_4_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_5_U(.d(max_reach_index_minus_reach_5), .clk(clk), .q(max_reach_index_minus_reach_5_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_6_U(.d(max_reach_index_minus_reach_6), .clk(clk), .q(max_reach_index_minus_reach_6_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_7_U(.d(max_reach_index_minus_reach_7), .clk(clk), .q(max_reach_index_minus_reach_7_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_8_U(.d(max_reach_index_minus_reach_8), .clk(clk), .q(max_reach_index_minus_reach_8_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_9_U(.d(max_reach_index_minus_reach_9), .clk(clk), .q(max_reach_index_minus_reach_9_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_10_U(.d(max_reach_index_minus_reach_10), .clk(clk), .q(max_reach_index_minus_reach_10_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_11_U(.d(max_reach_index_minus_reach_11), .clk(clk), .q(max_reach_index_minus_reach_11_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_12_U(.d(max_reach_index_minus_reach_12), .clk(clk), .q(max_reach_index_minus_reach_12_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_13_U(.d(max_reach_index_minus_reach_13), .clk(clk), .q(max_reach_index_minus_reach_13_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_14_U(.d(max_reach_index_minus_reach_14), .clk(clk), .q(max_reach_index_minus_reach_14_reg));
register_compression #(.N(5)) register_max_reach_index_minus_reach_15_U(.d(max_reach_index_minus_reach_15), .clk(clk), .q(max_reach_index_minus_reach_15_reg));

register_compression #(.N(128)) register_larray_s5_U(.d(larray_s4_reg), .clk(clk), .q(larray_s5_reg));
register_compression #(.N(256)) register_darray_s5_U(.d(darray_s4_reg), .clk(clk), .q(darray_s5_reg));

register_compression #(.N(128)) register_literals_s5_U(.d(literals_s4_reg), .clk(clk), .q(literals_s5_reg));
register_compression #(.N(16)) register_valid_raw_s5_U(.d(valid_raw_s4_reg), .clk(clk), .q(valid_raw_s5_reg));

register_compression #(.N(1)) register_en_s5_U(.d(en_s4_reg), .clk(clk), .q(en_s5_reg));
register_compression #(.N(1)) register_start_s5_U(.d(start_s4_reg), .clk(clk), .q(start_s5_reg));
register_compression #(.N(1)) register_last_s5_U(.d(last_s4_reg), .clk(clk), .q(last_s5_reg));


// ====================================================================
//
//  Stage 6: set bits between tail and head to be 0 #2
//
// ====================================================================

// stage 6 ports definition
// max_reach_index_neq_0 = 1 means max_reach_index != k
wire			max_reach_index_neq_0;
wire			max_reach_index_neq_1;
wire			max_reach_index_neq_2;
wire			max_reach_index_neq_3;
wire			max_reach_index_neq_4;
wire			max_reach_index_neq_5;
wire			max_reach_index_neq_6;
wire			max_reach_index_neq_7;
wire			max_reach_index_neq_8;	
wire			max_reach_index_neq_9;
wire			max_reach_index_neq_10;
wire			max_reach_index_neq_11;
wire			max_reach_index_neq_12;
wire			max_reach_index_neq_13;
wire			max_reach_index_neq_14;
wire			max_reach_index_neq_15;

wire	[15:0]	max_reach_index_neq_k_s6;
wire	[15:0] 	max_reach_index_neq_k_s6_reg;

// trimmed_len_ls_k = 0 means trimmed_len_k < 3
wire			trimmed_len_ls_0;
wire			trimmed_len_ls_1;
wire			trimmed_len_ls_2;
wire			trimmed_len_ls_3;
wire			trimmed_len_ls_4;
wire			trimmed_len_ls_5;
wire			trimmed_len_ls_6;
wire			trimmed_len_ls_7;
wire			trimmed_len_ls_8;	
wire			trimmed_len_ls_9;
wire			trimmed_len_ls_10;
wire			trimmed_len_ls_11;
wire			trimmed_len_ls_12;
wire			trimmed_len_ls_13;
wire			trimmed_len_ls_14;
wire			trimmed_len_ls_15;

//
wire	[4:0] 	trimmed_len_0_plus_3;

// here trimmed_len is trimmed_len - 3
wire	[4:0]	trimmed_len_0;
wire	[4:0]	trimmed_len_1;
wire	[4:0]	trimmed_len_2;
wire	[4:0]	trimmed_len_3;
wire	[4:0]	trimmed_len_4;
wire	[4:0]	trimmed_len_5;
wire	[4:0]	trimmed_len_6;
wire	[4:0]	trimmed_len_7;
wire	[4:0]	trimmed_len_8;	
wire	[4:0]	trimmed_len_9;
wire	[4:0]	trimmed_len_10;
wire	[4:0]	trimmed_len_11;
wire	[4:0]	trimmed_len_12;
wire	[4:0]	trimmed_len_13;
wire	[4:0]	trimmed_len_14;
wire	[4:0]	trimmed_len_15;

// 
wire			valid_comp_0_p1;
wire			valid_comp_1_p1;
wire			valid_comp_2_p1;
wire			valid_comp_3_p1;
wire			valid_comp_4_p1;
wire			valid_comp_5_p1;
wire			valid_comp_6_p1;
wire			valid_comp_7_p1;
wire			valid_comp_8_p1;
wire			valid_comp_9_p1;
wire			valid_comp_10_p1;
wire			valid_comp_11_p1;
wire			valid_comp_12_p1;
wire			valid_comp_13_p1;
wire			valid_comp_14_p1;
wire			valid_comp_15_p1;

//
wire			dist_valid_0_s6;
wire			dist_valid_1_s6;
wire			dist_valid_2_s6;
wire			dist_valid_3_s6;
wire			dist_valid_4_s6;
wire			dist_valid_5_s6;
wire			dist_valid_6_s6;
wire			dist_valid_7_s6;
wire			dist_valid_8_s6;
wire			dist_valid_9_s6;
wire			dist_valid_10_s6;
wire			dist_valid_11_s6;
wire			dist_valid_12_s6;
wire			dist_valid_13_s6;
wire			dist_valid_14_s6;
wire			dist_valid_15_s6;

wire 	[15:0]	dist_valid_s6; 
wire 	[15:0]	dist_valid_s6_reg; 

// 
wire	[7:0]   larray_0_plus_3_p1;
wire	[7:0]   larray_0_plus_3_p1_reg;

// 
wire	[7:0]	larray_0_p1;
wire	[7:0]	larray_1_p1;
wire	[7:0]	larray_2_p1;
wire	[7:0]	larray_3_p1;
wire	[7:0]	larray_4_p1;
wire	[7:0]	larray_5_p1;
wire	[7:0]	larray_6_p1;
wire	[7:0]	larray_7_p1;
wire	[7:0]	larray_8_p1;
wire	[7:0]	larray_9_p1;
wire	[7:0]	larray_10_p1;
wire	[7:0]	larray_11_p1;
wire	[7:0]	larray_12_p1;
wire	[7:0]	larray_13_p1;
wire	[7:0]	larray_14_p1;
wire	[7:0]	larray_15_p1;

wire	[7:0]	larray_0_p1_reg;
wire	[7:0]	larray_1_p1_reg;
wire	[7:0]	larray_2_p1_reg;
wire	[7:0]	larray_3_p1_reg;
wire	[7:0]	larray_4_p1_reg;
wire	[7:0]	larray_5_p1_reg;
wire	[7:0]	larray_6_p1_reg;
wire	[7:0]	larray_7_p1_reg;
wire	[7:0]	larray_8_p1_reg;
wire	[7:0]	larray_9_p1_reg;
wire	[7:0]	larray_10_p1_reg;
wire	[7:0]	larray_11_p1_reg;
wire	[7:0]	larray_12_p1_reg;
wire	[7:0]	larray_13_p1_reg;
wire	[7:0]	larray_14_p1_reg;
wire	[7:0]	larray_15_p1_reg;

// 
wire	[15:0]	darray_0_p1;
wire	[15:0]	darray_1_p1;
wire	[15:0]	darray_2_p1;
wire	[15:0]	darray_3_p1;
wire	[15:0]	darray_4_p1;
wire	[15:0]	darray_5_p1;
wire	[15:0]	darray_6_p1;
wire	[15:0]	darray_7_p1;
wire	[15:0]	darray_8_p1;
wire	[15:0]	darray_9_p1;
wire	[15:0]	darray_10_p1;
wire	[15:0]	darray_11_p1;
wire	[15:0]	darray_12_p1;
wire	[15:0]	darray_13_p1;
wire	[15:0]	darray_14_p1;
wire	[15:0]	darray_15_p1;

wire	[15:0]	darray_0_p1_reg;
wire	[15:0]	darray_1_p1_reg;
wire	[15:0]	darray_2_p1_reg;
wire	[15:0]	darray_3_p1_reg;
wire	[15:0]	darray_4_p1_reg;
wire	[15:0]	darray_5_p1_reg;
wire	[15:0]	darray_6_p1_reg;
wire	[15:0]	darray_7_p1_reg;
wire	[15:0]	darray_8_p1_reg;
wire	[15:0]	darray_9_p1_reg;
wire	[15:0]	darray_10_p1_reg;
wire	[15:0]	darray_11_p1_reg;
wire	[15:0]	darray_12_p1_reg;
wire	[15:0]	darray_13_p1_reg;
wire	[15:0]	darray_14_p1_reg;
wire	[15:0]	darray_15_p1_reg;

// 
wire 	[4:0]	old_head_match_pos_s6_reg;

//
wire	[15:0]	ldvalid_s6_reg;

//
wire	[127:0]  literals_s6_reg;

// 
wire 				en_s6_reg;
wire 				start_s6_reg;
wire 				last_s6_reg;

// stage 6
adder_5bits adder_5bits_trimmed_len_0_U(
	.a(larray_s5_reg[124:120]),
	.b(max_reach_index_minus_reach_0_reg),
	.ci(1'b0),
	.s(trimmed_len_0),
	.co(trimmed_len_ls_0) 
);

adder_5bits adder_5bits_trimmed_len_1_U(
	.a(larray_s5_reg[116:112]),
	.b(max_reach_index_minus_reach_1_reg),
	.ci(1'b0),
	.s(trimmed_len_1),
	.co(trimmed_len_ls_1) 
);

adder_5bits adder_5bits_trimmed_len_2_U(
	.a(larray_s5_reg[108:104]),
	.b(max_reach_index_minus_reach_2_reg),
	.ci(1'b0),
	.s(trimmed_len_2),
	.co(trimmed_len_ls_2) 
);

adder_5bits adder_5bits_trimmed_len_3_U(
	.a(larray_s5_reg[100:96]),
	.b(max_reach_index_minus_reach_3_reg),
	.ci(1'b0),
	.s(trimmed_len_3),
	.co(trimmed_len_ls_3) 
);

adder_5bits adder_5bits_trimmed_len_4_U(
	.a(larray_s5_reg[92:88]),
	.b(max_reach_index_minus_reach_4_reg),
	.ci(1'b0),
	.s(trimmed_len_4),
	.co(trimmed_len_ls_4) 
);

adder_5bits adder_5bits_trimmed_len_5_U(
	.a(larray_s5_reg[84:80]),
	.b(max_reach_index_minus_reach_5_reg),
	.ci(1'b0),
	.s(trimmed_len_5),
	.co(trimmed_len_ls_5) 
);

adder_5bits adder_5bits_trimmed_len_6_U(
	.a(larray_s5_reg[76:72]),
	.b(max_reach_index_minus_reach_6_reg),
	.ci(1'b0),
	.s(trimmed_len_6),
	.co(trimmed_len_ls_6) 
);

adder_5bits adder_5bits_trimmed_len_7_U(
	.a(larray_s5_reg[68:64]),
	.b(max_reach_index_minus_reach_7_reg),
	.ci(1'b0),
	.s(trimmed_len_7),
	.co(trimmed_len_ls_7) 
);

adder_5bits adder_5bits_trimmed_len_8_U(
	.a(larray_s5_reg[60:56]),
	.b(max_reach_index_minus_reach_8_reg),
	.ci(1'b0),
	.s(trimmed_len_8),
	.co(trimmed_len_ls_8) 
);

adder_5bits adder_5bits_trimmed_len_9_U(
	.a(larray_s5_reg[52:48]),
	.b(max_reach_index_minus_reach_9_reg),
	.ci(1'b0),
	.s(trimmed_len_9),
	.co(trimmed_len_ls_9) 
);

adder_5bits adder_5bits_trimmed_len_10_U(
	.a(larray_s5_reg[44:40]),
	.b(max_reach_index_minus_reach_10_reg),
	.ci(1'b0),
	.s(trimmed_len_10),
	.co(trimmed_len_ls_10) 
);

adder_5bits adder_5bits_trimmed_len_11_U(
	.a(larray_s5_reg[36:32]),
	.b(max_reach_index_minus_reach_11_reg),
	.ci(1'b0),
	.s(trimmed_len_11),
	.co(trimmed_len_ls_11) 
);

adder_5bits adder_5bits_trimmed_len_12_U(
	.a(larray_s5_reg[28:24]),
	.b(max_reach_index_minus_reach_12_reg),
	.ci(1'b0),
	.s(trimmed_len_12),
	.co(trimmed_len_ls_12) 
);

adder_5bits adder_5bits_trimmed_len_13_U(
	.a(larray_s5_reg[20:16]),
	.b(max_reach_index_minus_reach_13_reg),
	.ci(1'b0),
	.s(trimmed_len_13),
	.co(trimmed_len_ls_13) 
);

adder_5bits adder_5bits_trimmed_len_14_U(
	.a(larray_s5_reg[12:8]),
	.b(max_reach_index_minus_reach_14_reg),
	.ci(1'b0),
	.s(trimmed_len_14),
	.co(trimmed_len_ls_14) 
);

adder_5bits adder_5bits_trimmed_len_15_U(
	.a(larray_s5_reg[4:0]),
	.b(max_reach_index_minus_reach_15_reg),
	.ci(1'b0),
	.s(trimmed_len_15),
	.co(trimmed_len_ls_15) 
);

// 
assign trimmed_len_0_plus_3 = larray_0_plus_3_s5_reg + max_reach_index_minus_reach_0_reg;

// 
assign max_reach_index_neq_0 = (max_reach_index_s5_reg != 5'd0);
assign max_reach_index_neq_1 = (max_reach_index_s5_reg != 5'd1);
assign max_reach_index_neq_2 = (max_reach_index_s5_reg != 5'd2);
assign max_reach_index_neq_3 = (max_reach_index_s5_reg != 5'd3);
assign max_reach_index_neq_4 = (max_reach_index_s5_reg != 5'd4);
assign max_reach_index_neq_5 = (max_reach_index_s5_reg != 5'd5);
assign max_reach_index_neq_6 = (max_reach_index_s5_reg != 5'd6);
assign max_reach_index_neq_7 = (max_reach_index_s5_reg != 5'd7);
assign max_reach_index_neq_8 = (max_reach_index_s5_reg != 5'd8);
assign max_reach_index_neq_9 = (max_reach_index_s5_reg != 5'd9);
assign max_reach_index_neq_10 = (max_reach_index_s5_reg != 5'd10);
assign max_reach_index_neq_11 = (max_reach_index_s5_reg != 5'd11);
assign max_reach_index_neq_12 = (max_reach_index_s5_reg != 5'd12);
assign max_reach_index_neq_13 = (max_reach_index_s5_reg != 5'd13);
assign max_reach_index_neq_14 = (max_reach_index_s5_reg != 5'd14);
assign max_reach_index_neq_15 = (max_reach_index_s5_reg != 5'd15);

assign max_reach_index_neq_k_s6 = {max_reach_index_neq_0, max_reach_index_neq_1, max_reach_index_neq_2, max_reach_index_neq_3, max_reach_index_neq_4, max_reach_index_neq_5, max_reach_index_neq_6, max_reach_index_neq_7, 
								   max_reach_index_neq_8, max_reach_index_neq_9, max_reach_index_neq_10, max_reach_index_neq_11, max_reach_index_neq_12, max_reach_index_neq_13, max_reach_index_neq_14, max_reach_index_neq_15};

// 
assign valid_comp_0_p1 = ldvalid_s5_reg[15] && max_reach_index_neq_0 && valid_raw_s5_reg[15] && (~reach_0_lsequ_max_reach_index_reg);
assign valid_comp_1_p1 = ldvalid_s5_reg[14] && max_reach_index_neq_1 && valid_raw_s5_reg[14] && (~reach_1_lsequ_max_reach_index_reg);
assign valid_comp_2_p1 = ldvalid_s5_reg[13] && max_reach_index_neq_2 && valid_raw_s5_reg[13] && (~reach_2_lsequ_max_reach_index_reg);
assign valid_comp_3_p1 = ldvalid_s5_reg[12] && max_reach_index_neq_3 && valid_raw_s5_reg[12] && (~reach_3_lsequ_max_reach_index_reg);
assign valid_comp_4_p1 = ldvalid_s5_reg[11] && max_reach_index_neq_4 && valid_raw_s5_reg[11] && (~reach_4_lsequ_max_reach_index_reg);
assign valid_comp_5_p1 = ldvalid_s5_reg[10] && max_reach_index_neq_5 && valid_raw_s5_reg[10] && (~reach_5_lsequ_max_reach_index_reg);
assign valid_comp_6_p1 = ldvalid_s5_reg[9] && max_reach_index_neq_6 && valid_raw_s5_reg[9] && (~reach_6_lsequ_max_reach_index_reg);
assign valid_comp_7_p1 = ldvalid_s5_reg[8] && max_reach_index_neq_7 && valid_raw_s5_reg[8] && (~reach_7_lsequ_max_reach_index_reg);
assign valid_comp_8_p1 = ldvalid_s5_reg[7] && max_reach_index_neq_8 && valid_raw_s5_reg[7] && (~reach_8_lsequ_max_reach_index_reg);
assign valid_comp_9_p1 = ldvalid_s5_reg[6] && max_reach_index_neq_9 && valid_raw_s5_reg[6] && (~reach_9_lsequ_max_reach_index_reg);
assign valid_comp_10_p1 = ldvalid_s5_reg[5] && max_reach_index_neq_10 && valid_raw_s5_reg[5] && (~reach_10_lsequ_max_reach_index_reg);
assign valid_comp_11_p1 = ldvalid_s5_reg[4] && max_reach_index_neq_11 && valid_raw_s5_reg[4] && (~reach_11_lsequ_max_reach_index_reg);
assign valid_comp_12_p1 = ldvalid_s5_reg[3] && max_reach_index_neq_12 && valid_raw_s5_reg[3] && (~reach_12_lsequ_max_reach_index_reg);
assign valid_comp_13_p1 = ldvalid_s5_reg[2] && max_reach_index_neq_13 && valid_raw_s5_reg[2] && (~reach_13_lsequ_max_reach_index_reg);
assign valid_comp_14_p1 = ldvalid_s5_reg[1] && max_reach_index_neq_14 && valid_raw_s5_reg[1] && (~reach_14_lsequ_max_reach_index_reg);
assign valid_comp_15_p1 = ldvalid_s5_reg[0] && max_reach_index_neq_15 && valid_raw_s5_reg[0] && (~reach_15_lsequ_max_reach_index_reg);

// 
assign larray_0_p1 = (valid_comp_0_p1)?((trimmed_len_ls_0)?{3'd0,trimmed_len_0}:literals_s5_reg[127:120]):larray_s5_reg[127:120];
assign larray_1_p1 = (valid_comp_1_p1)?((trimmed_len_ls_1)?{3'd0,trimmed_len_1}:literals_s5_reg[119:112]):larray_s5_reg[119:112];
assign larray_2_p1 = (valid_comp_2_p1)?((trimmed_len_ls_2)?{3'd0,trimmed_len_2}:literals_s5_reg[111:104]):larray_s5_reg[111:104];
assign larray_3_p1 = (valid_comp_3_p1)?((trimmed_len_ls_3)?{3'd0,trimmed_len_3}:literals_s5_reg[103:96]):larray_s5_reg[103:96];
assign larray_4_p1 = (valid_comp_4_p1)?((trimmed_len_ls_4)?{3'd0,trimmed_len_4}:literals_s5_reg[95:88]):larray_s5_reg[95:88];
assign larray_5_p1 = (valid_comp_5_p1)?((trimmed_len_ls_5)?{3'd0,trimmed_len_5}:literals_s5_reg[87:80]):larray_s5_reg[87:80];
assign larray_6_p1 = (valid_comp_6_p1)?((trimmed_len_ls_6)?{3'd0,trimmed_len_6}:literals_s5_reg[79:72]):larray_s5_reg[79:72];
assign larray_7_p1 = (valid_comp_7_p1)?((trimmed_len_ls_7)?{3'd0,trimmed_len_7}:literals_s5_reg[71:64]):larray_s5_reg[71:64];
assign larray_8_p1 = (valid_comp_8_p1)?((trimmed_len_ls_8)?{3'd0,trimmed_len_0}:literals_s5_reg[63:56]):larray_s5_reg[63:56];
assign larray_9_p1 = (valid_comp_9_p1)?((trimmed_len_ls_9)?{3'd0,trimmed_len_1}:literals_s5_reg[55:48]):larray_s5_reg[55:48];
assign larray_10_p1 = (valid_comp_10_p1)?((trimmed_len_ls_10)?{3'd0,trimmed_len_2}:literals_s5_reg[47:40]):larray_s5_reg[47:40];
assign larray_11_p1 = (valid_comp_11_p1)?((trimmed_len_ls_11)?{3'd0,trimmed_len_3}:literals_s5_reg[39:32]):larray_s5_reg[39:32];
assign larray_12_p1 = (valid_comp_12_p1)?((trimmed_len_ls_12)?{3'd0,trimmed_len_4}:literals_s5_reg[31:24]):larray_s5_reg[31:24];
assign larray_13_p1 = (valid_comp_13_p1)?((trimmed_len_ls_13)?{3'd0,trimmed_len_5}:literals_s5_reg[23:16]):larray_s5_reg[23:16];
assign larray_14_p1 = (valid_comp_14_p1)?((trimmed_len_ls_14)?{3'd0,trimmed_len_6}:literals_s5_reg[15:8]):larray_s5_reg[15:8];
assign larray_15_p1 = (valid_comp_15_p1)?((trimmed_len_ls_15)?{3'd0,trimmed_len_7}:literals_s5_reg[7:0]):larray_s5_reg[7:0];

// 
assign larray_0_plus_3_p1 = (valid_comp_0_p1)?((trimmed_len_ls_0)?{3'd0,trimmed_len_0_plus_3}:literals_s5_reg[127:120]):{3'd0, larray_0_plus_3_s5_reg};

// 
assign darray_0_p1 = (valid_comp_0_p1 && (~trimmed_len_ls_0))?16'd0:darray_s5_reg[255:240];
assign darray_1_p1 = (valid_comp_1_p1 && (~trimmed_len_ls_1))?16'd0:darray_s5_reg[239:224];
assign darray_2_p1 = (valid_comp_2_p1 && (~trimmed_len_ls_2))?16'd0:darray_s5_reg[223:208];
assign darray_3_p1 = (valid_comp_3_p1 && (~trimmed_len_ls_3))?16'd0:darray_s5_reg[207:192];
assign darray_4_p1 = (valid_comp_4_p1 && (~trimmed_len_ls_4))?16'd0:darray_s5_reg[191:176];
assign darray_5_p1 = (valid_comp_5_p1 && (~trimmed_len_ls_5))?16'd0:darray_s5_reg[175:160];
assign darray_6_p1 = (valid_comp_6_p1 && (~trimmed_len_ls_6))?16'd0:darray_s5_reg[159:144];
assign darray_7_p1 = (valid_comp_7_p1 && (~trimmed_len_ls_7))?16'd0:darray_s5_reg[143:128];
assign darray_8_p1 = (valid_comp_8_p1 && (~trimmed_len_ls_8))?16'd0:darray_s5_reg[127:112];
assign darray_9_p1 = (valid_comp_9_p1 && (~trimmed_len_ls_9))?16'd0:darray_s5_reg[111:96];
assign darray_10_p1 = (valid_comp_10_p1 && (~trimmed_len_ls_10))?16'd0:darray_s5_reg[95:80];
assign darray_11_p1 = (valid_comp_11_p1 && (~trimmed_len_ls_11))?16'd0:darray_s5_reg[79:64];
assign darray_12_p1 = (valid_comp_12_p1 && (~trimmed_len_ls_12))?16'd0:darray_s5_reg[63:48];
assign darray_13_p1 = (valid_comp_13_p1 && (~trimmed_len_ls_13))?16'd0:darray_s5_reg[47:32];
assign darray_14_p1 = (valid_comp_14_p1 && (~trimmed_len_ls_14))?16'd0:darray_s5_reg[31:16];
assign darray_15_p1 = (valid_comp_15_p1 && (~trimmed_len_ls_15))?16'd0:darray_s5_reg[15:0];

// 
assign dist_valid_0_s6 = valid_raw_s5_reg[15] && ~(valid_comp_0_p1 && (~trimmed_len_ls_0));
assign dist_valid_1_s6 = valid_raw_s5_reg[14] && ~(valid_comp_1_p1 && (~trimmed_len_ls_1));
assign dist_valid_2_s6 = valid_raw_s5_reg[13] && ~(valid_comp_2_p1 && (~trimmed_len_ls_2));
assign dist_valid_3_s6 = valid_raw_s5_reg[12] && ~(valid_comp_3_p1 && (~trimmed_len_ls_3));
assign dist_valid_4_s6 = valid_raw_s5_reg[11] && ~(valid_comp_4_p1 && (~trimmed_len_ls_4));
assign dist_valid_5_s6 = valid_raw_s5_reg[10] && ~(valid_comp_5_p1 && (~trimmed_len_ls_5));
assign dist_valid_6_s6 = valid_raw_s5_reg[9] && ~(valid_comp_6_p1 && (~trimmed_len_ls_6));
assign dist_valid_7_s6 = valid_raw_s5_reg[8] && ~(valid_comp_7_p1 && (~trimmed_len_ls_7));
assign dist_valid_8_s6 = valid_raw_s5_reg[7] && ~(valid_comp_8_p1 && (~trimmed_len_ls_8)); 
assign dist_valid_9_s6 = valid_raw_s5_reg[6] && ~(valid_comp_9_p1 && (~trimmed_len_ls_9));
assign dist_valid_10_s6 = valid_raw_s5_reg[5] && ~(valid_comp_10_p1 && (~trimmed_len_ls_10));
assign dist_valid_11_s6 = valid_raw_s5_reg[4] && ~(valid_comp_11_p1 && (~trimmed_len_ls_11));
assign dist_valid_12_s6 = valid_raw_s5_reg[3] && ~(valid_comp_12_p1 && (~trimmed_len_ls_12));
assign dist_valid_13_s6 = valid_raw_s5_reg[2] && ~(valid_comp_13_p1 && (~trimmed_len_ls_13));
assign dist_valid_14_s6 = valid_raw_s5_reg[1] && ~(valid_comp_14_p1 && (~trimmed_len_ls_14));
assign dist_valid_15_s6 = valid_raw_s5_reg[0] && ~(valid_comp_15_p1 && (~trimmed_len_ls_15));

assign dist_valid_s6 = {dist_valid_0_s6, dist_valid_1_s6, dist_valid_2_s6, dist_valid_3_s6, dist_valid_4_s6, dist_valid_5_s6, dist_valid_6_s6, dist_valid_7_s6, 
						dist_valid_8_s6, dist_valid_9_s6, dist_valid_10_s6, dist_valid_11_s6, dist_valid_12_s6, dist_valid_13_s6, dist_valid_14_s6, dist_valid_15_s6};

// 
register_compression #(.N(5)) register_old_head_match_pos_s6_U(.d(old_head_match_pos_s5_reg), .clk(clk), .q(old_head_match_pos_s6_reg));

register_compression #(.N(16)) register_ldvalid_s6_U(.d(ldvalid_s5_reg), .clk(clk), .q(ldvalid_s6_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s6_reg_U(.d(max_reach_index_neq_k_s6), .clk(clk), .q(max_reach_index_neq_k_s6_reg));

register_compression #(.N(16)) register_dist_valid_s6_U(.d(dist_valid_s6), .clk(clk), .q(dist_valid_s6_reg));

register_compression #(.N(8)) register_larray_0_plus_3_p1_U(.d(larray_0_plus_3_p1), .clk(clk), .q(larray_0_plus_3_p1_reg));

register_compression #(.N(8)) register_larray_0_p1_U(.d(larray_0_p1), .clk(clk), .q(larray_0_p1_reg));
register_compression #(.N(8)) register_larray_1_p1_U(.d(larray_1_p1), .clk(clk), .q(larray_1_p1_reg));
register_compression #(.N(8)) register_larray_2_p1_U(.d(larray_2_p1), .clk(clk), .q(larray_2_p1_reg));
register_compression #(.N(8)) register_larray_3_p1_U(.d(larray_3_p1), .clk(clk), .q(larray_3_p1_reg));
register_compression #(.N(8)) register_larray_4_p1_U(.d(larray_4_p1), .clk(clk), .q(larray_4_p1_reg));
register_compression #(.N(8)) register_larray_5_p1_U(.d(larray_5_p1), .clk(clk), .q(larray_5_p1_reg));
register_compression #(.N(8)) register_larray_6_p1_U(.d(larray_6_p1), .clk(clk), .q(larray_6_p1_reg));
register_compression #(.N(8)) register_larray_7_p1_U(.d(larray_7_p1), .clk(clk), .q(larray_7_p1_reg));
register_compression #(.N(8)) register_larray_8_p1_U(.d(larray_8_p1), .clk(clk), .q(larray_8_p1_reg));
register_compression #(.N(8)) register_larray_9_p1_U(.d(larray_9_p1), .clk(clk), .q(larray_9_p1_reg));
register_compression #(.N(8)) register_larray_10_p1_U(.d(larray_10_p1), .clk(clk), .q(larray_10_p1_reg));
register_compression #(.N(8)) register_larray_11_p1_U(.d(larray_11_p1), .clk(clk), .q(larray_11_p1_reg));
register_compression #(.N(8)) register_larray_12_p1_U(.d(larray_12_p1), .clk(clk), .q(larray_12_p1_reg));
register_compression #(.N(8)) register_larray_13_p1_U(.d(larray_13_p1), .clk(clk), .q(larray_13_p1_reg));
register_compression #(.N(8)) register_larray_14_p1_U(.d(larray_14_p1), .clk(clk), .q(larray_14_p1_reg));
register_compression #(.N(8)) register_larray_15_p1_U(.d(larray_15_p1), .clk(clk), .q(larray_15_p1_reg));

register_compression #(.N(16)) register_darray_0_p1_U(.d(darray_0_p1), .clk(clk), .q(darray_0_p1_reg));
register_compression #(.N(16)) register_darray_1_p1_U(.d(darray_1_p1), .clk(clk), .q(darray_1_p1_reg));
register_compression #(.N(16)) register_darray_2_p1_U(.d(darray_2_p1), .clk(clk), .q(darray_2_p1_reg));
register_compression #(.N(16)) register_darray_3_p1_U(.d(darray_3_p1), .clk(clk), .q(darray_3_p1_reg));
register_compression #(.N(16)) register_darray_4_p1_U(.d(darray_4_p1), .clk(clk), .q(darray_4_p1_reg));
register_compression #(.N(16)) register_darray_5_p1_U(.d(darray_5_p1), .clk(clk), .q(darray_5_p1_reg));
register_compression #(.N(16)) register_darray_6_p1_U(.d(darray_6_p1), .clk(clk), .q(darray_6_p1_reg));
register_compression #(.N(16)) register_darray_7_p1_U(.d(darray_7_p1), .clk(clk), .q(darray_7_p1_reg));
register_compression #(.N(16)) register_darray_8_p1_U(.d(darray_8_p1), .clk(clk), .q(darray_8_p1_reg));
register_compression #(.N(16)) register_darray_9_p1_U(.d(darray_9_p1), .clk(clk), .q(darray_9_p1_reg));
register_compression #(.N(16)) register_darray_10_p1_U(.d(darray_10_p1), .clk(clk), .q(darray_10_p1_reg));
register_compression #(.N(16)) register_darray_11_p1_U(.d(darray_11_p1), .clk(clk), .q(darray_11_p1_reg));
register_compression #(.N(16)) register_darray_12_p1_U(.d(darray_12_p1), .clk(clk), .q(darray_12_p1_reg));
register_compression #(.N(16)) register_darray_13_p1_U(.d(darray_13_p1), .clk(clk), .q(darray_13_p1_reg));
register_compression #(.N(16)) register_darray_14_p1_U(.d(darray_14_p1), .clk(clk), .q(darray_14_p1_reg));
register_compression #(.N(16)) register_darray_15_p1_U(.d(darray_15_p1), .clk(clk), .q(darray_15_p1_reg));

register_compression #(.N(128)) register_literals_s6_U(.d(literals_s5_reg), .clk(clk), .q(literals_s6_reg));

register_compression #(.N(1)) register_en_s6_U(.d(en_s5_reg), .clk(clk), .q(en_s6_reg));
register_compression #(.N(1)) register_start_s6_U(.d(start_s5_reg), .clk(clk), .q(start_s6_reg));
register_compression #(.N(1)) register_last_s6_U(.d(last_s5_reg), .clk(clk), .q(last_s6_reg));


// ====================================================================
//
//  Stage 7: prepare the lazy evaluation for byte 0
//
// ====================================================================

// stage 7 ports definition
// comp_near_0 =1 means larray[0] >= larray[1]
wire			comp_near_0;
wire			comp_near_0_reg;

// processed_len_0_op1: processed_len[k]++
wire	[4:0]	processed_len_0_op1;
wire	[4:0]	processed_len_0_op1_reg;
// processed_len_0_op2: processed_len[k] += larray[k] + 3
wire	[4:0]	processed_len_0_op2;
wire	[4:0]	processed_len_0_op2_reg;

// 
wire	[4:0]	larray_1_plus_3;
wire	[4:0]	larray_1_plus_3_reg;

// 
wire	[4:0]	old_head_match_pos_s7_reg;	

//
wire	[15:0]	max_reach_index_neq_k_s7_reg;

// 
wire	[15:0]		dist_valid_s7_reg;

// 
wire	[7:0]	larray_0_s7_reg;
wire	[7:0]	larray_1_s7_reg;
wire	[7:0]	larray_2_s7_reg;
wire	[7:0]	larray_3_s7_reg;
wire	[7:0]	larray_4_s7_reg;
wire	[7:0]	larray_5_s7_reg;
wire	[7:0]	larray_6_s7_reg;
wire	[7:0]	larray_7_s7_reg;
wire	[7:0]	larray_8_s7_reg;
wire	[7:0]	larray_9_s7_reg;
wire	[7:0]	larray_10_s7_reg;
wire	[7:0]	larray_11_s7_reg;
wire	[7:0]	larray_12_s7_reg;
wire	[7:0]	larray_13_s7_reg;
wire	[7:0]	larray_14_s7_reg;
wire	[7:0]	larray_15_s7_reg;

// 
wire	[15:0]	darray_0_s7_reg;
wire	[15:0]	darray_1_s7_reg;
wire	[15:0]	darray_2_s7_reg;
wire	[15:0]	darray_3_s7_reg;
wire	[15:0]	darray_4_s7_reg;
wire	[15:0]	darray_5_s7_reg;
wire	[15:0]	darray_6_s7_reg;
wire	[15:0]	darray_7_s7_reg;
wire	[15:0]	darray_8_s7_reg;
wire	[15:0]	darray_9_s7_reg;
wire	[15:0]	darray_10_s7_reg;
wire	[15:0]	darray_11_s7_reg;
wire	[15:0]	darray_12_s7_reg;
wire	[15:0]	darray_13_s7_reg;
wire	[15:0]	darray_14_s7_reg;
wire	[15:0]	darray_15_s7_reg;

// 
wire	[15:0]	ldvalid_s7_reg;

// 
wire	[127:0]	literals_s7_reg;

// 
wire 			en_s7_reg;
wire 			start_s7_reg;
wire 			last_s7_reg;

// stage 7 
// prepare the lazy evaluation for k = 0
// comp_near_0 =1 means larray[0] >= larray[1]
adder_5bits adder_5bits_comp_near_0_U(	
	.a(larray_0_p1_reg[4:0]),
	.b(~larray_1_p1_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_0) 	
);

assign processed_len_0_op1 = old_head_match_pos_s6_reg + 5'd1;
assign processed_len_0_op2 = old_head_match_pos_s6_reg + larray_0_plus_3_p1_reg[4:0];

assign larray_1_plus_3 = larray_1_p1_reg[4:0] + 5'd3;

// 
register_compression #(.N(1)) register_comp_near_0_U(.d(comp_near_0), .clk(clk), .q(comp_near_0_reg));

register_compression #(.N(5)) register_processed_len_0_op1_U(.d(processed_len_0_op1), .clk(clk), .q(processed_len_0_op1_reg));
register_compression #(.N(5)) register_processed_len_0_op2_U(.d(processed_len_0_op2), .clk(clk), .q(processed_len_0_op2_reg));

register_compression #(.N(5)) register_larray_1_plus_3_U(.d(larray_1_plus_3), .clk(clk), .q(larray_1_plus_3_reg));

register_compression #(.N(5)) register_old_head_match_pos_s7_U(.d(old_head_match_pos_s6_reg), .clk(clk), .q(old_head_match_pos_s7_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s7_reg_U(.d(max_reach_index_neq_k_s6_reg), .clk(clk), .q(max_reach_index_neq_k_s7_reg));

register_compression #(.N(16)) register_dist_valid_s7_U(.d(dist_valid_s6_reg), .clk(clk), .q(dist_valid_s7_reg));

register_compression #(.N(8)) register_larray_0_s7_U(.d(larray_0_p1_reg), .clk(clk), .q(larray_0_s7_reg));
register_compression #(.N(8)) register_larray_1_s7_U(.d(larray_1_p1_reg), .clk(clk), .q(larray_1_s7_reg));
register_compression #(.N(8)) register_larray_2_s7_U(.d(larray_2_p1_reg), .clk(clk), .q(larray_2_s7_reg));
register_compression #(.N(8)) register_larray_3_s7_U(.d(larray_3_p1_reg), .clk(clk), .q(larray_3_s7_reg));
register_compression #(.N(8)) register_larray_4_s7_U(.d(larray_4_p1_reg), .clk(clk), .q(larray_4_s7_reg));
register_compression #(.N(8)) register_larray_5_s7_U(.d(larray_5_p1_reg), .clk(clk), .q(larray_5_s7_reg));
register_compression #(.N(8)) register_larray_6_s7_U(.d(larray_6_p1_reg), .clk(clk), .q(larray_6_s7_reg));
register_compression #(.N(8)) register_larray_7_s7_U(.d(larray_7_p1_reg), .clk(clk), .q(larray_7_s7_reg));
register_compression #(.N(8)) register_larray_8_s7_U(.d(larray_8_p1_reg), .clk(clk), .q(larray_8_s7_reg));
register_compression #(.N(8)) register_larray_9_s7_U(.d(larray_9_p1_reg), .clk(clk), .q(larray_9_s7_reg));
register_compression #(.N(8)) register_larray_10_s7_U(.d(larray_10_p1_reg), .clk(clk), .q(larray_10_s7_reg));
register_compression #(.N(8)) register_larray_11_s7_U(.d(larray_11_p1_reg), .clk(clk), .q(larray_11_s7_reg));
register_compression #(.N(8)) register_larray_12_s7_U(.d(larray_12_p1_reg), .clk(clk), .q(larray_12_s7_reg));
register_compression #(.N(8)) register_larray_13_s7_U(.d(larray_13_p1_reg), .clk(clk), .q(larray_13_s7_reg));
register_compression #(.N(8)) register_larray_14_s7_U(.d(larray_14_p1_reg), .clk(clk), .q(larray_14_s7_reg));
register_compression #(.N(8)) register_larray_15_s7_U(.d(larray_15_p1_reg), .clk(clk), .q(larray_15_s7_reg));

register_compression #(.N(16)) register_darray_0_s7_U(.d(darray_0_p1_reg), .clk(clk), .q(darray_0_s7_reg));
register_compression #(.N(16)) register_darray_1_s7_U(.d(darray_1_p1_reg), .clk(clk), .q(darray_1_s7_reg));
register_compression #(.N(16)) register_darray_2_s7_U(.d(darray_2_p1_reg), .clk(clk), .q(darray_2_s7_reg));
register_compression #(.N(16)) register_darray_3_s7_U(.d(darray_3_p1_reg), .clk(clk), .q(darray_3_s7_reg));
register_compression #(.N(16)) register_darray_4_s7_U(.d(darray_4_p1_reg), .clk(clk), .q(darray_4_s7_reg));
register_compression #(.N(16)) register_darray_5_s7_U(.d(darray_5_p1_reg), .clk(clk), .q(darray_5_s7_reg));
register_compression #(.N(16)) register_darray_6_s7_U(.d(darray_6_p1_reg), .clk(clk), .q(darray_6_s7_reg));
register_compression #(.N(16)) register_darray_7_s7_U(.d(darray_7_p1_reg), .clk(clk), .q(darray_7_s7_reg));
register_compression #(.N(16)) register_darray_8_s7_U(.d(darray_8_p1_reg), .clk(clk), .q(darray_8_s7_reg));
register_compression #(.N(16)) register_darray_9_s7_U(.d(darray_9_p1_reg), .clk(clk), .q(darray_9_s7_reg));
register_compression #(.N(16)) register_darray_10_s7_U(.d(darray_10_p1_reg), .clk(clk), .q(darray_10_s7_reg));
register_compression #(.N(16)) register_darray_11_s7_U(.d(darray_11_p1_reg), .clk(clk), .q(darray_11_s7_reg));
register_compression #(.N(16)) register_darray_12_s7_U(.d(darray_12_p1_reg), .clk(clk), .q(darray_12_s7_reg));
register_compression #(.N(16)) register_darray_13_s7_U(.d(darray_13_p1_reg), .clk(clk), .q(darray_13_s7_reg));
register_compression #(.N(16)) register_darray_14_s7_U(.d(darray_14_p1_reg), .clk(clk), .q(darray_14_s7_reg));
register_compression #(.N(16)) register_darray_15_s7_U(.d(darray_15_p1_reg), .clk(clk), .q(darray_15_s7_reg));

register_compression #(.N(16)) register_ldvalid_s7_U(.d(ldvalid_s6_reg), .clk(clk), .q(ldvalid_s7_reg));

register_compression #(.N(128)) register_literals_s7_U(.d(literals_s6_reg), .clk(clk), .q(literals_s7_reg));

register_compression #(.N(1)) register_en_s7_U(.d(en_s6_reg), .clk(clk), .q(en_s7_reg));
register_compression #(.N(1)) register_start_s7_U(.d(start_s6_reg), .clk(clk), .q(start_s7_reg));
register_compression #(.N(1)) register_last_s7_U(.d(last_s6_reg), .clk(clk), .q(last_s7_reg));


// ====================================================================
//
//  Stage 8: prepare the lazy evaluation for byte 1 and perform 
// 			 lazy evaluation for byte 0
//
// ====================================================================

// stage 8 ports definition
// 
wire 			do_lazy_0;

// 
wire	[4:0]	processed_len_0;
wire	[4:0]	processed_len_0_reg;

// 
wire	[7:0]	larray_0_s8;

wire	[7:0]	larray_0_s8_reg;
wire	[7:0]	larray_1_s8_reg;
wire	[7:0]	larray_2_s8_reg;
wire	[7:0]	larray_3_s8_reg;
wire	[7:0]	larray_4_s8_reg;
wire	[7:0]	larray_5_s8_reg;
wire	[7:0]	larray_6_s8_reg;
wire	[7:0]	larray_7_s8_reg;
wire	[7:0]	larray_8_s8_reg;
wire	[7:0]	larray_9_s8_reg;
wire	[7:0]	larray_10_s8_reg;
wire	[7:0]	larray_11_s8_reg;
wire	[7:0]	larray_12_s8_reg;
wire	[7:0]	larray_13_s8_reg;
wire	[7:0]	larray_14_s8_reg;
wire	[7:0]	larray_15_s8_reg;

// 
wire	[15:0]	darray_0_s8;

wire	[15:0]	darray_0_s8_reg;
wire	[15:0]	darray_1_s8_reg;
wire	[15:0]	darray_2_s8_reg;
wire	[15:0]	darray_3_s8_reg;
wire	[15:0]	darray_4_s8_reg;
wire	[15:0]	darray_5_s8_reg;
wire	[15:0]	darray_6_s8_reg;
wire	[15:0]	darray_7_s8_reg;
wire	[15:0]	darray_8_s8_reg;
wire	[15:0]	darray_9_s8_reg;
wire	[15:0]	darray_10_s8_reg;
wire	[15:0]	darray_11_s8_reg;
wire	[15:0]	darray_12_s8_reg;
wire	[15:0]	darray_13_s8_reg;
wire	[15:0]	darray_14_s8_reg;
wire	[15:0]	darray_15_s8_reg;

// 
wire			comp_near_1;
wire			comp_near_1_reg;

// 0 means k < processed_len
wire			comp_1_processed_len_0;	
wire			comp_1_processed_len_0_reg;

// 
wire	[4:0]	processed_len_1_op1;
wire	[4:0]	processed_len_1_op2;

wire	[4:0]	processed_len_1_op1_reg;
wire	[4:0]	processed_len_1_op2_reg;

// 
wire	[4:0]   larray_2_plus_3;
wire	[4:0]   larray_2_plus_3_reg;

// 
wire	[15:0]	ldvalid_s8_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s8_reg;

// 
wire	[15:0]		dist_valid_s8_reg;

// 
wire	[127:0] 	literals_s8_reg;

// 
wire 				en_s8_reg;
wire 				start_s8_reg;
wire 				last_s8_reg;

// stage 8 
// do the lazy evaluation for k = 0
// prepare the lazy evaluation for k = 1
assign do_lazy_0 = (ldvalid_s7_reg[14]) && (dist_valid_s7_reg[14]) && (~comp_near_0_reg);
assign processed_len_0 = (ldvalid_s7_reg[15] && max_reach_index_neq_k_s7_reg[15])?((dist_valid_s7_reg[15])?(do_lazy_0?processed_len_0_op1_reg:processed_len_0_op2_reg):processed_len_0_op1_reg):old_head_match_pos_s7_reg;
assign larray_0_s8 = (ldvalid_s7_reg[15] && max_reach_index_neq_k_s7_reg[15] && (dist_valid_s7_reg[15]) && (do_lazy_0))?literals_s7_reg[127:120]:larray_0_s7_reg;
assign darray_0_s8 = (ldvalid_s7_reg[15] && max_reach_index_neq_k_s7_reg[15] && (dist_valid_s7_reg[15]) && (do_lazy_0))?16'd0:darray_0_s7_reg;

// comp_near_1 =1 means larray[1] >= larray[2]
adder_5bits adder_5bits_comp_near_1_U(	
	.a(larray_1_p1_reg[4:0]),
	.b(~larray_2_p1_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_1) 
);

// 
adder_5bits comp_1_processed_len_0_U(
	.a(5'd1), 
	.b(~processed_len_0), 
	.ci(1'b1), 
	.s(), 
	.co(comp_1_processed_len_0)
);

assign processed_len_1_op1 = processed_len_0 + 5'd1;

assign processed_len_1_op2 = processed_len_0 + larray_1_plus_3_reg;

assign larray_2_plus_3 = larray_2_s7_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_0_reg_U(.d(processed_len_0), .clk(clk), .q(processed_len_0_reg));

register_compression #(.N(8)) larray_0_s8_reg_U(.d(larray_0_s8), .clk(clk), .q(larray_0_s8_reg));
register_compression #(.N(8)) larray_1_s8_reg_U(.d(larray_1_s7_reg), .clk(clk), .q(larray_1_s8_reg));
register_compression #(.N(8)) larray_2_s8_reg_U(.d(larray_2_s7_reg), .clk(clk), .q(larray_2_s8_reg));
register_compression #(.N(8)) larray_3_s8_reg_U(.d(larray_3_s7_reg), .clk(clk), .q(larray_3_s8_reg));
register_compression #(.N(8)) larray_4_s8_reg_U(.d(larray_4_s7_reg), .clk(clk), .q(larray_4_s8_reg));
register_compression #(.N(8)) larray_5_s8_reg_U(.d(larray_5_s7_reg), .clk(clk), .q(larray_5_s8_reg));
register_compression #(.N(8)) larray_6_s8_reg_U(.d(larray_6_s7_reg), .clk(clk), .q(larray_6_s8_reg));
register_compression #(.N(8)) larray_7_s8_reg_U(.d(larray_7_s7_reg), .clk(clk), .q(larray_7_s8_reg));
register_compression #(.N(8)) larray_8_s8_reg_U(.d(larray_8_s7_reg), .clk(clk), .q(larray_8_s8_reg));
register_compression #(.N(8)) larray_9_s8_reg_U(.d(larray_9_s7_reg), .clk(clk), .q(larray_9_s8_reg));
register_compression #(.N(8)) larray_10_s8_reg_U(.d(larray_10_s7_reg), .clk(clk), .q(larray_10_s8_reg));
register_compression #(.N(8)) larray_11_s8_reg_U(.d(larray_11_s7_reg), .clk(clk), .q(larray_11_s8_reg));
register_compression #(.N(8)) larray_12_s8_reg_U(.d(larray_12_s7_reg), .clk(clk), .q(larray_12_s8_reg));
register_compression #(.N(8)) larray_13_s8_reg_U(.d(larray_13_s7_reg), .clk(clk), .q(larray_13_s8_reg));
register_compression #(.N(8)) larray_14_s8_reg_U(.d(larray_14_s7_reg), .clk(clk), .q(larray_14_s8_reg));
register_compression #(.N(8)) larray_15_s8_reg_U(.d(larray_15_s7_reg), .clk(clk), .q(larray_15_s8_reg));

register_compression #(.N(16)) darray_0_s8_reg_U(.d(darray_0_s8), .clk(clk), .q(darray_0_s8_reg));
register_compression #(.N(16)) darray_1_s8_reg_U(.d(darray_1_s7_reg), .clk(clk), .q(darray_1_s8_reg));
register_compression #(.N(16)) darray_2_s8_reg_U(.d(darray_2_s7_reg), .clk(clk), .q(darray_2_s8_reg));
register_compression #(.N(16)) darray_3_s8_reg_U(.d(darray_3_s7_reg), .clk(clk), .q(darray_3_s8_reg));
register_compression #(.N(16)) darray_4_s8_reg_U(.d(darray_4_s7_reg), .clk(clk), .q(darray_4_s8_reg));
register_compression #(.N(16)) darray_5_s8_reg_U(.d(darray_5_s7_reg), .clk(clk), .q(darray_5_s8_reg));
register_compression #(.N(16)) darray_6_s8_reg_U(.d(darray_6_s7_reg), .clk(clk), .q(darray_6_s8_reg));
register_compression #(.N(16)) darray_7_s8_reg_U(.d(darray_7_s7_reg), .clk(clk), .q(darray_7_s8_reg));
register_compression #(.N(16)) darray_8_s8_reg_U(.d(darray_8_s7_reg), .clk(clk), .q(darray_8_s8_reg));
register_compression #(.N(16)) darray_9_s8_reg_U(.d(darray_9_s7_reg), .clk(clk), .q(darray_9_s8_reg));
register_compression #(.N(16)) darray_10_s8_reg_U(.d(darray_10_s7_reg), .clk(clk), .q(darray_10_s8_reg));
register_compression #(.N(16)) darray_11_s8_reg_U(.d(darray_11_s7_reg), .clk(clk), .q(darray_11_s8_reg));
register_compression #(.N(16)) darray_12_s8_reg_U(.d(darray_12_s7_reg), .clk(clk), .q(darray_12_s8_reg));
register_compression #(.N(16)) darray_13_s8_reg_U(.d(darray_13_s7_reg), .clk(clk), .q(darray_13_s8_reg));
register_compression #(.N(16)) darray_14_s8_reg_U(.d(darray_14_s7_reg), .clk(clk), .q(darray_14_s8_reg));
register_compression #(.N(16)) darray_15_s8_reg_U(.d(darray_15_s7_reg), .clk(clk), .q(darray_15_s8_reg));

register_compression #(.N(1)) comp_near_1_reg_U(.d(comp_near_1), .clk(clk), .q(comp_near_1_reg));

register_compression #(.N(1)) comp_1_processed_len_0_reg_U(.d(comp_1_processed_len_0), .clk(clk), .q(comp_1_processed_len_0_reg));

register_compression #(.N(5)) processed_len_1_op1_reg_U(.d(processed_len_1_op1), .clk(clk), .q(processed_len_1_op1_reg));
register_compression #(.N(5)) processed_len_1_op2_reg_U(.d(processed_len_1_op2), .clk(clk), .q(processed_len_1_op2_reg));

register_compression #(.N(5)) larray_2_plus_3_reg_U(.d(larray_2_plus_3), .clk(clk), .q(larray_2_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s8_reg_U(.d(max_reach_index_neq_k_s7_reg), .clk(clk), .q(max_reach_index_neq_k_s8_reg));

register_compression #(.N(16)) dist_valid_s8_reg_U(.d(dist_valid_s7_reg), .clk(clk), .q(dist_valid_s8_reg));

register_compression #(.N(16)) register_ldvalid_s8_U(.d(ldvalid_s7_reg), .clk(clk), .q(ldvalid_s8_reg));

register_compression #(.N(128)) literals_s8_reg_U(.d(literals_s7_reg), .clk(clk), .q(literals_s8_reg));

register_compression #(.N(1)) register_en_s8_U(.d(en_s7_reg), .clk(clk), .q(en_s8_reg));
register_compression #(.N(1)) register_start_s8_U(.d(start_s7_reg), .clk(clk), .q(start_s8_reg));
register_compression #(.N(1)) register_last_s8_U(.d(last_s7_reg), .clk(clk), .q(last_s8_reg));


// ====================================================================
//
//  Stage 9: prepare the lazy evaluation for byte 2 and perform 
// 			 lazy evaluation for byte 1
//
// ====================================================================

// stage 9 ports definition
// 
wire 			do_lazy_1;

// 
wire	[4:0]	processed_len_1;
wire	[4:0]	processed_len_1_reg;

// 
wire	[7:0]	larray_1_s9;

wire	[7:0]	larray_0_s9_reg;
wire	[7:0]	larray_1_s9_reg;
wire	[7:0]	larray_2_s9_reg;
wire	[7:0]	larray_3_s9_reg;
wire	[7:0]	larray_4_s9_reg;
wire	[7:0]	larray_5_s9_reg;
wire	[7:0]	larray_6_s9_reg;
wire	[7:0]	larray_7_s9_reg;
wire	[7:0]	larray_8_s9_reg;
wire	[7:0]	larray_9_s9_reg;
wire	[7:0]	larray_10_s9_reg;
wire	[7:0]	larray_11_s9_reg;
wire	[7:0]	larray_12_s9_reg;
wire	[7:0]	larray_13_s9_reg;
wire	[7:0]	larray_14_s9_reg;
wire	[7:0]	larray_15_s9_reg;

// 
wire	[15:0]	darray_1_s9;

wire	[15:0]	darray_0_s9_reg;
wire	[15:0]	darray_1_s9_reg;
wire	[15:0]	darray_2_s9_reg;
wire	[15:0]	darray_3_s9_reg;
wire	[15:0]	darray_4_s9_reg;
wire	[15:0]	darray_5_s9_reg;
wire	[15:0]	darray_6_s9_reg;
wire	[15:0]	darray_7_s9_reg;
wire	[15:0]	darray_8_s9_reg;
wire	[15:0]	darray_9_s9_reg;
wire	[15:0]	darray_10_s9_reg;
wire	[15:0]	darray_11_s9_reg;
wire	[15:0]	darray_12_s9_reg;
wire	[15:0]	darray_13_s9_reg;
wire	[15:0]	darray_14_s9_reg;
wire	[15:0]	darray_15_s9_reg;

//
wire	[15:0]	ldvalid_s9;
wire	[15:0]	ldvalid_s9_reg;

// 
wire			comp_near_2;
wire			comp_near_2_reg;

// 
wire			comp_2_processed_len_1;	//0 means k < processed_len_k-1
wire			comp_2_processed_len_1_reg;

// 
wire	[4:0]	processed_len_2_op1;
wire	[4:0]	processed_len_2_op1_reg;

wire	[4:0]	processed_len_2_op2;
wire	[4:0]	processed_len_2_op2_reg;

// 
wire	[4:0]   larray_3_plus_3;
wire	[4:0]   larray_3_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s9_reg;
wire	[15:0]	dist_valid_s9_reg;

// 
wire	[127:0] literals_s9_reg;

// 
wire 			en_s9_reg;
wire 			start_s9_reg;
wire 			last_s9_reg;

// stage 9
// do the lazy evaluation for k = 1
// prepare the lazy evaluation for k = 2
assign do_lazy_1 = (ldvalid_s8_reg[13]) && (dist_valid_s8_reg[13]) && (~comp_near_1_reg);
assign processed_len_1 = (ldvalid_s8_reg[14] && max_reach_index_neq_k_s8_reg[14] && comp_1_processed_len_0_reg)?((dist_valid_s8_reg[14])?(do_lazy_1?processed_len_1_op1_reg:processed_len_1_op2_reg):processed_len_1_op1_reg):processed_len_0_reg;
assign larray_1_s9 = (ldvalid_s8_reg[14] && max_reach_index_neq_k_s8_reg[14] && comp_1_processed_len_0_reg && dist_valid_s8_reg[14] && do_lazy_1)?literals_s8_reg[119:112]:larray_1_s8_reg;
assign darray_1_s9 = (ldvalid_s8_reg[14] && max_reach_index_neq_k_s8_reg[14] && comp_1_processed_len_0_reg && dist_valid_s8_reg[14] && do_lazy_1)?16'd0:darray_1_s8_reg;
assign ldvalid_s9 = (ldvalid_s8_reg[14] && max_reach_index_neq_k_s8_reg[14] && (~comp_1_processed_len_0_reg))?{ldvalid_s8_reg[15], 1'b0, ldvalid_s8_reg[13:0]}:ldvalid_s8_reg;

// comp_near_2 =1 means larray[2] >= larray[3]
adder_5bits adder_5bits_comp_near_2_U(	
	.a(larray_2_s8_reg[4:0]),
	.b(~larray_3_s8_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_2) 	
);

// 
adder_5bits comp_2_processed_len_1_U(
	.a(5'd2), 
	.b(~processed_len_1), 
	.ci(1'b1), 
	.s(), 
	.co(comp_2_processed_len_1)
);

// 
assign processed_len_2_op1 = processed_len_1 + 5'd1;

assign processed_len_2_op2 = processed_len_1 + larray_2_plus_3_reg;

assign larray_3_plus_3 = larray_3_s8_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_1_reg_U(.d(processed_len_1), .clk(clk), .q(processed_len_1_reg));

register_compression #(.N(8)) larray_0_s9_reg_U(.d(larray_0_s8_reg), .clk(clk), .q(larray_0_s9_reg));
register_compression #(.N(8)) larray_1_s9_reg_U(.d(larray_1_s9), .clk(clk), .q(larray_1_s9_reg));
register_compression #(.N(8)) larray_2_s9_reg_U(.d(larray_2_s8_reg), .clk(clk), .q(larray_2_s9_reg));
register_compression #(.N(8)) larray_3_s9_reg_U(.d(larray_3_s8_reg), .clk(clk), .q(larray_3_s9_reg));
register_compression #(.N(8)) larray_4_s9_reg_U(.d(larray_4_s8_reg), .clk(clk), .q(larray_4_s9_reg));
register_compression #(.N(8)) larray_5_s9_reg_U(.d(larray_5_s8_reg), .clk(clk), .q(larray_5_s9_reg));
register_compression #(.N(8)) larray_6_s9_reg_U(.d(larray_6_s8_reg), .clk(clk), .q(larray_6_s9_reg));
register_compression #(.N(8)) larray_7_s9_reg_U(.d(larray_7_s8_reg), .clk(clk), .q(larray_7_s9_reg));
register_compression #(.N(8)) larray_8_s9_reg_U(.d(larray_8_s8_reg), .clk(clk), .q(larray_8_s9_reg));
register_compression #(.N(8)) larray_9_s9_reg_U(.d(larray_9_s8_reg), .clk(clk), .q(larray_9_s9_reg));
register_compression #(.N(8)) larray_10_s9_reg_U(.d(larray_10_s8_reg), .clk(clk), .q(larray_10_s9_reg));
register_compression #(.N(8)) larray_11_s9_reg_U(.d(larray_11_s8_reg), .clk(clk), .q(larray_11_s9_reg));
register_compression #(.N(8)) larray_12_s9_reg_U(.d(larray_12_s8_reg), .clk(clk), .q(larray_12_s9_reg));
register_compression #(.N(8)) larray_13_s9_reg_U(.d(larray_13_s8_reg), .clk(clk), .q(larray_13_s9_reg));
register_compression #(.N(8)) larray_14_s9_reg_U(.d(larray_14_s8_reg), .clk(clk), .q(larray_14_s9_reg));
register_compression #(.N(8)) larray_15_s9_reg_U(.d(larray_15_s8_reg), .clk(clk), .q(larray_15_s9_reg));


register_compression #(.N(16)) darray_0_s9_reg_U(.d(darray_0_s8_reg), .clk(clk), .q(darray_0_s9_reg));
register_compression #(.N(16)) darray_1_s9_reg_U(.d(darray_1_s9), .clk(clk), .q(darray_1_s9_reg));
register_compression #(.N(16)) darray_2_s9_reg_U(.d(darray_2_s8_reg), .clk(clk), .q(darray_2_s9_reg));
register_compression #(.N(16)) darray_3_s9_reg_U(.d(darray_3_s8_reg), .clk(clk), .q(darray_3_s9_reg));
register_compression #(.N(16)) darray_4_s9_reg_U(.d(darray_4_s8_reg), .clk(clk), .q(darray_4_s9_reg));
register_compression #(.N(16)) darray_5_s9_reg_U(.d(darray_5_s8_reg), .clk(clk), .q(darray_5_s9_reg));
register_compression #(.N(16)) darray_6_s9_reg_U(.d(darray_6_s8_reg), .clk(clk), .q(darray_6_s9_reg));
register_compression #(.N(16)) darray_7_s9_reg_U(.d(darray_7_s8_reg), .clk(clk), .q(darray_7_s9_reg));
register_compression #(.N(16)) darray_8_s9_reg_U(.d(darray_8_s8_reg), .clk(clk), .q(darray_8_s9_reg));
register_compression #(.N(16)) darray_9_s9_reg_U(.d(darray_9_s8_reg), .clk(clk), .q(darray_9_s9_reg));
register_compression #(.N(16)) darray_10_s9_reg_U(.d(darray_10_s8_reg), .clk(clk), .q(darray_10_s9_reg));
register_compression #(.N(16)) darray_11_s9_reg_U(.d(darray_11_s8_reg), .clk(clk), .q(darray_11_s9_reg));
register_compression #(.N(16)) darray_12_s9_reg_U(.d(darray_12_s8_reg), .clk(clk), .q(darray_12_s9_reg));
register_compression #(.N(16)) darray_13_s9_reg_U(.d(darray_13_s8_reg), .clk(clk), .q(darray_13_s9_reg));
register_compression #(.N(16)) darray_14_s9_reg_U(.d(darray_14_s8_reg), .clk(clk), .q(darray_14_s9_reg));
register_compression #(.N(16)) darray_15_s9_reg_U(.d(darray_15_s8_reg), .clk(clk), .q(darray_15_s9_reg));


register_compression #(.N(16)) register_ldvalid_s9_U(.d(ldvalid_s9), .clk(clk), .q(ldvalid_s9_reg));

register_compression #(.N(1)) comp_near_2_reg_U(.d(comp_near_2), .clk(clk), .q(comp_near_2_reg));

register_compression #(.N(1)) comp_2_processed_len_1_reg_U(.d(comp_2_processed_len_1), .clk(clk), .q(comp_2_processed_len_1_reg));

register_compression #(.N(5)) processed_len_2_op1_reg_U(.d(processed_len_2_op1), .clk(clk), .q(processed_len_2_op1_reg));
register_compression #(.N(5)) processed_len_2_op2_reg_U(.d(processed_len_2_op2), .clk(clk), .q(processed_len_2_op2_reg));

register_compression #(.N(5)) larray_3_plus_3_reg_U(.d(larray_3_plus_3), .clk(clk), .q(larray_3_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s9_reg_U(.d(max_reach_index_neq_k_s8_reg), .clk(clk), .q(max_reach_index_neq_k_s9_reg));

register_compression #(.N(16)) dist_valid_s9_reg_U(.d(dist_valid_s8_reg), .clk(clk), .q(dist_valid_s9_reg));

register_compression #(.N(128)) literals_s9_reg_U(.d(literals_s8_reg), .clk(clk), .q(literals_s9_reg));

register_compression #(.N(1)) register_en_s9_U(.d(en_s8_reg), .clk(clk), .q(en_s9_reg));
register_compression #(.N(1)) register_start_s9_U(.d(start_s8_reg), .clk(clk), .q(start_s9_reg));
register_compression #(.N(1)) register_last_s9_U(.d(last_s8_reg), .clk(clk), .q(last_s9_reg));


// ====================================================================
//
//  Stage 10: prepare the lazy evaluation for byte 3 and perform 
// 			 lazy evaluation for byte 2
//
// ====================================================================

// stage 10 ports definition
// 
wire 			do_lazy_2;

// 
wire	[4:0]	processed_len_2;
wire	[4:0]	processed_len_2_reg;

// 
wire	[7:0]	larray_2_s10;

wire	[7:0]	larray_0_s10_reg;
wire	[7:0]	larray_1_s10_reg;
wire	[7:0]	larray_2_s10_reg;
wire	[7:0]	larray_3_s10_reg;
wire	[7:0]	larray_4_s10_reg;
wire	[7:0]	larray_5_s10_reg;
wire	[7:0]	larray_6_s10_reg;
wire	[7:0]	larray_7_s10_reg;
wire	[7:0]	larray_8_s10_reg;
wire	[7:0]	larray_9_s10_reg;
wire	[7:0]	larray_10_s10_reg;
wire	[7:0]	larray_11_s10_reg;
wire	[7:0]	larray_12_s10_reg;
wire	[7:0]	larray_13_s10_reg;
wire	[7:0]	larray_14_s10_reg;
wire	[7:0]	larray_15_s10_reg;

// 
wire	[15:0]	darray_2_s10;

wire	[15:0]	darray_0_s10_reg;
wire	[15:0]	darray_1_s10_reg;
wire	[15:0]	darray_2_s10_reg;
wire	[15:0]	darray_3_s10_reg;
wire	[15:0]	darray_4_s10_reg;
wire	[15:0]	darray_5_s10_reg;
wire	[15:0]	darray_6_s10_reg;
wire	[15:0]	darray_7_s10_reg;
wire	[15:0]	darray_8_s10_reg;
wire	[15:0]	darray_9_s10_reg;
wire	[15:0]	darray_10_s10_reg;
wire	[15:0]	darray_11_s10_reg;
wire	[15:0]	darray_12_s10_reg;
wire	[15:0]	darray_13_s10_reg;
wire	[15:0]	darray_14_s10_reg;
wire	[15:0]	darray_15_s10_reg;

// 
wire	[15:0]	ldvalid_s10;
wire	[15:0]	ldvalid_s10_reg;

// 
wire			comp_near_3;
wire			comp_near_3_reg;


// 0 means 3 < processed_len_2
wire			comp_3_processed_len_2;
wire			comp_3_processed_len_2_reg;

// 
wire	[4:0]	processed_len_3_op1;
wire	[4:0]	processed_len_3_op1_reg;

wire	[4:0]	processed_len_3_op2;
wire	[4:0]	processed_len_3_op2_reg;

// 
wire	[4:0]   larray_4_plus_3;
wire	[4:0]   larray_4_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s10_reg;

wire	[15:0]	dist_valid_s10_reg;


// 
wire	[127:0] 	literals_s10_reg;

// 
wire 				en_s10_reg;
wire 				start_s10_reg;
wire 				last_s10_reg;

// stage 10 
// do the lazy evaluation for k = 2
// prepare the lazy evaluation for k = 3
assign do_lazy_2 = (ldvalid_s9_reg[12]) && (dist_valid_s9_reg[12]) && (~comp_near_2_reg);
assign processed_len_2 = (ldvalid_s9_reg[13] && max_reach_index_neq_k_s9_reg[13] && comp_2_processed_len_1_reg)?((dist_valid_s9_reg[13])?(do_lazy_2?processed_len_2_op1_reg:processed_len_2_op2_reg):processed_len_2_op1_reg):processed_len_1_reg;
assign larray_2_s10 = (ldvalid_s9_reg[13] && max_reach_index_neq_k_s9_reg[13] && comp_2_processed_len_1_reg && (dist_valid_s9_reg[13]) && (do_lazy_2))?literals_s9_reg[111:104]:larray_2_s9_reg;
assign darray_2_s10 = (ldvalid_s9_reg[13] && max_reach_index_neq_k_s9_reg[13] && comp_2_processed_len_1_reg && (dist_valid_s9_reg[13]) && (do_lazy_2))?16'd0:darray_2_s9_reg;
assign ldvalid_s10 = (ldvalid_s9_reg[13] && max_reach_index_neq_k_s9_reg[13] && (~comp_2_processed_len_1_reg))?{ldvalid_s9_reg[15:14], 1'b0, ldvalid_s9_reg[12:0]}:ldvalid_s9_reg;

// comp_near_3 =1 means larray[3] >= larray[4]
adder_5bits adder_5bits_comp_near_3_U(	
	.a(larray_3_s9_reg[4:0]),
	.b(~larray_4_s9_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_3) 	
);

adder_5bits comp_3_processed_len_2_U(
	.a(5'd3), 
	.b(~processed_len_2), 
	.ci(1'b1), 
	.s(), 
	.co(comp_3_processed_len_2)
);

assign processed_len_3_op1 = processed_len_2 + 5'd1;

assign processed_len_3_op2 = processed_len_2 + larray_3_plus_3_reg;

assign larray_4_plus_3 = larray_4_s9_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_2_reg_U(.d(processed_len_2), .clk(clk), .q(processed_len_2_reg));

register_compression #(.N(8)) larray_0_s10_reg_U(.d(larray_0_s9_reg), .clk(clk), .q(larray_0_s10_reg));
register_compression #(.N(8)) larray_1_s10_reg_U(.d(larray_1_s9_reg), .clk(clk), .q(larray_1_s10_reg));
register_compression #(.N(8)) larray_2_s10_reg_U(.d(larray_2_s10), .clk(clk), .q(larray_2_s10_reg));
register_compression #(.N(8)) larray_3_s10_reg_U(.d(larray_3_s9_reg), .clk(clk), .q(larray_3_s10_reg));
register_compression #(.N(8)) larray_4_s10_reg_U(.d(larray_4_s9_reg), .clk(clk), .q(larray_4_s10_reg));
register_compression #(.N(8)) larray_5_s10_reg_U(.d(larray_5_s9_reg), .clk(clk), .q(larray_5_s10_reg));
register_compression #(.N(8)) larray_6_s10_reg_U(.d(larray_6_s9_reg), .clk(clk), .q(larray_6_s10_reg));
register_compression #(.N(8)) larray_7_s10_reg_U(.d(larray_7_s9_reg), .clk(clk), .q(larray_7_s10_reg));
register_compression #(.N(8)) larray_8_s10_reg_U(.d(larray_8_s9_reg), .clk(clk), .q(larray_8_s10_reg));
register_compression #(.N(8)) larray_9_s10_reg_U(.d(larray_9_s9_reg), .clk(clk), .q(larray_9_s10_reg));
register_compression #(.N(8)) larray_10_s10_reg_U(.d(larray_10_s9_reg), .clk(clk), .q(larray_10_s10_reg));
register_compression #(.N(8)) larray_11_s10_reg_U(.d(larray_11_s9_reg), .clk(clk), .q(larray_11_s10_reg));
register_compression #(.N(8)) larray_12_s10_reg_U(.d(larray_12_s9_reg), .clk(clk), .q(larray_12_s10_reg));
register_compression #(.N(8)) larray_13_s10_reg_U(.d(larray_13_s9_reg), .clk(clk), .q(larray_13_s10_reg));
register_compression #(.N(8)) larray_14_s10_reg_U(.d(larray_14_s9_reg), .clk(clk), .q(larray_14_s10_reg));
register_compression #(.N(8)) larray_15_s10_reg_U(.d(larray_15_s9_reg), .clk(clk), .q(larray_15_s10_reg));


register_compression #(.N(16)) darray_0_s10_reg_U(.d(darray_0_s9_reg), .clk(clk), .q(darray_0_s10_reg));
register_compression #(.N(16)) darray_1_s10_reg_U(.d(darray_1_s9_reg), .clk(clk), .q(darray_1_s10_reg));
register_compression #(.N(16)) darray_2_s10_reg_U(.d(darray_2_s10), .clk(clk), .q(darray_2_s10_reg));
register_compression #(.N(16)) darray_3_s10_reg_U(.d(darray_3_s9_reg), .clk(clk), .q(darray_3_s10_reg));
register_compression #(.N(16)) darray_4_s10_reg_U(.d(darray_4_s9_reg), .clk(clk), .q(darray_4_s10_reg));
register_compression #(.N(16)) darray_5_s10_reg_U(.d(darray_5_s9_reg), .clk(clk), .q(darray_5_s10_reg));
register_compression #(.N(16)) darray_6_s10_reg_U(.d(darray_6_s9_reg), .clk(clk), .q(darray_6_s10_reg));
register_compression #(.N(16)) darray_7_s10_reg_U(.d(darray_7_s9_reg), .clk(clk), .q(darray_7_s10_reg));
register_compression #(.N(16)) darray_8_s10_reg_U(.d(darray_8_s9_reg), .clk(clk), .q(darray_8_s10_reg));
register_compression #(.N(16)) darray_9_s10_reg_U(.d(darray_9_s9_reg), .clk(clk), .q(darray_9_s10_reg));
register_compression #(.N(16)) darray_10_s10_reg_U(.d(darray_10_s9_reg), .clk(clk), .q(darray_10_s10_reg));
register_compression #(.N(16)) darray_11_s10_reg_U(.d(darray_11_s9_reg), .clk(clk), .q(darray_11_s10_reg));
register_compression #(.N(16)) darray_12_s10_reg_U(.d(darray_12_s9_reg), .clk(clk), .q(darray_12_s10_reg));
register_compression #(.N(16)) darray_13_s10_reg_U(.d(darray_13_s9_reg), .clk(clk), .q(darray_13_s10_reg));
register_compression #(.N(16)) darray_14_s10_reg_U(.d(darray_14_s9_reg), .clk(clk), .q(darray_14_s10_reg));
register_compression #(.N(16)) darray_15_s10_reg_U(.d(darray_15_s9_reg), .clk(clk), .q(darray_15_s10_reg));

register_compression #(.N(16)) register_ldvalid_s10_U(.d(ldvalid_s10), .clk(clk), .q(ldvalid_s10_reg));

register_compression #(.N(1)) comp_near_3_reg_U(.d(comp_near_3), .clk(clk), .q(comp_near_3_reg));

register_compression #(.N(1)) comp_3_processed_len_2_reg_U(.d(comp_3_processed_len_2), .clk(clk), .q(comp_3_processed_len_2_reg));

register_compression #(.N(5)) processed_len_3_op1_reg_U(.d(processed_len_3_op1), .clk(clk), .q(processed_len_3_op1_reg));
register_compression #(.N(5)) processed_len_3_op2_reg_U(.d(processed_len_3_op2), .clk(clk), .q(processed_len_3_op2_reg));

register_compression #(.N(5)) larray_4_plus_3_reg_U(.d(larray_4_plus_3), .clk(clk), .q(larray_4_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s10_reg_U(.d(max_reach_index_neq_k_s9_reg), .clk(clk), .q(max_reach_index_neq_k_s10_reg));

register_compression #(.N(16)) dist_valid_s10_reg_U(.d(dist_valid_s9_reg), .clk(clk), .q(dist_valid_s10_reg));

register_compression #(.N(128)) literals_s10_reg_U(.d(literals_s9_reg), .clk(clk), .q(literals_s10_reg));

register_compression #(.N(1)) register_en_s10_U(.d(en_s9_reg), .clk(clk), .q(en_s10_reg));
register_compression #(.N(1)) register_start_s10_U(.d(start_s9_reg), .clk(clk), .q(start_s10_reg));
register_compression #(.N(1)) register_last_s10_U(.d(last_s9_reg), .clk(clk), .q(last_s10_reg));


// ====================================================================
//
//  Stage 11: prepare the lazy evaluation for byte 4 and perform 
// 			 lazy evaluation for byte 3
//
// ====================================================================

// stage 11 ports definition
// 
wire 			do_lazy_3;

// 
wire	[4:0]	processed_len_3;
wire	[4:0]	processed_len_3_reg;

// 
wire	[7:0]	larray_3_s11;

wire	[7:0]	larray_0_s11_reg;
wire	[7:0]	larray_1_s11_reg;
wire	[7:0]	larray_2_s11_reg;
wire	[7:0]	larray_3_s11_reg;
wire	[7:0]	larray_4_s11_reg;
wire	[7:0]	larray_5_s11_reg;
wire	[7:0]	larray_6_s11_reg;
wire	[7:0]	larray_7_s11_reg;
wire	[7:0]	larray_8_s11_reg;
wire	[7:0]	larray_9_s11_reg;
wire	[7:0]	larray_10_s11_reg;
wire	[7:0]	larray_11_s11_reg;
wire	[7:0]	larray_12_s11_reg;
wire	[7:0]	larray_13_s11_reg;
wire	[7:0]	larray_14_s11_reg;
wire	[7:0]	larray_15_s11_reg;

// 
wire	[15:0]	darray_3_s11;

wire	[15:0]	darray_0_s11_reg;
wire	[15:0]	darray_1_s11_reg;
wire	[15:0]	darray_2_s11_reg;
wire	[15:0]	darray_3_s11_reg;
wire	[15:0]	darray_4_s11_reg;
wire	[15:0]	darray_5_s11_reg;
wire	[15:0]	darray_6_s11_reg;
wire	[15:0]	darray_7_s11_reg;
wire	[15:0]	darray_8_s11_reg;
wire	[15:0]	darray_9_s11_reg;
wire	[15:0]	darray_10_s11_reg;
wire	[15:0]	darray_11_s11_reg;
wire	[15:0]	darray_12_s11_reg;
wire	[15:0]	darray_13_s11_reg;
wire	[15:0]	darray_14_s11_reg;
wire	[15:0]	darray_15_s11_reg;

// 
wire	[15:0]	ldvalid_s11;
wire	[15:0]	ldvalid_s11_reg;

// 
wire			comp_near_4;
wire			comp_near_4_reg;

// 0 means 4 < processed_len_3
wire			comp_4_processed_len_3;	
wire			comp_4_processed_len_3_reg;

// 
wire	[4:0]	processed_len_4_op1;
wire	[4:0]	processed_len_4_op2;

wire	[4:0]	processed_len_4_op1_reg;
wire	[4:0]	processed_len_4_op2_reg;

// 
wire	[4:0]   larray_5_plus_3;
wire	[4:0]   larray_5_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s11_reg;

wire	[15:0]	dist_valid_s11_reg;

// 
wire	[127:0] 	literals_s11_reg;

// 
wire 				en_s11_reg;
wire 				start_s11_reg;
wire 				last_s11_reg;

// stage 11
// do the lazy evaluation for k = 3
// prepare the lazy evaluation for k = 4
assign do_lazy_3 = (ldvalid_s10_reg[11]) && (dist_valid_s10_reg[11]) && (~comp_near_3_reg);
assign processed_len_3 = (ldvalid_s10_reg[12] && max_reach_index_neq_k_s10_reg[12] && comp_3_processed_len_2_reg)?((dist_valid_s10_reg[12])?(do_lazy_3?processed_len_3_op1_reg:processed_len_3_op2_reg):processed_len_3_op1_reg):processed_len_2_reg;
assign larray_3_s11 = (ldvalid_s10_reg[12] && max_reach_index_neq_k_s10_reg[12] && comp_3_processed_len_2_reg && (dist_valid_s10_reg[12]) && (do_lazy_3))?literals_s10_reg[103:96]:larray_3_s10_reg;
assign darray_3_s11 = (ldvalid_s10_reg[12] && max_reach_index_neq_k_s10_reg[12] && comp_3_processed_len_2_reg && (dist_valid_s10_reg[12]) && (do_lazy_3))?16'd0:darray_3_s10_reg;
assign ldvalid_s11 = (ldvalid_s10_reg[12] && max_reach_index_neq_k_s10_reg[12] && (~comp_3_processed_len_2_reg))?{ldvalid_s10_reg[15:13], 1'b0, ldvalid_s10_reg[11:0]}:ldvalid_s10_reg;

// comp_near_4 =1 means larray[4] >= larray[5]
adder_5bits adder_5bits_comp_near_4_U(	
	.a(larray_4_s10_reg[4:0]),
	.b(~larray_5_s10_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_4) 	
);

// 
adder_5bits comp_4_processed_len_3_U(
	.a(5'd4), 
	.b(~processed_len_3), 
	.ci(1'b1), 
	.s(), 
	.co(comp_4_processed_len_3)
);

// 
assign processed_len_4_op1 = processed_len_3 + 4'd1;

assign processed_len_4_op2 = processed_len_3 + larray_4_plus_3_reg;

assign larray_5_plus_3 = larray_5_s10_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_3_reg_U(.d(processed_len_3), .clk(clk), .q(processed_len_3_reg));

register_compression #(.N(8)) larray_0_s11_reg_U(.d(larray_0_s10_reg), .clk(clk), .q(larray_0_s11_reg));
register_compression #(.N(8)) larray_1_s11_reg_U(.d(larray_1_s10_reg), .clk(clk), .q(larray_1_s11_reg));
register_compression #(.N(8)) larray_2_s11_reg_U(.d(larray_2_s10_reg), .clk(clk), .q(larray_2_s11_reg));
register_compression #(.N(8)) larray_3_s11_reg_U(.d(larray_3_s11), .clk(clk), .q(larray_3_s11_reg));
register_compression #(.N(8)) larray_4_s11_reg_U(.d(larray_4_s10_reg), .clk(clk), .q(larray_4_s11_reg));
register_compression #(.N(8)) larray_5_s11_reg_U(.d(larray_5_s10_reg), .clk(clk), .q(larray_5_s11_reg));
register_compression #(.N(8)) larray_6_s11_reg_U(.d(larray_6_s10_reg), .clk(clk), .q(larray_6_s11_reg));
register_compression #(.N(8)) larray_7_s11_reg_U(.d(larray_7_s10_reg), .clk(clk), .q(larray_7_s11_reg));
register_compression #(.N(8)) larray_8_s11_reg_U(.d(larray_8_s10_reg), .clk(clk), .q(larray_8_s11_reg));
register_compression #(.N(8)) larray_9_s11_reg_U(.d(larray_9_s10_reg), .clk(clk), .q(larray_9_s11_reg));
register_compression #(.N(8)) larray_10_s11_reg_U(.d(larray_10_s10_reg), .clk(clk), .q(larray_10_s11_reg));
register_compression #(.N(8)) larray_11_s11_reg_U(.d(larray_11_s10_reg), .clk(clk), .q(larray_11_s11_reg));
register_compression #(.N(8)) larray_12_s11_reg_U(.d(larray_12_s10_reg), .clk(clk), .q(larray_12_s11_reg));
register_compression #(.N(8)) larray_13_s11_reg_U(.d(larray_13_s10_reg), .clk(clk), .q(larray_13_s11_reg));
register_compression #(.N(8)) larray_14_s11_reg_U(.d(larray_14_s10_reg), .clk(clk), .q(larray_14_s11_reg));
register_compression #(.N(8)) larray_15_s11_reg_U(.d(larray_15_s10_reg), .clk(clk), .q(larray_15_s11_reg));


register_compression #(.N(16)) darray_0_s11_reg_U(.d(darray_0_s10_reg), .clk(clk), .q(darray_0_s11_reg));
register_compression #(.N(16)) darray_1_s11_reg_U(.d(darray_1_s10_reg), .clk(clk), .q(darray_1_s11_reg));
register_compression #(.N(16)) darray_2_s11_reg_U(.d(darray_2_s10_reg), .clk(clk), .q(darray_2_s11_reg));
register_compression #(.N(16)) darray_3_s11_reg_U(.d(darray_3_s11), .clk(clk), .q(darray_3_s11_reg));
register_compression #(.N(16)) darray_4_s11_reg_U(.d(darray_4_s10_reg), .clk(clk), .q(darray_4_s11_reg));
register_compression #(.N(16)) darray_5_s11_reg_U(.d(darray_5_s10_reg), .clk(clk), .q(darray_5_s11_reg));
register_compression #(.N(16)) darray_6_s11_reg_U(.d(darray_6_s10_reg), .clk(clk), .q(darray_6_s11_reg));
register_compression #(.N(16)) darray_7_s11_reg_U(.d(darray_7_s10_reg), .clk(clk), .q(darray_7_s11_reg));
register_compression #(.N(16)) darray_8_s11_reg_U(.d(darray_8_s10_reg), .clk(clk), .q(darray_8_s11_reg));
register_compression #(.N(16)) darray_9_s11_reg_U(.d(darray_9_s10_reg), .clk(clk), .q(darray_9_s11_reg));
register_compression #(.N(16)) darray_10_s11_reg_U(.d(darray_10_s10_reg), .clk(clk), .q(darray_10_s11_reg));
register_compression #(.N(16)) darray_11_s11_reg_U(.d(darray_11_s10_reg), .clk(clk), .q(darray_11_s11_reg));
register_compression #(.N(16)) darray_12_s11_reg_U(.d(darray_12_s10_reg), .clk(clk), .q(darray_12_s11_reg));
register_compression #(.N(16)) darray_13_s11_reg_U(.d(darray_13_s10_reg), .clk(clk), .q(darray_13_s11_reg));
register_compression #(.N(16)) darray_14_s11_reg_U(.d(darray_14_s10_reg), .clk(clk), .q(darray_14_s11_reg));
register_compression #(.N(16)) darray_15_s11_reg_U(.d(darray_15_s10_reg), .clk(clk), .q(darray_15_s11_reg));

register_compression #(.N(16)) register_ldvalid_s11_U(.d(ldvalid_s11), .clk(clk), .q(ldvalid_s11_reg));

register_compression #(.N(1)) comp_near_4_reg_U(.d(comp_near_4), .clk(clk), .q(comp_near_4_reg));

register_compression #(.N(1)) comp_4_processed_len_3_reg_U(.d(comp_4_processed_len_3), .clk(clk), .q(comp_4_processed_len_3_reg));

register_compression #(.N(5)) processed_len_4_op1_reg_U(.d(processed_len_4_op1), .clk(clk), .q(processed_len_4_op1_reg));
register_compression #(.N(5)) processed_len_4_op2_reg_U(.d(processed_len_4_op2), .clk(clk), .q(processed_len_4_op2_reg));

register_compression #(.N(5)) larray_5_plus_3_reg_U(.d(larray_5_plus_3), .clk(clk), .q(larray_5_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s11_reg_U(.d(max_reach_index_neq_k_s10_reg), .clk(clk), .q(max_reach_index_neq_k_s11_reg));

register_compression #(.N(16)) dist_valid_s11_reg_U(.d(dist_valid_s10_reg), .clk(clk), .q(dist_valid_s11_reg));

register_compression #(.N(128)) literals_s11_reg_U(.d(literals_s10_reg), .clk(clk), .q(literals_s11_reg));

register_compression #(.N(1)) register_en_s11_U(.d(en_s10_reg), .clk(clk), .q(en_s11_reg));
register_compression #(.N(1)) register_start_s11_U(.d(start_s10_reg), .clk(clk), .q(start_s11_reg));
register_compression #(.N(1)) register_last_s11_U(.d(last_s10_reg), .clk(clk), .q(last_s11_reg));


// ====================================================================
//
//  Stage 12: prepare the lazy evaluation for byte 5 and perform 
// 			 lazy evaluation for byte 4
//
// ====================================================================

// stage 12 ports definition
// 
wire 			do_lazy_4;

// 
wire	[4:0]	processed_len_4;
wire	[4:0]	processed_len_4_reg;

// 
wire	[7:0]	larray_4_s12;

wire	[7:0]	larray_0_s12_reg;
wire	[7:0]	larray_1_s12_reg;
wire	[7:0]	larray_2_s12_reg;
wire	[7:0]	larray_3_s12_reg;
wire	[7:0]	larray_4_s12_reg;
wire	[7:0]	larray_5_s12_reg;
wire	[7:0]	larray_6_s12_reg;
wire	[7:0]	larray_7_s12_reg;
wire	[7:0]	larray_8_s12_reg;
wire	[7:0]	larray_9_s12_reg;
wire	[7:0]	larray_10_s12_reg;
wire	[7:0]	larray_11_s12_reg;
wire	[7:0]	larray_12_s12_reg;
wire	[7:0]	larray_13_s12_reg;
wire	[7:0]	larray_14_s12_reg;
wire	[7:0]	larray_15_s12_reg;

// 
wire	[15:0]	darray_4_s12;

wire	[15:0]	darray_0_s12_reg;
wire	[15:0]	darray_1_s12_reg;
wire	[15:0]	darray_2_s12_reg;
wire	[15:0]	darray_3_s12_reg;
wire	[15:0]	darray_4_s12_reg;
wire	[15:0]	darray_5_s12_reg;
wire	[15:0]	darray_6_s12_reg;
wire	[15:0]	darray_7_s12_reg;
wire	[15:0]	darray_8_s12_reg;
wire	[15:0]	darray_9_s12_reg;
wire	[15:0]	darray_10_s12_reg;
wire	[15:0]	darray_11_s12_reg;
wire	[15:0]	darray_12_s12_reg;
wire	[15:0]	darray_13_s12_reg;
wire	[15:0]	darray_14_s12_reg;
wire	[15:0]	darray_15_s12_reg;

// 
wire	[15:0]	ldvalid_s12;
wire	[15:0]	ldvalid_s12_reg;

//
wire			comp_near_5;
wire			comp_near_5_reg;

//0 means 5 < processed_len_4
wire			comp_5_processed_len_4;	
wire			comp_5_processed_len_4_reg;

// 
wire	[4:0]	processed_len_5_op1;
wire	[4:0]	processed_len_5_op2;

wire	[4:0]	processed_len_5_op1_reg;
wire	[4:0]	processed_len_5_op2_reg;

//
wire	[4:0]   larray_6_plus_3;
wire	[4:0]   larray_6_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s12_reg;

wire	[15:0]	dist_valid_s12_reg;

// 
wire	[127:0] 	literals_s12_reg;

// 
wire 				en_s12_reg;
wire 				start_s12_reg;
wire 				last_s12_reg;

// stage 12
// do the lazy evaluation for k = 4
// prepare the lazy evaluation for k = 5
assign do_lazy_4 = (ldvalid_s11_reg[10]) && (dist_valid_s11_reg[10]) && (~comp_near_4_reg);
assign processed_len_4 = (ldvalid_s11_reg[11] && max_reach_index_neq_k_s11_reg[11] && comp_4_processed_len_3_reg)?((dist_valid_s11_reg[11])?(do_lazy_4?processed_len_4_op1_reg:processed_len_4_op2_reg):processed_len_4_op1_reg):processed_len_3_reg;
assign larray_4_s12 = (ldvalid_s11_reg[11] && max_reach_index_neq_k_s11_reg[11] && comp_4_processed_len_3_reg && (dist_valid_s11_reg[11]) && (do_lazy_4))?literals_s11_reg[95:88]:larray_4_s11_reg;
assign darray_4_s12 = (ldvalid_s11_reg[11] && max_reach_index_neq_k_s11_reg[11] && comp_4_processed_len_3_reg && (dist_valid_s11_reg[11]) && (do_lazy_4))?16'd0:darray_4_s11_reg;
assign ldvalid_s12 = (ldvalid_s11_reg[11] && max_reach_index_neq_k_s11_reg[11] && (~comp_4_processed_len_3_reg))?{ldvalid_s11_reg[15:12], 1'b0, ldvalid_s11_reg[10:0]}:ldvalid_s11_reg;

// comp_near_5 =1 means larray[5] >= larray[6]
adder_5bits adder_5bits_comp_near_5_U(	
	.a(larray_5_s11_reg[4:0]),
	.b(~larray_6_s11_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_5) 	
);

// 
adder_5bits comp_5_processed_len_4_U(
	.a(5'd5), 
	.b(~processed_len_4), 
	.ci(1'b1), 
	.s(), 
	.co(comp_5_processed_len_4)
);

// 
assign processed_len_5_op1 = processed_len_4 + 5'd1;

assign processed_len_5_op2 = processed_len_4 + larray_5_plus_3_reg;

assign larray_6_plus_3 = larray_6_s11_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_4_reg_U(.d(processed_len_4), .clk(clk), .q(processed_len_4_reg));

register_compression #(.N(8)) larray_0_s12_reg_U(.d(larray_0_s11_reg), .clk(clk), .q(larray_0_s12_reg));
register_compression #(.N(8)) larray_1_s12_reg_U(.d(larray_1_s11_reg), .clk(clk), .q(larray_1_s12_reg));
register_compression #(.N(8)) larray_2_s12_reg_U(.d(larray_2_s11_reg), .clk(clk), .q(larray_2_s12_reg));
register_compression #(.N(8)) larray_3_s12_reg_U(.d(larray_3_s11_reg), .clk(clk), .q(larray_3_s12_reg));
register_compression #(.N(8)) larray_4_s12_reg_U(.d(larray_4_s12), .clk(clk), .q(larray_4_s12_reg));
register_compression #(.N(8)) larray_5_s12_reg_U(.d(larray_5_s11_reg), .clk(clk), .q(larray_5_s12_reg));
register_compression #(.N(8)) larray_6_s12_reg_U(.d(larray_6_s11_reg), .clk(clk), .q(larray_6_s12_reg));
register_compression #(.N(8)) larray_7_s12_reg_U(.d(larray_7_s11_reg), .clk(clk), .q(larray_7_s12_reg));
register_compression #(.N(8)) larray_8_s12_reg_U(.d(larray_8_s11_reg), .clk(clk), .q(larray_8_s12_reg));
register_compression #(.N(8)) larray_9_s12_reg_U(.d(larray_9_s11_reg), .clk(clk), .q(larray_9_s12_reg));
register_compression #(.N(8)) larray_10_s12_reg_U(.d(larray_10_s11_reg), .clk(clk), .q(larray_10_s12_reg));
register_compression #(.N(8)) larray_11_s12_reg_U(.d(larray_11_s11_reg), .clk(clk), .q(larray_11_s12_reg));
register_compression #(.N(8)) larray_12_s12_reg_U(.d(larray_12_s11_reg), .clk(clk), .q(larray_12_s12_reg));
register_compression #(.N(8)) larray_13_s12_reg_U(.d(larray_13_s11_reg), .clk(clk), .q(larray_13_s12_reg));
register_compression #(.N(8)) larray_14_s12_reg_U(.d(larray_14_s11_reg), .clk(clk), .q(larray_14_s12_reg));
register_compression #(.N(8)) larray_15_s12_reg_U(.d(larray_15_s11_reg), .clk(clk), .q(larray_15_s12_reg));

register_compression #(.N(16)) darray_0_s12_reg_U(.d(darray_0_s11_reg), .clk(clk), .q(darray_0_s12_reg));
register_compression #(.N(16)) darray_1_s12_reg_U(.d(darray_1_s11_reg), .clk(clk), .q(darray_1_s12_reg));
register_compression #(.N(16)) darray_2_s12_reg_U(.d(darray_2_s11_reg), .clk(clk), .q(darray_2_s12_reg));
register_compression #(.N(16)) darray_3_s12_reg_U(.d(darray_3_s11_reg), .clk(clk), .q(darray_3_s12_reg));
register_compression #(.N(16)) darray_4_s12_reg_U(.d(darray_4_s12), .clk(clk), .q(darray_4_s12_reg));
register_compression #(.N(16)) darray_5_s12_reg_U(.d(darray_5_s11_reg), .clk(clk), .q(darray_5_s12_reg));
register_compression #(.N(16)) darray_6_s12_reg_U(.d(darray_6_s11_reg), .clk(clk), .q(darray_6_s12_reg));
register_compression #(.N(16)) darray_7_s12_reg_U(.d(darray_7_s11_reg), .clk(clk), .q(darray_7_s12_reg));
register_compression #(.N(16)) darray_8_s12_reg_U(.d(darray_8_s11_reg), .clk(clk), .q(darray_8_s12_reg));
register_compression #(.N(16)) darray_9_s12_reg_U(.d(darray_9_s11_reg), .clk(clk), .q(darray_9_s12_reg));
register_compression #(.N(16)) darray_10_s12_reg_U(.d(darray_10_s11_reg), .clk(clk), .q(darray_10_s12_reg));
register_compression #(.N(16)) darray_11_s12_reg_U(.d(darray_11_s11_reg), .clk(clk), .q(darray_11_s12_reg));
register_compression #(.N(16)) darray_12_s12_reg_U(.d(darray_12_s11_reg), .clk(clk), .q(darray_12_s12_reg));
register_compression #(.N(16)) darray_13_s12_reg_U(.d(darray_13_s11_reg), .clk(clk), .q(darray_13_s12_reg));
register_compression #(.N(16)) darray_14_s12_reg_U(.d(darray_14_s11_reg), .clk(clk), .q(darray_14_s12_reg));
register_compression #(.N(16)) darray_15_s12_reg_U(.d(darray_15_s11_reg), .clk(clk), .q(darray_15_s12_reg));


register_compression #(.N(16)) register_ldvalid_s12_U(.d(ldvalid_s12), .clk(clk), .q(ldvalid_s12_reg));

register_compression #(.N(1)) comp_near_5_reg_U(.d(comp_near_5), .clk(clk), .q(comp_near_5_reg));

register_compression #(.N(1)) comp_5_processed_len_4_reg_U(.d(comp_5_processed_len_4), .clk(clk), .q(comp_5_processed_len_4_reg));

register_compression #(.N(5)) processed_len_5_op1_reg_U(.d(processed_len_5_op1), .clk(clk), .q(processed_len_5_op1_reg));
register_compression #(.N(5)) processed_len_5_op2_reg_U(.d(processed_len_5_op2), .clk(clk), .q(processed_len_5_op2_reg));

register_compression #(.N(5)) larray_6_plus_3_reg_U(.d(larray_6_plus_3), .clk(clk), .q(larray_6_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s12_reg_U(.d(max_reach_index_neq_k_s11_reg), .clk(clk), .q(max_reach_index_neq_k_s12_reg));

register_compression #(.N(16)) dist_valid_s12_reg_U(.d(dist_valid_s11_reg), .clk(clk), .q(dist_valid_s12_reg));

register_compression #(.N(128)) literals_s12_reg_U(.d(literals_s11_reg), .clk(clk), .q(literals_s12_reg));

register_compression #(.N(1)) register_en_s12_U(.d(en_s11_reg), .clk(clk), .q(en_s12_reg));
register_compression #(.N(1)) register_start_s12_U(.d(start_s11_reg), .clk(clk), .q(start_s12_reg));
register_compression #(.N(1)) register_last_s12_U(.d(last_s11_reg), .clk(clk), .q(last_s12_reg));


// ====================================================================
//
//  Stage 13: prepare the lazy evaluation for byte 6 and perform 
// 			 lazy evaluation for byte 5
//
// ====================================================================

// stage 13 ports definition
// 
wire 			do_lazy_5;

// 
wire	[4:0]	processed_len_5;
wire	[4:0]	processed_len_5_reg;

// 
wire	[7:0]	larray_5_s13;

wire	[7:0]	larray_0_s13_reg;
wire	[7:0]	larray_1_s13_reg;
wire	[7:0]	larray_2_s13_reg;
wire	[7:0]	larray_3_s13_reg;
wire	[7:0]	larray_4_s13_reg;
wire	[7:0]	larray_5_s13_reg;
wire	[7:0]	larray_6_s13_reg;
wire	[7:0]	larray_7_s13_reg;
wire	[7:0]	larray_8_s13_reg;
wire	[7:0]	larray_9_s13_reg;
wire	[7:0]	larray_10_s13_reg;
wire	[7:0]	larray_11_s13_reg;
wire	[7:0]	larray_12_s13_reg;
wire	[7:0]	larray_13_s13_reg;
wire	[7:0]	larray_14_s13_reg;
wire	[7:0]	larray_15_s13_reg;

// 
wire	[15:0]	darray_5_s13;

wire	[15:0]	darray_0_s13_reg;
wire	[15:0]	darray_1_s13_reg;
wire	[15:0]	darray_2_s13_reg;
wire	[15:0]	darray_3_s13_reg;
wire	[15:0]	darray_4_s13_reg;
wire	[15:0]	darray_5_s13_reg;
wire	[15:0]	darray_6_s13_reg;
wire	[15:0]	darray_7_s13_reg;
wire	[15:0]	darray_8_s13_reg;
wire	[15:0]	darray_9_s13_reg;
wire	[15:0]	darray_10_s13_reg;
wire	[15:0]	darray_11_s13_reg;
wire	[15:0]	darray_12_s13_reg;
wire	[15:0]	darray_13_s13_reg;
wire	[15:0]	darray_14_s13_reg;
wire	[15:0]	darray_15_s13_reg;

// 
wire	[15:0]	ldvalid_s13;
wire	[15:0]	ldvalid_s13_reg;

// 
wire			comp_near_6;
wire			comp_near_6_reg;

// 0 means 6 < processed_len_5
wire			comp_6_processed_len_5;
wire			comp_6_processed_len_5_reg;

// 
wire	[4:0]	processed_len_6_op1;
wire	[4:0]	processed_len_6_op2;

wire	[4:0]	processed_len_6_op1_reg;
wire	[4:0]	processed_len_6_op2_reg;

// 
wire	[4:0]   larray_7_plus_3;
wire	[4:0]   larray_7_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s13_reg;

wire	[15:0]	dist_valid_s13_reg;

// 
wire	[127:0] 	literals_s13_reg;

// 
wire 				en_s13_reg;
wire 				start_s13_reg;
wire 				last_s13_reg;

// stage 13
// do the lazy evaluation for k = 5
// prepare the lazy evaluation for k = 6
assign do_lazy_5 = (ldvalid_s12_reg[9]) && (dist_valid_s12_reg[9]) && (~comp_near_5_reg);
assign processed_len_5 = (ldvalid_s12_reg[10] && max_reach_index_neq_k_s12_reg[10] && comp_5_processed_len_4_reg)?((dist_valid_s12_reg[10])?(do_lazy_5?processed_len_5_op1_reg:processed_len_5_op2_reg):processed_len_5_op1_reg):processed_len_4_reg;
assign larray_5_s13 = (ldvalid_s12_reg[10] && max_reach_index_neq_k_s12_reg[10] && comp_5_processed_len_4_reg && (dist_valid_s12_reg[10]) && (do_lazy_5))?literals_s12_reg[87:80]:larray_5_s12_reg;
assign darray_5_s13 = (ldvalid_s12_reg[10] && max_reach_index_neq_k_s12_reg[10] && comp_5_processed_len_4_reg && (dist_valid_s12_reg[10]) && (do_lazy_5))?16'd0:darray_5_s12_reg;
assign ldvalid_s13 = (ldvalid_s12_reg[10] && max_reach_index_neq_k_s12_reg[10] && (~comp_5_processed_len_4_reg))?{ldvalid_s12_reg[15:11], 1'b0, ldvalid_s12_reg[9:0]}:ldvalid_s12_reg;

// comp_near_6 =1 means larray[6] >= larray[7]
adder_5bits adder_5bits_comp_near_6_U(	
	.a(larray_6_s12_reg[4:0]),
	.b(~larray_7_s12_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_6) 	
);

// 
adder_5bits comp_6_processed_len_5_U(
	.a(5'd6), 
	.b(~processed_len_5), 
	.ci(1'b1), 
	.s(), 
	.co(comp_6_processed_len_5)
);

assign processed_len_6_op1 = processed_len_5 + 5'd1;

assign processed_len_6_op2 = processed_len_5 + larray_6_plus_3_reg;

assign larray_7_plus_3 = larray_7_s12_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_5_reg_U(.d(processed_len_5), .clk(clk), .q(processed_len_5_reg));

register_compression #(.N(8)) larray_0_s13_reg_U(.d(larray_0_s12_reg), .clk(clk), .q(larray_0_s13_reg));
register_compression #(.N(8)) larray_1_s13_reg_U(.d(larray_1_s12_reg), .clk(clk), .q(larray_1_s13_reg));
register_compression #(.N(8)) larray_2_s13_reg_U(.d(larray_2_s12_reg), .clk(clk), .q(larray_2_s13_reg));
register_compression #(.N(8)) larray_3_s13_reg_U(.d(larray_3_s12_reg), .clk(clk), .q(larray_3_s13_reg));
register_compression #(.N(8)) larray_4_s13_reg_U(.d(larray_4_s12_reg), .clk(clk), .q(larray_4_s13_reg));
register_compression #(.N(8)) larray_5_s13_reg_U(.d(larray_5_s13), .clk(clk), .q(larray_5_s13_reg));
register_compression #(.N(8)) larray_6_s13_reg_U(.d(larray_6_s12_reg), .clk(clk), .q(larray_6_s13_reg));
register_compression #(.N(8)) larray_7_s13_reg_U(.d(larray_7_s12_reg), .clk(clk), .q(larray_7_s13_reg));
register_compression #(.N(8)) larray_8_s13_reg_U(.d(larray_8_s12_reg), .clk(clk), .q(larray_8_s13_reg));
register_compression #(.N(8)) larray_9_s13_reg_U(.d(larray_9_s12_reg), .clk(clk), .q(larray_9_s13_reg));
register_compression #(.N(8)) larray_10_s13_reg_U(.d(larray_10_s12_reg), .clk(clk), .q(larray_10_s13_reg));
register_compression #(.N(8)) larray_11_s13_reg_U(.d(larray_11_s12_reg), .clk(clk), .q(larray_11_s13_reg));
register_compression #(.N(8)) larray_12_s13_reg_U(.d(larray_12_s12_reg), .clk(clk), .q(larray_12_s13_reg));
register_compression #(.N(8)) larray_13_s13_reg_U(.d(larray_13_s12_reg), .clk(clk), .q(larray_13_s13_reg));
register_compression #(.N(8)) larray_14_s13_reg_U(.d(larray_14_s12_reg), .clk(clk), .q(larray_14_s13_reg));
register_compression #(.N(8)) larray_15_s13_reg_U(.d(larray_15_s12_reg), .clk(clk), .q(larray_15_s13_reg));

register_compression #(.N(16)) darray_0_s13_reg_U(.d(darray_0_s12_reg), .clk(clk), .q(darray_0_s13_reg));
register_compression #(.N(16)) darray_1_s13_reg_U(.d(darray_1_s12_reg), .clk(clk), .q(darray_1_s13_reg));
register_compression #(.N(16)) darray_2_s13_reg_U(.d(darray_2_s12_reg), .clk(clk), .q(darray_2_s13_reg));
register_compression #(.N(16)) darray_3_s13_reg_U(.d(darray_3_s12_reg), .clk(clk), .q(darray_3_s13_reg));
register_compression #(.N(16)) darray_4_s13_reg_U(.d(darray_4_s12_reg), .clk(clk), .q(darray_4_s13_reg));
register_compression #(.N(16)) darray_5_s13_reg_U(.d(darray_5_s13), .clk(clk), .q(darray_5_s13_reg));
register_compression #(.N(16)) darray_6_s13_reg_U(.d(darray_6_s12_reg), .clk(clk), .q(darray_6_s13_reg));
register_compression #(.N(16)) darray_7_s13_reg_U(.d(darray_7_s12_reg), .clk(clk), .q(darray_7_s13_reg));
register_compression #(.N(16)) darray_8_s13_reg_U(.d(darray_8_s12_reg), .clk(clk), .q(darray_8_s13_reg));
register_compression #(.N(16)) darray_9_s13_reg_U(.d(darray_9_s12_reg), .clk(clk), .q(darray_9_s13_reg));
register_compression #(.N(16)) darray_10_s13_reg_U(.d(darray_10_s12_reg), .clk(clk), .q(darray_10_s13_reg));
register_compression #(.N(16)) darray_11_s13_reg_U(.d(darray_11_s12_reg), .clk(clk), .q(darray_11_s13_reg));
register_compression #(.N(16)) darray_12_s13_reg_U(.d(darray_12_s12_reg), .clk(clk), .q(darray_12_s13_reg));
register_compression #(.N(16)) darray_13_s13_reg_U(.d(darray_13_s12_reg), .clk(clk), .q(darray_13_s13_reg));
register_compression #(.N(16)) darray_14_s13_reg_U(.d(darray_14_s12_reg), .clk(clk), .q(darray_14_s13_reg));
register_compression #(.N(16)) darray_15_s13_reg_U(.d(darray_15_s12_reg), .clk(clk), .q(darray_15_s13_reg));


register_compression #(.N(16)) register_ldvalid_s13_U(.d(ldvalid_s13), .clk(clk), .q(ldvalid_s13_reg));

register_compression #(.N(1)) comp_near_6_reg_U(.d(comp_near_6), .clk(clk), .q(comp_near_6_reg));

register_compression #(.N(1)) comp_6_processed_len_5_reg_U(.d(comp_6_processed_len_5), .clk(clk), .q(comp_6_processed_len_5_reg));

register_compression #(.N(5)) processed_len_6_op1_reg_U(.d(processed_len_6_op1), .clk(clk), .q(processed_len_6_op1_reg));
register_compression #(.N(5)) processed_len_6_op2_reg_U(.d(processed_len_6_op2), .clk(clk), .q(processed_len_6_op2_reg));

register_compression #(.N(5)) larray_7_plus_3_reg_U(.d(larray_7_plus_3), .clk(clk), .q(larray_7_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s13_reg_U(.d(max_reach_index_neq_k_s12_reg), .clk(clk), .q(max_reach_index_neq_k_s13_reg));

register_compression #(.N(16)) dist_valid_s13_reg_U(.d(dist_valid_s12_reg), .clk(clk), .q(dist_valid_s13_reg));

register_compression #(.N(128)) literals_s13_reg_U(.d(literals_s12_reg), .clk(clk), .q(literals_s13_reg));

register_compression #(.N(1)) register_en_s13_U(.d(en_s12_reg), .clk(clk), .q(en_s13_reg));
register_compression #(.N(1)) register_start_s13_U(.d(start_s12_reg), .clk(clk), .q(start_s13_reg));
register_compression #(.N(1)) register_last_s13_U(.d(last_s12_reg), .clk(clk), .q(last_s13_reg));


// ====================================================================
//
//  Stage 14: prepare the lazy evaluation for byte 7 and perform 
// 			 lazy evaluation for byte 6
//
// ====================================================================

// stage 14 ports definition
// 
wire 			do_lazy_6;

// 
wire	[4:0]	processed_len_6;
wire	[4:0]	processed_len_6_reg;

// 
wire	[7:0]	larray_6_s14;

wire	[7:0]	larray_0_s14_reg;
wire	[7:0]	larray_1_s14_reg;
wire	[7:0]	larray_2_s14_reg;
wire	[7:0]	larray_3_s14_reg;
wire	[7:0]	larray_4_s14_reg;
wire	[7:0]	larray_5_s14_reg;
wire	[7:0]	larray_6_s14_reg;
wire	[7:0]	larray_7_s14_reg;
wire	[7:0]	larray_8_s14_reg;
wire	[7:0]	larray_9_s14_reg;
wire	[7:0]	larray_10_s14_reg;
wire	[7:0]	larray_11_s14_reg;
wire	[7:0]	larray_12_s14_reg;
wire	[7:0]	larray_13_s14_reg;
wire	[7:0]	larray_14_s14_reg;
wire	[7:0]	larray_15_s14_reg;

// 
wire	[15:0]	darray_6_s14;

wire	[15:0]	darray_0_s14_reg;
wire	[15:0]	darray_1_s14_reg;
wire	[15:0]	darray_2_s14_reg;
wire	[15:0]	darray_3_s14_reg;
wire	[15:0]	darray_4_s14_reg;
wire	[15:0]	darray_5_s14_reg;
wire	[15:0]	darray_6_s14_reg;
wire	[15:0]	darray_7_s14_reg;
wire	[15:0]	darray_8_s14_reg;
wire	[15:0]	darray_9_s14_reg;
wire	[15:0]	darray_10_s14_reg;
wire	[15:0]	darray_11_s14_reg;
wire	[15:0]	darray_12_s14_reg;
wire	[15:0]	darray_13_s14_reg;
wire	[15:0]	darray_14_s14_reg;
wire	[15:0]	darray_15_s14_reg;

// 
wire	[15:0]	ldvalid_s14;
wire	[15:0]	ldvalid_s14_reg;

// 
wire			comp_near_7;
wire			comp_near_7_reg;

// 0 means 7 < processed_len_6
wire			comp_7_processed_len_6;
wire			comp_7_processed_len_6_reg;

// 
wire	[4:0]	processed_len_7_op1;
wire	[4:0]	processed_len_7_op2;

wire	[4:0]	processed_len_7_op1_reg;
wire	[4:0]	processed_len_7_op2_reg;

// 
wire	[4:0]   larray_8_plus_3;
wire	[4:0]   larray_8_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s14_reg;

wire	[15:0]	dist_valid_s14_reg;

// 
wire	[127:0] literals_s14_reg;

// 
wire 				en_s14_reg;
wire 				start_s14_reg;
wire 				last_s14_reg;

// stage 14
// do the lazy evaluation for k = 6
// prepare the lazy evaluation for k = 7
assign do_lazy_6 = (ldvalid_s13_reg[8]) && (dist_valid_s13_reg[8]) && (~comp_near_6_reg);
assign processed_len_6 = (ldvalid_s13_reg[9] && max_reach_index_neq_k_s13_reg[9] && comp_6_processed_len_5_reg)?((dist_valid_s13_reg[9])?(do_lazy_6?processed_len_6_op1_reg:processed_len_6_op2_reg):processed_len_6_op1_reg):processed_len_5_reg;
assign larray_6_s14 = (ldvalid_s13_reg[9] && max_reach_index_neq_k_s13_reg[9] && comp_6_processed_len_5_reg && (dist_valid_s13_reg[9]) && (do_lazy_6))?literals_s13_reg[79:72]:larray_6_s13_reg;
assign darray_6_s14 = (ldvalid_s13_reg[9] && max_reach_index_neq_k_s13_reg[9] && comp_6_processed_len_5_reg && (dist_valid_s13_reg[9]) && (do_lazy_6))?16'd0:darray_6_s13_reg;
assign ldvalid_s14 = (ldvalid_s13_reg[9] && max_reach_index_neq_k_s13_reg[9] && (~comp_6_processed_len_5_reg))?{ldvalid_s13_reg[15:10], 1'b0, ldvalid_s13_reg[8:0]}:ldvalid_s13_reg;

// comp_near_7 =1 means larray[7] >= larray[8]
adder_5bits adder_5bits_comp_near_7_U(	
	.a(larray_7_s13_reg[4:0]),
	.b(~larray_8_s13_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_7) 	
);

// 
adder_5bits comp_7_processed_len_6_U(
	.a(5'd7), 
	.b(~processed_len_6), 
	.ci(1'b1), 
	.s(), 
	.co(comp_7_processed_len_6)
);

// 
assign processed_len_7_op1 = processed_len_6 + 5'd1;

assign processed_len_7_op2 = processed_len_6 + larray_7_plus_3_reg;

assign larray_8_plus_3 = larray_8_s13_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_6_reg_U(.d(processed_len_6), .clk(clk), .q(processed_len_6_reg));

register_compression #(.N(8)) larray_0_s14_reg_U(.d(larray_0_s13_reg), .clk(clk), .q(larray_0_s14_reg));
register_compression #(.N(8)) larray_1_s14_reg_U(.d(larray_1_s13_reg), .clk(clk), .q(larray_1_s14_reg));
register_compression #(.N(8)) larray_2_s14_reg_U(.d(larray_2_s13_reg), .clk(clk), .q(larray_2_s14_reg));
register_compression #(.N(8)) larray_3_s14_reg_U(.d(larray_3_s13_reg), .clk(clk), .q(larray_3_s14_reg));
register_compression #(.N(8)) larray_4_s14_reg_U(.d(larray_4_s13_reg), .clk(clk), .q(larray_4_s14_reg));
register_compression #(.N(8)) larray_5_s14_reg_U(.d(larray_5_s13_reg), .clk(clk), .q(larray_5_s14_reg));
register_compression #(.N(8)) larray_6_s14_reg_U(.d(larray_6_s14), .clk(clk), .q(larray_6_s14_reg));
register_compression #(.N(8)) larray_7_s14_reg_U(.d(larray_7_s13_reg), .clk(clk), .q(larray_7_s14_reg));
register_compression #(.N(8)) larray_8_s14_reg_U(.d(larray_8_s13_reg), .clk(clk), .q(larray_8_s14_reg));
register_compression #(.N(8)) larray_9_s14_reg_U(.d(larray_9_s13_reg), .clk(clk), .q(larray_9_s14_reg));
register_compression #(.N(8)) larray_10_s14_reg_U(.d(larray_10_s13_reg), .clk(clk), .q(larray_10_s14_reg));
register_compression #(.N(8)) larray_11_s14_reg_U(.d(larray_11_s13_reg), .clk(clk), .q(larray_11_s14_reg));
register_compression #(.N(8)) larray_12_s14_reg_U(.d(larray_12_s13_reg), .clk(clk), .q(larray_12_s14_reg));
register_compression #(.N(8)) larray_13_s14_reg_U(.d(larray_13_s13_reg), .clk(clk), .q(larray_13_s14_reg));
register_compression #(.N(8)) larray_14_s14_reg_U(.d(larray_14_s13_reg), .clk(clk), .q(larray_14_s14_reg));
register_compression #(.N(8)) larray_15_s14_reg_U(.d(larray_15_s13_reg), .clk(clk), .q(larray_15_s14_reg));

register_compression #(.N(16)) darray_0_s14_reg_U(.d(darray_0_s13_reg), .clk(clk), .q(darray_0_s14_reg));
register_compression #(.N(16)) darray_1_s14_reg_U(.d(darray_1_s13_reg), .clk(clk), .q(darray_1_s14_reg));
register_compression #(.N(16)) darray_2_s14_reg_U(.d(darray_2_s13_reg), .clk(clk), .q(darray_2_s14_reg));
register_compression #(.N(16)) darray_3_s14_reg_U(.d(darray_3_s13_reg), .clk(clk), .q(darray_3_s14_reg));
register_compression #(.N(16)) darray_4_s14_reg_U(.d(darray_4_s13_reg), .clk(clk), .q(darray_4_s14_reg));
register_compression #(.N(16)) darray_5_s14_reg_U(.d(darray_5_s13_reg), .clk(clk), .q(darray_5_s14_reg));
register_compression #(.N(16)) darray_6_s14_reg_U(.d(darray_6_s14), .clk(clk), .q(darray_6_s14_reg));
register_compression #(.N(16)) darray_7_s14_reg_U(.d(darray_7_s13_reg), .clk(clk), .q(darray_7_s14_reg));
register_compression #(.N(16)) darray_8_s14_reg_U(.d(darray_8_s13_reg), .clk(clk), .q(darray_8_s14_reg));
register_compression #(.N(16)) darray_9_s14_reg_U(.d(darray_9_s13_reg), .clk(clk), .q(darray_9_s14_reg));
register_compression #(.N(16)) darray_10_s14_reg_U(.d(darray_10_s13_reg), .clk(clk), .q(darray_10_s14_reg));
register_compression #(.N(16)) darray_11_s14_reg_U(.d(darray_11_s13_reg), .clk(clk), .q(darray_11_s14_reg));
register_compression #(.N(16)) darray_12_s14_reg_U(.d(darray_12_s13_reg), .clk(clk), .q(darray_12_s14_reg));
register_compression #(.N(16)) darray_13_s14_reg_U(.d(darray_13_s13_reg), .clk(clk), .q(darray_13_s14_reg));
register_compression #(.N(16)) darray_14_s14_reg_U(.d(darray_14_s13_reg), .clk(clk), .q(darray_14_s14_reg));
register_compression #(.N(16)) darray_15_s14_reg_U(.d(darray_15_s13_reg), .clk(clk), .q(darray_15_s14_reg));


register_compression #(.N(16)) register_ldvalid_s14_U(.d(ldvalid_s14), .clk(clk), .q(ldvalid_s14_reg));

register_compression #(.N(1)) comp_near_7_reg_U(.d(comp_near_7), .clk(clk), .q(comp_near_7_reg));

register_compression #(.N(1)) comp_7_processed_len_6_reg_U(.d(comp_7_processed_len_6), .clk(clk), .q(comp_7_processed_len_6_reg));

register_compression #(.N(5)) processed_len_7_op1_reg_U(.d(processed_len_7_op1), .clk(clk), .q(processed_len_7_op1_reg));
register_compression #(.N(5)) processed_len_7_op2_reg_U(.d(processed_len_7_op2), .clk(clk), .q(processed_len_7_op2_reg));

register_compression #(.N(5)) larray_8_plus_3_reg_U(.d(larray_8_plus_3), .clk(clk), .q(larray_8_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s14_reg_U(.d(max_reach_index_neq_k_s13_reg), .clk(clk), .q(max_reach_index_neq_k_s14_reg));

register_compression #(.N(16)) dist_valid_s14_reg_U(.d(dist_valid_s13_reg), .clk(clk), .q(dist_valid_s14_reg));

register_compression #(.N(128)) literals_s14_reg_U(.d(literals_s13_reg), .clk(clk), .q(literals_s14_reg));

register_compression #(.N(1)) register_en_s14_U(.d(en_s13_reg), .clk(clk), .q(en_s14_reg));
register_compression #(.N(1)) register_start_s14_U(.d(start_s13_reg), .clk(clk), .q(start_s14_reg));
register_compression #(.N(1)) register_last_s14_U(.d(last_s13_reg), .clk(clk), .q(last_s14_reg));


// ====================================================================
//
//  Stage 15: prepare the lazy evaluation for byte 8 and perform 
// 			 lazy evaluation for byte 7
//
// ====================================================================

// stage 15 ports definition
// 
wire 			do_lazy_7;

// 
wire	[4:0]	processed_len_7;
wire	[4:0]	processed_len_7_reg;

// 
wire	[7:0]	larray_7_s15;

wire	[7:0]	larray_0_s15_reg;
wire	[7:0]	larray_1_s15_reg;
wire	[7:0]	larray_2_s15_reg;
wire	[7:0]	larray_3_s15_reg;
wire	[7:0]	larray_4_s15_reg;
wire	[7:0]	larray_5_s15_reg;
wire	[7:0]	larray_6_s15_reg;
wire	[7:0]	larray_7_s15_reg;
wire	[7:0]	larray_8_s15_reg;
wire	[7:0]	larray_9_s15_reg;
wire	[7:0]	larray_10_s15_reg;
wire	[7:0]	larray_11_s15_reg;
wire	[7:0]	larray_12_s15_reg;
wire	[7:0]	larray_13_s15_reg;
wire	[7:0]	larray_14_s15_reg;
wire	[7:0]	larray_15_s15_reg;

// 
wire	[15:0]	darray_7_s15;

wire	[15:0]	darray_0_s15_reg;
wire	[15:0]	darray_1_s15_reg;
wire	[15:0]	darray_2_s15_reg;
wire	[15:0]	darray_3_s15_reg;
wire	[15:0]	darray_4_s15_reg;
wire	[15:0]	darray_5_s15_reg;
wire	[15:0]	darray_6_s15_reg;
wire	[15:0]	darray_7_s15_reg;
wire	[15:0]	darray_8_s15_reg;
wire	[15:0]	darray_9_s15_reg;
wire	[15:0]	darray_10_s15_reg;
wire	[15:0]	darray_11_s15_reg;
wire	[15:0]	darray_12_s15_reg;
wire	[15:0]	darray_13_s15_reg;
wire	[15:0]	darray_14_s15_reg;
wire	[15:0]	darray_15_s15_reg;

// 
wire	[15:0]	ldvalid_s15;
wire	[15:0]	ldvalid_s15_reg;

// 
wire			comp_near_8;
wire			comp_near_8_reg;

// 0 means 8 < processed_len_7
wire			comp_8_processed_len_7;
wire			comp_8_processed_len_7_reg;

// 
wire	[4:0]	processed_len_8_op1;
wire	[4:0]	processed_len_8_op2;

wire	[4:0]	processed_len_8_op1_reg;
wire	[4:0]	processed_len_8_op2_reg;

// 
wire	[4:0]   larray_9_plus_3;
wire	[4:0]   larray_9_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s15_reg;

wire	[15:0]	dist_valid_s15_reg;

// 
wire	[127:0] 	literals_s15_reg;

// 
wire 				en_s15_reg;
wire 				start_s15_reg;
wire 				last_s15_reg;

// stage 15
// do the lazy evaluation for k = 7
// prepare the lazy evaluation for k = 8
assign do_lazy_7 = (ldvalid_s14_reg[7]) && (dist_valid_s14_reg[7]) && (~comp_near_7_reg);
assign processed_len_7 = (ldvalid_s14_reg[8] && max_reach_index_neq_k_s14_reg[8] && comp_7_processed_len_6_reg)?((dist_valid_s14_reg[8])?(do_lazy_7?processed_len_7_op1_reg:processed_len_7_op2_reg):processed_len_7_op1_reg):processed_len_6_reg;
assign larray_7_s15 = (ldvalid_s14_reg[8] && max_reach_index_neq_k_s14_reg[8] && comp_7_processed_len_6_reg && (dist_valid_s14_reg[8]) && (do_lazy_7))?literals_s14_reg[71:64]:larray_7_s14_reg;
assign darray_7_s15 = (ldvalid_s14_reg[8] && max_reach_index_neq_k_s14_reg[8] && comp_7_processed_len_6_reg && (dist_valid_s14_reg[8]) && (do_lazy_7))?16'd0:darray_7_s14_reg;
assign ldvalid_s15 = (ldvalid_s14_reg[8] && max_reach_index_neq_k_s14_reg[8] && (~comp_7_processed_len_6_reg))?{ldvalid_s14_reg[15:9], 1'b0, ldvalid_s14_reg[7:0]}:ldvalid_s14_reg;

// comp_near_8 =1 means larray[8] >= larray[9]
adder_5bits adder_5bits_comp_near_8_U(	
	.a(larray_8_s14_reg[4:0]),
	.b(~larray_9_s14_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_8) 	
);

// 
adder_5bits comp_8_processed_len_7_U(
	.a(5'd8), 
	.b(~processed_len_7), 
	.ci(1'b1), 
	.s(), 
	.co(comp_8_processed_len_7)
);

// 
assign processed_len_8_op1 = processed_len_7 + 5'd1;

assign processed_len_8_op2 = processed_len_7 + larray_8_plus_3_reg;

assign larray_9_plus_3 = larray_9_s14_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_7_reg_U(.d(processed_len_7), .clk(clk), .q(processed_len_7_reg));

register_compression #(.N(8)) larray_0_s15_reg_U(.d(larray_0_s14_reg), .clk(clk), .q(larray_0_s15_reg));
register_compression #(.N(8)) larray_1_s15_reg_U(.d(larray_1_s14_reg), .clk(clk), .q(larray_1_s15_reg));
register_compression #(.N(8)) larray_2_s15_reg_U(.d(larray_2_s14_reg), .clk(clk), .q(larray_2_s15_reg));
register_compression #(.N(8)) larray_3_s15_reg_U(.d(larray_3_s14_reg), .clk(clk), .q(larray_3_s15_reg));
register_compression #(.N(8)) larray_4_s15_reg_U(.d(larray_4_s14_reg), .clk(clk), .q(larray_4_s15_reg));
register_compression #(.N(8)) larray_5_s15_reg_U(.d(larray_5_s14_reg), .clk(clk), .q(larray_5_s15_reg));
register_compression #(.N(8)) larray_6_s15_reg_U(.d(larray_6_s14_reg), .clk(clk), .q(larray_6_s15_reg));
register_compression #(.N(8)) larray_7_s15_reg_U(.d(larray_7_s15), .clk(clk), .q(larray_7_s15_reg));
register_compression #(.N(8)) larray_8_s15_reg_U(.d(larray_8_s14_reg), .clk(clk), .q(larray_8_s15_reg));
register_compression #(.N(8)) larray_9_s15_reg_U(.d(larray_9_s14_reg), .clk(clk), .q(larray_9_s15_reg));
register_compression #(.N(8)) larray_10_s15_reg_U(.d(larray_10_s14_reg), .clk(clk), .q(larray_10_s15_reg));
register_compression #(.N(8)) larray_11_s15_reg_U(.d(larray_11_s14_reg), .clk(clk), .q(larray_11_s15_reg));
register_compression #(.N(8)) larray_12_s15_reg_U(.d(larray_12_s14_reg), .clk(clk), .q(larray_12_s15_reg));
register_compression #(.N(8)) larray_13_s15_reg_U(.d(larray_13_s14_reg), .clk(clk), .q(larray_13_s15_reg));
register_compression #(.N(8)) larray_14_s15_reg_U(.d(larray_14_s14_reg), .clk(clk), .q(larray_14_s15_reg));
register_compression #(.N(8)) larray_15_s15_reg_U(.d(larray_15_s14_reg), .clk(clk), .q(larray_15_s15_reg));

register_compression #(.N(16)) darray_0_s15_reg_U(.d(darray_0_s14_reg), .clk(clk), .q(darray_0_s15_reg));
register_compression #(.N(16)) darray_1_s15_reg_U(.d(darray_1_s14_reg), .clk(clk), .q(darray_1_s15_reg));
register_compression #(.N(16)) darray_2_s15_reg_U(.d(darray_2_s14_reg), .clk(clk), .q(darray_2_s15_reg));
register_compression #(.N(16)) darray_3_s15_reg_U(.d(darray_3_s14_reg), .clk(clk), .q(darray_3_s15_reg));
register_compression #(.N(16)) darray_4_s15_reg_U(.d(darray_4_s14_reg), .clk(clk), .q(darray_4_s15_reg));
register_compression #(.N(16)) darray_5_s15_reg_U(.d(darray_5_s14_reg), .clk(clk), .q(darray_5_s15_reg));
register_compression #(.N(16)) darray_6_s15_reg_U(.d(darray_6_s14_reg), .clk(clk), .q(darray_6_s15_reg));
register_compression #(.N(16)) darray_7_s15_reg_U(.d(darray_7_s15), .clk(clk), .q(darray_7_s15_reg));
register_compression #(.N(16)) darray_8_s15_reg_U(.d(darray_8_s14_reg), .clk(clk), .q(darray_8_s15_reg));
register_compression #(.N(16)) darray_9_s15_reg_U(.d(darray_9_s14_reg), .clk(clk), .q(darray_9_s15_reg));
register_compression #(.N(16)) darray_10_s15_reg_U(.d(darray_10_s14_reg), .clk(clk), .q(darray_10_s15_reg));
register_compression #(.N(16)) darray_11_s15_reg_U(.d(darray_11_s14_reg), .clk(clk), .q(darray_11_s15_reg));
register_compression #(.N(16)) darray_12_s15_reg_U(.d(darray_12_s14_reg), .clk(clk), .q(darray_12_s15_reg));
register_compression #(.N(16)) darray_13_s15_reg_U(.d(darray_13_s14_reg), .clk(clk), .q(darray_13_s15_reg));
register_compression #(.N(16)) darray_14_s15_reg_U(.d(darray_14_s14_reg), .clk(clk), .q(darray_14_s15_reg));
register_compression #(.N(16)) darray_15_s15_reg_U(.d(darray_15_s14_reg), .clk(clk), .q(darray_15_s15_reg));


register_compression #(.N(16)) register_ldvalid_s15_U(.d(ldvalid_s15), .clk(clk), .q(ldvalid_s15_reg));

register_compression #(.N(1)) comp_near_8_reg_U(.d(comp_near_8), .clk(clk), .q(comp_near_8_reg));

register_compression #(.N(1)) comp_8_processed_len_7_reg_U(.d(comp_8_processed_len_7), .clk(clk), .q(comp_8_processed_len_7_reg));

register_compression #(.N(5)) processed_len_8_op1_reg_U(.d(processed_len_8_op1), .clk(clk), .q(processed_len_8_op1_reg));
register_compression #(.N(5)) processed_len_8_op2_reg_U(.d(processed_len_8_op2), .clk(clk), .q(processed_len_8_op2_reg));

register_compression #(.N(5)) larray_9_plus_3_reg_U(.d(larray_9_plus_3), .clk(clk), .q(larray_9_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s15_reg_U(.d(max_reach_index_neq_k_s14_reg), .clk(clk), .q(max_reach_index_neq_k_s15_reg));

register_compression #(.N(16)) dist_valid_s15_reg_U(.d(dist_valid_s14_reg), .clk(clk), .q(dist_valid_s15_reg));

register_compression #(.N(128)) literals_s15_reg_U(.d(literals_s14_reg), .clk(clk), .q(literals_s15_reg));

register_compression #(.N(1)) register_en_s15_U(.d(en_s14_reg), .clk(clk), .q(en_s15_reg));
register_compression #(.N(1)) register_start_s15_U(.d(start_s14_reg), .clk(clk), .q(start_s15_reg));
register_compression #(.N(1)) register_last_s15_U(.d(last_s14_reg), .clk(clk), .q(last_s15_reg));


// ====================================================================
//
//  Stage 16: prepare the lazy evaluation for byte 9 and perform 
// 			 lazy evaluation for byte 8
//
// ====================================================================

// stage 16 ports definition
// 
wire 			do_lazy_8;

// 
wire	[4:0]	processed_len_8;
wire	[4:0]	processed_len_8_reg;

// 
wire	[7:0]	larray_8_s16;

wire	[7:0]	larray_0_s16_reg;
wire	[7:0]	larray_1_s16_reg;
wire	[7:0]	larray_2_s16_reg;
wire	[7:0]	larray_3_s16_reg;
wire	[7:0]	larray_4_s16_reg;
wire	[7:0]	larray_5_s16_reg;
wire	[7:0]	larray_6_s16_reg;
wire	[7:0]	larray_7_s16_reg;
wire	[7:0]	larray_8_s16_reg;
wire	[7:0]	larray_9_s16_reg;
wire	[7:0]	larray_10_s16_reg;
wire	[7:0]	larray_11_s16_reg;
wire	[7:0]	larray_12_s16_reg;
wire	[7:0]	larray_13_s16_reg;
wire	[7:0]	larray_14_s16_reg;
wire	[7:0]	larray_15_s16_reg;

// 
wire	[15:0]	darray_8_s16;

wire	[15:0]	darray_0_s16_reg;
wire	[15:0]	darray_1_s16_reg;
wire	[15:0]	darray_2_s16_reg;
wire	[15:0]	darray_3_s16_reg;
wire	[15:0]	darray_4_s16_reg;
wire	[15:0]	darray_5_s16_reg;
wire	[15:0]	darray_6_s16_reg;
wire	[15:0]	darray_7_s16_reg;
wire	[15:0]	darray_8_s16_reg;
wire	[15:0]	darray_9_s16_reg;
wire	[15:0]	darray_10_s16_reg;
wire	[15:0]	darray_11_s16_reg;
wire	[15:0]	darray_12_s16_reg;
wire	[15:0]	darray_13_s16_reg;
wire	[15:0]	darray_14_s16_reg;
wire	[15:0]	darray_15_s16_reg;

// 
wire	[15:0]	ldvalid_s16;
wire	[15:0]	ldvalid_s16_reg;

// 
wire			comp_near_9;
wire			comp_near_9_reg;

// 0 means 9 < processed_len_8
wire			comp_9_processed_len_8;
wire			comp_9_processed_len_8_reg;

// 
wire	[4:0]	processed_len_9_op1;
wire	[4:0]	processed_len_9_op2;

wire	[4:0]	processed_len_9_op1_reg;
wire	[4:0]	processed_len_9_op2_reg;

// 
wire	[4:0]   larray_10_plus_3;
wire	[4:0]   larray_10_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s16_reg;

wire	[15:0]	dist_valid_s16_reg;

// 
wire	[127:0] 	literals_s16_reg;

// 
wire 				en_s16_reg;
wire 				start_s16_reg;
wire 				last_s16_reg;

// stage 16
// do the lazy evaluation for k = 8
// prepare the lazy evaluation for k = 9
assign do_lazy_8 = (ldvalid_s15_reg[6]) && (dist_valid_s15_reg[6]) && (~comp_near_8_reg);
assign processed_len_8 = (ldvalid_s15_reg[7] && max_reach_index_neq_k_s15_reg[7] && comp_8_processed_len_7_reg)?((dist_valid_s15_reg[7])?(do_lazy_8?processed_len_8_op1_reg:processed_len_8_op2_reg):processed_len_8_op1_reg):processed_len_7_reg;
assign larray_8_s16 = (ldvalid_s15_reg[7] && max_reach_index_neq_k_s15_reg[7] && comp_8_processed_len_7_reg && (dist_valid_s15_reg[7]) && (do_lazy_8))?literals_s15_reg[63:56]:larray_8_s15_reg;
assign darray_8_s16 = (ldvalid_s15_reg[7] && max_reach_index_neq_k_s15_reg[7] && comp_8_processed_len_7_reg && (dist_valid_s15_reg[7]) && (do_lazy_8))?16'd0:darray_8_s15_reg;
assign ldvalid_s16 = (ldvalid_s15_reg[7] && max_reach_index_neq_k_s15_reg[7] && (~comp_8_processed_len_7_reg))?{ldvalid_s15_reg[15:8], 1'b0, ldvalid_s15_reg[6:0]}:ldvalid_s15_reg;

// comp_near_9 =1 means larray[9] >= larray[10]
adder_5bits adder_5bits_comp_near_9_U(	
	.a(larray_9_s15_reg[4:0]),
	.b(~larray_10_s15_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_9) 	
);

// 
adder_5bits comp_9_processed_len_8_U(
	.a(5'd9), 
	.b(~processed_len_8), 
	.ci(1'b1), 
	.s(), 
	.co(comp_9_processed_len_8)
);

// 
assign processed_len_9_op1 = processed_len_8 + 5'd1;

assign processed_len_9_op2 = processed_len_8 + larray_9_plus_3_reg;

assign larray_10_plus_3 = larray_10_s15_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_8_reg_U(.d(processed_len_8), .clk(clk), .q(processed_len_8_reg));

register_compression #(.N(8)) larray_0_s16_reg_U(.d(larray_0_s15_reg), .clk(clk), .q(larray_0_s16_reg));
register_compression #(.N(8)) larray_1_s16_reg_U(.d(larray_1_s15_reg), .clk(clk), .q(larray_1_s16_reg));
register_compression #(.N(8)) larray_2_s16_reg_U(.d(larray_2_s15_reg), .clk(clk), .q(larray_2_s16_reg));
register_compression #(.N(8)) larray_3_s16_reg_U(.d(larray_3_s15_reg), .clk(clk), .q(larray_3_s16_reg));
register_compression #(.N(8)) larray_4_s16_reg_U(.d(larray_4_s15_reg), .clk(clk), .q(larray_4_s16_reg));
register_compression #(.N(8)) larray_5_s16_reg_U(.d(larray_5_s15_reg), .clk(clk), .q(larray_5_s16_reg));
register_compression #(.N(8)) larray_6_s16_reg_U(.d(larray_6_s15_reg), .clk(clk), .q(larray_6_s16_reg));
register_compression #(.N(8)) larray_7_s16_reg_U(.d(larray_7_s15_reg), .clk(clk), .q(larray_7_s16_reg));
register_compression #(.N(8)) larray_8_s16_reg_U(.d(larray_8_s16), .clk(clk), .q(larray_8_s16_reg));
register_compression #(.N(8)) larray_9_s16_reg_U(.d(larray_9_s15_reg), .clk(clk), .q(larray_9_s16_reg));
register_compression #(.N(8)) larray_10_s16_reg_U(.d(larray_10_s15_reg), .clk(clk), .q(larray_10_s16_reg));
register_compression #(.N(8)) larray_11_s16_reg_U(.d(larray_11_s15_reg), .clk(clk), .q(larray_11_s16_reg));
register_compression #(.N(8)) larray_12_s16_reg_U(.d(larray_12_s15_reg), .clk(clk), .q(larray_12_s16_reg));
register_compression #(.N(8)) larray_13_s16_reg_U(.d(larray_13_s15_reg), .clk(clk), .q(larray_13_s16_reg));
register_compression #(.N(8)) larray_14_s16_reg_U(.d(larray_14_s15_reg), .clk(clk), .q(larray_14_s16_reg));
register_compression #(.N(8)) larray_15_s16_reg_U(.d(larray_15_s15_reg), .clk(clk), .q(larray_15_s16_reg));

register_compression #(.N(16)) darray_0_s16_reg_U(.d(darray_0_s15_reg), .clk(clk), .q(darray_0_s16_reg));
register_compression #(.N(16)) darray_1_s16_reg_U(.d(darray_1_s15_reg), .clk(clk), .q(darray_1_s16_reg));
register_compression #(.N(16)) darray_2_s16_reg_U(.d(darray_2_s15_reg), .clk(clk), .q(darray_2_s16_reg));
register_compression #(.N(16)) darray_3_s16_reg_U(.d(darray_3_s15_reg), .clk(clk), .q(darray_3_s16_reg));
register_compression #(.N(16)) darray_4_s16_reg_U(.d(darray_4_s15_reg), .clk(clk), .q(darray_4_s16_reg));
register_compression #(.N(16)) darray_5_s16_reg_U(.d(darray_5_s15_reg), .clk(clk), .q(darray_5_s16_reg));
register_compression #(.N(16)) darray_6_s16_reg_U(.d(darray_6_s15_reg), .clk(clk), .q(darray_6_s16_reg));
register_compression #(.N(16)) darray_7_s16_reg_U(.d(darray_7_s15_reg), .clk(clk), .q(darray_7_s16_reg));
register_compression #(.N(16)) darray_8_s16_reg_U(.d(darray_8_s16), .clk(clk), .q(darray_8_s16_reg));
register_compression #(.N(16)) darray_9_s16_reg_U(.d(darray_9_s15_reg), .clk(clk), .q(darray_9_s16_reg));
register_compression #(.N(16)) darray_10_s16_reg_U(.d(darray_10_s15_reg), .clk(clk), .q(darray_10_s16_reg));
register_compression #(.N(16)) darray_11_s16_reg_U(.d(darray_11_s15_reg), .clk(clk), .q(darray_11_s16_reg));
register_compression #(.N(16)) darray_12_s16_reg_U(.d(darray_12_s15_reg), .clk(clk), .q(darray_12_s16_reg));
register_compression #(.N(16)) darray_13_s16_reg_U(.d(darray_13_s15_reg), .clk(clk), .q(darray_13_s16_reg));
register_compression #(.N(16)) darray_14_s16_reg_U(.d(darray_14_s15_reg), .clk(clk), .q(darray_14_s16_reg));
register_compression #(.N(16)) darray_15_s16_reg_U(.d(darray_15_s15_reg), .clk(clk), .q(darray_15_s16_reg));


register_compression #(.N(16)) register_ldvalid_s16_U(.d(ldvalid_s16), .clk(clk), .q(ldvalid_s16_reg));

register_compression #(.N(1)) comp_near_9_reg_U(.d(comp_near_9), .clk(clk), .q(comp_near_9_reg));

register_compression #(.N(1)) comp_9_processed_len_8_reg_U(.d(comp_9_processed_len_8), .clk(clk), .q(comp_9_processed_len_8_reg));

register_compression #(.N(5)) processed_len_9_op1_reg_U(.d(processed_len_9_op1), .clk(clk), .q(processed_len_9_op1_reg));
register_compression #(.N(5)) processed_len_9_op2_reg_U(.d(processed_len_9_op2), .clk(clk), .q(processed_len_9_op2_reg));

register_compression #(.N(5)) larray_10_plus_3_reg_U(.d(larray_10_plus_3), .clk(clk), .q(larray_10_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s16_reg_U(.d(max_reach_index_neq_k_s15_reg), .clk(clk), .q(max_reach_index_neq_k_s16_reg));

register_compression #(.N(16)) dist_valid_s16_reg_U(.d(dist_valid_s15_reg), .clk(clk), .q(dist_valid_s16_reg));

register_compression #(.N(128)) literals_s16_reg_U(.d(literals_s15_reg), .clk(clk), .q(literals_s16_reg));

register_compression #(.N(1)) register_en_s16_U(.d(en_s15_reg), .clk(clk), .q(en_s16_reg));
register_compression #(.N(1)) register_start_s16_U(.d(start_s15_reg), .clk(clk), .q(start_s16_reg));
register_compression #(.N(1)) register_last_s16_U(.d(last_s15_reg), .clk(clk), .q(last_s16_reg));


// ====================================================================
//
//  Stage 17: prepare the lazy evaluation for byte 10 and perform 
// 			 lazy evaluation for byte 9
//
// ====================================================================

// stage 17 ports definition
// 
wire 			do_lazy_9;

// 
wire	[4:0]	processed_len_9;
wire	[4:0]	processed_len_9_reg;

// 
wire	[7:0]	larray_9_s17;

wire	[7:0]	larray_0_s17_reg;
wire	[7:0]	larray_1_s17_reg;
wire	[7:0]	larray_2_s17_reg;
wire	[7:0]	larray_3_s17_reg;
wire	[7:0]	larray_4_s17_reg;
wire	[7:0]	larray_5_s17_reg;
wire	[7:0]	larray_6_s17_reg;
wire	[7:0]	larray_7_s17_reg;
wire	[7:0]	larray_8_s17_reg;
wire	[7:0]	larray_9_s17_reg;
wire	[7:0]	larray_10_s17_reg;
wire	[7:0]	larray_11_s17_reg;
wire	[7:0]	larray_12_s17_reg;
wire	[7:0]	larray_13_s17_reg;
wire	[7:0]	larray_14_s17_reg;
wire	[7:0]	larray_15_s17_reg;

// 
wire	[15:0]	darray_9_s17;

wire	[15:0]	darray_0_s17_reg;
wire	[15:0]	darray_1_s17_reg;
wire	[15:0]	darray_2_s17_reg;
wire	[15:0]	darray_3_s17_reg;
wire	[15:0]	darray_4_s17_reg;
wire	[15:0]	darray_5_s17_reg;
wire	[15:0]	darray_6_s17_reg;
wire	[15:0]	darray_7_s17_reg;
wire	[15:0]	darray_8_s17_reg;
wire	[15:0]	darray_9_s17_reg;
wire	[15:0]	darray_10_s17_reg;
wire	[15:0]	darray_11_s17_reg;
wire	[15:0]	darray_12_s17_reg;
wire	[15:0]	darray_13_s17_reg;
wire	[15:0]	darray_14_s17_reg;
wire	[15:0]	darray_15_s17_reg;

// 
wire	[15:0]	ldvalid_s17;
wire	[15:0]	ldvalid_s17_reg;

// 
wire			comp_near_10;
wire			comp_near_10_reg;

// 0 means 10 < processed_len_9
wire			comp_10_processed_len_9;
wire			comp_10_processed_len_9_reg;	

// 
wire	[4:0]	processed_len_10_op1;
wire	[4:0]	processed_len_10_op2;

wire	[4:0]	processed_len_10_op1_reg;
wire	[4:0]	processed_len_10_op2_reg;

// 
wire	[4:0]   larray_11_plus_3;
wire	[4:0]   larray_11_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s17_reg;

wire	[15:0]	dist_valid_s17_reg;

// 
wire	[127:0] 	literals_s17_reg;

// 
wire 				en_s17_reg;
wire 				start_s17_reg;
wire 				last_s17_reg;

// stage 17
// do the lazy evaluation for k = 9
// prepare the lazy evaluation for k = 10
assign do_lazy_9 = (ldvalid_s16_reg[5]) && (dist_valid_s16_reg[5]) && (~comp_near_9_reg);
assign processed_len_9 = (ldvalid_s16_reg[6] && max_reach_index_neq_k_s16_reg[6] && comp_9_processed_len_8_reg)?((dist_valid_s16_reg[6])?(do_lazy_9?processed_len_9_op1_reg:processed_len_9_op2_reg):processed_len_9_op1_reg):processed_len_8_reg;
assign larray_9_s17 = (ldvalid_s16_reg[6] && max_reach_index_neq_k_s16_reg[6] && comp_9_processed_len_8_reg && (dist_valid_s16_reg[6]) && (do_lazy_9))?literals_s16_reg[55:48]:larray_9_s16_reg;
assign darray_9_s17 = (ldvalid_s16_reg[6] && max_reach_index_neq_k_s16_reg[6] && comp_9_processed_len_8_reg && (dist_valid_s16_reg[6]) && (do_lazy_9))?16'd0:darray_9_s16_reg;
assign ldvalid_s17 = (ldvalid_s16_reg[6] && max_reach_index_neq_k_s16_reg[6] && (~comp_9_processed_len_8_reg))?{ldvalid_s16_reg[15:7], 1'b0, ldvalid_s16_reg[5:0]}:ldvalid_s16_reg;

// comp_near_10 =1 means larray[10] >= larray[11]
adder_5bits adder_5bits_comp_near_10_U(	
	.a(larray_10_s16_reg[4:0]),
	.b(~larray_11_s16_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_10) 	
);

// 
adder_5bits comp_10_processed_len_9_U(
	.a(5'd10), 
	.b(~processed_len_9), 
	.ci(1'b1), 
	.s(), 
	.co(comp_10_processed_len_9)
);

// 
assign processed_len_10_op1 = processed_len_9 + 5'd1;

assign processed_len_10_op2 = processed_len_9 + larray_10_plus_3_reg;

assign larray_11_plus_3 = larray_11_s16_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_9_reg_U(.d(processed_len_9), .clk(clk), .q(processed_len_9_reg));

register_compression #(.N(8)) larray_0_s17_reg_U(.d(larray_0_s16_reg), .clk(clk), .q(larray_0_s17_reg));
register_compression #(.N(8)) larray_1_s17_reg_U(.d(larray_1_s16_reg), .clk(clk), .q(larray_1_s17_reg));
register_compression #(.N(8)) larray_2_s17_reg_U(.d(larray_2_s16_reg), .clk(clk), .q(larray_2_s17_reg));
register_compression #(.N(8)) larray_3_s17_reg_U(.d(larray_3_s16_reg), .clk(clk), .q(larray_3_s17_reg));
register_compression #(.N(8)) larray_4_s17_reg_U(.d(larray_4_s16_reg), .clk(clk), .q(larray_4_s17_reg));
register_compression #(.N(8)) larray_5_s17_reg_U(.d(larray_5_s16_reg), .clk(clk), .q(larray_5_s17_reg));
register_compression #(.N(8)) larray_6_s17_reg_U(.d(larray_6_s16_reg), .clk(clk), .q(larray_6_s17_reg));
register_compression #(.N(8)) larray_7_s17_reg_U(.d(larray_7_s16_reg), .clk(clk), .q(larray_7_s17_reg));
register_compression #(.N(8)) larray_8_s17_reg_U(.d(larray_8_s16_reg), .clk(clk), .q(larray_8_s17_reg));
register_compression #(.N(8)) larray_9_s17_reg_U(.d(larray_9_s17), .clk(clk), .q(larray_9_s17_reg));
register_compression #(.N(8)) larray_10_s17_reg_U(.d(larray_10_s16_reg), .clk(clk), .q(larray_10_s17_reg));
register_compression #(.N(8)) larray_11_s17_reg_U(.d(larray_11_s16_reg), .clk(clk), .q(larray_11_s17_reg));
register_compression #(.N(8)) larray_12_s17_reg_U(.d(larray_12_s16_reg), .clk(clk), .q(larray_12_s17_reg));
register_compression #(.N(8)) larray_13_s17_reg_U(.d(larray_13_s16_reg), .clk(clk), .q(larray_13_s17_reg));
register_compression #(.N(8)) larray_14_s17_reg_U(.d(larray_14_s16_reg), .clk(clk), .q(larray_14_s17_reg));
register_compression #(.N(8)) larray_15_s17_reg_U(.d(larray_15_s16_reg), .clk(clk), .q(larray_15_s17_reg));

register_compression #(.N(16)) darray_0_s17_reg_U(.d(darray_0_s16_reg), .clk(clk), .q(darray_0_s17_reg));
register_compression #(.N(16)) darray_1_s17_reg_U(.d(darray_1_s16_reg), .clk(clk), .q(darray_1_s17_reg));
register_compression #(.N(16)) darray_2_s17_reg_U(.d(darray_2_s16_reg), .clk(clk), .q(darray_2_s17_reg));
register_compression #(.N(16)) darray_3_s17_reg_U(.d(darray_3_s16_reg), .clk(clk), .q(darray_3_s17_reg));
register_compression #(.N(16)) darray_4_s17_reg_U(.d(darray_4_s16_reg), .clk(clk), .q(darray_4_s17_reg));
register_compression #(.N(16)) darray_5_s17_reg_U(.d(darray_5_s16_reg), .clk(clk), .q(darray_5_s17_reg));
register_compression #(.N(16)) darray_6_s17_reg_U(.d(darray_6_s16_reg), .clk(clk), .q(darray_6_s17_reg));
register_compression #(.N(16)) darray_7_s17_reg_U(.d(darray_7_s16_reg), .clk(clk), .q(darray_7_s17_reg));
register_compression #(.N(16)) darray_8_s17_reg_U(.d(darray_8_s16_reg), .clk(clk), .q(darray_8_s17_reg));
register_compression #(.N(16)) darray_9_s17_reg_U(.d(darray_9_s17), .clk(clk), .q(darray_9_s17_reg));
register_compression #(.N(16)) darray_10_s17_reg_U(.d(darray_10_s16_reg), .clk(clk), .q(darray_10_s17_reg));
register_compression #(.N(16)) darray_11_s17_reg_U(.d(darray_11_s16_reg), .clk(clk), .q(darray_11_s17_reg));
register_compression #(.N(16)) darray_12_s17_reg_U(.d(darray_12_s16_reg), .clk(clk), .q(darray_12_s17_reg));
register_compression #(.N(16)) darray_13_s17_reg_U(.d(darray_13_s16_reg), .clk(clk), .q(darray_13_s17_reg));
register_compression #(.N(16)) darray_14_s17_reg_U(.d(darray_14_s16_reg), .clk(clk), .q(darray_14_s17_reg));
register_compression #(.N(16)) darray_15_s17_reg_U(.d(darray_15_s16_reg), .clk(clk), .q(darray_15_s17_reg));


register_compression #(.N(16)) register_ldvalid_s17_U(.d(ldvalid_s17), .clk(clk), .q(ldvalid_s17_reg));

register_compression #(.N(1)) comp_near_10_reg_U(.d(comp_near_10), .clk(clk), .q(comp_near_10_reg));

register_compression #(.N(1)) comp_10_processed_len_9_reg_U(.d(comp_10_processed_len_9), .clk(clk), .q(comp_10_processed_len_9_reg));

register_compression #(.N(5)) processed_len_10_op1_reg_U(.d(processed_len_10_op1), .clk(clk), .q(processed_len_10_op1_reg));
register_compression #(.N(5)) processed_len_10_op2_reg_U(.d(processed_len_10_op2), .clk(clk), .q(processed_len_10_op2_reg));

register_compression #(.N(5)) larray_11_plus_3_reg_U(.d(larray_11_plus_3), .clk(clk), .q(larray_11_plus_3_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s17_reg_U(.d(max_reach_index_neq_k_s16_reg), .clk(clk), .q(max_reach_index_neq_k_s17_reg));

register_compression #(.N(16)) dist_valid_s17_reg_U(.d(dist_valid_s16_reg), .clk(clk), .q(dist_valid_s17_reg));

register_compression #(.N(128)) literals_s17_reg_U(.d(literals_s16_reg), .clk(clk), .q(literals_s17_reg));

register_compression #(.N(1)) register_en_s17_U(.d(en_s16_reg), .clk(clk), .q(en_s17_reg));
register_compression #(.N(1)) register_start_s17_U(.d(start_s16_reg), .clk(clk), .q(start_s17_reg));
register_compression #(.N(1)) register_last_s17_U(.d(last_s16_reg), .clk(clk), .q(last_s17_reg));


// ====================================================================
//
//  Stage 18: prepare the lazy evaluation for byte 11 and perform 
// 			 lazy evaluation for byte 10
//
// ====================================================================

// stage 18 ports definition
// 
wire 			do_lazy_10;

// 
wire	[4:0]	processed_len_10;
wire	[4:0]	processed_len_10_reg;

// 
wire	[7:0]	larray_10_s18;

wire	[7:0]	larray_0_s18_reg;
wire	[7:0]	larray_1_s18_reg;
wire	[7:0]	larray_2_s18_reg;
wire	[7:0]	larray_3_s18_reg;
wire	[7:0]	larray_4_s18_reg;
wire	[7:0]	larray_5_s18_reg;
wire	[7:0]	larray_6_s18_reg;
wire	[7:0]	larray_7_s18_reg;
wire	[7:0]	larray_8_s18_reg;
wire	[7:0]	larray_9_s18_reg;
wire	[7:0]	larray_10_s18_reg;
wire	[7:0]	larray_11_s18_reg;
wire	[7:0]	larray_12_s18_reg;
wire	[7:0]	larray_13_s18_reg;
wire	[7:0]	larray_14_s18_reg;
wire	[7:0]	larray_15_s18_reg;

// 
wire	[15:0]	darray_10_s18;

wire	[15:0]	darray_0_s18_reg;
wire	[15:0]	darray_1_s18_reg;
wire	[15:0]	darray_2_s18_reg;
wire	[15:0]	darray_3_s18_reg;
wire	[15:0]	darray_4_s18_reg;
wire	[15:0]	darray_5_s18_reg;
wire	[15:0]	darray_6_s18_reg;
wire	[15:0]	darray_7_s18_reg;
wire	[15:0]	darray_8_s18_reg;
wire	[15:0]	darray_9_s18_reg;
wire	[15:0]	darray_10_s18_reg;
wire	[15:0]	darray_11_s18_reg;
wire	[15:0]	darray_12_s18_reg;
wire	[15:0]	darray_13_s18_reg;
wire	[15:0]	darray_14_s18_reg;
wire	[15:0]	darray_15_s18_reg;

// 
wire	[15:0]	ldvalid_s18;
wire	[15:0]	ldvalid_s18_reg;

// 
wire			comp_near_11;
wire			comp_near_11_reg;

// 0 means 11 < processed_len_10
wire			comp_11_processed_len_10;
wire			comp_11_processed_len_10_reg;

// 
wire	[4:0]	processed_len_11_op1;
wire	[4:0]	processed_len_11_op2;

wire	[4:0]	processed_len_11_op1_reg;
wire	[4:0]	processed_len_11_op2_reg;

// 
wire	[4:0]   larray_12_plus_3;
wire	[4:0]   larray_12_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s18_reg;

wire	[15:0]	dist_valid_s18_reg;

// 
wire	[127:0] literals_s18_reg;

// 
wire 			en_s18_reg;
wire 			start_s18_reg;
wire 			last_s18_reg;

// stage 18
// do the lazy evaluation for k = 10
// prepare the lazy evaluation for k = 11
assign do_lazy_10 = (ldvalid_s17_reg[4]) && (dist_valid_s17_reg[4]) && (~comp_near_10_reg);
assign processed_len_10 = (ldvalid_s17_reg[5] && max_reach_index_neq_k_s17_reg[5] && comp_10_processed_len_9_reg)?((dist_valid_s17_reg[5])?(do_lazy_10?processed_len_10_op1_reg:processed_len_10_op2_reg):processed_len_10_op1_reg):processed_len_9_reg;
assign larray_10_s18 = (ldvalid_s17_reg[5] && max_reach_index_neq_k_s17_reg[5] && comp_10_processed_len_9_reg && (dist_valid_s17_reg[5]) && (do_lazy_10))?literals_s17_reg[47:40]:larray_10_s17_reg;
assign darray_10_s18 = (ldvalid_s17_reg[5] && max_reach_index_neq_k_s17_reg[5] && comp_10_processed_len_9_reg && (dist_valid_s17_reg[5]) && (do_lazy_10))?16'd0:darray_10_s17_reg;
assign ldvalid_s18 = (ldvalid_s17_reg[5] && max_reach_index_neq_k_s17_reg[5] && (~comp_10_processed_len_9_reg))?{ldvalid_s17_reg[15:6], 1'b0, ldvalid_s17_reg[4:0]}:ldvalid_s17_reg;

// comp_near_11 =1 means larray[11] >= larray[12]
adder_5bits adder_5bits_comp_near_11_U(	
	.a(larray_11_s17_reg[4:0]),
	.b(~larray_12_s17_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_11) 	
);

// 
adder_5bits comp_11_processed_len_10_U(
	.a(5'd11), 
	.b(~processed_len_10), 
	.ci(1'b1), 
	.s(), 
	.co(comp_11_processed_len_10)
);

// 
assign processed_len_11_op1 = processed_len_10 + 5'd1;

assign processed_len_11_op2 = processed_len_10 + larray_11_plus_3_reg;

assign larray_12_plus_3 = larray_12_s17_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_10_reg_U(.d(processed_len_10), .clk(clk), .q(processed_len_10_reg));

register_compression #(.N(8)) larray_0_s18_reg_U(.d(larray_0_s17_reg), .clk(clk), .q(larray_0_s18_reg));
register_compression #(.N(8)) larray_1_s18_reg_U(.d(larray_1_s17_reg), .clk(clk), .q(larray_1_s18_reg));
register_compression #(.N(8)) larray_2_s18_reg_U(.d(larray_2_s17_reg), .clk(clk), .q(larray_2_s18_reg));
register_compression #(.N(8)) larray_3_s18_reg_U(.d(larray_3_s17_reg), .clk(clk), .q(larray_3_s18_reg));
register_compression #(.N(8)) larray_4_s18_reg_U(.d(larray_4_s17_reg), .clk(clk), .q(larray_4_s18_reg));
register_compression #(.N(8)) larray_5_s18_reg_U(.d(larray_5_s17_reg), .clk(clk), .q(larray_5_s18_reg));
register_compression #(.N(8)) larray_6_s18_reg_U(.d(larray_6_s17_reg), .clk(clk), .q(larray_6_s18_reg));
register_compression #(.N(8)) larray_7_s18_reg_U(.d(larray_7_s17_reg), .clk(clk), .q(larray_7_s18_reg));
register_compression #(.N(8)) larray_8_s18_reg_U(.d(larray_8_s17_reg), .clk(clk), .q(larray_8_s18_reg));
register_compression #(.N(8)) larray_9_s18_reg_U(.d(larray_9_s17_reg), .clk(clk), .q(larray_9_s18_reg));
register_compression #(.N(8)) larray_10_s18_reg_U(.d(larray_10_s18), .clk(clk), .q(larray_10_s18_reg));
register_compression #(.N(8)) larray_11_s18_reg_U(.d(larray_11_s17_reg), .clk(clk), .q(larray_11_s18_reg));
register_compression #(.N(8)) larray_12_s18_reg_U(.d(larray_12_s17_reg), .clk(clk), .q(larray_12_s18_reg));
register_compression #(.N(8)) larray_13_s18_reg_U(.d(larray_13_s17_reg), .clk(clk), .q(larray_13_s18_reg));
register_compression #(.N(8)) larray_14_s18_reg_U(.d(larray_14_s17_reg), .clk(clk), .q(larray_14_s18_reg));
register_compression #(.N(8)) larray_15_s18_reg_U(.d(larray_15_s17_reg), .clk(clk), .q(larray_15_s18_reg));

register_compression #(.N(16)) darray_0_s18_reg_U(.d(darray_0_s17_reg), .clk(clk), .q(darray_0_s18_reg));
register_compression #(.N(16)) darray_1_s18_reg_U(.d(darray_1_s17_reg), .clk(clk), .q(darray_1_s18_reg));
register_compression #(.N(16)) darray_2_s18_reg_U(.d(darray_2_s17_reg), .clk(clk), .q(darray_2_s18_reg));
register_compression #(.N(16)) darray_3_s18_reg_U(.d(darray_3_s17_reg), .clk(clk), .q(darray_3_s18_reg));
register_compression #(.N(16)) darray_4_s18_reg_U(.d(darray_4_s17_reg), .clk(clk), .q(darray_4_s18_reg));
register_compression #(.N(16)) darray_5_s18_reg_U(.d(darray_5_s17_reg), .clk(clk), .q(darray_5_s18_reg));
register_compression #(.N(16)) darray_6_s18_reg_U(.d(darray_6_s17_reg), .clk(clk), .q(darray_6_s18_reg));
register_compression #(.N(16)) darray_7_s18_reg_U(.d(darray_7_s17_reg), .clk(clk), .q(darray_7_s18_reg));
register_compression #(.N(16)) darray_8_s18_reg_U(.d(darray_8_s17_reg), .clk(clk), .q(darray_8_s18_reg));
register_compression #(.N(16)) darray_9_s18_reg_U(.d(darray_9_s17_reg), .clk(clk), .q(darray_9_s18_reg));
register_compression #(.N(16)) darray_10_s18_reg_U(.d(darray_10_s18), .clk(clk), .q(darray_10_s18_reg));
register_compression #(.N(16)) darray_11_s18_reg_U(.d(darray_11_s17_reg), .clk(clk), .q(darray_11_s18_reg));
register_compression #(.N(16)) darray_12_s18_reg_U(.d(darray_12_s17_reg), .clk(clk), .q(darray_12_s18_reg));
register_compression #(.N(16)) darray_13_s18_reg_U(.d(darray_13_s17_reg), .clk(clk), .q(darray_13_s18_reg));
register_compression #(.N(16)) darray_14_s18_reg_U(.d(darray_14_s17_reg), .clk(clk), .q(darray_14_s18_reg));
register_compression #(.N(16)) darray_15_s18_reg_U(.d(darray_15_s17_reg), .clk(clk), .q(darray_15_s18_reg));


register_compression #(.N(1)) comp_near_11_reg_U(.d(comp_near_11), .clk(clk), .q(comp_near_11_reg));

register_compression #(.N(1)) comp_11_processed_len_10_reg_U(.d(comp_11_processed_len_10), .clk(clk), .q(comp_11_processed_len_10_reg));

register_compression #(.N(5)) processed_len_11_op1_reg_U(.d(processed_len_11_op1), .clk(clk), .q(processed_len_11_op1_reg));
register_compression #(.N(5)) processed_len_11_op2_reg_U(.d(processed_len_11_op2), .clk(clk), .q(processed_len_11_op2_reg));

register_compression #(.N(5)) larray_12_plus_3_reg_U(.d(larray_12_plus_3), .clk(clk), .q(larray_12_plus_3_reg));

register_compression #(.N(16)) register_ldvalid_s18_U(.d(ldvalid_s18), .clk(clk), .q(ldvalid_s18_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s18_reg_U(.d(max_reach_index_neq_k_s17_reg), .clk(clk), .q(max_reach_index_neq_k_s18_reg));

register_compression #(.N(16)) dist_valid_s18_reg_U(.d(dist_valid_s17_reg), .clk(clk), .q(dist_valid_s18_reg));

register_compression #(.N(128)) literals_s18_reg_U(.d(literals_s17_reg), .clk(clk), .q(literals_s18_reg));

register_compression #(.N(1)) register_en_s18_U(.d(en_s17_reg), .clk(clk), .q(en_s18_reg));
register_compression #(.N(1)) register_start_s18_U(.d(start_s17_reg), .clk(clk), .q(start_s18_reg));
register_compression #(.N(1)) register_last_s18_U(.d(last_s17_reg), .clk(clk), .q(last_s18_reg));


// ====================================================================
//
//  Stage 19: prepare the lazy evaluation for byte 12 and perform 
// 			 lazy evaluation for byte 11
//
// ====================================================================

// stage 19 ports definition
// 
wire 			do_lazy_11;

// 
wire	[4:0]	processed_len_11;
wire	[4:0]	processed_len_11_reg;

// 
wire	[7:0]	larray_11_s19;

wire	[7:0]	larray_0_s19_reg;
wire	[7:0]	larray_1_s19_reg;
wire	[7:0]	larray_2_s19_reg;
wire	[7:0]	larray_3_s19_reg;
wire	[7:0]	larray_4_s19_reg;
wire	[7:0]	larray_5_s19_reg;
wire	[7:0]	larray_6_s19_reg;
wire	[7:0]	larray_7_s19_reg;
wire	[7:0]	larray_8_s19_reg;
wire	[7:0]	larray_9_s19_reg;
wire	[7:0]	larray_10_s19_reg;
wire	[7:0]	larray_11_s19_reg;
wire	[7:0]	larray_12_s19_reg;
wire	[7:0]	larray_13_s19_reg;
wire	[7:0]	larray_14_s19_reg;
wire	[7:0]	larray_15_s19_reg;

// 
wire	[15:0]	darray_11_s19;

wire	[15:0]	darray_0_s19_reg;
wire	[15:0]	darray_1_s19_reg;
wire	[15:0]	darray_2_s19_reg;
wire	[15:0]	darray_3_s19_reg;
wire	[15:0]	darray_4_s19_reg;
wire	[15:0]	darray_5_s19_reg;
wire	[15:0]	darray_6_s19_reg;
wire	[15:0]	darray_7_s19_reg;
wire	[15:0]	darray_8_s19_reg;
wire	[15:0]	darray_9_s19_reg;
wire	[15:0]	darray_10_s19_reg;
wire	[15:0]	darray_11_s19_reg;
wire	[15:0]	darray_12_s19_reg;
wire	[15:0]	darray_13_s19_reg;
wire	[15:0]	darray_14_s19_reg;
wire	[15:0]	darray_15_s19_reg;

// 
wire	[15:0]	ldvalid_s19;
wire	[15:0]	ldvalid_s19_reg;

// 
wire			comp_near_12;
wire			comp_near_12_reg;

// 0 means k < processed_len_k-1
wire			comp_12_processed_len_11;
wire			comp_12_processed_len_11_reg;

// 
wire	[4:0]	processed_len_12_op1;
wire	[4:0]	processed_len_12_op2;

wire	[4:0]	processed_len_12_op1_reg;
wire	[4:0]	processed_len_12_op2_reg;

// 
wire	[4:0]   larray_13_plus_3;
wire	[4:0]   larray_13_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s19_reg;

wire	[15:0]	dist_valid_s19_reg;

// 
wire	[127:0] 	literals_s19_reg;

// 
wire 				en_s19_reg;
wire 				start_s19_reg;
wire 				last_s19_reg;

// stage 19
// do the lazy evaluation for k = 11
// prepare the lazy evaluation for k = 12
assign do_lazy_11 = (ldvalid_s18_reg[3]) && (dist_valid_s18_reg[3]) && (~comp_near_11_reg);
assign processed_len_11 = (ldvalid_s18_reg[4] && max_reach_index_neq_k_s18_reg[4] && comp_11_processed_len_10_reg)?((dist_valid_s18_reg[4])?(do_lazy_11?processed_len_11_op1_reg:processed_len_11_op2_reg):processed_len_11_op1_reg):processed_len_10_reg;
assign larray_11_s19 = (ldvalid_s18_reg[4] && max_reach_index_neq_k_s18_reg[4] && comp_11_processed_len_10_reg && (dist_valid_s18_reg[4]) && (do_lazy_11))?literals_s18_reg[39:32]:larray_11_s18_reg;
assign darray_11_s19 = (ldvalid_s18_reg[4] && max_reach_index_neq_k_s18_reg[4] && comp_11_processed_len_10_reg && (dist_valid_s18_reg[4]) && (do_lazy_11))?16'd0:darray_11_s18_reg;
assign ldvalid_s19 = (ldvalid_s18_reg[4] && max_reach_index_neq_k_s18_reg[4] && (~comp_11_processed_len_10_reg))?{ldvalid_s18_reg[15:5], 1'b0, ldvalid_s18_reg[3:0]}:ldvalid_s18_reg;

// comp_near_12 =1 means larray[12] >= larray[13]
adder_5bits adder_5bits_comp_near_12_U(	
	.a(larray_12_s18_reg[4:0]),
	.b(~larray_13_s18_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_12) 	
);

// 
adder_5bits comp_12_processed_len_11_U(
	.a(5'd12), 
	.b(~processed_len_11), 
	.ci(1'b1), 
	.s(), 
	.co(comp_12_processed_len_11)
);

// 
assign processed_len_12_op1 = processed_len_11 + 5'd1;

assign processed_len_12_op2 = processed_len_11 + larray_12_plus_3_reg;

assign larray_13_plus_3 = larray_13_s18_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_11_reg_U(.d(processed_len_11), .clk(clk), .q(processed_len_11_reg));

register_compression #(.N(8)) larray_0_s19_reg_U(.d(larray_0_s18_reg), .clk(clk), .q(larray_0_s19_reg));
register_compression #(.N(8)) larray_1_s19_reg_U(.d(larray_1_s18_reg), .clk(clk), .q(larray_1_s19_reg));
register_compression #(.N(8)) larray_2_s19_reg_U(.d(larray_2_s18_reg), .clk(clk), .q(larray_2_s19_reg));
register_compression #(.N(8)) larray_3_s19_reg_U(.d(larray_3_s18_reg), .clk(clk), .q(larray_3_s19_reg));
register_compression #(.N(8)) larray_4_s19_reg_U(.d(larray_4_s18_reg), .clk(clk), .q(larray_4_s19_reg));
register_compression #(.N(8)) larray_5_s19_reg_U(.d(larray_5_s18_reg), .clk(clk), .q(larray_5_s19_reg));
register_compression #(.N(8)) larray_6_s19_reg_U(.d(larray_6_s18_reg), .clk(clk), .q(larray_6_s19_reg));
register_compression #(.N(8)) larray_7_s19_reg_U(.d(larray_7_s18_reg), .clk(clk), .q(larray_7_s19_reg));
register_compression #(.N(8)) larray_8_s19_reg_U(.d(larray_8_s18_reg), .clk(clk), .q(larray_8_s19_reg));
register_compression #(.N(8)) larray_9_s19_reg_U(.d(larray_9_s18_reg), .clk(clk), .q(larray_9_s19_reg));
register_compression #(.N(8)) larray_10_s19_reg_U(.d(larray_10_s18_reg), .clk(clk), .q(larray_10_s19_reg));
register_compression #(.N(8)) larray_11_s19_reg_U(.d(larray_11_s19), .clk(clk), .q(larray_11_s19_reg));
register_compression #(.N(8)) larray_12_s19_reg_U(.d(larray_12_s18_reg), .clk(clk), .q(larray_12_s19_reg));
register_compression #(.N(8)) larray_13_s19_reg_U(.d(larray_13_s18_reg), .clk(clk), .q(larray_13_s19_reg));
register_compression #(.N(8)) larray_14_s19_reg_U(.d(larray_14_s18_reg), .clk(clk), .q(larray_14_s19_reg));
register_compression #(.N(8)) larray_15_s19_reg_U(.d(larray_15_s18_reg), .clk(clk), .q(larray_15_s19_reg));

register_compression #(.N(16)) darray_0_s19_reg_U(.d(darray_0_s18_reg), .clk(clk), .q(darray_0_s19_reg));
register_compression #(.N(16)) darray_1_s19_reg_U(.d(darray_1_s18_reg), .clk(clk), .q(darray_1_s19_reg));
register_compression #(.N(16)) darray_2_s19_reg_U(.d(darray_2_s18_reg), .clk(clk), .q(darray_2_s19_reg));
register_compression #(.N(16)) darray_3_s19_reg_U(.d(darray_3_s18_reg), .clk(clk), .q(darray_3_s19_reg));
register_compression #(.N(16)) darray_4_s19_reg_U(.d(darray_4_s18_reg), .clk(clk), .q(darray_4_s19_reg));
register_compression #(.N(16)) darray_5_s19_reg_U(.d(darray_5_s18_reg), .clk(clk), .q(darray_5_s19_reg));
register_compression #(.N(16)) darray_6_s19_reg_U(.d(darray_6_s18_reg), .clk(clk), .q(darray_6_s19_reg));
register_compression #(.N(16)) darray_7_s19_reg_U(.d(darray_7_s18_reg), .clk(clk), .q(darray_7_s19_reg));
register_compression #(.N(16)) darray_8_s19_reg_U(.d(darray_8_s18_reg), .clk(clk), .q(darray_8_s19_reg));
register_compression #(.N(16)) darray_9_s19_reg_U(.d(darray_9_s18_reg), .clk(clk), .q(darray_9_s19_reg));
register_compression #(.N(16)) darray_10_s19_reg_U(.d(darray_10_s18_reg), .clk(clk), .q(darray_10_s19_reg));
register_compression #(.N(16)) darray_11_s19_reg_U(.d(darray_11_s19), .clk(clk), .q(darray_11_s19_reg));
register_compression #(.N(16)) darray_12_s19_reg_U(.d(darray_12_s18_reg), .clk(clk), .q(darray_12_s19_reg));
register_compression #(.N(16)) darray_13_s19_reg_U(.d(darray_13_s18_reg), .clk(clk), .q(darray_13_s19_reg));
register_compression #(.N(16)) darray_14_s19_reg_U(.d(darray_14_s18_reg), .clk(clk), .q(darray_14_s19_reg));
register_compression #(.N(16)) darray_15_s19_reg_U(.d(darray_15_s18_reg), .clk(clk), .q(darray_15_s19_reg));


register_compression #(.N(1)) comp_near_12_reg_U(.d(comp_near_12), .clk(clk), .q(comp_near_12_reg));

register_compression #(.N(1)) comp_12_processed_len_11_reg_U(.d(comp_12_processed_len_11), .clk(clk), .q(comp_12_processed_len_11_reg));

register_compression #(.N(5)) processed_len_12_op1_reg_U(.d(processed_len_12_op1), .clk(clk), .q(processed_len_12_op1_reg));
register_compression #(.N(5)) processed_len_12_op2_reg_U(.d(processed_len_12_op2), .clk(clk), .q(processed_len_12_op2_reg));

register_compression #(.N(5)) larray_13_plus_3_reg_U(.d(larray_13_plus_3), .clk(clk), .q(larray_13_plus_3_reg));

register_compression #(.N(16)) register_ldvalid_s19_U(.d(ldvalid_s19), .clk(clk), .q(ldvalid_s19_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s19_reg_U(.d(max_reach_index_neq_k_s18_reg), .clk(clk), .q(max_reach_index_neq_k_s19_reg));

register_compression #(.N(16)) dist_valid_s19_reg_U(.d(dist_valid_s18_reg), .clk(clk), .q(dist_valid_s19_reg));

register_compression #(.N(128)) literals_s19_reg_U(.d(literals_s18_reg), .clk(clk), .q(literals_s19_reg));

register_compression #(.N(1)) register_en_s19_U(.d(en_s18_reg), .clk(clk), .q(en_s19_reg));
register_compression #(.N(1)) register_start_s19_U(.d(start_s18_reg), .clk(clk), .q(start_s19_reg));
register_compression #(.N(1)) register_last_s19_U(.d(last_s18_reg), .clk(clk), .q(last_s19_reg));


// ====================================================================
//
//  Stage 20: prepare the lazy evaluation for byte 13 and perform 
// 			 lazy evaluation for byte 12
//
// ====================================================================

// stage 20 ports definition
// 
wire 			do_lazy_12;

// 
wire	[4:0]	processed_len_12;
wire	[4:0]	processed_len_12_reg;

// 
wire	[7:0]	larray_12_s20;

wire	[7:0]	larray_0_s20_reg;
wire	[7:0]	larray_1_s20_reg;
wire	[7:0]	larray_2_s20_reg;
wire	[7:0]	larray_3_s20_reg;
wire	[7:0]	larray_4_s20_reg;
wire	[7:0]	larray_5_s20_reg;
wire	[7:0]	larray_6_s20_reg;
wire	[7:0]	larray_7_s20_reg;
wire	[7:0]	larray_8_s20_reg;
wire	[7:0]	larray_9_s20_reg;
wire	[7:0]	larray_10_s20_reg;
wire	[7:0]	larray_11_s20_reg;
wire	[7:0]	larray_12_s20_reg;
wire	[7:0]	larray_13_s20_reg;
wire	[7:0]	larray_14_s20_reg;
wire	[7:0]	larray_15_s20_reg;

// 
wire	[15:0]	darray_12_s20;

wire	[15:0]	darray_0_s20_reg;
wire	[15:0]	darray_1_s20_reg;
wire	[15:0]	darray_2_s20_reg;
wire	[15:0]	darray_3_s20_reg;
wire	[15:0]	darray_4_s20_reg;
wire	[15:0]	darray_5_s20_reg;
wire	[15:0]	darray_6_s20_reg;
wire	[15:0]	darray_7_s20_reg;
wire	[15:0]	darray_8_s20_reg;
wire	[15:0]	darray_9_s20_reg;
wire	[15:0]	darray_10_s20_reg;
wire	[15:0]	darray_11_s20_reg;
wire	[15:0]	darray_12_s20_reg;
wire	[15:0]	darray_13_s20_reg;
wire	[15:0]	darray_14_s20_reg;
wire	[15:0]	darray_15_s20_reg;

// 
wire	[15:0]	ldvalid_s20;
wire	[15:0]	ldvalid_s20_reg;

// 
wire			comp_near_13;
wire			comp_near_13_reg;

// 0 means 13 < processed_len_12
wire			comp_13_processed_len_12;
wire			comp_13_processed_len_12_reg;

// 
wire	[4:0]	processed_len_13_op1;
wire	[4:0]	processed_len_13_op2;

wire	[4:0]	processed_len_13_op1_reg;
wire	[4:0]	processed_len_13_op2_reg;

// 
wire	[4:0]   larray_14_plus_3;
wire	[4:0]   larray_14_plus_3_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s20_reg;

wire	[15:0]	dist_valid_s20_reg;

// 
wire	[127:0] 	literals_s20_reg;

// 
wire 				en_s20_reg;
wire 				start_s20_reg;
wire 				last_s20_reg;

// stage 20
// do the lazy evaluation for k = 12
// prepare the lazy evaluation for k = 13
assign do_lazy_12 = (ldvalid_s19_reg[2]) && (dist_valid_s19_reg[2]) && (~comp_near_12_reg);
assign processed_len_12 = (ldvalid_s19_reg[3] && max_reach_index_neq_k_s19_reg[3] && comp_12_processed_len_11_reg)?((dist_valid_s19_reg[3])?(do_lazy_12?processed_len_12_op1_reg:processed_len_12_op2_reg):processed_len_12_op1_reg):processed_len_11_reg;
assign larray_12_s20 = (ldvalid_s19_reg[3] && max_reach_index_neq_k_s19_reg[3] && comp_12_processed_len_11_reg && (dist_valid_s19_reg[3]) && (do_lazy_12))?literals_s19_reg[31:24]:larray_12_s19_reg;
assign darray_12_s20 = (ldvalid_s19_reg[3] && max_reach_index_neq_k_s19_reg[3] && comp_12_processed_len_11_reg && (dist_valid_s19_reg[3]) && (do_lazy_12))?16'd0:darray_12_s19_reg;
assign ldvalid_s20 = (ldvalid_s19_reg[3] && max_reach_index_neq_k_s19_reg[3] && (~comp_12_processed_len_11_reg))?{ldvalid_s19_reg[15:4], 1'b0, ldvalid_s19_reg[2:0]}:ldvalid_s19_reg;

// comp_near_13 =1 means larray[13] >= larray[14]
adder_5bits adder_5bits_comp_near_13_U(	
	.a(larray_13_s19_reg[4:0]),
	.b(~larray_14_s19_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_13)
);

// 
adder_5bits comp_13_processed_len_12_U(
	.a(5'd13), 
	.b(~processed_len_12), 
	.ci(1'b1), 
	.s(), 
	.co(comp_13_processed_len_12)
);

// 
assign processed_len_13_op1 = processed_len_12 + 5'd1;

assign processed_len_13_op2 = processed_len_12 + larray_13_plus_3_reg;

assign larray_14_plus_3 = larray_14_s19_reg[4:0] + 5'd3;

// 
register_compression #(.N(5)) processed_len_12_reg_U(.d(processed_len_12), .clk(clk), .q(processed_len_12_reg));

register_compression #(.N(8)) larray_0_s20_reg_U(.d(larray_0_s19_reg), .clk(clk), .q(larray_0_s20_reg));
register_compression #(.N(8)) larray_1_s20_reg_U(.d(larray_1_s19_reg), .clk(clk), .q(larray_1_s20_reg));
register_compression #(.N(8)) larray_2_s20_reg_U(.d(larray_2_s19_reg), .clk(clk), .q(larray_2_s20_reg));
register_compression #(.N(8)) larray_3_s20_reg_U(.d(larray_3_s19_reg), .clk(clk), .q(larray_3_s20_reg));
register_compression #(.N(8)) larray_4_s20_reg_U(.d(larray_4_s19_reg), .clk(clk), .q(larray_4_s20_reg));
register_compression #(.N(8)) larray_5_s20_reg_U(.d(larray_5_s19_reg), .clk(clk), .q(larray_5_s20_reg));
register_compression #(.N(8)) larray_6_s20_reg_U(.d(larray_6_s19_reg), .clk(clk), .q(larray_6_s20_reg));
register_compression #(.N(8)) larray_7_s20_reg_U(.d(larray_7_s19_reg), .clk(clk), .q(larray_7_s20_reg));
register_compression #(.N(8)) larray_8_s20_reg_U(.d(larray_8_s19_reg), .clk(clk), .q(larray_8_s20_reg));
register_compression #(.N(8)) larray_9_s20_reg_U(.d(larray_9_s19_reg), .clk(clk), .q(larray_9_s20_reg));
register_compression #(.N(8)) larray_10_s20_reg_U(.d(larray_10_s19_reg), .clk(clk), .q(larray_10_s20_reg));
register_compression #(.N(8)) larray_11_s20_reg_U(.d(larray_11_s19_reg), .clk(clk), .q(larray_11_s20_reg));
register_compression #(.N(8)) larray_12_s20_reg_U(.d(larray_12_s20), .clk(clk), .q(larray_12_s20_reg));
register_compression #(.N(8)) larray_13_s20_reg_U(.d(larray_13_s19_reg), .clk(clk), .q(larray_13_s20_reg));
register_compression #(.N(8)) larray_14_s20_reg_U(.d(larray_14_s19_reg), .clk(clk), .q(larray_14_s20_reg));
register_compression #(.N(8)) larray_15_s20_reg_U(.d(larray_15_s19_reg), .clk(clk), .q(larray_15_s20_reg));

register_compression #(.N(16)) darray_0_s20_reg_U(.d(darray_0_s19_reg), .clk(clk), .q(darray_0_s20_reg));
register_compression #(.N(16)) darray_1_s20_reg_U(.d(darray_1_s19_reg), .clk(clk), .q(darray_1_s20_reg));
register_compression #(.N(16)) darray_2_s20_reg_U(.d(darray_2_s19_reg), .clk(clk), .q(darray_2_s20_reg));
register_compression #(.N(16)) darray_3_s20_reg_U(.d(darray_3_s19_reg), .clk(clk), .q(darray_3_s20_reg));
register_compression #(.N(16)) darray_4_s20_reg_U(.d(darray_4_s19_reg), .clk(clk), .q(darray_4_s20_reg));
register_compression #(.N(16)) darray_5_s20_reg_U(.d(darray_5_s19_reg), .clk(clk), .q(darray_5_s20_reg));
register_compression #(.N(16)) darray_6_s20_reg_U(.d(darray_6_s19_reg), .clk(clk), .q(darray_6_s20_reg));
register_compression #(.N(16)) darray_7_s20_reg_U(.d(darray_7_s19_reg), .clk(clk), .q(darray_7_s20_reg));
register_compression #(.N(16)) darray_8_s20_reg_U(.d(darray_8_s19_reg), .clk(clk), .q(darray_8_s20_reg));
register_compression #(.N(16)) darray_9_s20_reg_U(.d(darray_9_s19_reg), .clk(clk), .q(darray_9_s20_reg));
register_compression #(.N(16)) darray_10_s20_reg_U(.d(darray_10_s19_reg), .clk(clk), .q(darray_10_s20_reg));
register_compression #(.N(16)) darray_11_s20_reg_U(.d(darray_11_s19_reg), .clk(clk), .q(darray_11_s20_reg));
register_compression #(.N(16)) darray_12_s20_reg_U(.d(darray_12_s20), .clk(clk), .q(darray_12_s20_reg));
register_compression #(.N(16)) darray_13_s20_reg_U(.d(darray_13_s19_reg), .clk(clk), .q(darray_13_s20_reg));
register_compression #(.N(16)) darray_14_s20_reg_U(.d(darray_14_s19_reg), .clk(clk), .q(darray_14_s20_reg));
register_compression #(.N(16)) darray_15_s20_reg_U(.d(darray_15_s19_reg), .clk(clk), .q(darray_15_s20_reg));


register_compression #(.N(1)) comp_near_13_reg_U(.d(comp_near_13), .clk(clk), .q(comp_near_13_reg));

register_compression #(.N(1)) comp_13_processed_len_12_reg_U(.d(comp_13_processed_len_12), .clk(clk), .q(comp_13_processed_len_12_reg));

register_compression #(.N(5)) processed_len_13_op1_reg_U(.d(processed_len_13_op1), .clk(clk), .q(processed_len_13_op1_reg));
register_compression #(.N(5)) processed_len_13_op2_reg_U(.d(processed_len_13_op2), .clk(clk), .q(processed_len_13_op2_reg));

register_compression #(.N(5)) larray_14_plus_3_reg_U(.d(larray_14_plus_3), .clk(clk), .q(larray_14_plus_3_reg));

register_compression #(.N(16)) register_ldvalid_s20_U(.d(ldvalid_s20), .clk(clk), .q(ldvalid_s20_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s20_reg_U(.d(max_reach_index_neq_k_s19_reg), .clk(clk), .q(max_reach_index_neq_k_s20_reg));

register_compression #(.N(16)) dist_valid_s20_reg_U(.d(dist_valid_s19_reg), .clk(clk), .q(dist_valid_s20_reg));

register_compression #(.N(128)) literals_s20_reg_U(.d(literals_s19_reg), .clk(clk), .q(literals_s20_reg));

register_compression #(.N(1)) register_en_s20_U(.d(en_s19_reg), .clk(clk), .q(en_s20_reg));
register_compression #(.N(1)) register_start_s20_U(.d(start_s19_reg), .clk(clk), .q(start_s20_reg));
register_compression #(.N(1)) register_last_s20_U(.d(last_s19_reg), .clk(clk), .q(last_s20_reg));


// ====================================================================
//
//  Stage 21: prepare the lazy evaluation for byte 14 and perform 
// 			 lazy evaluation for byte 13
//
// ====================================================================

// stage 21 ports definition
// 
wire 			do_lazy_13;

// 
wire	[4:0]	processed_len_13;
wire	[4:0]	processed_len_13_reg;

// 
wire	[7:0]	larray_13_s21;

wire	[7:0]	larray_0_s21_reg;
wire	[7:0]	larray_1_s21_reg;
wire	[7:0]	larray_2_s21_reg;
wire	[7:0]	larray_3_s21_reg;
wire	[7:0]	larray_4_s21_reg;
wire	[7:0]	larray_5_s21_reg;
wire	[7:0]	larray_6_s21_reg;
wire	[7:0]	larray_7_s21_reg;
wire	[7:0]	larray_8_s21_reg;
wire	[7:0]	larray_9_s21_reg;
wire	[7:0]	larray_10_s21_reg;
wire	[7:0]	larray_11_s21_reg;
wire	[7:0]	larray_12_s21_reg;
wire	[7:0]	larray_13_s21_reg;
wire	[7:0]	larray_14_s21_reg;
wire	[7:0]	larray_15_s21_reg;

// 
wire	[15:0]	darray_13_s21;

wire	[15:0]	darray_0_s21_reg;
wire	[15:0]	darray_1_s21_reg;
wire	[15:0]	darray_2_s21_reg;
wire	[15:0]	darray_3_s21_reg;
wire	[15:0]	darray_4_s21_reg;
wire	[15:0]	darray_5_s21_reg;
wire	[15:0]	darray_6_s21_reg;
wire	[15:0]	darray_7_s21_reg;
wire	[15:0]	darray_8_s21_reg;
wire	[15:0]	darray_9_s21_reg;
wire	[15:0]	darray_10_s21_reg;
wire	[15:0]	darray_11_s21_reg;
wire	[15:0]	darray_12_s21_reg;
wire	[15:0]	darray_13_s21_reg;
wire	[15:0]	darray_14_s21_reg;
wire	[15:0]	darray_15_s21_reg;

// 
wire	[15:0]	ldvalid_s21;
wire	[15:0]	ldvalid_s21_reg;

// 
wire			comp_near_14;
wire			comp_near_14_reg;

// 0 means 14 < processed_len_13
wire			comp_14_processed_len_13;
wire			comp_14_processed_len_13_reg;

// 
wire	[4:0]	processed_len_14_op1;
wire	[4:0]	processed_len_14_op2;

wire	[4:0]	processed_len_14_op1_reg;
wire	[4:0]	processed_len_14_op2_reg;

// 
wire	[15:0]	max_reach_index_neq_k_s21_reg;

wire	[15:0]	dist_valid_s21_reg;

// 
wire	[127:0] 	literals_s21_reg;

// 
wire 				en_s21_reg;
wire 				start_s21_reg;
wire 				last_s21_reg;

// stage 21
// do the lazy evaluation for k = 13
// prepare the lazy evaluation for k = 14
assign do_lazy_13 = (ldvalid_s20_reg[1]) && (dist_valid_s20_reg[1]) && (~comp_near_13_reg);
assign processed_len_13 = (ldvalid_s20_reg[2] && max_reach_index_neq_k_s20_reg[2] && comp_13_processed_len_12_reg)?((dist_valid_s20_reg[2])?(do_lazy_13?processed_len_13_op1_reg:processed_len_13_op2_reg):processed_len_13_op1_reg):processed_len_12_reg;
assign larray_13_s21 = (ldvalid_s20_reg[2] && max_reach_index_neq_k_s20_reg[2] && comp_13_processed_len_12_reg && (dist_valid_s20_reg[2]) && (do_lazy_13))?literals_s20_reg[23:16]:larray_13_s20_reg;
assign darray_13_s21 = (ldvalid_s20_reg[2] && max_reach_index_neq_k_s20_reg[2] && comp_13_processed_len_12_reg && (dist_valid_s20_reg[2]) && (do_lazy_13))?16'd0:darray_13_s20_reg;
assign ldvalid_s21 = (ldvalid_s20_reg[2] && max_reach_index_neq_k_s20_reg[2] && (~comp_13_processed_len_12_reg))?{ldvalid_s20_reg[15:3], 1'b0, ldvalid_s20_reg[1:0]}:ldvalid_s20_reg;

// comp_near_14 =1 means larray[14] >= larray[15]
adder_5bits adder_5bits_comp_near_14_U(	
	.a(larray_14_s20_reg[4:0]),
	.b(~larray_15_s20_reg[4:0]),
	.ci(1'b1),
	.s(),
	.co(comp_near_14)
);

// 
adder_5bits comp_14_processed_len_13_U(
	.a(5'd14), 
	.b(~processed_len_13), 
	.ci(1'b1), 
	.s(), 
	.co(comp_14_processed_len_13)
);

// 
assign processed_len_14_op1 = processed_len_13 + 5'd1;

assign processed_len_14_op2 = processed_len_13 + larray_14_plus_3_reg;

// 
register_compression #(.N(5)) processed_len_13_reg_U(.d(processed_len_13), .clk(clk), .q(processed_len_13_reg));

register_compression #(.N(8)) larray_0_s21_reg_U(.d(larray_0_s20_reg), .clk(clk), .q(larray_0_s21_reg));
register_compression #(.N(8)) larray_1_s21_reg_U(.d(larray_1_s20_reg), .clk(clk), .q(larray_1_s21_reg));
register_compression #(.N(8)) larray_2_s21_reg_U(.d(larray_2_s20_reg), .clk(clk), .q(larray_2_s21_reg));
register_compression #(.N(8)) larray_3_s21_reg_U(.d(larray_3_s20_reg), .clk(clk), .q(larray_3_s21_reg));
register_compression #(.N(8)) larray_4_s21_reg_U(.d(larray_4_s20_reg), .clk(clk), .q(larray_4_s21_reg));
register_compression #(.N(8)) larray_5_s21_reg_U(.d(larray_5_s20_reg), .clk(clk), .q(larray_5_s21_reg));
register_compression #(.N(8)) larray_6_s21_reg_U(.d(larray_6_s20_reg), .clk(clk), .q(larray_6_s21_reg));
register_compression #(.N(8)) larray_7_s21_reg_U(.d(larray_7_s20_reg), .clk(clk), .q(larray_7_s21_reg));
register_compression #(.N(8)) larray_8_s21_reg_U(.d(larray_8_s20_reg), .clk(clk), .q(larray_8_s21_reg));
register_compression #(.N(8)) larray_9_s21_reg_U(.d(larray_9_s20_reg), .clk(clk), .q(larray_9_s21_reg));
register_compression #(.N(8)) larray_10_s21_reg_U(.d(larray_10_s20_reg), .clk(clk), .q(larray_10_s21_reg));
register_compression #(.N(8)) larray_11_s21_reg_U(.d(larray_11_s20_reg), .clk(clk), .q(larray_11_s21_reg));
register_compression #(.N(8)) larray_12_s21_reg_U(.d(larray_12_s20_reg), .clk(clk), .q(larray_12_s21_reg));
register_compression #(.N(8)) larray_13_s21_reg_U(.d(larray_13_s21), .clk(clk), .q(larray_13_s21_reg));
register_compression #(.N(8)) larray_14_s21_reg_U(.d(larray_14_s20_reg), .clk(clk), .q(larray_14_s21_reg));
register_compression #(.N(8)) larray_15_s21_reg_U(.d(larray_15_s20_reg), .clk(clk), .q(larray_15_s21_reg));

register_compression #(.N(16)) darray_0_s21_reg_U(.d(darray_0_s20_reg), .clk(clk), .q(darray_0_s21_reg));
register_compression #(.N(16)) darray_1_s21_reg_U(.d(darray_1_s20_reg), .clk(clk), .q(darray_1_s21_reg));
register_compression #(.N(16)) darray_2_s21_reg_U(.d(darray_2_s20_reg), .clk(clk), .q(darray_2_s21_reg));
register_compression #(.N(16)) darray_3_s21_reg_U(.d(darray_3_s20_reg), .clk(clk), .q(darray_3_s21_reg));
register_compression #(.N(16)) darray_4_s21_reg_U(.d(darray_4_s20_reg), .clk(clk), .q(darray_4_s21_reg));
register_compression #(.N(16)) darray_5_s21_reg_U(.d(darray_5_s20_reg), .clk(clk), .q(darray_5_s21_reg));
register_compression #(.N(16)) darray_6_s21_reg_U(.d(darray_6_s20_reg), .clk(clk), .q(darray_6_s21_reg));
register_compression #(.N(16)) darray_7_s21_reg_U(.d(darray_7_s20_reg), .clk(clk), .q(darray_7_s21_reg));
register_compression #(.N(16)) darray_8_s21_reg_U(.d(darray_8_s20_reg), .clk(clk), .q(darray_8_s21_reg));
register_compression #(.N(16)) darray_9_s21_reg_U(.d(darray_9_s20_reg), .clk(clk), .q(darray_9_s21_reg));
register_compression #(.N(16)) darray_10_s21_reg_U(.d(darray_10_s20_reg), .clk(clk), .q(darray_10_s21_reg));
register_compression #(.N(16)) darray_11_s21_reg_U(.d(darray_11_s20_reg), .clk(clk), .q(darray_11_s21_reg));
register_compression #(.N(16)) darray_12_s21_reg_U(.d(darray_12_s20_reg), .clk(clk), .q(darray_12_s21_reg));
register_compression #(.N(16)) darray_13_s21_reg_U(.d(darray_13_s21), .clk(clk), .q(darray_13_s21_reg));
register_compression #(.N(16)) darray_14_s21_reg_U(.d(darray_14_s20_reg), .clk(clk), .q(darray_14_s21_reg));
register_compression #(.N(16)) darray_15_s21_reg_U(.d(darray_15_s20_reg), .clk(clk), .q(darray_15_s21_reg));


register_compression #(.N(1)) comp_near_14_reg_U(.d(comp_near_14), .clk(clk), .q(comp_near_14_reg));

register_compression #(.N(1)) comp_14_processed_len_13_reg_U(.d(comp_14_processed_len_13), .clk(clk), .q(comp_14_processed_len_13_reg));

register_compression #(.N(5)) processed_len_14_op1_reg_U(.d(processed_len_14_op1), .clk(clk), .q(processed_len_14_op1_reg));
register_compression #(.N(5)) processed_len_14_op2_reg_U(.d(processed_len_14_op2), .clk(clk), .q(processed_len_14_op2_reg));

register_compression #(.N(16)) register_ldvalid_s21_U(.d(ldvalid_s21), .clk(clk), .q(ldvalid_s21_reg));

register_compression #(.N(16)) max_reach_index_neq_k_s21_reg_U(.d(max_reach_index_neq_k_s20_reg), .clk(clk), .q(max_reach_index_neq_k_s21_reg));

register_compression #(.N(16)) dist_valid_s21_reg_U(.d(dist_valid_s20_reg), .clk(clk), .q(dist_valid_s21_reg));

register_compression #(.N(128)) literals_s21_reg_U(.d(literals_s20_reg), .clk(clk), .q(literals_s21_reg));

register_compression #(.N(1)) register_en_s21_U(.d(en_s20_reg), .clk(clk), .q(en_s21_reg));
register_compression #(.N(1)) register_start_s21_U(.d(start_s20_reg), .clk(clk), .q(start_s21_reg));
register_compression #(.N(1)) register_last_s21_U(.d(last_s20_reg), .clk(clk), .q(last_s21_reg));


// ====================================================================
//
//  Stage 22: perform lazy evaluation for byte 14
//
// ====================================================================

// stage 22 ports definition
// 
wire 			do_lazy_14;

// 
wire	[7:0]	larray_14_s22;

// 
wire	[15:0]	darray_14_s22;

// 
wire 	[127:0]		larray;
wire 	[255:0]		darray;
wire	[15:0]		valid;

// stage 22
// do the lazy evaluation for k = 14
assign do_lazy_14 = (ldvalid_s21_reg[0]) && (dist_valid_s21_reg[0]) && (~comp_near_14_reg);

assign larray_14_s22 = (ldvalid_s21_reg[1] && max_reach_index_neq_k_s21_reg[1] && comp_14_processed_len_13_reg && (dist_valid_s21_reg[1]) && (do_lazy_14))?literals_s21_reg[15:8]:larray_14_s21_reg;
assign darray_14_s22 = (ldvalid_s21_reg[1] && max_reach_index_neq_k_s21_reg[1] && comp_14_processed_len_13_reg && (dist_valid_s21_reg[1]) && (do_lazy_14))?16'd0:darray_14_s21_reg;

assign larray = {larray_0_s21_reg, larray_1_s21_reg, larray_2_s21_reg, larray_3_s21_reg, larray_4_s21_reg, larray_5_s21_reg, larray_6_s21_reg, larray_7_s21_reg,
				 larray_8_s21_reg, larray_9_s21_reg, larray_10_s21_reg, larray_11_s21_reg, larray_12_s21_reg, larray_13_s21_reg, larray_14_s22, larray_15_s21_reg};

assign darray = {darray_0_s21_reg, darray_1_s21_reg, darray_2_s21_reg, darray_3_s21_reg, darray_4_s21_reg, darray_5_s21_reg, darray_6_s21_reg, darray_7_s21_reg, 
				 darray_8_s21_reg, darray_9_s21_reg, darray_10_s21_reg, darray_11_s21_reg, darray_12_s21_reg, darray_13_s21_reg, darray_14_s22, darray_15_s21_reg};

assign valid = (ldvalid_s21_reg[1] && max_reach_index_neq_k_s21_reg[1] && (~comp_14_processed_len_13_reg))?{ldvalid_s21_reg[15:2], 1'b0, ldvalid_s21_reg[0]}:ldvalid_s21_reg;


// 
register_compression #(.N(128)) register_larray_out_U(.d(larray), .clk(clk), .q(larray_out));
register_compression #(.N(256)) register_darray_out_U(.d(darray), .clk(clk), .q(darray_out));
register_compression #(.N(16)) register_valid_out_U(.d(valid), .clk(clk), .q(valid_out));
register_compression #(.N(1)) register_en_out_U(.d(en_s21_reg), .clk(clk), .q(ready_out));
register_compression #(.N(1)) register_start_out_U(.d(start_s21_reg), .clk(clk), .q(start_out));
register_compression #(.N(1)) register_last_out_U(.d(last_s21_reg), .clk(clk), .q(last_out));


endmodule