


module mux_adder_4bits(
	a,
	b,
	ci,
	s,
	co );
	
	input [3 : 0] a;
	input [3 : 0] b;
	input ci;
	output [3 : 0] s;
	output co;
	
	wire c0, c1;
	wire [3 :0] s0, s1;
	
	
	adder_4bits adder_inst1(
	   .a(a),
		.b(b),
		.ci(1'b1),
		.s(s1),
		.co(c1) );
	adder_4bits adder_inst0(
		.a(a),
	   .b(b),
		.ci(1'b0),
		.s(s0),
		.co(c0) );
	
	assign co = (ci & c1) | c0;
	assign s = ci ? s1 : s0;
	
endmodule