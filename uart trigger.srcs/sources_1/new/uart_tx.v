`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2020 10:53:47 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx
#(parameter SYSCLK=100_000_000,
  parameter BAUDRATE=115200)
(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [7:0] tx_byte,
    input wire start,
    output reg tx_line,
    output reg ready
);

// state machine constants
localparam UART_START      = 2'b00; // sending start bit
localparam UART_DATA       = 2'b01; // sending data
localparam UART_STOP       = 2'b10; // sending stop bit
localparam UART_IDLE       = 2'b11; // waiting for data to send

reg [1:0] state = UART_START;
reg [7:0] local_data = 8'd0;
reg [3:0] bits_sent = 3'b000;
wire uart_clk;

uart_clkgen #(.SYSCLK(SYSCLK), .BAUDRATE(BAUDRATE)) clkgen
(
    .clk(clk),
    .rst(rst),
    .en(en),
    .clk_out(uart_clk)
);

always @(posedge uart_clk)
begin
    if (rst)
    begin
        state <= UART_IDLE;
        tx_line <= 1'b1;
        ready <= 1'b1;
        local_data <= 8'h00;
        bits_sent <= 3'b000;
    end
    else if (en)
    begin
        // defaults
        tx_line <= tx_line;
        ready <= ready;
        local_data <= local_data;
        state <= state;
        bits_sent <= bits_sent;
        
        case (state)
            UART_IDLE:
            begin
                ready <= 1'b1;
                tx_line <= 1'b1;
                if (start)
                begin
                    state <= UART_START;
                end
            end

            UART_START:
            begin
                tx_line <= 1'b0;
                local_data <= tx_byte;
                bits_sent <= 3'b000;
                ready <= 1'b0;
                state <= UART_DATA;
            end
            UART_DATA:
            begin
                bits_sent <= (bits_sent + 1'b1);
                tx_line <= local_data[0];
                local_data <= {local_data[0], local_data[7:1]};
                    
                if (bits_sent == 3'd7)
                begin
                    state <= UART_STOP;
                end
            end
            UART_STOP:
            begin
                tx_line <= 1'b1;
                state <= UART_IDLE;
            end
        endcase
    end
    else
    begin
        tx_line <= 1'b1; // idle state
        ready <= 1'b1;
    end

end

endmodule
