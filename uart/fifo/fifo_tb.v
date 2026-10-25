`timescale 1ns/1ps
module fifo_tb;

initial begin
    $dumpfile("build/wave.vcd");
    $dumpvars(0, fifo_tb);
end

initial begin

    $finish;
end

endmodule