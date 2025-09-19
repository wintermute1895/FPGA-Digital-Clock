// testbench/full_functionality_tb.v
// --- A Comprehensive Testbench to Demonstrate ALL Clock Features ---

`timescale 1ns / 1ps

module full_functionality_tb;

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
    
    // -- Set Simulation Parameters for Child Modules --
    defparam uut.u_clk_divider.SIMULATION = 1;
    defparam uut.debounce_mode.SIMULATION = 1;
    defparam uut.debounce_inc.SIMULATION = 1;
    defparam uut.debounce_alarm_off.SIMULATION = 1;
    defparam uut.u_display_scanner.SIMULATION = 1;

    // -- Clock Generation --
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk; // 50MHz clock
    end

    // ================================================================
    //         Simple, Robust, Parameter-less Tasks
    // ================================================================
    task press_key_mode;
    begin
        @(posedge clk); key_mode = 1'b0; #21000; @(posedge clk); key_mode = 1'b1; @(posedge clk);
    end
    endtask

    task press_key_inc;
    begin
        @(posedge clk); key_inc = 1'b0; #21000; @(posedge clk); key_inc = 1'b1; @(posedge clk);
    end
    endtask
    
    task press_key_alarm_off;
    begin
        @(posedge clk); key_alarm_off = 1'b0; #21000; @(posedge clk); key_alarm_off = 1'b1; @(posedge clk);
    end
    endtask
    // ================================================================

    // --- Main Test Sequence ---
    initial begin
        $display("--- FULL FUNCTIONALITY TESTBENCH START ---");
        
        // --- STEP 1: SYSTEM RESET ---
        $display("\n[1. RESET] Initializing and resetting the clock...");
        key_mode = 1'b1; key_inc = 1'b1; key_alarm_off = 1'b1;
        rst = 1'b1; #200; rst = 1'b0;
        #50000; // Wait for system to stabilize
        $display("   >> Reset complete. Time should be 00:00:00. State should be S_NORMAL.");
        
        
        // --- STEP 2: ADJUST REAL TIME ---
        $display("\n[2. ADJUST TIME] Setting time to 23:58:00...");
        
        // Enter ADJ_H mode
        press_key_mode; #50000;
        $display("   >> Entered S_ADJ_H mode. Adjusting Hour to 23...");
        
        // Set hour to 23
        repeat (23) begin press_key_inc; #50000; end
        
        // Enter ADJ_M mode
        press_key_mode; #50000;
        $display("   >> Entered S_ADJ_M mode. Adjusting Minute to 58...");
        
        // Set minute to 58
        repeat (58) begin press_key_inc; #50000; end

        // Cycle through alarm modes back to NORMAL
        press_key_mode; #50000; // -> S_ALARM_H
        press_key_mode; #50000; // -> S_ALARM_M
        press_key_mode; #50000; // -> S_NORMAL
        $display("   >> Returned to S_NORMAL. Time is now set to 23:58:00.");
        

        // --- STEP 3: VERIFY TIME COUNT & CARRY-OVER ---
        $display("\n[3. VERIFY COUNTING] Letting time run for 125 seconds to observe carry-over...");
        // Wait for 125 simulated seconds. Each second is 1us in sim time (50 cycles * 20ns).
        // A large delay ensures we see the clock tick over from 23:59:59 to 00:00:00.
        #130_000_000; // Wait for 130 simulated seconds (130us)
        $display("   >> Time has advanced. Should be past midnight. Check waveform for 23:59:59 -> 00:00:00 transition.");

        
        // --- STEP 4: SET ALARM ---
        $display("\n[4. SET ALARM] Setting alarm time to 00:02:00...");
        
        // Enter ALARM_H mode
        press_key_mode; #50000; // -> S_ADJ_H
        press_key_mode; #50000; // -> S_ADJ_M
        press_key_mode; #50000; // -> S_ALARM_H
        $display("   >> Entered S_ALARM_H. Default alarm hour is 6. Setting to 0...");
        
        // Default alarm hour is 6. To get to 0, we need 24-6=18 presses.
        repeat(18) begin press_key_inc; #50000; end
        
        // Enter ALARM_M mode
        press_key_mode; #50000; // -> S_ALARM_M
        $display("   >> Entered S_ALARM_M. Setting alarm minute to 2...");
        
        // Set alarm minute to 2
        repeat(2) begin press_key_inc; #50000; end
        
        // Return to NORMAL mode
        press_key_mode; #50000;
        $display("   >> Returned to S_NORMAL. Alarm is now armed for 00:02:00.");


        // --- STEP 5: TRIGGER AND CANCEL ALARM ---
        $display("\n[5. TRIGGER ALARM] Waiting for real time to reach 00:02:00...");
        
        // We know the time is currently around 00:00:05. We need to wait about 115 more seconds.
        #120_000_000; // Wait for another 120 simulated seconds
        $display("   >> Real time is now 00:02:xx. The alarm should be beeping. Check waveform for 'beep' signal.");
        
        // Let the beep run for a bit
        #100_000; // 100us
        
        $display("   >> Now, pressing ALARM_OFF key to cancel the beep...");
        press_key_alarm_off; #50000;
        $display("   >> Alarm should now be silent. Check 'beep' signal is low.");
        

        // --- STEP 6: TEST HOURLY CHIME (整点报时) ---
        $display("\n[6. HOURLY CHIME] Setting time near the next hour (00:59:55) to test chime...");
        
        // Go to ADJ_M and set minute to 59
        press_key_mode; #50000; // S_ADJ_H
        press_key_mode; #50000; // S_ADJ_M
        // Current minute is ~2. 59-2 = 57 presses.
        repeat(57) begin press_key_inc; #50000; end
        
        // Return to normal
        press_key_mode; #50000; // S_ALARM_H
        press_key_mode; #50000; // S_ALARM_M
        press_key_mode; #50000; // S_NORMAL
        $display("   >> Time set to 00:59:xx. Waiting for the hour to change...");

        #10_000_000; // Wait 10 seconds
        $display("   >> Clock should have passed 01:00:00. A short beep for the hourly chime should have occurred.");
        

        $display("\n--- FULL FUNCTIONALITY TEST COMPLETE ---");
        $stop;
    end
endmodule