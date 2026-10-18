module counter_tx 
#(
    parameter M = 1250
)
(
    input wire clk_main,
    output reg tick = 0
);
    reg [10:0] counter = 0;

    always @(posedge clk_main) begin
        if (counter == M-1) begin
            tick <= 1'b1;
            counter <= 0;
        end else begin
            tick <= 1'b0;
            counter <= counter + 1;
        end
    end

endmodule