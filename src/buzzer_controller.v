// src/buzzer_controller.v
// --- FINAL VERSION ---
// 功能：在接收到报警触发信号时，产生驱动蜂鸣器的音频方波

module buzzer_controller(
    input wire clk,      // 50MHz 主时钟
    input wire rst,
    input wire alarm_on, // 报警触发信号 (来自 clock_controller)
    output reg beep     // 连接到物理蜂鸣器的输出引脚
);
    // 为了产生约 1kHz 的音频，我们需要一个周期为 50,000 个时钟周期的计数器
    // 50MHz / 50,000 = 1kHz
    reg [15:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 16'd0;
            beep <= 1'b0; // 复位时，不响
        end else if (alarm_on) begin // 【核心】只有在报警触发信号为高电平时才工作
            if (counter == 16'd49999) begin
                counter <= 16'd0;
            end else begin
                counter <= counter + 1;
            end

            // 当计数器在前一半周期时，输出高电平；后一半周期时，输出低电平
            // 这就产生了一个占空比为 50% 的方波
            if (counter < 16'd25000) begin
                beep <= 1'b1;
            end else begin
                beep <= 1'b0;
            end
        end else begin
            // 如果没有报警，计数器和蜂鸣器都保持静默
            counter <= 16'd0;
            beep <= 1'b0;
        end
    end
endmodule