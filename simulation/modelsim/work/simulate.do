# simulate.do
# ModelSim 编译和运行脚本

# 1. 清理环境，重新开始
quit -f
vdel -all
vlib work
vmap work work

echo "--- Compiling source files... ---"

# 2. 编译所有Verilog源文件
#    注意: 顺序很重要, 先编译底层模块, 最后编译顶层和testbench
vlog ./src/clk_divider.v
vlog ./src/key_debounce.v
vlog ./src/bcd_adjustable_time_reg.v
vlog ./src/time_counter.v
vlog ./src/buzzer_controller.v
vlog ./src/display_controller.v
vlog ./src/clock_controller.v
vlog ./src/DigitalClock.v

echo "--- Compiling testbench... ---"
vlog ./testbench.v

echo "--- Starting simulation... ---"

# 3. 启动仿真器
#    -voptargs=+acc 是为了让波形窗口可以访问和显示内部信号
vsim -voptargs=+acc work.testbench

# 4. 加载波形配置文件
do wave.do

echo "--- Running simulation... ---"

# 5. 运行仿真直到 testbench 中的 $finish 被调用
run -all

echo "--- Simulation finished. ---"