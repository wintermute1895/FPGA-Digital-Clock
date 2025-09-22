// src/clk_divider.v
`define CLOCK_FREQUENCY 50_000_000
module clk_divider (
    input   wire    clk_in,
    input   wire    rst,
    output  reg     clk_1hz_en
);
    parameter SIMULATION = 0;
    localparam CNT_MAX = (SIMULATION == 1) ? 50 : `CLOCK_FREQUENCY;
    reg [$clog2(CNT_MAX)-1:0] counter;
    always @(posedge clk_in or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            clk_1hz_en <= 1'b0;
        end else begin
            if (counter == CNT_MAX - 1) begin
                counter <= 0;
                clk_1hz_en <= 1'b1;
            end else begin
                counter <= counter + 1;
                clk_1hz_en <= 1'b0;
            end
        end
    end
endmodule