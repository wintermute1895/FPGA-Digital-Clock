// src/DigitalClock.v
// --- FINAL VERSION (Corrected) ---
// 功能：顶层模块，修正了子模块的连线以适配新的设计

module DigitalClock (
    input   wire        clk,
    input   wire        rst,
    input   wire        key_mode,
    input   wire        key_inc,
    input   wire        key_alarm_off,
    output  wire        beep,
    output  wire [6:0]  seg_out,
    output  wire [5:0]  digit_sel
);

    // 内部信号线
    wire clk_1hz_en_wire; // 【改动】信号重命名，表示它是一个使能信号
    wire [4:0] hour_from_counter;
    wire [5:0] min_from_counter;
    wire [5:0] sec_from_counter;
    wire [3:0] num_to_decode_wire;
    wire key_mode_pulse, key_inc_pulse, key_alarm_off_pulse;
    wire time_count_en_wire, load_en_wire;
    wire [4:0] hour_to_counter;
    wire [5:0] min_to_counter;
    wire alarm_on_flag_wire;
    wire [2:0] display_mode_wire;

    // 实例化按键消抖模块
    key_debounce debounce_mode (.clk(clk), .rst(rst), .key_in(key_mode), .key_pulse(key_mode_pulse));
    key_debounce debounce_inc (.clk(clk), .rst(rst), .key_in(key_inc), .key_pulse(key_inc_pulse));
    key_debounce debounce_alarm_off (.clk(clk), .rst(rst), .key_in(key_alarm_off), .key_pulse(key_alarm_off_pulse));

    // 实例化主控制器
    clock_controller u_controller (
        .clk(clk), .rst(rst),
        .key_mode_pulse(key_mode_pulse), .key_inc_pulse(key_inc_pulse), .key_alarm_off_pulse(key_alarm_off_pulse),
        .hour_in(hour_from_counter), .min_in(min_from_counter), .sec_in(sec_from_counter),
        .time_count_en(time_count_en_wire), .load_en(load_en_wire),
        .hour_out(hour_to_counter), .min_out(min_to_counter),
        .alarm_on_flag(alarm_on_flag_wire),
        .display_mode(display_mode_wire)
    );
    
    // 实例化蜂鸣器控制器 (假设存在)
    buzzer_controller u_buzzer (.clk(clk), .rst(rst), .alarm_on(alarm_on_flag_wire), .beep(beep));

    // 实例化时钟分频器（现在是使能信号生成器）
    clk_divider u_clk_divider (
        .clk_in(clk), 
        .rst(rst), 
        .clk_1hz_en(clk_1hz_en_wire) // 【改动】连接到新的输出端口
    );

    // 实例化时间计数器
    time_counter u_time_counter (
        .clk(clk),                   // 【改动】连接主时钟
        .clk_1hz_en(clk_1hz_en_wire),// 【改动】连接1Hz使能信号
        .rst(rst),
        .time_count_en(time_count_en_wire), .load_en(load_en_wire),
        .hour_in(hour_to_counter), .min_in(min_to_counter),
        .hour(hour_from_counter), .min(min_from_counter), .sec(sec_from_counter)
    );

    // 实例化显示扫描模块
    display_scanner u_display_scanner (
        .clk(clk), .rst(rst),
        .hour(hour_from_counter), .min(min_from_counter), .sec(sec_from_counter),
        .display_mode(display_mode_wire),
        .num_to_decode(num_to_decode_wire),
        .digit_sel(digit_sel)
    );

    // 实例化显示译码模块
    display_decoder u_display_decoder (.num_in(num_to_decode_wire), .seg_out(seg_out));

endmodule