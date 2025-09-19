library verilog;
use verilog.vl_types.all;
entity DigitalClock_vlg_sample_tst is
    port(
        clk             : in     vl_logic;
        key_alarm_off   : in     vl_logic;
        key_inc         : in     vl_logic;
        key_mode        : in     vl_logic;
        rst             : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end DigitalClock_vlg_sample_tst;
