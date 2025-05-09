`include "parameters.vh"

module data_memory (
    input wire clk,                         // Clock input
    input wire rst,                         // Reset input (active high assumed)
    input wire [`AWIDTH-1:0] addr,     // Address input
    input wire wr_en,                       // Write enable
    input wire rd_en,                       // Read enable (acts as an output enable for data_io)
    inout wire [`DWIDTH-1:0] data_io   // Bidirectional data port
);

    // Memory array for data
    reg [`DWIDTH-1:0] d_memory [0:(2**`AWIDTH)-1];
    // Internal register to hold data read from memory before driving the bus
    reg [`DWIDTH-1:0] read_data_reg;
    integer i ;
    localparam DATA_1_ADDR = 5'h1A;
    localparam DATA_2_ADDR = 5'h1B;
    localparam TEMP_ADDR   = 5'h1C;
    // Initialize data memory (optional, for simulation / BRAM initialization)
    initial begin
        // $display("Initializing Data Memory (bidirectional) at time %0t...", $time);
        // Example initial data values
//        d_memory[0] = 8'd5;
//        d_memory[1] = 8'd0;
//        d_memory[2] = 8'h00; // Will be overwritten by STO in example program
        
        // Initialize remaining data memory to 0 (optional)
        for (i = 0; i < (2**`AWIDTH); i = i + 1) begin
            d_memory[i] = 0;
        end
        
                // Initialize specific data memory locations
        d_memory[DATA_1_ADDR] = 8'h00; // DATA_1: 0x00
        d_memory[DATA_2_ADDR] = 8'hFF; // DATA_2: 0xFF
        d_memory[TEMP_ADDR]   = 8'hAA; // TEMP: 0xAA (Initial value, will be overwritten)
//        $display("Data Memory (bidirectional) Initialization Complete.");
    end

    // Synchronous write operation
    // Captures data from data_io bus into memory when wr_en is active
    always @(posedge clk) begin
        if (rst) begin
            // No specific reset action for d_memory array itself here,
            // contents are preserved or loaded by 'initial'.
        end else begin
            if (wr_en) begin // Assuming rd_en is low when wr_en is high
                d_memory[addr] <= data_io;
//                $display("DATA_MEM WRITE @%0t: addr=%h, data_from_bus(data_io)=%h", $time, addr, data_io);
            end
        end
    end

    // Synchronous read operation
    // Reads data from memory array into an internal register
    always @(posedge clk) begin
        if (rst) begin
            read_data_reg <= {`DWIDTH{1'b0}};
        end else begin
            if (rd_en) begin // Assuming wr_en is low when rd_en is high
                read_data_reg <= d_memory[addr];
                // $display("DATA_MEM Internal Read @%0t: addr=%h, value_to_read_data_reg=%h", $time, addr, d_memory[addr]);
            end
            // If not reading, read_data_reg holds its value.
        end
    end

    // Driving the bidirectional port
    // data_io is driven by read_data_reg when reading (rd_en is high),
    // otherwise it's high-impedance (Z) to allow external drivers during write.
    assign data_io = (rd_en && !wr_en) ? read_data_reg : {`DWIDTH{1'bz}};

endmodule