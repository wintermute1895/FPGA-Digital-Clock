// src/display_scanner.v (TIMING OPTIMIZED VERSION)

module display_scanner (
    input   wire        clk,
    input   wire        rst,
    input   wire [4:0]  hour,
    input   wire [5:0]  min,
    input   wire [5:0]  sec,
    input   wire [2:0]  display_mode,
    output  reg  [3:0]  num_to_decode,
    output  reg  [5:0]  digit_sel
);
    parameter SIMULATION = 0;
    
    // State definitions for blinking logic (matching controller)
    parameter S_ADJ_H     = 3'd1;
    parameter S_ADJ_M     = 3'd2;
    parameter S_ALARM_H   = 3'd3;
    parameter S_ALARM_M   = 3'd4;
    
    // Scan enable signal generation (approx. 1ms refresh for 6 digits -> ~166Hz per digit)
    localparam SCAN_CNT_MAX = (SIMULATION == 1) ? 4 : 50_000;
    reg [$clog2(SCAN_CNT_MAX)-1:0] scan_counter;
    wire scan_en = (scan_counter == SCAN_CNT_MAX - 1);

    always @(posedge clk or negedge rst) begin
        if (!rst) scan_counter <= 0;
        else if (scan_en) scan_counter <= 0;
        else scan_counter <= scan_counter + 1;
    end
    
    // BCD conversion logic (Timing-Optimized, using subtraction)
    reg [3:0] hour1_r, hour0_r;
    reg [3:0] min1_r, min0_r;
    reg [3:0] sec1_r, sec0_r;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            hour1_r <= 0; hour0_r <= 0;
            min1_r <= 0; min0_r <= 0;
            sec1_r <= 0; sec0_r <= 0;
        end else begin
            // BCD conversion for seconds (max value 59)
            if (sec >= 50) begin sec1_r <= 5; sec0_r <= sec - 50; end
            else if (sec >= 40) begin sec1_r <= 4; sec0_r <= sec - 40; end
            else if (sec >= 30) begin sec1_r <= 3; sec0_r <= sec - 30; end
            else if (sec >= 20) begin sec1_r <= 2; sec0_r <= sec - 20; end
            else if (sec >= 10) begin sec1_r <= 1; sec0_r <= sec - 10; end
            else begin sec1_r <= 0; sec0_r <= sec; end
            
            // BCD conversion for minutes (max value 59)
            if (min >= 50) begin min1_r <= 5; min0_r <= min - 50; end
            else if (min >= 40) begin min1_r <= 4; min0_r <= min - 40; end
            else if (min >= 30) begin min1_r <= 3; min0_r <= min - 30; end
            else if (min >= 20) begin min1_r <= 2; min0_r <= min - 20; end
            else if (min >= 10) begin min1_r <= 1; min0_r <= min - 10; end
            else begin min1_r <= 0; min0_r <= min; end

            // BCD conversion for hours (max value 23)
            if (hour >= 20) begin hour1_r <= 2; hour0_r <= hour - 20; end
            else if (hour >= 10) begin hour1_r <= 1; hour0_r <= hour - 10; end
            else begin hour1_r <= 0; hour0_r <= hour; end
        end
    end

    // Scan position counter
    reg [2:0] scan_pos;
    always @(posedge clk or negedge rst) begin
        if (!rst) scan_pos <= 3'd0;
        else if (scan_en) scan_pos <= (scan_pos == 3'd5) ? 3'd0 : scan_pos + 1;
    end
    
    // Blinking logic (approx. 2Hz blink rate @ 50MHz)
    reg [23:0] blink_counter;
    always @(posedge clk or negedge rst) begin
        if (!rst) blink_counter <= 0;
        else blink_counter <= blink_counter + 1;
    end
    wire blink_off = blink_counter[23];

    // Core display logic (combinational)
    always @(*) begin
        // Default assignments to prevent latches
        num_to_decode = 4'dx;
        digit_sel = 6'b111111; // Default: all digits off
        
        case(scan_pos)
            3'd0: begin num_to_decode = sec0_r;  digit_sel = 6'b111110; end // Rightmost digit
            3'd1: begin num_to_decode = sec1_r;  digit_sel = 6'b111101; end
            3'd2: begin num_to_decode = min0_r;  digit_sel = 6'b111011; end
            3'd3: begin num_to_decode = min1_r;  digit_sel = 6'b110111; end
            3'd4: begin num_to_decode = hour0_r; digit_sel = 6'b101111; end
            3'd5: begin num_to_decode = hour1_r; digit_sel = 6'b011111; end // Leftmost digit
            default: begin num_to_decode = 4'hF; digit_sel = 6'b111111; end
        endcase
        
        // Blinking override logic
        if (blink_off) begin
            if ((display_mode == S_ADJ_H || display_mode == S_ALARM_H) && (scan_pos == 3'd4 || scan_pos == 3'd5))
                digit_sel = 6'b111111; // Turn off hour digits
            if ((display_mode == S_ADJ_M || display_mode == S_ALARM_M) && (scan_pos == 3'd2 || scan_pos == 3'd3))
                digit_sel = 6'b111111; // Turn off minute digits
        end
    end
endmodule