module receiver 
#(
    parameter N = 8
)
(
    input line, 
    input clk,
    output reg rx_done = 0,
    output reg [N-1:0] din 
);

localparam idle = 2'b00;
localparam start = 2'b01;
localparam receive = 2'b10;
localparam stop = 2'b11;

reg [3:0] n = 0;
reg [3:0] n_next;

reg [2:0] counter = 0;
reg [2:0] counter_next;

reg [1:0] state = idle;
reg [1:0] state_next;

reg rx_done_next;

reg [N-1:0] din_next;

wire tick_16;
reg rst_tick = 0;

counter #(
    .M(78)
) baud (
    .rst(rst_tick),
    .clk_main(clk),
    .tick_16(tick_16)
);

initial begin
    state = idle;
    n = 0;
    d = 0;
    din = 8'b00000000;
    rx_done = 0;
end

always @(posedge clk) begin
    state <= state_next;
    d <= d_next;
    n <= n_next;
    din <= din_next;
    rx_done <= rx_done_next;
end

always @(*) begin
    state_next = state;
    n_next = n;
    din_next = din;
    rx_done_next = 0;
    d_next = d;
    rst_tick = 0;

    case (state)
        idle : begin
            if (line == 0) begin
                n_next = 0;
                rst_tick = 1'b1;
                state_next = start;
            end 
        end
        start : begin
            if (tick_16 == 1'b1) begin
                if (n == 7) begin
                    n_next = 0;
                    if (line == 0) begin 
                        state_next = receive;
                    end else begin 
                        state_next = idle;
                    end
                end else begin
                   n_next = n + 1; 
                end
            end
        end
        receive: begin
            if (tick_16 == 1'b1) begin
                if (n == 15) begin
                    n_next = 0;
                    din_next[d] = line;

                    if (d == DATA-1) begin
                        n_next = 0;
                        d_next = 0;
                        state_next = stop;
                    end else begin
                        d_next = d + 1;
                    end
                end else begin
                    n_next = n + 1;
                end
            end
        end
        stop: begin
            if (tick_16 == 1'b1) begin
                if (n == 15) begin
                    if (line == 1) begin
                        rx_done_next = 1;
                    end
                    state_next = idle;
                    n_next = 0;
                end
                else begin
                    n_next = n + 1;
                end
            end
        end
    endcase
end
    
endmodule