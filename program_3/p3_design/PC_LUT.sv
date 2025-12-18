module PC_LUT #(parameter D = 12) (
  input  logic [4:0]   addr,
  output logic [D-1:0] target
);

  always_comb begin
    case (addr)
      // Constants for LDI (Load immediate)
      5'd0:  target = 12'h001; // 0x01
      5'd1:  target = 12'h008; // 0x08
      5'd2:  target = 12'h0ff; // 0xFF (-1)
      5'd3:  target = 12'h080; // 0x80 (MSB mask)

      // Branch targets (absolute jumps)
      5'd4:  target = 12'h21; 
      5'd5:  target = 12'h24; 
      5'd6:  target = 12'h2d; 
      5'd7:  target = 12'h31; 
      5'd8:  target = 12'h3c; 
      5'd9:  target = 12'h40; 
      5'd10: target = 12'h47; 
      5'd11: target = 12'h4a; 
      5'd12: target = 12'h1a; 

      5'd13: target = 12'h75;       
      5'd14: target = 12'h78;      
      5'd15: target = 12'h81;           
      5'd16: target = 12'h85;           
      5'd17: target = 12'h90;        
      5'd18: target = 12'h94; 
      5'd19: target = 12'h9b;        
      5'd20: target = 12'h9e;      
      5'd21: target = 12'h6e;    
      
      5'd22: target = 12'hc8; 
      5'd23: target = 12'hcb;     
      5'd24: target = 12'hd4;       
      5'd25: target = 12'hd8;         
      5'd26: target = 12'he3; 
      5'd27: target = 12'he7; 
      5'd28: target = 12'hee; 
      5'd29: target = 12'hf1;     
      5'd30: target = 12'hc1; 
      // Halt (for done flag)
      5'd31: target = 12'd511; // prog_ctr == 511 == 9'b111111111

      default: target = '0;
    endcase
  end

endmodule
