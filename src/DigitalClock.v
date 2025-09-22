// src/DigitalClock.v (Corrected Top Module Wiring)
module DigitalClock (
    input  wire        clk,
    input  wire        rst_key_in, // 外部复位按键
    input  wire        key_mode,
    input  wire        key_inc,
    input  wire        key_alarm_off,
    output wire        beep,
    output wire [3:0]  seg_sec0, seg_sec1,
    output wire [3:0]  seg_min0, seg_min1,
    output wire [3:0]  seg_hour0, seg_hour1
);
    wire clk_1hz, clk_100hz, clk_buzzer_osc;
    wire key_mode_pulse, key_inc_pulse, key_alarm_off_pulse;
    wire rst_signal = ~rst_key_in;

    clk_divider u_clk_divider (.clk(clk), .rst(rst_signal), .clk_1hz(clk_1hz), .clk_100hz(clk_100hz), .clk_buzzer_osc(clk_buzzer_osc));
    key_debounce debounce_mode (.clk_100hz(clk_100hz), .rst(rst_signal), .key_in(key_mode), .key_pulse(key_mode_pulse));
    key_debounce debounce_inc (.clk_100hz(clk_100hz), .rst(rst_signal), .key_in(key_inc), .key_pulse(key_inc_pulse));
    key_debounce debounce_alarm_off (.clk_100hz(clk_100hz), .rst(rst_signal), .key_in(key_alarm_off), .key_pulse(key_alarm_off_pulse));

    wire [3:0] s_units, s_tens, m_units, m_tens, h_units, h_tens;
    wire time_count_en, time_load_en;
    wire [4:0] hour_to_load;
    wire [5:0] min_to_load;
    time_counter u_time_counter ( .clk(clk), .clk_1hz(clk_1hz), .rst(rst_signal), .time_count_en(time_count_en), .load_en(time_load_en), .hour_in(hour_to_load), .min_in(min_to_load), .s_units_r(s_units), .s_tens_r(s_tens), .m_units_r(m_units), .m_tens_r(m_tens), .h_units_r(h_units), .h_tens_r(h_tens) );

    wire time_adj_load_en, time_adj_h_sel, time_adj_m_sel, time_adj_inc_pulse;
    wire alarm_adj_load_en, alarm_adj_h_sel, alarm_adj_m_sel, alarm_adj_inc_pulse;
    wire [4:0] time_adj_init_h;
    wire [5:0] time_adj_init_m;
    wire [3:0] adj_h_units, adj_h_tens, adj_m_units, adj_m_tens;
    wire [3:0] alarm_h_units, alarm_h_tens, alarm_m_units, alarm_m_tens;
    bcd_adjustable_time_reg u_time_set_reg ( .clk_100hz(clk_100hz), .rst(rst_signal), .load_en(time_adj_load_en), .init_h_val(time_adj_init_h), .init_m_val(time_adj_init_m), .h_sel(time_adj_h_sel), .m_sel(time_adj_m_sel), .inc_val_pulse(time_adj_inc_pulse), .h_units_r(adj_h_units), .h_tens_r(adj_h_tens), .m_units_r(adj_m_units), .m_tens_r(adj_m_tens) );
    bcd_adjustable_time_reg u_alarm_set_reg ( .clk_100hz(clk_100hz), .rst(rst_signal), .load_en(alarm_adj_load_en), .init_h_val(5'd6), .init_m_val(6'd0), .h_sel(alarm_adj_h_sel), .m_sel(alarm_adj_m_sel), .inc_val_pulse(alarm_adj_inc_pulse), .h_units_r(alarm_h_units), .h_tens_r(alarm_h_tens), .m_units_r(alarm_m_units), .m_tens_r(alarm_m_tens) );

    wire alarm_on_flag;
    clock_controller u_controller (
        .clk_100hz(clk_100hz), .rst(rst_signal),
        .key_mode_pulse(key_mode_pulse), .key_inc_pulse(key_inc_pulse), .key_alarm_off_pulse(key_alarm_off_pulse),
        .h_units_in(h_units), .h_tens_in(h_tens),
        .m_units_in(m_units), .m_tens_in(m_tens),
        .s_units_in(s_units), .s_tens_in(s_tens),
        // 【修正】将 u_time_set_reg 的输出连接到 u_controller 的新输入
        .adj_h_units_in(adj_h_units), .adj_h_tens_in(adj_h_tens),
        .adj_m_units_in(adj_m_units), .adj_m_tens_in(adj_m_tens),
        .alarm_h_units_in(alarm_h_units), .alarm_h_tens_in(alarm_h_tens),
        .alarm_m_units_in(alarm_m_units), .alarm_m_tens_in(alarm_m_tens),
        .time_count_en(time_count_en), .time_load_en(time_load_en),
        .hour_to_load(hour_to_load), .min_to_load(min_to_load),
        .time_adj_load_en(time_adj_load_en), .time_adj_init_h(time_adj_init_h), .time_adj_init_m(time_adj_init_m),
        .time_adj_h_sel(time_adj_h_sel), .time_adj_m_sel(time_adj_m_sel), .time_adj_inc_pulse(time_adj_inc_pulse),
        .alarm_adj_load_en(alarm_adj_load_en), .alarm_adj_h_sel(alarm_adj_h_sel), .alarm_adj_m_sel(alarm_adj_m_sel), .alarm_adj_inc_pulse(alarm_adj_inc_pulse),
        .alarm_on_flag(alarm_on_flag)
    );

    display_controller u_display_controller ( .h_units_in(h_units), .h_tens_in(h_tens), .m_units_in(m_units), .m_tens_in(m_tens), .s_units_in(s_units), .s_tens_in(s_tens), .seg_hour0(seg_hour0), .seg_hour1(seg_hour1), .seg_min0(seg_min0), .seg_min1(seg_min1), .seg_sec0(seg_sec0), .seg_sec1(seg_sec1) );
    buzzer_controller u_buzzer (.clk_buzzer_osc(clk_buzzer_osc), .rst(rst_signal), .alarm_on(alarm_on_flag), .beep(beep));

endmodule