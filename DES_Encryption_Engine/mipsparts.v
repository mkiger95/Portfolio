//------------------------------------------------
// mipsparts.v
// David_Harris@hmc.edu 23 October 2005
// Components used in MIPS processor
//------------------------------------------------


module regfile(input         clk, 
               input         we3, 
               input  [4:0]  ra1, ra2, wa3, 
               input  [31:0] wd3, 
               output [31:0] rd1, rd2);

  reg [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clock
  // register 0 hardwired to 0

  always @(posedge clk)
    if (we3) rf[wa3] <= wd3;	

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

module adder(input [31:0] a, b,
             output [31:0] y);

  assign y = a + b;
endmodule

module sl2(input  [31:0] a,
           output [31:0] y);

  // shift left by 2
  assign y = {a[29:0], 2'b00};
endmodule

module signext(input  [15:0] a,
               output [31:0] y);
              
  assign y = {{16{a[15]}}, a};
endmodule

module flopr #(parameter WIDTH = 8)
              (input                  clk, reset,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module flopenr #(parameter WIDTH = 8)
                (input                  clk, reset,
                 input                  en,
                 input      [WIDTH-1:0] d, 
                 output reg [WIDTH-1:0] q);
 
  always @(posedge clk, posedge reset)
    if      (reset) q <= 0;
    else if (en)    q <= d;
endmodule

//pipeline register one
module preg1(input clk, enable, reset, clr, input [31:0] rd, input [31:0] pcplusF,
      output reg [31:0] instD, output reg [31:0] pcplusD);
always@(posedge clk)

if(reset | clr)
begin
  instD <= 0;
  pcplusD <= 0;
end
else if(enable)
begin
  instD <= rd;
  pcplusD <= pcplusF;
end
endmodule
//pipeline register two
module preg2(input clk, reset, clr, regwriteD, memtoregD, 
                input memwriteD,
               input [3:0] alucontrolD,
               input alusrcD, regdesD, 
               input [31:0] rd1D, rd2D, 
               input [4:0] rsD, rtD, rdD, 
               input [31:0] signimmD, 
               output reg regwriteE, memtoregE, memwriteE,
               output reg [3:0] alucontrolE,
               output reg alusrcE, regdesE,
               output reg [31:0] rd1E, rd2E,
               output reg [4:0] rsE, rtE, rdE, 
               output reg [31:0] signimmE);

always@(posedge clk)
if(reset | clr)
begin
  regwriteE <= 0;
  memtoregE <= 0;
  memwriteE <= 0;
  alucontrolE <= 0;
  alusrcE <= 0;
  regdesE <= 0;
  rd1E <= 0;
  rd2E <= 0;
  rsE <= 0;
  rtE <= 0;
  rdE <= 0;
  signimmE <= 0;
end
else 
begin
  regwriteE <= regwriteD;
  memtoregE <= memtoregD;
  memwriteE <= memwriteD;
  alucontrolE <= alucontrolD;
  alusrcE <= alusrcD;
  regdesE <= regdesD;
  rd1E <= rd1D;
  rd2E <= rd2D;
  rsE <= rsD;
  rtE <= rtD;
  rdE <= rdD;
  signimmE <= signimmD;
end
endmodule
//pipeline register three
module preg3(input clk, reset, rwE, mtrE, mwE,
          input [31:0] aluoutE, writedataE, 
          input [4:0] writeregE, 
          output reg rwM, mtrM, mwM,
          output reg [31:0] aluoutM, writedataM,
          output reg [4:0] writeregM);
always@(posedge clk, posedge reset)
if(reset)
  begin
    rwM <= 0;
    mtrM <= 0;
    mwM <= 0;
    aluoutM <= 0;
    writedataM <= 0;
   	writeregM <= 0;
  end
else
begin
  rwM <= rwE;
  mtrM <= mtrE;
  mwM <= mwE;
  aluoutM <= aluoutE;
  writedataM <= writedataE;
  writeregM <= writeregE;
end
endmodule
//pipeline register four
module preg4(input clk, reset, rwM, mtrM, 
        input [31:0] rdM, aluoutM,
        input [4:0] writeregM,
        output reg rwW, mtrW, 
        output reg [31:0] rdW, aluoutW, 
        output reg [4:0] writeregW);
always@(posedge clk, posedge reset)
if(reset)
  begin
    rwW <= 0;
  mtrW <= 0;
  rdW <= 0;
  aluoutW <= 0;
  writeregW <= 0; 
  end
else
begin
  rwW <= rwM;
  mtrW <= mtrM;
  rdW <= rdM;
  aluoutW <= aluoutM;
  writeregW <= writeregM;
end
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule


// upimm module needed for LUI
module upimm(input  [15:0] a,
             output [31:0] y);
              
  assign y = {a, 16'b0};
endmodule

// mux3 needed for LUI
module mux3 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2,
              input  [1:0]       s, 
              output [WIDTH-1:0] y);

  assign #1 y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module mux4 #(parameter WIDTH = 32)
	(input[WIDTH -1:0] d0, d1, d2,d3,
	input [1:0] s,
	output [WIDTH-1:0] y);
assign #1 y = s[1] ? (s[0]?d3:d2):(s[0] ? d1:d0);
endmodule

module mux8 #(parameter WIDTH = 32)
	(input[WIDTH -1:0] d0, d1, d2, d3, d4, d5, d6, d7,
	input [2:0] s,
	output reg [WIDTH-1:0] y);
	always@(*)
	begin
   case(s)
		3'b000 :      	
			y = d0;
		3'b001 :    	
			y = d1;
		3'b010 :      	
			y = d2;
		3'b011 :    		
			y = d3;
		3'b100 :      
			y = d4;
		3'b101 :    	
			y = d5;
		3'b110 :      	
			y = d6;
		3'b111 :    	
			y = d7;
		endcase
	end
//assign #1 y = s[1] ? (s[0]?d3:d2):(s[0] ? d1:d0);
endmodule

//or for register one
module orin(input pcsrc, input jump, output temp);
assign temp = (pcsrc || jump);
endmodule

//comparator
module comp(input [31:0] srca, srcb, output equald);
   assign equald = (srca == srcb) ? 1'b1 : 1'b0;
endmodule