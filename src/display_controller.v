// src/display_controller.v (Simplified for BCD input)
module display_controller (
    input  wire [3:0]  h_units_in, h_tens_in,
    input  wire [3:0]  m_units_in, m_tens_in,
    input  wire [3:0]  s_units_in, s_tens_in,
    output wire [3:0]  seg_sec0, seg_sec1,
    output wire [3:0]  seg_min0, seg_min1,
    output wire [3:0]  seg_hour0, seg_hour1
);
    // 输入已经是BCD的个位和十位，直接连接即可
    assign seg_sec0  = s_units_in;
    assign seg_sec1  = s_tens_in;
    assign seg_min0  = m_units_in;
    assign seg_min1  = m_tens_in;
    assign seg_hour0 = h_units_in;
    assign seg_hour1 = h_tens_in;
endmodule