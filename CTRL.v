`include "lib/defines.vh"
module CTRL(
    input wire rst,//复位信号
    input wire stallreq_from_ex,//来自执行阶段的暂停请求信号
    input wire stallreq_from_id,//来自指令解码阶段的暂停请求信号
    //这段代码实现了一个控制模块，用于处理复位信号，
    //来自执行单元和指令解码单元的暂停请求并且产生一个控制信号
    // output reg flush,
    // output reg [31:0] new_pc,
    output reg [`StallBus-1:0] stall//输出的暂停信号，控制流水线的暂停
    //其中，stall信号的宽度为StallBus,这是一个宏定义，表示暂停信号的位宽
);  
    always @ (*) begin//这是一个组合逻辑块，会在任何输入信号发生变化时触发
        if (rst) begin//如果rst复位信号为高电平(1),则暂停信号会被设置为全0，。这意味着在复位期间，流水线不需要暂停，所有操作都可以继续进行。
            stall <= `StallBus'b0;
        end
        else if(stallreq_from_ex == 1'b1) begin//如果来自执行阶段的暂停请求信号为高电平(1),则暂停信号stall会被设置为一个6位二进制数，表示一个特定的暂停状态。
            stall <= 6'b001111;
        end
        else if(stallreq_from_id == 1'b1) begin//如果来自指令解码阶段的暂停请求信号为高电平(1),则暂停信号stall会被设置为一个新的6位信号，在指令解码阶段会有一定的暂停
            stall <= 6'b000111;
        end else begin //默认状态，如果没有复位信号，也没有来自执行阶段或者解码阶段的暂停请求，则stall会被设置为6'000000,表示不需要暂停流水线
            stall <= 6'b000000;
        end
    end
    
endmodule