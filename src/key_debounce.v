// src/key_debounce.v
// --- FINAL VERSION ---

module key_debounce (
    input wire clk,       // 50MHz Main Clock
    input wire rst,
    input wire key_in,     // Physical key input (active low)
    output reg key_pulse  // Single-cycle pulse output
);
    parameter SIMULATION = 0; // Set to 1 for simulation, 0 for hardware

    localparam DEBOUNCE_CNT_MAX = (SIMULATION == 1) ? 1_000 : 50_000; // ~20us for sim, ~1ms for hardware

    reg [1:0] key_state;
    always @(posedge clk or posedge rst) begin
        if (rst)    key_state <= 2'b11;
        else        key_state <= {key_state[0], key_in};
    end

    // Detect falling edge (1 -> 0 transition)
    wire key_negedge = (key_state == 2'b10);
    
    reg [15:0] debounce_counter;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            debounce_counter <= 16'd0;
            key_pulse <= 1'b0;
        end else begin
            key_pulse <= 1'b0; // Pulse is high for one cycle only
            
            if (key_negedge) begin
                debounce_counter <= 16'd0; // Reset counter on new key press
            end else if (debounce_counter == DEBOUNCE_CNT_MAX - 1) begin
                key_pulse <= 1'b1; // If time is up, generate pulse
                debounce_counter <= debounce_counter; // Stop counting
            end else if (key_state == 2'b00) begin // If key is held down
                debounce_counter <= debounce_counter + 1;
            end else begin // If key is released
                debounce_counter <= 16'd0;
            end
        end
    end
endmodule