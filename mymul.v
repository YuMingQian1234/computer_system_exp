
`include "lib/defines.vh"

module mymul(
	input wire rst,							//��λ�ź�
	input wire clk,							//ʱ���ź�
	input wire signed_mul_i,				//�Ƿ�Ϊ�з��ų˷�����
	input wire[31:0] a_o,				//������
	input wire[31:0] b_o,				//����
	input wire start_i,						//�Ƿ�ʼ�˷�����
	output reg[63:0] result_o,				//�˷�������
	output reg ready_o						//�˷������Ƿ����
);
reg [31:0] temp_opa,temp_opb;//��ʱ�洢������
reg [63:0] pv;//���ֻ�
reg [63:0] ap;//�ۼ���
reg [5:0] i;//����������¼��ǰ�����ڼ�λ
reg [1:0] state;// 00:���� 10����ʼ 11������

always @ (posedge clk) begin
		if (rst) begin
			state <= `MulFree;
			result_o <= {`ZeroWord,`ZeroWord};
			ready_o <= `MulResultNotReady;
		end else begin
			case(state)			
				`MulFree: begin			//�˷�������״̬
                    if (start_i== `MulStart) begin
                        state <= `MulOn;
                        i <= 6'b00_0000;
                        //�����з��ų˷��ı�����
					    if(signed_mul_i == 1'b1 && a_o[31] == 1'b1) begin			
							temp_opa = ~a_o + 1;//����Ǹ�����ȡ�䲹��
						end else begin
							temp_opa = a_o;
						end
						if(signed_mul_i == 1'b1 && b_o[31] == 1'b1 ) begin			
								temp_opb = ~b_o + 1;//����Ǹ�����ȡ�䲹��
						end else begin
							temp_opb = b_o;
						end
                        ap <= {32'b0,temp_opa};//��ʼ���ۼ���
						ready_o <= `MulResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
                        pv <= 64'b0;//��ʼ�����ֻ�
                    end
				end				
				
				`MulOn: begin				//�˷�����װ��
                        if(i != 6'b100000) begin//��δ������32λ
                            if(temp_opb[0]==1'b1) begin
								pv <= pv + ap;//���������ǰλΪ�����ϱ�����
								ap <= {ap[62:0],1'b0};//����������һλ
								temp_opb <= {1'b0,temp_opb[31:1]};//��������һλ
							end
							else begin 
                                ap <= {ap[62:0],1'b0};//����������һλ
								temp_opb <= {1'b0,temp_opb[31:1]};//��������һλ
							end 	
                            i <= i + 1;//��������1
                        end
						else begin
							if ((signed_mul_i == 1'b1) && ((a_o[31] ^ b_o[31]) == 1'b1))begin
							    pv <= ~pv + 1;//������з��ų˷��ҽ��Ϊ����ȡ����
							end
							state <= `MulEnd;
							i <= 6'b00_0000;
						end
					   
				end
				
				`MulEnd: begin			//�˷�����״̬
					result_o <= pv;//������
					ready_o <= `MulResultReady;
					if (start_i == `MulStop) begin
						state <= `MulFree;//���ؿ���״̬
						ready_o <= `MulResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
					end
				end
				
			endcase
		end
	end

endmodule
