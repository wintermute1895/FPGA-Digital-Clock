library verilog;
use verilog.vl_types.all;
entity clock_controller is
    generic(
        S_NORMAL        : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        S_ADJ_H         : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        S_ADJ_M         : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        S_ALARM_H       : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        S_ALARM_M       : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        key_mode_pulse  : in     vl_logic;
        key_inc_pulse   : in     vl_logic;
        key_alarm_off_pulse: in     vl_logic;
        hour_in         : in     vl_logic_vector(4 downto 0);
        min_in          : in     vl_logic_vector(5 downto 0);
        sec_in          : in     vl_logic_vector(5 downto 0);
        time_count_en   : out    vl_logic;
        load_en         : out    vl_logic;
        hour_out        : out    vl_logic_vector(4 downto 0);
        min_out         : out    vl_logic_vector(5 downto 0);
        alarm_on_flag   : out    vl_logic;
        display_mode    : out    vl_logic_vector(2 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of S_NORMAL : constant is 1;
    attribute mti_svvh_generic_type of S_ADJ_H : constant is 1;
    attribute mti_svvh_generic_type of S_ADJ_M : constant is 1;
    attribute mti_svvh_generic_type of S_ALARM_H : constant is 1;
    attribute mti_svvh_generic_type of S_ALARM_M : constant is 1;
end clock_controller;
