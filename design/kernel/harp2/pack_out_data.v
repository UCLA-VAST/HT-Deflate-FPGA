// ==============================================================
// Description: huffman_encode			
// Author: Weikang Qiao
// Date: 01/01/2017
//
// Parameters:
// 				BANK_OFFSETS = 256
// 				HASH_TABLE_BANKS = VEC = 16;
//
// Note: Stage = 6 + VEC
//		 
// 		 s1-s4: huffman translate
// ==============================================================
module pack_out_data(
	clk, 
	reset, 
	start, 
	last, 
	en, 
	larray_in, 
	darray_in, 
	valid_in, 
	out_data, 
	out_ready, 
	out_len, 
	out_last
);

input 	[127:0]		larray_in;
input 	[255:0]		darray_in;
input	[15:0]		valid_in;

input 			clk;
input 			reset;
input 			en;
input 			start;
input 			last;

output 				out_ready;
output 	[255:0] 	out_data;
output 	[7:0]		out_len;
output 				out_last;



// stage 1-4 port
wire	[3:0]	l_huffman_len_0_s4;	//range: 7-9
wire	[11:0]	l_huffman_code_0_s4;
wire 	[3:0]	l_extra_len_0_s4;	//range: 0-5
wire	[7:0]	l_extra_0_s4;
wire 	[2:0] 	d_huffman_len_0_s4;	// range: 5-5
wire 	[4:0] 	d_huffman_code_0_s4;
wire	[3:0]	d_extra_len_0_s4;	// range: 0-13
wire 	[15:0]	d_extra_0_s4;
wire 			output_ready_0_s4;


wire	[3:0]	l_huffman_len_1_s4;
wire	[11:0]	l_huffman_code_1_s4;
wire 	[3:0]	l_extra_len_1_s4;
wire	[7:0]	l_extra_1_s4;
wire 	[2:0] 	d_huffman_len_1_s4;
wire 	[4:0] 	d_huffman_code_1_s4;
wire	[3:0]	d_extra_len_1_s4;
wire 	[15:0]	d_extra_1_s4;


wire	[3:0]	l_huffman_len_2_s4;
wire	[11:0]	l_huffman_code_2_s4;
wire 	[3:0]	l_extra_len_2_s4;
wire	[7:0]	l_extra_2_s4;
wire 	[2:0] 	d_huffman_len_2_s4;
wire 	[4:0] 	d_huffman_code_2_s4;
wire	[3:0]	d_extra_len_2_s4;
wire 	[15:0]	d_extra_2_s4;


wire	[3:0]	l_huffman_len_3_s4;
wire	[11:0]	l_huffman_code_3_s4;
wire 	[3:0]	l_extra_len_3_s4;
wire	[7:0]	l_extra_3_s4;
wire 	[2:0] 	d_huffman_len_3_s4;
wire 	[4:0] 	d_huffman_code_3_s4;
wire	[3:0]	d_extra_len_3_s4;
wire 	[15:0]	d_extra_3_s4;


wire	[3:0]	l_huffman_len_4_s4;
wire	[11:0]	l_huffman_code_4_s4;
wire 	[3:0]	l_extra_len_4_s4;
wire	[7:0]	l_extra_4_s4;
wire 	[2:0] 	d_huffman_len_4_s4;
wire 	[4:0] 	d_huffman_code_4_s4;
wire	[3:0]	d_extra_len_4_s4;
wire 	[15:0]	d_extra_4_s4;


wire	[3:0]	l_huffman_len_5_s4;
wire	[11:0]	l_huffman_code_5_s4;
wire 	[3:0]	l_extra_len_5_s4;
wire	[7:0]	l_extra_5_s4;
wire 	[2:0] 	d_huffman_len_5_s4;
wire 	[4:0] 	d_huffman_code_5_s4;
wire	[3:0]	d_extra_len_5_s4;
wire 	[15:0]	d_extra_5_s4;


wire	[3:0]	l_huffman_len_6_s4;
wire	[11:0]	l_huffman_code_6_s4;
wire 	[3:0]	l_extra_len_6_s4;
wire	[7:0]	l_extra_6_s4;
wire 	[2:0] 	d_huffman_len_6_s4;
wire 	[4:0] 	d_huffman_code_6_s4;
wire	[3:0]	d_extra_len_6_s4;
wire 	[15:0]	d_extra_6_s4;


wire	[3:0]	l_huffman_len_7_s4;
wire	[11:0]	l_huffman_code_7_s4;
wire 	[3:0]	l_extra_len_7_s4;
wire	[7:0]	l_extra_7_s4;
wire 	[2:0] 	d_huffman_len_7_s4;
wire 	[4:0] 	d_huffman_code_7_s4;
wire	[3:0]	d_extra_len_7_s4;
wire 	[15:0]	d_extra_7_s4;


wire	[3:0]	l_huffman_len_8_s4;
wire	[11:0]	l_huffman_code_8_s4;
wire 	[3:0]	l_extra_len_8_s4;
wire	[7:0]	l_extra_8_s4;
wire 	[2:0] 	d_huffman_len_8_s4;
wire 	[4:0] 	d_huffman_code_8_s4;
wire	[3:0]	d_extra_len_8_s4;
wire 	[15:0]	d_extra_8_s4;


wire	[3:0]	l_huffman_len_9_s4;
wire	[11:0]	l_huffman_code_9_s4;
wire 	[3:0]	l_extra_len_9_s4;
wire	[7:0]	l_extra_9_s4;
wire 	[2:0] 	d_huffman_len_9_s4;
wire 	[4:0] 	d_huffman_code_9_s4;
wire	[3:0]	d_extra_len_9_s4;
wire 	[15:0]	d_extra_9_s4;


wire	[3:0]	l_huffman_len_10_s4;
wire	[11:0]	l_huffman_code_10_s4;
wire 	[3:0]	l_extra_len_10_s4;
wire	[7:0]	l_extra_10_s4;
wire 	[2:0] 	d_huffman_len_10_s4;
wire 	[4:0] 	d_huffman_code_10_s4;
wire	[3:0]	d_extra_len_10_s4;
wire 	[15:0]	d_extra_10_s4;


wire	[3:0]	l_huffman_len_11_s4;
wire	[11:0]	l_huffman_code_11_s4;
wire 	[3:0]	l_extra_len_11_s4;
wire	[7:0]	l_extra_11_s4;
wire 	[2:0] 	d_huffman_len_11_s4;
wire 	[4:0] 	d_huffman_code_11_s4;
wire	[3:0]	d_extra_len_11_s4;
wire 	[15:0]	d_extra_11_s4;


wire	[3:0]	l_huffman_len_12_s4;
wire	[11:0]	l_huffman_code_12_s4;
wire 	[3:0]	l_extra_len_12_s4;
wire	[7:0]	l_extra_12_s4;
wire 	[2:0] 	d_huffman_len_12_s4;
wire 	[4:0] 	d_huffman_code_12_s4;
wire	[3:0]	d_extra_len_12_s4;
wire 	[15:0]	d_extra_12_s4;


wire	[3:0]	l_huffman_len_13_s4;
wire	[11:0]	l_huffman_code_13_s4;
wire 	[3:0]	l_extra_len_13_s4;
wire	[7:0]	l_extra_13_s4;
wire 	[2:0] 	d_huffman_len_13_s4;
wire 	[4:0] 	d_huffman_code_13_s4;
wire	[3:0]	d_extra_len_13_s4;
wire 	[15:0]	d_extra_13_s4;


wire	[3:0]	l_huffman_len_14_s4;
wire	[11:0]	l_huffman_code_14_s4;
wire 	[3:0]	l_extra_len_14_s4;
wire	[7:0]	l_extra_14_s4;
wire 	[2:0] 	d_huffman_len_14_s4;
wire 	[4:0] 	d_huffman_code_14_s4;
wire	[3:0]	d_extra_len_14_s4;
wire 	[15:0]	d_extra_14_s4;


wire	[3:0]	l_huffman_len_15_s4;
wire	[11:0]	l_huffman_code_15_s4;
wire 	[3:0]	l_extra_len_15_s4;
wire	[7:0]	l_extra_15_s4;
wire 	[2:0] 	d_huffman_len_15_s4;
wire 	[4:0] 	d_huffman_code_15_s4;
wire	[3:0]	d_extra_len_15_s4;
wire 	[15:0]	d_extra_15_s4;


wire	[15:0]	valid_s1;
wire	[15:0]	valid_s2;
wire	[15:0]	valid_s3;


wire 			start_s1;
wire 			start_s2;
wire 			start_s3;

wire 			last_s1;
wire 			last_s2;
wire 			last_s3;


wire 	huffman_translate_ready;



// stage 1-4
huffman_translation 	huffma_translation_0_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[127:120]), 
	.d_V(darray_in[255:240]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_0_s4), 
	.l_huffman_code(l_huffman_code_0_s4),
	.l_extra_len(l_extra_len_0_s4), 
	.l_extra(l_extra_0_s4), 
	.d_huffman_len(d_huffman_len_0_s4), 
	.d_huffman_code(d_huffman_code_0_s4),
	.d_extra_len(d_extra_len_0_s4), 
	.d_extra(d_extra_0_s4), 
	.output_ready(huffman_translate_ready)
);

huffman_translation 	huffma_translation_1_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[119:112]), 
	.d_V(darray_in[239:224]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_1_s4), 
	.l_huffman_code(l_huffman_code_1_s4),
	.l_extra_len(l_extra_len_1_s4), 
	.l_extra(l_extra_1_s4), 
	.d_huffman_len(d_huffman_len_1_s4), 
	.d_huffman_code(d_huffman_code_1_s4),
	.d_extra_len(d_extra_len_1_s4), 
	.d_extra(d_extra_1_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_2_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[111:104]), 
	.d_V(darray_in[223:208]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_2_s4), 
	.l_huffman_code(l_huffman_code_2_s4),
	.l_extra_len(l_extra_len_2_s4), 
	.l_extra(l_extra_2_s4), 
	.d_huffman_len(d_huffman_len_2_s4), 
	.d_huffman_code(d_huffman_code_2_s4),
	.d_extra_len(d_extra_len_2_s4), 
	.d_extra(d_extra_2_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_3_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[103:96]), 
	.d_V(darray_in[207:192]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_3_s4), 
	.l_huffman_code(l_huffman_code_3_s4),
	.l_extra_len(l_extra_len_3_s4), 
	.l_extra(l_extra_3_s4), 
	.d_huffman_len(d_huffman_len_3_s4), 
	.d_huffman_code(d_huffman_code_3_s4),
	.d_extra_len(d_extra_len_3_s4), 
	.d_extra(d_extra_3_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_4_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[95:88]), 
	.d_V(darray_in[191:176]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_4_s4), 
	.l_huffman_code(l_huffman_code_4_s4),
	.l_extra_len(l_extra_len_4_s4), 
	.l_extra(l_extra_4_s4), 
	.d_huffman_len(d_huffman_len_4_s4), 
	.d_huffman_code(d_huffman_code_4_s4),
	.d_extra_len(d_extra_len_4_s4), 
	.d_extra(d_extra_4_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_5_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[87:80]), 
	.d_V(darray_in[175:160]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_5_s4), 
	.l_huffman_code(l_huffman_code_5_s4),
	.l_extra_len(l_extra_len_5_s4), 
	.l_extra(l_extra_5_s4), 
	.d_huffman_len(d_huffman_len_5_s4), 
	.d_huffman_code(d_huffman_code_5_s4),
	.d_extra_len(d_extra_len_5_s4), 
	.d_extra(d_extra_5_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_6_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[79:72]), 
	.d_V(darray_in[159:144]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_6_s4), 
	.l_huffman_code(l_huffman_code_6_s4),
	.l_extra_len(l_extra_len_6_s4), 
	.l_extra(l_extra_6_s4), 
	.d_huffman_len(d_huffman_len_6_s4), 
	.d_huffman_code(d_huffman_code_6_s4),
	.d_extra_len(d_extra_len_6_s4), 
	.d_extra(d_extra_6_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_7_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[71:64]), 
	.d_V(darray_in[143:128]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_7_s4), 
	.l_huffman_code(l_huffman_code_7_s4),
	.l_extra_len(l_extra_len_7_s4), 
	.l_extra(l_extra_7_s4), 
	.d_huffman_len(d_huffman_len_7_s4), 
	.d_huffman_code(d_huffman_code_7_s4),
	.d_extra_len(d_extra_len_7_s4), 
	.d_extra(d_extra_7_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_8_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[63:56]), 
	.d_V(darray_in[127:112]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_8_s4), 
	.l_huffman_code(l_huffman_code_8_s4),
	.l_extra_len(l_extra_len_8_s4), 
	.l_extra(l_extra_8_s4), 
	.d_huffman_len(d_huffman_len_8_s4), 
	.d_huffman_code(d_huffman_code_8_s4),
	.d_extra_len(d_extra_len_8_s4), 
	.d_extra(d_extra_8_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_9_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[55:48]), 
	.d_V(darray_in[111:96]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_9_s4), 
	.l_huffman_code(l_huffman_code_9_s4),
	.l_extra_len(l_extra_len_9_s4), 
	.l_extra(l_extra_9_s4), 
	.d_huffman_len(d_huffman_len_9_s4), 
	.d_huffman_code(d_huffman_code_9_s4),
	.d_extra_len(d_extra_len_9_s4), 
	.d_extra(d_extra_9_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_10_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[47:40]), 
	.d_V(darray_in[95:80]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_10_s4), 
	.l_huffman_code(l_huffman_code_10_s4),
	.l_extra_len(l_extra_len_10_s4), 
	.l_extra(l_extra_10_s4), 
	.d_huffman_len(d_huffman_len_10_s4), 
	.d_huffman_code(d_huffman_code_10_s4),
	.d_extra_len(d_extra_len_10_s4), 
	.d_extra(d_extra_10_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_11_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[39:32]), 
	.d_V(darray_in[79:64]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_11_s4), 
	.l_huffman_code(l_huffman_code_11_s4),
	.l_extra_len(l_extra_len_11_s4), 
	.l_extra(l_extra_11_s4), 
	.d_huffman_len(d_huffman_len_11_s4), 
	.d_huffman_code(d_huffman_code_11_s4),
	.d_extra_len(d_extra_len_11_s4), 
	.d_extra(d_extra_11_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_12_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[31:24]), 
	.d_V(darray_in[63:48]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_12_s4), 
	.l_huffman_code(l_huffman_code_12_s4),
	.l_extra_len(l_extra_len_12_s4), 
	.l_extra(l_extra_12_s4), 
	.d_huffman_len(d_huffman_len_12_s4), 
	.d_huffman_code(d_huffman_code_12_s4),
	.d_extra_len(d_extra_len_12_s4), 
	.d_extra(d_extra_12_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_13_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[23:16]), 
	.d_V(darray_in[47:32]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_13_s4), 
	.l_huffman_code(l_huffman_code_13_s4),
	.l_extra_len(l_extra_len_13_s4), 
	.l_extra(l_extra_13_s4), 
	.d_huffman_len(d_huffman_len_13_s4), 
	.d_huffman_code(d_huffman_code_13_s4),
	.d_extra_len(d_extra_len_13_s4), 
	.d_extra(d_extra_13_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_14_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[15:8]), 
	.d_V(darray_in[31:16]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_14_s4), 
	.l_huffman_code(l_huffman_code_14_s4),
	.l_extra_len(l_extra_len_14_s4), 
	.l_extra(l_extra_14_s4), 
	.d_huffman_len(d_huffman_len_14_s4), 
	.d_huffman_code(d_huffman_code_14_s4),
	.d_extra_len(d_extra_len_14_s4), 
	.d_extra(d_extra_14_s4), 
	.output_ready()
);

