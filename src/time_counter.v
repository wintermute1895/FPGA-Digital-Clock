// src/time_counter.v (Re-architected BCD Version)
// 功能：基于BCD码的时间计数器

module time_counter (
    input wire clk,           // 主时钟 (50MHz)
    input wire clk_1hz,       // 真实的1Hz时钟信号
    input wire rst,
    input wire time_count_en,
    input wire load_en,
    input wire [4:0] hour_in, // 加载值为二进制
    input wire [5:0] min_in,
    output reg [3:0] h_units_r, h_tens_r,
    output reg [3:0] m_units_r, m_tens_r,
    output reg [3:0] s_units_r, s_tens_r
);
    // 使用边沿检测将1Hz时钟转换为在主时钟域下的单周期脉冲
    reg clk_1hz_dly;
    wire clk_1hz_pulse;
    always @(posedge clk) begin
        if(rst) clk_1hz_dly <= 1'b0;
        else    clk_1hz_dly <= clk_1hz;
    end
    assign clk_1hz_pulse = clk_1hz & ~clk_1hz_dly;

    // 二进制加载值 -> BCD
    wire [3:0] load_h_tens = hour_in / 10;
    wire [3:0] load_h_units = hour_in % 10;
    wire [3:0] load_m_tens = min_in / 10;
    wire [3:0] load_m_units = min_in % 10;
    
    always @(posedge clk) begin
        if (rst) begin
            s_units_r <= 0; s_tens_r <= 0;
            m_units_r <= 0; m_tens_r <= 0;
            h_units_r <= 0; h_tens_r <= 0;
        end else if (load_en) begin
            s_units_r <= 0; s_tens_r <= 0; // 调整时间秒归零
            m_units_r <= load_m_units; m_tens_r <= load_m_tens;
            h_units_r <= load_h_units; h_tens_r <= load_h_tens;
        end else if (time_count_en && clk_1hz_pulse) begin
            if (s_units_r == 9) begin
                s_units_r <= 0;
                if (s_tens_r == 5) begin // 59s -> 00s
                    s_tens_r <= 0;
                    if (m_units_r == 9) begin
                        m_units_r <= 0;
                        if (m_tens_r == 5) begin // 59m -> 00m
                            m_tens_r <= 0;
                            if (h_tens_r == 2 && h_units_r == 3) begin // 23h -> 00h
                                h_units_r <= 0; h_tens_r <= 0;
                            end else if (h_units_r == 9) begin
                                h_units_r <= 0; h_tens_r <= h_tens_r + 1;
                            end else begin h_units_r <= h_units_r + 1; end
                        end else begin m_tens_r <= m_tens_r + 1; end
                    end else begin m_units_r <= m_units_r + 1; end
                end else begin s_tens_r <= s_tens_r + 1; end
            end else begin s_units_r <= s_units_r + 1; end
        end
    end
endmodule