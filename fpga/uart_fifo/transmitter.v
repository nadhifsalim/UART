module transmitter 
#(
    parameter N = 8
)
(
    input wire clk, tx_ready,
    input wire [N-1:0] dout,
    output reg line  = 1'b1,
    output wire tx_busy
);

localparam idle = 2'd0;
localparam start = 2'd1;
localparam transmit = 2'd2;
localparam stop = 2'd3;

wire tick;
reg rst_tick;

counter #(
    .M(1250)
) baud (
    .clk_main(clk),
    .tick(tick),
    .rst(rst_tick)
);

reg [1:0] state = idle;
reg [1:0] state_next;

reg [2:0] d = 0;
reg [2:0] d_next;

reg [7:0] data = 0;
reg [7:0] data_next;

reg tx_ready_latch = 0;

reg line_next;

initial begin
    state_next = idle;
    d_next = 0;
    data_next = 0;
    line_next = 1'b1;
    rst_tick = 0;
end

always @(posedge clk) begin
    line <= line_next;
    state <= state_next;
    d <= d_next;
    tx_ready_latch <= tx_ready;
    data <= data_next;
end

always @(*) begin
    state_next = state;
    line_next = line;
    d_next = d;
    data_next = data;
    rst_tick = 0;

    case (state)
        idle : begin
            if (tx_ready_latch == 1) begin
                line_next = 1'b0;
                rst_tick = 1'b1;
                state_next = start;
                d_next = 0;
                data_next = dout; //capture the data input
            end
        end 
        start : begin
            if (tick == 1) begin
                line_next = data[d];
                d_next = d + 1;
                state_next = transmit;
            end
        end
        transmit : begin
            if (tick == 1) begin
                line_next = data[d];
                if (d == N-1) begin
                    state_next = stop;
                end else begin
                    d_next = d + 1;
                end  
            end
        end
        stop : begin
            if (tick == 1) begin
                line_next = 1'b1;
                state_next = idle;
            end
        end 
    endcase    
end
    
assign tx_busy = (state != idle);

endmodule