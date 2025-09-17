// clk_divider.v (Final, Most Robust Version)

module clk_divider (
    input   wire    clk_in,
    input   wire    rst,
    output  reg     clk_1hz
);

    parameter CLK_FREQ = 50; // For Simulation

    reg [25:0] counter_reg, counter_next; // 当前计数器值 和 下一个计数器值
    reg clk_1hz_next; // 下一个 clk_1hz 的值

    // 1. 时序逻辑：只负责在时钟边沿，用 "next" 值更新 "reg" 值
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter_reg <= 26'd0;
            clk_1hz     <= 1'b0;
        end else begin
            counter_reg <= counter_next;
            clk_1hz     <= clk_1hz_next;
        end
    end

    // 2. 组合逻辑：只负责根据 "reg" 的当前值，计算出 "next" 值
    always @(*) begin
        // 默认情况下，下一个值等于当前值
        counter_next = counter_reg + 1;
        clk_1hz_next = clk_1hz;

        if (counter_reg == CLK_FREQ - 1) begin
            counter_next = 26'd0;
        end
        
        // 明确定义 clk_1hz 的行为
        if(counter_reg >= (CLK_FREQ/2 -1) && counter_reg < (CLK_FREQ -1) )
             clk_1hz_next = 1'b1;
        else
             clk_1hz_next = 1'b0;
    end

endmodule