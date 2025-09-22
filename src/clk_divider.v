// src/clk_divider.v (Final Version with 2Hz output)
// 功能：从50MHz主时钟分频出多个用于不同子模块的真实时钟信号

module clk_divider (
    input wire clk,       // 50MHz 主时钟
    input wire rst,       // 高电平有效复位
    output wire clk_1hz,       // 1Hz 时钟，用于驱动时间计数
    output wire clk_2hz,       // 2Hz 时钟，用于驱动显示闪烁
    output wire clk_100hz,     // 100Hz 时钟，用于驱动按键消抖和状态机
    output wire clk_buzzer_osc // 1kHz 时钟，作为蜂鸣器振荡源
);

    parameter CLK_FREQ = 50_000_000;

    localparam TARGET_1HZ_FREQ    = 1;
    localparam TARGET_2HZ_FREQ    = 2;
    localparam TARGET_100HZ_FREQ  = 100;
    localparam TARGET_BUZZER_FREQ = 1000;

    // 计算计数器最大值: (输入频率 / 目标频率 / 2) - 1, 产生50%占空比时钟
    localparam DIV_1HZ_MAX      = CLK_FREQ / TARGET_1HZ_FREQ / 2 - 1;
    localparam DIV_2HZ_MAX      = CLK_FREQ / TARGET_2HZ_FREQ / 2 - 1;
    localparam DIV_100HZ_MAX    = CLK_FREQ / TARGET_100HZ_FREQ / 2 - 1; 
    localparam DIV_BUZZER_MAX   = CLK_FREQ / TARGET_BUZZER_FREQ / 2 - 1; 

    reg [$clog2(DIV_1HZ_MAX)-1:0]   count_1hz;
    reg [$clog2(DIV_2HZ_MAX)-1:0]   count_2hz;
    reg [$clog2(DIV_100HZ_MAX)-1:0] count_100hz;
    reg [$clog2(DIV_BUZZER_MAX)-1:0] count_buzzer;

    reg clk_1hz_r, clk_2hz_r, clk_100hz_r, clk_buzzer_osc_r;
    
    // 1Hz Clock Generation
    always @(posedge clk) begin
        if (rst) begin
            count_1hz <= 'd0;
            clk_1hz_r <= 1'b0;
        end else begin
            if (count_1hz == DIV_1HZ_MAX) begin
                count_1hz <= 'd0;
                clk_1hz_r <= ~clk_1hz_r;
            end else begin
                count_1hz <= count_1hz + 1'b1;
            end
        end
    end
    
    // 2Hz Clock Generation (for blinking)
    always @(posedge clk) begin
        if (rst) begin
            count_2hz <= 'd0;
            clk_2hz_r <= 1'b0;
        end else begin
            if (count_2hz == DIV_2HZ_MAX) begin
                count_2hz <= 'd0;
                clk_2hz_r <= ~clk_2hz_r;
            end else begin
                count_2hz <= count_2hz + 1'b1;
            end
        end
    end

    // 100Hz Clock Generation
    always @(posedge clk) begin
        if (rst) begin
            count_100hz <= 'd0;
            clk_100hz_r <= 1'b0;
        end else begin
            if (count_100hz == DIV_100HZ_MAX) begin
                count_100hz <= 'd0;
                clk_100hz_r <= ~clk_100hz_r;
            end else begin
                count_100hz <= count_100hz + 1'b1;
            end
        end
    end

    // Buzzer Clock Generation (1kHz)
    always @(posedge clk) begin
        if (rst) begin
            count_buzzer <= 'd0;
            clk_buzzer_osc_r <= 1'b0;
        end else begin
            if (count_buzzer == DIV_BUZZER_MAX) begin
                count_buzzer <= 'd0;
                clk_buzzer_osc_r <= ~clk_buzzer_osc_r;
            end else begin
                count_buzzer <= count_buzzer + 1'b1;
            end
        end
    end
    
    assign clk_1hz        = clk_1hz_r;
    assign clk_2hz        = clk_2hz_r;
    assign clk_100hz      = clk_100hz_r;
    assign clk_buzzer_osc = clk_buzzer_osc_r;

endmodule