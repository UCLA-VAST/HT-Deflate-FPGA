module adder_16bits(
	a,
	b,
	ci,
	s,
	co );
	
	input [15 : 0] a;
	input [15 : 0] b;
	input ci;
	output [15 : 0] s;
	output co;
	
	wire [2 : 0] c;
	

	adder_4bits adder_4bits_inst(
		.a(a[3 : 0]),
		.b(b[3 : 0]),
		.ci(ci),
		.s(s[3 : 0]),
		.co(c[0]) );
	
	mux_adder_4bits mux_adder_4bits_inst1(
		.a(a[7 : 4]),
		.b(b[7 : 4]),
		.ci(c[0]),
		.s(s[7 : 4]),
		.co(c[1]) );
	
	mux_adder_4bits mux_adder_4bits_inst2(
		.a(a[11 : 8]),
		.b(b[11 : 8]),
		.ci(c[1]),
		.s(s[11 : 8]),
		.co(c[2]) );
		
	mux_adder_4bits mux_adder_4bits_inst3(
		.a(a[15 : 12]),
		.b(b[15 : 12]),
		.ci(c[2]),
		.s(s[15 : 12]),
		.co(co) );

	
endmodule