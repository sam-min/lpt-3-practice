`define ZERO 8'b0
`define GARBAGE 8'bx

//
module Loader(  
    input [1:0] Rn,
    input w,
    input [7:0] rin,
    output reg [7:0] R0, R1, R2, R3, out
);
always @(*) begin
    if (w<=1) begin
        case (Rn)
            2'b00: R0 = rin; // load R0
            2'b01: R1 = rin; // load R1
            2'b10: R2 = rin; // load R2
            2'b11: R3 = rin; // load R3
            default: begin
                     R0 = `GARBAGE;   // default case
                     R1 = `GARBAGE; 
                     R2 = `GARBAGE;
                     R3 = `GARBAGE;
    	end
        endcase
    end
    else begin // retain previous values
        R0 = R0;
        R1 = R1; 
        R2 = R2;
        R3 = R3;
    end
    out = R0;
end
endmodule
//

//
module mux_1 (
    input [2:0] bsel,
    input [7:0] R1, R2, R3,
    output reg [7:0] Bin
);
    always @(*) begin
        case (bsel)
            3'b000: Bin = R1; 
            3'b001: Bin = R2; 
            3'b010: Bin = R3;
            default: Bin = `GARBAGE;  // default case
        endcase
    end
endmodule
//

//
module mux_2_clock (
    input [2:0] tsel,
    input lt,
    output reg [7:0] tmp,
    input [7:0] alu_out, out, Bin
);
    always @(posedge lt) begin
        case (tsel)
        3'b000: tmp <= alu_out; 
        3'b001: tmp <= out; 
        3'b010: tmp <= Bin;
        default: tmp <= `GARBAGE;  // default case
    endcase
end
endmodule
//

//
module mux_3 (
    input [1:0] sr,
    input lt,
    input [7:0] in, alu_out, tmp,
    output reg [7:0] rin
);
    always @(*) begin
        case (sr)
            2'b00: rin = in; 
            2'b01: rin = alu_out; 
            2'b10: rin = tmp;
            default: rin = `GARBAGE;  // default case
        endcase
    end
endmodule
//

//
module ALU(
    input [7:0] tmp, Bin,
    input [1:0] aluop,
    output reg [7:0] alu_out
);
    always @(*) begin
        case(aluop)
            2'b00: alu_out = tmp ^ Bin; // XOR
            2'b01: alu_out = tmp & Bin; // AND
            2'b10: alu_out = tmp << 1; // Bitwise left shift
            2'b11: alu_out = Bin; 
            default: alu_out = `GARBAGE; //default case
        endcase
    end
endmodule
//

//
module q1 (clk,in,sr,Rn,w,aluop,lt,tsel,bsel,out);

input clk, w, lt;
input [7:0] in;
input [1:0] sr, Rn, aluop;
input [2:0] bsel, tsel;
output [7:0] out;

    reg [7:0] rin;
    reg [7:0] R0, R1, R2, R3;
    //Loader instantiation
    Loader loader(
        .Rn(Rn),
        .w(w),
        .rin(rin),
        .R0(R0),
        .R1(R1),
        .R2(R2),
        .R3(R3),
        .out(out)
    );
    
    reg [7:0] Bin;
    //mux_1 instantiation
    mux_1 mux_1(
        .bsel(bsel),
        .R1(R1),
        .R2(R2),
        .R3(R3),
        .Bin(Bin)
    );

    reg [7:0] tmp;
    reg [7:0] alu_out;

    //mux_2_clock instantiation
    mux_2_clock mux_2_clock(
        .tsel(tsel),
        .tmp(tmp),
        .alu_out(alu_out),
        .out(out),
        .Bin(Bin),
        .lt(lt)
    );

    //mux_3 instantiation
    mux_3 mux_3(
        .sr(sr),
        .in(in),
        .alu_out(alu_out),
        .tmp(tmp),
        .rin(rin)
    );

    //ALU instantiation
    ALU alu(
        .Bin(Bin),
        .tmp(tmp),
        .aluop(aluop),
        .alu_out(alu_out)
    );

endmodule
//
