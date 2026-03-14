module ps2(
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output [15:0] code
);

reg [15:0]code_reg;

wire[15:0]code_wire;

reg [15:0]code_reg_next;

reg ps2_clk_sync0;
reg ps2_clk_sync1;
reg [2:0]state_reg;
reg[2:0]state_reg_next;
reg [3:0]n;
reg[3:0]n_next;
reg[7:0]data_reg;
reg[7:0]data_reg_next;

assign code=code_wire;
assign code_wire=code_reg;

localparam START_BIT=0;
localparam END_BIT=1;
localparam INITIATE=0;
localparam READ=1;
localparam SEND=2;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        code_reg<=16'h0000;
        state_reg<=3'h0;
        n<=4'h0;
        data_reg<=8'h00;
    end
    else begin
        code_reg<=code_reg_next;
        state_reg<=state_reg_next;
        n<=n_next;
        data_reg<=data_reg_next;
    end
end

always @(negedge ps2_clk) begin
    code_reg_next<=code_reg;
    state_reg_next<=state_reg;
    n_next=n;
    data_reg_next=data_reg;

    case(state_reg)
        INITIATE:begin
            if(ps2_data==START_BIT)begin
                n_next=4'd9;
                state_reg_next=READ;
            end
            else;
        end
        READ:begin
            if(n==4'h0 && ps2_data==END_BIT)begin
                //next state
                state_reg_next=SEND;
            end
            else if(n==4'h0 && ps2_data!=END_BIT)begin
                //error
                state_reg_next=INITIATE;
            end
            else if(n==4'h1)begin
                //parity bit, do nothing
                n_next=n_next-1;
            end
            else begin
                data_reg_next={data_reg_next[6:0],ps2_data};
                n_next=n_next-1;
            end
        end
        SEND:begin
            code_reg_next={code_reg_next[7:0],data_reg};
            state_reg_next=INITIATE;
        end
        default:state_reg_next=INITIATE;
    endcase
end
endmodule