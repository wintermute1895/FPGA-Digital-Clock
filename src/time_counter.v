// time_counter.v (Final, Decoupled Logic Version)

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

    // 1. 秒的逻辑：只管自己计数
    always @(posedge clk_1hz or posedge rst) begin
        if (rst)
            sec <= 6'd0;
        else if (load_en) // 调时的时候，秒归零
            sec <= 6'd0;
        else if (time_count_en) begin
            if (sec == 6'd59)
                sec <= 6'd0;
            else
                sec <= sec + 1;
        end
    end

    // 2. 分钟的逻辑：只关心秒是否即将进位
    always @(posedge clk_1hz or posedge rst) begin
        if (rst)
            min <= 6'd0;
        else if (load_en) // 加载新分钟
            min <= min_in;
        else if (time_count_en && sec == 6'd59) begin // 当计时使能，且秒即将进位时
            if (min == 6'd59)
                min <= 6'd0;
            else
                min <= min + 1;
        end
    end

    // 3. 小时的逻辑：只关心分和秒是否都即将进位
    always @(posedge clk_1hz or posedge rst) begin
        if (rst)
            hour <= 5'd0;
        else if (load_en) // 加载新小时
            hour <= hour_in;
        else if (time_count_en && sec == 6'd59 && min == 6'd59) begin // 当计时使能，且分秒都即将进位时
            if (hour == 5'd23)
                hour <= 5'd0;
            else
                hour <= hour + 1;
        end
    end

endmodule