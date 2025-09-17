// clock_controller.v (Final, Ultra-Robust FSM Version)

module clock_controller (
    input   wire        clk,
    input   wire        rst,
    input   wire        key_mode_pulse,
    input   wire        key_inc_pulse,
    input   wire [4:0]  hour_in,
    input   wire [5:0]  min_in,
    output  reg         time_count_en,
    output  reg         load_en,
    output  reg [4:0]   hour_out,
    output  reg [5:0]   min_out
);

    // 1. 状态定义
    parameter S_NORMAL = 2'd0;
    parameter S_ADJ_H  = 2'd1;
    parameter S_ADJ_M  = 2'd2;
    
    reg [1:0] current_state, next_state;

    // 2. 状态寄存器 (时序逻辑)
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S_NORMAL;
        else
            current_state <= next_state;
    end

    // 3. 次态逻辑 (组合逻辑)
    always @(*) begin
        case (current_state)
            S_NORMAL: next_state = key_mode_pulse ? S_ADJ_H   : S_NORMAL;
            S_ADJ_H:  next_state = key_mode_pulse ? S_ADJ_M   : S_ADJ_H;
            S_ADJ_M:  next_state = key_mode_pulse ? S_NORMAL  : S_ADJ_M;
            default:  next_state = S_NORMAL;
        endcase
    end

    // 4. 输出逻辑 (组合逻辑，最关键的修正)
    //    这个 always 块明确定义了所有输出在任何情况下的值
    always @(*) begin
        // 首先，设置所有输出的默认值
        time_count_en = 1'b0; // 默认暂停计时
        load_en       = 1'b0; // 默认不加载
        hour_out      = hour_in; // 默认输出等于输入
        min_out       = min_in;

        // 然后，根据当前状态覆盖默认值
        case (current_state)
            S_NORMAL: begin
                time_count_en = 1'b1; // 在正常模式下，允许计时
            end
            S_ADJ_H: begin
                if (key_inc_pulse) begin
                    load_en  = 1'b1; // 只有在按键时才加载
                    hour_out = (hour_in == 5'd23) ? 5'd0 : hour_in + 1;
                end
            end
            S_ADJ_M: begin
                if (key_inc_pulse) begin
                    load_en  = 1'b1;
                    min_out  = (min_in == 6'd59) ? 6'd0 : min_in + 1;
                end
            end
        endcase
    end

endmodule