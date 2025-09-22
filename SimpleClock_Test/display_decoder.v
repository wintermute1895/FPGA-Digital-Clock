// src/display_decoder.v (Corrected for Common Anode Displays)

module display_decoder (
    input   wire [3:0]  num_in,     // Input number (0-9)
    output  reg  [6:0]  seg_out     // 7-segment output (g,f,e,d,c,b,a)
);

    // This is a pure combinational circuit.
    always @(*) begin
        case(num_in)
            // Common Cathode codes are bitwise inverted ('~') for Common Anode.
            // 0 = ON, 1 = OFF.
            4'd0: seg_out = ~7'b0111111; // Displays "0"
            4'd1: seg_out = ~7'b0000110; // Displays "1"
            4'd2: seg_out = ~7'b1011011; // Displays "2"
            4'd3: seg_out = ~7'b1001111; // Displays "3"
            4'd4: seg_out = ~7'b1100110; // Displays "4"
            4'd5: seg_out = ~7'b1101101; // Displays "5"
            4'd6: seg_out = ~7'b1111101; // Displays "6"
            4'd7: seg_out = ~7'b0000111; // Displays "7"
            4'd8: seg_out = ~7'b1111111; // Displays "8"
            4'd9: seg_out = ~7'b1101111; // Displays "9"
            default: seg_out = ~7'b0000000; // All segments off (outputs all 1s)
        endcase
    end

endmodule