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
	output wire memenM,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,


	input wire[31:0] readdataM,
	output wire [3:0] selM,
	output wire [1:0] sizeM,

    // input clk,
    // input resetn,  // TODO rst, low active 
	// input wire[5:0] int, // interrupt,high active

    // // cpu inst sram
    // output        inst_sram_en   ,
    // output [3 :0] inst_sram_wen  ,
    // output [31:0] inst_sram_addr ,
    // output [31:0] inst_sram_wdata,
    // input  [31:0] inst_sram_rdata,
    
	// // cpu data sram
    // output        data_sram_en   ,
    // output [3 :0] data_sram_wen  ,
    // output [31:0] data_sram_addr ,
    // output [31:0] data_sram_wdata,
    // // output [1 :0] data_sram_size ,
    // input  [31:0] data_sram_rdata,

	// debug signals
	output wire [31:0] debug_wb_pc,
	output wire [3 :0] debug_wb_rf_wen,
	output wire [4 :0] debug_wb_rf_wnum,
	output wire [31:0] debug_wb_rf_wdata
    );

	// IF
	// wire [31:0] pcF;
	// wire [31:0] instrF;

	// ID
	wire [31:0] instrD;
	wire [5 :0] opD;
	wire [5 :0] functD;
	wire 		pcsrcD;
	wire 		equalD;
	wire 		stallD;
	wire 		branchD;
	wire 		jumpD;
	wire 		jalD;
	wire 		jrD;
	wire 		balD;

	// EX
	wire 		stallE;
	wire 		flushE;
	wire [7 :0] alucontrolE;
	wire 		regdstE;
	wire 		alusrcE;
	wire 		memtoregE;
	wire 		regwriteE;

	wire 		hi_weE; // HI寄存器 - 写使能
	wire 		lo_weE; // LO寄存器 - 写使能
	wire 		div_validE;  // 除法 - 使能
	wire 		signed_divE; // 除法 - 有无符号
	
	wire 		jalE;
	wire 		balE;
	wire 		jrE;

	// MEM
	// wire 	    memwriteM;
	wire 		memtoregM;
	wire 		regwriteM;
	// wire [31:0] aluoutM;
	// wire [31:0] writedataM;
	wire [7 :0] alucontrolM;
	// wire [3 :0] selM;
	// wire [31:0] readdataM;
	// wire [1 :0] sizeM;
	// wire [3:0] rselM;

	// WB
	wire 		memtoregW;
	wire 		regwriteW;

	// ---------- inst_sram ----------
	// assign inst_sram_en = 1'b1;     	// 如果有inst_en，就用inst_en
    // assign inst_sram_wen = 4'b0;
    // assign inst_sram_addr = pcF;
    // assign inst_sram_wdata = 32'b0;
    // assign instrF = inst_sram_rdata;

	// ---------- data_sram ----------
    // assign data_sram_en = 1'b1;     	// 如果有data_en，就用data_en
    // assign data_sram_wen = selM; 		// TODO
    // assign data_sram_addr = aluoutM;
    // assign data_sram_wdata = writedataM;
    // assign readdata = data_sram_rdata;

    // assign data_sram_size = sizeM; // TODO

	// wire stallreq_from_if;
	// wire stallreq_from_mem;

	// assign stallreq_from_if = ~i_ready;
	// assign stallreq_from_mem = data_sram_en & ~d_ready;

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
		.jalE(jalE),
		.jrE(jrE),
		.balE(balE),

		// MEM stage
		.memenM(memenM),
		.memtoregM(memtoregM),
		.memwriteM(memwriteM),
		.regwriteM(regwriteM),
		.alucontrolM(alucontrolM),
		
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
		.jalE(jalE),
		.jrE(jrE),
		.balE(balE),
		.stallE(stallE),
		.flushE(flushE),

		// MEM stage
		// .memenM(memenM),
		.memtoregM(memtoregM),
		.regwriteM(regwriteM),
		.aluoutM(aluoutM),
		// .writedataM(writedataM),
		.writedata2M(writedataM), // TODO 
		.readdataM(readdataM),
		.alucontrolM(alucontrolM),
		.selM(selM),
		.sizeM(sizeM),

		// WB stage
		.memtoregW(memtoregW),
		.regwriteW(regwriteW),

		// debug output
		.pcW(debug_wb_pc),			  // 指令地址pc
		.rf_wen(debug_wb_rf_wen),	  // 写寄存器使能信号
		.writeregW(debug_wb_rf_wnum), // regfile的寄存器值WriteRegW
		.resultW(debug_wb_rf_wdata)	  // data_ram的数据值ResultW


		// // sram请求停顿
		// .stallreq_from_if(stallreq_from_if),
		// .stallreq_from_mem(stallreq_from_mem)
	    );
	
endmodule
