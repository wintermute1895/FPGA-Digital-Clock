// src/clock_controller.v (Final Corrected and Complete Version)
// 功能: 数字时钟的核心状态机，控制所有操作模式和信号流。

module clock_controller (
    input   wire        clk_100hz,
    input   wire        rst,
    input   wire        key_mode_pulse,
    input   wire        key_inc_pulse,
    input   wire        key_alarm_off_pulse,
    
    // 来自 time_counter 的当前时间
    input   wire [3:0]  h_units_in, h_tens_in,
    input   wire [3:0]  m_units_in, m_tens_in,
    input   wire [3:0]  s_units_in, s_tens_in,
    
    // 来自 u_time_set_reg 的调整时间
    input   wire [3:0]  adj_h_units_in, adj_h_tens_in,
    input   wire [3:0]  adj_m_units_in, adj_m_tens_in,
    
    // 来自 u_alarm_set_reg 的闹钟时间
    input   wire [3:0]  alarm_h_units_in, alarm_h_tens_in,
    input   wire [3:0]  alarm_m_units_in, alarm_m_tens_in,
    
    // 控制 time_counter
    output  reg         time_count_en,
    output  reg         time_load_en,
    output  reg [4:0]   hour_to_load,
    output  reg [5:0]   min_to_load,

    // 控制 u_time_set_reg (时间调整寄存器)
    output  reg         time_adj_load_en,
    output  reg [4:0]   time_adj_init_h,
    output  reg [5:0]   time_adj_init_m,
    output  reg         time_adj_h_sel,
    output  reg         time_adj_m_sel,
    output  reg         time_adj_inc_pulse,
    
    // 控制 u_alarm_set_reg (闹钟调整寄存器)
    output  reg         alarm_adj_load_en,
    output  reg         alarm_adj_h_sel,
    output  reg         alarm_adj_m_sel,
    output  reg         alarm_adj_inc_pulse,
    
    // 控制 buzzer_controller
    output              alarm_on_flag,
    
    // 控制顶层显示逻辑
    output  wire        display_is_adjusting,
    output  wire [2:0]  current_state 
);

    // 状态定义
    parameter S_NORMAL  = 3'd0;
    parameter S_ADJ_H   = 3'd1;
    parameter S_ADJ_M   = 3'd2;
    parameter S_ALARM_H = 3'd3;
    parameter S_ALARM_M = 3'd4;

    // 状态机寄存器
    reg [2:0] state_r;      // 当前状态寄存器
    reg [2:0] prev_state_r; // 上一个状态寄存器
    reg [2:0] next_state;   // 下一个状态 (组合逻辑)

    // 状态机时序逻辑: 在时钟沿更新状态
    always @(posedge clk_100hz) begin
        if (rst) begin
            state_r      <= S_NORMAL;
            prev_state_r <= S_NORMAL;
        end else begin
            state_r      <= next_state;
            prev_state_r <= state_r;
        end
    end

    // 状态机次态逻辑: 根据当前状态和输入计算下一个状态
    always @(*) begin
        case (state_r)
            S_NORMAL:  next_state = key_mode_pulse ? S_ADJ_H     : S_NORMAL;
            S_ADJ_H:   next_state = key_mode_pulse ? S_ADJ_M     : S_ADJ_H;
            S_ADJ_M:   next_state = key_mode_pulse ? S_ALARM_H   : S_ADJ_M;
            S_ALARM_H: next_state = key_mode_pulse ? S_ALARM_M   : S_ALARM_H;
            S_ALARM_M: next_state = key_mode_pulse ? S_NORMAL    : S_ALARM_M;
            default:   next_state = S_NORMAL;
        endcase
    end

    // 闹钟状态和一次性加载标志
    reg is_alarming;
    reg load_alarm_after_rst;
    wire [5:0] current_sec_bin = s_tens_in * 10 + s_units_in;

    // 核心控制逻辑: 根据当前状态产生所有控制信号
    always @(posedge clk_100hz) begin
        if (rst) begin
            // 复位所有控制信号
            time_count_en <= 1'b1; time_load_en <= 1'b0; hour_to_load <= 'd0; min_to_load <= 'd0;
            time_adj_load_en <= 1'b0; time_adj_init_h <= 'd0; time_adj_init_m <= 'd0;
            time_adj_h_sel <= 1'b0; time_adj_m_sel <= 1'b0; time_adj_inc_pulse <= 1'b0;
            alarm_adj_load_en <= 1'b0; alarm_adj_h_sel <= 1'b0; alarm_adj_m_sel <= 1'b0; alarm_adj_inc_pulse <= 1'b0;
            is_alarming <= 1'b0;
            load_alarm_after_rst <= 1'b1; // 置位标志，以便复位后加载闹钟默认值
        end else begin
            // 每个周期默认将脉冲信号拉低，防止产生过宽的脉冲
            time_load_en <= 1'b0;
            time_adj_load_en <= 1'b0;
            time_adj_inc_pulse <= 1'b0;
            alarm_adj_load_en <= 1'b0;
            alarm_adj_inc_pulse <= 1'b0;
            
            // 默认将选择信号拉低
            time_adj_h_sel <= 1'b0; time_adj_m_sel <= 1'b0;
            alarm_adj_h_sel <= 1'b0; alarm_adj_m_sel <= 1'b0;

            // 复位后的一次性闹钟加载
            if (load_alarm_after_rst) begin
                alarm_adj_load_en <= 1'b1;
                load_alarm_after_rst <= 1'b0;
            end

            // 根据当前状态执行相应操作
            case (state_r)
                S_NORMAL: begin
                    time_count_en <= 1'b1; // 正常模式下，时间计数器使能
                end
                S_ADJ_H: begin
                    time_count_en <= 1'b0; // 调整时间时，暂停时间计数器
                    // **关键修复**: 仅当从正常模式进入时，才加载当前时间到调整寄存器
                    if (prev_state_r == S_NORMAL) begin 
                        time_adj_load_en <= 1'b1;
                        time_adj_init_h <= h_tens_in * 10 + h_units_in;
                        time_adj_init_m <= m_tens_in * 10 + m_units_in;
                    end
                    time_adj_h_sel <= 1'b1;
                    time_adj_inc_pulse <= key_inc_pulse;
                end
                S_ADJ_M: begin
                    time_count_en <= 1'b0; // 调整时间时，暂停时间计数器
                    time_adj_m_sel <= 1'b1;
                    time_adj_inc_pulse <= key_inc_pulse;
                     // 当完成分钟调整，即将切换到闹钟调整时，将调整好的时间加载回主计数器
                     if (next_state != state_r) begin 
                        time_load_en <= 1'b1;
                        hour_to_load <= adj_h_tens_in * 10 + adj_h_units_in;
                        min_to_load  <= adj_m_tens_in * 10 + adj_m_units_in;
                     end
                end
                S_ALARM_H: begin
                    time_count_en <= 1'b1; // 调整闹钟时，主时间继续运行
                    alarm_adj_h_sel <= 1'b1;
                    alarm_adj_inc_pulse <= key_inc_pulse;
                end
                S_ALARM_M: begin
                    time_count_en <= 1'b1; // 调整闹钟时，主时间继续运行
                    alarm_adj_m_sel <= 1'b1;
                    alarm_adj_inc_pulse <= key_inc_pulse;
                end
            endcase

            // 闹钟触发与关闭逻辑
            if (key_alarm_off_pulse || (state_r != S_NORMAL && key_mode_pulse)) begin
                is_alarming <= 1'b0; // 按下关闭键或切换模式时，关闭闹钟
            end else if (!is_alarming && state_r == S_NORMAL &&
                         h_tens_in == alarm_h_tens_in && h_units_in == alarm_h_units_in &&
                         m_tens_in == alarm_m_tens_in && m_units_in == alarm_m_units_in &&
                         current_sec_bin == 0) begin
                is_alarming <= 1'b1; // 时间匹配时，触发闹钟
            end
        end
    end
    
    // 输出信号赋值
    assign alarm_on_flag = is_alarming;
    assign display_is_adjusting = (state_r != S_NORMAL);
    assign current_state = state_r;
    
endmodule