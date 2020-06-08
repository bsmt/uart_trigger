`timescale 1ns / 1ps

module top_test();


reg clk = 1'b1;
reg [3:0] btn;
reg ck_rst = 1'b1;
reg tx_start;
wire rx_line;
wire trigger;
wire [3:0] led;
reg tx_en;
reg [7:0] tx_data;
wire tx_done;

uart_tx #(.SYSCLK(100_000_000), .BAUDRATE(38400)) tx
(
    .clk(clk),
    .rst(btn[0]),
    .en(tx_en),
    .start(tx_start),
    .tx_byte(tx_data),
    .tx_line(rx_line),
    .ready(tx_done)
);

top _top
(
    .clk(clk),
    .ck_rst(ck_rst),
    .btn(btn),
    .target_rx(rx_line),
    .trigger(trigger),
    .led(led)
);

initial
begin
    // reset
    btn[0] <= 1'b1;
    btn[1] <= 1'b0;
    btn[2] <= 1'b0;
    btn[3] <= 1'b0;
    #10;
    btn[0] <= 1'b0;
    
    #500;
    
    // round 1
    tx_data <= 8'h11;
    tx_en <= 1'b1;
    tx_start <= 1'b1;
    #10;
    tx_start <=1'b0;
    
    #300000; // idk how long this will take
    tx_data <= 8'hee;
    #10;
    tx_start <= 1'b1;
    
    #300000;
    tx_start <= 1'b0;
    tx_en <= 1'b0;
    tx_data <= 8'h00;
    
    #100000;
   
    // round 2   
    tx_data <= 8'h11;
    tx_en <= 1'b1;
    tx_start <= 1'b1;
    #10;
    tx_start <=1'b0;
    
    #300000;
    tx_data <= 8'hee;
    #10;
    tx_start <= 1'b1;
    
    #300000;
    tx_start <= 1'b0;
    tx_en <= 1'b0;
    tx_data <= 8'h00;
     
end

// clock
always
begin
#5;
clk = ~clk;
end


endmodule