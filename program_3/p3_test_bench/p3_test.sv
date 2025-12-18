`include "top_level.sv"
`include "alu.sv"
`include "dat_mem.sv"
`include "PC.sv"
`include "PC_LUT.sv"
`include "reg_file.sv"
`include "instr_ROM.sv"
`include "Control.sv"

// program 3    CSE141L   product D = OpA * OpB * OpC  
// operands are 8-bit two's comp integers, product is 24-bit two's comp integer
// revised 2025.11.12 to resolve endianness of product and reset connection disparity against the assignment writeup
module test_bench;

// connections to DUT: clk (clock), reset, start (request), done (acknowledge) 
  bit  clk,
       reset = 'b1,				 // should set your PC = 0
       start = 'b1;				 // falling edge should initiate the program
  wire done;					 // you return 1 when finished

  logic signed[ 7:0] OpA, OpB,OpC;
  logic signed[23:0] Prod;	    // holds 2-byte product		  

  top_level D1(.clk  (clk  ),	        // your design goes here
         .reset(reset),
		 .start(start),
		 .done (done )); 

  always begin
    #50ns clk = 'b1;
	#50ns clk = 'b0;
  end

  logic signed [7:0] A [0:7];
  logic signed [7:0] B [0:7];
  logic signed [7:0] C [0:7];

  integer i;

  initial begin
    A[0]=  0;  B[0]=  1;  C[0]=  1;
    A[1]=  2;  B[1]=  3;  C[1]=  4;
    A[2]= -2;  B[2]=  -20;  C[2]=  4;
    A[3]=  5;  B[3]= -6;  C[3]=  7;
    A[4]= -8;  B[4]= -2;  C[4]=  4;
    A[5]= 32;  B[5]= 32;  C[5]= -32;
    A[6]= 10;  B[6]=  10;  C[6]=  5;
    A[7]= -1;  B[7]= -1;  C[7]= -1;

    for (i = 0; i < 8; i = i + 1) begin
      #100ns;
      OpA = A[i];
      OpB = B[i];
      OpC = C[i];

      D1.dm.core[0] = OpA;
      D1.dm.core[1] = OpB;
      D1.dm.core[2] = OpC;

      #10ns   $display("%d, %d, %d",OpA, OpB, OpC);
      #10ns   Prod = OpA * OpB * OpC;
      #10ns   reset = 'b0;
	  #10ns   start = 'b0;

      #200ns wait (done);

      if({D1.dm.core[4], D1.dm.core[5], D1.dm.core[6]} == Prod)
	    $display("Yes! %d * %d * %d = %d",OpA,OpB,OpC,Prod);
	  else
	    $display("Boo! %d * %d * %d should = %d",OpA,OpB,OpC,Prod);

      #20ns start = 'b1;
	  #10ns reset = 'b1;
    end 
	$stop;
  end


endmodule