module adder_8bits(
	a,
	b,
	ci,
	s,
	co );
	
	input [7 : 0] a;
	input [7 : 0] b;
	input ci;
	output [7 : 0] s;
	output co;
	
	wire  c;
	

	adder_4bits adder_4bits_inst(
		.a(a[3 : 0]),
		.b(b[3 : 0]),
		.ci(ci),
		.s(s[3 : 0]),
		.co(c) );
	
	mux_adder_4bits mux_adder_4bits_inst1(
		.a(a[7 : 4]),
		.b(b[7 : 4]),
		.ci(c),
		.s(s[7 : 4]),
		.co(co) );
		

	
endmodule