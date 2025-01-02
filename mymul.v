
`include "lib/defines.vh"

module mymul(
	input wire rst,							//复位信号
	input wire clk,							//时钟信号
	input wire signed_mul_i,				//是否为有符号乘法运算
	input wire[31:0] a_o,				//被乘数
	input wire[31:0] b_o,				//乘数
	input wire start_i,						//是否开始乘法运算
	output reg[63:0] result_o,				//乘法运算结果
	output reg ready_o						//乘法运算是否结束
);
reg [31:0] temp_opa,temp_opb;//临时存储操作数
reg [63:0] pv;//部分积
reg [63:0] ap;//累加器
reg [5:0] i;//计数器，记录当前处理到第几位
reg [1:0] state;// 00:空闲 10：开始 11：结束

always @ (posedge clk) begin
		if (rst) begin
			state <= `MulFree;
			result_o <= {`ZeroWord,`ZeroWord};
			ready_o <= `MulResultNotReady;
		end else begin
			case(state)			
				`MulFree: begin			//乘法器空闲状态
                    if (start_i== `MulStart) begin
                        state <= `MulOn;
                        i <= 6'b00_0000;
                        //处理有符号乘法的被乘数
					    if(signed_mul_i == 1'b1 && a_o[31] == 1'b1) begin			
							temp_opa = ~a_o + 1;//如果是负数，取其补码
						end else begin
							temp_opa = a_o;
						end
						if(signed_mul_i == 1'b1 && b_o[31] == 1'b1 ) begin			
								temp_opb = ~b_o + 1;//如果是负数，取其补码
						end else begin
							temp_opb = b_o;
						end
                        ap <= {32'b0,temp_opa};//初始化累加器
						ready_o <= `MulResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
                        pv <= 64'b0;//初始化部分积
                    end
				end				
				
				`MulOn: begin				//乘法运算装填
                        if(i != 6'b100000) begin//还未处理完32位
                            if(temp_opb[0]==1'b1) begin
								pv <= pv + ap;//如果乘数当前位为，加上被乘数
								ap <= {ap[62:0],1'b0};//被乘数左移一位
								temp_opb <= {1'b0,temp_opb[31:1]};//乘数右移一位
							end
							else begin 
                                ap <= {ap[62:0],1'b0};//被乘数左移一位
								temp_opb <= {1'b0,temp_opb[31:1]};//乘数右移一位
							end 	
                            i <= i + 1;//计数器加1
                        end
						else begin
							if ((signed_mul_i == 1'b1) && ((a_o[31] ^ b_o[31]) == 1'b1))begin
							    pv <= ~pv + 1;//如果是有符号乘法且结果为负，取补码
							end
							state <= `MulEnd;
							i <= 6'b00_0000;
						end
					   
				end
				
				`MulEnd: begin			//乘法结束状态
					result_o <= pv;//输出结果
					ready_o <= `MulResultReady;
					if (start_i == `MulStop) begin
						state <= `MulFree;//返回空闲状态
						ready_o <= `MulResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
					end
				end
				
			endcase
		end
	end

endmodule
