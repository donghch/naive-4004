module RegFile
(
    /* Clock and Reset */
    input clock,
    /* Reg File Inputs */
    input [3:0] addr, 
    input [3:0] data_in, 
    input write_enable,
    input select,
    /* Reg File Outputs */
    output [3:0] data_out
);

    /* Define the register file */
    wire [3:0] reg_mem_out;
    reg_file_mem reg_mem
    (
        .address(addr), 
        .clock(clock),
        .data(data_in), 
        .wren(write_enable), 
        .q(reg_mem_out)
    );

    assign data_out = select ? reg_mem_out : 4'bz;


endmodule