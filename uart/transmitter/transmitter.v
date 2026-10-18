module transmitter 
#(
    parameter N = 8
)
(
    input wire clk, tick, signal,
    input reg [N-1:0] tx,
    output reg pin 
);

localparam idle = 2'd0;
localparam start = 2'd1;
localparam transmit = 2'd2;
localparam stop = 2'd3;

counter_tx baud 
(
    .clk_main(clk),
    .tick(tick)
);

reg state = idle;
reg state_next;

reg [2:0] d = 0;
reg [2:0] d_next;

reg pin_next;

always @(posedge clk) begin
    pin <= pin_next;
    state <= state_next;
    d <= d_next;
end

always @(*) begin
    state_next = state;
    pin_next = pin;
    d <= d_next;

    case (state)
        idle : begin
            if (signal == 1) begin
                state_next = start;
            end else begin
                pin_next = 1'b1;
            end
        end 
        start : begin
            if (tick == 1) begin
                pin_next = 1'b0;
                state_next = transmit;
            end
        end
        transmit : begin
            if (tick == 1) begin
                pin_next = tx[d];
                if (d == N-1) begin
                    state_next = stop;
                end else begin
                    d_next = d_next + 1;
                end  
            end
        end
        stop : begin
            if (tick == 1) begin
                pin_next = 1'b1;
                state_next = idle;
            end
        end 
    endcase    
end
    
endmodule