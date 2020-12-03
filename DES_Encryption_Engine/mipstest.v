//------------------------------------------------
// mipstest.v
// Sarah_Harris@hmc.edu 23 October 2005
// Testbench for single-cycle MIPS processor
//------------------------------------------------

module testbench();

  reg         clk;
  reg         reset;

	reg [3:0] KEY;
  wire [17:0] LEDR;
  wire [15:0] SW;		
  wire [6:0] HEX0, HEX1,HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

  //assign SW = 16'h0001;
  assign SW = 16'h0002;//message_low 
  //assign SW = 16'h0004;//key_low
  //assign SW = 16'h0008;//cipher_low
  //assign SW = 16'h0010;//cipher_low2
  //assign SW = 16'h0020;//message_low2 
  
  // instantiate device to be tested
  wrapper dut(clk, SW, KEY, LEDR,HEX0, HEX1, 
						 HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
  
  // initialize test
  initial
    begin
      KEY <= 4'h0; # 22; KEY <= 4'h1;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5;
    end

  // check results
  /*always@(negedge clk)
    begin
      if(memwriteM & aluoutM == 84) begin
        if(writedataM == 7)
          $display("Simulation succeeded");
        else begin
          $display("Simulation failed");
        end
        $stop;
      end
    end*/
endmodule