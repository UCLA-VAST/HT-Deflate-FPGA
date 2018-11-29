// ==============================================================
// Description: huffman_encode			
// Author: Weikang Qiao
// Date: 11/03/2016
//
// Parameters:
// 				
// 				
//
// Note: 
// 		 
//		 
// ==============================================================


module huffman_translation(
	clk, 
	reset, 
	l_V, 
	d_V, 
	enable, 
	l_huffman_len, 
	l_huffman_code,
	l_extra_len, 
	l_extra, 
	d_huffman_len, 
	d_huffman_code,
	d_extra_len, 
	d_extra, 
	output_ready
);


//input ports
input 				clk;
input				reset;
input	[7 	:	0]	l_V;
input	[15 :	0]	d_V;
input 				enable;

// output ports
output	[3 	:	0]	l_huffman_len;
output	[11 :	0]	l_huffman_code;
output 	[3 	:	0]	l_extra_len;
output	[7 	:	0]	l_extra;
output 	[2 	:	0] 	d_huffman_len;
output 	[4 	:	0] 	d_huffman_code;
output	[3 	:	0]	d_extra_len;
output 	[15 :	0]	d_extra;
output 				output_ready;


// stage 1 port
wire				l_V_equ_255;
wire	[2 	:	0]	address_lbound;

wire	[31 :	0]	l_upper_bound_v4;
wire	[31 :	0]	l_lower_bound_v4;


wire	[7 	:	0]	l_s1_reg;
wire	[2 	:	0]	address_lbound_reg;

wire	[3 	:	0]	address_dbound;

wire				d_V_lower_equ_0;
wire				d_V_upper_equ_0;
wire				d_V_neq_0;

wire	[31 :	0] 	d_upper_bound_v2;
wire	[31 :	0]	d_lower_bound_v2;

wire	[15 :	0]	d_s1_reg;
wire				d_V_neq_0_reg_s1;
wire				enable_reg_s1;
wire 	[3 	:	0] 	address_dbound_reg;




// stage 1
assign l_V_equ_255 = l_V[7] & l_V[6] & l_V[5] & l_V[4] & l_V[3] & l_V[2] & l_V[1] & l_V[0];
assign address_lbound = l_V[7]?(l_V_equ_255?3'd7:3'd6):(l_V[6]?3'd5:(l_V[5]?3'd4:(l_V[4]?3'd3:(l_V[3]?3'd2:(l_V[2]?3'd1:3'd0)))));

huffman_translate_l_upper_bound_rom  huffman_translate_l_upper_bound_rom_U(
	.address(address_lbound), 
	.rden(enable), 
	.q(l_upper_bound_v4), 
	.clock(clk)
);



huffman_translate_l_lower_bound_rom  huffman_translate_l_lower_bound_rom_U(
	.address(address_lbound), 
	.rden(enable), 
	.q(l_lower_bound_v4), 
	.clock(clk)
);

assign address_dbound = (d_V[15] | d_V[14])?4'd14:(d_V[13]?4'd13:(d_V[12]?4'd12:(d_V[11]?4'd11:(d_V[10]?4'd10:(d_V[9]?4'd9:d_V[8]?4'd8:(
						d_V[7]?4'd7:(d_V[6]?4'd6:(d_V[5]?4'd5:(d_V[4]?4'd4:(d_V[3]?4'd3:(d_V[2]?4'd2:(d_V[1]?4'd1:4'd0))))))))))));

assign d_V_lower_equ_0 = d_V[7] | d_V[6] | d_V[5] | d_V[4] | d_V[3] | d_V[2] | d_V[1] | d_V[0];
assign d_V_upper_equ_0 = d_V[15] | d_V[14] | d_V[13] | d_V[12] | d_V[11] | d_V[10] | d_V[9] | d_V[8];
assign d_V_neq_0 = d_V_upper_equ_0 | d_V_lower_equ_0;


huffman_translate_d_upper_bound_rom   huffman_translate_d_upper_bound_rom_U(
	.address(address_dbound), 
	.rden(enable), 
	.q(d_upper_bound_v2), 
	.clock(clk)
);

