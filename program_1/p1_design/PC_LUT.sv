module PC_LUT #(parameter D=12)(
  input  logic [4:0]   addr,	   
  output logic [D-1:0] target);

  always_comb case(addr)
	// Constants for LDI (Load immediate)
    5'd0:  target = 12'h000;   // 0x00
	5'd1:  target = 12'h001;   // 0x01
	5'd2:  target = 12'h008;   // 0x08
	5'd3:  target = 12'h010;   // 0x10 = 16
	5'd4:  target = 12'h011;   // 0x11 = 17
	5'd5:  target = 12'h0FF;   // 0xFF = for two's comp 
	5'd6:  target = 12'h080;   // 0x80 = MSB mask

	// Branch targets (absolute jumps) 
	// [as decimal list: 9, 13, 16, 20, 29, 37, 50, 52, 65, 67, 70, 73]
	5'd10: target = 12'h009;   // outer_loop
	5'd11: target = 12'h00d;   // outer_loop_cont
	5'd12: target = 12'h010;   // inner_loop
	5'd13: target = 12'h014;   // inner_loop_cont
	5'd14: target = 12'h01d;   // bit_loop
	5'd15: target = 12'h025;   // compare_min
	5'd16: target = 12'h032;   // update_min
	5'd17: target = 12'h034;   // compare_max
	5'd18: target = 12'h041;   // update_max
	5'd19: target = 12'h043;   // inner_end
	5'd20: target = 12'h046;   // outer_end
	5'd21: target = 12'h049;   // halt

	// Done flag
	5'd22: target = 12'd511;    // prog_ctr == 511 == 9'b111111111

	
	default: target = 'b0;  // hold PC  
  endcase

endmodule