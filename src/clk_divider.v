// src/clk_divider.v
// --- FINAL VERSION (Corrected) ---
// 功能：不再生成一个独立时钟，而是生成一个1Hz的单周期脉冲使能信号

module clk_divider (
    input   wire    clk_in,
    input   wire    rst,
    output  reg     clk_1hz_en // 输出端口从 clk_1hz 重命名为 clk_1hz_en
);
    // 使用参数方便在仿真和硬件之间切换
    parameter SIMULATION = 0; // 仿真设为1, 硬件设为0

    // 根据模式定义计数器最大值
    localparam CNT_MAX = (SIMULATION == 1) ? 50 : 50_000_000;

    reg [$clog2(CNT_MAX)-1:0] counter;

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_1hz_en <= 1'b0;
        end else begin
            if (counter == CNT_MAX - 1) begin
                counter <= 0;
                clk_1hz_en <= 1'b1; // 在计数达到最大值时，产生一个单周期的使能脉冲
            end else begin
                counter <= counter + 1;
                clk_1hz_en <= 1'b0; // 在其他时间，使能信号保持为低
            end
        end
    end
endmodule