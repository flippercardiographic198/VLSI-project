module clk_div #(
    parameter DIVISOR = 50_000_000
)(
    input clk,
    input rst_n,
    output reg out
);

    integer counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            out <= 0;
        end
        else begin
            if (counter == DIVISOR-1) begin
                counter <= 0;
                out <= ~out;   
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

endmodule