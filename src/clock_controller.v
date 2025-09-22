// src/clock_controller.v (Final Version with display control output)
module clock_controller (
    input   wire        clk_100hz,
    input   wire        rst,
    input   wire        key_mode_pulse,
    input   wire        key_inc_pulse,
    input   wire        key_alarm_off_pulse,
    
    input   wire [3:0]  h_units_in, h_tens_in,
    input   wire [3:0]  m_units_in, m_tens_in,
    input   wire [3:0]  s_units_in, s_tens_in,
    
    input   wire [3:0]  adj_h_units_in, adj_h_tens_in,
    input   wire [3:0]  adj_m_units_in, adj_m_tens_in,
    
    input   wire [3:0]  alarm_h_units_in, alarm_h_tens_in,
    input   wire [3:0]  alarm_m_units_in, alarm_m_tens_in,
    
    output  reg         time_count_en,
    output  reg         time_load_en,
    output  reg [4:0]   hour_to_load,
    output  reg [5:0]   min_to_load,

    output  reg         time_adj_load_en,
    output  reg [4:0]   time_adj_init_h,
    output  reg [5:0]   time_adj_init_m,
    output  reg         time_adj_h_sel,
    output  reg         time_adj_m_sel,
    output  reg         time_adj_inc_pulse,
    
    output  reg         alarm_adj_load_en,
    output  reg         alarm_adj_h_sel,
    output  reg         alarm_adj_m_sel,
    output  reg         alarm_adj_inc_pulse,
    
    output              alarm_on_flag,
    
    output  wire        display_is_adjusting // New output for display control
);

    parameter S_NORMAL=3'd0, S_ADJ_H=3'd1, S_ADJ_M=3'd2, S_ALARM_H=3'd3, S_ALARM_M=3'd4;
    reg [2:0] current_state, next_state;

    always @(posedge clk_100hz) begin
        if (rst) current_state <= S_NORMAL;
        else     current_state <= next_state;
    end

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

    reg is_alarming;
    wire [5:0] current_sec_bin = s_tens_in * 10 + s_units_in;

    always @(posedge clk_100hz) begin
        if (rst) begin
            time_count_en <= 1'b1; time_load_en <= 1'b0; hour_to_load <= 'd0; min_to_load <= 'd0;
            time_adj_load_en <= 1'b0; time_adj_init_h <= 'd0; time_adj_init_m <= 'd0;
            time_adj_h_sel <= 1'b0; time_adj_m_sel <= 1'b0; time_adj_inc_pulse <= 1'b0;
            alarm_adj_load_en <= 1'b1; alarm_adj_h_sel <= 1'b0; alarm_adj_m_sel <= 1'b0; alarm_adj_inc_pulse <= 1'b0;
            is_alarming <= 1'b0;
        end else begin
            time_load_en <= 1'b0;
            time_adj_load_en <= 1'b0; time_adj_h_sel <= 1'b0; time_adj_m_sel <= 1'b0; time_adj_inc_pulse <= 1'b0;
            alarm_adj_h_sel <= 1'b0; alarm_adj_m_sel <= 1'b0; alarm_adj_inc_pulse <= 1'b0;

            case (current_state)
                S_NORMAL: begin
                    time_count_en <= 1'b1;
                end
                S_ADJ_H: begin
                    time_count_en <= 1'b0;
                    if (next_state != current_state) begin
                        time_adj_load_en <= 1'b1;
                        time_adj_init_h <= h_tens_in * 10 + h_units_in;
                        time_adj_init_m <= m_tens_in * 10 + m_units_in;
                    end
                    time_adj_h_sel <= 1'b1;
                    time_adj_inc_pulse <= key_inc_pulse;
                end
                S_ADJ_M: begin
                    time_count_en <= 1'b0;
                    time_adj_m_sel <= 1'b1;
                    time_adj_inc_pulse <= key_inc_pulse;
                     if (next_state != current_state) begin
                        time_load_en <= 1'b1;
                        hour_to_load <= adj_h_tens_in * 10 + adj_h_units_in;
                        min_to_load  <= adj_m_tens_in * 10 + adj_m_units_in;
                     end
                end
                S_ALARM_H: begin
                    time_count_en <= 1'b1;
                    alarm_adj_h_sel <= 1'b1;
                    alarm_adj_inc_pulse <= key_inc_pulse;
                end
                S_ALARM_M: begin
                    time_count_en <= 1'b1;
                    alarm_adj_m_sel <= 1'b1;
                    alarm_adj_inc_pulse <= key_inc_pulse;
                end
            endcase

            if (key_alarm_off_pulse || (current_state != S_NORMAL && key_mode_pulse)) begin
                is_alarming <= 1'b0;
            end else if (!is_alarming && current_state == S_NORMAL &&
                         h_tens_in == alarm_h_tens_in && h_units_in == alarm_h_units_in &&
                         m_tens_in == alarm_m_tens_in && m_units_in == alarm_m_units_in &&
                         current_sec_bin == 0) begin
                is_alarming <= 1'b1;
            end
        end
    end
    
    assign alarm_on_flag = is_alarming;
    assign display_is_adjusting = (current_state != S_NORMAL);
    
endmodule