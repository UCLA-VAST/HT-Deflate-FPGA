module adder_3bits(
	a,
	b,
	ci,
	s,
	co );
	
	input [2 : 0] a;
	input [2 : 0] b;
	input ci;
	output [2 : 0] s;
	output co;
	wire [2 : 0] g;
	wire [2 : 0] p;
	wire [1 : 0] c;

	
	assign g = a & b;
	assign p = a | b;

	assign c[0] = g[0] | (p[0] & ci);
	assign c[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & ci);
	assign co = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & ci);

	assign s = (p & ~g) ^ {c[1 : 0], ci};
	
endmodule



module mux_adder_3bits(
	a,
	b,
	ci,
	s,
	co );
	
	input [2 : 0] a;
	input [2 : 0] b;
	input ci;
	output [2 : 0] s;
	output co;
	
	wire c0, c1;
	wire [2 :0] s0, s1;
	
	
	adder_3bits adder_inst1(
	   .a(a),
		.b(b),
		.ci(1'b1),
		.s(s1),
		.co(c1) );
	adder_3bits adder_inst0(
		.a(a),
	   .b(b),
		.ci(1'b0),
		.s(s0),
		.co(c0) );
	
	assign co = (ci & c1) | c0;
	assign s = ci ? s1 : s0;
	
endmodule



module adder_9bits(
	a,
	b,
	ci,
	s,
	co );

	input [8 : 0] a;
	input [8 : 0] b;
	input ci;
	output [8 : 0] s;
	output co;
	
	wire [1 : 0] c;
	

	adder_3bits adder_3bits_inst(
		.a(a[2 : 0]),
		.b(b[2 : 0]),
		.ci(ci),
		.s(s[2 : 0]),
		.co(c[0]) );
	
	mux_adder_3bits mux_adder_3bits_inst1(
		.a(a[5 : 3]),
		.b(b[5 : 3]),
		.ci(c[0]),
		.s(s[5 : 3]),
		.co(c[1]) );
	
	mux_adder_3bits mux_adder_3bits_inst2(
		.a(a[8 : 6]),
		.b(b[8 : 6]),
		.ci(c[1]),
		.s(s[8 :6]),
		.co(co) );

endmodule


