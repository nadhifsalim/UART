module uart_fifo (
    input wire clk, line_in,
    output wire line_out
);

localparam IDLE = 2'd0;
localparam WAIT_BUSY = 2'd1;
localparam WAIT_IDLE = 2'd2;

wire [7:0] din, dout;

wire empty, full;

wire rx_done, tx_ready, tx_busy;

reg tx_start = 0;

reg [1:0] state = 0;

receiver #(
    .N(8)
) receive (
    .clk(clk),
    .rx_done(rx_done),
    .line(line_in),
    .din(din)
);

fifo #(
    .WIDTH(8),
    .DEPTH(32)
) fifo (
    .clk(clk),
    .rst(1'b0),
    .din(din),
    .dout(dout),
    .en_write(rx_done && !full),
    .en_read(tx_start),
    .empty(empty),
    .full(full)

);

transmitter #(
    .N(8)
) transmit (
    .clk(clk),
    .tx_ready(tx_start),
    .dout(dout),
    .line(line_out),
    .tx_busy(tx_busy)
);

always @(posedge clk) begin
    tx_start <= 0;

    case (state)
        IDLE: begin
            if(!empty && !tx_busy) begin
                tx_start <= 1'b1;
                state <= WAIT_BUSY;
            end
        end

        WAIT_BUSY: begin
            if (tx_busy) state <= WAIT_IDLE;
        end

        WAIT_IDLE: begin
            if (!tx_busy) state <= IDLE;
        end
    endcase
end
endmodule