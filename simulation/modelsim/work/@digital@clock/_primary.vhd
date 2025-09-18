library verilog;
use verilog.vl_types.all;
entity DigitalClock is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        key_mode        : in     vl_logic;
        key_inc         : in     vl_logic;
        key_alarm_off   : in     vl_logic;
        beep            : out    vl_logic;
        seg_out         : out    vl_logic_vector(6 downto 0);
        digit_sel       : out    vl_logic_vector(5 downto 0)
    );
end DigitalClock;
