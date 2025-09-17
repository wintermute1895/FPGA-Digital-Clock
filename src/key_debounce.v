// key_debounce.v
module key_debounce (
    input wire clk,       // 50MHz 主时钟
    input wire rst,
    input wire key_in,     // 物理按键输入 (通常是低电平有效)
    output reg key_pulse  // 输出单周期脉冲
);
    reg [1:0] key_state;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            key_state <= 2'b11;
        end else begin
            key_state <= {key_state[0], key_in};
        end
    end

    // 检测到下降沿 (从 11 -> 10)
    wire key_negedge = (key_state == 2'b11) & (key_in == 1'b0);
    
    reg [15:0] debounce_counter; // 约1.3ms的消抖延时
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            debounce_counter <= 16'd0;
            key_pulse <= 1'b0;
        end else begin
            key_pulse <= 1'b0; // 脉冲只持续一个周期
            if (key_negedge) begin
                debounce_counter <= 16'd0;
            end else if (debounce_counter == 16'd999) begin
                // 延时结束，如果按键仍然按下，输出脉冲
                if (key_in == 1'b0) begin
                    key_pulse <= 1'b1;
                end
            end else if (key_in == 1'b0) begin
                debounce_counter <= debounce_counter + 1;
            end
        end
    end
endmodule