huffman_translate_d_lower_bound_rom  huffman_translate_d_lower_bound_rom_U(
	.address(address_dbound), 
	.rden(enable), 
	.q(d_lower_bound_v2), 
	.clock(clk)
);

register_compression_reset #(.N(8)) register_l_s1_U(.d(l_V), .clk(clk), .reset(reset), .q(l_s1_reg));
register_compression_reset #(.N(3)) register_l_address_lbound_U(.d(address_lbound), .clk(clk), .reset(reset), .q(address_lbound_reg));

register_compression_reset #(.N(16)) register_d_s1_U(.d(d_V), .clk(clk), .reset(reset), .q(d_s1_reg));
register_compression_reset #(.N(1)) register_d_V_neq_0_s1_U(.d(d_V_neq_0), .clk(clk), .reset(reset), .q(d_V_neq_0_reg_s1)); 
register_compression_reset #(.N(1)) register_enable_reg_s1_U(.d(enable), .clk(clk), .reset(reset), .q(enable_reg_s1));
register_compression_reset #(.N(4)) register_address_dbound_U(.d(address_dbound), .clk(clk), .reset(reset), .q(address_dbound_reg));


//stage 2 port
wire	l_upper_bound_3;
wire	l_upper_bound_2;
wire	l_upper_bound_1;
wire	l_upper_bound_0;

wire	l_lower_bound_0;
wire	l_lower_bound_1;
wire	l_lower_bound_2;
wire	l_lower_bound_3;

wire	[7:0]	l_offset_0;
wire	[7:0]	l_offset_1;
wire	[7:0]	l_offset_2;
wire	[7:0]	l_offset_3;

wire	[1:0]	l_index_v4;
wire	[4:0]	l_index;
wire	[7:0]	l_offset;

wire	[7:0]	l_s2_reg;
wire	[4:0]	l_index_reg;
wire	[7:0]	l_offset_reg;


wire 	d_upper_bound_1; 
wire 	d_upper_bound_0;
wire 	d_lower_bound_1; 
wire 	d_lower_bound_0;


wire 	[15:0]  d_offset_0;
wire 	[15:0]  d_offset_1;
wire 	[15:0]  d_offset_temp;

wire 	[15:0]	dbound;	//dbound = 1<<address_dbound_reg
wire 	dbound_test;

wire 	d_index;

wire 	[4:0]	d_code_1;
wire 	[15:0] 	d_offset;
wire        d_equ_1;

wire 	[4:0] 	d_code_1_reg;
wire 	[15:0] 	d_offset_reg;
wire 	[15:0]  d_offset_temp_reg;
wire 			dbound_test_reg;
wire			d_V_neq_0_reg_s2;
wire			enable_reg_s2;
wire 			d_index_reg;
wire 	[3:0] 	address_dbound_reg_s2;
wire      d_equ_1_reg;

