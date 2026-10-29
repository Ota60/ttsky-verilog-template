module alu(a,b,opcode,r);
    input [31:0] a;
    input [31:0] b;
    input [6:0] opcode;
    output reg [31:0] r;

    always @* begin
        r = 32'b0;
        case (opcode)

            7'b0: r = 32'b0;
            7'b0000001: r = a+b;
        endcase
    end
endmodule
