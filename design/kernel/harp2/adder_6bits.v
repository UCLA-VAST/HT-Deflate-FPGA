module adder_6bits(
	a,
	b,
	ci,
	s,
	co );
	
	input [5 : 0] a;
	input [5 : 0] b;
	input ci;
	output [5 : 0] s;
	output co;
	wire [5 : 0] g;
	wire [5 : 0] p;
	wire [4 : 0] c;

	
	assign g = a & b;
	assign p = a | b;
	
	assign c[0] = g[0] | (p[0] & ci);
	assign c[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & ci);
	assign c[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & ci);
	assign c[3] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & ci);
	assign c[4] = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]) | (p[4] & p[3] & p[2] & p[1] & g[0]) | (p[4] & p[3] & p[2] & p[1] & p[0] & ci);
	assign co = g[5] | (p[5] & g[4]) | (p[5] & p[4] & g[3]) | (p[5] & p[4] & p[3] & g[2]) | (p[5] & p[4] & p[3] & p[2] & g[1])  | (p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & ci);
	
	assign s = (p & ~g) ^ {c[4 : 0], ci};
	
	
endmodule