huffman_translation 	huffma_translation_15_U(
	.clk(clk), 
	.reset(reset), 
	.l_V(larray_in[7:0]), 
	.d_V(darray_in[15:0]), 
	.enable(en), 
	.l_huffman_len(l_huffman_len_15_s4), 
	.l_huffman_code(l_huffman_code_15_s4),
	.l_extra_len(l_extra_len_15_s4), 
	.l_extra(l_extra_15_s4), 
	.d_huffman_len(d_huffman_len_15_s4), 
	.d_huffman_code(d_huffman_code_15_s4),
	.d_extra_len(d_extra_len_15_s4), 
	.d_extra(d_extra_15_s4), 
	.output_ready()
);


register_compression_reset #(.N(16)) register_valid_s1_U(.d(valid_in), .clk(clk), .reset(reset), .q(valid_s1));
register_compression_reset #(.N(16)) register_valid_s2_U(.d(valid_s1), .clk(clk), .reset(reset), .q(valid_s2));
register_compression_reset #(.N(16)) register_valid_s3_U(.d(valid_s2), .clk(clk), .reset(reset), .q(valid_s3));


register_compression_reset #(.N(1))	register_start_s1_U(.d(start), .clk(clk), .reset(reset), .q(start_s1));
register_compression_reset #(.N(1))	register_start_s2_U(.d(start_s1), .clk(clk), .reset(reset), .q(start_s2));
register_compression_reset #(.N(1))	register_start_s3_U(.d(start_s2), .clk(clk), .reset(reset), .q(start_s3));

register_compression_reset #(.N(1))	register_last_s1_U(.d(last), .clk(clk), .reset(reset), .q(last_s1));
register_compression_reset #(.N(1))	register_last_s2_U(.d(last_s1), .clk(clk), .reset(reset), .q(last_s2));
register_compression_reset #(.N(1))	register_last_s3_U(.d(last_s2), .clk(clk), .reset(reset), .q(last_s3));


// stage 4 port

wire 	[31:0]	l_d_packer_out_0_opt0;
wire 	[31:0]	l_d_packer_out_0_opt1;

wire 	[31:0]	l_d_packer_out_0;
wire 	[31:0]	l_d_packer_out_1;
wire 	[31:0]	l_d_packer_out_2;
wire 	[31:0]	l_d_packer_out_3;
wire 	[31:0]	l_d_packer_out_4;
wire 	[31:0]	l_d_packer_out_5;
wire 	[31:0]	l_d_packer_out_6;
wire 	[31:0]	l_d_packer_out_7;
wire 	[31:0]	l_d_packer_out_8;
wire 	[31:0]	l_d_packer_out_9;
wire 	[31:0]	l_d_packer_out_10;
wire 	[31:0]	l_d_packer_out_11;
wire 	[31:0]	l_d_packer_out_12;
wire 	[31:0]	l_d_packer_out_13;
wire 	[31:0]	l_d_packer_out_14;
wire 	[31:0]	l_d_packer_out_15;


wire 	[31:0]	reg_l_d_packer_out_0_s4;
wire 	[31:0]	reg_l_d_packer_out_1_s4;
wire 	[31:0]	reg_l_d_packer_out_2_s4;
wire 	[31:0]	reg_l_d_packer_out_3_s4;
wire 	[31:0]	reg_l_d_packer_out_4_s4;
wire 	[31:0]	reg_l_d_packer_out_5_s4;
wire 	[31:0]	reg_l_d_packer_out_6_s4;
wire 	[31:0]	reg_l_d_packer_out_7_s4;
wire 	[31:0]	reg_l_d_packer_out_8_s4;
wire 	[31:0]	reg_l_d_packer_out_9_s4;
wire 	[31:0]	reg_l_d_packer_out_10_s4;
wire 	[31:0]	reg_l_d_packer_out_11_s4;
wire 	[31:0]	reg_l_d_packer_out_12_s4;
wire 	[31:0]	reg_l_d_packer_out_13_s4;
wire 	[31:0]	reg_l_d_packer_out_14_s4;
wire 	[31:0]	reg_l_d_packer_out_15_s4;


wire 	[3:0] 	l_huffman_len0;	// range: 8-13
wire 	[3:0] 	l_huffman_len1;
wire 	[3:0] 	l_huffman_len2;
wire 	[3:0] 	l_huffman_len3;
wire 	[3:0] 	l_huffman_len4;
wire 	[3:0] 	l_huffman_len5;
wire 	[3:0] 	l_huffman_len6;
wire 	[3:0] 	l_huffman_len7;
wire 	[3:0] 	l_huffman_len8;
wire 	[3:0] 	l_huffman_len9;
wire 	[3:0] 	l_huffman_len10;
wire 	[3:0] 	l_huffman_len11;
wire 	[3:0] 	l_huffman_len12;
wire 	[3:0] 	l_huffman_len13;
wire 	[3:0] 	l_huffman_len14;
wire 	[3:0] 	l_huffman_len15;


wire 	[4:0]   d_huffman_len0;	// range: 5-18
wire 	[4:0]   d_huffman_len1;
wire 	[4:0]   d_huffman_len2;
wire 	[4:0]   d_huffman_len3;
wire 	[4:0]   d_huffman_len4;
wire 	[4:0]   d_huffman_len5;
wire 	[4:0]   d_huffman_len6;
wire 	[4:0]   d_huffman_len7;
wire 	[4:0]   d_huffman_len8;
wire 	[4:0]   d_huffman_len9;
wire 	[4:0]   d_huffman_len10;
wire 	[4:0]   d_huffman_len11;
wire 	[4:0]   d_huffman_len12;
wire 	[4:0]   d_huffman_len13;
wire 	[4:0]   d_huffman_len14;
wire 	[4:0]   d_huffman_len15;


wire 	[4:0] 	total_len_0_op;	// range: 13-31
wire 	[4:0] 	total_len_1_op;
wire 	[4:0] 	total_len_2_op;
wire 	[4:0] 	total_len_3_op;
wire 	[4:0] 	total_len_4_op;
wire 	[4:0] 	total_len_5_op;
wire 	[4:0] 	total_len_6_op;
wire 	[4:0] 	total_len_7_op;
wire 	[4:0] 	total_len_8_op;	
wire 	[4:0] 	total_len_9_op;
wire 	[4:0] 	total_len_10_op;
wire 	[4:0] 	total_len_11_op;
wire 	[4:0] 	total_len_12_op;
wire 	[4:0] 	total_len_13_op;
wire 	[4:0] 	total_len_14_op;
wire 	[4:0] 	total_len_15_op;


wire 	[4:0] 	total_len_0;
wire 	[4:0] 	total_len_1;
wire 	[4:0] 	total_len_2;
wire 	[4:0] 	total_len_3;
wire 	[4:0] 	total_len_4;
wire 	[4:0] 	total_len_5;
wire 	[4:0] 	total_len_6;
wire 	[4:0] 	total_len_7;
wire 	[4:0] 	total_len_8;
wire 	[4:0] 	total_len_9;
wire 	[4:0] 	total_len_10;
wire 	[4:0] 	total_len_11;
wire 	[4:0] 	total_len_12;
wire 	[4:0] 	total_len_13;
wire 	[4:0] 	total_len_14;
wire 	[4:0] 	total_len_15;


wire 	[4:0] 	total_len_0_s4;
wire 	[4:0] 	total_len_1_s4;
wire 	[4:0] 	total_len_2_s4;
wire 	[4:0] 	total_len_3_s4;
wire 	[4:0] 	total_len_4_s4;
wire 	[4:0] 	total_len_5_s4;
wire 	[4:0] 	total_len_6_s4;
wire 	[4:0] 	total_len_7_s4;
wire 	[4:0] 	total_len_8_s4;
wire 	[4:0] 	total_len_9_s4;
wire 	[4:0] 	total_len_10_s4;
wire 	[4:0] 	total_len_11_s4;
wire 	[4:0] 	total_len_12_s4;
wire 	[4:0] 	total_len_13_s4;
wire 	[4:0] 	total_len_14_s4;
wire 	[4:0] 	total_len_15_s4;


wire 			ready_s4;
wire 			last_s4;

// stage 4
// calculate length
// length of l_code
assign l_huffman_len0 = l_huffman_len_0_s4 + l_extra_len_0_s4;
assign l_huffman_len1 = l_huffman_len_1_s4 + l_extra_len_1_s4;
assign l_huffman_len2 = l_huffman_len_2_s4 + l_extra_len_2_s4;
assign l_huffman_len3 = l_huffman_len_3_s4 + l_extra_len_3_s4;
assign l_huffman_len4 = l_huffman_len_4_s4 + l_extra_len_4_s4;
assign l_huffman_len5 = l_huffman_len_5_s4 + l_extra_len_5_s4;
assign l_huffman_len6 = l_huffman_len_6_s4 + l_extra_len_6_s4;
assign l_huffman_len7 = l_huffman_len_7_s4 + l_extra_len_7_s4;
assign l_huffman_len8 = l_huffman_len_8_s4 + l_extra_len_8_s4;
assign l_huffman_len9 = l_huffman_len_9_s4 + l_extra_len_9_s4;
assign l_huffman_len10 = l_huffman_len_10_s4 + l_extra_len_10_s4;
assign l_huffman_len11 = l_huffman_len_11_s4 + l_extra_len_11_s4;
assign l_huffman_len12 = l_huffman_len_12_s4 + l_extra_len_12_s4;
assign l_huffman_len13 = l_huffman_len_13_s4 + l_extra_len_13_s4;
assign l_huffman_len14 = l_huffman_len_14_s4 + l_extra_len_14_s4;
assign l_huffman_len15 = l_huffman_len_15_s4 + l_extra_len_15_s4;

// length of d_code
assign d_huffman_len0 = d_extra_len_0_s4 + d_huffman_len_0_s4;
assign d_huffman_len1 = d_extra_len_1_s4 + d_huffman_len_1_s4;
assign d_huffman_len2 = d_extra_len_2_s4 + d_huffman_len_2_s4;
assign d_huffman_len3 = d_extra_len_3_s4 + d_huffman_len_3_s4;
assign d_huffman_len4 = d_extra_len_4_s4 + d_huffman_len_4_s4;
assign d_huffman_len5 = d_extra_len_5_s4 + d_huffman_len_5_s4;
assign d_huffman_len6 = d_extra_len_6_s4 + d_huffman_len_6_s4;
assign d_huffman_len7 = d_extra_len_7_s4 + d_huffman_len_7_s4;
assign d_huffman_len8 = d_extra_len_8_s4 + d_huffman_len_8_s4;
assign d_huffman_len9 = d_extra_len_9_s4 + d_huffman_len_9_s4;
assign d_huffman_len10 = d_extra_len_10_s4 + d_huffman_len_10_s4;
assign d_huffman_len11 = d_extra_len_11_s4 + d_huffman_len_11_s4;
assign d_huffman_len12 = d_extra_len_12_s4 + d_huffman_len_12_s4;
assign d_huffman_len13 = d_extra_len_13_s4 + d_huffman_len_13_s4;
assign d_huffman_len14 = d_extra_len_14_s4 + d_huffman_len_14_s4;
assign d_huffman_len15 = d_extra_len_15_s4 + d_huffman_len_15_s4;

assign total_len_0_op = l_huffman_len0 + d_huffman_len0;
assign total_len_1_op = l_huffman_len1 + d_huffman_len1;
assign total_len_2_op = l_huffman_len2 + d_huffman_len2;
assign total_len_3_op = l_huffman_len3 + d_huffman_len3;
assign total_len_4_op = l_huffman_len4 + d_huffman_len4;
assign total_len_5_op = l_huffman_len5 + d_huffman_len5;
assign total_len_6_op = l_huffman_len6 + d_huffman_len6;
assign total_len_7_op = l_huffman_len7 + d_huffman_len7;
assign total_len_8_op = l_huffman_len8 + d_huffman_len8;
assign total_len_9_op = l_huffman_len9 + d_huffman_len9;
assign total_len_10_op = l_huffman_len10 + d_huffman_len10;
assign total_len_11_op = l_huffman_len11 + d_huffman_len11;
assign total_len_12_op = l_huffman_len12 + d_huffman_len12;
assign total_len_13_op = l_huffman_len13 + d_huffman_len13;
assign total_len_14_op = l_huffman_len14 + d_huffman_len14;
assign total_len_15_op = l_huffman_len15 + d_huffman_len15;

