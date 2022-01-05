module mycpu_top(
    // input clk,
    // input resetn,  //low active

    // //cpu inst sram
    // output        inst_sram_en   ,
    // output [3 :0] inst_sram_wen  ,
    // output [31:0] inst_sram_addr ,
    // output [31:0] inst_sram_wdata,
    // input  [31:0] inst_sram_rdata,
    // //cpu data sram
    // output        data_sram_en   ,
    // output [3 :0] data_sram_wen  ,
    // output [31:0] data_sram_addr ,
    // output [31:0] data_sram_wdata,
    // output [1 :0] data_sram_size ,
    // input  [31:0] data_sram_rdata
    
    input clk,
    input resetn,  // TODO rst, low active 
	input wire[5:0] int, // interrupt,high active

    // cpu inst sram
    output        inst_sram_en   ,
    output [3 :0] inst_sram_wen  ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    
	// cpu data sram
    output        data_sram_en   ,
    output [3 :0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,
    // output [1 :0] data_sram_size ,
    input  [31:0] data_sram_rdata,

	// debug signals
	output wire [31:0] debug_wb_pc,
	output wire [3 :0] debug_wb_rf_wen,
	output wire [4 :0] debug_wb_rf_wnum,
	output wire [31:0] debug_wb_rf_wdata
);

    // 一个例子
	wire [31:0] pc;
	wire [31:0] instr;
    wire memenM;
	wire memwrite;
	wire [31:0] aluout, writedata, readdata;
    wire [3:0] selM;
    wire [1:0] sizeM;
    
    mips mips(
        .clk(clk),
        .rst(~resetn),
        
        //instr
        // .inst_en(inst_en),
        .pcF(pc),                    //pcF
        .instrF(instr),              //instrF
    
        //data
        // .data_en(data_en),
        .memenM(memenM),
        .memwriteM(memwrite),
        .aluoutM(aluout),
        .writedataM(writedata),
        .readdataM(readdata),
        
        .selM(selM),
        // .sizeM(sizeM),

        .debug_wb_pc(debug_wb_pc),
	    .debug_wb_rf_wen(debug_wb_rf_wen),
	    .debug_wb_rf_wnum(debug_wb_rf_wnum),
	    .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );

    assign inst_sram_en = 1'b1;     //如果有inst_en，就用inst_en
    assign inst_sram_wen = 4'b0;
    // assign inst_sram_addr = pc;
    assign inst_sram_wdata = 32'b0;
    assign instr = inst_sram_rdata;


    assign data_sram_en = 1'b1;     //如果有data_en，就用data_en
    // assign data_sram_en = memenM;     //如果有data_en，就用data_en
    // assign data_sram_wen = {4{memwrite}};
    assign data_sram_wen = selM; // TODO
    // assign data_sram_addr = aluout;
    assign data_sram_wdata = writedata;
    assign readdata = data_sram_rdata;

    // assign data_sram_size = sizeM; // TODO

    //ascii
    // instdec instdec(
    //     .instr(instr)
    // );

    mmu mmu(
        .inst_vaddr(pc),
        .inst_paddr(inst_sram_addr),
        .data_vaddr(aluout),
        .data_paddr(data_sram_addr)
        // output wire no_dcache    //是否经过d cache
    );
endmodule