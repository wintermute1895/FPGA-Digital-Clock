# simulation/modelsim/wave_format.do
# --- FINAL & CORRECTED FOR DIRECT SIGNAL ACCESS ---

onerror {resume}
quietly WaveActivateNextPane {} 0

# --- Group 1: Core Inputs & Clock Enables ---
# Testbench-level signals
add wave -noupdate -expand -group {Inputs & Clocks} -radix binary /full_functionality_tb/clk
add wave -noupdate -expand -group {Inputs & Clocks} -radix binary /full_functionality_tb/rst
# 【修正】直接引用UUT内部的信号
add wave -noupdate -expand -group {Inputs & Clocks} -radix binary /full_functionality_tb/uut/clk_1hz_en_wire 
add wave -noupdate -divider {User Keys}
# Testbench-level signals
add wave -noupdate -expand -group {Inputs & Clocks} -radix binary /full_functionality_tb/key_mode
add wave -noupdate -expand -group {Inputs & Clocks} -radix binary /full_functionality_tb/key_inc
add wave -noupdate -expand -group {Inputs & Clocks} -radix binary /full_functionality_tb/key_alarm_off

# --- Group 2: Key Debouncing & Pulse Generation ---
# 【修正】直接引用UUT内部的信号
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/debounce_mode/key_state_sync
add wave -noupdate -expand -group {Key Processing} -radix unsigned /full_functionality_tb/uut/debounce_mode/counter
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/debounce_mode/key_state_q
add wave -noupdate -divider {Generated Pulses}
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/key_mode_pulse
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/key_inc_pulse
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/key_alarm_off_pulse
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/debounce_mode/key_in
add wave -noupdate -divider {Debounce Internals}

# --- Group 3: Controller FSM & Control Signals ---
# 【修正】直接引用UUT内部的信号
add wave -noupdate -expand -group {Controller} -radix symbolic /full_functionality_tb/uut/u_controller/current_state
add wave -noupdate -expand -group {Controller} -radix binary /full_functionality_tb/uut/time_count_en_wire
add wave -noupdate -expand -group {Controller} -radix binary /full_functionality_tb/uut/load_en_wire
add wave -noupdate -divider {Controller Outputs to Counter}
add wave -noupdate -expand -group {Controller} -radix unsigned /full_functionality_tb/uut/hour_to_counter
add wave -noupdate -expand -group {Controller} -radix unsigned /full_functionality_tb/uut/min_to_counter

# --- Group 4: Time Counter Data ---
# 【修正】直接引用UUT内部的信号
add wave -noupdate -expand -group {Time Data} -radix unsigned /full_functionality_tb/uut/hour_from_counter
add wave -noupdate -expand -group {Time Data} -radix unsigned /full_functionality_tb/uut/min_from_counter
add wave -noupdate -expand -group {Time Data} -radix unsigned /full_functionality_tb/uut/sec_from_counter

# --- Group 5: Alarm Logic ---
# 【修正】直接引用UUT内部的信号
add wave -noupdate -expand -group {Alarm} -radix unsigned /full_functionality_tb/uut/u_controller/alarm_hour_reg
add wave -noupdate -expand -group {Alarm} -radix unsigned /full_functionality_tb/uut/u_controller/alarm_min_reg
add wave -noupdate -divider {Alarm Flags}
add wave -noupdate -expand -group {Alarm} -radix binary /full_functionality_tb/uut/alarm_on_flag_wire
add wave -noupdate -expand -group {Alarm} -radix binary /full_functionality_tb/uut/beep

# --- Waveform Window Configuration ---
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 350
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {400000 ps}