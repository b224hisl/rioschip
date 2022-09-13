module counter_tmp #(
    parameter CNT_SIZE = 32 + 8,
    parameter CNT_SIZE_WIDTH = 6
) (
    input clk,
    input reset,
    input cnt_add_flag,
    output reg [CNT_SIZE_WIDTH-1:0] cnt,
    output cnt_end
);

always @(posedge clk) begin
    if (reset) begin
        cnt <= 0;
    end else if (cnt_add_flag) begin
        if (cnt_end) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
        end
    end
end

assign cnt_end = cnt == CNT_SIZE-1;

endmodule
