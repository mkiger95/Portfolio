//-------------------------------------------------
// top.v
// Sarah_Harris@hmc.edu 23 October 2005
// Top-level module for single-cycle MIPS processor
//-------------------------------------------------

module toppipeline(input clk, reset,
                 input  [15:0] SW,
                   input  [3:0]  KEY,
                   output [17:0] LEDR, 
                  output [6:0] HEX0, HEX1, 
						 HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);


  wire [31:0] readdata, writedata, dataadr, aluoutM, writedataM, resultW; 
  wire [31:0] pc, instr;
  wire [6:0] WE;
  wire [31:0] LEDdata, newreaddata;
  wire [2:0] RDsel;
  wire memwrite, memwriteM;
  wire [31:0] message_high, message_low, cipher_high, cipher_low,cipher_high2, cipher_low2, message_high2, message_low2;
  wire [31:0] key_high, key_low;
  wire mode;
  wire [31:0] displayhex;
  
  assign message_high = 32'b 0000_0001_0010_0011_0100_0101_0110_0111; //assigned message low for encrypt
  assign message_low =  32'b 1000_1001_1010_1011_1100_1101_1110_1111; //assigned message low for encrypt
  assign key_high =     32'b 0001_0011_0011_0100_0101_0111_0111_1001; //assigned key high for encrypt/decrypt
  assign key_low =      32'b 1001_1011_1011_1100_1101_1111_1111_0001; //assigned key high for encrypt/decrypt
  assign cipher_high2 = 32'h 85e81354; //assigned cipher high for decrypt
  assign cipher_low2 =  32'h 0f0ab405; //assigned cipher  low for decrypt
  
  // instantiate processor and memories
  mipspipeline mipspipeline(clk, reset, pc, instr, memwrite, dataadr, 
                        writedata, newreaddata, memwriteM, aluoutM, writedataM, resultW);
 						
  imem imem(pc[7:2], instr);
  dmem dmem(clk, WE[0], aluoutM, writedataM, 
           readdata);
				
	 assign mode = SW[0];//set mode either encrypt or decrypt
   addrdec addrdec(aluoutM, memwriteM, WE, RDsel, SW[5:0]); //instantiation for address decoder
   
   flopenr1 WE1reg(clk, reset, SW[0], WE[1], writedataM, LEDdata); //LEDdata display
   flopenr2 WE2reg(clk, reset, SW, WE, writedataM, displayhex); //7 seg display
   
   //mux selector
   mux8 #(32) IOsel(readdata, {31'b0, SW[0]}, message_low, key_low, cipher_low, cipher_low2, 
   message_low2, cipher_low, RDsel, newreaddata);
				  
	//instantiates encryption and decryption modules			  
	des_encrypt des_encrypt(cipher_high, cipher_low, message_high, message_low, key_high, key_low);
  des_decrypt des_decrypt(message_high2, message_low2, cipher_high2, cipher_low2, key_high, key_low);
	
  assign LEDR = LEDdata[17:0]; //set red LEDs to LEDdata
  
  //instantiates seven segments
	hexto7seg hexto7seg0(displayhex[3:0],   HEX0);
	hexto7seg hexto7seg1(displayhex[7:4],   HEX1);
	hexto7seg hexto7seg2(displayhex[11:8],  HEX2);
	hexto7seg hexto7seg3(displayhex[15:12], HEX3);
	
	hexto7seg hexto7seg4(displayhex[19:16], HEX4);
	hexto7seg hexto7seg5(displayhex[23:20], HEX5);
	hexto7seg hexto7seg6(displayhex[27:24], HEX6);
	hexto7seg hexto7seg7(displayhex[31:28], HEX7);
endmodule

