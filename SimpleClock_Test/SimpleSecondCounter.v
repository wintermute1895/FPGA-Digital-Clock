// src/SimpleSecondCounter.v (CORRECTED WIRING)

module SimpleSecondCounter (
    input  wire        clk,        // 50MHz clock input
    input  wire        rst_in,     // Manual reset button (low-active)
    output wire [6:0]  seg_out,
    output wire [5:0]  digit_sel
);

    // --- Internal Wires ---
    wire rst_n;            // Debounced, low-active reset signal
    wire clk_1hz_en;       // 1Hz enable pulse from the clock divider
    wire [5:0] sec_count;  // The output from our 6-bit second counter
    wire [3:0] num_to_decode_wire; // 【关键】定义一根线，用于连接 scanner 和 decoder

    // --- Sub-modules ---

    // 1. Debounce the manual reset button.
    key_debounce debounce_rst (
        .clk(clk),
        .rst(1'b1),
        .key_in(rst_in),
        .key_pulse(),
        .key_level(rst_n)
    );

    // 2. Generate a 1Hz enable signal.
    clk_divider u_clk_divider (
        .clk_in(clk),
        .rst(rst_n),
        .clk_1hz_en(clk_1hz_en)
    );

    // 3. A simple 0-59 second counter.
    reg [5:0] sec_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sec_reg <= 6'd0;
        end else if (clk_1hz_en) begin
            if (sec_reg == 6'd59) begin
                sec_reg <= 6'd0;
            end else begin
                sec_reg <= sec_reg + 1'b1; // (修正了截断警告)
            end
        end
    end
    assign sec_count = sec_reg;
    
    // 4. Instantiate the display scanner.
    display_scanner u_display_scanner (
        .clk(clk),
        .rst(rst_n),
        .hour(5'd0),
        .min(6'd0),
        .sec(sec_count),
        .display_mode(3'd0),
        .num_to_decode(num_to_decode_wire), // 【关键修正】将内部线连接到输出端口
        .digit_sel(digit_sel)
    );
    
    // 5. Instantiate the display decoder.
    display_decoder u_display_decoder (
        .num_in(num_to_decode_wire),      // 【关键修正】将内部线连接到输入端口
        .seg_out(seg_out)
    );

endmodule