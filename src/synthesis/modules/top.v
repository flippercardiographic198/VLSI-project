module top #(parameter DIVISOR=50_000_000,
parameter FILE_NAME="mem_init.mif",
parameter DATA_WIDTH=16,
parameter ADDR_WIDTH=6)(
    input clk,
    input rst_n,
    input [1:0]kbd,
    input [2:0]btn,
    input [8:0]sw,
    output [13:0]mnt,
    output [9:0]led,
    output [27:0]hex
);
    wire clk_slow;

    clk_div #(.DIVISOR(DIVISOR)) clk_divisor(.clk(clk),.rst_n(rst_n),.out(clk_slow));
   
    wire we_wire;
    wire [DATA_WIDTH-1:0]data_wire;
    wire [ADDR_WIDTH-1:0]addr_wire;
    wire [DATA_WIDTH-1:0]mem_out_wire;
    wire [15:0]ps2_code_wire;
    wire[23:0]vga_code_wire;
    wire status_wire;
    wire control_wire;

    memory#(.FILE_NAME(FILE_NAME),.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) 
        mem_inst(
            .clk(clk_slow),
            .we(we_wire),
            .data(data_wire),
            .addr(addr_wire),
            .out(mem_out_wire)
            );

    ps2 ps2_inst(.clk(clk),
            .rst_n(rst_n),
            .ps2_clk(kbd[0]),
            .ps2_data(kbd[1]),
            .code(ps2_code_wire),
            .ps2_cln(ps2_clean_wire));

    scan_codes scan_codes_inst(.clk(clk_slow),
            .rst_n(rst_n),
            .code(ps2_code_wire),
            .status(status_wire),
            .control(control_wire),
            .num(in[3:0])
            );

    color_codes color_codes_inst(.num(cpu_out_wire[5:0]),
            .code(vga_code_wire)
            );

    vga vga_inst(.clk(clk),
            .rst_n(rst_n),
            .code(vga_code_wire),
            .hsync(mnt[13]),
            .vsync(mnt[12]),
            .red(mnt[11:8]),
            .green(mnt[7:4]),
            .blue(mnt[3:0])
            );

    wire [DATA_WIDTH-1:0]in;
    wire [ADDR_WIDTH-1:0]pc_wire;
    wire [ADDR_WIDTH-1:0]sp_wire;
    wire [DATA_WIDTH-1:0]cpu_out_wire;

    cpu#(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
        cpu_inst(
            .clk(clk_slow),
            .rst_n(rst_n),
            .mem(mem_out_wire),
            .in({12'h000,in[3:0]}),
            .we(we_wire),
            .control(control_wire),
            .addr(addr_wire),
            .data(data_wire),
            .status(status_wire),
            .out(cpu_out_wire),
            .pc(pc_wire),
            .sp(sp_wire)
            );

   assign led[5:0]={status_wire,cpu_out_wire[4:0]};

    wire ps2_clean_wire;
    wire [3:0]ones_pc;
    wire [3:0]tens_pc;
    wire [3:0]ones_sp;
    wire [3:0]tens_sp;
    bcd bcd_inst_pc(.in(pc_wire),.ones(ones_pc),.tens(tens_pc));
    bcd bcd_isnt_sp(.in(sp_wire),.ones(ones_sp),.tens(tens_sp));

    ssd ssd_pc_ones(.in(tens_pc),.out(hex[6:0]));
    ssd ssd_pc_tens(.in(ones_pc),.out(hex[13:7]));
    ssd ssd_sp_ones(.in(tens_sp),.out(hex[20:14]));
    ssd ssd_sp_tens(.in(ones_sp),.out(hex[27:21]));
        
endmodule
