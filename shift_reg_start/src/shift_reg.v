`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 06:11:06 PM
// Design Name: 
// Module Name: shift_register
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


module shift_register #(
    parameter integer CLOCK_DIVIDE_PARAM = 50000000
)(
    input logic clk,
    input logic nRst, 
    input logic soft_reset,
    input logic [1:0] start_pos,
    output logic [3:0] led_out
    );
    
    logic clk_en;
    logic [31:0] counter;
    
always_ff @(posedge clk, negedge nRst) begin
    if (!nRst) begin
      clk_en <= '0;
      counter <= '0;
    end else begin
      if (counter < CLOCK_DIVIDE_PARAM) begin
        counter <= counter + 1;
        clk_en <= 0;
      end else begin
        counter <= 0;
        clk_en <= 1;
      end
    end
end
    
always_ff @(posedge clk, negedge nRst) begin
    if (!nRst) begin
      led_out <= '0;
    end else if (soft_reset) begin
      led_out <= (4'b0001 << start_pos);
    end else if (clk_en) begin
      led_out <= {led_out[2:0], led_out[3]};
    end
end
endmodule