assign total_len_0 = start_s3?{5'd11}:((valid_s3[15])?total_len_0_op:{5'd0});
assign total_len_1 = (valid_s3[14])?total_len_1_op:{5'd0};
assign total_len_2 = (valid_s3[13])?total_len_2_op:{5'd0};
assign total_len_3 = (valid_s3[12])?total_len_3_op:{5'd0};
assign total_len_4 = (valid_s3[11])?total_len_4_op:{5'd0};
assign total_len_5 = (valid_s3[10])?total_len_5_op:{5'd0};
assign total_len_6 = (valid_s3[9])?total_len_6_op:{5'd0};
assign total_len_7 = (valid_s3[8])?total_len_7_op:{5'd0};
assign total_len_8 = (valid_s3[7])?total_len_8_op:{5'd0};
assign total_len_9 = (valid_s3[6])?total_len_9_op:{5'd0};
assign total_len_10 = (valid_s3[5])?total_len_10_op:{5'd0};
assign total_len_11 = (valid_s3[4])?total_len_11_op:{5'd0};
assign total_len_12 = (valid_s3[3])?total_len_12_op:{5'd0};
assign total_len_13 = (valid_s3[2])?total_len_13_op:{5'd0};
assign total_len_14 = (valid_s3[1])?total_len_14_op:{5'd0};
assign total_len_15 = (valid_s3[0])?total_len_15_op:{5'd0};


// special case for start
assign l_d_packer_out_0_opt0 = {21'd0, l_huffman_code_0_s4[7:0], 3'b011};

l_d_packer  l_d_packer_0_U(
	.l_code(l_huffman_code_0_s4),
	.l_len(l_huffman_len_0_s4), 
	.l_extra(l_extra_0_s4), 
	.l_extra_len(l_extra_len_0_s4),  
	.d_code(d_huffman_code_0_s4), 
	.d_extra(d_extra_0_s4), 
	.d_extra_len(d_extra_len_0_s4),
	.input_valid(valid_s3[15]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_0_opt1)
	);

assign l_d_packer_out_0 = start_s3 ? l_d_packer_out_0_opt0 : l_d_packer_out_0_opt1;

l_d_packer  l_d_packer_1_U(
	.l_code(l_huffman_code_1_s4),
	.l_len(l_huffman_len_1_s4), 
	.l_extra(l_extra_1_s4), 
	.l_extra_len(l_extra_len_1_s4),  
	.d_code(d_huffman_code_1_s4), 
	.d_extra(d_extra_1_s4), 
	.d_extra_len(d_extra_len_1_s4),
	.input_valid(valid_s3[14]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_1)
	);


l_d_packer  l_d_packer_2_U(
	.l_code(l_huffman_code_2_s4),
	.l_len(l_huffman_len_2_s4), 
	.l_extra(l_extra_2_s4), 
	.l_extra_len(l_extra_len_2_s4),  
	.d_code(d_huffman_code_2_s4), 
	.d_extra(d_extra_2_s4), 
	.d_extra_len(d_extra_len_2_s4),
	.input_valid(valid_s3[13]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_2)
	);


l_d_packer  l_d_packer_3_U(
	.l_code(l_huffman_code_3_s4),
	.l_len(l_huffman_len_3_s4), 
	.l_extra(l_extra_3_s4), 
	.l_extra_len(l_extra_len_3_s4),  
	.d_code(d_huffman_code_3_s4), 
	.d_extra(d_extra_3_s4), 
	.d_extra_len(d_extra_len_3_s4),
	.input_valid(valid_s3[12]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_3)
	);


l_d_packer  l_d_packer_4_U(
	.l_code(l_huffman_code_4_s4),
	.l_len(l_huffman_len_4_s4), 
	.l_extra(l_extra_4_s4), 
	.l_extra_len(l_extra_len_4_s4),  
	.d_code(d_huffman_code_4_s4), 
	.d_extra(d_extra_4_s4), 
	.d_extra_len(d_extra_len_4_s4),
	.input_valid(valid_s3[11]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_4)
	);


l_d_packer  l_d_packer_5_U(
	.l_code(l_huffman_code_5_s4),
	.l_len(l_huffman_len_5_s4), 
	.l_extra(l_extra_5_s4), 
	.l_extra_len(l_extra_len_5_s4),  
	.d_code(d_huffman_code_5_s4), 
	.d_extra(d_extra_5_s4), 
	.d_extra_len(d_extra_len_5_s4),
	.input_valid(valid_s3[10]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_5)
	);


l_d_packer  l_d_packer_6_U(
	.l_code(l_huffman_code_6_s4),
	.l_len(l_huffman_len_6_s4), 
	.l_extra(l_extra_6_s4), 
	.l_extra_len(l_extra_len_6_s4),  
	.d_code(d_huffman_code_6_s4), 
	.d_extra(d_extra_6_s4), 
	.d_extra_len(d_extra_len_6_s4),
	.input_valid(valid_s3[9]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_6)
	);


l_d_packer  l_d_packer_7_U(
	.l_code(l_huffman_code_7_s4),
	.l_len(l_huffman_len_7_s4), 
	.l_extra(l_extra_7_s4), 
	.l_extra_len(l_extra_len_7_s4),  
	.d_code(d_huffman_code_7_s4), 
	.d_extra(d_extra_7_s4), 
	.d_extra_len(d_extra_len_7_s4),
	.input_valid(valid_s3[8]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_7)
	);

l_d_packer  l_d_packer_8_U(
	.l_code(l_huffman_code_8_s4),
	.l_len(l_huffman_len_8_s4), 
	.l_extra(l_extra_8_s4), 
	.l_extra_len(l_extra_len_8_s4),  
	.d_code(d_huffman_code_8_s4), 
	.d_extra(d_extra_8_s4), 
	.d_extra_len(d_extra_len_8_s4),
	.input_valid(valid_s3[7]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_8)
	);


l_d_packer  l_d_packer_9_U(
	.l_code(l_huffman_code_9_s4),
	.l_len(l_huffman_len_9_s4), 
	.l_extra(l_extra_9_s4), 
	.l_extra_len(l_extra_len_9_s4),  
	.d_code(d_huffman_code_9_s4), 
	.d_extra(d_extra_9_s4), 
	.d_extra_len(d_extra_len_9_s4),
	.input_valid(valid_s3[6]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_9)
	);


l_d_packer  l_d_packer_10_U(
	.l_code(l_huffman_code_10_s4),
	.l_len(l_huffman_len_10_s4), 
	.l_extra(l_extra_10_s4), 
	.l_extra_len(l_extra_len_10_s4),  
	.d_code(d_huffman_code_10_s4), 
	.d_extra(d_extra_10_s4), 
	.d_extra_len(d_extra_len_10_s4),
	.input_valid(valid_s3[5]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_10)
	);


l_d_packer  l_d_packer_11_U(
	.l_code(l_huffman_code_11_s4),
	.l_len(l_huffman_len_11_s4), 
	.l_extra(l_extra_11_s4), 
	.l_extra_len(l_extra_len_11_s4),  
	.d_code(d_huffman_code_11_s4), 
	.d_extra(d_extra_11_s4), 
	.d_extra_len(d_extra_len_11_s4),
	.input_valid(valid_s3[4]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_11)
	);


l_d_packer  l_d_packer_12_U(
	.l_code(l_huffman_code_12_s4),
	.l_len(l_huffman_len_12_s4), 
	.l_extra(l_extra_12_s4), 
	.l_extra_len(l_extra_len_12_s4),  
	.d_code(d_huffman_code_12_s4), 
	.d_extra(d_extra_12_s4), 
	.d_extra_len(d_extra_len_12_s4),
	.input_valid(valid_s3[3]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_12)
	);


l_d_packer  l_d_packer_13_U(
	.l_code(l_huffman_code_13_s4),
	.l_len(l_huffman_len_13_s4), 
	.l_extra(l_extra_13_s4), 
	.l_extra_len(l_extra_len_13_s4),  
	.d_code(d_huffman_code_13_s4), 
	.d_extra(d_extra_13_s4), 
	.d_extra_len(d_extra_len_13_s4),
	.input_valid(valid_s3[2]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_13)
	);


l_d_packer  l_d_packer_14_U(
	.l_code(l_huffman_code_14_s4),
	.l_len(l_huffman_len_14_s4), 
	.l_extra(l_extra_14_s4), 
	.l_extra_len(l_extra_len_14_s4),  
	.d_code(d_huffman_code_14_s4), 
	.d_extra(d_extra_14_s4), 
	.d_extra_len(d_extra_len_14_s4),
	.input_valid(valid_s3[1]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_14)
	);


l_d_packer  l_d_packer_15_U(
	.l_code(l_huffman_code_15_s4),
	.l_len(l_huffman_len_15_s4), 
	.l_extra(l_extra_15_s4), 
	.l_extra_len(l_extra_len_15_s4),  
	.d_code(d_huffman_code_15_s4), 
	.d_extra(d_extra_15_s4), 
	.d_extra_len(d_extra_len_15_s4),
	.input_valid(valid_s3[0]), 
	.enable(huffman_translate_ready),  
	.l_d_packer_out(l_d_packer_out_15)
	);


register_compression_reset #(.N(32))  l_d_packer_out_0_U(.d(l_d_packer_out_0), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_0_s4));
register_compression_reset #(.N(32))  l_d_packer_out_1_U(.d(l_d_packer_out_1), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_1_s4));
register_compression_reset #(.N(32))  l_d_packer_out_2_U(.d(l_d_packer_out_2), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_2_s4));
register_compression_reset #(.N(32))  l_d_packer_out_3_U(.d(l_d_packer_out_3), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_3_s4));
register_compression_reset #(.N(32))  l_d_packer_out_4_U(.d(l_d_packer_out_4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_4_s4));
register_compression_reset #(.N(32))  l_d_packer_out_5_U(.d(l_d_packer_out_5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_5_s4));
register_compression_reset #(.N(32))  l_d_packer_out_6_U(.d(l_d_packer_out_6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_6_s4));
register_compression_reset #(.N(32))  l_d_packer_out_7_U(.d(l_d_packer_out_7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_7_s4));
register_compression_reset #(.N(32))  l_d_packer_out_8_U(.d(l_d_packer_out_8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_8_s4));
register_compression_reset #(.N(32))  l_d_packer_out_9_U(.d(l_d_packer_out_9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s4));
register_compression_reset #(.N(32))  l_d_packer_out_10_U(.d(l_d_packer_out_10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s4));
register_compression_reset #(.N(32))  l_d_packer_out_11_U(.d(l_d_packer_out_11), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s4));
register_compression_reset #(.N(32))  l_d_packer_out_12_U(.d(l_d_packer_out_12), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s4));
register_compression_reset #(.N(32))  l_d_packer_out_13_U(.d(l_d_packer_out_13), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s4));
register_compression_reset #(.N(32))  l_d_packer_out_14_U(.d(l_d_packer_out_14), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s4));
register_compression_reset #(.N(32))  l_d_packer_out_15_U(.d(l_d_packer_out_15), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s4));


register_compression_reset #(.N(5))   total_len_0_U(.d(total_len_0), .clk(clk), .reset(reset), .q(total_len_0_s4));
register_compression_reset #(.N(5))   total_len_1_U(.d(total_len_1), .clk(clk), .reset(reset), .q(total_len_1_s4));
register_compression_reset #(.N(5))   total_len_2_U(.d(total_len_2), .clk(clk), .reset(reset), .q(total_len_2_s4));
register_compression_reset #(.N(5))   total_len_3_U(.d(total_len_3), .clk(clk), .reset(reset), .q(total_len_3_s4));
register_compression_reset #(.N(5))   total_len_4_U(.d(total_len_4), .clk(clk), .reset(reset), .q(total_len_4_s4));
register_compression_reset #(.N(5))   total_len_5_U(.d(total_len_5), .clk(clk), .reset(reset), .q(total_len_5_s4));
register_compression_reset #(.N(5))   total_len_6_U(.d(total_len_6), .clk(clk), .reset(reset), .q(total_len_6_s4));
register_compression_reset #(.N(5))   total_len_7_U(.d(total_len_7), .clk(clk), .reset(reset), .q(total_len_7_s4));
register_compression_reset #(.N(5))   total_len_8_U(.d(total_len_8), .clk(clk), .reset(reset), .q(total_len_8_s4));
register_compression_reset #(.N(5))   total_len_9_U(.d(total_len_9), .clk(clk), .reset(reset), .q(total_len_9_s4));
register_compression_reset #(.N(5))   total_len_10_U(.d(total_len_10), .clk(clk), .reset(reset), .q(total_len_10_s4));
register_compression_reset #(.N(5))   total_len_11_U(.d(total_len_11), .clk(clk), .reset(reset), .q(total_len_11_s4));
register_compression_reset #(.N(5))   total_len_12_U(.d(total_len_12), .clk(clk), .reset(reset), .q(total_len_12_s4));
register_compression_reset #(.N(5))   total_len_13_U(.d(total_len_13), .clk(clk), .reset(reset), .q(total_len_13_s4));
register_compression_reset #(.N(5))   total_len_14_U(.d(total_len_14), .clk(clk), .reset(reset), .q(total_len_14_s4));
register_compression_reset #(.N(5))   total_len_15_U(.d(total_len_15), .clk(clk), .reset(reset), .q(total_len_15_s4));

register_compression_reset #(.N(1))   ready_s4_U(.d(huffman_translate_ready), .clk(clk), .reset(reset), .q(ready_s4));
register_compression_reset #(.N(1))   last_s4_U(.d(last_s3), .clk(clk), .reset(reset), .q(last_s4));


// stage 5 port
wire 	[5:0] 	current_len_s5;
wire 			data_full_s5;
wire 	[31:0] 	data_to_write_s5;
wire 	[63:0]	data_out_s5;

wire 		ready_s5;
wire 		last_s5;

wire 	[31:0]	reg_l_d_packer_out_1_s5;
wire 	[31:0]	reg_l_d_packer_out_2_s5;
wire 	[31:0]	reg_l_d_packer_out_3_s5;
wire 	[31:0]	reg_l_d_packer_out_4_s5;
wire 	[31:0]	reg_l_d_packer_out_5_s5;
wire 	[31:0]	reg_l_d_packer_out_6_s5;
wire 	[31:0]	reg_l_d_packer_out_7_s5;
wire 	[31:0]	reg_l_d_packer_out_8_s5;
wire 	[31:0]	reg_l_d_packer_out_9_s5;
wire 	[31:0]	reg_l_d_packer_out_10_s5;
wire 	[31:0]	reg_l_d_packer_out_11_s5;
wire 	[31:0]	reg_l_d_packer_out_12_s5;
wire 	[31:0]	reg_l_d_packer_out_13_s5;
wire 	[31:0]	reg_l_d_packer_out_14_s5;
wire 	[31:0]	reg_l_d_packer_out_15_s5;

wire 	[4:0] 	total_len_1_s5;
wire 	[4:0] 	total_len_2_s5;
wire 	[4:0] 	total_len_3_s5;
wire 	[4:0] 	total_len_4_s5;
wire 	[4:0] 	total_len_5_s5;
wire 	[4:0] 	total_len_6_s5;
wire 	[4:0] 	total_len_7_s5;
wire 	[4:0] 	total_len_8_s5;
wire 	[4:0] 	total_len_9_s5;
wire 	[4:0] 	total_len_10_s5;
wire 	[4:0] 	total_len_11_s5;
wire 	[4:0] 	total_len_12_s5;
wire 	[4:0] 	total_len_13_s5;
wire 	[4:0] 	total_len_14_s5;
wire 	[4:0] 	total_len_15_s5;


// stage 5 
// pack l_d_1

barrel_shifter_64bits 	barrel_shifter_64bits_s5(
	.clk(clk), 
	.reset(reset), 
	.pre_data(64'd0), 
	.pre_len(6'd0), 
	.data_in(reg_l_d_packer_out_0_s4), 
	.len_in(total_len_0_s4), 
	.enable(ready_s4), 
	.current_len(current_len_s5), 
	.data_full(data_full_s5), 
	.data_to_write(data_to_write_s5), 
	.data_out(data_out_s5)
);

register_compression_reset #(.N(1))   ready_s5_U(.d(ready_s4), .clk(clk), .reset(reset), .q(ready_s5));

register_compression_reset #(.N(1))   last_s5_U(.d(last_s4), .clk(clk), .reset(reset), .q(last_s5));

register_compression_reset #(.N(32))  l_d_packer_out_1_s5(.d(reg_l_d_packer_out_1_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_1_s5));
register_compression_reset #(.N(32))  l_d_packer_out_2_s5(.d(reg_l_d_packer_out_2_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_2_s5));
register_compression_reset #(.N(32))  l_d_packer_out_3_s5(.d(reg_l_d_packer_out_3_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_3_s5));
register_compression_reset #(.N(32))  l_d_packer_out_4_s5(.d(reg_l_d_packer_out_4_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_4_s5));
register_compression_reset #(.N(32))  l_d_packer_out_5_s5(.d(reg_l_d_packer_out_5_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_5_s5));
register_compression_reset #(.N(32))  l_d_packer_out_6_s5(.d(reg_l_d_packer_out_6_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_6_s5));
register_compression_reset #(.N(32))  l_d_packer_out_7_s5(.d(reg_l_d_packer_out_7_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_7_s5));
register_compression_reset #(.N(32))  l_d_packer_out_8_s5(.d(reg_l_d_packer_out_8_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_8_s5));
register_compression_reset #(.N(32))  l_d_packer_out_9_s5(.d(reg_l_d_packer_out_9_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s5));
register_compression_reset #(.N(32))  l_d_packer_out_10_s5(.d(reg_l_d_packer_out_10_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s5));
register_compression_reset #(.N(32))  l_d_packer_out_11_s5(.d(reg_l_d_packer_out_11_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s5));
register_compression_reset #(.N(32))  l_d_packer_out_12_s5(.d(reg_l_d_packer_out_12_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s5));
register_compression_reset #(.N(32))  l_d_packer_out_13_s5(.d(reg_l_d_packer_out_13_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s5));
register_compression_reset #(.N(32))  l_d_packer_out_14_s5(.d(reg_l_d_packer_out_14_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s5));
register_compression_reset #(.N(32))  l_d_packer_out_15_s5(.d(reg_l_d_packer_out_15_s4), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s5));

register_compression_reset #(.N(5))   total_len_1_s5_U(.d(total_len_1_s4), .clk(clk), .reset(reset), .q(total_len_1_s5));
register_compression_reset #(.N(5))   total_len_2_s5_U(.d(total_len_2_s4), .clk(clk), .reset(reset), .q(total_len_2_s5));
register_compression_reset #(.N(5))   total_len_3_s5_U(.d(total_len_3_s4), .clk(clk), .reset(reset), .q(total_len_3_s5));
register_compression_reset #(.N(5))   total_len_4_s5_U(.d(total_len_4_s4), .clk(clk), .reset(reset), .q(total_len_4_s5));
register_compression_reset #(.N(5))   total_len_5_s5_U(.d(total_len_5_s4), .clk(clk), .reset(reset), .q(total_len_5_s5));
register_compression_reset #(.N(5))   total_len_6_s5_U(.d(total_len_6_s4), .clk(clk), .reset(reset), .q(total_len_6_s5));
register_compression_reset #(.N(5))   total_len_7_s5_U(.d(total_len_7_s4), .clk(clk), .reset(reset), .q(total_len_7_s5));
register_compression_reset #(.N(5))   total_len_8_s5_U(.d(total_len_8_s4), .clk(clk), .reset(reset), .q(total_len_8_s5));
register_compression_reset #(.N(5))   total_len_9_s5_U(.d(total_len_9_s4), .clk(clk), .reset(reset), .q(total_len_9_s5));
register_compression_reset #(.N(5))   total_len_10_s5_U(.d(total_len_10_s4), .clk(clk), .reset(reset), .q(total_len_10_s5));
register_compression_reset #(.N(5))   total_len_11_s5_U(.d(total_len_11_s4), .clk(clk), .reset(reset), .q(total_len_11_s5));
register_compression_reset #(.N(5))   total_len_12_s5_U(.d(total_len_12_s4), .clk(clk), .reset(reset), .q(total_len_12_s5));
register_compression_reset #(.N(5))   total_len_13_s5_U(.d(total_len_13_s4), .clk(clk), .reset(reset), .q(total_len_13_s5));
register_compression_reset #(.N(5))   total_len_14_s5_U(.d(total_len_14_s4), .clk(clk), .reset(reset), .q(total_len_14_s5));
register_compression_reset #(.N(5))   total_len_15_s5_U(.d(total_len_15_s4), .clk(clk), .reset(reset), .q(total_len_15_s5));


// stage 6 port
wire 	[127:0] 		data_buffer_s6; 	

wire 	[5:0] 	current_len_s6;
wire 			data_full_s6;
wire 	[31:0] 	data_to_write_s6;
wire 	[63:0]	data_out_s6;
wire 	[7:0]	data_len_s6;

wire 			ready_s6;

wire 			last_s6;

wire 	[31:0]	reg_l_d_packer_out_2_s6;
wire 	[31:0]	reg_l_d_packer_out_3_s6;
wire 	[31:0]	reg_l_d_packer_out_4_s6;
wire 	[31:0]	reg_l_d_packer_out_5_s6;
wire 	[31:0]	reg_l_d_packer_out_6_s6;
wire 	[31:0]	reg_l_d_packer_out_7_s6;
wire 	[31:0]	reg_l_d_packer_out_8_s6;
wire 	[31:0]	reg_l_d_packer_out_9_s6;
wire 	[31:0]	reg_l_d_packer_out_10_s6;
wire 	[31:0]	reg_l_d_packer_out_11_s6;
wire 	[31:0]	reg_l_d_packer_out_12_s6;
wire 	[31:0]	reg_l_d_packer_out_13_s6;
wire 	[31:0]	reg_l_d_packer_out_14_s6;
wire 	[31:0]	reg_l_d_packer_out_15_s6;

wire 	[4:0] 	total_len_2_s6;
wire 	[4:0] 	total_len_3_s6;
wire 	[4:0] 	total_len_4_s6;
wire 	[4:0] 	total_len_5_s6;
wire 	[4:0] 	total_len_6_s6;
wire 	[4:0] 	total_len_7_s6;
wire 	[4:0] 	total_len_8_s6;
wire 	[4:0] 	total_len_9_s6;
wire 	[4:0] 	total_len_10_s6;
wire 	[4:0] 	total_len_11_s6;
wire 	[4:0] 	total_len_12_s6;
wire 	[4:0] 	total_len_13_s6;
wire 	[4:0] 	total_len_14_s6;
wire 	[4:0] 	total_len_15_s6;


// stage 6

// store pack_0 result if it is full
shift_reg_128bits 	shift_reg_128bits_s6(
	.clk(clk), 
	.reset(reset), 
	.prev_data(128'd0), 
	.data_in(data_to_write_s5), 
	.enable(data_full_s5), 
	.data_out(data_buffer_s6), 
	.prev_len(8'd0), 
	.len_in(6'd32), 
	.data_len(data_len_s6)
);

// pack l_d_1
barrel_shifter_64bits 	barrel_shifter_64bits_s6(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s5), 
	.pre_len(current_len_s5), 
	.data_in(reg_l_d_packer_out_1_s5), 
	.len_in(total_len_1_s5), 
	.enable(ready_s5), 
	.current_len(current_len_s6), 
	.data_full(data_full_s6), 
	.data_to_write(data_to_write_s6), 
	.data_out(data_out_s6)
);

register_compression_reset #(.N(1))   ready_s6_U(.d(ready_s5), .clk(clk), .reset(reset), .q(ready_s6));

register_compression_reset #(.N(1))   last_s6_U(.d(last_s5), .clk(clk), .reset(reset), .q(last_s6));

register_compression_reset #(.N(32))  l_d_packer_out_2_s6(.d(reg_l_d_packer_out_2_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_2_s6));
register_compression_reset #(.N(32))  l_d_packer_out_3_s6(.d(reg_l_d_packer_out_3_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_3_s6));
register_compression_reset #(.N(32))  l_d_packer_out_4_s6(.d(reg_l_d_packer_out_4_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_4_s6));
register_compression_reset #(.N(32))  l_d_packer_out_5_s6(.d(reg_l_d_packer_out_5_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_5_s6));
register_compression_reset #(.N(32))  l_d_packer_out_6_s6(.d(reg_l_d_packer_out_6_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_6_s6));
register_compression_reset #(.N(32))  l_d_packer_out_7_s6(.d(reg_l_d_packer_out_7_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_7_s6));
register_compression_reset #(.N(32))  l_d_packer_out_8_s6(.d(reg_l_d_packer_out_8_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_8_s6));
register_compression_reset #(.N(32))  l_d_packer_out_9_s6(.d(reg_l_d_packer_out_9_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s6));
register_compression_reset #(.N(32))  l_d_packer_out_10_s6(.d(reg_l_d_packer_out_10_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s6));
register_compression_reset #(.N(32))  l_d_packer_out_11_s6(.d(reg_l_d_packer_out_11_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s6));
register_compression_reset #(.N(32))  l_d_packer_out_12_s6(.d(reg_l_d_packer_out_12_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s6));
register_compression_reset #(.N(32))  l_d_packer_out_13_s6(.d(reg_l_d_packer_out_13_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s6));
register_compression_reset #(.N(32))  l_d_packer_out_14_s6(.d(reg_l_d_packer_out_14_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s6));
register_compression_reset #(.N(32))  l_d_packer_out_15_s6(.d(reg_l_d_packer_out_15_s5), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s6));

register_compression_reset #(.N(5))   total_len_2_s6_U(.d(total_len_2_s5), .clk(clk), .reset(reset), .q(total_len_2_s6));
register_compression_reset #(.N(5))   total_len_3_s6_U(.d(total_len_3_s5), .clk(clk), .reset(reset), .q(total_len_3_s6));
register_compression_reset #(.N(5))   total_len_4_s6_U(.d(total_len_4_s5), .clk(clk), .reset(reset), .q(total_len_4_s6));
register_compression_reset #(.N(5))   total_len_5_s6_U(.d(total_len_5_s5), .clk(clk), .reset(reset), .q(total_len_5_s6));
register_compression_reset #(.N(5))   total_len_6_s6_U(.d(total_len_6_s5), .clk(clk), .reset(reset), .q(total_len_6_s6));
register_compression_reset #(.N(5))   total_len_7_s6_U(.d(total_len_7_s5), .clk(clk), .reset(reset), .q(total_len_7_s6));
register_compression_reset #(.N(5))   total_len_8_s6_U(.d(total_len_8_s5), .clk(clk), .reset(reset), .q(total_len_8_s6));
register_compression_reset #(.N(5))   total_len_9_s6_U(.d(total_len_9_s5), .clk(clk), .reset(reset), .q(total_len_9_s6));
register_compression_reset #(.N(5))   total_len_10_s6_U(.d(total_len_10_s5), .clk(clk), .reset(reset), .q(total_len_10_s6));
register_compression_reset #(.N(5))   total_len_11_s6_U(.d(total_len_11_s5), .clk(clk), .reset(reset), .q(total_len_11_s6));
register_compression_reset #(.N(5))   total_len_12_s6_U(.d(total_len_12_s5), .clk(clk), .reset(reset), .q(total_len_12_s6));
register_compression_reset #(.N(5))   total_len_13_s6_U(.d(total_len_13_s5), .clk(clk), .reset(reset), .q(total_len_13_s6));
register_compression_reset #(.N(5))   total_len_14_s6_U(.d(total_len_14_s5), .clk(clk), .reset(reset), .q(total_len_14_s6));
register_compression_reset #(.N(5))   total_len_15_s6_U(.d(total_len_15_s5), .clk(clk), .reset(reset), .q(total_len_15_s6));



// stage 7 port
wire 	[127:0] 		data_buffer_s7; 	

wire 	[5:0] 	current_len_s7;
wire 			data_full_s7;
wire 	[31:0] 	data_to_write_s7;
wire 	[63:0]	data_out_s7;
wire 	[7:0]	data_len_s7;

wire 			ready_s7;

wire 			last_s7;

wire 	[31:0]	reg_l_d_packer_out_3_s7;
wire 	[31:0]	reg_l_d_packer_out_4_s7;
wire 	[31:0]	reg_l_d_packer_out_5_s7;
wire 	[31:0]	reg_l_d_packer_out_6_s7;
wire 	[31:0]	reg_l_d_packer_out_7_s7;
wire 	[31:0]	reg_l_d_packer_out_8_s7;
wire 	[31:0]	reg_l_d_packer_out_9_s7;
wire 	[31:0]	reg_l_d_packer_out_10_s7;
wire 	[31:0]	reg_l_d_packer_out_11_s7;
wire 	[31:0]	reg_l_d_packer_out_12_s7;
wire 	[31:0]	reg_l_d_packer_out_13_s7;
wire 	[31:0]	reg_l_d_packer_out_14_s7;
wire 	[31:0]	reg_l_d_packer_out_15_s7;


wire 	[4:0] 	total_len_3_s7;
wire 	[4:0] 	total_len_4_s7;
wire 	[4:0] 	total_len_5_s7;
wire 	[4:0] 	total_len_6_s7;
wire 	[4:0] 	total_len_7_s7;
wire 	[4:0] 	total_len_8_s7;
wire 	[4:0] 	total_len_9_s7;
wire 	[4:0] 	total_len_10_s7;
wire 	[4:0] 	total_len_11_s7;
wire 	[4:0] 	total_len_12_s7;
wire 	[4:0] 	total_len_13_s7;
wire 	[4:0] 	total_len_14_s7;
wire 	[4:0] 	total_len_15_s7;


// stage 7

//data_buffer_s7 store the l_d_packer_1 if full
shift_reg_128bits 	shift_reg_128bits_s7(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s6), 
	.data_in(data_to_write_s6), 
	.enable(data_full_s6), 
	.data_out(data_buffer_s7), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s6), 
	.len_in(6'd32), 
	.data_len(data_len_s7)
);

// pack l_d_2
barrel_shifter_64bits 	barrel_shifter_64bits_s7(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s6), 
	.pre_len(current_len_s6), 
	.data_in(reg_l_d_packer_out_2_s6), 
	.len_in(total_len_2_s6), 
	.enable(ready_s6), 
	.current_len(current_len_s7), 
	.data_full(data_full_s7), 
	.data_to_write(data_to_write_s7), 
	.data_out(data_out_s7)
);

register_compression_reset #(.N(1))   ready_s7_U(.d(ready_s6), .clk(clk), .reset(reset), .q(ready_s7));

register_compression_reset #(.N(1))   last_s7_U(.d(last_s6), .clk(clk), .reset(reset), .q(last_s7));

register_compression_reset #(.N(32))  l_d_packer_out_3_s7(.d(reg_l_d_packer_out_3_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_3_s7));
register_compression_reset #(.N(32))  l_d_packer_out_4_s7(.d(reg_l_d_packer_out_4_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_4_s7));
register_compression_reset #(.N(32))  l_d_packer_out_5_s7(.d(reg_l_d_packer_out_5_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_5_s7));
register_compression_reset #(.N(32))  l_d_packer_out_6_s7(.d(reg_l_d_packer_out_6_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_6_s7));
register_compression_reset #(.N(32))  l_d_packer_out_7_s7(.d(reg_l_d_packer_out_7_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_7_s7));
register_compression_reset #(.N(32))  l_d_packer_out_8_s7(.d(reg_l_d_packer_out_8_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_8_s7));
register_compression_reset #(.N(32))  l_d_packer_out_9_s7(.d(reg_l_d_packer_out_9_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s7));
register_compression_reset #(.N(32))  l_d_packer_out_10_s7(.d(reg_l_d_packer_out_10_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s7));
register_compression_reset #(.N(32))  l_d_packer_out_11_s7(.d(reg_l_d_packer_out_11_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s7));
register_compression_reset #(.N(32))  l_d_packer_out_12_s7(.d(reg_l_d_packer_out_12_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s7));
register_compression_reset #(.N(32))  l_d_packer_out_13_s7(.d(reg_l_d_packer_out_13_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s7));
register_compression_reset #(.N(32))  l_d_packer_out_14_s7(.d(reg_l_d_packer_out_14_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s7));
register_compression_reset #(.N(32))  l_d_packer_out_15_s7(.d(reg_l_d_packer_out_15_s6), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s7));

register_compression_reset #(.N(5))   total_len_3_s7_U(.d(total_len_3_s6), .clk(clk), .reset(reset), .q(total_len_3_s7));
register_compression_reset #(.N(5))   total_len_4_s7_U(.d(total_len_4_s6), .clk(clk), .reset(reset), .q(total_len_4_s7));
register_compression_reset #(.N(5))   total_len_5_s7_U(.d(total_len_5_s6), .clk(clk), .reset(reset), .q(total_len_5_s7));
register_compression_reset #(.N(5))   total_len_6_s7_U(.d(total_len_6_s6), .clk(clk), .reset(reset), .q(total_len_6_s7));
register_compression_reset #(.N(5))   total_len_7_s7_U(.d(total_len_7_s6), .clk(clk), .reset(reset), .q(total_len_7_s7));
register_compression_reset #(.N(5))   total_len_8_s7_U(.d(total_len_8_s6), .clk(clk), .reset(reset), .q(total_len_8_s7));
register_compression_reset #(.N(5))   total_len_9_s7_U(.d(total_len_9_s6), .clk(clk), .reset(reset), .q(total_len_9_s7));
register_compression_reset #(.N(5))   total_len_10_s7_U(.d(total_len_10_s6), .clk(clk), .reset(reset), .q(total_len_10_s7));
register_compression_reset #(.N(5))   total_len_11_s7_U(.d(total_len_11_s6), .clk(clk), .reset(reset), .q(total_len_11_s7));
register_compression_reset #(.N(5))   total_len_12_s7_U(.d(total_len_12_s6), .clk(clk), .reset(reset), .q(total_len_12_s7));
register_compression_reset #(.N(5))   total_len_13_s7_U(.d(total_len_13_s6), .clk(clk), .reset(reset), .q(total_len_13_s7));
register_compression_reset #(.N(5))   total_len_14_s7_U(.d(total_len_14_s6), .clk(clk), .reset(reset), .q(total_len_14_s7));
register_compression_reset #(.N(5))   total_len_15_s7_U(.d(total_len_15_s6), .clk(clk), .reset(reset), .q(total_len_15_s7));




// stage 8 port
wire 	[127:0] 		data_buffer_s8; 

wire 	[5:0] 	current_len_s8;
wire 			data_full_s8;
wire 	[31:0] 	data_to_write_s8;
wire 	[63:0]	data_out_s8;
wire 	[7:0]	data_len_s8;

wire 			ready_s8;

wire 			last_s8;

wire 	[31:0]	reg_l_d_packer_out_4_s8;
wire 	[31:0]	reg_l_d_packer_out_5_s8;
wire 	[31:0]	reg_l_d_packer_out_6_s8;
wire 	[31:0]	reg_l_d_packer_out_7_s8;
wire 	[31:0]	reg_l_d_packer_out_8_s8;
wire 	[31:0]	reg_l_d_packer_out_9_s8;
wire 	[31:0]	reg_l_d_packer_out_10_s8;
wire 	[31:0]	reg_l_d_packer_out_11_s8;
wire 	[31:0]	reg_l_d_packer_out_12_s8;
wire 	[31:0]	reg_l_d_packer_out_13_s8;
wire 	[31:0]	reg_l_d_packer_out_14_s8;
wire 	[31:0]	reg_l_d_packer_out_15_s8;

wire 	[4:0] 	total_len_4_s8;
wire 	[4:0] 	total_len_5_s8;
wire 	[4:0] 	total_len_6_s8;
wire 	[4:0] 	total_len_7_s8;
wire 	[4:0] 	total_len_8_s8;
wire 	[4:0] 	total_len_9_s8;
wire 	[4:0] 	total_len_10_s8;
wire 	[4:0] 	total_len_11_s8;
wire 	[4:0] 	total_len_12_s8;
wire 	[4:0] 	total_len_13_s8;
wire 	[4:0] 	total_len_14_s8;
wire 	[4:0] 	total_len_15_s8;


// stage 8

//data_buffer_s8 store the l_d_packer_2 if full
shift_reg_128bits 	shift_reg_128bits_s8(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s7), 
	.data_in(data_to_write_s7), 
	.enable(data_full_s7), 
	.data_out(data_buffer_s8), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s7), 
	.len_in(6'd32), 
	.data_len(data_len_s8)
);

// pack l_d_3
barrel_shifter_64bits 	barrel_shifter_64bits_s8(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s7), 
	.pre_len(current_len_s7), 
	.data_in(reg_l_d_packer_out_3_s7), 
	.len_in(total_len_3_s7), 
	.enable(ready_s7), 
	.current_len(current_len_s8), 
	.data_full(data_full_s8), 
	.data_to_write(data_to_write_s8), 
	.data_out(data_out_s8)
);

register_compression_reset #(.N(1))   ready_s8_U(.d(ready_s7), .clk(clk), .reset(reset), .q(ready_s8));
register_compression_reset #(.N(1))   last_s8_U(.d(last_s7), .clk(clk), .reset(reset), .q(last_s8));

register_compression_reset #(.N(32))  l_d_packer_out_4_s8(.d(reg_l_d_packer_out_4_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_4_s8));
register_compression_reset #(.N(32))  l_d_packer_out_5_s8(.d(reg_l_d_packer_out_5_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_5_s8));
register_compression_reset #(.N(32))  l_d_packer_out_6_s8(.d(reg_l_d_packer_out_6_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_6_s8));
register_compression_reset #(.N(32))  l_d_packer_out_7_s8(.d(reg_l_d_packer_out_7_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_7_s8));
register_compression_reset #(.N(32))  l_d_packer_out_8_s8(.d(reg_l_d_packer_out_8_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_8_s8));
register_compression_reset #(.N(32))  l_d_packer_out_9_s8(.d(reg_l_d_packer_out_9_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s8));
register_compression_reset #(.N(32))  l_d_packer_out_10_s8(.d(reg_l_d_packer_out_10_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s8));
register_compression_reset #(.N(32))  l_d_packer_out_11_s8(.d(reg_l_d_packer_out_11_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s8));
register_compression_reset #(.N(32))  l_d_packer_out_12_s8(.d(reg_l_d_packer_out_12_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s8));
register_compression_reset #(.N(32))  l_d_packer_out_13_s8(.d(reg_l_d_packer_out_13_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s8));
register_compression_reset #(.N(32))  l_d_packer_out_14_s8(.d(reg_l_d_packer_out_14_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s8));
register_compression_reset #(.N(32))  l_d_packer_out_15_s8(.d(reg_l_d_packer_out_15_s7), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s8));

register_compression_reset #(.N(5))   total_len_4_s8_U(.d(total_len_4_s7), .clk(clk), .reset(reset), .q(total_len_4_s8));
register_compression_reset #(.N(5))   total_len_5_s8_U(.d(total_len_5_s7), .clk(clk), .reset(reset), .q(total_len_5_s8));
register_compression_reset #(.N(5))   total_len_6_s8_U(.d(total_len_6_s7), .clk(clk), .reset(reset), .q(total_len_6_s8));
register_compression_reset #(.N(5))   total_len_7_s8_U(.d(total_len_7_s7), .clk(clk), .reset(reset), .q(total_len_7_s8));
register_compression_reset #(.N(5))   total_len_8_s8_U(.d(total_len_8_s7), .clk(clk), .reset(reset), .q(total_len_8_s8));
register_compression_reset #(.N(5))   total_len_9_s8_U(.d(total_len_9_s7), .clk(clk), .reset(reset), .q(total_len_9_s8));
register_compression_reset #(.N(5))   total_len_10_s8_U(.d(total_len_10_s7), .clk(clk), .reset(reset), .q(total_len_10_s8));
register_compression_reset #(.N(5))   total_len_11_s8_U(.d(total_len_11_s7), .clk(clk), .reset(reset), .q(total_len_11_s8));
register_compression_reset #(.N(5))   total_len_12_s8_U(.d(total_len_12_s7), .clk(clk), .reset(reset), .q(total_len_12_s8));
register_compression_reset #(.N(5))   total_len_13_s8_U(.d(total_len_13_s7), .clk(clk), .reset(reset), .q(total_len_13_s8));
register_compression_reset #(.N(5))   total_len_14_s8_U(.d(total_len_14_s7), .clk(clk), .reset(reset), .q(total_len_14_s8));
register_compression_reset #(.N(5))   total_len_15_s8_U(.d(total_len_15_s7), .clk(clk), .reset(reset), .q(total_len_15_s8));



// stage 9 port
wire 	[127:0] 		data_buffer_s9; 

wire 	[5:0] 	current_len_s9;
wire 			data_full_s9;
wire 	[31:0] 	data_to_write_s9;
wire 	[63:0]	data_out_s9;
wire 	[7:0]	data_len_s9;

wire 			ready_s9;

wire 			last_s9;

wire 	[31:0]	reg_l_d_packer_out_5_s9;
wire 	[31:0]	reg_l_d_packer_out_6_s9;
wire 	[31:0]	reg_l_d_packer_out_7_s9;
wire 	[31:0]	reg_l_d_packer_out_8_s9;
wire 	[31:0]	reg_l_d_packer_out_9_s9;
wire 	[31:0]	reg_l_d_packer_out_10_s9;
wire 	[31:0]	reg_l_d_packer_out_11_s9;
wire 	[31:0]	reg_l_d_packer_out_12_s9;
wire 	[31:0]	reg_l_d_packer_out_13_s9;
wire 	[31:0]	reg_l_d_packer_out_14_s9;
wire 	[31:0]	reg_l_d_packer_out_15_s9;


wire 	[4:0] 	total_len_5_s9;
wire 	[4:0] 	total_len_6_s9;
wire 	[4:0] 	total_len_7_s9;
wire 	[4:0] 	total_len_8_s9;
wire 	[4:0] 	total_len_9_s9;
wire 	[4:0] 	total_len_10_s9;
wire 	[4:0] 	total_len_11_s9;
wire 	[4:0] 	total_len_12_s9;
wire 	[4:0] 	total_len_13_s9;
wire 	[4:0] 	total_len_14_s9;
wire 	[4:0] 	total_len_15_s9;



// stage 9

//data_buffer_s9 store the l_d_packer_3 if full
shift_reg_128bits 	shift_reg_128bits_s9(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s8), 
	.data_in(data_to_write_s8), 
	.enable(data_full_s8), 
	.data_out(data_buffer_s9), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s8), 
	.len_in(6'd32), 
	.data_len(data_len_s9)
);

// pack l_d_4
barrel_shifter_64bits 	barrel_shifter_64bits_s9(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s8), 
	.pre_len(current_len_s8), 
	.data_in(reg_l_d_packer_out_4_s8), 
	.len_in(total_len_4_s8), 
	.enable(ready_s8), 
	.current_len(current_len_s9), 
	.data_full(data_full_s9), 
	.data_to_write(data_to_write_s9), 
	.data_out(data_out_s9)
);

register_compression_reset #(.N(1))   ready_s9_U(.d(ready_s8), .clk(clk), .reset(reset), .q(ready_s9));

register_compression_reset #(.N(1))   last_s9_U(.d(last_s8), .clk(clk), .reset(reset), .q(last_s9));

register_compression_reset #(.N(32))  l_d_packer_out_5_s9(.d(reg_l_d_packer_out_5_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_5_s9));
register_compression_reset #(.N(32))  l_d_packer_out_6_s9(.d(reg_l_d_packer_out_6_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_6_s9));
register_compression_reset #(.N(32))  l_d_packer_out_7_s9(.d(reg_l_d_packer_out_7_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_7_s9));
register_compression_reset #(.N(32))  l_d_packer_out_8_s9(.d(reg_l_d_packer_out_8_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_8_s9));
register_compression_reset #(.N(32))  l_d_packer_out_9_s9(.d(reg_l_d_packer_out_9_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s9));
register_compression_reset #(.N(32))  l_d_packer_out_10_s9(.d(reg_l_d_packer_out_10_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s9));
register_compression_reset #(.N(32))  l_d_packer_out_11_s9(.d(reg_l_d_packer_out_11_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s9));
register_compression_reset #(.N(32))  l_d_packer_out_12_s9(.d(reg_l_d_packer_out_12_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s9));
register_compression_reset #(.N(32))  l_d_packer_out_13_s9(.d(reg_l_d_packer_out_13_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s9));
register_compression_reset #(.N(32))  l_d_packer_out_14_s9(.d(reg_l_d_packer_out_14_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s9));
register_compression_reset #(.N(32))  l_d_packer_out_15_s9(.d(reg_l_d_packer_out_15_s8), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s9));



register_compression_reset #(.N(5))   total_len_5_s9_U(.d(total_len_5_s8), .clk(clk), .reset(reset), .q(total_len_5_s9));
register_compression_reset #(.N(5))   total_len_6_s9_U(.d(total_len_6_s8), .clk(clk), .reset(reset), .q(total_len_6_s9));
register_compression_reset #(.N(5))   total_len_7_s9_U(.d(total_len_7_s8), .clk(clk), .reset(reset), .q(total_len_7_s9));
register_compression_reset #(.N(5))   total_len_8_s9_U(.d(total_len_8_s8), .clk(clk), .reset(reset), .q(total_len_8_s9));
register_compression_reset #(.N(5))   total_len_9_s9_U(.d(total_len_9_s8), .clk(clk), .reset(reset), .q(total_len_9_s9));
register_compression_reset #(.N(5))   total_len_10_s9_U(.d(total_len_10_s8), .clk(clk), .reset(reset), .q(total_len_10_s9));
register_compression_reset #(.N(5))   total_len_11_s9_U(.d(total_len_11_s8), .clk(clk), .reset(reset), .q(total_len_11_s9));
register_compression_reset #(.N(5))   total_len_12_s9_U(.d(total_len_12_s8), .clk(clk), .reset(reset), .q(total_len_12_s9));
register_compression_reset #(.N(5))   total_len_13_s9_U(.d(total_len_13_s8), .clk(clk), .reset(reset), .q(total_len_13_s9));
register_compression_reset #(.N(5))   total_len_14_s9_U(.d(total_len_14_s8), .clk(clk), .reset(reset), .q(total_len_14_s9));
register_compression_reset #(.N(5))   total_len_15_s9_U(.d(total_len_15_s8), .clk(clk), .reset(reset), .q(total_len_15_s9));



// stage 10 port
wire 	[127:0] 		data_buffer_s10; 

wire 	[5:0] 	current_len_s10;
wire 			data_full_s10;
wire 	[31:0] 	data_to_write_s10;
wire 	[63:0]	data_out_s10;
wire 	[7:0]	data_len_s10;

wire 			ready_s10;

wire 			last_s10;

wire 	[31:0]	reg_l_d_packer_out_6_s10;
wire 	[31:0]	reg_l_d_packer_out_7_s10;
wire 	[31:0]	reg_l_d_packer_out_8_s10;
wire 	[31:0]	reg_l_d_packer_out_9_s10;
wire 	[31:0]	reg_l_d_packer_out_10_s10;
wire 	[31:0]	reg_l_d_packer_out_11_s10;
wire 	[31:0]	reg_l_d_packer_out_12_s10;
wire 	[31:0]	reg_l_d_packer_out_13_s10;
wire 	[31:0]	reg_l_d_packer_out_14_s10;
wire 	[31:0]	reg_l_d_packer_out_15_s10;

wire 	[4:0] 	total_len_6_s10;
wire 	[4:0] 	total_len_7_s10;
wire 	[4:0] 	total_len_8_s10;
wire 	[4:0] 	total_len_9_s10;
wire 	[4:0] 	total_len_10_s10;
wire 	[4:0] 	total_len_11_s10;
wire 	[4:0] 	total_len_12_s10;
wire 	[4:0] 	total_len_13_s10;
wire 	[4:0] 	total_len_14_s10;
wire 	[4:0] 	total_len_15_s10;


// stage 10
//data_buffer_s10 store the l_d_packer_4 if full
shift_reg_128bits 	shift_reg_128bits_s10(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s9), 
	.data_in(data_to_write_s9), 
	.enable(data_full_s9), 
	.data_out(data_buffer_s10), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s9), 
	.len_in(6'd32), 
	.data_len(data_len_s10)
);

// pack l_d_5
barrel_shifter_64bits 	barrel_shifter_64bits_s10(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s9), 
	.pre_len(current_len_s9), 
	.data_in(reg_l_d_packer_out_5_s9), 
	.len_in(total_len_5_s9), 
	.enable(ready_s9), 
	.current_len(current_len_s10), 
	.data_full(data_full_s10), 
	.data_to_write(data_to_write_s10), 
	.data_out(data_out_s10)
);

register_compression_reset #(.N(1))   ready_s10_U(.d(ready_s9), .clk(clk), .reset(reset), .q(ready_s10));

register_compression_reset #(.N(1))   last_s10_U(.d(last_s9), .clk(clk), .reset(reset), .q(last_s10));

register_compression_reset #(.N(32))  l_d_packer_out_6_s10(.d(reg_l_d_packer_out_6_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_6_s10));
register_compression_reset #(.N(32))  l_d_packer_out_7_s10(.d(reg_l_d_packer_out_7_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_7_s10));
register_compression_reset #(.N(32))  l_d_packer_out_8_s10(.d(reg_l_d_packer_out_8_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_8_s10));
register_compression_reset #(.N(32))  l_d_packer_out_9_s10(.d(reg_l_d_packer_out_9_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s10));
register_compression_reset #(.N(32))  l_d_packer_out_10_s10(.d(reg_l_d_packer_out_10_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s10));
register_compression_reset #(.N(32))  l_d_packer_out_11_s10(.d(reg_l_d_packer_out_11_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s10));
register_compression_reset #(.N(32))  l_d_packer_out_12_s10(.d(reg_l_d_packer_out_12_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s10));
register_compression_reset #(.N(32))  l_d_packer_out_13_s10(.d(reg_l_d_packer_out_13_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s10));
register_compression_reset #(.N(32))  l_d_packer_out_14_s10(.d(reg_l_d_packer_out_14_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s10));
register_compression_reset #(.N(32))  l_d_packer_out_15_s10(.d(reg_l_d_packer_out_15_s9), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s10));

register_compression_reset #(.N(5))   total_len_6_s10_U(.d(total_len_6_s9), .clk(clk), .reset(reset), .q(total_len_6_s10));
register_compression_reset #(.N(5))   total_len_7_s10_U(.d(total_len_7_s9), .clk(clk), .reset(reset), .q(total_len_7_s10));
register_compression_reset #(.N(5))   total_len_8_s10_U(.d(total_len_8_s9), .clk(clk), .reset(reset), .q(total_len_8_s10));
register_compression_reset #(.N(5))   total_len_9_s10_U(.d(total_len_9_s9), .clk(clk), .reset(reset), .q(total_len_9_s10));
register_compression_reset #(.N(5))   total_len_10_s10_U(.d(total_len_10_s9), .clk(clk), .reset(reset), .q(total_len_10_s10));
register_compression_reset #(.N(5))   total_len_11_s10_U(.d(total_len_11_s9), .clk(clk), .reset(reset), .q(total_len_11_s10));
register_compression_reset #(.N(5))   total_len_12_s10_U(.d(total_len_12_s9), .clk(clk), .reset(reset), .q(total_len_12_s10));
register_compression_reset #(.N(5))   total_len_13_s10_U(.d(total_len_13_s9), .clk(clk), .reset(reset), .q(total_len_13_s10));
register_compression_reset #(.N(5))   total_len_14_s10_U(.d(total_len_14_s9), .clk(clk), .reset(reset), .q(total_len_14_s10));
register_compression_reset #(.N(5))   total_len_15_s10_U(.d(total_len_15_s9), .clk(clk), .reset(reset), .q(total_len_15_s10));


// stage 11 port
wire 	[127:0] 		data_buffer_s11; 

wire 	[5:0] 	current_len_s11;
wire 			data_full_s11;
wire 	[31:0] 	data_to_write_s11;
wire 	[63:0]	data_out_s11;
wire 	[7:0] 	data_len_s11;

wire 			ready_s11;

wire 			last_s11;

wire 	[31:0]	reg_l_d_packer_out_7_s11;
wire 	[31:0]	reg_l_d_packer_out_8_s11;
wire 	[31:0]	reg_l_d_packer_out_9_s11;
wire 	[31:0]	reg_l_d_packer_out_10_s11;
wire 	[31:0]	reg_l_d_packer_out_11_s11;
wire 	[31:0]	reg_l_d_packer_out_12_s11;
wire 	[31:0]	reg_l_d_packer_out_13_s11;
wire 	[31:0]	reg_l_d_packer_out_14_s11;
wire 	[31:0]	reg_l_d_packer_out_15_s11;

wire 	[4:0] 	total_len_7_s11;
wire 	[4:0] 	total_len_8_s11;
wire 	[4:0] 	total_len_9_s11;
wire 	[4:0] 	total_len_10_s11;
wire 	[4:0] 	total_len_11_s11;
wire 	[4:0] 	total_len_12_s11;
wire 	[4:0] 	total_len_13_s11;
wire 	[4:0] 	total_len_14_s11;
wire 	[4:0] 	total_len_15_s11;


// stage 11 

//data_buffer_s11 store the l_d_packer_5 if full
shift_reg_128bits 	shift_reg_128bits_s11(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s10), 
	.data_in(data_to_write_s10), 
	.enable(data_full_s10), 
	.data_out(data_buffer_s11), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s10), 
	.len_in(6'd32), 
	.data_len(data_len_s11)
);

// pack l_d_6
barrel_shifter_64bits 	barrel_shifter_64bits_s11(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s10), 
	.pre_len(current_len_s10), 
	.data_in(reg_l_d_packer_out_6_s10), 
	.len_in(total_len_6_s10), 
	.enable(ready_s10), 
	.current_len(current_len_s11), 
	.data_full(data_full_s11), 
	.data_to_write(data_to_write_s11), 
	.data_out(data_out_s11)
);

register_compression_reset #(.N(1))   ready_s11_U(.d(ready_s10), .clk(clk), .reset(reset), .q(ready_s11));

register_compression_reset #(.N(1))   last_s11_U(.d(last_s10), .clk(clk), .reset(reset), .q(last_s11));

register_compression_reset #(.N(32))  l_d_packer_out_7_s11(.d(reg_l_d_packer_out_7_s10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_7_s11));
register_compression_reset #(.N(32))  l_d_packer_out_8_s11(.d(reg_l_d_packer_out_8_s10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_8_s11));
register_compression_reset #(.N(32))  l_d_packer_out_9_s11(.d(reg_l_d_packer_out_9_s10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s11));
register_compression_reset #(.N(32))  l_d_packer_out_10_s11(.d(reg_l_d_packer_out_10_s10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s11));
register_compression_reset #(.N(32))  l_d_packer_out_11_s11(.d(reg_l_d_packer_out_11_s10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s11));
register_compression_reset #(.N(32))  l_d_packer_out_12_s11(.d(reg_l_d_packer_out_12_s10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s11));
register_compression_reset #(.N(32))  l_d_packer_out_13_s11(.d(reg_l_d_packer_out_13_s10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s11));
register_compression_reset #(.N(32))  l_d_packer_out_14_s11(.d(reg_l_d_packer_out_14_s10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s11));
register_compression_reset #(.N(32))  l_d_packer_out_15_s11(.d(reg_l_d_packer_out_15_s10), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s11));


register_compression_reset #(.N(5))   total_len_7_s11_U(.d(total_len_7_s10), .clk(clk), .reset(reset), .q(total_len_7_s11));
register_compression_reset #(.N(5))   total_len_8_s11_U(.d(total_len_8_s10), .clk(clk), .reset(reset), .q(total_len_8_s11));
register_compression_reset #(.N(5))   total_len_9_s11_U(.d(total_len_9_s10), .clk(clk), .reset(reset), .q(total_len_9_s11));
register_compression_reset #(.N(5))   total_len_10_s11_U(.d(total_len_10_s10), .clk(clk), .reset(reset), .q(total_len_10_s11));
register_compression_reset #(.N(5))   total_len_11_s11_U(.d(total_len_11_s10), .clk(clk), .reset(reset), .q(total_len_11_s11));
register_compression_reset #(.N(5))   total_len_12_s11_U(.d(total_len_12_s10), .clk(clk), .reset(reset), .q(total_len_12_s11));
register_compression_reset #(.N(5))   total_len_13_s11_U(.d(total_len_13_s10), .clk(clk), .reset(reset), .q(total_len_13_s11));
register_compression_reset #(.N(5))   total_len_14_s11_U(.d(total_len_14_s10), .clk(clk), .reset(reset), .q(total_len_14_s11));
register_compression_reset #(.N(5))   total_len_15_s11_U(.d(total_len_15_s10), .clk(clk), .reset(reset), .q(total_len_15_s11));






// stage 12 port
wire 	[127:0] 		data_buffer_s12; 

wire 	[5:0] 	current_len_s12;
wire 			data_full_s12;
wire 	[31:0] 	data_to_write_s12;
wire 	[63:0]	data_out_s12;
wire 	[7:0]	data_len_s12;

wire 			ready_s12;
wire 			last_12;

wire 	[31:0]	reg_l_d_packer_out_8_s12;
wire 	[31:0]	reg_l_d_packer_out_9_s12;
wire 	[31:0]	reg_l_d_packer_out_10_s12;
wire 	[31:0]	reg_l_d_packer_out_11_s12;
wire 	[31:0]	reg_l_d_packer_out_12_s12;
wire 	[31:0]	reg_l_d_packer_out_13_s12;
wire 	[31:0]	reg_l_d_packer_out_14_s12;
wire 	[31:0]	reg_l_d_packer_out_15_s12;

wire 	[4:0] 	total_len_8_s12;
wire 	[4:0] 	total_len_9_s12;
wire 	[4:0] 	total_len_10_s12;
wire 	[4:0] 	total_len_11_s12;
wire 	[4:0] 	total_len_12_s12;
wire 	[4:0] 	total_len_13_s12;
wire 	[4:0] 	total_len_14_s12;
wire 	[4:0] 	total_len_15_s12;


// stage 12
//data_buffer_s12 store the l_d_packer_6 if full
shift_reg_128bits 	shift_reg_128bits_s12(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s11), 
	.data_in(data_to_write_s11), 
	.enable(data_full_s11), 
	.data_out(data_buffer_s12), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s11), 
	.len_in(6'd32), 
	.data_len(data_len_s12)
);

// pack l_d_7
barrel_shifter_64bits 	barrel_shifter_64bits_s12(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s11), 
	.pre_len(current_len_s11), 
	.data_in(reg_l_d_packer_out_7_s11), 
	.len_in(total_len_7_s11), 
	.enable(ready_s11), 
	.current_len(current_len_s12), 
	.data_full(data_full_s12), 
	.data_to_write(data_to_write_s12), 
	.data_out(data_out_s12)
);

register_compression_reset #(.N(1))   ready_s12_U(.d(ready_s11), .clk(clk), .reset(reset), .q(ready_s12));
register_compression_reset #(.N(1))   last_s12_U(.d(last_s11), .clk(clk), .reset(reset), .q(last_s12));

register_compression_reset #(.N(32))  l_d_packer_out_8_s12(.d(reg_l_d_packer_out_8_s11), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_8_s12));
register_compression_reset #(.N(32))  l_d_packer_out_9_s12(.d(reg_l_d_packer_out_9_s11), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s12));
register_compression_reset #(.N(32))  l_d_packer_out_10_s12(.d(reg_l_d_packer_out_10_s11), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s12));
register_compression_reset #(.N(32))  l_d_packer_out_11_s12(.d(reg_l_d_packer_out_11_s11), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s12));
register_compression_reset #(.N(32))  l_d_packer_out_12_s12(.d(reg_l_d_packer_out_12_s11), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s12));
register_compression_reset #(.N(32))  l_d_packer_out_13_s12(.d(reg_l_d_packer_out_13_s11), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s12));
register_compression_reset #(.N(32))  l_d_packer_out_14_s12(.d(reg_l_d_packer_out_14_s11), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s12));
register_compression_reset #(.N(32))  l_d_packer_out_15_s12(.d(reg_l_d_packer_out_15_s11), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s12));


register_compression_reset #(.N(5))   total_len_8_s12_U(.d(total_len_8_s11), .clk(clk), .reset(reset), .q(total_len_8_s12));
register_compression_reset #(.N(5))   total_len_9_s12_U(.d(total_len_9_s11), .clk(clk), .reset(reset), .q(total_len_9_s12));
register_compression_reset #(.N(5))   total_len_10_s12_U(.d(total_len_10_s11), .clk(clk), .reset(reset), .q(total_len_10_s12));
register_compression_reset #(.N(5))   total_len_11_s12_U(.d(total_len_11_s11), .clk(clk), .reset(reset), .q(total_len_11_s12));
register_compression_reset #(.N(5))   total_len_12_s12_U(.d(total_len_12_s11), .clk(clk), .reset(reset), .q(total_len_12_s12));
register_compression_reset #(.N(5))   total_len_13_s12_U(.d(total_len_13_s11), .clk(clk), .reset(reset), .q(total_len_13_s12));
register_compression_reset #(.N(5))   total_len_14_s12_U(.d(total_len_14_s11), .clk(clk), .reset(reset), .q(total_len_14_s12));
register_compression_reset #(.N(5))   total_len_15_s12_U(.d(total_len_15_s11), .clk(clk), .reset(reset), .q(total_len_15_s12));


// stage 13 port
wire 	[127:0] 		data_buffer_s13; 

wire 	[5:0] 	current_len_s13;
wire 			data_full_s13;
wire 	[31:0] 	data_to_write_s13;
wire 	[63:0]	data_out_s13;
wire 	[7:0]	data_len_s13;

wire 			ready_s13;
wire 			last_s13;

wire 	[31:0]	reg_l_d_packer_out_9_s13;
wire 	[31:0]	reg_l_d_packer_out_10_s13;
wire 	[31:0]	reg_l_d_packer_out_11_s13;
wire 	[31:0]	reg_l_d_packer_out_12_s13;
wire 	[31:0]	reg_l_d_packer_out_13_s13;
wire 	[31:0]	reg_l_d_packer_out_14_s13;
wire 	[31:0]	reg_l_d_packer_out_15_s13;

wire 	[4:0] 	total_len_9_s13;
wire 	[4:0] 	total_len_10_s13;
wire 	[4:0] 	total_len_11_s13;
wire 	[4:0] 	total_len_12_s13;
wire 	[4:0] 	total_len_13_s13;
wire 	[4:0] 	total_len_14_s13;
wire 	[4:0] 	total_len_15_s13;

//// stage 13
//data_buffer_s13 store the l_d_packer_7 if full
shift_reg_128bits 	shift_reg_128bits_s13(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s12), 
	.data_in(data_to_write_s12), 
	.enable(data_full_s12), 
	.data_out(data_buffer_s13), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s12), 
	.len_in(6'd32), 
	.data_len(data_len_s13)
);

// pack l_d_8
barrel_shifter_64bits 	barrel_shifter_64bits_s13(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s12), 
	.pre_len(current_len_s12), 
	.data_in(reg_l_d_packer_out_8_s12), 
	.len_in(total_len_8_s12), 
	.enable(ready_s12), 
	.current_len(current_len_s13), 
	.data_full(data_full_s13), 
	.data_to_write(data_to_write_s13), 
	.data_out(data_out_s13)
);

register_compression_reset #(.N(1))   ready_s13_U(.d(ready_s12), .clk(clk), .reset(reset), .q(ready_s13));

register_compression_reset #(.N(1))   last_s13_U(.d(last_s12), .clk(clk), .reset(reset), .q(last_s13));

register_compression_reset #(.N(32))  l_d_packer_out_9_s13(.d(reg_l_d_packer_out_9_s12), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_9_s13));
register_compression_reset #(.N(32))  l_d_packer_out_10_s13(.d(reg_l_d_packer_out_10_s12), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s13));
register_compression_reset #(.N(32))  l_d_packer_out_11_s13(.d(reg_l_d_packer_out_11_s12), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s13));
register_compression_reset #(.N(32))  l_d_packer_out_12_s13(.d(reg_l_d_packer_out_12_s12), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s13));
register_compression_reset #(.N(32))  l_d_packer_out_13_s13(.d(reg_l_d_packer_out_13_s12), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s13));
register_compression_reset #(.N(32))  l_d_packer_out_14_s13(.d(reg_l_d_packer_out_14_s12), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s13));
register_compression_reset #(.N(32))  l_d_packer_out_15_s13(.d(reg_l_d_packer_out_15_s12), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s13));


register_compression_reset #(.N(5))   total_len_9_s13_U(.d(total_len_9_s12), .clk(clk), .reset(reset), .q(total_len_9_s13));
register_compression_reset #(.N(5))   total_len_10_s13_U(.d(total_len_10_s12), .clk(clk), .reset(reset), .q(total_len_10_s13));
register_compression_reset #(.N(5))   total_len_11_s13_U(.d(total_len_11_s12), .clk(clk), .reset(reset), .q(total_len_11_s13));
register_compression_reset #(.N(5))   total_len_12_s13_U(.d(total_len_12_s12), .clk(clk), .reset(reset), .q(total_len_12_s13));
register_compression_reset #(.N(5))   total_len_13_s13_U(.d(total_len_13_s12), .clk(clk), .reset(reset), .q(total_len_13_s13));
register_compression_reset #(.N(5))   total_len_14_s13_U(.d(total_len_14_s12), .clk(clk), .reset(reset), .q(total_len_14_s13));
register_compression_reset #(.N(5))   total_len_15_s13_U(.d(total_len_15_s12), .clk(clk), .reset(reset), .q(total_len_15_s13));


// stage 14 port 
wire 	[127:0] 		data_buffer_s14; 

wire 	[5:0] 	current_len_s14;
wire 			data_full_s14;
wire 	[31:0] 	data_to_write_s14;
wire 	[63:0]	data_out_s14;
wire 	[7:0]	data_len_s14;

wire 			ready_s14;
wire 			last_s14;

wire 	[31:0]	reg_l_d_packer_out_10_s14;
wire 	[31:0]	reg_l_d_packer_out_11_s14;
wire 	[31:0]	reg_l_d_packer_out_12_s14;
wire 	[31:0]	reg_l_d_packer_out_13_s14;
wire 	[31:0]	reg_l_d_packer_out_14_s14;
wire 	[31:0]	reg_l_d_packer_out_15_s14;

wire 	[4:0] 	total_len_10_s14;
wire 	[4:0] 	total_len_11_s14;
wire 	[4:0] 	total_len_12_s14;
wire 	[4:0] 	total_len_13_s14;
wire 	[4:0] 	total_len_14_s14;
wire 	[4:0] 	total_len_15_s14;


//// stage 14
//data_buffer_s14 store the l_d_packer_8 if full
shift_reg_128bits 	shift_reg_128bits_s14(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s13), 
	.data_in(data_to_write_s13), 
	.enable(data_full_s13), 
	.data_out(data_buffer_s14), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s13), 
	.len_in(6'd32), 
	.data_len(data_len_s14)
);

// pack l_d_9
barrel_shifter_64bits 	barrel_shifter_64bits_s14(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s13), 
	.pre_len(current_len_s13), 
	.data_in(reg_l_d_packer_out_9_s13), 
	.len_in(total_len_9_s13), 
	.enable(ready_s13), 
	.current_len(current_len_s14), 
	.data_full(data_full_s14), 
	.data_to_write(data_to_write_s14), 
	.data_out(data_out_s14)
);

register_compression_reset #(.N(1))   ready_s14_U(.d(ready_s13), .clk(clk), .reset(reset), .q(ready_s14));
register_compression_reset #(.N(1))   last_s14_U(.d(last_s13), .clk(clk), .reset(reset), .q(last_s14));

register_compression_reset #(.N(32))  l_d_packer_out_10_s14(.d(reg_l_d_packer_out_10_s13), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_10_s14));
register_compression_reset #(.N(32))  l_d_packer_out_11_s14(.d(reg_l_d_packer_out_11_s13), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s14));
register_compression_reset #(.N(32))  l_d_packer_out_12_s14(.d(reg_l_d_packer_out_12_s13), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s14));
register_compression_reset #(.N(32))  l_d_packer_out_13_s14(.d(reg_l_d_packer_out_13_s13), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s14));
register_compression_reset #(.N(32))  l_d_packer_out_14_s14(.d(reg_l_d_packer_out_14_s13), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s14));
register_compression_reset #(.N(32))  l_d_packer_out_15_s14(.d(reg_l_d_packer_out_15_s13), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s14));


register_compression_reset #(.N(5))   total_len_10_s14_U(.d(total_len_10_s13), .clk(clk), .reset(reset), .q(total_len_10_s14));
register_compression_reset #(.N(5))   total_len_11_s14_U(.d(total_len_11_s13), .clk(clk), .reset(reset), .q(total_len_11_s14));
register_compression_reset #(.N(5))   total_len_12_s14_U(.d(total_len_12_s13), .clk(clk), .reset(reset), .q(total_len_12_s14));
register_compression_reset #(.N(5))   total_len_13_s14_U(.d(total_len_13_s13), .clk(clk), .reset(reset), .q(total_len_13_s14));
register_compression_reset #(.N(5))   total_len_14_s14_U(.d(total_len_14_s13), .clk(clk), .reset(reset), .q(total_len_14_s14));
register_compression_reset #(.N(5))   total_len_15_s14_U(.d(total_len_15_s13), .clk(clk), .reset(reset), .q(total_len_15_s14));


// stage 15 port 
wire 	[127:0] 		data_buffer_s15; 

wire 	[5:0] 	current_len_s15;
wire 			data_full_s15;
wire 	[31:0] 	data_to_write_s15;
wire 	[63:0]	data_out_s15;
wire 	[7:0]	data_len_s15;

wire 			ready_s15;
wire 			last_s15;

wire 	[31:0]	reg_l_d_packer_out_11_s15;
wire 	[31:0]	reg_l_d_packer_out_12_s15;
wire 	[31:0]	reg_l_d_packer_out_13_s15;
wire 	[31:0]	reg_l_d_packer_out_14_s15;
wire 	[31:0]	reg_l_d_packer_out_15_s15;

wire 	[4:0] 	total_len_11_s15;
wire 	[4:0] 	total_len_12_s15;
wire 	[4:0] 	total_len_13_s15;
wire 	[4:0] 	total_len_14_s15;
wire 	[4:0] 	total_len_15_s15;

// stage 15
//data_buffer_s15 store the l_d_packer_9 if full
shift_reg_128bits 	shift_reg_128bits_s15(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s14), 
	.data_in(data_to_write_s14), 
	.enable(data_full_s14), 
	.data_out(data_buffer_s15), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s14), 
	.len_in(6'd32), 
	.data_len(data_len_s15)
);

// pack l_d_10
barrel_shifter_64bits 	barrel_shifter_64bits_s15(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s14), 
	.pre_len(current_len_s14), 
	.data_in(reg_l_d_packer_out_10_s14), 
	.len_in(total_len_10_s14), 
	.enable(ready_s14), 
	.current_len(current_len_s15), 
	.data_full(data_full_s15), 
	.data_to_write(data_to_write_s15), 
	.data_out(data_out_s15)
);

register_compression_reset #(.N(1))   ready_s15_U(.d(ready_s14), .clk(clk), .reset(reset), .q(ready_s15));
register_compression_reset #(.N(1))   last_s15_U(.d(last_s14), .clk(clk), .reset(reset), .q(last_s15));

register_compression_reset #(.N(32))  l_d_packer_out_11_s15(.d(reg_l_d_packer_out_11_s14), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_11_s15));
register_compression_reset #(.N(32))  l_d_packer_out_12_s15(.d(reg_l_d_packer_out_12_s14), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s15));
register_compression_reset #(.N(32))  l_d_packer_out_13_s15(.d(reg_l_d_packer_out_13_s14), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s15));
register_compression_reset #(.N(32))  l_d_packer_out_14_s15(.d(reg_l_d_packer_out_14_s14), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s15));
register_compression_reset #(.N(32))  l_d_packer_out_15_s15(.d(reg_l_d_packer_out_15_s14), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s15));

register_compression_reset #(.N(5))   total_len_11_s15_U(.d(total_len_11_s14), .clk(clk), .reset(reset), .q(total_len_11_s15));
register_compression_reset #(.N(5))   total_len_12_s15_U(.d(total_len_12_s14), .clk(clk), .reset(reset), .q(total_len_12_s15));
register_compression_reset #(.N(5))   total_len_13_s15_U(.d(total_len_13_s14), .clk(clk), .reset(reset), .q(total_len_13_s15));
register_compression_reset #(.N(5))   total_len_14_s15_U(.d(total_len_14_s14), .clk(clk), .reset(reset), .q(total_len_14_s15));
register_compression_reset #(.N(5))   total_len_15_s15_U(.d(total_len_15_s14), .clk(clk), .reset(reset), .q(total_len_15_s15));


// stage 16 port 
wire 	[127:0] 		data_buffer_s16; 

wire 	[5:0] 	current_len_s16;
wire 			data_full_s16;
wire 	[31:0] 	data_to_write_s16;
wire 	[63:0]	data_out_s16;
wire 	[7:0]	data_len_s16;

wire 			ready_s16;

wire 			last_s16;

wire 	[31:0]	reg_l_d_packer_out_12_s16;
wire 	[31:0]	reg_l_d_packer_out_13_s16;
wire 	[31:0]	reg_l_d_packer_out_14_s16;
wire 	[31:0]	reg_l_d_packer_out_15_s16;

wire 	[4:0] 	total_len_12_s16;
wire 	[4:0] 	total_len_13_s16;
wire 	[4:0] 	total_len_14_s16;
wire 	[4:0] 	total_len_15_s16;

// stage 16
//data_buffer_s16 store the l_d_packer_10 if full
shift_reg_128bits 	shift_reg_128bits_s16(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s15), 
	.data_in(data_to_write_s15), 
	.enable(data_full_s15), 
	.data_out(data_buffer_s16), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s15), 
	.len_in(6'd32), 
	.data_len(data_len_s16)
);

