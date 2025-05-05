`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2025
// Design Name: 
// Module Name: ins_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//    Instruction Memory for RISC processor
//    - 32 locations x 8-bit memory
//    - Synchronous read operation
//    - Stores both instructions and data
// 
// Dependencies: 
//    parameters.vh for AWIDTH and DWIDTH definitions
// 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.vh"

module ins_memory(
    input wire clk,                    // Clock input
    input wire rd,
    input wire wr, 
    input wire data_en,
    input wire rst,
    input wire [`AWIDTH-1:0] addr,     // 5-bit address input
    output reg [`DWIDTH-1:0] data_out  // 8-bit data output
);

    // Memory array: 32 locations x 8-bit
    reg [`DWIDTH-1:0] memory [0:(2**`AWIDTH)-1];

    // Initialize memory with a test program
    initial begin
        // This is for testing program, not for a real program
        // // Example program:
        // // You can modify these values based on your program needs
        // memory[0]  = 8'b101_00000;  // LDA 0    ; Load value from address 0
        // memory[1]  = 8'b011_00001;  // ADD 1    ; Add value from address 1
        // memory[2]  = 8'b110_00010;  // STO 2    ; Store result to address 2
        // memory[3]  = 8'b000_00000;  // HLT      ; Halt the processor
        
        // // Initialize data locations
        // memory[16] = 8'h05;         // Example data
        // memory[17] = 8'h03;         // Example data
        
        // // Initialize remaining memory to 0
        // for (integer i = 4; i < 16; i = i + 1) begin
        //     memory[i] = 8'h00;
        // end
        // for (integer i = 18; i < 32; i = i + 1) begin
        //     memory[i] = 8'h00;
        // end
    end

    // Synchronous read operation
    always @(posedge clk) begin
        if (rst) begin
            memory[0] = 8'b000_00000;
            memory[1] = 8'b000_00000;
            memory[2] = 8'b000_00000;
            memory[3] = 8'b000_00000;
            memory[4] = 8'b000_00000;
            memory[5] = 8'b000_00000;
            memory[6] = 8'b000_00000;
            memory[7] = 8'b000_00000;
            memory[8] = 8'b000_00000;
            memory[9] = 8'b000_00000;
            memory[10] = 8'b000_00000;
            memory[11] = 8'b000_00000;
            memory[12] = 8'b000_00000;
            memory[13] = 8'b000_00000;
            memory[14] = 8'b000_00000;
            memory[15] = 8'b000_00000;
            memory[16] = 8'b000_00000;
            memory[17] = 8'b000_00000;
            memory[18] = 8'b000_00000;
            memory[19] = 8'b000_00000;
            memory[20] = 8'b000_00000;
            memory[21] = 8'b000_00000;
            memory[22] = 8'b000_00000;
            memory[23] = 8'b000_00000;
            memory[24] = 8'b000_00000;
            memory[25] = 8'b000_00000;
            memory[26] = 8'b000_00000;
            memory[27] = 8'b000_00000;
            memory[28] = 8'b000_00000;
            memory[29] = 8'b000_00000;
            memory[30] = 8'b000_00000;
            memory[31] = 8'b000_00000;
            
        end
        if (rd_en) begin
            data_out <= memory[addr];
        end
    end

endmodule