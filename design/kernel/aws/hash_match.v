/******************************************************************************
* 
* Description： Hash calculation & hash updates
* Author: Weikang Qiao
* Date: 06/27/2018
* 
* Parameters:
*				VEC = 16
*				BANK_OFFSET = 256
*				HASH_TABLE_BANKS = 16
* 
******************************************************************************/

module hash_match #
(
	parameter MEM_BANK_NUM = 'd5, 
	parameter MEM_BANK_DEPTH = 'd8
)
(
	clk, 
	rst, 
	start, 
	data_window_in, 
//	in_size_in, 
	literals_out, 
	len_raw_out,
	dist_raw_out, 
	valid_out, 
	output_ready
);

// ====================================================================
//
//  Input & output ports defined here
//
// ====================================================================
input			clk;
input 			rst;

// start signal high to indicate input data window is effective
input			start;

// assume inputs are current and next windows
// data_window_in[255:248] is input[0]
input 	[255:0]	data_window_in;

// output the original input literals
output	[127:0]	literals_out;

// output the original matched length information starting from each
// position of the current windows. If it is not a match, the 8-bit 
// length information is equal to the orignal input literal
output 	[127:0]	len_raw_out;

// output the original matched distance information starting from each
// position of the current windows. Current distance information is 
// 16 bits, representing a maximum distance of 64kB
output	[255:0]	dist_raw_out;

// output the valid information for each substring
output 	[15:0]	valid_out;

// output the ready signal to indicate the following match selection
// part that current input window is already processed
output 			output_ready;


// ====================================================================
//
//  Stage 1: Hash Calculation
//
// ====================================================================

// stage 1 ports definition

// ports for hash values
wire	[12:0]	hash_value_0;
wire 	[12:0]	hash_value_1;
wire 	[12:0]	hash_value_2;
wire	[12:0]	hash_value_3;
wire 	[12:0]	hash_value_4;
wire	[12:0]	hash_value_5;
wire	[12:0]	hash_value_6;
wire	[12:0]	hash_value_7;
wire	[12:0]	hash_value_8;
wire 	[12:0]	hash_value_9;
wire 	[12:0]	hash_value_10;
wire	[12:0]	hash_value_11;
wire 	[12:0]	hash_value_12;
wire	[12:0]	hash_value_13;
wire	[12:0]	hash_value_14;
wire	[12:0]	hash_value_15;

// ports for bank number of each substring corresponding to the hash 
// value. Take the LSBs as the bank number.
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_0;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_1;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_2;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_3;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_4;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_5;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_6;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_7;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_8;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_9;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_10;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_11;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_12;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_13;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_14;
wire	[MEM_BANK_NUM-1:0]	raw_bank_num_15;

wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_0_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_1_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_2_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_3_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_4_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_5_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_6_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_7_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_8_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_9_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_10_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_11_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_12_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_13_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_14_s1;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_15_s1;

// ports for bank depth of each substring corresponding to the hash 
// value. Take the MSBs as the bank number.
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_0;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_1;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_2;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_3;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_4;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_5;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_6;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_7;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_8;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_9;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_10;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_11;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_12;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_13;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_14;
wire	[MEM_BANK_DEPTH-1:0]	raw_bank_offset_15;

wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_0_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_1_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_2_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_3_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_4_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_5_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_6_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_7_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_8_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_9_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_10_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_11_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_12_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_13_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_14_s1;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_15_s1;

// Position information about current prosessing window
// 32 bits position can support up to 4 GB input file
wire 	[31:0]	prev_input_position;
wire 	[31:0]	prev_input_position_plus_16;
wire 	[31:0]	input_position;

// ready signal after stage 1
wire  			start_s1;

// input window after stage 1
wire 	[255:0]	data_window_in_s1;

