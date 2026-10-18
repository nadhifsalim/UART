module counter_rx
#(
    parameter N = 7, 
    M = 78 
)
(
    input clk_main,
    output reg tick_16 = 0
);
    
    reg [N-1:0] counter = 0;

    always @(posedge clk_main) begin
        if (counter == M-1) begin
            counter <=  0;
            tick_16 <= 1'b1;
        end else begin
            counter <= counter + 1;
            tick_16 <= 1'b0;
        end
    end
endmodule