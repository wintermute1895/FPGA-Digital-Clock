// src/key_debounce.v (Final Correct Version)
module key_debounce (
    input wire clk_100hz,      // Correct port name
    input wire rst,
    input wire key_in,
    output reg key_pulse
);
    parameter DEBOUNCE_CYCLES = 5; 

    reg [2:0] key_sync_reg;
    reg [$clog2(DEBOUNCE_CYCLES)-1:0] debounce_cnt;
    reg key_stable;
    reg prev_key_stable;

    always @(posedge clk_100hz) begin
        if (rst) key_sync_reg <= 3'b111;
        else     key_sync_reg <= {key_sync_reg[1:0], key_in};
    end
    
    wire key_filtered = key_sync_reg[2];

    always @(posedge clk_100hz) begin
        if (rst) begin
            key_stable <= 1'b1;
            debounce_cnt <= 'd0;
        end else begin
            if (key_filtered != key_stable) begin
                if (debounce_cnt == DEBOUNCE_CYCLES - 1) begin
                    key_stable <= key_filtered;
                    debounce_cnt <= 'd0;
                end else begin
                    debounce_cnt <= debounce_cnt + 1'b1;
                end
            end else begin
                debounce_cnt <= 'd0;
            end
        end
    end

    always @(posedge clk_100hz) begin
        if (rst) begin
            prev_key_stable <= 1'b1;
            key_pulse <= 1'b0;
        end else begin
            prev_key_stable <= key_stable;
            if (prev_key_stable == 1'b1 && key_stable == 1'b0) begin
                key_pulse <= 1'b1;
            end else begin
                key_pulse <= 1'b0;
            end
        end
    end
endmodule