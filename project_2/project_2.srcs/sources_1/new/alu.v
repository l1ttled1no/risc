module alu (
    input wire [7:0] inA,     // input a
    input wire [7:0] inB,     // input b
    input wire [2:0] opcode,  // opcode (CORRECTED TO 3-BIT)
    output reg [7:0] result,  // result value
    output wire is_zero       // is_zero indicates if ALU 'result' is 0
);

    // 'is_zero' should ideally reflect if the ALU 'result' is zero.
    // This is the most common interpretation for an ALU zero flag.
    assign is_zero = (result == 8'b00000000);

    always @(inA, inB, opcode) begin // Combinational block
        // Default assignment to prevent latches if any path isn't covered,
        // though with a full case for a 3-bit opcode, it's less critical for latches
        // but good for defining behavior for unknown opcodes during simulation.
        result = 8'hXX; // Default to 'X' for undefined opcodes (or 8'h00)
        case (opcode)
            3'b000: begin // HALT Program (ALU might just pass through a value)
                result = inA;
            end

            3'b001: begin // SKZ (Skip if Zero). ALU often just passes through a value like inA.
                          // The control unit would use the 'is_zero' flag (based on this 'result').
                result = inA;
            end

            3'b010: begin // ADD
                // case 3'b010: ADD, result = inA + inB (COMMENT FIXED)
                result = inA + inB;
            end

            3'b011: begin // AND
                result = inA & inB;
            end

            3'b100: begin // XOR
                result = inA ^ inB;
            end

            3'b101: begin // LDA (Load Accumulator, e.g., result gets value from 'memory' via inB)
                result = inB;
            end

            3'b110: begin // STO (Store Accumulator, e.g., result gets value from 'accumulator' via inA)
                result = inA;
            end

            3'b111: begin // JMP (Jump, e.g., result might hold target address from inA)
                result = inA;
            end

            default: begin
                result = 8'hXX; // Or 8'b00000000; // Handle undefined opcodes
            end
        endcase
    end
endmodule