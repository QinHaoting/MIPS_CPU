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
	// input wire[5:0] op,
	// output wire memtoreg,memwrite,
	// output wire branch,alusrc,
	// output wire regdst,regwrite,
	// output wire jump,
	// output wire[1:0] aluop


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
	// output reg invalid,
	// output wire cp0we
    );

	wire [5:0] op;
	wire [5:0] func;
	wire [4:0] rt;
	assign op = instr[31:26];
	assign rt = instr[20:16];
	assign func = instr[5:0];

	// reg[13:0] controls;
	// assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump, jal, jr, bal, jalr, hi_we, lo_we, memen} = controls;
	// always @(*) begin
	// 	if (stallD) begin
	// 		controls <= 14'b0000000_0000_00_0;
	// 	end
	// 	else begin
	// 		controls <= 14'b0000000_0000_00_0;
	// 		case (op)
	// 			// R-型
	// 			`EXE_SPECIAL_INST: begin
	// 				// TODO 可删除？？？
	// 				controls <= 14'b1100000_0000_00_0;
	// 				case(func)
	// 					// R-型 - 逻辑
	// 					`EXE_AND:     controls <= 14'b1100000_0000_00_0;
	// 					`EXE_OR:      controls <= 14'b1100000_0000_00_0;
	// 					`EXE_XOR:     controls <= 14'b1100000_0000_00_0;
	// 					`EXE_NOR:     controls <= 14'b1100000_0000_00_0;
						
	// 					// R-型 - 移位
	// 					`EXE_SLL:     controls <= 14'b1100000_0000_00_0;
	// 					`EXE_SLLV:    controls <= 14'b1100000_0000_00_0;
	// 					`EXE_SRLV:    controls <= 14'b1100000_0000_00_0;
	// 					`EXE_SRL:     controls <= 14'b1100000_0000_00_0;
	// 					`EXE_SRA:     controls <= 14'b1100000_0000_00_0;
	// 					`EXE_SRAV:    controls <= 14'b1100000_0000_00_0;					

	// 					// R-型 - 数据移动
	// 					`EXE_MFHI:    controls <= 14'b1100000_0000_00_0; // HI寄存器 → 通用寄存器
	// 					`EXE_MFLO:    controls <= 14'b1100000_0000_00_0; // LO寄存器 → 通用寄存器
	// 					`EXE_MTHI:    controls <= 14'b0000000_0000_10_0; // 通用寄存器 → HI寄存器
	// 					`EXE_MTLO:    controls <= 14'b0000000_0000_01_0; // 通用寄存器 → LO寄存器	
						
	// 					// R-型 - 算术
	// 					`EXE_ADD:     controls <= 14'b1100000_0000_00_0;
	// 					`EXE_ADDU:    controls <= 14'b1100000_0000_00_0;
	// 					`EXE_SUB:     controls <= 14'b1100000_0000_00_0;
	// 					`EXE_SUBU:    controls <= 14'b1100000_0000_00_0;
	// 					`EXE_SLT:     controls <= 14'b1100000_0000_00_0;
	// 					`EXE_SLTU:    controls <= 14'b1100000_0000_00_0;
	// 					`EXE_MULT:    controls <= 13'b0000000_0000_11_0;
	// 					`EXE_MULTU:   controls <= 13'b0000000_0000_11_0;
	// 					`EXE_DIV:     controls <= 13'b0000000_0000_11_0;
	// 					`EXE_DIVU:    controls <= 13'b0000000_0000_11_0;						

	// 					default:  controls <= 14'b0000000_0000_00_0; //illegal op
	// 					// default:      invalid <= 1; //异常指令controls <= 14'b0000000000000;
	// 				endcase
	// 			end

	// 			// I-型
	// 			// I-型 - 逻辑运算
	// 			`EXE_ANDI: controls <= 14'b1010000_0000_00_0;
	// 			`EXE_XORI: controls <= 14'b1010000_0000_00_0;
	// 			`EXE_LUI:  controls <= 14'b1010000_0000_00_0;
	// 			`EXE_ORI:  controls <= 14'b1010000_0000_00_0;
				
	// 			// I-型 - 算术
	// 			`EXE_ADDI:  controls <= 14'b1010000_0000_00_0;
	// 			`EXE_ADDIU: controls <= 14'b1010000_0000_00_0;
	// 			`EXE_SLTI:  controls <= 14'b1010000_0000_00_0;
	// 			`EXE_SLTIU: controls <= 14'b1010000_0000_00_0;

	// 			// TODO I-型 - 访存
	// 			// `EXE_LW:   controls <= 9'b101001000; // lw
	// 			// `EXE_SW:   controls <= 9'b001010000; // sw
				
	// 			// TODO I-型 - 跳转
	// 			// `EXE_BEQ:  controls <= 9'b000100001; // beq
			
	// 			// J-型
	// 			// `EXE_J: controls <= 9'b000000100; // J

	// 			default:  controls <= 14'b0000000_0000_00_0;//illegal op
	// 		endcase
	// 	end
	// end

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
                   		// (instr[31:21] == 11'b01000000000 && instr[10:0] == 11'b00000000000)//MFC0
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
