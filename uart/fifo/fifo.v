module fifo
#(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
)

(
    input wire clk, en_write, en_read, din, rst
    output wire empty, full.
    output reg dout
);
    localparam wrt = $clog2(DEPTH);
    localparam rd = $clog2(DEPTH);

    reg [WIDTH-1 : 0] mem [DEPTH-1:0];

    reg [wrt:0] p_write;
    reg [wrt:0] p_read;

    reg [wrt:0] np_write;
    reg [wrt:0] np_read;

    always @(posedge clk) begin
        
        if(rst) begin
            p_read <= 0;
            p_write <= 0;
        end else begin
            if (!full && en_write) begin
                fifo[p_write[wrt-1:0]] <= din;
                p_write <= p_write + 1'b1;
            end
            if (!empty && en_read) begin
                dout <= fifo[p_read[wrt-1:0]];
                p_read <= p_read + 1'b1;
            end
        end
    end

    assign full = (p_write [wrt-1:0] == p_read [wrt-1:0] && p_write[wrt] != p_read[wrt]);
    assign empty = (p_write == p_read);
    
endmodule