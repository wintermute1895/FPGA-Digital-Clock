library verilog;
use verilog.vl_types.all;
entity display_decoder is
    port(
        num_in          : in     vl_logic_vector(3 downto 0);
        seg_out         : out    vl_logic_vector(6 downto 0)
    );
end display_decoder;