// pack l_d_11
barrel_shifter_64bits 	barrel_shifter_64bits_s16(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s15), 
	.pre_len(current_len_s15), 
	.data_in(reg_l_d_packer_out_11_s15), 
	.len_in(total_len_11_s15), 
	.enable(ready_s15), 
	.current_len(current_len_s16), 
	.data_full(data_full_s16), 
	.data_to_write(data_to_write_s16), 
	.data_out(data_out_s16)
);

register_compression_reset #(.N(1))   ready_s16_U(.d(ready_s15), .clk(clk), .reset(reset), .q(ready_s16));

register_compression_reset #(.N(1))   last_s16_U(.d(last_s15), .clk(clk), .reset(reset), .q(last_s16));

register_compression_reset #(.N(32))  l_d_packer_out_12_s16(.d(reg_l_d_packer_out_12_s15), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_12_s16));
register_compression_reset #(.N(32))  l_d_packer_out_13_s16(.d(reg_l_d_packer_out_13_s15), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s16));
register_compression_reset #(.N(32))  l_d_packer_out_14_s16(.d(reg_l_d_packer_out_14_s15), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s16));
register_compression_reset #(.N(32))  l_d_packer_out_15_s16(.d(reg_l_d_packer_out_15_s15), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s16));

register_compression_reset #(.N(5))   total_len_12_s16_U(.d(total_len_12_s15), .clk(clk), .reset(reset), .q(total_len_12_s16));
register_compression_reset #(.N(5))   total_len_13_s16_U(.d(total_len_13_s15), .clk(clk), .reset(reset), .q(total_len_13_s16));
register_compression_reset #(.N(5))   total_len_14_s16_U(.d(total_len_14_s15), .clk(clk), .reset(reset), .q(total_len_14_s16));
register_compression_reset #(.N(5))   total_len_15_s16_U(.d(total_len_15_s15), .clk(clk), .reset(reset), .q(total_len_15_s16));


