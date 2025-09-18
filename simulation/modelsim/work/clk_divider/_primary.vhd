library verilog;
use verilog.vl_types.all;
entity clk_divider is
    generic(
        SIMULATION      : integer := 0
    );
    port(
        clk_in          : in     vl_logic;
        rst             : in     vl_logic;
        clk_1hz         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIMULATION : constant is 1;
end clk_divider;
