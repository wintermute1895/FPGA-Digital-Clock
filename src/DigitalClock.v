// src/DigitalClock.v (Fully Corrected and Upgraded Version)
module DigitalClock (
    input  wire        clk,           // 50MHz Main Clock
    input  wire        rst_key_in,    // External reset key
    input  wire        key_mode,
    input  wire        key_inc,
    input  wire        key_alarm_off,
    output wire        beep,
    output wire [3:0]  seg_sec0, seg_sec1,
    output wire [3:0]  seg_min0, seg_min1,
    output wire [3:0]  seg_hour0, seg_hour1
);
    // -- Internal Wires and Parameters --
    localparam S_NORMAL=3'd0, S_ADJ_H=3'd1, S_ADJ_M=3'd2, S_ALARM_H=3'd3, S_ALARM_M=3'd4;
    localparam BLANK = 4'hF; // BCD code to make the 7-seg display blank

    wire clk_1hz, clk_2hz, clk_100hz, clk_buzzer_osc;
    wire key_mode_pulse, key_inc_pulse, key_alarm_off_pulse;
    wire rst_signal;

    // -- Reset Logic: Combining Power-On Reset and Synchronized Manual Reset --
    wire por_rst;
    power_on_reset u_por (.clk(clk), .rst(por_rst));

    // Synchronize the external manual reset key to prevent metastability
    reg rst_key_sync_0, rst_key_sync_1;
    always @(posedge clk) begin
        // ** IMPORTANT **: Modify based on your board. This assumes active-low key (press = 0).
        rst_key_sync_0 <= rst_key_in; 
        rst_key_sync_1 <= rst_key_sync_0;
    end
    
    // Final reset signal is high if power-on reset is active OR manual reset is pressed
    assign rst_signal = por_rst || rst_key_sync_1;

    // -- Module Instantiations --

    clk_divider u_clk_divider (
        .clk(clk), .rst(rst_signal),
        .clk_1hz(clk_1hz), .clk_2hz(clk_2hz), .clk_100hz(clk_100hz), .clk_buzzer_osc(clk_buzzer_osc)
    );

    key_debounce debounce_mode (.clk_100hz(clk_100hz), .rst(rst_signal), .key_in(key_mode), .key_pulse(key_mode_pulse));
    key_debounce debounce_inc (.clk_100hz(clk_100hz), .rst(rst_signal), .key_in(key_inc), .key_pulse(key_inc_pulse));
    key_debounce debounce_alarm_off (.clk_100hz(clk_100hz), .rst(rst_signal), .key_in(key_alarm_off), .key_pulse(key_alarm_off_pulse));

    wire [3:0] s_units, s_tens, m_units, m_tens, h_units, h_tens;
    wire time_count_en, time_load_en;
    wire [4:0] hour_to_load;
    wire [5:0] min_to_load;
    time_counter u_time_counter ( .clk(clk), .clk_1hz(clk_1hz), .rst(rst_signal), .time_count_en(time_count_en), .load_en(time_load_en), .hour_in(hour_to_load), .min_in(min_to_load), .s_units_r(s_units), .s_tens_r(s_tens), .m_units_r(m_units), .m_tens_r(m_tens), .h_units_r(h_units), .h_tens_r(h_tens) );

    wire time_adj_load_en, time_adj_h_sel, time_adj_m_sel, time_adj_inc_pulse;
    wire alarm_adj_load_en, alarm_adj_h_sel, alarm_adj_m_sel, alarm_adj_inc_pulse;
    wire [4:0] time_adj_init_h;
    wire [5:0] time_adj_init_m;
    wire [3:0] adj_h_units, adj_h_tens, adj_m_units, adj_m_tens;
    wire [3:0] alarm_h_units, alarm_h_tens, alarm_m_units, alarm_m_tens;
    bcd_adjustable_time_reg u_time_set_reg ( .clk_100hz(clk_100hz), .rst(rst_signal), .load_en(time_adj_load_en), .init_h_val(time_adj_init_h), .init_m_val(time_adj_init_m), .h_sel(time_adj_h_sel), .m_sel(time_adj_m_sel), .inc_val_pulse(time_adj_inc_pulse), .h_units_r(adj_h_units), .h_tens_r(adj_h_tens), .m_units_r(adj_m_units), .m_tens_r(adj_m_tens) );
    bcd_adjustable_time_reg u_alarm_set_reg ( .clk_100hz(clk_100hz), .rst(rst_signal), .load_en(alarm_adj_load_en), .init_h_val(5'd6), .init_m_val(6'd0), .h_sel(alarm_adj_h_sel), .m_sel(alarm_adj_m_sel), .inc_val_pulse(alarm_adj_inc_pulse), .h_units_r(alarm_h_units), .h_tens_r(alarm_h_tens), .m_units_r(alarm_m_units), .m_tens_r(alarm_m_tens) );

    wire alarm_on_flag, display_is_adjusting;
    wire [2:0] controller_state;
    clock_controller u_controller (
        .clk_100hz(clk_100hz), .rst(rst_signal),
        .key_mode_pulse(key_mode_pulse), .key_inc_pulse(key_inc_pulse), .key_alarm_off_pulse(key_alarm_off_pulse),
        .h_units_in(h_units), .h_tens_in(h_tens), .m_units_in(m_units), .m_tens_in(m_tens), .s_units_in(s_units), .s_tens_in(s_tens),
        .adj_h_units_in(adj_h_units), .adj_h_tens_in(adj_h_tens), .adj_m_units_in(adj_m_units), .adj_m_tens_in(adj_m_tens),
        .alarm_h_units_in(alarm_h_units), .alarm_h_tens_in(alarm_h_tens), .alarm_m_units_in(alarm_m_units), .alarm_m_tens_in(alarm_m_tens),
        .time_count_en(time_count_en), .time_load_en(time_load_en), .hour_to_load(hour_to_load), .min_to_load(min_to_load),
        .time_adj_load_en(time_adj_load_en), .time_adj_init_h(time_adj_init_h), .time_adj_init_m(time_adj_init_m),
        .time_adj_h_sel(time_adj_h_sel), .time_adj_m_sel(time_adj_m_sel), .time_adj_inc_pulse(time_adj_inc_pulse),
        .alarm_adj_load_en(alarm_adj_load_en), .alarm_adj_h_sel(alarm_adj_h_sel), .alarm_adj_m_sel(alarm_adj_m_sel), .alarm_adj_inc_pulse(alarm_adj_inc_pulse),
        .alarm_on_flag(alarm_on_flag), .display_is_adjusting(display_is_adjusting),
        .current_state(controller_state)
    );
        
    // -- Correct Display Mux Logic --
    // This block selects which BCD values to show based on the controller's state.
    reg [3:0] disp_h_tens_mux, disp_h_units_mux, disp_m_tens_mux, disp_m_units_mux;

    always @(*) begin
        case (controller_state)
            S_ADJ_H, S_ADJ_M: begin // In time adjust mode, show the adjusted value
                disp_h_tens_mux = adj_h_tens;
                disp_h_units_mux = adj_h_units;
                disp_m_tens_mux = adj_m_tens;
                disp_m_units_mux = adj_m_units;
            end
            S_ALARM_H, S_ALARM_M: begin // In alarm adjust mode, show the alarm value
                disp_h_tens_mux = alarm_h_tens;
                disp_h_units_mux = alarm_h_units;
                disp_m_tens_mux = alarm_m_tens;
                disp_m_units_mux = alarm_m_units;
            end
            default: begin // In normal mode, show the current time
                disp_h_tens_mux = h_tens;
                disp_h_units_mux = h_units;
                disp_m_tens_mux = m_tens;
                disp_m_units_mux = m_units;
            end
        endcase
    end

    // -- New Blinking Logic: Blink HH:MM during any adjustment --
    wire is_blinking = display_is_adjusting && clk_2hz;

    assign seg_hour1 = is_blinking ? BLANK : disp_h_tens_mux;
    assign seg_hour0 = is_blinking ? BLANK : disp_h_units_mux;
    assign seg_min1  = is_blinking ? BLANK : disp_m_tens_mux;
    assign seg_min0  = is_blinking ? BLANK : disp_m_units_mux;
    assign seg_sec1  = s_tens; // Seconds never blink
    assign seg_sec0  = s_units;

    // -- Final Module Instantiations --
    // u_display_controller removed as it's redundant.
    buzzer_controller u_buzzer (.clk_buzzer_osc(clk_buzzer_osc), .rst(rst_signal), .alarm_on(alarm_on_flag), .beep(beep));

endmodule