`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2024 17:51:28
// Design Name: 
// Module Name: sign_ext
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


module sign_ext
#(
    parameter NB_DATA_IN = 16,
    parameter NB_DATA_OUT = 32
)
(
    input  [NB_DATA_IN-1:0] i_data_in,
    output  [NB_DATA_OUT-1:0] o_sigext
);
    assign o_sigext = {{NB_DATA_OUT-NB_DATA_IN{i_data_in[NB_DATA_IN-1]}},  i_data_in}; //copia 16 veces el bit mas significativo de data_in y luego copia data_in

endmodule
