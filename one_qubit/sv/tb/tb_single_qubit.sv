`timescale 1ns/1ps

module tb_single_qubit;

localparam CLK_PERIOD = 10;
localparam NUM_MEASUREMENT = 1000;

logic clk = 0, rst_n;
logic signed [15:0] alpha_real;
logic signed [15:0] alpha_imag;
logic signed [15:0] beta_real;
logic signed [15:0] beta_imag;
logic load_en, measure_en;
logic [2:0] read_addr;
logic signed [15:0] read_val;

real one_chance = 0;
real zero_chance = 0;

// clock generation
always #(CLK_PERIOD / 2) clk = ~clk;

// instantiate the DUT
single_qubit DUT (
    .clk(clk),
    .rst_n(rst_n),
    .alpha_real(alpha_real),
    .alpha_imag(alpha_imag),
    .beta_real(beta_real),
    .beta_imag(beta_imag),
    .load_en(load_en),
    .measure_en(measure_en),
    .read_addr(read_addr),
    .read_val(read_val)
);

// function to reset
task config_reset();
    @(posedge clk);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
endtask

task perform_measurement();
    one_chance = 0;
    zero_chance = 0;
    for(int i = 0; i < NUM_MEASUREMENT; i++) begin
        @(posedge clk); 
        load_en = 0;
        measure_en = 1;
        @(posedge clk);
        measure_en = 0;
        read_addr = 4;
        @(posedge clk);
        // if (i < 5) begin
        //     $display("DEBUG: P0_val=%0d, rand_out=%0d, config_mem[0]=%0h",                                                               
        //        DUT.P0_val, DUT.rand_out, DUT.config_mem[0]);                                                                       
        // end  
        if (read_val == 1) begin
            one_chance = one_chance + 1;
        end else begin
            zero_chance = zero_chance + 1;
        end
    end
endtask

// function to assign |0 state
task config_0_state();
    @(posedge clk);
    alpha_real = 16'h7fff;
    alpha_imag = 0;
    beta_real = 0;
    beta_imag = 0;
    load_en = 1;
endtask
// function to assign |1 state
task config_1_state();
    @(posedge clk);
    alpha_real = 0;
    alpha_imag = 0;
    beta_real = 16'h7fff;
    beta_imag = 0;
    load_en = 1;
endtask
// function to assign |+ state
task config_plus_state();
    @(posedge clk);
    alpha_real = 16'h5a82;
    alpha_imag = 0;
    beta_real = 16'h5a82;
    beta_imag = 0;
    load_en = 1;
endtask
// function to assign |- state
task config_minus_state();
    @(posedge clk);
    alpha_real = 16'h5a82;
    alpha_imag = 0;
    beta_real = 16'ha57e;
    beta_imag = 0;
    load_en = 1;
endtask
// function to assign |i state
task config_plus_i_state();
    @(posedge clk);
    alpha_real = 16'h5a82;
    alpha_imag = 0;
    beta_real = 0;
    beta_imag = 16'h5a82;
    load_en = 1;
endtask
// function to assign |-i state
task config_minus_i_state();
    @(posedge clk);
    alpha_real = 16'h5a82;
    alpha_imag = 0;
    beta_real = 0;
    beta_imag = 16'ha57e;
    load_en = 1;
endtask


initial begin
    // reset
    config_reset();
    $display("rst_n=%b", rst_n);
    // |0> state
    config_0_state();
    perform_measurement();
    $display("measured for |0 state. possiblity of getting 0 is %f, getting 1 is %f", zero_chance / (zero_chance + one_chance) , one_chance / (zero_chance + one_chance));
     // |1> state
    config_1_state();
    perform_measurement();
    $display("measured for |1 state. possiblity of getting 0 is %f, getting 1 is %f", zero_chance / (zero_chance + one_chance) , one_chance / (zero_chance + one_chance));
     // |+> state
    config_plus_state();
    perform_measurement();
    $display("measured for |+ state. possiblity of getting 0 is %f, getting 1 is %f", zero_chance / (zero_chance + one_chance) , one_chance / (zero_chance + one_chance));
     // |-> state
    config_minus_state();
    perform_measurement();
    $display("measured for |- state. possiblity of getting 0 is %f, getting 1 is %f", zero_chance / (zero_chance + one_chance) , one_chance / (zero_chance + one_chance));
     // |i> state
    config_plus_i_state();
    perform_measurement();
    $display("measured for |i state. possiblity of getting 0 is %f, getting 1 is %f", zero_chance / (zero_chance + one_chance) , one_chance / (zero_chance + one_chance));
     // |-> state
    config_minus_i_state();
    perform_measurement();
    $display("measured for |-i state. possiblity of getting 0 is %f, getting 1 is %f", zero_chance / (zero_chance + one_chance) , one_chance / (zero_chance + one_chance));
    $finish;
end

// Waveform dump
initial begin
    $dumpfile("single_qubit.vcd");
    $dumpvars(0, tb_single_qubit);
end

endmodule