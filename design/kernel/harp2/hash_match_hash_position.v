// hash_match_hash_position.v

// Generated using ACDS version 16.1 196

`timescale 1 ps / 1 ps
module hash_match_hash_position (
		input  wire [31:0] data,      //  ram_input.datain
		input  wire [7:0]  wraddress, //           .wraddress
		input  wire [7:0]  rdaddress, //           .rdaddress
		input  wire        wren,      //           .wren
		input  wire        clock,     //           .clock
		input  wire        rden,      //           .rden
		output wire [31:0] q          // ram_output.dataout
	);

	hash_position_ram_2port_161_u4gsski ram_2port_0 (
		.data      (data),      //  ram_input.datain
		.wraddress (wraddress), //           .wraddress
		.rdaddress (rdaddress), //           .rdaddress
		.wren      (wren),      //           .wren
		.clock     (clock),     //           .clock
		.rden      (rden),      //           .rden
		.q         (q)          // ram_output.dataout
	);

endmodule
