`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 17:49:24
// Design Name: 
// Module Name: tb_alu
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


module tb_alu;

    parameter NB_DATA = 8;
    parameter NB_OPS = 5;
    
    reg clk;
    reg reset;
    reg [NB_DATA-1:0] data_a;
    reg [NB_DATA-1:0] data_b;
    reg [NB_OPS-1:0] ops;
    wire [NB_DATA-1:0] res;
    wire zero;
    
    initial
    begin
        #0
        clk = 0;
        reset = 1;
        data_a = 8'b00000000;
        data_b = 8'b00000000;
        ops = 5'b00000;                
        #10
        reset = 0;
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b00000;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b00001;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b00010;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b00011;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b00100;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b00101;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b00110;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b00111;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b01000;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b01001;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b01010;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b01011;
        #10
        data_a = 8'b00000010;
        data_b = 8'b00000011;
        ops = 5'b01100;
        $finish;
    end

    always #0.5 clk = ~clk;

    alu
    #(
        .NB_DATA(NB_DATA),
        .NB_OPS(NB_OPS)
    )
    u_alu
    (
        .i_data_a(data_a),
        .i_data_b(data_b),
        .i_ops(ops),
        .o_res(res),
        .o_zero(zero)
    );

endmodule
