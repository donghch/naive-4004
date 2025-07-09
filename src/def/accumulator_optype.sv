package accumulator_optype;

    typedef enum reg [2:0] {
        INC, 
        DEC, 
        ROT_LEFT, 
        ROT_RIGHT,
        WRITE, 
        NOP
    } acu_op_t;

endpackage