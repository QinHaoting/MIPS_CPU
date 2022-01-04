`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/04 17:16:55
// Design Name: 
// Module Name: data_mem_sel
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
module data_mem_sel(
    input wire[7:0] op,
    input wire[1:0] addr,               // 访存地址最低2位
    input wire[31:0] writedata,readdata,
    output wire[3:0] sel,rsel,
    output wire[31:0] writedata2,readdata2,
    output wire adel,ades,
    output wire[1:0] size               // 请求数据的大小
    );

    assign sel = (
                  (op == `EXE_LW_OP || op == `EXE_LB_OP || op == `EXE_LBU_OP || op == `EXE_LH_OP || op == `EXE_LHU_OP) ? 4'b0000:
                  (op == `EXE_SW_OP && addr == 2'b00) ? 4'b1111: // 存字
                  (op == `EXE_SH_OP && addr == 2'b10) ? 4'b1100: // 存高半字
                  (op == `EXE_SH_OP && addr == 2'b00) ? 4'b0011: // 存低半字

                  (op == `EXE_SB_OP && addr == 2'b11) ? 4'b1000: // 存最高字节
                  (op == `EXE_SB_OP && addr == 2'b10) ? 4'b0100: // 存次高字节
                  (op == `EXE_SB_OP && addr == 2'b01) ? 4'b0010: // 存次低字节
                  (op == `EXE_SB_OP && addr == 2'b00) ? 4'b0001: // 存最低字节
                4'b0000);

    //use in cache
    assign rsel = ((op == `EXE_SW_OP || op == `EXE_SB_OP || op == `EXE_SH_OP)? 4'b0000:
                (op == `EXE_LW_OP && addr == 2'b00)? 4'b1111:
                (op == `EXE_LH_OP && addr == 2'b10)? 4'b1100:
                (op == `EXE_LH_OP && addr == 2'b00)? 4'b0011:

                (op == `EXE_LB_OP && addr == 2'b11)? 4'b1000:
                (op == `EXE_LB_OP && addr == 2'b10)? 4'b0100:
                (op == `EXE_LB_OP && addr == 2'b01)? 4'b0010:
                (op == `EXE_LB_OP && addr == 2'b00)? 4'b0001:
                4'b0000);

    assign size = (op == `EXE_LW_OP || op == `EXE_SW_OP) ? 2'b10:                       // 取字
                  (op == `EXE_LH_OP || op == `EXE_LHU_OP || op == `EXE_SH_OP) ? 2'b01:  // 取半字
                  (op == `EXE_LB_OP || op == `EXE_LBU_OP || op == `EXE_SB_OP) ? 2'b00:  // 取字节
                  2'b00;

    assign writedata2 = (
                        (op == `EXE_SW_OP) ?  writedata:                                                     // 存字
                        (op == `EXE_SH_OP) ? {writedata[15:0], writedata[15:0]}:                             // 存半字
                        (op == `EXE_SB_OP) ? {writedata[7:0], writedata[7:0],writedata[7:0],writedata[7:0]}: // 存字节
                        32'b0);

    assign readdata2 = (// 取有符号
                        (op == `EXE_LW_OP && addr == 2'b00)  ? readdata:                             // 取所有字节
                        (op == `EXE_LB_OP && addr == 2'b11)  ? {{24{readdata[31]}},readdata[31:24]}: // 取最高字节
                        (op == `EXE_LB_OP && addr == 2'b10)  ? {{24{readdata[23]}},readdata[23:16]}: // 取次高字节
                        (op == `EXE_LB_OP && addr == 2'b01)  ? {{24{readdata[15]}},readdata[15:8]}:  // 取次低字节
                        (op == `EXE_LB_OP && addr == 2'b00)  ? {{24{readdata[7]}},readdata[7:0]}:    // 取最低字节
    
                        (op == `EXE_LH_OP && addr == 2'b10)  ? {{16{readdata[31]}},readdata[31:16]}: // 取高半字
                        (op == `EXE_LH_OP && addr == 2'b00)  ? {{16{readdata[15]}},readdata[15:0]}:  // 取低半字
                        
                        
                        // 取无符号
                        (op == `EXE_LBU_OP && addr == 2'b11) ? {{24{1'b0}},readdata[31:24]}: // 取最高字节
                        (op == `EXE_LBU_OP && addr == 2'b10) ? {{24{1'b0}},readdata[23:16]}: // 取次高字节
                        (op == `EXE_LBU_OP && addr == 2'b01) ? {{24{1'b0}},readdata[15:8]}:  // 取次低字节
                        (op == `EXE_LBU_OP && addr == 2'b00) ? {{24{1'b0}},readdata[7:0]}:   // 取最低字节

                        (op == `EXE_LHU_OP && addr == 2'b10) ? {{16{1'b0}},readdata[31:16]}: // 取高半字
                        (op == `EXE_LHU_OP && addr == 2'b00) ? {{16{1'b0}},readdata[15:0]}:  // 取低半字
                        32'b0);

    assign adel = ((op == `EXE_LH_OP || op == `EXE_LHU_OP) && addr[0]) || (op == `EXE_LW_OP && addr != 2'b00);
    assign ades = (op == `EXE_SH_OP & addr[0]) | (op == `EXE_SW_OP & addr != 2'b00);

endmodule
