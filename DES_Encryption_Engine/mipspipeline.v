//------------------------------------------------
// mipspipeline.v
// Sarah_Harris@hmc.edu 22 June 2007
// Pipeline MIPS processor
//------------------------------------------------

// pipeline MIPS processor

module mipspipeline(input clk, reset,
                  output [31:0] pc,
                  input  [31:0] instr,
                  output        memwrite,
                  output [31:0] aluresult, writedata,
                  input  [31:0] readdata, output memwriteM, 
                  output [31:0] aluoutM, writedataM, resultW); //added Memory wires

  wire  memtoreg;
  wire  alusrc;  
  wire  regdst;  
  wire  regwrite, jump, pcsrc, zero;
  wire [3:0]  alucontrol;  // SLL
  wire ltez;  // BLEZ
  wire jal;   // JAL
  wire lh;    // LH
  wire equalD; //output of comparator
  wire branch; //branch instruction
  wire [31:0] instrD; //D instruction
  wire enable;
  
  controller c(instrD[31:26], instrD[5:0], zero, branch,
               memtoreg, memwrite, pcsrc,
               alusrc, regdst, regwrite, jump,
               alucontrol, 
		        			ltez,  // BLEZ
					     jal,   // JAL
					     lh, 
					     equalD);   

  datapath dp(clk, reset, enable,memtoreg, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol,
              zero, pc, instr,
              aluresult, writedata, readdata, 
				      ltez,  // BLEZ
				      jal,   // JAL
				      lh, equalD, memwrite, branch, memwriteM, instrD, aluoutM, writedataM, resultW); 
endmodule

//-----------------controller------------------------------------
module controller(input  [5:0] op, funct,
                  input        zero, 
						output branch,
                  output       memtoreg, memwrite,
                  output       pcsrc, 
		              output  alusrc,      
                  output  regdst,       
		              output       regwrite,
                  output       jump,
                  output [3:0] alucontrol,  // 4 bits for SLL
		              input        ltez,        // BLEZ
		              output       jal,         // JAL
		              output       lh,
		              input equalD);         // LH
						
                  wire [1:0] aluop;
                  wire       blez;  // BLEZ

  maindec md(op, memtoreg, memwrite, branch,
             alusrc, regdst, regwrite, jump,
             aluop, blez, jal, lh);  // BLEZ, JAL, LH
  aludec  ad(funct, aluop, alucontrol);

  assign pcsrc = (branch & equalD);  //PCSrc
endmodule
//------------------------maindec-----------------------------
module maindec(input  [5:0] op,
               output       memtoreg, memwrite,
               output       branch, 
	             output  alusrc, // LUI
               output  regdst, // JAL 
	             output       regwrite,
               output       jump,
               output [1:0] aluop,
	             output       blez,   // BLEZ
	             output       jal,    // JAL
	             output       lh);    // LH

  reg [11:0] controls;  

  assign {regwrite, regdst, alusrc,
          branch, memwrite,
          memtoreg, jump, aluop, 
			 blez,   // BLEZ
			 jal,    // JAL
			 lh}     // LH
			 = controls;

  always @(*)
    case(op)
      6'b000000: controls <= 12'b1_1_0_0_0_0_0_10_000; //Rtype
      6'b100011: controls <= 12'b1_0_1_0_0_1_0_00_000; //LW
      6'b101011: controls <= 12'b0_0_1_0_1_0_0_00_000; //SW
      6'b000100: controls <= 12'b0_0_0_1_0_0_0_01_000; //BEQ
      6'b001000: controls <= 12'b1_0_1_0_0_0_0_00_000; //ADDI
      6'b000010: controls <= 12'b0_0_0_0_0_0_1_00_000; //J
      6'b001010: controls <= 12'b1_0_1_0_0_0_0_11_000; //SLTI
      6'b001111: controls <= 12'b1_0_0_0_0_0_0_00_000; //LUI
      6'b000110: controls <= 12'b0_0_0_0_0_0_0_01_100; //BLEZ
      6'b000011: controls <= 12'b1_0_0_0_0_0_1_00_010; //JAL
      6'b100001: controls <= 12'b1_0_1_0_0_1_0_00_001; //LH
      default:   controls <= 12'bxxxxxxxxxxxx; //???
    endcase
