`include "lib/defines.vh"
module MEM(//�������ݺ�д�ع��̵���ˮ�߽׶�ģ��
    input wire clk,//ʱ���źţ�����ͬ��ʱ��
    input wire rst,//��λ�źţ����ڽ�ģ���װ������
    // input wire flush,
    input wire [`StallBus-1:0] stall,//һ����ͣ�źţ�������ˮ�ߵ���ͣ

    input wire [`EX_TO_MEM_WD-1:0] ex_to_mem_bus,//����EX�׶ε��������ߣ�����ִ�н׶ε��ڴ�׶ε��ź�
    input wire [31:0] data_sram_rdata,//������SRAM�ж�ȡ������
    
    output wire [37:0] mem_to_id,//���ݸ�ID�׶ε��źţ������Ƿ�д�ؼĴ���������
    


    output wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus//���ݸ�WB�׶ε��źţ�����д�ؼĴ����Ŀ����źź�����
);

    reg [`EX_TO_MEM_WD-1:0] ex_to_mem_bus_r;//������һ���Ĵ��������ڴ洢EX�׶ε�MEM�׶ε��������ߣ��Ա���ʱ�ӵ������ؽ���ͬ��

    always @ (posedge clk) begin
        if (rst) begin//�����λ�ź���Ч�����Ĵ���ex_to_mem_bus_r����Ϊ0����ʾ��ռĴ���
            ex_to_mem_bus_r <= `EX_TO_MEM_WD'b0;
        end
        // else if (flush) begin
        //     ex_to_mem_bus_r <= `EX_TO_MEM_WD'b0;
        // end
        else if (stall[3]==`Stop && stall[4]==`NoStop) begin//���stall�ź�Ҫ����ͣ������stall[4]Ϊ����ͣ״̬ʱ������ռĴ���
            ex_to_mem_bus_r <= `EX_TO_MEM_WD'b0;
        end
        else if (stall[3]==`NoStop) begin//û�и�λ��ͣ��ex_to_mem_bus�����ݱ����ص�ex_to_mem_bus_r�Ĵ�����
            ex_to_mem_bus_r <= ex_to_mem_bus;
        end
    end

    wire [31:0] mem_pc;//���ڴ�׶ε�PCֵ
    wire data_ram_en;//����RAMʹ���ź�
    wire [3:0] data_ram_wen , data_ram_readen;//����RAMдʹ�ܣ���ʹ���ź�
    wire sel_rf_res;//ѡ��Ĵ�����д�����ݵ��ź�
    wire rf_we;//�Ĵ���дʹ���ź�
    wire [4:0] rf_waddr;//�Ĵ���д��ַ
    wire [31:0] rf_wdata;//�Ĵ���д����
    wire [31:0] ex_result;//ִ�н׶εĽ��

    assign {//��ex_to_mem_bus_r����ź�
        data_ram_readen,//79:76�������ڴ��ȡʹ��
        mem_pc,         // 75:44����ǰָ���PCֵ
        data_ram_en,    // 43�������ڴ�ʹ��
        data_ram_wen,   // 42:39�������ڴ�дʹ��
        sel_rf_res,     // 38������ѡ���Ƿ�����д�ؼĴ�����
        rf_we,          // 37���Ĵ�����дʹ��
        rf_waddr,       // 36:32��д��ļĴ�����ַ
        ex_result       // 31:0��ִ�н׶εļ�����
    } =  ex_to_mem_bus_r;

    //����Ϊд�ؼĴ��������ݣ�data_sram_rdata��ʾ�������ڴ��ж�ȡ������
    //data_ram_readenΪ��ȡʹ���ź�
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
        mem_pc,     // 41:38����ǰ�ĳ��������(PC)ֵ
        rf_we,      // 37,�Ĵ���дʹ���ź�
        rf_waddr,   // 36:32��д��ļĴ�����ַ
        rf_wdata    // 31:0��д��Ĵ���������
    };//д�ؽ׶ε����ݴ���
     assign  mem_to_id =
    {   rf_we,      // 37���Ĵ���дʹ���ź�
        rf_waddr,   // 36:32��д��ļĴ�����ַ
        rf_wdata    // 31:0��д��Ĵ���������
    };//���ݸ�ID�׶ε�����



endmodule