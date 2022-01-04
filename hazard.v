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

	// input [31:0] excepttypeM,
	// output reg [31:0] newpcM

	// output wire flush_except
    );

	// assign flush_except = (excepttypeM != 32'b0);

	wire lwstallD, branchstallD;
	wire jrstall;

	//forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	//forwarding sources to E stage (ALU)

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
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign #1 branchstallD = branchD & // 条件①是分支指令
							((regwriteE & (writeregE == rsD | writeregE == rtD)) | // 条件②(i)
							 (memtoregM & (writeregM == rsD | writeregM == rtD))); // 条件②(ii)

	assign jrstall = (jumpD & jrD) & // 条件①jr和jalr指令（涉及临时的写回寄存器temp）
	 				 ((regwriteE & (writeregE == rsD | writeregE == rtD)) | // 条件②(i)
					  (memtoregM & (writeregM == rsD | writeregM == rtD))); // 条件②(ii)
	assign stallF = (lwstallD | branchstallD | div_stallE | jrstall);
	// assign stallF = (lwstallD | branchstallD | div_stallE); // TODO
	assign stallD = stallF;
	assign stallE = div_stallE;
	// TODO 停顿出问题
	
	
	// assign #1 stallD = lwstallD | branchstallD;
	// assign #1 stallF = stallD;
	

	// assign stallE = div_stallE | stallreq_from_mem;
	// assign #1 stallE = 1'b0;
	
		//stalling D stalls all previous stages
	// assign #1 flushE = stallD;

	assign flushE = (lwstallD | branchstallD | jumpD);
	// assign flushF = flush_except;
	// assign flushE = (lwstallD | branchstallD); // TODO 

	// assign #1 flushE = stallD & ~div_stallE;
		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
	

	//异常处理地址bfc00380
    // always @(*) begin
    //     if(excepttypeM != 32'b0) begin
    //         if(excepttypeM == 32'h0000000e) begin
    //             newpcM <= cp0_epcM;
    //         end
    //         else begin
    //             newpcM <= 32'hBFC00380;//10 jump200
    //         end
    //     end
    // end
endmodule
