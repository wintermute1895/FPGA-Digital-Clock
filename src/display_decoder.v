// display_decoder.v
// 功能：将一个4位的BCD码数字（0-9）翻译成七段数码管的段选信号
// 假设开发板上的数码管是“共阴极”类型，即高电平（1）点亮LED段

module display_decoder (
    input   wire [3:0]  num_in,     // 输入的数字 (0-9)
    output  reg  [6:0]  seg_out     // 输出的七段码 (对应 g,f,e,d,c,b,a)
);

    // 这是一个纯组合逻辑电路，所以使用 always @(*)
    // 意味着只要输入 num_in 发生任何变化，就立刻重新计算输出
    always @(*) begin
        case(num_in)
            4'd0: seg_out = 7'b0111111; // 显示 "0"
            4'd1: seg_out = 7'b0000110; // 显示 "1"
            4'd2: seg_out = 7'b1011011; // 显示 "2"
            4'd3: seg_out = 7'b1001111; // 显示 "3"
            4'd4: seg_out = 7'b1100110; // 显示 "4"
            4'd5: seg_out = 7'b1101101; // 显示 "5"
            4'd6: seg_out = 7'b1111101; // 显示 "6"
            4'd7: seg_out = 7'b0000111; // 显示 "7"
            4'd8: seg_out = 7'b1111111; // 显示 "8"
            4'd9: seg_out = 7'b1101111; // 显示 "9"
            default: seg_out = 7'b0000000; // 如果输入的不是0-9，则全灭
        endcase
    end

endmodule