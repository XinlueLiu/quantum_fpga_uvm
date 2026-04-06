module lfsr #(
    parameter [14:0] SEED_LFSR =15'h0001
)(
    input logic clk, rst_n,
    output logic [14:0] rand_out
);
    logic feedback;
    assign feedback = rand_out[14] ^ rand_out[0];

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            rand_out <= SEED_LFSR;
        end else begin
            // feed_back shift register, use [14, 0] as tap sets
            rand_out <= {feedback, rand_out[14:1]};
        end
    end

endmodule