// src/clk_divider.v
// --- FINAL VERSION ---

module clk_divider (
    input   wire    clk_in,
    input   wire    rst,
    output  reg     clk_1hz
);
    // Use a parameter to switch between simulation and hardware
    parameter SIMULATION = 0; // Set to 1 for simulation, 0 for hardware

    // Define counter maximum value based on the mode
    localparam CNT_MAX = (SIMULATION == 1) ? 50 : 50_000_000;

    reg [25:0] counter;

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 26'd0;
            clk_1hz <= 1'b0;
        end else begin
            if (counter == CNT_MAX - 1) begin
                counter <= 26'd0;
                clk_1hz <= 1'b0; // Pulse goes low at the end of the cycle
            end else if (counter == (CNT_MAX / 2) - 1) begin
                counter <= counter + 1;
                clk_1hz <= 1'b1; // Pulse goes high in the middle of the cycle
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule