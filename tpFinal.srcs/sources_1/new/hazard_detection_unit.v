`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.05.2024 15:57:44
// Design Name: 
// Module Name: hazard_detection_unit
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


module hazard_detection_unit
#(
    parameter N_REG = 32,
    parameter NB_REG_ADDRESS = $clog2(N_REG)
)
( 
    //source registers from ID
    input [NB_REG_ADDRESS-1:0] i_rs_address_id,
    input [NB_REG_ADDRESS-1:0] i_rt_address_id,
    //EX memRead y rt
    input i_MemRead, //señal de control
    input [NB_REG_ADDRESS-1:0] i_rt_address_ex,
    //signals to stall
    output reg o_PCwrite,
    output reg o_IFIDwrite,
    output reg o_pipeline_stalled_to_ID
);


always@(*)
begin
    if(i_MemRead && ((i_rt_address_ex == i_rs_address_id) || (i_rt_address_ex == i_rt_address_id)))
        begin
            o_PCwrite = 1;
            o_IFIDwrite = 1;          
            //para la segunda parte del pipeline se insertan nops, se ponen a 0 las señales de control (enable)
            o_pipeline_stalled_to_ID = 1'b1;
        end
    else
        begin
            o_PCwrite = 0;
            o_IFIDwrite = 0;
            o_pipeline_stalled_to_ID = 1'b0;
        end
end

// if i_mem_read_ex and                                 --> si escribe en memoria es un load
//((i_rt_address_ex == i_rs_address_id or               --> si coincide alguno de los operandos
//i_rt_address_ex == i_rt_address_id)) then stall = 1   --> entonces se pone el stall
/*
La primera línea comprueba si la instrucción es una carga: ésta es la única instrucción que lee de memoria. 
Las dos líneas siguientes comprueban si el campo de registro destino de la carga en la etapa EX es igual a cualquiera de los dos registros
fuente de la instrucción en ID. Si la condición se cumple, la instrucción se bloquea durante 1 ciclo. 
Si la instrucción situada en la etapa ID se bloquea, entonces también debe bloquearse la que esté en IF; de no hacerse así se perdería 
la instrucción buscada de memoria. Evitar que estas dos instrucciones progresen en el procesador supone simplemente evitar que cambien 
el registro PC y el registro de segmentación IF/ID. 
Si estos valores no cambian, la instrucción en la etapa IF continuará leyendo de memoria usando el mismo PC y se volverán a leer los 
registros en la etapa ID usando los mismos campos de instrucción en el registro de segmentación IF/ID. 
Por su parte en la mitad posterior del pipeline (las etapas EX, MEM y WB) se insertan NOPS
¿Cómo se pueden insertar estos nops, que actúan como burbujas en el pipeline? negando las nueve señales de control (poniéndolas a 0) en 
las etapas EX/MEM y WB se creará una nop. Al identificar el riesgo en la etapa ID, se puede insertar una burbuja en el pipeline poniendo 
a 0 los campos de control de EX, MEM y WB en el registro de segmentación ID/EX. Estos nuevos valores de control se propagan
hacia adelante en cada ciclo con el efecto deseado: si los valores de control valen todos 0 no se escribe sobre memoria o sobre registros
*/
endmodule
