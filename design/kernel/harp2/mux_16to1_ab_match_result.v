module mux_16to1_ab_match_result(
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
	sel,
	dout
);


input 	[127:0]		din0;
input 	[127:0]		din1;
input 	[127:0]		din2;
input 	[127:0]		din3;
input 	[127:0]		din4;
input 	[127:0]		din5;
input 	[127:0]		din6;
input 	[127:0]		din7;
input 	[127:0]		din8;
input 	[127:0]		din9;
input 	[127:0]		din10;
input 	[127:0]		din11;
input 	[127:0]		din12;
input 	[127:0]		din13;
input 	[127:0]		din14;
input 	[127:0]		din15;


input	[3:0]		sel;

output	[127:0]		dout;

reg		[31:0]		reg_dout_0;
reg		[31:0]		reg_dout_1;
reg		[31:0]		reg_dout_2;
reg		[31:0]		reg_dout_3;


always @(*)
	begin
		case(sel)
			4'd0:
			begin
				reg_dout_0 = din0[31:0];
			end

			4'd1:
			begin
				reg_dout_0 = din1[31:0];
			end

			4'd2:
			begin
				reg_dout_0 = din2[31:0];
			end

			4'd3:
			begin
				reg_dout_0 = din3[31:0];
			end

			4'd4:
			begin
				reg_dout_0 = din4[31:0];
			end

			4'd5:
			begin
				reg_dout_0 = din5[31:0];
			end

			4'd6:
			begin
				reg_dout_0 = din6[31:0];
			end

			4'd7:
			begin
				reg_dout_0 = din7[31:0];
			end

			4'd8:
			begin
				reg_dout_0 = din8[31:0];
			end

			4'd9:
			begin
				reg_dout_0 = din9[31:0];
			end

			4'd10:
			begin
				reg_dout_0 = din10[31:0];
			end

			4'd11:
			begin
				reg_dout_0 = din11[31:0];
			end

			4'd12:
			begin
				reg_dout_0 = din12[31:0];
			end

			4'd13:
			begin
				reg_dout_0 = din13[31:0];
			end

			4'd14:
			begin
				reg_dout_0 = din14[31:0];
			end

			4'd15:
			begin
				reg_dout_0 = din15[31:0];
			end

			default:
			begin
			 	reg_dout_0 = din0[31:0];
			 end
		endcase
	end

always @(*)
	begin
		case(sel)
			4'd0:
			begin
				reg_dout_1 = din0[63:32];
			end

			4'd1:
			begin
				reg_dout_1 = din1[63:32];
			end

			4'd2:
			begin
				reg_dout_1 = din2[63:32];
			end

			4'd3:
			begin
				reg_dout_1 = din3[63:32];
			end

			4'd4:
			begin
				reg_dout_1 = din4[63:32];
			end

			4'd5:
			begin
				reg_dout_1 = din5[63:32];
			end

			4'd6:
			begin
				reg_dout_1 = din6[63:32];
			end

			4'd7:
			begin
				reg_dout_1 = din7[63:32];
			end

			4'd8:
			begin
				reg_dout_1 = din8[63:32];
			end

			4'd9:
			begin
				reg_dout_1 = din9[63:32];
			end

			4'd10:
			begin
				reg_dout_1 = din10[63:32];
			end

			4'd11:
			begin
				reg_dout_1 = din11[63:32];
			end

			4'd12:
			begin
				reg_dout_1 = din12[63:32];
			end

			4'd13:
			begin
				reg_dout_1 = din13[63:32];
			end

			4'd14:
			begin
				reg_dout_1 = din14[63:32];
			end

			4'd15:
			begin
				reg_dout_1 = din15[63:32];
			end

			default:
			begin
			 	reg_dout_1 = din0[63:32];
			 end
		endcase
	end

always @(*)
	begin
		case(sel)
			4'd0:
			begin
				reg_dout_2 = din0[95:64];
			end

			4'd1:
			begin
				reg_dout_2 = din1[95:64];
			end

			4'd2:
			begin
				reg_dout_2 = din2[95:64];
			end

			4'd3:
			begin
				reg_dout_2 = din3[95:64];
			end

			4'd4:
			begin
				reg_dout_2 = din4[95:64];
			end

			4'd5:
			begin
				reg_dout_2 = din5[95:64];
			end

			4'd6:
			begin
				reg_dout_2 = din6[95:64];
			end

			4'd7:
			begin
				reg_dout_2 = din7[95:64];
			end

			4'd8:
			begin
				reg_dout_2 = din8[95:64];
			end

			4'd9:
			begin
				reg_dout_2 = din9[95:64];
			end

			4'd10:
			begin
				reg_dout_2 = din10[95:64];
			end

			4'd11:
			begin
				reg_dout_2 = din11[95:64];
			end

			4'd12:
			begin
				reg_dout_2 = din12[95:64];
			end

			4'd13:
			begin
				reg_dout_2 = din13[95:64];
			end

			4'd14:
			begin
				reg_dout_2 = din14[95:64];
			end

			4'd15:
			begin
				reg_dout_2 = din15[95:64];
			end

			default:
			begin
			 	reg_dout_2 = din0[95:64];
			 end
		endcase
	end

always @(*)
	begin
		case(sel)
			4'd0:
			begin
				reg_dout_3 = din0[127:96];
			end

			4'd1:
			begin
				reg_dout_3 = din1[127:96];
			end

			4'd2:
			begin
				reg_dout_3 = din2[127:96];
			end

			4'd3:
			begin
				reg_dout_3 = din3[127:96];
			end

			4'd4:
			begin
				reg_dout_3 = din4[127:96];
			end

			4'd5:
			begin
				reg_dout_3 = din5[127:96];
			end

			4'd6:
			begin
				reg_dout_3 = din6[127:96];
			end

			4'd7:
			begin
				reg_dout_3 = din7[127:96];
			end

			4'd8:
			begin
				reg_dout_3 = din8[127:96];
			end

			4'd9:
			begin
				reg_dout_3 = din9[127:96];
			end

			4'd10:
			begin
				reg_dout_3 = din10[127:96];
			end

			4'd11:
			begin
				reg_dout_3 = din11[127:96];
			end

			4'd12:
			begin
				reg_dout_3 = din12[127:96];
			end

			4'd13:
			begin
				reg_dout_3 = din13[127:96];
			end

			4'd14:
			begin
				reg_dout_3 = din14[127:96];
			end

			4'd15:
			begin
				reg_dout_3 = din15[127:96];
			end

			default:
			begin
			 	reg_dout_3 = din0[127:96];
			 end
		endcase
	end


assign dout = {reg_dout_3, reg_dout_2, reg_dout_1, reg_dout_0};

endmodule