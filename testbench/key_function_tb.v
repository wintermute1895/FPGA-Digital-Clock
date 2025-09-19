// testbench/key_function_tb.v
// --- FINAL & ENHANCED VERSION (Logic Corrected) ---

`timescale 1ns / 1ps

module key_function_tb;

    // -- Testbench Internal Signals --
    reg clk;
    reg rst;
    reg key_mode;
    reg key_inc;
    reg key_alarm_off;

    // -- Wires for Probing and Monitoring --
    wire beep_probe;
    wire clk_1hz_en_probe;
    wire [2:0] state_probe = uut.u_controller.current_state;
    wire [4:0] hour_probe = uut.hour_from_counter;
    wire [5:0] min_probe  = uut.min_from_counter;
    wire [5:0] sec_probe  = uut.sec_from_counter;
    wire [4:0] alarm_h_probe = uut.u_controller.alarm_hour_reg;
    wire [5:0] alarm_m_probe = uut.u_controller.alarm_min_reg;

    // -- Instantiate the Unit Under Test (UUT) --
    DigitalClock uut (
        .clk(clk), 
        .rst(rst), 
        .key_mode(key_mode), 
        .key_inc(key_inc), 
        .key_alarm_off(key_alarm_off),
        .beep(beep_probe), 
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

    // -- Task for Simulating a Key Press --
    task press_key;
        inout reg key_to_press;
        begin
            @(posedge clk);
            key_to_press = 1'b0; // Key is pressed (active low)
            #21000;              // Hold for 21us (longer than 20us debounce time)
            key_to_press = 1'b1; // Key is released
            @(posedge clk);
            
            // 【核心修正】增加按键释放后的等待时间，确保消抖逻辑完全复位
            // 之前的 #1000 (1us) 太短，导致 repeat 循环过快，产生重复触发
            #30000; // Wait for 30us, safely longer than the debounce period
        end
    endtask
    
    // -- Main Test Sequence --
    initial begin
        $display("--- COMPREHENSIVE DIGITAL CLOCK TESTBENCH START ---");

        // 1. Initial Reset
        rst = 1'b1; 
        key_mode = 1'b1; key_inc = 1'b1; key_alarm_off = 1'b1;
        #100; 
        rst = 1'b0;
        $display("\n[TIME: %t] System Reset Released. Initial time should be 00:00:00.", $time);
        #1000;
        if (hour_probe == 0 && min_probe == 0 && sec_probe == 0) $display("[SUCCESS] Time correctly reset to 00:00:00.");
        else $display("[FAILURE] Time is %d:%d:%d after reset.", hour_probe, min_probe, sec_probe);

        // 2. Adjust Time to 23:58
        $display("\n[TIME: %t] Adjusting time to 23:58...", $time);
        press_key(key_mode); // -> S_ADJ_H
        repeat (23) press_key(key_inc); // Set Hour to 23
        
        press_key(key_mode); // -> S_ADJ_M
        repeat (58) press_key(key_inc); // Set Minute to 58
        
        press_key(key_mode); // -> S_ALARM_H
        press_key(key_mode); // -> S_ALARM_M
        press_key(key_mode); // -> S_NORMAL (Return to normal operation)
        
        if (hour_probe == 23 && min_probe == 58) $display("[SUCCESS] Time successfully set to 23:58.");
        else $display("[FAILURE] Time is %02d:%02d, expected 23:58.", hour_probe, min_probe);
        
        // 3. Test Time Flow and Carry-over
        $display("\n[TIME: %t] Waiting for time to roll over from 23:59:59 to 00:00:00...", $time);
        // Each 1Hz cycle takes 50 * 20ns = 1us in simulation time.
        // Wait for 125 seconds of simulated clock time (125 * (50*2) clk cycles = 12.5us)
        // Let's use wait for simplicity and robustness
        wait(clk_1hz_en_probe == 1); // Sync to a 1Hz edge
        repeat (125) @(posedge clk_1hz_en_probe);
        #1000; // Settle
        
        $display("[TIME: %t] Current time is %02d:%02d:%02d", $time, hour_probe, min_probe, sec_probe);
        if (hour_probe == 0 && min_probe >= 0 && min_probe <= 1) $display("[SUCCESS] Time correctly rolled over to 00:0x."); // Allow some slack due to sim time
        else $display("[FAILURE] Time did not roll over correctly. Current: %d:%d", hour_probe, min_probe);
        
        // 4. Set Alarm to 00:01
        $display("\n[TIME: %t] Setting alarm to 00:01...", $time);
        // Note: Time is already around 00:01, let's set alarm to 00:02
        press_key(key_mode); // -> S_ADJ_H
        press_key(key_mode); // -> S_ADJ_M
        press_key(key_mode); // -> S_ALARM_H
        // Alarm was 6:00 initially. Let's set it to 0. 6->23 needs 18 presses. 23->0 needs 1. Total 19.
        repeat (18) press_key(key_inc); 
        
        press_key(key_mode); // -> S_ALARM_M
        // Alarm min was 0. Set to 2.
        repeat (2) press_key(key_inc); 
        
        press_key(key_mode); // -> S_NORMAL
        
        if (alarm_h_probe == 0 && alarm_m_probe == 2) $display("[SUCCESS] Alarm time successfully set to 00:02.");
        else $display("[FAILURE] Alarm time is %d:%d, expected 00:02.", alarm_h_probe, alarm_m_probe);
        
        // 5. Wait for Alarm to Trigger
        $display("\n[TIME: %t] Waiting for alarm to trigger at 00:02:00...", $time);
        wait (beep_probe == 1'b1);
        $display("[TIME: %t] BEEP DETECTED! Current time is %02d:%02d:%02d.", $time, hour_probe, min_probe, sec_probe);
        if (hour_probe == 0 && min_probe == 2 && sec_probe == 0) $display("[SUCCESS] Alarm triggered at the correct time.");
        else $display("[FAILURE] Alarm triggered at the wrong time: %d:%d:%d", hour_probe, min_probe, sec_probe);
        
        // 6. Turn Off Alarm
        #20000; // Let the beep sound for a bit
        $display("\n[TIME: %t] Pressing alarm_off key...", $time);
        press_key(key_alarm_off);
        #1000;
        if (beep_probe == 1'b0) $display("[SUCCESS] Beep was successfully turned off.");
        else $display("[FAILURE] Beep is still on after pressing key_alarm_off.");

        $display("\n--- TESTBENCH FINISHED ---");
        $stop;
    end
endmodule