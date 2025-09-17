// src/time_counter.v
// --- FINAL VERSION ---

module time_counter (
    input   wire        clk_1hz,
    input   wire        rst,
    input   wire        time_count_en,
    input   wire        load_en,
    input   wire [4:0]  hour_in,
    input   wire [5:0]  min_in,
    output  reg [5:0]   sec,
    output  reg [5:0]   min,
    output  reg [4:0]   hour
);
    // Logic for seconds
    always @(posedge clk_1hz or posedge rst) begin
        if (rst)
            sec <= 6'd0;
        else if (load_en) // When adjusting time, seconds reset to 0
            sec <= 6'd0;
        else if (time_count_en) begin
            if (sec == 6'd59)
                sec <= 6'd0;
            else
                sec <= sec + 1;
        end
    end

    // Logic for minutes
    always @(posedge clk_1hz or posedge rst) begin
        if (rst)
            min <= 6'd0;
        else if (load_en) // Load new minute value
            min <= min_in;
        else if (time_count_en && sec == 6'd59) begin // Carry from seconds
            if (min == 6'd59)
                min <= 6'd0;
            else
                min <= min + 1;
        end
    end

    // Logic for hours
    always @(posedge clk_1hz or posedge rst) begin
        if (rst)
            hour <= 5'd0;
        else if (load_en) // Load new hour value
            hour <= hour_in;
        else if (time_count_en && sec == 6'd59 && min == 6'd59) begin // Carry from minutes
            if (hour == 5'd23)
                hour <= 5'd0;
            else
                hour <= hour + 1;
        end
    end
endmodule