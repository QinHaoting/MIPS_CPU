`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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
module maindec(
	input wire stallD,
	input wire[31:0] instr,
	output wire memtoreg,
	output wire memwrite, //   访存 - 写使能
	output wire memen, 	  // TODO 访存 - 使能
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump, jal, jr, bal, // 转移指令 - 控制信号
	output wire hi_we, // HI寄存器 - 写使能
	output wire lo_we, // LO寄存器 - 写使能
	output wire div_valid, // 除法 - 使能
	output wire signed_div // 除法 - 有无符号
    );

	wire [5:0] op;
	wire [5:0] func;
	wire [4:0] rt;
	assign op = instr[31:26];
	assign rt = instr[20:16];
	assign func = instr[5:0];

	// 写回寄存器 - 写使能信号
	assign regwrite = (
					   // ①逻辑
					   (op == `EXE_ANDI)  ||
					   (op == `EXE_ORI)   ||
					   (op == `EXE_XORI)  ||
					   (op == `EXE_LUI)   ||
					   // ③数据移动 & 乘除法
					   (op == `EXE_SPECIAL_INST && func != `EXE_MTHI && func != `EXE_MTLO && func != `EXE_MULT && func != `EXE_MULTU && func != `EXE_DIV && func != `EXE_DIVU) ||
					   // ④算术
					   (op == `EXE_ADDI)  ||
					   (op == `EXE_ADDIU) ||
					   // ⑤跳转
					   (op == `EXE_SLTI)  ||
					   (op == `EXE_SLTIU) ||
					   (op == `EXE_JAL)   ||
					   (op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL) ||
					   (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL) ||
					   // ⑥访存 - LW
					   (op == `EXE_LB)    ||
					   (op == `EXE_LBU)   ||
					   (op == `EXE_LH)    ||
					   (op == `EXE_LHU)   ||
					   (op == `EXE_LW)
                   ) && ~stallD; 

	assign regdst = (// R型
					 (op == `EXE_SPECIAL_INST) ||
					 (op == 6'b111111 && func == 6'b000000));

	// ALU操作数 - 控制信号
	assign alusrc = (// ①逻辑
					 (op == `EXE_ANDI) ||
                 	 (op == `EXE_ORI)  ||
                 	 (op == `EXE_XORI) ||
					 (op == `EXE_LUI)  ||
					 // ④算术
					 (op == `EXE_ADDI)  ||
                 	 (op == `EXE_ADDIU) ||
                 	 (op == `EXE_SLTI)  ||
                 	 (op == `EXE_SLTIU) ||
					
					 // ⑥访存
					 // ⑥访存 - Load
                 	 (op == `EXE_LB)  ||
                 	 (op == `EXE_LB)  ||
                 	 (op == `EXE_LBU) ||
                 	 (op == `EXE_LH)  ||
                 	 (op == `EXE_LHU) ||
                 	 (op == `EXE_LW)  ||
					 // ⑥访存 - Store
                 	 (op == `EXE_SB)  ||
                 	 (op == `EXE_SH)  ||
                 	 (op == `EXE_SW)) && ~stallD;
	
	// ③数据移动指令 - 控制信号
	// ③数据移动指令 - 控制信号 - HI寄存器 - 写使能
	assign hi_we = // 数据移动
				   (op == `EXE_SPECIAL_INST && func == `EXE_MTHI)  ||
				   // 算术 - 乘法
				   (op == `EXE_SPECIAL_INST && func == `EXE_MULT)  ||
				   (op == `EXE_SPECIAL_INST && func == `EXE_MULTU) ||
				   // 算术 - 除法
				   (op == `EXE_SPECIAL_INST && func == `EXE_DIV)   ||
				   (op == `EXE_SPECIAL_INST && func == `EXE_DIVU);
	
	// ③数据移动指令 - 控制信号 - LO寄存器 - 写使能
	assign lo_we = // 数据移动
				   (op == `EXE_SPECIAL_INST && func == `EXE_MTLO)  ||
				   // 算术 - 乘法
				   (op == `EXE_SPECIAL_INST && func == `EXE_MULT)  ||
				   (op == `EXE_SPECIAL_INST && func == `EXE_MULTU) ||
				   // 算术 - 除法
				   (op == `EXE_SPECIAL_INST && func == `EXE_DIV)   ||
				   (op == `EXE_SPECIAL_INST && func == `EXE_DIVU);


	// ④算术指令 - 控制信号
	// ④算术指令 - 控制信号 - 除法 - 使能
	assign div_valid = (((op == `EXE_SPECIAL_INST && func == `EXE_DIV) || 
						 (op == `EXE_SPECIAL_INST && func == `EXE_DIVU))) && ~stallD;
	// ④算术指令 - 控制信号 - 除法 - 有无符号
	assign signed_div = (op == `EXE_SPECIAL_INST && func == `EXE_DIV) && ~stallD;


	// ⑤转移指令 - 控制信号
	// ⑤转移指令 - 控制信号
	assign branch = ((op == `EXE_BEQ)  || // BEQ组
                 	 (op == `EXE_BNE)  ||
                 	 (op == `EXE_BLEZ) || // BGEZ组
                 	 (op == `EXE_BGTZ) ||
                 	 (op == `EXE_REGIMM_INST && rt == `EXE_BLTZ)   || // R型 - BGEZ组
					 (op == `EXE_REGIMM_INST && rt == `EXE_BGEZ)   ||
                 	 (op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL) || // R型 - BGEZ & Link组
                 	 (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL));
	
	// ⑤转移指令 - 控制信号 - J组
	assign jump = (op == `EXE_J) ||
               	  (op == `EXE_SPECIAL_INST && func == `EXE_JR);
	
	// ⑤转移指令 - 控制信号 - JAL组
	assign jal = ((op == `EXE_JAL));
	
	// ⑤转移指令 - 控制信号 - JR组
	assign jr = ((op == `EXE_SPECIAL_INST && func == `EXE_JR) ||
                 (op == `EXE_SPECIAL_INST && func == `EXE_JALR));
	
	// ⑤转移指令 - 控制信号 - BGEZ & Link组
	assign bal = ((op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL) ||
              	  (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL));


	// ⑥访存指令 - 控制信号
	// ⑥访存指令 - 控制信号 - Store指令
	assign memwrite = (op == `EXE_SB) || 
					  (op == `EXE_SH) || 
					  (op == `EXE_SW) && ~stallD;

	// ⑥访存指令 - 控制信号 - Load指令
	assign memtoreg = ((op == `EXE_LB)  ||
                   	   (op == `EXE_LBU) ||
                   	   (op == `EXE_LH)  ||
                   	   (op == `EXE_LHU) ||
                   	   (op == `EXE_LW)) && ~stallD;
endmodule