// stage 17 port 
wire 	[127:0] 		data_buffer_s17; 

wire 	[5:0] 	current_len_s17;
wire 			data_full_s17;
wire 	[31:0] 	data_to_write_s17;
wire 	[63:0]	data_out_s17;
wire 	[7:0]	data_len_s17;

wire 			ready_s17;
wire 			last_s17;

wire 	[31:0]	reg_l_d_packer_out_13_s17;
wire 	[31:0]	reg_l_d_packer_out_14_s17;
wire 	[31:0]	reg_l_d_packer_out_15_s17;

wire 	[4:0] 	total_len_13_s17;
wire 	[4:0] 	total_len_14_s17;
wire 	[4:0] 	total_len_15_s17;

// stage 17
//data_buffer_s17 store the l_d_packer_11 if full
shift_reg_128bits 	shift_reg_128bits_s17(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s16), 
	.data_in(data_to_write_s16), 
	.enable(data_full_s16), 
	.data_out(data_buffer_s17), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s16), 
	.len_in(6'd32), 
	.data_len(data_len_s17)
);

// pack l_d_12
barrel_shifter_64bits 	barrel_shifter_64bits_s17(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s16), 
	.pre_len(current_len_s16), 
	.data_in(reg_l_d_packer_out_12_s16), 
	.len_in(total_len_12_s16), 
	.enable(ready_s16), 
	.current_len(current_len_s17), 
	.data_full(data_full_s17), 
	.data_to_write(data_to_write_s17), 
	.data_out(data_out_s17)
);

