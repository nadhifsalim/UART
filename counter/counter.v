module counter 
#(
    parameter N = 7, 
    M = 78 
)
(
    input clk, rst,
    output reg [N-1:0] out = 0
);
    initial begin
        out = 0;
    end

    always @(posedge clk) begin
        if (out == M-1) begin
            out <=  0;
        end else begin
            out <= out + 1;
        end
    end
endmodule