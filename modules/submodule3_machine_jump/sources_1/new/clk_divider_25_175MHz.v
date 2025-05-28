`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/02 12:52:01
// Design Name: 
// Module Name: clk_divider_25_175MHz
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
/////////////////////////////////////////////////////////////////////////////////
module clk_divider_25_175MHz (
    input wire clk_100MHz,    // ����100MHzʱ��
    input wire reset,         // �첽��λ
    output reg clk_25_175MHz  // ���25.175MHzʱ��
);

reg [3:0] counter;
always @(posedge clk_100MHz or posedge reset) begin
    if (reset) begin
        counter <= 4'd0;
        clk_25_175MHz <= 1'b0;
    end else begin
        if (counter == 4'd3) begin  // 3��Ƶ��25MHz��
            clk_25_175MHz <= ~clk_25_175MHz;
            counter <= 4'd0;
        end else if (counter == 4'd2) begin  // 4��Ƶ��25MHz��
            clk_25_175MHz <= ~clk_25_175MHz;
            counter <= counter + 1;
        end else begin
            counter <= counter + 1;
        end
    end
end

endmodule