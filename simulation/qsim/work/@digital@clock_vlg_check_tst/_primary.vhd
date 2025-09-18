library verilog;
use verilog.vl_types.all;
entity DigitalClock_vlg_check_tst is
    port(
        digit_sel       : in     vl_logic_vector(5 downto 0);
        seg_out         : in     vl_logic_vector(6 downto 0);
        sampler_rx      : in     vl_logic
    );
end DigitalClock_vlg_check_tst;
