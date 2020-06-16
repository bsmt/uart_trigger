`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2020 09:31:00 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx
#(parameter SYSCLK=100_000_000,
  parameter BAUDRATE=115200,
  parameter PARITY=0)
(
    input wire clk,        // system clock
    input wire rst,
    input wire en,         // enable
    input wire rx_line,    // serial rx line
    output reg [7:0] data, // a received byte
    output reg valid       // 1 when a complete byte is received and ready to be buffered
);

// state machine constants
localparam UART_START      = 3'b000; // waiting for start bit
localparam UART_START_WAIT = 3'b001; // wait for start bit to finish
localparam UART_DATA       = 3'b010; // receiving 
localparam UART_PARITY     = 3'b100; // receive parity bit
localparam UART_STOP       = 3'b011; // waiting for stop bit


wire uart_clk;
wire uart_mid_clk;
reg  baud_en;

reg [2:0] state       = UART_START;
reg [2:0] bits_recved = 3'b0;


uart_clkgen #(.SYSCLK(SYSCLK), .BAUDRATE(BAUDRATE)) clkgen
(
    .clk(clk),
    .rst(rst),
    .en(baud_en),
    .clk_out(uart_clk),
    .clk_middle(uart_mid_clk)
);


always @(posedge clk)
begin
    if (rst)
    begin
        state <= UART_START;
        baud_en <= 1'b0;
        data <= 8'h00;
        valid <= 1'b0;
    end
    else if (en)
    begin
        // defaults
        valid <= 1'b0;
        state <= state;
        bits_recved <= bits_recved;
        data <= data;
        
        case (state)
            UART_START:
            begin
                if (rx_line == 1'b0) // start bit found
                begin
                    valid <= 1'b0;
                    // start baud generator
                    baud_en <= 1'b1;
                    bits_recved <= 3'b0;
                    data <= 8'b0;
                    state <= UART_START_WAIT;
                end 
            end
            // we will get a baud pulse in the middle of the stop bit, which we don't want to sample
            // using this state to account for that
            // it's lame, whatever
            UART_START_WAIT:
            begin
                if (uart_mid_clk)
                begin
                    state <= UART_DATA;
                end
            end
            UART_DATA:
            begin
                // at the middle of a bit timing and it's not a start bit
                if (uart_mid_clk)
                begin
                    // shift in data
                    data <= {rx_line, data[7:1]};
                    bits_recved <= bits_recved + 1'b1;
                    
                    if (bits_recved == 3'd7) // goto next state
                    begin
                        if (PARITY == 0)
                        begin
                            state <= UART_STOP;
                        end
                        else
                        begin
                            state <= UART_PARITY;
                        end
                    end
                end
            end
            UART_PARITY:
            begin
                // wait for next bit time
                // then just go to next state
                // we don't need no parity bits
                if (uart_mid_clk)
                begin
                    state <= UART_STOP;
                end
            end
            UART_STOP:
            begin
                if (uart_mid_clk)
                begin
                    // wait for stop bit again
                    state <= UART_START;
                    // rx line should be high for stop bit, so valid = stop here effectively
                    //valid <= rx_line;
                    valid <= 1'b1;
                    // disable baud clock so our phase lines up at the next start bit
                    baud_en <= 1'b0;
                end
            end
        endcase
    end
    else
    begin
        valid <= 1'b0;
        state <= UART_START;
        bits_recved <= 3'b0;
        data <= 8'b0;
    end
end
 
endmodule
