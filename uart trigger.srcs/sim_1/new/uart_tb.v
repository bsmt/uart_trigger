`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2020 10:49:26 PM
// Design Name: 
// Module Name: uart_tb
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


module uart_tb(

    );

reg clk;
reg rst;
reg en;
wire uart;
wire [7:0] uart_rx;
wire uart_valid;
wire uart_ready;

uart_tx #(.SYSCLK(100_000_000), .BAUDRATE(115200)) tx
(
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .tx_byte(8'h41),
    .tx_line(uart),
    .ready(uart_ready)
);

uart_rx #(.SYSCLK(100_000_000), .BAUDRATE(115200)) rx
(
    .clk(clk),        // system clock
    .rst(rst),
    .en(en),         // enable
    .rx_line(uart),    // serial rx line
    .data(uart_rx), // a received byte
    .valid(uart_valid)       // 1 when a complete byte is received and ready to be buffered
);

initial
begin
    clk = 1'b0;
    rst = 1'b1;
    en = 1'b0;
    #5;
    clk = ~clk;
    #5;
    clk = ~clk;
    rst = 1'b0;
    #5;
    clk = ~clk;
    en = 1'b1;

    forever
    begin
        #5 clk = ~clk;
    end
    
end
endmodule
