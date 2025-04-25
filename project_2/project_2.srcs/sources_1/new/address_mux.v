`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2025 12:35:15 AM
// Design Name: 
// Module Name: address_mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "parameters.vh"

module address_mux(
    input wire [`AWIDTH-1:0] pc_addr, 
    input wire [`AWIDTH-1:0] instr_addr,
    input wire sel,
    output wire [`AWIDTH-1:0] out_addr
    );
    // if sel is 0, select instr_addr, otherwise select pc_addr
    assign out_addr = (sel == 1'b0) ? instr_addr : pc_addr; 

endmodule
