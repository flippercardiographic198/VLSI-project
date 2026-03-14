module scan_codes(
    input clk,
    input rst_n,
    input [15:0]code,
    input status,
    output control,
    output [3:0]num
);
reg[3:0]num_reg;
reg control_reg;

assign num=num_reg;
assign control=control_reg;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        num_reg<=4'h0;
        control_reg<=0;
    end
    else begin
        if (status) begin
            case (code)
                16'hF07C: begin num_reg <= 4'd0; control_reg <= 1'b1; end // 0
                16'hF069: begin num_reg <= 4'd1; control_reg <= 1'b1; end // 1
                16'hF072: begin num_reg <= 4'd2; control_reg <= 1'b1; end // 2
                16'hF07A: begin num_reg <= 4'd3; control_reg <= 1'b1; end // 3
                16'hF06B: begin num_reg <= 4'd4; control_reg <= 1'b1; end // 4
                16'hF073: begin num_reg <= 4'd5; control_reg <= 1'b1; end // 5
                16'hF074: begin num_reg <= 4'd6; control_reg <= 1'b1; end // 6
                16'hF06C: begin num_reg <= 4'd7; control_reg <= 1'b1; end // 7
                16'hF075: begin num_reg <= 4'd8; control_reg <= 1'b1; end // 8
                16'hF07D: begin num_reg <= 4'd9; control_reg <= 1'b1; end // 9
                default: begin num_reg<=4'h0; control_reg <= 1'b0;end
            endcase
            end else begin
                num_reg<=4'h0;
                control_reg<= 1'b0;
            end
    end
end
endmodule