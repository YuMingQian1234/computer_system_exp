module fa (
  input a,b,cin,//����˿ڣ�a��b������������cin�ǽ�λ����
  output s,c//����˿ڣ�s�Ǻͣ�c�ǽ�λ���
);
  wire s1,t1,t2,t3;//s1,t1,t2,t3���м��źţ������ֽ��߼�����
  assign s1 = a^b;//����a��b��������õ��м�ֵs1
  assign s = s1^cin;//Ȼ��s1��cin����������㣬�õ����յĺ�s�����Ǽӷ������е����һ��������cin����һ����λ�Ľ�λ
  assign t3 = a&b;
  assign t2 = a&cin;
  assign t1 = b&cin;
  assign c = t1|t2|t3;
endmodule
//��δ���ʵ����һ��ȫ�����������������źţ�a,b��cin(��λ����)������������źţ�s���ͣ���c����λ�����