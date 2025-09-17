// display_scanner.v (Final Dual-Mode Version)

module display_scanner (
    input   wire        clk,
    input   wire        rst,
    input   wire [4:0]  hour,
    input   wire [5:0]  min,
    input   wire [5:0]  sec,

    output  reg  [3:0]  num_to_decode,
    output  reg  [5:0]  digit_sel
);
    
    // 添加一个参数来区分仿真和硬件
    parameter SIMULATION = 1; // 1 = 仿真模式, 0 = 硬件模式

    reg [15:0] scan_counter;
    wire scan_en;

    // 使用 generate 语句来根据参数生成不同的电路
    generate
        if (SIMULATION == 1) begin
            // -- 仿真模式下的扫描使能逻辑 (非常快) --
            always @(posedge clk or posedge rst) begin
                if (rst)
                    scan_counter <= 16'd0;
                else if (scan_counter == 16'd31) // 计数到31 (周期640ns)
                    scan_counter <= 16'd0;
                else
                    scan_counter <= scan_counter + 1;
            end
            assign scan_en = (scan_counter == 16'd31);
        end else begin
            // -- 硬件模式下的扫描使能逻辑 (1kHz) --
            always @(posedge clk or posedge rst) begin
                if (rst)
                    scan_counter <= 16'd0;
                else if (scan_counter == 16'd49999) // 计数到49999
                    scan_counter <= 16'd0;
                else
                    scan_counter <= scan_counter + 1;
            end
            assign scan_en = (scan_counter == 16'd49999);
        end
    endgenerate
    
    // ... 后面的 BCD 码转换, scan_pos, 和 case 语句完全不变 ...
    wire [3:0] hour1 = hour / 10;
    wire [3:0] hour0 = hour % 10;
    wire [3:0] min1  = min / 10;
    wire [3:0] min0  = min % 10;
    wire [3:0] sec1  = sec / 10;
    wire [3:0] sec0  = sec % 10;

    reg [2:0] scan_pos;
    always @(posedge clk or posedge rst) begin
        if (rst)
            scan_pos <= 3'd0;
        else if (scan_en)
            scan_pos <= scan_pos + 1;
    end

    always @(*) begin
        case(scan_pos)
            3'd0: begin num_to_decode = sec0;  digit_sel = 6'b111110; end
            3'd1: begin num_to_decode = sec1;  digit_sel = 6'b111101; end
            3'd2: begin num_to_decode = min0;  digit_sel = 6'b111011; end
            3'd3: begin num_to_decode = min1;  digit_sel = 6'b110111; end
            3'd4: begin num_to_decode = hour0; digit_sel = 6'b101111; end
            3'd5: begin num_to_decode = hour1; digit_sel = 6'b011111; end
            default: begin num_to_decode = 4'dx; digit_sel = 6'b111111; end
        endcase
    end
endmodule