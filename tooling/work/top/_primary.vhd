library verilog;
use verilog.vl_types.all;
entity top is
    generic(
        DIVISOR         : integer := 50000000;
        FILE_NAME       : string  := "mem_init.mif";
        DATA_WIDTH      : integer := 16;
        ADDR_WIDTH      : integer := 6
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        btn             : in     vl_logic_vector(2 downto 0);
        sw              : in     vl_logic_vector(8 downto 0);
        led             : out    vl_logic_vector(9 downto 0);
        hex             : out    vl_logic_vector(27 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DIVISOR : constant is 1;
    attribute mti_svvh_generic_type of FILE_NAME : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
end top;
