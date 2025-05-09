`include "parameters.vh"
module instruction_memory (
    input wire clk,                         // Clock input
    input wire rst,                         // Reset input (active high assumed)
    input wire [`AWIDTH-1:0] addr,          // Address input (from Program Counter)
    input wire rd_en,                       // Read enable (often always true or tied to a fetch cycle signal)
    output reg [`DWIDTH-1:0] instruction_out // Fetched instruction output
);

    // Memory array for instructions
    reg [`DWIDTH-1:0] i_memory [0:(2**`AWIDTH)-1];
    integer i;
    // Initialize instruction memory with a program (for simulation / BRAM initialization)
        localparam BEGIN_ADDR   = 5'h00;
    // HLT at 0x01
    // HLT at 0x02
    localparam JMP_OK_ADDR  = 5'h03;
    // SKZ at 0x04
    // HLT at 0x05
    // LDA DATA_2 at 0x06
    // SKZ at 0x07
    // JMP SKZ_OK at 0x08
    // HLT at 0x09
    localparam SKZ_OK_ADDR  = 5'h0A;
    // LDA DATA_1 at 0x0B
    // STO TEMP at 0x0C
    // LDA TEMP at 0x0D
    // SKZ at 0x0E
    // HLT at 0x0F
    // XOR DATA_2 at 0x10
    // SKZ at 0x11
    // JMP XOR_OK at 0x12
    // HLT at 0x13
    localparam XOR_OK_ADDR  = 5'h14;
    // SKZ at 0x15
    // HLT at 0x16
    localparam END_ADDR     = 5'h17;
    // JMP BEGIN at 0x18
    // ...
    localparam TST_JMP_ADDR = 5'h1E;
    // HLT at 0x1F

    // --- Define Data Memory Addresses (for instruction operands) ---
    localparam DATA_1_OPERAND = 5'h1A; // Corresponds to DATA_1 address in data memory
    localparam DATA_2_OPERAND = 5'h1B; // Corresponds to DATA_2 address in data memory
    localparam TEMP_OPERAND   = 5'h1C; // Corresponds to TEMP address in data memory
    initial begin
        $display("Initializing Instruction Memory for complex test case at time %0t...", $time);

        // Initialize all instruction memory to HLT by default
        for (i = 0; i < (2**`AWIDTH); i = i + 1) begin
            i_memory[i] = {`HLT, 5'd0}; // Default to HLT
        end

        // --- Program Instructions ---
        // @00 BEGIN : JMP TST_JMP
        i_memory[BEGIN_ADDR]    = {`JMP, TST_JMP_ADDR[4:0]}; // JMP target is TST_JMP (0x1E)
        // 01 HLT (already default)
        // 02 HLT (already default)

        // @03 JMP_OK: LDA DATA_1
        i_memory[JMP_OK_ADDR]   = {`LDA, DATA_1_OPERAND[4:0]};
        // 04 SKZ (operand usually doesn't matter for SKZ, or is 0)
        i_memory[5'h04]         = {`SKZ, 5'd0};
        // 05 HLT (already default)

        // 06 LDA DATA_2
        i_memory[5'h06]         = {`LDA, DATA_2_OPERAND[4:0]};
        // 07 SKZ
        i_memory[5'h07]         = {`SKZ, 5'd0};
        // 08 JMP SKZ_OK
        i_memory[5'h08]         = {`JMP, SKZ_OK_ADDR[4:0]};
        // 09 HLT (already default)

        // @0A SKZ_OK: STO TEMP
        i_memory[SKZ_OK_ADDR]   = {`STO, TEMP_OPERAND[4:0]};
        // 0B LDA DATA_1
        i_memory[5'h0B]         = {`LDA, DATA_1_OPERAND[4:0]};
        // 0C STO TEMP
        i_memory[5'h0C]         = {`STO, TEMP_OPERAND[4:0]};
        // 0D LDA TEMP
        i_memory[5'h0D]         = {`LDA, TEMP_OPERAND[4:0]};
        // 0E SKZ
        i_memory[5'h0E]         = {`SKZ, 5'd0};
        // 0F HLT (already default)

        // 10 XOR DATA_2
        i_memory[5'h10]         = {`XOR, DATA_2_OPERAND[4:0]}; // Assuming XOR uses inB from memory
        // 11 SKZ
        i_memory[5'h11]         = {`SKZ, 5'd0};
        // 12 JMP XOR_OK
        i_memory[5'h12]         = {`JMP, XOR_OK_ADDR[4:0]};
        // 13 HLT (already default)

        // @14 XOR_OK: XOR DATA_2
        i_memory[XOR_OK_ADDR]   = {`XOR, DATA_2_OPERAND[4:0]};
        // 15 SKZ
        i_memory[5'h15]         = {`SKZ, 5'd0};
        // 16 HLT (already default)

        // @17 END: HLT (already default, but can be explicit)
        i_memory[END_ADDR]      = {`HLT, 5'd0};

        // 18 JMP BEGIN
        i_memory[5'h18]         = {`JMP, BEGIN_ADDR[4:0]};

        // @1E TST_JMP: JMP JMP_OK
        i_memory[TST_JMP_ADDR]  = {`JMP, JMP_OK_ADDR[4:0]};
        // 1F HLT (already default)

        // $display("Instruction Memory Initialization Complete.");
        // You can add more $display statements here to verify specific memory contents if needed
        // e.g., $display("i_memory[0x00] = %b", i_memory[BEGIN_ADDR]);
        //      $display("i_memory[0x03] = %b", i_memory[JMP_OK_ADDR]);
    end

    // Synchronous read operation
    always @(posedge clk) begin
        if (rst) begin
            instruction_out <= {`DWIDTH{1'b0}}; // Reset output
        end else begin
            if (rd_en) begin // Read enable for instruction fetch
                instruction_out <= i_memory[addr];
                // $display("INST_MEM READ @%0t: addr=%h, inst_out_next_cycle_will_be=%h", $time, addr, i_memory[addr]);
            end
            // If not rd_en, instruction_out holds its value
        end
    end

endmodule