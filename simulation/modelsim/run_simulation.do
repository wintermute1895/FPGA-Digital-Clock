# ===================================================================
# ModelSim Simulation Script: run_simulation.do (with Absolute Paths)
# ===================================================================
# This script automates the entire simulation process using full,
# unambiguous file paths.
#
# USAGE: In ModelSim Transcript, type: do F:/FPGA/quartus/bin64/simulation/modelsim/run_simulation.do
# ===================================================================

echo "--- Starting Automated Simulation Script with Absolute Paths ---"

# --- Step 1: Clean and Prepare Environment ---
# It's good practice to work from a known directory.
cd F:/FPGA/quartus/bin64/simulation/modelsim

# Clean the 'work' library for a fresh start.
if {[file exists work]} {
    vdel -lib work -all
    echo "--- Old 'work' library deleted. ---"
}
vlib work
vmap work work
echo "--- New 'work' library created and mapped. ---"

# --- Step 2: Compile All Design Source Files (.v) using Absolute Paths ---
echo "--- Compiling 7 design files... ---"
vlog -work work F:/FPGA/quartus/bin64/src/clk_divider.v
vlog -work work F:/FPGA/quartus/bin64/src/display_decoder.v
vlog -work work F:/FPGA/quartus/bin64/src/key_debounce.v
vlog -work work F:/FPGA/quartus/bin64/src/time_counter.v
vlog -work work F:/FPGA/quartus/bin64/src/display_scanner.v
vlog -work work F:/FPGA/quartus/bin64/src/clock_controller.v
vlog -work work F:/FPGA/quartus/bin64/src/DigitalClock.v

# --- Step 3: Compile the Testbench File using an Absolute Path ---
echo "--- Compiling testbench file... ---"
vlog -work work F:/FPGA/quartus/bin64/testbench/final_test_tb.v

# --- Step 4: Launch the Simulator ---
echo "--- Launching simulator... ---"
# Launch vsim with the testbench from the 'work' library.
# The -voptargs="+acc" is CRITICAL for full signal visibility.
vsim -voptargs="+acc" work.final_test_tb

# --- Step 5: Configure Waveform and Run Simulation ---
echo "--- Loading custom wave format and running... ---"
# Load the predefined wave settings using its absolute path.
do F:/FPGA/quartus/bin64/simulation/modelsim/final_wave_format.do

# Run the simulation until the $stop command is encountered in the testbench.
run -all

# --- Script Finished ---
echo "--- Simulation paused. Analysis can begin. ---"

