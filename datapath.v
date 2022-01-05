`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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

`include "defines.vh"
module datapath(
	input wire clk,rst,
	// IF stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	
	// ID stage
	input wire pcsrcD,
	input wire branchD, jumpD, 
	input wire jalD, jrD, balD,
	output wire equalD,
	output wire stallD,
	output wire [31:0] instrD,

	output wire[5:0] opD,functD,
	
	// EX stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[7:0] alucontrolE,
	input wire hi_weE, lo_weE, 			// HI、LO寄存器 - 写使能信号
	input wire div_validE, signed_divE, // 除法 - 使能、有无符号
	input wire jalE,jrE,balE,
	output wire stallE,
	output wire flushE,
	
	// MEM stage
	input wire memenM,
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM, 
	output wire[31:0] writedata2M,
	input wire[31:0] readdataM,
	// 访存
	input wire[7:0] alucontrolM,
	output wire[3:0] selM,
	output wire [1:0] sizeM,
	// output wire[3:0] rselM,

	// output wire flush_except,
	
	// WB stage
	input wire memtoregW,
	input wire regwriteW,


	output wire[31:0] pcW,		  // PC
	output wire[3 :0] rf_wen,	  // 
	output wire[4 :0] writeregW,  // 写入寄存器
	output wire[31:0] resultW	  // 写入数据
    );

	
	
	// IF stage
	wire stallF;
	wire flushF;
	
	// IF-ID
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	// wire [31:0] pcnext2FD;

	wire is_in_delayslotF;
	
	// ID stage
	wire [31:0] pcD;
	wire [31:0] pcplus4D;
	wire [1:0] jumpjrjalD;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD, saD;
	// wire flushD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;

	wire is_in_delayslotD;
	

	// EX stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE, saE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
	// HI寄存器
	wire [31:0] hi_inE;
	wire [31:0] hi_outE;
	// LO寄存器
	wire [31:0] lo_inE;
	wire [31:0] lo_outE;

	// 除法stall
	wire div_stallE;
	wire [63:0] div_resE;


	// 分支跳转
	wire [31:0] pcE;
	// wire branchE, jumpE, jalE, jrE, balE;
	wire [4:0] writereg2E;
	wire [31:0] aluout2E;
	wire [31:0] pcplus8F, pcplus8D, pcplus8E;

	wire is_in_delayslotE;

	// MEM stage
	wire [31:0] pcM;
	wire [4:0] writeregM;
	wire [31:0] writedataM;
	wire [31:0] readdata2M;
	// wire [31:0] newpcM;
	// wire is_in_delayslotM;
	


	// WB stage
	// wire [4:0] writeregW;
	wire [31:0] aluoutW;
	wire [31:0] readdataW;
	// wire [31:0] resultW;
	
	assign rf_wen = {4{regwriteW}};

	// hazard detection
	hazard h(
		// IF stage
		.stallF(stallF),
		.flushF(flushF),

		// ID stage
		.rsD(rsD),
		.rtD(rtD),
		
		.branchD(branchD),
		.jumpD(jumpD), 
		.jrD(jrD),

		.forwardaD(forwardaD),
		.forwardbD(forwardbD),
		.stallD(stallD),
		// .flushD(flushD),

		// EX stage
		.rsE(rsE),
		.rtE(rtE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.stallE(stallE),
		.flushE(flushE),
		.div_stallE(div_stallE),

		// MEM stage
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),

		// WB stage
		.writeregW(writeregW),
		.regwriteW(regwriteW)
		
		// .excepttypeM(excepttypeM),
		// .newpcM(newpcM)

		// .flush_except(flush_except)
		);

	// next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F, pcbranchD, // 要么PC+4，要么分支
					   pcsrcD, pcnextbrFD); 
	
	// PC - 选择信号
	assign jumpjrjalD = (!jumpD & !jrD & !jalD) ? 2'b00: // 非J家族
					    ((jumpD & !jrD) | jalD) ? 2'b01: // J型 或 JAL型   ： 从
					 	(jrD)					? 2'b10: // JR型 或 JALR型 ： 从
					 							  2'b00; // 默认
	// 下一条PC的目标地址
	mux3 #(32) pcmux(pcnextbrFD, {pcplus4D[31:28],instrD[25:0],2'b00}, srca2D,
					 jumpjrjalD, pcnextFD);

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//fetch stage logic
	pc #(32) pcreg(.clk(clk), .rst(rst),
				   .en(~stallF),
				   .d(pcnextFD), .q(pcF));
	// pcflopenrc #(32) pcreg(clk,rst,~stallF,flushF,pcnextFD,newpcM,pcF);
	// pc #(32) pcreg(clk,rst,~stallF,flushF,pcnext2FD,newpcM,pcF);  //地址计算部分
	adder pcadd1(pcF,32'b100,pcplus4F);  // PC+4：当前指令的下一条指令
	adder pcadd2(pcF,32'b1000,pcplus8F); // PC+8：延迟槽指令的下一条指令

	// 异常处理
	// assign is_in_delayslotF = (branchD| jumpD | jalD | jrD | balD); // 延时槽
	// 异常类型判断
	// exception exp(rst,exceptM,tlb_except2M,adelM,adesM,status_o,cause_o,excepttypeM);

	// ID stage
	flopenrc #(32) r1D(.clk(clk), .rst(rst), .en(~stallD), .d(pcplus4F),.q(pcplus4D));
	// TODO flushD没有值
	flopenrc #(32) r2D(.clk(clk), .rst(rst), .en(~stallD), .d(instrF),  .q(instrD));
	flopenrc #(32) r3D(.clk(clk), .rst(rst), .en(~stallD), .d(pcplus8F),.q(pcplus8D));
	flopenrc #(32) r4D(.clk(clk), .rst(rst), .en(~stallD), .d(pcF),     .q(pcD));

	// flopenrc #(1) r6D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
	
	signext se(.a(instrD[15:0]), .type(instrD[29:28]), .y(signimmD));
	sl2 immsh(signimmD,signimmshD);

	adder pcadd3(pcplus4D,signimmshD,pcbranchD); // 计算分支指令的目标地址

	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);

	assign opD = instrD[31:26];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];
	assign functD = instrD[5:0];

	// EX stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);

	flopenrc #(5)  r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5)  r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5)  r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5)  r7E(.clk(clk), .rst(rst), .en(~stallE), .clear(flushE), .d(saD), .q(saE));
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	// flopenrc #(5)  r9E(clk,rst,~stallE,flushE,{branchD, jumpD, jalD, jrD, balD},{branchE, jumpE, jalE, jrE, balE});
	flopenrc #(32) r10E(clk,rst,~stallE,flushE,pcD,pcE);
	// flopenrc #(1) r11E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);
	
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	// 除法器
	divider div(.clk(~clk), .rst(rst), 
				   .a(srca2E), .b(srcb3E), 
				   .valid(div_validE), .sign(signed_divE), .div_stall(div_stallE), 
				   .result(div_resE)); 
	alu alu(
			.a(srca2E), .b(srcb3E), .alucontrol(alucontrolE), 
	        .sa(saE), 
			.hi_in(hi_inE), .lo_in(lo_inE), .hi_out(hi_outE), .lo_out(lo_outE), // HI寄存器、LO寄存器
			
			.div_res(div_resE), // 除法结果
			.y(aluoutE)
			);
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);
	mux2 #(5) wrmux2(writeregE, 5'b11111, jalE|balE, writereg2E);
	mux2 #(32) wrmux3(aluoutE, pcplus8E, jalE|jrE|balE, aluout2E);


	// MEM stage
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluout2E,aluoutM); // TODO PC
	// flopenrc #(32) r2M(.clk(clk), .rst(rst), .en(~stallM), .clear(flushM), .d(aluout2E), .q(aluoutM));
	flopr #(5) r3M(clk,rst,writereg2E,writeregM);
	flopr #(32) r5M(clk,rst,pcE,pcM); // TODO flushM
	// flopenrc #(1) r7M(clk,rst,~stallM,flushM,is_in_delayslotE,is_in_delayslotM);
	
	// HI寄存器 - MEM阶段写回
	flopenr #(32) rHIM(.clk(clk), .rst(rst), .en((hi_weE&(~flushE))), .d(hi_outE), .q(hi_inE)); // 在MEM阶段写回HI寄存器，结果为hi_inE
	// LO寄存器 - MEM阶段写回
	flopenr #(32) rLOM(.clk(clk), .rst(rst), .en((lo_weE&(~flushE))), .d(lo_outE), .q(lo_inE)); // 在MEM阶段写回LO寄存器，结果为lo_inE

	data_mem_sel data_mem_sel(.op(alucontrolM), .addr(aluoutM[1:0]), 
							  .writedata(writedataM), .readdata(readdataM),
							  .sel(selM),
							//   .rsel(rselM),
							  .writedata2(writedata2M), .readdata2(readdata2M),
							//   .adel(adelM), .ades(adesM),
							  .size(sizeM));


	// WB stage
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdata2M,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);
	flopr #(32) r5W(clk,rst,pcM,pcW);

	//W阶段处理MTC0，M阶段处理异常
	// cp0 CP0(// ---input---
	// 		.clk(clk), .rst(rst),
	// 		.we_i(cp0weW), 
	// 		.waddr_i(rdW), 
	// 		.raddr_i(rdE),
	// 		.data_i(aluoutW), 
	// 		.int_i(6'b000000), 
	// 		.excepttype_i(excepttypeM),
	// 		.current_inst_addr_i(pcM), 
	// 		.is_in_delayslot_i(is_in_delayslotM),
	// 		.bad_addr_i(bad_addrM), 
	// 		// ---output---
	// 		.data_o(cp0dataE), 
	// 		.count_o(count_oW),		// Count
	// 		.compare_o(compare_oW), 
	// 		.status_o(status_oW),   // Status
	// 		.cause_o(cause_oW),		// Cause
	// 		.epc_o(epc_oW),			// EPC
	// 		.config_o(config_oW),
	// 		.prid_o(prid_oW),
	// 		.badvaddr(badvaddrM));


	
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);


endmodule
