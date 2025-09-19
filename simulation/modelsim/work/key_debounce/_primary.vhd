library verilog;
use verilog.vl_types.all;
entity key_debounce is
    generic(
        SIMULATION      : integer := 1
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        key_in          : in     vl_logic;
        key_pulse       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIMULATION : constant is 1;
end key_debounce;
