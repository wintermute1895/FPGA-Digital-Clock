library verilog;
use verilog.vl_types.all;
entity time_counter is
    port(
        clk_1hz         : in     vl_logic;
        rst             : in     vl_logic;
        time_count_en   : in     vl_logic;
        load_en         : in     vl_logic;
        hour_in         : in     vl_logic_vector(4 downto 0);
        min_in          : in     vl_logic_vector(5 downto 0);
        sec             : out    vl_logic_vector(5 downto 0);
        min             : out    vl_logic_vector(5 downto 0);
        hour            : out    vl_logic_vector(4 downto 0)
    );
end time_counter;
