// src/buzzer_controller.v (Re-architected Version)
module buzzer_controller(
    input wire clk_buzzer_osc, // 外部1kHz振荡源
    input wire rst,
    input wire alarm_on,       // 使能信号
    output reg beep
);
    always @(posedge clk_buzzer_osc) begin
        if (rst) begin
            beep <= 1'b0;
        end else begin
            if (alarm_on) begin
                beep <= ~beep; // 使能时，直接翻转输出方波
            end else begin
                beep <= 1'b0;
            end
        end
    end
endmodule