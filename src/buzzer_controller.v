// buzzer_controller.v
module buzzer_controller(
    input wire clk,      // 50MHz 主时钟
    input wire rst,
    input wire alarm_on, // 报警触发信号
    output reg beep     // 连接到蜂鸣器的输出
);
    reg [15:0] counter;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 16'd0;
            beep <= 1'b0;
        end else if (alarm_on) begin // 只有在报警时才工作
            counter <= counter + 1;
            if (counter < 16'd25000) begin // 产生一个 1kHz 的方波 (50MHz / 50000)
                beep <= 1'b1;
            end else if (counter < 16'd50000) begin
                beep <= 1'b0;
            end else begin
                counter <= 16'd0;
            end
        end else begin
            counter <= 16'd0;
            beep <= 1'b0;
        end
    end
endmodule