module counter 
#(
    parameter M = 1250
)
(
    input wire clk_main,
    input wire rst,
    output reg tick = 0
);
    reg [$clog2(M)-1:0] counter = 0;

    always @(posedge clk_main) begin
        if (rst) begin 
            counter <= 0;
            tick <= 0;
        end else begin 
            if (counter == M-1) begin
                tick <= 1'b1;
                counter <= 0;
            end else begin
                tick <= 1'b0;
                counter <= counter + 1;
            end
        end
    end

endmodule