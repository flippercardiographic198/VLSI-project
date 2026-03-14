module color_codes(
    input wire[5:0]num,
    output reg[23:0]code
);

    function [11:0] digit_to_color;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: digit_to_color = 12'h000; 
                4'd1: digit_to_color = 12'hF00; 
                4'd2: digit_to_color = 12'hF80; 
                4'd3: digit_to_color = 12'hFF0; 
                4'd4: digit_to_color = 12'h0F0; 
                4'd5: digit_to_color = 12'h0FF; 
                4'd6: digit_to_color = 12'h08F; 
                4'd7: digit_to_color = 12'h00F; 
                4'd8: digit_to_color = 12'hF0F; 
                4'd9: digit_to_color = 12'hFFF; 
                default: digit_to_color = 12'h000;
            endcase
        end
    endfunction

    always @(*) begin
        code[23:12] = digit_to_color(num / 10); 
        code[11:0]  = digit_to_color(num % 10); 
    end
endmodule