endmodule
//---------------------aludec--------------------------------
module aludec(input      [5:0] funct,
              input      [1:0] aluop,
              output reg [3:0] alucontrol); // 4-bits for SLL

  always @(*)
    case(aluop)
      2'b00: alucontrol <= 4'b0010;  // add
      2'b01: alucontrol <= 4'b1010;  // sub
		  2'b11: alucontrol <= 4'b1011;  // slt
      default: case(funct)          // RTYPE
          6'b100000: alucontrol <= 4'b0010; // ADD
          6'b100010: alucontrol <= 4'b1010; // SUB
          6'b100100: alucontrol <= 4'b0000; // AND
          6'b100101: alucontrol <= 4'b0001; // OR
          6'b101010: alucontrol <= 4'b1011; // SLT
          6'b000000: alucontrol <= 4'b0100; // SLL
          default:   alucontrol <= 4'bxxxx; // ???
        endcase
    endcase
endmodule
//------------------------datapath----------------------------
module datapath(input         clk, reset, enable,
                input         memtoreg, pcsrc,
                input         alusrc,    
		            input         regdst,   
                input         regwrite, jump,
                input  [3:0]  alucontrol, // SLL
                output        zero,
                output [31:0] pc,
                input  [31:0] instr,
                output [31:0] aluresult, writedata,
                input  [31:0] readdata,
		            output        ltez,  // BLEZ
	             	input         jal,   // JAL
	             	input         lh,
	              output equalD, 
					  input memwrite, branch, memwriteM, 
	              output [31:0] instrD, output [31:0] aluoutM, input [31:0] writedataM, output [31:0] resultW);
					  
					  
	             	wire [1:0] fBE, fAE;
	             	wire fBD, fAD;
	             	wire fE, sD, sF;  
	
  //wire [31:0] instrD; 
  //assign instrD = instrD[31:0];
  wire [4:0]  writereg;
  wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch; 
  wire [31:0] signimm, signimmsh;
  wire [31:0] srca, srcb;
  wire [31:0] comp1;
  wire [31:0] comp2;
  wire [31:0] tmpsrcb;
  wire pctemp;
  
  //D
  wire [31:0] pcplusD;
  wire [4:0] rsd, rtd, rdd;
  //W
  wire regwriteW, memtoregW;
  wire [4:0] writeregW;
  //wire [31:0] resultW;
  wire [31:0] readdataW, aluoutW;
  //E
  wire [31:0] srcaE, srcbE, rd1E, rd2E, signimmE;
  wire [4:0] rsE, rtE, rdE, writeregE;
  wire [3:0] alucontrolE;
  wire regwriteE, memtoregE, alusrcE, regdesE, memwriteE;
  //M
  wire [4:0] writeregM;
  wire regwriteM, memtoregM;
  
//-----------------------FETCH STAGE-----------------------------------------
  // next PC logic
  flopenr #(32) pcreg(clk, reset, ~sF, pcnext, pc); 
  adder       pcadd1(pc, 32'b100, pcplus4);
  sl2         immsh(signimm, signimmsh);
  adder       pcadd2(pcplusD, signimmsh, pcbranch);
  mux2 #(32)  pcbrmux(pcplus4, pcbranch, pcsrc,
                      pcnextbr);
	wire [25:0] temp;
	assign temp = instrD[25:0];
  mux2 #(32)  pcmux(pcnextbr, {pcplusD[31:28], 
                    temp, 2'b00}, 
                    jump, pcnext);

//-----------------------DECODE STAGE-------------------------------------------
  orin ors(pcsrc, jump, pctemp);
  preg1 regone(clk, ~sD, reset, pctemp,  instr[31:0], pcplus4, instrD[31:0], pcplusD);

  
  // register file logic
  regfile     rf(~clk, regwriteW, instrD[25:21],
                instrD[20:16], writeregW,
		            resultW,  
		            srca, writedata);
 
  signext     se(instrD[15:0], signimm);
 
  // ALU logic
  mux2 #(32) srcamux(srca, aluoutM, fAD, comp1);
  mux2 #(32) srcbmux(writedata,aluoutM, fBD, comp2);
  comp compa(comp1, comp2, equalD); //comparator
  
  assign rsd = instrD[25:21];
  assign rtd = instrD[20:16];
  assign rdd = instrD[15:11];
  
