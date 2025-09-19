library verilog;
use verilog.vl_types.all;
entity buzzer_controller is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        alarm_on        : in     vl_logic;
        beep            : out    vl_logic
    );
end buzzer_controller;
