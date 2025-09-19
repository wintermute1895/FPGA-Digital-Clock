// testbench/manual_debug_tb.v
// --- FINAL, ROBUST, AND SIMPLIFIED TESTBENCH ---

`timescale 1ns / 1ps

module manual_debug_tb;

    // -- Testbench Internal Signals --
    reg clk;
    reg rst;
    reg key_mode;
    reg key_inc;
    reg key_alarm_off;

    // -- Instantiate the Unit Under Test (UUT) --
    DigitalClock uut (
        .clk(clk), 
        .rst(rst), 
        .key_mode(key_mode), 
        .key_inc(key_inc), 
        .key_alarm_off(key_alarm_off),
        .beep(), 
        .seg_out(), 
        .digit_sel()
    );
    
    // -- Set Simulation Parameters --
    defparam uut.u_clk_divider.SIMULATION = 1;
    defparam uut.debounce_mode.SIMULATION = 1;
    defparam uut.debounce_inc.SIMULATION = 1;
    defparam uut.debounce_alarm_off.SIMULATION = 1;
    defparam uut.u_display_scanner.SIMULATION = 1;

    // -- Clock Generation --
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // ================================================================
    //         【核心修正】: 使用简单、无参数的任务
    // ================================================================
    task press_key_mode;
    begin
        $display("[TASK] Pressing key_mode...");
        @(posedge clk);
        key_mode = 1'b0;
        #21000; // Hold for 21us
        @(posedge clk);
        key_mode = 1'b1;
        @(posedge clk);
        $display("[TASK] Released key_mode.");
    end
    endtask

    task press_key_inc;
    begin
        $display("[TASK] Pressing key_inc...");
        @(posedge clk);
        key_inc = 1'b0;
        #21000; // Hold for 21us
        @(posedge clk);
        key_inc = 1'b1;
        @(posedge clk);
        $display("[TASK] Released key_inc.");
    end
    endtask
    // ================================================================

    // --- MAIN TEST SEQUENCE ---
    initial begin
        $display("--- Starting Manual Step-by-Step Debug Session ---");

        // 1. Initialize and Reset
        key_mode      = 1'b1; // Default state: not pressed
        key_inc       = 1'b1;
        key_alarm_off = 1'b1;
        rst           = 1'b1;
        #200; 
        rst           = 1'b0;
        $display("[TIME: %t] Reset released.", $time);
        
        // --- TEST SCENARIO 1: Increment Hour ONCE ---
        $display("\n--- Testing Single Hour Increment ---");
        
        #50000; // 50us delay
        
        // 直接调用新的、明确的任务
        press_key_mode; 
        
        #50000; // 50us delay
        
        // 直接调用新的、明确的任务
        press_key_inc;
        
        #50000;
        
        $display("[TIME: %t] Check waveform. Hour should be 1.", $time);

        $display("\n--- Halting simulation. ---");
        #100000;
        $stop;
    end
endmodule