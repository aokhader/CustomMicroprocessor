module alu(
  input  logic [2:0] alu_cmd,    // ALU instructions
  input  logic [7:0] inA, inB,   // 8-bit wide data path
  
  output logic [7:0] rslt
);

  always_comb begin 
    rslt = 'b0;            
    
    // R-type operations
    case(alu_cmd)
      3'b000: rslt = inB;                 // MOV 
      3'b001: rslt = inA + inB;           // ADD
      3'b010: rslt = inA & inB;           // AND
      3'b011: rslt = inA ^ inB;           // XOR
      3'b100: rslt = inA >> inB[2:0];     // LSR (Logical Shift Right)
    endcase
  end
   
endmodule