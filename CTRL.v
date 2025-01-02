`include "lib/defines.vh"
module CTRL(
    input wire rst,//��λ�ź�
    input wire stallreq_from_ex,//����ִ�н׶ε���ͣ�����ź�
    input wire stallreq_from_id,//����ָ�����׶ε���ͣ�����ź�
    //��δ���ʵ����һ������ģ�飬���ڴ���λ�źţ�
    //����ִ�е�Ԫ��ָ����뵥Ԫ����ͣ�����Ҳ���һ�������ź�
    // output reg flush,
    // output reg [31:0] new_pc,
    output reg [`StallBus-1:0] stall//�������ͣ�źţ�������ˮ�ߵ���ͣ
    //���У�stall�źŵĿ��ΪStallBus,����һ���궨�壬��ʾ��ͣ�źŵ�λ��
);  
    always @ (*) begin//����һ������߼��飬�����κ������źŷ����仯ʱ����
        if (rst) begin//���rst��λ�ź�Ϊ�ߵ�ƽ(1),����ͣ�źŻᱻ����Ϊȫ0��������ζ���ڸ�λ�ڼ䣬��ˮ�߲���Ҫ��ͣ�����в��������Լ������С�
            stall <= `StallBus'b0;
        end
        else if(stallreq_from_ex == 1'b1) begin//�������ִ�н׶ε���ͣ�����ź�Ϊ�ߵ�ƽ(1),����ͣ�ź�stall�ᱻ����Ϊһ��6λ������������ʾһ���ض�����ͣ״̬��
            stall <= 6'b001111;
        end
        else if(stallreq_from_id == 1'b1) begin//�������ָ�����׶ε���ͣ�����ź�Ϊ�ߵ�ƽ(1),����ͣ�ź�stall�ᱻ����Ϊһ���µ�6λ�źţ���ָ�����׶λ���һ������ͣ
            stall <= 6'b000111;
        end else begin //Ĭ��״̬�����û�и�λ�źţ�Ҳû������ִ�н׶λ��߽���׶ε���ͣ������stall�ᱻ����Ϊ6'000000,��ʾ����Ҫ��ͣ��ˮ��
            stall <= 6'b000000;
        end
    end
    
endmodule