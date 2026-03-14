module cpu #(
    parameter ADDR_WIDTH=6,
    parameter DATA_WIDTH=16
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0]mem,
    input [DATA_WIDTH-1:0]in,
    output we,
    output [ADDR_WIDTH-1:0]addr,
    output [DATA_WIDTH-1:0]data,
    output [DATA_WIDTH-1:0]out,
    output [ADDR_WIDTH-1:0]pc,
    output [ADDR_WIDTH-1:0]sp
);

// pc(0), sp(1), ir_low(2), ir_high(3), mar(4), mdr(5), acc(6)
    reg[6:0] ld_trigger;
    reg[6:0] cl_trigger;
    reg[6:0] inc_trigger;
    reg[6:0] dec_trigger;
    reg[6:0] ir_trigger;
    reg[6:0] sr_trigger;
    reg[6:0] il_trigger;
    reg[6:0] sl_trigger;

    localparam PC_MASK=     7'b0000001;
    localparam SP_MASK=     7'b0000010;
    localparam IR_LOW_MASK= 7'b0000100;
    localparam IR_HIGH_MASK=7'b0001000;
    localparam MAR_MASK=    7'b0010000;
    localparam MDR_MASK=    7'b0100000;
    localparam ACC_MASK=    7'b1000000;

    reg [ADDR_WIDTH-1:0]pc_in;
    reg [ADDR_WIDTH-1:0]sp_in;
    reg [DATA_WIDTH-1:0]ir_low_in;
    reg [DATA_WIDTH-1:0]ir_high_in;
    reg [ADDR_WIDTH-1:0]mar_in;
    reg [DATA_WIDTH-1:0]mdr_in;
    reg [DATA_WIDTH-1:0]acc_in;
    reg [DATA_WIDTH-1:0]out_reg;
    reg [DATA_WIDTH-1:0]out_reg_next;
    reg we_reg;
    reg we_reg_next;


    wire [ADDR_WIDTH-1:0]pc_wire;
    wire [ADDR_WIDTH-1:0]sp_wire;
    wire [DATA_WIDTH-1:0]ir_low_wire;
    wire [DATA_WIDTH-1:0]ir_high_wire;
    wire [ADDR_WIDTH-1:0]mar_wire;
    wire [DATA_WIDTH-1:0]mdr_wire;
    wire [DATA_WIDTH-1:0]acc_wire;   

    assign pc=pc_wire;
    assign sp=sp_wire;
    assign out=out_reg;
    assign we=we_reg;
    assign addr=mar_wire;
    assign data=mdr_wire;

    register#(.DATA_WIDTH(6)) register_pc(
        .clk(clk),
        .rst_n(rst_n),
        .cl(cl_trigger[0]),
        .ld(ld_trigger[0]),
        .in(pc_in),
        .inc(inc_trigger[0]),
        .dec(dec_trigger[0]),
        .sr(sr_trigger[0]),
        .ir(ir_trigger[0]),
        .sl(sl_trigger[0]),
        .il(il_trigger[0]),
        .out(pc_wire)
        );
    register#(.DATA_WIDTH(6)) register_sp(
        .clk(clk),
        .rst_n(rst_n),
        .cl(cl_trigger[1]),
        .ld(ld_trigger[1]),
        .in(sp_in),
        .inc(inc_trigger[1]),
        .dec(dec_trigger[1]),
        .sr(sr_trigger[1]),
        .ir(ir_trigger[1]),
        .sl(sl_trigger[1]),
        .il(il_trigger[1]),
        .out(sp_wire)
        );
    register#(.DATA_WIDTH(16)) register_ir_low(clk,rst_n,cl_trigger[2],ld_trigger[2],ir_low_in,inc_trigger[2],dec_trigger[2],sr_trigger[2],ir_trigger[2],sl_trigger[2],il_trigger[2],ir_low_wire);
    register#(.DATA_WIDTH(16)) register_ir_high(clk,rst_n,cl_trigger[3],ld_trigger[3],ir_high_in,inc_trigger[3],dec_trigger[3],sr_trigger[3],ir_trigger[3],sl_trigger[3],il_trigger[3],ir_high_wire);
    register#(.DATA_WIDTH(6))  register_mar(clk,rst_n,cl_trigger[4],ld_trigger[4],mar_in,inc_trigger[4],dec_trigger[4],sr_trigger[4],ir_trigger[4],sl_trigger[4],il_trigger[4],mar_wire);
    register#(.DATA_WIDTH(16)) register_mdr(clk,rst_n,cl_trigger[5],ld_trigger[5],mdr_in,inc_trigger[5],dec_trigger[5],sr_trigger[5],ir_trigger[5],sl_trigger[5],il_trigger[5],mdr_wire);
    register#(.DATA_WIDTH(16)) register_a(clk,rst_n,cl_trigger[6],ld_trigger[6],acc_in,inc_trigger[6],dec_trigger[6],sr_trigger[6],ir_trigger[6],sl_trigger[6],il_trigger[6],acc_wire);

    reg [DATA_WIDTH-1:0]mdr_reg;
    reg [DATA_WIDTH-1:0]mdr_reg_seq;

    localparam MOV=4'b0000;
    localparam ADD=4'b0001;
    localparam SUB=4'b0010;
    localparam MUL=4'b0011;
    localparam DIV=4'b0100;
    localparam IN=4'b0111;
    localparam OUT=4'b1000;
    localparam STOP=4'b1111;
    localparam DIR=1'b0;
    localparam IND=1'b1;
    localparam BEG=4'b0101;//MODIFIKACIJA

    wire[2:0]operand_1;
    wire operand_1_adr;
    wire[2:0]operand_2;
    wire operand_2_adr;
    wire[2:0]operand_3;
    wire operand_3_adr;

    reg[3:0] operand_1_full;
    reg[3:0] operand_2_full;
    reg[3:0] operand_3_full;
    reg[3:0] operand_1_full_seq;
    reg[3:0] operand_2_full_seq;
    reg[3:0] operand_3_full_seq;
