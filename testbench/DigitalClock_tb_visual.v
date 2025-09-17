// DigitalClock_tb_visual.v (Final and Complete Version)

`timescale 1ns / 1ps

module DigitalClock_tb_visual;

    // --- 1. 信号和变量声明区 ---
    //    为 DigitalClock 的每一个端口，都定义一个对应的信号
    reg clk;
    reg rst;
    reg key_mode;
    reg key_inc;

    wire [6:0] seg_out;
    wire [5:0] digit_sel;
    
    integer file_handle;

    // --- 2. 设计实例化 (DUT - Design Under Test) ---
    //    将所有端口都连接上
    DigitalClock uut (
        .clk(clk),
        .rst(rst),
        .key_mode(key_mode),
        .key_inc(key_inc),
        .seg_out(seg_out),
        .digit_sel(digit_sel)
    );

    // --- 3. 辅助任务 (Tasks) ---
    //    将重复的按键操作封装成任务，让代码更清晰
    task press_key;
        input key_to_press;
        begin
            @(posedge clk); // 等待时钟上升沿对齐
            key_to_press = 1'b0; // 按下按键
            #100;                // 按下 100ns
            key_to_press = 1'b1; // 松开按键
            @(posedge clk); // 等待时钟上升沿对齐
        end
    endtask

    // --- 4. 时钟发生器 ---
    //    这个 initial 块的唯一职责，就是从头到尾产生一个稳定的时钟
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk; // 每 10ns 翻转一次，产生 50MHz 时钟
    end

    // --- 5. 主测试流程 ---
    initial begin
        // 打开文件用于记录
        file_handle = $fopen("display_data.txt", "w");
        if (file_handle == 0) begin
            $display("Error: Could not open file 'display_data.txt'.");
            $finish;
        end
        $fmonitor(file_handle, "%b %b", digit_sel, seg_out);
        
        // ---- 仿真开始 ----
        $display("--- Simulation Start ---");

        // 1. 初始化所有输入并进行复位
        rst      = 1'b1;
        key_mode = 1'b1; // 按键默认松开
        key_inc  = 1'b1;
        #100;
        rst = 1'b0;
        $display("T=%t ns: System Reset Released. Clock starts running normally.", $time);
        
        // 2. 等待时钟走到 2 秒 (在仿真中是 2us)
        #1900; // 从 100ns 走到 2000ns (2us)
        $display("T=%t ns: Reached 2 seconds. Preparing to adjust time.", $time);

        // 3. 按下模式键，进入“调整小时”模式
        press_key(key_mode);
        $display("T=%t ns: MODE key pressed. Should enter ADJUST HOUR state.", $time);

        // 4. 等待 1 秒
        #1000;

        // 5. 按下增加键 2 次，将小时调整为 2
        press_key(key_inc);
        $display("T=%t ns: INC key pressed. Hour should be 1.", $time);
        #1000;
        press_key(key_inc);
        $display("T=%t ns: INC key pressed. Hour should be 2.", $time);

        // 6. 等待 1 秒
        #1000;

        // 7. 按下模式键，进入“调整分钟”模式
        press_key(key_mode);
        $display("T=%t ns: MODE key pressed. Should enter ADJUST MINUTE state.", $time);

        // 8. 等待 1 秒
        #1000;
        
        // 9. 按下增加键 3 次，将分钟调整为 3
        press_key(key_inc);
        $display("T=%t ns: INC key pressed. Minute should be 1.", $time);
        #1000;
        press_key(key_inc);
        $display("T=%t ns: INC key pressed. Minute should be 2.", $time);
        #1000;
        press_key(key_inc);
        $display("T=%t ns: INC key pressed. Minute should be 3.", $time);

        // 10. 等待 1 秒
        #1000;

        // 11. 按下模式键，回到“正常显示”模式
        press_key(key_mode);
        $display("T=%t ns: MODE key pressed. Should return to NORMAL state. Time is now 02:03:00.", $time);
        
        // 12. 让调整后的时间再走 3 秒
        #3000;
        $display("T=%t ns: Clock has been running for 3 more seconds.", $time);

        // ---- 仿真结束 ----
        $display("--- Simulation Finished ---");
        $fclose(file_handle);
        $stop;
    end

endmodule