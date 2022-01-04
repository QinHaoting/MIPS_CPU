`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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
module alu(
	// input wire clk,		// 时钟
	// input wire rst,		// 复位

	input wire[31:0] a, // 操作数A
	input wire[31:0] b, // 操作数B
	input wire[7:0] alucontrol, // ALU控制信号
	
	input wire[4:0] sa, // 移位立即数
	
	input wire[31:0] hi_in,  // HI寄存器 - 输入
	input wire[31:0] lo_in,  // LO寄存器 - 输入
	output reg[31:0] hi_out, // HI寄存器 - 输出
	output reg[31:0] lo_out, // LO寄存器 - 输出
	
	// output wire stall_d,

	input wire[63:0] div_res, // 除法结果


	output reg[31:0] y,  // 输出结果
	output reg overflow, // 溢出
	output wire zero	 // 零标志
    );

	// ################## 算术 - 乘法 ##################
	// wire mult_sign_we;
	// wire mult_unsign_we;
	// wire [63:0] mul_result_sign; // 乘法结果
	// wire [63:0] mul_result_unsign;
	// assign mult_sign_we = (alucontrol == `EXE_MULT_OP);
	// assign mult_unsign_we = (alucontrol == `EXE_MULTU_OP);
	

	// TODO 性能优化：没有使能信号会一直进行乘法操作
	// 有符号乘法实现
	// multiplier_sign mult_sign(
	// 	.CLK(clk),  // input wire CLK
	// 	.A(a),      // input wire [31 : 0] A
	// 	.B(b),      // input wire [31 : 0] B
	// 	// .CE(mult_sign_we),      // 使能
	// 	.P(mul_result_sign)      // output wire [63 : 0] P
	// );

	// 无符号乘法实现
	// multiplier_unsign mult_unsign(
	// 	.CLK(clk),  // input wire CLK
	// 	.A(a),      // input wire [31 : 0] A
	// 	.B(b),      // input wire [31 : 0] B
	// 	// .CE(mult_unsign_we),      // 使能
	// 	.P(mul_result_unsign)      // output wire [63 : 0] P
	// );
	// ################## 算术 - 乘法 ##################

	always @(*) begin
		case (alucontrol)
			// ①8条逻辑运算指令
			`EXE_AND_OP:  y <= a & b; // and  - 与
			`EXE_ANDI_OP: y <= a & b; // andi - 与
			`EXE_OR_OP:   y <= a | b; // or  - 或
			`EXE_ORI_OP:  y <= a | b; // ori - 或
			`EXE_XOR_OP:  y <= a ^ b; // xor  - 异或
			`EXE_XORI_OP: y <= a ^ b; // xori - 异或
			`EXE_NOR_OP:  y <= ~(a | b); // nor - 或非
			`EXE_LUI_OP:  y <= {b[15:0], 16'b0}; // lui
			
			// ②6条移位运算指令
			`EXE_SLL_OP:   y <= b << sa;     // sll  - 逻辑左移
			`EXE_SLLV_OP:  y <= b << a[4:0]; // sllv - 逻辑左移
			`EXE_SRL_OP:   y <= b >> sa;	 // srl  - 逻辑右移，最高位用0补
			`EXE_SRLV_OP:  y <= b >> a[4:0]; // srlv - 逻辑右移，最高位用0补
			`EXE_SRA_OP:   y <= $signed(b) >>> sa; 	   // sra  - 算术右移，最高位用b的符号位补
			`EXE_SRAV_OP:  y <= $signed(b) >>> a[4:0]; // srav - 算术右移，最高位用b的符号位补
			
			// ③4条数据移动指令
			// TODO 可优化hilo，将其拆开
			// `EXE_MFHI_OP:  y <= hilo_in[63:32];
			// `EXE_MTHI_OP:  hilo_out <= {a, hilo_in[31:0]};
			// `EXE_MFLO_OP:  y <= hilo_in[31:0];
			// `EXE_MTLO_OP:  hilo_out <= {hilo_in[63:32], a};
			
			`EXE_MFHI_OP:  y <= hi_in;
			`EXE_MTHI_OP:  hi_out <= a;
			`EXE_MFLO_OP:  y <= lo_in;
			`EXE_MTLO_OP:  lo_out <= a;
			
			// ④14条算术运算指令
			// R-型
			// # 加法组
			`EXE_ADD_OP:   y <= a + b;
			`EXE_ADDU_OP:  y <= a + b;
			// # 减法组
			`EXE_SUB_OP:   y <= a - b;
			`EXE_SUBU_OP:  y <= a - b;
			// # 比较组
			`EXE_SLT_OP:   y <= ($signed(a) < $signed(b));
			`EXE_SLTU_OP:  y <= (a < b);
			// # 乘法组
			`EXE_MULT_OP:  {hi_out, lo_out} <= $signed(a) * $signed(b);
			`EXE_MULTU_OP: {hi_out, lo_out} <= a * b;
			// TODO 乘法优化
			// `EXE_MULT_OP: {hi_out, lo_out} <= mul_result_sign;
            // `EXE_MULTU_OP: {hi_out, lo_out} <= mul_result_unsign;
			// # 除法组
			`EXE_DIV_OP: {hi_out, lo_out} <= div_res;
            `EXE_DIVU_OP: {hi_out, lo_out} <= div_res;
			// I-型
			// # 加法组
			`EXE_ADDI_OP:  y <= a + b;
			`EXE_ADDIU_OP: y <= a + b;
			// # 比较组
			`EXE_SLTI_OP:  y <= ($signed(a) < $signed(b));
			`EXE_SLTIU_OP: y <= (a < b);

			// ⑥8条访存指令
			`EXE_LW_OP:    y <= a + b;
			`EXE_LB_OP:    y <= a + b;
			`EXE_LBU_OP:   y <= a + b;
			`EXE_LH_OP:    y <= a + b;
			`EXE_LHU_OP:   y <= a + b;
			`EXE_SB_OP:    y <= a + b;
			`EXE_SH_OP:    y <= a + b;
			`EXE_SW_OP:    y <= a + b;
			default: begin
				y <= 32'b0;
				// hi_out <= 32'b0;
				// lo_out <= 32'b0;
			end
		endcase	
	end


	// 溢出判断
	always @(*) begin
		case (alucontrol) // 只有三种指令会发生溢出
			`EXE_ADD_OP: // 有符号数加法溢出情况：①上溢：正+正=负；②下溢：负+负=正
				overflow <= (a[31] & b[31] & ~y[31]) | (~a[31] & ~b[31] & y[31]);
			`EXE_ADDI_OP: 
				overflow <= (a[31] & b[31] & ~y[31]) | (~a[31] & ~b[31] & y[31]);
			`EXE_SUB_OP: // 有符号数减法溢出情况：①上溢：正-负=负；②下溢：负-正=正
				overflow <= (~a[31] & b[31] & y[31]) | (a[31] & ~b[31] & ~y[31]);
			default: overflow <= 0;
		endcase	
	end
	assign zero = (y == 32'b0);
endmodule
