module top_level(
  input        clk, reset, start, 
  output logic done
);
  // Parameters
  parameter D = 12;   // Program Counter width
  parameter A = 3;    // ALU command bit width

  // Wires & Logic
  wire [D-1:0] target, prog_ctr;
  
  wire [7:0] datA, datB, rslt, immed, mem_out, lut_data;
  logic [7:0] muxB, mem_addr;
  logic [2:0] rd_addrA, rd_addrB, wr_addr;
  
  wire [8:0] mach_code;
  wire [2:0] opcode;
  wire [A-1:0] alu_cmd;
	
  wire RegWrite, MemWrite, ALUSrc, MemtoReg, Branch, BranchNotZero;
  wire branch_taken;


  // Absolute jumps enable
  assign branch_taken = Branch | (BranchNotZero & (datA != 8'b0));
  assign opcode       = mach_code[8:6];

  // Program Counter
  PC #(.D(D)) pc1 (
    .reset       (reset),
    .start		 (start),
    .clk         (clk),
    .reljump_en  (1'b0),        // Not using relative jumps
    .absjump_en  (branch_taken),
    .target      (target),
    .prog_ctr    (prog_ctr)
  );

  // LUT for absolute jumps
  PC_LUT #(.D(D)) pl1 (
    .addr   (mach_code[4:0]),   // LUT index from instruction
    .target (target)
  );
  assign lut_data = target[7:0]; // Lower byte used for LDI constants

  // Instruction Memory
  instr_ROM ir1 (
    .prog_ctr (prog_ctr),
    .mach_code(mach_code)
  );

  // Control Unit
  Control ctl1 (
    .instr        (mach_code),
    .RegDst       (), 
    .Branch       (Branch),
    .BranchNotZero(BranchNotZero),
    .MemWrite     (MemWrite), 
    .ALUSrc       (ALUSrc), 
    .RegWrite     (RegWrite),     
    .MemtoReg     (MemtoReg),
    .ALUOp        (alu_cmd)
  );

  // Register Addresses
  always_comb begin
    rd_addrA = mach_code[5:3];
    rd_addrB = mach_code[2:0];

    case (opcode)
      3'b101: begin
        if (mach_code[5] == 1'b0) begin
          // LDM: address register encoded in lower bits
          rd_addrA = mach_code[2:0];
          rd_addrB = mach_code[2:0];
        end else begin
          // LDI: no register operands; keep reads on r0
          rd_addrA = 3'b000;
          rd_addrB = 3'b000;
        end
      end
      3'b110: begin
        // STR: choose r0 or r1 as source; depends on control bit
        rd_addrA = mach_code[5] ? 3'b001 : 3'b000;
        rd_addrB = rd_addrA;
      end
      3'b111: begin
        // BR/BNZ: choose to read register r0 for jumps
        rd_addrA = 3'b000;
        rd_addrB = 3'b000;
      end
    endcase
  end

  // Immediate value 
  assign immed = {5'b0, mach_code[2:0]}; // 3-bit immediate

  // Register File 
  logic [7:0] regfile_dat;

  assign wr_addr     = (opcode == 3'b101) ? 3'b000 : rd_addrA; // Loads always write to r0, else write to rd_addrA
  assign regfile_dat = MemtoReg ? mem_out : rslt; // Write either memory output or ALU result into the register

  reg_file #(.pw(3)) rf1 (
    .dat_in    (regfile_dat),
    .clk       (clk),
    .wr_en     (RegWrite),
    .rd_addrA  (rd_addrA),
    .rd_addrB  (rd_addrB),
    .wr_addr   (wr_addr),
    .datA_out  (datA),
    .datB_out  (datB)
  );

  // ALU
  always_comb begin
    muxB = datB; // default to register operand
    if (opcode == 3'b100) begin
      muxB = immed;          // LSR uses immediate shift amount
    end else if ((opcode == 3'b101) && (mach_code[5] == 1'b1)) begin
      muxB = lut_data;       // LDI pulls constant from LUT
    end
  end
  
  // muxB's value is one of three: 2nd register operand, immediate shift amount, or constant from LUT

  alu alu1 (
    .alu_cmd  (alu_cmd),
    .inA      (datA),
    .inB      (muxB),
    .rslt     (rslt)
  );

  // Data Memory
  always_comb begin
    mem_addr = datA; // Default to address from register; LDM uses register-based memory indexing
    if (opcode == 3'b110) begin
      mem_addr = {3'b000, mach_code[4:0]};  // STR uses immediate address
    end
  end

  dat_mem dm (
    .dat_in  (datA),      // rd_addrA selects either r0 or r1 for STR; depends on control bit
    .clk     (clk),
    .wr_en   (MemWrite & ~start), // Disables writing to data memory while start is asserted
    .addr    (mem_addr),
    .dat_out (mem_out)
  );

  // Done signal
  assign done = (prog_ctr == 9'b111111111); // Unused instruction

endmodule
