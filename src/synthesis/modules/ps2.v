module ps2(
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output reg [15:0] code,
    output ps2_cln
);

assign ps2_cln=ps2_clk_clean;
reg [3:0]cnt;
reg[7:0]data_reg;
wire ps2_clk_red;

wire ps2_clk_inv;
assign ps2_clk_inv=~ps2_clk;
wire ps2_clk_clean;

red red_clk(.clk(clk),.rst_n(rst_n),.in(ps2_clk_inv),.out(ps2_clk_red));
debouncer deb(.clk(clk),.rst_n(rst_n),.in(ps2_clk),.out(ps2_clk_clean));

reg ps2_clk_sync0, ps2_clk_sync1, ps2_clk_sync2;

always @(posedge clk) begin
    ps2_clk_sync0 <= ps2_clk_clean;
    ps2_clk_sync1 <= ps2_clk_sync0;
    ps2_clk_sync2 <= ps2_clk_sync1;
end

wire ps2_clk_falling_edge = (ps2_clk_sync2 && !ps2_clk_sync1);

always@(posedge clk,negedge rst_n)begin
    if (!rst_n)begin
        cnt<=4'h0;
        code<=16'h0000;
        data_reg<=8'h00;
    end
    else begin
        if (ps2_clk_falling_edge)begin
            if(cnt==4'h0 || cnt==4'h9)cnt<=cnt+4'h1;
            else if(cnt<9)begin
                data_reg<={ps2_data,data_reg[7:1]};
                cnt<=cnt+4'h1;
            end
            else begin
                code<={code[7:0],data_reg};
                cnt<=4'h0;
            end
        end
    
    end
end



endmodule