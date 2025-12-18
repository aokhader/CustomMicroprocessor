// program counter
// supports both relative and absolute jumps
// use either or both, as desired
module PC #(parameter D=12)(
  input start,
  		  reset,					// synchronous reset
        clk,
		    reljump_en,             
        absjump_en,				// absolute branch enable
  input       [D-1:0] target,	// branch address
  output logic[D-1:0] prog_ctr
);

  always_ff @(posedge clk)
    if(reset)
	  prog_ctr <= '0;
  	else if(start)
      prog_ctr <= prog_ctr;	
  	else if(reljump_en)
	  prog_ctr <= prog_ctr + target;
    else if(absjump_en)
	  prog_ctr <= target;
	else
	  prog_ctr <= prog_ctr + 'b1;

endmodule