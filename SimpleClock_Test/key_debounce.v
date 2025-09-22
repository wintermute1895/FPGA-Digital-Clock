// src/key_debounce.v (FINAL, UPGRADED VERSION)

module key_debounce (
    input  wire clk,
    input  wire rst,
    input  wire key_in,
    output reg  key_pulse,
    output wire key_level
);
    parameter SIMULATION = 0;

    localparam DEBOUNCE_CYCLES = (SIMULATION == 1) ? 1000 : (`CLOCK_FREQUENCY / 50); // ~20ms debounce time
    localparam CNT_WIDTH = $clog2(DEBOUNCE_CYCLES);

    reg [1:0] key_state_sync;
    reg [CNT_WIDTH-1:0] counter;
    reg key_state_q;

    // Step 1: Synchronize asynchronous input to the clock domain
    always @(posedge clk or negedge rst) begin
        if (!rst)
            key_state_sync <= 2'b11;
        else
            key_state_sync <= {key_state_sync[0], key_in};
    end

    // Step 2: Debounce Counter Logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            key_state_q <= 1'b1; // Assume released state is '1'
        end else begin
            if (key_state_sync[1] == key_state_q) begin
                // If input is stable, reset the counter
                counter <= 0;
            end else begin
                // If input has changed, start counting
                if (counter < DEBOUNCE_CYCLES - 1) begin
                    counter <= counter + 1;
                end else begin
                    // If counter is full, the new state is stable, update the state
                    key_state_q <= key_state_sync[1];
                end
            end
        end
    end

    // Step 3: Edge detection to generate a single-cycle pulse
    reg key_state_q_prev;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            key_state_q_prev <= 1'b1;
            key_pulse <= 1'b0;
        end else begin
            key_state_q_prev <= key_state_q;
            
            // Generate a pulse on the falling edge (1 -> 0) of the final debounced signal
            if (key_state_q_prev == 1'b1 && key_state_q == 1'b0)
                key_pulse <= 1'b1;
            else
                key_pulse <= 1'b0;
        end
    end

    // Assign the stable, continuous level to the output
    assign key_level = key_state_q;

endmodule