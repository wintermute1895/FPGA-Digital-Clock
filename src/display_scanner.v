// src/display_scanner.v
// --- FINAL VERSION ---

module display_scanner (
    input   wire        clk,
    input   wire        rst,
    input   wire [4:0]  hour,
    input   wire [5:0]  min,
    input   wire [5:0]  sec,
    input   wire [2:0]  display_mode, // Receives mode from controller
    output  reg  [3:0]  num_to_decode,
    output  reg  [5:0]  digit_sel
);
    parameter SIMULATION = 0;
    
    // State definitions (must match the controller)
    parameter S_ADJ_H     = 3'd1;
    parameter S_ADJ_M     = 3'd2;
    parameter S_ALARM_H   = 3'd3;
    parameter S_ALARM_M   = 3'd4;
    
    // Scan enable signal generation
    localparam SCAN_CNT_MAX = (SIMULATION == 1) ? 4 : 50_000; // ~100ns for sim, ~1ms for hardware
    reg [$clog2(SCAN_CNT_MAX)-1:0] scan_counter;
    wire scan_en = (scan_counter == SCAN_CNT_MAX - 1);

    always @(posedge clk or posedge rst) begin
        if (rst)
            scan_counter <= 0;
        else if (scan_en)
            scan_counter <= 0;
        else
            scan_counter <= scan_counter + 1;
    end
    
    // BCD conversion
    wire [3:0] hour1 = hour / 10; wire [3:0] hour0 = hour % 10;
    wire [3:0] min1  = min / 10;  wire [3:0] min0  = min % 10;
    wire [3:0] sec1  = sec / 10;  wire [3:0] sec0  = sec % 10;

    // Scan position counter
    reg [2:0] scan_pos;
    always @(posedge clk or posedge rst) begin
        if (rst)                scan_pos <= 3'd0;
        else if (scan_en)       scan_pos <= (scan_pos == 3'd5) ? 3'd0 : scan_pos + 1;
    end
    
    // Blinking logic
    reg [23:0] blink_counter;
    always @(posedge clk or posedge rst) begin
        if (rst)    blink_counter <= 0;
        else        blink_counter <= blink_counter + 1;
    end
    wire blink_off = blink_counter[23]; // ~2Hz blink rate

    // Core display logic
    always @(*) begin
        // Default assignment
        num_to_decode = 4'dx;
        digit_sel = 6'b111111; // Default off
        
        case(scan_pos)
            3'd0: begin num_to_decode = sec0;  digit_sel = 6'b111110; end
            3'd1: begin num_to_decode = sec1;  digit_sel = 6'b111101; end
            3'd2: begin num_to_decode = min0;  digit_sel = 6'b111011; end
            3'd3: begin num_to_decode = min1;  digit_sel = 6'b110111; end
            3'd4: begin num_to_decode = hour0; digit_sel = 6'b101111; end
            3'd5: begin num_to_decode = hour1; digit_sel = 6'b011111; end
        endcase
        
        // Blinking override
        if (blink_off) begin
            if ((display_mode == S_ADJ_H || display_mode == S_ALARM_H) && (scan_pos == 3'd4 || scan_pos == 3'd5))
                digit_sel = 6'b111111; // Turn off hour digits
            if ((display_mode == S_ADJ_M || display_mode == S_ALARM_M) && (scan_pos == 3'd2 || scan_pos == 3'd3))
                digit_sel = 6'b111111; // Turn off minute digits
        end
    end
endmodule