register_compression_reset #(.N(1))   ready_s17_U(.d(ready_s16), .clk(clk), .reset(reset), .q(ready_s17));
register_compression_reset #(.N(1))   last_s17_U(.d(last_s16), .clk(clk), .reset(reset), .q(last_s17));

register_compression_reset #(.N(32))  l_d_packer_out_13_s17(.d(reg_l_d_packer_out_13_s16), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_13_s17));
register_compression_reset #(.N(32))  l_d_packer_out_14_s17(.d(reg_l_d_packer_out_14_s16), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s17));
register_compression_reset #(.N(32))  l_d_packer_out_15_s17(.d(reg_l_d_packer_out_15_s16), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s17));

register_compression_reset #(.N(5))   total_len_13_s17_U(.d(total_len_13_s16), .clk(clk), .reset(reset), .q(total_len_13_s17));
register_compression_reset #(.N(5))   total_len_14_s17_U(.d(total_len_14_s16), .clk(clk), .reset(reset), .q(total_len_14_s17));
register_compression_reset #(.N(5))   total_len_15_s17_U(.d(total_len_15_s16), .clk(clk), .reset(reset), .q(total_len_15_s17));


// stage 18 port 
wire 	[127:0] 		data_buffer_s18; 

wire 	[5:0] 	current_len_s18;
wire 			data_full_s18;
wire 	[31:0] 	data_to_write_s18;
wire 	[63:0]	data_out_s18;
wire 	[7:0]	data_len_s18;

