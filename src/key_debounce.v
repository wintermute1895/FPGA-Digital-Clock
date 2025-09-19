// key_debounce.v (FINAL, ABSOLUTELY CORRECTED LOGIC)

module key_debounce (
    input wire clk,
    input wire rst,
    input wire key_in,
    output reg key_pulse
);
    parameter SIMULATION = 1;

    localparam DEBOUNCE_CYCLES = (SIMULATION == 1) ? 1000 : 1000000;
    localparam CNT_WIDTH = $clog2(DEBOUNCE_CYCLES);

    reg [1:0] key_state_sync;
    reg [CNT_WIDTH-1:0] counter;
    reg key_state_q;

    // Step 1: Synchronize input to clock domain (2-stage synchronizer)
    always @(posedge clk or posedge rst) begin
        if (rst)
            key_state_sync <= 2'b11;
        else
            key_state_sync <= {key_state_sync[0], key_in};
    end

    // Step 2: Debounce Counter Logic (Corrected)
    // This logic ensures the counter runs ONLY when the input is stable.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            key_state_q <= 1'b1;
        end else begin
            if (key_state_sync[1] == key_state_q) begin
                // If input is stable, reset the counter
                counter <= 0;
            end else begin
                // If input has changed, start counting
                if (counter < DEBOUNCE_CYCLES - 1) begin
                    counter <= counter + 1;
                end else begin
                    // If counter is full, the new state is stable
                    key_state_q <= key_state_sync[1];
                end
            end
        end
    end

    // Step 3: Edge detection to generate the pulse
    reg key_state_q_prev;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            key_state_q_prev <= 1'b1;
            key_pulse <= 1'b0;
        end else begin
            key_state_q_prev <= key_state_q;
            
            // Generate a pulse on the falling edge (1 -> 0) of the FINAL debounced signal
            if (key_state_q_prev == 1'b1 && key_state_q == 1'b0)
                key_pulse <= 1'b1;
            else
                key_pulse <= 1'b0;
        end
    end

endmodule