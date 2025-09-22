// src/power_on_reset.v (Corrected Final Version)

module power_on_reset (
    input  wire clk,
    output wire rst
);

    // 定义复位脉冲需要持续的时钟周期数
    // 50,000 周期 @ 50MHz = 1ms
    localparam RST_CYCLES = 24'd50000; 

    reg rst_out_reg;
    reg [23:0] counter_reg;

    // FPGA 上电时，所有 reg 默认为 0
    always @(posedge clk) begin
        // 当计数器还未计满时，保持复位信号为高
        if (counter_reg < RST_CYCLES) begin
            counter_reg <= counter_reg + 1;
            rst_out_reg <= 1'b1; // 保持复位有效 (高电平)
        end else begin
            // 计数完成后，释放复位信号
            rst_out_reg <= 1'b0; // 永久拉低复位信号
        end
    end

    // 将寄存器的值赋给输出端口
    assign rst = rst_out_reg;

endmodule