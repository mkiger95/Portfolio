// Wrapper for interfacing with the switches and LEDs on the DE2-115 board

module wrapper(input CLOCK_50,
                   input  [15:0] SW,
                   input  [3:0]  KEY,
                   output [17:0] LEDR,
                   output [6:0] HEX0, HEX1, 
						 HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);

  // Use KEY[0] (push button switch 0) for reset. 

//  wire clk_out;       
  
//  altpll0 altpll0 (.inclk0(CLOCK_50), .c0(clk_out));

   toppipeline toppipeline(CLOCK_50, ~KEY[0], SW, KEY, LEDR, HEX0, HEX1, 
						 HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
						 
 // assign LEDR = {KEY[1:0], SW};
  
endmodule