// Perform hash value calculation for each substring based on the 
// current and next windows 
// hash_value = (input[0]<<5) ^ (input[1]<<4) ^ (input[2]<<3) 
// 				^ (input[3]<<2) ^ (input[4]<<1) ^ input[5]
assign hash_value_0 = {data_window_in[255:248], 5'b0} ^ {1'b0, data_window_in[247:240], 4'b0} 
		  			  ^ {2'b0, data_window_in[239:232], 3'b0} ^ {3'b0, data_window_in[231:224], 2'b0} 
		 			  ^ {4'b0, data_window_in[223:216], 1'b0} ^ {5'b0, data_window_in[215:208]};

assign hash_value_1 = {data_window_in[247:240], 5'b0} ^ {1'b0, data_window_in[239:232], 4'b0} 
					  ^ {2'b0, data_window_in[231:224], 3'b0} ^ {3'b0, data_window_in[223:216], 2'b0} 
			 		  ^ {4'b0, data_window_in[215:208], 1'b0} ^ {5'b0, data_window_in[207:200]};

assign hash_value_2 = {data_window_in[239:232], 5'b0} ^ {1'b0, data_window_in[231:224], 4'b0} 
					  ^ {2'b0, data_window_in[223:216], 3'b0} ^ {3'b0, data_window_in[215:208], 2'b0} 
					  ^ {4'b0, data_window_in[207:200], 1'b0} ^ {5'b0, data_window_in[199:192]};

assign hash_value_3 = {data_window_in[231:224], 5'b0} ^ {1'b0, data_window_in[223:216], 4'b0} 
					  ^ {2'b0, data_window_in[215:208], 3'b0} ^ {3'b0, data_window_in[207:200], 2'b0} 
					  ^ {4'b0, data_window_in[199:192], 1'b0} ^ {5'b0, data_window_in[191:184]};

assign hash_value_4 = {data_window_in[223:216], 5'b0} ^ {1'b0, data_window_in[215:208], 4'b0} 
 					  ^ {2'b0, data_window_in[207:200], 3'b0} ^ {3'b0, data_window_in[199:192], 2'b0} 
                      ^ {4'b0, data_window_in[191:184], 1'b0} ^ {5'b0, data_window_in[183:176]};

assign hash_value_5 = {data_window_in[215:208], 5'b0} ^ {1'b0, data_window_in[207:200], 4'b0} 
					  ^ {2'b0, data_window_in[199:192], 3'b0} ^ {3'b0, data_window_in[191:184], 2'b0} 
					  ^ {4'b0, data_window_in[183:176], 1'b0} ^ {5'b0, data_window_in[175:168]};

assign hash_value_6 = {data_window_in[207:200], 5'b0} ^ {1'b0, data_window_in[199:192], 4'b0} 
					  ^ {2'b0, data_window_in[191:184], 3'b0} ^ {3'b0, data_window_in[183:176], 2'b0} 
					  ^ {4'b0, data_window_in[175:168], 1'b0} ^ {5'b0, data_window_in[167:160]};

assign hash_value_7 = {data_window_in[199:192], 5'b0} ^ {1'b0, data_window_in[191:184], 4'b0} 
					  ^ {2'b0, data_window_in[183:176], 3'b0} ^ {3'b0, data_window_in[175:168], 2'b0} 
					  ^ {4'b0, data_window_in[167:160], 1'b0} ^ {5'b0, data_window_in[159:152]};

assign hash_value_8 = {data_window_in[191:184], 5'b0} ^ {1'b0, data_window_in[183:176], 4'b0} 
					  ^ {2'b0, data_window_in[175:168], 3'b0} ^ {3'b0, data_window_in[167:160], 2'b0} 
					  ^ {4'b0, data_window_in[159:152], 1'b0} ^ {5'b0, data_window_in[151:144]};

assign hash_value_9 = {data_window_in[183:176], 5'b0} ^ {1'b0, data_window_in[175:168], 4'b0} 
					  ^ {2'b0, data_window_in[167:160], 3'b0} ^ {3'b0, data_window_in[159:152], 2'b0} 
					  ^ {4'b0, data_window_in[151:144], 1'b0} ^ {5'b0, data_window_in[143:136]};

assign hash_value_10 = {data_window_in[175:168], 5'b0} ^ {1'b0, data_window_in[167:160], 4'b0} 
					  ^ {2'b0, data_window_in[159:152], 3'b0} ^ {3'b0, data_window_in[151:144], 2'b0} 
					  ^ {4'b0, data_window_in[143:136], 1'b0} ^ {5'b0, data_window_in[135:128]};

assign hash_value_11 = {data_window_in[167:160], 5'b0} ^ {1'b0, data_window_in[159:152], 4'b0} 
					  ^ {2'b0, data_window_in[151:144], 3'b0} ^ {3'b0, data_window_in[143:136], 2'b0} 
					  ^ {4'b0, data_window_in[135:128], 1'b0} ^ {5'b0, data_window_in[127:120]};

assign hash_value_12 = {data_window_in[159:152], 5'b0} ^ {1'b0, data_window_in[151:144], 4'b0} 
					  ^ {2'b0, data_window_in[143:136], 3'b0} ^ {3'b0, data_window_in[135:128], 2'b0} 
					  ^ {4'b0, data_window_in[127:120], 1'b0} ^ {5'b0, data_window_in[119:112]};

assign hash_value_13 = {data_window_in[151:144], 5'b0} ^ {1'b0, data_window_in[143:136], 4'b0} 
					  ^ {2'b0, data_window_in[135:128], 3'b0} ^ {3'b0, data_window_in[127:120], 2'b0} 
					  ^ {4'b0, data_window_in[119:112], 1'b0} ^ {5'b0, data_window_in[111:104]};

assign hash_value_14 = {data_window_in[143:136], 5'b0} ^ {1'b0, data_window_in[135:128], 4'b0} 
					  ^ {2'b0, data_window_in[127:120], 3'b0} ^ {3'b0, data_window_in[119:112], 2'b0} 
					  ^ {4'b0, data_window_in[111:104], 1'b0} ^ {5'b0, data_window_in[103:96]};

assign hash_value_15 = {data_window_in[135:128], 5'b0} ^ {1'b0, data_window_in[127:120], 4'b0} 
					  ^ {2'b0, data_window_in[119:112], 3'b0} ^ {3'b0, data_window_in[111:104], 2'b0} 
					  ^ {4'b0, data_window_in[103:96], 1'b0} ^ {5'b0, data_window_in[95:88]};

// raw_bank_num[k] = hash_value[k] % HASH_TABLE_BANKS;
assign raw_bank_num_0 = {hash_value_0[MEM_BANK_NUM-1:0]};
assign raw_bank_num_1 = {hash_value_1[MEM_BANK_NUM-1:0]};
assign raw_bank_num_2 = {hash_value_2[MEM_BANK_NUM-1:0]};
assign raw_bank_num_3 = {hash_value_3[MEM_BANK_NUM-1:0]};
assign raw_bank_num_4 = {hash_value_4[MEM_BANK_NUM-1:0]};
assign raw_bank_num_5 = {hash_value_5[MEM_BANK_NUM-1:0]};
assign raw_bank_num_6 = {hash_value_6[MEM_BANK_NUM-1:0]};
assign raw_bank_num_7 = {hash_value_7[MEM_BANK_NUM-1:0]};
assign raw_bank_num_8 = {hash_value_8[MEM_BANK_NUM-1:0]};
assign raw_bank_num_9 = {hash_value_9[MEM_BANK_NUM-1:0]};
assign raw_bank_num_10 = {hash_value_10[MEM_BANK_NUM-1:0]};
assign raw_bank_num_11 = {hash_value_11[MEM_BANK_NUM-1:0]};
assign raw_bank_num_12 = {hash_value_12[MEM_BANK_NUM-1:0]};
assign raw_bank_num_13 = {hash_value_13[MEM_BANK_NUM-1:0]};
assign raw_bank_num_14 = {hash_value_14[MEM_BANK_NUM-1:0]};
assign raw_bank_num_15 = {hash_value_15[MEM_BANK_NUM-1:0]};

// raw_bank_offset[k] = hash_value[k] / HASH_TABLE_BANKS;
assign raw_bank_offset_0 = hash_value_0[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_1 = hash_value_1[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_2 = hash_value_2[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_3 = hash_value_3[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_4 = hash_value_4[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_5 = hash_value_5[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_6 = hash_value_6[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_7 = hash_value_7[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_8 = hash_value_8[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_9 = hash_value_9[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_10 = hash_value_10[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_11 = hash_value_11[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_12 = hash_value_12[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_13 = hash_value_13[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_14 = hash_value_14[12:12-MEM_BANK_DEPTH+1];
assign raw_bank_offset_15 = hash_value_15[12:12-MEM_BANK_DEPTH+1];

// stage 1 data path 

// calculate input position based on incoming start signal
assign prev_input_position_plus_16 = prev_input_position + {32'd16};
assign input_position = start?prev_input_position_plus_16:prev_input_position;

// store the results into pipeline registers
// input position  is also a control path, which needs reset
register_compression_reset #(.N(32)) register_input_position_s1_U(.d(input_position), .clk(clk), .reset(rst), .q(prev_input_position));
register_compression_reset #(.N(1)) register_start_s1_U(.d(start), .clk(clk), .reset(rst), .q(start_s1));

// registers for data path
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_0_U(.d(raw_bank_num_0), .clk(clk), .q(reg_raw_bank_num_0_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_1_U(.d(raw_bank_num_1), .clk(clk), .q(reg_raw_bank_num_1_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_2_U(.d(raw_bank_num_2), .clk(clk), .q(reg_raw_bank_num_2_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_3_U(.d(raw_bank_num_3), .clk(clk), .q(reg_raw_bank_num_3_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_4_U(.d(raw_bank_num_4), .clk(clk), .q(reg_raw_bank_num_4_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_5_U(.d(raw_bank_num_5), .clk(clk), .q(reg_raw_bank_num_5_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_6_U(.d(raw_bank_num_6), .clk(clk), .q(reg_raw_bank_num_6_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_7_U(.d(raw_bank_num_7), .clk(clk), .q(reg_raw_bank_num_7_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_8_U(.d(raw_bank_num_8), .clk(clk), .q(reg_raw_bank_num_8_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_9_U(.d(raw_bank_num_9), .clk(clk), .q(reg_raw_bank_num_9_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_10_U(.d(raw_bank_num_10), .clk(clk), .q(reg_raw_bank_num_10_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_11_U(.d(raw_bank_num_11), .clk(clk), .q(reg_raw_bank_num_11_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_12_U(.d(raw_bank_num_12), .clk(clk), .q(reg_raw_bank_num_12_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_13_U(.d(raw_bank_num_13), .clk(clk), .q(reg_raw_bank_num_13_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_14_U(.d(raw_bank_num_14), .clk(clk), .q(reg_raw_bank_num_14_s1));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_15_U(.d(raw_bank_num_15), .clk(clk), .q(reg_raw_bank_num_15_s1));

register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_0_U(.d(raw_bank_offset_0), .clk(clk), .q(reg_raw_bank_offset_0_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_1_U(.d(raw_bank_offset_1), .clk(clk), .q(reg_raw_bank_offset_1_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_2_U(.d(raw_bank_offset_2), .clk(clk), .q(reg_raw_bank_offset_2_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_3_U(.d(raw_bank_offset_3), .clk(clk), .q(reg_raw_bank_offset_3_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_4_U(.d(raw_bank_offset_4), .clk(clk), .q(reg_raw_bank_offset_4_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_5_U(.d(raw_bank_offset_5), .clk(clk), .q(reg_raw_bank_offset_5_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_6_U(.d(raw_bank_offset_6), .clk(clk), .q(reg_raw_bank_offset_6_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_7_U(.d(raw_bank_offset_7), .clk(clk), .q(reg_raw_bank_offset_7_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_8_U(.d(raw_bank_offset_8), .clk(clk), .q(reg_raw_bank_offset_8_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_9_U(.d(raw_bank_offset_9), .clk(clk), .q(reg_raw_bank_offset_9_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_10_U(.d(raw_bank_offset_10), .clk(clk), .q(reg_raw_bank_offset_10_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_11_U(.d(raw_bank_offset_11), .clk(clk), .q(reg_raw_bank_offset_11_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_12_U(.d(raw_bank_offset_12), .clk(clk), .q(reg_raw_bank_offset_12_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_13_U(.d(raw_bank_offset_13), .clk(clk), .q(reg_raw_bank_offset_13_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_14_U(.d(raw_bank_offset_14), .clk(clk), .q(reg_raw_bank_offset_14_s1));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_15_U(.d(raw_bank_offset_15), .clk(clk), .q(reg_raw_bank_offset_15_s1));

register_compression #(.N(256)) register_data_window_in_s1_U(.d(data_window_in), .clk(clk), .q(data_window_in_s1));


// ====================================================================
//
//  Stage 2: Hash Calculation
//
// ====================================================================

// stage 2 ports definition

// ports to check if the substrings access the same bank
wire 	 	bank_num_2_equ_0;
wire 		bank_num_2_equ_1;

wire 		bank_num_3_equ_0;
wire 	 	bank_num_3_equ_1;
wire 		bank_num_3_equ_2;

wire 		bank_num_4_equ_0;
wire 	 	bank_num_4_equ_1;
wire 	 	bank_num_4_equ_2;
wire 	 	bank_num_4_equ_3;

wire 	 	bank_num_5_equ_0;
wire 	 	bank_num_5_equ_1;
wire 		bank_num_5_equ_2;
wire 		bank_num_5_equ_3;
wire 		bank_num_5_equ_4;

wire 	 	bank_num_6_equ_0;
wire 	 	bank_num_6_equ_1;
wire 	 	bank_num_6_equ_2;
wire 	 	bank_num_6_equ_3;
wire 	 	bank_num_6_equ_4;
wire 	 	bank_num_6_equ_5;

wire 	 	bank_num_7_equ_0;
wire 	 	bank_num_7_equ_1;
wire 	 	bank_num_7_equ_2;
wire 	 	bank_num_7_equ_3;
wire 	 	bank_num_7_equ_4;
wire 	 	bank_num_7_equ_5;
wire 	 	bank_num_7_equ_6;

wire 	 	bank_num_8_equ_0;
wire 	 	bank_num_8_equ_1;
wire 	 	bank_num_8_equ_2;
wire 	 	bank_num_8_equ_3;
wire 	 	bank_num_8_equ_4;
wire 	 	bank_num_8_equ_5;
wire 	 	bank_num_8_equ_6;
wire 	 	bank_num_8_equ_7;

wire 	 	bank_num_9_equ_0;
wire 	 	bank_num_9_equ_1;
wire 	 	bank_num_9_equ_2;
wire 	 	bank_num_9_equ_3;
wire 	 	bank_num_9_equ_4;
wire 	 	bank_num_9_equ_5;
wire 	 	bank_num_9_equ_6;
wire 	 	bank_num_9_equ_7;
wire 	 	bank_num_9_equ_8;

wire 	 	bank_num_10_equ_0;
wire 	 	bank_num_10_equ_1;
wire 	 	bank_num_10_equ_2;
wire 	 	bank_num_10_equ_3;
wire 	 	bank_num_10_equ_4;
wire 	 	bank_num_10_equ_5;
wire 	 	bank_num_10_equ_6;
wire 	 	bank_num_10_equ_7;
wire 	 	bank_num_10_equ_8;
wire 	 	bank_num_10_equ_9;

wire 	 	bank_num_11_equ_0;
wire 	 	bank_num_11_equ_1;
wire 	 	bank_num_11_equ_2;
wire 	 	bank_num_11_equ_3;
wire 	 	bank_num_11_equ_4;
wire 	 	bank_num_11_equ_5;
wire 	 	bank_num_11_equ_6;
wire 	 	bank_num_11_equ_7;
wire 	 	bank_num_11_equ_8;
wire 	 	bank_num_11_equ_9;
wire 	 	bank_num_11_equ_10;

wire 	 	bank_num_12_equ_0;
wire 	 	bank_num_12_equ_1;
wire 	 	bank_num_12_equ_2;
wire 	 	bank_num_12_equ_3;
wire 	 	bank_num_12_equ_4;
wire 	 	bank_num_12_equ_5;
wire 	 	bank_num_12_equ_6;
wire 	 	bank_num_12_equ_7;
wire 	 	bank_num_12_equ_8;
wire 	 	bank_num_12_equ_9;
wire 	 	bank_num_12_equ_10;
wire 	 	bank_num_12_equ_11;

wire 	 	bank_num_13_equ_0;
wire 	 	bank_num_13_equ_1;
wire 	 	bank_num_13_equ_2;
wire 	 	bank_num_13_equ_3;
wire 	 	bank_num_13_equ_4;
wire 	 	bank_num_13_equ_5;
wire 	 	bank_num_13_equ_6;
wire 	 	bank_num_13_equ_7;
wire 	 	bank_num_13_equ_8;
wire 	 	bank_num_13_equ_9;
wire 	 	bank_num_13_equ_10;
wire 	 	bank_num_13_equ_11;
wire 	 	bank_num_13_equ_12;

wire 	 	bank_num_14_equ_0;
wire 	 	bank_num_14_equ_1;
wire 	 	bank_num_14_equ_2;
wire 	 	bank_num_14_equ_3;
wire 	 	bank_num_14_equ_4;
wire 	 	bank_num_14_equ_5;
wire 	 	bank_num_14_equ_6;
wire 	 	bank_num_14_equ_7;
wire 	 	bank_num_14_equ_8;
wire 	 	bank_num_14_equ_9;
wire 	 	bank_num_14_equ_10;
wire 	 	bank_num_14_equ_11;
wire 	 	bank_num_14_equ_12;
wire 	 	bank_num_14_equ_13;

wire 	 	bank_num_15_equ_0;
wire 	 	bank_num_15_equ_1;
wire 	 	bank_num_15_equ_2;
wire 	 	bank_num_15_equ_3;
wire 	 	bank_num_15_equ_4;
wire 	 	bank_num_15_equ_5;
wire 	 	bank_num_15_equ_6;
wire 	 	bank_num_15_equ_7;
wire 	 	bank_num_15_equ_8;
wire 	 	bank_num_15_equ_9;
wire 	 	bank_num_15_equ_10;
wire 	 	bank_num_15_equ_11;
wire 	 	bank_num_15_equ_12;
wire 	 	bank_num_15_equ_13;
wire 	 	bank_num_15_equ_14;

// selection==1 means the substring actually doesn't access its correspoding bank
wire 	[14:0]	bank_select;
wire 	[14:0]	reg_bank_select_s2;

// reorder the accessed bank number
// bank_num[k] is the bank that kth string will access
wire 	[MEM_BANK_NUM:0]	bank_num_0;
wire 	[MEM_BANK_NUM:0]	bank_num_1;
wire 	[MEM_BANK_NUM:0]	bank_num_2;
wire 	[MEM_BANK_NUM:0]	bank_num_3;
wire 	[MEM_BANK_NUM:0]	bank_num_4;
wire 	[MEM_BANK_NUM:0]	bank_num_5;
wire 	[MEM_BANK_NUM:0]	bank_num_6;
wire 	[MEM_BANK_NUM:0]	bank_num_7;
wire 	[MEM_BANK_NUM:0]	bank_num_8;
wire 	[MEM_BANK_NUM:0]	bank_num_9;
wire 	[MEM_BANK_NUM:0]	bank_num_10;
wire 	[MEM_BANK_NUM:0]	bank_num_11;
wire 	[MEM_BANK_NUM:0]	bank_num_12;
wire 	[MEM_BANK_NUM:0]	bank_num_13;
wire 	[MEM_BANK_NUM:0]	bank_num_14;
wire 	[MEM_BANK_NUM:0]	bank_num_15;

wire 	[MEM_BANK_NUM:0]	reg_bank_num_0_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_1_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_2_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_3_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_4_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_5_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_6_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_7_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_8_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_9_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_10_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_11_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_12_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_13_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_14_s2;
wire 	[MEM_BANK_NUM:0]	reg_bank_num_15_s2;

// other temporary information stored in pipeline registers
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_0_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_1_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_2_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_3_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_4_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_5_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_6_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_7_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_8_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_9_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_10_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_11_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_12_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_13_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_14_s2;
wire	[MEM_BANK_NUM-1:0]	reg_raw_bank_num_15_s2;

wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_0_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_1_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_2_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_3_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_4_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_5_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_6_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_7_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_8_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_9_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_10_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_11_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_12_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_13_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_14_s2;
wire 	[MEM_BANK_DEPTH-1:0] 	reg_raw_bank_offset_15_s2;

wire 	[31:0]	input_position_s2;

wire  			start_s2;

wire 	[255:0]	data_window_in_s2;


// stage 2 data path

assign bank_select_1 = reg_raw_bank_num_1_s1 == reg_raw_bank_num_0_s1;

assign bank_num_2_equ_0 = (reg_raw_bank_num_2_s1 == reg_raw_bank_num_0_s1);
assign bank_num_2_equ_1 = (reg_raw_bank_num_2_s1 == reg_raw_bank_num_1_s1);
assign bank_select_2 = bank_num_2_equ_0 || bank_num_2_equ_1;

assign bank_num_3_equ_0 = (reg_raw_bank_num_3_s1 == reg_raw_bank_num_0_s1);
assign bank_num_3_equ_1 = (reg_raw_bank_num_3_s1 == reg_raw_bank_num_1_s1);
assign bank_num_3_equ_2 = (reg_raw_bank_num_3_s1 == reg_raw_bank_num_2_s1);
assign bank_select_3 = bank_num_3_equ_0 || bank_num_3_equ_1 || bank_num_3_equ_2;

assign bank_num_4_equ_0 = (reg_raw_bank_num_4_s1 == reg_raw_bank_num_0_s1);
assign bank_num_4_equ_1 = (reg_raw_bank_num_4_s1 == reg_raw_bank_num_1_s1);
assign bank_num_4_equ_2 = (reg_raw_bank_num_4_s1 == reg_raw_bank_num_2_s1);
assign bank_num_4_equ_3 = (reg_raw_bank_num_4_s1 == reg_raw_bank_num_3_s1);
assign bank_select_4 = bank_num_4_equ_0 || bank_num_4_equ_1 || bank_num_4_equ_2 || bank_num_4_equ_3;

assign bank_num_5_equ_0 = (reg_raw_bank_num_5_s1 == reg_raw_bank_num_0_s1);
assign bank_num_5_equ_1 = (reg_raw_bank_num_5_s1 == reg_raw_bank_num_1_s1);
assign bank_num_5_equ_2 = (reg_raw_bank_num_5_s1 == reg_raw_bank_num_2_s1);
assign bank_num_5_equ_3 = (reg_raw_bank_num_5_s1 == reg_raw_bank_num_3_s1);
assign bank_num_5_equ_4 = (reg_raw_bank_num_5_s1 == reg_raw_bank_num_4_s1);
assign bank_select_5 = bank_num_5_equ_0 || bank_num_5_equ_1 || bank_num_5_equ_2 || bank_num_5_equ_3 || bank_num_5_equ_4;

assign bank_num_6_equ_0 = (reg_raw_bank_num_6_s1 == reg_raw_bank_num_0_s1);
assign bank_num_6_equ_1 = (reg_raw_bank_num_6_s1 == reg_raw_bank_num_1_s1);
assign bank_num_6_equ_2 = (reg_raw_bank_num_6_s1 == reg_raw_bank_num_2_s1);
assign bank_num_6_equ_3 = (reg_raw_bank_num_6_s1 == reg_raw_bank_num_3_s1);
assign bank_num_6_equ_4 = (reg_raw_bank_num_6_s1 == reg_raw_bank_num_4_s1);
assign bank_num_6_equ_5 = (reg_raw_bank_num_6_s1 == reg_raw_bank_num_5_s1);
assign bank_select_6 = bank_num_6_equ_0 || bank_num_6_equ_1 || bank_num_6_equ_2 || bank_num_6_equ_3 || bank_num_6_equ_4 || bank_num_6_equ_5;

assign bank_num_7_equ_0 = (reg_raw_bank_num_7_s1 == reg_raw_bank_num_0_s1);
assign bank_num_7_equ_1 = (reg_raw_bank_num_7_s1 == reg_raw_bank_num_1_s1);
assign bank_num_7_equ_2 = (reg_raw_bank_num_7_s1 == reg_raw_bank_num_2_s1);
assign bank_num_7_equ_3 = (reg_raw_bank_num_7_s1 == reg_raw_bank_num_3_s1);
assign bank_num_7_equ_4 = (reg_raw_bank_num_7_s1 == reg_raw_bank_num_4_s1);
assign bank_num_7_equ_5 = (reg_raw_bank_num_7_s1 == reg_raw_bank_num_5_s1);
assign bank_num_7_equ_6 = (reg_raw_bank_num_7_s1 == reg_raw_bank_num_6_s1);
assign bank_select_7 = bank_num_7_equ_0 || bank_num_7_equ_1 || bank_num_7_equ_2 || bank_num_7_equ_3 || bank_num_7_equ_4 || bank_num_7_equ_5 + bank_num_7_equ_6;

assign bank_num_8_equ_0 = (reg_raw_bank_num_8_s1 == reg_raw_bank_num_0_s1);
assign bank_num_8_equ_1 = (reg_raw_bank_num_8_s1 == reg_raw_bank_num_1_s1);
assign bank_num_8_equ_2 = (reg_raw_bank_num_8_s1 == reg_raw_bank_num_2_s1);
assign bank_num_8_equ_3 = (reg_raw_bank_num_8_s1 == reg_raw_bank_num_3_s1);
assign bank_num_8_equ_4 = (reg_raw_bank_num_8_s1 == reg_raw_bank_num_4_s1);
assign bank_num_8_equ_5 = (reg_raw_bank_num_8_s1 == reg_raw_bank_num_5_s1);
assign bank_num_8_equ_6 = (reg_raw_bank_num_8_s1 == reg_raw_bank_num_6_s1);
assign bank_num_8_equ_7 = (reg_raw_bank_num_8_s1 == reg_raw_bank_num_7_s1);
assign bank_select_8 = bank_num_8_equ_0 || bank_num_8_equ_1 || bank_num_8_equ_2 || bank_num_8_equ_3 || bank_num_8_equ_4 || bank_num_8_equ_5 || bank_num_8_equ_6 || bank_num_8_equ_7;

assign bank_num_9_equ_0 = (reg_raw_bank_num_9_s1 == reg_raw_bank_num_0_s1);
assign bank_num_9_equ_1 = (reg_raw_bank_num_9_s1 == reg_raw_bank_num_1_s1);
assign bank_num_9_equ_2 = (reg_raw_bank_num_9_s1 == reg_raw_bank_num_2_s1);
assign bank_num_9_equ_3 = (reg_raw_bank_num_9_s1 == reg_raw_bank_num_3_s1);
assign bank_num_9_equ_4 = (reg_raw_bank_num_9_s1 == reg_raw_bank_num_4_s1);
assign bank_num_9_equ_5 = (reg_raw_bank_num_9_s1 == reg_raw_bank_num_5_s1);
assign bank_num_9_equ_6 = (reg_raw_bank_num_9_s1 == reg_raw_bank_num_6_s1);
assign bank_num_9_equ_7 = (reg_raw_bank_num_9_s1 == reg_raw_bank_num_7_s1);
assign bank_num_9_equ_8 = (reg_raw_bank_num_9_s1 == reg_raw_bank_num_8_s1);
assign bank_select_9 = bank_num_9_equ_0 || bank_num_9_equ_1 || bank_num_9_equ_2 || bank_num_9_equ_3 || bank_num_9_equ_4 || bank_num_9_equ_5 || bank_num_9_equ_6 || bank_num_9_equ_7 || bank_num_9_equ_8;

assign bank_num_10_equ_0 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_0_s1);
assign bank_num_10_equ_1 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_1_s1);
assign bank_num_10_equ_2 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_2_s1);
assign bank_num_10_equ_3 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_3_s1);
assign bank_num_10_equ_4 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_4_s1);
assign bank_num_10_equ_5 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_5_s1);
assign bank_num_10_equ_6 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_6_s1);
assign bank_num_10_equ_7 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_7_s1);
assign bank_num_10_equ_8 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_8_s1);
assign bank_num_10_equ_9 = (reg_raw_bank_num_10_s1 == reg_raw_bank_num_9_s1);
assign bank_select_10 = bank_num_10_equ_0 || bank_num_10_equ_1 || bank_num_10_equ_2 || bank_num_10_equ_3 || bank_num_10_equ_4 || bank_num_10_equ_5 || bank_num_10_equ_6 || bank_num_10_equ_7 
						 || bank_num_10_equ_8 || bank_num_10_equ_9;

assign bank_num_11_equ_0 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_0_s1);
assign bank_num_11_equ_1 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_1_s1);
assign bank_num_11_equ_2 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_2_s1);
assign bank_num_11_equ_3 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_3_s1);
assign bank_num_11_equ_4 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_4_s1);
assign bank_num_11_equ_5 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_5_s1);
assign bank_num_11_equ_6 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_6_s1);
assign bank_num_11_equ_7 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_7_s1);
assign bank_num_11_equ_8 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_8_s1);
assign bank_num_11_equ_9 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_9_s1);
assign bank_num_11_equ_10 = (reg_raw_bank_num_11_s1 == reg_raw_bank_num_10_s1);
assign bank_select_11 = bank_num_11_equ_0 || bank_num_11_equ_1 || bank_num_11_equ_2 || bank_num_11_equ_3 || bank_num_11_equ_4 || bank_num_11_equ_5 || bank_num_11_equ_6 || bank_num_11_equ_7 
						 || bank_num_11_equ_8 || bank_num_11_equ_9 || bank_num_11_equ_10;

assign bank_num_12_equ_0 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_0_s1);
assign bank_num_12_equ_1 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_1_s1);
assign bank_num_12_equ_2 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_2_s1);
assign bank_num_12_equ_3 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_3_s1);
assign bank_num_12_equ_4 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_4_s1);
assign bank_num_12_equ_5 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_5_s1);
assign bank_num_12_equ_6 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_6_s1);
assign bank_num_12_equ_7 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_7_s1);
assign bank_num_12_equ_8 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_8_s1);
assign bank_num_12_equ_9 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_9_s1);
assign bank_num_12_equ_10 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_10_s1);
assign bank_num_12_equ_11 = (reg_raw_bank_num_12_s1 == reg_raw_bank_num_11_s1);
assign bank_select_12 = bank_num_12_equ_0 || bank_num_12_equ_1 || bank_num_12_equ_2 || bank_num_12_equ_3 || bank_num_12_equ_4 || bank_num_12_equ_5 || bank_num_12_equ_6 || bank_num_12_equ_7 
						 || bank_num_12_equ_8 || bank_num_12_equ_9 || bank_num_12_equ_10 || bank_num_12_equ_11;

assign bank_num_13_equ_0 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_0_s1);
assign bank_num_13_equ_1 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_1_s1);
assign bank_num_13_equ_2 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_2_s1);
assign bank_num_13_equ_3 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_3_s1);
assign bank_num_13_equ_4 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_4_s1);
assign bank_num_13_equ_5 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_5_s1);
assign bank_num_13_equ_6 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_6_s1);
assign bank_num_13_equ_7 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_7_s1);
assign bank_num_13_equ_8 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_8_s1);
assign bank_num_13_equ_9 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_9_s1);
assign bank_num_13_equ_10 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_10_s1);
assign bank_num_13_equ_11 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_11_s1);
assign bank_num_13_equ_12 = (reg_raw_bank_num_13_s1 == reg_raw_bank_num_12_s1);
assign bank_select_13 = bank_num_13_equ_0 || bank_num_13_equ_1 || bank_num_13_equ_2 || bank_num_13_equ_3 || bank_num_13_equ_4 || bank_num_13_equ_5 || bank_num_13_equ_6 || bank_num_13_equ_7 
						 || bank_num_13_equ_8 || bank_num_13_equ_9 || bank_num_13_equ_10 || bank_num_13_equ_11 || bank_num_13_equ_12;

assign bank_num_14_equ_0 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_0_s1);
assign bank_num_14_equ_1 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_1_s1);
assign bank_num_14_equ_2 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_2_s1);
assign bank_num_14_equ_3 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_3_s1);
assign bank_num_14_equ_4 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_4_s1);
assign bank_num_14_equ_5 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_5_s1);
assign bank_num_14_equ_6 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_6_s1);
assign bank_num_14_equ_7 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_7_s1);
assign bank_num_14_equ_8 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_8_s1);
assign bank_num_14_equ_9 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_9_s1);
assign bank_num_14_equ_10 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_10_s1);
assign bank_num_14_equ_11 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_11_s1);
assign bank_num_14_equ_12 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_12_s1);
assign bank_num_14_equ_13 = (reg_raw_bank_num_14_s1 == reg_raw_bank_num_13_s1);
assign bank_select_14 = bank_num_14_equ_0 || bank_num_14_equ_1 || bank_num_14_equ_2 || bank_num_14_equ_3 || bank_num_14_equ_4 || bank_num_14_equ_5 || bank_num_14_equ_6 || bank_num_14_equ_7 
						 || bank_num_14_equ_8 || bank_num_14_equ_9 || bank_num_14_equ_10 || bank_num_14_equ_11 || bank_num_14_equ_12 || bank_num_14_equ_13;

assign bank_num_15_equ_0 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_0_s1);
assign bank_num_15_equ_1 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_1_s1);
assign bank_num_15_equ_2 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_2_s1);
assign bank_num_15_equ_3 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_3_s1);
assign bank_num_15_equ_4 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_4_s1);
assign bank_num_15_equ_5 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_5_s1);
assign bank_num_15_equ_6 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_6_s1);
assign bank_num_15_equ_7 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_7_s1);
assign bank_num_15_equ_8 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_8_s1);
assign bank_num_15_equ_9 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_9_s1);
assign bank_num_15_equ_10 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_10_s1);
assign bank_num_15_equ_11 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_11_s1);
assign bank_num_15_equ_12 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_12_s1);
assign bank_num_15_equ_13 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_13_s1);
assign bank_num_15_equ_14 = (reg_raw_bank_num_15_s1 == reg_raw_bank_num_14_s1);
assign bank_select_15 = bank_num_15_equ_0 || bank_num_15_equ_1 || bank_num_15_equ_2 || bank_num_15_equ_3 || bank_num_15_equ_4 || bank_num_15_equ_5 || bank_num_15_equ_6 || bank_num_15_equ_7 
						 || bank_num_15_equ_8 || bank_num_15_equ_9 || bank_num_15_equ_10 || bank_num_15_equ_11 || bank_num_15_equ_12 || bank_num_15_equ_13 || bank_num_15_equ_14;

// bank_select[0] correspond to substring 1
assign bank_select = {bank_select_15, bank_select_14, bank_select_13, bank_select_12, bank_select_11, bank_select_10, bank_select_9, bank_select_8, 
					   bank_select_7, bank_select_6, bank_select_5, bank_select_4, bank_select_3, bank_select_2, bank_select_1};

assign bank_num_0 = {1'b0, reg_raw_bank_num_0_s1};			//raw_bank_num_0 is number of bank that the first string accesses
assign bank_num_1 = (bank_select_1)?{6'd32}:{1'b0, reg_raw_bank_num_1_s1};
assign bank_num_2 = (bank_select_2)?{6'd32}:{1'b0, reg_raw_bank_num_2_s1};
assign bank_num_3 = (bank_select_3)?{6'd32}:{1'b0, reg_raw_bank_num_3_s1};
assign bank_num_4 = (bank_select_4)?{6'd32}:{1'b0, reg_raw_bank_num_4_s1};
assign bank_num_5 = (bank_select_5)?{6'd32}:{1'b0, reg_raw_bank_num_5_s1};
assign bank_num_6 = (bank_select_6)?{6'd32}:{1'b0, reg_raw_bank_num_6_s1};
assign bank_num_7 = (bank_select_7)?{6'd32}:{1'b0, reg_raw_bank_num_7_s1};
assign bank_num_8 = (bank_select_8)?{6'd32}:{1'b0, reg_raw_bank_num_8_s1};
assign bank_num_9 = (bank_select_9)?{6'd32}:{1'b0, reg_raw_bank_num_9_s1};
assign bank_num_10 = (bank_select_10)?{6'd32}:{1'b0, reg_raw_bank_num_10_s1};
assign bank_num_11 = (bank_select_11)?{6'd32}:{1'b0, reg_raw_bank_num_11_s1};
assign bank_num_12 = (bank_select_12)?{6'd32}:{1'b0, reg_raw_bank_num_12_s1};
assign bank_num_13 = (bank_select_13)?{6'd32}:{1'b0, reg_raw_bank_num_13_s1};
assign bank_num_14 = (bank_select_14)?{6'd32}:{1'b0, reg_raw_bank_num_14_s1};
assign bank_num_15 = (bank_select_15)?{6'd32}:{1'b0, reg_raw_bank_num_15_s1};

register_compression_reset #(.N(32)) register_input_position_s2_U(.d(prev_input_position), .clk(clk), .reset(rst), .q(input_position_s2));
register_compression_reset #(.N(1)) register_start_s2_U(.d(start_s1), .clk(clk), .reset(rst), .q(start_s2));

register_compression #(.N(15)) reg_bank_select_s2_U(.d(bank_select), .clk(clk), .q(reg_bank_select_s2));

register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_0_s2_U(.d(bank_num_0), .clk(clk), .q(reg_bank_num_0_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_1_s2_U(.d(bank_num_1), .clk(clk), .q(reg_bank_num_1_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_2_s2_U(.d(bank_num_2), .clk(clk), .q(reg_bank_num_2_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_3_s2_U(.d(bank_num_3), .clk(clk), .q(reg_bank_num_3_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_4_s2_U(.d(bank_num_4), .clk(clk), .q(reg_bank_num_4_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_5_s2_U(.d(bank_num_5), .clk(clk), .q(reg_bank_num_5_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_6_s2_U(.d(bank_num_6), .clk(clk), .q(reg_bank_num_6_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_7_s2_U(.d(bank_num_7), .clk(clk), .q(reg_bank_num_7_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_8_s2_U(.d(bank_num_8), .clk(clk), .q(reg_bank_num_8_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_9_s2_U(.d(bank_num_9), .clk(clk), .q(reg_bank_num_9_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_10_s2_U(.d(bank_num_10), .clk(clk), .q(reg_bank_num_10_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_11_s2_U(.d(bank_num_11), .clk(clk), .q(reg_bank_num_11_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_12_s2_U(.d(bank_num_12), .clk(clk), .q(reg_bank_num_12_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_13_s2_U(.d(bank_num_13), .clk(clk), .q(reg_bank_num_13_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_14_s2_U(.d(bank_num_14), .clk(clk), .q(reg_bank_num_14_s2));
register_compression #(.N(MEM_BANK_NUM+1)) reg_bank_num_15_s2_U(.d(bank_num_15), .clk(clk), .q(reg_bank_num_15_s2));

register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_0_s2_U(.d(reg_raw_bank_offset_0_s1), .clk(clk), .q(reg_raw_bank_offset_0_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_1_s2_U(.d(reg_raw_bank_offset_1_s1), .clk(clk), .q(reg_raw_bank_offset_1_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_2_s2_U(.d(reg_raw_bank_offset_2_s1), .clk(clk), .q(reg_raw_bank_offset_2_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_3_s2_U(.d(reg_raw_bank_offset_3_s1), .clk(clk), .q(reg_raw_bank_offset_3_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_4_s2_U(.d(reg_raw_bank_offset_4_s1), .clk(clk), .q(reg_raw_bank_offset_4_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_5_s2_U(.d(reg_raw_bank_offset_5_s1), .clk(clk), .q(reg_raw_bank_offset_5_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_6_s2_U(.d(reg_raw_bank_offset_6_s1), .clk(clk), .q(reg_raw_bank_offset_6_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_7_s2_U(.d(reg_raw_bank_offset_7_s1), .clk(clk), .q(reg_raw_bank_offset_7_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_8_s2_U(.d(reg_raw_bank_offset_8_s1), .clk(clk), .q(reg_raw_bank_offset_8_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_9_s2_U(.d(reg_raw_bank_offset_9_s1), .clk(clk), .q(reg_raw_bank_offset_9_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_10_s2_U(.d(reg_raw_bank_offset_10_s1), .clk(clk), .q(reg_raw_bank_offset_10_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_11_s2_U(.d(reg_raw_bank_offset_11_s1), .clk(clk), .q(reg_raw_bank_offset_11_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_12_s2_U(.d(reg_raw_bank_offset_12_s1), .clk(clk), .q(reg_raw_bank_offset_12_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_13_s2_U(.d(reg_raw_bank_offset_13_s1), .clk(clk), .q(reg_raw_bank_offset_13_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_14_s2_U(.d(reg_raw_bank_offset_14_s1), .clk(clk), .q(reg_raw_bank_offset_14_s2));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_15_s2_U(.d(reg_raw_bank_offset_15_s1), .clk(clk), .q(reg_raw_bank_offset_15_s2));

register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_0_s2_U(.d(reg_raw_bank_num_0_s1), .clk(clk), .q(reg_raw_bank_num_0_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_1_s2_U(.d(reg_raw_bank_num_1_s1), .clk(clk), .q(reg_raw_bank_num_1_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_2_s2_U(.d(reg_raw_bank_num_2_s1), .clk(clk), .q(reg_raw_bank_num_2_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_3_s2_U(.d(reg_raw_bank_num_3_s1), .clk(clk), .q(reg_raw_bank_num_3_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_4_s2_U(.d(reg_raw_bank_num_4_s1), .clk(clk), .q(reg_raw_bank_num_4_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_5_s2_U(.d(reg_raw_bank_num_5_s1), .clk(clk), .q(reg_raw_bank_num_5_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_6_s2_U(.d(reg_raw_bank_num_6_s1), .clk(clk), .q(reg_raw_bank_num_6_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_7_s2_U(.d(reg_raw_bank_num_7_s1), .clk(clk), .q(reg_raw_bank_num_7_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_8_s2_U(.d(reg_raw_bank_num_8_s1), .clk(clk), .q(reg_raw_bank_num_8_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_9_s2_U(.d(reg_raw_bank_num_9_s1), .clk(clk), .q(reg_raw_bank_num_9_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_10_s2_U(.d(reg_raw_bank_num_10_s1), .clk(clk), .q(reg_raw_bank_num_10_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_11_s2_U(.d(reg_raw_bank_num_11_s1), .clk(clk), .q(reg_raw_bank_num_11_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_12_s2_U(.d(reg_raw_bank_num_12_s1), .clk(clk), .q(reg_raw_bank_num_12_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_13_s2_U(.d(reg_raw_bank_num_13_s1), .clk(clk), .q(reg_raw_bank_num_13_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_14_s2_U(.d(reg_raw_bank_num_14_s1), .clk(clk), .q(reg_raw_bank_num_14_s2));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_15_s2_U(.d(reg_raw_bank_num_15_s1), .clk(clk), .q(reg_raw_bank_num_15_s2));

register_compression #(.N(256)) register_data_window_in_s2_U(.d(data_window_in_s1), .clk(clk), .q(data_window_in_s2));


// ====================================================================
//
//  Stage 3: Hash Calculation
//
// ====================================================================

// stage 3 ports definition

// kth string occupy the bank_occupied_k bank
// bank_occupied_k_s3 = 32 means kth bank is not occupied
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_0_s3;  
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_1_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_2_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_3_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_4_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_5_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_6_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_7_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_8_s3; 
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_9_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_10_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_11_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_12_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_13_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_14_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_15_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_16_s3; 
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_17_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_18_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_19_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_20_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_21_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_22_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_23_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_24_s3; 
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_25_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_26_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_27_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_28_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_29_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_30_s3;
wire 	[MEM_BANK_NUM-1:0]		bank_occupied_31_s3;

wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_0_s3;  
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_1_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_2_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_3_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_4_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_5_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_6_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_7_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_8_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_9_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_10_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_11_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_12_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_13_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_14_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_15_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_16_s3;  
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_17_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_18_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_19_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_20_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_21_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_22_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_23_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_24_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_25_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_26_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_27_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_28_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_29_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_30_s3;
wire 	[MEM_BANK_NUM-1:0]		reg_bank_occupied_31_s3;

//
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_0_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_1_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_2_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_3_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_4_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_5_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_6_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_7_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_8_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_9_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_10_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_11_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_12_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_13_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_14_s3;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_15_s3;

//
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_0_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_1_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_2_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_3_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_4_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_5_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_6_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_7_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_8_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_9_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_10_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_11_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_12_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_13_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_14_s3;
wire 	[MEM_BANK_DEPTH-1:0] 		reg_raw_bank_offset_15_s3;

//
wire 	[14:0]		reg_bank_select_s3;

wire	[31:0]      input_position_s3;

wire 	[255:0]		data_window_in_s3;

wire 				start_s3;

// 
generate_bank_occupied  generate_bank_occupied_0_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd0),  
	.dout(bank_occupied_0_s3)
);

generate_bank_occupied  generate_bank_occupied_1_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd1),  
	.dout(bank_occupied_1_s3)
);

generate_bank_occupied  generate_bank_occupied_2_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd2),  
	.dout(bank_occupied_2_s3)
);

generate_bank_occupied  generate_bank_occupied_3_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd3),  
	.dout(bank_occupied_3_s3)
);

generate_bank_occupied  generate_bank_occupied_4_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd4),  
	.dout(bank_occupied_4_s3)
);

generate_bank_occupied  generate_bank_occupied_5_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd5),  
	.dout(bank_occupied_5_s3)
);

generate_bank_occupied  generate_bank_occupied_6_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd6),  
	.dout(bank_occupied_6_s3)
);

generate_bank_occupied  generate_bank_occupied_7_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd7),  
	.dout(bank_occupied_7_s3)
);

generate_bank_occupied  generate_bank_occupied_8_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd8),  
	.dout(bank_occupied_8_s3)
);

generate_bank_occupied  generate_bank_occupied_9_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd9),  
	.dout(bank_occupied_9_s3)
);

generate_bank_occupied  generate_bank_occupied_10_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd10),  
	.dout(bank_occupied_10_s3)
);

generate_bank_occupied  generate_bank_occupied_11_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd11),  
	.dout(bank_occupied_11_s3)
);

generate_bank_occupied  generate_bank_occupied_12_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd12),  
	.dout(bank_occupied_12_s3)
);

generate_bank_occupied  generate_bank_occupied_13_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd13),  
	.dout(bank_occupied_13_s3)
);

generate_bank_occupied  generate_bank_occupied_14_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd14),  
	.dout(bank_occupied_14_s3)
);

generate_bank_occupied  generate_bank_occupied_15_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd15),  
	.dout(bank_occupied_15_s3)
);

generate_bank_occupied  generate_bank_occupied_16_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd16),  
	.dout(bank_occupied_16_s3)
);

generate_bank_occupied  generate_bank_occupied_17_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd17),  
	.dout(bank_occupied_17_s3)
);

generate_bank_occupied  generate_bank_occupied_18_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd18),  
	.dout(bank_occupied_18_s3)
);

generate_bank_occupied  generate_bank_occupied_19_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd19),  
	.dout(bank_occupied_19_s3)
);

generate_bank_occupied  generate_bank_occupied_20_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd20),  
	.dout(bank_occupied_20_s3)
);

generate_bank_occupied  generate_bank_occupied_21_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd21),  
	.dout(bank_occupied_21_s3)
);

generate_bank_occupied  generate_bank_occupied_22_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd22),  
	.dout(bank_occupied_22_s3)
);

generate_bank_occupied  generate_bank_occupied_23_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd23),  
	.dout(bank_occupied_23_s3)
);

generate_bank_occupied  generate_bank_occupied_24_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd24),  
	.dout(bank_occupied_24_s3)
);

generate_bank_occupied  generate_bank_occupied_25_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd25),  
	.dout(bank_occupied_25_s3)
);

generate_bank_occupied  generate_bank_occupied_26_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd26),  
	.dout(bank_occupied_26_s3)
);

generate_bank_occupied  generate_bank_occupied_27_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd27),  
	.dout(bank_occupied_27_s3)
);

generate_bank_occupied  generate_bank_occupied_28_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd28),  
	.dout(bank_occupied_28_s3)
);

generate_bank_occupied  generate_bank_occupied_29_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd29),  
	.dout(bank_occupied_29_s3)
);

generate_bank_occupied  generate_bank_occupied_30_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd30),  
	.dout(bank_occupied_30_s3)
);

generate_bank_occupied  generate_bank_occupied_31_U(
	.din0(reg_bank_num_0_s2), 
	.din1(reg_bank_num_1_s2), 
	.din2(reg_bank_num_2_s2), 
	.din3(reg_bank_num_3_s2), 
	.din4(reg_bank_num_4_s2), 
	.din5(reg_bank_num_5_s2), 
	.din6(reg_bank_num_6_s2), 
	.din7(reg_bank_num_7_s2), 
	.din8(reg_bank_num_8_s2), 
	.din9(reg_bank_num_9_s2), 
	.din10(reg_bank_num_10_s2), 
	.din11(reg_bank_num_11_s2), 
	.din12(reg_bank_num_12_s2), 
	.din13(reg_bank_num_13_s2), 
	.din14(reg_bank_num_14_s2), 
	.din15(reg_bank_num_15_s2),
	.sel(6'd31),  
	.dout(bank_occupied_31_s3)
);

//
register_compression_reset #(.N(32)) register_input_position_s3_U(.d(input_position_s2), .clk(clk), .reset(rst), .q(input_position_s3));

register_compression_reset #(.N(1)) register_start_s3_U(.d(start_s2), .clk(clk), .reset(rst), .q(start_s3));

//
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_0_s3_U(.d(bank_occupied_0_s3), .clk(clk), .q(reg_bank_occupied_0_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_1_s3_U(.d(bank_occupied_1_s3), .clk(clk), .q(reg_bank_occupied_1_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_2_s3_U(.d(bank_occupied_2_s3), .clk(clk), .q(reg_bank_occupied_2_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_3_s3_U(.d(bank_occupied_3_s3), .clk(clk), .q(reg_bank_occupied_3_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_4_s3_U(.d(bank_occupied_4_s3), .clk(clk), .q(reg_bank_occupied_4_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_5_s3_U(.d(bank_occupied_5_s3), .clk(clk), .q(reg_bank_occupied_5_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_6_s3_U(.d(bank_occupied_6_s3), .clk(clk), .q(reg_bank_occupied_6_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_7_s3_U(.d(bank_occupied_7_s3), .clk(clk), .q(reg_bank_occupied_7_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_8_s3_U(.d(bank_occupied_8_s3), .clk(clk), .q(reg_bank_occupied_8_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_9_s3_U(.d(bank_occupied_9_s3), .clk(clk), .q(reg_bank_occupied_9_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_10_s3_U(.d(bank_occupied_10_s3), .clk(clk), .q(reg_bank_occupied_10_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_11_s3_U(.d(bank_occupied_11_s3), .clk(clk), .q(reg_bank_occupied_11_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_12_s3_U(.d(bank_occupied_12_s3), .clk(clk), .q(reg_bank_occupied_12_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_13_s3_U(.d(bank_occupied_13_s3), .clk(clk), .q(reg_bank_occupied_13_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_14_s3_U(.d(bank_occupied_14_s3), .clk(clk), .q(reg_bank_occupied_14_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_15_s3_U(.d(bank_occupied_15_s3), .clk(clk), .q(reg_bank_occupied_15_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_16_s3_U(.d(bank_occupied_16_s3), .clk(clk), .q(reg_bank_occupied_16_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_17_s3_U(.d(bank_occupied_17_s3), .clk(clk), .q(reg_bank_occupied_17_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_18_s3_U(.d(bank_occupied_18_s3), .clk(clk), .q(reg_bank_occupied_18_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_19_s3_U(.d(bank_occupied_19_s3), .clk(clk), .q(reg_bank_occupied_19_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_20_s3_U(.d(bank_occupied_20_s3), .clk(clk), .q(reg_bank_occupied_20_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_21_s3_U(.d(bank_occupied_21_s3), .clk(clk), .q(reg_bank_occupied_21_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_22_s3_U(.d(bank_occupied_22_s3), .clk(clk), .q(reg_bank_occupied_22_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_23_s3_U(.d(bank_occupied_23_s3), .clk(clk), .q(reg_bank_occupied_23_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_24_s3_U(.d(bank_occupied_24_s3), .clk(clk), .q(reg_bank_occupied_24_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_25_s3_U(.d(bank_occupied_25_s3), .clk(clk), .q(reg_bank_occupied_25_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_26_s3_U(.d(bank_occupied_26_s3), .clk(clk), .q(reg_bank_occupied_26_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_27_s3_U(.d(bank_occupied_27_s3), .clk(clk), .q(reg_bank_occupied_27_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_28_s3_U(.d(bank_occupied_28_s3), .clk(clk), .q(reg_bank_occupied_28_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_29_s3_U(.d(bank_occupied_29_s3), .clk(clk), .q(reg_bank_occupied_29_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_30_s3_U(.d(bank_occupied_30_s3), .clk(clk), .q(reg_bank_occupied_30_s3));
register_compression #(.N(MEM_BANK_NUM)) register_bank_occupied_31_s3_U(.d(bank_occupied_31_s3), .clk(clk), .q(reg_bank_occupied_31_s3));

register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_0_s3_U(.d(reg_raw_bank_offset_0_s2), .clk(clk), .q(reg_raw_bank_offset_0_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_1_s3_U(.d(reg_raw_bank_offset_1_s2), .clk(clk), .q(reg_raw_bank_offset_1_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_2_s3_U(.d(reg_raw_bank_offset_2_s2), .clk(clk), .q(reg_raw_bank_offset_2_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_3_s3_U(.d(reg_raw_bank_offset_3_s2), .clk(clk), .q(reg_raw_bank_offset_3_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_4_s3_U(.d(reg_raw_bank_offset_4_s2), .clk(clk), .q(reg_raw_bank_offset_4_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_5_s3_U(.d(reg_raw_bank_offset_5_s2), .clk(clk), .q(reg_raw_bank_offset_5_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_6_s3_U(.d(reg_raw_bank_offset_6_s2), .clk(clk), .q(reg_raw_bank_offset_6_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_7_s3_U(.d(reg_raw_bank_offset_7_s2), .clk(clk), .q(reg_raw_bank_offset_7_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_8_s3_U(.d(reg_raw_bank_offset_8_s2), .clk(clk), .q(reg_raw_bank_offset_8_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_9_s3_U(.d(reg_raw_bank_offset_9_s2), .clk(clk), .q(reg_raw_bank_offset_9_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_10_s3_U(.d(reg_raw_bank_offset_10_s2), .clk(clk), .q(reg_raw_bank_offset_10_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_11_s3_U(.d(reg_raw_bank_offset_11_s2), .clk(clk), .q(reg_raw_bank_offset_11_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_12_s3_U(.d(reg_raw_bank_offset_12_s2), .clk(clk), .q(reg_raw_bank_offset_12_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_13_s3_U(.d(reg_raw_bank_offset_13_s2), .clk(clk), .q(reg_raw_bank_offset_13_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_14_s3_U(.d(reg_raw_bank_offset_14_s2), .clk(clk), .q(reg_raw_bank_offset_14_s3));
register_compression #(.N(MEM_BANK_DEPTH)) register_raw_bank_offset_15_s3_U(.d(reg_raw_bank_offset_15_s2), .clk(clk), .q(reg_raw_bank_offset_15_s3));

register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_0_s3_U(.d(reg_raw_bank_num_0_s2), .clk(clk), .q(reg_raw_bank_num_0_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_1_s3_U(.d(reg_raw_bank_num_1_s2), .clk(clk), .q(reg_raw_bank_num_1_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_2_s3_U(.d(reg_raw_bank_num_2_s2), .clk(clk), .q(reg_raw_bank_num_2_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_3_s3_U(.d(reg_raw_bank_num_3_s2), .clk(clk), .q(reg_raw_bank_num_3_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_4_s3_U(.d(reg_raw_bank_num_4_s2), .clk(clk), .q(reg_raw_bank_num_4_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_5_s3_U(.d(reg_raw_bank_num_5_s2), .clk(clk), .q(reg_raw_bank_num_5_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_6_s3_U(.d(reg_raw_bank_num_6_s2), .clk(clk), .q(reg_raw_bank_num_6_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_7_s3_U(.d(reg_raw_bank_num_7_s2), .clk(clk), .q(reg_raw_bank_num_7_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_8_s3_U(.d(reg_raw_bank_num_8_s2), .clk(clk), .q(reg_raw_bank_num_8_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_9_s3_U(.d(reg_raw_bank_num_9_s2), .clk(clk), .q(reg_raw_bank_num_9_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_10_s3_U(.d(reg_raw_bank_num_10_s2), .clk(clk), .q(reg_raw_bank_num_10_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_11_s3_U(.d(reg_raw_bank_num_11_s2), .clk(clk), .q(reg_raw_bank_num_11_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_12_s3_U(.d(reg_raw_bank_num_12_s2), .clk(clk), .q(reg_raw_bank_num_12_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_13_s3_U(.d(reg_raw_bank_num_13_s2), .clk(clk), .q(reg_raw_bank_num_13_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_14_s3_U(.d(reg_raw_bank_num_14_s2), .clk(clk), .q(reg_raw_bank_num_14_s3));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_15_s3_U(.d(reg_raw_bank_num_15_s2), .clk(clk), .q(reg_raw_bank_num_15_s3));

register_compression #(.N(15)) reg_bank_select_s3_U(.d(reg_bank_select_s2), .clk(clk), .q(reg_bank_select_s3));

register_compression #(.N(256)) register_data_window_in_s3_U(.d(data_window_in_s2), .clk(clk), .q(data_window_in_s3));


// ====================================================================
//
//  Stage 4: Hash Calculation
//
// ====================================================================

// stage 4 ports definition

// 
wire	[MEM_BANK_DEPTH:0] 	bank_offset_0_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_1_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_2_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_3_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_4_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_5_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_6_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_7_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_8_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_9_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_10_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_11_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_12_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_13_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_14_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_15_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_16_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_17_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_18_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_19_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_20_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_21_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_22_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_23_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_24_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_25_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_26_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_27_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_28_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_29_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_30_s4;
wire	[MEM_BANK_DEPTH:0] 	bank_offset_31_s4;

wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_0_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_1_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_2_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_3_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_4_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_5_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_6_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_7_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_8_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_9_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_10_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_11_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_12_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_13_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_14_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_15_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_16_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_17_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_18_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_19_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_20_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_21_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_22_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_23_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_24_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_25_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_26_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_27_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_28_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_29_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_30_s4;
wire	[MEM_BANK_DEPTH:0] 	reg_bank_offset_31_s4;

//
wire 	[127:0] 	update_0_s4;
wire 	[127:0] 	update_1_s4;
wire 	[127:0] 	update_2_s4;
wire 	[127:0] 	update_3_s4;
wire 	[127:0] 	update_4_s4;
wire 	[127:0] 	update_5_s4;
wire 	[127:0] 	update_6_s4;
wire 	[127:0] 	update_7_s4;
wire 	[127:0] 	update_8_s4;
wire 	[127:0] 	update_9_s4;
wire 	[127:0] 	update_10_s4;
wire 	[127:0] 	update_11_s4;
wire 	[127:0] 	update_12_s4;
wire 	[127:0] 	update_13_s4;
wire 	[127:0] 	update_14_s4;
wire 	[127:0] 	update_15_s4;
wire 	[127:0] 	update_16_s4;
wire 	[127:0] 	update_17_s4;
wire 	[127:0] 	update_18_s4;
wire 	[127:0] 	update_19_s4;
wire 	[127:0] 	update_20_s4;
wire 	[127:0] 	update_21_s4;
wire 	[127:0] 	update_22_s4;
wire 	[127:0] 	update_23_s4;
wire 	[127:0] 	update_24_s4;
wire 	[127:0] 	update_25_s4;
wire 	[127:0] 	update_26_s4;
wire 	[127:0] 	update_27_s4;
wire 	[127:0] 	update_28_s4;
wire 	[127:0] 	update_29_s4;
wire 	[127:0] 	update_30_s4;
wire 	[127:0] 	update_31_s4;

wire 	[127:0] 	reg_update_0_s4;
wire 	[127:0] 	reg_update_1_s4;
wire 	[127:0] 	reg_update_2_s4;
wire 	[127:0] 	reg_update_3_s4;
wire 	[127:0] 	reg_update_4_s4;
wire 	[127:0] 	reg_update_5_s4;
wire 	[127:0] 	reg_update_6_s4;
wire 	[127:0] 	reg_update_7_s4;
wire 	[127:0] 	reg_update_8_s4;
wire 	[127:0] 	reg_update_9_s4;
wire 	[127:0] 	reg_update_10_s4;
wire 	[127:0] 	reg_update_11_s4;
wire 	[127:0] 	reg_update_12_s4;
wire 	[127:0] 	reg_update_13_s4;
wire 	[127:0] 	reg_update_14_s4;
wire 	[127:0] 	reg_update_15_s4;
wire 	[127:0] 	reg_update_16_s4;
wire 	[127:0] 	reg_update_17_s4;
wire 	[127:0] 	reg_update_18_s4;
wire 	[127:0] 	reg_update_19_s4;
wire 	[127:0] 	reg_update_20_s4;
wire 	[127:0] 	reg_update_21_s4;
wire 	[127:0] 	reg_update_22_s4;
wire 	[127:0] 	reg_update_23_s4;
wire 	[127:0] 	reg_update_24_s4;
wire 	[127:0] 	reg_update_25_s4;
wire 	[127:0] 	reg_update_26_s4;
wire 	[127:0] 	reg_update_27_s4;
wire 	[127:0] 	reg_update_28_s4;
wire 	[127:0] 	reg_update_29_s4;
wire 	[127:0] 	reg_update_30_s4;
wire 	[127:0] 	reg_update_31_s4;

//
wire 	[31:0] 		update_position_bank_0_s4;
wire 	[31:0] 		update_position_bank_1_s4;
wire 	[31:0] 		update_position_bank_2_s4;
wire 	[31:0] 		update_position_bank_3_s4;
wire 	[31:0] 		update_position_bank_4_s4;
wire 	[31:0] 		update_position_bank_5_s4;
wire 	[31:0] 		update_position_bank_6_s4;
wire 	[31:0] 		update_position_bank_7_s4;
wire 	[31:0] 		update_position_bank_8_s4;
wire 	[31:0] 		update_position_bank_9_s4;
wire 	[31:0] 		update_position_bank_10_s4;
wire 	[31:0] 		update_position_bank_11_s4;
wire 	[31:0] 		update_position_bank_12_s4;
wire 	[31:0] 		update_position_bank_13_s4;
wire 	[31:0] 		update_position_bank_14_s4;
wire 	[31:0] 		update_position_bank_15_s4;
wire 	[31:0] 		update_position_bank_16_s4;
wire 	[31:0] 		update_position_bank_17_s4;
wire 	[31:0] 		update_position_bank_18_s4;
wire 	[31:0] 		update_position_bank_19_s4;
wire 	[31:0] 		update_position_bank_20_s4;
wire 	[31:0] 		update_position_bank_21_s4;
wire 	[31:0] 		update_position_bank_22_s4;
wire 	[31:0] 		update_position_bank_23_s4;
wire 	[31:0] 		update_position_bank_24_s4;
wire 	[31:0] 		update_position_bank_25_s4;
wire 	[31:0] 		update_position_bank_26_s4;
wire 	[31:0] 		update_position_bank_27_s4;
wire 	[31:0] 		update_position_bank_28_s4;
wire 	[31:0] 		update_position_bank_29_s4;
wire 	[31:0] 		update_position_bank_30_s4;
wire 	[31:0] 		update_position_bank_31_s4;

wire	[31:0]		reg_update_position_bank_0_s4;
wire	[31:0]		reg_update_position_bank_1_s4;
wire	[31:0]		reg_update_position_bank_2_s4;
wire	[31:0]		reg_update_position_bank_3_s4;
wire	[31:0]		reg_update_position_bank_4_s4;
wire	[31:0]		reg_update_position_bank_5_s4;
wire	[31:0]		reg_update_position_bank_6_s4;
wire	[31:0]		reg_update_position_bank_7_s4;
wire	[31:0]		reg_update_position_bank_8_s4;
wire	[31:0]		reg_update_position_bank_9_s4;
wire	[31:0]		reg_update_position_bank_10_s4;
wire	[31:0]		reg_update_position_bank_11_s4;
wire	[31:0]		reg_update_position_bank_12_s4;
wire	[31:0]		reg_update_position_bank_13_s4;
wire	[31:0]		reg_update_position_bank_14_s4;
wire	[31:0]		reg_update_position_bank_15_s4;
wire	[31:0]		reg_update_position_bank_16_s4;
wire	[31:0]		reg_update_position_bank_17_s4;
wire	[31:0]		reg_update_position_bank_18_s4;
wire	[31:0]		reg_update_position_bank_19_s4;
wire	[31:0]		reg_update_position_bank_20_s4;
wire	[31:0]		reg_update_position_bank_21_s4;
wire	[31:0]		reg_update_position_bank_22_s4;
wire	[31:0]		reg_update_position_bank_23_s4;
wire	[31:0]		reg_update_position_bank_24_s4;
wire	[31:0]		reg_update_position_bank_25_s4;
wire	[31:0]		reg_update_position_bank_26_s4;
wire	[31:0]		reg_update_position_bank_27_s4;
wire	[31:0]		reg_update_position_bank_28_s4;
wire	[31:0]		reg_update_position_bank_29_s4;
wire	[31:0]		reg_update_position_bank_30_s4;
wire	[31:0]		reg_update_position_bank_31_s4;

// 
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_0_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_1_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_2_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_3_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_4_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_5_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_6_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_7_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_8_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_9_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_10_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_11_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_12_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_13_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_14_s4;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_15_s4;

// 
wire 	[14:0]		reg_bank_select_s4;

wire	[31:0]      input_position_s4;

wire 	[255:0]		data_window_in_s4;

wire 				start_s4;

// select the right offset (address) for each memory bank
mux_16to1_bank_offset  mux_16to1_bank_offset_0_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_0_s3),
	.dout(bank_offset_0_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_1_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_1_s3),
	.dout(bank_offset_1_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_2_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_2_s3),
	.dout(bank_offset_2_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_3_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_3_s3),
	.dout(bank_offset_3_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_4_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_4_s3),
	.dout(bank_offset_4_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_5_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_5_s3),
	.dout(bank_offset_5_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_6_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_6_s3),
	.dout(bank_offset_6_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_7_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_7_s3),
	.dout(bank_offset_7_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_8_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_8_s3),
	.dout(bank_offset_8_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_9_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_9_s3),
	.dout(bank_offset_9_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_10_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_10_s3),
	.dout(bank_offset_10_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_11_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_11_s3),
	.dout(bank_offset_11_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_12_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_12_s3),
	.dout(bank_offset_12_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_13_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_13_s3),
	.dout(bank_offset_13_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_14_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_14_s3),
	.dout(bank_offset_14_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_15_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_15_s3),
	.dout(bank_offset_15_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_16_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_16_s3),
	.dout(bank_offset_16_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_17_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_17_s3),
	.dout(bank_offset_17_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_18_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_18_s3),
	.dout(bank_offset_18_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_19_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_19_s3),
	.dout(bank_offset_19_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_20_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_20_s3),
	.dout(bank_offset_20_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_21_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_21_s3),
	.dout(bank_offset_21_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_22_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_22_s3),
	.dout(bank_offset_22_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_23_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_23_s3),
	.dout(bank_offset_23_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_24_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_24_s3),
	.dout(bank_offset_24_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_25_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_25_s3),
	.dout(bank_offset_25_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_26_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_26_s3),
	.dout(bank_offset_26_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_27_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_27_s3),
	.dout(bank_offset_27_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_28_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_28_s3),
	.dout(bank_offset_28_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_29_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_29_s3),
	.dout(bank_offset_29_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_30_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_30_s3),
	.dout(bank_offset_30_s4)
);

mux_16to1_bank_offset  mux_16to1_bank_offset_31_U(
	.din0(reg_raw_bank_offset_0_s3),
	.din1(reg_raw_bank_offset_1_s3), 
	.din2(reg_raw_bank_offset_2_s3), 
	.din3(reg_raw_bank_offset_3_s3), 
	.din4(reg_raw_bank_offset_4_s3), 
	.din5(reg_raw_bank_offset_5_s3), 
	.din6(reg_raw_bank_offset_6_s3), 
	.din7(reg_raw_bank_offset_7_s3), 
	.din8(reg_raw_bank_offset_8_s3),
	.din9(reg_raw_bank_offset_9_s3), 
	.din10(reg_raw_bank_offset_10_s3), 
	.din11(reg_raw_bank_offset_11_s3), 
	.din12(reg_raw_bank_offset_12_s3), 
	.din13(reg_raw_bank_offset_13_s3), 
	.din14(reg_raw_bank_offset_14_s3), 
	.din15(reg_raw_bank_offset_15_s3),
	.sel(reg_bank_occupied_31_s3),
	.dout(bank_offset_31_s4)
);

// select the right hash content input for each bank
mux_16to1_hash_update 	mux_8to1_hash_update_0_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_0_s3),
	.dout(update_0_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_1_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_1_s3),
	.dout(update_1_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_2_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_2_s3),
	.dout(update_2_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_3_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_3_s3),
	.dout(update_3_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_4_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_4_s3),
	.dout(update_4_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_5_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_5_s3),
	.dout(update_5_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_6_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_6_s3),
	.dout(update_6_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_7_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_7_s3),
	.dout(update_7_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_8_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_8_s3),
	.dout(update_8_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_9_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_9_s3),
	.dout(update_9_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_10_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_10_s3),
	.dout(update_10_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_11_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_11_s3),
	.dout(update_11_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_12_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_12_s3),
	.dout(update_12_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_13_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_13_s3),
	.dout(update_13_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_14_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_14_s3),
	.dout(update_14_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_15_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_15_s3),
	.dout(update_15_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_16_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_16_s3),
	.dout(update_16_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_17_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_17_s3),
	.dout(update_17_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_18_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_18_s3),
	.dout(update_18_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_19_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_19_s3),
	.dout(update_19_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_20_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_20_s3),
	.dout(update_20_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_21_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_21_s3),
	.dout(update_21_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_22_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_22_s3),
	.dout(update_22_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_23_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_23_s3),
	.dout(update_23_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_24_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_24_s3),
	.dout(update_24_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_25_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_25_s3),
	.dout(update_25_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_26_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_26_s3),
	.dout(update_26_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_27_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_27_s3),
	.dout(update_27_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_28_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_28_s3),
	.dout(update_28_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_29_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_29_s3),
	.dout(update_29_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_30_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_30_s3),
	.dout(update_30_s4)
);

mux_16to1_hash_update 	mux_8to1_hash_update_31_U(
	.din0(data_window_in_s3[255:128]),
	.din1(data_window_in_s3[247:120]),
	.din2(data_window_in_s3[239:112]),
	.din3(data_window_in_s3[231:104]),
	.din4(data_window_in_s3[223:96]),
	.din5(data_window_in_s3[215:88]),
	.din6(data_window_in_s3[207:80]),
	.din7(data_window_in_s3[199:72]),
	.din8(data_window_in_s3[191:64]),
	.din9(data_window_in_s3[183:56]),
	.din10(data_window_in_s3[175:48]),
	.din11(data_window_in_s3[167:40]),
	.din12(data_window_in_s3[159:32]),
	.din13(data_window_in_s3[151:24]),
	.din14(data_window_in_s3[143:16]),
	.din15(data_window_in_s3[135:8]),
	.sel(reg_bank_occupied_31_s3),
	.dout(update_31_s4)
);

// calculate the hash position for each bank
assign update_position_bank_0_s4 = input_position_s3 + reg_bank_occupied_0_s3;
assign update_position_bank_1_s4 = input_position_s3 + reg_bank_occupied_1_s3;
assign update_position_bank_2_s4 = input_position_s3 + reg_bank_occupied_2_s3;
assign update_position_bank_3_s4 = input_position_s3 + reg_bank_occupied_3_s3;
assign update_position_bank_4_s4 = input_position_s3 + reg_bank_occupied_4_s3;
assign update_position_bank_5_s4 = input_position_s3 + reg_bank_occupied_5_s3;
assign update_position_bank_6_s4 = input_position_s3 + reg_bank_occupied_6_s3;
assign update_position_bank_7_s4 = input_position_s3 + reg_bank_occupied_7_s3;
assign update_position_bank_8_s4 = input_position_s3 + reg_bank_occupied_8_s3;
assign update_position_bank_9_s4 = input_position_s3 + reg_bank_occupied_9_s3;
assign update_position_bank_10_s4 = input_position_s3 + reg_bank_occupied_10_s3;
assign update_position_bank_11_s4 = input_position_s3 + reg_bank_occupied_11_s3;
assign update_position_bank_12_s4 = input_position_s3 + reg_bank_occupied_12_s3;
assign update_position_bank_13_s4 = input_position_s3 + reg_bank_occupied_13_s3;
assign update_position_bank_14_s4 = input_position_s3 + reg_bank_occupied_14_s3;
assign update_position_bank_15_s4 = input_position_s3 + reg_bank_occupied_15_s3;
assign update_position_bank_16_s4 = input_position_s3 + reg_bank_occupied_16_s3;
assign update_position_bank_17_s4 = input_position_s3 + reg_bank_occupied_17_s3;
assign update_position_bank_18_s4 = input_position_s3 + reg_bank_occupied_18_s3;
assign update_position_bank_19_s4 = input_position_s3 + reg_bank_occupied_19_s3;
assign update_position_bank_20_s4 = input_position_s3 + reg_bank_occupied_20_s3;
assign update_position_bank_21_s4 = input_position_s3 + reg_bank_occupied_21_s3;
assign update_position_bank_22_s4 = input_position_s3 + reg_bank_occupied_22_s3;
assign update_position_bank_23_s4 = input_position_s3 + reg_bank_occupied_23_s3;
assign update_position_bank_24_s4 = input_position_s3 + reg_bank_occupied_24_s3;
assign update_position_bank_25_s4 = input_position_s3 + reg_bank_occupied_25_s3;
assign update_position_bank_26_s4 = input_position_s3 + reg_bank_occupied_26_s3;
assign update_position_bank_27_s4 = input_position_s3 + reg_bank_occupied_27_s3;
assign update_position_bank_28_s4 = input_position_s3 + reg_bank_occupied_28_s3;
assign update_position_bank_29_s4 = input_position_s3 + reg_bank_occupied_29_s3;
assign update_position_bank_30_s4 = input_position_s3 + reg_bank_occupied_30_s3;
assign update_position_bank_31_s4 = input_position_s3 + reg_bank_occupied_31_s3;

// 
register_compression_reset #(.N(32)) register_input_position_s4_U(.d(input_position_s3), .clk(clk), .reset(rst), .q(input_position_s4));

register_compression_reset #(.N(1)) register_start_s4_U(.d(start_s3), .clk(clk), .reset(rst), .q(start_s4));

// 
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_0_s4_U(.d(bank_offset_0_s4), .clk(clk), .q(reg_bank_offset_0_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_1_s4_U(.d(bank_offset_1_s4), .clk(clk), .q(reg_bank_offset_1_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_2_s4_U(.d(bank_offset_2_s4), .clk(clk), .q(reg_bank_offset_2_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_3_s4_U(.d(bank_offset_3_s4), .clk(clk), .q(reg_bank_offset_3_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_4_s4_U(.d(bank_offset_4_s4), .clk(clk), .q(reg_bank_offset_4_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_5_s4_U(.d(bank_offset_5_s4), .clk(clk), .q(reg_bank_offset_5_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_6_s4_U(.d(bank_offset_6_s4), .clk(clk), .q(reg_bank_offset_6_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_7_s4_U(.d(bank_offset_7_s4), .clk(clk), .q(reg_bank_offset_7_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_8_s4_U(.d(bank_offset_8_s4), .clk(clk), .q(reg_bank_offset_8_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_9_s4_U(.d(bank_offset_9_s4), .clk(clk), .q(reg_bank_offset_9_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_10_s4_U(.d(bank_offset_10_s4), .clk(clk), .q(reg_bank_offset_10_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_11_s4_U(.d(bank_offset_11_s4), .clk(clk), .q(reg_bank_offset_11_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_12_s4_U(.d(bank_offset_12_s4), .clk(clk), .q(reg_bank_offset_12_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_13_s4_U(.d(bank_offset_13_s4), .clk(clk), .q(reg_bank_offset_13_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_14_s4_U(.d(bank_offset_14_s4), .clk(clk), .q(reg_bank_offset_14_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_15_s4_U(.d(bank_offset_15_s4), .clk(clk), .q(reg_bank_offset_15_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_16_s4_U(.d(bank_offset_16_s4), .clk(clk), .q(reg_bank_offset_16_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_17_s4_U(.d(bank_offset_17_s4), .clk(clk), .q(reg_bank_offset_17_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_18_s4_U(.d(bank_offset_18_s4), .clk(clk), .q(reg_bank_offset_18_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_19_s4_U(.d(bank_offset_19_s4), .clk(clk), .q(reg_bank_offset_19_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_20_s4_U(.d(bank_offset_20_s4), .clk(clk), .q(reg_bank_offset_20_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_21_s4_U(.d(bank_offset_21_s4), .clk(clk), .q(reg_bank_offset_21_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_22_s4_U(.d(bank_offset_22_s4), .clk(clk), .q(reg_bank_offset_22_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_23_s4_U(.d(bank_offset_23_s4), .clk(clk), .q(reg_bank_offset_23_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_24_s4_U(.d(bank_offset_24_s4), .clk(clk), .q(reg_bank_offset_24_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_25_s4_U(.d(bank_offset_25_s4), .clk(clk), .q(reg_bank_offset_25_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_26_s4_U(.d(bank_offset_26_s4), .clk(clk), .q(reg_bank_offset_26_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_27_s4_U(.d(bank_offset_27_s4), .clk(clk), .q(reg_bank_offset_27_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_28_s4_U(.d(bank_offset_28_s4), .clk(clk), .q(reg_bank_offset_28_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_29_s4_U(.d(bank_offset_29_s4), .clk(clk), .q(reg_bank_offset_29_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_30_s4_U(.d(bank_offset_30_s4), .clk(clk), .q(reg_bank_offset_30_s4));
register_compression #(.N(MEM_BANK_DEPTH+1)) 	reg_bank_offset_31_s4_U(.d(bank_offset_31_s4), .clk(clk), .q(reg_bank_offset_31_s4));

//
register_compression #(.N(128)) 		reg_update_0_s4_U(.d(update_0_s4), .clk(clk), .q(reg_update_0_s4));
register_compression #(.N(128)) 		reg_update_1_s4_U(.d(update_1_s4), .clk(clk), .q(reg_update_1_s4));
register_compression #(.N(128)) 		reg_update_2_s4_U(.d(update_2_s4), .clk(clk), .q(reg_update_2_s4));
register_compression #(.N(128)) 		reg_update_3_s4_U(.d(update_3_s4), .clk(clk), .q(reg_update_3_s4));
register_compression #(.N(128)) 		reg_update_4_s4_U(.d(update_4_s4), .clk(clk), .q(reg_update_4_s4));
register_compression #(.N(128)) 		reg_update_5_s4_U(.d(update_5_s4), .clk(clk), .q(reg_update_5_s4));
register_compression #(.N(128)) 		reg_update_6_s4_U(.d(update_6_s4), .clk(clk), .q(reg_update_6_s4));
register_compression #(.N(128)) 		reg_update_7_s4_U(.d(update_7_s4), .clk(clk), .q(reg_update_7_s4));
register_compression #(.N(128)) 		reg_update_8_s4_U(.d(update_8_s4), .clk(clk), .q(reg_update_8_s4));
register_compression #(.N(128)) 		reg_update_9_s4_U(.d(update_9_s4), .clk(clk), .q(reg_update_9_s4));
register_compression #(.N(128)) 		reg_update_10_s4_U(.d(update_10_s4), .clk(clk), .q(reg_update_10_s4));
register_compression #(.N(128)) 		reg_update_11_s4_U(.d(update_11_s4), .clk(clk), .q(reg_update_11_s4));
register_compression #(.N(128)) 		reg_update_12_s4_U(.d(update_12_s4), .clk(clk), .q(reg_update_12_s4));
register_compression #(.N(128)) 		reg_update_13_s4_U(.d(update_13_s4), .clk(clk), .q(reg_update_13_s4));
register_compression #(.N(128)) 		reg_update_14_s4_U(.d(update_14_s4), .clk(clk), .q(reg_update_14_s4));
register_compression #(.N(128)) 		reg_update_15_s4_U(.d(update_15_s4), .clk(clk), .q(reg_update_15_s4));
register_compression #(.N(128)) 		reg_update_16_s4_U(.d(update_16_s4), .clk(clk), .q(reg_update_16_s4));
register_compression #(.N(128)) 		reg_update_17_s4_U(.d(update_17_s4), .clk(clk), .q(reg_update_17_s4));
register_compression #(.N(128)) 		reg_update_18_s4_U(.d(update_18_s4), .clk(clk), .q(reg_update_18_s4));
register_compression #(.N(128)) 		reg_update_19_s4_U(.d(update_19_s4), .clk(clk), .q(reg_update_19_s4));
register_compression #(.N(128)) 		reg_update_20_s4_U(.d(update_20_s4), .clk(clk), .q(reg_update_20_s4));
register_compression #(.N(128)) 		reg_update_21_s4_U(.d(update_21_s4), .clk(clk), .q(reg_update_21_s4));
register_compression #(.N(128)) 		reg_update_22_s4_U(.d(update_22_s4), .clk(clk), .q(reg_update_22_s4));
register_compression #(.N(128)) 		reg_update_23_s4_U(.d(update_23_s4), .clk(clk), .q(reg_update_23_s4));
register_compression #(.N(128)) 		reg_update_24_s4_U(.d(update_24_s4), .clk(clk), .q(reg_update_24_s4));
register_compression #(.N(128)) 		reg_update_25_s4_U(.d(update_25_s4), .clk(clk), .q(reg_update_25_s4));
register_compression #(.N(128)) 		reg_update_26_s4_U(.d(update_26_s4), .clk(clk), .q(reg_update_26_s4));
register_compression #(.N(128)) 		reg_update_27_s4_U(.d(update_27_s4), .clk(clk), .q(reg_update_27_s4));
register_compression #(.N(128)) 		reg_update_28_s4_U(.d(update_28_s4), .clk(clk), .q(reg_update_28_s4));
register_compression #(.N(128)) 		reg_update_29_s4_U(.d(update_29_s4), .clk(clk), .q(reg_update_29_s4));
register_compression #(.N(128)) 		reg_update_30_s4_U(.d(update_30_s4), .clk(clk), .q(reg_update_30_s4));
register_compression #(.N(128)) 		reg_update_31_s4_U(.d(update_31_s4), .clk(clk), .q(reg_update_31_s4));

//
register_compression #(.N(32))		reg_update_position_bank_0_s4_U(.d(update_position_bank_0_s4), .clk(clk), .q(reg_update_position_bank_0_s4));
register_compression #(.N(32))		reg_update_position_bank_1_s4_U(.d(update_position_bank_1_s4), .clk(clk), .q(reg_update_position_bank_1_s4));
register_compression #(.N(32))		reg_update_position_bank_2_s4_U(.d(update_position_bank_2_s4), .clk(clk), .q(reg_update_position_bank_2_s4));
register_compression #(.N(32))		reg_update_position_bank_3_s4_U(.d(update_position_bank_3_s4), .clk(clk), .q(reg_update_position_bank_3_s4));
register_compression #(.N(32))		reg_update_position_bank_4_s4_U(.d(update_position_bank_4_s4), .clk(clk), .q(reg_update_position_bank_4_s4));
register_compression #(.N(32))		reg_update_position_bank_5_s4_U(.d(update_position_bank_5_s4), .clk(clk), .q(reg_update_position_bank_5_s4));
register_compression #(.N(32))		reg_update_position_bank_6_s4_U(.d(update_position_bank_6_s4), .clk(clk), .q(reg_update_position_bank_6_s4));
register_compression #(.N(32))		reg_update_position_bank_7_s4_U(.d(update_position_bank_7_s4), .clk(clk), .q(reg_update_position_bank_7_s4));
register_compression #(.N(32))		reg_update_position_bank_8_s4_U(.d(update_position_bank_8_s4), .clk(clk), .q(reg_update_position_bank_8_s4));
register_compression #(.N(32))		reg_update_position_bank_9_s4_U(.d(update_position_bank_9_s4), .clk(clk), .q(reg_update_position_bank_9_s4));
register_compression #(.N(32))		reg_update_position_bank_10_s4_U(.d(update_position_bank_10_s4), .clk(clk), .q(reg_update_position_bank_10_s4));
register_compression #(.N(32))		reg_update_position_bank_11_s4_U(.d(update_position_bank_11_s4), .clk(clk), .q(reg_update_position_bank_11_s4));
register_compression #(.N(32))		reg_update_position_bank_12_s4_U(.d(update_position_bank_12_s4), .clk(clk), .q(reg_update_position_bank_12_s4));
register_compression #(.N(32))		reg_update_position_bank_13_s4_U(.d(update_position_bank_13_s4), .clk(clk), .q(reg_update_position_bank_13_s4));
register_compression #(.N(32))		reg_update_position_bank_14_s4_U(.d(update_position_bank_14_s4), .clk(clk), .q(reg_update_position_bank_14_s4));
register_compression #(.N(32))		reg_update_position_bank_15_s4_U(.d(update_position_bank_15_s4), .clk(clk), .q(reg_update_position_bank_15_s4));
register_compression #(.N(32))		reg_update_position_bank_16_s4_U(.d(update_position_bank_16_s4), .clk(clk), .q(reg_update_position_bank_16_s4));
register_compression #(.N(32))		reg_update_position_bank_17_s4_U(.d(update_position_bank_17_s4), .clk(clk), .q(reg_update_position_bank_17_s4));
register_compression #(.N(32))		reg_update_position_bank_18_s4_U(.d(update_position_bank_18_s4), .clk(clk), .q(reg_update_position_bank_18_s4));
register_compression #(.N(32))		reg_update_position_bank_19_s4_U(.d(update_position_bank_19_s4), .clk(clk), .q(reg_update_position_bank_19_s4));
register_compression #(.N(32))		reg_update_position_bank_20_s4_U(.d(update_position_bank_20_s4), .clk(clk), .q(reg_update_position_bank_20_s4));
register_compression #(.N(32))		reg_update_position_bank_21_s4_U(.d(update_position_bank_21_s4), .clk(clk), .q(reg_update_position_bank_21_s4));
register_compression #(.N(32))		reg_update_position_bank_22_s4_U(.d(update_position_bank_22_s4), .clk(clk), .q(reg_update_position_bank_22_s4));
register_compression #(.N(32))		reg_update_position_bank_23_s4_U(.d(update_position_bank_23_s4), .clk(clk), .q(reg_update_position_bank_23_s4));
register_compression #(.N(32))		reg_update_position_bank_24_s4_U(.d(update_position_bank_24_s4), .clk(clk), .q(reg_update_position_bank_24_s4));
register_compression #(.N(32))		reg_update_position_bank_25_s4_U(.d(update_position_bank_25_s4), .clk(clk), .q(reg_update_position_bank_25_s4));
register_compression #(.N(32))		reg_update_position_bank_26_s4_U(.d(update_position_bank_26_s4), .clk(clk), .q(reg_update_position_bank_26_s4));
register_compression #(.N(32))		reg_update_position_bank_27_s4_U(.d(update_position_bank_27_s4), .clk(clk), .q(reg_update_position_bank_27_s4));
register_compression #(.N(32))		reg_update_position_bank_28_s4_U(.d(update_position_bank_28_s4), .clk(clk), .q(reg_update_position_bank_28_s4));
register_compression #(.N(32))		reg_update_position_bank_29_s4_U(.d(update_position_bank_29_s4), .clk(clk), .q(reg_update_position_bank_29_s4));
register_compression #(.N(32))		reg_update_position_bank_30_s4_U(.d(update_position_bank_30_s4), .clk(clk), .q(reg_update_position_bank_30_s4));
register_compression #(.N(32))		reg_update_position_bank_31_s4_U(.d(update_position_bank_31_s4), .clk(clk), .q(reg_update_position_bank_31_s4));

// 
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_0_s4_U(.d(reg_raw_bank_num_0_s3), .clk(clk), .q(reg_raw_bank_num_0_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_1_s4_U(.d(reg_raw_bank_num_1_s3), .clk(clk), .q(reg_raw_bank_num_1_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_2_s4_U(.d(reg_raw_bank_num_2_s3), .clk(clk), .q(reg_raw_bank_num_2_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_3_s4_U(.d(reg_raw_bank_num_3_s3), .clk(clk), .q(reg_raw_bank_num_3_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_4_s4_U(.d(reg_raw_bank_num_4_s3), .clk(clk), .q(reg_raw_bank_num_4_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_5_s4_U(.d(reg_raw_bank_num_5_s3), .clk(clk), .q(reg_raw_bank_num_5_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_6_s4_U(.d(reg_raw_bank_num_6_s3), .clk(clk), .q(reg_raw_bank_num_6_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_7_s4_U(.d(reg_raw_bank_num_7_s3), .clk(clk), .q(reg_raw_bank_num_7_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_8_s4_U(.d(reg_raw_bank_num_8_s3), .clk(clk), .q(reg_raw_bank_num_8_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_9_s4_U(.d(reg_raw_bank_num_9_s3), .clk(clk), .q(reg_raw_bank_num_9_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_10_s4_U(.d(reg_raw_bank_num_10_s3), .clk(clk), .q(reg_raw_bank_num_10_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_11_s4_U(.d(reg_raw_bank_num_11_s3), .clk(clk), .q(reg_raw_bank_num_11_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_12_s4_U(.d(reg_raw_bank_num_12_s3), .clk(clk), .q(reg_raw_bank_num_12_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_13_s4_U(.d(reg_raw_bank_num_13_s3), .clk(clk), .q(reg_raw_bank_num_13_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_14_s4_U(.d(reg_raw_bank_num_14_s3), .clk(clk), .q(reg_raw_bank_num_14_s4));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_15_s4_U(.d(reg_raw_bank_num_15_s3), .clk(clk), .q(reg_raw_bank_num_15_s4));

// 
register_compression #(.N(15)) reg_bank_select_s4_U(.d(reg_bank_select_s3), .clk(clk), .q(reg_bank_select_s4));

register_compression #(.N(256)) register_data_window_in_s4_U(.d(data_window_in_s3), .clk(clk), .q(data_window_in_s4));


// ====================================================================
//
//  Stage 5: 
//
// ====================================================================

// stage 5 ports definition

// read & write control signal for bram
wire 				rw_en_0_s5;
wire 				rw_en_1_s5;
wire 				rw_en_2_s5;
wire 				rw_en_3_s5;
wire 				rw_en_4_s5;
wire 				rw_en_5_s5;
wire 				rw_en_6_s5;
wire 				rw_en_7_s5;
wire 				rw_en_8_s5;
wire 				rw_en_9_s5;
wire 				rw_en_10_s5;
wire 				rw_en_11_s5;
wire 				rw_en_12_s5;
wire 				rw_en_13_s5;
wire 				rw_en_14_s5;
wire 				rw_en_15_s5;
wire 				rw_en_16_s5;
wire 				rw_en_17_s5;
wire 				rw_en_18_s5;
wire 				rw_en_19_s5;
wire 				rw_en_20_s5;
wire 				rw_en_21_s5;
wire 				rw_en_22_s5;
wire 				rw_en_23_s5;
wire 				rw_en_24_s5;
wire 				rw_en_25_s5;
wire 				rw_en_26_s5;
wire 				rw_en_27_s5;
wire 				rw_en_28_s5;
wire 				rw_en_29_s5;
wire 				rw_en_30_s5;
wire 				rw_en_31_s5;

// output of level-1 bram
// hash content
wire  [127:0]   hash_content_bank_0_bram_s5;
wire  [127:0]   hash_content_bank_1_bram_s5;
wire  [127:0]   hash_content_bank_2_bram_s5;
wire  [127:0]   hash_content_bank_3_bram_s5;
wire  [127:0]   hash_content_bank_4_bram_s5;
wire  [127:0]   hash_content_bank_5_bram_s5;
wire  [127:0]   hash_content_bank_6_bram_s5;
wire  [127:0]   hash_content_bank_7_bram_s5;
wire  [127:0]   hash_content_bank_8_bram_s5;
wire  [127:0]   hash_content_bank_9_bram_s5;
wire  [127:0]   hash_content_bank_10_bram_s5;
wire  [127:0]   hash_content_bank_11_bram_s5;
wire  [127:0]   hash_content_bank_12_bram_s5;
wire  [127:0]   hash_content_bank_13_bram_s5;
wire  [127:0]   hash_content_bank_14_bram_s5;
wire  [127:0]   hash_content_bank_15_bram_s5;
wire  [127:0]   hash_content_bank_16_bram_s5;
wire  [127:0]   hash_content_bank_17_bram_s5;
wire  [127:0]   hash_content_bank_18_bram_s5;
wire  [127:0]   hash_content_bank_19_bram_s5;
wire  [127:0]   hash_content_bank_20_bram_s5;
wire  [127:0]   hash_content_bank_21_bram_s5;
wire  [127:0]   hash_content_bank_22_bram_s5;
wire  [127:0]   hash_content_bank_23_bram_s5;
wire  [127:0]   hash_content_bank_24_bram_s5;
wire  [127:0]   hash_content_bank_25_bram_s5;
wire  [127:0]   hash_content_bank_26_bram_s5;
wire  [127:0]   hash_content_bank_27_bram_s5;
wire  [127:0]   hash_content_bank_28_bram_s5;
wire  [127:0]   hash_content_bank_29_bram_s5;
wire  [127:0]   hash_content_bank_30_bram_s5;
wire  [127:0]   hash_content_bank_31_bram_s5;

// hash position 
wire  [30:0]    hash_position_bank_0_bram_s5;
wire  [30:0]    hash_position_bank_1_bram_s5;
wire  [30:0]    hash_position_bank_2_bram_s5;
wire  [30:0]    hash_position_bank_3_bram_s5;
wire  [30:0]    hash_position_bank_4_bram_s5;
wire  [30:0]    hash_position_bank_5_bram_s5;
wire  [30:0]    hash_position_bank_6_bram_s5;
wire  [30:0]    hash_position_bank_7_bram_s5;
wire  [30:0]    hash_position_bank_8_bram_s5;
wire  [30:0]    hash_position_bank_9_bram_s5;
wire  [30:0]    hash_position_bank_10_bram_s5;
wire  [30:0]    hash_position_bank_11_bram_s5;
wire  [30:0]    hash_position_bank_12_bram_s5;
wire  [30:0]    hash_position_bank_13_bram_s5;
wire  [30:0]    hash_position_bank_14_bram_s5;
wire  [30:0]    hash_position_bank_15_bram_s5;
wire  [30:0]    hash_position_bank_16_bram_s5;
wire  [30:0]    hash_position_bank_17_bram_s5;
wire  [30:0]    hash_position_bank_18_bram_s5;
wire  [30:0]    hash_position_bank_19_bram_s5;
wire  [30:0]    hash_position_bank_20_bram_s5;
wire  [30:0]    hash_position_bank_21_bram_s5;
wire  [30:0]    hash_position_bank_22_bram_s5;
wire  [30:0]    hash_position_bank_23_bram_s5;
wire  [30:0]    hash_position_bank_24_bram_s5;
wire  [30:0]    hash_position_bank_25_bram_s5;
wire  [30:0]    hash_position_bank_26_bram_s5;
wire  [30:0]    hash_position_bank_27_bram_s5;
wire  [30:0]    hash_position_bank_28_bram_s5;
wire  [30:0]    hash_position_bank_29_bram_s5;
wire  [30:0]    hash_position_bank_30_bram_s5;
wire  [30:0]    hash_position_bank_31_bram_s5;

// hash valid
wire        	hash_valid_bank_0_bram_s5;
wire        	hash_valid_bank_1_bram_s5;
wire        	hash_valid_bank_2_bram_s5;
wire        	hash_valid_bank_3_bram_s5;
wire        	hash_valid_bank_4_bram_s5;
wire        	hash_valid_bank_5_bram_s5;
wire        	hash_valid_bank_6_bram_s5;
wire        	hash_valid_bank_7_bram_s5;
wire        	hash_valid_bank_8_bram_s5;
wire        	hash_valid_bank_9_bram_s5;
wire        	hash_valid_bank_10_bram_s5;
wire        	hash_valid_bank_11_bram_s5;
wire        	hash_valid_bank_12_bram_s5;
wire        	hash_valid_bank_13_bram_s5;
wire        	hash_valid_bank_14_bram_s5;
wire        	hash_valid_bank_15_bram_s5;
wire        	hash_valid_bank_16_bram_s5;
wire        	hash_valid_bank_17_bram_s5;
wire        	hash_valid_bank_18_bram_s5;
wire        	hash_valid_bank_19_bram_s5;
wire        	hash_valid_bank_20_bram_s5;
wire        	hash_valid_bank_21_bram_s5;
wire        	hash_valid_bank_22_bram_s5;
wire        	hash_valid_bank_23_bram_s5;
wire        	hash_valid_bank_24_bram_s5;
wire        	hash_valid_bank_25_bram_s5;
wire        	hash_valid_bank_26_bram_s5;
wire        	hash_valid_bank_27_bram_s5;
wire        	hash_valid_bank_28_bram_s5;
wire        	hash_valid_bank_29_bram_s5;
wire        	hash_valid_bank_30_bram_s5;
wire        	hash_valid_bank_31_bram_s5;

// current window information
wire 	[127:0] 	reg_update_0_s5;
wire 	[127:0] 	reg_update_1_s5;
wire 	[127:0] 	reg_update_2_s5;
wire 	[127:0] 	reg_update_3_s5;
wire 	[127:0] 	reg_update_4_s5;
wire 	[127:0] 	reg_update_5_s5;
wire 	[127:0] 	reg_update_6_s5;
wire 	[127:0] 	reg_update_7_s5;
wire 	[127:0] 	reg_update_8_s5;
wire 	[127:0] 	reg_update_9_s5;
wire 	[127:0] 	reg_update_10_s5;
wire 	[127:0] 	reg_update_11_s5;
wire 	[127:0] 	reg_update_12_s5;
wire 	[127:0] 	reg_update_13_s5;
wire 	[127:0] 	reg_update_14_s5;
wire 	[127:0] 	reg_update_15_s5;
wire 	[127:0] 	reg_update_16_s5;
wire 	[127:0] 	reg_update_17_s5;
wire 	[127:0] 	reg_update_18_s5;
wire 	[127:0] 	reg_update_19_s5;
wire 	[127:0] 	reg_update_20_s5;
wire 	[127:0] 	reg_update_21_s5;
wire 	[127:0] 	reg_update_22_s5;
wire 	[127:0] 	reg_update_23_s5;
wire 	[127:0] 	reg_update_24_s5;
wire 	[127:0] 	reg_update_25_s5;
wire 	[127:0] 	reg_update_26_s5;
wire 	[127:0] 	reg_update_27_s5;
wire 	[127:0] 	reg_update_28_s5;
wire 	[127:0] 	reg_update_29_s5;
wire 	[127:0] 	reg_update_30_s5;
wire 	[127:0] 	reg_update_31_s5;

wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_0_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_1_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_2_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_3_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_4_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_5_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_6_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_7_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_8_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_9_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_10_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_11_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_12_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_13_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_14_s5;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_15_s5;

// general information for stage 5
wire 	[14:0]		reg_bank_select_s5;

wire	[31:0]      input_position_s5;

wire 	[255:0]		data_window_in_s5;

wire 				start_s5;

//
assign rw_en_0_s5 = start_s4 & (~reg_bank_offset_0_s4[8]);
assign rw_en_1_s5 = start_s4 & (~reg_bank_offset_1_s4[8]);
assign rw_en_2_s5 = start_s4 & (~reg_bank_offset_2_s4[8]);
assign rw_en_3_s5 = start_s4 & (~reg_bank_offset_3_s4[8]);
assign rw_en_4_s5 = start_s4 & (~reg_bank_offset_4_s4[8]);
assign rw_en_5_s5 = start_s4 & (~reg_bank_offset_5_s4[8]);
assign rw_en_6_s5 = start_s4 & (~reg_bank_offset_6_s4[8]);
assign rw_en_7_s5 = start_s4 & (~reg_bank_offset_7_s4[8]);
assign rw_en_8_s5 = start_s4 & (~reg_bank_offset_8_s4[8]);
assign rw_en_9_s5 = start_s4 & (~reg_bank_offset_9_s4[8]);
assign rw_en_10_s5 = start_s4 & (~reg_bank_offset_10_s4[8]);
assign rw_en_11_s5 = start_s4 & (~reg_bank_offset_11_s4[8]);
assign rw_en_12_s5 = start_s4 & (~reg_bank_offset_12_s4[8]);
assign rw_en_13_s5 = start_s4 & (~reg_bank_offset_13_s4[8]);
assign rw_en_14_s5 = start_s4 & (~reg_bank_offset_14_s4[8]);
assign rw_en_15_s5 = start_s4 & (~reg_bank_offset_15_s4[8]);
assign rw_en_16_s5 = start_s4 & (~reg_bank_offset_16_s4[8]);
assign rw_en_17_s5 = start_s4 & (~reg_bank_offset_17_s4[8]);
assign rw_en_18_s5 = start_s4 & (~reg_bank_offset_18_s4[8]);
assign rw_en_19_s5 = start_s4 & (~reg_bank_offset_19_s4[8]);
assign rw_en_20_s5 = start_s4 & (~reg_bank_offset_20_s4[8]);
assign rw_en_21_s5 = start_s4 & (~reg_bank_offset_21_s4[8]);
assign rw_en_22_s5 = start_s4 & (~reg_bank_offset_22_s4[8]);
assign rw_en_23_s5 = start_s4 & (~reg_bank_offset_23_s4[8]);
assign rw_en_24_s5 = start_s4 & (~reg_bank_offset_24_s4[8]);
assign rw_en_25_s5 = start_s4 & (~reg_bank_offset_25_s4[8]);
assign rw_en_26_s5 = start_s4 & (~reg_bank_offset_26_s4[8]);
assign rw_en_27_s5 = start_s4 & (~reg_bank_offset_27_s4[8]);
assign rw_en_28_s5 = start_s4 & (~reg_bank_offset_28_s4[8]);
assign rw_en_29_s5 = start_s4 & (~reg_bank_offset_29_s4[8]);
assign rw_en_30_s5 = start_s4 & (~reg_bank_offset_30_s4[8]);
assign rw_en_31_s5 = start_s4 & (~reg_bank_offset_31_s4[8]);

// read & write to block memory: SDP mode
// port A is for write, port B is for read
// read first
// read output doesn't have one clock delay (no output register)
// 1st level depth
// memory banks to store hash_content
hash_match_hash_content 	hash_content_bank_0_U(
  .clka(clk),
  .ena(rw_en_0_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_0_s4[7:0]),
  .dina(reg_update_0_s4),
  .clkb(clk),
  .enb(rw_en_0_s5),
  .addrb(reg_bank_offset_0_s4[7:0]),
  .doutb(hash_content_bank_0_bram_s5)
);

hash_match_hash_content 	hash_content_bank_1_U(
  .clka(clk),
  .ena(rw_en_1_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_1_s4[7:0]),
  .dina(reg_update_1_s4),
  .clkb(clk),
  .enb(rw_en_1_s5),
  .addrb(reg_bank_offset_1_s4[7:0]),
  .doutb(hash_content_bank_1_bram_s5)
);

hash_match_hash_content 	hash_content_bank_2_U(
  .clka(clk),
  .ena(rw_en_2_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_2_s4[7:0]),
  .dina(reg_update_2_s4),
  .clkb(clk),
  .enb(rw_en_2_s5),
  .addrb(reg_bank_offset_2_s4[7:0]),
  .doutb(hash_content_bank_2_bram_s5)
);

hash_match_hash_content 	hash_content_bank_3_U(
  .clka(clk),
  .ena(rw_en_3_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_3_s4[7:0]),
  .dina(reg_update_3_s4),
  .clkb(clk),
  .enb(rw_en_3_s5),
  .addrb(reg_bank_offset_3_s4[7:0]),
  .doutb(hash_content_bank_3_bram_s5)
);

hash_match_hash_content 	hash_content_bank_4_U(
  .clka(clk),
  .ena(rw_en_4_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_4_s4[7:0]),
  .dina(reg_update_4_s4),
  .clkb(clk),
  .enb(rw_en_4_s5),
  .addrb(reg_bank_offset_4_s4[7:0]),
  .doutb(hash_content_bank_4_bram_s5)
);

hash_match_hash_content 	hash_content_bank_5_U(
  .clka(clk),
  .ena(rw_en_5_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_5_s4[7:0]),
  .dina(reg_update_5_s4),
  .clkb(clk),
  .enb(rw_en_5_s5),
  .addrb(reg_bank_offset_5_s4[7:0]),
  .doutb(hash_content_bank_5_bram_s5)
);

hash_match_hash_content 	hash_content_bank_6_U(
  .clka(clk),
  .ena(rw_en_6_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_6_s4[7:0]),
  .dina(reg_update_6_s4),
  .clkb(clk),
  .enb(rw_en_6_s5),
  .addrb(reg_bank_offset_6_s4[7:0]),
  .doutb(hash_content_bank_6_bram_s5)
);

hash_match_hash_content 	hash_content_bank_7_U(
  .clka(clk),
  .ena(rw_en_7_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_7_s4[7:0]),
  .dina(reg_update_7_s4),
  .clkb(clk),
  .enb(rw_en_7_s5),
  .addrb(reg_bank_offset_7_s4[7:0]),
  .doutb(hash_content_bank_7_bram_s5)
);

hash_match_hash_content 	hash_content_bank_8_U(
  .clka(clk),
  .ena(rw_en_8_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_8_s4[7:0]),
  .dina(reg_update_8_s4),
  .clkb(clk),
  .enb(rw_en_8_s5),
  .addrb(reg_bank_offset_8_s4[7:0]),
  .doutb(hash_content_bank_8_bram_s5)
);

hash_match_hash_content 	hash_content_bank_9_U(
  .clka(clk),
  .ena(rw_en_9_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_9_s4[7:0]),
  .dina(reg_update_9_s4),
  .clkb(clk),
  .enb(rw_en_9_s5),
  .addrb(reg_bank_offset_9_s4[7:0]),
  .doutb(hash_content_bank_9_bram_s5)
);

hash_match_hash_content 	hash_content_bank_10_U(
  .clka(clk),
  .ena(rw_en_10_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_10_s4[7:0]),
  .dina(reg_update_10_s4),
  .clkb(clk),
  .enb(rw_en_10_s5),
  .addrb(reg_bank_offset_10_s4[7:0]),
  .doutb(hash_content_bank_10_bram_s5)
);

hash_match_hash_content 	hash_content_bank_11_U(
  .clka(clk),
  .ena(rw_en_11_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_11_s4[7:0]),
  .dina(reg_update_11_s4),
  .clkb(clk),
  .enb(rw_en_11_s5),
  .addrb(reg_bank_offset_11_s4[7:0]),
  .doutb(hash_content_bank_11_bram_s5)
);

hash_match_hash_content 	hash_content_bank_12_U(
  .clka(clk),
  .ena(rw_en_12_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_12_s4[7:0]),
  .dina(reg_update_12_s4),
  .clkb(clk),
  .enb(rw_en_12_s5),
  .addrb(reg_bank_offset_12_s4[7:0]),
  .doutb(hash_content_bank_12_bram_s5)
);

hash_match_hash_content 	hash_content_bank_13_U(
  .clka(clk),
  .ena(rw_en_13_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_13_s4[7:0]),
  .dina(reg_update_13_s4),
  .clkb(clk),
  .enb(rw_en_13_s5),
  .addrb(reg_bank_offset_13_s4[7:0]),
  .doutb(hash_content_bank_13_bram_s5)
);

hash_match_hash_content 	hash_content_bank_14_U(
  .clka(clk),
  .ena(rw_en_14_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_14_s4[7:0]),
  .dina(reg_update_14_s4),
  .clkb(clk),
  .enb(rw_en_14_s5),
  .addrb(reg_bank_offset_14_s4[7:0]),
  .doutb(hash_content_bank_14_bram_s5)
);

hash_match_hash_content 	hash_content_bank_15_U(
  .clka(clk),
  .ena(rw_en_15_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_15_s4[7:0]),
  .dina(reg_update_15_s4),
  .clkb(clk),
  .enb(rw_en_15_s5),
  .addrb(reg_bank_offset_15_s4[7:0]),
  .doutb(hash_content_bank_15_bram_s5)
);

hash_match_hash_content 	hash_content_bank_16_U(
  .clka(clk),
  .ena(rw_en_16_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_16_s4[7:0]),
  .dina(reg_update_16_s4),
  .clkb(clk),
  .enb(rw_en_16_s5),
  .addrb(reg_bank_offset_16_s4[7:0]),
  .doutb(hash_content_bank_16_bram_s5)
);

hash_match_hash_content 	hash_content_bank_17_U(
  .clka(clk),
  .ena(rw_en_17_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_17_s4[7:0]),
  .dina(reg_update_17_s4),
  .clkb(clk),
  .enb(rw_en_17_s5),
  .addrb(reg_bank_offset_17_s4[7:0]),
  .doutb(hash_content_bank_17_bram_s5)
);

hash_match_hash_content 	hash_content_bank_18_U(
  .clka(clk),
  .ena(rw_en_18_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_18_s4[7:0]),
  .dina(reg_update_18_s4),
  .clkb(clk),
  .enb(rw_en_18_s5),
  .addrb(reg_bank_offset_18_s4[7:0]),
  .doutb(hash_content_bank_18_bram_s5)
);

hash_match_hash_content 	hash_content_bank_19_U(
  .clka(clk),
  .ena(rw_en_19_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_19_s4[7:0]),
  .dina(reg_update_19_s4),
  .clkb(clk),
  .enb(rw_en_19_s5),
  .addrb(reg_bank_offset_19_s4[7:0]),
  .doutb(hash_content_bank_19_bram_s5)
);

hash_match_hash_content 	hash_content_bank_20_U(
  .clka(clk),
  .ena(rw_en_20_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_20_s4[7:0]),
  .dina(reg_update_20_s4),
  .clkb(clk),
  .enb(rw_en_20_s5),
  .addrb(reg_bank_offset_20_s4[7:0]),
  .doutb(hash_content_bank_20_bram_s5)
);

hash_match_hash_content 	hash_content_bank_21_U(
  .clka(clk),
  .ena(rw_en_21_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_21_s4[7:0]),
  .dina(reg_update_21_s4),
  .clkb(clk),
  .enb(rw_en_21_s5),
  .addrb(reg_bank_offset_21_s4[7:0]),
  .doutb(hash_content_bank_21_bram_s5)
);

hash_match_hash_content 	hash_content_bank_22_U(
  .clka(clk),
  .ena(rw_en_22_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_22_s4[7:0]),
  .dina(reg_update_22_s4),
  .clkb(clk),
  .enb(rw_en_22_s5),
  .addrb(reg_bank_offset_22_s4[7:0]),
  .doutb(hash_content_bank_22_bram_s5)
);

hash_match_hash_content 	hash_content_bank_23_U(
  .clka(clk),
  .ena(rw_en_23_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_23_s4[7:0]),
  .dina(reg_update_23_s4),
  .clkb(clk),
  .enb(rw_en_23_s5),
  .addrb(reg_bank_offset_23_s4[7:0]),
  .doutb(hash_content_bank_23_bram_s5)
);

hash_match_hash_content 	hash_content_bank_24_U(
  .clka(clk),
  .ena(rw_en_24_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_24_s4[7:0]),
  .dina(reg_update_24_s4),
  .clkb(clk),
  .enb(rw_en_24_s5),
  .addrb(reg_bank_offset_24_s4[7:0]),
  .doutb(hash_content_bank_24_bram_s5)
);

hash_match_hash_content 	hash_content_bank_25_U(
  .clka(clk),
  .ena(rw_en_25_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_25_s4[7:0]),
  .dina(reg_update_25_s4),
  .clkb(clk),
  .enb(rw_en_25_s5),
  .addrb(reg_bank_offset_25_s4[7:0]),
  .doutb(hash_content_bank_25_bram_s5)
);

hash_match_hash_content 	hash_content_bank_26_U(
  .clka(clk),
  .ena(rw_en_26_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_26_s4[7:0]),
  .dina(reg_update_26_s4),
  .clkb(clk),
  .enb(rw_en_26_s5),
  .addrb(reg_bank_offset_26_s4[7:0]),
  .doutb(hash_content_bank_26_bram_s5)
);

hash_match_hash_content 	hash_content_bank_27_U(
  .clka(clk),
  .ena(rw_en_27_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_27_s4[7:0]),
  .dina(reg_update_27_s4),
  .clkb(clk),
  .enb(rw_en_27_s5),
  .addrb(reg_bank_offset_27_s4[7:0]),
  .doutb(hash_content_bank_27_bram_s5)
);

hash_match_hash_content 	hash_content_bank_28_U(
  .clka(clk),
  .ena(rw_en_28_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_28_s4[7:0]),
  .dina(reg_update_28_s4),
  .clkb(clk),
  .enb(rw_en_28_s5),
  .addrb(reg_bank_offset_28_s4[7:0]),
  .doutb(hash_content_bank_28_bram_s5)
);

hash_match_hash_content 	hash_content_bank_29_U(
  .clka(clk),
  .ena(rw_en_29_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_29_s4[7:0]),
  .dina(reg_update_29_s4),
  .clkb(clk),
  .enb(rw_en_29_s5),
  .addrb(reg_bank_offset_29_s4[7:0]),
  .doutb(hash_content_bank_29_bram_s5)
);

hash_match_hash_content 	hash_content_bank_30_U(
  .clka(clk),
  .ena(rw_en_30_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_30_s4[7:0]),
  .dina(reg_update_30_s4),
  .clkb(clk),
  .enb(rw_en_30_s5),
  .addrb(reg_bank_offset_30_s4[7:0]),
  .doutb(hash_content_bank_30_bram_s5)
);

hash_match_hash_content 	hash_content_bank_31_U(
  .clka(clk),
  .ena(rw_en_31_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_31_s4[7:0]),
  .dina(reg_update_31_s4),
  .clkb(clk),
  .enb(rw_en_31_s5),
  .addrb(reg_bank_offset_31_s4[7:0]),
  .doutb(hash_content_bank_31_bram_s5)
);


// memory banks to store hash_position & hash_valid
hash_match_hash_position_valid 	hash_position_valid_bank_0_U(
  .clka(clk),
  .ena(rw_en_0_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_0_s4[7:0]),
  .dina({reg_update_position_bank_0_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_0_s5),
  .addrb(reg_bank_offset_0_s4[7:0]),
  .doutb({hash_position_bank_0_bram_s5, hash_valid_bank_0_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_1_U(
  .clka(clk),
  .ena(rw_en_1_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_1_s4[7:0]),
  .dina({reg_update_position_bank_1_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_1_s5),
  .addrb(reg_bank_offset_1_s4[7:0]),
  .doutb({hash_position_bank_1_bram_s5, hash_valid_bank_1_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_2_U(
  .clka(clk),
  .ena(rw_en_2_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_2_s4[7:0]),
  .dina({reg_update_position_bank_2_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_2_s5),
  .addrb(reg_bank_offset_2_s4[7:0]),
  .doutb({hash_position_bank_2_bram_s5, hash_valid_bank_2_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_3_U(
  .clka(clk),
  .ena(rw_en_3_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_3_s4[7:0]),
  .dina({reg_update_position_bank_3_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_3_s5),
  .addrb(reg_bank_offset_3_s4[7:0]),
  .doutb({hash_position_bank_3_bram_s5, hash_valid_bank_3_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_4_U(
  .clka(clk),
  .ena(rw_en_4_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_4_s4[7:0]),
  .dina({reg_update_position_bank_4_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_4_s5),
  .addrb(reg_bank_offset_4_s4[7:0]),
  .doutb({hash_position_bank_4_bram_s5, hash_valid_bank_4_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_5_U(
  .clka(clk),
  .ena(rw_en_5_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_5_s4[7:0]),
  .dina({reg_update_position_bank_5_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_5_s5),
  .addrb(reg_bank_offset_5_s4[7:0]),
  .doutb({hash_position_bank_5_bram_s5, hash_valid_bank_5_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_6_U(
  .clka(clk),
  .ena(rw_en_6_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_6_s4[7:0]),
  .dina({reg_update_position_bank_6_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_6_s5),
  .addrb(reg_bank_offset_6_s4[7:0]),
  .doutb({hash_position_bank_6_bram_s5, hash_valid_bank_6_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_7_U(
  .clka(clk),
  .ena(rw_en_7_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_7_s4[7:0]),
  .dina({reg_update_position_bank_7_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_7_s5),
  .addrb(reg_bank_offset_7_s4[7:0]),
  .doutb({hash_position_bank_7_bram_s5, hash_valid_bank_7_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_8_U(
  .clka(clk),
  .ena(rw_en_8_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_8_s4[7:0]),
  .dina({reg_update_position_bank_8_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_8_s5),
  .addrb(reg_bank_offset_8_s4[7:0]),
  .doutb({hash_position_bank_8_bram_s5, hash_valid_bank_8_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_9_U(
  .clka(clk),
  .ena(rw_en_9_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_9_s4[7:0]),
  .dina({reg_update_position_bank_9_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_9_s5),
  .addrb(reg_bank_offset_9_s4[7:0]),
  .doutb({hash_position_bank_9_bram_s5, hash_valid_bank_9_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_10_U(
  .clka(clk),
  .ena(rw_en_10_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_10_s4[7:0]),
  .dina({reg_update_position_bank_10_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_10_s5),
  .addrb(reg_bank_offset_10_s4[7:0]),
  .doutb({hash_position_bank_10_bram_s5, hash_valid_bank_10_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_11_U(
  .clka(clk),
  .ena(rw_en_11_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_11_s4[7:0]),
  .dina({reg_update_position_bank_11_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_11_s5),
  .addrb(reg_bank_offset_11_s4[7:0]),
  .doutb({hash_position_bank_11_bram_s5, hash_valid_bank_11_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_12_U(
  .clka(clk),
  .ena(rw_en_12_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_12_s4[7:0]),
  .dina({reg_update_position_bank_12_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_12_s5),
  .addrb(reg_bank_offset_12_s4[7:0]),
  .doutb({hash_position_bank_12_bram_s5, hash_valid_bank_12_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_13_U(
  .clka(clk),
  .ena(rw_en_13_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_13_s4[7:0]),
  .dina({reg_update_position_bank_13_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_13_s5),
  .addrb(reg_bank_offset_13_s4[7:0]),
  .doutb({hash_position_bank_13_bram_s5, hash_valid_bank_13_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_14_U(
  .clka(clk),
  .ena(rw_en_14_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_14_s4[7:0]),
  .dina({reg_update_position_bank_14_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_14_s5),
  .addrb(reg_bank_offset_14_s4[7:0]),
  .doutb({hash_position_bank_14_bram_s5, hash_valid_bank_14_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_15_U(
  .clka(clk),
  .ena(rw_en_15_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_15_s4[7:0]),
  .dina({reg_update_position_bank_15_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_15_s5),
  .addrb(reg_bank_offset_15_s4[7:0]),
  .doutb({hash_position_bank_15_bram_s5, hash_valid_bank_15_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_16_U(
  .clka(clk),
  .ena(rw_en_16_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_16_s4[7:0]),
  .dina({reg_update_position_bank_16_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_16_s5),
  .addrb(reg_bank_offset_16_s4[7:0]),
  .doutb({hash_position_bank_16_bram_s5, hash_valid_bank_16_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_17_U(
  .clka(clk),
  .ena(rw_en_17_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_17_s4[7:0]),
  .dina({reg_update_position_bank_17_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_17_s5),
  .addrb(reg_bank_offset_17_s4[7:0]),
  .doutb({hash_position_bank_17_bram_s5, hash_valid_bank_17_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_18_U(
  .clka(clk),
  .ena(rw_en_18_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_18_s4[7:0]),
  .dina({reg_update_position_bank_18_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_18_s5),
  .addrb(reg_bank_offset_18_s4[7:0]),
  .doutb({hash_position_bank_18_bram_s5, hash_valid_bank_18_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_19_U(
  .clka(clk),
  .ena(rw_en_19_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_19_s4[7:0]),
  .dina({reg_update_position_bank_19_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_19_s5),
  .addrb(reg_bank_offset_19_s4[7:0]),
  .doutb({hash_position_bank_19_bram_s5, hash_valid_bank_19_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_20_U(
  .clka(clk),
  .ena(rw_en_20_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_20_s4[7:0]),
  .dina({reg_update_position_bank_20_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_20_s5),
  .addrb(reg_bank_offset_20_s4[7:0]),
  .doutb({hash_position_bank_20_bram_s5, hash_valid_bank_20_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_21_U(
  .clka(clk),
  .ena(rw_en_21_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_21_s4[7:0]),
  .dina({reg_update_position_bank_21_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_21_s5),
  .addrb(reg_bank_offset_21_s4[7:0]),
  .doutb({hash_position_bank_21_bram_s5, hash_valid_bank_21_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_22_U(
  .clka(clk),
  .ena(rw_en_22_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_22_s4[7:0]),
  .dina({reg_update_position_bank_22_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_22_s5),
  .addrb(reg_bank_offset_22_s4[7:0]),
  .doutb({hash_position_bank_22_bram_s5, hash_valid_bank_22_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_23_U(
  .clka(clk),
  .ena(rw_en_23_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_23_s4[7:0]),
  .dina({reg_update_position_bank_23_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_23_s5),
  .addrb(reg_bank_offset_23_s4[7:0]),
  .doutb({hash_position_bank_23_bram_s5, hash_valid_bank_23_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_24_U(
  .clka(clk),
  .ena(rw_en_24_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_24_s4[7:0]),
  .dina({reg_update_position_bank_24_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_24_s5),
  .addrb(reg_bank_offset_24_s4[7:0]),
  .doutb({hash_position_bank_24_bram_s5, hash_valid_bank_24_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_25_U(
  .clka(clk),
  .ena(rw_en_25_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_25_s4[7:0]),
  .dina({reg_update_position_bank_25_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_25_s5),
  .addrb(reg_bank_offset_25_s4[7:0]),
  .doutb({hash_position_bank_25_bram_s5, hash_valid_bank_25_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_26_U(
  .clka(clk),
  .ena(rw_en_26_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_26_s4[7:0]),
  .dina({reg_update_position_bank_26_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_26_s5),
  .addrb(reg_bank_offset_26_s4[7:0]),
  .doutb({hash_position_bank_26_bram_s5, hash_valid_bank_26_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_27_U(
  .clka(clk),
  .ena(rw_en_27_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_27_s4[7:0]),
  .dina({reg_update_position_bank_27_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_27_s5),
  .addrb(reg_bank_offset_27_s4[7:0]),
  .doutb({hash_position_bank_27_bram_s5, hash_valid_bank_27_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_28_U(
  .clka(clk),
  .ena(rw_en_28_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_28_s4[7:0]),
  .dina({reg_update_position_bank_28_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_28_s5),
  .addrb(reg_bank_offset_28_s4[7:0]),
  .doutb({hash_position_bank_28_bram_s5, hash_valid_bank_28_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_29_U(
  .clka(clk),
  .ena(rw_en_29_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_29_s4[7:0]),
  .dina({reg_update_position_bank_29_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_29_s5),
  .addrb(reg_bank_offset_29_s4[7:0]),
  .doutb({hash_position_bank_29_bram_s5, hash_valid_bank_29_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_30_U(
  .clka(clk),
  .ena(rw_en_30_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_30_s4[7:0]),
  .dina({reg_update_position_bank_30_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_30_s5),
  .addrb(reg_bank_offset_30_s4[7:0]),
  .doutb({hash_position_bank_30_bram_s5, hash_valid_bank_30_bram_s5})
);

hash_match_hash_position_valid 	hash_position_valid_bank_31_U(
  .clka(clk),
  .ena(rw_en_31_s5),
  .wea(1'b1),
  .addra(reg_bank_offset_31_s4[7:0]),
  .dina({reg_update_position_bank_31_s4[30:0], 1'b1}),
  .clkb(clk),
  .enb(rw_en_31_s5),
  .addrb(reg_bank_offset_31_s4[7:0]),
  .doutb({hash_position_bank_31_bram_s5, hash_valid_bank_31_bram_s5})
);

//
register_compression_reset #(.N(32)) register_input_position_s5_U(.d(input_position_s4), .clk(clk), .reset(rst), .q(input_position_s5));

register_compression_reset #(.N(1)) register_start_s5_U(.d(start_s4), .clk(clk), .reset(rst), .q(start_s5));

// 
register_compression #(.N(128)) 		reg_update_0_s5_U(.d(reg_update_0_s4), .clk(clk), .q(reg_update_0_s5));
register_compression #(.N(128)) 		reg_update_1_s5_U(.d(reg_update_1_s4), .clk(clk), .q(reg_update_1_s5));
register_compression #(.N(128)) 		reg_update_2_s5_U(.d(reg_update_2_s4), .clk(clk), .q(reg_update_2_s5));
register_compression #(.N(128)) 		reg_update_3_s5_U(.d(reg_update_3_s4), .clk(clk), .q(reg_update_3_s5));
register_compression #(.N(128)) 		reg_update_4_s5_U(.d(reg_update_4_s4), .clk(clk), .q(reg_update_4_s5));
register_compression #(.N(128)) 		reg_update_5_s5_U(.d(reg_update_5_s4), .clk(clk), .q(reg_update_5_s5));
register_compression #(.N(128)) 		reg_update_6_s5_U(.d(reg_update_6_s4), .clk(clk), .q(reg_update_6_s5));
register_compression #(.N(128)) 		reg_update_7_s5_U(.d(reg_update_7_s4), .clk(clk), .q(reg_update_7_s5));
register_compression #(.N(128)) 		reg_update_8_s5_U(.d(reg_update_8_s4), .clk(clk), .q(reg_update_8_s5));
register_compression #(.N(128)) 		reg_update_9_s5_U(.d(reg_update_9_s4), .clk(clk), .q(reg_update_9_s5));
register_compression #(.N(128)) 		reg_update_10_s5_U(.d(reg_update_10_s4), .clk(clk), .q(reg_update_10_s5));
register_compression #(.N(128)) 		reg_update_11_s5_U(.d(reg_update_11_s4), .clk(clk), .q(reg_update_11_s5));
register_compression #(.N(128)) 		reg_update_12_s5_U(.d(reg_update_12_s4), .clk(clk), .q(reg_update_12_s5));
register_compression #(.N(128)) 		reg_update_13_s5_U(.d(reg_update_13_s4), .clk(clk), .q(reg_update_13_s5));
register_compression #(.N(128)) 		reg_update_14_s5_U(.d(reg_update_14_s4), .clk(clk), .q(reg_update_14_s5));
register_compression #(.N(128)) 		reg_update_15_s5_U(.d(reg_update_15_s4), .clk(clk), .q(reg_update_15_s5));
register_compression #(.N(128)) 		reg_update_16_s5_U(.d(reg_update_16_s4), .clk(clk), .q(reg_update_16_s5));
register_compression #(.N(128)) 		reg_update_17_s5_U(.d(reg_update_17_s4), .clk(clk), .q(reg_update_17_s5));
register_compression #(.N(128)) 		reg_update_18_s5_U(.d(reg_update_18_s4), .clk(clk), .q(reg_update_18_s5));
register_compression #(.N(128)) 		reg_update_19_s5_U(.d(reg_update_19_s4), .clk(clk), .q(reg_update_19_s5));
register_compression #(.N(128)) 		reg_update_20_s5_U(.d(reg_update_20_s4), .clk(clk), .q(reg_update_20_s5));
register_compression #(.N(128)) 		reg_update_21_s5_U(.d(reg_update_21_s4), .clk(clk), .q(reg_update_21_s5));
register_compression #(.N(128)) 		reg_update_22_s5_U(.d(reg_update_22_s4), .clk(clk), .q(reg_update_22_s5));
register_compression #(.N(128)) 		reg_update_23_s5_U(.d(reg_update_23_s4), .clk(clk), .q(reg_update_23_s5));
register_compression #(.N(128)) 		reg_update_24_s5_U(.d(reg_update_24_s4), .clk(clk), .q(reg_update_24_s5));
register_compression #(.N(128)) 		reg_update_25_s5_U(.d(reg_update_25_s4), .clk(clk), .q(reg_update_25_s5));
register_compression #(.N(128)) 		reg_update_26_s5_U(.d(reg_update_26_s4), .clk(clk), .q(reg_update_26_s5));
register_compression #(.N(128)) 		reg_update_27_s5_U(.d(reg_update_27_s4), .clk(clk), .q(reg_update_27_s5));
register_compression #(.N(128)) 		reg_update_28_s5_U(.d(reg_update_28_s4), .clk(clk), .q(reg_update_28_s5));
register_compression #(.N(128)) 		reg_update_29_s5_U(.d(reg_update_29_s4), .clk(clk), .q(reg_update_29_s5));
register_compression #(.N(128)) 		reg_update_30_s5_U(.d(reg_update_30_s4), .clk(clk), .q(reg_update_30_s5));
register_compression #(.N(128)) 		reg_update_31_s5_U(.d(reg_update_31_s4), .clk(clk), .q(reg_update_31_s5));

register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_0_s5_U(.d(reg_raw_bank_num_0_s4), .clk(clk), .q(reg_raw_bank_num_0_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_1_s5_U(.d(reg_raw_bank_num_1_s4), .clk(clk), .q(reg_raw_bank_num_1_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_2_s5_U(.d(reg_raw_bank_num_2_s4), .clk(clk), .q(reg_raw_bank_num_2_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_3_s5_U(.d(reg_raw_bank_num_3_s4), .clk(clk), .q(reg_raw_bank_num_3_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_4_s5_U(.d(reg_raw_bank_num_4_s4), .clk(clk), .q(reg_raw_bank_num_4_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_5_s5_U(.d(reg_raw_bank_num_5_s4), .clk(clk), .q(reg_raw_bank_num_5_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_6_s5_U(.d(reg_raw_bank_num_6_s4), .clk(clk), .q(reg_raw_bank_num_6_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_7_s5_U(.d(reg_raw_bank_num_7_s4), .clk(clk), .q(reg_raw_bank_num_7_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_8_s5_U(.d(reg_raw_bank_num_8_s4), .clk(clk), .q(reg_raw_bank_num_8_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_9_s5_U(.d(reg_raw_bank_num_9_s4), .clk(clk), .q(reg_raw_bank_num_9_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_10_s5_U(.d(reg_raw_bank_num_10_s4), .clk(clk), .q(reg_raw_bank_num_10_s5));
register_compression #(.N(MEM_BANK_NUM))	register_raw_bank_num_11_s5_U(.d(reg_raw_bank_num_11_s4), .clk(clk), .q(reg_raw_bank_num_11_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_12_s5_U(.d(reg_raw_bank_num_12_s4), .clk(clk), .q(reg_raw_bank_num_12_s5));
register_compression #(.N(MEM_BANK_NUM))	register_raw_bank_num_13_s5_U(.d(reg_raw_bank_num_13_s4), .clk(clk), .q(reg_raw_bank_num_13_s5));
register_compression #(.N(MEM_BANK_NUM))	register_raw_bank_num_14_s5_U(.d(reg_raw_bank_num_14_s4), .clk(clk), .q(reg_raw_bank_num_14_s5));
register_compression #(.N(MEM_BANK_NUM)) 	register_raw_bank_num_15_s5_U(.d(reg_raw_bank_num_15_s4), .clk(clk), .q(reg_raw_bank_num_15_s5));

//
register_compression_reset #(.N(15)) reg_bank_select_s5_U(.d(reg_bank_select_s4), .clk(clk), .reset(rst), .q(reg_bank_select_s5));

register_compression_reset #(.N(256)) register_data_window_in_s5_U(.d(data_window_in_s4), .clk(clk), .reset(rst), .q(data_window_in_s5));


// ====================================================================
//
//  Stage 6: 
//
// ====================================================================

// stage 6 ports definition

//
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_0;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_1;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_2;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_3;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_4;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_5;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_6;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_7;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_8;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_9;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_10;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_11;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_12;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_13;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_14;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_15;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_16;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_17;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_18;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_19;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_20;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_21;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_22;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_23;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_24;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_25;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_26;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_27;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_28;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_29;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_30;
wire 	[MEM_BANK_NUM-1:0] 	match_length_bank_31;

wire  	[30:0]    hash_position_bank_0_bram_s6;
wire  	[30:0]    hash_position_bank_1_bram_s6;
wire  	[30:0]    hash_position_bank_2_bram_s6;
wire  	[30:0]    hash_position_bank_3_bram_s6;
wire  	[30:0]    hash_position_bank_4_bram_s6;
wire  	[30:0]    hash_position_bank_5_bram_s6;
wire  	[30:0]    hash_position_bank_6_bram_s6;
wire  	[30:0]    hash_position_bank_7_bram_s6;
wire  	[30:0]    hash_position_bank_8_bram_s6;
wire  	[30:0]    hash_position_bank_9_bram_s6;
wire  	[30:0]    hash_position_bank_10_bram_s6;
wire  	[30:0]    hash_position_bank_11_bram_s6;
wire  	[30:0]    hash_position_bank_12_bram_s6;
wire  	[30:0]    hash_position_bank_13_bram_s6;
wire  	[30:0]    hash_position_bank_14_bram_s6;
wire  	[30:0]    hash_position_bank_15_bram_s6;
wire  	[30:0]    hash_position_bank_16_bram_s6;
wire  	[30:0]    hash_position_bank_17_bram_s6;
wire  	[30:0]    hash_position_bank_18_bram_s6;
wire  	[30:0]    hash_position_bank_19_bram_s6;
wire  	[30:0]    hash_position_bank_20_bram_s6;
wire  	[30:0]    hash_position_bank_21_bram_s6;
wire  	[30:0]    hash_position_bank_22_bram_s6;
wire  	[30:0]    hash_position_bank_23_bram_s6;
wire  	[30:0]    hash_position_bank_24_bram_s6;
wire  	[30:0]    hash_position_bank_25_bram_s6;
wire  	[30:0]    hash_position_bank_26_bram_s6;
wire  	[30:0]    hash_position_bank_27_bram_s6;
wire  	[30:0]    hash_position_bank_28_bram_s6;
wire  	[30:0]    hash_position_bank_29_bram_s6;
wire  	[30:0]    hash_position_bank_30_bram_s6;
wire  	[30:0]    hash_position_bank_31_bram_s6;

wire				hash_valid_bank_0_bram_s6;
wire				hash_valid_bank_1_bram_s6;
wire				hash_valid_bank_2_bram_s6;
wire				hash_valid_bank_3_bram_s6;
wire				hash_valid_bank_4_bram_s6;
wire				hash_valid_bank_5_bram_s6;
wire				hash_valid_bank_6_bram_s6;
wire				hash_valid_bank_7_bram_s6;
wire				hash_valid_bank_8_bram_s6;
wire				hash_valid_bank_9_bram_s6;
wire				hash_valid_bank_10_bram_s6;
wire				hash_valid_bank_11_bram_s6;
wire				hash_valid_bank_12_bram_s6;
wire				hash_valid_bank_13_bram_s6;
wire				hash_valid_bank_14_bram_s6;
wire				hash_valid_bank_15_bram_s6;
wire				hash_valid_bank_16_bram_s6;
wire				hash_valid_bank_17_bram_s6;
wire				hash_valid_bank_18_bram_s6;
wire				hash_valid_bank_19_bram_s6;
wire				hash_valid_bank_20_bram_s6;
wire				hash_valid_bank_21_bram_s6;
wire				hash_valid_bank_22_bram_s6;
wire				hash_valid_bank_23_bram_s6;
wire				hash_valid_bank_24_bram_s6;
wire				hash_valid_bank_25_bram_s6;
wire				hash_valid_bank_26_bram_s6;
wire				hash_valid_bank_27_bram_s6;
wire				hash_valid_bank_28_bram_s6;
wire				hash_valid_bank_29_bram_s6;
wire				hash_valid_bank_30_bram_s6;
wire				hash_valid_bank_31_bram_s6;

// current window for stage 6
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_0_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_1_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_2_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_3_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_4_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_5_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_6_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_7_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_8_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_9_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_10_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_11_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_12_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_13_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_14_s6;
wire	[MEM_BANK_NUM-1:0]		reg_raw_bank_num_15_s6;

//
wire 	[14:0]		reg_bank_select_s6;

wire	[31:0]      input_position_s6;

wire 	[255:0]		data_window_in_s6;

wire 				start_s6;

// calculate the matched length
calc_match_len  calc_match_length_0_U(
  .clk(clk), 
  .current_vec(reg_update_0_s5), 
  .match_result(hash_content_bank_0_bram_s5), 
  .match_length(match_length_bank_0)
);

calc_match_len  calc_match_length_1_U(
  .clk(clk), 
  .current_vec(reg_update_1_s5), 
  .match_result(hash_content_bank_1_bram_s5), 
  .match_length(match_length_bank_1)
);

calc_match_len  calc_match_length_2_U(
  .clk(clk), 
  .current_vec(reg_update_2_s5), 
  .match_result(hash_content_bank_2_bram_s5), 
  .match_length(match_length_bank_2)
);

calc_match_len  calc_match_length_3_U(
  .clk(clk), 
  .current_vec(reg_update_3_s5), 
  .match_result(hash_content_bank_3_bram_s5), 
  .match_length(match_length_bank_3)
);

calc_match_len  calc_match_length_4_U(
  .clk(clk), 
  .current_vec(reg_update_4_s5), 
  .match_result(hash_content_bank_4_bram_s5), 
  .match_length(match_length_bank_4)
);

calc_match_len  calc_match_length_5_U(
  .clk(clk), 
  .current_vec(reg_update_5_s5), 
  .match_result(hash_content_bank_5_bram_s5), 
  .match_length(match_length_bank_5)
);

calc_match_len  calc_match_length_6_U(
  .clk(clk), 
  .current_vec(reg_update_6_s5), 
  .match_result(hash_content_bank_6_bram_s5), 
  .match_length(match_length_bank_6)
);

calc_match_len  calc_match_length_7_U(
  .clk(clk), 
  .current_vec(reg_update_7_s5), 
  .match_result(hash_content_bank_7_bram_s5), 
  .match_length(match_length_bank_7)
);

calc_match_len  calc_match_length_8_U(
  .clk(clk), 
  .current_vec(reg_update_8_s5), 
  .match_result(hash_content_bank_8_bram_s5), 
  .match_length(match_length_bank_8)
);

calc_match_len  calc_match_length_9_U(
  .clk(clk), 
  .current_vec(reg_update_9_s5), 
  .match_result(hash_content_bank_9_bram_s5), 
  .match_length(match_length_bank_9)
);

calc_match_len  calc_match_length_10_U(
  .clk(clk), 
  .current_vec(reg_update_10_s5), 
  .match_result(hash_content_bank_10_bram_s5), 
  .match_length(match_length_bank_10)
);

calc_match_len  calc_match_length_11_U(
  .clk(clk), 
  .current_vec(reg_update_11_s5), 
  .match_result(hash_content_bank_11_bram_s5), 
  .match_length(match_length_bank_11)
);

calc_match_len  calc_match_length_12_U(
  .clk(clk), 
  .current_vec(reg_update_12_s5), 
  .match_result(hash_content_bank_12_bram_s5), 
  .match_length(match_length_bank_12)
);

calc_match_len  calc_match_length_13_U(
  .clk(clk), 
  .current_vec(reg_update_13_s5), 
  .match_result(hash_content_bank_13_bram_s5), 
  .match_length(match_length_bank_13)
);

calc_match_len  calc_match_length_14_U(
  .clk(clk), 
  .current_vec(reg_update_14_s5), 
  .match_result(hash_content_bank_14_bram_s5), 
  .match_length(match_length_bank_14)
);

calc_match_len  calc_match_length_15_U(
  .clk(clk), 
  .current_vec(reg_update_15_s5), 
  .match_result(hash_content_bank_15_bram_s5), 
  .match_length(match_length_bank_15)
);

calc_match_len  calc_match_length_16_U(
  .clk(clk), 
  .current_vec(reg_update_16_s5), 
  .match_result(hash_content_bank_16_bram_s5), 
  .match_length(match_length_bank_16)
);

calc_match_len  calc_match_length_17_U(
  .clk(clk), 
  .current_vec(reg_update_17_s5), 
  .match_result(hash_content_bank_17_bram_s5), 
  .match_length(match_length_bank_17)
);

calc_match_len  calc_match_length_18_U(
  .clk(clk), 
  .current_vec(reg_update_18_s5), 
  .match_result(hash_content_bank_18_bram_s5), 
  .match_length(match_length_bank_18)
);

calc_match_len  calc_match_length_19_U(
  .clk(clk), 
  .current_vec(reg_update_19_s5), 
  .match_result(hash_content_bank_19_bram_s5), 
  .match_length(match_length_bank_19)
);

calc_match_len  calc_match_length_20_U(
  .clk(clk), 
  .current_vec(reg_update_20_s5), 
  .match_result(hash_content_bank_20_bram_s5), 
  .match_length(match_length_bank_20)
);

calc_match_len  calc_match_length_21_U(
  .clk(clk), 
  .current_vec(reg_update_21_s5), 
  .match_result(hash_content_bank_21_bram_s5), 
  .match_length(match_length_bank_21)
);

calc_match_len  calc_match_length_22_U(
  .clk(clk), 
  .current_vec(reg_update_22_s5), 
  .match_result(hash_content_bank_22_bram_s5), 
  .match_length(match_length_bank_22)
);

calc_match_len  calc_match_length_23_U(
  .clk(clk), 
  .current_vec(reg_update_23_s5), 
  .match_result(hash_content_bank_23_bram_s5), 
  .match_length(match_length_bank_23)
);

calc_match_len  calc_match_length_24_U(
  .clk(clk), 
  .current_vec(reg_update_24_s5), 
  .match_result(hash_content_bank_24_bram_s5), 
  .match_length(match_length_bank_24)
);

calc_match_len  calc_match_length_25_U(
  .clk(clk), 
  .current_vec(reg_update_25_s5), 
  .match_result(hash_content_bank_25_bram_s5), 
  .match_length(match_length_bank_25)
);

calc_match_len  calc_match_length_26_U(
  .clk(clk), 
  .current_vec(reg_update_26_s5), 
  .match_result(hash_content_bank_26_bram_s5), 
  .match_length(match_length_bank_26)
);

calc_match_len  calc_match_length_27_U(
  .clk(clk), 
  .current_vec(reg_update_27_s5), 
  .match_result(hash_content_bank_27_bram_s5), 
  .match_length(match_length_bank_27)
);

calc_match_len  calc_match_length_28_U(
  .clk(clk), 
  .current_vec(reg_update_28_s5), 
  .match_result(hash_content_bank_28_bram_s5), 
  .match_length(match_length_bank_28)
);

calc_match_len  calc_match_length_29_U(
  .clk(clk), 
  .current_vec(reg_update_0_s5), 
  .match_result(hash_content_bank_29_bram_s5), 
  .match_length(match_length_bank_29)
);

calc_match_len  calc_match_length_30_U(
  .clk(clk), 
  .current_vec(reg_update_30_s5), 
  .match_result(hash_content_bank_30_bram_s5), 
  .match_length(match_length_bank_30)
);

calc_match_len  calc_match_length_31_U(
  .clk(clk), 
  .current_vec(reg_update_31_s5), 
  .match_result(hash_content_bank_31_bram_s5), 
  .match_length(match_length_bank_31)
);

// 
register_compression_reset #(.N(32)) register_input_position_s6_U(.d(input_position_s5), .clk(clk), .reset(rst), .q(input_position_s6));

register_compression_reset #(.N(1)) register_start_s6_U(.d(start_s5), .clk(clk), .reset(rst), .q(start_s6));

//
register_compression #(.N(31)) register_hash_position_bank_0_bram_s6_U(.d(hash_position_bank_0_bram_s5), .clk(clk), .q(hash_position_bank_0_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_1_bram_s6_U(.d(hash_position_bank_1_bram_s5), .clk(clk), .q(hash_position_bank_1_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_2_bram_s6_U(.d(hash_position_bank_2_bram_s5), .clk(clk), .q(hash_position_bank_2_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_3_bram_s6_U(.d(hash_position_bank_3_bram_s5), .clk(clk), .q(hash_position_bank_3_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_4_bram_s6_U(.d(hash_position_bank_4_bram_s5), .clk(clk), .q(hash_position_bank_4_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_5_bram_s6_U(.d(hash_position_bank_5_bram_s5), .clk(clk), .q(hash_position_bank_5_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_6_bram_s6_U(.d(hash_position_bank_6_bram_s5), .clk(clk), .q(hash_position_bank_6_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_7_bram_s6_U(.d(hash_position_bank_7_bram_s5), .clk(clk), .q(hash_position_bank_7_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_8_bram_s6_U(.d(hash_position_bank_8_bram_s5), .clk(clk), .q(hash_position_bank_8_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_9_bram_s6_U(.d(hash_position_bank_9_bram_s5), .clk(clk), .q(hash_position_bank_9_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_10_bram_s6_U(.d(hash_position_bank_10_bram_s5), .clk(clk), .q(hash_position_bank_10_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_11_bram_s6_U(.d(hash_position_bank_11_bram_s5), .clk(clk), .q(hash_position_bank_11_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_12_bram_s6_U(.d(hash_position_bank_12_bram_s5), .clk(clk), .q(hash_position_bank_12_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_13_bram_s6_U(.d(hash_position_bank_13_bram_s5), .clk(clk), .q(hash_position_bank_13_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_14_bram_s6_U(.d(hash_position_bank_14_bram_s5), .clk(clk), .q(hash_position_bank_14_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_15_bram_s6_U(.d(hash_position_bank_15_bram_s5), .clk(clk), .q(hash_position_bank_15_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_16_bram_s6_U(.d(hash_position_bank_16_bram_s5), .clk(clk), .q(hash_position_bank_16_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_17_bram_s6_U(.d(hash_position_bank_17_bram_s5), .clk(clk), .q(hash_position_bank_17_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_18_bram_s6_U(.d(hash_position_bank_18_bram_s5), .clk(clk), .q(hash_position_bank_18_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_19_bram_s6_U(.d(hash_position_bank_19_bram_s5), .clk(clk), .q(hash_position_bank_19_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_20_bram_s6_U(.d(hash_position_bank_20_bram_s5), .clk(clk), .q(hash_position_bank_20_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_21_bram_s6_U(.d(hash_position_bank_21_bram_s5), .clk(clk), .q(hash_position_bank_21_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_22_bram_s6_U(.d(hash_position_bank_22_bram_s5), .clk(clk), .q(hash_position_bank_22_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_23_bram_s6_U(.d(hash_position_bank_23_bram_s5), .clk(clk), .q(hash_position_bank_23_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_24_bram_s6_U(.d(hash_position_bank_24_bram_s5), .clk(clk), .q(hash_position_bank_24_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_25_bram_s6_U(.d(hash_position_bank_25_bram_s5), .clk(clk), .q(hash_position_bank_25_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_26_bram_s6_U(.d(hash_position_bank_26_bram_s5), .clk(clk), .q(hash_position_bank_26_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_27_bram_s6_U(.d(hash_position_bank_27_bram_s5), .clk(clk), .q(hash_position_bank_27_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_28_bram_s6_U(.d(hash_position_bank_28_bram_s5), .clk(clk), .q(hash_position_bank_28_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_29_bram_s6_U(.d(hash_position_bank_29_bram_s5), .clk(clk), .q(hash_position_bank_29_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_30_bram_s6_U(.d(hash_position_bank_30_bram_s5), .clk(clk), .q(hash_position_bank_30_bram_s6));
register_compression #(.N(31)) register_hash_position_bank_31_bram_s6_U(.d(hash_position_bank_31_bram_s5), .clk(clk), .q(hash_position_bank_31_bram_s6));

register_compression #(.N(1)) register_hash_valid_bank_0_bram_s6_U(.d(hash_valid_bank_0_bram_s5), .clk(clk), .q(hash_valid_bank_0_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_1_bram_s6_U(.d(hash_valid_bank_1_bram_s5), .clk(clk), .q(hash_valid_bank_1_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_2_bram_s6_U(.d(hash_valid_bank_2_bram_s5), .clk(clk), .q(hash_valid_bank_2_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_3_bram_s6_U(.d(hash_valid_bank_3_bram_s5), .clk(clk), .q(hash_valid_bank_3_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_4_bram_s6_U(.d(hash_valid_bank_4_bram_s5), .clk(clk), .q(hash_valid_bank_4_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_5_bram_s6_U(.d(hash_valid_bank_5_bram_s5), .clk(clk), .q(hash_valid_bank_5_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_6_bram_s6_U(.d(hash_valid_bank_6_bram_s5), .clk(clk), .q(hash_valid_bank_6_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_7_bram_s6_U(.d(hash_valid_bank_7_bram_s5), .clk(clk), .q(hash_valid_bank_7_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_8_bram_s6_U(.d(hash_valid_bank_8_bram_s5), .clk(clk), .q(hash_valid_bank_8_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_9_bram_s6_U(.d(hash_valid_bank_9_bram_s5), .clk(clk), .q(hash_valid_bank_9_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_10_bram_s6_U(.d(hash_valid_bank_10_bram_s5), .clk(clk), .q(hash_valid_bank_10_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_11_bram_s6_U(.d(hash_valid_bank_11_bram_s5), .clk(clk), .q(hash_valid_bank_11_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_12_bram_s6_U(.d(hash_valid_bank_12_bram_s5), .clk(clk), .q(hash_valid_bank_12_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_13_bram_s6_U(.d(hash_valid_bank_13_bram_s5), .clk(clk), .q(hash_valid_bank_13_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_14_bram_s6_U(.d(hash_valid_bank_14_bram_s5), .clk(clk), .q(hash_valid_bank_14_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_15_bram_s6_U(.d(hash_valid_bank_15_bram_s5), .clk(clk), .q(hash_valid_bank_15_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_16_bram_s6_U(.d(hash_valid_bank_16_bram_s5), .clk(clk), .q(hash_valid_bank_16_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_17_bram_s6_U(.d(hash_valid_bank_17_bram_s5), .clk(clk), .q(hash_valid_bank_17_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_18_bram_s6_U(.d(hash_valid_bank_18_bram_s5), .clk(clk), .q(hash_valid_bank_18_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_19_bram_s6_U(.d(hash_valid_bank_19_bram_s5), .clk(clk), .q(hash_valid_bank_19_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_20_bram_s6_U(.d(hash_valid_bank_20_bram_s5), .clk(clk), .q(hash_valid_bank_20_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_21_bram_s6_U(.d(hash_valid_bank_21_bram_s5), .clk(clk), .q(hash_valid_bank_21_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_22_bram_s6_U(.d(hash_valid_bank_22_bram_s5), .clk(clk), .q(hash_valid_bank_22_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_23_bram_s6_U(.d(hash_valid_bank_23_bram_s5), .clk(clk), .q(hash_valid_bank_23_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_24_bram_s6_U(.d(hash_valid_bank_24_bram_s5), .clk(clk), .q(hash_valid_bank_24_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_25_bram_s6_U(.d(hash_valid_bank_25_bram_s5), .clk(clk), .q(hash_valid_bank_25_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_26_bram_s6_U(.d(hash_valid_bank_26_bram_s5), .clk(clk), .q(hash_valid_bank_26_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_27_bram_s6_U(.d(hash_valid_bank_27_bram_s5), .clk(clk), .q(hash_valid_bank_27_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_28_bram_s6_U(.d(hash_valid_bank_28_bram_s5), .clk(clk), .q(hash_valid_bank_28_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_29_bram_s6_U(.d(hash_valid_bank_29_bram_s5), .clk(clk), .q(hash_valid_bank_29_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_30_bram_s6_U(.d(hash_valid_bank_30_bram_s5), .clk(clk), .q(hash_valid_bank_30_bram_s6));
register_compression #(.N(1)) register_hash_valid_bank_31_bram_s6_U(.d(hash_valid_bank_31_bram_s5), .clk(clk), .q(hash_valid_bank_31_bram_s6));

register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_0_s6_U(.d(reg_raw_bank_num_0_s5), .clk(clk), .q(reg_raw_bank_num_0_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_1_s6_U(.d(reg_raw_bank_num_1_s5), .clk(clk), .q(reg_raw_bank_num_1_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_2_s6_U(.d(reg_raw_bank_num_2_s5), .clk(clk), .q(reg_raw_bank_num_2_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_3_s6_U(.d(reg_raw_bank_num_3_s5), .clk(clk), .q(reg_raw_bank_num_3_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_4_s6_U(.d(reg_raw_bank_num_4_s5), .clk(clk), .q(reg_raw_bank_num_4_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_5_s6_U(.d(reg_raw_bank_num_5_s5), .clk(clk), .q(reg_raw_bank_num_5_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_6_s6_U(.d(reg_raw_bank_num_6_s5), .clk(clk), .q(reg_raw_bank_num_6_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_7_s6_U(.d(reg_raw_bank_num_7_s5), .clk(clk), .q(reg_raw_bank_num_7_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_8_s6_U(.d(reg_raw_bank_num_8_s5), .clk(clk), .q(reg_raw_bank_num_8_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_9_s6_U(.d(reg_raw_bank_num_9_s5), .clk(clk), .q(reg_raw_bank_num_9_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_10_s6_U(.d(reg_raw_bank_num_10_s5), .clk(clk), .q(reg_raw_bank_num_10_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_11_s6_U(.d(reg_raw_bank_num_11_s5), .clk(clk), .q(reg_raw_bank_num_11_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_12_s6_U(.d(reg_raw_bank_num_12_s5), .clk(clk), .q(reg_raw_bank_num_12_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_13_s6_U(.d(reg_raw_bank_num_13_s5), .clk(clk), .q(reg_raw_bank_num_13_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_14_s6_U(.d(reg_raw_bank_num_14_s5), .clk(clk), .q(reg_raw_bank_num_14_s6));
register_compression #(.N(MEM_BANK_NUM)) register_raw_bank_num_15_s6_U(.d(reg_raw_bank_num_15_s5), .clk(clk), .q(reg_raw_bank_num_15_s6));

register_compression #(.N(15)) reg_bank_select_s6_U(.d(reg_bank_select_s5), .clk(clk), .q(reg_bank_select_s6));

register_compression #(.N(256)) register_data_window_in_s6_U(.d(data_window_in_s5), .clk(clk), .q(data_window_in_s6));


// ====================================================================
//
//  Stage 7: 
//
// ====================================================================

// stage 7 ports definition
//
wire  [4:0]   match_length_0;
wire  [4:0]   match_length_1;
wire  [4:0]   match_length_2;
wire  [4:0]   match_length_3;
wire  [4:0]   match_length_4;
wire  [4:0]   match_length_5;
wire  [4:0]   match_length_6;
wire  [4:0]   match_length_7;
wire  [4:0]   match_length_8;
wire  [4:0]   match_length_9;
wire  [4:0]   match_length_10;
wire  [4:0]   match_length_11;
wire  [4:0]   match_length_12;
wire  [4:0]   match_length_13;
wire  [4:0]   match_length_14;
wire  [4:0]   match_length_15;

wire  [30:0]  match_position_0;
wire  [30:0]  match_position_1;
wire  [30:0]  match_position_2;
wire  [30:0]  match_position_3;
wire  [30:0]  match_position_4;
wire  [30:0]  match_position_5;
wire  [30:0]  match_position_6;
wire  [30:0]  match_position_7;
wire  [30:0]  match_position_8;
wire  [30:0]  match_position_9;
wire  [30:0]  match_position_10;
wire  [30:0]  match_position_11;
wire  [30:0]  match_position_12;
wire  [30:0]  match_position_13;
wire  [30:0]  match_position_14;
wire  [30:0]  match_position_15;

wire     	  match_valid_0;
wire   	  	  match_valid_1;
wire    	  match_valid_2;
wire      	  match_valid_3;
wire      	  match_valid_4;
wire      	  match_valid_5;
wire      	  match_valid_6;
wire      	  match_valid_7;
wire      	  match_valid_8;
wire      	  match_valid_9;
wire      	  match_valid_10;
wire      	  match_valid_11;
wire      	  match_valid_12;
wire      	  match_valid_13;
wire      	  match_valid_14;
wire      	  match_valid_15;

wire 	[4:0]	reg_match_length_0_s7;
wire 	[4:0]	reg_match_length_1_s7;
wire 	[4:0]	reg_match_length_2_s7;
wire 	[4:0]	reg_match_length_3_s7;
wire 	[4:0]	reg_match_length_4_s7;
wire 	[4:0]	reg_match_length_5_s7;
wire 	[4:0]	reg_match_length_6_s7;
wire 	[4:0]	reg_match_length_7_s7;
wire 	[4:0]	reg_match_length_8_s7;
wire 	[4:0]	reg_match_length_9_s7;
wire 	[4:0]	reg_match_length_10_s7;
wire 	[4:0]	reg_match_length_11_s7;
wire 	[4:0]	reg_match_length_12_s7;
wire 	[4:0]	reg_match_length_13_s7;
wire 	[4:0]	reg_match_length_14_s7;
wire 	[4:0]	reg_match_length_15_s7;

wire	[30:0]	reg_match_position_0_s7;
wire	[30:0]	reg_match_position_1_s7;
wire	[30:0]	reg_match_position_2_s7;
wire	[30:0]	reg_match_position_3_s7;
wire	[30:0]	reg_match_position_4_s7;
wire	[30:0]	reg_match_position_5_s7;
wire	[30:0]	reg_match_position_6_s7;
wire	[30:0]	reg_match_position_7_s7;
wire	[30:0]	reg_match_position_8_s7;
wire	[30:0]	reg_match_position_9_s7;
wire	[30:0]	reg_match_position_10_s7;
wire	[30:0]	reg_match_position_11_s7;
wire	[30:0]	reg_match_position_12_s7;
wire	[30:0]	reg_match_position_13_s7;
wire	[30:0]	reg_match_position_14_s7;
wire	[30:0]	reg_match_position_15_s7;

wire			reg_match_valid_0_s7;
wire			reg_match_valid_1_s7;
wire			reg_match_valid_2_s7;
wire			reg_match_valid_3_s7;
wire			reg_match_valid_4_s7;
wire			reg_match_valid_5_s7;
wire			reg_match_valid_6_s7;
wire			reg_match_valid_7_s7;
wire			reg_match_valid_8_s7;
wire			reg_match_valid_9_s7;
wire			reg_match_valid_10_s7;
wire			reg_match_valid_11_s7;
wire			reg_match_valid_12_s7;
wire			reg_match_valid_13_s7;
wire			reg_match_valid_14_s7;
wire			reg_match_valid_15_s7;

// current window information for stage 7
wire 	[14:0]		reg_bank_select_s7;

wire 	[255:0]		data_window_in_s7;

wire	[31:0]      input_position_s7;

wire 				start_s7;

// select the right matched length
mux_32to1 #(.N(5))	match_length_0_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_0_s6),
	.dout(match_length_0)
);

mux_32to1 #(.N(5))	match_length_1_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_1_s6),
	.dout(match_length_1)
);

mux_32to1 #(.N(5))	match_length_2_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_2_s6),
	.dout(match_length_2)
);

mux_32to1 #(.N(5))	match_length_3_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_3_s6),
	.dout(match_length_3)
);

mux_32to1 #(.N(5))	match_length_4_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_4_s6),
	.dout(match_length_4)
);

mux_32to1 #(.N(5))	match_length_5_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_5_s6),
	.dout(match_length_5)
);

mux_32to1 #(.N(5))	match_length_6_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_6_s6),
	.dout(match_length_6)
);

mux_32to1 #(.N(5))	match_length_7_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_7_s6),
	.dout(match_length_7)
);

mux_32to1 #(.N(5))	match_length_8_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_8_s6),
	.dout(match_length_8)
);

mux_32to1 #(.N(5))	match_length_9_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_9_s6),
	.dout(match_length_9)
);

mux_32to1 #(.N(5))	match_length_10_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_10_s6),
	.dout(match_length_10)
);

mux_32to1 #(.N(5))	match_length_11_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_11_s6),
	.dout(match_length_11)
);

mux_32to1 #(.N(5))	match_length_12_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_12_s6),
	.dout(match_length_12)
);

mux_32to1 #(.N(5))	match_length_13_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_13_s6),
	.dout(match_length_13)
);

mux_32to1 #(.N(5))	match_length_14_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_14_s6),
	.dout(match_length_14)
);

mux_32to1 #(.N(5))	match_length_15_U(
	.din0(match_length_bank_0),
	.din1(match_length_bank_1),
	.din2(match_length_bank_2),
	.din3(match_length_bank_3),
	.din4(match_length_bank_4),
	.din5(match_length_bank_5),
	.din6(match_length_bank_6),
	.din7(match_length_bank_7),
	.din8(match_length_bank_8),
	.din9(match_length_bank_9),
	.din10(match_length_bank_10),
	.din11(match_length_bank_11),
	.din12(match_length_bank_12),
	.din13(match_length_bank_13),
	.din14(match_length_bank_14),
	.din15(match_length_bank_15),
	.din16(match_length_bank_16),
	.din17(match_length_bank_17),
	.din18(match_length_bank_18),
	.din19(match_length_bank_19),
	.din20(match_length_bank_20),
	.din21(match_length_bank_21),
	.din22(match_length_bank_22),
	.din23(match_length_bank_23),
	.din24(match_length_bank_24),
	.din25(match_length_bank_25),
	.din26(match_length_bank_26),
	.din27(match_length_bank_27),
	.din28(match_length_bank_28),
	.din29(match_length_bank_29),
	.din30(match_length_bank_30),
	.din31(match_length_bank_31),
	.sel(reg_raw_bank_num_15_s6),
	.dout(match_length_15)
);

// select the right matched position 
mux_32to1 #(.N(31))	match_position_0_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_0_s6),
	.dout(match_position_0)
);

mux_32to1 #(.N(31))	match_position_1_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_1_s6),
	.dout(match_position_1)
);

mux_32to1 #(.N(31))	match_position_2_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_2_s6),
	.dout(match_position_2)
);

mux_32to1 #(.N(31))	match_position_3_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_3_s6),
	.dout(match_position_3)
);

mux_32to1 #(.N(31))	match_position_4_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_4_s6),
	.dout(match_position_4)
);

mux_32to1 #(.N(31))	match_position_5_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_5_s6),
	.dout(match_position_5)
);

mux_32to1 #(.N(31))	match_position_6_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_6_s6),
	.dout(match_position_6)
);

mux_32to1 #(.N(31))	match_position_7_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_7_s6),
	.dout(match_position_7)
);

mux_32to1 #(.N(31))	match_position_8_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_8_s6),
	.dout(match_position_8)
);

mux_32to1 #(.N(31))	match_position_9_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_9_s6),
	.dout(match_position_9)
);

mux_32to1 #(.N(31))	match_position_10_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_10_s6),
	.dout(match_position_10)
);

mux_32to1 #(.N(31))	match_position_11_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_11_s6),
	.dout(match_position_11)
);

mux_32to1 #(.N(31))	match_position_12_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_12_s6),
	.dout(match_position_12)
);

mux_32to1 #(.N(31))	match_position_13_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_13_s6),
	.dout(match_position_13)
);

mux_32to1 #(.N(31))	match_position_14_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_14_s6),
	.dout(match_position_14)
);

mux_32to1 #(.N(31))	match_position_15_U(
	.din0(hash_position_bank_0_bram_s6),
	.din1(hash_position_bank_1_bram_s6),
	.din2(hash_position_bank_2_bram_s6),
	.din3(hash_position_bank_3_bram_s6),
	.din4(hash_position_bank_4_bram_s6),
	.din5(hash_position_bank_5_bram_s6), 
	.din6(hash_position_bank_6_bram_s6),
	.din7(hash_position_bank_7_bram_s6),
	.din8(hash_position_bank_8_bram_s6),
	.din9(hash_position_bank_9_bram_s6),
	.din10(hash_position_bank_10_bram_s6),
	.din11(hash_position_bank_11_bram_s6),
	.din12(hash_position_bank_12_bram_s6),
	.din13(hash_position_bank_13_bram_s6),
	.din14(hash_position_bank_14_bram_s6),
	.din15(hash_position_bank_15_bram_s6),
	.din16(hash_position_bank_16_bram_s6),
	.din17(hash_position_bank_17_bram_s6),
	.din18(hash_position_bank_18_bram_s6),
	.din19(hash_position_bank_19_bram_s6),
	.din20(hash_position_bank_20_bram_s6),
	.din21(hash_position_bank_21_bram_s6), 
	.din22(hash_position_bank_22_bram_s6),
	.din23(hash_position_bank_23_bram_s6),
	.din24(hash_position_bank_24_bram_s6),
	.din25(hash_position_bank_25_bram_s6),
	.din26(hash_position_bank_26_bram_s6),
	.din27(hash_position_bank_27_bram_s6),
	.din28(hash_position_bank_28_bram_s6),
	.din29(hash_position_bank_29_bram_s6),
	.din30(hash_position_bank_30_bram_s6),
	.din31(hash_position_bank_31_bram_s6),
	.sel(reg_raw_bank_num_15_s6),
	.dout(match_position_15)
);

// select the right 
mux_32to1 #(.N(1))	match_valid_bank_0_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_0_s6),
	.dout(match_valid_0)
);

mux_32to1 #(.N(1))	match_valid_bank_1_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_1_s6),
	.dout(match_valid_1)
);

mux_32to1 #(.N(1))	match_valid_bank_2_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_2_s6),
	.dout(match_valid_2)
);

mux_32to1 #(.N(1))	match_valid_bank_3_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_3_s6),
	.dout(match_valid_3)
);

mux_32to1 #(.N(1))	match_valid_bank_4_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_4_s6),
	.dout(match_valid_4)
);

mux_32to1 #(.N(1))	match_valid_bank_5_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_5_s6),
	.dout(match_valid_5)
);

mux_32to1 #(.N(1))	match_valid_bank_6_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_6_s6),
	.dout(match_valid_6)
);

mux_32to1 #(.N(1))	match_valid_bank_7_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_7_s6),
	.dout(match_valid_7)
);

mux_32to1 #(.N(1))	match_valid_bank_8_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_8_s6),
	.dout(match_valid_8)
);

mux_32to1 #(.N(1))	match_valid_bank_9_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_9_s6),
	.dout(match_valid_9)
);

mux_32to1 #(.N(1))	match_valid_bank_10_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_10_s6),
	.dout(match_valid_10)
);

mux_32to1 #(.N(1))	match_valid_bank_11_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_11_s6),
	.dout(match_valid_11)
);

mux_32to1 #(.N(1))	match_valid_bank_12_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_12_s6),
	.dout(match_valid_12)
);

mux_32to1 #(.N(1))	match_valid_bank_13_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_13_s6),
	.dout(match_valid_13)
);

mux_32to1 #(.N(1))	match_valid_bank_14_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_14_s6),
	.dout(match_valid_14)
);

mux_32to1 #(.N(1))	match_valid_bank_15_U(
	.din0(hash_valid_bank_0_bram_s6),
	.din1(hash_valid_bank_1_bram_s6),
	.din2(hash_valid_bank_2_bram_s6),
	.din3(hash_valid_bank_3_bram_s6),
	.din4(hash_valid_bank_4_bram_s6),
	.din5(hash_valid_bank_5_bram_s6), 
	.din6(hash_valid_bank_6_bram_s6),
	.din7(hash_valid_bank_7_bram_s6),
	.din8(hash_valid_bank_8_bram_s6),
	.din9(hash_valid_bank_9_bram_s6),
	.din10(hash_valid_bank_10_bram_s6),
	.din11(hash_valid_bank_11_bram_s6),
	.din12(hash_valid_bank_12_bram_s6),
	.din13(hash_valid_bank_13_bram_s6),
	.din14(hash_valid_bank_14_bram_s6),
	.din15(hash_valid_bank_15_bram_s6),
	.din16(hash_valid_bank_16_bram_s6),
	.din17(hash_valid_bank_17_bram_s6),
	.din18(hash_valid_bank_18_bram_s6),
	.din19(hash_valid_bank_19_bram_s6),
	.din20(hash_valid_bank_20_bram_s6),
	.din21(hash_valid_bank_21_bram_s6), 
	.din22(hash_valid_bank_22_bram_s6),
	.din23(hash_valid_bank_23_bram_s6),
	.din24(hash_valid_bank_24_bram_s6),
	.din25(hash_valid_bank_25_bram_s6),
	.din26(hash_valid_bank_26_bram_s6),
	.din27(hash_valid_bank_27_bram_s6),
	.din28(hash_valid_bank_28_bram_s6),
	.din29(hash_valid_bank_29_bram_s6),
	.din30(hash_valid_bank_30_bram_s6),
	.din31(hash_valid_bank_31_bram_s6),
	.sel(reg_raw_bank_num_15_s6),
	.dout(match_valid_15)
);

//
register_compression_reset #(.N(32)) register_input_position_s7_U(.d(input_position_s6), .clk(clk), .reset(rst), .q(input_position_s7));

register_compression_reset #(.N(1)) register_start_s7_U(.d(start_s6), .clk(clk), .reset(rst), .q(start_s7));

//
register_compression #(.N(5))	register_match_length_0_U(.d(match_length_0), .clk(clk), .q(reg_match_length_0_s7));
register_compression #(.N(5))	register_match_length_1_U(.d(match_length_1), .clk(clk), .q(reg_match_length_1_s7));
register_compression #(.N(5))	register_match_length_2_U(.d(match_length_2), .clk(clk), .q(reg_match_length_2_s7));
register_compression #(.N(5))	register_match_length_3_U(.d(match_length_3), .clk(clk), .q(reg_match_length_3_s7));
register_compression #(.N(5))	register_match_length_4_U(.d(match_length_4), .clk(clk), .q(reg_match_length_4_s7));
register_compression #(.N(5))	register_match_length_5_U(.d(match_length_5), .clk(clk), .q(reg_match_length_5_s7));
register_compression #(.N(5))	register_match_length_6_U(.d(match_length_6), .clk(clk), .q(reg_match_length_6_s7));
register_compression #(.N(5))	register_match_length_7_U(.d(match_length_7), .clk(clk), .q(reg_match_length_7_s7));
register_compression #(.N(5))	register_match_length_8_U(.d(match_length_8), .clk(clk), .q(reg_match_length_8_s7));
register_compression #(.N(5))	register_match_length_9_U(.d(match_length_9), .clk(clk), .q(reg_match_length_9_s7));
register_compression #(.N(5))	register_match_length_10_U(.d(match_length_10), .clk(clk), .q(reg_match_length_10_s7));
register_compression #(.N(5))	register_match_length_11_U(.d(match_length_11), .clk(clk), .q(reg_match_length_11_s7));
register_compression #(.N(5))	register_match_length_12_U(.d(match_length_12), .clk(clk), .q(reg_match_length_12_s7));
register_compression #(.N(5))	register_match_length_13_U(.d(match_length_13), .clk(clk), .q(reg_match_length_13_s7));
register_compression #(.N(5))	register_match_length_14_U(.d(match_length_14), .clk(clk), .q(reg_match_length_14_s7));
register_compression #(.N(5))	register_match_length_15_U(.d(match_length_15), .clk(clk), .q(reg_match_length_15_s7));

register_compression #(.N(31))	register_match_position_0_U(.d(match_position_0), .clk(clk), .q(reg_match_position_0_s7));
register_compression #(.N(31))	register_match_position_1_U(.d(match_position_1), .clk(clk), .q(reg_match_position_1_s7));
register_compression #(.N(31))	register_match_position_2_U(.d(match_position_2), .clk(clk), .q(reg_match_position_2_s7));
register_compression #(.N(31))	register_match_position_3_U(.d(match_position_3), .clk(clk), .q(reg_match_position_3_s7));
register_compression #(.N(31))	register_match_position_4_U(.d(match_position_4), .clk(clk), .q(reg_match_position_4_s7));
register_compression #(.N(31))	register_match_position_5_U(.d(match_position_5), .clk(clk), .q(reg_match_position_5_s7));
register_compression #(.N(31))	register_match_position_6_U(.d(match_position_6), .clk(clk), .q(reg_match_position_6_s7));
register_compression #(.N(31))	register_match_position_7_U(.d(match_position_7), .clk(clk), .q(reg_match_position_7_s7));
register_compression #(.N(31))	register_match_position_8_U(.d(match_position_8), .clk(clk), .q(reg_match_position_8_s7));
register_compression #(.N(31))	register_match_position_9_U(.d(match_position_9), .clk(clk), .q(reg_match_position_9_s7));
register_compression #(.N(31))	register_match_position_10_U(.d(match_position_10), .clk(clk), .q(reg_match_position_10_s7));
register_compression #(.N(31))	register_match_position_11_U(.d(match_position_11), .clk(clk), .q(reg_match_position_11_s7));
register_compression #(.N(31))	register_match_position_12_U(.d(match_position_12), .clk(clk), .q(reg_match_position_12_s7));
register_compression #(.N(31))	register_match_position_13_U(.d(match_position_13), .clk(clk), .q(reg_match_position_13_s7));
register_compression #(.N(31))	register_match_position_14_U(.d(match_position_14), .clk(clk), .q(reg_match_position_14_s7));
register_compression #(.N(31))	register_match_position_15_U(.d(match_position_15), .clk(clk), .q(reg_match_position_15_s7));

register_compression #(.N(1))	register_match_valid_0_U(.d(match_valid_0), .clk(clk), .q(reg_match_valid_0_s7));
register_compression #(.N(1))	register_match_valid_1_U(.d(match_valid_1), .clk(clk), .q(reg_match_valid_1_s7));
register_compression #(.N(1))	register_match_valid_2_U(.d(match_valid_2), .clk(clk), .q(reg_match_valid_2_s7));
register_compression #(.N(1))	register_match_valid_3_U(.d(match_valid_3), .clk(clk), .q(reg_match_valid_3_s7));
register_compression #(.N(1))	register_match_valid_4_U(.d(match_valid_4), .clk(clk), .q(reg_match_valid_4_s7));
register_compression #(.N(1))	register_match_valid_5_U(.d(match_valid_5), .clk(clk), .q(reg_match_valid_5_s7));
register_compression #(.N(1))	register_match_valid_6_U(.d(match_valid_6), .clk(clk), .q(reg_match_valid_6_s7));
register_compression #(.N(1))	register_match_valid_7_U(.d(match_valid_7), .clk(clk), .q(reg_match_valid_7_s7));
register_compression #(.N(1))	register_match_valid_8_U(.d(match_valid_8), .clk(clk), .q(reg_match_valid_8_s7));
register_compression #(.N(1))	register_match_valid_9_U(.d(match_valid_9), .clk(clk), .q(reg_match_valid_9_s7));
register_compression #(.N(1))	register_match_valid_10_U(.d(match_valid_10), .clk(clk), .q(reg_match_valid_10_s7));
register_compression #(.N(1))	register_match_valid_11_U(.d(match_valid_11), .clk(clk), .q(reg_match_valid_11_s7));
register_compression #(.N(1))	register_match_valid_12_U(.d(match_valid_12), .clk(clk), .q(reg_match_valid_12_s7));
register_compression #(.N(1))	register_match_valid_13_U(.d(match_valid_13), .clk(clk), .q(reg_match_valid_13_s7));
register_compression #(.N(1))	register_match_valid_14_U(.d(match_valid_14), .clk(clk), .q(reg_match_valid_14_s7));
register_compression #(.N(1))	register_match_valid_15_U(.d(match_valid_15), .clk(clk), .q(reg_match_valid_15_s7));

// 
register_compression #(.N(15)) reg_bank_select_s7_U(.d(reg_bank_select_s6), .clk(clk), .q(reg_bank_select_s7));

register_compression #(.N(256)) register_data_window_in_s7_U(.d(data_window_in_s6), .clk(clk), .q(data_window_in_s7));


// ====================================================================
//
//  Stage 8: 
//
// ====================================================================

// stage 8 ports definition
// dist info port
wire 	[30:0] 	dist_0_s8;
wire 	[30:0] 	dist_1_s8;
wire 	[30:0] 	dist_2_s8;
wire 	[30:0] 	dist_3_s8;
wire 	[30:0] 	dist_4_s8;
wire 	[30:0] 	dist_5_s8;
wire 	[30:0] 	dist_6_s8;
wire 	[30:0] 	dist_7_s8;
wire 	[30:0] 	dist_8_s8;
wire 	[30:0] 	dist_9_s8;
wire 	[30:0] 	dist_10_s8;
wire 	[30:0] 	dist_11_s8;
wire 	[30:0] 	dist_12_s8;
wire 	[30:0] 	dist_13_s8;
wire 	[30:0] 	dist_14_s8;
wire 	[30:0] 	dist_15_s8;

wire 	[15:0] 	reg_dist_0_s8;
wire 	[15:0] 	reg_dist_1_s8;
wire 	[15:0] 	reg_dist_2_s8;
wire 	[15:0] 	reg_dist_3_s8;
wire 	[15:0] 	reg_dist_4_s8;
wire 	[15:0] 	reg_dist_5_s8;
wire 	[15:0] 	reg_dist_6_s8;
wire 	[15:0] 	reg_dist_7_s8;
wire 	[15:0] 	reg_dist_8_s8;
wire 	[15:0] 	reg_dist_9_s8;
wire 	[15:0] 	reg_dist_10_s8;
wire 	[15:0] 	reg_dist_11_s8;
wire 	[15:0] 	reg_dist_12_s8;
wire 	[15:0] 	reg_dist_13_s8;
wire 	[15:0] 	reg_dist_14_s8;
wire 	[15:0] 	reg_dist_15_s8;

// match_valid info including checking distance
wire			match_valid_0_s8;
wire			match_valid_1_s8;
wire			match_valid_2_s8;
wire			match_valid_3_s8;
wire			match_valid_4_s8;
wire			match_valid_5_s8;
wire			match_valid_6_s8;
wire			match_valid_7_s8;
wire			match_valid_8_s8;
wire			match_valid_9_s8;
wire			match_valid_10_s8;
wire			match_valid_11_s8;
wire			match_valid_12_s8;
wire			match_valid_13_s8;
wire			match_valid_14_s8;
wire			match_valid_15_s8;

wire			reg_match_valid_0_s8;
wire			reg_match_valid_1_s8;
wire			reg_match_valid_2_s8;
wire			reg_match_valid_3_s8;
wire			reg_match_valid_4_s8;
wire			reg_match_valid_5_s8;
wire			reg_match_valid_6_s8;
wire			reg_match_valid_7_s8;
wire			reg_match_valid_8_s8;
wire			reg_match_valid_9_s8;
wire			reg_match_valid_10_s8;
wire			reg_match_valid_11_s8;
wire			reg_match_valid_12_s8;
wire			reg_match_valid_13_s8;
wire			reg_match_valid_14_s8;
wire			reg_match_valid_15_s8;

// match length info inherited from previous stage
wire 	[4:0]	reg_match_length_0_s8;
wire 	[4:0]	reg_match_length_1_s8;
wire 	[4:0]	reg_match_length_2_s8;
wire 	[4:0]	reg_match_length_3_s8;
wire 	[4:0]	reg_match_length_4_s8;
wire 	[4:0]	reg_match_length_5_s8;
wire 	[4:0]	reg_match_length_6_s8;
wire 	[4:0]	reg_match_length_7_s8;
wire 	[4:0]	reg_match_length_8_s8;
wire 	[4:0]	reg_match_length_9_s8;
wire 	[4:0]	reg_match_length_10_s8;
wire 	[4:0]	reg_match_length_11_s8;
wire 	[4:0]	reg_match_length_12_s8;
wire 	[4:0]	reg_match_length_13_s8;
wire 	[4:0]	reg_match_length_14_s8;
wire 	[4:0]	reg_match_length_15_s8;

// general information
wire 	[14:0]		reg_bank_select_s8;

wire	[31:0]      input_position_s8;

wire 	[255:0]		data_window_in_s8;

wire 				start_s8;

// 
assign dist_0_s8 = {input_position_s7[30:4], 4'd0} - reg_match_position_0_s7;
assign dist_1_s8 = {input_position_s7[30:4], 4'd1} - reg_match_position_1_s7;
assign dist_2_s8 = {input_position_s7[30:4], 4'd2} - reg_match_position_2_s7;
assign dist_3_s8 = {input_position_s7[30:4], 4'd3} - reg_match_position_3_s7;
assign dist_4_s8 = {input_position_s7[30:4], 4'd4} - reg_match_position_4_s7;
assign dist_5_s8 = {input_position_s7[30:4], 4'd5} - reg_match_position_5_s7;
assign dist_6_s8 = {input_position_s7[30:4], 4'd6} - reg_match_position_6_s7;
assign dist_7_s8 = {input_position_s7[30:4], 4'd7} - reg_match_position_7_s7;
assign dist_8_s8 = {input_position_s7[30:4], 4'd8} - reg_match_position_8_s7;
assign dist_9_s8 = {input_position_s7[30:4], 4'd9} - reg_match_position_9_s7;
assign dist_10_s8 = {input_position_s7[30:4], 4'd10} - reg_match_position_10_s7;
assign dist_11_s8 = {input_position_s7[30:4], 4'd11} - reg_match_position_11_s7;
assign dist_12_s8 = {input_position_s7[30:4], 4'd12} - reg_match_position_12_s7;
assign dist_13_s8 = {input_position_s7[30:4], 4'd13} - reg_match_position_13_s7;
assign dist_14_s8 = {input_position_s7[30:4], 4'd14} - reg_match_position_14_s7;
assign dist_15_s8 = {input_position_s7[30:4], 4'd15} - reg_match_position_15_s7;

assign match_valid_0_s8 = ((dist_0_s8[30:15] == 16'd0) || (dist_0_s8 == 31'd32768)) && reg_match_valid_0_s7;
assign match_valid_1_s8 = ((dist_1_s8[30:15] == 16'd0) || (dist_1_s8 == 31'd32768)) && reg_match_valid_1_s7;
assign match_valid_2_s8 = ((dist_2_s8[30:15] == 16'd0) || (dist_2_s8 == 31'd32768)) && reg_match_valid_2_s7;
assign match_valid_3_s8 = ((dist_3_s8[30:15] == 16'd0) || (dist_3_s8 == 31'd32768)) && reg_match_valid_3_s7;
assign match_valid_4_s8 = ((dist_4_s8[30:15] == 16'd0) || (dist_4_s8 == 31'd32768)) && reg_match_valid_4_s7;
assign match_valid_5_s8 = ((dist_5_s8[30:15] == 16'd0) || (dist_5_s8 == 31'd32768)) && reg_match_valid_5_s7;
assign match_valid_6_s8 = ((dist_6_s8[30:15] == 16'd0) || (dist_6_s8 == 31'd32768)) && reg_match_valid_6_s7;
assign match_valid_7_s8 = ((dist_7_s8[30:15] == 16'd0) || (dist_7_s8 == 31'd32768)) && reg_match_valid_7_s7;
assign match_valid_8_s8 = ((dist_8_s8[30:15] == 16'd0) || (dist_8_s8 == 31'd32768)) && reg_match_valid_8_s7;
assign match_valid_9_s8 = ((dist_9_s8[30:15] == 16'd0) || (dist_9_s8 == 31'd32768)) && reg_match_valid_9_s7;
assign match_valid_10_s8 = ((dist_10_s8[30:15] == 16'd0) || (dist_10_s8 == 31'd32768)) && reg_match_valid_10_s7;
assign match_valid_11_s8 = ((dist_11_s8[30:15] == 16'd0) || (dist_11_s8 == 31'd32768)) && reg_match_valid_11_s7;
assign match_valid_12_s8 = ((dist_12_s8[30:15] == 16'd0) || (dist_12_s8 == 31'd32768)) && reg_match_valid_12_s7;
assign match_valid_13_s8 = ((dist_13_s8[30:15] == 16'd0) || (dist_13_s8 == 31'd32768)) && reg_match_valid_13_s7;
assign match_valid_14_s8 = ((dist_14_s8[30:15] == 16'd0) || (dist_14_s8 == 31'd32768)) && reg_match_valid_14_s7;
assign match_valid_15_s8 = ((dist_15_s8[30:15] == 16'd0) || (dist_15_s8 == 31'd32768)) && reg_match_valid_15_s7;

//
register_compression_reset #(.N(32)) register_input_position_s8_U(.d(input_position_s7), .clk(clk), .reset(rst), .q(input_position_s8));

register_compression_reset #(.N(1)) register_start_s8_U(.d(start_s7), .clk(clk), .reset(rst), .q(start_s8));

// 
register_compression #(.N(16))	register_dist_0_s8_U(.d(dist_0_s8[15:0]), .clk(clk), .q(reg_dist_0_s8));
register_compression #(.N(16))	register_dist_1_s8_U(.d(dist_1_s8[15:0]), .clk(clk), .q(reg_dist_1_s8));
register_compression #(.N(16))	register_dist_2_s8_U(.d(dist_2_s8[15:0]), .clk(clk), .q(reg_dist_2_s8));
register_compression #(.N(16))	register_dist_3_s8_U(.d(dist_3_s8[15:0]), .clk(clk), .q(reg_dist_3_s8));
register_compression #(.N(16))	register_dist_4_s8_U(.d(dist_4_s8[15:0]), .clk(clk), .q(reg_dist_4_s8));
register_compression #(.N(16))	register_dist_5_s8_U(.d(dist_5_s8[15:0]), .clk(clk), .q(reg_dist_5_s8));
register_compression #(.N(16))	register_dist_6_s8_U(.d(dist_6_s8[15:0]), .clk(clk), .q(reg_dist_6_s8));
register_compression #(.N(16))	register_dist_7_s8_U(.d(dist_7_s8[15:0]), .clk(clk), .q(reg_dist_7_s8));
register_compression #(.N(16))	register_dist_8_s8_U(.d(dist_8_s8[15:0]), .clk(clk), .q(reg_dist_8_s8));
register_compression #(.N(16))	register_dist_9_s8_U(.d(dist_9_s8[15:0]), .clk(clk), .q(reg_dist_9_s8));
register_compression #(.N(16))	register_dist_10_s8_U(.d(dist_10_s8[15:0]), .clk(clk), .q(reg_dist_10_s8));
register_compression #(.N(16))	register_dist_11_s8_U(.d(dist_11_s8[15:0]), .clk(clk), .q(reg_dist_11_s8));
register_compression #(.N(16))	register_dist_12_s8_U(.d(dist_12_s8[15:0]), .clk(clk), .q(reg_dist_12_s8));
register_compression #(.N(16))	register_dist_13_s8_U(.d(dist_13_s8[15:0]), .clk(clk), .q(reg_dist_13_s8));
register_compression #(.N(16))	register_dist_14_s8_U(.d(dist_14_s8[15:0]), .clk(clk), .q(reg_dist_14_s8));
register_compression #(.N(16))	register_dist_15_s8_U(.d(dist_15_s8[15:0]), .clk(clk), .q(reg_dist_15_s8));

register_compression #(.N(1))	register_match_valid_0_s8_U(.d(match_valid_0_s8), .clk(clk), .q(reg_match_valid_0_s8));
register_compression #(.N(1))	register_match_valid_1_s8_U(.d(match_valid_1_s8), .clk(clk), .q(reg_match_valid_1_s8));
register_compression #(.N(1))	register_match_valid_2_s8_U(.d(match_valid_2_s8), .clk(clk), .q(reg_match_valid_2_s8));
register_compression #(.N(1))	register_match_valid_3_s8_U(.d(match_valid_3_s8), .clk(clk), .q(reg_match_valid_3_s8));
register_compression #(.N(1))	register_match_valid_4_s8_U(.d(match_valid_4_s8), .clk(clk), .q(reg_match_valid_4_s8));
register_compression #(.N(1))	register_match_valid_5_s8_U(.d(match_valid_5_s8), .clk(clk), .q(reg_match_valid_5_s8));
register_compression #(.N(1))	register_match_valid_6_s8_U(.d(match_valid_6_s8), .clk(clk), .q(reg_match_valid_6_s8));
register_compression #(.N(1))	register_match_valid_7_s8_U(.d(match_valid_7_s8), .clk(clk), .q(reg_match_valid_7_s8));
register_compression #(.N(1))	register_match_valid_8_s8_U(.d(match_valid_8_s8), .clk(clk), .q(reg_match_valid_8_s8));
register_compression #(.N(1))	register_match_valid_9_s8_U(.d(match_valid_9_s8), .clk(clk), .q(reg_match_valid_9_s8));
register_compression #(.N(1))	register_match_valid_10_s8_U(.d(match_valid_10_s8), .clk(clk), .q(reg_match_valid_10_s8));
register_compression #(.N(1))	register_match_valid_11_s8_U(.d(match_valid_11_s8), .clk(clk), .q(reg_match_valid_11_s8));
register_compression #(.N(1))	register_match_valid_12_s8_U(.d(match_valid_12_s8), .clk(clk), .q(reg_match_valid_12_s8));
register_compression #(.N(1))	register_match_valid_13_s8_U(.d(match_valid_13_s8), .clk(clk), .q(reg_match_valid_13_s8));
register_compression #(.N(1))	register_match_valid_14_s8_U(.d(match_valid_14_s8), .clk(clk), .q(reg_match_valid_14_s8));
register_compression #(.N(1))	register_match_valid_15_s8_U(.d(match_valid_15_s8), .clk(clk), .q(reg_match_valid_15_s8));

register_compression #(.N(5))		register_match_length_0_s8_U(.d(reg_match_length_0_s7), .clk(clk), .q(reg_match_length_0_s8));
register_compression #(.N(5))		register_match_length_1_s8_U(.d(reg_match_length_1_s7), .clk(clk), .q(reg_match_length_1_s8));
register_compression #(.N(5))		register_match_length_2_s8_U(.d(reg_match_length_2_s7), .clk(clk), .q(reg_match_length_2_s8));
register_compression #(.N(5))		register_match_length_3_s8_U(.d(reg_match_length_3_s7), .clk(clk), .q(reg_match_length_3_s8));
register_compression #(.N(5))		register_match_length_4_s8_U(.d(reg_match_length_4_s7), .clk(clk), .q(reg_match_length_4_s8));
register_compression #(.N(5))		register_match_length_5_s8_U(.d(reg_match_length_5_s7), .clk(clk), .q(reg_match_length_5_s8));
register_compression #(.N(5))		register_match_length_6_s8_U(.d(reg_match_length_6_s7), .clk(clk), .q(reg_match_length_6_s8));
register_compression #(.N(5))		register_match_length_7_s8_U(.d(reg_match_length_7_s7), .clk(clk), .q(reg_match_length_7_s8));
register_compression #(.N(5))		register_match_length_8_s8_U(.d(reg_match_length_8_s7), .clk(clk), .q(reg_match_length_8_s8));
register_compression #(.N(5))		register_match_length_9_s8_U(.d(reg_match_length_9_s7), .clk(clk), .q(reg_match_length_9_s8));
register_compression #(.N(5))		register_match_length_10_s8_U(.d(reg_match_length_10_s7), .clk(clk), .q(reg_match_length_10_s8));
register_compression #(.N(5))		register_match_length_11_s8_U(.d(reg_match_length_11_s7), .clk(clk), .q(reg_match_length_11_s8));
register_compression #(.N(5))		register_match_length_12_s8_U(.d(reg_match_length_12_s7), .clk(clk), .q(reg_match_length_12_s8));
register_compression #(.N(5))		register_match_length_13_s8_U(.d(reg_match_length_13_s7), .clk(clk), .q(reg_match_length_13_s8));
register_compression #(.N(5))		register_match_length_14_s8_U(.d(reg_match_length_14_s7), .clk(clk), .q(reg_match_length_14_s8));
register_compression #(.N(5))		register_match_length_15_s8_U(.d(reg_match_length_15_s7), .clk(clk), .q(reg_match_length_15_s8));

register_compression #(.N(15)) 		reg_bank_select_s8_U(.d(reg_bank_select_s7), .clk(clk), .q(reg_bank_select_s8));

register_compression #(.N(256)) 	register_data_window_in_s8_U(.d(data_window_in_s7), .clk(clk), .q(data_window_in_s8));


// ====================================================================
//
//  Stage 9: 
//
// ====================================================================

// stage 9 ports definition
// match_length_k_modified is used in case distance is less than match length
wire 	[4:0] 	match_length_0_modified;
wire 	[4:0] 	match_length_1_modified;
wire 	[4:0] 	match_length_2_modified;
wire 	[4:0] 	match_length_3_modified;
wire 	[4:0] 	match_length_4_modified;
wire 	[4:0] 	match_length_5_modified;
wire 	[4:0] 	match_length_6_modified;
wire 	[4:0] 	match_length_7_modified;
wire 	[4:0] 	match_length_8_modified;
wire 	[4:0] 	match_length_9_modified;
wire 	[4:0] 	match_length_10_modified;
wire 	[4:0] 	match_length_11_modified;
wire 	[4:0] 	match_length_12_modified;
wire 	[4:0] 	match_length_13_modified;
wire 	[4:0] 	match_length_14_modified;
wire 	[4:0] 	match_length_15_modified;

// match_length_k_op is equal to the real match length - 3
wire 	[4:0] 	match_length_0_op;
wire 	[4:0] 	match_length_1_op;
wire 	[4:0] 	match_length_2_op;
wire 	[4:0] 	match_length_3_op;
wire 	[4:0] 	match_length_4_op;
wire 	[4:0] 	match_length_5_op;
wire 	[4:0] 	match_length_6_op;
wire 	[4:0] 	match_length_7_op;
wire 	[4:0] 	match_length_8_op;
wire 	[4:0] 	match_length_9_op;
wire 	[4:0] 	match_length_10_op;
wire 	[4:0] 	match_length_11_op;
wire 	[4:0] 	match_length_12_op;
wire 	[4:0] 	match_length_13_op;
wire 	[4:0] 	match_length_14_op;
wire 	[4:0] 	match_length_15_op;

// overflow_k = 1 means match_length_k >= 3
wire 			overflow_0;
wire 			overflow_1;
wire 			overflow_2;
wire 			overflow_3;
wire 			overflow_4;
wire 			overflow_5;
wire 			overflow_6;
wire 			overflow_7;
wire 			overflow_8;
wire 			overflow_9;
wire 			overflow_10;
wire 			overflow_11;
wire 			overflow_12;
wire 			overflow_13;
wire 			overflow_14;
wire 			overflow_15;

// l_valid_k indicate if length k corresponds to a real match
wire 			l_valid_0;
wire 			l_valid_1;
wire 			l_valid_2;
wire 			l_valid_3;
wire 			l_valid_4;
wire 			l_valid_5;
wire 			l_valid_6;
wire 			l_valid_7;
wire 			l_valid_8;
wire 			l_valid_9;
wire 			l_valid_10;
wire 			l_valid_11;
wire 			l_valid_12;
wire 			l_valid_13;
wire 			l_valid_14;
wire 			l_valid_15;

// len_k is either a literal value or a matched length
wire 	[7:0]	len_0;
wire 	[7:0]	len_1;
wire 	[7:0]	len_2;
wire 	[7:0]	len_3;
wire 	[7:0]	len_4;
wire 	[7:0]	len_5;
wire 	[7:0]	len_6;
wire 	[7:0]	len_7;
wire 	[7:0]	len_8;
wire 	[7:0]	len_9;
wire 	[7:0]	len_10;
wire 	[7:0]	len_11;
wire 	[7:0]	len_12;
wire 	[7:0]	len_13;
wire 	[7:0]	len_14;
wire 	[7:0]	len_15;

// dist_k is either 0 (for literal value) or a matched distance
wire 	[15:0] 	dist_0;
wire 	[15:0] 	dist_1;
wire 	[15:0] 	dist_2;
wire 	[15:0] 	dist_3;
wire 	[15:0] 	dist_4;
wire 	[15:0] 	dist_5;
wire 	[15:0] 	dist_6;
wire 	[15:0] 	dist_7;
wire 	[15:0] 	dist_8;
wire 	[15:0] 	dist_9;
wire 	[15:0] 	dist_10;
wire 	[15:0] 	dist_11;
wire 	[15:0] 	dist_12;
wire 	[15:0] 	dist_13;
wire 	[15:0] 	dist_14;
wire 	[15:0] 	dist_15;

wire 	[15:0]	valid;
wire 	[127:0] len_raw;
wire	[255:0] dist_raw;

// match_length_k_modified is used in case distance is less than match length
assign match_length_0_modified = ({11'd0, reg_match_length_0_s8} > reg_dist_0_s8)?reg_dist_0_s8[4:0]:reg_match_length_0_s8;
assign match_length_1_modified = ({11'd0, reg_match_length_1_s8} > reg_dist_1_s8)?reg_dist_1_s8[4:0]:reg_match_length_1_s8;
assign match_length_2_modified = ({11'd0, reg_match_length_2_s8} > reg_dist_2_s8)?reg_dist_2_s8[4:0]:reg_match_length_2_s8;
assign match_length_3_modified = ({11'd0, reg_match_length_3_s8} > reg_dist_3_s8)?reg_dist_3_s8[4:0]:reg_match_length_3_s8;
assign match_length_4_modified = ({11'd0, reg_match_length_4_s8} > reg_dist_4_s8)?reg_dist_4_s8[4:0]:reg_match_length_4_s8;
assign match_length_5_modified = ({11'd0, reg_match_length_5_s8} > reg_dist_5_s8)?reg_dist_5_s8[4:0]:reg_match_length_5_s8;
assign match_length_6_modified = ({11'd0, reg_match_length_6_s8} > reg_dist_6_s8)?reg_dist_6_s8[4:0]:reg_match_length_6_s8;
assign match_length_7_modified = ({11'd0, reg_match_length_7_s8} > reg_dist_7_s8)?reg_dist_7_s8[4:0]:reg_match_length_7_s8;
assign match_length_8_modified = ({11'd0, reg_match_length_8_s8} > reg_dist_8_s8)?reg_dist_8_s8[4:0]:reg_match_length_8_s8;
assign match_length_9_modified = ({11'd0, reg_match_length_9_s8} > reg_dist_9_s8)?reg_dist_9_s8[4:0]:reg_match_length_9_s8;
assign match_length_10_modified = ({11'd0, reg_match_length_10_s8} > reg_dist_10_s8)?reg_dist_10_s8[4:0]:reg_match_length_10_s8;
assign match_length_11_modified = ({11'd0, reg_match_length_11_s8} > reg_dist_11_s8)?reg_dist_11_s8[4:0]:reg_match_length_11_s8;
assign match_length_12_modified = ({11'd0, reg_match_length_12_s8} > reg_dist_12_s8)?reg_dist_12_s8[4:0]:reg_match_length_12_s8;
assign match_length_13_modified = ({11'd0, reg_match_length_13_s8} > reg_dist_13_s8)?reg_dist_13_s8[4:0]:reg_match_length_13_s8;
assign match_length_14_modified = ({11'd0, reg_match_length_14_s8} > reg_dist_14_s8)?reg_dist_14_s8[4:0]:reg_match_length_14_s8;
assign match_length_15_modified = ({11'd0, reg_match_length_15_s8} > reg_dist_15_s8)?reg_dist_15_s8[4:0]:reg_match_length_15_s8;

// check if matched length is larger than 3
adder_5bits adder_5bits_0_U(
	.a(match_length_0_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_0_op),
	.co(overflow_0) );

adder_5bits adder_5bits_1_U(
	.a(match_length_1_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_1_op),
	.co(overflow_1) );

adder_5bits adder_5bits_2_U(
	.a(match_length_2_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_2_op),
	.co(overflow_2) );

adder_5bits adder_5bits_3_U(
	.a(match_length_3_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_3_op),
	.co(overflow_3) );

adder_5bits adder_5bits_4_U(
	.a(match_length_4_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_4_op),
	.co(overflow_4) );

adder_5bits adder_5bits_5_U(
	.a(match_length_5_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_5_op),
	.co(overflow_5) );

adder_5bits adder_5bits_6_U(
	.a(match_length_6_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_6_op),
	.co(overflow_6) );

adder_5bits adder_5bits_7_U(
	.a(match_length_7_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_7_op),
	.co(overflow_7) );

adder_5bits adder_5bits_8_U(
	.a(match_length_8_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_8_op),
	.co(overflow_8) );

adder_5bits adder_5bits_9_U(
	.a(match_length_9_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_9_op),
	.co(overflow_9) );

adder_5bits adder_5bits_10_U(
	.a(match_length_10_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_10_op),
	.co(overflow_10) );

adder_5bits adder_5bits_11_U(
	.a(match_length_11_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_11_op),
	.co(overflow_11) );

adder_5bits adder_5bits_12_U(
	.a(match_length_12_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_12_op),
	.co(overflow_12) );

adder_5bits adder_5bits_13_U(
	.a(match_length_13_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_13_op),
	.co(overflow_13) );

adder_5bits adder_5bits_14_U(
	.a(match_length_14_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_14_op),
	.co(overflow_14) );

adder_5bits adder_5bits_15_U(
	.a(match_length_15_modified),
	.b(5'b11101),
	.ci(1'b0),
	.s(match_length_15_op),
	.co(overflow_15) );

// l_valid_k is set when the following requirements are met
// 		(1) matched length is larger than 3 
// 		(2) match candidate in history memory is valid 
// 		(3) current substring can access the memory bank
assign l_valid_0 = overflow_0 & reg_match_valid_0_s8;
assign l_valid_1 = overflow_1 & reg_match_valid_1_s8 & (~reg_bank_select_s8[0]);
assign l_valid_2 = overflow_2 & reg_match_valid_2_s8 & (~reg_bank_select_s8[1]); 
assign l_valid_3 = overflow_3 & reg_match_valid_3_s8 & (~reg_bank_select_s8[2]);
assign l_valid_4 = overflow_4 & reg_match_valid_4_s8 & (~reg_bank_select_s8[3]);
assign l_valid_5 = overflow_5 & reg_match_valid_5_s8 & (~reg_bank_select_s8[4]);
assign l_valid_6 = overflow_6 & reg_match_valid_6_s8 & (~reg_bank_select_s8[5]);
assign l_valid_7 = overflow_7 & reg_match_valid_7_s8 & (~reg_bank_select_s8[6]);
assign l_valid_8 = overflow_8 & reg_match_valid_8_s8 & (~reg_bank_select_s8[7]);
assign l_valid_9 = overflow_9 & reg_match_valid_9_s8 & (~reg_bank_select_s8[8]);
assign l_valid_10 = overflow_10 & reg_match_valid_10_s8 & (~reg_bank_select_s8[9]);
assign l_valid_11 = overflow_11 & reg_match_valid_11_s8 & (~reg_bank_select_s8[10]);
assign l_valid_12 = overflow_12 & reg_match_valid_12_s8 & (~reg_bank_select_s8[11]);
assign l_valid_13 = overflow_13 & reg_match_valid_13_s8 & (~reg_bank_select_s8[12]);
assign l_valid_14 = overflow_14 & reg_match_valid_14_s8 & (~reg_bank_select_s8[13]);
assign l_valid_15 = overflow_15 & reg_match_valid_15_s8 & (~reg_bank_select_s8[14]);

// len_k is either matched length or literal value
assign len_0 = l_valid_0?{3'd0, match_length_0_op}:data_window_in_s8[255:248];
assign len_1 = l_valid_1?{3'd0, match_length_1_op}:data_window_in_s8[247:240];
assign len_2 = l_valid_2?{3'd0, match_length_2_op}:data_window_in_s8[239:232];
assign len_3 = l_valid_3?{3'd0, match_length_3_op}:data_window_in_s8[231:224];
assign len_4 = l_valid_4?{3'd0, match_length_4_op}:data_window_in_s8[223:216];
assign len_5 = l_valid_5?{3'd0, match_length_5_op}:data_window_in_s8[215:208];
assign len_6 = l_valid_6?{3'd0, match_length_6_op}:data_window_in_s8[207:200];
assign len_7 = l_valid_7?{3'd0, match_length_7_op}:data_window_in_s8[199:192];
assign len_8 = l_valid_8?{3'd0, match_length_8_op}:data_window_in_s8[191:184];
assign len_9 = l_valid_9?{3'd0, match_length_9_op}:data_window_in_s8[183:176];
assign len_10 = l_valid_10?{3'd0, match_length_10_op}:data_window_in_s8[175:168];
assign len_11 = l_valid_11?{3'd0, match_length_11_op}:data_window_in_s8[167:160];
assign len_12 = l_valid_12?{3'd0, match_length_12_op}:data_window_in_s8[159:152];
assign len_13 = l_valid_13?{3'd0, match_length_13_op}:data_window_in_s8[151:144];
assign len_14 = l_valid_14?{3'd0, match_length_14_op}:data_window_in_s8[143:136];
assign len_15 = l_valid_15?{3'd0, match_length_15_op}:data_window_in_s8[135:128];

// dist_k is either matched distance or 0
assign dist_0 = l_valid_0?reg_dist_0_s8:16'd0;
assign dist_1 = l_valid_1?reg_dist_1_s8:16'd0;
assign dist_2 = l_valid_2?reg_dist_2_s8:16'd0;
assign dist_3 = l_valid_3?reg_dist_3_s8:16'd0;
assign dist_4 = l_valid_4?reg_dist_4_s8:16'd0;
assign dist_5 = l_valid_5?reg_dist_5_s8:16'd0;
assign dist_6 = l_valid_6?reg_dist_6_s8:16'd0;
assign dist_7 = l_valid_7?reg_dist_7_s8:16'd0;
assign dist_8 = l_valid_8?reg_dist_8_s8:16'd0;
assign dist_9 = l_valid_9?reg_dist_9_s8:16'd0;
assign dist_10 = l_valid_10?reg_dist_10_s8:16'd0;
assign dist_11 = l_valid_11?reg_dist_11_s8:16'd0;
assign dist_12 = l_valid_12?reg_dist_12_s8:16'd0;
assign dist_13 = l_valid_13?reg_dist_13_s8:16'd0;
assign dist_14 = l_valid_14?reg_dist_14_s8:16'd0;
assign dist_15 = l_valid_15?reg_dist_15_s8:16'd0;

// 
assign valid = {l_valid_0, l_valid_1, l_valid_2, l_valid_3, l_valid_4, l_valid_5, l_valid_6, l_valid_7, 
				 l_valid_8, l_valid_9, l_valid_10, l_valid_11, l_valid_12, l_valid_13, l_valid_14, l_valid_15};

assign len_raw = {len_0[7:0], len_1[7:0], len_2[7:0], len_3[7:0], len_4[7:0], len_5[7:0], len_6[7:0], len_7[7:0], 
				   len_8[7:0], len_9[7:0], len_10[7:0], len_11[7:0], len_12[7:0], len_13[7:0], len_14[7:0], len_15[7:0]};

assign dist_raw = {dist_0, dist_1, dist_2, dist_3, dist_4, dist_5, dist_6, dist_7, 
					dist_8, dist_9, dist_10, dist_11, dist_12, dist_13, dist_14, dist_15};

// 
register_compression_reset #(.N(1)) 	register_output_ready_U(.d(start_s8), .clk(clk), .reset(rst), .q(output_ready));

// 
register_compression #(.N(128))		register_len_raw_out_U(.d(len_raw), .clk(clk), .q(len_raw_out));
register_compression #(.N(256))		register_dist_raw_out_U(.d(dist_raw), .clk(clk), .q(dist_raw_out));
register_compression #(.N(128)) 	register_literals_out_U(.d(data_window_in_s8[255:128]), .clk(clk), .q(literals_out));
register_compression #(.N(16))		register_valid_out_U(.d(valid), .clk(clk), .q(valid_out));



endmodule