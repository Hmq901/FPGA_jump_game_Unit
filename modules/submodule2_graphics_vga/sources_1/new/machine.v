`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/28 16:52:52
// Design Name: 
// Module Name: machine
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


module machine(
    input  wire        clk_machine,    // ��ʱ�� (25.175MHz)
    input  wire        rst_machine,    // �첽��λ (����Ч)
    input  wire        i_btn,          // ��Ұ�������
    input  wire        i_jump_done,    // ����������Ծ����ź�

    output reg [9:0] o_x_man,
    output reg [9:0] o_y_man,
    output reg [9:0] o_x_block1,
    output reg [9:0] o_x_block2,

    output reg [3:0] o_type_block1,
    output reg [3:0] o_type_block2,

    output reg o_gameover,    // ��Ϸ�����ź�
    output reg o_titile,

    output reg  [7:0]  o_jump_v_init,  // ��Ծ���ٶ�
    output reg  [2:0]  o_squeeze_man,  // С��ѹ��� (0-7)
    output reg         o_jump_en,       // ��������ʹ��

    );

    



endmodule
