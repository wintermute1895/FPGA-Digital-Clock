// testbench.v
// 功能: 对DigitalClock模块进行全面的功能性仿真测试
`timescale 1ns / 1ps

module testbench;

    // -- 参数定义 --
    localparam CLK_PERIOD       = 20; // 50MHz 时钟周期 (20 ns)
    localparam KEY_PRESS_TIME   = 200; // 模拟按键按下的持续时间 (200 ns)
    localparam KEY_WAIT_TIME    = 500; // 模拟两次按键之间的间隔时间 (500 ns)

    // -- 信号定义 --
    // DUT 输入 (reg类型)
    reg clk;
    reg rst_key_in;
    reg key_mode;
    reg key_inc;
    reg key_alarm_off;

    // DUT 输出 (wire类型)
    wire beep;
    wire [3:0] seg_sec0, seg_sec1;
    wire [3:0] seg_min0, seg_min1;
    wire [3:0] seg_hour0, seg_hour1;

    // -- 实例化待测模块 (DUT) --
    DigitalClock uut (
        .clk            (clk),
        .rst_key_in     (rst_key_in),
        .key_mode       (key_mode),
        .key_inc        (key_inc),
        .key_alarm_off  (key_alarm_off),
        .beep           (beep),
        .seg_sec0       (seg_sec0),
        .seg_sec1       (seg_sec1),
        .seg_min0       (seg_min0),
        .seg_min1       (seg_min1),
        .seg_hour0      (seg_hour0),
        .seg_hour1      (seg_hour1)
    );

    // -- 时钟生成 --
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // -- 按键任务 (简化测试流程) --
    // 模拟一次完整的按键按下和释放
    task press_key(inout reg key);
        begin
            key = 1'b0; // 按键按下 (低电平有效)
            #(KEY_PRESS_TIME);
            key = 1'b1; // 按键释放 (高电平有效)
            #(KEY_WAIT_TIME);
        end
    endtask

    // -- 主测试序列 --
    initial begin
        $display("[%0t ns] --- Simulation Start ---", $time);

        // 1. 初始化
        rst_key_in    = 1'b0; // 复位键未按下 (高电平有效)
        key_mode      = 1'b1; // 功能键未按下
        key_inc       = 1'b1;
        key_alarm_off = 1'b1;

        // 2. 施加复位脉冲
        $display("[%0t ns] Applying reset pulse...", $time);
        rst_key_in = 1'b1; // 按下复位键
        #100;
        rst_key_in = 1'b0; // 释放复位键
        $display("[%0t ns] Reset released. Clock starts running.", $time);

        // 3. 测试正常计时
        $display("[%0t ns] Stage 1: Testing normal time counting for 5 seconds.", $time);
        repeat (5) @(posedge uut.u_clk_divider.clk_1hz);
        #1; // 等待一小段时间确保信号稳定
        $display("[%0t ns] Current time is %h%h:%h%h:%h%h.", $time, 
            uut.seg_hour1, uut.seg_hour0, uut.seg_min1, uut.seg_min0, uut.seg_sec1, uut.seg_sec0);

        // 4. 测试时间设置 (设置为 23:59:xx)
        $display("[%0t ns] Stage 2: Testing time adjustment. Setting time to 23:59.", $time);
        press_key(key_mode); // 进入 S_ADJ_H
        $display("          >> Entered hour adjustment mode.");
        repeat (23) press_key(key_inc); // 设置小时为 23

        press_key(key_mode); // 进入 S_ADJ_M
        $display("          >> Entered minute adjustment mode.");
        repeat (59) press_key(key_inc); // 设置分钟为 59
        
        // 5. 测试闹钟设置 (设置为 00:01:xx)
        $display("[%0t ns] Stage 3: Testing alarm adjustment. Setting alarm to 00:01.", $time);
        press_key(key_mode); // 进入 S_ALARM_H
        $display("          >> Entered alarm hour adjustment mode.");
        // 默认闹钟是 6:00, 按 18 次到 0:00 (6->7...23->0)
        repeat (18) press_key(key_inc); 

        press_key(key_mode); // 进入 S_ALARM_M
        $display("          >> Entered alarm minute adjustment mode.");
        press_key(key_inc); // 设置闹钟分钟为 1
        
        press_key(key_mode); // 返回正常模式
        $display("[%0t ns] Stage 4: Returned to normal mode. Waiting for time to roll over and trigger alarm.", $time);
        #1;
        $display("          >> Current time is 23:59:xx. Alarm is set for 00:01:00.");
        
        // 6. 等待并验证闹钟触发
        // 等待时间从 23:59 翻转到 00:00, 再到 00:01
        $display("[%0t ns] Waiting for alarm trigger at 00:01:00...", $time);
        while ({uut.seg_hour1, uut.seg_hour0, uut.seg_min1, uut.seg_min0} !== 16'h0001) begin
            @(posedge uut.u_clk_divider.clk_1hz);
        end
        @(posedge uut.u_clk_divider.clk_1hz); // 再等一秒确保进入 00:01:00
        #1;
        $display("[%0t ns] ALARM SHOULD BE RINGING NOW! (beep=%b)", $time, beep);

        if (beep !== 1'b1) $error("ALARM FAILED TO TRIGGER!");

        // 7. 测试闹钟关闭
        $display("[%0t ns] Stage 5: Alarm is ringing. Waiting for 3 seconds then silencing.", $time);
        repeat (3) @(posedge uut.u_clk_divider.clk_1hz);
        
        press_key(key_alarm_off);
        #1;
        $display("[%0t ns] Alarm Off key pressed. Alarm should be silent now. (beep=%b)", $time, beep);

        if (beep !== 1'b0) $error("ALARM FAILED TO SILENCE!");
        
        // 8. 结束仿真
        $display("[%0t ns] --- All tests passed. Simulation Finish ---", $time);
        $finish;
    end

endmodule