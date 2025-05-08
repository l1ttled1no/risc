// Code your design here
module control_unit(
    input wire clk, // clock signal 
    input wire rst, // reset signal 

  input wire [2:0] opcode, 
    input wire is_zero, 

    output reg sel, // selection for the mux between ... 
    output reg rd, // for dmem, imem,...
    output reg ld_ir, // 
    output reg halt,
    output reg inc_pc, 
    output reg ld_ac, // load accumulator regs 
    output reg ld_pc, // load program_counter
    output reg wr, // Write
    output reg data_e,
    output reg [2:0] current_state
); 
    // State of the control unit 
    parameter INST_ADDR =   3'b000;
    parameter INST_FETCH =  3'b001; 
    parameter INST_LOAD =   3'b010; 
    parameter IDLE =        3'b011;
    parameter OP_ADDR =     3'b100; 
    parameter OP_FETCH =    3'b101; 
    parameter ALU_OP =      3'b110; 
    parameter STORE =       3'b111; 

    // reg [2:0] current_state, next_state; 
    reg [2:0] next_state; 

    // opcode
    parameter OP_HLT = 3'b000; 
    parameter OP_SKZ = 3'b001; 
    parameter OP_ADD = 3'b010; 
    parameter OP_AND = 3'b011; 
    parameter OP_XOR = 3'b100; 
    parameter OP_LDA = 3'b101; 
    parameter OP_STO = 3'b110; 
    parameter OP_JMP = 3'b111; 
    
    always @(posedge clk) begin 
        // initialize the signal first
        
        if (rst) begin //begin: rst == 0 
            current_state <= INST_ADDR; // reset: current_state is set to INST_ADDR 
        end // end: rst == 0 
        else begin // begin: else 
            current_state <= next_state;  // current state <= next state
        end // emd: else
    end //end: always @(posedge clk)

    // This always block will handling next state status 
    always @(current_state) begin //always @(*)
        case (current_state)
            INST_ADDR:  next_state = INST_FETCH; 
            INST_FETCH: next_state = INST_LOAD; 
            INST_LOAD:  next_state = IDLE; 
            IDLE:       next_state = OP_ADDR; 
            OP_ADDR:    next_state = OP_FETCH; 
            OP_FETCH:   next_state = ALU_OP; 
            ALU_OP:     next_state = STORE; 
            STORE:      next_state = INST_ADDR; 

        endcase // endcase: current state
    end // end: always @(*)
    
    // reg halt_latch; // flag for halt signal until it reset


    always @(current_state or opcode or is_zero) begin //always @(*)
        // Set initial state 

        sel =    1'b0; 
        rd =     1'b0; 
        ld_ir =  1'b0; 
        halt =   1'b0; 
        inc_pc = 1'b0; 
        ld_ac =  1'b0; 
        ld_pc =  1'b0; 
        wr =     1'b0; 
        data_e = 1'b0; 


        case (current_state)
            INST_ADDR: begin // begin: INST_ADDR 
                sel =   1'b1; 
            end // end: INST_ADDR

            INST_FETCH: begin 
                sel =   1'b1; 
                rd =    1'b1; 
            end // end: INST_FETCH 

            INST_LOAD: begin 
                sel =   1'b1; 
                rd =    1'b1; 
                ld_ir = 1'b1; 
            end // end: INST_LOAD

            IDLE: begin 
                sel =   1'b1; 
                rd =    1'b1; 
                ld_ir = 1'b1; 
            end // end: IDLE 

            OP_ADDR: begin 
              halt = (opcode == OP_HLT) ? 1'b1 : 1'b0; 
                inc_pc = 1'b1; 
            end // end: OP_ADDR

            OP_FETCH: begin 
                rd = (opcode == OP_ADD || opcode == OP_AND || opcode == OP_XOR || opcode == OP_LDA) ? 1'b1 : 1'b0; 
            end // end: OP_FETCH

            ALU_OP: begin
                rd = (opcode == OP_ADD || opcode == OP_AND || opcode == OP_XOR || opcode == OP_LDA) ? 1'b1 : 1'b0; 
                inc_pc = (opcode == OP_SKZ && is_zero) ? 1'b1 : 1'b0; 
              ld_pc = (opcode == OP_JMP) ? 1'b1 : 1'b0;
                data_e = (opcode == OP_STO) ? 1'b1 : 1'b0; 
            end // end: ALU_OP

            STORE: begin 
                rd =     (opcode == OP_ADD || opcode == OP_AND || opcode == OP_XOR || opcode == OP_LDA) ? 1'b1 : 1'b0; 
                ld_ac =  (opcode == OP_ADD || opcode == OP_AND || opcode == OP_XOR || opcode == OP_LDA) ? 1'b1: 1'b0; 
                ld_pc =  (opcode == OP_JMP) ? 1'b1 : 1'b0; 
                wr =     (opcode == OP_STO) ? 1'b1 : 1'b0; 
                data_e = (opcode == OP_STO) ? 1'b1 : 1'b0; 
            end // end: STORE
        endcase // endcase: current_state
    end // end: always @(*)
    
endmodule // endmodule: control_unit 
