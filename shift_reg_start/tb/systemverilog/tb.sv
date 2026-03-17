`timescale 1ns / 1ps


module tb_shift_register;

localparam CLK_PERIOD = 10; // 10ns per clock is 100MHz
localparam CLK_DIVIDER = 10; // example clock divider

logic clk = 0;
logic nRst, soft_reset;
logic [1:0] start_pos;
logic [3:0] led_out;

// test status tracking variables
int test_pass;
int test_fail;

// generate clock
always #(CLK_PERIOD / 2) clk = ~clk;

// instantiate the DUT
shift_register #(.CLOCK_DIVIDE_PARAM(CLK_DIVIDER))
DUT (
    .clk(clk),
    .nRst(nRst),
    .soft_reset(soft_reset),
    .start_pos(start_pos),
    .led_out(led_out)
);

// timeout watchdog
initial begin
    #10000;
    $display("\nSimulation time exceeded\n");
    $finish;
end

task automatic wait_clk_cycles(int n);
    repeat(n) @(posedge clk);
endtask

task automatic apply_hard_reset();
    @(posedge clk);
    nRst = 0;
    wait_clk_cycles(5);
    nRst = 1;
    wait_clk_cycles(5);

endtask : apply_hard_reset

task automatic start_test_with_post(int pos);
    @(posedge clk);
    start_pos = pos;
    soft_reset = 1;
    wait_clk_cycles(2);
    soft_reset = 0;
    wait_clk_cycles(100);
endtask : start_test_with_post

// main test sequence
initial begin
    nRst = 1;
    soft_reset = 0;
    start_pos = 0;
    test_pass = 0;
    test_fail = 0;

// hard reset test
    apply_hard_reset();
// soft reset test with all start position
    for (int i = 0; i < 4; i++) begin
        start_test_with_post(i);
    end
// test running with hard reset
end

// dump file
initial begin
    $dumpfile("shift_reg_wave.vcd");
    $dumpvars(0,tb_shift_register);
end
    
endmodule