//    reg[15:0] operand_4;
    reg[3:0] operation_code;
    reg[3:0] operation_code_seq;

    reg[DATA_WIDTH-1:0] alu_operand_1;
    reg[DATA_WIDTH-1:0] alu_operand_2;
    wire[DATA_WIDTH-1:0] alu_output;
    reg[3:0]alu_oc;

    reg[DATA_WIDTH-1:0] alu_operand_1_seq;
    reg[DATA_WIDTH-1:0] alu_operand_2_seq;
    reg[3:0]alu_oc_seq;

    alu#(.DATA_WIDTH(16))ALU_module(alu_oc,alu_operand_1,alu_operand_2,alu_output);

    localparam DATA_WIDTH_RESET={DATA_WIDTH{1'b0}};
    localparam ADDR_WIDTH_RESET={ADDR_WIDTH{1'b0}};

    assign operand_1=operand_1_full[2:0];
    assign operand_2=operand_2_full[2:0];
    assign operand_3=operand_3_full[2:0];
    assign operand_1_adr=operand_1_full[3];
    assign operand_2_adr=operand_2_full[3];
    assign operand_3_adr=operand_3_full[3];

    reg[7:0] state_reg,state_reg_next;
    reg status_reg,status_reg_next;

    localparam MEMORY_DIRECT_ADR=1'b0;
    localparam MEMORY_INDIRECT_ADR=1'b1;

    localparam PC_INITIAL_VALUE=8;
    localparam SP_INITIAL_VALUE=63;

    localparam RESET_STATE=0;

    localparam FETCH_STATE_MAR_IN=1;
    localparam FETCH_STATE_MEM_READ=2;
    localparam FETCH_STATE_MDR_IN=3;
    localparam FETCH_STATE_IR=4;
    localparam FETCH_STATE_MAR_IN1=5;

    localparam DECODE_STATE=10;
    
    localparam EXEC_STATE_MOV=11;
    localparam EXEC_STATE_MOV_IND_1=12;
    localparam EXEC_STATE_MOV_IND_2=13;
    localparam EXEC_STATE_MOV_IND_3=14;
    localparam EXEC_STATE_MOV_DIR=15;
    localparam EXEC_STATE_MOV_DST_DIR=16;
    localparam EXEC_STATE_MOV_DST_IND_1=17;
    localparam EXEC_STATE_MOV_DST_IND_2=18;
    localparam EXEC_STATE_MOV_DST_IND_3=19;
    localparam EXEC_STATE_MOV_DST=20;
    localparam EXEC_STATE_MOV_DIR_WAIT=21;
    localparam EXEC_STATE_MOV_IND_1_WAIT=22;
    localparam EXEC_STATE_MOV_DST_IND_1_WAIT=23;

 //   localparam EXEC_STATE_MOV_FETCH_IR_LOW=110;       //MOV MOD
 //   localparam EXEC_STATE_MOV_FETCH_IR_LOW_2=111;     //MOV MOD
 //   localparam EXEC_STATE_MOV_FETCH_IR_LOW_3=112;     //MOV MOD
 //   localparam EXEC_STATE_MOV_TWO_WORDED=113;     //MOV MOD
 //   localparam EXEC_STATE_MOV_TWO_WORDED_DIR=114;     //MOV MOD
 //   localparam EXEC_STATE_MOV_TWO_WORDED_DIR_WR=115;      //MOV MOD
 //   localparam EXEC_STATE_MOV_TWO_WORDED_IND=116;     //MOV MOD
 //   localparam EXEC_STATE_MOV_TWO_WORDED_IND_2=117;       //MOV MOD
 //   localparam EXEC_STATE_MOV_TWO_WORDED_IND_3=118;       //MOV MOD
 //   localparam EXEC_STATE_MOV_TWO_WORDED_IND_WAIT=119;        //MOV MOD
 //   localparam EXEC_STATE_MOV_TWO_WORDED_IND_WR=120;      //MOV MOD

    localparam EXEC_STATE_BEG=110;
    localparam EXEC_STATE_BEG_BOTH=111;
    localparam EXEC_STATE_BEG_BOTH_DIR_OP1=112;
    localparam EXEC_STATE_BEG_BOTH_DIR_OP1_2=113;
    localparam EXEC_STATE_BEG_BOTH_DIR_OP1_WAIT=114;
    localparam EXEC_STATE_BEG_BOTH_DIR_OP2=115;
    localparam EXEC_STATE_BEG_BOTH_DIR_OP2_WAIT=116;
    localparam EXEC_STATE_BEG_BOTH_IND_OP1=117;
    localparam EXEC_STATE_BEG_BOTH_IND_OP1_2=118;
    localparam EXEC_STATE_BEG_BOTH_IND_OP1_3=119;
    localparam EXEC_STATE_BEG_BOTH_IND_OP1_3_WAIT=120;
    localparam EXEC_STATE_BEG_BOTH_IND_OP1_4=121;
    localparam EXEC_STATE_BEG_BOTH_IND_OP1_WAIT=122;
    localparam EXEC_STATE_BEG_BOTH_IND_OP2=123;
    localparam EXEC_STATE_BEG_BOTH_IND_OP2_2=124;
    localparam EXEC_STATE_BEG_BOTH_IND_OP2_3=125;
    localparam EXEC_STATE_BEG_BOTH_IND_OP2_3_WAIT=126;
    localparam EXEC_STATE_BEG_BOTH_IND_OP2_WAIT=127;
    localparam EXEC_STATE_BEG_BOTH_JUMP=128;
    localparam EXEC_STATE_BEG_BOTH_OP2=129;
    localparam EXEC_STATE_BEG_CHECK=130;
    localparam EXEC_STATE_BEG_FETCH=131;
    localparam EXEC_STATE_BEG_FETCH_1=132;
    localparam EXEC_STATE_BEG_FETCH_2=133;

    localparam EXEC_STATE_ALU=30;
    localparam EXEC_STATE_ALU_EXEC=31;
    localparam EXEC_STATE_ALU_IND_WRITE_1=32;
    localparam EXEC_STATE_ALU_IND_WRITE_2=33;
    localparam EXEC_STATE_ALU_OPERAND_1_DIR_1=34;
    localparam EXEC_STATE_ALU_OPERAND_1_DIR_2=35;
    localparam EXEC_STATE_ALU_OPERAND_2_DIR_1=36;
    localparam EXEC_STATE_ALU_OPERAND_2_DIR_2=37;
    localparam EXEC_STATE_ALU_WRITE=38;
    localparam EXEC_STATE_ALU_OPERAND_1_IND_1=39;
    localparam EXEC_STATE_ALU_OPERAND_1_IND_2 =40;
    localparam EXEC_STATE_ALU_OPERAND_2_IND_1=41;
    localparam EXEC_STATE_ALU_OPERAND_2_IND_2=42;
    localparam EXEC_STATE_ALU_OPERAND_2_DIR_3=43;
    localparam EXEC_STATE_ALU_OPERAND_1_DIR_1_WAIT=45;////
    localparam EXEC_STATE_ALU_OPERAND_2_DIR_1_WAIT=46;////
    localparam EXEC_STATE_ALU_OPERAND_2_DIR_2_WAIT=47;////
    localparam EXEC_STATE_ALU_IND_WRITE_1_WAIT=48;
    localparam EXEC_STATE_ALU_OPERAND_1_IND_1_WAIT=49;
    localparam EXEC_STATE_ALU_OPERAND_2_IND_1_WAIT=50;

    localparam EXEC_STATE_IN=50+1;
    localparam EXEC_STATE_IN_DIR=51+1;
    localparam EXEC_STATE_IN_IND_1=52+1;
    localparam EXEC_STATE_IN_IND_2=53+1;
    localparam EXEC_STATE_IN_WRITE=54+1;
    localparam EXEC_STATE_IN_SET_STATUS=55+1;
    localparam EXEC_STATE_IN_CHECK_STATUS=56+1;
    localparam EXEC_STATE_IN_IND_3=57+1;
    localparam EXEC_STATE_IN_IND_1_WAIT=59;

    localparam EXEC_STATE_OUT=60;
    localparam EXEC_STATE_OUT_2=61;
    localparam EXEC_STATE_OUT_3=62;
    localparam EXEC_STATE_OUT_CHECK_STATUS=63;
    localparam EXEC_STATE_OUT_IND_1=64;
    localparam EXEC_STATE_OUT_IND_2=65;
    localparam EXEC_STATE_OUT_IND_3=66;
    localparam EXEC_STATE_OUT_4=67;
    localparam EXEC_STATE_OUT_3_1=68;
    localparam EXEC_STATE_OUT_2_1=69;
    localparam EXEC_STATE_OUT_IND_1_WAIT=70;
    

    localparam EXEC_STATE_STOP=80;
    localparam EXEC_STATE_STOP_CHECK_OP_2=81;
    localparam EXEC_STATE_STOP_CHECK_OP_3=82;
    localparam EXEC_STATE_STOP_IND_OP_1=83;
    localparam EXEC_STATE_STOP_IND_OP_1_2=84;
    localparam EXEC_STATE_STOP_IND_OP_2=85;
    localparam EXEC_STATE_STOP_IND_OP_2_2=86;
    localparam EXEC_STATE_STOP_IND_OP_3=87;
    localparam EXEC_STATE_STOP_IND_OP_3_2=88;
    localparam EXEC_STATE_STOP_OP_2=89;
    localparam EXEC_STATE_STOP_OP_3=90;
    localparam EXEC_STATE_STOP_OUT_OP_1=91;
    localparam EXEC_STATE_STOP_OUT_OP_2=92;
    localparam EXEC_STATE_STOP_OUT_OP_3=93;
    localparam EXEC_STATE_STOP_OUT_OP_1_WAIT=94;
    localparam EXEC_STATE_STOP_OUT_OP_2_WAIT=95;
    localparam EXEC_STATE_STOP_OUT_OP_3_WAIT=96;
    localparam EXEC_STATE_STOP_IND_OP_1_WAIT=97;
    localparam EXEC_STATE_STOP_IND_OP_2_WAIT=98;
    localparam EXEC_STATE_STOP_IND_OP_3_WAIT=99;
    localparam EXEC_STATE_STOP_OUT_OP_3_1_WAIT=100;
    localparam EXEC_STATE_STOP_IND_OP_1_2_WAIT=101;
    localparam EXEC_STATE_STOP_IND_OP_2_2_WAIT=102;
    localparam EXEC_STATE_STOP_IND_OP_3_2_WAIT=103;
    localparam EXEC_STATE_STOP_CHECK_OP_2_WAIT=104;
    localparam EXEC_STATE_STOP_CHECK_OP_3_WAIT=105;
    localparam EXEC_STATE_STOP_OUT_OP_3_1=106;
    
    
    localparam HALT=200;

    always @(posedge clk,negedge rst_n)begin
        if (!rst_n)begin
            state_reg<=RESET_STATE;
            status_reg<=1'b0;
            we_reg<=1'b0;
            out_reg<={DATA_WIDTH{1'b0}};
            mdr_reg_seq<={DATA_WIDTH{1'b0}};
            operation_code_seq<=4'h0;
            operand_1_full_seq<=4'h0;
            operand_2_full_seq<=4'h0;
            operand_3_full_seq<=4'h0;
            alu_operand_1_seq<={DATA_WIDTH{1'b0}};
            alu_operand_2_seq<={DATA_WIDTH{1'b0}};
            alu_oc_seq<=4'h0;

        end
        else begin
            state_reg<=state_reg_next;
            status_reg<=status_reg_next;
            out_reg<=out_reg_next;
            we_reg<=we_reg_next;
            mdr_reg_seq<=mdr_reg;
            operation_code_seq<=operation_code;
            operand_1_full_seq<=operand_1_full;
            operand_2_full_seq<=operand_2_full;
            operand_3_full_seq<=operand_3_full;
            alu_operand_1_seq<=alu_operand_1;
            alu_operand_2_seq<=alu_operand_2;
            alu_oc_seq<=alu_oc;
        end
    end

    always@(*)begin
            ld_trigger=7'h00;
            cl_trigger=7'h00;
            il_trigger=7'h00;
            ir_trigger=7'h00;
            sl_trigger=7'h00;
            sr_trigger=7'h00;
            dec_trigger=7'h00;
            inc_trigger=7'h00;

            mar_in={ADDR_WIDTH{1'b0}};
            mdr_in={DATA_WIDTH{1'b0}};
            ir_high_in={DATA_WIDTH{1'b0}};
            pc_in={ADDR_WIDTH{1'b0}}+PC_INITIAL_VALUE;
            sp_in={ADDR_WIDTH{1'b0}}+SP_INITIAL_VALUE;
            ir_low_in={DATA_WIDTH{1'b0}};
            acc_in={DATA_WIDTH{1'b0}};
            we_reg_next=1'b0;
            state_reg_next=state_reg;
            out_reg_next=out_reg;
            mdr_reg=mdr_reg_seq;
            status_reg_next=status_reg;
            operation_code=operation_code_seq;
            operand_1_full=operand_1_full_seq;
            operand_2_full=operand_2_full_seq;
            operand_3_full=operand_3_full_seq;
            alu_operand_1=alu_operand_1_seq;
            alu_operand_2=alu_operand_2_seq;
            alu_oc=alu_oc_seq;

        case(state_reg)
//----------------------------------------------------------//
            RESET_STATE:begin
                pc_in={ADDR_WIDTH{1'b0}}+PC_INITIAL_VALUE;
                sp_in={ADDR_WIDTH{1'b0}}+SP_INITIAL_VALUE;
                ld_trigger=PC_MASK | SP_MASK;
                state_reg_next=FETCH_STATE_MAR_IN;
            end
//----------------------------------------------------------//
            FETCH_STATE_MAR_IN:begin
                state_reg_next=FETCH_STATE_MAR_IN1;
            end
            FETCH_STATE_MAR_IN1:begin
                mar_in=pc_wire;
                ld_trigger=MAR_MASK;
                state_reg_next=FETCH_STATE_MEM_READ;
            end
            FETCH_STATE_MEM_READ:begin
                inc_trigger=PC_MASK;
                state_reg_next=FETCH_STATE_MDR_IN;
            end
            FETCH_STATE_MDR_IN:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=FETCH_STATE_IR;
            end
            FETCH_STATE_IR:begin
                ir_high_in=mdr_wire;
                ld_trigger=IR_HIGH_MASK;
                state_reg_next=DECODE_STATE;
            end
//----------------------------------------------------------//
            DECODE_STATE:begin
                operation_code=ir_high_wire[15:12];
                operand_1_full=ir_high_wire[11:8];
                operand_2_full=ir_high_wire[7:4];
                operand_3_full=ir_high_wire[3:0];
                case(operation_code)
                    MOV:begin
                        state_reg_next=EXEC_STATE_MOV;
                    end
                    ADD,
                    MUL,
                    SUB:begin
                        state_reg_next=EXEC_STATE_ALU;
                    end
                    DIV:begin
                        //DIV does not work
                        state_reg_next=RESET_STATE;
                    end
                    IN:begin
                        state_reg_next=EXEC_STATE_IN_SET_STATUS;
                    end
                    OUT:begin
                        state_reg_next=EXEC_STATE_OUT;
                    end
                    STOP:begin
                        state_reg_next=EXEC_STATE_STOP;
                    end
                   BEG:begin// BEQ MOD
                       state_reg_next=EXEC_STATE_BEG;// BEQ MOD
                   end// BEQ MOD
                    default:state_reg_next=RESET_STATE;
                endcase
            end
//----------------------------------------------------------//            
            EXEC_STATE_MOV:begin
        //        if(operand_3_full==4'b1000)begin          //MOV MOD
        //            mar_in=pc_wire;           //MOV MOD
        //            ld_trigger=MAR_MASK;          //MOV MOD
        //            state_reg_next=EXEC_STATE_MOV_FETCH_IR_LOW;           //MOV MOD
        //        end           //MOV MOD
            //    else          //MOV MOD
                if(operand_3_full!=4'h0)begin
                    mar_in={3'h0,operand_1};
                    ld_trigger=MAR_MASK;
                    if(operand_1_adr==1'b0)state_reg_next=EXEC_STATE_MOV_DIR_WAIT;
                    else state_reg_next=EXEC_STATE_MOV_IND_1_WAIT;
                end
                else begin
                    mar_in={4'h0,operand_2};
                    ld_trigger=MAR_MASK;
                    if(operand_2_adr==1'b0)state_reg_next=EXEC_STATE_MOV_DIR_WAIT;
                    else state_reg_next=EXEC_STATE_MOV_IND_1_WAIT;
                end
            end            
       //     EXEC_STATE_MOV_FETCH_IR_LOW:begin //MOV MOD
       //         inc_trigger=PC_MASK;  //MOV MOD
       //         state_reg_next=EXEC_STATE_MOV_FETCH_IR_LOW_2; //MOV MOD
       //     end   //MOV MOD
       //     EXEC_STATE_MOV_FETCH_IR_LOW_2:begin   //MOV MOD
       //         mdr_in=mem;   //MOV MOD
       //         ld_trigger=MDR_MASK;  //MOV MOD
       //         state_reg_next=EXEC_STATE_MOV_FETCH_IR_LOW_3; //MOV MOD
       //     end   //MOV MOD
       //     EXEC_STATE_MOV_FETCH_IR_LOW_3:begin   //MOV MOD
       //         ir_low_in=mdr_wire;   //MOV MOD
       //         ld_trigger=IR_LOW_MASK;   //MOV MOD
       //         state_reg_next=EXEC_STATE_MOV_TWO_WORDED; //MOV MOD
       //     end   //MOV MOD
       //     EXEC_STATE_MOV_TWO_WORDED:begin   //MOV MOD
        //        if(operand_1_adr==MEMORY_DIRECT_ADR)begin //MOV MOD
        //            mar_in={3'h0,operand_1};  //MOV MOD
        //            ld_trigger=MAR_MASK;  //MOV MOD
        //            state_reg_next=EXEC_STATE_MOV_TWO_WORDED_DIR; //MOV MOD
        //        end   //MOV MOD
        //        else begin    //MOV MOD
        //            mar_in={3'h0,operand_1};  //MOV MOD
        //            ld_trigger=MAR_MASK;  //MOV MOD
        //            state_reg_next=EXEC_STATE_MOV_TWO_WORDED_IND_WAIT;    //MOV MOD
        //        end   //MOV MOD
        //    end   //MOV MOD
        //   EXEC_STATE_MOV_TWO_WORDED_DIR:begin    //MOV MOD
        //       mdr_in=ir_low_wire;    //MOV MOD
        //       ld_trigger=MDR_MASK;   //MOV MOD
        //       state_reg_next=EXEC_STATE_MOV_TWO_WORDED_DIR_WR;   //MOV MOD
        //   end    //MOV MOD
        //   EXEC_STATE_MOV_TWO_WORDED_DIR_WR:begin //MOV MOD
        //       we_reg_next=1'b1;  //MOV MOD
        //       state_reg_next=FETCH_STATE_MAR_IN; //MOV MOD
        //   end    //MOV MOD
    //MOV MOD
        //   EXEC_STATE_MOV_TWO_WORDED_IND_WAIT:begin   //MOV MOD
        //       state_reg_next=EXEC_STATE_MOV_TWO_WORDED_IND;  //MOV MOD
        //   end    //MOV MOD
        //   EXEC_STATE_MOV_TWO_WORDED_IND:begin    //MOV MOD
        //       mdr_reg=mem;   //MOV MOD
        //       state_reg_next=EXEC_STATE_MOV_TWO_WORDED_IND_2;    //MOV MOD
        //   end    //MOV MOD
        //   EXEC_STATE_MOV_TWO_WORDED_IND_2:begin  //MOV MOD
        //       mar_in=mdr_reg[5:0];   //MOV MOD
        //       ld_trigger=MAR_MASK;   //MOV MOD
        //       state_reg_next=EXEC_STATE_MOV_TWO_WORDED_IND_3;    //MOV MOD
        //   end    //MOV MOD
        //   EXEC_STATE_MOV_TWO_WORDED_IND_3:begin  //MOV MOD
        //       mdr_in=ir_low_wire;    //MOV MOD
        //       ld_trigger=MDR_MASK;   //MOV MOD
        //       state_reg_next=EXEC_STATE_MOV_TWO_WORDED_IND_WR;   //MOV MOD
        //   end    //MOV MOD
        //   EXEC_STATE_MOV_TWO_WORDED_IND_WR:begin //MOV MOD
        //       we_reg_next=1'b1;  //MOV MOD
        //       state_reg_next=FETCH_STATE_MAR_IN; //MOV MOD
        //   end    //MOV MOD

            EXEC_STATE_MOV_DIR_WAIT:begin
                state_reg_next=EXEC_STATE_MOV_DIR;
            end
            EXEC_STATE_MOV_DIR:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_MOV_DST;
            end
            EXEC_STATE_MOV_IND_1_WAIT:
                state_reg_next=EXEC_STATE_MOV_IND_1;
            EXEC_STATE_MOV_IND_1:begin
                mdr_reg=mem;
                state_reg_next=EXEC_STATE_MOV_IND_2;
            end
            EXEC_STATE_MOV_IND_2:begin
                mar_in=mdr_wire[5:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_MOV_IND_3;
            end
            EXEC_STATE_MOV_IND_3:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_MOV_DST;
            end
            EXEC_STATE_MOV_DST:begin
                if(operand_3_full!=4'h0)begin
                    if(operand_2_adr==1'b0)begin
                        mar_in={4'h0,operand_2};
                        ld_trigger=MAR_MASK;
                        state_reg_next=EXEC_STATE_MOV_DST_DIR;
                    end
                    else begin
                        mar_in={4'h0,operand_2};
                        ld_trigger=MAR_MASK;
                        mdr_reg=mdr_wire;
                        state_reg_next=EXEC_STATE_MOV_DST_IND_1_WAIT;
                    end
                end
                else begin
                    if(operand_1_adr==1'b0)begin
                        mar_in={3'h0,operand_1};
                        ld_trigger=MAR_MASK;
                        state_reg_next=EXEC_STATE_MOV_DST_DIR;
                    end
                    else begin
                        mar_in={3'h0,operand_1};
                        ld_trigger=MAR_MASK;
                        mdr_reg=mdr_wire;
                        state_reg_next=EXEC_STATE_MOV_DST_IND_1_WAIT;
                    end
                end
            end
            EXEC_STATE_MOV_DST_DIR:begin
                we_reg_next=1'b1;
                state_reg_next=FETCH_STATE_MAR_IN;
            end
            EXEC_STATE_MOV_DST_IND_1_WAIT:
                state_reg_next=EXEC_STATE_MOV_DST_IND_1;
            EXEC_STATE_MOV_DST_IND_1:begin
                mdr_reg=mem;
                state_reg_next=EXEC_STATE_MOV_DST_IND_2;
            end
            EXEC_STATE_MOV_DST_IND_2:begin
                mar_in=mdr_reg[5:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_MOV_DST_IND_3;
            end
            EXEC_STATE_MOV_DST_IND_3:begin
                we_reg_next=1'b1;
                state_reg_next=FETCH_STATE_MAR_IN;
            end
//----------------------------------------------------------//     
            EXEC_STATE_BEG:begin
                mar_in=pc_wire;
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_BEG_FETCH;
            end
            EXEC_STATE_BEG_FETCH:begin
                inc_trigger=PC_MASK;
                state_reg_next=EXEC_STATE_BEG_FETCH_1;
            end
            EXEC_STATE_BEG_FETCH_1:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_BEG_FETCH_2;
            end
            EXEC_STATE_BEG_FETCH_2:begin
                ir_low_in=mdr_wire;
                ld_trigger=IR_LOW_MASK;
                state_reg_next=EXEC_STATE_BEG_CHECK;
            end
            EXEC_STATE_BEG_CHECK:begin
                state_reg_next=EXEC_STATE_BEG_BOTH;
            end
            EXEC_STATE_BEG_BOTH:begin
                mar_in={3'h0,operand_1};
                ld_trigger=MAR_MASK;
                if(operand_1_adr==MEMORY_DIRECT_ADR)begin
                    state_reg_next=EXEC_STATE_BEG_BOTH_DIR_OP1_WAIT;
                end
                else begin
                    state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP1_WAIT;
                end
            end
            EXEC_STATE_BEG_BOTH_DIR_OP1_WAIT:begin
                state_reg_next=EXEC_STATE_BEG_BOTH_DIR_OP1;
            end
            EXEC_STATE_BEG_BOTH_DIR_OP1:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_BEG_BOTH_DIR_OP1_2;
            end
            EXEC_STATE_BEG_BOTH_DIR_OP1_2:begin
                acc_in=mdr_wire;
                ld_trigger=ACC_MASK;
                state_reg_next=EXEC_STATE_BEG_BOTH_OP2;
            end
            EXEC_STATE_BEG_BOTH_IND_OP1_WAIT:begin
                state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP1;
            end
            EXEC_STATE_BEG_BOTH_IND_OP1:begin
                mdr_reg=mem;
                state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP1_2;
            end
            EXEC_STATE_BEG_BOTH_IND_OP1_2:begin
                mar_in=mdr_reg[5:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP1_3_WAIT;
            end
            EXEC_STATE_BEG_BOTH_IND_OP1_3_WAIT:begin
                state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP1_3;
            end
            EXEC_STATE_BEG_BOTH_IND_OP1_3:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP1_4;
            end
            EXEC_STATE_BEG_BOTH_IND_OP1_4:begin
                acc_in=mdr_wire;
                ld_trigger=ACC_MASK;
                state_reg_next=EXEC_STATE_BEG_BOTH_OP2;
            end
            EXEC_STATE_BEG_BOTH_OP2:begin
                mar_in={3'h0,operand_2};
                ld_trigger=MAR_MASK;
                if(operand_2_adr==MEMORY_DIRECT_ADR)begin
                    state_reg_next=EXEC_STATE_BEG_BOTH_DIR_OP2_WAIT;
                end
                else begin
                    state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP2_WAIT;
                end
            end
            EXEC_STATE_BEG_BOTH_DIR_OP2_WAIT:begin
                state_reg_next=EXEC_STATE_BEG_BOTH_DIR_OP2;
            end
            EXEC_STATE_BEG_BOTH_DIR_OP2:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_BEG_BOTH_JUMP;
            end
            EXEC_STATE_BEG_BOTH_IND_OP2_WAIT:begin
                state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP2;
            end
            EXEC_STATE_BEG_BOTH_IND_OP2:begin
                mdr_reg=mem;
                state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP2_2;
            end
            EXEC_STATE_BEG_BOTH_IND_OP2_2:begin
                mar_in=mdr_reg[5:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP2_3_WAIT;
            end
            EXEC_STATE_BEG_BOTH_IND_OP2_3_WAIT:begin
                state_reg_next=EXEC_STATE_BEG_BOTH_IND_OP2_3;
            end
            EXEC_STATE_BEG_BOTH_IND_OP2_3:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_BEG_BOTH_JUMP;
            end
            EXEC_STATE_BEG_BOTH_JUMP:begin //acc=op1 mdr=op2
                if(operand_1_full!=4'h0 && operand_2_full!=4'h0)begin
                    if(acc_wire==mdr_wire)begin
                        pc_in=ir_low_wire[5:0];
                        ld_trigger=PC_MASK;
                        state_reg_next=FETCH_STATE_MAR_IN;
                    end
                    else state_reg_next=FETCH_STATE_MAR_IN;
                end
                else if(operand_1_full!=4'h0)begin
                    if(acc_wire==4'h0)begin
                        pc_in=ir_low_wire[5:0];
                        ld_trigger=PC_MASK;
                        state_reg_next=FETCH_STATE_MAR_IN;
                    end
                    else state_reg_next=FETCH_STATE_MAR_IN;
                end
                else begin
                    if(mdr_wire==4'h0)begin
                        pc_in=ir_low_wire[5:0];
                        ld_trigger=PC_MASK;
                        state_reg_next=FETCH_STATE_MAR_IN;
                    end
                    else state_reg_next=FETCH_STATE_MAR_IN;
                end
            end
     
//----------------------------------------------------------//     
            EXEC_STATE_ALU:begin
                if(operand_2_adr==MEMORY_DIRECT_ADR)begin
                    mar_in={3'h0,operand_2};
                    ld_trigger=MAR_MASK;
                    state_reg_next=EXEC_STATE_ALU_OPERAND_1_DIR_1_WAIT;
                end
                else begin
                    mar_in={3'h0,operand_2};
                    ld_trigger=MAR_MASK;
                    mdr_reg=mdr_wire;
                    state_reg_next=EXEC_STATE_ALU_OPERAND_1_IND_1_WAIT;
                end
            end
            EXEC_STATE_ALU_OPERAND_1_IND_1_WAIT:
                state_reg_next=EXEC_STATE_ALU_OPERAND_1_IND_1;
            EXEC_STATE_ALU_OPERAND_1_IND_1:begin
                mdr_reg=mem;
                state_reg_next=EXEC_STATE_ALU_OPERAND_1_IND_2; 
            end
            EXEC_STATE_ALU_OPERAND_1_IND_2:begin
                mar_in=mdr_reg[5:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_ALU_OPERAND_1_DIR_1_WAIT; 
            end
            EXEC_STATE_ALU_OPERAND_1_DIR_1_WAIT:begin
                state_reg_next=EXEC_STATE_ALU_OPERAND_1_DIR_1;
            end
            EXEC_STATE_ALU_OPERAND_1_DIR_1:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_ALU_OPERAND_1_DIR_2;
            end
            EXEC_STATE_ALU_OPERAND_1_DIR_2:begin
                alu_operand_1=mdr_wire;
                        if(operand_3_adr==MEMORY_DIRECT_ADR)begin
                        mar_in={3'h0,operand_3};
                        ld_trigger=MAR_MASK;
                        state_reg_next=EXEC_STATE_ALU_OPERAND_2_DIR_1_WAIT;
                    end
                    else begin
                        mar_in={3'h0,operand_3};
                        ld_trigger=MAR_MASK;
                        mdr_reg=mdr_wire;
                        state_reg_next=EXEC_STATE_ALU_OPERAND_2_IND_1_WAIT;
                    end
            end
            EXEC_STATE_ALU_OPERAND_2_IND_1_WAIT:
                state_reg_next=EXEC_STATE_ALU_OPERAND_2_IND_1;
            EXEC_STATE_ALU_OPERAND_2_IND_1:begin
                mdr_reg=mem;
                state_reg_next=EXEC_STATE_ALU_OPERAND_2_IND_2; 
            end
            EXEC_STATE_ALU_OPERAND_2_IND_2:begin
                mar_in=mdr_reg[5:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_ALU_OPERAND_2_DIR_1_WAIT; 
            end
            EXEC_STATE_ALU_OPERAND_2_DIR_1_WAIT:begin
                state_reg_next=EXEC_STATE_ALU_OPERAND_2_DIR_1;
            end        
            EXEC_STATE_ALU_OPERAND_2_DIR_1:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_ALU_OPERAND_2_DIR_2_WAIT;
            end
            EXEC_STATE_ALU_OPERAND_2_DIR_2_WAIT:
                state_reg_next=EXEC_STATE_ALU_OPERAND_2_DIR_2;
            EXEC_STATE_ALU_OPERAND_2_DIR_2:begin
                alu_operand_2=mdr_wire;
                alu_oc=(operation_code-1)& 3'b111;
                state_reg_next=EXEC_STATE_ALU_OPERAND_2_DIR_3;
            end
            EXEC_STATE_ALU_OPERAND_2_DIR_3:begin
                mdr_in=alu_output;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_ALU_EXEC;
            end
            EXEC_STATE_ALU_EXEC:begin
                mar_in={3'h0,operand_1};
                ld_trigger=MAR_MASK;
                if(operand_1_adr==MEMORY_DIRECT_ADR)begin
                    state_reg_next=EXEC_STATE_ALU_WRITE;
                end
                else
                    state_reg_next=EXEC_STATE_ALU_IND_WRITE_1_WAIT;
            end
            EXEC_STATE_ALU_IND_WRITE_1_WAIT:
                state_reg_next=EXEC_STATE_ALU_IND_WRITE_1;
            EXEC_STATE_ALU_IND_WRITE_1:begin
                mdr_reg=mem;
                state_reg_next=EXEC_STATE_ALU_IND_WRITE_2;
            end
            EXEC_STATE_ALU_IND_WRITE_2:begin
                mar_in=mdr_reg[ADDR_WIDTH-1:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_ALU_WRITE;
            end
            EXEC_STATE_ALU_WRITE:begin
                we_reg_next=1'b1;
                state_reg_next=FETCH_STATE_MAR_IN;
            end
//----------------------------------------------------------//
            EXEC_STATE_IN_SET_STATUS:begin
                status_reg_next=1'b1;
                state_reg_next=EXEC_STATE_IN_CHECK_STATUS;
            end
            EXEC_STATE_IN_CHECK_STATUS:begin
                if(status_reg==1'b1)state_reg_next=EXEC_STATE_IN;
                else state_reg_next=EXEC_STATE_IN_CHECK_STATUS;
            end
            EXEC_STATE_IN:begin
                mar_in={3'b0,operand_1};
                ld_trigger=MAR_MASK;
                if(operand_1_adr==MEMORY_DIRECT_ADR)begin
                    state_reg_next=EXEC_STATE_IN_DIR;
                end
                else begin
                    state_reg_next=EXEC_STATE_IN_IND_1_WAIT;
                end
            end
            EXEC_STATE_IN_DIR:begin
                mdr_in=in;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_IN_WRITE;
            end
            EXEC_STATE_IN_IND_1_WAIT:
                state_reg_next=EXEC_STATE_IN_IND_1;
            EXEC_STATE_IN_IND_1:begin
                mdr_reg=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_IN_IND_2;
            end
            EXEC_STATE_IN_IND_2:begin
                mar_in=mdr_wire;
                mdr_in=in;
                ld_trigger=MDR_MASK|MAR_MASK;
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_IN_WRITE;
            end
            EXEC_STATE_IN_WRITE:begin
                we_reg_next=1'b1;
                state_reg_next=FETCH_STATE_MAR_IN;
            end
//----------------------------------------------------------//
           EXEC_STATE_OUT :begin
                mar_in={3'b0,operand_1};
                ld_trigger=MAR_MASK;
                if(operand_1_adr==MEMORY_DIRECT_ADR)begin
                    state_reg_next=EXEC_STATE_OUT_2;
                end
                else begin
                    state_reg_next=EXEC_STATE_OUT_IND_1_WAIT;
                end
            end
            EXEC_STATE_OUT_IND_1_WAIT:
                state_reg_next=EXEC_STATE_OUT_IND_1;
            EXEC_STATE_OUT_IND_1:begin
                mdr_reg=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_OUT_IND_2;
            end
            EXEC_STATE_OUT_IND_2:begin
                mar_in=mdr_reg[ADDR_WIDTH-1:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_OUT_2;
            end
            EXEC_STATE_OUT_2:begin
            state_reg_next=EXEC_STATE_OUT_2_1;
            end
            EXEC_STATE_OUT_2_1:begin
                 mdr_in=mem;
                 ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_OUT_3;
            end
            EXEC_STATE_OUT_3:begin
                state_reg_next=EXEC_STATE_OUT_3_1;
            end
            EXEC_STATE_OUT_3_1:begin
                state_reg_next=EXEC_STATE_OUT_4;
            end
            EXEC_STATE_OUT_4:begin
               out_reg_next=mdr_wire;
                state_reg_next=FETCH_STATE_MAR_IN;
            end
//----------------------------------------------------------//
            EXEC_STATE_STOP:begin
                if(operand_1_full==4'h0 && operand_2_full==4'h0 && operand_2_full==4'h0)begin
                    state_reg_next=HALT;
                end
                else if(operand_1_full!=4'h0)begin
                    if (operand_1_adr==MEMORY_DIRECT_ADR)begin
                        mar_in={3'b0,operand_1};
                        ld_trigger=MAR_MASK;
                        state_reg_next=EXEC_STATE_STOP_OUT_OP_1_WAIT;
                    end
                    else begin
                        mar_in={3'b0,operand_1};
                        ld_trigger=MAR_MASK;           
                        state_reg_next=EXEC_STATE_STOP_IND_OP_1_WAIT;             
                    end
                end
                else if(operand_2_full!=4'h0)begin
                    state_reg_next=EXEC_STATE_STOP_OP_2;
                end 
                else begin
                    state_reg_next=EXEC_STATE_STOP_OP_3;
                end
            end
            EXEC_STATE_STOP_IND_OP_1_WAIT:
                state_reg_next=EXEC_STATE_STOP_IND_OP_1;
            EXEC_STATE_STOP_IND_OP_1:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_STOP_IND_OP_1_2_WAIT;
            end
            EXEC_STATE_STOP_IND_OP_1_2_WAIT:
                state_reg_next=EXEC_STATE_STOP_IND_OP_1_2;
            EXEC_STATE_STOP_IND_OP_1_2:begin
                mar_in=mdr_wire[ADDR_WIDTH-1:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_STOP_OUT_OP_1_WAIT;
            end
            EXEC_STATE_STOP_OUT_OP_1_WAIT:
                state_reg_next=EXEC_STATE_STOP_OUT_OP_1;
            EXEC_STATE_STOP_OUT_OP_1:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_STOP_CHECK_OP_2_WAIT;
            end
            EXEC_STATE_STOP_CHECK_OP_2_WAIT:
                state_reg_next=EXEC_STATE_STOP_CHECK_OP_2;
            EXEC_STATE_STOP_CHECK_OP_2:begin
                out_reg_next=mdr_wire;
                if(operand_2_full!=4'h0) state_reg_next=EXEC_STATE_STOP_OP_2;
                else state_reg_next=EXEC_STATE_STOP_OP_3;
            end
            EXEC_STATE_STOP_OP_2:begin
                if (operand_2_adr==MEMORY_DIRECT_ADR)begin
                    mar_in={3'h0,operand_2};
                    ld_trigger=MAR_MASK;
                    state_reg_next=EXEC_STATE_STOP_OUT_OP_2_WAIT;
                end
                else begin
                    mar_in={3'h0,operand_2};
                    ld_trigger=MAR_MASK;           
                    state_reg_next=EXEC_STATE_STOP_IND_OP_2_WAIT;             
                end
            end
            EXEC_STATE_STOP_IND_OP_2_WAIT:
                state_reg_next=EXEC_STATE_STOP_IND_OP_2;
            EXEC_STATE_STOP_IND_OP_2:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_STOP_IND_OP_2_2_WAIT;
            end
            EXEC_STATE_STOP_IND_OP_2_2_WAIT:
                state_reg_next=EXEC_STATE_STOP_IND_OP_2_2;
            EXEC_STATE_STOP_IND_OP_2_2:begin
                mar_in=mdr_wire[ADDR_WIDTH-1:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_STOP_OUT_OP_2_WAIT;
            end
            EXEC_STATE_STOP_OUT_OP_2_WAIT:
                state_reg_next=EXEC_STATE_STOP_OUT_OP_2;
            EXEC_STATE_STOP_OUT_OP_2:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_STOP_CHECK_OP_3_WAIT;
            end
            EXEC_STATE_STOP_CHECK_OP_3_WAIT:
                state_reg_next=EXEC_STATE_STOP_CHECK_OP_3;
            EXEC_STATE_STOP_CHECK_OP_3:begin
                out_reg_next=mdr_wire;
                if(operand_3_full!=4'h0) state_reg_next=EXEC_STATE_STOP_OP_3;
                else state_reg_next=HALT;
            end
            EXEC_STATE_STOP_OP_3:begin
                if (operand_3_adr==MEMORY_DIRECT_ADR)begin
                    mar_in={3'h0,operand_3};
                    ld_trigger=MAR_MASK;
                    state_reg_next=EXEC_STATE_STOP_OUT_OP_3_WAIT;
                end
                else begin
                    mar_in={3'h0,operand_3};
                    ld_trigger=MAR_MASK;           
                    state_reg_next=EXEC_STATE_STOP_IND_OP_3_WAIT;             
                end
            end
            EXEC_STATE_STOP_IND_OP_3_WAIT:
                state_reg_next=EXEC_STATE_STOP_IND_OP_3;
            EXEC_STATE_STOP_IND_OP_3:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_STOP_IND_OP_3_2_WAIT;
            end
            EXEC_STATE_STOP_IND_OP_3_2_WAIT:
                state_reg_next=EXEC_STATE_STOP_IND_OP_3_2;
            EXEC_STATE_STOP_IND_OP_3_2:begin
                mar_in=mdr_wire[ADDR_WIDTH-1:0];
                ld_trigger=MAR_MASK;
                state_reg_next=EXEC_STATE_STOP_OUT_OP_3_WAIT;
            end
            EXEC_STATE_STOP_OUT_OP_3_WAIT:
                state_reg_next=EXEC_STATE_STOP_OUT_OP_3;
            EXEC_STATE_STOP_OUT_OP_3:begin
                mdr_in=mem;
                ld_trigger=MDR_MASK;
                state_reg_next=EXEC_STATE_STOP_OUT_OP_3_1_WAIT;
            end
            EXEC_STATE_STOP_OUT_OP_3_1_WAIT:
                state_reg_next=EXEC_STATE_STOP_OUT_OP_3_1;
            EXEC_STATE_STOP_OUT_OP_3_1:begin
                out_reg_next=mdr_wire;
                state_reg_next=HALT;
            end
            HALT:begin
                state_reg_next=HALT;
            end
            default:begin
                state_reg_next=RESET_STATE;
            end
        endcase

    end



endmodule