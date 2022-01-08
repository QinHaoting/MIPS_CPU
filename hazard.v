`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hazard(
	//fetch stage
	output wire stallF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD, 
	input wire jumpD, jrD,
	output wire forwardaD,forwardbD,
	output wire stallD,
	output flushD,
	//execute stage
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	input wire div_stallE,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushF, flushE,
	output wire stallE,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,

	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW
    );


	wire lwstallD, branchstallD;
	wire jrstall;

	//forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	//forwarding sources to E stage (ALU)
	// TODO 数据前推的问题
	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			/* code */
			if(rsE == writeregM & regwriteM) begin
				/* code */
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				/* code */
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			/* code */
			if(rtE == writeregM & regwriteM) begin
				/* code */
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				/* code */
				forwardbE = 2'b01;
			end
		end
	end

	//stalls
	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD); // TODO : rtE == rtD？
	assign branchstallD =  // 条件①是分支指令      // 条件②(i)      // 条件②(ii)
							((branchD & regwriteE & (writeregE == rsD | writeregE == rtD)) | 
							 (branchD & memtoregM & (writeregM == rsD | writeregM == rtD))); 

	assign jrstall =  // 条件①jr和jalr指令（涉及临时的写回寄存器temp）   // 条件②(i)   // 条件②(ii)
	 				 (jumpD & jrD & regwriteE & (writeregE == rsD | writeregE == rtD)) |
					 (jumpD & jrD & memtoregM & (writeregM == rsD | writeregM == rtD));
	
	assign stallF = (lwstallD |branchstallD | div_stallE | jrstall);
				
	assign stallD = stallF;

	assign stallE = div_stallE;

	assign stallW = 0;
	
	assign flushE = (lwstallD | branchstallD | jumpD);
endmodule
