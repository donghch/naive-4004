module ROM 
(
    /* Clock */
    input clock, 
    /* Input Signals */
    input select, 
    input [11:0] addr, 
    /* Output Signals */
    output [3:0] data_out, 
);

    wire [3:0] rom_data_output;

    rom r
    (
        .address(addr), 
        .clock(clock), 
        .q(rom_data_output)
    );

    assign data_out = select ? rom_data_output : 4'bz;
    
endmodule