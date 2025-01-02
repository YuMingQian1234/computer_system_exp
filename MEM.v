`include "lib/defines.vh"
module MEM(//处理数据和写回过程的流水线阶段模块
    input wire clk,//时钟信号，用于同步时序
    input wire rst,//复位信号，用于将模块的装填重置
    // input wire flush,
    input wire [`StallBus-1:0] stall,//一个暂停信号，控制流水线的暂停

    input wire [`EX_TO_MEM_WD-1:0] ex_to_mem_bus,//来自EX阶段的数据总线，包含执行阶段到内存阶段的信号
    input wire [31:0] data_sram_rdata,//从数据SRAM中读取的数据
    
    output wire [37:0] mem_to_id,//传递给ID阶段的信号，包含是否写回寄存器的数据
    


    output wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus//传递给WB阶段的信号，包含写回寄存器的控制信号和数据
);

    reg [`EX_TO_MEM_WD-1:0] ex_to_mem_bus_r;//定义了一个寄存器，用于存储EX阶段到MEM阶段的数据总线，以便在时钟的上升沿进行同步

    always @ (posedge clk) begin
        if (rst) begin//如果复位信号有效，将寄存器ex_to_mem_bus_r设置为0，表示清空寄存器
            ex_to_mem_bus_r <= `EX_TO_MEM_WD'b0;
        end
        // else if (flush) begin
        //     ex_to_mem_bus_r <= `EX_TO_MEM_WD'b0;
        // end
        else if (stall[3]==`Stop && stall[4]==`NoStop) begin//如果stall信号要求暂停，且在stall[4]为非暂停状态时，则清空寄存器
            ex_to_mem_bus_r <= `EX_TO_MEM_WD'b0;
        end
        else if (stall[3]==`NoStop) begin//没有复位暂停，ex_to_mem_bus的数据被加载到ex_to_mem_bus_r寄存器中
            ex_to_mem_bus_r <= ex_to_mem_bus;
        end
    end

    wire [31:0] mem_pc;//在内存阶段的PC值
    wire data_ram_en;//数据RAM使能信号
    wire [3:0] data_ram_wen , data_ram_readen;//数据RAM写使能，读使能信号
    wire sel_rf_res;//选择寄存器堆写回数据的信号
    wire rf_we;//寄存器写使能信号
    wire [4:0] rf_waddr;//寄存器写地址
    wire [31:0] rf_wdata;//寄存器写数据
    wire [31:0] ex_result;//执行阶段的结果

    assign {//从ex_to_mem_bus_r解包信号
        data_ram_readen,//79:76，数据内存读取使能
        mem_pc,         // 75:44，当前指令的PC值
        data_ram_en,    // 43，数据内存使能
        data_ram_wen,   // 42:39，数据内存写使能
        sel_rf_res,     // 38，用于选择是否将数据写回寄存器堆
        rf_we,          // 37，寄存器堆写使能
        rf_waddr,       // 36:32，写入的寄存器地址
        ex_result       // 31:0，执行阶段的计算结果
    } =  ex_to_mem_bus_r;

    //以下为写回寄存器的数据，data_sram_rdata表示从数据内存中读取的数据
    //data_ram_readen为读取使能信号
    assign rf_wdata =     (data_ram_readen==4'b1111 && data_ram_en==1'b1) ? data_sram_rdata 
                        : (data_ram_readen==4'b0001 && data_ram_en==1'b1 && ex_result[1:0]==2'b00) ?({{24{data_sram_rdata[7]}},data_sram_rdata[7:0]})
                        : (data_ram_readen==4'b0001 && data_ram_en==1'b1 && ex_result[1:0]==2'b01) ?({{24{data_sram_rdata[15]}},data_sram_rdata[15:8]})
                        : (data_ram_readen==4'b0001 && data_ram_en==1'b1 && ex_result[1:0]==2'b10) ?({{24{data_sram_rdata[23]}},data_sram_rdata[23:16]})
                        : (data_ram_readen==4'b0001 && data_ram_en==1'b1 && ex_result[1:0]==2'b11) ?({{24{data_sram_rdata[31]}},data_sram_rdata[31:24]})
                        : (data_ram_readen==4'b0010 && data_ram_en==1'b1 && ex_result[1:0]==2'b00) ?({24'b0,data_sram_rdata[7:0]})
                        : (data_ram_readen==4'b0010 && data_ram_en==1'b1 && ex_result[1:0]==2'b01) ?({24'b0,data_sram_rdata[15:8]})
                        : (data_ram_readen==4'b0010 && data_ram_en==1'b1 && ex_result[1:0]==2'b10) ?({24'b0,data_sram_rdata[23:16]})
                        : (data_ram_readen==4'b0010 && data_ram_en==1'b1 && ex_result[1:0]==2'b11) ?({24'b0,data_sram_rdata[31:24]})
                        : (data_ram_readen==4'b0011 && data_ram_en==1'b1 && ex_result[1:0]==2'b00) ?({{16{data_sram_rdata[15]}},data_sram_rdata[15:0]})
                        : (data_ram_readen==4'b0011 && data_ram_en==1'b1 && ex_result[1:0]==2'b10) ?({{16{data_sram_rdata[31]}},data_sram_rdata[31:16]})
                        : (data_ram_readen==4'b0100 && data_ram_en==1'b1 && ex_result[1:0]==2'b00) ?({16'b0,data_sram_rdata[15:0]})
                        : (data_ram_readen==4'b0100 && data_ram_en==1'b1 && ex_result[1:0]==2'b10) ?({16'b0,data_sram_rdata[31:16]})
                        : ex_result;
    assign mem_to_wb_bus = {
        mem_pc,     // 41:38，当前的程序计数器(PC)值
        rf_we,      // 37,寄存器写使能信号
        rf_waddr,   // 36:32，写入的寄存器地址
        rf_wdata    // 31:0，写入寄存器的数据
    };//写回阶段的数据传递
     assign  mem_to_id =
    {   rf_we,      // 37，寄存器写使能信号
        rf_waddr,   // 36:32，写入的寄存器地址
        rf_wdata    // 31:0，写入寄存器的数据
    };//传递给ID阶段的数据



endmodule