//****************************address decoder*************************************************************
module addrdec(input [31:0] addr, input memwrite, output [6:0] WE, output reg [2:0] RDsel, input [5:0] sw);
  always@(*) begin
			//lw
			if(~memwrite) begin
				case(addr[15:0])
					16'hfff0: RDsel <= 3'b001; //SW
					16'hfff8: RDsel <= 3'b010; //message_low
					16'h0000: RDsel <= 3'b011; //key_low
					16'h0008: RDsel <= 3'b100; //cipher_low
					16'h0010: RDsel <= 3'b101; //cipher_low2
					16'h0018: RDsel <= 3'b110; //message_low2				
				default: RDsel <= 3'b000;
				endcase
			end
			else RDsel <= 3'b000;
	end
	
	//sw
	assign WE[1] = (memwrite & (addr[15:0] == 16'hfff4) & (sw[0])); //LED           000001
	assign WE[2] = (memwrite & (addr[15:0] == 16'hfffc) & (sw[1])); //message_low   000010
	assign WE[3] = (memwrite & (addr[15:0] == 16'h0004) & (sw[2])); //key_low       000100
	assign WE[4] = (memwrite & (addr[15:0] == 16'h000c) & (sw[3])); //cipher_low    001000
	assign WE[5] = (memwrite & (addr[15:0] == 16'h0014) & (sw[4])); //cipher_low2   010000
	assign WE[6] = (memwrite & (addr[15:0] == 16'h001c) & (sw[5])); //message_low2  100000
	

	assign WE[0] = memwrite & ~WE[1] & ~WE[2] & ~WE[3] & ~WE[4] & ~WE[5] & ~WE[6];
	
endmodule
//-----------------------------7 seg module---------------------------------------------------------
module hexto7seg(input [3:0] x, output reg [6:0] z);
	always @(*)
	case (x)
		4'b0000 :      	//Hexadecimal 0
			z = 7'b1000000;
		4'b0001 :    		//Hexadecimal 1
			z = 7'b1111001;
		4'b0010 :  		// Hexadecimal 2
			z = 7'b0100100; 
		4'b0011 : 		// Hexadecimal 3
			z = 7'b0110000;
		4'b0100 :		// Hexadecimal 4
			z = 7'b0011001;
		4'b0101 :		// Hexadecimal 5
			z = 7'b0010010;  
		4'b0110 :		// Hexadecimal 6
			z = 7'b0000010;
		4'b0111 :		// Hexadecimal 7
			z = 7'b1111000;
		4'b1000 :     		 //Hexadecimal 8
			z = 7'b0000000;
		4'b1001 :    		//Hexadecimal 9
			z = 7'b0010000;
		4'b1010 :  		// Hexadecimal A
			z = 7'b0001000; 
		4'b1011 : 		// Hexadecimal B
			z = 7'b0000011;
		4'b1100 :		// Hexadecimal C
			z = 7'b1000110;
		4'b1101 :		// Hexadecimal D
			z = 7'b0100001;
		4'b1110 :		// Hexadecimal E
			z = 7'b0000110;
		4'b1111 :		// Hexadecimal F
			z = 7'b0001110;
	endcase
endmodule
//------------------------------reg for switch-------------------------------------------------
module flopenr1 (input clk, reset, SW,
                 input en,
                 input [31:0] d, 
                 output reg [31:0] q);
 
  always @(posedge clk)
    if (en & SW)   
      q <= d;
  else
    q <=0;
endmodule
//-------------------------------reg for 7 seg-------------------------------------------------
module flopenr2(input clk, reset, input [15:0] SW, input [6:0] WE, 
          input [31:0] writedataM, output reg [31:0] displayhex);
 
always@(*)
   begin
    if(SW[1] & WE[2])
		begin
        displayhex <= writedataM;    //sets message low
		end 
	 else if(SW[2] & WE[3])
    begin
         displayhex <= writedataM; //sets key low
    end else if(SW[3] & WE[4])
    begin
         displayhex <= writedataM; //sets cipher low
    end
	 else if(SW[4] & WE[5])
    begin
         displayhex <= writedataM; //sets cipher low 2
    end
	 else if(SW[5] & WE[6])
    begin
         displayhex <= writedataM; //sets  message low 2
    end
	
    else
	 begin
		displayhex = 32'b0000_0000_0000_0000_0000_0000_0000_0000; //sets to zero
   end
	 end
endmodule