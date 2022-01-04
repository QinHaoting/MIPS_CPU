`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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
module aludec(
	// input wire[5:0] funct,
	// input wire[1:0] aluop,
	// output reg[2:0] alucontrol

	input wire [31:0] instr,
	input wire stallD,
	output reg[7:0] alucontrol
    );

	wire [5:0]aluop;
	wire [5:0]funct;
	assign aluop = instr[31:26];
	assign funct = instr[5:0];
	always @(*) begin
		if(!stallD) begin
			case (aluop)
				`EXE_SPECIAL_INST: begin // R型
					case (funct)
						// 逻辑
						`EXE_AND:  alucontrol <= `EXE_AND_OP;
						`EXE_OR:   alucontrol <= `EXE_OR_OP;
						`EXE_XOR:  alucontrol <= `EXE_XOR_OP;
						`EXE_NOR:  alucontrol <= `EXE_NOR_OP;
						
						// 移位
						`EXE_SLL:  alucontrol <= `EXE_SLL_OP;
						`EXE_SLLV: alucontrol <= `EXE_SLLV_OP;
						`EXE_SRL:  alucontrol <= `EXE_SRL_OP;
						`EXE_SRLV: alucontrol <= `EXE_SRLV_OP;
						`EXE_SRA:  alucontrol <= `EXE_SRA_OP;
						`EXE_SRAV: alucontrol <= `EXE_SRAV_OP;
						
						// 数据移动
						`EXE_MFHI: alucontrol <= `EXE_MFHI_OP;
						`EXE_MTHI: alucontrol <= `EXE_MTHI_OP;
						`EXE_MFLO: alucontrol <= `EXE_MFLO_OP;
						`EXE_MTLO: alucontrol <= `EXE_MTLO_OP;
						
						// 算术
						// # 加法组
						`EXE_ADD:  alucontrol <= `EXE_ADD_OP;
						`EXE_ADDU: alucontrol <= `EXE_ADDU_OP;
						// # 减法组
						`EXE_SUB:  alucontrol <= `EXE_SUB_OP;
						`EXE_SUBU: alucontrol <= `EXE_SUBU_OP;
						// # 比较组
						`EXE_SLT:  alucontrol <= `EXE_SLT_OP;
						`EXE_SLTU: alucontrol <= `EXE_SLTU_OP;
						// # 乘法组
						`EXE_MULT:  alucontrol <= `EXE_MULT_OP;
						`EXE_MULTU: alucontrol <= `EXE_MULTU_OP;
						// # 除法组
						`EXE_DIV:   alucontrol <= `EXE_DIV_OP;
						`EXE_DIVU:  alucontrol <= `EXE_DIVU_OP;
						
						// 跳转
						// ⑤转移类 - JR组
						`EXE_JR:   alucontrol <= `EXE_JR_OP;
						// ⑤转移类 - JR & Link组
						`EXE_JALR: alucontrol <= `EXE_JALR_OP;
						default: // TODO 默认是啥?
							alucontrol <= `EXE_NOP_OP;
					endcase
				end
				// I型 - 逻辑
				`EXE_ANDI: alucontrol <= `EXE_ANDI_OP;
				`EXE_ORI:  alucontrol <= `EXE_ORI_OP;
				`EXE_XORI: alucontrol <= `EXE_XORI_OP;
				`EXE_LUI:  alucontrol <= `EXE_LUI_OP;

				// I型 - 算术
				// # 加法组
				`EXE_ADDI:  alucontrol <= `EXE_ADDI_OP;
				`EXE_ADDIU: alucontrol <= `EXE_ADDIU_OP;
				// # 比较组
				`EXE_SLTI:  alucontrol <= `EXE_SLTI_OP;
				`EXE_SLTIU: alucontrol <= `EXE_SLTIU_OP;
				
				// 转移
				// ⑤转移类 - J组
				`EXE_J:    alucontrol <= `EXE_J_OP;
				// ⑤转移类 - JAL组
				`EXE_JAL:  alucontrol <= `EXE_JAL_OP;
				// ⑤转移类 - BEQ组
				`EXE_BEQ:  alucontrol <= `EXE_BEQ_OP;
				`EXE_BNE:  alucontrol <= `EXE_BNE_OP;
				// ⑤转移类 - BGEZ组
				`EXE_BGTZ: alucontrol <= `EXE_BGTZ_OP;
				`EXE_BLEZ: alucontrol <= `EXE_BLEZ_OP;
				`EXE_REGIMM_INST: begin
					case (instr[20:16])
						// ⑤转移类 - BGEZ组
						`EXE_BLTZ:   alucontrol <= `EXE_BLTZ_OP;
						`EXE_BGEZ:   alucontrol <= `EXE_BGEZ_OP;
						
						// ⑤转移类 - BGEZ & Link组
						`EXE_BGEZAL: alucontrol <= `EXE_BGEZAL_OP;
						`EXE_BLTZAL: alucontrol <= `EXE_BLTZAL_OP;
						default: 
							alucontrol <= `EXE_NOP_OP;
					endcase
				end



				// 2'b00: alucontrol <= 3'b010; //add (for lw/sw/addi)
				// 2'b01: alucontrol <= 3'b110; //sub (for beq)
				// default : case (funct)
					
				// 	`EXE_ADD:alucontrol <= 3'b010; //add
				// 	`EXE_SUB:alucontrol <= 3'b110; //sub
				// 	`EXE_AND:alucontrol <= 3'b000; //and
				// 	`EXE_OR:alucontrol <= 3'b001; //or
				// 	`EXE_SLT:alucontrol <= 3'b111; //slt
				// 	default:  alucontrol <= 3'b000;
				// endcase
			endcase
		end
	end
endmodule
