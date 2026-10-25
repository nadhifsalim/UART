module fifo
#(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
)

(
    input wire clk, en_write, en_read, rst,
    input wire [WIDTH-1:0] din,
    output wire empty, full,
    output reg [WIDTH-1:0] dout
);
    localparam wrt = $clog2(DEPTH);
    localparam rd = $clog2(DEPTH);

    reg [WIDTH-1:0] mem [DEPTH-1:0];

    reg [wrt:0] p_write;
    reg [wrt:0] p_read;

    reg [wrt:0] np_write;
    reg [wrt:0] np_read;

    always @(posedge clk) begin
        if (!empty && en_read) begin
            dout <= mem[p_read[wrt-1:0]];
        end
        if (!full && en_write) begin
            mem[p_write[wrt-1:0]] <= din;
        end

        if(rst) begin
            p_read <= 0;
            p_write <= 0;
            empty <= 1'b1;
            full <= 1'b0;
        end else begin
            p_read <= np_read;
            p_write <= np_write;
        end
    end

    always @(*) begin
        np_read = p_read;
        np_write = p_write;

        if (!empty && en_read) begin
            np_read = np_read + 1'b1;
        end
        if (!full && en_write) begin
            np_write = np_write + 1'b1;
        end
    end

    assign full = (p_write[wrt-1:0] == p_read[wrt-1:0] && p_write[wrt] != p_read[wrt]);
    assign empty = (p_write == p_read);
    
endmodule