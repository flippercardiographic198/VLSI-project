module top;
reg [2:0]oc;
reg [3:0]a;
reg[3:0]b;
wire [3:0]f;
integer index;
alu al(.OC(oc),.A(a),.B(b),.F(f));

reg clk,rst_n,cl,ld,inc,dec,sr,ir,sl,il;
reg [3:0]in;
wire[3:0]out;

register regi(.clk(clk), .rst_n(rst_n), .cl(cl), .ld(ld), .in(in), .inc(inc), .dec(dec), .sr(sr), .ir(ir), .sl(sl), .il(il), .out(out));
initial begin
    for(index=0;index<2048;index=index+1)begin
        {oc,a,b}=index;
        #5;
    end
    #10 $stop;
    rst_n=1'b0;clk=1'b1;cl=1'b0;ld=1'b0;inc=1'b0;dec=1'b0;sr=1'b0;ir=1'b0;sl=1'b0;il=1'b0;in=4'b0000;
    #2 rst_n=1'b1;
    repeat(1000)begin
        cl={$random}%2;
        ld={$random}%2;
        inc={$random}%2;
        dec={$random}%2;
        sr={$random}%2;
        ir={$random}%2;
        sl={$random}%2;
        il={$random}%2;
        in={$random}%16;
        #10;
    end
    #10 $finish;
    
end
initial begin
    $monitor("%b %b %b %b",oc,a,b,f);
end
always@(out)begin
    $strobe("Vreme=%4d cl=%b ld=%b inc=%b dec=%b sr=%b ir=%b sl=%b il=%b in=%4b out=%4b", $time ,cl,ld,inc,dec,sr,ir,sl,il,in,out);
end
always #5 clk=~clk;
endmodule