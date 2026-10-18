`timescale 1ns/1ps
module receiver_tb;
reg clk;
reg signal_tx;
reg [7:0] data_in;
wire serial;
wire signal_rx;
wire [7:0] data_out;

receiver dut_rx 
(
    .clk(clk),
    .signal(signal_rx),
    .data(data_out),
    .rx(serial)
);

transmitter dut_tx 
(
    .clk(clk),
    .signal(signal_tx),
    .tx(data_in),
    .pin(serial)
);

always #41.67 clk = ~clk;

initial begin
    $dumpfile("build/wave.vcd");
    $dumpvars(0, receiver_tb);
end

initial begin
    clk = 0;
    signal_tx = 0;
    data_in = 8'h5A;

    #5000

    signal_tx = 1;
    #83.33;
    signal_tx = 0;

    #1500000;
    $finish;
end

endmodule