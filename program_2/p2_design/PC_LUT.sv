module PC_LUT #(parameter D = 12) (
  input  logic [4:0]   addr,
  output logic [D-1:0] target
);

  always_comb begin
    case (addr)
      // Constants for LDI (Load immediate)
      5'd0:  target = 12'h000; // 0x00
      5'd1:  target = 12'h001; // 0x01
      5'd2:  target = 12'h008; // 0x08
      5'd3:  target = 12'h0FF; // 0xFF (-1)
      5'd4:  target = 12'h080; // 0x80 (MSB mask)

      // Branch targets (absolute jumps)
      5'd10: target = 12'd15;  // loop_start
      5'd11: target = 12'd22;  // check_diff
      5'd12: target = 12'd25;  // do_sub
      5'd13: target = 12'd34;  // do_add
      5'd14: target = 12'd38;  // after_condition
      5'd15: target = 12'd68;  // set_Q_msb
      5'd16: target = 12'd49;  // shift_A
      5'd17: target = 12'd53;  // set_A_msb
      5'd18: target = 12'd60;  // dec_counter
      5'd19: target = 12'd63;  // store_results
      

      // Halt (for done flag)
      5'd20: target = 12'd511; // prog_ctr == 511 == 9'b111111111

      default: target = '0;
    endcase
  end

endmodule
