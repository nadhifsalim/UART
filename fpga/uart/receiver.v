module receiver 
#(
    parameter M = 16,
    DATA = 8
)
(
    input rx, 
    input clk,
    output reg signal = 0,
    output reg [7:0] data 
);

localparam idle = 2'b00;
localparam start = 2'b01;
localparam receive = 2'b10;
localparam stop = 2'b11;

reg [3:0] n = 0;
reg [3:0] n_next;

reg [2:0] d = 0;
reg [2:0] d_next;

reg [1:0] state = idle;
reg [1:0] state_next;

reg signal_next;

reg [7:0] data_next;

wire tick_16;

counter_rx baud
(
    .clk_main(clk),
    .tick_16(tick_16)
);

initial begin
    state = idle;
    n = 0;
    d = 0;
    data = 8'b00000000;
    signal = 0;
end

always @(posedge clk) begin
    state <= state_next;
    d <= d_next;
    n <= n_next;
    data <= data_next;
    signal <= signal_next;
end

always @(*) begin
    state_next = state;
    n_next = n;
    data_next = data;
    signal_next = 0;
    d_next = d;

    case (state)
        idle : begin
            if (rx == 0) begin
                n_next = 0;
                state_next = start;
            end 
        end
        start : begin
            if (tick_16 == 1'b1) begin
                if (n == 7) begin
                    n_next = 0;
                    if (rx == 0) begin 
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
                    data_next[d] = rx;

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
                    if (rx == 1) begin
                        signal_next = 1;
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