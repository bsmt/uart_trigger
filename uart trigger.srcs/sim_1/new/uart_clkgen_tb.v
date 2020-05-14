`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2020 10:11:10 PM
// Design Name: 
// Module Name: uart_clkgen_tb
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


module uart_clkgen_tb(
    );

reg clk_in;
reg rst = 0;
reg en = 0;
wire uart_clk;
wire uart_clk_middle;

uart_clkgen #(.SYSCLK(100_000_000), .BAUDRATE(115200)) clkgen (
    .clk(clk_in),
    .rst(rst),
    .en(en),
    .clk_out(uart_clk),
    .clk_middle(uart_clk_middle)
);

initial
begin
    // do initial reset for one cycle
    clk_in = 0;
    rst = 1;
    en = 0;
    #5;
    clk_in = 1;
    #5;
    clk_in = 0;
    rst = 0;
    #5;
    en = 1;
    clk_in = 1;
    
    // generate 100MHz clock
    for (i = 0; i < 5; i = i + 1)
    begin
        #5 clk_in = ~clk_in;
    end
end

endmodule
