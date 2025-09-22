// src/bcd_adjustable_time_reg.v (New Module)
// 功能：一个通用的BCD可调时间寄存器

module bcd_adjustable_time_reg (
    input wire clk_100hz,
    input wire rst,
    input wire load_en,
    input wire [4:0] init_h_val,
    input wire [5:0] init_m_val,
    input wire h_sel,
    input wire m_sel,
    input wire inc_val_pulse,
    output reg [3:0] h_units_r, h_tens_r,
    output reg [3:0] m_units_r, m_tens_r
);
    wire [3:0] load_h_tens = init_h_val / 10;
    wire [3:0] load_h_units = init_h_val % 10;
    wire [3:0] load_m_tens = init_m_val / 10;
    wire [3:0] load_m_units = init_m_val % 10;

    always @(posedge clk_100hz) begin
        if (rst) begin
            h_units_r <= 4'h0; h_tens_r <= 4'h0;
            m_units_r <= 4'h0; m_tens_r <= 4'h0;
        end else if (load_en) begin
            h_units_r <= load_h_units; h_tens_r <= load_h_tens;
            m_units_r <= load_m_units; m_tens_r <= load_m_tens;
        end else if (inc_val_pulse) begin
            if (h_sel) begin
                if (h_tens_r == 2 && h_units_r == 3) begin // 23 -> 00
                    h_units_r <= 0; h_tens_r <= 0;
                end else if (h_units_r == 9) begin // x9 -> (x+1)0
                    h_units_r <= 0; h_tens_r <= h_tens_r + 1;
                end else begin
                    h_units_r <= h_units_r + 1;
                end
            end else if (m_sel) begin
                if (m_tens_r == 5 && m_units_r == 9) begin // 59 -> 00
                    m_units_r <= 0; m_tens_r <= 0;
                end else if (m_units_r == 9) begin // x9 -> (x+1)0
                    m_units_r <= 0; m_tens_r <= m_tens_r + 1;
                end else begin
                    m_units_r <= m_units_r + 1;
                end
            end
        end
    end
endmodule