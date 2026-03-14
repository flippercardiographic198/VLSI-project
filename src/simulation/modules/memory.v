module memory(clk,we,addr,data,out);
input clk,we;
input [5:0]addr;
input [7:0]data;
output [7:0]out;
reg [7:0]mem[0:64];
reg [7:0]output_reg;
assign out=output_reg;
integer i;
initial begin
    for (i=0;i<64;i=i+1)begin
        mem[i]={8{1'b0}};
    end
end
always @(posedge clk)
begin
    if(we)begin
        mem[addr]=data;
    end
    else begin
        output_reg=mem[addr];
    end
end

endmodule