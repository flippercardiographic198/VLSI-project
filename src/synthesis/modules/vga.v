module vga(
    input clk,
    input rst_n,
    input [23:0]code,
    output reg hsync,
    output reg vsync,
    output reg [3:0]red,
    output reg [3:0]green,
    output reg [3:0]blue
);

    parameter H_DISPLAY = 800;
    parameter H_FRONT = 56;
    parameter H_SYNC = 120;
    parameter H_BACK = 64;
    parameter H_TOTAL = H_DISPLAY + H_FRONT + H_SYNC + H_BACK;
    
    parameter V_DISPLAY = 600;
    parameter V_FRONT = 37;
    parameter V_SYNC = 6;
    parameter V_BACK = 23;
    parameter V_TOTAL = V_DISPLAY + V_FRONT + V_SYNC + V_BACK;

reg [11:0] h_cnt;
reg [10:0] v_cnt;

wire visible;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        h_cnt <= 12'h000;
        v_cnt <= 11'h000;
    end
    else begin
        if(h_cnt == H_TOTAL-1) begin
            h_cnt <= 12'h000;
            if(v_cnt == V_TOTAL-1)
                v_cnt <= 11'h000;
            else
                v_cnt <= v_cnt + 1;
        end
        else begin
            h_cnt <= h_cnt + 1;
        end
    end
end

always @(*) begin
    if(h_cnt >= H_DISPLAY+H_FRONT && h_cnt < H_DISPLAY+H_FRONT+H_SYNC)
        hsync = 0;
    else
        hsync = 1;
end

always @(*) begin
    if(v_cnt >= V_DISPLAY+V_FRONT && v_cnt < V_DISPLAY+V_FRONT+V_SYNC)
        vsync = 0;
    else
        vsync = 1;
end

assign visible = (h_cnt < H_DISPLAY) && (v_cnt < V_DISPLAY);

wire [11:0] left_color  = code[23:12];
wire [11:0] right_color = code[11:0];

always @(*) begin
    if(!visible) begin
        red   = 0;
        green = 0;
        blue  = 0;
    end
    else begin
        if(h_cnt < H_DISPLAY/2) begin
            red   = left_color[11:8];
            green = left_color[7:4];
            blue  = left_color[3:0];
        end
        else begin
            red   = right_color[11:8];
            green = right_color[7:4];
            blue  = right_color[3:0];
        end
    end
end

endmodule