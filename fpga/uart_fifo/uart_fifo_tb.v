`timescale 1ns / 1ps

module uart_fifo_tb;

    // 1. Signal Declarations
    reg clk;
    reg line_in;
    wire line_out;

    // 12 MHz Clock = ~83.33 ns period
    localparam CLK_PERIOD = 83.333;
    
    // 9600 Baud = ~104167 ns per bit
    localparam BIT_TIME = 104167;

    // 2. Instantiate the Top Module
    uart_fifo dut (
        .clk(clk),
        .line_in(line_in),
        .line_out(line_out)
    );

    // 3. Clock Generation
    always #(CLK_PERIOD / 2) clk = ~clk;

    // 4. UART Byte Injection Task (Simulates PC Terminal)
    task send_byte(input [7:0] data);
        integer i;
        begin
            // Start Bit (Drive line low)
            line_in = 1'b0;
            #(BIT_TIME);

            // Data Bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                line_in = data[i];
                #(BIT_TIME);
            end

            // Stop Bit (Drive line high)
            line_in = 1'b1;
            #(BIT_TIME);
        end
    endtask

    // 5. Test Sequence
    initial begin
        // Configure VCD dump for Surfer / GTKWave
        $dumpfile("build/wave.vcd");
        $dumpvars(0, uart_fifo_tb);

        // Initialize signals
        clk = 0;
        line_in = 1; // UART idle state is high

        // Wait a brief moment before starting
        #1000;

        // Send a burst of three bytes ("A", "B", "C") back-to-back
        // This tests the RX -> FIFO -> Glue Logic -> TX pipeline
        send_byte(8'h41); // 'A'
        send_byte(8'h42); // 'B'
        send_byte(8'h43); // 'C'

        // Wait for the transmitter to finish echoing all three bytes.
        // 3 bytes * 10 bits/byte * 104.167 us = ~3.125 milliseconds.
        #4000000; 
        
        $display("Simulation Complete.");
        $finish;
    end

endmodule