library verilog;
use verilog.vl_types.all;
entity m21_dataflow is
    port(
        I0              : in     vl_logic;
        I1              : in     vl_logic;
        S0              : in     vl_logic;
        Y               : out    vl_logic
    );
end m21_dataflow;
