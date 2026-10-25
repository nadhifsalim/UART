`timescale 1ns/1ps
module fifo_tb;
reg clk = 0;
reg en_write = 0;
reg en_read = 0;
reg [7:0] din = 0;
reg rst = 0;
wire empty;
wire full;
wire [7:0] dout;

fifo #( .WIDTH(8), .DEPTH(16)) dut
(
    .clk(clk),
    .en_write(en_write),
    .en_read(en_read),
    .rst(rst),
    .empty(empty),
    .full(full),
    .dout(dout),
    .din(din)
);

always #41.67 clk = ~clk; 
initial begin
    $dumpfile("build/wave.vcd");
    $dumpvars(0, fifo_tb);
end

initial begin
    rst = 1; #83.33;
    rst = 0; #83.33;

    en_write = 1;
    repeat(16) begin
        din = din + 1;
        #83.33;
    end    
    en_write = 0; #83.33;

    en_read = 1;
    repeat (16) begin
        #83.33;
    end
    en_read = 0;
    #83.33;

    din = 8'hAA;
    en_write = 1;
    en_read = 1;
    #83.33;

    en_write = 0;
    en_read = 0;
    #83.33;

    $finish;
end

endmodule