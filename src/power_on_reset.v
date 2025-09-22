// src/power_on_reset.v (MORE ROBUST VERSION)
module power_on_reset (
    input  wire clk,
    output wire rst_n
);
    localparam CNT_WIDTH = 18;
    localparam CNT_MAX = {CNT_WIDTH{1'b1}};

    reg [CNT_WIDTH-1:0] counter_reg;
    reg por_done_reg;

    always @(posedge clk) begin
        if (por_done_reg == 1'b0) begin
            counter_reg <= counter_reg + 1'b1;
            if (counter_reg == CNT_MAX) begin
                por_done_reg <= 1'b1;
            end
        end
    end

    assign rst_n = por_done_reg;
endmodule