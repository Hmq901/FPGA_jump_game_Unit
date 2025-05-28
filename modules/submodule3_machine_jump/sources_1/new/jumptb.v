`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/19 20:06:38
// Design Name: 
// Module Name: jumptb
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


module jumptb();
 // �����ź�
    reg en;
    reg clk_jump;
    reg [10:0] i_v_init;
    
    // ����ź�
    wire [8:0] o_height;
    wire [10:0] o_dist;
    wire o_done;
    
    // ʵ��������ģ��
    jump uut (
        .en(en),
        .clk_jump(clk_jump),
        .i_v_init(i_v_init),
        .o_height(o_height),
        .o_dist(o_dist),
        .o_done(o_done)
    );
    
    // ����192Hzʱ�� (Լ5.2ms����)
    initial begin
        clk_jump = 0;
        forever #2604167 clk_jump = ~clk_jump; // 1/(192Hz)/2 �� 2.604167ms
    end
    
    // ��������
    initial begin
        // ��ʼ���ź�
        en = 0;
        i_v_init = 0;
        
        // ����1: �еȳ��ٶ���Ծ (Լ2��)
        #10 en = 1;
        i_v_init = 11'd128; // �еȳ��ٶ�
        wait(o_done == 1);
        #100 en = 0;
        
        // ����2: �����ٶ���Ծ (Լ3��)
        #100 en = 1;
        i_v_init = 11'd255; // �����ٶ�
        wait(o_done == 1);
        #100 en = 0;
        
        // ����3: ��С���ٶ���Ծ (Լ1��)
        #100 en = 1;
        i_v_init = 11'd32; // ��С���ٶ�
        wait(o_done == 1);
        #100 en = 0;
        
        #100;
    end
endmodule