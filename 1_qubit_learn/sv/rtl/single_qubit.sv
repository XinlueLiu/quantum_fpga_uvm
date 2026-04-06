module single_qubit (
    input logic clk, rst_n,
    input logic signed [15:0] alpha_real,  // a+bj, value a
    input logic signed [15:0] alpha_imag,  // a+bj, value b
    input logic signed [15:0] beta_real,   // a+bj, value a
    input logic signed [15:0] beta_imag,   // a+bj, value b
    input logic load_en,                   // 0:not loading initial alpha and beta. 1: initial loading. tb will load for 1 clock cycle to read
    input logic measure_en,                // 0:not measuring initial alpha and beta. 1: initial measurement
    input logic [2:0] read_addr,           // address tb wants to read after measurement
    output logic signed [15:0] read_val    // value read after the measurement
);

    logic signed [31:0] P0_val_read;    
    logic signed [31:0] P0_val_imag;
    logic [14:0] P0_val;

    logic [14:0] rand_out;
    lfsr rand_num_gen (
        .clk(clk),
        .rst_n(rst_n),
        .rand_out(rand_out)
    );
    
    // declare the configuration register
    logic signed [15:0] config_mem [4:0];
    assign P0_val_read = config_mem[0] * config_mem[0];
    assign P0_val_imag = config_mem[1] * config_mem[1];
    assign P0_val = P0_val_read[29:15] + P0_val_imag[29:15];
    assign read_val = config_mem[read_addr];


    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            // clean the memory
            for(int i = 0; i < 5; i++) begin
                config_mem[i] <= '0;
            end
        end else begin
            if (load_en) begin
                config_mem[0] <= alpha_real;
                config_mem[1] <= alpha_imag;
                config_mem[2] <= beta_real;
                config_mem[3] <= beta_imag;
            end 
            // generate random number
            // if random_number < P(0), stores 0. otherwise, store 1
            if (measure_en) begin
                if (rand_out < P0_val) begin
                    config_mem[4] <= 0;
                end else begin
                    config_mem[4] <= 1;
                end
            end
        end 
    end

endmodule