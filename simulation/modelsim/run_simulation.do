# ===================================================================
# ModelSim Simulation Script: run_manual_debug.do
# ===================================================================
# This script is for step-by-step manual debugging.
#
# USAGE: In ModelSim Transcript, type: do F:/FPGA/quartus/bin64/simulation/modelsim/run_simulation.do
# ===================================================================

echo "--- Starting Automated Script for MANUAL DEBUGGING ---"

# --- Step 1: Clean and Prepare Environment ---
cd F:/FPGA/quartus/bin64/simulation/modelsim
if {[file exists work]} {
    vdel -lib work -all
    echo "--- Old 'work' library deleted. ---"
}
vlib work
vmap work work
echo "--- New 'work' library created and mapped. ---"

# --- Step 2: Compile All 8 Design Source Files ---
echo "--- Compiling 8 design files... ---"
vlog -work work F:/FPGA/quartus/bin64/src/clk_divider.v
vlog -work work F:/FPGA/quartus/bin64/src/display_decoder.v
vlog -work work F:/FPGA/quartus/bin64/src/key_debounce.v
vlog -work work F:/FPGA/quartus/bin64/src/time_counter.v
vlog -work work F:/FPGA/quartus/bin64/src/display_scanner.v
vlog -work work F:/FPGA/quartus/bin64/src/buzzer_controller.v
vlog -work work F:/FPGA/quartus/bin64/src/clock_controller.v
vlog -work work F:/FPGA/quartus/bin64/src/DigitalClock.v

# --- Step 3: Compile the MANUAL DEBUG Testbench ---
# 【核心改动】: 编译新的、简单的Testbench
echo "--- Compiling manual debug testbench file... ---"
vlog -work work F:/FPGA/quartus/bin64/testbench/full_functionality_tb.v

# --- Step 4: Launch the Simulator ---
# 【核心改动】: 启动新的Testbench
echo "--- Launching simulator with full_functionality_tb... ---"
vsim -voptargs="+acc" work.full_functionality_tb

# --- Step 5: Configure Waveform and Run Simulation ---
echo "--- Loading custom wave format and running... ---"
do F:/FPGA/quartus/bin64/simulation/modelsim/wave_format.do
run -all

# --- Script Finished ---
echo "--- Simulation paused. Analysis can begin. ---"