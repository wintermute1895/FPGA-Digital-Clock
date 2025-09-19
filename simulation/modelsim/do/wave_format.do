# ===================================================================
# FINAL FULL WAVEFORM CONFIGURATION SCRIPT (.do file)
# ===================================================================
# This script sets up the entire wave window with proper groups,
# signals, and radix settings for the final digital clock design.
# ===================================================================

onerror {resume}
quietly WaveActivateNextPane {} 0

# --- Group 1: Inputs & Clocking ---
add wave -noupdate -expand -group {Inputs & Clocking} -radix binary /full_functionality_tb/uut/clk
add wave -noupdate -expand -group {Inputs & Clocking} -radix binary /full_functionality_tb/uut/rst
add wave -noupdate -expand -group {Inputs & Clocking} -radix binary /full_functionality_tb/uut/clk_1hz_wire

# --- Group 2: Key Processing ---
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/key_mode
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/key_inc
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/key_alarm_off
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/key_mode_pulse
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/key_inc_pulse
add wave -noupdate -expand -group {Key Processing} -radix binary /full_functionality_tb/uut/key_alarm_off_pulse

# --- Group 3: FSM (State & Control) ---
add wave -noupdate -expand -group {FSM (State & Control)} -radix symbolic /full_functionality_tb/uut/u_controller/current_state
add wave -noupdate -expand -group {FSM (State & Control)} -radix binary /full_functionality_tb/uut/time_count_en_wire
add wave -noupdate -expand -group {FSM (State & Control)} -radix binary /full_functionality_tb/uut/load_en_wire
add wave -noupdate -expand -group {FSM (State & Control)} -radix unsigned /full_functionality_tb/uut/hour_to_counter
add wave -noupdate -expand -group {FSM (State & Control)} -radix unsigned /full_functionality_tb/uut/min_to_counter
add wave -noupdate -expand -group {FSM (State & Control)} -radix symbolic /full_functionality_tb/uut/display_mode_wire

# --- Group 4: Timer & Alarm Core ---
add wave -noupdate -expand -group {Timer & Alarm Core} -radix unsigned /full_functionality_tb/uut/sec_from_counter
add wave -noupdate -expand -group {Timer & Alarm Core} -radix unsigned /full_functionality_tb/uut/min_from_counter
add wave -noupdate -expand -group {Timer & Alarm Core} -radix unsigned /full_functionality_tb/uut/hour_from_counter
add wave -noupdate -expand -group {Timer & Alarm Core} -radix unsigned /full_functionality_tb/uut/u_controller/alarm_hour_reg
add wave -noupdate -expand -group {Timer & Alarm Core} -radix unsigned /full_functionality_tb/uut/u_controller/alarm_min_reg
add wave -noupdate -expand -group {Timer & Alarm Core} -radix binary /full_functionality_tb/uut/u_controller/is_alarming

# --- Group 5: Outputs (Buzzer & Display) ---
add wave -noupdate -expand -group {Outputs (Buzzer & Display)} -radix binary /full_functionality_tb/uut/beep
add wave -noupdate -expand -group {Outputs (Buzzer & Display)} -radix binary /full_functionality_tb/uut/alarm_on_flag_wire
add wave -noupdate -expand -group {Outputs (Buzzer & Display)} -radix binary /full_functionality_tb/uut/digit_sel
add wave -noupdate -expand -group {Outputs (Buzzer & Display)} -radix binary /full_functionality_tb/uut/seg_out
add wave -noupdate -expand -group {Outputs (Buzzer & Display)} -radix unsigned /full_functionality_tb/uut/num_to_decode_wire

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
WaveRestoreZoom {0 ps} {10000000 ps}