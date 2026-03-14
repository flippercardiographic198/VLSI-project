module alu(OC,A,B,F);
    input [2:0]OC;
    input [3:0]A;
    input [3:0]B;
    output reg [3:0]F;

    always@(OC,A,B)
        case(OC)
            3'b000: F=A+B;
            3'b001: F=A-B;
            3'b010: F=A*B;
            3'b011: F=A/B;
            3'b100: F=~A;
            3'b101: F=A^B;
            3'b110: F=A|B;
            3'b111: F=A&B;
        endcase
endmodule