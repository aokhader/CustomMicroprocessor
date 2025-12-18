module Control #(parameter opwidth = 3)(
  input  logic [8:0] instr,       // 9-bit instruction
  output logic       RegDst, 
  output logic       Branch, 
  output logic       MemtoReg, 
  output logic       MemWrite, 
  output logic       ALUSrc, 
  output logic       RegWrite, 
  output logic       BranchNotZero,
  output logic [opwidth-1:0] ALUOp // 3-bit ALU Operation
);

  logic [2:0] opcode;
  assign opcode = instr[8:6];

  always_comb begin
    // Initialize values
    RegDst        = 'b0;
    Branch        = 'b0;
    BranchNotZero = 'b0;
    MemWrite      = 'b0;
    ALUSrc        = 'b0;
    RegWrite      = 'b0;
    MemtoReg      = 'b0;
    ALUOp         = 'b000;

    // Decode: R-types route to respective ALU operation, I/J-types disregard ALU output
    case(opcode)
      
      // MOV: 000 RRR RRR
      3'b000: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;      
        ALUOp    = 3'b000;    
      end

      // ADD: 001 RRR RRR
      3'b001: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;
        ALUOp    = 3'b001;    
      end

      // AND: 010 RRR RRR
      3'b010: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;
        ALUOp    = 3'b010;    
      end

      // XOR: 011 RRR RRR
      3'b011: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;
        ALUOp    = 3'b011;    
      end

      // LSR: 100 RRR III
      3'b100: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;      
        ALUOp    = 3'b100;    
      end

      // LD: 101 C AAAAA
      3'b101: begin
        RegWrite = 1'b1;
        
        if (instr[5] == 1'b0) begin 
          // LDM: 101 0 RRRRR (Load from MEM using a register address)
          ALUSrc   = 1'b0;    
          MemtoReg = 1'b1;
        end else begin 
          // LDI: 101 1 AAAAA (Load immediate from LUT)
          ALUSrc   = 1'b1;    
          MemtoReg = 1'b0;
        end
      end

      // STR: 110 R AAAAA
      3'b110: begin
        MemWrite = 1'b1;
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;      // ALU result unused
      end

      // BR: 111 C AAAAA
      3'b111: begin
        RegWrite = 1'b0;
        if (instr[5] == 1'b0) begin 
          // Unconditional Jump
          Branch = 1'b1;
        end else begin 
          // BNZ: Jump if r0 != 0
          BranchNotZero = 1'b1;
        end
        ALUSrc = 1'b0;
      end

    endcase
  end
  
endmodule
