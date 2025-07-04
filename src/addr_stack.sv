module AddrStack
(
    /* Clock */
    input clock,
    /* Address Stack Inputs */
    input [1:0] addr,
    input [11:0] data_in,
    input write_enable,
    input select,
    /* Address Stack Outputs */
    output [11:0] data_out
);

    wire [11:0] stack_mem_out;
    addr_stack_mem addr_stack
    (
        .address(addr), 
        .clock(clock),
        .data(data_in), 
        .wren(write_enable), 
        .q(stack_mem_out)
    );

    assign data_out = select ? stack_mem_out : 12'bz;

endmodule