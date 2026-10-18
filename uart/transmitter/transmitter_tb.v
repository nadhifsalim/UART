`timescale 1ns/1ps
module transmitter_tb;
reg clk;
reg signal;
reg [7:0] data;

wire pin;

transmitter dut
(
    .clk(clk),
    .signal(signal),
    .tx(data),
    .pin(pin)
);

always #41.67 clk = ~clk; 

initial begin
    $dumpfile("build/wave.vcd");
    $dumpvars(0, transmitter_tb);
end

initial begin
    clk = 0;
    signal = 0;
    data = 8'b01001110;

    #1000;

    signal = 1;
    #83.33;
    signal = 0;

    #1500000;
    $finish;
end

endmodule