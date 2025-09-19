// src/clock_controller.v
// --- FINAL POLISHED VERSION ---

module clock_controller (
    input   wire        clk,
    input   wire        rst,
    input   wire        key_mode_pulse,
    input   wire        key_inc_pulse,
    input   wire        key_alarm_off_pulse,
    input   wire [4:0]  hour_in,
    input   wire [5:0]  min_in,
    input   wire [5:0]  sec_in,
    output  reg         time_count_en,
    output  reg         load_en,
    output  reg [4:0]   hour_out,
    output  reg [5:0]   min_out,
    output  wire        alarm_on_flag,
    output  reg [2:0]   display_mode
);

    // 状态定义
    parameter S_NORMAL    = 3'd0;
    parameter S_ADJ_H     = 3'd1;
    parameter S_ADJ_M     = 3'd2;
    parameter S_ALARM_H   = 3'd3;
    parameter S_ALARM_M   = 3'd4;
    
    reg [2:0] current_state, next_state;
    
    // FSM Segment 1: 状态寄存器 (时序逻辑)
    always @(posedge clk or posedge rst) begin
        if (rst)    current_state <= S_NORMAL;
        else        current_state <= next_state;
    end

    // FSM Segment 2: 次态逻辑 (组合逻辑)
    always @(*) begin
        case (current_state)
            S_NORMAL:  next_state = key_mode_pulse ? S_ADJ_H     : S_NORMAL;
            S_ADJ_H:   next_state = key_mode_pulse ? S_ADJ_M     : S_ADJ_H;
            S_ADJ_M:   next_state = key_mode_pulse ? S_ALARM_H   : S_ADJ_M;
            S_ALARM_H: next_state = key_mode_pulse ? S_ALARM_M   : S_ALARM_H;
            S_ALARM_M: next_state = key_mode_pulse ? S_NORMAL    : S_ALARM_M;
            default:   next_state = S_NORMAL;
        endcase
    end

    // FSM Segment 3: 输出逻辑与内部状态更新 (时序逻辑)
    reg [4:0] alarm_hour_reg;
    reg [5:0] alarm_min_reg;
    reg       is_alarming;
    reg       sec_is_59_reg; // 【优化】将此 reg 移入主 always 块

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            time_count_en  <= 1'b1;
            load_en        <= 1'b0;
            hour_out       <= 5'd0;
            min_out        <= 6'd0;
            display_mode   <= S_NORMAL;
            alarm_hour_reg <= 5'd6;
            alarm_min_reg  <= 6'd0;
            is_alarming    <= 1'b0;
            sec_is_59_reg  <= 1'b0;
        end else begin
            // 默认行为
            load_en <= 1'b0; 
            hour_out <= hour_in;
            min_out <= min_in;
            display_mode <= current_state;

            // 【优化】sec_is_59_reg 的更新逻辑合并于此
            sec_is_59_reg <= (sec_in == 6'd59);

            // FSM 输出逻辑
            case (current_state)
                S_NORMAL:  time_count_en <= 1'b1;
                S_ADJ_H:   begin
                    time_count_en <= 1'b0;
                    if (key_inc_pulse) begin load_en <= 1'b1; hour_out <= (hour_in == 5'd23) ? 5'd0 : hour_in + 1; end
                end
                S_ADJ_M:   begin
                    time_count_en <= 1'b0;
                    if (key_inc_pulse) begin load_en <= 1'b1; min_out  <= (min_in == 6'd59) ? 6'd0 : min_in + 1; end
                end
                S_ALARM_H: begin
                    time_count_en <= 1'b1;
                    if (key_inc_pulse) alarm_hour_reg <= (alarm_hour_reg == 5'd23) ? 5'd0 : alarm_hour_reg + 1;
                end
                S_ALARM_M: begin
                    time_count_en <= 1'b1;
                    if (key_inc_pulse) alarm_min_reg  <= (alarm_min_reg == 6'd59) ? 6'd0 : alarm_min_reg + 1;
                end
                default:   time_count_en <= 1'b1;
            endcase
            
            // 闹钟触发/关闭逻辑
            if (key_alarm_off_pulse) begin
                is_alarming <= 1'b0;
            end else if (key_mode_pulse) begin
                is_alarming <= 1'b0;
            end else if (is_alarming == 1'b0 && 
                         hour_in == alarm_hour_reg && 
                         min_in == alarm_min_reg && 
                         sec_in == 6'd0) begin
                is_alarming <= 1'b1;
            end
        end
    end

    // 组合逻辑输出
    wire hourly_chime = time_count_en && (min_in == 6'd0) && (sec_in == 6'd0) && sec_is_59_reg;
    assign alarm_on_flag = is_alarming || hourly_chime;

endmodule