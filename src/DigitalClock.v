// DigitalClock.v (Upgraded for Advanced Features)

module DigitalClock (
    // -- 物理引脚接口 --
    input   wire        clk,        // 50MHz 主时钟
    input   wire        rst,        // 复位
    
    // 新增的按键输入
    input   wire        key_mode,   // 模式切换键
    input   wire        key_inc,    // 数值增加键
    
    // 输出端口不变
    output  wire [6:0]  seg_out,
    output  wire [5:0]  digit_sel
);

    // -- 内部信号/导线定义 --
    
    // 基础功能连线
    wire clk_1hz_wire;
    wire [4:0] hour_from_counter; // 从计数器输出的小时
    wire [5:0] min_from_counter;  // 从计数器输出的分钟
    wire [5:0] sec_from_counter;  // 从计数器输出的秒
    wire [3:0] num_to_decode_wire;

    // 按键消抖后产生的脉冲信号
    wire key_mode_pulse;
    wire key_inc_pulse;

    // 控制器 -> 计数器 的控制信号
    wire time_count_en_wire;
    wire load_en_wire;
    wire [4:0] hour_to_counter; // 从控制器传给计数器的新小时值
    wire [5:0] min_to_counter;  // 从控制器传给计数器的新分钟值

    // -- 模块实例化 --

    // 1. 安装“神经”：按键消抖模块 (需要两个实例)
    key_debounce debounce_mode (
        .clk(clk),
        .rst(rst),
        .key_in(key_mode),
        .key_pulse(key_mode_pulse)
    );
    key_debounce debounce_inc (
        .clk(clk),
        .rst(rst),
        .key_in(key_inc),
        .key_pulse(key_inc_pulse)
    );

    // 2. 安装“大脑皮层”：控制状态机
    //    (这是我们下一步要编写的新模块)
    clock_controller u_controller (
        .clk(clk),
        .rst(rst),
        .key_mode_pulse(key_mode_pulse),
        .key_inc_pulse(key_inc_pulse),
        
        .hour_in(hour_from_counter), // 将当前时间输入给控制器
        .min_in(min_from_counter),
        
        .time_count_en(time_count_en_wire), // 控制器输出的使能信号
        .load_en(load_en_wire),
        .hour_out(hour_to_counter),     // 控制器输出的调整后时间
        .min_out(min_to_counter)
    );
    
    // 3. 安装“心脏”：时钟分频器 (不变)
    clk_divider u_clk_divider (
        .clk_in(clk),
        .rst(rst),
        .clk_1hz(clk_1hz_wire)
    );

    // 4. 安装升级后的“大脑”：时间计数器
    time_counter u_time_counter (
        .clk_1hz(clk_1hz_wire),
        .rst(rst),
        .time_count_en(time_count_en_wire), // 接收来自控制器的使能信号
        .load_en(load_en_wire),
        .hour_in(hour_to_counter),      // 接收来自控制器的新时间
        .min_in(min_to_counter),
        
        .hour(hour_from_counter),       // 输出当前时间给控制器和显示器
        .min(min_from_counter),
        .sec(sec_from_counter)
    );

    // 5. 安装“现场总指挥”：动态扫描驱动 (不变)
    display_scanner u_display_scanner (
        .clk(clk),
        .rst(rst),
        .hour(hour_from_counter), // 显示来自计数器的当前时间
        .min(min_from_counter),
        .sec(sec_from_counter),
        .num_to_decode(num_to_decode_wire),
        .digit_sel(digit_sel)
    );

    // 6. 安装“翻译官”：七段译码器 (不变)
    display_decoder u_display_decoder (
        .num_in(num_to_decode_wire),
        .seg_out(seg_out)
    );

endmodule