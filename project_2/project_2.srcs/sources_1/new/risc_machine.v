`include "parameters.vh"

module riscv_simple_processor (
    input wire clk,
    input wire rst,
    // Optional outputs for monitoring/debugging
    output wire cu_sel_o,      // Address MUX select
    output wire cu_rd_o,       // General read signal from CU
    output wire cu_ld_ir_o,    // Load Instruction Register
    output wire cu_halt_o,     // Halt signal
    output wire cu_inc_pc_o,   // Increment Program Counter
    output wire cu_ld_ac_o,    // Load Accumulator
    output wire cu_ld_pc_o,    // Load Program Counter (for jumps)
    output wire cu_wr_o,       // General write signal from CU (for Data Memory)
    output wire [`AWIDTH-1:0] current_pc_o,
    output wire [`DWIDTH-1:0] acc_val_o,
    output wire [2:0] cu_current_state_o,
    output wire [`DWIDTH-1:0] current_instruction_o
);

    // --- Internal Wires ---

    // Program Counter signals
    wire [`AWIDTH-1:0] pc_out_w;
    wire [`AWIDTH-1:0] pc_in_w; // Input to PC for jumps/branches

    // Instruction Memory signals
    wire [`DWIDTH-1:0] imem_instr_out_w; // Fetched instruction

    // Instruction Register signals
    wire [`DWIDTH-1:0] ir_out_w;         // Current instruction being processed
    wire [2:0]          ir_opcode_w;      // Opcode part of the instruction (bits 7-5)
    wire [`AWIDTH-1:0]  ir_operand_addr_extended_w; // Operand address part (bits 4-0), zero-extended to AWIDTH

    // Address MUX signals
    wire [`AWIDTH-1:0] addr_mux_out_w;   // Address going to Data Memory

    // Data Memory signals
    wire [`DWIDTH-1:0] dmem_data_bus_w;  // Bidirectional data bus for Data Memory
    wire               dmem_rd_en_w;     // Data Memory read enable
    wire               dmem_wr_en_w;     // Data Memory write enable

    // Accumulator signals
    wire [`DWIDTH-1:0] acc_out_w;

    // ALU signals
    wire [`DWIDTH-1:0] alu_result_w;
    wire               alu_is_zero_w;

    // Control Unit signals
    wire cu_sel_w;      // Address MUX select
    wire cu_rd_w;       // General read signal from CU
    wire cu_ld_ir_w;    // Load Instruction Register
    wire cu_halt_w;     // Halt signal
    wire cu_inc_pc_w;   // Increment Program Counter
    wire cu_ld_ac_w;    // Load Accumulator
    wire cu_ld_pc_w;    // Load Program Counter (for jumps)
    wire cu_wr_w;       // General write signal from CU (for Data Memory)
    // wire cu_data_e_w; // This signal from your CU is currently not used explicitly,
                        // as 'wr' and ALU output path to DMEM seems to cover STO.
    wire [2:0] cu_current_state_w;


    // --- Instruction Decoding ---
    // Assuming DWIDTH is 8, instruction format: Opcode (bits 7-5) | Operand_Address (bits 4-0)
    localparam OPCODE_MSB = `DWIDTH-1;        // 7
    localparam OPCODE_LSB = `DWIDTH-3;        // 5
    localparam OPERAND_ADDR_MSB = `DWIDTH-4;  // 4
    localparam OPERAND_ADDR_LSB = 0;          // 0
    localparam OPERAND_ADDR_WIDTH = OPERAND_ADDR_MSB - OPERAND_ADDR_LSB + 1; // 5

    assign ir_opcode_w = ir_out_w[OPCODE_MSB:OPCODE_LSB];
    // Zero-extend the 5-bit operand address from instruction to AWIDTH for memory addressing
    assign ir_operand_addr_extended_w = {{(`AWIDTH-OPERAND_ADDR_WIDTH){1'b0}}, ir_out_w[OPERAND_ADDR_MSB:OPERAND_ADDR_LSB]};


    // --- Component Instantiations ---

    // 1. Program Counter (PC)
    program_counter pc_unit (
        .clk(clk),
        .rst(rst),
        .inc_pc(cu_inc_pc_w),
        .ld_pc(cu_ld_pc_w),
        .pc_in(pc_in_w), // Jump target address
        .pc_out(pc_out_w)
    );
    // PC input for jumps comes from the instruction's operand address
    assign pc_in_w = ir_operand_addr_extended_w;

    // 2. Instruction Memory (IMEM)
    // IMEM is read when cu_rd_w is active during instruction fetch phases.
    // The CU's FSM and rd signal must align for this.
    instruction_memory imem_unit (
        .clk(clk),
        .rst(rst),
        .addr(pc_out_w),           // IMEM always addressed by PC
        .rd_en(cu_rd_w),           // Using CU's general 'rd' signal.
                                   // Assumes CU logic correctly activates 'rd' for IMEM reads
                                   // during relevant states (e.g., INST_FETCH, INST_LOAD).
        .instruction_out(imem_instr_out_w)
    );

    // 3. Instruction Register (IR)
    instruction_register ir_unit (
        .clk(clk),
        .rst(rst),
        .ld_ir(cu_ld_ir_w),
        .instruction_in(imem_instr_out_w),
        .ir_out(ir_out_w)
    );

    // 4. Address MUX (for Data Memory Address)
    // Selects between PC output or instruction operand address for Data Memory
    address_mux addr_mux_unit (
        .pc_addr(pc_out_w),                      // Source 1: Current PC value
        .instr_addr(ir_operand_addr_extended_w), // Source 0: Operand address from instruction
        .sel(cu_sel_w),                          // Select signal from Control Unit
        .out_addr(addr_mux_out_w)                // Output to Data Memory address port
    );

    // 5. Data Memory (DMEM)
    // DMEM is read when cu_rd_w is active during operand fetch phases.
    // DMEM is written when cu_wr_w is active.
    assign dmem_rd_en_w = cu_rd_w; // Using CU's general 'rd' signal for DMEM reads.
                                   // Assumes CU logic correctly activates 'rd' for DMEM reads
                                   // and sets 'sel' appropriately for DMEM addressing.
    assign dmem_wr_en_w = cu_wr_w; // Write enable from Control Unit

    data_memory dmem_unit (
        .clk(clk),
        .rst(rst),
        .addr(addr_mux_out_w),     // Address from Address MUX
        .wr_en(dmem_wr_en_w),      // Write enable
        .rd_en(dmem_rd_en_w),      // Read enable
        .data_io(dmem_data_bus_w)  // Bidirectional data bus
    );

    // 6. Accumulator Register (ACC)
    accumulator_register acc_unit (
        .clk(clk),
        .rst(rst),
        .ld_ac(cu_ld_ac_w),
        .acc_in(alu_result_w),     // ACC input from ALU result
        .acc_out(acc_out_w)
    );

    // 7. Arithmetic Logic Unit (ALU)
    alu alu_unit (
        .inA(acc_out_w),           // Input A from Accumulator
        .inB(dmem_data_bus_w),     // Input B from Data Memory bus (for LDA, ADD, etc.)
        .opcode(ir_opcode_w),      // Opcode from Instruction Register
        .result(alu_result_w),
        .is_zero(alu_is_zero_w)
    );

    // 8. Control Unit (CU)
    control_unit ctrl_unit (
        .clk(clk),
        .rst(rst),
        .opcode(ir_opcode_w),
        .is_zero(alu_is_zero_w),
        .sel(cu_sel_w),
        .rd(cu_rd_w),
        .ld_ir(cu_ld_ir_w),
        .halt(cu_halt_w),
        .inc_pc(cu_inc_pc_w),
        .ld_ac(cu_ld_ac_w),
        .ld_pc(cu_ld_pc_w),
        .wr(cu_wr_w),
        .data_e(), // cu_data_e_w - This signal is not explicitly connected as 'wr' handles STO enable.
                   // If 'data_e' had a specific role like enabling an output buffer for STO distinct
                   // from 'wr', it would be connected here.
        .current_state(cu_current_state_w)
    );


    // --- Data Bus Management for Data Memory ---
    // The dmem_data_bus_w is shared:
    // - Data Memory drives it during a read (dmem_unit handles this internally via its 'rd_en').
    // - ALU result drives it during a store to Data Memory.
    //   This requires an explicit tristate buffer if dmem_unit doesn't expect data_io to be driven externally during write.
    //   However, the dmem_unit's "assign data_io = (rd_en && !wr_en) ? read_data_reg : {`DWIDTH{1'bz}};"
    //   means when wr_en=1, data_io is high-Z from dmem's perspective, so it acts as an input.
    //   Thus, we need to drive alu_result_w onto dmem_data_bus_w when writing.
    assign dmem_data_bus_w = dmem_wr_en_w ? alu_result_w : {`DWIDTH{1'bz}};




    // --- Assign Optional Outputs for Debugging/Monitoring ---
    assign cu_sel_o = cu_sel_w;
    assign cu_rd_o = cu_rd_w;
    assign cu_ld_ir_o = cu_ld_ir_w;
    assign cu_halt_o = cu_halt_w;
    assign cu_inc_pc_o = cu_inc_pc_w;
    assign cu_ld_ac_o = cu_ld_ac_w;
    assign cu_ld_pc_o = cu_ld_pc_w;
    assign cu_wr_o = cu_wr_w;
    assign current_pc_o = pc_out_w;
    assign acc_val_o = acc_out_w;
    assign cu_current_state_o = cu_current_state_w;
    assign current_instruction_o = ir_out_w; // Or imem_instr_out_w for fetched, not-yet-latched instruction

endmodule