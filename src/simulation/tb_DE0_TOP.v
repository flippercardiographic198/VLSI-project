`timescale 1ns / 1ps

module tb_DE0_TOP();

    reg clk_50;
    reg rst_n;
    
    reg [9:0] SW;
    reg [2:0] BUTTON;
    
    wire [9:0] LEDG;
    wire [6:0] HEX0_D, HEX1_D, HEX2_D, HEX3_D;
    wire HEX0_DP, HEX1_DP, HEX2_DP, HEX3_DP;
    wire [8:0]sw;

    initial clk_50 = 0;
    always #10 clk_50 = ~clk_50;
    assign sw=SW;
    initial begin
        rst_n = 0;
        SW = 10'b0;
        BUTTON = 3'b0;
        SW={9'b1};
        #200;        
        rst_n = 1;    
        SW=9'd8;
        SW[9]=1;
        #1200;
        SW=9'd9;
        #5500;
        SW=9'd3;

    end

    top #(.DIVISOR(2),.FILE_NAME("mem_init.hex")) uut (
    .clk(clk_50),
    .rst_n(rst_n),
    .btn(3'b000),
    .sw(sw),
    .led(),
    .hex()
    );

    initial begin
         $display("Starting simulation with memory file: %s", "mem_init.mif");

    end
  
    initial begin
        #20000; 
        $display("Simulation finished.");
        $finish;
    end

    always @(posedge uut.clk_slow) begin
    $display("Time %0t | PC=%0d ADDR=%h DATA=%h MEM=%h WE=%b CPU_OUT=%0h LED=%d op1=%h op2=%h op3=%h ir_low=%h",
             $time,
             uut.cpu_inst.pc_wire,
             uut.addr_wire,
             uut.data_wire,
             uut.mem_out_wire,
             uut.cpu_inst.we_reg,
             uut.cpu_out_wire,
             uut.cpu_out_wire[4:0],
             uut.cpu_inst.operand_1_full,
             uut.cpu_inst.operand_2_full,
             uut.cpu_inst.operand_3_full,
             uut.cpu_inst.ir_low_wire);
end

endmodule
