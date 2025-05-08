// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module controlunit_tb;

    reg clk;
    reg rst; // Reset tích cực thấp (active-low)
    reg [2:0] opcode;
    reg is_zero;

    wire sel;
    wire rd;
    wire ld_ir;
    wire halt;
    wire inc_pc;
    wire ld_ac;
    wire ld_pc;
    wire wr;
    wire data_e;

    // Instantiate the Design Under Test (DUT)
    control_unit dut (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .is_zero(is_zero),
        .sel(sel),
        .rd(rd),
        .ld_ir(ld_ir),
        .halt(halt),
        .inc_pc(inc_pc),
        .ld_ac(ld_ac),
        .ld_pc(ld_pc),
        .wr(wr),
        .data_e(data_e)
    );

    // Clock generation
    localparam CLK_PERIOD = 10; // Chu kỳ clock là 10ns
    always #(CLK_PERIOD/2) clk = ~clk;

    // Stimulus generation and control
    initial begin
        // Thiết lập file dump VCD để xem dạng sóng
        $dumpfile("dump.vcd");
        // Dump tất cả các biến trong module controlunit_tb và các module con (DUT)
        $dumpvars(0, controlunit_tb);

        // 1. Khởi tạo các tín hiệu đầu vào và áp dụng reset
        clk = 1'b0;       // Bắt đầu clock ở mức thấp
        rst = 1'b0;       // Kích hoạt reset (rst=0 là active cho DUT của bạn)
        opcode = 3'b000;  // Giá trị khởi tạo mặc định
        is_zero = 1'b0;   // Giá trị khởi tạo mặc định

        $display("Time=%0dns: Bat dau Reset (rst=0)", $time);
        // Giữ reset trong 2 chu kỳ clock
        // Ở mỗi sườn lên của clock khi rst=0, DUT sẽ vào trạng thái INST_ADDR
        repeat (2) @(posedge clk);
        #1; // Độ trễ nhỏ để dễ xem dạng sóng

        // 2. Ngừng kích hoạt reset để FSM bắt đầu hoạt động
        rst = 1'b1; // Cho rst lên 1
        $display("Time=%0dns: Ngung Reset (rst=1). FSM bat dau hoat dong.", $time);
        // Đợi một sườn lên của clock để trạng thái reset được giải phóng và FSM chuyển trạng thái
        // Sau sườn lên này, nếu current_state là INST_ADDR, nó sẽ chuyển sang INST_FETCH
        @(posedge clk);
        #1; // Độ trễ nhỏ

        // 3. Vòng lặp qua tất cả các giá trị opcode, kiểm tra với is_zero = 0 và is_zero = 1
        // Mỗi opcode có FSM 8 trạng thái, một chu trình đầy đủ là 8 xung clock.
        // Ta sẽ kiểm tra mỗi cặp (opcode, is_zero) trong 8 xung clock.
        for (integer op_idx = 0; op_idx < 8; op_idx = op_idx + 1) begin
            opcode = op_idx[2:0]; // Gán opcode hiện tại

            // Kiểm tra với is_zero = 0
            is_zero = 1'b0;
            $display("--------------------------------------------------------------------");
            $display("Time=%0dns: Kiem tra Opcode: %b (%d), is_zero: 0", $time, opcode, opcode);
            $display("--------------------------------------------------------------------");
            // Cho FSM chạy 8 chu kỳ clock
            repeat (8) @(posedge clk);
            #1; // Độ trễ nhỏ để dạng sóng rõ ràng hơn

            // Kiểm tra với is_zero = 1
            is_zero = 1'b1;
            $display("--------------------------------------------------------------------");
            $display("Time=%0dns: Kiem tra Opcode: %b (%d), is_zero: 1", $time, opcode, opcode);
            $display("--------------------------------------------------------------------");
            // Cho FSM chạy 8 chu kỳ clock
            repeat (8) @(posedge clk);
            #1; // Độ trễ nhỏ
        end

        $display("--------------------------------------------------------------------");
        $display("Time=%0dns: Mo phong hoan tat.", $time);
        $display("--------------------------------------------------------------------");
        $finish; // Kết thúc mô phỏng
    end

    // Monitor outputs - khối này chạy đồng thời với khối stimulus ở trên
    initial begin
        // In tiêu đề cho output của $monitor
        $display("\nTime\t\tOpcode\tis_zero\tSEL\tRD\tLD_IR\tHALT\tINC_PC\tLD_AC\tLD_PC\tWR\tDATA_E");
        // $monitor sẽ in ra mỗi khi có sự thay đổi ở các tín hiệu được theo dõi
        $monitor("%0dns\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b",
                 $time, opcode, is_zero, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
    end

endmodule