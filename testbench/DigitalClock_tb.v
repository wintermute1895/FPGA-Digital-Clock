// DigitalClock_tb.v
// 这是一个用于测试 DigitalClock 模块的测试平台

`timescale 1ns / 1ps // 定义仿真时间单位

module DigitalClock_tb;

    // 1. 定义信号，用来连接到你的 DigitalClock 模块
    reg clk;
    reg rst;
    wire [6:0] seg_out;
    wire [5:0] digit_sel;

    // 2. 实例化你的设计 (把你的数字钟放到测试台上)
    DigitalClock uut (
        .clk(clk),
        .rst(rst),
        .seg_out(seg_out),
        .digit_sel(digit_sel)
    );

    // 3. 产生时钟信号
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 每10ns翻转一次，产生一个20ns周期(50MHz)的时钟
    end

    // 4. 产生复位信号和其他测试激励
    initial begin
        rst = 1; // 开始时，复位
        #100;    // 等待100ns
        rst = 0; // 结束复位，时钟开始正常工作

        #65000;  // 仿真运行65000ns (65us)
        $stop;   // 结束仿真
    end

    // 5. 【虚拟点亮】在控制台打印显示信息
    //    $monitor 会在任何信号变化时，打印出当前时间和信号值
    initial begin
        $monitor("Time: %t | Digits: %b | Segments: %b",
                  $time, digit_sel, seg_out);
    end

endmodule