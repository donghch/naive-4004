`timescale 1ps/1ps

module AddrStack_tb();

    /* Setup Signals */
    reg clock;
    reg [1:0] addr;
    reg [11:0] data;
    reg write_enable;
    reg select;
    wire [11:0] data_out;
    integer i;

    /* Setup Instance */
    AddrStack dut
    (
        .clock(clock), 
        .addr(addr), 
        .data_in(data), 
        .write_enable(write_enable), 
        .select(select), 
        .data_out(data_out)
    );

    initial begin
        clock = 0;
        forever #10000 clock = ~clock;
    end

    // Exhaustive unit test task for AddrStack
    task automatic test_addr_stack;
        
        reg [11:0] test_data [0:3];
        reg [11:0] read_data;
        begin
            // Write unique values to each address
            for (i = 0; i < 4; i = i + 1) begin
                addr = i[1:0];
                data = 12'h100 + i;
                test_data[i] = data;
                write_enable = 1'b1;
                select = 1'b1;
                @(negedge clock);
                write_enable = 1'b0;
                select = 1'b0;
            end

            // Read back and check each address
            for (i = 0; i < 4; i = i + 1) begin
                addr = i[1:0];
                select = 1'b1;
                @(negedge clock);
                read_data = data_out;
                if (read_data !== test_data[i]) begin
                    $display("[FAIL] AddrStack: addr %0d expected %h, got %h", i, test_data[i], read_data);
                end else begin
                    $display("[PASS] AddrStack: addr %0d value %h", i, read_data);
                end
                select = 1'b0;
            end

            // Test high-Z output when select is low
            addr = 2'd0;
            select = 1'b0;
            @(negedge clock);
            if (data_out !== 12'bz) begin
                $display("[FAIL] AddrStack: data_out not high-Z when select=0");
            end else begin
                $display("[PASS] AddrStack: data_out is high-Z when select=0");
            end
        end
    endtask

    initial begin
        addr = 2'd0;
        data = 12'd0;
        write_enable = 1'b0;
        select = 1'b0;
        @(negedge clock);
        test_addr_stack();
        $display("AddrStack unit test completed.");
        $stop;
    end

endmodule