module top_reg;
    reg clk,we;
    reg [5:0]addr;
    reg[15:0]data;
    wire[15:0]out;
    integer i;
    memory mem1(.clk(clk),.we(we),.addr(addr),.data(data[7:0]),.out(out[7:0]));
    memory mem2(.clk(clk),.we(we),.addr(addr),.data(data[15:8]),.out(out[15:8]));
initial begin
    #7;
    clk=0;
    we=1;
    addr={6{1'b0}};
    data={16{1'b0}};
    for(i=0;i<64;i=i+1)begin
        data={$random}%(256*256);
        addr=i;
        #10;
    end
    we=0;
    #10;
    for(i=0;i<64;i=i+1)
    begin
        addr=i;
        #10;
    end
    #10;
    $finish;
end

always #5 clk=~clk;

always@(out)begin
    $strobe("Vreme=%4d addr=%6b out=%16b", $time,addr ,out);
end
endmodule