// stage 2
adder_8bits adder_8bits_l_upper_bound_0_U(
	.a(l_upper_bound_v4[7:0]),
	.b(~l_s1_reg),
	.ci(1'b1),
	.s(),
	.co(l_upper_bound_0) 		//l_upper_bound_0 = 1 means l_s1 <= l_l_upper_bound_v4[7:0]
);

adder_8bits adder_8bits_l_upper_bound_1_U(
	.a(l_upper_bound_v4[15:8]),
	.b(~l_s1_reg),
	.ci(1'b1),
	.s(),
	.co(l_upper_bound_1) 		//l_upper_bound_1 = 1 means l_s1 <= l_l_upper_bound_v4[15:8]
);

adder_8bits adder_8bits_l_upper_bound_2_U(
	.a(l_upper_bound_v4[23:16]),
	.b(~l_s1_reg),
	.ci(1'b1),
	.s(),
	.co(l_upper_bound_2) 		//l_upper_bound_0 = 1 means l_s1 <= l_l_upper_bound_v4[23:16]
);

adder_8bits adder_8bits_l_upper_bound_3_U(
	.a(l_upper_bound_v4[31:24]),
	.b(~l_s1_reg),
	.ci(1'b1),
	.s(),
	.co(l_upper_bound_3) 		//l_upper_bound_0 = 1 means l_s1 <= l_l_upper_bound_v4[31:24]
);

adder_8bits adder_8bits_l_lower_bound_0_U(
	.a(l_s1_reg),
	.b(~l_lower_bound_v4[7:0]),
	.ci(1'b1),
	.s(l_offset_0),
	.co(l_lower_bound_0) 		//l_lower_bound_0 = 1 means l_s1 >= l_lower_bound_v4[7:0]
);

adder_8bits adder_8bits_l_lower_bound_1_U(
	.a(l_s1_reg),
	.b(~l_lower_bound_v4[15:8]),
	.ci(1'b1),
	.s(l_offset_1),
	.co(l_lower_bound_1) 		//l_lower_bound_1 = 1 means l_s1 >= l_lower_bound_v4[15:8]
);

adder_8bits adder_8bits_l_lower_bound_2_U(
	.a(l_s1_reg),
	.b(~l_lower_bound_v4[23:16]),
	.ci(1'b1),
	.s(l_offset_2),
	.co(l_lower_bound_2) 		//l_lower_bound_2 = 1 means l_s1 >= l_lower_bound_v4[23:16]
);

adder_8bits adder_8bits_l_lower_bound_3_U(
	.a(l_s1_reg),
	.b(~l_lower_bound_v4[31:24]),
	.ci(1'b1),
	.s(l_offset_3),
	.co(l_lower_bound_3) 		//l_lower_bound_3 = 1 means l_s1 >= l_lower_bound_v4[31:24]
);

//assign l_bound_choose = {(l_upper_bound_3 & l_lower_bound_3), (l_upper_bound_2 & l_lower_bound_2), (l_upper_bound_1 & l_lower_bound_1), (l_upper_bound_0 & l_lower_bound_0)};

assign l_index_v4 = (l_upper_bound_3 & l_lower_bound_3)?2'd3:((l_upper_bound_2 & l_lower_bound_2)?2'd2:((l_upper_bound_1 & l_lower_bound_1)?2'd1:2'd0));
assign l_offset = (l_upper_bound_3 & l_lower_bound_3)?l_offset_3:((l_upper_bound_2 & l_lower_bound_2)?l_offset_2:(((l_upper_bound_1 & l_lower_bound_1)?l_offset_1:l_offset_0)));
assign l_index = {address_lbound_reg, l_index_v4};


adder_16bits adder_16bits_d_upper_bound_1_U(
	.a(d_upper_bound_v2[31:16]),
	.b(~d_s1_reg),
	.ci(1'b1),
	.s(),
	.co(d_upper_bound_1) 		//
);

adder_16bits adder_16bits_d_upper_bound_0_U(
	.a(d_upper_bound_v2[15:0]),
	.b(~d_s1_reg),
	.ci(1'b1),
	.s(),
	.co(d_upper_bound_0) 		//
);

adder_16bits adder_16bits_d_lower_bound_1_U(
	.a(d_s1_reg),
	.b(~d_lower_bound_v2[31:16]),
	.ci(1'b1),
	.s(d_offset_1),
	.co(d_lower_bound_1) 		//
);

adder_16bits adder_16bits_d_lower_bound_0_U(
	.a(d_s1_reg),
	.b(~d_lower_bound_v2[15:0]),
	.ci(1'b1),
	.s(d_offset_0),
	.co(d_lower_bound_0) 		//
);

adder_16bits adder_16bits_d_lower_bound_0_temp_U(
	.a(d_s1_reg),
	.b(~d_lower_bound_v2[15:0]),
	.ci(1'b0),
	.s(d_offset_temp),
	.co() 		//
);

assign dbound = 16'h0001 << address_dbound_reg;
//dbound_test = 1 means d_s1_reg != dbound
assign dbound_test = (dbound[15]^d_s1_reg[15]) | (dbound[14]^d_s1_reg[14]) | (dbound[13]^d_s1_reg[13]) | (dbound[12]^d_s1_reg[12]) 
					 | (dbound[11]^d_s1_reg[11]) | (dbound[10]^d_s1_reg[10]) | (dbound[9]^d_s1_reg[9]) | (dbound[8]^d_s1_reg[8])
					 | (dbound[7]^d_s1_reg[7]) | (dbound[6]^d_s1_reg[6]) | (dbound[5]^d_s1_reg[5]) | (dbound[4]^d_s1_reg[4])
					 | (dbound[3]^d_s1_reg[3]) | (dbound[2]^d_s1_reg[2]) | (dbound[1]^d_s1_reg[1]) | (dbound[0]^d_s1_reg[0]);

//d_equ_1 = 1 means d_s1_reg == 1					 
assign d_equ_1 = (~d_s1_reg[15]) & (~d_s1_reg[14]) & (~d_s1_reg[13]) & (~d_s1_reg[12])
         & (~d_s1_reg[11]) & (~d_s1_reg[10]) & (~d_s1_reg[9]) & (~d_s1_reg[8])
         & (~d_s1_reg[7]) & (~d_s1_reg[6]) & (~d_s1_reg[5]) & (~d_s1_reg[4])
         & (~d_s1_reg[3]) & (~d_s1_reg[2]) & (~d_s1_reg[1]) & (d_s1_reg[0]);

assign d_index = (d_lower_bound_0 & d_upper_bound_0)?1'b0:1'b1;
assign d_offset = (d_lower_bound_0 & d_upper_bound_0)?d_offset_0:d_offset_1;
assign d_code_1 = {address_dbound_reg, d_index};


register_compression_reset #(.N(8)) register_l_s2_U(.d(l_s1_reg), .clk(clk), .reset(reset), .q(l_s2_reg));
register_compression_reset #(.N(5)) register_l_index_U(.d(l_index), .clk(clk), .reset(reset), .q(l_index_reg));
register_compression_reset #(.N(8)) register_l_offset_U(.d(l_offset), .clk(clk), .reset(reset), .q(l_offset_reg));

register_compression_reset #(.N(5)) register_d_code_1_U(.d(d_code_1), .clk(clk), .reset(reset), .q(d_code_1_reg));
register_compression_reset #(.N(16)) register_d_offset_U(.d(d_offset), .clk(clk), .reset(reset), .q(d_offset_reg));
register_compression_reset #(.N(16)) register_d_offset_temp_U(.d(d_offset_temp), .clk(clk), .reset(reset), .q(d_offset_temp_reg));
register_compression_reset #(.N(1)) register_dbound_test_U(.d(dbound_test), .clk(clk), .reset(reset), .q(dbound_test_reg));
register_compression_reset #(.N(1)) register_d_V_neq_0_s2_U(.d(d_V_neq_0_reg_s1), .clk(clk), .reset(reset), .q(d_V_neq_0_reg_s2));
register_compression_reset #(.N(1)) register_enable_reg_s2_U(.d(enable_reg_s1), .clk(clk), .reset(reset), .q(enable_reg_s2));
register_compression_reset #(.N(1)) register_d_index_U(.d(d_index), .clk(clk), .reset(reset), .q(d_index_reg));
register_compression_reset #(.N(4)) register_address_dbound_s2_U(.d(address_dbound_reg), .clk(clk), .reset(reset), .q(address_dbound_reg_s2));
register_compression_reset #(.N(1)) register_d_equ_1_U(.d(d_equ_1), .clk(clk), .reset(reset), .q(d_equ_1_reg));



//stage 3 port
wire	[8:0]	l_code_1;	
wire	[3:0]	l_extra_len_1;	

wire	[8:0]	l_code;

wire 	[7:0] 	l_offset_reg_s3;

wire	[4:0]	d_code_2;	
wire	[3:0]	d_extra_len_1;	

wire	[4:0]	d_code;
wire	[15:0]	d_extra_1;


wire 	[2:0]	d_huffman_len_tmp;
wire 	[4:0]	d_huffman_code_tmp;

wire 			d_V_neq_0_reg_s3;
wire 			dbound_test_reg_s3;
wire 			d_index_reg_s3;
wire 	[15:0] 	d_offset_reg_s3;
wire 	[15:0] 	d_offset_temp_reg_s3;


//stage 3
assign l_code = (d_V_neq_0_reg_s2)?l_code_1:l_s2_reg; 

adder_9bits adder_9bits_l_code_U(
	.a({4'd0, l_index_reg}),
	.b(9'b100000000),
	.ci(1'b1),
	.s(l_code_1),
	.co()
);

huffman_translate_l_extra_bits_rom  huffman_translate_l_extra_bits_rom_U(
	.address(l_index_reg), 
	.rden(enable_reg_s2), 
	.q(l_extra_len_1), 
	.clock(clk)
);

huffman_translate_ltree_rom   huffman_translate_ltree_rom_U(
	.address(l_code), 
	.rden(enable_reg_s2), 
	.q({l_huffman_len, l_huffman_code}), 
	.clock(clk)
);



assign d_code = (dbound_test_reg | d_equ_1_reg)?d_code_1_reg:d_code_2; 

adder_5bits adder_5bits_d_code_U(
	.a({d_code_1_reg}),
	.b(5'b11110),
	.ci(1'b1),
	.s(d_code_2),
	.co() 
);

huffman_translate_d_extra_bits_rom  huffman_translate_d_extra_bits_rom_U(
	.address(d_code), 
	.rden(enable_reg_s2), 
	.q(d_extra_len_1), 
	.clock(clk)
);

huffman_translate_d_extra_rom   huffman_translate_d_extra_rom_U(
	.address(address_dbound_reg_s2), 
	.rden(~dbound_test_reg), 
	.q(d_extra_1), 
	.clock(clk)
);

huffman_translate_dtree_rom  	huffman_translate_dtree_rom_U(
	.address(d_code), 
	.rden(enable_reg_s2), 
	.q({d_huffman_len_tmp, d_huffman_code_tmp}), 
	.clock(clk)
);

register_compression_reset #(.N(8)) register_l_offset_s3_U(.d(l_offset_reg), .clk(clk), .reset(reset), .q(l_offset_reg_s3));

register_compression_reset #(.N(1)) register_d_V_neq_0_s3_U(.d(d_V_neq_0_reg_s2), .clk(clk), .reset(reset), .q(d_V_neq_0_reg_s3));
register_compression_reset #(.N(1)) register_dbound_test_s3_U(.d(dbound_test_reg), .clk(clk), .reset(reset), .q(dbound_test_reg_s3));
register_compression_reset #(.N(1)) register_d_index_s3_U(.d(d_index_reg), .clk(clk), .reset(reset), .q(d_index_reg_s3));
register_compression_reset #(.N(16)) register_d_offset_s3_U(.d(d_offset_reg), .clk(clk), .reset(reset), .q(d_offset_reg_s3));
register_compression_reset #(.N(16)) register_d_offset_temp_s3_U(.d(d_offset_temp_reg), .clk(clk), .reset(reset), .q(d_offset_temp_reg_s3));

register_compression_reset #(.N(1)) register_enable_reg_s3_U(.d(enable_reg_s2), .clk(clk), .reset(reset), .q(output_ready));


//stage 4
assign l_extra = (d_V_neq_0_reg_s3)?l_offset_reg_s3:8'd0; 
assign l_extra_len = (d_V_neq_0_reg_s3)?l_extra_len_1:4'd0;

assign d_huffman_len = (d_V_neq_0_reg_s3)?d_huffman_len_tmp:3'd0;
assign d_huffman_code = (d_V_neq_0_reg_s3)?d_huffman_code_tmp:5'd0;
assign d_extra_len = (d_V_neq_0_reg_s3)?d_extra_len_1:4'd0;
assign d_extra = (d_V_neq_0_reg_s3)?((dbound_test_reg_s3)?(d_index_reg_s3?d_offset_reg_s3:d_offset_temp_reg_s3):d_extra_1):16'd0;


endmodule