// src/time_counter.v
// --- FINAL VERSION (Corrected) ---
// 功能：在统一的主时钟域下工作，通过时钟使能信号控制计数

module time_counter (
    input   wire        clk,            // 【改动】使用主时钟 clk
    input   wire        clk_1hz_en,     // 【改动】使用1Hz使能信号
    input   wire        rst,
    input   wire        time_count_en,
    input   wire        load_en,
    input   wire [4:0]  hour_in,
    input   wire [5:0]  min_in,
    output  reg [5:0]   sec,
    output  reg [5:0]   min,
    output  reg [4:0]   hour
);
    // 【改动】将所有逻辑合并到一个由主时钟 clk 驱动的 always 块中
    // 这样可以确保 load_en 信号能被正确采样
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sec <= 6'd0;
            min <= 6'd0;
            hour <= 5'd0;
        end 
        // 加载操作具有最高优先级，只要 load_en 有效就执行
        else if (load_en) begin
            sec <= 6'd0;       // 调整时间时，秒数清零
            min <= min_in;
            hour <= hour_in;
        end 
        // 只有在1Hz使能信号有效且计数使能时，才进行计数
        else if (time_count_en && clk_1hz_en) begin
            if (sec == 6'd59) begin
                sec <= 6'd0;
                if (min == 6'd59) begin
                    min <= 6'd0;
                    if (hour == 5'd23) begin
                        hour <= 5'd0;
                    end else begin
                        hour <= hour + 1;
                    end
                end else begin
                    min <= min + 1;
                end
            end else begin
                sec <= sec + 1;
            end
        end
    end
endmodule