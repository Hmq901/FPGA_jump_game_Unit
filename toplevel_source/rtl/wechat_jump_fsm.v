`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/02 13:32:28
// Design Name: 
// Module Name: wechat_jump_fsm
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
module wechat_jump_fsm (
    // ���������ź�
    input  wire        clk_machine,    // ��ʱ�� (25.175MHz)
    input  wire        rst_machine,    // �첽��λ (����Ч)
    input  wire        i_btn,          // ��Ұ�������

    //��jumpģ�������
    input  wire        i_jump_done,    // ����������Ծ����ź�
    input  wire [31:0] i_jump_dist,
    input  wire [31:0] i_jump_height,
    output wire  [7:0]  o_jump_v_init,  // ��Ծ���ٶ�
    output reg         o_jump_en,       // ��������ʹ��
    
    
    // ״̬���
    output reg  [2:0]  state,          // ��ǰ״̬��
    
    // ������ݸ�graphicsģ����ź�
    output reg  [31:0] o_x_man,
    output reg  [31:0] o_y_man,
    output reg  [31:0] o_x_block1,     // ����1��X����
    output reg  [31:0] o_x_block2,     // ����2��X����
    output reg         o_en_block2,     // ����2��ʾʹ��
    output reg  [4:0]  o_type_index1, // ����1����
    output reg  [4:0]  o_type_index2, // ����2����
    /*�޸Ľ��ͣ��Ұ�ԭ����color�ĳ���type����Ϊgraphics��block�в�ͬ�����࣬ÿһ�������Ӧһ��ͼƬ*/
    //ע�������������Ч��Χ��0~5
    output wire  [2:0]  o_squeeze_man,  // С��ѹ��� (0-7)

    /*������ͣ������graphicsģ�飬��ʾ�Ƿ���ʾ�������Ϸ��������*/
    output reg o_title,
    output reg o_gameover
    
    );

    // ================= ״̬���� ================= //
    localparam INIT = 3'd0;  // ��ʼ��״̬ (����λ�ý���)
    localparam RELD = 3'd1;  // ���Ӹ�λ����
    localparam WAIT = 3'd2;  // �ȴ�����״̬
    localparam ACCU = 3'd3;  // ����״̬
    localparam JUMP = 3'd4;  // ��Ծ��״̬
    localparam LAND = 3'd5;  // ��½�ж�״̬
    localparam OVER = 3'd6;  // ��Ϸ����״̬

    // ================= �������� ================= //
    localparam ORIGIN         = 32'd0;   // ��׼ԭ������
    localparam ORIGIN_STARTUP = 32'd100;     // ��ʼ���꣬���޸�
    localparam JUMP_THRESHOLD = 32'd30;    // ��Ծ�ж���ֵ
    localparam BLOCK2_OFFSET  = 32'd65;    // ����2����ƫ����
    localparam MAX_SQUEEZE    = 4'd14;     // ���ѹ�������ֵ

    // ================= �ڲ��ź� ================= //
    reg  [16:0] cnt_clk_reload;       // ��λ����������
    reg  [23:0] cnt_v_init;           // ���ٶȼ�����
    reg  [19:0] cnt_clk_squeeze;      // ѹ��ʱ�ӷ�Ƶ
    reg  [3:0]  cnt_squeeze;          // ѹ��ȼ�����
    wire        clk_squeeze;          // ѹ�����ʱ�� (��Ƶ)
    wire        reload_done;          // ��λ��ɱ�־
    wire [6:0]  random;               // ���������

    // ================= ʱ�ӷ�Ƶ ================= //
    assign clk_squeeze = cnt_clk_squeeze[19];  // Լ192Hz��Ƶ
    assign reload_done = (o_x_block1 <= ORIGIN); // ��λ����ж�

    // ================= ״̬������ ================= //
    //����ͬ״̬֮����л�
    always @(posedge clk_machine or posedge rst_machine) begin
        if (rst_machine) begin
            // �첽��λ��ʼ��
            state          <= RELD;
            o_x_block1     <= ORIGIN_STARTUP;
            o_x_block2     <= ORIGIN_STARTUP;
            o_en_block2    <= 1'b0;
            o_type_index1 <= 5'd17;
            o_type_index2 <= 5'd0;
            cnt_v_init     <= 24'd0;
            cnt_squeeze    <= 4'd0;
            cnt_clk_squeeze<= 20'd0;
            cnt_clk_reload <= 17'd0;
            o_jump_en      <= 1'b0;
            o_x_man        <= ORIGIN_STARTUP;
            o_y_man        <= 32'd0;
        end else begin
            // ѹ��ʱ�Ӽ�����
            cnt_clk_squeeze <= cnt_clk_squeeze + 1;
            
            // Ĭ�����
            o_jump_en <= 1'b0;
            
            // ״̬ת���߼�
            case (state)
                INIT: begin
                    state <= RELD;  // ��ʼ����������ʼ��λ����
                end
                
                RELD: begin
                    if (reload_done || o_x_block1 == ORIGIN) begin
                        state <= WAIT;
                    end else begin
                        state <= RELD;
                    end    
                end
                                    
                WAIT: begin
                    if (i_btn) begin
                        state <= ACCU;
                    end else begin
                        state <= WAIT;
                    end 
                end
                        
                ACCU: begin
                    if (!i_btn) begin
                        state <= JUMP;
                    end else begin
                        state <= ACCU;
                    end    
                end
                
                JUMP: begin
                    if (i_jump_done) begin
                        state <= LAND;
                    end else begin
                        state <= JUMP;
                    end    
                end
                
                LAND: begin
                    if (o_x_man <= JUMP_THRESHOLD) begin
                        state <= WAIT;  // δ������ǰ����
                    end else if ((o_x_block2 > o_x_man) ? 
                            (o_x_block2 - o_x_man <= JUMP_THRESHOLD) : 
                            (o_x_man - o_x_block2 <= JUMP_THRESHOLD)) begin
                        state <= INIT;  // �ɹ�������һ������
                    end else begin
                        state <= OVER;   // ��Ծʧ��
                    end
                end
                
                OVER: begin
                    state <= OVER;  // ���ֽ���״̬
                end
                default: begin
                    state <= RELD;  // �쳣״̬�ָ�
                end
            endcase
        end
    end

    /*�޸Ľ��ͣ���Ȼ��ͬ���ֶ�ʹ��clk_machine�������ش�����
        ���ǻ��ǽ���д����ͬ��always����У���ǿ�ɶ���*/
    
    //�����������ʵ����
    random #(7) random_inst (
        .clk_random(clk_machine),
        .rst_random(rst_machine),
        .i_roll(i_btn),
        .o_random_binary(random)
    );

    //���������ӽ��п���
    always@(posedge clk_machine) begin
        // ����λ�ÿ���
        case (state)
            INIT: begin
                o_x_block1  <= o_x_block2;  // ����2��Ϊ����1
                o_en_block2 <= 1'b0;        // ��������2
                cnt_clk_reload <= 0;
            end
            
            RELD: begin
                if (o_x_block1 > ORIGIN) begin
                    // ����1��λ����
                    if (cnt_clk_reload == 17'h1ffff) begin
                        o_x_block1  <= o_x_block1 - 1;
                        cnt_clk_reload <= 0;
                    end else begin
                        cnt_clk_reload <= cnt_clk_reload + 1;
                    end
                    o_en_block2 <= 1'b0;
                end else begin
                    // ��λ��ɣ�����������2
                    o_x_block1  <= ORIGIN;
                    o_x_block2  <= ORIGIN + random + BLOCK2_OFFSET;
                    o_en_block2 <= 1'b1;
                end
            end
            
            default: begin
                // ����״̬����λ�ò���
            end
        endcase
    end
    
    // ������������п���
    always@(posedge clk_machine) begin
        case(state) 
            INIT:begin
                o_type_index1 <= o_type_index2;
                if(o_type_index2 == 5) begin
                    o_type_index2 <= 0;
                end else begin
                    o_type_index2 <= o_type_index2 + 1;
                end 
            end 
            
            default:begin
            end 
        endcase
    end
    
    // ���ٶȿ���
    always@(posedge clk_machine) begin
        case (state)
            ACCU: begin
                if (i_btn && cnt_v_init < 24'hffffff) begin
                    cnt_v_init <= cnt_v_init + 1;
                end
            end
            
            JUMP: begin
                if (i_jump_done) begin
                    cnt_v_init <= 0;
                end
            end
            
            default: begin
                if (i_jump_done) begin
                    cnt_v_init <= 0;
                end
            end    
        endcase
            
            // ѹ��ȿ���
            if (state == ACCU) begin
                if (cnt_squeeze < MAX_SQUEEZE) begin
                    cnt_squeeze <= cnt_squeeze + 1;
                end
            end else begin
                cnt_squeeze <= 0;
            end
            
    end

    // ��ɫλ�ÿ���
    always@(posedge clk_machine) begin
        case (state)
            INIT: begin
                o_x_man <= o_x_block2;
                o_y_man <= 0;
            end
            
            ACCU: begin
                o_x_man <= o_x_block1;
                o_y_man <= 0;
            end
            
            JUMP: begin
                o_x_man <= i_jump_dist;
                o_y_man <= i_jump_height << 2;
            end
            
            LAND, OVER: begin
                // ���ֵ�ǰλ��
            end
            
            default: begin
                o_x_man <= o_x_block1;
                o_y_man <= 0;
            end
        endcase
    end
            
    // �����ֵ
    assign o_jump_v_init = cnt_v_init[23:17];  // ������0-255
    assign o_squeeze_man = cnt_squeeze[3:1];   // ѹ���0-7


endmodule