library verilog;
use verilog.vl_types.all;
entity debouncer is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        \in\            : in     vl_logic;
        \out\           : out    vl_logic
    );
end debouncer;
