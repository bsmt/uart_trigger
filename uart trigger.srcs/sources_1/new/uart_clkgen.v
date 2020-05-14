`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2020 08:48:44 PM
// Design Name: 
// Module Name: uart_clkgen
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


module uart_clkgen
#(parameter SYSCLK=100_000_000,
  parameter BAUDRATE=115200)
(
    input wire clk,        // system clock
    input wire rst,        // active high reset
    input wire en,         // enable
    output wire clk_out,   // output divided clock
    output wire clk_middle // will be high for one system clock at negedge
);

localparam CLK_DIVISOR = SYSCLK / BAUDRATE;
localparam CLK_MAX = CLK_DIVISOR - 1;
localparam DIVISOR_SIZE = $clog2(CLK_DIVISOR); // how big the counter is in bits, so we can define a reg 
localparam MIDDLE_POS = (CLK_DIVISOR / 2);

reg [DIVISOR_SIZE - 1:0] clk_counter;

always @(posedge clk)
begin
    if (rst) // reset
    begin
        clk_counter <= 0;
    end
    else if (en)
    begin
        clk_counter <= clk_counter + 1;
        if (clk_counter == CLK_MAX)
        begin
            clk_counter <= 0;
        end
    end
    else
    begin
        clk_counter <= CLK_MAX;
    end
end

assign clk_out = (clk_counter < MIDDLE_POS) ? en : 1'b0;
assign clk_middle = (clk_counter == MIDDLE_POS);

endmodule
