module uart_top (
    input wire clk, line_in,
    output wire line_out
);
    wire rx_done;
    wire [7:0] din;

    receiver #(
        .N(8)
    ) receive (
        .clk(clk),
        .rx_done(rx_done),
        .line(line_in),
        .din(din)
    );

    transmitter #(
        .N(8)
    ) transmit (
        .clk(clk),
        .tx_ready(rx_done),
        .dout(din),
        .line(line_out)
    );

endmodule