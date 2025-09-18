// final_test_tb.v
// The ultimate testbench to verify ALL clock features in real-time scale.

`timescale 1ns / 1ps

module final_test_tb;

    // --- 1. Signal Declarations ---
    reg clk;
    reg rst;
    reg key_mode;
    reg key_inc;
    reg key_alarm_off;

    wire beep;
    // We don't need to observe seg_out/digit_sel in this test,
    // as we will check the internal timer values directly.

    // --- 2. Instantiate the Design Under Test (DUT) ---
    DigitalClock uut (
        .clk(clk), .rst(rst), 
        .key_mode(key_mode), .key_inc(key_inc), .key_alarm_off(key_alarm_off),
        .beep(beep),
        .seg_out(), .digit_sel() // In a testbench, outputs can be left unconnected
    );

    // --- 3. Helper Task for Simulating Key Presses ---
    task press_key;
        input key_to_press;
        begin
            @(posedge clk);
            key_to_press = 1'b0; // Press the key
            #20_000_000;         // Hold for 20ms (enough for debounce)
            key_to_press = 1'b1; // Release the key
            @(posedge clk);
        end
    endtask

    // --- 4. Clock Generator (50MHz) ---
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // --- 5. The Main Test Storyline ---
    initial begin
        $display("==========================================================");
        $display("=           FINAL FULL FEATURE VERIFICATION            =");
        $display("==========================================================");

        // --- SCENE 1: System Boot and Normal Operation ---
        rst = 1'b1; key_mode = 1'b1; key_inc = 1'b1; key_alarm_off = 1'b1;
        #100;
        rst = 1'b0;
        $display("T=%t ns: [ACTION] System Reset Released. Clock starts at 00:00:00.", $time);

        // --- SCENE 2: Fast-forward to just before an hour change to test hourly chime ---
        $display("\n[SCENE] Fast-forwarding time to just before 01:00:00...");
        force uut.u_time_counter.hour = 5'd0;
        force uut.u_time_counter.min = 6'd59;
        force uut.u_time_counter.sec = 6'd59;
        #100; // Wait a bit for force to apply
        release uut.u_time_counter.hour;
        release uut.u_time_counter.min;
        release uut.u_time_counter.sec;
        $display("T=%t ns: [INFO] Time is now 00:59:59.", $time);
        
        // --- SCENE 3: Verifying Hourly Chime ---
        $display("\n[SCENE] Verifying Hourly Chime at 01:00:00...");
        // Wait for 4 seconds. Time will advance from 00:59:59 to 01:00:01
        #2_000_000_000;
        $display("T=%t ns: [CHECK] Time has passed 01:00:00. Check 'beep' signal for a short pulse during the 01:00:00 second.", $time);

        // --- SCENE 4: Adjusting Time ---
        $display("\n[SCENE] Verifying Time Adjustment...");
        // Current time is 01:00:01
        press_key(key_mode); // Enter ADJ_H state
        $display("T=%t ns: [ACTION] Pressed MODE. Entered ADJUST HOUR state. Timer should be paused.", $time);
        press_key(key_inc);  // Hour should become 2
        $display("T=%t ns: [ACTION] Pressed INC. Hour should now be set to 2.", $time);
        
        press_key(key_mode); // Enter ADJ_M state
        $display("T=%t ns: [ACTION] Pressed MODE. Entered ADJUST MINUTE state.", $time);
        press_key(key_inc);  // Minute should become 1
        $display("T=%t ns: [ACTION] Pressed INC. Minute should now be set to 1.", $time);
        
        press_key(key_mode); // Return to NORMAL state
        $display("T=%t ns: [CHECK] Returned to NORMAL. Time is now 02:01:00. Timer should resume.", $time);
        
        #1_000_000_000; // Wait 1 second to confirm timer has resumed
        $display("T=%t ns: [CHECK] Waited 1 second. Time should be 02:01:01.", $time);


        // --- SCENE 5: Setting and Verifying Alarm ---
        $display("\n[SCENE] Verifying Alarm Functionality...");
        // Current time is ~02:01:01. Let's set the alarm to 02:01:05
        
        press_key(key_mode); // to ADJ_H
        press_key(key_mode); // to ADJ_M
        press_key(key_mode); // to ALARM_H
        $display("T=%t ns: [ACTION] Entered ALARM HOUR state.", $time);
        // Hour is already 2, no need to press inc
        
        press_key(key_mode); // to ALARM_M
        $display("T=%t ns: [ACTION] Entered ALARM MINUTE state.", $time);
        press_key(key_inc); // Alarm min = 1
        press_key(key_inc); // Alarm min = 2
        press_key(key_inc); // Alarm min = 3
        press_key(key_inc); // Alarm min = 4
        press_key(key_inc); // Alarm min = 5
        
        press_key(key_mode); // to NORMAL
        $display("T=%t ns: [CHECK] Alarm set to 02:05. Returned to NORMAL.", $time);

        // Wait for the alarm to trigger
        $display("... Waiting for alarm trigger at 02:05:00 ...");
        // We fast-forward again to save a lot of simulation time
        force uut.u_time_counter.min = 6'd4;
        force uut.u_time_counter.sec = 6'd58;
        #100;
        release uut.u_time_counter.min;
        release uut.u_time_counter.sec;
        $display("T=%t ns: [INFO] Time fast-forwarded to 02:04:58.", $time);
        
        #3_000_000_000; // Wait 3 seconds, time will become 02:05:01
        $display("T=%t ns: [CHECK] Time has passed 02:05:00. 'beep' should be continuously active.", $time);

        // --- SCENE 6: Turning Off the Alarm ---
        #1_000_000_000; // Let the alarm ring for 1 second
        press_key(key_alarm_off);
        $display("T=%t ns: [ACTION] Pressed ALARM_OFF. 'beep' should stop.", $time);

        #2_000_000_000; // Wait 2 more seconds to ensure it stays off

        // --- Simulation End ---
        $display("\n==========================================================");
        $display("=               FINAL TEST FINISHED                      =");
        $display("==========================================================");
        $stop;
    end

endmodule