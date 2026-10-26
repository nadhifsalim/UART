module fifo
#(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)

(
    input wire clk, en_write, en_read, rst,
    input wire [WIDTH-1:0] din,
    output wire empty, full,
    output reg [WIDTH-1:0] dout = 0
);
    localparam wrt = $clog2(DEPTH);
    localparam rd = $clog2(DEPTH);

    reg [WIDTH-1:0] mem [DEPTH-1:0];

    reg [wrt:0] p_write = 0;
    reg [wrt:0] p_read = 0;

    always @(posedge clk) begin
        if(rst) begin
            p_read <= 0;
            p_write <= 0;
            dout <= 0;
        end else begin
            if (!empty && en_read) begin
                dout <= mem[p_read[wrt-1:0]];
                p_read <= p_read + 1'b1;
            end
            if (!full && en_write) begin
                mem[p_write[wrt-1:0]] <= din;
                p_write <= p_write + 1'b1;
            end

        end
    end

    assign full = (p_write[wrt-1:0] == p_read[wrt-1:0] && p_write[wrt] != p_read[wrt]);
    assign empty = (p_write == p_read);
    
endmodule