module mux_32to1(
	din0,
	din1,
	din2,
	din3,
	din4,
	din5, 
	din6,
	din7,
	din8,
	din9,
	din10,
	din11,
	din12,
	din13,
	din14,
	din15,
	din16,
	din17,
	din18,
	din19,
	din20,
	din21, 
	din22,
	din23,
	din24,
	din25,
	din26,
	din27,
	din28,
	din29,
	din30,
	din31,
	sel,
	dout
);

parameter N = 8;

input 	[N-1:0]		din0;
input 	[N-1:0]		din1;
input 	[N-1:0]		din2;
input 	[N-1:0]		din3;
input 	[N-1:0]		din4;
input 	[N-1:0]		din5;
input 	[N-1:0]		din6;
input 	[N-1:0]		din7;
input 	[N-1:0]		din8;
input 	[N-1:0]		din9;
input 	[N-1:0]		din10;
input 	[N-1:0]		din11;
input 	[N-1:0]		din12;
input 	[N-1:0]		din13;
input 	[N-1:0]		din14;
input 	[N-1:0]		din15;
input 	[N-1:0]		din16;
input 	[N-1:0]		din17;
input 	[N-1:0]		din18;
input 	[N-1:0]		din19;
input 	[N-1:0]		din20;
input 	[N-1:0]		din21;
input 	[N-1:0]		din22;
input 	[N-1:0]		din23;
input 	[N-1:0]		din24;
input 	[N-1:0]		din25;
input 	[N-1:0]		din26;
input 	[N-1:0]		din27;
input 	[N-1:0]		din28;
input 	[N-1:0]		din29;
input 	[N-1:0]		din30;
input 	[N-1:0]		din31;


input	[4:0]		sel;

output	[N-1:0]		dout;

reg		[N-1:0]		reg_dout;

always @(*)
	begin
		case(sel)
			5'd0:
			begin
				reg_dout = din0;
			end

			5'd1:
			begin
				reg_dout = din1;
			end

			5'd2:
			begin
				reg_dout = din2;
			end

			5'd3:
			begin
				reg_dout = din3;
			end

			5'd4:
			begin
				reg_dout = din4;
			end

			5'd5:
			begin
				reg_dout = din5;
			end

			5'd6:
			begin
				reg_dout = din6;
			end

			5'd7:
			begin
				reg_dout = din7;
			end

			5'd8:
			begin
				reg_dout = din8;
			end

			5'd9:
			begin
				reg_dout = din9;
			end

			5'd10:
			begin
				reg_dout = din10;
			end

			5'd11:
			begin
				reg_dout = din11;
			end

			5'd12:
			begin
				reg_dout = din12;
			end

			5'd13:
			begin
				reg_dout = din13;
			end

			5'd14:
			begin
				reg_dout = din14;
			end

			5'd15:
			begin
				reg_dout = din15;
			end

			5'd16:
			begin
				reg_dout = din16;
			end

			5'd17:
			begin
				reg_dout = din17;
			end

			5'd18:
			begin
				reg_dout = din18;
			end

			5'd19:
			begin
				reg_dout = din19;
			end

			5'd20:
			begin
				reg_dout = din20;
			end

			5'd21:
			begin
				reg_dout = din21;
			end

			5'd22:
			begin
				reg_dout = din22;
			end

			5'd23:
			begin
				reg_dout = din23;
			end

			5'd24:
			begin
				reg_dout = din24;
			end

			5'd25:
			begin
				reg_dout = din25;
			end

			5'd26:
			begin
				reg_dout = din26;
			end

			5'd27:
			begin
				reg_dout = din27;
			end

			5'd28:
			begin
				reg_dout = din28;
			end

			5'd29:
			begin
				reg_dout = din29;
			end

			5'd30:
			begin
				reg_dout = din30;
			end

			5'd31:
			begin
				reg_dout = din31;
			end

			default:
			begin
			 	reg_dout = din0;
			 end
		endcase
	end


assign dout = reg_dout;

endmodule