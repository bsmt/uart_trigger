`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2020 08:35:26 PM
// Design Name: 
// Module Name: top
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

// See ST AN3155 for documentation on bootloader UART protocol

// Connection instructions:
// RST on arty to nRST on CW308
// GND to... GND
// IO0 to UART TX on CW308 (CW to target)
// IO1 to UART RX on CW308 (target to CW)
// IO7 to trigger

module top(
    input wire clk,
    input wire ck_rst,
    input wire [3:0] btn,
    input wire target_rx,
    input wire target_tx,
    input wire uart_txd_in,
    output wire uart_rxd_out,
    output reg trigger,
    output reg [3:0] led
    );

localparam STATE_IDLE         = 2'b00; // waiting for a byte on UART
localparam STATE_COMMAND_BYTE = 2'b01; // that byte's the command byte we want (0x11)
localparam STATE_CHECK_BYTE   = 2'b10; // and a valid checksum byte followed. we're definitely reading mem and it's time to glitch!
localparam STATE_TRIGGER      = 2'b11; // holding trigger for some time

localparam TRIGGER_HOLD_DUR   = 2'b11; // how many cycles to hold the trigger for

wire rst_btn = btn[0];

assign uart_rxd_out = target_tx;

reg uart_en = 1'b1;
wire [7:0] uart_byte;
wire uart_valid;
reg [1:0] state;
reg [1:0] trigger_count;

uart_rx #(.SYSCLK(100_000_000), .BAUDRATE(38400)) rx
(
    .clk(clk),        // system clock
    .rst(rst),
    .en(uart_en),         // enable
    .rx_line(target_tx),    // serial tx line
    .data(uart_byte), // a received byte
    .valid(uart_valid)       // 1 when a complete byte is received and ready to be buffered
); 

always @(posedge clk)
begin
    if (rst_btn == 1 || ck_rst == 0) // reset
    begin
        led[0] <= 1'b0;
        led[1] <= 1'b0;
        led[2] <= 1'b0;
        led[3] <= 1'b0;
        state <= STATE_IDLE;
        trigger <= 1'b0;
        trigger_count <= 2'b00;
    end
    else
    begin
        // defaults
        led[0] <= 1'b1;
        trigger <= 1'b0;

        case (state)
        STATE_IDLE:
        begin
            if (uart_valid) // we found a byte!
            begin
                if (uart_byte == 8'h11) // is it the read memory command?
                begin
                // this assumes uart_valid will drop back to 0 at the next system clock cycle
                    state <= STATE_COMMAND_BYTE;
                end
            end
        end
        STATE_COMMAND_BYTE: // have command byte
        begin
            if (uart_valid) // we found another byte!
            begin
                if (uart_byte == 8'hee) // is it the checksum?
                begin
                    state <= STATE_CHECK_BYTE;
                end
                else // what should we do if we don't get the right byte? go back to idle? just hang out and wait for the right one?
                begin
                    state <= STATE_IDLE;
                end
            end
        end
        STATE_CHECK_BYTE: // have checksum byte
        begin
            led[1] <= 1'b1;
            trigger <= 1'b1;
            trigger_count <= 2'b00;
            state <= STATE_TRIGGER;            
        end
        STATE_TRIGGER:
        begin
            if  (trigger_count < TRIGGER_HOLD_DUR)
            begin
                trigger <= 1'b1;
                trigger_count <= trigger_count + 2'b01;
            end
            else
            begin
                trigger <= 1'b0;
                trigger_count <= 2'b00;
                state <= STATE_IDLE;
            end
        end
        endcase
    end
end

endmodule
