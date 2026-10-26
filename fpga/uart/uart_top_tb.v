`timescale 1ns / 1ps

module uart_top_tb;
    reg clk = 0;
    reg line_in = 1; // UART idle state is strictly high (1)
    wire line_out;

    // Instantiate Top Module
    uart_top uut (
        .clk(clk),
        .line_in(line_in),
        .line_out(line_out)
    );

    // 12 MHz clock generation
    always #41.67 clk = ~clk;

    // 9600 Baud period in nanoseconds (1 sec / 9600 = 104167 ns)
    localparam BIT_PERIOD = 104167;

    // Task to mimic a PC sending a serial byte
    task send_byte(input [7:0] data);
        integer i;
        begin
            // 1. Send Start Bit
            line_in = 0;
            #(BIT_PERIOD);
            
            // 2. Send 8 Data Bits (LSB First)
            for (i = 0; i < 8; i = i + 1) begin
                line_in = data[i];
                #(BIT_PERIOD);
            end
            
            // 3. Send Stop Bit
            line_in = 1;
            #(BIT_PERIOD);
        end
    endtask

    initial begin
        $dumpfile("build/wave.vcd");
        $dumpvars(0, uart_top_tb);
        
        // Wait for system to initialize
        #(BIT_PERIOD);
        
        // Inject the character 'A' (8'h41) into the receiver
        send_byte(8'h41);
        
        // Wait for the transmitter to finish echoing the byte back
        // 1 byte requires 10 bit periods. Wait 15 to be safe.
        #(BIT_PERIOD * 15);
        
        $finish;
    end
endmodule