wire 			ready_s18;
wire 			last_s18;

wire 	[31:0]	reg_l_d_packer_out_14_s18;
wire 	[31:0]	reg_l_d_packer_out_15_s18;

wire 	[4:0] 	total_len_14_s18;
wire 	[4:0] 	total_len_15_s18;

// stage 18
//data_buffer_s18 store the l_d_packer_12 if full
shift_reg_128bits 	shift_reg_128bits_s18(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s17), 
	.data_in(data_to_write_s17), 
	.enable(data_full_s17), 
	.data_out(data_buffer_s18), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s17), 
	.len_in(6'd32), 
	.data_len(data_len_s18)
);

// pack l_d_13
barrel_shifter_64bits 	barrel_shifter_64bits_s18(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s17), 
	.pre_len(current_len_s17), 
	.data_in(reg_l_d_packer_out_13_s17), 
	.len_in(total_len_13_s17), 
	.enable(ready_s17), 
	.current_len(current_len_s18), 
	.data_full(data_full_s18), 
	.data_to_write(data_to_write_s18), 
	.data_out(data_out_s18)
);

register_compression_reset #(.N(1))   ready_s18_U(.d(ready_s17), .clk(clk), .reset(reset), .q(ready_s18));
register_compression_reset #(.N(1))   last_s18_U(.d(last_s17), .clk(clk), .reset(reset), .q(last_s18));

