`timescale 1ps/1ps
import accumulator_optype::acu_op_t;

module Acu_tb();

    reg clock;
    reg reset;
    // Inputs to Accumulator
    reg select;
    reg [3:0] data_in;
    accumulator_optype::acu_op_t opcode;

    // Outputs from Accumulator
    wire [3:0] out;
    wire carry;
    wire borrow;

    reg [3:0] expected;

    // DUT实例化
    Accumulator dut (
        .clock(clock),
        .reset(reset),
        .select(select),
        .data_in(data_in),
        .opcode(opcode),
        .out(out),
        .carry(carry),
        .borrow(borrow)
    );

    initial begin

        clock = 0;

        forever begin
            #1000 clock = ~clock;
        end
    end


    integer i;

    // INC单元测试封装为task
    task automatic test_inc_and_carry();
        opcode = accumulator_optype::NOP;
        select = 0;
        data_in = 4'b0;

        repeat (5) @(negedge clock);
        reset = 1;
        repeat (5) @(negedge clock);
        reset = 0;

        $display("[TESTBENCH] Start Accumulator unit test");
        select = 1;
        opcode = accumulator_optype::WRITE;
        data_in = 4'b0000;
        @(negedge clock);
        opcode = accumulator_optype::NOP;
        data_in = 4'b0000;
        @(negedge clock);

        for (i = 0; i < 16; i = i + 1) begin
            opcode = accumulator_optype::INC;
            @(negedge clock);
            opcode = accumulator_optype::NOP;
            @(negedge clock);
            $display("[INC TEST] i=%0d, acc=0x%0h, carry=%0b", i, out, carry);
            // 检查累加器值
            if (out !== ((i+1) & 4'hF)) begin
                $error("[INC TEST] INC value error at i=%0d: expected 0x%0h, got 0x%0h", i, (i+1)&4'hF, out);
            end
        end

        // 3. 检查最后一次加法后carry为1
        if (carry !== 1'b1) begin
            $error("[INC TEST] Carry flag error: expected 1, got %0b", carry);
        end else begin
            $display("[INC TEST] Carry flag correct after overflow");
        end

        // 单元测试结束信息移至顶层initial
    endtask

    // DEC单元测试封装为task
    task automatic test_dec_and_borrow();
        opcode = accumulator_optype::NOP;
        select = 0;
        data_in = 4'b0;

        repeat (5) @(negedge clock);
        reset = 1;
        repeat (5) @(negedge clock);
        reset = 0;

        $display("[TESTBENCH] Start Accumulator DEC unit test");
        // 先写入最大值
        select = 1;
        opcode = accumulator_optype::WRITE;
        data_in = 4'b1111;
        @(negedge clock);
        opcode = accumulator_optype::NOP;
        data_in = 4'b0000;
        select = 1;
        @(negedge clock);

        for (i = 0; i < 16; i = i + 1) begin
            opcode = accumulator_optype::DEC;
            @(negedge clock);
            opcode = accumulator_optype::NOP;
            @(negedge clock);
            $display("[DEC TEST] i=%0d, acc=0x%0h, borrow=%0b", i, out, borrow);
            // 检查累加器值
            if (out !== ((15-i-1) & 4'hF)) begin
                $error("[DEC TEST] DEC value error at i=%0d: expected 0x%0h, got 0x%0h", i, (15-i-1)&4'hF, out);
            end
        end

        // 检查最后一次减法后borrow为1
        if (borrow !== 1'b1) begin
            $error("[DEC TEST] Borrow flag error: expected 1, got %0b", borrow);
        end else begin
            $display("[DEC TEST] Borrow flag correct after underflow");
        end

    endtask

    // 左旋测试
    task automatic test_rot_left();
        opcode = accumulator_optype::NOP;
        select = 0;
        data_in = 4'b0;

        repeat (5) @(negedge clock);
        reset = 1;
        repeat (5) @(negedge clock);
        reset = 0;

        $display("[TESTBENCH] Start Accumulator ROT_LEFT unit test");
        // 先写入一个已知值
        select = 1;
        opcode = accumulator_optype::WRITE;
        data_in = 4'b1011;
        @(negedge clock);
        opcode = accumulator_optype::NOP;
        data_in = 4'b0000;
        select = 1;
        @(negedge clock);

        expected = 4'b1011;
        for (i = 0; i < 4; i = i + 1) begin
            opcode = accumulator_optype::ROT_LEFT;
            @(negedge clock);
            opcode = accumulator_optype::NOP;
            @(negedge clock);
            expected = {expected[2:0], expected[3]};
            $display("[ROT_LEFT TEST] i=%0d, acc=0x%0h, expected=0x%0h", i, out, expected);
            if (out !== expected) begin
                $error("[ROT_LEFT TEST] Value error at i=%0d: expected 0x%0h, got 0x%0h", i, expected, out);
            end
        end
    endtask

    // 右旋测试
    task automatic test_rot_right();
        opcode = accumulator_optype::NOP;
        select = 0;
        data_in = 4'b0;

        repeat (5) @(negedge clock);
        reset = 1;
        repeat (5) @(negedge clock);
        reset = 0;

        $display("[TESTBENCH] Start Accumulator ROT_RIGHT unit test");
        // 先写入一个已知值
        select = 1;
        opcode = accumulator_optype::WRITE;
        data_in = 4'b1011;
        @(negedge clock);
        opcode = accumulator_optype::NOP;
        data_in = 4'b0000;
        select = 0;
        @(negedge clock);
        select = 1;
        expected = 4'b1011;
        for (i = 0; i < 4; i = i + 1) begin
            opcode = accumulator_optype::ROT_RIGHT;
            @(negedge clock);
            opcode = accumulator_optype::NOP;
            @(negedge clock);
            expected = {expected[0], expected[3:1]};
            $display("[ROT_RIGHT TEST] i=%0d, acc=0x%0h, expected=0x%0h", i, out, expected);
            if (out !== expected) begin
                $error("[ROT_RIGHT TEST] Value error at i=%0d: expected 0x%0h, got 0x%0h", i, expected, out);
            end
        end
    endtask

    // 读写测试
    task automatic test_write_and_read();
        opcode = accumulator_optype::NOP;
        select = 0;
        data_in = 4'b0;

        repeat (5) @(negedge clock);
        reset = 1;
        repeat (5) @(negedge clock);
        reset = 0;

        $display("[TESTBENCH] Start Accumulator WRITE/READ unit test");
        // 依次写入不同值并读出
        for (i = 0; i < 16; i = i + 1) begin
            // 写入
            select = 1;
            opcode = accumulator_optype::WRITE;
            data_in = i[3:0];
            @(negedge clock);
            select = 0;
            opcode = accumulator_optype::NOP;
            data_in = 4'b0000;
            @(negedge clock);
            // 读出
            select = 1;
            @(negedge clock);
            $display("[WRITE/READ TEST] i=%0d, out=0x%0h", i, out);
            if (out !== i[3:0]) begin
                $error("[WRITE/READ TEST] Value error at i=%0d: expected 0x%0h, got 0x%0h", i, i[3:0], out);
            end
            select = 0;
            @(negedge clock);
        end
    endtask

    // 测试初始化和调度
    initial begin
        $display("[TESTBENCH] Start Accumulator unit test");
        test_inc_and_carry();
        test_dec_and_borrow();
        test_rot_left();
        test_rot_right();
        test_write_and_read();
        $display("[TESTBENCH] End Accumulator unit test");
        $stop;
    end



endmodule