//-----------------------EXECUTE STAGE---------------------------------------
  
  preg2 regtwo(clk, reset, fE, regwrite, memtoreg, memwrite, alucontrol, alusrc, regdst, srca, writedata,
	rsd, rtd, rdd, signimm, regwriteE, memtoregE, memwriteE, alucontrolE, alusrcE, 
	regdesE, rd1E, rd2E, rsE, rtE, rdE, signimmE);

  mux3 #(32) alusrca(rd1E, resultW, aluoutM, fAE, srcaE);
  mux3 #(32) alusrcb(rd2E, resultW, aluoutM, fBE, tmpsrcb);
  mux2 #(32) srcbemux(tmpsrcb, signimmE, alusrcE, srcbE);

  alu         alu(srcaE, srcbE, alucontrolE, instr[10:6],  // SLL
                  aluresult, zero, ltez); // BLEZ
                  
  mux2 #(5)   wrmux(rtE, rdE, regdesE, writeregE); 
   
//------------------------MEMORY STAGE--------------------------------------------
  preg3 regthree(clk, reset, regwriteE, memtoregE, memwriteE,aluresult, tmpsrcb, writeregE,
	regwriteM, memtoregM, memwriteM, aluoutM, writedataM, writeregM);
	
//-----------------------WRITEBACK STAGE-----------------------------------------
  preg4 regfour(clk, reset, regwriteM, memtoregM, readdata, aluoutM, writeregM,
	regwriteW, memtoregW, readdataW, aluoutW, writeregW);

  mux2 #(32)  resmux(aluoutW, readdataW, memtoregW, resultW);
	
//-------------------------HAZARD UNIT-----------------------------------------
	hazardunit hu(regwriteW, regwriteM, memtoregM, regwriteE, memtoregE, branch, rsd,
	  rtd, rtE, rsE, writeregE, writeregM, writeregW, fBE, fAE, fE, fBD, fAD, sD, sF);
	
endmodule

//----------------------Hazardunit Module-----------------------------------
module hazardunit(input regwriteW, regwriteM, memtoregM, regwriteE, memtoregE, branchD,
        input [4:0] rsD, rtD, rtE, rsE, writeregE, writeregM, writeregW,
        output reg [1:0] forwardBE, forwardAE,
        output reg flushE,
        output reg forwardBD, forwardAD,
        output reg stallD, stallF);

    reg lwstall;
    reg branchstall;

always@(*)
   begin
    if((rsE != 5'b00000) && (rsE == writeregM) && regwriteM)
    begin
        forwardAE <= 2'b10;    
    end else if((rsE != 5'b00000) && (rsE == writeregW) && regwriteW)
    begin
        forwardAE <= 2'b01;
    end else
    begin
        forwardAE <= 2'b00;
    end

    if((rtE != 5'b00000) && (rtE == writeregM) && regwriteM)
    begin
        forwardBE <= 2'b10;
    end else if((rtE != 5'b00000) && (rtE == writeregW) && regwriteW)
    begin
        forwardBE <= 2'b01;
    end else
    begin
        forwardBE <= 2'b00;
    end

     lwstall <= ((rsD == rtE) || (rtD == rtE)) && memtoregE;

     forwardAD <= (rsD != 5'b00000) && (rsD == writeregM) && regwriteM;
     forwardBD <= (rtD != 5'b00000) && (rtD == writeregM) && regwriteM;

    branchstall <= (branchD && writeregE && ((writeregE == rsD) || (writeregE == rtD))) ||
              (branchD && memtoregM && ((writeregM == rsD) || (writeregM == rtD)));

     flushE <= (lwstall || branchstall);
     stallD <= (lwstall || branchstall);
     stallF <= (lwstall || branchstall);
end
endmodule