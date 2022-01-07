`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,

	input wire[31:0] instrD,
	
	input wire stallD,
	input wire stallE,
	// input wire stallM,

	// ID stage
	input wire[5:0] opD,functD,
	input wire equalD,
	output wire pcsrcD, 
	output wire branchD, jumpD, jalD, jrD, balD,
	
	// EX stage
	input wire flushE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[7:0] alucontrolE,
	output wire hi_weE, // HI寄存器 - 写使能信号
	output wire lo_weE, // LO寄存器 - 写使能信号
	output wire div_validE, signed_divE, // 除法控制信号
	output wire jalE, jrE, balE, // 转移控制信号

	// MEM stage
	output wire memtoregM,memwriteM,
				regwriteM,
	output wire [7:0]alucontrolM,
	output wire memenM,
	// WB stage
	output wire memtoregW,regwriteW

    );
	
	// ID stage
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire[7:0] alucontrolD;
	wire hi_weD; // HI寄存器 - 写使能信号
	wire lo_weD; // LO寄存器 - 写使能信号

	wire memenD;
	
	// EX stage
	wire memwriteE;
	wire memenE;


	maindec md(.instr(instrD),
			   .stallD(stallD),
			   .memtoreg(memtoregD),
			   .memwrite(memwriteD),
			   .memen(memenD),
			   
			   .alusrc(alusrcD),
			   .regdst(regdstD),
			   .regwrite(regwriteD),
			   
			   // ⑤转移指令
			   .branch(branchD),
			   .jump(jumpD),
			   .jal(jalD),
			   .jr(jrD),
			   .bal(balD),
			   
			   .hi_we(hi_weD),  // HI - 写使能信号
			   .lo_we(lo_weD),  // LO - 写使能信号
			   
			   .div_valid(div_validD),  // 除法 - 使能信号
			   .signed_div(signed_divD) // 除法 - 有无符号
			   );

	aludec ad(.instr(instrD),
			  .stallD(stallD),
			  .alucontrol(alucontrolD));

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(21) regE(
		.clk(clk),
		.rst(rst),
		.en(~stallE),
		.clear(flushE),
		.d({memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD, 
			hi_weD, lo_weD,
			div_validD,signed_divD,
			jalD, jrD, balD,
			memenD
			}),
		.q({memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE, 
			hi_weE, lo_weE,
			div_validE, signed_divE,
			jalE, jrE, balE,
			memenE
			})
	);


	flopr #(15) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE,
		 alucontrolE,
		 memenE},
		{memtoregM,memwriteM,regwriteM,
		 alucontrolM,
		 memenM}
		);

	flopr #(8) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
