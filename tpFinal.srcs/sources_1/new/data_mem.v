`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2024 17:47:39
// Design Name: 
// Module Name: data_mem
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


module data_mem
#(
    parameter NB_ADDR = 32,
    parameter NB_INS = 32     
)
(
    input   i_clk,    
    input   [NB_ADDR-1:0] i_data_mem_read_address,
    input   [NB_ADDR-1:0] i_data_mem_write_address,
    input   [NB_INS-1:0]  i_data_mem_data,
    input   i_data_mem_write_enable, // 0 NO WRITE - 1 WRITE
    input   [2:0] i_data_mem_bhw,
    output reg  [NB_INS-1:0] o_mem_data
);

localparam MEM_SIZE = 255;

integer i;
reg [NB_INS-1:0] mem_data[0:MEM_SIZE];

initial
begin      
    for (i = 0; i <= MEM_SIZE-1; i = i + 1) begin
        if(i%2 == 0)
            mem_data[i] = i;
        else
            mem_data[i] = 'hffffffff - i;
    end
end

always@(posedge i_clk)
begin
    if(i_data_mem_write_enable)
        begin
            case (i_data_mem_bhw)
                2'b11: mem_data[i_data_mem_write_address] = i_data_mem_data;
                2'b10: mem_data[i_data_mem_write_address] = {mem_data[i_data_mem_write_address][NB_INS-1:16], i_data_mem_data[15:0]};
                2'b01: mem_data[i_data_mem_write_address] = {mem_data[i_data_mem_write_address][NB_INS-1:8], i_data_mem_data[7:0]};
                2'b00: mem_data[i_data_mem_write_address] = i_data_mem_data; // Should not happen
            endcase
        end
end

always@(*)
begin
    case (i_data_mem_bhw)
        3'b111: o_mem_data = mem_data[i_data_mem_read_address]; // LW, LWU
        3'b000: o_mem_data = {{24{mem_data[i_data_mem_read_address][7]}}, mem_data[i_data_mem_read_address][7:0]}; // LB
        3'b001: o_mem_data = {{24{1'b0}}, mem_data[i_data_mem_read_address][7:0]}; // LBU
        3'b010: o_mem_data = {{16{mem_data[i_data_mem_read_address][15]}}, mem_data[i_data_mem_read_address][15:0]}; // LH
        3'b011: o_mem_data = {{16{1'b0}}, mem_data[i_data_mem_read_address][15:0]}; // LHU
        default: o_mem_data = mem_data[i_data_mem_read_address]; // Should not happen
    endcase
end

endmodule