register_compression_reset #(.N(32))  l_d_packer_out_14_s18(.d(reg_l_d_packer_out_14_s17), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_14_s18));
register_compression_reset #(.N(32))  l_d_packer_out_15_s18(.d(reg_l_d_packer_out_15_s17), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s18));

register_compression_reset #(.N(5))   total_len_14_s18_U(.d(total_len_14_s17), .clk(clk), .reset(reset), .q(total_len_14_s18));
register_compression_reset #(.N(5))   total_len_15_s18_U(.d(total_len_15_s17), .clk(clk), .reset(reset), .q(total_len_15_s18));


// stage 19 port 
wire 	[127:0] 		data_buffer_s19; 

wire 	[5:0] 	current_len_s19;
wire 			data_full_s19;
wire 	[31:0] 	data_to_write_s19;
wire 	[63:0]	data_out_s19;
wire 	[7:0]	data_len_s19;

wire 			ready_s19;
wire 			last_s19;

wire 	[31:0]	reg_l_d_packer_out_15_s19;

wire 	[4:0] 	total_len_15_s19;

// stage 19
//data_buffer_s19 store the l_d_packer_13 if full
shift_reg_128bits 	shift_reg_128bits_s19(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s18), 
	.data_in(data_to_write_s18), 
	.enable(data_full_s18), 
	.data_out(data_buffer_s19), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s18), 
	.len_in(6'd32), 
	.data_len(data_len_s19)
);

// pack l_d_14
barrel_shifter_64bits 	barrel_shifter_64bits_s19(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s18), 
	.pre_len(current_len_s18), 
	.data_in(reg_l_d_packer_out_14_s18), 
	.len_in(total_len_14_s18), 
	.enable(ready_s18), 
	.current_len(current_len_s19), 
	.data_full(data_full_s19), 
	.data_to_write(data_to_write_s19), 
	.data_out(data_out_s19)
);

register_compression_reset #(.N(1))   ready_s19_U(.d(ready_s18), .clk(clk), .reset(reset), .q(ready_s19));
register_compression_reset #(.N(1))   last_s19_U(.d(last_s18), .clk(clk), .reset(reset), .q(last_s19));

register_compression_reset #(.N(32))  l_d_packer_out_15_s19(.d(reg_l_d_packer_out_15_s18), .clk(clk), .reset(reset), .q(reg_l_d_packer_out_15_s19));

register_compression_reset #(.N(5))   total_len_15_s19_U(.d(total_len_15_s18), .clk(clk), .reset(reset), .q(total_len_15_s19));


// stage 20 port 
wire 	[127:0] 		data_buffer_s20; 

wire 	[5:0] 	current_len_s20;
wire 			data_full_s20;
wire 	[31:0] 	data_to_write_s20;
wire 	[63:0]	data_out_s20;
wire 	[7:0]	data_len_s20;

wire 			ready_s20;
wire 			last_s20;



// stage 20
//data_buffer_s20 store the l_d_packer_14 if full
shift_reg_128bits 	shift_reg_128bits_s20(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s19), 
	.data_in(data_to_write_s19), 
	.enable(data_full_s19), 
	.data_out(data_buffer_s20), 
//	.last_shift(1'b0), 
	.prev_len(data_len_s19), 
	.len_in(6'd32), 
	.data_len(data_len_s20)
);

// pack l_d_15
barrel_shifter_64bits 	barrel_shifter_64bits_s20(
	.clk(clk), 
	.reset(reset), 
	.pre_data(data_out_s19), 
	.pre_len(current_len_s19), 
	.data_in(reg_l_d_packer_out_15_s19), 
	.len_in(total_len_15_s19), 
	.enable(ready_s19), 
	.current_len(current_len_s20), 
	.data_full(data_full_s20), 
	.data_to_write(data_to_write_s20), 
	.data_out(data_out_s20)
);

register_compression_reset #(.N(1))   ready_s20_U(.d(ready_s19), .clk(clk), .reset(reset), .q(ready_s20));
register_compression_reset #(.N(1))   last_s20_U(.d(last_s19), .clk(clk), .reset(reset), .q(last_s20));


// stage 21 port
wire 	[127:0] 	data_buffer_s21;


wire 				ready_s21;
wire 				last_s21;

wire 	[7:0]		data_len_s21;

// last bits
wire 	[63:0]		data_out_s21;
wire 	[5:0]		current_len_s21;

// stage 21
//data_buffer_s21 store the l_d_packer_7 if full

shift_reg_128bits 	shift_reg_128bits_s21(
	.clk(clk), 
	.reset(reset), 
	.prev_data(data_buffer_s20), 
	.data_in(data_to_write_s20), 
	.enable(data_full_s20), 
	.data_out(data_buffer_s21), 
	.prev_len(data_len_s20), 
	.len_in(6'd32), 
	.data_len(data_len_s21)
);

register_compression_reset #(.N(64))	data_out_s21_U(.d(data_out_s20), .clk(clk), .reset(reset), .q(data_out_s21));
register_compression_reset #(.N(6)) 	current_len_s21_U(.d(current_len_s20), .clk(clk), .reset(reset), .q(current_len_s21));
register_compression_reset #(.N(1))   ready_s21_U(.d(ready_s20), .clk(clk), .reset(reset), .q(ready_s21));
register_compression_reset #(.N(1))   last_s21_U(.d(last_s20), .clk(clk), .reset(reset), .q(last_s21));


// stage 22 port
wire 	[255:0] 	data_buffer_s22;
wire 	[7:0]		data_len_s22;
wire 				ready_s22;

// stage 22
shift_reg_256bits 	shift_reg_256bits_s22(
	.clk(clk), 
	.reset(reset), 
	.prev_data({128'd0, data_buffer_s21}), 
	.data_in(data_out_s21[31:0]), 
	.enable(ready_s21), 
	.data_out(data_buffer_s22), 
	.prev_len(data_len_s21), 
	.len_in(current_len_s21), 
	.data_len(data_len_s22)
);

register_compression_reset #(.N(1))   ready_s22_U(.d(ready_s21), .clk(clk), .reset(reset), .q(ready_s22));

register_compression #(.N(1))	last_s22_U(.d(last_s21), .clk(clk), .q(out_last));


assign out_data = data_buffer_s22;
assign out_ready = ready_s22;

assign out_len = data_len_s22;




endmodule

