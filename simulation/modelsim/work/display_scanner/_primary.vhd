library verilog;
use verilog.vl_types.all;
entity display_scanner is
    generic(
        SIMULATION      : integer := 0;
        S_ADJ_H         : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        S_ADJ_M         : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        S_ALARM_H       : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        S_ALARM_M       : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        hour            : in     vl_logic_vector(4 downto 0);
        min             : in     vl_logic_vector(5 downto 0);
        sec             : in     vl_logic_vector(5 downto 0);
        display_mode    : in     vl_logic_vector(2 downto 0);
        num_to_decode   : out    vl_logic_vector(3 downto 0);
        digit_sel       : out    vl_logic_vector(5 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIMULATION : constant is 1;
    attribute mti_svvh_generic_type of S_ADJ_H : constant is 1;
    attribute mti_svvh_generic_type of S_ADJ_M : constant is 1;
    attribute mti_svvh_generic_type of S_ALARM_H : constant is 1;
    attribute mti_svvh_generic_type of S_ALARM_M : constant is 1;
end display_scanner;
