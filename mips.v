`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM 
    );
	

	wire [31:0] instrD;

	wire [5:0] opD,functD;
	wire branchD, jumpD;
	wire jalD, jrD, balD;

	wire stallD, stallE;
	wire hi_weE, lo_weE; // HI、LO寄存器 - 写使能
	wire div_validE, signed_divE; // 除法

	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire [7:0] alucontrolE;
	wire flushE,equalD;

	controller c(
		.clk(clk),
		.rst(rst),
		
		// ID stage
		.opD(opD),
		.functD(functD),
		.pcsrcD(pcsrcD),
		.equalD(equalD),
		// 转移控制信号
		.branchD(branchD),
		.jumpD(jumpD),
		.jalD(jalD),
		.jrD(jrD),
		.balD(balD),
		
		.instrD(instrD),
		.stallD(stallD),
		
		// EX stage
		.flushE(flushE),
		.stallE(stallE),
		.memtoregE(memtoregE),
		.alusrcE(alusrcE),
		.regdstE(regdstE),
		.regwriteE(regwriteE),	
		.alucontrolE(alucontrolE),
		.hi_weE(hi_weE), // HI寄存器 - 写使能
		.lo_weE(lo_weE), // LO寄存器 - 写使能
		.div_validE(div_validE),   // 除法 - 使能
		.signed_divE(signed_divE), // 除法 - 有无符号

		// MEM stage
		.memtoregM(memtoregM),
		.memwriteM(memwriteM),
		.regwriteM(regwriteM),
		
		// WB stage
		.memtoregW(memtoregW),
		.regwriteW(regwriteW)
		);
	
	datapath dp(
		.clk(clk),
		.rst(rst),

		// IF stage
		.pcF(pcF),
		.instrF(instrF),

		// ID stage
		.pcsrcD(pcsrcD),

		.branchD(branchD),
		.jumpD(jumpD),
		.jalD(jalD),
		.jrD(jrD),
		.balD(balD),

		.equalD(equalD),
		.opD(opD),
		.functD(functD),
		.instrD(instrD),
		.stallD(stallD),

		// EX stage
		.memtoregE(memtoregE),
		.alusrcE(alusrcE),
		.regdstE(regdstE),
		.regwriteE(regwriteE),
		.alucontrolE(alucontrolE),
		.hi_weE(hi_weE), // HI寄存器 - 写使能
		.lo_weE(lo_weE), // LO寄存器 - 写使能
		.div_validE(div_validE),   // 除法 - 使能
		.signed_divE(signed_divE), // 除法 - 有无符号
		.stallE(stallE),
		.flushE(flushE),

		// MEM stage
		.memtoregM(memtoregM),
		.regwriteM(regwriteM),
		.aluoutM(aluoutM),
		.writedataM(writedataM),
		.readdataM(readdataM),

		// WB stage
		.memtoregW(memtoregW),
		.regwriteW(regwriteW)
	    );
	
endmodule
